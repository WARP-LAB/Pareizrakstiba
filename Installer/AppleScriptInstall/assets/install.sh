#!/bin/sh

# Pareizrakstība - Latviešu valodas pareizrakstības pārbaude macOS operētājsistēmai
# Pareizrakstiba - Latvian spellcheck for macOS operating system
# Copyright (C) 2008-2020 Reinis Adovičs a.k.a. kroko

# current dir
CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# console user
CONSOLE_USER=$(ps aux | grep console | grep -v grep | cut -d' ' -f1)
# major.minor.revision
SYSVER="$(sw_vers -productVersion)"
# major.minor
SYSVER_MIN="${SYSVER#*.}"
# minor
SYSVER_MIN="${SYSVER_MIN%%.*}"
# pbs
PBS="/System/Library/CoreServices/pbs"

# touch ~/Desktop/debug.txt
# echo "UNINSTALL" >> ~/Desktop/debug.txt
# echo $CURRENT_DIR >> ~/Desktop/debug.txt
# echo $CONSOLE_USER >> ~/Desktop/debug.txt
# exit 0

# ================================
# Revoke elevated

sudo -k

# ================================
# Create user Services dir if not exists

mkdir -p ~/Library/Services/

# ================================
# Unpack, put into place

rm -rf $CURRENT_DIR/Pareizrakstiba.service
unzip $CURRENT_DIR/Pareizrakstiba.service.zip -d $CURRENT_DIR
mv $CURRENT_DIR/Pareizrakstiba.service ~/Library/Services/

# ================================
# Flush

if [ -f $PBS ];
then
  $PBS -flush
fi
