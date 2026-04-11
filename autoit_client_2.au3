#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>

; Initialize TCP services
TCPStartup()

Local $sIPAddress = "127.0.0.1"
Local $iPort = 65432

; Create the GUI
Local $hGUI = GUICreate("AutoIt Client 2 - Walkie Talkie", 400, 300)

; Create a multi-line Edit control to act as our "Console" (Read-Only, Vertical Scrollbar)
Local $idConsole = GUICtrlCreateEdit("", 10, 10, 380, 200, BitOR($ES_READONLY, $WS_VSCROLL, $ES_AUTOVSCROLL))
GUICtrlSetBkColor($idConsole, 0x000000) ; Black background
GUICtrlSetColor($idConsole, 0x00FFFF)   ; Cyan text for client 2

; Input box for variable change
GUICtrlCreateLabel("Variable to send:", 10, 223, 100, 20)
Local $idInput = GUICtrlCreateInput("Hello from Client 2", 110, 220, 190, 25)

; Send and Close Buttons
Local $idBtnSend = GUICtrlCreateButton("Send", 310, 220, 80, 25)
Local $idBtnClose = GUICtrlCreateButton("Close", 310, 260, 80, 25)

GUISetState(@SW_SHOW)

; Try to connect
Local $iSocket = TCPConnect($sIPAddress, $iPort)
If @error Then
    GUICtrlSetData($idConsole, "[System] Could not connect to Python server." & @CRLF, 1) ; 1 = Append to end
Else
    GUICtrlSetData($idConsole, "[System] Connected to Python Walkie-Talkie Server!" & @CRLF, 1)
EndIf

; Main Loop
While 1
    Local $iMsg = GUIGetMsg()
    
    Select
        Case $iMsg = $GUI_EVENT_CLOSE Or $iMsg = $idBtnClose
            ExitLoop
            
        Case $iMsg = $idBtnSend
            If $iSocket <> -1 Then
                Local $sDataToSend = GUICtrlRead($idInput)
                If $sDataToSend <> "" Then
                    TCPSend($iSocket, $sDataToSend)
                    ; Show what we just sent in our own console
                    GUICtrlSetData($idConsole, "[Sent] " & $sDataToSend & @CRLF, 1)
                    GUICtrlSetData($idInput, "") ; Clear the input box after sending
                EndIf
            Else
                GUICtrlSetData($idConsole, "[Error] Not connected to server!" & @CRLF, 1)
            EndIf
    EndSelect

    ; Constantly check for incoming data from the Python Server
    If $iSocket <> -1 Then
        Local $sRecvData = TCPRecv($iSocket, 2048)
        
        ; If @error is set, the server disconnected
        If @error Then
            GUICtrlSetData($idConsole, "[System] Lost connection to the server." & @CRLF, 1)
            TCPCloseSocket($iSocket)
            $iSocket = -1
        EndIf
        
        ; If we received data, append it to the console
        If $sRecvData <> "" Then
            GUICtrlSetData($idConsole, "[Received] " & $sRecvData & @CRLF, 1)
        EndIf
    EndIf
WEnd

; Cleanup
If $iSocket <> -1 Then TCPCloseSocket($iSocket)
TCPShutdown()
