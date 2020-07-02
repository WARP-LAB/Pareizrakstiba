#!/bin/sh
CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
PAREIZ_XCODEPROJ="${CURRENT_DIR}/Pareizrakstiba.xcodeproj"
xcrun xcodebuild -project ${PAREIZ_XCODEPROJ} -target Pareizrakstiba -configuration Debug $@
