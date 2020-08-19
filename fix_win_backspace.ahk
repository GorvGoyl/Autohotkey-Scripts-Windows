#IfWinActive, ahk_class CabinetWClass 
Backspace:: 
;make sure no renaming in process and we are actually in list or in tree 

ControlGet renamestatus,Visible,,Edit1,A 
ControlGetFocus focussed, A 
if(renamestatus!=1&&(focussed="DirectUIHWND3"||focussed="SysTreeView321")) 
{ 
SendInput {Alt Down}{Up}{Alt Up} 
return 
}else{ 
Send {Backspace} 
return 
}