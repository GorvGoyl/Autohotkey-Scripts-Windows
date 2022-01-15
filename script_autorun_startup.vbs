'put it in startup folder to run the mentioned ahk scripts at startup
Set WshShell = CreateObject("WScript.Shell" ) 
  WshShell.Run """C:\Users\1gour\OneDrive\Documents\Autohotkey-Scripts-Windows\mouseless.ahk""", 0 'Must quote command if it has spaces; must escape quotes
  WshShell.Run """C:\Users\1gour\OneDrive\Documents\Autohotkey-Scripts-Windows\look_up.ahk""", 0
  Set WshShell = Nothing