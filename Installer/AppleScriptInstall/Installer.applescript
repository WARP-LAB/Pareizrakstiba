set thisPath to POSIX path of ((path to me as text) & "::")
-- with title "Pareizrakst´ba" with icon caution
set dialog1Answer to button returned of (display dialog "Choose your action! Although Pareizrakst´ba will be set up per user not globally admin password will be asked (this installer needs to clean legacy stuff)." buttons {"Install", "Uninstall", "Cancel"} default button 3 with title "Pareizrakst´ba")
if dialog1Answer is "Install" then
	do shell script "/bin/bash " & thisPath & "assets/uninstall.sh" with administrator privileges
	do shell script "/bin/bash " & thisPath & "assets/enable-unsigned.sh" with administrator privileges
	do shell script "/bin/bash " & thisPath & "assets/install.sh"
	if button returned of (display dialog "Do you wish to set Latvian as preferred spelling language everywhere?" buttons {"No", "Yes"} default button 2 with title "Pareizrakst´ba") is "Yes" then
		do shell script "/bin/bash " & thisPath & "assets/force-default.sh" with administrator privileges
	end if
else if dialog1Answer is "Uninstall" then
	do shell script "/bin/bash " & thisPath & "assets/uninstall.sh" with administrator privileges
end if

