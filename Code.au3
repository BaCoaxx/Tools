            If Not $BotRunning Then
                ResetStart()
                Return
            EndIf

            If $NickRun Then
                Local $currentCount = GetItemCountByModelID($NickItem[0])
                If Not $TwoFiddy Then
                    If $currentCount >= 25 Then
                        LogInfo("Nicholas farm goal reached! Collected " & $currentCount & " " & $NickItem[1])
                        Return
                    EndIf
                Else
                    If $currentCount >= 250 Then
                        LogInfo("Nicholas farm goal reached! Collected " & $currentCount & " " & $NickItem[1])
                        Return
                    EndIf
                EndIf
            EndIf