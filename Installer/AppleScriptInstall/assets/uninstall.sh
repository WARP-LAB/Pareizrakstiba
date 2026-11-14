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
# Just to be sure
rm -rf $CURRENT_DIR/Pareizrakstiba.service

# ================================
# disbale it for this user
if [ $SYSVER_MIN -gt "5" ];
then
  # defaults write -g NSSpellCheckerAutomaticallyIdentifiesLanguages -bool FALSE > /dev/null 2>&1
  sudo -u $CONSOLE_USER defaults delete -g NSSpellCheckerAutomaticallyIdentifiesLanguages > /dev/null 2>&1
fi

# ================================
# Unset Latvian to be default language when launching application
if [ $SYSVER_MIN -gt "4" ];
then
  sudo -u $CONSOLE_USER defaults delete -g NSPreferredSpellServerLanguage > /dev/null 2>&1
fi

# ================================
# Kill Pareizrakstiba if running

killall Pareizrakstiba > /dev/null 2>&1
killall Pareizrakstiba.service > /dev/null 2>&1
sudo killall Pareizrakstiba > /dev/null 2>&1
sudo killall Pareizrakstiba.service > /dev/null 2>&1

# ================================
# Delete Pareizrakstiba if exists (including old system wide installation)

sudo rm -rf ~/Library/Services/Pareizrakstiba.service
sudo rm -rf /Library/Services/Pareizrakstiba.service

# ================================
# Remove old Pareizrakstiba installer stuff
sudo rm -rf /Library/Application\ Support/Pareizrakstiba
sudo rm -rf /Library/Receipts/pareizrakstiba.pkg
sudo rm -rf /Library/Receipts/Uzstādīt\ Pareizrakstību.pkg
sudo rm -rf /Library/Receipts/Izdzēst\ Pareizrakstību.pkg
sudo rm -rf /Library/Receipts/Latviešu\ valodas\ afiksu\ tabula\ un\ vārdnīca.pkg
sudo rm -rf /Library/Receipts/Latviešu\ valodas\ pareizrakstības\ pārbaude.pkg

# ================================
# Flush

if [ -f $PBS ];
then
  $PBS -flush
fi

