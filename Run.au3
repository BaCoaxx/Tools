#include "GwAu3.au3"

; 2D Array: [FromMapID, ToMapID, "FunctionName"]
Global $g_aTravelRoute[15][3] = [ _
    [$GC_I_MAP_ID_ASCALON_CITY_OUTPOST, $GC_I_MAP_ID_FORT_RANIK_OUTPOST, "RunRanik"], _
    [$GC_I_MAP_ID_FORT_RANIK_OUTPOST, $GC_I_MAP_ID_RUINS_OF_SURMIA_OUTPOST, "RunSurmia"], _
    [$GC_I_MAP_ID_RUINS_OF_SURMIA_OUTPOST, $GC_I_MAP_ID_NOLANI_ACADEMY_OUTPOST, "RunNolani"], _
    [$GC_I_MAP_ID_NOLANI_ACADEMY_OUTPOST, $GC_I_MAP_ID_GRENDICH_COURTHOUSE, "RunGrendich"], _
    [$GC_I_MAP_ID_GRENDICH_COURTHOUSE, $GC_I_MAP_ID_PIKEN_SQUARE, "RunPiken"], _
    [$GC_I_MAP_ID_PIKEN_SQUARE, $GC_I_MAP_ID_YAKS_BEND, "RunYaks"], _
    [$GC_I_MAP_ID_YAKS_BEND, $GC_I_MAP_ID_FRONTIER_GATE, "RunFrontier"], _
    [$GC_I_MAP_ID_FRONTIER_GATE, $GC_I_MAP_ID_BEETLETUN, "RunBeetletun"], _
    [$GC_I_MAP_ID_BEETLETUN, $GC_I_MAP_ID_BERGEN_HOT_SPRINGS, "RunBergen"], _
    [$GC_I_MAP_ID_BERGEN_HOT_SPRINGS, $GC_I_MAP_ID_LIONS_ARCH, "RunLA"], _
    [$GC_I_MAP_ID_LIONS_ARCH, $GC_I_MAP_ID_TEMPLE_OF_THE_AGES, "RunTemple"], _
    [$GC_I_MAP_ID_TEMPLE_OF_THE_AGES, $GC_I_MAP_ID_CAMP_RANKOR, "RunRankor"], _
    [$GC_I_MAP_ID_CAMP_RANKOR, $GC_I_MAP_ID_THE_GRANITE_CITADEL, "RunGranite"], _
    [$GC_I_MAP_ID_THE_GRANITE_CITADEL, $GC_I_MAP_ID_MARHANS_GROTTO, "RunMarhan"], _
    [$GC_I_MAP_ID_MARHANS_GROTTO, $GC_I_MAP_ID_DROKNARS_FORGE, "RunDroks"] _
]

; Main travel route function with unlocked checks
Func TravelRoute()
    Out("=== Starting Travel Route Check ===")
    
    ; Check if first map is unlocked (starting location)
    Local $iFirstMap = $g_aTravelRoute[0][0]
    If Not Map_IsMapUnlocked($iFirstMap) Then
        Out("ERROR: Starting location not unlocked! Map ID: " & $iFirstMap)
        Out("Unable to start bot due to location error.")
        Return False
    EndIf
    
    Out("✓ Starting location unlocked: " & $iFirstMap)
    
    ; Loop through each step in the route
    For $i = 0 To UBound($g_aTravelRoute) - 1
        Local $iFromMap = $g_aTravelRoute[$i][0]
        Local $iToMap = $g_aTravelRoute[$i][1]
        Local $sFuncName = $g_aTravelRoute[$i][2]
        
        Out("")
        Out("=== Step " & ($i + 1) & "/" & UBound($g_aTravelRoute) & ": " & $sFuncName & " ===")
        Out("Checking: Map " & $iFromMap & " -> Map " & $iToMap)
        
        ; Check if FROM map is unlocked
        If Not Map_IsMapUnlocked($iFromMap) Then
            Out("ERROR: From map not unlocked! Map ID: " & $iFromMap)
            Out("Unable to start bot due to location error.")
            Return False
        EndIf
        Out("✓ From map unlocked: " & $iFromMap)
        
        ; Check if TO map is unlocked
        If Not Map_IsMapUnlocked($iToMap) Then
            Out("✗ Destination not unlocked: " & $iToMap)
            Out("Running function: " & $sFuncName)
            
            ; Map not unlocked - need to run the function
            Local $bSuccess = CallFunction($sFuncName, $iFromMap, $iToMap)
            
            If Not $bSuccess Then
                Out("ERROR: Failed to complete run: " & $sFuncName)
                Return False
            EndIf
            
            ; Verify the map is now unlocked
            If Not Map_IsMapUnlocked($iToMap) Then
                Out("ERROR: Map still not unlocked after run: " & $iToMap)
                Return False
            EndIf
            
            Out("✓ SUCCESS: Map now unlocked: " & $iToMap)
        Else
            Out("✓ Destination already unlocked: " & $iToMap)
            Out("Skipping run, traveling directly...")
            
            ; Map already unlocked - just travel there
            If Not TravelToMap($iToMap) Then
                Out("ERROR: Failed to travel to map: " & $iToMap)
                Return False
            EndIf
        EndIf
        
        Sleep(1000)
    Next
    
    Out("")
    Out("=== Route Complete! ===")
    Out("All maps unlocked and accessible!")
    Return True
EndFunc

; Function caller - routes to appropriate run function
Func CallFunction($sFuncName, $iFromMap, $iToMap)
    Out("Executing: " & $sFuncName & "()")
    
    ; Make sure we're in the correct starting map
    If Map_GetMapID() <> $iFromMap Then
        Out("Traveling to starting map: " & $iFromMap)
        If Not TravelToMap($iFromMap) Then
            Out("ERROR: Cannot travel to starting map: " & $iFromMap)
            Return False
        EndIf
    EndIf
    
    ; Call the appropriate function
    Local $bResult = False
    Switch $sFuncName
        Case "RunRanik"
            $bResult = RunRanik($iFromMap, $iToMap)
        Case "RunSurmia"
            $bResult = RunSurmia($iFromMap, $iToMap)
        Case "RunNolani"
            $bResult = RunNolani($iFromMap, $iToMap)
        Case "RunGrendich"
            $bResult = RunGrendich($iFromMap, $iToMap)
        Case "RunPiken"
            $bResult = RunPiken($iFromMap, $iToMap)
        Case "RunYaks"
            $bResult = RunYaks($iFromMap, $iToMap)
        Case "RunFrontier"
            $bResult = RunFrontier($iFromMap, $iToMap)
        Case "RunBeetletun"
            $bResult = RunBeetletun($iFromMap, $iToMap)
        Case "RunBergen"
            $bResult = RunBergen($iFromMap, $iToMap)
        Case "RunLA"
            $bResult = RunLA($iFromMap, $iToMap)
        Case "RunTemple"
            $bResult = RunTemple($iFromMap, $iToMap)
        Case "RunRankor"
            $bResult = RunRankor($iFromMap, $iToMap)
        Case "RunGranite"
            $bResult = RunGranite($iFromMap, $iToMap)
        Case "RunMarhan"
            $bResult = RunMarhan($iFromMap, $iToMap)
        Case "RunDroks"
            $bResult = RunDroks($iFromMap, $iToMap)
        Case Else
            Out("ERROR: Unknown function: " & $sFuncName)
            Return False
    EndSwitch
    
    Return $bResult
EndFunc

; Helper function to travel to a map
Func TravelToMap($iMapID)
    If Map_GetMapID() = $iMapID Then
        Out("Already at destination map: " & $iMapID)
        Return True
    EndIf
    
    If Not Map_IsMapUnlocked($iMapID) Then
        Out("Cannot travel - map not unlocked: " & $iMapID)
        Return False
    EndIf
    
    Out("Traveling to map: " & $iMapID)
    Return Map_TravelTo($iMapID)
EndFunc

; ========================================
; RUN FUNCTIONS (Template - customize each)
; ========================================

Func RunRanik($iFromMap, $iToMap)
    Out("Running Fort Ranik mission...")
    
    ; Enter explorable area
    Local $aPortal = Map_GetExitPortalCoords($iFromMap, $GC_I_MAP_ID_ASCALON_ACADEMY_EXPLORABLE)
    Map_Move($aPortal[0], $aPortal[1])
    Sleep(2000)
    Map_WaitMapLoading($GC_I_MAP_ID_ASCALON_ACADEMY_EXPLORABLE)
    
    ; TODO: Add navigation and mission logic here
    ; Navigate to Fort Ranik, complete mission
    
    ; For now, just travel (assumes mission completed)
    Sleep(5000) ; Simulate mission time
    Return TravelToMap($iToMap)
EndFunc

Func RunSurmia($iFromMap, $iToMap)
    Out("Running Ruins of Surmia mission...")
    ; TODO: Add mission logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunNolani($iFromMap, $iToMap)
    Out("Running Nolani Academy mission...")
    ; TODO: Add mission logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunGrendich($iFromMap, $iToMap)
    Out("Running to Grendich Courthouse...")
    
    ; Enter Old Ascalon
    Local $aPortal = Map_GetExitPortalCoords($iFromMap, $GC_I_MAP_ID_OLD_ASCALON)
    Map_Move($aPortal[0], $aPortal[1])
    Sleep(2000)
    Map_WaitMapLoading($GC_I_MAP_ID_OLD_ASCALON)
    
    ; TODO: Navigate to Grendich portal
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunPiken($iFromMap, $iToMap)
    Out("Running to Piken Square...")
    ; TODO: Add navigation logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunYaks($iFromMap, $iToMap)
    Out("Running to Yak's Bend...")
    ; TODO: Add navigation logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunFrontier($iFromMap, $iToMap)
    Out("Running to Frontier Gate...")
    ; TODO: Add navigation logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunBeetletun($iFromMap, $iToMap)
    Out("Running to Beetletun...")
    ; TODO: Add navigation logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunBergen($iFromMap, $iToMap)
    Out("Running to Bergen Hot Springs...")
    ; TODO: Add navigation logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunLA($iFromMap, $iToMap)
    Out("Running to Lion's Arch...")
    ; TODO: Add navigation logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunTemple($iFromMap, $iToMap)
    Out("Running to Temple of the Ages...")
    ; TODO: Add navigation logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunRankor($iFromMap, $iToMap)
    Out("Running to Camp Rankor...")
    ; TODO: Add navigation logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunGranite($iFromMap, $iToMap)
    Out("Running to Granite Citadel...")
    ; TODO: Add navigation logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunMarhan($iFromMap, $iToMap)
    Out("Running to Marhan's Grotto...")
    ; TODO: Add navigation logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

Func RunDroks($iFromMap, $iToMap)
    Out("Running to Droknar's Forge...")
    ; TODO: Add navigation logic
    Sleep(5000)
    Return TravelToMap($iToMap)
EndFunc

; ========================================
; MAIN EXECUTION
; ========================================

Core_Initialize("Your Character Name")
Sleep(2000)

; Start the route
If TravelRoute() Then
    Out("Bot started successfully!")
Else
    Out("Bot failed to start due to location requirements.")
EndIf