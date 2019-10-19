#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance Force
SetTitleMatchMode 2


;******************************************************************************
; This is a random selection of utilities. All are activated by holding 
; "Application Key" (left of right Ctrl) and pressing some other key. 
; Some of them have a second function activated by holding Shift at the 
; same time. Hopefully you will find some of the useful. Feel free to 
; modify, reuse or share any of this.
;
; AppsKey plus - Result
;
;        Enter - Inserts a linebreak.
;                For use when pressing enter would submit a form.
;          Tab - Inserts a tab.
;                For use when pressing tab would change the focus.
;   Arrow Keys - Move the mouse with the arrow keys.
;                For use when you need pixel-precise control.
;       Insert - Searches for the slected text with Google. Or if the text
;                is a URL, goes directly there. See BROWSER CONFIG below.
;    Caps Lock - Opens a context menu with commands to change the case of
;                the selected text, reverse it or "fix" Unix style newlines.
;           F1 - Shows the AutoHotkey help file.
;           F4 - Terminates active application after confirmation.
;                This is like using the Ctrl+Alt+Delete menu.
;     SHIFT F4 - As above, but skips confirmation window.
;  Windows Key - Disables the Windows keys. For use with fullscreen games.
;                Press both windows keys at once to re-enable them.
;            A - Makes the active window "Always On Top".
;                This will be indicated on it's title bar with a †.
;      SHIFT A - Makes the active window NOT "Always On Top".
;            C - Eject the CD tray.   |Handy if the computer is on the floor
;      SHIFT C - Retract the CD tray. |or otherwise awkward to reach.
;            B   Turns the monitor off, similar to power saving mode.
;                Moving the mouse or typing will turn it back on.
;            E - Opens this script for editing.
;            H - Hides the active window.
;      SHIFT H - Unhide all windows that were hidden this way.
;            L - Launch (run) a script selected in explorer.
;                For use when .ahk is not associated with AutoHotkey.
;            R - Reloads this script.
;                If the active window is this script, it will be saved first.
;            T - Makes the active window 50% transpartent.
;      SHIFT T - Makes the active window opaque again.
;            V - Pastes clipboard contents as plain text (if possible).
;                If you "copy" files, this will paste their paths.
;            W - Wraps text to a specific width. (Default 70).
;      SHIFT W - Undoes the above.
;            X - Shows a custom shutdown menu. Press a letter to select from:
;                Shutdown, Restart, Log Off, Hibernate or Powersave (suspend).
;            / - Do a RegEx replace on selected text.
;            [ - Creates matching BBCode tags. (Applied to selected text)
;            , - Creates matching HTML tags. (Ditto)
;            ; - Comments/Uncomments a block of AutoHotkey code.

; BROWSER CONFIG
; This should be the full path to your preferred web browser.
; Example: C:\Program Files\Mozilla Firefox\Firefox.exe

BrowserPath = 

;******************************************************************************

GroupAdd All

Menu Case, Add, &UPPERCASE, CCase
Menu Case, Add, &lowercase, CCase
Menu Case, Add, &Title Case, CCase
Menu Case, Add, &Sentence case, CCase
Menu Case, Add
Menu Case, Add, &Fix Linebreaks, CCase
Menu Case, Add, &Reverse, CCase

;******************************************************************************

AppsKey::
;Keep AppsKey working (mostly) normally.
Send {AppsKey}
Return

AppsKey & enter::
PutText("`r`n")
Return

AppsKey & tab::
PutText("`t")
Return

AppsKey & Left::MouseMove, -1, 0, 0, R
AppsKey & Right::MouseMove, 1, 0, 0, R
AppsKey & Up::MouseMove, 0, -1, 0, R
AppsKey & Down::MouseMove, 0, 1, 0, R

AppsKey & Insert::
TempText := GetText()
TempText := RegExReplace(TempText, "^\s+|\s+$") ;trim whitespace
If RegExMatch(TempText, "\w\.[a-zA-Z]+(/|$)") ;contains .com etc
{
   If SubStr(TempText, 1, 4) != "http"
      TempText := "http://" . TempText
}
Else
{
   If InStr(TempText, " ")
   {
      StringReplace TempText, TempText, %A_Space%, +
      TempText := "%22" . TempText . "%22"
   }
   TempText := "http://www.google.com/search?&q=" . TempText
}
Run %BrowserPath% %TempText%
Return

CapsLock::
GetText(TempText)
If NOT ERRORLEVEL
   Menu Case, Show
Return

AppsKey & F1::
IfWinExist AutoHotkey Help
   WinActivate AutoHotkey Help
Else
{
   SplitPath A_AhkPath, , TempText
   Run %TempText%\AutoHotkey.chm
}
Return

AppsKey & F4::
MyWin := WinExist("A")
WinGetTitle TempText, ahk_id %MyWin%
If NOT TempText ;Prevents terminated the taskbar, or the like.
   Return
If NOT GetKeyState("shift")
{
   WinGetTitle TempText, ahk_id %MyWin%
   MsgBox 49, Terminate!, Terminate "%TempText%"?`nUnsaved data will be lost.
   IfMsgBox Cancel
      Return
}
WinGet MyPID, PID, ahk_id %MyWin%
Process, Close, %MyPID%
Return

AppsKey & RWin::
AppsKey & LWin::
Hotkey RWin, DoNothing, On
Hotkey LWin, DoNothing, On
Return
;;;;;;;;;;;
Lwin & RWin::
Rwin & LWin::
Hotkey RWin, DoNothing, Off
Hotkey LWin, DoNothing, Off
Return
DoNothing:
Return

AppsKey & a::
If NOT IsWindow(WinExist("A"))
   Return
WinGetTitle, TempText, A
If GetKeyState("shift")
{
   WinSet AlwaysOnTop, Off, A
   If (SubStr(TempText, 1, 2) = "† ")
      TempText := SubStr(TempText, 3)
}
else
{
   WinSet AlwaysOnTop, On, A
   If (SubStr(TempText, 1, 2) != "† ")
      TempText := "† " . TempText ;chr(134)
}
WinSetTitle, A, , %TempText%
Return

AppsKey & b::
SendMessage, 0x112, 0xF170, 1,, Program Manager
Sleep 1000
SendMessage, 0x112, 0xF170, 1,, Program Manager
Return


AppsKey & c::
Drive Eject,, % GetKeyState("shift")
Return

AppsKey & e::Edit

AppsKey & h::
If GetKeyState("shift")
{
   Loop Parse, HiddenWins, |
      WinShow ahk_id %A_LoopField%
   HiddenWins =
}
else
{
   MyWin := WinExist("A")
   if IsWindow(MyWin) 
   {
      HiddenWins .= (HiddenWins ? "|" : "") . MyWin
      WinHide ahk_id %MyWin%
      GroupActivate All
   }
}
Return

AppsKey & l::
TempText := GetText()
If FileExist(TempText)
   Run %A_AhkPath% "%TempText%"
Else
   MsgBox Before using this command, select the .ahk file you wish to run in windows explorer.
Return

AppsKey & r::
KeyWait AppsKey
IfWinActive %A_ScriptName%
   Send ^s ;Save
Reload
Return

AppsKey & t::
If NOT IsWindow(WinExist("A"))
   Return
If GetKeyState("shift")
   Winset, Transparent, OFF, A
else
   Winset, Transparent, 128, A
Return

AppsKey & v::
TempText := ClipBoard
If (TempText != "")
   PutText(ClipBoard)
Return

AppsKey & w::
GetText(TempText)
If NOT WrapWidth
   WrapWidth := "70"
If GetKeyState("shift")
   StringReplace TempText, TempText, %A_Space%`r`n, %A_Space%, All
else
{
   Temp2 := SafeInput("Enter Width", "Width:", WrapWidth)
   If ErrorLevel
      Return
   WrapWidth := Temp2
   Temp2 := "(?=.{" . WrapWidth + 1 . ",})(.{1," . WrapWidth - 1 . "}[^ ]) +"
   TempText := RegExReplace(TempText, Temp2, "$1 `r`n")
}
PutText(TempText)
Return

AppsKey & x::
SplashImage, , MC01, (S) Shutdown`n(R) Restart`n(L) Log Off`n(H) Hibernate`n(P) Power Saving Mode`n`nPress ESC to cancel., Press A Key:, Shutdown?, Courier New
Input TempText, L1
SplashImage, Off
If (TempText = "S")
   ShutDown 8
Else If (TempText = "R")
   ShutDown 2
Else If (TempText = "L")
   ShutDown 0
Else If (TempText = "H")
   DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
Else If (TempText = "P")
   DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
Return

AppsKey & /::
; RegEx Replace
TempText := SafeInput("Enter Pattern", "RegEx Pattern:", REPatern)
If ErrorLevel
   Return
Temp2 := SafeInput("Enter Replacement", "Replacement:", REReplacement)
If ErrorLevel
   Return
REPatern := TempText
REReplacement := Temp2
GetText(TempText)
TempText := RegExReplace(TempText, REPatern, REReplacement)
PutText(TempText)
Return

AppsKey & ,::
TempText := SafeInput("Enter Tag", "Example: a href=""http://www.autohotkey.com/""", HTFormat)
If ErrorLevel
   Return
If SubStr(TempText, 1, 4) = "http"
   TempText = a href="%TempText%"
HTFormat := TempText
GetText(Temp2)
Temp2 := "<" . TempText . ">" . Temp2
TempText := RegExReplace(TempText, " .*")
Temp2 := Temp2 . "</" . TempText . ">"
PutText(Temp2)
Return

AppsKey & [::
TempText := SafeInput("Enter Tag", "Example: color=red", BBFormat)
If ErrorLevel
   Return
If SubStr(TempText, 1, 4) = "http"
   TempText = url=%TempText%
BBFormat := TempText
GetText(Temp2)
If SubStr(TempText, 1, 4) = "list" AND NOT InStr(Temp2, "[*]")
   Temp2 := RegExReplace(Temp2, "m`a)^(\*\s*)?", "[*]")
Temp2 := "[" . TempText . "]" . Temp2
TempText := RegExReplace(TempText, "=.*")
Temp2 := Temp2 . "[/" . TempText . "]"
PutText(Temp2)
Return

AppsKey & `;::
;Comment or uncomment AutoHotkey code
GetText(TempText)
If (SubStr(TempText, 1, 1) = ";")
   TempText := RegExReplace(TempText, "`am)^;")
Else
   TempText := RegExReplace(TempText, "`am)^", ";")
PutText(TempText)
Return

;******************************************************************************
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

;******************************************************************************

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

;This makes sure sure the same window stays active after showing the InputBox.
;Otherwise you might get the text pasted into another window unexpectedly.
SafeInput(Title, Prompt, Default = "")
{
   ActiveWin := WinExist("A")
   InputBox OutPut, %Title%, %Prompt%,,, 120,,,,, %Default%
   WinActivate ahk_id %ActiveWin%
   Return OutPut
}

;This checks if a window is, in fact a window.
;As opposed to the desktop or a menu, etc.
IsWindow(hwnd) 
{
   WinGet, s, Style, ahk_id %hwnd% 
   return s & 0xC00000 ? (s & 0x80000000 ? 0 : 1) : 0
   ;WS_CAPTION AND !WS_POPUP(for tooltips etc) 
}

