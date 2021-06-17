clipboard(action="") {
    global
    if (action = "save")
        clipboard_r := clipboardAll
    else if (action = "get")
        {
        clipboard := ""
        send ^{c}
        clipWait, 0.3
        }
    else if (action = "paste")
        {
        send, ^{v}
        sleep 100
        }
    else if (action = "restore")
        {
        clipboard := clipboard_r
        clipboard_r := ""
        }
}