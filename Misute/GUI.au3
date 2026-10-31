#include-once
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Date.au3>
#include <TabConstants.au3>
#include <ProgressConstants.au3>
#include <GuiTab.au3>

; Main Form
$MainGui = GUICreate($BotTitle, 340, 396, 244, 170, -1, BitOR($WS_EX_TOPMOST, $WS_EX_WINDOWEDGE))

$Group3 = GUICtrlCreateGroup(" ", 8, 8, 324, 380, -1, $WS_EX_TRANSPARENT)
$Group1 = GUICtrlCreateGroup("Character", 16, 20, 308, 56)

Global $GUINameCombo
If $doLoadLoggedChars Then
    $GUINameCombo = GUICtrlCreateCombo($g_s_MainCharName, 28, 40, 148, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
    GUICtrlSetData(-1, Scanner_GetLoggedCharNames())
Else
    $GUINameCombo = GUICtrlCreateInput($g_s_MainCharName, 28, 40, 148, 25)
EndIf
$GUIStartButton = GUICtrlCreateButton("Start", 184, 40, 64, 25)
GUICtrlSetOnEvent($GUIStartButton, "GuiButtonHandler")
$GUIRefreshButton = GUICtrlCreateButton("Refresh", 256, 40, 56, 25)
GUICtrlSetOnEvent($GUIRefreshButton, "GuiButtonHandler")
GUICtrlCreateGroup("", -99, -99, 1, 1)

Global $g_hItemLabel = GUICtrlCreateLabel("Item to sell", 16, 92, 108, 18)
Global $g_hItemCombo = GUICtrlCreateCombo("", 124, 88, 194, 25, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))
GUICtrlSetOnEvent($g_hItemCombo, "GuiButtonHandler")
Tot_FillCombo($g_hItemCombo, $g_av_TotItems)

Global $g_hAmountLabel = GUICtrlCreateLabel("Amount per trade", 16, 120, 108, 18)
Global $g_hAmountInput = GUICtrlCreateInput($g_av_TotItems[0][3], 124, 116, 80, 22, BitOR($ES_NUMBER, $ES_RIGHT))
GUICtrlSetLimit($g_hAmountInput, 3)
GUICtrlSetOnEvent($g_hAmountInput, "GuiButtonHandler")
GUICtrlCreateLabel("(1 to 250)", 210, 120, 108, 18)

Global Const $TOT_MAX_PRICE = 100000
Global $g_i_TotPrice = 1
Global $g_hPriceLabel = GUICtrlCreateLabel("Price per stack", 16, 148, 108, 18)
Global $g_hPriceInput = GUICtrlCreateInput("1", 124, 144, 80, 22, BitOR($ES_NUMBER, $ES_RIGHT))
GUICtrlSetLimit($g_hPriceInput, 6)
GUICtrlSetOnEvent($g_hPriceInput, "GuiButtonHandler")
Global $g_hCurrencyCombo = GUICtrlCreateCombo("", 210, 144, 108, 25, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))
GUICtrlSetOnEvent($g_hCurrencyCombo, "GuiButtonHandler")
Tot_FillCombo($g_hCurrencyCombo, $g_av_TotCurrencies)

Global $g_hSummary = GUICtrlCreateLabel("", 16, 200, 308, 18, $SS_CENTER)
GUICtrlSetFont($g_hSummary, 9, $FW_BOLD)

Global $g_hKeepRunning = GUICtrlCreateCheckbox("Keep running if stock stays low", 16, 176, 196, 18)
$GUIToggleRendering = GUICtrlCreateCheckbox("Rendering", 220, 176, 96, 18)
GUICtrlSetOnEvent($GUIToggleRendering, "GuiButtonHandler")
GUICtrlSetState($GUIToggleRendering, $GUI_DISABLE)

$g_h_EditText = _GUICtrlRichEdit_Create($MainGui, "", 16, 224, 308, 64, BitOR($ES_AUTOVSCROLL, $ES_MULTILINE, $WS_VSCROLL, $ES_READONLY), $WS_EX_STATICEDGE)
_GUICtrlRichEdit_SetBkColor($g_h_EditText, $COLOR_WHITE)

$Pic1 = GUICtrlCreatePic("Misute.jpg", 42, 296, 256, 71)
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetOnEvent($GUI_EVENT_CLOSE, "GuiButtonHandler")
GUISetState(@SW_SHOW)

Func GuiButtonHandler()
    Switch @GUI_CtrlId
        Case $GUIStartButton
            If Not $BotRunning Then
                If Not $Bot_Core_Initialized Then
                    InitializeBot()
                    WinSetTitle($MainGui, "", $BotTitle & " - " & player_GetCharname())
                    GUICtrlSetState($GUINameCombo, $GUI_DISABLE)
                    GUICtrlSetState($GUIRefreshButton, $GUI_DISABLE)
                    $Bot_Core_Initialized = True
                EndIf

                Tot_ApplyChoices(True)
                GUICtrlSetState($GUIToggleRendering, $GUI_ENABLE)
                Tot_LockChoices($GUI_DISABLE)
                GUICtrlSetState($GUIStartButton, $GUI_DISABLE)

                GUICtrlSetData($GUIStartButton, "Stop")
                GUICtrlSetState($GUIStartButton, $GUI_ENABLE)
                $BotRunning = True

            ElseIf $BotRunning Then
                
                GUICTrlSetState($GUIStartButton, $GUI_DISABLE)
                GUICtrlSetData($GUIStartButton, "Pausing...")
                LogStatus("Bot will pause, please wait..")
                $BotRunning = False
            EndIf

        Case $GUIRefreshButton
            GUICtrlSetData($GUINameCombo, "")
            GUICtrlSetData($GUINameCombo, Scanner_GetLoggedCharNames())

        Case $GUIToggleRendering
            Ui_ToggleRendering()

        Case $g_hItemCombo
            ; A new item starts from its default amount in $g_av_TotItems.
            GUICtrlSetData($g_hAmountInput, $g_av_TotItems[Tot_ComboIndex($g_hItemCombo, $g_av_TotItems)][3])
            Tot_ApplyChoices(False)

        Case $g_hAmountInput, $g_hCurrencyCombo, $g_hPriceInput
            Tot_ApplyChoices(False)

        Case $GUI_EVENT_CLOSE
            Exit
    EndSwitch
EndFunc

Func Tot_FillCombo($a_h_Combo, ByRef $a_av_Rows)
    Local $l_s_List = ""
    For $l_i_Idx = 0 To UBound($a_av_Rows) - 1
        $l_s_List &= "|" & $a_av_Rows[$l_i_Idx][0]
    Next
    GUICtrlSetData($a_h_Combo, $l_s_List, $a_av_Rows[0][0])
EndFunc

Func Tot_ComboIndex($a_h_Combo, ByRef $a_av_Rows)
    Local $l_s_Pick = GUICtrlRead($a_h_Combo)
    For $l_i_Idx = 0 To UBound($a_av_Rows) - 1
        If $a_av_Rows[$l_i_Idx][0] = $l_s_Pick Then Return $l_i_Idx
    Next
    Return 0
EndFunc

; Reads the item, price and currency from the GUI into the bot and refreshes the labels.
Func Tot_ApplyChoices($a_b_Log = False)
    Local $l_i_Item = Tot_ComboIndex($g_hItemCombo, $g_av_TotItems)
    $g_s_TotItemName = $g_av_TotItems[$l_i_Item][0]
    $g_i_TotModel = $g_av_TotItems[$l_i_Item][1]
    $g_s_TotAdvertName = $g_av_TotItems[$l_i_Item][2]
    $g_i_TotLotSize = Tot_ValidLotSize(GUICtrlRead($g_hAmountInput))
    If String($g_i_TotLotSize) <> GUICtrlRead($g_hAmountInput) Then GUICtrlSetData($g_hAmountInput, $g_i_TotLotSize)

    Local $l_i_Cur = Tot_ComboIndex($g_hCurrencyCombo, $g_av_TotCurrencies)
    $g_s_TotCurName = $g_av_TotCurrencies[$l_i_Cur][0]
    $g_i_TotCurModel = $g_av_TotCurrencies[$l_i_Cur][1]
    $g_s_TotCurShort = $g_av_TotCurrencies[$l_i_Cur][2]

    Local $l_i_Price = Int(Number(GUICtrlRead($g_hPriceInput)))
    If $l_i_Price < 1 Then $l_i_Price = 1
    If $l_i_Price > $TOT_MAX_PRICE Then $l_i_Price = $TOT_MAX_PRICE
    If String($l_i_Price) <> GUICtrlRead($g_hPriceInput) Then GUICtrlSetData($g_hPriceInput, $l_i_Price)
    $g_i_TotPrice = $l_i_Price

    GUICtrlSetData($g_hPriceLabel, "Price " & Tot_PerLot())
    GUICtrlSetData($g_hSummary, Tot_Summary())
    If $a_b_Log Then LogInfo(Tot_Summary() & ".")
EndFunc

Func Tot_LockChoices($a_i_State)
    GUICtrlSetState($g_hItemCombo, $a_i_State)
    GUICtrlSetState($g_hAmountInput, $a_i_State)
    GUICtrlSetState($g_hPriceInput, $a_i_State)
    GUICtrlSetState($g_hCurrencyCombo, $a_i_State)
EndFunc

Func InitializeBot()
    GUICtrlSetState($GUIStartButton, $GUI_DISABLE)
    Local $g_s_MainCharName = GUICtrlRead($GUINameCombo)
    If $g_s_MainCharName=="" Then
        If Core_Initialize(ProcessExists("gw.exe"), True) = 0 Then
            MsgBox(0, "Error", "Guild Wars is not running.")
            Exit
        EndIf
    ElseIf $ProcessID Then
        $proc_id_int = Number($ProcessID, 2)
        If Core_Initialize($proc_id_int, True) = 0 Then
            MsgBox(0, "Error", "Could not Find a ProcessID or somewhat '"&$proc_id_int&"'  "&VarGetType($proc_id_int)&"'")
            Exit
            If ProcessExists($proc_id_int) Then
                ProcessClose($proc_id_int)
            EndIf
            Exit
        EndIf
    Else
        If Core_Initialize($g_s_MainCharName, True) = 0 Then
            MsgBox(0, "Error", "Could not Find a Guild Wars client with a Character named '"&$g_s_MainCharName&"'")
            Exit
        EndIf
    EndIf

    $Bot_Core_Initialized = True
EndFunc

Func ResetStart()
    Tot_LockChoices($GUI_ENABLE)
    GUICtrlSetState($GUIStartButton, $GUI_ENABLE)
    GUICtrlSetData($GUIStartButton, "Start")
    LogStatus("Bot paused.")
    Sleep(500)
EndFunc
