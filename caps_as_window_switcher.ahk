
; capslock as ctrl+alt+tab i.e. show window switcher
; enable/disable capslock with shift+capslock

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
#SingleInstance Force
SetTitleMatchMode 2


+CapsLock::CapsLock

CapsLock::
Send, ^!{Tab}
return