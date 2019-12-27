'put it in startup folder to run the mentioned ahk script at startup
Set WshShell = CreateObject("WScript.Shell" ) 
  WshShell.Run """C:\Users\1gour\OneDrive\Documents\old\Github\Productivity-Scripts-Autohotkey-Windows\mouseless.ahk""", 0 'Must quote command if it has spaces; must escape quotes
  WshShell.Run """C:\Users\1gour\OneDrive\Documents\old\Github\Productivity-Scripts-Autohotkey-Windows\app_switcher.ahk""", 0 'Must quote command if it has spaces; must escape quotes
  Set WshShell = Nothing