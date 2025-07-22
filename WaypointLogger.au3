#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>

$gui = GUICreate("Waypoint Saver", 450, 300)
GUICtrlCreateLabel("Waypoint:", 10, 10, 60, 20)

; Title
GUICtrlCreateLabel("Title", 10, 40, 50, 20)
$inputTitle = GUICtrlCreateInput("", 10, 60, 100, 20)

; X
GUICtrlCreateLabel("X", 120, 40, 50, 20)
$inputX = GUICtrlCreateInput("", 120, 60, 70, 20)

; Y
GUICtrlCreateLabel("Y", 200, 40, 50, 20)
$inputY = GUICtrlCreateInput("", 200, 60, 70, 20)

; Comments
GUICtrlCreateLabel("Comments", 280, 40, 70, 20)
$inputComments = GUICtrlCreateInput("", 280, 60, 120, 20)

; Output Box
GUICtrlCreateLabel("Output", 10, 90, 50, 20)
$outputBox = GUICtrlCreateEdit("", 10, 110, 420, 100, $ES_READONLY + $ES_AUTOVSCROLL + $WS_VSCROLL)

; Buttons
$btnSave = GUICtrlCreateButton("Save Output", 230, 220, 200, 30)
$btnAdd = GUICtrlCreateButton("Add Waypoint", 10, 220, 200, 30)

GUISetState(@SW_SHOW)

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit

        Case $btnAdd
            $x = GUICtrlRead($inputX)
            $y = GUICtrlRead($inputY)
            $comments = GUICtrlRead($inputComments)
            If $x <> "" And $y <> "" Then
                If StringIsInt($x) And StringIsInt($y) Then
                    $outputLine = $x & ", " & $y
                    If $comments <> "" Then
                        $outputLine &= " ;~ " & $comments
                    EndIf
                    GUICtrlSetData($outputBox, GUICtrlRead($outputBox) & $outputLine & @CRLF)
                    ; Clear X, Y, and Comments input boxes
                    GUICtrlSetData($inputX, "")
                    GUICtrlSetData($inputY, "")
                    GUICtrlSetData($inputComments, "")
                Else
                    MsgBox($MB_ICONWARNING, "Warning", "Only numbers are allowed for X and Y.")
                EndIf
            Else
                MsgBox($MB_ICONWARNING, "Warning", "Enter both X and Y values.")
            EndIf

        Case $btnSave
            $title = GUICtrlRead($inputTitle)
            $data = GUICtrlRead($outputBox)
            If $title <> "" And $data <> "" Then
                FileWrite(@ScriptDir & "\WaypointLogs\" & $title & ".txt", $data)
                MsgBox($MB_ICONINFORMATION, "Saved", "Output saved as " & $title & ".txt")
                ; Clear all input boxes
                GUICtrlSetData($inputTitle, "")
                GUICtrlSetData($inputX, "")
                GUICtrlSetData($inputY, "")
                GUICtrlSetData($inputComments, "")
                GUICtrlSetData($outputBox, "")
            Else
                MsgBox($MB_ICONWARNING, "Warning", "Enter a title and make sure there is output to save.")
            EndIf
    EndSwitch
WEnd

Func HelloWorld()
    MsgBox($MB_OK, "Hello", "Hello, World!")
    Return
EndFunc

Func FunctionName($Param)
    
    Return True
EndFunc