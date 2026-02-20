; Precomputed XP needed for each level
Global $g_aXPNeeded[21] = [ _
    0, ; Dummy value for index 0 (unused)
    2000, ; Level 1 → 2
    2600, ; Level 2 → 3
    3200, ; Level 3 → 4
    3800, ; Level 4 → 5
    4400, ; Level 5 → 6
    5000, ; Level 6 → 7
    5600, ; Level 7 → 8
    6200, ; Level 8 → 9
    6800, ; Level 9 → 10
    7400, ; Level 10 → 11
    8000, ; Level 11 → 12
    8600, ; Level 12 → 13
    9200, ; Level 13 → 14
    9800, ; Level 14 → 15
    10400, ; Level 15 → 16
    11000, ; Level 16 → 17
    11600, ; Level 17 → 18
    11800, ; Level 18 → 19
    12800, ; Level 19 → 20
    0 ; Dummy value for level 20+ (unused)
]

Func UpdateProgressBar()
    Local $TotalExp = World_GetWorldInfo("Experience")
    Local $Level = Agent_GetAgentInfo(-2, "Level")

    If $Level >= 20 Then
        $ProgressPercent = 100
    Else
        ; Calculate total XP required to reach current level
        Local $TotalXPForLevel = 0
        For $i = 1 To $Level
            $TotalXPForLevel += $g_aXPNeeded[$i]
        Next

        ; Calculate XP earned in current level
        Local $XPInLevel = $TotalExp - $TotalXPForLevel
        Local $XPNeeded = $g_aXPNeeded[$Level + 1] ; XP needed to reach next level

        ; Clamp progress between 0% and 100%
        If $XPInLevel < 0 Then
            $ProgressPercent = 0
        ElseIf $XPInLevel >= $XPNeeded Then
            $ProgressPercent = 100
        Else
            $ProgressPercent = ($XPInLevel / $XPNeeded) * 100
        EndIf
    EndIf

    ; Update the progress bar control
    GUICtrlSetData($Progress, Round($ProgressPercent))
EndFunc

; Register the function to run frequently
AdlibRegister("UpdateProgressBar", 100) ; Update every 100ms