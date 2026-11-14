# Pareizrakstība

Pareizrakstība - Latvian spellcheck for macOS operating system.
Service that adds support for system wide spellchecking in Latvian language.

## Requirements

- macOS 12+
- Tested on macOS 27 and macOS 12
- Universal (Intel & Apple Silicon)

## Older OS support

- macOS 10.13+ Universal [v4.1.0](https://github.com/WARP-LAB/Pareizrakstiba/releases/tag/v4.1.0)
- Mac OS X 10.7+ Intel 32 & 64-bit [Pareizrakstiba-Archive](https://github.com/WARP-LAB/Pareizrakstiba-Archive)

## Installation

- See [Releases](https://github.com/WARP-LAB/Pareizrakstiba/releases).
- Use Installer package that is attached to release (usually named `Pareizrakstiba_<VERSION>_Installer.zip`).
- **Check README.pdf within installer package before continuing with Installer.app.**
- If you wish to use this service then before running _Installer_ you have enable the possibility of running unsigned apps on macOS (see README.pdf).

## Usage

- Check out official Apple macOS User Guide for [Check spelling and grammar on Mac](https://support.apple.com/en-gb/guide/mac-help/mchlp2299/mac)
- Make sure that in applications Latvian spellcheck is selected _Edit : Spelling and Grammar : Show Spelling and Grammar : Latviešu (Pareizrakstiba)_
- _LibreOffice_ et al. users have no need to download and install dictionaries from within these apps, for the mentioned applications use macOS system wide spellcheck. Besides, when using Pareizrakstība in the applications and adding new words, they will apply to the whole OS.
- Rich text content in _Google Docs, Sheets & Slides_ on _Safari_, _Chrome_ and others can not be _reached_ by macOS system wide spellcheck because of how Google has coded their web applications.
- Learned spelling by user are kept in `~/Library/Spelling/` for the user.
- Shortcut for the rarely used autocompletion list is either `Option+Esc` or `F5` (before Mac OS X 10.6 it was `Esc`).

## Installation sidefects

Pareizrakstība upon install checks for and removes all previous versions.
Pareizrakstība does not check for CheckSpell and cocoAspell (and pspell). Historically it did, as first versions were playing with that.

## Building from source

### Build

```zsh
# clone
git clone --recurse-submodules git@github.com:WARP-LAB/Pareizrakstiba.git

# at this point you can pull in and configure latest hunspell (optional)
# read Hunspell submodule management

# build
./build.sh --help # specify config release|debug, zip yes|no
./build.sh

# profit
open build/Release # or build/Debug
```

The resulting product is `Pareizrakstiba.service` bundle (zipped by default).

### Hunspell submodule management

This is optional step.

Some helper scripts to pull in newer version and to reconfigure Hunspell if needed.

To (re)configure some extra (as in does not ship with macOS / Xcode CLT) build-time tooling is needed:
- `autotools` (namely `autoconf`, `automake`)
- `autopoint` (from `gettext`)
- `libtool` from GNU instead of Apple's (it will be advertised as `glibtoolize`)

```zsh
# check if newer tag exists, and if yes, you can checkout that
vendors/hunspell/check-update.sh

# for autoreconf
brew install automake libtool gettext

# generate <vendors/hunspell/config.h>
HUNSPELL_CONFIGURE_PATH="/opt/homebrew/bin:/usr/bin:/bin" vendors/hunspell/generate-config.sh
```

#### If already exists on the system, kill Pareizrakstiba service and remove it

You might not need sudo if it was running as user

```zsh
sudo killall Pareizrakstiba > /dev/null 2>&1
sudo rm -rf /Library/Services/Pareizrakstiba.service
sudo rm -rf ~/Library/Services/Pareizrakstiba.service
sudo -k
```

#### Move the product to the correct install path

Move the built `Pareizrakstiba.service` bundle to one of the following locations
- `~/Library/Services` for current user (create directory, if needed)
- `/Library/Services` for all users (check permissions)

#### Flush services

```zsh
/System/Library/CoreServices/pbs -flush
```

## Spelling configuration via CLI

A few one-liners to avoid digging through deeply buried checkboxes in macOS Settings.

```zsh
# Disable automatic language detection
defaults write NSGlobalDomain NSSpellCheckerAutomaticallyIdentifiesLanguages -bool FALSE

# Try to force Latvian as the default language when launching applications
defaults write NSGlobalDomain NSPreferredSpellServerLanguage 'lv'

# Disable system-wide autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool FALSE
```

## Clangd

Been using [clangd](https://clangd.llvm.org) for long time. And on VS Code that I use for this project now that means using [vscode-clangd](https://github.com/clangd/vscode-clangd?tab=readme-ov-file) instead of MS IntelliSense.

This will generate `compile_commands.json` to make clangd lang server happy

```zsh
./clangd_generate.sh
```

## Version history

See [CHANGELOG.md](CHANGELOG.md).

## OS API / behaviour bugs

Never resolved bugs as reported to Apple (OpenRadar):
- [https://lists.apple.com/archives/cocoa-dev/2009/oct/msg00637.html](https://web.archive.org/web/20240812193115/https://lists.apple.com/archives/cocoa-dev/2009/oct/msg00637.html)
- [https://lists.apple.com/archives/cocoa-dev/2009/Oct/msg01212.html](https://web.archive.org/web/20240724003520/https://lists.apple.com/archives/cocoa-dev/2009/Oct/msg01212.html)

## License

[GNU GENERAL PUBLIC LICENSE, Version 2, June 1991](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
