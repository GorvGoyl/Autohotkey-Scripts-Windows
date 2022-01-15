; disable zoom when doing ctrl+scroll in edge browser

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetTitleMatchMode, 2                    ; window title can contain text anywhere inside             
#IfWinActive, Microsoft​ Edge                  ; if the title contains "Microsoft​ Edge"
#MaxHotkeysPerInterval 200
$^WheelDown::Return           ; ctrl-wheel-down 
#MaxHotkeysPerInterval 200
$^WheelUp::Return               ; ctrl-wheel-up 
