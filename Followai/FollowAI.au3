#RequireAdmin
#include "../../API/_GwAu3.au3"
#include "GwAu3_AddOns.au3"
#include "GwAu3_ChatLog.au3"
#include "FollowBehind.au3"

#cs
+---------------------------------------------------------------+
| Module: Follower Bot - Coaxx                                  |
| Description: Follows and accepts commands from the party      |
|              leader via the 'Team' channel (ChatLog module).  |
| Commands: Follow | Wait | Resign                              |
| Notes: Multiple instances supported; addable custom commands  |
+---------------------------------------------------------------+
#ce

Global Const $doLoadLoggedChars = True
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Opt("ExpandVarStrings", 1)

#Region Declarations
Global $ProcessID = ""
Global $timer = TimerInit()

Global $g_b_DebugMode = False
Global $BotRunning = False
Global $Bot_Core_Initialized = False
Global Const $BotTitle = "Follow.AI"
Global $Action = ""

;~ Follower bot variables
Global $p1x, $p1y, $p2x, $p2y, $rotation

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

#include "GUI.au3"

LogInfo("Why have shared memory when we can just talk about it?")

Core_AutoStart()

While 1
    If Not $Bot_Core_Initialized Then
        ContinueLoop
    Else
        CallBack_SetEvent("OnChatMessage")
        ExitLoop
    EndIf
    Sleep(100)
WEnd

While Not $BotRunning
    Sleep(100)
WEnd

While $BotRunning
    Select
        Case $Action = 1 ; Follow command
            GetPartyLeaderAndFollowerData()
            Cache_SkillBar()
            FollowLeaderSmoothPredict($p1x, $p1y, $rotation, $p2x, $p2y, 80)
        Case $Action = 2 ; Wait command
            If $g_Init = True Then $g_Init = False
            Sleep(100)
        Case $Action = 3 ; Resign command
            If Map_GetInstanceInfo("Type") = $GC_I_MAP_TYPE_EXPLORABLE Then
                Chat_SendChat("resign", "/")
                LogInfo("Follower has resigned.")
            Else
                LogError("Cannot resign as not in explorable...")
            EndIf
            $Action = 2
            Sleep(250)
    EndSelect
    Sleep(500)
WEnd

Func OnChatMessage($channel, $sender, $message, $guildtag)
    If $channel = "Team" Then
        If StringInStr($message, "Follow") Then
            $Action = 1
            LogInfo("Executing command from " & $sender)
            LogInfo("Following the party leader...")
        EndIf
        If StringInStr($message, "Wait") Then
            $Action = 2
            LogInfo("Executing command from " & $sender)
            LogInfo("Stopping movement...waiting for further instructions.")
        EndIf
        If StringInStr($message, "Resign") Then
            LogInfo("Executing command from " & $sender)
            LogInfo("Resigning...")
            $Action = 3
        EndIf
    EndIf
EndFunc

Func GetPartyLeaderAndFollowerData()
    Local $leader = GetMemberAgentID(1)
    If $leader = 0 Then Return

    ; Leader
    $p1x = Agent_GetAgentInfo($leader, "X")
    $p1y = Agent_GetAgentInfo($leader, "Y")
    $rotation = Agent_GetAgentInfo($leader, "Rotation")

    ; Follower
    $p2x = Agent_GetAgentInfo(-2, "X")
    $p2y = Agent_GetAgentInfo(-2, "Y")
EndFunc