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
$MainGui = GUICreate($BotTitle, 340, 368, 244, 170, -1, BitOR($WS_EX_TOPMOST, $WS_EX_WINDOWEDGE))

$Group3 = GUICtrlCreateGroup(" ", 8, 8, 324, 352, -1, $WS_EX_TRANSPARENT)
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
Tot_FillItemCombo()

Global $g_i_EctoPerStack = 1
Global $g_hPriceLabel = GUICtrlCreateLabel("Ectos per stack", 16, 120, 108, 18)
Global $g_hPriceSlider = GUICtrlCreateSlider(124, 116, 156, 22)
GUICtrlSetLimit($g_hPriceSlider, 10, 1)
GUICtrlSetData($g_hPriceSlider, $g_i_EctoPerStack)
GUICtrlSetOnEvent($g_hPriceSlider, "GuiButtonHandler")
Global $g_hPriceValue = GUICtrlCreateLabel("1", 286, 116, 32, 22, $SS_CENTER)
GUICtrlSetFont($g_hPriceValue, 12, $FW_BOLD)
GUIRegisterMsg($WM_HSCROLL, "Tot_PriceScroll")

Global $g_hKeepRunning = GUICtrlCreateCheckbox("Keep running if stock stays low", 16, 148, 196, 18)
$GUIToggleRendering = GUICtrlCreateCheckbox("Rendering", 220, 148, 96, 18)
GUICtrlSetOnEvent($GUIToggleRendering, "GuiButtonHandler")
GUICtrlSetState($GUIToggleRendering, $GUI_DISABLE)

$g_h_EditText = _GUICtrlRichEdit_Create($MainGui, "", 16, 176, 308, 84, BitOR($ES_AUTOVSCROLL, $ES_MULTILINE, $WS_VSCROLL, $ES_READONLY), $WS_EX_STATICEDGE)
_GUICtrlRichEdit_SetBkColor($g_h_EditText, $COLOR_WHITE)

$Pic1 = GUICtrlCreatePic("Misute.jpg", 42, 268, 256, 71)
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

                Tot_SelectItem()
                GUICtrlSetState($GUIToggleRendering, $GUI_ENABLE)
                GUICtrlSetState($g_hPriceSlider, $GUI_DISABLE)
                GUICtrlSetState($g_hItemCombo, $GUI_DISABLE)
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

        Case $g_hPriceSlider
            Tot_ShowPrice()

        Case $GUI_EVENT_CLOSE
            Exit
    EndSwitch
EndFunc

Func Tot_FillItemCombo()
    Local $l_s_List = ""
    For $l_i_Idx = 0 To UBound($g_av_TotItems) - 1
        $l_s_List &= "|" & $g_av_TotItems[$l_i_Idx][0]
    Next
    GUICtrlSetData($g_hItemCombo, $l_s_List, $g_av_TotItems[0][0])
EndFunc

; Points the bot at the item picked in the dropdown.
Func Tot_SelectItem()
    Local $l_s_Pick = GUICtrlRead($g_hItemCombo)
    For $l_i_Idx = 0 To UBound($g_av_TotItems) - 1
        If $g_av_TotItems[$l_i_Idx][0] = $l_s_Pick Then
            $g_s_TotItemName = $g_av_TotItems[$l_i_Idx][0]
            $g_i_TotModel = $g_av_TotItems[$l_i_Idx][1]
            $g_s_TotAdvertName = $g_av_TotItems[$l_i_Idx][2]
            LogInfo("Selling: " & $g_s_TotItemName & " (model " & $g_i_TotModel & ").")
            Return
        EndIf
    Next
EndFunc

Func Tot_PriceScroll($hWnd, $iMsg, $wParam, $lParam)
    If $lParam = GUICtrlGetHandle($g_hPriceSlider) Then Tot_ShowPrice()
    Return $GUI_RUNDEFMSG
EndFunc

Func Tot_ShowPrice()
    $g_i_EctoPerStack = Number(GUICtrlRead($g_hPriceSlider))
    If $g_i_EctoPerStack < 1 Then $g_i_EctoPerStack = 1
    If $g_i_EctoPerStack > 10 Then $g_i_EctoPerStack = 10
    GUICtrlSetData($g_hPriceValue, $g_i_EctoPerStack)
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
    GUICtrlSetState($g_hPriceSlider, $GUI_ENABLE)
    GUICtrlSetState($g_hItemCombo, $GUI_ENABLE)
    GUICtrlSetState($GUIStartButton, $GUI_ENABLE)
    GUICtrlSetData($GUIStartButton, "Start")
    LogStatus("Bot paused.")
    Sleep(500)
EndFunc
