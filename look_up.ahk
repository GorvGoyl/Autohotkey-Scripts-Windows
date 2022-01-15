; alt+g : open highlighted text in browser and do google search / visit site (if it's url)


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


!g::
MyClip := ClipboardAll
Clipboard = ; empty the clipboard
Send, ^c
ClipWait, 2
if ErrorLevel  ; ClipWait timed out.
{
    return
}
if RegExMatch(Clipboard, "^[^ ]*\.[^ ]*$")
{
    Run "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" %Clipboard%
}
else  
{
    ; Modify some characters that screw up the URL
    ; RFC 3986 section 2.2 Reserved Characters (January 2005):  !*'();:@&=+$,/?#[]
    StringReplace, Clipboard, Clipboard, `r`n, %A_Space%, All
    StringReplace, Clipboard, Clipboard, #, `%23, All
    StringReplace, Clipboard, Clipboard, &, `%26, All
    StringReplace, Clipboard, Clipboard, +, `%2b, All
    StringReplace, Clipboard, Clipboard, ", `%22, All
    Run % "https://www.google.com/search?hl=en&q=" . clipboard ; uriEncode(clipboard)
}
Clipboard := MyClip
return

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

