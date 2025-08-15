Func Fight($x, $s = "enemies")
    If GetPartyDead() Then Return

    Local $target, $distance, $energy, $useSkill
    Local $lastId = -1, $coordinate[2], $timer
    Local $startTime = TimerInit()

    While GetNumberOfFoesInRangeOfAgent(-2, 1700) > 0 And TimerDiff($startTime) < 120000 And Not GetPartyDead()
        $target = GetNearestEnemyToAgent(-2, 1700, $GC_I_AGENT_TYPE_LIVING, 1, "EnemyFilter")
        If $target = 0 Or GetPartyDead() Then ExitLoop

        $distance = GetDistance($target, -2)
        If $distance < $x Then
            If Agent_GetAgentInfo($target, 'ID') <> $lastId Then
                Agent_ChangeTarget($target)
                Other_RndSleep(100)
                Agent_CallTarget($target)
                Other_RndSleep(100)
                Agent_Attack($target)
                $lastId = Agent_GetAgentInfo($target, 'ID')
                $coordinate[0] = Agent_GetAgentInfo($target, 'X')
                $coordinate[1] = Agent_GetAgentInfo($target, 'Y')
                $timer = TimerInit()

                ; Move closer if needed
                While GetDistance($target, -2) > 1100 And TimerDiff($timer) < 7000 And Not GetPartyDead()
                    Map_Move($coordinate[0], $coordinate[1])
                    Other_RndSleep(40)
                WEnd
            EndIf

            $timer = TimerInit()
            While Agent_GetAgentInfo($target, 'HP') > 0.005 And GetDistance($target, -2) < $x And TimerDiff($timer) < 12000 And Not GetPartyDead()
                For $i = 0 To 7
                    $energy = GetEnergy(-2)
                    If IsRecharged($i + 1) And $energy >= $skillCost[$i] Then
                        UseSkillEx($i + 1, $target)
                        Other_RndSleep(90)
                        Agent_Attack($target)
                        Other_RndSleep(90)
                    EndIf
                Next
                Agent_Attack($target)
                Other_RndSleep(70)
            WEnd
        EndIf
    WEnd

    ; Pickup loot if alive and inventory space
    If CountSlots() <> 0 And Not GetPartyDead() Then
        PickupLoot()
    EndIf
EndFunc

Func AggroMoveToEx($x, $y, $s = "", $z = 1700)
    If GetPartyDead() Then Return
    $TimerToKill = TimerInit()
    Local $blocked = 0, $random = 50
    Local $coords[2], $oldCoords[2]
    Local $enemy, $distance

    Map_Move($x, $y, $random)
    $coords[0] = Agent_GetAgentInfo(-2, 'X')
    $coords[1] = Agent_GetAgentInfo(-2, 'Y')

    Do
        If GetPartyDead() Then ExitLoop
        Other_RndSleep(200) ; slightly faster

        $oldCoords[0] = $coords[0]
        $oldCoords[1] = $coords[1]

        ; Only get nearest enemy if there are foes in range
        If GetNumberOfFoesInRangeOfAgent(-2, $z, $GC_I_AGENT_TYPE_LIVING, 1, "EnemyFilter") > 0 Then
            $enemy = GetNearestEnemyToAgent(-2, $z, $GC_I_AGENT_TYPE_LIVING, 1, "EnemyFilter")
            If $enemy > 0 And Not GetPartyDead() Then
                $distance = ComputeDistance(Agent_GetAgentInfo($enemy, 'X'), Agent_GetAgentInfo($enemy, 'Y'), $coords[0], $coords[1])
                If $distance < $z Then
                    Fight($z, $s)
                EndIf
            EndIf
        EndIf

        Other_RndSleep(200)

        If GetPartyDead() Then ExitLoop
        $coords[0] = Agent_GetAgentInfo(-2, 'X')
        $coords[1] = Agent_GetAgentInfo(-2, 'Y')

        If $oldCoords[0] = $coords[0] And $oldCoords[1] = $coords[1] Then
            $blocked += 1
            MoveTo($coords[0], $coords[1], 250)
            Other_RndSleep(250)
            If GetPartyDead() Then ExitLoop
            Map_Move($x, $y)
        Else
            $blocked = 0
        EndIf

    Until ComputeDistance($coords[0], $coords[1], $x, $y) < 250 Or $blocked > 10 Or GetPartyDead() Or TimerDiff($TimerToKill) > 120000
EndFunc