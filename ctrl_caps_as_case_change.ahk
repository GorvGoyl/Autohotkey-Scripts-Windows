/*
    ---
    CTRL + CAPSLOCK — TO SHOW TEXT CASE CONVERER MENU
    ---
*/


; SCRIPT SETUP
#NoEnv
#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode 2


; FUNCTIONS
upper_case(target_text) {
    StringUpper, target_text, target_text
    return target_text
}
lower_case(target_text) {
    StringLower, target_text, target_text
    return target_text
}
title_case(target_text) {
    StringLower, target_text, target_text, T
    return target_text
}
sentence_case(target_text) {
    StringLower, target_text, target_text
    target_text := RegExReplace(target_text, "((?:^|[.!?]\s+)[a-z])", "$u1")
    return target_text
}
kebab_case(target_text) {
    StringLower, target_text, target_text
    target_text := RegExReplace(target_text, "[_-]", " ")
    StringReplace, target_text, target_text, %A_Space%, -, All
    return target_text
}
snake_case(target_text) {
    StringLower, target_text, target_text
    target_text := RegExReplace(target_text, "[_-]", " ")
    StringReplace, target_text, target_text, %A_Space%, _, All
    return target_text
}
fix_linebreaks(target_text) {
    target_text := RegExReplace(target_text, "\R", "`r`n")
    return target_text
}
reverse_string(target_text) {
    temp_text :=
    StringReplace, target_text, target_text, `r`n, % Chr(29), All
    Loop Parse, target_text
        temp_text := A_LoopField . temp_text
    StringReplace, target_text, temp_text, % Chr(29), `r`n, All
    return target_text
}


; MENU SETUP
GroupAdd All
Menu Case, Add, &UPPERCASE, CCase
Menu Case, Add, &lowercase, CCase
Menu Case, Add, &Title Case, CCase
Menu Case, Add, &Sentence case, CCase
Menu Case, Add
Menu Case, Add, &kebab-case, CCase
Menu Case, Add, &snake_case, CCase
Menu Case, Add
Menu Case, Add, &Fix Linebreaks, CCase
Menu Case, Add, &Reverse, CCase


; INPUT TEXT
^CapsLock::
GetText(InputText)
If NOT ERRORLEVEL
    Menu Case, Show
Return


; CASE SWITCH 
CCase:
; CONVERT TO  UPPER CASE
If (A_ThisMenuItemPos = 1) {
    InputText := upper_case(InputText)
}
; CONVERT TO  LOWER CASE
Else If (A_ThisMenuItemPos = 2) {
    InputText := lower_case(InputText)
}
; CONVERT TO  TITLE CASE
Else If (A_ThisMenuItemPos = 3) {
    InputText := title_case(InputText)
}
; CONVERT TO  SENTENCE CASE
Else If (A_ThisMenuItemPos = 4) {
    InputText := sentence_case(InputText)
}
; --------------------------------------------------------
; CONVERT TO KEBAB CASE
Else If (A_ThisMenuItemPos = 6) {
    InputText := kebab_case(InputText)
}
; CONVERT TO SNAKE CASE
Else If (A_ThisMenuItemPos = 7) {
    InputText := snake_case(InputText)
}
; --------------------------------------------------------
; FIX LINEBREAKS
Else If (A_ThisMenuItemPos = 9) {
    InputText := fix_linebreaks(InputText)
}
; REVERSE STRING
Else If (A_ThisMenuItemPos = 10) {
    InputText := reverse_string(InputText)
}


; OUTPUT TEXT
PutText(InputText)
Return


; HANDY FUNCTIONS
; COPIES THE SELECTED TEXT TO A VARIABLE WHILE PRESERVING THE CLIPBOARD.
GetText(ByRef MyText = "") {
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
; PASTES TEXT FROM A VARIABLE WHILE PRESERVING THE CLIPBOARD.
PutText(MyText) {
   SavedClip := ClipboardAll 
   Clipboard =
   Sleep 20
   Clipboard := MyText
   Send ^v
   Sleep 100
   Clipboard := SavedClip
   Return
}

