#!/bin/bash

# ================================
# ENABLE UNSIGNED

sudo spctl --master-disable

# ================================
# PREFLIGTH
mkdir -p ~/Library/Services/

sudo killall Pareizrakstiba
sudo killall Pareizrakstiba.service

sudo rm -rf ~/Library/Services/Pareizrakstiba.service
sudo rm -rf /Library/Services/Pareizrakstiba.service
sudo rm -rf /Library/Application\ Support/Pareizrakstiba
sudo rm -rf /Library/Receipts/pareizrakstiba.pkg
sudo rm -rf /Library/Receipts/Uzstādīt\ Pareizrakstību.pkg
sudo rm -rf /Library/Receipts/Izdzēst\ Pareizrakstību.pkg
sudo rm -rf /Library/Receipts/Latviešu\ valodas\ afiksu\ tabula\ un\ vārdnīca.pkg
sudo rm -rf /Library/Receipts/Latviešu\ valodas\ pareizrakstības\ pārbaude.pkg
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

/System/Library/CoreServices/pbs -flush

# ================================
# INSTALL
unzip Pareizrakstiba.service.zip
mv Pareizrakstiba.service ~/Library/Services/

# ================================
# POSTFLIGHT
/System/Library/CoreServices/pbs --flush