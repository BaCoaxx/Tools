#RequireAdmin
#include "../../API/_GwAu3.au3"

Global Const $doLoadLoggedChars = True
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Opt("ExpandVarStrings", 1)

#Region Declarations
Global $ProcessID = ""
Global $timer = TimerInit()

Global $BotRunning = False
Global $Bot_Core_Initialized = False
Global Const $BotTitle = ""

$g_bAutoStart = False  ; Flag for auto-start
$g_s_MainCharName  = ""

#EndRegion Declaration

; Process command line arguments
For $i = 1 To $CmdLine[0]
    If $CmdLine[$i] = "-character" And $i < $CmdLine[0] Then
        $g_s_MainCharName = $CmdLine[$i + 1]
        $g_bAutoStart = True
        ExitLoop
    EndIf
Next

#Region ### START Koda GUI section ### Form=
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
#EndRegion ### END Koda GUI section ###


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

Out("Based on GWA2")
Out("GWA2 - Created by: " & $GC_S_GWA2_CREATOR)
Out("GWA2 - Build date: " & $GC_S_GWA2_BUILD_DATE & @CRLF)

Out("GwAu3 - Created by: " & $GC_S_UPDATOR)
Out("GwAu3 - Build date: " & $GC_S_BUILD_DATE)
Out("GwAu3 - Version: " & $GC_S_VERSION)
Out("GwAu3 - Last Update: " & $GC_S_LAST_UPDATE & @CRLF)
Core_AutoStart()

While Not $BotRunning
    Sleep(100)
WEnd

While $BotRunning
    Out("Debug")
    Sleep(1000)
WEnd



; We use a skill on target if we are not dead
; Default target is self (-2)
Func UseSkill($aSkillSlot, $aTarget = -2)
    If GetIsDead() Then Return
    If Not IsRecharged($aSkillSlot) Then Return
    If GetEnergy() >= GetSkillCost($aSkillSlot) Then
        Skill_UseSkill($aSkillSlot, $aTarget)
        Do
            Sleep(32)
        Until Not IsCasting($aSkillSlot)
    Else
        Return
    EndIf
EndFunc

; We get targets current energy
; Default target is self (-2)
Func GetEnergy($aTarget = -2)
    Return Agent_GetAgentInfo($aTarget, "CurrentEnergy")
EndFunc

; We get the energy cost of a skill
Func GetSkillCost($aSkillSlot)
    Return Skill_GetSkillInfo(Skill_GetSkillBarInfo($aSkillSlot, "SkillID"), "EnergyCost")
EndFunc

; We check to see if a target is dead
; Default target is self (-2)
Func GetIsDead($aTarget = -2)
    If Agent_GetAgentInfo($aTarget, "IsDead") Then
        Return True
    Else
        Return False
    EndIf
EndFunc

; We check to see if we are currently casting a skill
; We check 3 different sources to be sure
Func IsCasting($aSkillSlot)
    If Not Agent_GetAgentInfo(-2, "IsCasting") And Not Agent_GetAgentInfo(-2, "Skill") And Not Skill_GetSkillbarInfo($aSkillSlot, "Casting") Then
        Return False
    Else 
        Return True
    EndIf
EndFunc

; We check to see if a skill is recharged
Func IsRecharged($aSkillSlot)
    If Skill_GetSkillbarInfo($aSkillSlot, "IsRecharged") Then
        Return True
    Else
        Return False
    EndIf
EndFunc

; We count the number of empty slots in all bags - @BubbleTea
Func CountSlots()
    Local $bag
    Local $temp = 0
    For $i = 1 To 4
        $bag = Item_GetBagPtr($i)
        $temp += Item_GetBagInfo($bag, "EmptySlots")
    Next
    Return $temp
EndFunc

; We pick up loot if we are not dead - @BubbleTea
Func PickUpLoot()
    Local $lAgentArray = Item_GetItemArray()
    Local $maxItems = $lAgentArray[0]

    If GetIsDead() Then Return
    For $i = 1 To $maxItems
        If GetIsDead() Then ExitLoop
        Local $aItemPtr = $lAgentArray[$i]
        Local $aItemAgentID = Item_GetItemInfoByPtr($aItemPtr, "AgentID")

        If GetIsDead() Then ExitLoop
        If $aItemAgentID = 0 Then ContinueLoop

        If CanPickUp($aItemPtr) Then
            Item_PickUpItem($aItemAgentID)
            Local $lDeadlock = TimerInit()
            While GetItemAgentExists($aItemAgentID)
                Sleep(100)
                If GetIsDead() Then ExitLoop
                If TimerDiff($lDeadlock) > 10000 Then ExitLoop
            WEnd
        EndIf
    Next
EndFunc

; We check to see if an item agent still exists - @BubbleTea
Func GetItemAgentExists($aItemAgentID)
    Return (Agent_GetAgentPtr($aItemAgentID) > 0 And $aItemAgentID < Item_GetMaxItems())
EndFunc

; We check to see if we want to pick up an item
Func CanPickUp($aItemPtr)
	Local $lModelID = Item_GetItemInfoByPtr($aItemPtr, "ModelID")
	Local $aExtraID = Item_GetItemInfoByPtr($aItemPtr, "ExtraID")
	Local $lRarity = Item_GetItemInfoByPtr($aItemPtr, "Rarity")
	If (($lModelID == 2511) And (GetGoldCharacter() < 99000)) Then
		Return True
	ElseIf ($lModelID == $GC_I_MODELID_DYE) Then
		If (($aExtraID == $GC_I_EXTRAID_DYE_BLACK) Or ($aExtraID == $GC_I_EXTRAID_DYE_WHITE)) Then
			Return True
		EndIf
	ElseIf $lRarity == $GC_I_MODELID_RARITY_GOLD Then
		Return False
	ElseIf $lRarity == $GC_I_MODELID_RARITY_PURPLE Then
		Return False
	ElseIf $lModelID == $GC_I_MODELID_KEY_LOCKPICK Then
		Return True
	ElseIf (($lModelID == $GC_I_MODELID_PCONS_WAR_SUPPLIES) Or ($lModelID == $GC_I_MODELID_STACKABLE_TROPHIES_WHITE_MANTLE_EMBLEM) Or ($lModelID == $GC_I_MODELID_STACKABLE_TROPHIES_WHITE_MANTLE_BADGE)) Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func Out($TEXT)
    Local $TEXTLEN = StringLen($TEXT)
    Local $CONSOLELEN = _GUICtrlEdit_GetTextLen($g_h_EditText)
    If $TEXTLEN + $CONSOLELEN > 30000 Then GUICtrlSetData($g_h_EditText, StringRight(_GUICtrlEdit_GetText($g_h_EditText), 30000 - $TEXTLEN - 1000))
	_GUICtrlRichEdit_SetCharColor($g_h_EditText, $COLOR_BLACK)
    _GUICtrlEdit_AppendText($g_h_EditText, @CRLF & $TEXT)
    _GUICtrlEdit_Scroll($g_h_EditText, 1)
EndFunc

Func _Exit()
    Exit
EndFunc