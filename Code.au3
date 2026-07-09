            If Not $BotRunning Then
              If Not $NickRun And Not $TwoFiddy
                ResetStart()
              EndIf
            EndIf

            If $NickRun Then
              Local $currentCount = GetItemCountByModelID($NickItem[0])
              If $currentCount >= 25 Then
                  LogInfo("Nicholas farm goal reached! Collected " & $currentCount & " " & $NickItem[1])
                  Return
              EndIf
            ElseIf $TwoFiddy Then
              Local $currentCount = GetItemCountByModelID($NickItem[0])
              If $currentCount >= 250 Then
                  LogInfo("You got that mad stack brother! Collected " & $currentCount & " " & $NickItem[1])
                  Return
              EndIf
            EndIf