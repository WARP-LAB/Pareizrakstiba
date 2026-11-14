# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

<!-- markdownlint-disable MD024 -->

## [Unreleased]

## [4.1.0] - 2020-07-02

- Beta as it is not code signed.
- Tagged as 2020.01

### Added

- A version for macOS 10.15 (64-bit) created.

### Changed

- Built w/ minimum deployment target macOS 10.13.
- Language dictionary and affix tables updated to latest stable 1.4.0 (2020-04-11).
- Hunspell updated to latest stable 1.7.0 (2018-11-12).
- Looked at Nuspell, but kept Hunspell for this version because I'm lazy.

## [4.0.0] - 2018-01-19

- Beta as it is not code signed.

### Added

- A version for macOS 10.13 (64-bit) created.

### Changed

- Built w/ minimum deployment target macOS 10.13.
- Language dictionary and affix tables updated to latest stable 1.3.0 (2016-09-16).

## [3.2.0] - 2015-07-02

- However v3.1 is still suggested for OS X 10.7 to 10.9.
- Beta as it is not code signed.

### Added

- A version for OS X 10.10+ (64-bit) created.

### Changed

- Built w/ minimum deployment target OS X 10.9.
- Language dictionary and affix tables updated to latest stable 1.1.0. (2015-05-21).
- Hunspell updated to latest stable 1.3.3. (2014-06-02).

## [3.1.0] - 2013-05-03

- Beta as it is not certified and code signed.

### Added

- A version for Mac OS X 10.7+ (32 & 64-bit) created.

### Changed

- Language dictionary and affix tables updated to latest stable 0.9.6. (2013-04-15).
- Hunspell updated to latest stable 1.3.2. (2011-02-16).

## [3.01.0] - 2010-05-16

### Fixed

- Solved issue where Pareizraktība crashes if user checks text that contains characters that cannot be losslessly converted to ISO8859-13 character set.

## [3.0.0] - 2010-04-19

- Releasing a preference pane _System Preferences : Pareizrakstība_ that gives user ability to set various options for spellchecking has been postponed.

### Added

- A version for Mac OS X 10.6 (32 & 64-bit) created.
- Enabled autocomplete. Possible word completions can be called by pressing `ESC` key.

### Changed

- Rewrite for Mac OS X 10.4 and 10.5.
- Language dictionary and affix tables updated to latest stable 0.9.1. (2010-04-22).
- Hunspell updated to latest stable 1.2.9. (2010-03-03).
- Various enhancements in the code.

## [2.1.0] - 2008-05-10

### Fixed

- Solved issue with Mac OS X 10.4.

## [2.0.0] - 2008-05-10

### Fixed

- Solved issue with iWork '08.

### Changed

- Pareizrakstība now registers without vendor name.

## [1.1.0] - 2008-04-01

### Added

- First public version.
- Finished documentation.

## [1.0.0] - 2008-03-31

- Test version.

### Changed

- Switched to Hunspell from Aspell

### Fixed

- Corrections made for Latvian dictionary and affix tables 0.7.3:
  - Affix and dictionary files are converted to UTF-8.
  - Some changes in aff (TRY UTF-8).
  - Removed all unnecessary information.

## [0.1.0] - 2008-02-01

- Local build only, based on Aspell / cocoAspell.
