Global $g_aLevelXP[20] = [ _
    0, 2000, 4600, 7800, 11600, 16000, 21000, _
    26600, 32800, 39600, 47000, 55000, 63600, _
    72800, 82600, 93000, 104000, 115600, _
    127800, 140600 _
]

Func UpdateProgressBar()
    Static $iLastXP = -1

    Local $iMyXP = World_GetWorldInfo("Experience")

    If $iMyXP = $iLastXP Then Return
    $iLastXP = $iMyXP

    Local $iMyLevel = 0

    For $i = UBound($g_aLevelXP) - 1 To 0 Step -1
        If $iMyXP >= $g_aLevelXP[$i] Then
            $iMyLevel = $i
            ExitLoop
        EndIf
    Next

    ; At max level, fill the bar to 100%
    If $iMyLevel >= UBound($g_aLevelXP) - 1 Then
        GUICtrlSetData($hProgressBar, 100)
        Return
    EndIf

    Local $iLevelStart = $g_aLevelXP[$iMyLevel]
    Local $iLevelEnd   = $g_aLevelXP[$iMyLevel + 1]

    Local $fPercent = (($iMyXP - $iLevelStart) / ($iLevelEnd - $iLevelStart)) * 100

    GUICtrlSetData($hProgressBar, Round($fPercent))
EndFunc