
Local Const $UI_BG = 0x0B0F1A
Local Const $UI_PANEL = 0x121A2C
Local Const $UI_NEON = 0x00F0FF
Local Const $UI_TEXT = 0xE6F1FF

$MainGui = GUICreate($BotTitle, 260, 190, -1, -1, BitOR($WS_SYSMENU, $WS_MINIMIZEBOX), BitOR($WS_EX_TOPMOST, $WS_EX_WINDOWEDGE))
GUISetBkColor($UI_BG, $MainGui)

Local $l_i_Title = GUICtrlCreateLabel('FOLLOW.AI', 12, 10, 120, 18)
GUICtrlSetColor($l_i_Title, $UI_NEON)
GUICtrlSetFont($l_i_Title, 11, 800, 0, 'Consolas')

Local $l_i_Sub = GUICtrlCreateLabel('COMMAND: FOLLOW / WAIT / RESIGN', 12, 28, 236, 14)
GUICtrlSetColor($l_i_Sub, $UI_TEXT)
GUICtrlSetFont($l_i_Sub, 8, 400, 0, 'Consolas')

Local $l_i_Panel = GUICtrlCreateLabel('', 10, 48, 240, 132)
GUICtrlSetBkColor($l_i_Panel, $UI_PANEL)

Local $l_i_CharLbl = GUICtrlCreateLabel('CHAR', 18, 56, 40, 14)
GUICtrlSetColor($l_i_CharLbl, $UI_NEON)
GUICtrlSetFont($l_i_CharLbl, 8, 700, 0, 'Consolas')

Global $GUINameCombo
If $doLoadLoggedChars Then
    $GUINameCombo = GUICtrlCreateCombo($g_s_MainCharName, 64, 52, 180, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
    GUICtrlSetData(-1, Scanner_GetLoggedCharNames())
Else
    $GUINameCombo = GUICtrlCreateInput($g_s_MainCharName, 64, 52, 180, 25)
EndIf
GUICtrlSetColor($GUINameCombo, $UI_TEXT)
GUICtrlSetFont($GUINameCombo, 9, 400, 0, 'Consolas')

Local $l_i_StartLbl = GUICtrlCreateLabel('RUN', 18, 84, 40, 14)
GUICtrlSetColor($l_i_StartLbl, $UI_NEON)
GUICtrlSetFont($l_i_StartLbl, 8, 700, 0, 'Consolas')

$GUIStartButton = GUICtrlCreateButton('START', 64, 80, 86, 24)
GUICtrlSetOnEvent($GUIStartButton, "GuiButtonHandler")
$GUIRefreshButton = GUICtrlCreateButton('SYNC', 158, 80, 86, 24)
GUICtrlSetOnEvent($GUIRefreshButton, "GuiButtonHandler")
GUICtrlSetColor($GUIStartButton, $UI_TEXT)
GUICtrlSetColor($GUIRefreshButton, $UI_TEXT)
GUICtrlSetFont($GUIStartButton, 9, 700, 0, 'Consolas')
GUICtrlSetFont($GUIRefreshButton, 9, 700, 0, 'Consolas')

Local $l_i_LogLbl = GUICtrlCreateLabel('LOG', 18, 114, 40, 14)
GUICtrlSetColor($l_i_LogLbl, $UI_NEON)
GUICtrlSetFont($l_i_LogLbl, 8, 700, 0, 'Consolas')

$g_h_EditText = _GUICtrlRichEdit_Create($MainGui, "", 18, 130, 226, 44, BitOR($ES_AUTOVSCROLL, $ES_MULTILINE, $WS_VSCROLL, $ES_READONLY))
_GUICtrlRichEdit_SetBkColor($g_h_EditText, $UI_BG)
_GUICtrlRichEdit_SetTextColor($g_h_EditText, $UI_TEXT)

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
