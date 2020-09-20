# Productivity-Autohotkey-Scripts--Windows

Autohotkey scripts to make you more productive when using Windows.

## Bookmarks
- http://daviddeley.com/autohotkey/xprxmp/autohotkey_expression_examples.htm
- https://www.autohotkey.com/docs/AutoHotkey.htm

## Run script at statup
1.
open startup folder
`Win+R` then `shell:startup`
or
`C:\Users\1gour\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`

then paste script as shortcut

OR

2.
put `script_autorun_startup.vbs` at startup folder 


### Run script as Admin
1.
```
; check if it is running as Admin, if not reload as Admin. put at top
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}
```

OR

2.
Check "run this program as administrator" in:

> autohothey.exe > properties > compatability > settings

### Common things often found at the beginning of autohotkey scripts

```
#NoTrayIcon              ;if you don't want a tray icon for this AutoHotkey program.
#NoEnv                   ;Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force    ;Skips the dialog box and replaces the old instance automatically
;;SendMode Input           ;I discovered this causes MouseMove to jump as if Speed was 0. (was Recommended for new scripts due to its superior speed and reliability.)
SetKeyDelay, 90          ;Any number you want (milliseconds)
CoordMode,Mouse,Screen   ;Initial state is Relative
CoordMode,Pixel,Screen   ;Initial state is Relative. Frustration awaits if you set Mouse to Screen and then use GetPixelColor because you forgot this line. There are separate ones for: Mouse, Pixel, ToolTip, Menu, Caret
MouseGetPos, xpos, ypos  ;Save initial position of mouse
WinGet, SavedWinId, ID, A     ;Save our current active window

;Set Up a Log File:
SetWorkingDir, %A_ScriptDir%  ;Set default directory to where this script file is located. (Note %% because it's expecting and unquoted string)
LogFile := "MyLog.txt"
FileAppend, This is a message`n, %LogFile%  ;Note the trailing (`n) to start a new line. This could instead be a leading (`n) if you want. (Note %% because it's expecting and unquoted string)
```