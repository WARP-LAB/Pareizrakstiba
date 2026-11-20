#!/usr/bin/env bash
# validate-installer.sh — check that the release DMG is ready to distribute:
# signed with Developer ID, secure timestamps, hardened runtime, notarized,
# stapled and accepted by Gatekeeper. Prints one PASS/FAIL line per check
# and exits non-zero if any check fails.
#
# Everything is checked from the DMG itself (the .pkg and the uninstaller
# are taken from inside it), so a DMG downloaded from a GitHub release can
# be checked the same way as a freshly built one.
#
# Usage:
#   ./validate-installer.sh                       # ../../dmg/Pareizrakstiba.dmg
#   ./validate-installer.sh path/to/Pareizrakstiba.dmg
#
# Gatekeeper (spctl) may ask Apple's servers for items without a stapled
# ticket (the uninstaller), so run it online.

set -euo pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
REPO_ROOT=$( cd "${SCRIPT_DIR}/../.." && pwd )

SERVICE_NAME="Pareizrakstiba.service"
PKG_NAME="Pareizrakstiba.pkg"
UNINSTALLER_NAME="Uninstall Pareizrakstiba.app"

case "${1:-}" in
	-h | --help)
		sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
		exit 0
		;;
esac

DMG="${1:-${REPO_ROOT}/dmg/Pareizrakstiba.dmg}"
if [ ! -f "${DMG}" ]; then
	echo "error: no DMG at '${DMG}' (run make-installer.sh --notarize yes first)" >&2
	exit 1
fi

# Physical path (/private/var/...), as the mount table lists it
WORK_DIR=$( cd "$(mktemp -d)" && pwd -P )
MOUNT_DIR="${WORK_DIR}/mnt"
MOUNTED=no

cleanup() {
	if [ "${MOUNTED}" = yes ]; then
		hdiutil detach -quiet "${MOUNT_DIR}" || hdiutil detach -quiet -force "${MOUNT_DIR}" || true
	fi
	# never recurse into a volume that is still mounted
	if ! grep -qF " on ${MOUNT_DIR} " <<< "$(mount)"; then
		rm -rf "${WORK_DIR}"
	fi
}
trap cleanup EXIT

PASSED=0
FAILED=0
TEAMS=()

pass() {
	echo "  [PASS] $1"
	PASSED=$((PASSED + 1))
}

# fail "label" ["output to show"]
fail() {
	echo "  [FAIL] $1"
	FAILED=$((FAILED + 1))
	if [ -n "${2:-}" ]; then
		printf '%s\n' "$2" | sed 's/^/         | /'
	fi
}

# check "label" command...: passes when the command exits 0
check() {
	local label=$1 out
	shift
	if out=$("$@" 2>&1); then
		pass "${label}"
	else
		fail "${label}" "${out}"
	fi
}

# expect "label" "output" "extended regex": passes when the output matches
expect() {
	if grep -qE "$3" <<< "$2"; then
		pass "$1"
	else
		fail "$1" "$2"
	fi
}

# code_signature "label" path runtime(yes|no): Developer ID Application,
# secure timestamp, optionally hardened runtime; records the team ID
code_signature() {
	local label=$1 path=$2 runtime=$3 info
	check "${label}: signature valid (strict)" codesign --verify --deep --strict --verbose=2 "${path}"
	info=$(codesign -dvv "${path}" 2>&1 || true)
	expect "${label}: signed by Developer ID Application" "${info}" '^Authority=Developer ID Application: '
	expect "${label}: secure timestamp" "${info}" '^Timestamp='
	if [ "${runtime}" = yes ]; then
		expect "${label}: hardened runtime" "${info}" '^CodeDirectory .*flags=0x[0-9a-f]*\(.*runtime.*\)'
	fi
	TEAMS+=("$(sed -n 's/^TeamIdentifier=//p' <<< "${info}")")
}

# gatekeeper "label" path spctl-args...: accepted as notarized Developer ID
gatekeeper() {
	local label=$1 path=$2 out
	shift 2
	if out=$(spctl --assess "$@" -vv "${path}" 2>&1) && grep -q '^source=Notarized Developer ID' <<< "${out}"; then
		pass "${label}"
	else
		fail "${label}" "${out}"
	fi
}

echo "Validating ${DMG}"

echo "==> DMG"
code_signature "dmg" "${DMG}" no
check "dmg: notarization ticket stapled" xcrun stapler validate "${DMG}"
gatekeeper "dmg: Gatekeeper accepts (notarized)" "${DMG}" --type open --context context:primary-signature

if hdiutil attach -nobrowse -noautoopen -readonly -mountpoint "${MOUNT_DIR}" "${DMG}" > /dev/null 2>&1; then
	MOUNTED=yes
	pass "dmg: mounts"
else
	fail "dmg: mounts"
fi

PKG="${MOUNT_DIR}/${PKG_NAME}"
UNINSTALLER="${MOUNT_DIR}/${UNINSTALLER_NAME}"

if [ "${MOUNTED}" = yes ] && [ -f "${PKG}" ]; then
	pass "dmg: contains ${PKG_NAME}"

	echo "==> Installer package (from the DMG)"
	# Status, notarization and leaf certificate lines; the rest is the chain
	PKG_INFO=$(pkgutil --check-signature "${PKG}" 2>&1 | grep -E 'Status:|Notarization:|^ *1\. ' || true)
	expect "pkg: signed for distribution" "${PKG_INFO}" 'signed by a developer certificate issued by Apple for distribution'
	expect "pkg: signed by Developer ID Installer" "${PKG_INFO}" 'Developer ID Installer: '
	expect "pkg: notarized" "${PKG_INFO}" 'Notarization: trusted by the Apple notary service'
	TEAMS+=("$(sed -n 's/.*Developer ID Installer: .*(\([A-Z0-9]*\)).*/\1/p' <<< "${PKG_INFO}" | head -n 1)")
	check "pkg: notarization ticket stapled" xcrun stapler validate "${PKG}"
	gatekeeper "pkg: Gatekeeper accepts (notarized)" "${PKG}" --type install

	echo "==> ${SERVICE_NAME} (from the package payload)"
	SERVICE=""
	if pkgutil --expand-full "${PKG}" "${WORK_DIR}/pkg" > /dev/null 2>&1; then
		SERVICE=$(find "${WORK_DIR}/pkg" -maxdepth 4 -type d -name "${SERVICE_NAME}" | head -n 1)
	fi
	if [ -n "${SERVICE}" ]; then
		VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${SERVICE}/Contents/Info.plist" 2>/dev/null || echo "?")
		pass "service: present in payload (version ${VERSION})"
		code_signature "service" "${SERVICE}" yes
	else
		fail "service: present in payload"
	fi
else
	fail "dmg: contains ${PKG_NAME}"
fi

if [ "${MOUNTED}" = yes ] && [ -d "${UNINSTALLER}" ]; then
	pass "dmg: contains ${UNINSTALLER_NAME}"

	echo "==> ${UNINSTALLER_NAME} (from the DMG)"
	code_signature "uninstaller" "${UNINSTALLER}" yes
	gatekeeper "uninstaller: Gatekeeper accepts (notarized)" "${UNINSTALLER}" --type exec
else
	fail "dmg: contains ${UNINSTALLER_NAME}"
fi

echo "==> Consistency"
# An unreadable team shows up as an empty entry, which also fails this
UNIQUE_TEAMS=$(printf '%s\n' "${TEAMS[@]}" | sort -u)
if [ -n "${UNIQUE_TEAMS}" ] && [ "$(grep -c '' <<< "${UNIQUE_TEAMS}")" -eq 1 ]; then
	pass "same team everywhere (${UNIQUE_TEAMS})"
else
	fail "same team everywhere (found: $(paste -sd ',' - <<< "${UNIQUE_TEAMS}"))"
fi

echo
echo "${PASSED} passed, ${FAILED} failed"
[ "${FAILED}" -eq 0 ]
