#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
SetTitleMatchMode 2

; ctrl+capslock to case change menu *****************************************
GroupAdd All

Menu Case, Add, &UPPERCASE, CCase
Menu Case, Add, &lowercase, CCase
Menu Case, Add, &Title Case, CCase
Menu Case, Add, &Sentence case, CCase
Menu Case, Add
Menu Case, Add, &Fix Linebreaks, CCase
Menu Case, Add, &Reverse, CCase


^CapsLock::
GetText(TempText)
If NOT ERRORLEVEL
   Menu Case, Show
Return

CCase:
If (A_ThisMenuItemPos = 1)
   StringUpper, TempText, TempText
Else If (A_ThisMenuItemPos = 2)
   StringLower, TempText, TempText
Else If (A_ThisMenuItemPos = 3)
   StringLower, TempText, TempText, T
Else If (A_ThisMenuItemPos = 4)
{
   StringLower, TempText, TempText
   TempText := RegExReplace(TempText, "((?:^|[.!?]\s+)[a-z])", "$u1")
} ;Seperator, no 5
Else If (A_ThisMenuItemPos = 6)
{
   TempText := RegExReplace(TempText, "\R", "`r`n")
}
Else If (A_ThisMenuItemPos = 7)
{
   Temp2 =
   StringReplace, TempText, TempText, `r`n, % Chr(29), All
   Loop Parse, TempText
      Temp2 := A_LoopField . Temp2
   StringReplace, TempText, Temp2, % Chr(29), `r`n, All
}
PutText(TempText)
Return

; WIN key as mouse left click *****************************************
LWin::LButton

; ctrl+alt is Alttab *****************************************
LControl & RAlt::AltTab
; LShift & RAlt::AltTabAndMenu

; RCTRL as Win key ******************************************************
RCtrl::LWin

; Google Search highlighted text: alt+g *****************************************
!g::
{
 Send, ^c
 Sleep 50
 Run, http://www.google.com/search?q=%clipboard%
 Return
}

; 4) autocomplete


; Handy function.
; Copies the selected text to a variable while preserving the clipboard.
GetText(ByRef MyText = "")
{
   SavedClip := ClipboardAll
   Clipboard =
   Send ^c
   ClipWait 0.5
   If ERRORLEVEL
   {
      Clipboard := SavedClip
      MyText =
      Return
   }
   MyText := Clipboard
   Clipboard := SavedClip
   Return MyText
}

; Pastes text from a variable while preserving the clipboard.
PutText(MyText)
{
   SavedClip := ClipboardAll 
   Clipboard =              ; For better compatability
   Sleep 20                 ; with Clipboard History
   Clipboard := MyText
   Send ^v
   Sleep 100
   Clipboard := SavedClip
   Return
}

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