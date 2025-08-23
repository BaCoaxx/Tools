Func SmartCast($aSkill, $aTarget = -2, $waitForRecharge = False)
    If Agent_GetAgentInfo(-2, "IsDead") Then Return

    ; If waitForRecharge is True, wait until the skill is recharged
    If $waitForRecharge Then
        While Skill_GetSkillbarInfo($aSkill, "IsRecharged") = False
            Sleep(100)
        WEnd
    EndIf

    ; If skill is now recharged, proceed
    If Skill_GetSkillbarInfo($aSkill, "IsRecharged") = True Then
        If Agent_GetAgentInfo(-2, "CurrentEnergy") >= Skill_GetSkillInfo($aSkill, "EnergyCost") Then
            Skill_UseSkill($aSkill, $aTarget)
            ; Wait dynamically for casting to finish
            Do
                Sleep(32)
            Until Not IsCasting($aSkill)
        Else
            Return ; Not enough energy
        EndIf
    Else
        Return ; Skill not recharged and not waiting
    EndIf
EndFunc

Func IsCasting($aSkill)
    If Not Agent_GetAgentInfo(-2, "IsCasting") And Not Agent_GetAgentInfo(-2, "Skill") And Not Skill_GetSkillbarInfo($aSkill, "Casting") Then
        Return False
    Else 
        Return True
    EndIf
EndFunc