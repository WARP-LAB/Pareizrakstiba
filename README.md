# Pareizrakstība

Pareizrakstība - Latvian spellcheck for macOS operating system.  
Service that adds support for system wide spellchecking in Latvian language.

## Requirements

* Built for macOS 10.13+ (it could be built for older deployment targets).  
* Tested on 10.15.5. and 10.13.6
* 64-bit only.
* For yet older OS versions, see [Pareizrakstiba-Archive](https://github.com/WARP-LAB/Pareizrakstiba-Archive).

## Installation

* See [Releases](https://github.com/WARP-LAB/Pareizrakstiba/releases).
* Use Installer package that is attached to release (usually named `Pareizrakstiba_<VERSION>_Installer.zip`).
* Check README.pdf within installer package before continuing.

## Notes

* Make sure that in applications Latvian spellcheck is selected *Edit : Spelling and Grammar : Show Spelling and Grammar : Latviešu (Pareizrakstiba)*
* Play around with settings under *System Preferences : Keyboard : Text*. Here you can also set preferred default spelling language (*Installer* also has a step which lets you choose Latvian as preferred).
* *LibreOffice* / *OpenOffice* et al. users have no need to download and install dictionaries from within these apps, for the mentioned applications use macOS system wide spellcheck. Besides, when using Pareizrakstība in the applications and adding new words, they will apply to the whole OS.
* Learned words are kept in `~/Library/Spelling/`
* Since Mac OS X 10.6 shortcut for the rarely used autocompletion list is either `Option+Esc` or `F5`, previously it was `Esc`.

## Additional information

* Pareizrakstība removes all previous versions.
* Pareizrakstība completely removes CheckSpell.
* Pareizrakstība completely removes cocoAspell.

## Building from source

#### Build

```sh
git clone --recursive git@github.com:WARP-LAB/Pareizrakstiba.git
cd Pareizrakstiba
bash build-release.sh
open build/Release
```

Resulting product is `Pareizrakstiba.service` bundle.

#### If already exists on the system - kill Pareizrakstiba service and remove it

```sh
sudo killall Pareizrakstiba > /dev/null 2>&1
sudo rm -rf ~/Library/Services/Pareizrakstiba.service
sudo rm -rf /Library/Services/Pareizrakstiba.service
sudo -k
```

#### Move the product to the correct install path

Move the resulting `Pareizrakstiba.service` bundle to one of the following locations 
* `~/Library/Services` for current user (create directory, if needed)
* `/Library/Services` for all users (check permissions)

#### Flush services

```sh
/System/Library/CoreServices/pbs -flush
```

## Version history

#### 2020.01

* 2020-07-02  
* Language dictionary and affix tables updated to latest stable 1.4.0 (2020-04-11)
* Hunspell updated to latest stable 1.7.0 (2018-11-12)
* Looked at Nuspell, but kept Hunspell for this version because I'm lazy
* Beta as it is not code signed.

#### 4.0

* 2018-01-19
* A version for Mac OS X 10.13 (64-bit) created.
* Language dictionary and affix tables updated to latest stable 1.3.0 (2016-09-16).
* Beta as it is not code signed.

#### 3.2

* 2015-07-02
* A version for Mac OS X 10.10+ (64-bit) created.
* Built w/ deployment target 10.9, so it should work also from 10.9.
* However v3.1 is still suggested for OS X 10.7 to 10.9.
* Language dictionary and affix tables updated to latest stable 1.1.0. (2015-05-21).
* Hunspell updated to latest stable 1.3.3. (2014-06-02).
* Beta as it is not code signed.

#### 3.1

* 2013-05-03
* A version for Mac OS X 10.7+ (32 & 64-bit) created.
* Language dictionary and affix tables updated to latest stable 0.9.6. (2013-04-15).
* Hunspell updated to latest stable 1.3.2. (2011-02-16).
* Beta as it is not certified and code signed.
* 
#### 3.01

* 2010-05-16
* Solved issue where Pareizraktība crashes if user checks text that contains characters that cannot be losslessly converted to ISO8859-13 character set.

#### 3.0

* 2010-04-19
* A version for Mac OS 10.6 (32 & 64-bit) created.
* Rewrite for OS 10.4 and 10.5.
* Language dictionary and affix tables updated to latest stable 0.9.1. (2010-04-22).
* Hunspell updated to latest stable 1.2.9. (2010-03-03).
* Enabled autocomplete. Possible word completions can be called by pressing ESC key.
* Various enhancements in the code.
* Releasing a preference pane System Preferences : Pareizrakstība that gives user ability to set various options for spellchecking has been postponed.

#### 2.1

* 2008-05-10
* Solved issue with Mac OS 10.4.

#### 2.0

* 2008-05-10
* Solved issue with iWork '08.
* Pareizrakstība now registers without vendor name.

#### 1.1

* 2008-04-01
* First public version.
* Finished documentation.

#### 1.0

* 2008-03-31
* Test version.
* Corrections made for Latvian affix table 0.7.3:
	- Affix and dictionary files are converted to UTF-8.
	- Some changes in aff (TRY UTF-8).
	- Removed all unnecessary information.

## License

[GNU GENERAL PUBLIC LICENSE, Version 2, June 1991](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
