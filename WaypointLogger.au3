#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <MsgBoxConstants.au3>

$gui = GUICreate("Waypoint Saver", 350, 300)
GUICtrlCreateLabel("Waypoint:", 10, 10, 60, 20)

; Title
GUICtrlCreateLabel("Title", 10, 40, 50, 20)
$inputTitle = GUICtrlCreateInput("", 10, 60, 100, 20)

; X
GUICtrlCreateLabel("X", 120, 40, 50, 20)
$inputX = GUICtrlCreateInput("", 120, 60, 100, 20)

; Y
GUICtrlCreateLabel("Y", 230, 40, 50, 20)
$inputY = GUICtrlCreateInput("", 230, 60, 100, 20)

; Output Box
GUICtrlCreateLabel("Output", 10, 90, 50, 20)
$outputBox = GUICtrlCreateEdit("", 10, 110, 320, 100, $ES_READONLY)

; Buttons
$btnSave = GUICtrlCreateButton("Save Output", 10, 220, 150, 30)
$btnAdd = GUICtrlCreateButton("Add X/Y", 180, 220, 150, 30)

GUISetState(@SW_SHOW)

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit

        Case $btnAdd
            $x = GUICtrlRead($inputX)
            $y = GUICtrlRead($inputY)
            If $x <> "" And $y <> "" Then
                ; Add to output box
                GUICtrlSetData($outputBox, GUICtrlRead($outputBox) & $x & " " & $y & @CRLF)
                ; Clear X and Y input boxes
                GUICtrlSetData($inputX, "")
                GUICtrlSetData($inputY, "")
            Else
                MsgBox($MB_ICONWARNING, "Warning", "Enter both X and Y values.")
            EndIf

        Case $btnSave
            $title = GUICtrlRead($inputTitle)
            $data = GUICtrlRead($outputBox)
            If $title <> "" And $data <> "" Then
                FileWrite(@ScriptDir & "\" & $title & ".txt", $data)
                MsgBox($MB_ICONINFORMATION, "Saved", "Output saved as " & $title & ".txt")
                ; Clear all input boxes
                GUICtrlSetData($inputTitle, "")
                GUICtrlSetData($inputX, "")
                GUICtrlSetData($inputY, "")
            Else
                MsgBox($MB_ICONWARNING, "Warning", "Enter a title and make sure there is output to save.")
            EndIf
    EndSwitch
WEnd
