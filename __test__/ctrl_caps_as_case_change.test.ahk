#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
SetOptions := "StrCaseSense On"

; FUNCTIONS
upper_case(target_text) {
    StringUpper, target_text, target_text
    return target_text
}
lower_case(target_text) {
    StringLower, target_text, target_text
    return target_text
}
title_case(target_text) {
    StringLower, target_text, target_text, T
    return target_text
}
kebab_case(target_text) {
    StringLower, target_text, target_text
    target_text := RegExReplace(target_text, "[_-]", " ")
    StringReplace, target_text, target_text, %A_Space%, -, All
    return target_text
}
snake_case(target_text) {
    StringLower, target_text, target_text
    target_text := RegExReplace(target_text, "[_-]", " ")
    StringReplace, target_text, target_text, %A_Space%, _, All
    return target_text
}


; TEST
test(testName, testInput, exactOutput, expectedOutput, isDisplayPass) {
    if (exactOutput == expectedOutput){
        if (isDisplayPass)
            MsgBox, %testName% | PASS: %exactOutput%
    }
    else {
        MsgBox, %testName% | BUG: input(%testInput%) output(%exactOutput%) expected(%expectedOutput%)
    }
}

test_loop(testName, caseIndex, isDisplayPass) {
    testInputList := ["JUST TEST", "just test", "just-test", "just_test"]
    expectedOutputList := ["just-test", "just_test"]
    _output := expectedOutputList[caseIndex]
    
    i := 1
    while (i <= 4) {
        if (caseIndex == 1) {
            _input := kebab_case(testInputList[i])
            test(testName, testInputList[i], _input, _output, isDisplayPass)
        }
        else if (caseIndex == 2) {
            _input := snake_case(testInputList[i])
            test(testName, testInputList[i], _input, _output, isDisplayPass)
        }
        i++
    }
}

test_loop("Kebab Case",  1, true)
test_loop("Snake Case",  2, true)

