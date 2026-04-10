#RequireAdmin
#include "../../API/_GwAu3.au3"
#include "../../API/Plugins/UtilityAI/_UtilityAI.au3"
#include "GwAu3_AddOns.au3"
#include "FollowBehind.au3"
#include "ChatListener.au3"

#cs
+---------------------------------------------------------------+
| Module: Follower Bot - Coaxx                                  |
| Description: Follows and accepts commands from the party      |
|              leader via the 'Team' channel (ChatLog module).  |
| Commands: Follow | Wait | Blessing (WIP) | Dialog (WIP)       |
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

Global $BotRunning = False
Global $Bot_Core_Initialized = False
Global Const $BotTitle = ""
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

LogInfo("Based on GWA2")
LogInfo("GWA2 - Created by: " & $GC_S_GWA2_CREATOR)
LogInfo("GWA2 - Build date: " & $GC_S_GWA2_BUILD_DATE & @CRLF)

LogInfo("GwAu3 - Created by: " & $GC_S_UPDATOR)
LogInfo("GwAu3 - Build date: " & $GC_S_BUILD_DATE)
LogInfo("GwAu3 - Version: " & $GC_S_VERSION)
LogInfo("GwAu3 - Last Update: " & $GC_S_LAST_UPDATE & @CRLF)

Core_AutoStart()

While 1
    If Not $Bot_Core_Initialized Then
        ContinueLoop
    Else
        ExitLoop
    EndIf
    Sleep(100)
WEnd

While Not $BotRunning
    Sleep(100)
WEnd

While $BotRunning
    Local $l_s_Latest = ChatListener_GetLatestMessage()
    If $l_s_Latest <> "" Then
        ProcessChatCommand($l_s_Latest)
    EndIf

    Select
        Case $Action = 1 ; Follow command
            GetPartyLeaderAndFollowerData()
            Cache_SkillBar()
            FollowLeaderSmoothPredict($p1x, $p1y, $rotation, $p2x, $p2y, 80)
        Case $Action = 2 ; Wait command
            If $g_Init = True Then $g_Init = False
            Sleep(100)
        Case $Action = 3 ; Get Blessing command
            LogInfo("Taking the blessing...")
            LogInfo("--NOT IMPLEMENTED YET--")
        Case $Action = 4 ; Dialog command
            LogInfo("Running Dialog...")
            LogInfo("--NOT IMPLEMENTED YET--")
    EndSelect
    Sleep(500)
WEnd

Func ProcessChatCommand($message)
    If StringInStr($message, "Follow") Then
        $Action = 1
        LogInfo("Executing command: Follow")
        LogInfo("Following the party leader...")
        Return
    EndIf
    If StringInStr($message, "Wait") Then
        $Action = 2
        LogInfo("Executing command: Wait")
        LogInfo("Stopping movement...waiting for further instructions.")
        Return
    EndIf
    If StringInStr($message, "Bless") Then
        $Action = 3
        LogInfo("Executing command: Bless")
        Return
    EndIf
    If StringInStr($message, "Dialog") Then
        $Action = 4
        LogInfo("Executing command: Dialog")
        Return
    EndIf
EndFunc

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
        If StringInStr($message, "Bless") Then
            $Action = 3
            LogInfo("Executing command from " & $sender)
        EndIf
        If StringInStr($message, "Dialog") Then
            $Action = 4
            LogInfo("Executing command from " & $sender)
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
