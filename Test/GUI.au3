
$MainGui = GUICreate($BotTitle, 281, 257, 821, 240, -1, BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE))
GUISetBkColor(0xEAEAEA, $MainGui)
$Group1 = GUICtrlCreateGroup("Select Your Character", 8, 8, 265, 241)
Global $GUINameCombo
If $doLoadLoggedChars Then
    $GUINameCombo = GUICtrlCreateCombo($g_s_MainCharName, 24, 32, 233, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
    GUICtrlSetData(-1, Scanner_GetLoggedCharNames())
Else
    $GUINameCombo = GUICtrlCreateInput($g_s_MainCharName, 24, 32, 233, 25)
EndIf

; Buttons side by side under checkbox
$GUIStartButton = GUICtrlCreateButton("Start", 24, 64, 105, 33)
GUICtrlSetOnEvent($GUIStartButton, "GuiButtonHandler")
$GUIRefreshButton = GUICtrlCreateButton("Refresh", 152, 64, 105, 33)
GUICtrlSetOnEvent($GUIRefreshButton, "GuiButtonHandler")

; Adjusted Rich Edit size for smaller window
$g_h_EditText = _GUICtrlRichEdit_Create($MainGui, "", 24, 112, 233, 121, BitOR($ES_AUTOVSCROLL, $ES_MULTILINE, $WS_VSCROLL, $ES_READONLY))
_GUICtrlRichEdit_SetBkColor($g_h_EditText, $COLOR_WHITE)

GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUISetState(@SW_SHOW)

Func _Exit()
    Exit
EndFunc

Func StartBot()
    Local $g_s_MainCharName = GUICtrlRead($GUINameCombo)
    If $g_s_MainCharName=="" Then
        If Core_Initialize(ProcessExists("gw.exe"), True) = 0 Then
            MsgBox(0, "Error", "Guild Wars is not running.")
            _Exit()
        EndIf
    ElseIf $ProcessID Then
        $proc_id_int = Number($ProcessID, 2)
        If Core_Initialize($proc_id_int, True) = 0 Then
            MsgBox(0, "Error", "Could not Find a ProcessID or somewhat '"&$proc_id_int&"'  "&VarGetType($proc_id_int)&"'")
            _Exit()
            If ProcessExists($proc_id_int) Then
                ProcessClose($proc_id_int)
            EndIf
            Exit
        EndIf
    Else
        If Core_Initialize($g_s_MainCharName, True) = 0 Then
            MsgBox(0, "Error", "Could not Find a Guild Wars client with a Character named '"&$g_s_MainCharName&"'")
            _Exit()
        EndIf
    EndIf
    GUICtrlSetState($GUIStartButton, $GUI_Disable)
    GUICtrlSetState($GUIRefreshButton, $GUI_Disable)
    GUICtrlSetState($GUINameCombo, $GUI_DISABLE)
    WinSetTitle($MainGui, "", player_GetCharname())
    $BotRunning = True
    $Bot_Core_Initialized = True
EndFunc

Func GuiButtonHandler()
    Switch @GUI_CtrlId
		Case $GUIStartButton
            StartBot()

        Case $GUIRefreshButton
            GUICtrlSetData($GUINameCombo, "")
            GUICtrlSetData($GUINameCombo, Scanner_GetLoggedCharNames())

        Case $GUI_EVENT_CLOSE
            Exit
    EndSwitch
EndFunc