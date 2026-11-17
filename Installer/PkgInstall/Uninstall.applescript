-- Uninstall Pareizrakstiba
-- Double-clickable uninstaller for the Pareizrakstiba spell server.
-- Steps:
--   1. tells the user what is about to happen
--   2. checks both install domains (/Library/Services and
--      ~/Library/Services); plain user read access is enough for that
--   3. presents the findings and asks for confirmation; only elevates
--      to administrator privileges when the system domain is involved
--   4. stops the running server, removes the .service bundle, forgets
--      the installer receipt and refreshes the macOS services cache
-- Learned words in ~/Library/Spelling are kept, they belong to the user.

on run
	-- Step 1: what is about to happen
	display dialog "This will remove Pareizrakstība spell checking from this Mac.

First, will check if installed at all, and if yes if for all users or only you." buttons {"Cancel", "Continue"} default button "Continue" cancel button "Cancel" with icon caution with title "Uninstall Pareizrakstība"

	-- Step 2: find installations in both domains
	set systemPath to quoted form of "/Library/Services/Pareizrakstiba.service"
	set userServicesPath to quoted form of (POSIX path of (path to home folder) & "Library/Services/Pareizrakstiba.service")
	set systemInstalled to do shell script "[ -d " & systemPath & " ] && echo yes || echo no"
	set userInstalled to do shell script "[ -d " & userServicesPath & " ] && echo yes || echo no"

	if systemInstalled is "no" and userInstalled is "no" then
		display dialog "No Pareizrakstība installation was found on this Mac." buttons {"OK"} default button "OK" with icon note with title "Uninstall Pareizrakstība"
		return
	end if

	-- Step 3: present the findings, confirm, decide on privileges
	if systemInstalled is "yes" and userInstalled is "yes" then
		set findingsText to "Pareizrakstība was found in two locations:

- /Library/Services, installed for all users
- ~/Library/Services, installed for this user

An administrator password will be asked to remove both."
		set needsAdmin to true
	else if systemInstalled is "yes" then
		set findingsText to "Pareizrakstība was found in /Library/Services, installed for all users.

An administrator password will be asked to remove it."
		set needsAdmin to true
	else
		set findingsText to "Pareizrakstība was found in ~/Library/Services, installed for this user only.

No administrator password is needed to remove it."
		set needsAdmin to false
	end if

	display dialog findingsText buttons {"Cancel", "Uninstall"} default button "Uninstall" cancel button "Cancel" with icon caution with title "Uninstall Pareizrakstība"

	-- Step 4: removal
	set shellScript to "killall Pareizrakstiba 2>/dev/null; killall Pareizrakstiba.service 2>/dev/null; if [ -x /System/Library/CoreServices/pbs ]; then /System/Library/CoreServices/pbs -flush >/dev/null 2>&1; fi; found=''; if [ -d /Library/Services/Pareizrakstiba.service ]; then rm -rf /Library/Services/Pareizrakstiba.service; found=\"$found all-users\"; fi; if [ -d " & userServicesPath & " ]; then rm -rf " & userServicesPath & "; found=\"$found current-user\"; fi; pkgutil --forget lv.warp.Pareizrakstiba.service >/dev/null 2>&1; if [ -x /System/Library/CoreServices/pbs ]; then /System/Library/CoreServices/pbs -flush >/dev/null 2>&1; fi; echo \"$found\""

	if needsAdmin then
		try
			set removedFor to do shell script shellScript with administrator privileges
		on error number -128
			-- user cancelled the password prompt
			return
		end try
	else
		set removedFor to do shell script shellScript
	end if

	if removedFor contains "all-users" and removedFor contains "current-user" then
		set whatWasDone to "Pareizrakstība was removed for all users and for this user."
	else if removedFor contains "all-users" then
		set whatWasDone to "Pareizrakstība was removed for all users."
	else if removedFor contains "current-user" then
		set whatWasDone to "Pareizrakstība was removed for this user."
	else
		set whatWasDone to "No Pareizrakstība installation was found on this Mac."
	end if

	display dialog whatWasDone & "

Learned words are kept in ~/Library/Spelling." buttons {"OK"} default button "OK" with icon note with title "Uninstall Pareizrakstība"
end run
