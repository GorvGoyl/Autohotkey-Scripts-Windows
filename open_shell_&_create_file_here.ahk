; run script as admin (reload if not as admin) 
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

#IfWinActive ahk_class CabinetWClass
^+p::
    pwshHere()
    return
^+m::
    newFileHere()
    return
#IfWinActive

newFileHere(){
WinHWND := WinActive()
For win in ComObjCreate("Shell.Application").Windows
    If (win.HWND = WinHWND) {
        dir := SubStr(win.LocationURL, 9) ; remove "file:///"
        dir := RegExReplace(dir, "%20", " ")
        Break
    }

file = %dir%/NewFile.txt
if FileExist(file)
{
    MsgBox, NewFile.txt already exists
    return
}
FileAppend,, %file%  ; create new file
}

pwshHere(){
If WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
      If WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        WinHWND := WinActive()
        For win in ComObjCreate("Shell.Application").Windows
            If (win.HWND = WinHWND) {
                dir := SubStr(win.LocationURL, 9) ; remove "file:///"
                dir := RegExReplace(dir, "%20", " ")
                Break
            }
    }
    Run, pwsh, % dir ? dir : A_Desktop
    }

}