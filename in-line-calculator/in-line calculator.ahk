/*
[script info]
version     = 2.5.3
description = an interface-less calculator for basic math
author      = davebrny
source      = https://github.com/davebrny/in-line-calculator
*/

    ;# script settings
#noEnv
#singleInstance, force
sendMode input

    ;# ini settings
iniRead, section, % a_scriptDir "\settings.ini", settings
loop, parse, % section, `n, `r
    {
    stringGetPos, pos, a_loopField, =, L1
    stringMid, ini_key, a_loopField, pos, , L
    stringMid, ini_value, a_loopField, pos + 2
    %ini_key% := ini_value
    }

    ;# tray menu stuff
if (a_isCompiled = 1)
    menu, tray, add, Reload This Script, reload
menu, tray, icon, % a_scriptDir "\in-line calculator.ico"
start_with_windows(1)    ; add the option to start the script when windows boots
menu, tray, add, Github readme, open_github

    ;# group calculator apps
groupAdd, calculators, Calculator ahk_exe ApplicationFrameHost.exe  ; windows 10
groupAdd, calculators, ahk_class CalcFrame                     ; windows classic
groupAdd, calculators, ahk_exe numbers.exe                     ; windows 8

    ;# set hotstrings & hotkeys
hotkey, ifWinNotActive, ahk_group calculators
if (enable_hotstrings = "yes")
    {
    if (trigger_key)
        {
        hotkey, ~%trigger_key%, inline_hotstring, on
        delete_n := "2"
        }
    else  ; trigger with any number key or -.(
        {
        if (enable_number_row = "yes")
            {
            loop, 10    ; set 0 to 9 on the number row
                hotkey, % "~" . a_index - 1, inline_hotstring, on
            hotkey, ~- , inline_hotstring, on
            hotkey, ~. , inline_hotstring, on
            hotkey, ~( , inline_hotstring, on
            }
        if (enable_number_pad = "yes")
            {
            loop, 10    ; set 0 to 9 on the numberpad
                hotkey, % "~numpad" . a_index - 1, inline_hotstring, on 
            hotkey, ~numpadDot, inline_hotstring, on
            hotkey, ~numpadSub, inline_hotstring, on
            }
        delete_n := "1"
        }
    if (numpadEnter_endKey = "yes")
        hotkey, ~numpadEnter, numpadEnter_endKey, on
    }
if (result_hotkey)
    hotkey, % result_hotkey, inline_hotkey, on
if (equation_hotkey)
    hotkey, % equation_hotkey, inline_hotkey, on
if (history_hotkey)
    hotkey, % history_hotkey, history_menu, on
hotkey, ifWinNotActive

    ;# keys that will end the calculator
end_keys =
(join
{c}{f}{g}{h}{i}{j}{k}{l}{n}{o}{q}{r}{u}{v}{w}{y}{z}{[}{]}{;}{'}{``}{#}{=}{!}{"}
{$}{`%}{^}{&}{_}{{}{}}{:}{@}{~}{<}{>}{?}{\}{|}{up}{down}{left}{right}{esc}{enter}
{delete}{backspace}{tab}{LWin}{rWin}{LControl}{rControl}{LAlt}{rAlt}{printScreen}
{home}{end}{insert}{pgUp}{pgDn}{numlock}{scrollLock}{help}{appsKey}{pause}{sleep}
{ctrlBreak}{capsLock}{numpadEnter}{numpadUp}{numpadDown}{numpadLeft}{numpadRight}
{numpadClear}{numpadHome}{numpadEnd}{numpadPgUp}{numpadPgDn}{numpadIns}{numpadDel}
{browser_back}{browser_forward}{browser_refresh}{browser_stop}{browser_search}
{browser_favorites}{browser_home}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}
{F12}{F13}{F14}{F15}{F16}{F17}{F18}{F19}{F20}{F21}{F22}{F23}{F24}
)

history := []
calculator_state := "off"

return  ; end of auto-execute ---------------------------------------------------









inline_hotstring:
if (calculator_state = "off")
    {
    calculator("on")

    stringReplace, this_input, a_thisHotkey, ~     ,  ,
    stringReplace, this_input, this_input  , numpad,  ,
    stringReplace, this_input, this_input  , enter ,  ,
    stringReplace, this_input, this_input  , dot   , .,
    stringReplace, this_input, this_input  , sub   , -,
    stringReplace, this_input, this_input  , %trigger_key%,  ,
    active_window := winExist("a")

    loop,
        {
        input, new_input, V %timeout%, %end_keys%
        this_input .= new_input    ; append
        this_endkey := strReplace(errorLevel, "EndKey:", "")
        if (this_endkey = "backspace")    ; trim and continue with loop/input
            stringTrimRight, this_input, this_input, 1
        else break ; if any other end key
        }
    if (this_endkey = "numpadEnter") and (numpadEnter_endKey = "yes")
        this_endkey := result_endkey

    if (this_endkey != result_endkey) and (this_endkey != equation_endkey)
        goTo, turn_calculator_off
    if (winExist("a") != active_window)
        goTo, turn_calculator_off
	original_equation := this_input
    equation := convert_letters(this_input)    ; convert letters to math symbols
    if equation contains +,-,*,/
        goSub, calculate_equation

    calculator("off")
    }
return



inline_hotkey:
clipboard("save")
clipboard("get")
equation := convert_letters(trim(clipboard))
clipboard("restore")

stringReplace, equation, equation, `r`n, % " ", all  ; replace lines with spaces
stringReplace, equation, equation, `n,   % " ", all
loop,    ; remove double spaces
    stringReplace, equation, equation, % a_space . a_space, % a_space, useErrorLevel
until (errorLevel = 0)

if (equation = "") or if regExMatch(equation, "[^0-9\Q+*-/(),. \E]")
	return    ; only continue if numbers, +/-*,.() or spaces

if equation not contains +,-,*,/    ; convert spaces to pluses
    stringReplace, equation, equation, % a_space, +, all

goSub, calculate_equation
goSub, clear_vars
return



calculate_equation:
result := eval( strReplace(equation, ",", "") )    ; convert string to expression
if (result != "")
    {
	if (nb_decimals != "no")
	{
		result := Round(result , nb_decimals)
	}
    if inStr(equation, ",")    ; add comma back in to numbers over 1,000
        {
        stringSplit, split, result, .
        result := regExReplace(split1, "(\d)(?=(?:\d{3})+(?:\.|$))", "$1,") "." split2
        }
    if inStr(result, ".")
        result := rTrim( rTrim(result, "0"), ".")       ; trim trailing .000

    if (a_thisHotkey = result_hotkey) or (a_thisHotkey = equation_hotkey)
         send % "{backspace}"                                  ; delete selected text
    else send % "{backspace " strLen(original_equation) + delete_n "}"  ; delete hotstring input

    clipboard("save")
    if (this_endkey = result_endkey) or (a_thisHotkey = result_hotkey)
         clipboard := result
    else clipboard := equation " = " result
    clipboard("paste")
    clipboard("restore")

    history.insertAt(1, equation "    =    " result)
    if (history.maxIndex() > 15)
        history.pop()
    }
return



calculator(mode) {
    global
    if (mode = "on")
        {
        calculator_state := "on"
        menu, tray, icon, % a_scriptDir "\in-line calculator.ico", 2  ; plus icon
        }
    else if (mode = "off")
        {
        calculator_state := "off"
        menu, tray, icon, % a_scriptDir "\in-line calculator.ico", 1  ; default icon
        goSub, clear_vars
        }
}

turn_calculator_off:
calculator("off")
return



convert_letters(string) {
	; I tried to add the tax number as a variable but it's always empty. Nore sure why so I'll leave it like that.
	string := StrReplace(string, "e", 1.14975) ; convert e to tax % value

    for letters, symbols in {"p":"+", "a":"+", "m":"-", "s":"-"
                           , "x":"*", "t":"*", "b":"*", "d":"/"}
        stringReplace, string, string, % letters, % symbols, all
    return string
}



numpadEnter_endKey:
if getKeyState("numLock", "T") and (trigger_key != "")
    {
    send, {backspace}{%trigger_key%}
    goSub, inline_hotstring
    }
return



clear_vars:
this_endkey := ""
this_input  := ""
new_input   := ""
equation    := ""
return



#ifWinActive, ahk_group calculators

p::send, {+}    ; plus
a::send, {+}    ; and OR add
m::send, {-}    ; minus
s::send, {-}    ; subtract
x::send, {*}    ; multiply
t::send, {*}    ; times
b::send, {*}    ; by
d::send, {/}    ; divide

=::send, {enter}

#ifWinActive



history_menu:
menu, history_menu, add,     in-line calculator history:, history_select
menu, history_menu, disable, in-line calculator history:
menu, history_menu, add
loop, % history.maxIndex()
    menu, history_menu, add, % history[a_index], history_select
if history.maxIndex()
    menu, history_menu, add
menu, history_menu, add, clear history, clear_history
menu, history_menu, show
menu, history_menu, deleteAll
return

history_select:
this_menu := a_thisMenuItem
if getKeyState("ctrl", "p")
    {
    stringSplit, split_, this_menu, =, % a_space
    this_menu := split_2    ; result only
    }
stringReplace, this_menu, this_menu, % "    =    ", % " = "
clipboard := this_menu
msg(this_menu "  added to the clipboard")
return

clear_history:
history := []
msg("history cleared")
return



msg(string) {
    toolTip, % string
    setTimer, msg_timer, 2500
}
msg_timer:
setTimer, msg_timer, off
toolTip,
return



reload:
reload
sleep 1000
msgBox, 4, , The script could not be reloaded and will need to be manually restarted. Would you like Exit?
ifMsgBox, yes, exitApp
return



open_github:
run, https://github.com/davebrny/in-line-calculator#usage
return