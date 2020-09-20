
; run script as admin (reload if not as admin) 
if not A_IsAdmin  {    Run *RunAs "%A_ScriptFullPath%"     ExitApp }

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

; alt+Q switches windows when file explorer has tabs
#If WinActive("ahk_exe Explorer.EXE")
$!Q::    ; Next window
WinGetClass, ActiveClass, A
WinSet, Bottom,, A
WinActivate, ahk_class %ActiveClass%
return
$PgUp::    ; Last window
WinGetClass, ActiveClass, A
WinActivateBottom, ahk_class %ActiveClass%
return
#If