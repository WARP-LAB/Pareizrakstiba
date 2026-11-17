#!/usr/bin/env bash
# Builds the Pareizrakstiba.service bundle and, by default, zips it, so no
# bare bundle is left on the system.
# Optionally installs the built service into ~/Library/Services/, replacing
# the one already there (install forces the zip, the service is installed
# from the zip).
# Usage: ./build.sh [--configuration debug|release] [--zip yes|no] [--install yes|no] [extra xcodebuild arguments]

set -euo pipefail

CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
PAREIZ_XCODEPROJ="${CURRENT_DIR}/Pareizrakstiba.xcodeproj"
CONFIGURATION=Release
ZIP=yes
INSTALL=no

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
		-i | --install)
			[ $# -ge 2 ] || { echo "error: $1 needs a value (yes or no)" >&2; exit 1; }
			INSTALL=$2
			shift 2
			;;
		--install=?*) INSTALL=${1#*=}; shift ;;
		-h | --help)
			cat <<EOF
Usage: $(basename "$0") [options] [extra xcodebuild arguments]

Options:
  -c, --configuration <debug|release>  Build configuration (default: release)
  -z, --zip <yes|no>                   Zip the .service bundle after building
                                       and remove the bare bundle (default: yes)
  -i, --install <yes|no>               Install the built service into
                                       ~/Library/Services (default: no).
                                       Implies zip: the service is installed
                                       from the zip, whatever the zip setting
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

case "${INSTALL}" in
	yes | y | true) INSTALL=yes ;;
	no | n | false) INSTALL=no ;;
	*) echo "error: unknown install value '${INSTALL}' (expected yes or no)" >&2; exit 1 ;;
esac

# Install goes through the zip, whatever the zip setting
if [ "${INSTALL}" = yes ] && [ "${ZIP}" = no ]; then
	echo "note: install requires the zip, forcing --zip yes"
	ZIP=yes
fi

xcrun xcodebuild -project "${PAREIZ_XCODEPROJ}" -target Pareizrakstiba -configuration "${CONFIGURATION}" "$@"

BUILT_DIR="${CURRENT_DIR}/build/${CONFIGURATION}"
SERVICE="${BUILT_DIR}/Pareizrakstiba.service"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${SERVICE}/Contents/Info.plist")
ZIPFILE="${BUILT_DIR}/Pareizrakstiba_${VERSION}.zip"

if [ "${ZIP}" = yes ]; then
	rm -f "${ZIPFILE}"
	ditto -c -k --keepParent "${SERVICE}" "${ZIPFILE}"
	rm -rf "${SERVICE}"
	echo "Build zipped to ${ZIPFILE}"
else
	echo "Build product left at ${SERVICE}"
fi

if [ "${INSTALL}" = yes ]; then
	SERVICES_DIR="${HOME}/Library/Services"
	INSTALLED_ZIP="${SERVICES_DIR}/${ZIPFILE##*/}"

	# The spell server normally runs as the user, so no sudo is needed;
	# escalate only if something survives (e.g. owned by another user)
	stop_service_process() {
		local name=$1
		killall "$name" >/dev/null 2>&1 || true
		if pgrep -x "$name" >/dev/null 2>&1; then
			sudo killall "$name" >/dev/null 2>&1 || true
		fi
	}

	# preflight: stop the running spell server, drop the old service,
	# let the services cache know something is going away
	mkdir -p "${SERVICES_DIR}"
	stop_service_process Pareizrakstiba
	stop_service_process Pareizrakstiba.service
	rm -rf "${SERVICES_DIR}/Pareizrakstiba.service"
	if [ -e "${SERVICES_DIR}/Pareizrakstiba.service" ]; then
		sudo rm -rf "${SERVICES_DIR}/Pareizrakstiba.service"
	fi
	/System/Library/CoreServices/pbs -flush

	# install: copy the zip over and expand it into the plain .service bundle
	cp "${ZIPFILE}" "${INSTALLED_ZIP}"
	ditto -x -k "${INSTALLED_ZIP}" "${SERVICES_DIR}"

	# postflight: no dangling zip, refresh the services cache
	rm -f "${INSTALLED_ZIP}"
	/System/Library/CoreServices/pbs -flush

	echo "Installed ${SERVICES_DIR}/Pareizrakstiba.service"
fi
