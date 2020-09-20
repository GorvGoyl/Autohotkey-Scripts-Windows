'put it in startup folder to run the mentioned ahk script at startup
Set WshShell = CreateObject("WScript.Shell" ) 
  WshShell.Run """C:\Users\1gour\OneDrive\Documents\old\Github\Autohotkey-Scripts-Windows\mouseless.ahk""", 0 'Must quote command if it has spaces; must escape quotes
  WshShell.Run """C:\Users\1gour\OneDrive\Documents\old\Github\Autohotkey-Scripts-Windows\app_switcher.ahk""", 0
  WshShell.Run """C:\Users\1gour\OneDrive\Documents\old\Github\Autohotkey-Scripts-Windows\batterydeley\source\BatteryDeley.ahk""", 0
  WshShell.Run """C:\Users\1gour\OneDrive\Documents\old\Github\Autohotkey-Scripts-Windows\batterydeley\source\open_shell_here.ahk""", 0
  Set WshShell = Nothing