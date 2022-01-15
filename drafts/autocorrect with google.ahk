; Ctrl+Alt+c autocorrect selected text
^!c::
clipback := ClipboardAll
clipboard=
Send ^c
ClipWait, 0
UrlDownloadToFile % "https://www.google.com/search?q=" . clipboard, temp
FileRead, contents, temp
FileDelete temp
if (RegExMatch(contents, "(Showing results for|Did you mean:)</span>.*?>(.*?)</a>", match)) {
   StringReplace, clipboard, match2, <b><i>,, All
   StringReplace, clipboard, clipboard, </i></b>,, All
}
Send ^v
Sleep 500
clipboard := clipback
return