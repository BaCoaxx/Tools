Global Const $GUI_COLOR_BG = 0x090B13
Global Const $GUI_COLOR_PANEL = 0x111827
Global Const $GUI_COLOR_EDGE = 0x24324A
Global Const $GUI_COLOR_TEXT = 0xD4E7FF
Global Const $GUI_COLOR_ACCENT = 0x00F0FF
Global Const $GUI_COLOR_LOG = 0x59E6FF
Global Const $GUI_COLOR_PINK = 0xFF4FD8

$MainGui = GUICreate($BotTitle, 248, 228, 821, 240, -1, BitOR($WS_EX_TOPMOST, $WS_EX_WINDOWEDGE))
GUISetBkColor($GUI_COLOR_BG, $MainGui)

$GUIHeader = GUICtrlCreateLabel("FOLLOW//AI", 14, 10, 92, 18)
GUICtrlSetColor($GUIHeader, $GUI_COLOR_ACCENT)
GUICtrlSetFont($GUIHeader, 9, 800, 0, "Arial")

$GUIHeaderTag = GUICtrlCreateLabel("cheap neon ops", 136, 12, 92, 15)
GUICtrlSetColor($GUIHeaderTag, $GUI_COLOR_PINK)
GUICtrlSetFont($GUIHeaderTag, 7, 400, 0, "Arial")

$GUIAccent = GUICtrlCreateLabel("", 14, 31, 220, 2)
GUICtrlSetBkColor($GUIAccent, $GUI_COLOR_PINK)

$Group1 = GUICtrlCreateGroup("", 10, 40, 228, 178)
GUICtrlSetColor($Group1, $GUI_COLOR_EDGE)

$GUICharLabel = GUICtrlCreateLabel("char link", 18, 52, 64, 14)
GUICtrlSetColor($GUICharLabel, $GUI_COLOR_ACCENT)
GUICtrlSetFont($GUICharLabel, 7, 700, 0, "Arial")

Global $GUINameCombo
If $doLoadLoggedChars Then
    $GUINameCombo = GUICtrlCreateCombo($g_s_MainCharName, 18, 70, 212, 24, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
    GUICtrlSetData(-1, Scanner_GetLoggedCharNames())
Else
    $GUINameCombo = GUICtrlCreateInput($g_s_MainCharName, 18, 70, 212, 24)
EndIf
GUICtrlSetColor($GUINameCombo, $GUI_COLOR_TEXT)
GUICtrlSetBkColor($GUINameCombo, $GUI_COLOR_PANEL)
GUICtrlSetFont($GUINameCombo, 9, 400, 0, "Arial")

$GUIStartButton = GUICtrlCreateButton("JACK IN", 18, 102, 102, 28)
GUICtrlSetColor($GUIStartButton, $GUI_COLOR_ACCENT)
GUICtrlSetBkColor($GUIStartButton, $GUI_COLOR_PANEL)
GUICtrlSetFont($GUIStartButton, 8, 700, 0, "Arial")
GUICtrlSetOnEvent($GUIStartButton, "GuiButtonHandler")
$GUIRefreshButton = GUICtrlCreateButton("PING", 128, 102, 102, 28)
GUICtrlSetColor($GUIRefreshButton, $GUI_COLOR_PINK)
GUICtrlSetBkColor($GUIRefreshButton, $GUI_COLOR_PANEL)
GUICtrlSetFont($GUIRefreshButton, 8, 700, 0, "Arial")
GUICtrlSetOnEvent($GUIRefreshButton, "GuiButtonHandler")

$g_h_EditText = _GUICtrlRichEdit_Create($MainGui, "", 18, 138, 212, 66, BitOR($ES_AUTOVSCROLL, $ES_MULTILINE, $WS_VSCROLL, $ES_READONLY))
_GUICtrlRichEdit_SetBkColor($g_h_EditText, _GuiColorToColorRef($GUI_COLOR_PANEL))
_GUICtrlRichEdit_SetCharColor($g_h_EditText, _GuiColorToColorRef($GUI_COLOR_LOG))

GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUISetState(@SW_SHOW)

Func _Exit()
    Exit
EndFunc

Func _GuiColorToColorRef($iColor)
    Return BitOR(BitShift(BitAND($iColor, 0xFF0000), 16), BitAND($iColor, 0x00FF00), BitShift(BitAND($iColor, 0x0000FF), -16))
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
