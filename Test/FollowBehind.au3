#include-once

Global $g_Init = False
Global $g_LastLeaderX = 0
Global $g_LastLeaderY = 0
Global $g_LastUpdateTime = TimerInit()
Global $g_LastTargetX = 0
Global $g_LastTargetY = 0

Global $g_SmoothFactor = 0.25
Global $g_MinUpdateDist = 40
Global $g_PredictionStrength = 0.25
Global $g_StartFreezeTime = 300

Global $g_LastMapID = -1

Func CheckMapReset()
    Local $curMap = Map_GetMapID()

    If $curMap <> $g_LastMapID Then
        ; new zone → reset follow state
        $g_Init = False
        $g_LastMapID = $curMap
    EndIf
EndFunc

Func FollowLeaderSmoothPredict($p1x, $p1y, $rotation, $p2x, $p2y, $FOLLOW_OFFSET)
    CheckMapReset()

    If Not $g_Init Then
        $g_LastLeaderX = $p1x
        $g_LastLeaderY = $p1y
        $g_LastTargetX = $p1x
        $g_LastTargetY = $p1y
        $g_LastUpdateTime = TimerInit()
        $g_Init = True
        Return
    EndIf

    Local $now = TimerInit()
    Local $dt = TimerDiff($g_LastUpdateTime)
    If $dt <= 0 Then $dt = 16.6

    Local $vx = ($p1x - $g_LastLeaderX) / $dt
    Local $vy = ($p1y - $g_LastLeaderY) / $dt

    $g_LastLeaderX = $p1x
    $g_LastLeaderY = $p1y
    $g_LastUpdateTime = $now

    Local $predictionTime = 250
    Local $predictedX = $p1x + ($vx * $predictionTime * $g_PredictionStrength)
    Local $predictedY = $p1y + ($vy * $predictionTime * $g_PredictionStrength)

    Local $rawTX = $predictedX - (Cos($rotation) * $FOLLOW_OFFSET)
    Local $rawTY = $predictedY - (Sin($rotation) * $FOLLOW_OFFSET)

    Local $dist = ComputeDistance($g_LastTargetX, $g_LastTargetY, $rawTX, $rawTY)
    If $dist > $g_MinUpdateDist Then
        $g_LastTargetX = ($g_LastTargetX * $g_SmoothFactor) + ($rawTX * (1 - $g_SmoothFactor))
        $g_LastTargetY = ($g_LastTargetY * $g_SmoothFactor) + ($rawTY * (1 - $g_SmoothFactor))
    EndIf

    Local $d = ComputeDistance($p2x, $p2y, $g_LastTargetX, $g_LastTargetY)
    If $d < 40 Then Return

    AggroMoveSmartFilter($g_LastTargetX, $g_LastTargetY)
EndFunc
