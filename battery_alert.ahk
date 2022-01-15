; Battery notification
;
; When the battery is charged, a notification
; will appear to tell the user to remove the charger
;
; When the battery is below 10%, a notification
; will appear to tell the user to plug in the charger

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

; set desired low battery percentage to get alert
lowBatteryPercentage := 90
;

sleepTime := 60
chargedPercentage := 99
percentage := "%"

Loop{ ;Loop forever

;Grab the current data.
VarSetCapacity(powerstatus, 1+1+1+1+4+4)
success := DllCall("kernel32.dll\GetSystemPowerStatus", "uint", &powerstatus)

acLineStatus:=ReadInteger(&powerstatus,0)
batteryLifePercent:=ReadInteger(&powerstatus,2)

;Is the battery charged higher than 99%
if (batteryLifePercent > chargedPercentage){ ;Yes. 

	if (acLineStatus == 1){ ;Only notify me once
		if (batteryLifePercent == 255){
			sleepTime := 60
			}
		else{
			title= Battery: %batteryLifePercent%`%
			popupmfk(title,"Remove Charger", , , 1)
			;Format the message box
			SoundBeep, 1500, 200
			; MsgBox, %output% ;Notify me.
			sleepTime := 600
		}
	}
	else{
		sleepTime := 60
	}
}

if (batteryLifePercent < lowBatteryPercentage){ ;Yes. 

	if (acLineStatus == 0){ ;Only notify me once
		;Format the message box
		; output=PLUG IN THE CHARGING CABLE.`nBattery Life: %batteryLifePercent%%percentage%
		title= Battery: %batteryLifePercent%`%
		SoundBeep, 1500, 200
		; MsgBox, %output% ;Notify me.
		popupmfk(title,"Plug-in Charger", 7000, , 1)
		sleepTime := 300
	}
	else{
		sleepTime := 60
	}
}


sleep, sleepTime*1000 ;sleep for 5 seconds
}

;Format the data
ReadInteger( p_address, p_offset)
{
  loop, 1
	value := 0+( *( ( p_address+p_offset )+( a_Index-1 ) ) << ( 8* ( a_Index-1 ) ) )
  return, value
}


popupmfk(popTitle=0, popMsg=0, popTime=5000, icoPath=0, hasGoAway=0)
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