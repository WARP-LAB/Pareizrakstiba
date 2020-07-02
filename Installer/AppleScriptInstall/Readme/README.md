# Pareizrakstība Installation

This application is not signed as the developer is not willing to pay the Apple fee[1].  

If you wish to use this then before running *Installer* you have enable the possibility of running unsigned apps on macOS.

* Open *Terminal.app*.

* Search for it by name in *Spotlight* or find it under `/Applications/Utilities`.

* Copy and paste this one-liner command and hit *Enter*

	```sh
	sudo spctl --master-disable
	```
* You will be asked for administrator password, enter it.

* Visit *System Preferences : Security & Privacy : General* 

* Check that *Anywhere* is selected for *Allow apps downloaded from*

![](allow-anywhere.png)

* If not, then unlock *System Preferences* and set it to *Anywhere*

* Run *Installer.app*. You might have to use right-click and *Open* instead of double click. It can be used both for installing and uninstalling Pareizrakstība.

* On first use in any app using spellchecking you might be greeted with a dialog which will ask if you want to open Pareizrakstība as it is run for the first time. Clicking *Open* is suggested.

![](first-time.png)


[1] This project has been continued over a decade now. Although it was used widely in the community *donations never worked*. If you wish for it to be officially signed, for example you wish to run this in a strict corporate environment or plainly do not want to open up your system for unsigned apps, build it from source on every machine or contact the developer for options (you / community could sponsor the Apple fee so that signed version can be built).


```
Pareizrakstība - Latviešu valodas pareizrakstības pārbaude macOS operētājsistēmai
Pareizrakstiba - Latvian spellcheck for macOS operating system
Copyright (C) 2008-2020 Reinis Adovičs a.k.a. kroko

GNU GENERAL PUBLIC LICENSE
Version 2, June 1991
https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
```
