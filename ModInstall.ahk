#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

;;Version
Version = 1

;;Drop 7za.exe to TEMP
FileInstall, 7za.exe, %A_TEMP%\7za.exe, 1

;;Check Installer Version
URLDownloadToFile, https://raw.githubusercontent.com/JRWR/BeatSaberModManager/master/version.txt, %A_TEMP%\version.txt
FileReadLine, CurVersion, %A_TEMP%\version.txt, 1
if (Version != CurVersion) {
	MsgBox, This Version is out of date, I will now launch your browser to download the newest version
	Run, https://github.com/JRWR/BeatSaberModManager/releases
	ExitApp,
}

;;Check for Steam Version
RegRead, SteamLocation, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 620980, InstallLocation

;;Check for Oculus Version
RegRead, OculusLocation, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Oculus VR`, LLC\Oculus\Config, InitialAppLibrary

;;If Failed, Open Folder selection
if OculusLocation
	OutputDir := OculusLocation . "\Software\hyperbolic-magnetism-beat-saber"
	
if SteamLocation
	OutputDir := SteamLocation
if (!OutputDir)
	FileSelectFolder, OutputDir, ,2, Beat Saber Installed path
	
Msgbox, 4, Beat Saber Mod Installer, Your Beat Saber folder is`n`n  %OutputDir%`n`n Does that look correct?
IfMsgBox, No
	FileSelectFolder, OutputDir, ,2, Beat Saber Installed path

;;Go Back if BeatSaber.exe is not detected
IfNotExist, %OutputDir%\Beat Saber.exe 
{
	MsgBox, Unable to Detect Beat Saber.exe -- Please Make sure it is installed!
	ExitApp,
}


;;Grab mod list from github
URLDownloadToFile, https://raw.githubusercontent.com/JRWR/BeatSaberModManager/master/list.txt, %A_TEMP%\modlist.txt

;;Setup GUI
Gui, New, +Resize -MaximizeBox, Beat Saber Mod Installer v%Version%
Gui, Add, Text,, Please select the mods you wish to install                      `n`nAll mods are auto-updated if installed again.`n`nIt is suggested to install all mods listed here`nas they have been tested by the Discord staff as being stable`n`n

;;Loop over list from github and make the array + list out GUI entreis
Loop, read, %A_TEMP%\modlist.txt
{
StringSplit, Mod%A_Index%, A_LoopReadLine,`,
Name := Mod%A_Index%1
Version := Mod%A_Index%4
Owner := Mod%A_Index%2
Gui, Add, Checkbox, Checked -Wrap vMod%A_Index%Check, %Name% (%Version%) - %Owner%
}
Gui, Add, Button, Default, OK
Gui, Add, Text,, `n`n
Gui, Show
Return
;;Take selected Mods and loop over them
ButtonOK:
Gui, Submit

Loop, read, %A_TEMP%\modlist.txt
{
if ( Mod%A_Index%Check == 1) {
;; Install it
URL := Mod%A_Index%5
Type := Mod%A_Index%3
Filename := Mod%A_Index%6
SplashTextOn, , , Downloading %Filename%                  
URLDownloadToFile, %URL%, %A_TEMP%\%Filename%

if (Type == 1){
SplashTextOn, , , Extracting %Filename%                  
RunWait, %A_TEMP%\7za.exe x -y -o"%OutputDir%" %A_TEMP%\%Filename%
}else{
FileMove, %A_TEMP%\%Filename%, %OutputDir%\Plugins, 1
}

}
}
SplashTextOn, , , Running IPA Patcher
RunWait, "%OutputDir%\IPA.exe" "%OutputDir%\Beat Saber.exe"
SplashTextOff,
;;Display Success
Msgbox, All done!
ExitApp,
Return,





;;Cleanup
GuiClose:
ExitApp,










