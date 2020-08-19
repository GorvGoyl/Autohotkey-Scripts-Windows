;BatteryRun.ahk
; Run commands when the power plug is connected or disconnected
; Command: BatteryRun.exe "<connect command>" "<disconnect command>"
; Example: BatteryRun.exe "ding.wav" "calc.exe"
;Skrommel @ 2007

#NoEnv
#SingleInstance,Force

applicationname=BatteryRun
Gosub,TRAYMENU

If 0=0
  Goto,ABOUT
onlinecommand=%1%
offlinecommand=%2%

VarSetCapacity(powerStatus, 1+1+1+1+4+4)
acLineStatus=FirstRun
SetTimer,GETSYSTEMPOWERSTATUS,1000
Return


GETSYSTEMPOWERSTATUS:  ;Stolen from anthonyb and others at http://www.autohotkey.com/forum/topic7633.html
success:=DllCall("GetSystemPowerStatus", "UInt", &powerStatus)
If (ErrorLevel != 0 Or success = 0)
{
  MsgBox,0,%applicationname%,Can't get the power state!
  ExitApp
}
oldacLineStatus:=acLineStatus
acLineStatus:=GetInteger(powerStatus, 0, false, 1)
If (acLineStatus<>oldacLineStatus And oldacLineStatus<>"FirstRun")
{
  If acLineStatus = 1   ;  acLineStatus = Online
  {
    SplitPath,onlinecommand,name,dir,ext,name_no_ext,drive
    If ext In wav    
      SoundPlay,%onlinecommand%
    Else
      Run,%onlinecommand%,,,UseErrorLevel
  }
  Else
  If acLineStatus = 0   ;  acLineStatus = Offline
  {
    SplitPath,offlinecommand,name,dir,ext,name_no_ext,drive
    If ext In wav    
      SoundPlay,%offlinecommand%
    Else
      Run,%offlinecommand%,,,UseErrorLevel
  }
}
Return


GetInteger(ByRef @source, _offset = 0, _bIsSigned = false, _size = 4)
{
   Local result

   Loop %_size%  ; Build the integer by adding up its bytes.
   {
      result += *(&@source + _offset + A_Index-1) << 8*(A_Index-1)
   }
   If (!_bIsSigned OR _size > 4 OR result < 0x80000000)
      Return result  ; Signed vs. unsigned doesn't matter in these cases.
   ; Otherwise, convert the value (now known to be 32-bit & negative) to its signed counterpart:
   Return -(0xFFFFFFFF - result + 1)
}


TRAYMENU:
Menu,Tray,NoStandard
Menu,Tray,DeleteAll
Menu,Tray,Add,%applicationname%,ABOUT
Menu,Tray,Add
Menu,Tray,Add,&About,ABOUT
Menu,Tray,Add,E&xit,EXIT
Menu,Tray,Default,%applicationname%
Menu,Tray,Tip,%applicationname%
Return


ABOUT:
Gui,99:Destroy
Gui,99:Margin,20,20
Gui,99:Add,Picture,xm Icon1,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,%applicationname% v1.0
Gui,99:Font
Gui,99:Add,Text,y+10,- Run commands when the power plug is connected or disconnected.
Gui,99:Add,Text,y+10,- Command line:
Gui,99:Add,Text,xp+10 y+5,BatteryRun.exe "<connect_command>" "<disconnect_command>"
Gui,99:Add,Text,xp-10 y+10,- Example: 
Gui,99:Add,Text,xp+10 y+5,BatteryRun.exe "ding.wav" "calc.exe"

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
  If 0=0
    Goto,EXIT
Return

WM_MOUSEMOVE(wParam,lParam)
{
  Global hCurs
  MouseGetPos,,,,ctrl
  If ctrl in Static11,Static15,Static19
    DllCall("SetCursor","UInt",hCurs)
  Return
}
Return


EXIT:
ExitApp
