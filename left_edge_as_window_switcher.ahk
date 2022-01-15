;AltEdge.ahk
; Sends Alt-Tab when the mouse is on the left edge of the screen.
; Keep it there to tab through the other windows. 
;Skrommel @ 2008


#NoEnv
#Persistent,On
#SingleInstance,Force
#WinActivateForce
SetBatchLines,-1
SetWinDelay,0
SetKeyDelay,0
CoordMode,Mouse,Screen

applicationname=AltEgde

Gosub,MENU
tabbed=0

Loop
{
  MouseGetPos,mx,my

  If (mx=0)
  {
    If tabbed=0
    {
      Send,{Alt Down}{Tab}
      SetTimer,TAB,500
    }
    tabbed=1
  }
  Else
  {
    If tabbed=1
    {
      SetTimer,TAB,Off
      Send,{Alt Up}
      tabbed=0
    }
  }
  Sleep,50
}      


TAB:
Send,{Alt Down}{Tab}
Return


MENU:
Menu,Tray,DeleteAll
Menu,Tray,NoStandard
Menu,Tray,Add,%applicationname%,ABOUT
Menu,Tray,Add,
Menu,Tray,Add,&About...,ABOUT
Menu,Tray,Add,E&xit,EXIT
Menu,Tray,Tip,%applicationname%
Menu,Tray,Default,%applicationname%
Return


ABOUT:
Gui,99:Destroy
Gui,99:Margin,20,20
Gui,99:Add,Picture,xm Icon1,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,%applicationname% v1.1
Gui,99:Font
Gui,99:Add,Text,y+10,- Sends Alt-Tab when the mouse is on the left edge of the screen.
Gui,99:Add,Text,y+10,- Keep it there to tab through the other windows.

Gui,99:Add,Picture,xm y+20 Icon2,%applicationname%.exe
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

Gui,99:Add,Button,GABOUTOK Default w75,&OK

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

ABOUTOK:
  Gui,99:Destroy
  OnMessage(0x200,"")
  DllCall("DestroyCursor","Uint",hCur)
Return

WM_MOUSEMOVE(wParam,lParam)
{
  Global hCurs
  MouseGetPos,,,,ctrl
  If ctrl in Static8,Static12,Static16
    DllCall("SetCursor","UInt",hCurs)
  Return
}
Return


EXIT:
ExitApp