;PushToShow.ahk
; Only shows the taskbar when the Windows key is pushed
;Skrommel @ 2008


#SingleInstance,Force
DetectHiddenWindows,On
SetWinDelay,0
OnExit,EXIT

applicationname=PushToShow

WinGet,active,Id,ahk_class Progman
WinGet,taskbar,Id,ahk_class Shell_TrayWnd
Gosub,TRAYMENU
Gosub,AUTOHIDE
Gosub,HIDE
Return


~LWin::
Input,SingleKey,L1 M V I,{LWin Up}
If ErrorLevel<>Match
  action=1
Return


LWin Up::
If action<>
{
  action=
  Return
}
WinSet,Region,,ahk_id %taskbar%
If (WinExist("A")<>taskbar)
  active:=WinExist("A")
WinActivate,ahk_class Shell_TrayWnd
SetTimer,HIDE,100
Return


HIDE:
MouseGetPos,,,mwin
If (mwin=taskbar)
  Return
WinActivate,ahk_id %active%

SHRINK:
WinGetPos,wx,wy,ww,wh,ahk_id %taskbar%
ww-=2
wh-=2
WinSet,Region,2-2 W%ww% H%wh%,ahk_id %taskbar%
SetTimer,HIDE,Off
Return


EXIT:
WinSet,Region,,ahk_id %taskbar%
Gosub,NORMAL
ExitApp


TRAYMENU:
  Menu,Tray,NoStandard 
  Menu,Tray,DeleteAll
  Menu,Tray,Add,%applicationname%,ABOUT
  Menu,Tray,Add,
  Menu,Tray,Default,%applicationname%
  Menu,Tray,Add,&About...,ABOUT
  Menu,Tray,Add,E&xit,EXIT
  Menu,Tray,Tip,%applicationname% 
Return 


SHOWINFO:
  If showinfo=1
    showinfo=0
  Else
    showinfo=1
Return


SETTINGS:
  Run,%A_ScriptDir%
Return


HELP:
  Run,Barnacle.rtf
Return


ABOUT:
Gui,99:Destroy
Gui,99:Margin,20,20
Gui,99:Add,Picture,xm Icon1,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,%applicationname% v1.0
Gui,99:Font
Gui,99:Add,Text,y+10,Completely hides the taskbar until the windows key is pushed.

Gui,99:Add,Picture,xm y+20 Icon5,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,1 Hour Software by Skrommel
Gui,99:Font
Gui,99:Add,Text,y+10,For more tools, information and donations, please visit 
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 G1HOURSOFTWARE,www.1HourSoftware.com
Gui,99:Font

Gui,99:Add,Picture,xm y+20 Icon7,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,DonationCoder
Gui,99:Font
Gui,99:Add,Text,y+10,Please support the contributors at
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 GDONATIONCODER,www.DonationCoder.com
Gui,99:Font

Gui,99:Add,Picture,xm y+20 Icon6,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,AutoHotkey
Gui,99:Font
Gui,99:Add,Text,y+10,This tool was made using the powerful
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 GAUTOHOTKEY,www.AutoHotkey.com
Gui,99:Font

Gui,99:Show,,%applicationname% About
hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
OnMessage(0x200,"WM_MOUSEMOVE") 
Return

1HOURSOFTWARE:
  Run,http://www.1hoursoftware.com,,UseErrorLevel
Return

DONATIONCODER:
  Run,http://www.donationcoder.com,,UseErrorLevel
Return

AUTOHOTKEY:
  Run,http://www.autohotkey.com,,UseErrorLevel
Return

99GuiClose:
  Gui,99:Destroy
  OnMessage(0x200,"")
  DllCall("DestroyCursor","Uint",hCur)
Return

WM_MOUSEMOVE(wParam,lParam)
{
  Global hCurs
  MouseGetPos,,,,ctrl
  If ctrl in Static7,Static11,Static15
    DllCall("SetCursor","UInt",hCurs)
  Return
}
Return


ShellMessage(wParam,lParam) 
{ 
  Global active
  If (wParam=4) ;HSHELL_WINDOWACTIVATED
  { 
    WinGetClass,class,ahk_id %lParam% 
    If (class<>"Shell_TrayWnd") 
      active:=lParam
    If (lParam=0) 
      WinGet,active,Id,ahk_class Progman
  }
}


AUTOHIDE: ;Stolen from SKAN at http://www.autohotkey.com/forum/topic26107.html
ABM_SETSTATE    := 10 
ABS_NORMAL      := 0x0 
ABS_AUTOHIDE    := 0x1 
ABS_ALWAYSONTOP := 0x2 
VarSetCapacity(APPBARDATA,36,0) 
Off:=NumPut(36,APPBARDATA) 
Off:=NumPut(WinExist("ahk_class Shell_TrayWnd"),Off+0) 

NumPut(ABS_AUTOHIDE|ABS_ALWAYSONTOP, Off+24) 
DllCall("Shell32.dll\SHAppBarMessage",UInt,ABM_SETSTATE,UInt,&APPBARDATA) 
Return

NORMAL: 
NumPut(ABS_ALWAYSONTOP,Off+24) 
DllCall("Shell32.dll\SHAppBarMessage",UInt,ABM_SETSTATE,UInt,&APPBARDATA) 
Return