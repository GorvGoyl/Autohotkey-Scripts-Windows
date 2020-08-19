;RunAndHide.ahk
; Run to hide or show the taskbar
;Skrommel @ 2008

#NoEnv
#SingleInstance,Force
#NoTrayIcon
SetWinDelay,0

IfWinExist,ahk_class Shell_TrayWnd
{
  WinHide,ahk_class Shell_TrayWnd
  WinHide,Start ahk_class Button
}
Else
{
  WinShow,ahk_class Shell_TrayWnd
  WinShow,Start ahk_class Button
}