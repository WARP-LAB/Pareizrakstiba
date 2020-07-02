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
# starting 10.6 we have automatic language detection
# ...which does not work, see my tickets here
# https://lists.apple.com/archives/Cocoa-dev/2009/Oct/msg00637.html
# https://lists.apple.com/archives/Cocoa-dev/2009/Oct/msg01212.html

# disbale it for this user
if [ $SYSVER_MIN -gt "5" ];
then
  # defaults write -g NSSpellCheckerAutomaticallyIdentifiesLanguages -bool FALSE > /dev/null 2>&1
  sudo -u $CONSOLE_USER defaults write -g NSSpellCheckerAutomaticallyIdentifiesLanguages -bool FALSE > /dev/null 2>&1
fi

# ================================
# try forcing Latvian to be default language when launching applications
if [ $SYSVER_MIN -gt "4" ];
then
  # defaults write -g NSPreferredSpellServerLanguage 'lv' > /dev/null 2>&1
  sudo -u $CONSOLE_USER defaults write -g NSPreferredSpellServerLanguage 'lv' > /dev/null 2>&1
fi

# ================================
# Revoke elevated

sudo -k