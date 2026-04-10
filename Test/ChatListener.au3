#include-once

Global $g_i_ChatListener_ArrayOffset = -1
Global $g_p_ChatListener_ArrayBase = 0
Global $g_i_ChatListener_ArraySize = 0
Global $g_s_ChatListener_LastMessage = ""

Func ChatListener_Reset()
    $g_i_ChatListener_ArrayOffset = -1
    $g_p_ChatListener_ArrayBase = 0
    $g_i_ChatListener_ArraySize = 0
    $g_s_ChatListener_LastMessage = ""
EndFunc

Func ChatListener_GetLatestMessage($a_i_Lookback = 30)
    If $g_p_ChatListener_ArrayBase = 0 Or $g_i_ChatListener_ArraySize <= 0 Then
        If Not ChatListener_FindMessageArray() Then Return ""
    EndIf

    Local $l_i_Size = $g_i_ChatListener_ArraySize
    Local $l_i_Min = $l_i_Size - $a_i_Lookback
    If $l_i_Min < 0 Then $l_i_Min = 0

    For $i = $l_i_Size - 1 To $l_i_Min Step -1
        Local $l_p_Entry = Memory_Read($g_p_ChatListener_ArrayBase + ($i * 4), "ptr")
        If $l_p_Entry = 0 Then ContinueLoop

        Local $l_s_Message = ChatListener_FindTextInStruct($l_p_Entry)
        If $l_s_Message = "" Then ContinueLoop

        $l_s_Message = StringStripWS($l_s_Message, 3)
        If $l_s_Message = "" Then ContinueLoop
        If $l_s_Message = $g_s_ChatListener_LastMessage Then ContinueLoop

        $g_s_ChatListener_LastMessage = $l_s_Message
        Return $l_s_Message
    Next

    Return ""
EndFunc

Func ChatListener_FindMessageArray()
    Local $l_p_World = World_GetWorldContextPtr()
    If $l_p_World = 0 Then Return False

    Local $l_i_BestScore = 0
    Local $l_p_BestBase = 0
    Local $l_i_BestSize = 0
    Local $l_i_BestOffset = -1

    For $l_i_Off = 0 To 0x900 Step 4
        Local $l_a_Candidate1 = ChatListener_TryArrayInline($l_p_World + $l_i_Off)
        If IsArray($l_a_Candidate1) Then
            If $l_a_Candidate1[2] > $l_i_BestScore Then
                $l_p_BestBase = $l_a_Candidate1[0]
                $l_i_BestSize = $l_a_Candidate1[1]
                $l_i_BestScore = $l_a_Candidate1[2]
                $l_i_BestOffset = $l_i_Off
            EndIf
        EndIf

        Local $l_a_Candidate2 = ChatListener_TryArrayPtr($l_p_World + $l_i_Off)
        If IsArray($l_a_Candidate2) Then
            If $l_a_Candidate2[2] > $l_i_BestScore Then
                $l_p_BestBase = $l_a_Candidate2[0]
                $l_i_BestSize = $l_a_Candidate2[1]
                $l_i_BestScore = $l_a_Candidate2[2]
                $l_i_BestOffset = $l_i_Off
            EndIf
        EndIf
    Next

    If $l_p_BestBase = 0 Or $l_i_BestSize <= 0 Then Return False

    $g_p_ChatListener_ArrayBase = $l_p_BestBase
    $g_i_ChatListener_ArraySize = $l_i_BestSize
    $g_i_ChatListener_ArrayOffset = $l_i_BestOffset
    Return True
EndFunc

Func ChatListener_TryArrayInline($a_p_ArrayHeader)
    Local $l_p_Base = Memory_Read($a_p_ArrayHeader, "ptr")
    Local $l_i_Size = Memory_Read($a_p_ArrayHeader + 0x8, "long")
    Return ChatListener_ScoreArray($l_p_Base, $l_i_Size)
EndFunc

Func ChatListener_TryArrayPtr($a_p_PtrToHeader)
    Local $l_p_Header = Memory_Read($a_p_PtrToHeader, "ptr")
    If $l_p_Header = 0 Then Return 0
    Local $l_p_Base = Memory_Read($l_p_Header, "ptr")
    Local $l_i_Size = Memory_Read($l_p_Header + 0x8, "long")
    Return ChatListener_ScoreArray($l_p_Base, $l_i_Size)
EndFunc

Func ChatListener_ScoreArray($a_p_Base, $a_i_Size)
    If $a_p_Base = 0 Then Return 0
    If $a_i_Size <= 0 Or $a_i_Size > 512 Then Return 0

    Local $l_i_TextHits = 0
    Local $l_i_NonZero = 0
    Local $l_i_Check = $a_i_Size
    If $l_i_Check > 12 Then $l_i_Check = 12

    For $i = 0 To $l_i_Check - 1
        Local $l_p_Entry = Memory_Read($a_p_Base + ($i * 4), "ptr")
        If $l_p_Entry = 0 Then ContinueLoop
        $l_i_NonZero += 1

        Local $l_s_Text = ChatListener_FindTextInStruct($l_p_Entry)
        If $l_s_Text <> "" Then $l_i_TextHits += 1
    Next

    If $l_i_NonZero = 0 Then Return 0
    If $l_i_TextHits = 0 Then Return 0

    Local $l_a_Result[3] = [$a_p_Base, $a_i_Size, ($l_i_TextHits * 100) + $l_i_NonZero]
    Return $l_a_Result
EndFunc

Func ChatListener_FindTextInStruct($a_p_Struct)
    For $l_i_Off = 0 To 0x80 Step 4
        Local $l_p_Str = Memory_Read($a_p_Struct + $l_i_Off, "ptr")
        If $l_p_Str = 0 Then ContinueLoop

        Local $l_s = Memory_Read($l_p_Str, "wchar[256]")
        If ChatListener_IsProbablyText($l_s) Then
            Return $l_s
        EndIf
    Next

    Return ""
EndFunc

Func ChatListener_IsProbablyText($a_s)
    If Not IsString($a_s) Then Return False
    $a_s = StringStripWS($a_s, 3)
    If StringLen($a_s) < 3 Then Return False
    If StringRegExp($a_s, "[A-Za-z]{3,}") Then Return True
    Return False
EndFunc

