;CloseFence.ahk
; Prevents the autohiding Taskbar from appearing when the mouse is over a Close button (X)
; Save as CloseFence.ahk and install AutoHotkey from www.autohotkey.com
;Skrommel @2005

#SingleInstance,Force
SetWinDelay,0

applicationname=CloseFence

Gosub,INIREAD
Gosub,TRAYMENU

START:
Gui,1:Destroy
x1:=A_ScreenWidth-width-Thickness
Gui,1:+ToolWindow -Caption +Border -Resize +AlwaysOnTop
Gui,1:Show
WinGet,id1,ID,A
WinMove,ahk_id %id1%,,%x1%,0,%width%,%thickness%
If hide<>0
  WinSet,Transparent,1,ahk_id %id1%

Gui,2:Destroy
x2:=A_ScreenWidth-thickness
Gui,2:+ToolWindow -Caption +Border -Resize +AlwaysOnTop
Gui,2:Show
WinGet,id2,ID,A
WinMove,ahk_id %id2%,,%x2%,0,%thickness%,%height%
If hide<>0
  WinSet,Transparent,1,ahk_id %id2%

Loop
{
  Sleep,25
  MouseGetPos,,,id
  If (id=id1)
    MouseMove,0,%thickness%,0,R
  If (id=id2)
    MouseMove,-%thickness%,0,0,R
}
Return

TRAYMENU:
Menu,Tray,NoStandard 
Menu,Tray,DeleteAll 
Menu,Tray,Add,%applicationname%,ABOUT
Menu,Tray,Add,
Menu,Tray,Add,&Settings...,SETTINGS
Menu,Tray,Add,&About...,ABOUT
Menu,Tray,Add,E&xit,EXIT
Menu,Tray,Default,%applicationname%
Menu,Tray,Tip,%applicationname%
Return


SETTINGS:
Gui,Destroy
Gui,Add,GroupBox,xm y+10 w170 h50,&Width
Gui,Add,Edit,xp+10 yp+20 w150 vowidth,%width%
Gui,Add,GroupBox,xm y+20 w170 h50,&Height
Gui,Add,Edit,xp+10 yp+20 w150 voheight,%height%
Gui,Add,GroupBox,xm y+20 w170 h50,&Thickness
Gui,Add,Edit,xp+10 yp+20 w150 vothickness,%thickness%
checked=
If hide=1
  checked=Checked
Gui,Add,GroupBox,xm y+20 w170 h50,&Hidden
Gui,Add,CheckBox,xp+10 yp+20 w150 %checked% vohide,Hide the fence

Gui,Add,Button,xm y+30 w75 GSETTINGSOK,&OK
Gui,Add,Button,x+5 w75 GSETTINGSCANCEL,&Cancel
Gui,Show,,%applicationname% Settings
Return

SETTINGSOK:
Gui,Submit
If owidth>0
  width:=owidth
If oheight>0
  height:=oheight
If othickness>0
  thickness:=othickness
If (ohide=0 Or ohide=1)
  hide:=ohide
Gosub,INIWRITE
Gosub,START
Return

SETTINGSCANCEL:
Gui,Destroy
Return


INIREAD:
IfNotExist,%applicationname%.ini
{
  width:=100     ; Width of the fence above the close button
  height:=50     ; Height of the fence to the right of the close button
  thickness:=3   ; Thickness of the fence
  hide:=1        ; Hide the fence
  Gosub,INIWRITE
}
IniRead,width,%applicationname%.ini,Settings,width
IniRead,height,%applicationname%.ini,Settings,height
IniRead,thickness,%applicationname%.ini,Settings,thickness
IniRead,hide,%applicationname%.ini,Settings,hide
Return

INIWRITE:
IniWrite,%width%,%applicationname%.ini,Settings,width
IniWrite,%height%,%applicationname%.ini,Settings,height
IniWrite,%thickness%,%applicationname%.ini,Settings,thickness
IniWrite,%hide%,%applicationname%.ini,Settings,hide
Return


ABOUT:
Gui,99:Destroy
Gui,99:Margin,20,20
Gui,99:Add,Picture,xm Icon1,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,%applicationname% v1.0
Gui,99:Font
Gui,99:Add,Text,y+10,- Prevents an autohiding Taskbar from appearing
Gui,99:Add,Text,y+5 ,when the mouse is over a Close button (X).
Gui,99:Add,Text,y+10,- To change the settings, choose Settings in the tray menu.

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
  If ctrl in Static9,Static13,Static17
    DllCall("SetCursor","UInt",hCurs)
  Return
}
Return

EXIT:
ExitApp