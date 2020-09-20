;BatteryDeley.ahk
; Version 1.4 03/30/2011
; Alert user when laptop battery goes below set percentages
; Also alert when the power plug is connected or disconnected
; See file BatteryDeley.ini for settings (if there is no BatteryDeley.ini file, run this program and it will make one)
;
; David Deley @ 2009
; http://members.cox.net/deleyd/
;
; Pieced together from parts made by others:
; BatteryRun - by Skrommel (2007)  http://www.donationcoder.com/Software/Skrommel/index.html#BatteryRun
; popupmfk  - Mithat Konar (2007)  http://www.autohotkey.net/~meter/scripts/popupmfkDevelopment_2k70729.zip
;
; See also PowerCircle battery monitor: http://powercircle.aldwin.us/
;
;Notes to myself:
; Icons:
; 1 - BatteryDeley.ico
; 2 -    AutoHotKey white H
; 3 - deleylogo.ico
; 4 -    AutoHotKey H slanted top (not used)
; 5 -    AutoHotKey S (not used)
; 6 -    AutoHotKey H
; 7 - Duck.ico
;
;  colon-equal operator (:=) to store numbers, quoted strings
;  equal sign operator (=) to assign unquoted literal strings or variables enclosed in percent signs.

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
#SingleInstance force

if A_IsCompiled
  Menu, Tray, Icon, %A_ScriptFullPath%, -159  ;set tray icon

applicationname=BatteryDeley
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.

Gosub,READINI
Gosub,TRAYMENU

VarSetCapacity(powerStatus, 1+1+1+1+4+4)  ;Size of SYSTEM_POWER_STATUS Structure
acLineStatus=FirstRun
BatteryLifePercent=FirstRun

GoSub GETSYSTEMPOWERSTATUS
SetTimer,GETSYSTEMPOWERSTATUS, %pollingms%  ;set the polling timer
Return


GETSYSTEMPOWERSTATUS:  ;Stolen from anthonyb and others at http://www.autohotkey.com/forum/topic7633.html
success:=DllCall("GetSystemPowerStatus", "UInt", &powerStatus)
If (ErrorLevel != 0 Or success = 0)
{
  MsgBox,0,%applicationname%,Can't get the power state. Error=%A_LastError%
  ExitApp
}

oldacLineStatus       := acLineStatus
acLineStatus          := GetInteger(powerStatus, 0, false, 1)
oldBatteryLifePercent := BatteryLifePercent
BatteryLifePercent    := GetInteger(powerStatus, 2, false, 1)
If BatteryLifePercent = 255
{
  BatteryLifePercent = ---
  ;MsgBox,0,%applicationname%,Can't get the battery power state unknown.
  ;ExitApp
}
Menu,Tray,Tip,Battery %BatteryLifePercent%`%


;Is it time for a low battery alert?
;  (Note: We do this backwards, starting with the lowest percent alert,
;   so we don't give an alert1 when we really should be giving an alert6
;MsgBox, 0, BatteryDeley, checking battery percentage`noldBatteryLifePercent=%oldBatteryLifePercent%`nnew BatteryLifePercent=%BatteryLifePercent%,1
Do_Alert := FALSE
loop,%NumAlerts%
{
  i := NumAlerts - a_index + 1
  alertpct := alert%i%pct
  If (oldBatteryLifePercent > alertpct And BatteryLifePercent <= alertpct)
  {
    alertms  := alert%i%ms
    alertimg := alert%i%img
    alertcmd := alert%i%cmd
    MsgRight = %BatteryLifePercent%`%
    Do_Alert := TRUE
    break
  }
}

;Is it time for a battery charged alert?
loop,%NumChargeAlerts%
{
  i := NumChargeAlerts - a_index + 1
  ChargeAlertPct := ChargeAlert%i%pct
  If (oldBatteryLifePercent < ChargeAlertPct And BatteryLifePercent >= ChargeAlertPct)
  {
    alertms  := ChargeAlert%i%ms
    alertimg := ChargeAlert%i%img
    alertcmd := ChargeAlert%i%cmd
    MsgRight = Battery charging.`n`nBattery`n%BatteryLifePercent%`%
    Do_Alert := TRUE
    break
  }
}

;CHECK AC LINE STATUS
;do this last so it supersedes low battery alert
;MsgBox, 0, BatteryDeley, checking ac line status`noldacLineStatus=%oldacLineStatus%`nnew acLineStatus=%acLineStatus%,
; If (acLineStatus<>oldacLineStatus)
; {
;   ;DID WE GET PLUGGED IN?
;   If acLineStatus = 1   ;  acLineStatus = Online
;   {
;     alertms  := PLUGINms
;     alertimg := PLUGINimg
;     alertcmd := PLUGINcmd
;     MsgRight = Plugged In`n`nBattery`n%BatteryLifePercent%`%
;     Do_Alert := TRUE
;   }
;   ;DID WE GET UNPLUGGED?
;   Else If acLineStatus = 0   ;  acLineStatus = Offline
;   {
;     alertms  := UNPLUGms
;     alertimg := UNPLUGimg
;     alertcmd := UNPLUGcmd
;     MsgRight = Unplugged`n`nBattery`n%BatteryLifePercent%`%
;     Do_Alert := TRUE
;   }
; }
If ( Do_Alert )
{
  GoSub DOALERT
}
Return


DOALERT:
If (alertcmd != "")
{
  SplitPath,alertcmd,name,dir,ext,name_no_ext,drive
  ;MsgBox, 0,SplitPath, alertcmd=%alertcmd%`nname=%name%`ndir=%dir%`next=%ext%`ndrive=%drive%,
  If ext In wav
  {
    ;MsgBox, 0, , SoundPlay alertcmd=%alertcmd%,
    SoundPlay,%alertcmd%
  }
  Else
  {
    ;MsgBox, 0, , Run alertcmd=%alertcmd%,
    Run,%alertcmd%,,UseErrorLevel
  }
}
If (alertms > 0)
{
  MsgBelow := "Battery Deley"        ;(Note: We need some text for MsgBelow or popupmfk won't display anything.)
  ;MsgBox, 0, , popup alertimg=%alertimg%,
  popupmfk(MsgRight, MsgBelow, alertms, alertimg, 1)  ;popup a window
  ;Sleep %alertms%
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



;==============================================================================================;
; Functions
;==============================================================================================;

popupmfk(popTitle=0, popMsg=0, popTime=3000, icoPath=0, hasGoAway=0)
; Displays a popup with popTitle and popMsg for popTime msec.
; If popTitle is missing, then only popMsg will appear.
; If you call popupmfk with no popMsg (or no parameters at all), it will kill the topmost popup.
; (In theory, you should only be showing one popup at a time anyway.)
; icoPath specifies the (optional) icon you want to show on the left-top of the popup
; Setting hasGoAway will make the popup have a (kludgey) go-away box. In either case,
; clicking on the popup's icon or any of the text will dismiss the popup.
; If a popup created by this function (even from outside this script) is already displayed, it will be
; killed and a new one will be shown.
;
; This function creates/uses the global kInstanceGuiFcnPopupmfk,
; you can use this global to test for popup windows outside this function.
; This function creates the following label: lbl_fcn_popupmfk_DONE
;
{
        ; constants
        kInstanceGuiFcnPopupmfk = instance_gui_fcn_popupmfk_1           ; used to identify windows launched by this funciton

       kTitleTypeFace = Tahoma                                                 ; typeface of titles
        kTitleStyle = s8 w700 c000000                                   ; style for titles
        kMessageTypeFace = Tahoma                                               ; typeface of message
        kMessageStyle = s8 w400 c000000                                 ; style for messages

        ; let's get to work
        DetectHiddenText, On                                                            ; we will need to make sure that we can detect hidden text
        ; I should store the state that DetectHiddenText is in before changing it so it can be reset later,
        ; sadly I am not aware of any reasonable way of querying the state of DetectHiddenText :-(
        IfWinExist, ahk_class AutoHotkeyGUI, %kInstanceGuiFcnPopupmfk%  ; if a popup is already being displayed
        {
                gosub lbl_fcn_popupmfk_DONE                                                                     ; kill popups and timer from this App
                WinKill, ahk_class AutoHotkeyGUI, %kInstanceGuiFcnPopupmfk%             ; kill popups from other Apps
                ;WinWaitClose, ahk_class AutoHotkeyGUI, %kInstanceGuiFcnPopupmfk%       ; make sure the previous popup is dead
        }

        if popMsg                                               ; if a message is specified, pop up a new window
        {
                Gui, +AlwaysOnTop +toolwindow -resize -caption +border  ;;DWD moved to here. Doc says, "For performance reasons, it is better to set all options in a single line, and to do so before creating the window (that is, before any use of other sub-commands such as Gui Add)."
                ;WinWaitClose, ahk_class AutoHotkeyGUI, %kInstanceGuiFcnPopupmfk%       ; make sure the previous popup is dead
                Gui, Add, Text, hidden, %kInstanceGuiFcnPopupmfk%                                       ; add the ID text as hidden

                if popTitle                                                                                                     ; if we have a title
                {
                        if icoPath                                                                                                      ; if we have an icon
                        {
                                Gui, Add, Picture, xm ym section glbl_fcn_popupmfk_DONE ,%icoPath%      ; add the icon
                                Gui, font, %kTitleStyle%, %kTitleTypeFace%                                                      ; add first the title (popTitle)
                                Gui, Add, Text, ys glbl_fcn_popupmfk_DONE , %popTitle%
                        }
                        else                                                                                                            ; otherwise
                        {
                                Gui, font, %kTitleStyle%, %kTitleTypeFace%                                                      ; add first the title (popTitle)
                                Gui, Add, Text, xm ym section glbl_fcn_popupmfk_DONE , %popTitle%
                        }
                        Gui, font, s8 %kMessageStyle%, %kMessageTypeFace%                                               ; now add the message (popMsg)
                        Gui, Add, Text, xm glbl_fcn_popupmfk_DONE , %popMsg%
                }
                else                                                                                                            ; otherwise
                {
                        Gui, font, %kMessageStyle%, %kMessageTypeFace%
                        if icoPath                                                                                                      ; if we have an icon
                        {
                                Gui, Add, Picture, xm ym section glbl_fcn_popupmfk_DONE ,%icoPath%      ; add the icon
                                Gui, Add, Text, ys glbl_fcn_popupmfk_DONE, %popMsg%                                     ; and the message
                        }
                        else                                                                                                                                    ; add the only the message (popMsg)
                                Gui, Add, Text, xm ym glbl_fcn_popupmfk_DONE, %popMsg%
                }

                if hasGoAway                                            ; if you want a go-away box...
                {
                        ;Gui, font, s8 w700 c990000, Tahoma             ; kludge go-away box by making a red [X]
                        ;Gui, Add, Text, ys glbl_fcn_popupmfk_DONE , [X]
                        Gui, font, s6 w400                              ; kludge go-away box by making a button with a little x in it
                        Gui, Add, Button, ym glbl_fcn_popupmfk_DONE , x
                }
                Gui, font
                ;Gui, +AlwaysOnTop +toolwindow -resize -caption +border [DWD moved up]
                Gui, Color, ffffdd
                ; position the thing at (monWorkAreaRight-GuiWidth, monWorkAreaBottom-GuiHeight
                SysGet, popup_monWorkArea, MonitorWorkArea      ; get the primary monitor's client area
                Gui, Show, x%popup_monWorkAreaRight% y%popup_monWorkAreaBottom% NoActivate ; first show a "hidden" window (offscreen)
                WinWait , ahk_class AutoHotkeyGUI, %kInstanceGuiFcnPopupmfk%
                WinGetPos ,,, GuiWidth, GuiHeight, ahk_class AutoHotkeyGUI, %kInstanceGuiFcnPopupmfk%   ; and get its dimensions
                popup_x := popup_monWorkAreaRight-GuiWidth
                popup_y := popup_monWorkAreaBottom-GuiHeight
                Gui, Show, x%popup_x% y%popup_y% NoActivate             ; now show the window for real
                WinWait , ahk_class AutoHotkeyGUI, %kInstanceGuiFcnPopupmfk%
                SetTimer, lbl_fcn_popupmfk_DONE, %popTime%
        }
        return

        lbl_fcn_popupmfk_DONE:
                SetTimer, lbl_fcn_popupmfk_DONE, Off
                Gui, Destroy
                return
}


DeRefDeley(v)
; Keep translating over & over until all the variables have been expanded
; e.g.
;   msg     := "Today is %day%"
;   day     := "your %special% day"
;   special := "%nth% birthday"
;   nth     := "18th"
;   s := DeRefDeley(msg)
;   MsgBox s=%s%
;   ExitApp
;resulting message is: "Today is your 18th birthday day"
;(apply some reasonable upper bound on the loop)
{
    loop,20
    {
        Transform, w, deref, %v%
        ;MsgBox v=%v%`nw=%w%
        if (w = v)
        {
           Return (w)
        }
        v := w
    }
    Return ("DeRefDeley looped 20 times and gave up") ;hopefully this never happens
}


TRAYMENU:
Menu,Tray,NoStandard
Menu,Tray,DeleteAll
Menu,Tray,Add,%applicationname%,ABOUT

Menu,Tray,Add,&Settings,SETTINGS
Menu,Tray,Add,R&eload settings,RELOAD

Menu,Tray,Add
Menu,Tray,Add,&About,ABOUT
Menu,Tray,Add,E&xit,EXIT
Menu,Tray,Default,%applicationname%
Menu,Tray,Tip,%applicationname%
Return

SETTINGS:
Gosub,READINI
Run,BatteryDeley.ini
Return


RELOAD:
Reload


READINI:
IfNotExist,BatteryDeley.ini
{
ini=;BatteryDeley.ini
ini=%ini%`n;[Settings]
ini=%ini%`n; alert pct  -- the percentage of battery charge remaining at which the alert is issued
ini=%ini%`n; alert ms   -- milliseconds to show the alert (1 second = 1000 ms)
ini=%ini%`n; alert img  -- image to show for alert (Place images in the same directory as this program, or change ImgPath below)
ini=%ini%`n; alert cmd  -- command to execute, or .wav file to play
ini=%ini%`n; polling ms -- polling loop delay; (milliseconds between checks of battery state)
ini=%ini%`n;
ini=%ini%`n;KEEP THE ALERT PERCENTS IN DECREASING ORDER, WITH ALERT1 THE HIGHEST (FIRST ALERT TO BE TRIGGERED)
ini=%ini%`n;and don't make the changes here, make them below under [Settings]
ini=%ini%`n;alert1pct=90      `;alert1 battery percent (e.g. battery down to 22`%)
ini=%ini%`n;alert2pct=75      `;alert2 battery percent
ini=%ini%`n;alert3pct=50      `;alert3 battery percent
ini=%ini%`n;alert4pct=22      `;alert4 battery percent
ini=%ini%`n;alert5pct=16      `;alert5 battery percent
ini=%ini%`n;alert6pct=12      `;alert6 battery percent
ini=%ini%`n;alert7pct=        `;(We are not limited to 3 alerts. You may add alert 7,8,9,... as many as you please. Just keep them in decreasing order.)
ini=%ini%`n;alert8pct=        `;
ini=%ini%`n;alert9pct=        `;
ini=%ini%`n;alert1ms=8000     `;alert1 milliseconds to show (8 seconds)(Change this to whatever you like.)
ini=%ini%`n;alert2ms=8000     `;alert2 milliseconds to show (8 seconds)
ini=%ini%`n;alert3ms=8000     `;alert3 milliseconds to show (8 seconds)
ini=%ini%`n;alert4ms=10000    `;alert4 milliseconds to show (10 seconds)
ini=%ini%`n;alert5ms=10000    `;alert5 milliseconds to show (10 seconds)
ini=%ini%`n;alert6ms=30000    `;alert6 milliseconds to show (30 seconds)
ini=%ini%`n;alert7ms=         `;
ini=%ini%`n;alert8ms=         `;
ini=%ini%`n;alert9ms=         `;
ini=%ini%`n;ImgPath=`%A_ScriptDir`%   `; Place images in the same directory as this program. Or change this.
ini=%ini%`n;alert1img=`%ImgPath`%\ClipartConnection_3775464_thm.jpg     `;battery strong  (Thank you to ClipartConnection.com for their images. My favorite place to get icons.)
ini=%ini%`n;alert2img=`%ImgPath`%\ClipartConnection_3775464_thm.jpg     `;battery strong  (Thank you to ClipartConnection.com for their images. My favorite place to get icons.)
ini=%ini%`n;alert3img=`%ImgPath`%\ClipartConnection_3775464_thm.jpg     `;battery strong  (Thank you to ClipartConnection.com for their images. My favorite place to get icons.)
ini=%ini%`n;alert4img=`%ImgPath`%\ClipartConnection_3775464_thm.jpg     `;battery strong  (Thank you to ClipartConnection.com for their images. My favorite place to get icons.)
ini=%ini%`n;alert5img=`%ImgPath`%\ClipartConnection_3700840.thm.jpg     `;battery medium  (you may use your own images if you wish)
ini=%ini%`n;alert6img=`%ImgPath`%\ClipartConnection_3775471_thm.jpg     `;battery weak
ini=%ini%`n;alert7img=
ini=%ini%`n;alert8img=
ini=%ini%`n;alert9img=
ini=%ini%`n;alert1cmd=%windir%\media\notify.wav
ini=%ini%`n;alert2cmd=%windir%\media\notify.wav
ini=%ini%`n;alert3cmd=%windir%\media\notify.wav
ini=%ini%`n;alert4cmd=%windir%\media\notify.wav
ini=%ini%`n;alert5cmd=%windir%\media\notify.wav
ini=%ini%`n;alert6cmd=%windir%\media\notify.wav
ini=%ini%`n;alert7cmd=
ini=%ini%`n;alert8cmd=
ini=%ini%`n;alert9cmd=
ini=%ini%`n;ChargeAlert1pct=100     `;alert for battery charged up to this percent (e.g. battery charged up to 100`%)
ini=%ini%`n;ChargeAlert1ms=7000
ini=%ini%`n;ChargeAlert1img=`%ImgPath`%\ClipartConnection_3775464_thm.jpg
ini=%ini%`n;ChargeAlert1cmd=`%windir`%\media\notify.wav
ini=%ini%`n;ChargeAlert2pct=
ini=%ini%`n;ChargeAlert2ms=
ini=%ini%`n;ChargeAlert2img=
ini=%ini%`n;ChargeAlert2cmd=
ini=%ini%`n;ChargeAlert3pct=
ini=%ini%`n;ChargeAlert3ms=
ini=%ini%`n;ChargeAlert3img=
ini=%ini%`n;ChargeAlert3cmd=
ini=%ini%`n;UNPLUGms=4000     ;milliseconds to show alert for external power was recently unplugged (4000 = 4 seconds)
ini=%ini%`n;UNPLUGimg=`%ImgPath`%\ClipartConnection_3890038_thm.jpg     `;image for unplug alert
ini=%ini%`n;UNPLUGcmd=`%windir`%\media\notify.wav
ini=%ini%`n;PLUGINms=8000     ;milliseconds to show alert for external power was recently plugged in (2000 = 2 seconds)
ini=%ini%`n;PLUGINimg=`%ImgPath`%\ClipartConnection_3861328_thm.jpg     `;image for plugged in alert
ini=%ini%`n;PLUGINcmd=`%windir`%\media\notify.wav
ini=%ini%`n;pollingms=8000   ;polling period (how often battery status is checked)
ini=%ini%`n
ini=%ini%`n[Settings]
ini=%ini%`nalert1pct=90
ini=%ini%`nalert2pct=80
ini=%ini%`nalert3pct=70
ini=%ini%`nalert4pct=60
ini=%ini%`nalert5pct=50
ini=%ini%`nalert6pct=40
ini=%ini%`nalert7pct=30
ini=%ini%`nalert8pct=20
ini=%ini%`nalert9pct=10
ini=%ini%`nalert10pct=5
ini=%ini%`nalert1ms=8000
ini=%ini%`nalert2ms=8000
ini=%ini%`nalert3ms=8000
ini=%ini%`nalert4ms=8000
ini=%ini%`nalert5ms=8000
ini=%ini%`nalert6ms=8000
ini=%ini%`nalert7ms=8000
ini=%ini%`nalert8ms=8000
ini=%ini%`nalert9ms=30000
ini=%ini%`nalert10ms=30000
ini=%ini%`nImgPath=`%A_ScriptDir`%
ini=%ini%`nalert1img=`%ImgPath`%\ClipartConnection_3775464_thm.jpg
ini=%ini%`nalert2img=`%ImgPath`%\ClipartConnection_3775464_thm.jpg
ini=%ini%`nalert3img=`%ImgPath`%\ClipartConnection_3775464_thm.jpg
ini=%ini%`nalert4img=`%ImgPath`%\ClipartConnection_3775464_thm.jpg
ini=%ini%`nalert5img=`%ImgPath`%\ClipartConnection_3775464_thm.jpg
ini=%ini%`nalert6img=`%ImgPath`%\ClipartConnection_3775464_thm.jpg
ini=%ini%`nalert7img=`%ImgPath`%\ClipartConnection_3700840.thm.jpg
ini=%ini%`nalert8img=`%ImgPath`%\ClipartConnection_3700840.thm.jpg
ini=%ini%`nalert9img=`%ImgPath`%\ClipartConnection_3775471_thm.jpg
ini=%ini%`nalert10img=`%ImgPath`%\ClipartConnection_3775471_thm.jpg
ini=%ini%`nalert1cmd=`%windir`%\media\notify.wav
ini=%ini%`nalert2cmd=`%windir`%\media\notify.wav
ini=%ini%`nalert3cmd=`%windir`%\media\notify.wav
ini=%ini%`nalert4cmd=`%windir`%\media\notify.wav
ini=%ini%`nalert5cmd=`%windir`%\media\notify.wav
ini=%ini%`nalert6cmd=`%windir`%\media\notify.wav
ini=%ini%`nalert7cmd=`%windir`%\media\notify.wav
ini=%ini%`nalert8cmd=`%windir`%\media\notify.wav
ini=%ini%`nalert9cmd=`%windir`%\media\notify.wav
ini=%ini%`nalert10cmd=`%windir`%\media\notify.wav
ini=%ini%`nChargeAlert1pct=100
ini=%ini%`nChargeAlert1ms=7000
ini=%ini%`nChargeAlert1img=`%ImgPath`%\ClipartConnection_3775464_thm.jpg
ini=%ini%`nChargeAlert1cmd=`%windir`%\media\notify.wav
ini=%ini%`nUNPLUGms=7000
ini=%ini%`nUNPLUGimg=`%ImgPath`%\ClipartConnection_3890038_thm.jpg
ini=%ini%`nUNPLUGcmd=`%windir`%\media\notify.wav
ini=%ini%`nPLUGINms=7000
ini=%ini%`nPLUGINimg=`%ImgPath`%\ClipartConnection_3861328_thm.jpg
ini=%ini%`nPLUGINcmd=`%windir`%\media\notify.wav
ini=%ini%`npollingms=8000
ini=%ini%`n
FileAppend,%ini%,BatteryDeley.ini
ini=
}
IniRead,ImgPath,BatteryDeley.ini,Settings,ImgPath
;read in when to give battery draining alerts
loop
{
  IniRead, alert%A_Index%pct, BatteryDeley.ini, Settings, alert%A_Index%pct
  if (alert%A_Index%pct = "ERROR")
  {
    NumAlerts := A_Index - 1  ;We need to force expression mode. Note that variables go without % in expressions
    ;msgbox NumAlerts=%NumAlerts%
    break
  }
  IniRead, alert%A_Index%ms,  BatteryDeley.ini, Settings, alert%A_Index%ms    ;milliseconds to show alert
  IniRead, alert%A_Index%img, BatteryDeley.ini, Settings, alert%A_Index%img   ;image to show for this alert
  alert%A_Index%img := DeRefDeley(alert%A_Index%img)                          ;translate %ImgPath%
  IniRead, alert%A_Index%cmd, BatteryDeley.ini, Settings, alert%A_Index%cmd   ;command to run or .wav file to play for this alert
  alert%A_Index%cmd := DeRefDeley(alert%A_Index%cmd)                          ;translate %ImgPath%
}
;read in when to give battery charging alerts
loop
{
  IniRead, ChargeAlert%A_Index%pct, BatteryDeley.ini, Settings, ChargeAlert%A_Index%pct
  if (ChargeAlert%A_Index%pct = "ERROR")
  {
    NumChargeAlerts := A_Index - 1  ;We need to force expression mode. Note that variables go without % in expressions
    ;msgbox NumChargeAlerts=%NumChargeAlerts%
    break
  }
  IniRead, ChargeAlert%A_Index%ms,  BatteryDeley.ini, Settings, ChargeAlert%A_Index%ms    ;milliseconds to show ChargeAlert
  IniRead, ChargeAlert%A_Index%img, BatteryDeley.ini, Settings, ChargeAlert%A_Index%img   ;image to show for this ChargeAlert
  ChargeAlert%A_Index%img := DeRefDeley(ChargeAlert%A_Index%img)                          ;translate %ImgPath%
  IniRead, ChargeAlert%A_Index%cmd, BatteryDeley.ini, Settings, ChargeAlert%A_Index%cmd   ;command to run or .wav file to play for this ChargeAlert
  ChargeAlert%A_Index%cmd := DeRefDeley(ChargeAlert%A_Index%cmd)                          ;translate %ImgPath%
}
IniRead, UNPLUGms,  BatteryDeley.ini, Settings, UNPLUGms     ;milliseconds to show alert when power is unplugged
IniRead, UNPLUGimg, BatteryDeley.ini, Settings, UNPLUGimg    ;image to show
UNPLUGimg := DeRefDeley(UNPLUGimg)
IniRead, UNPLUGcmd, BatteryDeley.ini, Settings, UNPLUGcmd    ;command to run or .wav file to play for this alert
UNPLUGcmd := DeRefDeley(UNPLUGcmd)

IniRead, PLUGINms,  BatteryDeley.ini, Settings, PLUGINms     ;milliseconds to show alert when power is plugged in
IniRead, PLUGINimg, BatteryDeley.ini, Settings, PLUGINimg    ;image to show
PLUGINimg := DeRefDeley(PLUGINimg)
IniRead, PLUGINcmd, BatteryDeley.ini, Settings, PLUGINcmd    ;command to run or .wav file to play for this alert
PLUGINcmd := DeRefDeley(PLUGINcmd)

IniRead, FULLms,  BatteryDeley.ini, Settings, FULLms     ;milliseconds to show alert when power is plugged in
IniRead, FULLimg, BatteryDeley.ini, Settings, FULLimg    ;image to show
FULLimg := DeRefDeley(FULLimg)
IniRead, FULLcmd, BatteryDeley.ini, Settings, FULLcmd    ;command to run or .wav file to play for this alert
FULLcmd := DeRefDeley(FULLcmd)

IniRead, pollingms, BatteryDeley.ini, Settings, pollingms    ;polling period

/*
;FOR DEBUGGING
v = ImgPath=%ImgPath%
v = %v%`nalert1pct=%alert1pct%
v = %v%`nalert2pct=%alert2pct%
v = %v%`nalert3pct=%alert3pct%
v = %v%`nalert4pct=%alert4pct%
v = %v%`nalert5pct=%alert5pct%
v = %v%`nalert6pct=%alert6pct%

v = %v%`nalert1ms=%alert1ms%
v = %v%`nalert2ms=%alert2ms%
v = %v%`nalert3ms=%alert3ms%
v = %v%`nalert4ms=%alert4ms%
v = %v%`nalert5ms=%alert5ms%
v = %v%`nalert6ms=%alert6ms%

v = %v%`nalert1img=%alert1img%
v = %v%`nalert2img=%alert2img%
v = %v%`nalert3img=%alert3img%
v = %v%`nalert4img=%alert4img%
v = %v%`nalert5img=%alert5img%
v = %v%`nalert6img=%alert6img%

v = %v%`nalert1cmd=%alert1cmd%
v = %v%`nalert2cmd=%alert2cmd%
v = %v%`nalert3cmd=%alert3cmd%
v = %v%`nalert4cmd=%alert4cmd%
v = %v%`nalert5cmd=%alert5cmd%
v = %v%`nalert6cmd=%alert6cmd%

v = %v%`nPLUGINms  =%PLUGINms%
v = %v%`nPLUGINimg =%PLUGINimg%
v = %v%`nPLUGINcmd =%PLUGINcmd%
v = %v%`nUNPLUGms =%UNPLUGms%
v = %v%`nUNPLUGimg=%UNPLUGimg%
v = %v%`nUNPLUGcmd=%UNPLUGcmd%
v = %v%`nFULLms =%FULLms%
v = %v%`nFULLimg=%FULLimg%
v = %v%`nFULLcmd=%FULLcmd%

v = %v%`nNumAlerts=%NumAlerts%
v = %v%`npollingms=%pollingms%

MsgBox, 0, BatteryDeley, %v%
*/
Return


ABOUT:
Gui,99:Destroy
Gui,99:Margin,20,20
Gui,99:Add,Picture,xm Icon1,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,%applicationname% v1.4
Gui,99:Font
Gui,99:Add,Text,y+10,- Alert user when laptop battery goes below set percentages
Gui,99:Add,Text,y+5, - Also alert when the power plug is connected or disconnected
Gui,99:Add,Text,y+5, - See file BatteryDeley.ini for settings
Gui,99:Add,Text,xp+10 y+5,(if there is no BatteryDeley.ini file, run this program and it will make one)
Gui,99:Add,Picture, xp-4 y+10 w16 h16 Icon3 GDELEYWEBSITE,%applicationname%.exe
Gui,99:Add,Text,xp+20 ,David Deley:
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,x+4 GDELEYWEBSITE,http://members.cox.net/deleyd/
Gui,99:Font

Gui,99:Add,Picture,xm y+20 Icon2 G1HOURSOFTWARE,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,1 Hour Software by Skrommel
Gui,99:Font
Gui,99:Add,Text,y+10,For more tools, information and donations, please visit
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 G1HOURSOFTWARE,www.1HourSoftware.com
Gui,99:Font

Gui,99:Add,Picture,xm y+20 Icon7 GDONATIONCODER,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,DonationCoder
Gui,99:Font
Gui,99:Add,Text,y+10,Please support the contributors at
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 GDONATIONCODER,www.DonationCoder.com
Gui,99:Font

Gui,99:Add,Picture,xm y+20 Icon6 GAUTOHOTKEY,%applicationname%.exe
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

DELEYWEBSITE:
  Run,http://members.cox.net/deleyd/,,UseErrorLevel
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
  If ctrl in Static7,Static9,Static10,Static13,Static14,Static17,Static18,Static21
    DllCall("SetCursor","UInt",hCurs)
  Return
}
Return


EXIT:
ExitApp