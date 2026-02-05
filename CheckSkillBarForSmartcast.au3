Func CheckSkillbar()
    ; Get player's professions
    Local $primaryProf = Agent_GetAgentInfo(-2, "Primary")
    Local $secondaryProf = Agent_GetAgentInfo(-2, "Secondary")
    
    ; Check if player has secondary profession
    If $secondaryProf <> 0 Then
        LogInfo("Player has a secondary profession. Using SmartCast!")
        UAI_CacheSkillBar()
        Return True ; Has secondary, skillbar is valid
    EndIf
    
    LogWarn("Player has no secondary profession. Validating skills to consider SmartCast...")
    
    ; Check all skills on the bar
    For $slot = 1 To 8
        Local $skillID = Skill_GetSkillbarInfo($slot, "SkillID")
        
        If $skillID = 0 Then ContinueLoop ; Empty slot
        
        ; Get the attribute required for this skill
        Local $requiredAttribute = Skill_GetSkillInfo($skillID, "Attribute")
        
        If $requiredAttribute = 0 Then ContinueLoop ; No attribute required (common skills are OK)
        
        ; Check if we have this attribute
        Local $hasAttribute = Attribute_GetPartyAttributeInfo($requiredAttribute, 0, "HasAttribute")
        
        If Not $hasAttribute Then
            ; We don't have this attribute - skillbar is invalid
            Local $skillName = Skill_GetSkillInfo($skillID, "Name")
            LogError("Skill '" & $skillName & "' (slot " & $slot & ") requires an attribute which you don't have!")
            LogError("Skillbar validarion failed. Using regular fight mode!")
            Return False ; Invalid skillbar
        EndIf
    Next
    
    ; All skills are valid for primary profession
    LogInfo("All skills are valid. Using SmartCast!")
    UAI_CacheSkillBar()
    Return True ; Valid skillbar
EndFunc