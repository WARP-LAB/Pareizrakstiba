#!/usr/bin/env bash
# make-installer.sh — build the Release .service, wrap it in a double-clickable
# macOS installer (.pkg) inside a .dmg, with optional signing and notarization.
#
# The Release build itself is delegated to ../../build.sh (bare bundle, no zip:
# the pkg wants the plain .service). The bundle is consumed into the package
# payload and removed from build/ right after, so no bare bundle is left.
#
# Usage:
#   ./make-installer.sh                       # unsigned, not notarized
#   ./make-installer.sh --sign yes            # signed (needs identities)
#   ./make-installer.sh --notarize yes        # signed + notarized (implies sign)
#
# Signing settings (only needed when the toggles are on). Each comes from the
# environment if set there, otherwise from the resolved Release build
# settings, i.e. Config/Local.xcconfig (see Config/Local.xcconfig.example):
#   CODE_SIGN_IDENTITY        Developer ID Application identity,
#                             signs the .service bundle and the .dmg
#   INSTALLER_SIGN_IDENTITY   Developer ID Installer identity, signs the .pkg
#   NOTARY_PROFILE            notarytool keychain profile name
#                             (default: notarytool)
#
# Output lives in ../../dmg/ (gitignored): the final .pkg, the final .dmg,
# and a work/ dir with intermediates.

set -euo pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
REPO_ROOT=$( cd "${SCRIPT_DIR}/../.." && pwd )
BUILD_SH="${REPO_ROOT}/build.sh"
OUT_DIR="${REPO_ROOT}/dmg"
WORK_DIR="${OUT_DIR}/work"

SERVICE_NAME="Pareizrakstiba.service"
SERVICE_BUNDLE_ID="lv.warp.Pareizrakstiba"
PKG_ID="lv.warp.Pareizrakstiba.service"

CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY:-}"
INSTALLER_SIGN_IDENTITY="${INSTALLER_SIGN_IDENTITY:-}"
NOTARY_PROFILE="${NOTARY_PROFILE:-}"

SIGN=no
NOTARIZE=no

while [ $# -gt 0 ]; do
	case "$1" in
		-s | --sign)
			[ $# -ge 2 ] || { echo "error: $1 needs a value (yes or no)" >&2; exit 1; }
			SIGN=$2
			shift 2
			;;
		--sign=?*) SIGN=${1#*=}; shift ;;
		-n | --notarize)
			[ $# -ge 2 ] || { echo "error: $1 needs a value (yes or no)" >&2; exit 1; }
			NOTARIZE=$2
			shift 2
			;;
		--notarize=?*) NOTARIZE=${1#*=}; shift ;;
		-h | --help)
			sed -n '2,24p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
			exit 0
			;;
		--)
			shift
			break
			;;
		*)
			echo "error: unknown option '$1' (see --help)" >&2
			exit 2
			;;
	esac
done

case "${SIGN}" in
	yes | y | true) SIGN=yes ;;
	no | n | false) SIGN=no ;;
	*) echo "error: unknown sign value '${SIGN}' (expected yes or no)" >&2; exit 1 ;;
esac

case "${NOTARIZE}" in
	yes | y | true) NOTARIZE=yes ;;
	no | n | false) NOTARIZE=no ;;
	*) echo "error: unknown notarize value '${NOTARIZE}' (expected yes or no)" >&2; exit 1 ;;
esac

# Notarization applies to signed artifacts only
if [ "${NOTARIZE}" = yes ] && [ "${SIGN}" = no ]; then
	echo "note: notarization requires signing, forcing --sign yes"
	SIGN=yes
fi

if [ "${SIGN}" = yes ]; then
	# Ask Xcode rather than parsing Local.xcconfig: this resolves includes,
	# [config=Release] conditions and $(...) references the same way the build does
	echo "==> Resolving signing settings (environment, else Release build settings)"
	RELEASE_SETTINGS=$(xcrun xcodebuild -project "${REPO_ROOT}/Pareizrakstiba.xcodeproj" \
		-target Pareizrakstiba -configuration Release -showBuildSettings 2>/dev/null)
	release_setting() {
		printf '%s\n' "${RELEASE_SETTINGS}" | sed -n "s/^ *$1 = //p" | head -n 1
	}
	[ -n "${CODE_SIGN_IDENTITY}" ] || CODE_SIGN_IDENTITY=$(release_setting CODE_SIGN_IDENTITY)
	[ -n "${INSTALLER_SIGN_IDENTITY}" ] || INSTALLER_SIGN_IDENTITY=$(release_setting INSTALLER_SIGN_IDENTITY)
	[ -n "${NOTARY_PROFILE}" ] || NOTARY_PROFILE=$(release_setting NOTARY_PROFILE)

	case "${CODE_SIGN_IDENTITY}" in
		"Developer ID Application: "*) ;;
		*)
			echo "error: CODE_SIGN_IDENTITY is '${CODE_SIGN_IDENTITY}', expected a Developer ID Application" >&2
			echo "       identity (option B in Config/Local.xcconfig, or set it in the environment)" >&2
			exit 1
			;;
	esac
	case "${INSTALLER_SIGN_IDENTITY}" in
		"Developer ID Installer: "*) ;;
		*)
			echo "error: INSTALLER_SIGN_IDENTITY is '${INSTALLER_SIGN_IDENTITY}', expected a Developer ID Installer" >&2
			echo "       identity (set it in Config/Local.xcconfig or in the environment)" >&2
			exit 1
			;;
	esac
	echo "    CODE_SIGN_IDENTITY      = ${CODE_SIGN_IDENTITY}"
	echo "    INSTALLER_SIGN_IDENTITY = ${INSTALLER_SIGN_IDENTITY}"
fi
NOTARY_PROFILE="${NOTARY_PROFILE:-notarytool}"
[ "${NOTARIZE}" = no ] || echo "    NOTARY_PROFILE          = ${NOTARY_PROFILE}"

echo "==> Building Release .service (via build.sh)"
"${BUILD_SH}" -c Release -z no

BUILT_SERVICE="${REPO_ROOT}/build/Release/${SERVICE_NAME}"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${BUILT_SERVICE}/Contents/Info.plist")

# Versionless output names: a GitHub release asset URL can always point at
# Pareizrakstiba.dmg / Pareizrakstiba.pkg whatever the version inside
PKG_OUT="${OUT_DIR}/Pareizrakstiba.pkg"
DMG_OUT="${OUT_DIR}/Pareizrakstiba.dmg"

echo "==> Staging payload (${SERVICE_NAME}, version ${VERSION})"
PAYLOAD_DIR="${WORK_DIR}/payload"
mkdir -p "${PAYLOAD_DIR}"
cp -R "${BUILT_SERVICE}" "${PAYLOAD_DIR}/${SERVICE_NAME}"

# The bundle now lives in the payload; do not leave a bare copy under
# build/ (build.sh -z no intentionally skipped its own removal)
rm -rf "${BUILT_SERVICE}"

if [ "${SIGN}" = yes ]; then
	echo "==> Signing ${SERVICE_NAME} (${CODE_SIGN_IDENTITY})"
	codesign --force --options runtime --timestamp --sign "${CODE_SIGN_IDENTITY}" \
		"${PAYLOAD_DIR}/${SERVICE_NAME}"
	codesign --verify --strict "${PAYLOAD_DIR}/${SERVICE_NAME}"
fi

# Build outputs can carry read-only files and codesign xattrs
# that make pkgbuild complain mid-copy
chmod -R u+w "${PAYLOAD_DIR}"

echo "==> Compiling Uninstall app"
osacompile -o "${WORK_DIR}/Uninstall Pareizrakstiba.app" "${SCRIPT_DIR}/Uninstall.applescript"

if [ "${SIGN}" = yes ]; then
	echo "==> Signing Uninstall app (${CODE_SIGN_IDENTITY})"
	codesign --force --options runtime --timestamp --sign "${CODE_SIGN_IDENTITY}" \
		"${WORK_DIR}/Uninstall Pareizrakstiba.app"
	codesign --verify --strict "${WORK_DIR}/Uninstall Pareizrakstiba.app"
fi

echo "==> Building component package"
pkgbuild --root "${PAYLOAD_DIR}" \
	--component-plist "${SCRIPT_DIR}/component.plist" \
	--identifier "${PKG_ID}" \
	--version "${VERSION}" \
	--install-location "/Library/Services" \
	--scripts "${SCRIPT_DIR}/scripts" \
	--ownership recommended \
	"${WORK_DIR}/Pareizrakstiba.component.pkg"

# pkgbuild hardcodes auth="root" in the PackageInfo; installing into the
# user home does not need admin rights, so drop it and let the chosen
# destination decide whether elevation is needed
pkgutil --expand "${WORK_DIR}/Pareizrakstiba.component.pkg" "${WORK_DIR}/component-expanded"
sed -i '' 's/ auth="root"//' "${WORK_DIR}/component-expanded/PackageInfo"
pkgutil --flatten "${WORK_DIR}/component-expanded" "${WORK_DIR}/Pareizrakstiba.component.pkg"
rm -rf "${WORK_DIR}/component-expanded"

echo "==> Building distribution package"
sed "s/@VERSION@/${VERSION}/g" "${SCRIPT_DIR}/dist.xml" > "${WORK_DIR}/dist.xml"
xcrun productbuild --distribution "${WORK_DIR}/dist.xml" \
	--package-path "${WORK_DIR}" \
	--resources "${SCRIPT_DIR}/resources" \
	"${WORK_DIR}/Pareizrakstiba.unsigned.pkg"

if [ "${SIGN}" = yes ]; then
	echo "==> Signing installer package (${INSTALLER_SIGN_IDENTITY})"
	xcrun productsign --sign "${INSTALLER_SIGN_IDENTITY}" \
		"${WORK_DIR}/Pareizrakstiba.unsigned.pkg" "${PKG_OUT}"
else
	mv "${WORK_DIR}/Pareizrakstiba.unsigned.pkg" "${PKG_OUT}"
fi

if [ "${NOTARIZE}" = yes ]; then
	echo "==> Notarizing installer package (${NOTARY_PROFILE})"
	xcrun notarytool submit "${PKG_OUT}" --keychain-profile "${NOTARY_PROFILE}" --wait
	xcrun stapler staple "${PKG_OUT}"
fi

echo "==> Building DMG"
DMG_STAGE="${WORK_DIR}/dmg-stage"
mkdir -p "${DMG_STAGE}"
cp "${PKG_OUT}" "${DMG_STAGE}/"
cp -R "${WORK_DIR}/Uninstall Pareizrakstiba.app" "${DMG_STAGE}/"
hdiutil create -volname "Pareizrakstība ${VERSION}" \
	-srcfolder "${DMG_STAGE}" -ov -format UDZO "${DMG_OUT}"

if [ "${SIGN}" = yes ]; then
	echo "==> Signing DMG (${CODE_SIGN_IDENTITY})"
	codesign --force --timestamp --sign "${CODE_SIGN_IDENTITY}" "${DMG_OUT}"
fi

if [ "${NOTARIZE}" = yes ]; then
	echo "==> Notarizing DMG (${NOTARY_PROFILE})"
	xcrun notarytool submit "${DMG_OUT}" --keychain-profile "${NOTARY_PROFILE}" --wait
	xcrun stapler staple "${DMG_OUT}"

	# What a downloader's Mac will check: fail here, not after a release
	echo "==> Checking Gatekeeper acceptance"
	xcrun stapler validate "${PKG_OUT}"
	xcrun stapler validate "${DMG_OUT}"
	spctl --assess --type install --verbose "${PKG_OUT}"
	spctl --assess --type open --context context:primary-signature --verbose "${DMG_OUT}"
fi

rm -rf "${WORK_DIR}"

echo "Installer package: ${PKG_OUT}"
echo "Disk image:        ${DMG_OUT}"
