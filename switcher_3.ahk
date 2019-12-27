#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


!`::    ; Next window if using alt-backtick
    WinGet, ExeName, ProcessName , A
    WinGet, ExeCount, Count, ahk_exe %ExeName%
    If ExeCount = 1
        Return
    Else
        WinSet, Bottom,, A
        WinActivate, ahk_exe %ExeName%
return

!+`::    ; prev window, Alt+shift+backtick
    WinGet, ExeName, ProcessName , A
    WinActivateBottom, ahk_exe %ExeName%
return