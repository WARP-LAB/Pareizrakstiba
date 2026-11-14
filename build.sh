#!/usr/bin/env bash
# Builds the Pareizrakstiba.service bundle and, by default, zips it, so no
# bare bundle is left on the system.
# Usage: ./build.sh [--configuration debug|release] [--zip yes|no] [extra xcodebuild arguments]

set -euo pipefail

CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
PAREIZ_XCODEPROJ="${CURRENT_DIR}/Pareizrakstiba.xcodeproj"
CONFIGURATION=Release
ZIP=yes

while [ $# -gt 0 ]; do
	case "$1" in
		-c | --configuration)
			[ $# -ge 2 ] || { echo "error: $1 needs a value (debug or release)" >&2; exit 1; }
			CONFIGURATION=$2
			shift 2
			;;
		--configuration=?*) CONFIGURATION=${1#*=}; shift ;;
		-z | --zip)
			[ $# -ge 2 ] || { echo "error: $1 needs a value (yes or no)" >&2; exit 1; }
			ZIP=$2
			shift 2
			;;
		--zip=?*) ZIP=${1#*=}; shift ;;
		-h | --help)
			cat <<EOF
Usage: $(basename "$0") [options] [extra xcodebuild arguments]

Options:
  -c, --configuration <debug|release>  Build configuration (default: release)
  -z, --zip <yes|no>                   Zip the .service bundle after building
                                       and remove the bare bundle (default: yes)
  -h, --help                           Show this help and exit

Any other arguments are passed through to xcodebuild, for example
MACOSX_DEPLOYMENT_TARGET=12.0.
EOF
			exit 0
			;;
		--) shift; break ;;
		*) break ;;
	esac
done

case "${CONFIGURATION}" in
	debug | Debug) CONFIGURATION=Debug ;;
	release | Release) CONFIGURATION=Release ;;
	*) echo "error: unknown configuration '${CONFIGURATION}' (expected debug or release)" >&2; exit 1 ;;
esac

case "${ZIP}" in
	yes | y | true) ZIP=yes ;;
	no | n | false) ZIP=no ;;
	*) echo "error: unknown zip value '${ZIP}' (expected yes or no)" >&2; exit 1 ;;
esac

xcrun xcodebuild -project "${PAREIZ_XCODEPROJ}" -target Pareizrakstiba -configuration "${CONFIGURATION}" "$@"

BUILT_DIR="${CURRENT_DIR}/build/${CONFIGURATION}"
SERVICE="${BUILT_DIR}/Pareizrakstiba.service"

if [ "${ZIP}" = yes ]; then
	VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${SERVICE}/Contents/Info.plist")
	ZIPFILE="${BUILT_DIR}/Pareizrakstiba_${VERSION}.zip"
	rm -f "${ZIPFILE}"
	ditto -c -k --keepParent "${SERVICE}" "${ZIPFILE}"
	rm -rf "${SERVICE}"
	echo "Build zipped to ${ZIPFILE}"
else
	echo "Build product left at ${SERVICE}"
fi
