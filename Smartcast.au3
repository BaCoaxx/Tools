Func SmartCast($aSkill, $aTarget = -2, $waitForRecharge = False)
    If Agent_GetAgentInfo(-2, "IsDead") Then Return False ; We are dead, so we return

    ; If waitForRecharge is True, we wait until the skill is recharged
    If $waitForRecharge Then
        While Skill_GetSkillbarInfo($aSkill, "IsRecharged") = False
            Sleep(100)
        WEnd
    EndIf

    ; Check if the skill is recharged and then make sure we have enough energy needed to cast
    If Skill_GetSkillbarInfo($aSkill, "IsRecharged") = True Then
        If Agent_GetAgentInfo(-2, "CurrentEnergy") >= Skill_GetSkillInfo($aSkill, "EnergyCost") Then
            Skill_UseSkill($aSkill, $aTarget)
            
            ; We wait until we are done casting before we 
            Do
                Sleep(32)
            Until Not IsCasting($aSkill)
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
Func IsCasting($aSkill)
    If Not Agent_GetAgentInfo(-2, "IsCasting") And Not Agent_GetAgentInfo(-2, "Skill") And Not Skill_GetSkillbarInfo($aSkill, "Casting") Then
        Return False
    Else 
        Return True
    EndIf
EndFunc