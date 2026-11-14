#!/usr/bin/env bash
# Checks the hunspell submodule against the newest tag published upstream.
# If the pin already matches the latest tag, it says so and exits.
# If a newer tag exists, it asks before checking it out in the submodule.
# Staging and commiting the new gitlink in the parent repo is left to the user.
# Usage: ./check-update.sh [y|n]
#   An argument pre-answers the prompt if run scripted

set -euo pipefail

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SUPER=$( git -C "${SCRIPT_DIR}" rev-parse --show-toplevel )

SUBREL=$( git -C "${SUPER}" config --file "${SUPER}/.gitmodules" --get-regexp '\.path$' \
	| awk '{print $2}' | head -n 1 )
if [ -z "${SUBREL}" ]; then
	echo "error: no submodule entry found in .gitmodules" >&2
	exit 1
fi
SUB="${SUPER}/${SUBREL}"

if [ ! -e "${SUB}/.git" ]; then
	echo "error: submodule not initialized; run:" >&2
	echo "  git submodule update --init ${SUBREL}" >&2
	exit 1
fi

# The version the parent repo actually pins (may differ from the submodule's
# working tree if someone checked something out without staging it).
PIN=$( git -C "${SUPER}" rev-parse "HEAD:${SUBREL}" )
CURRENT=$( git -C "${SUB}" describe --tags "${PIN}" 2>/dev/null || echo "${PIN}" )

REMOTE_TAGS=$( git -C "${SUB}" ls-remote --tags origin || {
	echo "error: cannot list tags from the hunspell remote" >&2
	exit 1
} )
LATEST=$( printf '%s\n' "${REMOTE_TAGS}" \
	| sed -n 's|.*refs/tags/||p' \
	| grep -vF '^{}' || true )
LATEST=$( printf '%s\n' "${LATEST}" | sort -V | tail -n 1 )
if [ -z "${LATEST}" ]; then
	echo "error: no tags found on the hunspell remote" >&2
	exit 1
fi

echo "Current pin: ${CURRENT}"
echo "Latest tag:  ${LATEST}"

if [ "${CURRENT}" = "${LATEST}" ]; then
	echo "Already at the latest version, nothing to do."
	exit 0
fi

echo "A newer version is available: ${CURRENT} -> ${LATEST}"
ANSWER=${1:-}
if [ -z "${ANSWER}" ]; then
	printf 'Checkout %s in the submodule? [y/N] ' "${LATEST}"
	read -r ANSWER || ANSWER=""
fi
case "${ANSWER}" in
	y | Y) ;;
	*)
		echo "Left the submodule pinned at ${CURRENT}."
		exit 0
		;;
esac

git -C "${SUB}" fetch --tags origin
git -C "${SUB}" checkout --detach "${LATEST}"

echo
echo "Checked out ${LATEST} ($( git -C "${SUB}" rev-parse HEAD )) in ${SUBREL}."
echo "Regenerate config.h to match the new version:"
echo "  generate-config.sh"
echo "Stage the new pin and commit it:"
echo "  git add ${SUBREL}"
echo "  git commit [-S] -m \"pin hunspell submodule to ${LATEST}\""
