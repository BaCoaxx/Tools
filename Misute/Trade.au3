#include-once

; The item being sold. Set from the GUI dropdown ($g_av_TotItems in Misute.au3) on Start.
Global $g_s_TotItemName = $g_av_TotItems[0][0]
Global $g_i_TotModel = $g_av_TotItems[0][1]
Global $g_s_TotAdvertName = $g_av_TotItems[0][2]
Global $g_i_TotLotSize = Tot_ValidLotSize($g_av_TotItems[0][3]) ; how many items the price buys
; What the buyer pays with. Set from the GUI dropdown ($g_av_TotCurrencies in Misute.au3).
Global $g_s_TotCurName = $g_av_TotCurrencies[0][0]
Global $g_i_TotCurModel = $g_av_TotCurrencies[0][1] ; 0 = gold
Global $g_s_TotCurShort = $g_av_TotCurrencies[0][2]
Global Const $TOT_MAX_GOLD = 100000 ; most gold a character can hold or trade
Global Const $TOT_STACK = 250
Global Const $TOT_LOW_STACKS = 10
Global Const $TOT_WAIT_MS = 60000
Global Const $TOT_MAX_TRADE_STACKS = 7 ; trade window item slots
Global Const $TOT_MAX_STRIKES = 3         ; failed trades in a row before a cooldown
Global Const $TOT_COOLDOWN_MS = 300000    ; 5 minutes

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
Global $g_b_TotRestockCut = False
Global $g_b_TotRestocking = False
Global $g_s_TotPartnerName = ""
Global $g_i_TotOutcome = 0 ; 0 = no fault, 1 = sold, 2 = their trade fell through
Global $g_i_TotSales = 0
Global $g_o_TotEarned = ObjCreate("Scripting.Dictionary") ; currency name -> amount
Tot_ApplyChoices() ; labels match the default picks
Global $g_o_TotStrikes = ObjCreate("Scripting.Dictionary")
Global $g_o_TotBlocked = ObjCreate("Scripting.Dictionary")
Global $g_s_TotLastIgnored = ""

Func Tot_Run()
    If Not StoC_WatchTrade() Then
        LogError("Could not watch trades.")
        $BotRunning = False
        Return
    EndIf

    Trade_InitTradePartner()
    StoC_UpdateTrade()
    _StoC_ResetTrade()
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
                If $g_b_TotRestockCut Then
                    ; Restock was cut short for a trade. Retry it once the trade is done.
                    $g_i_TotRestockFloor = -1
                Else
                    $g_i_TotRestockFloor = Tot_FullStacks()
                    If $g_i_TotRestockFloor >= $TOT_LOW_STACKS Then $g_i_TotRestockFloor = -1
                EndIf
            EndIf
        EndIf
        If Not $BotRunning Then ExitLoop

        Local $l_i_Partner = Trade_GetTradePartner()
        If $l_i_Partner = 0 Then
            StoC_UpdateTrade()
            Sleep(100)
            ContinueLoop
        EndIf

        If $g_s_TotLastIgnored = "" Then LogInfo("Player " & $l_i_Partner & " requested a trade.")
        Tot_RunSession($l_i_Partner)
        Tot_RecordOutcome()
        Trade_InitTradePartner()
        If $BotRunning Then Tot_Pause()
        ; Clear the finished trade here, not when the next one opens. A player can
        ; offer and submit while we restock, and that submit must survive.
        StoC_UpdateTrade()
        _StoC_ResetTrade()
        $l_i_RestockCheck = 0
        If $BotRunning Then LogInfo("Waiting for a trade.")
    WEnd

    Tot_EndSession()
    StoC_UnwatchTrade()
EndFunc

Func Tot_RunSession($a_i_PlayerNumber)
    ; Only reset if a stale result is left over (e.g. someone cancelled while we restocked).
    ; Otherwise keep the state, so an offer they already submitted is not wiped.
    StoC_UpdateTrade()
    Local $l_i_Stale = StoC_GetTradeInfo("Result")
    If $l_i_Stale = $GC_I_STOC_TRADE_ACK_CANCELLED Or $l_i_Stale = $GC_I_STOC_TRADE_ACK_EXECUTED Then
        _StoC_ResetTrade()
    ElseIf StoC_GetTradeInfo("PartnerSubmitted") Then
        LogInfo("They already submitted before the window opened.")
    EndIf

    Local $l_i_Price = $g_i_TotPrice

    $g_i_TotOutcome = 0
    $g_s_TotPartnerName = ""
    Local $l_i_Agent = Tot_PartnerAgent($a_i_PlayerNumber)
    If $l_i_Agent = 0 Then
        LogWarn("Could not find the player who requested the trade.")
        Return
    EndIf
    $g_s_TotPartnerName = Agent_GetPlayerInfo($l_i_Agent, "Name")

    If Tot_IsBlocked($g_s_TotPartnerName) Then
        If $g_s_TotLastIgnored <> $g_s_TotPartnerName Then
            LogInfo("Ignoring " & $g_s_TotPartnerName & " for a few minutes after repeated failed trades.")
            $g_s_TotLastIgnored = $g_s_TotPartnerName
        EndIf
        Trade_CancelTrade()
        Return
    EndIf
    $g_s_TotLastIgnored = ""

    LogInfo("Opening the trade at " & Tot_Amount($l_i_Price) & " " & Tot_PerLot() & ".")
    If Not Tot_Pause() Then Return
    Trade_InitiateTrade($l_i_Agent)
    If Not Tot_WaitActive() Then
        LogWarn("Trade window did not open.")
        Tot_EndSession()
        Return
    EndIf
    $g_i_TotOutcome = 2 ; from here, anything short of a sale counts against them unless it is our fault

    LogInfo("Waiting for their " & $g_s_TotCurName & ".")
    Local $l_i_Ectos = Tot_WaitForOffer()
    If $l_i_Ectos < 0 Then
        Tot_EndSession()
        Return
    EndIf

    Local $l_i_Stacks = Tot_StacksForEctos($l_i_Ectos, $l_i_Price)
    If $l_i_Stacks < 1 Then
        LogInfo("Their " & $g_s_TotCurName & " does not match " & Tot_Amount($l_i_Price) & " " & Tot_PerLot() & ". Cancelling.")
        Tot_Tell("Price is " & Tot_Amount($l_i_Price) & " " & Tot_PerLot() & ", so please offer a multiple of " & Tot_Amount($l_i_Price) & ".")
        Tot_EndSession()
        Return
    EndIf
    If $l_i_Stacks > Tot_MaxLots() Then
        LogInfo(Tot_Amount($l_i_Ectos) & " is " & $l_i_Stacks * $g_i_TotLotSize & " items, over the " & Tot_MaxLots() * $g_i_TotLotSize & "-item trade limit. Cancelling.")
        Tot_Tell("Max " & Tot_MaxLots() * $g_i_TotLotSize & " per trade (" & Tot_Amount(Tot_MaxLots() * $l_i_Price) & "). Trade me again for more.")
        Tot_EndSession()
        Return
    EndIf
    If Tot_FullStacks() < $l_i_Stacks Then
        LogWarn("Not enough " & $g_s_TotItemName & " for " & Tot_Amount($l_i_Ectos) & ". Cancelling.")
        Tot_Tell("Sorry, only " & Tot_FullStacks() * $g_i_TotLotSize & " in stock right now. Try a smaller amount or check back soon.")
        $g_i_TotOutcome = 0
        Tot_EndSession()
        Return
    EndIf

    If Not Tot_Pause() Then
        Tot_EndSession()
        Return
    EndIf
    Local $l_i_Offered = Tot_OfferStacks($l_i_Stacks)
    If $l_i_Offered <> $l_i_Stacks Then
        LogWarn("Could not place " & $l_i_Stacks * $g_i_TotLotSize & " " & $g_s_TotItemName & ". Cancelling.")
        $g_i_TotOutcome = 0
        Tot_EndSession()
        Return
    EndIf
    If Not Tot_Pause() Then
        Tot_EndSession()
        Return
    EndIf
    If Not Trade_SubmitOffer(0) Or Not Tot_WaitOurSubmit() Then
        LogWarn("Could not submit the offer.")
        $g_i_TotOutcome = 0
        Tot_EndSession()
        Return
    EndIf
    LogInfo("Offered " & $l_i_Offered * $g_i_TotLotSize & " " & $g_s_TotItemName & ".")

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
        LogInfo("Their " & $g_s_TotCurName & " does not match the " & $g_s_TotItemName & " offered. Cancelling.")
        Tot_Tell("Your " & $g_s_TotCurName & " changed after I offered. Please trade me again.")
        Tot_EndSession()
        Return
    EndIf

    If $g_i_TotCurModel = 0 And Item_GetInventoryInfo("GoldCharacter") + Tot_ReadEctos() > $TOT_MAX_GOLD Then
        LogWarn("Taking " & Tot_Amount(Tot_ReadEctos()) & " would put this character over " & Tot_Amount($TOT_MAX_GOLD) & ". Cancelling.")
        Tot_Tell("Sorry, I can't carry that much gold right now. Try a smaller amount.")
        $g_i_TotOutcome = 0
        Tot_EndSession()
        Return
    EndIf
    If Not Trade_AcceptTrade() Then
        LogWarn("Could not accept the trade.")
        $g_i_TotOutcome = 0
        Tot_EndSession()
        Return
    EndIf
    LogInfo("Accepted. Waiting for them to finish.")
    Tot_WaitFinished($l_i_Offered, $l_i_Offered * $l_i_Price)
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

; Offers $a_i_Lots trade units, taking from as many inventory stacks as needed
; (up to the trade window's slots). Returns how many whole units were offered.
Func Tot_OfferStacks($a_i_Lots)
    Local $l_i_Need = $a_i_Lots * $g_i_TotLotSize
    Local $l_ai_Items = Tot_ListItems($g_i_TotModel, 1)
    Local $l_i_Placed = 0
    Local $l_i_Slots = 0
    For $l_i_Idx = 1 To $l_ai_Items[0]
        If $l_i_Placed >= $l_i_Need Or $l_i_Slots >= $TOT_MAX_TRADE_STACKS Then ExitLoop
        Local $l_i_Qty = Item_GetItemInfoByItemID($l_ai_Items[$l_i_Idx], "Quantity")
        If $l_i_Qty < 1 Then ContinueLoop
        If $l_i_Qty > $l_i_Need - $l_i_Placed Then $l_i_Qty = $l_i_Need - $l_i_Placed
        If $l_i_Slots > 0 And Not Tot_Pause() Then ExitLoop
        If Not Trade_OfferItem($l_ai_Items[$l_i_Idx], $l_i_Qty) Then ExitLoop
        $l_i_Placed += $l_i_Qty
        $l_i_Slots += 1
    Next
    Return Int($l_i_Placed / $g_i_TotLotSize)
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
                LogInfo("Their offer is not " & $g_s_TotCurName & " only.")
                Tot_Tell($g_s_TotCurName & " only please, " & Tot_Amount($g_i_TotPrice) & " " & Tot_PerLot() & ".")
                Return -2
            EndIf
            LogInfo("They offered " & Tot_Amount($l_i_Ectos) & ".")
            Return $l_i_Ectos
        EndIf
        Sleep(50)
    WEnd
    If Not $BotRunning Then Return -1
    LogInfo("Timed out waiting for their offer.")
    Tot_Tell("Timed out waiting for your offer. Trade me again when ready.")
    Return -2
EndFunc

; How much of the chosen currency they offered. -1 if they offered anything else.
Func Tot_ReadEctos()
    Local $l_i_Count = Trade_GetTradeInfo("PartnerItemCount")
    If $g_i_TotCurModel = 0 Then
        If $l_i_Count > 0 Then Return -1
        Return Trade_GetTradeInfo("PartnerGold")
    EndIf
    If Trade_GetTradeInfo("PartnerGold") > 0 Then Return -1
    Local $l_i_Ectos = 0
    For $l_i_Slot = 0 To $l_i_Count - 1
        If Trade_GetPartnerTradeItemsInfo($l_i_Slot, "ModelID") <> $g_i_TotCurModel Then Return -1
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

    Local $l_i_Total = 0
    For $l_i_Slot = 0 To $l_i_Count - 1
        If Trade_GetPlayerTradeItemsInfo($l_i_Slot, "ModelID") <> $g_i_TotModel Then Return -1
        $l_i_Total += Trade_GetPlayerTradeItemsInfo($l_i_Slot, "Quantity")
    Next
    If $l_i_Total < 1 Or Mod($l_i_Total, $g_i_TotLotSize) <> 0 Then Return -1
    Return Int($l_i_Total / $g_i_TotLotSize)
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

Func Tot_WaitFinished($a_i_Stacks, $a_i_Ectos)
    Local $l_i_Timer = TimerInit()
    While $BotRunning And TimerDiff($l_i_Timer) < $TOT_WAIT_MS
        StoC_UpdateTrade()
        Tot_Advert()
        Local $l_i_Result = StoC_GetTradeInfo("Result")
        If $l_i_Result = $GC_I_STOC_TRADE_ACK_EXECUTED Then
            Tot_RecordSale($a_i_Stacks, $a_i_Ectos)
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
    If Not $BotRunning Or $g_b_TotRestocking Or TimerDiff($g_i_TotAdvert) < 120000 Then Return
    Local $l_i_Stock = Tot_FullStacks()
    If $l_i_Stock < 1 Then Return ; try again once we have stock
    $g_i_TotAdvert = TimerInit()
    Chat_SendChat("WTS " & $g_s_TotAdvertName & " - " & Tot_AdvertPrice() & ", " & Tot_AdvertStock($l_i_Stock) & " in stock.", "$")
EndFunc

Func Tot_SessionOpen()
    Return BitAND(Trade_GetTradeInfo("Flags"), $GC_I_TRADE_FLAG_ACTIVE) <> 0
EndFunc

Func Tot_EndSession()
    If StoC_GetTradeInfo("Result") = $GC_I_STOC_TRADE_ACK_EXECUTED Then Return
    If Not Tot_SessionOpen() Then Return
    Trade_CancelTrade()
EndFunc

; How many trade units are in the inventory (full stacks when the trade size is 250).
Func Tot_FullStacks()
    Local $l_ai_Items = Tot_ListItems($g_i_TotModel, 1)
    Local $l_i_Total = 0
    For $l_i_Idx = 1 To $l_ai_Items[0]
        $l_i_Total += Item_GetItemInfoByItemID($l_ai_Items[$l_i_Idx], "Quantity")
    Next
    Return Int($l_i_Total / $g_i_TotLotSize)
EndFunc

Func Tot_ValidLotSize($a_v_Size)
    Local $l_i_Size = Int($a_v_Size)
    If $l_i_Size < 1 Or $l_i_Size > $TOT_STACK Then $l_i_Size = $TOT_STACK
    Return $l_i_Size
EndFunc

Func Tot_IsFullStack()
    Return $g_i_TotLotSize = $TOT_STACK
EndFunc

; "per stack" or "per 50"
Func Tot_PerLot()
    If Tot_IsFullStack() Then Return "per stack"
    Return "per " & $g_i_TotLotSize
EndFunc

; "3e/stk", "2arm per 50" or "5k/stk"
Func Tot_AdvertPrice()
    Local $l_s_Price = $g_i_TotPrice & $g_s_TotCurShort
    If $g_i_TotCurModel = 0 And $g_i_TotPrice >= 1000 And Mod($g_i_TotPrice, 1000) = 0 Then $l_s_Price = ($g_i_TotPrice / 1000) & "k"
    If Tot_IsFullStack() Then Return $l_s_Price & "/stk"
    Return $l_s_Price & " per " & $g_i_TotLotSize
EndFunc

; "42 stks" or "2100"
Func Tot_AdvertStock($a_i_Lots)
    If Tot_IsFullStack() Then Return $a_i_Lots & " stks"
    Return $a_i_Lots * $g_i_TotLotSize
EndFunc

; Most units one trade can hold: our side is limited to 7 full stacks, and the
; buyer's side to 7 stacks of the currency, or 100k when paying in gold.
Func Tot_MaxLots()
    Local $l_i_Lots = Int($TOT_MAX_TRADE_STACKS * $TOT_STACK / $g_i_TotLotSize)
    Local $l_i_MaxPay = $TOT_MAX_TRADE_STACKS * $TOT_STACK
    If $g_i_TotCurModel = 0 Then $l_i_MaxPay = $TOT_MAX_GOLD
    Local $l_i_PayLots = Int($l_i_MaxPay / $g_i_TotPrice)
    If $l_i_PayLots < $l_i_Lots Then $l_i_Lots = $l_i_PayLots
    Return $l_i_Lots
EndFunc

; "3 Ecto", "2 Armbrace", "5,000 Gold"
Func Tot_Amount($a_i_Amount)
    Return Tot_Thousands($a_i_Amount) & " " & $g_s_TotCurName
EndFunc

Func Tot_Thousands($a_i_Num)
    Local $l_s_Num = String(Int($a_i_Num))
    Local $l_s_Out = ""
    While StringLen($l_s_Num) > 3
        $l_s_Out = "," & StringRight($l_s_Num, 3) & $l_s_Out
        $l_s_Num = StringTrimRight($l_s_Num, 3)
    WEnd
    Return $l_s_Num & $l_s_Out
EndFunc

; "Selling 250 Trick or Treat Bag for 3 Ecto"
Func Tot_Summary()
    Return "Selling " & $g_i_TotLotSize & " " & $g_s_TotItemName & " for " & Tot_Amount($g_i_TotPrice)
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
    $g_b_TotRestocking = True
    Local $l_b_Ok = Tot_DoRestock()
    $g_b_TotRestocking = False
    Return $l_b_Ok
EndFunc

Func Tot_DoRestock()
    $g_b_TotRestockCut = False
    LogInfo("Fewer than " & $TOT_LOW_STACKS & " " & $g_s_TotItemName & " stacks. Opening the Xunlai chest.")
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
        If $g_i_TotCurModel = 0 Then
            Item_DepositGold()
        Else
            Tot_StoreEctos()
        EndIf
        If $BotRunning And Not Tot_TradeWaiting() Then Tot_WithdrawBags()
    EndIf

    If $BotRunning And Tot_TradeWaiting() Then
        $g_b_TotRestockCut = True
        LogInfo("Someone wants to trade. Pausing the restock to serve them first.")
        Return True
    EndIf

    Local $l_ai_Fill = Tot_BagFill()
    If $l_ai_Fill[1] = 0 Or $l_ai_Fill[0] * 2 < $l_ai_Fill[1] Then
        If GUICtrlRead($g_hKeepRunning) = $GUI_CHECKED Then
            LogWarn($g_s_TotItemName & " fills less than half the inventory. Keep running is on.")
        Else
            LogWarn($g_s_TotItemName & " fills less than half the inventory. Pausing.")
            $BotRunning = False
            Return False
        EndIf
    EndIf
    If Not $BotRunning Then Return False
    LogInfo($g_s_TotItemName & " in stock: " & Tot_AdvertStock(Tot_FullStacks()) & ".")
    Return True
EndFunc

Func Tot_StoreEctos()
    Local $l_ai_Ectos = Tot_ListItems($g_i_TotCurModel, 1)
    For $l_i_Idx = 1 To $l_ai_Ectos[0]
        If Not $BotRunning Or Tot_TradeWaiting() Then Return
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
                LogWarn("Could not stack " & $g_s_TotCurName & " into storage.")
                ExitLoop
            EndIf
        WEnd

        If $l_i_Qty < 1 Then ContinueLoop
        Local $l_ai_Empty = Tot_EmptySlot($g_ai_TotStorage)
        If $l_ai_Empty[0] = 0 Then
            LogWarn("No storage space left for " & $g_s_TotCurName & ".")
            Return
        EndIf
        Item_MoveItem($l_i_Item, $l_ai_Empty[0], $l_ai_Empty[1])
        Tot_Pause()
        If Item_GetItemBySlot($l_ai_Empty[0], $l_ai_Empty[1]) = 0 Then
            LogWarn("Could not move " & $g_s_TotCurName & " into storage.")
            Return
        EndIf
    Next
EndFunc

Func Tot_WithdrawBags()
    Local $l_av_Storage = Item_GetStorageArray()
    For $l_i_Idx = 0 To UBound($l_av_Storage) - 1
        If Not $BotRunning Or Tot_TradeWaiting() Then Return
        If $l_av_Storage[$l_i_Idx][$GC_I_INVENTORY_MODELID] <> $g_i_TotModel Then ContinueLoop
        Local $l_ai_Empty = Tot_EmptySlot($g_ai_TotBags)
        If $l_ai_Empty[0] = 0 Then Return
        Item_MoveItem($l_av_Storage[$l_i_Idx][$GC_I_INVENTORY_ITEMID], $l_ai_Empty[0], $l_ai_Empty[1])
        Tot_Pause()
        If Item_GetItemBySlot($l_ai_Empty[0], $l_ai_Empty[1]) = 0 Then
            LogWarn("Could not move " & $g_s_TotItemName & " out of storage.")
            Return
        EndIf
    Next
EndFunc

Func Tot_Tell($a_s_Message)
    If Not IsString($g_s_TotPartnerName) Or $g_s_TotPartnerName = "" Then Return
    Chat_SendWhisper($g_s_TotPartnerName, $a_s_Message)
EndFunc

Func Tot_RecordSale($a_i_Stacks, $a_i_Ectos)
    $g_i_TotOutcome = 1
    $g_i_TotSales += 1
    $g_o_TotEarned.Item($g_s_TotCurName) = $g_o_TotEarned.Item($g_s_TotCurName) + $a_i_Ectos
    Local $l_s_Earned = ""
    For $l_s_Cur In $g_o_TotEarned.Keys
        $l_s_Earned &= ", " & Tot_Thousands($g_o_TotEarned.Item($l_s_Cur)) & " " & $l_s_Cur
    Next
    LogInfo("Trade completed: " & $a_i_Stacks * $g_i_TotLotSize & " " & $g_s_TotItemName & " for " & Tot_Amount($a_i_Ectos) & ". Total: " & $g_i_TotSales & " trade(s)" & $l_s_Earned & ".")
    WinSetTitle($MainGui, "", $BotTitle & " - " & player_GetCharname() & " - " & $g_i_TotSales & " trades" & $l_s_Earned)
EndFunc

Func Tot_RecordOutcome()
    Local $l_s_Name = $g_s_TotPartnerName
    If Not $BotRunning Or Not IsString($l_s_Name) Or $l_s_Name = "" Or $g_s_TotLastIgnored <> "" Then Return
    If $g_i_TotOutcome = 1 Then
        If $g_o_TotStrikes.Exists($l_s_Name) Then $g_o_TotStrikes.Remove($l_s_Name)
        Return
    EndIf
    If $g_i_TotOutcome <> 2 Then Return
    Local $l_i_Strikes = 1
    If $g_o_TotStrikes.Exists($l_s_Name) Then $l_i_Strikes = $g_o_TotStrikes.Item($l_s_Name) + 1
    If $l_i_Strikes >= $TOT_MAX_STRIKES Then
        If $g_o_TotStrikes.Exists($l_s_Name) Then $g_o_TotStrikes.Remove($l_s_Name)
        $g_o_TotBlocked.Item($l_s_Name) = TimerInit()
        LogInfo($l_s_Name & " had " & $TOT_MAX_STRIKES & " failed trades in a row. Ignoring them for " & Int($TOT_COOLDOWN_MS / 60000) & " minutes.")
        Tot_Tell("Too many cancelled trades, please try again in " & Int($TOT_COOLDOWN_MS / 60000) & " minutes.")
    Else
        $g_o_TotStrikes.Item($l_s_Name) = $l_i_Strikes
    EndIf
EndFunc

Func Tot_IsBlocked($a_s_Name)
    If Not IsString($a_s_Name) Or $a_s_Name = "" Or Not $g_o_TotBlocked.Exists($a_s_Name) Then Return False
    If TimerDiff($g_o_TotBlocked.Item($a_s_Name)) < $TOT_COOLDOWN_MS Then Return True
    $g_o_TotBlocked.Remove($a_s_Name)
    Return False
EndFunc

Func Tot_TradeWaiting()
    Return Trade_GetTradePartner() <> 0
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
            If Item_GetItemInfoByPtr($l_p_Item, "ModelID") <> $g_i_TotCurModel Then ContinueLoop
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
            If Item_GetItemInfoByPtr($l_p_Item, "ModelID") = $g_i_TotModel Then $l_i_Bags += 1
        Next
    Next
    Local $l_ai_Fill[2] = [$l_i_Bags, $l_i_Total]
    Return $l_ai_Fill
EndFunc
