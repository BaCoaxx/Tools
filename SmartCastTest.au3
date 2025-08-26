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

Global $runningEnchants[3] = [1, 2, 3]  ; Array with 3 elements

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
    ;Sleep(500)
    ;Out("Ready")
    Sleep(250)
    MoveRunning(-6031, 400, $runningEnchants, 100)
    MoveRunning(-7675, 3473, $runningEnchants, 100)
    MoveRunning(-8506, 4314, $runningEnchants, 100)  ; Move to coords with upkeep skills and a range of 100
    Sleep(1000)
WEnd

Func SmartCast($aSkillSlot, $aTarget = -2, $waitForRecharge = False)
    Local $aSkill = Skill_GetSkillBarInfo($aSkillSlot, "SkillID")

    ; Check for the smell of death to avoid casting skills from beyond the grave, return if dead
    If Agent_GetAgentInfo(-2, "IsDead") Then Return False
    
    ; If waitForRecharge is True, we wait until the skill is recharged
    If $waitForRecharge Then
        While Not Skill_GetSkillbarInfo($aSkillSlot, "IsRecharged")
            Sleep(32)
        WEnd

        ; Wait for enough energy too
        While Agent_GetAgentInfo(-2, "CurrentEnergy") < Skill_GetSkillInfo($aSkill, "EnergyCost")
            Sleep(32)
        WEnd
    EndIf

    ; Check if the skill is recharged and then make sure we have enough energy needed to cast
    If Skill_GetSkillbarInfo($aSkillSlot, "IsRecharged") Then
        If Agent_GetAgentInfo(-2, "CurrentEnergy") >= Skill_GetSkillInfo($aSkill, "EnergyCost") Then
            Skill_UseSkill($aSkillSlot, $aTarget)
            
            ; We wait until we are done casting before we return
            ; This is to avoid issues with trying to cast another skill while we are still casting
            Do
                Sleep(32)
            Until Not IsCasting($aSkillSlot)
        Else
            Return False ; Skill was recharged but we dont have enough energy to cast, so we return
        EndIf
    Else
        Return False ; The skill was not recharged, so we return
    EndIf
    Return True
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

Func MoveRunning($x, $y, $aUpkeepSkills, $Range = 100)
    While ComputeDistance(Agent_GetAgentInfo(-2, "X"), Agent_GetAgentInfo(-2, "Y"), $x, $y) > $Range
        ; If the skills in the skillslots are not active, or they are about to expire then we recast them
        For $i = 0 To UBound($aUpkeepSkills) - 1
            Local $aSkill = Skill_GetSkillBarInfo($aUpkeepSkills[$i], "SkillID")
            Local $hasEffect = Agent_GetAgentEffectInfo(-2, $aSkill, "HasEffect")
            Local $skillDuration = Agent_GetAgentEffectInfo(-2, $aSkill, "Duration")
            Local $timeRemaining = Agent_GetAgentEffectInfo(-2, $aSkill, "TimeRemaining")

            Out("Skill Slot: " & $aUpkeepSkills[$i] & " SkillID: " & $aSkill & " HasEffect: " & $hasEffect & " TimeRemaining: " & $timeRemaining)

            If (Not $hasEffect) Or ($timeRemaining >= 0 And $timeRemaining <= ($skillDuration / 4)) Then
                SmartCast($aUpkeepSkills[$i], -2, True)
            EndIf            
        Next
        Map_Move($x, $y)
    WEnd
EndFunc

Func ComputeDistance($aX1, $aY1, $aX2, $aY2)
	Return Sqrt(($aX1 - $aX2) ^ 2 + ($aY1 - $aY2) ^ 2)
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