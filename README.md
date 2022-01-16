# Top [AutoHotkey](https://www.autohotkey.com) scripts to get more out of Windows

Useful AutoHotkey scripts (Windows) for quick lookup, in-line calculator, remap keys, battery alert, and more.
👇
http://gourav.io/blog/autohotkey-scripts-windows

## How to run script

- Download and install main program (one-time step) https://www.autohotkey.com
- Download a script (`*.ahk`) or copy paste script content in a text file and then rename it with `.ahk` extension e.g. `my-script.ahk`
- Right-click -> `Run script`.  
  You can also run scripts by double-click, or do right-click ->`Open with` -> `AutoHotkey`
- Bonus: you can right-click and `Compile script` to make it a standalone `*.exe` program which would run without needing to install AutoHotkey first.

_scripts inside /drafts folder are not tested properly and might not work. The rest of the scripts should work fine._

### Run script at startup

Method 1:

- Open startup folder: open `Run` window by `Win+R` and then write `shell:startup` and enter.
- It'll open explorer at something like this path: `C:\Users\{username}\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`
- Copy script (`*.ahk`) -> go to that `Startup` folder -> right-click and select `Paste shortcut`.

OR

Method 2:

- Put `script_autorun_startup.vbs` at startup folder. Make sure to put the correct path of your ahk scripts in that file first.

### Run script as Admin

Put it at the beginning of the script:

```
; check if it is running as Admin, if not reload as Admin. put at top
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"
   ExitApp
}
```

OR

Check `Run this program as administrator` in:

> autohothey.exe > properties > compatibility > settings

## Docs

- Official docs  
  https://www.autohotkey.com/docs/AutoHotkey.htm

- AutoHotkey Expression Examples  
  http://daviddeley.com/autohotkey/xprxmp/autohotkey_expression_examples.htm

### Keys and their symbols

- https://www.autohotkey.com/docs/Hotkeys.htm#Symbols

### Common things often found at the beginning of AutoHotkey scripts

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

## Community

- https://www.reddit.com/r/AutoHotkey/
- https://www.autohotkey.com/boards/
