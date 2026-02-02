Func AggroMoveToExFilter($aX, $aY, $a_f_AggroRange = 1700, $filterFunc = "EnemyFilter")

    If GetPartyDead() Then Return
    $TimerToKill = TimerInit()
    Local $random = 50
    Local $iBlocked = 0
    Local $enemy
    Local $distance

    Map_Move($aX, $aY, $random)
    $coords[0] = Agent_GetAgentInfo(-2, 'X')
    $coords[1] = Agent_GetAgentInfo(-2, 'Y')
    
    Do
        If GetPartyDead() Then ExitLoop
        Other_RndSleep(250)
        $oldCoords = $coords
        
        ; Check filter type
        If $filterFunc = "EnemyFilter" Then
            ; Use standard UAI_Fight with SmartCast
            If Map_GetInstanceInfo("Type") = $GC_I_MAP_TYPE_EXPLORABLE Then
                UAI_Fight($coords[0], $coords[1], $a_f_AggroRange, 3500, $g_i_FightMode)
                PickUpLoot()
                Return
            EndIf
        Else
            ; Use custom filter with FightExFilter
            If GetNumberOfFoesInRangeOfAgent(-2, 1700, $GC_I_AGENT_TYPE_LIVING, 1, $filterFunc) > 0 Then
                If GetPartyDead() Then ExitLoop
                $enemy = GetNearestEnemyToAgent(-2, 1700, $GC_I_AGENT_TYPE_LIVING, 1, $filterFunc)
                If GetPartyDead() Then ExitLoop
                $distance = ComputeDistance(Agent_GetAgentInfo($enemy, 'X'), Agent_GetAgentInfo($enemy, 'Y'), Agent_GetAgentInfo(-2, 'X'), Agent_GetAgentInfo(-2, 'Y'))
                If $distance < $a_f_AggroRange And $enemy <> 0 And Not GetPartyDead() Then
                    Out("Filtering enemies with " & $filterFunc & ".")
                    FightExFilter($a_f_AggroRange, $filterFunc)
                    If SurvivorMode() Then Return
                EndIf
            EndIf
        EndIf

        Other_RndSleep(250)

        If GetPartyDead() Then ExitLoop
        $coords[0] = Agent_GetAgentInfo(-2, 'X')
        $coords[1] = Agent_GetAgentInfo(-2, 'Y')
        If $oldCoords[0] = $coords[0] And $oldCoords[1] = $coords[1] And Not GetPartyDead() Then
            $iBlocked += 1
            MoveTo($coords[0], $coords[1], 300)
            Other_RndSleep(350)
            If GetPartyDead() Then ExitLoop
            Map_Move($aX, $aY)
        EndIf

    Until ComputeDistance($coords[0], $coords[1], $aX, $aY) < 250 Or $iBlocked > 20 Or GetPartyDead() Or TimerDiff($TimerToKill) > 180000
EndFunc   ;==>AggroMoveToExFilter