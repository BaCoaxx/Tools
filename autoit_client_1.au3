#include <GUIConstantsEx.au3>

; Initialize TCP services
TCPStartup()

Local $sIPAddress = "127.0.0.1"
Local $iPort = 65432

; Connect to the Python Walkie-Talkie Server
Local $iSocket = TCPConnect($sIPAddress, $iPort)
If @error Then
    MsgBox(16, "Connection Error", "Could not connect to Python server. Please ensure walkie_talkie_server.py is running first.")
    Exit
EndIf

; Create a simple GUI to change and view variables
GUICreate("AutoIt Client 1 - Walkie Talkie", 350, 150)
GUICtrlCreateLabel("Variable to send:", 10, 13, 100, 20)
Local $idInput = GUICtrlCreateInput("Hello from Client 1!", 110, 10, 150, 20)
Local $idBtnSend = GUICtrlCreateButton("Send", 270, 9, 70, 22)

GUICtrlCreateLabel("Variable received:", 10, 50, 100, 20)
Local $idLabelRecv = GUICtrlCreateLabel("Waiting for data...", 110, 50, 230, 80)
GUISetState(@SW_SHOW)

; Main Loop
While 1
    Local $iMsg = GUIGetMsg()
    
    Select
        Case $iMsg = $GUI_EVENT_CLOSE
            ExitLoop
            
        Case $iMsg = $idBtnSend
            ; Read the variable from the input box
            Local $sDataToSend = GUICtrlRead($idInput)
            ; Send it to the Python server
            TCPSend($iSocket, "[Client 1] " & $sDataToSend)
    EndSelect

    ; Constantly check for incoming data from the Python Server
    Local $sRecvData = TCPRecv($iSocket, 2048)
    
    ; If @error is set, the server disconnected
    If @error Then
        MsgBox(16, "Disconnected", "Lost connection to the Python server.")
        ExitLoop
    EndIf
    
    ; If we received data, update the GUI
    If $sRecvData <> "" Then
        GUICtrlSetData($idLabelRecv, $sRecvData)
    EndIf
WEnd

; Cleanup
TCPCloseSocket($iSocket)
TCPShutdown()
