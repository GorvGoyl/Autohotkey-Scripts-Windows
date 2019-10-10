#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

LWin::LButton

/*
;run at startup
;run as admin
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}

SplitPath, A_Scriptname, , , , OutNameNoExt 
LinkFile=%A_StartupCommon%\%OutNameNoExt%.lnk 
IfNotExist, %LinkFile% 
  FileCreateShortcut, %A_ScriptFullPath%, %LinkFile% 
SetWorkingDir, %A_ScriptDir%

test:
ctrl+shift
shift hold and cursor move
shift+a = A
format code in vscode
ctrl+shift+a
ALt + Tab

;shortcuts
;F1::AltTab
;F2::RButton
F1::AltTabAndMenu
;LAlt & *::return
;LWin & *::return
;~Ctrl & ~LShift::return
;~LShift & ~Ctrl::return
;~Alt & ~LShift::return
;~Shift & ~Alt::return
;~Ctrl & ~Alt::return
;LCtrl & LWin::^LButton
;lWin::LButton

LWin::LButton

$LWin::
Send {LButton Down} ; Press the LButton key Down
KeyWait, LWin ; Wait for the LShift key to be lifted
Send {LButton Up} ; Release the LButton key
return 
 
;~LWin & *::return
;LAlt::RButton
*/