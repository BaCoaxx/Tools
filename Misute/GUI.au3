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
#include <GuiComboBox.au3>
#include <FileConstants.au3>

; Main Form
$MainGui = GUICreate($BotTitle, 340, 452, 244, 170, -1, BitOR($WS_EX_TOPMOST, $WS_EX_WINDOWEDGE))

$Group3 = GUICtrlCreateGroup(" ", 8, 8, 324, 436, -1, $WS_EX_TRANSPARENT)
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

Global Const $TOT_MAX_PRICE = 100000
Global $g_i_TotPrice = 1

; One set of controls per tab, indexed by $TOT_MODE_SELL / $TOT_MODE_BUY.
; The tab that is showing when Start is pressed is the mode the bot runs in.
Global $g_ah_TabItem[2], $g_ah_ItemCombo[2], $g_ah_AmountInput[2], $g_ah_PriceLabel[2]
Global $g_ah_PriceInput[2], $g_ah_CurrencyCombo[2], $g_ah_KeepRunning[2], $g_ah_Summary[2]

Global $g_hTab = GUICtrlCreateTab(16, 84, 308, 164)
GUICtrlSetOnEvent($g_hTab, "GuiButtonHandler")
$g_ah_TabItem[$TOT_MODE_SELL] = GUICtrlCreateTabItem("Sell")
Tot_CreateTabControls($TOT_MODE_SELL, "Item to sell", "Keep running if stock stays low")
$g_ah_TabItem[$TOT_MODE_BUY] = GUICtrlCreateTabItem("Buy")
Tot_CreateTabControls($TOT_MODE_BUY, "Item to buy", "Keep running if currency runs low")
GUICtrlCreateTabItem("")

Global $g_hSaveButton = GUICtrlCreateButton("Save config", 16, 254, 90, 25)
GUICtrlSetOnEvent($g_hSaveButton, "GuiButtonHandler")
Global $g_hLoadButton = GUICtrlCreateButton("Load config", 112, 254, 90, 25)
GUICtrlSetOnEvent($g_hLoadButton, "GuiButtonHandler")
$GUIToggleRendering = GUICtrlCreateCheckbox("Rendering", 228, 258, 90, 18)
GUICtrlSetOnEvent($GUIToggleRendering, "GuiButtonHandler")
GUICtrlSetState($GUIToggleRendering, $GUI_DISABLE)

$g_h_EditText = _GUICtrlRichEdit_Create($MainGui, "", 16, 286, 308, 64, BitOR($ES_AUTOVSCROLL, $ES_MULTILINE, $WS_VSCROLL, $ES_READONLY), $WS_EX_STATICEDGE)
_GUICtrlRichEdit_SetBkColor($g_h_EditText, $COLOR_WHITE)

$Pic1 = GUICtrlCreatePic("Misute.jpg", 42, 358, 256, 71)
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetOnEvent($GUI_EVENT_CLOSE, "GuiButtonHandler")
GUISetState(@SW_SHOW)

; Builds the item, amount, price, currency, keep running and summary controls
; inside the tab item that was just created. Both tabs use the same layout.
Func Tot_CreateTabControls($a_i_Tab, $a_s_ItemText, $a_s_KeepText)
    GUICtrlCreateLabel($a_s_ItemText, 26, 118, 98, 18)
    $g_ah_ItemCombo[$a_i_Tab] = GUICtrlCreateCombo("", 124, 114, 190, 25, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))
    GUICtrlSetOnEvent(-1, "GuiButtonHandler")
    Tot_FillCombo($g_ah_ItemCombo[$a_i_Tab], $g_av_TotItems)

    GUICtrlCreateLabel("Amount per trade", 26, 146, 98, 18)
    $g_ah_AmountInput[$a_i_Tab] = GUICtrlCreateInput($g_av_TotItems[0][3], 124, 142, 80, 22, BitOR($ES_NUMBER, $ES_RIGHT))
    GUICtrlSetLimit(-1, 3)
    GUICtrlSetOnEvent(-1, "GuiButtonHandler")
    GUICtrlCreateLabel("(1 to 250)", 210, 146, 100, 18)

    $g_ah_PriceLabel[$a_i_Tab] = GUICtrlCreateLabel("Price per stack", 26, 174, 98, 18)
    $g_ah_PriceInput[$a_i_Tab] = GUICtrlCreateInput("1", 124, 170, 80, 22, BitOR($ES_NUMBER, $ES_RIGHT))
    GUICtrlSetLimit(-1, 6)
    GUICtrlSetOnEvent(-1, "GuiButtonHandler")
    $g_ah_CurrencyCombo[$a_i_Tab] = GUICtrlCreateCombo("", 210, 170, 104, 25, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))
    GUICtrlSetOnEvent(-1, "GuiButtonHandler")
    Tot_FillCombo($g_ah_CurrencyCombo[$a_i_Tab], $g_av_TotCurrencies)

    $g_ah_KeepRunning[$a_i_Tab] = GUICtrlCreateCheckbox($a_s_KeepText, 26, 198, 288, 18)

    $g_ah_Summary[$a_i_Tab] = GUICtrlCreateLabel("", 24, 222, 292, 18, $SS_CENTER)
    GUICtrlSetFont(-1, 9, $FW_BOLD)
EndFunc

Func GuiButtonHandler()
    Switch @GUI_CtrlId
        Case $GUIStartButton
            If Not $BotRunning Then
                If Not $Bot_Core_Initialized Then
                    InitializeBot()
                    GUICtrlSetState($GUINameCombo, $GUI_DISABLE)
                    GUICtrlSetState($GUIRefreshButton, $GUI_DISABLE)
                    $Bot_Core_Initialized = True
                EndIf

                Tot_ApplyChoices(True)
                Tot_UpdateTitle()
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

        Case $g_hTab
            Tot_ApplyChoices(False)

        Case $g_ah_ItemCombo[$TOT_MODE_SELL], $g_ah_ItemCombo[$TOT_MODE_BUY]
            ; A new item starts from its default amount in $g_av_TotItems.
            Local $l_i_Tab = $TOT_MODE_SELL
            If @GUI_CtrlId = $g_ah_ItemCombo[$TOT_MODE_BUY] Then $l_i_Tab = $TOT_MODE_BUY
            GUICtrlSetData($g_ah_AmountInput[$l_i_Tab], $g_av_TotItems[Tot_ComboIndex($g_ah_ItemCombo[$l_i_Tab], $g_av_TotItems)][3])
            Tot_ApplyChoices(False)

        Case $g_ah_AmountInput[$TOT_MODE_SELL], $g_ah_AmountInput[$TOT_MODE_BUY], _
                $g_ah_CurrencyCombo[$TOT_MODE_SELL], $g_ah_CurrencyCombo[$TOT_MODE_BUY], _
                $g_ah_PriceInput[$TOT_MODE_SELL], $g_ah_PriceInput[$TOT_MODE_BUY]
            Tot_ApplyChoices(False)

        Case $g_hSaveButton
            Tot_SaveConfig()

        Case $g_hLoadButton
            Tot_LoadConfig()

        Case $GUI_EVENT_CLOSE
            Exit
    EndSwitch
EndFunc

; Fills a dropdown with column 0 of $a_av_Rows and selects row $a_i_Pick.
Func Tot_FillCombo($a_h_Combo, ByRef $a_av_Rows, $a_i_Pick = 0)
    Local $l_s_List = ""
    For $l_i_Idx = 0 To UBound($a_av_Rows) - 1
        $l_s_List &= "|" & $a_av_Rows[$l_i_Idx][0]
    Next
    If $a_i_Pick < 0 Or $a_i_Pick >= UBound($a_av_Rows) Then $a_i_Pick = 0
    GUICtrlSetData($a_h_Combo, $l_s_List, $a_av_Rows[$a_i_Pick][0])
EndFunc

Func Tot_ComboIndex($a_h_Combo, ByRef $a_av_Rows)
    Local $l_s_Pick = GUICtrlRead($a_h_Combo)
    For $l_i_Idx = 0 To UBound($a_av_Rows) - 1
        If $a_av_Rows[$l_i_Idx][0] = $l_s_Pick Then Return $l_i_Idx
    Next
    Return 0
EndFunc

; Row whose dropdown name is $a_s_Name. Unknown or empty names fall back to row 0 with a warning.
Func Tot_RowIndex(ByRef $a_av_Rows, $a_s_Name, $a_s_What)
    If IsString($a_s_Name) And $a_s_Name <> "" Then
        For $l_i_Idx = 0 To UBound($a_av_Rows) - 1
            If $a_av_Rows[$l_i_Idx][0] = $a_s_Name Then Return $l_i_Idx
        Next
    EndIf
    LogWarn("Config " & $a_s_What & " '" & $a_s_Name & "' is not in the list. Using " & $a_av_Rows[0][0] & ".")
    Return 0
EndFunc

Func Tot_ActiveTab()
    If GUICtrlRead($g_hTab) = $TOT_MODE_BUY Then Return $TOT_MODE_BUY
    Return $TOT_MODE_SELL
EndFunc

; Reads both tabs and refreshes their labels. The active tab is read last, so the
; bot's item, amount, price, currency and mode are the active tab's.
Func Tot_ApplyChoices($a_b_Log = False)
    Local $l_i_Active = Tot_ActiveTab()
    Tot_ApplyTab(1 - $l_i_Active)
    Tot_ApplyTab($l_i_Active)
    If $a_b_Log Then LogInfo(Tot_ModeName() & " mode. " & Tot_Summary() & ".")
EndFunc

; Reads the item, amount, price and currency from one tab into the bot and refreshes that tab's labels.
Func Tot_ApplyTab($a_i_Tab)
    $g_i_TotMode = $a_i_Tab
    Local $l_i_Item = Tot_ComboIndex($g_ah_ItemCombo[$a_i_Tab], $g_av_TotItems)
    $g_s_TotItemName = $g_av_TotItems[$l_i_Item][0]
    $g_i_TotModel = $g_av_TotItems[$l_i_Item][1]
    $g_s_TotAdvertName = $g_av_TotItems[$l_i_Item][2]
    $g_i_TotLotSize = Tot_ValidLotSize(GUICtrlRead($g_ah_AmountInput[$a_i_Tab]))
    If String($g_i_TotLotSize) <> GUICtrlRead($g_ah_AmountInput[$a_i_Tab]) Then GUICtrlSetData($g_ah_AmountInput[$a_i_Tab], $g_i_TotLotSize)

    Local $l_i_Cur = Tot_ComboIndex($g_ah_CurrencyCombo[$a_i_Tab], $g_av_TotCurrencies)
    $g_s_TotCurName = $g_av_TotCurrencies[$l_i_Cur][0]
    $g_i_TotCurModel = $g_av_TotCurrencies[$l_i_Cur][1]
    $g_s_TotCurShort = $g_av_TotCurrencies[$l_i_Cur][2]

    Local $l_i_Price = Int(Number(GUICtrlRead($g_ah_PriceInput[$a_i_Tab])))
    If $l_i_Price < 1 Then $l_i_Price = 1
    If $l_i_Price > $TOT_MAX_PRICE Then $l_i_Price = $TOT_MAX_PRICE
    If String($l_i_Price) <> GUICtrlRead($g_ah_PriceInput[$a_i_Tab]) Then GUICtrlSetData($g_ah_PriceInput[$a_i_Tab], $l_i_Price)
    $g_i_TotPrice = $l_i_Price

    GUICtrlSetData($g_ah_PriceLabel[$a_i_Tab], "Price " & Tot_PerLot())
    GUICtrlSetData($g_ah_Summary[$a_i_Tab], Tot_Summary())
EndFunc

; Locks or unlocks both tabs while running. The keep running boxes stay live,
; as before, so they can be changed mid-run.
Func Tot_LockChoices($a_i_State)
    GUICtrlSetState($g_hTab, $a_i_State)
    For $l_i_Tab = $TOT_MODE_SELL To $TOT_MODE_BUY
        GUICtrlSetState($g_ah_ItemCombo[$l_i_Tab], $a_i_State)
        GUICtrlSetState($g_ah_AmountInput[$l_i_Tab], $a_i_State)
        GUICtrlSetState($g_ah_PriceInput[$l_i_Tab], $a_i_State)
        GUICtrlSetState($g_ah_CurrencyCombo[$l_i_Tab], $a_i_State)
    Next
    GUICtrlSetState($g_hLoadButton, $a_i_State)
EndFunc

; =======================
; Config (.ini)
; =======================

Func Tot_SaveConfig()
    Local $l_s_Dir = @WorkingDir
    Local $l_s_File = FileSaveDialog("Save config", @ScriptDir, "Config files (*.ini)", BitOR($FD_PATHMUSTEXIST, $FD_PROMPTOVERWRITE), "Misute.ini", $MainGui)
    Local $l_i_Err = @error
    FileChangeDir($l_s_Dir)
    If $l_i_Err Or $l_s_File = "" Then Return
    If StringRight($l_s_File, 4) <> ".ini" Then $l_s_File &= ".ini"
    If Not $BotRunning Then Tot_ApplyChoices(False) ; tidy the boxes before saving them

    If Not IniWrite($l_s_File, "General", "Character", GUICtrlRead($GUINameCombo)) Then
        LogError("Could not write " & $l_s_File & ".")
        Return
    EndIf
    IniWrite($l_s_File, "General", "Tab", Tot_ModeName(Tot_ActiveTab()))
    For $l_i_Tab = $TOT_MODE_SELL To $TOT_MODE_BUY
        Local $l_s_Section = Tot_ModeName($l_i_Tab)
        IniWrite($l_s_File, $l_s_Section, "Item", GUICtrlRead($g_ah_ItemCombo[$l_i_Tab]))
        IniWrite($l_s_File, $l_s_Section, "Amount", GUICtrlRead($g_ah_AmountInput[$l_i_Tab]))
        IniWrite($l_s_File, $l_s_Section, "Price", GUICtrlRead($g_ah_PriceInput[$l_i_Tab]))
        IniWrite($l_s_File, $l_s_Section, "Currency", GUICtrlRead($g_ah_CurrencyCombo[$l_i_Tab]))
        Local $l_i_Keep = 0
        If GUICtrlRead($g_ah_KeepRunning[$l_i_Tab]) = $GUI_CHECKED Then $l_i_Keep = 1
        IniWrite($l_s_File, $l_s_Section, "KeepRunning", $l_i_Keep)
    Next
    LogInfo("Config saved to " & $l_s_File & ".")
EndFunc

; With no file, asks for one. $a_b_Startup keeps a -character name from the command line.
Func Tot_LoadConfig($a_s_File = "", $a_b_Startup = False)
    If $BotRunning Then Return
    Local $l_s_File = $a_s_File
    If $l_s_File = "" Then
        Local $l_s_Dir = @WorkingDir
        $l_s_File = FileOpenDialog("Load config", @ScriptDir, "Config files (*.ini)", $FD_FILEMUSTEXIST, "Misute.ini", $MainGui)
        Local $l_i_Err = @error
        FileChangeDir($l_s_Dir)
        If $l_i_Err Or $l_s_File = "" Then Return
    EndIf
    If Not FileExists($l_s_File) Then
        LogWarn("Config " & $l_s_File & " not found.")
        Return
    EndIf

    Local $l_s_Char = IniRead($l_s_File, "General", "Character", "")
    If $l_s_Char <> "" And Not $Bot_Core_Initialized And Not ($a_b_Startup And $g_s_MainCharName <> "") Then
        If $doLoadLoggedChars Then
            _GUICtrlComboBox_SetEditText(GUICtrlGetHandle($GUINameCombo), $l_s_Char)
        Else
            GUICtrlSetData($GUINameCombo, $l_s_Char)
        EndIf
    EndIf

    For $l_i_Tab = $TOT_MODE_SELL To $TOT_MODE_BUY
        Local $l_s_Section = Tot_ModeName($l_i_Tab)
        Local $l_i_Item = Tot_RowIndex($g_av_TotItems, IniRead($l_s_File, $l_s_Section, "Item", ""), $l_s_Section & " item")
        Tot_FillCombo($g_ah_ItemCombo[$l_i_Tab], $g_av_TotItems, $l_i_Item)
        GUICtrlSetData($g_ah_AmountInput[$l_i_Tab], IniRead($l_s_File, $l_s_Section, "Amount", $g_av_TotItems[$l_i_Item][3]))
        GUICtrlSetData($g_ah_PriceInput[$l_i_Tab], IniRead($l_s_File, $l_s_Section, "Price", "1"))
        Local $l_i_Cur = Tot_RowIndex($g_av_TotCurrencies, IniRead($l_s_File, $l_s_Section, "Currency", ""), $l_s_Section & " currency")
        Tot_FillCombo($g_ah_CurrencyCombo[$l_i_Tab], $g_av_TotCurrencies, $l_i_Cur)
        If IniRead($l_s_File, $l_s_Section, "KeepRunning", "0") = "1" Then
            GUICtrlSetState($g_ah_KeepRunning[$l_i_Tab], $GUI_CHECKED)
        Else
            GUICtrlSetState($g_ah_KeepRunning[$l_i_Tab], $GUI_UNCHECKED)
        EndIf
    Next

    If IniRead($l_s_File, "General", "Tab", "Sell") = Tot_ModeName($TOT_MODE_BUY) Then
        GUICtrlSetState($g_ah_TabItem[$TOT_MODE_BUY], $GUI_SHOW)
    Else
        GUICtrlSetState($g_ah_TabItem[$TOT_MODE_SELL], $GUI_SHOW)
    EndIf
    Tot_ApplyChoices(False)
    LogInfo("Config loaded from " & $l_s_File & ". " & Tot_ModeName() & " tab: " & Tot_Summary() & ".")
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
