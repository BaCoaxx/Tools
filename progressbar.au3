#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <WindowsConstants.au3>

; Total exp for each level
Global $g_aLevelXP[20] = [ _
    0, 2000, 4600, 7800, 11600, 16000, 21000, _
    26600, 32800, 39600, 47000, 55000, 63600, _
    72800, 82600, 93000, 104000, 115600, _
    127800, 140600 _
]

Func GetXPBarPercent()
    Local $iXP = World_GetWorldInfo("Experience")
    Local $iLevel = Agent_GetAgentInfo(-2, "Level")

    ; Safety for max level
    If $iLevel >= UBound($g_aLevelXP) - 1 Then Return 100

    Local $iXPThisLevel = $g_aLevelXP[$iLevel]
    Local $iXPNextLevel = $g_aLevelXP[$iLevel + 1]

    Local $iIntoLevel = $iXP - $iXPThisLevel
    Local $iRange = $iXPNextLevel - $iXPThisLevel

    If $iRange <= 0 Then Return 100

    Return Int(($iIntoLevel / $iRange) * 100)
EndFunc

; Progress bar with scalable experience percentage
Global $hProgressBar = GUICtrlCreateProgress(50, 50, 300, 30)
GUICtrlSetRange($hProgressBar, 100) ; percent range

; Update progress bar along with total time adlibregister
GUICtrlSetData($hProgressBar, GetXPBarPercent())