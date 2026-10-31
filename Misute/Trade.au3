#include-once

Global Const $TOT_MODEL_ECTO = 930
Global Const $TOT_MODEL_BAG = 28434
Global Const $TOT_STACK = 250
Global Const $TOT_LOW_STACKS = 10
Global Const $TOT_WAIT_MS = 60000

Global Const $g_ai_TotBags[4] = [$GC_I_INVENTORY_BACKPACK, $GC_I_INVENTORY_BELT_POUCH, $GC_I_INVENTORY_BAG1, $GC_I_INVENTORY_BAG2]
Global Const $g_ai_TotStorage[14] = [ _
    $GC_I_INVENTORY_STORAGE1, $GC_I_INVENTORY_STORAGE2, _
    $GC_I_INVENTORY_STORAGE3, $GC_I_INVENTORY_STORAGE4, _
    $GC_I_INVENTORY_STORAGE5, $GC_I_INVENTORY_STORAGE6, _
    $GC_I_INVENTORY_STORAGE7, $GC_I_INVENTORY_STORAGE8, _
    $GC_I_INVENTORY_STORAGE9, $GC_I_INVENTORY_STORAGE10, _
    $GC_I_INVENTORY_STORAGE11, $GC_I_INVENTORY_STORAGE12, _
    $GC_I_INVENTORY_STORAGE13, $GC_I_INVENTORY_STORAGE14]

Global $g_i_TotRestockFloor = -1
Global $g_i_TotAdvert = 0

Func Tot_Run()
    If Not StoC_WatchTrade() Then
        LogError("Could not watch trades.")
        $BotRunning = False
        Return
    EndIf

    Trade_InitTradePartner()
    $g_i_EctoPerStack = Number(GUICtrlRead($g_hPriceSlider))
    If $g_i_EctoPerStack < 1 Then $g_i_EctoPerStack = 1
    $g_i_TotAdvert = 0
    LogInfo("Waiting for a trade.")
    Local $l_i_RestockCheck = 0

    While $BotRunning
        Tot_Advert()
        If TimerDiff($l_i_RestockCheck) > 1000 Then
            $l_i_RestockCheck = TimerInit()
            Local $l_i_Stacks = Tot_FullStacks()
            If $l_i_Stacks < $TOT_LOW_STACKS And $l_i_Stacks <> $g_i_TotRestockFloor Then
                If Not Tot_Restock() Then ExitLoop
                $g_i_TotRestockFloor = Tot_FullStacks()
                If $g_i_TotRestockFloor >= $TOT_LOW_STACKS Then $g_i_TotRestockFloor = -1
            EndIf
        EndIf
        If Not $BotRunning Then ExitLoop

        Local $l_i_Partner = Trade_GetTradePartner()
        If $l_i_Partner = 0 Then
            StoC_UpdateTrade()
            Sleep(100)
            ContinueLoop
        EndIf

        LogInfo("Player " & $l_i_Partner & " requested a trade.")
        Tot_RunSession($l_i_Partner)
        Trade_InitTradePartner()
        If $BotRunning Then Tot_Pause()
        $l_i_RestockCheck = 0
        If $BotRunning Then LogInfo("Waiting for a trade.")
    WEnd

    Tot_EndSession()
    StoC_UnwatchTrade()
EndFunc

Func Tot_RunSession($a_i_PlayerNumber)
    StoC_UpdateTrade()
    _StoC_ResetTrade()

    Local $l_i_Price = Number(GUICtrlRead($g_hPriceSlider))
    If $l_i_Price < 1 Then $l_i_Price = 1
    If $l_i_Price > 10 Then $l_i_Price = 10
    $g_i_EctoPerStack = $l_i_Price

    Local $l_i_Agent = Tot_PartnerAgent($a_i_PlayerNumber)
    If $l_i_Agent = 0 Then
        LogWarn("Could not find the player who requested the trade.")
        Return
    EndIf

    LogInfo("Opening the trade at " & $l_i_Price & " ecto(s) per stack.")
    If Not Tot_Pause() Then Return
    Trade_InitiateTrade($l_i_Agent)
    If Not Tot_WaitActive() Then
        LogWarn("Trade window did not open.")
        Tot_EndSession()
        Return
    EndIf

    LogInfo("Waiting for their ectos.")
    Local $l_i_Ectos = Tot_WaitForOffer()
    If $l_i_Ectos < 0 Then
        Tot_EndSession()
        Return
    EndIf

    Local $l_i_Stacks = Tot_StacksForEctos($l_i_Ectos, $l_i_Price)
    If $l_i_Stacks < 1 Then
        LogInfo("Their ectos do not match " & $l_i_Price & " per stack. Cancelling.")
        Tot_EndSession()
        Return
    EndIf
    If Tot_FullStacks() < $l_i_Stacks Then
        LogWarn("Not enough Trick or Treat stacks for " & $l_i_Ectos & " ecto(s). Cancelling.")
        Tot_EndSession()
        Return
    EndIf

    If Not Tot_Pause() Then
        Tot_EndSession()
        Return
    EndIf
    Local $l_i_Offered = Tot_OfferStacks($l_i_Stacks)
    If $l_i_Offered <> $l_i_Stacks Then
        LogWarn("Could not place " & $l_i_Stacks & " stack(s). Cancelling.")
        Tot_EndSession()
        Return
    EndIf
    If Not Tot_Pause() Then
        Tot_EndSession()
        Return
    EndIf
    If Not Trade_SubmitOffer(0) Or Not Tot_WaitOurSubmit() Then
        LogWarn("Could not submit the offer.")
        Tot_EndSession()
        Return
    EndIf
    LogInfo("Offered " & $l_i_Offered & " stack(s).")

    StoC_UpdateTrade()
    If Not StoC_GetTradeInfo("PartnerSubmitted") Then
        LogInfo("Waiting for them to submit again.")
        $l_i_Ectos = Tot_WaitForOffer()
        If $l_i_Ectos < 0 Then
            Tot_EndSession()
            Return
        EndIf
    EndIf

    If Not Tot_Pause() Then
        Tot_EndSession()
        Return
    EndIf
    StoC_UpdateTrade()
    If Not $BotRunning Or Not Tot_SessionOpen() Then
        Tot_EndSession()
        Return
    EndIf
    If StoC_GetTradeInfo("Result") = $GC_I_STOC_TRADE_ACK_CANCELLED Then
        LogInfo("Trade cancelled.")
        Tot_EndSession()
        Return
    EndIf
    If Not StoC_GetTradeInfo("PartnerSubmitted") Or Not Trade_GetTradeInfo("IsSubmitted") Then
        LogInfo("The offer was taken back before accept.")
        Tot_EndSession()
        Return
    EndIf
    If Not Tot_OfferMatches($l_i_Price) Then
        LogInfo("Ectos do not match the Trick or Treat stacks. Cancelling.")
        Tot_EndSession()
        Return
    EndIf

    If Not Trade_AcceptTrade() Then
        LogWarn("Could not accept the trade.")
        Tot_EndSession()
        Return
    EndIf
    LogInfo("Accepted. Waiting for them to finish.")
    Tot_WaitFinished()
EndFunc

Func Tot_PartnerAgent($a_i_PlayerNumber)
    Local $l_a_Agents = Agent_GetAgentArray($GC_I_AGENT_TYPE_LIVING)
    For $l_i_Idx = 1 To $l_a_Agents[0]
        If Not Agent_GetAgentInfo($l_a_Agents[$l_i_Idx], "IsPlayer") Then ContinueLoop
        If Agent_GetAgentInfo($l_a_Agents[$l_i_Idx], "PlayerNumber") <> $a_i_PlayerNumber Then ContinueLoop
        Return Agent_GetAgentInfo($l_a_Agents[$l_i_Idx], "ID")
    Next
    If Agent_GetAgentInfo($a_i_PlayerNumber, "IsPlayer") Then Return $a_i_PlayerNumber
    Return 0
EndFunc

Func Tot_WaitActive()
    Local $l_i_Timer = TimerInit()
    While $BotRunning And TimerDiff($l_i_Timer) < 5000
        StoC_UpdateTrade()
        If StoC_GetTradeInfo("Result") = $GC_I_STOC_TRADE_ACK_CANCELLED Then Return False
        If BitAND(Trade_GetTradeInfo("Flags"), $GC_I_TRADE_FLAG_ACTIVE) And Not Trade_GetTradeInfo("IsBusy") Then Return True
        Sleep(50)
    WEnd
    Return False
EndFunc

Func Tot_OfferStacks($a_i_Stacks)
    Local $l_ai_Stacks = Tot_ListItems($TOT_MODEL_BAG, $TOT_STACK)
    If $l_ai_Stacks[0] < $a_i_Stacks Then Return 0

    Local $l_i_Offered = 0
    For $l_i_Idx = 1 To $a_i_Stacks
        If $l_i_Offered > 0 And Not Tot_Pause() Then Return $l_i_Offered
        If Not Trade_OfferItem($l_ai_Stacks[$l_i_Idx], $TOT_STACK) Then Return $l_i_Offered
        $l_i_Offered += 1
    Next
    Return $l_i_Offered
EndFunc

; -1: session already ending. -2: caller should cancel.
Func Tot_WaitForOffer()
    Local $l_i_Timer = TimerInit()
    While $BotRunning And TimerDiff($l_i_Timer) < $TOT_WAIT_MS
        StoC_UpdateTrade()
        Tot_Advert()
        Local $l_i_Result = StoC_GetTradeInfo("Result")
        If $l_i_Result = $GC_I_STOC_TRADE_ACK_CANCELLED Then
            LogInfo("Trade cancelled.")
            Return -1
        EndIf
        If $l_i_Result = $GC_I_STOC_TRADE_ACK_EXECUTED Or Not Tot_SessionOpen() Then
            LogInfo("Trade closed.")
            Return -1
        EndIf
        If StoC_GetTradeInfo("PartnerSubmitted") Then
            Local $l_i_Expected = StoC_GetTradeInfo("PartnerItems")
            Local $l_i_ItemsTimer = TimerInit()
            While $BotRunning And TimerDiff($l_i_ItemsTimer) < 1000
                If Trade_GetTradeInfo("PartnerItemCount") >= $l_i_Expected Then ExitLoop
                StoC_UpdateTrade()
                Sleep(20)
            WEnd
            If StoC_GetTradeInfo("Result") = $GC_I_STOC_TRADE_ACK_CANCELLED Then
                LogInfo("Trade cancelled.")
                Return -1
            EndIf
            Local $l_i_Ectos = Tot_ReadEctos()
            If $l_i_Ectos < 0 Then
                LogInfo("Their offer is not ectos only.")
                Return -2
            EndIf
            LogInfo("They offered " & $l_i_Ectos & " ecto(s).")
            Return $l_i_Ectos
        EndIf
        Sleep(50)
    WEnd
    If Not $BotRunning Then Return -1
    LogInfo("Timed out waiting for their offer.")
    Return -2
EndFunc

Func Tot_ReadEctos()
    Local $l_i_Count = Trade_GetTradeInfo("PartnerItemCount")
    Local $l_i_Ectos = 0
    For $l_i_Slot = 0 To $l_i_Count - 1
        If Trade_GetPartnerTradeItemsInfo($l_i_Slot, "ModelID") <> $TOT_MODEL_ECTO Then Return -1
        $l_i_Ectos += Trade_GetPartnerTradeItemsInfo($l_i_Slot, "Quantity")
    Next
    Return $l_i_Ectos
EndFunc

Func Tot_StacksForEctos($a_i_Ectos, $a_i_Price)
    If $a_i_Price < 1 Or $a_i_Ectos < 1 Then Return 0
    If Mod($a_i_Ectos, $a_i_Price) <> 0 Then Return 0
    Return Int($a_i_Ectos / $a_i_Price)
EndFunc

Func Tot_OurBagStacks()
    Local $l_i_Count = Trade_GetTradeInfo("PlayerItemCount")
    If $l_i_Count < 1 Then Return 0

    Local $l_i_Bags = 0
    For $l_i_Slot = 0 To $l_i_Count - 1
        If Trade_GetPlayerTradeItemsInfo($l_i_Slot, "ModelID") <> $TOT_MODEL_BAG Then Return -1
        If Trade_GetPlayerTradeItemsInfo($l_i_Slot, "Quantity") <> $TOT_STACK Then Return -1
        $l_i_Bags += 1
    Next
    Return $l_i_Bags
EndFunc

Func Tot_OfferMatches($a_i_Price)
    Local $l_i_Ectos = Tot_ReadEctos()
    Local $l_i_Bags = Tot_OurBagStacks()
    If $l_i_Ectos < 1 Or $l_i_Bags < 1 Or $a_i_Price < 1 Then Return False
    Return $l_i_Ectos = $l_i_Bags * $a_i_Price
EndFunc

Func Tot_WaitOurSubmit()
    Local $l_i_Timer = TimerInit()
    While $BotRunning And TimerDiff($l_i_Timer) < 3000
        If Trade_GetTradeInfo("IsSubmitted") Then Return True
        Sleep(20)
    WEnd
    Return False
EndFunc

Func Tot_WaitFinished()
    Local $l_i_Timer = TimerInit()
    While $BotRunning And TimerDiff($l_i_Timer) < $TOT_WAIT_MS
        StoC_UpdateTrade()
        Tot_Advert()
        Local $l_i_Result = StoC_GetTradeInfo("Result")
        If $l_i_Result = $GC_I_STOC_TRADE_ACK_EXECUTED Then
            LogInfo("Trade completed.")
            Return
        EndIf
        If $l_i_Result = $GC_I_STOC_TRADE_ACK_CANCELLED Or Not Tot_SessionOpen() Then
            LogInfo("Trade closed.")
            Return
        EndIf
        Sleep(50)
    WEnd
    If $BotRunning Then LogInfo("Timed out waiting for the trade to finish.")
    Tot_EndSession()
EndFunc

Func Tot_Pause()
    Local $l_i_Wait = Random(1000, 3000, 1)
    Local $l_i_Timer = TimerInit()
    While $BotRunning And TimerDiff($l_i_Timer) < $l_i_Wait
        StoC_UpdateTrade()
        Tot_Advert()
        Sleep(50)
    WEnd
    Return $BotRunning
EndFunc

Func Tot_Advert()
    If Not $BotRunning Or TimerDiff($g_i_TotAdvert) < 120000 Then Return
    $g_i_TotAdvert = TimerInit()
    Chat_SendChat("WTS ToT Bags - " & $g_i_EctoPerStack & "e/stk.", "$")
EndFunc

Func Tot_SessionOpen()
    Return BitAND(Trade_GetTradeInfo("Flags"), $GC_I_TRADE_FLAG_ACTIVE) <> 0
EndFunc

Func Tot_EndSession()
    If StoC_GetTradeInfo("Result") = $GC_I_STOC_TRADE_ACK_EXECUTED Then Return
    If Not Tot_SessionOpen() Then Return
    Trade_CancelTrade()
EndFunc

Func Tot_FullStacks()
    Local $l_ai_Stacks = Tot_ListItems($TOT_MODEL_BAG, $TOT_STACK)
    Return $l_ai_Stacks[0]
EndFunc

Func Tot_ListItems($a_i_Model, $a_i_MinQty)
    Local $l_av_Items = Item_GetInventoryArray()
    Local $l_ai_Ids[UBound($l_av_Items) + 1]
    Local $l_i_Count = 0
    For $l_i_Idx = 0 To UBound($l_av_Items) - 1
        If $l_av_Items[$l_i_Idx][$GC_I_INVENTORY_MODELID] <> $a_i_Model Then ContinueLoop
        If $l_av_Items[$l_i_Idx][$GC_I_INVENTORY_QUANTITY] < $a_i_MinQty Then ContinueLoop
        $l_i_Count += 1
        $l_ai_Ids[$l_i_Count] = $l_av_Items[$l_i_Idx][$GC_I_INVENTORY_ITEMID]
    Next
    $l_ai_Ids[0] = $l_i_Count
    ReDim $l_ai_Ids[$l_i_Count + 1]
    Return $l_ai_Ids
EndFunc

Func Tot_Restock()
    LogInfo("Fewer than " & $TOT_LOW_STACKS & " Trick or Treat stacks. Opening the Xunlai chest.")
    Ui_Xunlai()

    Local $l_i_Timer = TimerInit()
    Local $l_b_Readable = False
    While Not $l_b_Readable And TimerDiff($l_i_Timer) < 3000
        For $l_i_Idx = 0 To UBound($g_ai_TotStorage) - 1
            If Item_GetBagInfo($g_ai_TotStorage[$l_i_Idx], "Slots") > 0 Then
                $l_b_Readable = True
                ExitLoop
            EndIf
        Next
        If Not $l_b_Readable Then Sleep(100)
    WEnd

    If Not $l_b_Readable Then
        LogWarn("Could not read the Xunlai chest.")
    Else
        Tot_Pause()
        Tot_StoreEctos()
        If $BotRunning Then Tot_WithdrawBags()
    EndIf

    Local $l_ai_Fill = Tot_BagFill()
    If $l_ai_Fill[1] = 0 Or $l_ai_Fill[0] * 2 < $l_ai_Fill[1] Then
        If GUICtrlRead($g_hKeepRunning) = $GUI_CHECKED Then
            LogWarn("Trick or Treat bags fill less than half the inventory. Keep running is on.")
        Else
            LogWarn("Trick or Treat bags fill less than half the inventory. Pausing.")
            $BotRunning = False
            Return False
        EndIf
    EndIf
    If Not $BotRunning Then Return False
    LogInfo("Trick or Treat stacks in inventory: " & Tot_FullStacks())
    Return True
EndFunc

Func Tot_StoreEctos()
    Local $l_ai_Ectos = Tot_ListItems($TOT_MODEL_ECTO, 1)
    For $l_i_Idx = 1 To $l_ai_Ectos[0]
        If Not $BotRunning Then Return
        Local $l_i_Item = $l_ai_Ectos[$l_i_Idx]
        Local $l_i_Qty = Item_GetItemInfoByItemID($l_i_Item, "Quantity")
        Local $l_i_Tries = 0

        While $l_i_Qty > 0 And $l_i_Tries < 30
            $l_i_Tries += 1
            Local $l_ai_Partial = Tot_BestEctoSlot()
            If $l_ai_Partial[0] = 0 Then ExitLoop
            Local $l_i_Move = $l_i_Qty
            If $l_i_Move > $l_ai_Partial[2] Then $l_i_Move = $l_ai_Partial[2]
            Local $l_i_Before = $l_i_Qty
            Item_MoveItem_($l_i_Item, $l_ai_Partial[0], $l_ai_Partial[1], $l_i_Move)
            Tot_Pause()
            If Not Tot_InInventory($l_i_Item) Then
                $l_i_Qty = 0
                ExitLoop
            EndIf
            $l_i_Qty = Item_GetItemInfoByItemID($l_i_Item, "Quantity")
            If $l_i_Qty = $l_i_Before Then
                LogWarn("Could not stack ectos into storage.")
                ExitLoop
            EndIf
        WEnd

        If $l_i_Qty < 1 Then ContinueLoop
        Local $l_ai_Empty = Tot_EmptySlot($g_ai_TotStorage)
        If $l_ai_Empty[0] = 0 Then
            LogWarn("No storage space left for ectos.")
            Return
        EndIf
        Item_MoveItem($l_i_Item, $l_ai_Empty[0], $l_ai_Empty[1])
        Tot_Pause()
        If Item_GetItemBySlot($l_ai_Empty[0], $l_ai_Empty[1]) = 0 Then
            LogWarn("Could not move ectos into storage.")
            Return
        EndIf
    Next
EndFunc

Func Tot_WithdrawBags()
    Local $l_av_Storage = Item_GetStorageArray()
    For $l_i_Idx = 0 To UBound($l_av_Storage) - 1
        If Not $BotRunning Then Return
        If $l_av_Storage[$l_i_Idx][$GC_I_INVENTORY_MODELID] <> $TOT_MODEL_BAG Then ContinueLoop
        Local $l_ai_Empty = Tot_EmptySlot($g_ai_TotBags)
        If $l_ai_Empty[0] = 0 Then Return
        Item_MoveItem($l_av_Storage[$l_i_Idx][$GC_I_INVENTORY_ITEMID], $l_ai_Empty[0], $l_ai_Empty[1])
        Tot_Pause()
        If Item_GetItemBySlot($l_ai_Empty[0], $l_ai_Empty[1]) = 0 Then
            LogWarn("Could not move Trick or Treat bags out of storage.")
            Return
        EndIf
    Next
EndFunc

Func Tot_InInventory($a_i_Item)
    Local $l_p_Item = Item_GetItemPtr($a_i_Item)
    If $l_p_Item = 0 Then Return False
    Local $l_p_Bag = Item_GetItemInfoByPtr($l_p_Item, "Bag")
    If $l_p_Bag = 0 Then Return False
    For $l_i_Idx = 0 To UBound($g_ai_TotBags) - 1
        If Item_GetBagPtr($g_ai_TotBags[$l_i_Idx]) = $l_p_Bag Then Return True
    Next
    Return False
EndFunc

Func Tot_BestEctoSlot()
    Local $l_i_Bag = 0
    Local $l_i_Slot = 0
    Local $l_i_Room = $TOT_STACK
    For $l_i_BagIdx = 0 To UBound($g_ai_TotStorage) - 1
        Local $l_i_Slots = Item_GetBagInfo($g_ai_TotStorage[$l_i_BagIdx], "Slots")
        For $l_i_TrySlot = 1 To $l_i_Slots
            Local $l_p_Item = Item_GetItemBySlot($g_ai_TotStorage[$l_i_BagIdx], $l_i_TrySlot)
            If $l_p_Item = 0 Then ContinueLoop
            If Item_GetItemInfoByPtr($l_p_Item, "ModelID") <> $TOT_MODEL_ECTO Then ContinueLoop
            Local $l_i_Qty = Item_GetItemInfoByPtr($l_p_Item, "Quantity")
            If $l_i_Qty < 1 Or $l_i_Qty >= $TOT_STACK Then ContinueLoop
            Local $l_i_ThisRoom = $TOT_STACK - $l_i_Qty
            If $l_i_ThisRoom < $l_i_Room Then
                $l_i_Room = $l_i_ThisRoom
                $l_i_Bag = $g_ai_TotStorage[$l_i_BagIdx]
                $l_i_Slot = $l_i_TrySlot
            EndIf
        Next
    Next
    Local $l_ai_Slot[3] = [$l_i_Bag, $l_i_Slot, $l_i_Room]
    Return $l_ai_Slot
EndFunc

Func Tot_EmptySlot($a_ai_Bags)
    For $l_i_Idx = 0 To UBound($a_ai_Bags) - 1
        Local $l_i_Slots = Item_GetBagInfo($a_ai_Bags[$l_i_Idx], "Slots")
        For $l_i_Slot = 1 To $l_i_Slots
            If Item_GetItemBySlot($a_ai_Bags[$l_i_Idx], $l_i_Slot) = 0 Then
                Local $l_ai_Empty[2] = [$a_ai_Bags[$l_i_Idx], $l_i_Slot]
                Return $l_ai_Empty
            EndIf
        Next
    Next
    Local $l_ai_None[2] = [0, 0]
    Return $l_ai_None
EndFunc

Func Tot_BagFill()
    Local $l_i_Bags = 0
    Local $l_i_Total = 0
    For $l_i_Idx = 0 To UBound($g_ai_TotBags) - 1
        Local $l_i_Slots = Item_GetBagInfo($g_ai_TotBags[$l_i_Idx], "Slots")
        $l_i_Total += $l_i_Slots
        For $l_i_Slot = 1 To $l_i_Slots
            Local $l_p_Item = Item_GetItemBySlot($g_ai_TotBags[$l_i_Idx], $l_i_Slot)
            If $l_p_Item = 0 Then ContinueLoop
            If Item_GetItemInfoByPtr($l_p_Item, "ModelID") = $TOT_MODEL_BAG Then $l_i_Bags += 1
        Next
    Next
    Local $l_ai_Fill[2] = [$l_i_Bags, $l_i_Total]
    Return $l_ai_Fill
EndFunc
