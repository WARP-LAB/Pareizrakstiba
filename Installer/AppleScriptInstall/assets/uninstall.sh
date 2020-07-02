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
# Remove check spell and cocoAspell
sudo killall CheckSpell > /dev/null 2>&1
sudo killall cocoAspell > /dev/null 2>&1
sudo rm -rf /Library/Services/CheckSpell.service
sudo rm -rf /Library/Receipts/CheckSpell.mpkg
sudo rm -rf ~/Library/Services/CheckSpell.service
sudo rm -rf ~/Library/Services/cocoAspell.service
sudo rm -rf /Library/Application\ Support/cocoAspell
sudo rm -rf /Library/PreferencePanes/Spelling.prefPane
sudo rm -rf /usr/local/include/pspell
sudo rm -rf /usr/local/lib/aspell-0.60
sudo rm -rf /usr/local/bin/aspell
sudo rm -rf /usr/local/bin/aspell-import
sudo rm -rf /usr/local/bin/precat
sudo rm -rf /usr/local/bin/preunzip
sudo rm -rf /usr/local/bin/prezip
sudo rm -rf /usr/local/bin/prezip-bin
sudo rm -rf /usr/local/bin/pspell-config
sudo rm -rf /usr/local/bin/run-with-aspell
sudo rm -rf /usr/local/bin/word-list-compress
sudo rm -rf /usr/local/etc/aspell.conf
sudo rm -rf /usr/local/include/aspell.h
sudo rm -rf /usr/local/info/aspell-dev.info
sudo rm -rf /usr/local/info/aspell.info
sudo rm -rf /usr/local/lib/libaspell.*
sudo rm -rf /usr/local/lib/libpspell.*
sudo rm -rf /usr/local/man/man1/aspell-import.*
sudo rm -rf /usr/local/man/man1/aspell.*
sudo rm -rf /usr/local/man/man1/prezip-bin.*
sudo rm -rf /usr/local/man/man1/pspell-config.*
sudo rm -rf /usr/local/man/man1/run-with-aspell.*
sudo rm -rf /usr/local/man/man1/word-list-compress.*
sudo rm -rf ~/Library/Services/cocoAspell.service
sudo rm -rf /Library/Receipts/AspellEnglishDictionary.pkg
sudo rm -rf /Library/Receipts/aspell.pkg
sudo rm -rf /Library/Receipts/Spelling.pkg

# ================================
# Flush

if [ -f $PBS ];
then
  $PBS -flush
fi

