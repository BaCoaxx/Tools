#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>

; Initialize TCP services
TCPStartup()

Local $sIPAddress = "127.0.0.1"
Local $iPort = 65432

; Create the GUI - Futuristic Theme
Local $hGUI = GUICreate("NEURAL LINK: Terminal Alpha", 420, 320, -1, -1, BitOR($WS_POPUP, $WS_CAPTION, $WS_SYSMENU))
GUISetBkColor(0x0A0A0A) ; Deep dark gray/black background

; Set global font to something monospaced/techy
GUISetFont(9, 600, 0, "Consolas")

; Top decorative header
Local $idHeader = GUICtrlCreateLabel("[ SYS.UPLINK ESTABLISHED ]", 10, 5, 400, 20)
GUICtrlSetColor($idHeader, 0x00FF00) ; Neon Green
GUICtrlSetBkColor($idHeader, $GUI_BKCOLOR_TRANSPARENT)

; Create a multi-line Edit control to act as our "Console" (Read-Only, Vertical Scrollbar)
Local $idConsole = GUICtrlCreateEdit("", 10, 30, 400, 190, BitOR($ES_READONLY, $WS_VSCROLL, $ES_AUTOVSCROLL))
GUICtrlSetBkColor($idConsole, 0x111111) ; Darker grey background
GUICtrlSetColor($idConsole, 0x33FF33)   ; Cyber green text
GUICtrlSetFont($idConsole, 9, 400, 0, "Consolas")

; Input box for variable change
Local $idLblInput = GUICtrlCreateLabel("> DATA STREAM:", 10, 233, 110, 20)
GUICtrlSetColor($idLblInput, 0x00FFFF) ; Cyan
GUICtrlSetBkColor($idLblInput, $GUI_BKCOLOR_TRANSPARENT)

Local $idInput = GUICtrlCreateInput("INITIATE_HANDSHAKE", 120, 230, 190, 22)
GUICtrlSetBkColor($idInput, 0x1A1A1A)
GUICtrlSetColor($idInput, 0x00FFFF) ; Cyan text

; Send and Close Buttons - Flat and Colored
Local $idBtnSend = GUICtrlCreateButton("TRANSMIT", 320, 230, 90, 22)
GUICtrlSetBkColor($idBtnSend, 0x004400)
GUICtrlSetColor($idBtnSend, 0x33FF33)

Local $idBtnFollow = GUICtrlCreateButton("CMD: FOLLOW", 120, 265, 90, 22)
GUICtrlSetBkColor($idBtnFollow, 0x004444)
GUICtrlSetColor($idBtnFollow, 0x00FFFF)

Local $idBtnWait = GUICtrlCreateButton("CMD: WAIT", 220, 265, 90, 22)
GUICtrlSetBkColor($idBtnWait, 0x444400)
GUICtrlSetColor($idBtnWait, 0xFFFF00)

Local $idBtnClose = GUICtrlCreateButton("ABORT", 320, 265, 90, 22)
GUICtrlSetBkColor($idBtnClose, 0x440000)
GUICtrlSetColor($idBtnClose, 0xFF3333)

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
            
        Case $iMsg = $idBtnFollow
            If $iSocket <> -1 Then
                TCPSend($iSocket, "Follow")
                GUICtrlSetData($idConsole, "[Command Sent] Follow" & @CRLF, 1)
            Else
                GUICtrlSetData($idConsole, "[Error] Not connected to server!" & @CRLF, 1)
            EndIf
            
        Case $iMsg = $idBtnWait
            If $iSocket <> -1 Then
                TCPSend($iSocket, "Wait")
                GUICtrlSetData($idConsole, "[Command Sent] Wait" & @CRLF, 1)
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
