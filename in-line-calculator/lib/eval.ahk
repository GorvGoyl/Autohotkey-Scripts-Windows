    ; eval by Laszlo: http://www.autohotkey.com/board/topic/4779-simple-script-for-evaluating-arithmetic-expressions/page-2#entry101504

eval(x) {                              ; expression preprocessing
   Static pi = 3.141592653589793, e = 2.718281828459045

   StringReplace x, x,`%, \, All       ; % -> \ for MOD
   x := RegExReplace(x,"\s*")          ; remove whitespace
   x := RegExReplace(x,"([a-zA-Z]\w*)([^\w\(]|$)","%$1%$2") ; var -> %var%
   Transform x, Deref, %x%             ; dereference all %var%

   StringReplace x, x, -, #, All       ; # = subtraction
   StringReplace x, x, (#, (0#, All    ; (-x -> (0-x
   If (Asc(x) = Asc("#"))
      x = 0%x%                         ; leading -x -> 0-x
   StringReplace x, x, (+, (, All      ; (+x -> (x
   If (Asc(x) = Asc("+"))
      StringTrimLeft x, x, 1           ; leading +x -> x
   StringReplace x, x, **, @, All      ; ** -> @ for easier process

   Loop {                              ; find innermost (..)
      If !RegExMatch(x, "(.*)\(([^\(\)]*)\)(.*)", y)
         Break
      x := y1 . Eval@(y2) . y3         ; replace "(x)" with value of x
   }
   Return Eval@(x)                     ; no more (..)
}

Eval@(x) {
   RegExMatch(x, "(.*)(\+|\#)(.*)", y) ; execute rightmost +- operator
   IfEqual y2,+,  Return Eval@(y1) + Eval@(y3)
   IfEqual y2,#,  Return Eval@(y1) - Eval@(y3)
                                       ; execute rightmost */% operator
   RegExMatch(x, "(.*)(\*|\/|\\)(.*)", y)
   IfEqual y2,*,  Return Eval@(y1) * Eval@(y3)
   IfEqual y2,/,  Return Eval@(y1) / Eval@(y3)
   IfEqual y2,\,  Return Mod(Eval@(y1),Eval@(y3))
                                       ; execute rightmost power
   StringGetPos i, x, @, R
   IfGreaterOrEqual i,0, Return Eval@(SubStr(x,1,i)) ** Eval@(SubStr(x,2+i))
                                       ; execute rightmost function
   If !RegExMatch(x,".*(abs|floor|sqrt)(.*)", y)
      Return x                         ; no more function
   IfEqual y1,abs,  Return abs(  Eval@(y2))
   IfEqual y1,floor,Return floor(Eval@(y2))
   IfEqual y1,sqrt, Return sqrt( Eval@(y2))
}