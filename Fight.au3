Func GeneralFight($aSkillSlots, $range = 1250)
    While True
        Local $nearestEnemy = Agent_TargetNearestEnemy($range)
        If $nearestEnemy == 0 Then
            Out("No enemies left within range: " & $range)
            ExitLoop
        EndIf

        While Not GetIsDead($nearestEnemyID)
        		If Not GetIsDead() Then
            	If Not IsCasting() Then
              	  For $j = 0 To UBound ($aSkillSlots) - 1
                    UseSkill($aSkillSlots[$j], $nearestEnemyID)
              	  Next
            	EndIf
          	EndIf
          Sleep(50)
        WEnd
    WEnd
    PickUpLoot()
EndFunc

Func CombatAction($skillSlot, $enemyID)
    Local $energy = GetEnergy()
    Local $isReady = IsRecharged($skillSlot)

    Select
        Case $skillSlot = 0 And $enemyHP < 50
            ; Only use skill in slot 0 if enemy HP < 50%
            If $isReady And $energy >= GetSkillCost($skillSlot) Then
                UseSkill($skillSlot, $enemyID)
            EndIf

        Case $skillSlot = 1 And $energy > 20
            ; Only use skill in slot 1 if energy > 20
            If $isReady Then
                UseSkill($skillSlot, $enemyID)
            EndIf

        Case $skillSlot = 2
            ; Always use skill in slot 2 if ready
            If $isReady And $energy >= GetSkillCost($skillSlot) Then
                UseSkill($skillSlot, $enemyID)
            EndIf

        Case Else
            ; Default: cast if recharged and enough energy
            If $isReady And $energy >= GetSkillCost($skillSlot) Then
                UseSkill($skillSlot, $enemyID)
            EndIf
    EndSelect
EndFunc

Func GetIsDead($agentID = -2)
    Return Agent_GetAgentInfo($agentID, "IsDead")
EndFunc

Func IsRecharged($skillSlot)
    Return Skill_GetSkillBarInfo($skillSlot, "IsRecharged")
EndFunc

Func GetEnergy()
    Return Agent_GetAgentInfo(-2, "CurrentEnergy")
EndFunc

Func GetSkillCost($skillSlot)
    Local $skillID = Skill_GetSkillBarInfo($skillSlot, "SkillID")
    Return Skill_GetSkillInfo($skillID, "EnergyCost")
EndFunc

Func UseSkill($skillSlot, $targetID)
    Skill_UseSkill($skillSlot, $targetID)
EndFunc

Func IsCasting()
    Return Agent_GetAgentInfo(-2, "IsCasting")
EndFunc

Func EnemyHP($agentID)
    Return Agent_GetAgentInfo($agentID, "HP")
EndFunc

Func PickUpLoot()
    ; Implement your loot pickup here
EndFunc