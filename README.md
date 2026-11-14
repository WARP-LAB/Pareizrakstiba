# Pareizrakstība

Pareizrakstība - Latvian spellcheck for macOS operating system.
Service that adds support for system wide spellchecking in Latvian language.

## Requirements

- Built for macOS 12+
- Tested on macOS 27 and macOS 12
- Universal (Intel & Apple Silicon)

## Older OS support

See [Pareizrakstiba-Archive](https://github.com/WARP-LAB/Pareizrakstiba-Archive).

## Installation

- See [Releases](https://github.com/WARP-LAB/Pareizrakstiba/releases).
- Use Installer package that is attached to release (usually named `Pareizrakstiba_<VERSION>_Installer.zip`).
- **Check README.pdf within installer package before continuing with Installer.app.**
- If you wish to use this service then before running _Installer_ you have enable the possibility of running unsigned apps on macOS (see README.pdf).

## Notes

- Check out official Apple macOS User Guide for [Check spelling and grammar on Mac](https://support.apple.com/en-gb/guide/mac-help/mchlp2299/mac)
- Make sure that in applications Latvian spellcheck is selected _Edit : Spelling and Grammar : Show Spelling and Grammar : Latviešu (Pareizrakstiba)_
- Play around with settings under _System Preferences : Keyboard : Text_. Here you can also set preferred default spelling language (_Installer_ also has a step which lets you choose Latvian as preferred).
- Rich text content in _Google Docs, Sheets & Slides_ on _Safari_, _Chrome_ and others can not be _reached_ by macOS system wide spellcheck because of how Google has coded their web applications.
- _LibreOffice_ / _OpenOffice_ et al. users have no need to download and install dictionaries from within these apps, for the mentioned applications use macOS system wide spellcheck. Besides, when using Pareizrakstība in the applications and adding new words, they will apply to the whole OS.
- Learned words are kept in `~/Library/Spelling/`
- Since Mac OS X 10.6 shortcut for the rarely used autocompletion list is either `Option+Esc` or `F5`, previously it was `Esc`.

## Additional information

- Pareizrakstība removes all previous versions.
- Pareizrakstība completely removes CheckSpell.
- Pareizrakstība completely removes cocoAspell.

## Building from source

### Build

```sh
git clone --recursive git@github.com:WARP-LAB/Pareizrakstiba.git
cd Pareizrakstiba
$(echo $SHELL) build.sh
open build/Release
```

The resulting product is `Pareizrakstiba.service` bundle.

#### If already exists on the system, kill Pareizrakstiba service and remove it

```sh
sudo killall Pareizrakstiba > /dev/null 2>&1
sudo rm -rf ~/Library/Services/Pareizrakstiba.service
sudo rm -rf /Library/Services/Pareizrakstiba.service
sudo -k
```

#### Move the product to the correct install path

Move the built `Pareizrakstiba.service` bundle to one of the following locations
- `~/Library/Services` for current user (create directory, if needed)
- `/Library/Services` for all users (check permissions)

#### Flush services

```sh
/System/Library/CoreServices/pbs -flush
```

## Version history

See [CHANGELOG.md](CHANGELOG.md).

## OS API / behaviour bugs

Bugs as reported to Apple by Pareizrakstība developer:
- <https://lists.apple.com/archives/Cocoa-dev/2009/Oct/msg00637.html>
- <https://lists.apple.com/archives/Cocoa-dev/2009/Oct/msg01212.html>

## License

[GNU GENERAL PUBLIC LICENSE, Version 2, June 1991](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
