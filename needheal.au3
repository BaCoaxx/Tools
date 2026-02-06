; ===============================================
; HEALING SYSTEM
; ===============================================

; Healing skill IDs
Global $g_aHealingSkills[8] = [ _
    40,   ; Ether Feast (Mesmer)
    281,  ; Orison of Healing (Monk)
    288,  ; Healing Breeze (Monk)
    279,  ; Divine Healing (Monk)
    280,  ; Heal Area (Monk)
    307,  ; Healing Signet (Warrior)
    460,  ; Healing Spring (Ranger - Trap)
    458   ; Troll Unguent (Ranger)
]

; Check if skill ID is a healing skill
Func IsHealingSkill($skillID)
    For $i = 0 To UBound($g_aHealingSkills) - 1
        If $skillID = $g_aHealingSkills[$i] Then Return True
    Next
    Return False
EndFunc

; Get first recharged healing skill on bar
Func GetHealOnBar()
    For $slot = 1 To 8
        Local $skillID = Skill_GetSkillbarInfo($slot, "SkillID")
        If IsHealingSkill($skillID) Then
            If IsRecharged($slot) Then Return $slot
        EndIf
    Next
    Return 0
EndFunc

; Check if HP is below threshold percentage
Func NeedHeal($Threshold = 70)
    If Agent_GetAgentInfo(-2, 'CurrentHP') <= Agent_GetAgentInfo(-2, 'MaxHP') * ($Threshold / 100) Then
        Local $currentHP = Agent_GetAgentInfo(-2, 'CurrentHP')
        Local $maxHP = Agent_GetAgentInfo(-2, 'MaxHP')
        Local $hpPercent = Int(($currentHP / $maxHP) * 100)
        LogWarn("HP low (" & $hpPercent & "%), need healing!")
        Return True
    EndIf
    Return False
EndFunc

; Use one healing skill and return
Func UseHeal()
    Local $healSlot = GetHealOnBar()
    If $healSlot = 0 Then Return False
    
    Local $skillID = Skill_GetSkillbarInfo($healSlot, "SkillID")
    Local $skillName = Skill_GetSkillInfo($skillID, "Name")
    LogWarn("Using healing skill: " & $skillName & " (slot " & $healSlot & ")")
    
    UseSkillEx($healSlot, -2)
    
    Return True
EndFunc

; ===============================================
; FIGHT FUNCTION WITH HEALING
; ===============================================

Func FightExFilter($a_f_AggroRange, $filterFunc = "EnemyFilter")
	If GetPartyDead() Then Return
	If SurvivorMode() Then Return
	Local $target
	Local $distance
	Local $useSkill
	Local $energy
	Local $lastId = 99999, $coordinate[2], $timer
	
	Do
		If GetNumberOfFoesInRangeOfAgent(-2, 1700) = 0 Then ExitLoop
		If TimerDiff($TimerToKill) > 180000 Then ExitLoop
		If GetPartyDead() Then ExitLoop
		If SurvivorMode() Then Return
		
		; Check for healing before engaging target
		If NeedHeal(70) Then UseHeal()
		
		$target = GetNearestEnemyToAgent(-2, 1700, $GC_I_AGENT_TYPE_LIVING, 1, $filterFunc)
		If GetPartyDead() Then ExitLoop
		If SurvivorMode() Then Return
		$distance = ComputeDistance(Agent_GetAgentInfo($target, 'X'), Agent_GetAgentInfo($target, 'Y'), Agent_GetAgentInfo(-2, 'X'), Agent_GetAgentInfo(-2, 'Y'))
		
		If $target <> 0 AND $distance < $a_f_AggroRange And Not GetPartyDead() Then
			If TimerDiff($TimerToKill) > 180000 Then ExitLoop
			
			If Agent_GetAgentInfo($target, 'ID') <> $lastId Then
				If GetPartyDead() Then ExitLoop
				If SurvivorMode() Then Return
				Agent_ChangeTarget($target)
				Other_RndSleep(150)
				Agent_CallTarget($target)
				Other_RndSleep(150)
				If GetPartyDead() Then ExitLoop
				If SurvivorMode() Then Return
				Agent_Attack($target)
				$lastId = Agent_GetAgentInfo($target, 'ID')
				$coordinate[0] = Agent_GetAgentInfo($target, 'X')
				$coordinate[1] = Agent_GetAgentInfo($target, 'Y')
				$timer = TimerInit()
				$distance = ComputeDistance($coordinate[0], $coordinate[1], Agent_GetAgentInfo(-2, 'X'), Agent_GetAgentInfo(-2, 'Y'))
				If GetPartyDead() Then ExitLoop
				If SurvivorMode() Then Return
				
				If $distance > 1100 Then
					Do
						If GetNumberOfFoesInRangeOfAgent(-2, 1700) = 0 Then ExitLoop
						If TimerDiff($TimerToKill) > 180000 Then ExitLoop
						If GetPartyDead() Then ExitLoop
						If SurvivorMode() Then Return
						Map_Move($coordinate[0], $coordinate[1])
						Other_RndSleep(50)
						If GetPartyDead() Then ExitLoop
						If SurvivorMode() Then Return
						$distance = ComputeDistance($coordinate[0], $coordinate[1], Agent_GetAgentInfo(-2, 'X'), Agent_GetAgentInfo(-2, 'Y'))
					Until $distance < 1100 Or TimerDiff($timer) > 10000 Or GetPartyDead() Or TimerDiff($TimerToKill) > 180000
				EndIf
			EndIf
			
			If TimerDiff($TimerToKill) > 180000 Then ExitLoop
			Other_RndSleep(150)
			$timer = TimerInit()
			If GetPartyDead() Then ExitLoop
			If SurvivorMode() Then Return
			
			Do
				If GetNumberOfFoesInRangeOfAgent(-2, 1700) = 0 Then ExitLoop
				If TimerDiff($TimerToKill) > 180000 Then ExitLoop
				If GetPartyDead() Then ExitLoop
				If SurvivorMode() Then Return
				
				; Check for healing during combat (more aggressive threshold)
				If NeedHeal(60) Then UseHeal()
				
				$target = GetNearestEnemyToAgent(-2, 1700, $GC_I_AGENT_TYPE_LIVING, 1, $filterFunc)
				If GetPartyDead() Then ExitLoop
				If SurvivorMode() Then Return
				$distance = GetDistance($target, -2)
				
				If $distance < 1250 And Not GetPartyDead() Then
					If GetNumberOfFoesInRangeOfAgent(-2, 1700) = 0 Then ExitLoop
					If TimerDiff($TimerToKill) > 180000 Then ExitLoop
					
					For $i = 0 To 7
						If GetNumberOfFoesInRangeOfAgent(-2, 1700) = 0 Then ExitLoop
						If TimerDiff($TimerToKill) > 180000 Then ExitLoop
						If GetPartyDead() Then ExitLoop
						If SurvivorMode() Then Return
						If Agent_GetAgentInfo($target, 'IsDead') Then ExitLoop
						
						$distance = GetDistance($target, -2)
						If $distance > $a_f_AggroRange Then ExitLoop
						
						$energy = GetEnergy(-2)
						
						; Get skill ID for current slot
						Local $currentSkillID = Skill_GetSkillbarInfo($i, "SkillID")
						
						; Skip healing skills - they're handled separately
						If IsHealingSkill($currentSkillID) Then ContinueLoop
						
						If IsRecharged($i+1) And $energy >= Skill_GetSkillInfo($currentSkillID, "EnergyCost") And Not GetPartyDead() Then
							If GetNumberOfFoesInRangeOfAgent(-2, 1700) = 0 Then ExitLoop
							If TimerDiff($TimerToKill) > 180000 Then ExitLoop
							$useSkill = $i + 1
							UseSkillEx($useSkill, $target)
							Other_RndSleep(150)
							If GetPartyDead() Then ExitLoop
							If SurvivorMode() Then Return
							Agent_Attack($target)
							Other_RndSleep(150)
						EndIf
						
						If TimerDiff($TimerToKill) > 180000 Then ExitLoop
						If $i = 7 Then $i = -1
						If GetPartyDead() Then ExitLoop
						If SurvivorMode() Then Return
					Next
				EndIf
				
				If TimerDiff($TimerToKill) > 180000 Then ExitLoop
				If GetPartyDead() Then ExitLoop
				If SurvivorMode() Then Return
				Agent_Attack($target)
				$distance = GetDistance($target, -2)
			Until Agent_GetAgentInfo($target, 'HP') < 0.005 Or $distance > $a_f_AggroRange Or TimerDiff($timer) > 20000 Or GetPartyDead() Or TimerDiff($TimerToKill) > 180000
		EndIf
		
		If GetNumberOfFoesInRangeOfAgent(-2, 1700) = 0 Then ExitLoop
		If TimerDiff($TimerToKill) > 180000 Then ExitLoop
		If GetPartyDead() Then ExitLoop
		If SurvivorMode() Then Return
		$target = GetNearestEnemyToAgent(-2, 1700, $GC_I_AGENT_TYPE_LIVING, 1, $filterFunc)
		If GetPartyDead() Then ExitLoop
		If SurvivorMode() Then Return
		$distance = GetDistance($target, -2)
	Until Agent_GetAgentInfo($target, 'ID') = 0 Or $distance > $a_f_AggroRange Or GetPartyDead() Or TimerDiff($TimerToKill) > 180000
	
	If CountSlots() <> 0 And Not GetPartyDead() Then
		If TimerDiff($TimerToKill) > 180000 Then Return
		PickupLoot()
	EndIf
EndFunc   ;==>FightExFilter