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

/System/Library/CoreServices/pbs -flush

# ================================
# INSTALL
unzip Pareizrakstiba.service.zip
mv Pareizrakstiba.service ~/Library/Services/

# ================================
# POSTFLIGHT
/System/Library/CoreServices/pbs --flush
