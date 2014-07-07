;PublicIPNotifier by Brandon
;Parameters for the script listed here
#SingleInstance, Force ;if the script is ran and it was already running, this will cause it to reload itself.
#NoEnv ;supposed to make compatibility better
;Set working directory to My Documents
SetWorkingDir %a_mydocuments%
;Set current public IP, store it in My Documents
ifnotexist,%a_workingdir%/mypubip.txt
{
	msgbox,Your Public IP has not been set yet or you deleted mypubip.txt out of My Documents. Press OK to set public IP and store it in mypubip.txt.
	URLDownloadToFile,http://www.netikus.net/show_ip.html, %A_workingdir%\mypubip.txt
	fileread,mypubip,%a_workingdir%\mypubip.txt
	msgbox,Public IP set to %mypubip%. Mypubip.txt will be checked daily to see if it matches current public IP address. When it changes, an email notification will be sent. Please set an email address to send this notification to.
	gui, 1:show, w567 h170, Enter Your Email Address
	gui, 1:font, s16
	gui, 1:add,text,,Enter your email address to be notified.
	gui, 1:add,edit,vemail
	guicontrol, 6:focus,email
	gui, 1:add,button,vbutsub2 default gsubmitemail,Submit
	exit
	submitemail:
	gui, 1:submit
	fileappend,`r`n%email%,%a_workingdir%\mypubip.txt
	msgbox,You set %email% as your email address. You can change this at any time by modifying the mypubip.txt file, your email address is stored in there. Email notifications will be sent from publicipnotifier.by.brandon@gmail.com.`n`n Please use Task Scheduler to schedule this application to run at whatever interval you like.
	gui, 1:destroy
	gosub dailyrun
	exit
}
else
	gosub dailyrun
dailyrun:
URLDownloadToFile,http://www.netikus.net/show_ip.html, %A_workingdir%\verifypubip.txt
fileread,verifypubip,%a_workingdir%\verifypubip.txt
fileread,mypubip,%a_workingdir%\mypubip.txt
filedelete,%a_workingdir%\verifypubip.txt
stringsplit,mypubipdata,mypubip,`r`n,`n,
ifinstring,mypubip,%verifypubip%
	exitapp

else
{
	URLDownloadToFile,https://raw.githubusercontent.com/Silverlink34/autoconnector/master/ver, %a_workingdir%\ver
	fileread,data,%a_workingdir%\ver
	filedelete,%a_workingdir%\ver
	emailpass := Decrypt(data,pass)
	emailtoaddress = %mypubipdata3%
	emailfromaddress = publicipnotifier.by.brandon@gmail.com
	emailsubject = Your Public IP Changed!
	emailmessage = Your public IP address is no longer %mypubipdata1%.`n`nIt has changed to %verifypubip%.`n`nPlease make necessary changes to domain names, firewall rules ect.`nYour public ip that was previously set with PublicIPNotifier has been updated to prevent further notifications.
	emailfromnodomain = publicipnotifier.by.brandon
	sendMail(emailToAddress,emailPass,emailFromAddress,emailSubject,emailMessage,EmailFromNoDomain)
	filedelete,%a_workingdir%\mypubip.txt
	fileappend,%verifypubip%`r`n%mypubipdata3%,%a_workingdir%\mypubip.txt
}
exitapp

;Email send functions below here
sendMail(emailToAddress,emailPass,emailFromAddress,emailSubject,emailMessage,EmailFromNoDomain)
	{
		fileinstall, mailsend.exe,%a_workingdir%\mailsend.exe,1
        mailsendlocation = %a_workingdir%
		Run, %mailsendlocation%\mailsend.exe -to %emailToAddress% -from %emailFromAddress% -ssl -smtp smtp.gmail.com -port 465 -sub "%emailSubject%" -M "%emailMessage%" +cc +bc -q -auth-plain -user "%emailFromNoDomain%" -pass "%emailPass%",, Hide
		filedelete,%a_workingdir%\mailsend.exe
	}

;Decrypt function listed here
Decrypt(Data,Pass) {
	b := 0, j := 0, x := "0x"
	VarSetCapacity(Result,StrLen(Data)//2)
	Loop 256
		a := A_Index - 1
		,Key%a% := Asc(SubStr(Pass, Mod(a,StrLen(Pass))+1, 1)) 
		,sBox%a% := a
	Loop 256
		a := A_Index - 1
		,b := b + sBox%a% + Key%a%  & 255
		,sBox%a% := (sBox%b%+0, sBox%b% := sBox%a%) ; SWAP(a,b)
	Loop % StrLen(Data)//2
		i := A_Index  & 255
		,j := sBox%i% + j  & 255
		,k := sBox%i% + sBox%j%  & 255
		,sBox%i% := (sBox%j%+0, sBox%j% := sBox%i%) ; SWAP(i,j)
		,Result .= Chr((x . SubStr(Data,2*A_Index-1,2)) ^ sBox%k%)
   	Return Result
}
Return
	
	