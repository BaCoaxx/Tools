#cs
;;; Mount Qinkai Vanquisher - Luxon Points Farmer
; You run in Hard Mode
; Possible valuable drops: Gold q9 Luxon drops

; Author: Bubbletea

#ce

#RequireAdmin
#include "../../API/_GwAu3.au3"
#include "GwAu3_AddOns.au3"

Global Const $doLoadLoggedChars = True
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Opt("ExpandVarStrings", 1)

; === PERFORMANCE CONFIGURATION ===
Global Const $MOVEMENT_RANGE = 150
Global Const $DEATH_CHECK_INTERVAL = 250
Global Const $SPIRIT_CAST_DELAY = 1500
Global Const $DEADLOCK_TIMEOUT = 600000 ; 10 minutes

; Performance macro
#define CHECK_PARTY_DEAD() If GetPartyDead() Then Return

#Region Declarations
Global $charName  = ""
Global $ProcessID = ""
Global $timer = TimerInit()

Global $BotRunning = False
Global $Bot_Core_Initialized = False
Global $g_bAutoStart = False  ; Flag for auto-start
#EndRegion Declaration

; Process command line arguments
For $i = 1 To $CmdLine[0]
    If $CmdLine[$i] = "-character" And $i < $CmdLine[0] Then
        $charName = $CmdLine[$i + 1]
        $g_bAutoStart = True
        ExitLoop
    EndIf
Next

; ------------- GUI --------------
#include "Gui.au3"

While Not $BotRunning
    Sleep(100)
WEnd

While True
    If $BotRunning = True Then
        MainFarm()
    Else
        Sleep(1000)
    EndIf
WEnd


; --------- Start of Bot --------------
Func MainFarm()

    If GetLuxonFaction() >= (GetMaxLuxonFaction() - 15000) Then DonateDemPoints()

    While (CountSlots() > 4)
        If Not $BotRunning Then
            Out("Bot Paused")
            GUICtrlSetState($Button, $GUI_ENABLE)
            GUICtrlSetData($Button, "Resume")
            GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
            Return
        EndIf

        If $Deadlocked Then
            $Deadlocked = False
            Inventory()
            Return
        EndIf
		sleep(2000)
        CombatLoop()
        If GetLuxonFaction() >= (GetMaxLuxonFaction() - 15000) Then DonateDemPoints()
    WEnd

    If (CountSlots() < 5) Then
        If Not $BotRunning Then
            Out("Bot Paused")
            GUICtrlSetState($Button, $GUI_ENABLE)
            GUICtrlSetData($Button, "Resume")
			GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
            Return
        EndIf

        Inventory()
        If GetLuxonFaction() >= (GetMaxLuxonFaction() - 15000) Then DonateDemPoints()
    EndIf
EndFunc

Func MapP()

	; Load builds, if it is the first run
	If GUICtrlRead($Builds) = $GUI_CHECKED and $RunCount = 0 Then
		; When Option is chosen and we are at the first Run, then we load the Hero_Builds
        ; Therefore we will go to a 8man Area, so all 7 Herobuilds will be loaded
        Out("Travelling to Great Temple of Balthazar")
        RndTravel($Town_ID_Great_Temple_of_Balthazar)
        Sleep(3000)

		;~ Loading Skilltemplates
		Party_KickAllHeroes()
		Sleep(250)
		Out("Load my Skills")
		Attribute_LoadSkillTemplate($SkillBarTemplate)
		Sleep(250)
		Out("Player skillbar loaded")
		Out("Add Heroes")

		Party_AddHero($HERO_ID_Gwen)
		Sleep(250)
		Out("Load Gwen's Skillbar")
		Attribute_LoadSkillTemplate("OQlkAkC8QZizJIHM9wpmuMQNeHD", 1)
		Sleep(250)
        Party_SetHeroAggression(1, 0) ; 0 = Aggressive
		Sleep(500)
		Out("Gwen ready!")

		Party_AddHero($HERO_ID_Sousuke)
		Sleep(250)
		Out("Load Sousuke's Skillbar")
		Attribute_LoadSkillTemplate("OgVCIMzzJY6lDuAyAc6QgWA", 2)
		Sleep(250)
        Party_SetHeroAggression(2, 0) ; 0 = Aggressive
		Sleep(500)
		Out("Sousuke ready!")

        Party_AddHero($HERO_ID_Livia)
		Sleep(250)
		Out("Load Livia's Skillbar")
		Attribute_LoadSkillTemplate("OAhjUwGaISyBTB4BbhVVKgRTDTA", 3)
		Sleep(250)
        Party_SetHeroAggression(3, 1) ; 1 = Guard
		Sleep(500)
		Out("Livia ready!")

        Party_AddHero($HERO_ID_Vekk)
		Sleep(250)
		Out("Load Vekk's Skillbar")
		Attribute_LoadSkillTemplate("OgdUgW1yw/MHRaBuosOLQH5QcHA", 4)
		Sleep(250)
        Party_SetHeroAggression(4, 0) ; 0 = Aggressive
		Sleep(500)
		Out("Vekk ready!")

		Party_AddHero($HERO_ID_Xandra)
		Sleep(250)
		Out("Load Xandra's Skillbar")
		Attribute_LoadSkillTemplate("OACjAyhDJPYTrX48xBNdmI3LGA", 5)
		Sleep(250)
        Party_SetHeroAggression(5, 1) ; 1 = Guard
		Sleep(500)
		Out("Xandra ready!")

		Party_AddHero($HERO_ID_Master)
		Sleep(250)
		Out("Load Master of Whisper's Skillbar")
		Attribute_LoadSkillTemplate("OAhjQoGYIP3hqazeYK8kmTuxJA", 6)
		Sleep(250)
        Party_SetHeroAggression(6, 1) ; 1 = Guard
		Sleep(500)
		Out("Master of Whisper ready!")

		Party_AddHero($HERO_ID_Ogden)
		Sleep(250)
		Out("Load Ogden's Skillbar")
		Attribute_LoadSkillTemplate("Owkk0wPHEaiEDxdV9Ad1GRDYN2OG", 7)
		Sleep(250)
        Party_SetHeroAggression(7, 1) ; 1 = Guard
		Sleep(500)
		Out("Ogden ready!")
	EndIf

    ; Cache, what heroes have a rez skill
    If $RunCount = 0 then CacheHeroesWithRez()

    ;~ Checks if you are already in Aspenwood Gate (Luxon) -> if not travel there
	If Map_GetMapID() <> $Town_ID_AspenwoodgateLuxon Then
		Out("Travelling to Aspenwood Gate (Luxon)")
		RndTravel($Town_ID_AspenwoodgateLuxon)
		Sleep(1000)
	EndIf
	
	;~ HardMode
	If GUICtrlRead($HardmodeCheckbox) = $GUI_CHECKED Then
        Game_SwitchMode($DIFFICULTY_HARD)
    Else
        Game_SwitchMode($DIFFICULTY_NORMAL)
    EndIf
	
EndFunc

Func FastWayOut()
	Out("You have chosen the gate trick option.")
    Out("What a wise fella you are!")
    Out("Now take you legs and run to the gate!!!")

	MoveTo(-5096.79, 12933.94)
	Map_Move(-5700, 13900)
	Map_WaitMapLoading($MAP_ID_MountQinkai, 1)
	Sleep(2000)

    MoveTo(-8710.48, -10694.13)
	Map_Move(-8200, -11250)
	Map_WaitMapLoading($Town_ID_AspenwoodgateLuxon, 0)
	Sleep(2000)
	Return True
EndFunc ;==>FastWayOut

; Here, the Magic happens
Func CombatLoop()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $RunCount = 0 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	EndIf

    If GetGoldCharacter() < 500 Then
        If GetGoldStorage() < 1000 Then
            Out("What a poor bastard you are!!!")
            Out("Get money elsewhere!!!")
            Out("I will automatically close in 5")
            Sleep(1000)
            Out("4")
            Sleep(1000)
            Out("3")
            Sleep(1000)
            Out("2")
            Sleep(1000)
            Out("1")
            Sleep(1000)
            Exit
        Else
            Item_WithdrawGold(1000)
		    Sleep(1000)
        EndIf
    EndIf

	Out("Exiting Outpost")
	MoveTo(-5096.79, 12933.94)
	Map_Move(-5700, 13900)
	Map_WaitMapLoading($MAP_ID_MountQinkai, 1)

	Sleep(1000)
	$RunTimer = TimerInit()

	FarmMountQinkai()
	
	If GetIsDead(-2) = True then
		$FailCount += 1
	Else
		$SuccessCount += 1
        $RunTime = TimerDiff($RunTimer)

        $RunTimeCalc = Round($RunTime / 1000)
        Redim $AvgTime[UBound($AvgTime)+1]
        $AvgTime[UBound($AvgTime)-1] = $RunTimeCalc

        CalculateFastestTime()
        CalculateAverageTime()
	EndIf
	$RunCount += 1

	UpdateStatistics()

	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED Then
		Resign()
		Sleep(5000)
		Map_ReturnToOutpost()
		Sleep(2000)
		Map_WaitMapLoading($Town_ID_AspenwoodgateLuxon, 0)
		Sleep(500)
	Else
		RndTravel($Town_ID_AspenwoodgateLuxon)
	EndIf
	Memory_Clear()
EndFunc


Func FarmMountQinkai()

    CHECK_PARTY_DEAD()
    GetBlessing()
    $RezShrine = 1
    
    Out("Now let's Farm some Luxon Points")
    If GetPartyDefeated() then Return
    Do
        If GetPartyDefeated() then ExitLoop
        UseRunEnhancers() ; Consets and stuff like that
        FarmToSecondShrine()
    Until $RezShrine = 2 or GetPartyDefeated()

    If GetPartyDefeated() then Return
    Do
        If GetPartyDefeated() then ExitLoop
        UseRunEnhancers() ; Consets and stuff like that
        FarmToThirdShrine()
    Until $RezShrine = 3 or GetPartyDefeated()

    If GetPartyDefeated() then Return
    Do
        If GetPartyDefeated() then ExitLoop
        UseRunEnhancers() ; Consets and stuff like that
        FarmToFourthShrine()
    Until $RezShrine = 4 or GetPartyDefeated()
    
    If GetPartyDefeated() then Return
    Do
        If GetPartyDefeated() then ExitLoop
        UseRunEnhancers() ; Consets and stuff like that
        FarmToEnd()
    Until $RezShrine = 0 or GetPartyDefeated()

EndFunc ;==> FarmMountQinkai


Func GetBlessing()
    If GetisDead(-2) Then Return
    Out("Get the Blessing!")
    MoveTo(-8394.10, -9863.09)
    Local $NPC = GetNearestNPCToAgent(-2, 1320, $GC_I_AGENT_TYPE_LIVING, 1, "NPCFilter")
	MoveTo(Agent_GetAgentInfo($NPC, "X")-20,Agent_GetAgentInfo($NPC, "Y")-20)
    Agent_GoNPC($NPC)
    Sleep(500)
    If GetKurzickFaction() > GetLuxonFaction() Then
        Out("Bribe the Golddigger!")
        Ui_Dialog(0x81)
        sleep(1000)
        Ui_Dialog(0x2)
        sleep(1000)
        Ui_Dialog(0x84)
        sleep(1000)
        Ui_Dialog(0x86)
        sleep(1000)
    Else
        Out("He is on our side!")
        Ui_Dialog(0x85)
        sleep(1000)
        Ui_Dialog(0x86)
        sleep(1000)
    EndIf
EndFunc ;==> GetBlessing

Func DonateDemPoints()
    Local $StartTime = TimerInit()
    
    Out("Travel to Cavalon - Donating Points")
    RndTravel($Town_ID_Cavalon)
    Sleep(2000)
    $inventorytrigger = 1

    Out("Go to Luxon Scavenger")
    NavigateToLuxonScavenger()
    
    Local $isDonating = (GUICtrlRead($DonateBox) = $GUI_CHECKED)
    Out($isDonating ? "Donate the Points" : "Buy Jadeite Shards")

    While GetLuxonFaction() >= 5000
        If TimerDiff($StartTime) > $DEADLOCK_TIMEOUT Then
            Out("Deadlock detected in DonateDemPoints - Exiting to restart...")
            Return
        EndIf

        ProcessLuxonFaction($isDonating)
    WEnd

    UpdateLuxonStats()
EndFunc   ;==> DonateDemPoints

Func NavigateToLuxonScavenger()
    If CheckAreaRange(5439.88, 1441.83, 500) Then
        MoveTo(5378.04, 1093.01)
        MoveTo(7561.78, -1139.63)
    EndIf
    MoveTo(9050.54, -1120.91, 0)
    
    Local $NPC = GetNearestNPCToAgent(-2, 1320, $GC_I_AGENT_TYPE_LIVING, 1, "NPCFilter")
    Agent_GoNPC($NPC)
    Sleep(1000)
EndFunc

Func ProcessLuxonFaction($isDonating)
    If $isDonating Then
        Ui_Dialog(0x87)
        Sleep(1000)
        Game_DonateFaction("luxon")
        Sleep(1000)
    Else
        Ui_Dialog(0x84)
        Sleep(1000)
        Ui_Dialog(0x800101)
        Sleep(1000)
    EndIf
EndFunc

Func UpdateLuxonStats()
    $LuxonPointsGained = GetLuxonTitlePoints() - $LuxonPointsStart
    $LuxonTitle = GetLuxonTitle()
    UpdateStatistics()
EndFunc

Func UseRunEnhancers()
    If GUICtrlRead($PconsBox) = $GUI_CHECKED Then
        Out("Eat some juicy Snacks.")
        If GetPartyDefeated() Then Return
        If FindConset() = True Then UseConset()
        If FindSummoningStone() = True Then UseSummoningStone()
    EndIf
EndFunc ;==> UseRunEnhancers

; Optimized waypoint execution function
Func ExecuteWaypoints($waypoints, $description = "")
    If $description <> "" Then Out($description)
    
    For $i = 0 To UBound($waypoints) - 1
        CHECK_PARTY_DEAD()
        AggroMoveToEx($waypoints[$i][0], $waypoints[$i][1], $MOVEMENT_RANGE)
    Next
EndFunc

; Optimized spirit precasting
Func PrecastSpirits()
    If GetPartyDead() Or GUICtrlRead($Builds) <> $GUI_CHECKED Then Return
    
    Local $spirits[8][3] = [ _
        [$sos, -2, 0], _
        [2, 5, -2], _
        [$pain, -2, 0], _
        [3, 5, -2], _
        [$bs, -2, 0], _
        [4, 5, -2], _
        [$vamp, -2, 0], _
        [3, 7, Party_GetMyPartyHeroInfo(4, "AgentID")] _
    ]
    
    Out("Precast Defensive Spirits if possible")
    For $i = 0 To 7
        CHECK_PARTY_DEAD()
        
        If $spirits[$i][2] = 0 Then ; Player skill
            If IsRecharged($spirits[$i][0]) Then
                UseSkillEx($spirits[$i][0], $spirits[$i][1])
                Sleep($SPIRIT_CAST_DELAY)
            EndIf
        ElseIf $spirits[$i][2] = -2 Then ; Hero skill on player
            If Skill_GetSkillbarInfo($spirits[$i][0], "IsRecharged", $spirits[$i][1]) Then
                Skill_UseHeroSkill($spirits[$i][1], $spirits[$i][0], $spirits[$i][2])
                Sleep($SPIRIT_CAST_DELAY)
            EndIf
        Else ; Hero skill on specific target
            If Skill_GetSkillbarInfo($spirits[$i][0], "IsRecharged", $spirits[$i][1]) Then
                Skill_UseHeroSkill($spirits[$i][1], $spirits[$i][0], $spirits[$i][2])
                Sleep($SPIRIT_CAST_DELAY)
            EndIf
        EndIf
    Next
EndFunc

; Death handling function
Func HandleDeath($shrineNumber)
    If GetPartyDead() Then
        If GetPartyDefeated() Then Return
        
        Local $messages[5] = [ _
            "Damn son, you are a disappointment", _
            "Seriously? Disgraceful!!!", _
            "This is somewhat embarrassing!", _
            "Boy oh boy ...", _
            "" _
        ]
        
        Local $ordinals[5] = ["first", "second", "third", "fourth", "fifth"]
        
        Out($messages[$shrineNumber - 1])
        Out("Restart from the " & $ordinals[$shrineNumber - 1] & " Shrine")
        
        Do
            Sleep($DEATH_CHECK_INTERVAL)
        Until GetPartyDead() = False
    Else
        $RezShrine = $shrineNumber
    EndIf
EndFunc

Func FarmToSecondShrine()
    Local $yetiWaypoints[3][2] = [ _
        [-11345.94, -9236.53], _
        [-13374.57, -8792.12], _
        [-15136.31, -8014.83] _
    ]
    
    Local $rangerBossWaypoints[1][2] = [[-17681.92, -10434.07]]
    
    Local $rotWallowWaypoints[3][2] = [ _
        [-15480.86, -8330.52], _
        [-13927.14, -5273.81], _
        [-11642.35, -3830.33] _
    ]
    
    Local $ritualistWaypoints[2][2] = [ _
        [-12145.45, -3141.13], _
        [-14437.85, -2362.25] _
    ]
    
    Local $oniSpawnWaypoints[2][2] = [ _
        [-11999.42, -4100.08], _
        [-11014.63, -6204.00] _
    ]
    
    Local $midRotWallowWaypoints[5][2] = [ _
        [-8446.23, -5402.07], _
        [-6917.16, -4646.15], _
        [-5230.77, -4663.20], _
        [-7164.92, -7365.83], _
        [-3134.56, -7523.34] _
    ]
    
    Local $endSection1Waypoints[3][2] = [ _
        [97.45, -9296.17], _
        [2102.55, -8464.81], _
        [4912.55, -7074.77] _
    ]
    
    Local $endSection2Waypoints[6][2] = [ _
        [6431.07, -8751.93], _
        [5095.10, -6959.62], _
        [5656.60, -3676.80], _
        [6753.56, 222.45], _
        [3763.82, 1040.80], _
        [1708.60, 1520.75] _
    ]
    
    Local $shrineWaypoints[2][2] = [ _
        [561.35, 591.78], _
        [-477.48, -1325.30] _
    ]

    ExecuteWaypoints($yetiWaypoints, "Kill some Yetis")
    ExecuteWaypoints($rangerBossWaypoints, "Kill the Ranger Boss")
    ExecuteWaypoints($rotWallowWaypoints, "Kill Rot Wallow")
    
    Out("Kill the Ritualist Boss")
    CHECK_PARTY_DEAD()
    AggroMoveToEx($ritualistWaypoints[0][0], $ritualistWaypoints[0][1], $MOVEMENT_RANGE)
    PrecastSpirits()
    
    CHECK_PARTY_DEAD()
    Party_CommandHero(4, -13947.86, -2250.88)
    Sleep(6000)
    Party_CancelHero(4)
    AggroMoveToEx($ritualistWaypoints[1][0], $ritualistWaypoints[1][1], $MOVEMENT_RANGE)
    CHECK_PARTY_DEAD()
    AggroMoveToEx(-13967.48, -1656.00, $MOVEMENT_RANGE)

    ExecuteWaypoints($oniSpawnWaypoints, "Oni Spawn Point")
    ExecuteWaypoints($midRotWallowWaypoints, "Kill Rot Wallow")
    ExecuteWaypoints($endSection1Waypoints, "")
    ExecuteWaypoints($endSection2Waypoints, "Oni Spawn Point")
    ExecuteWaypoints($shrineWaypoints, "Move To Shrine")
    
    CHECK_PARTY_DEAD()
    Sleep(3000)

    HandleDeath(2)
EndFunc ;==> FarmToSecondShrine

Func FarmToThirdShrine()
    Local $nagaWaypoints[1][2] = [[68.80, -2812.41]]
    
    Local $rotWallowWaypoints[4][2] = [ _
        [-1975.36, -2447.14], _
        [-2743.20, -718.23], _
        [-6319.35, -3363.90], _
        [-8786.40, 252.08] _
    ]
    
    Local $yetiCaveWaypoints[2][2] = [ _
        [-10728.21, 1438.67], _
        [-10846.09, 5862.79] _
    ]
    
    Local $monkBossWaypoints[1][2] = [[-8582.28, 8468.58]]
    
    Local $yetiAfterCaveWaypoints[5][2] = [ _
        [-6679.04, 7025.30], _
        [-4679.15, 7633.20], _
        [-2548.89, 8731.90], _
        [-4619.15, 6394.57], _
        [-5406.97, 3420.06] _
    ]
    
    Local $shrineWaypoints[3][2] = [ _
        [-6323.47, 622.15], _
        [-2498.45, 1072.42], _
        [30.04, 960.86] _
    ]

    ExecuteWaypoints($nagaWaypoints, "Kill Nagas")
    ExecuteWaypoints($rotWallowWaypoints, "Kill Rot Wallow")
    ExecuteWaypoints($yetiCaveWaypoints, "Kill Yetis before cave")
    ExecuteWaypoints($monkBossWaypoints, "Kill the Monk Boss")
    ExecuteWaypoints($yetiAfterCaveWaypoints, "Kill Yetis after cave")
    ExecuteWaypoints($shrineWaypoints, "Move close to the same Shrine as before")

    HandleDeath(3)
EndFunc ;==> FarmToThirdShrine

Func FarmToFourthShrine()
    Local $rotWallowWaypoints[3][2] = [ _
        [1967.51, 3169.33], _
        [4816.43, 5845.84], _
        [6774.16, 7644.99] _
    ]
    
    Local $nagaWaypoints[3][2] = [ _
        [8587.53, 6622.35], _
        [10557.92, 6783.90], _
        [10919.80, 9021.05] _
    ]
    
    Local $shrineWaypoints[2][2] = [ _
        [13768.36, 7637.01], _
        [14666.68, 9607.33] _
    ]

    ExecuteWaypoints($rotWallowWaypoints, "Kill Rot Wallow")
    ExecuteWaypoints($nagaWaypoints, "Kill Nagas")
    ExecuteWaypoints($shrineWaypoints, "Move to Shrine")
    
    CHECK_PARTY_DEAD()
    Sleep(3000)

    HandleDeath(4)
EndFunc ;==> FarmToFourthShrine

Func FarmToEnd()
    Local $oniSpawnWaypoints[3][2] = [ _
        [15533.14, 6853.51], _
        [15695.05, 4637.03], _
        [13542.48, 2297.27] _
    ]
    
    Local $nagaWaypoints[3][2] = [ _
        [13171.07, 39.77], _
        [11701.90, -3727.37], _
        [11770.87, -7040.32] _
    ]
    
    Local $outcastWaypoints[2][2] = [ _
        [14650.99, -9058.19], _
        [14872.70, -5791.33] _
    ]
    
    Local $cleanupWaypoints[8][2] = [ _
        [11385.53, -7817.82], _
        [7756.05, -7611.91], _
        [5039.12, -7104.21], _
        [5410.23, -3772.06], _
        [1190.87, -1992.54], _
        [2043.36, 1272.71], _
        [6404.70, 766.38], _
        [6089.76, -2339.20] _
    ]

    ExecuteWaypoints($oniSpawnWaypoints, "Oni Spawn Point")
    ExecuteWaypoints($nagaWaypoints, "Kill Nagas")
    
    Out("Kill Outcasts")
    For $i = 0 To UBound($outcastWaypoints) - 1
        If World_GetWorldInfo("FoesToKill") > 0 Then
            CHECK_PARTY_DEAD()
            AggroMoveToEx($outcastWaypoints[$i][0], $outcastWaypoints[$i][1], $MOVEMENT_RANGE)
        EndIf
    Next

    If World_GetWorldInfo("FoesToKill") > 0 Then
        Out("Looks like we missed a patrol")
        Out("!!!Go get them!!!")
        For $i = 0 To UBound($cleanupWaypoints) - 1
            If World_GetWorldInfo("FoesToKill") > 0 Then
                CHECK_PARTY_DEAD()
                AggroMoveToEx($cleanupWaypoints[$i][0], $cleanupWaypoints[$i][1], $MOVEMENT_RANGE)
            EndIf
        Next
    EndIf

    HandleDeath(0)
EndFunc ;==> FarmToEnd
