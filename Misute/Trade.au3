#include-once

; The item being sold or bought. Set from the active tab's dropdown ($g_av_TotItems in Misute.au3) on Start.
Global $g_s_TotItemName = $g_av_TotItems[0][0]
Global $g_i_TotModel = $g_av_TotItems[0][1]
Global $g_s_TotAdvertName = $g_av_TotItems[0][2]
Global $g_i_TotLotSize = Tot_ValidLotSize($g_av_TotItems[0][3]) ; how many items the price buys
; What the trade is paid with. Set from the active tab's dropdown ($g_av_TotCurrencies in Misute.au3).
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
Global $g_i_TotBuys = 0
Global $g_i_TotItemsBought = 0
Global $g_o_TotSpent = ObjCreate("Scripting.Dictionary") ; currency name -> amount paid out
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
            If Tot_NeedsRestock() And Tot_StockLevel() <> $g_i_TotRestockFloor Then
                If Not Tot_Restock() Then ExitLoop
                If $g_b_TotRestockCut Then
                    ; Restock was cut short for a trade. Retry it once the trade is done.
                    $g_i_TotRestockFloor = -1
                Else
                    ; Still low after restocking: wait until the stock changes before trying again.
                    $g_i_TotRestockFloor = Tot_StockLevel()
                    If Not Tot_NeedsRestock() Then $g_i_TotRestockFloor = -1
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

    If Tot_Buying() Then
        Tot_BuySession($l_i_Price)
    Else
        Tot_SellSession($l_i_Price)
    EndIf
EndFunc

; Sell mode: they offer the currency, we offer the item.
Func Tot_SellSession($a_i_Price)
    Local $l_i_Price = $a_i_Price
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

; Buy mode: they offer the item, we pay in the currency.
Func Tot_BuySession($a_i_Price)
    LogInfo("Waiting for their " & $g_s_TotItemName & ".")
    Local $l_i_Items = Tot_WaitForOffer()
    If $l_i_Items < 0 Then
        Tot_EndSession()
        Return
    EndIf

    If $l_i_Items < 1 Or Mod($l_i_Items, $g_i_TotLotSize) <> 0 Then
        LogInfo("They offered " & $l_i_Items & " " & $g_s_TotItemName & ", not a multiple of " & $g_i_TotLotSize & ". Cancelling.")
        Tot_Tell("I buy " & $g_i_TotLotSize & " at a time for " & Tot_Amount($a_i_Price) & ", so please offer a multiple of " & $g_i_TotLotSize & ".")
        Tot_EndSession()
        Return
    EndIf
    Local $l_i_Lots = Int($l_i_Items / $g_i_TotLotSize)
    Local $l_i_Pay = $l_i_Lots * $a_i_Price
    If $l_i_Lots > Tot_MaxLots() Then
        LogInfo($l_i_Items & " " & $g_s_TotItemName & " is over the " & Tot_MaxLots() * $g_i_TotLotSize & "-item trade limit. Cancelling.")
        Tot_Tell("Max " & Tot_MaxLots() * $g_i_TotLotSize & " per trade (" & Tot_Amount(Tot_MaxLots() * $a_i_Price) & "). Trade me again for the rest.")
        Tot_EndSession()
        Return
    EndIf
    If $l_i_Lots > Tot_PayLots() Then
        LogWarn("Not enough " & $g_s_TotCurName & " to pay " & Tot_Amount($l_i_Pay) & ". Cancelling.")
        Tot_Tell("Sorry, I can only pay for " & Tot_PayLots() * $g_i_TotLotSize & " right now. Try a smaller amount or check back soon.")
        $g_i_TotOutcome = 0
        Tot_EndSession()
        Return
    EndIf
    If Trade_GetTradeInfo("PartnerItemCount") > Tot_FreeSlots() Then
        LogWarn("Not enough bag space for " & Trade_GetTradeInfo("PartnerItemCount") & " stacks of " & $g_s_TotItemName & ". Cancelling.")
        Tot_Tell("Sorry, my bags are too full for that many stacks right now. Try fewer stacks or check back soon.")
        $g_i_TotOutcome = 0
        Tot_EndSession()
        Return
    EndIf

    If Not Tot_Pause() Then
        Tot_EndSession()
        Return
    EndIf
    If Not Tot_OfferPayment($l_i_Pay) Or Not Tot_WaitOurSubmit() Then
        LogWarn("Could not offer and submit " & Tot_Amount($l_i_Pay) & ". Cancelling.")
        $g_i_TotOutcome = 0
        Tot_EndSession()
        Return
    EndIf
    LogInfo("Offered " & Tot_Amount($l_i_Pay) & " for " & $l_i_Items & " " & $g_s_TotItemName & ".")

    StoC_UpdateTrade()
    If Not StoC_GetTradeInfo("PartnerSubmitted") Then
        LogInfo("Waiting for them to submit again.")
        If Tot_WaitForOffer() < 0 Then
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
    If Not Tot_BuyOfferMatches($l_i_Items, $l_i_Pay) Then
        LogInfo("Their " & $g_s_TotItemName & " does not match the " & $g_s_TotCurName & " offered. Cancelling.")
        Tot_Tell("Your " & $g_s_TotItemName & " changed after I offered. Please trade me again.")
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
    Tot_WaitFinished($l_i_Lots, $l_i_Pay)
EndFunc

; Puts $a_i_Pay of the currency on our side and submits: gold goes in with the
; submit, currency items are offered from as many stacks as needed first.
Func Tot_OfferPayment($a_i_Pay)
    If $g_i_TotCurModel = 0 Then
        If Item_GetInventoryInfo("GoldCharacter") < $a_i_Pay Then Return False
        Return Trade_SubmitOffer($a_i_Pay)
    EndIf
    If Tot_OfferModel($g_i_TotCurModel, $a_i_Pay) <> $a_i_Pay Then Return False
    If Not Tot_Pause() Then Return False
    Return Trade_SubmitOffer(0)
EndFunc

; Their side must still be exactly the items we priced, and ours exactly the payment.
Func Tot_BuyOfferMatches($a_i_Items, $a_i_Pay)
    Local $l_i_Theirs = Tot_ReadSide(True, $g_i_TotModel)
    Local $l_i_Ours = Tot_ReadSide(False, $g_i_TotCurModel)
    If $l_i_Theirs < 1 Or $l_i_Ours < 1 Then Return False
    Return $l_i_Theirs = $a_i_Items And $l_i_Ours = $a_i_Pay
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

; Offers $a_i_Lots trade units of the item. Returns how many whole units were offered.
Func Tot_OfferStacks($a_i_Lots)
    Return Int(Tot_OfferModel($g_i_TotModel, $a_i_Lots * $g_i_TotLotSize) / $g_i_TotLotSize)
EndFunc

; Offers $a_i_Need of model $a_i_Model, taking from as many inventory stacks as needed
; (up to the trade window's slots). Returns how many were offered.
Func Tot_OfferModel($a_i_Model, $a_i_Need)
    Local $l_i_Need = $a_i_Need
    Local $l_ai_Items = Tot_ListItems($a_i_Model, 1)
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
    Return $l_i_Placed
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
            Local $l_i_Ectos = Tot_ReadPartner()
            If $l_i_Ectos < 0 Then
                If Tot_Buying() Then
                    LogInfo("Their offer is not " & $g_s_TotItemName & " only.")
                    Tot_Tell("I only buy " & $g_s_TotItemName & ", " & Tot_Amount($g_i_TotPrice) & " " & Tot_PerLot() & ". Please offer just those, no gold.")
                Else
                    LogInfo("Their offer is not " & $g_s_TotCurName & " only.")
                    Tot_Tell($g_s_TotCurName & " only please, " & Tot_Amount($g_i_TotPrice) & " " & Tot_PerLot() & ".")
                EndIf
                Return -2
            EndIf
            If Tot_Buying() Then
                LogInfo("They offered " & $l_i_Ectos & " " & $g_s_TotItemName & ".")
            Else
                LogInfo("They offered " & Tot_Amount($l_i_Ectos) & ".")
            EndIf
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
    Return Tot_ReadSide(True, $g_i_TotCurModel)
EndFunc

; What this mode expects from them: the currency when selling, the item when buying.
Func Tot_ReadPartner()
    If Tot_Buying() Then Return Tot_ReadSide(True, $g_i_TotModel)
    Return Tot_ReadEctos()
EndFunc

; How much of model $a_i_Model (0 = gold) is on their side ($a_b_Partner) or ours.
; -1 if that side holds anything else.
Func Tot_ReadSide($a_b_Partner, $a_i_Model)
    Local $l_s_Who = "Player"
    If $a_b_Partner Then $l_s_Who = "Partner"
    Local $l_i_Count = Trade_GetTradeInfo($l_s_Who & "ItemCount")
    If $a_i_Model = 0 Then
        If $l_i_Count > 0 Then Return -1
        Return Trade_GetTradeInfo($l_s_Who & "Gold")
    EndIf
    If Trade_GetTradeInfo($l_s_Who & "Gold") > 0 Then Return -1
    Local $l_i_Total = 0
    For $l_i_Slot = 0 To $l_i_Count - 1
        If $a_b_Partner Then
            If Trade_GetPartnerTradeItemsInfo($l_i_Slot, "ModelID") <> $a_i_Model Then Return -1
            $l_i_Total += Trade_GetPartnerTradeItemsInfo($l_i_Slot, "Quantity")
        Else
            If Trade_GetPlayerTradeItemsInfo($l_i_Slot, "ModelID") <> $a_i_Model Then Return -1
            $l_i_Total += Trade_GetPlayerTradeItemsInfo($l_i_Slot, "Quantity")
        EndIf
    Next
    Return $l_i_Total
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
            If Tot_Buying() Then
                Tot_RecordBuy($a_i_Stacks, $a_i_Ectos)
            Else
                Tot_RecordSale($a_i_Stacks, $a_i_Ectos)
            EndIf
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
    If Tot_Buying() Then
        Local $l_i_CanBuy = Tot_BuyLots()
        If $l_i_CanBuy < 1 Then Return ; try again once we can pay and have room
        $g_i_TotAdvert = TimerInit()
        Chat_SendChat("WTB " & $g_s_TotAdvertName & " - " & Tot_AdvertPrice() & ", buying up to " & Tot_AdvertStock($l_i_CanBuy) & ".", "$")
        Return
    EndIf
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

Func Tot_Buying()
    Return $g_i_TotMode = $TOT_MODE_BUY
EndFunc

; "Sell" or "Buy" (the tab and ini section names). No argument = the current mode.
Func Tot_ModeName($a_i_Mode = -1)
    If $a_i_Mode = -1 Then $a_i_Mode = $g_i_TotMode
    If $a_i_Mode = $TOT_MODE_BUY Then Return "Buy"
    Return "Sell"
EndFunc

; Sell: fewer than $TOT_LOW_STACKS units of the item. Buy: we cannot pay for a
; full-size trade, or there is not room for one (7 trade stacks).
Func Tot_NeedsRestock()
    If Tot_Buying() Then Return Tot_PayLots() < Tot_MaxLots() Or Tot_FreeSlots() < $TOT_MAX_TRADE_STACKS
    Return Tot_FullStacks() < $TOT_LOW_STACKS
EndFunc

; A number that changes whenever the stock the restock cares about changes.
Func Tot_StockLevel()
    If Tot_Buying() Then Return Tot_PayableCurrency() * 1000 + Tot_FreeSlots()
    Return Tot_FullStacks()
EndFunc

; How much currency one trade can pay out: carried gold up to 100k, or the
; first 7 inventory stacks of the currency item (the trade window's slots).
Func Tot_PayableCurrency()
    If $g_i_TotCurModel = 0 Then
        Local $l_i_Gold = Item_GetInventoryInfo("GoldCharacter")
        If $l_i_Gold > $TOT_MAX_GOLD Then $l_i_Gold = $TOT_MAX_GOLD
        Return $l_i_Gold
    EndIf
    Local $l_ai_Cur = Tot_ListItems($g_i_TotCurModel, 1)
    Local $l_i_Total = 0
    For $l_i_Idx = 1 To $l_ai_Cur[0]
        If $l_i_Idx > $TOT_MAX_TRADE_STACKS Then ExitLoop
        $l_i_Total += Item_GetItemInfoByItemID($l_ai_Cur[$l_i_Idx], "Quantity")
    Next
    Return $l_i_Total
EndFunc

; How many trade units we can pay for right now.
Func Tot_PayLots()
    If $g_i_TotPrice < 1 Then Return 0
    Return Int(Tot_PayableCurrency() / $g_i_TotPrice)
EndFunc

; How many trade units we can pay for and have bag room for (assumes full stacks come in).
Func Tot_BuyLots()
    Local $l_i_Lots = Tot_PayLots()
    Local $l_i_Room = Int(Tot_FreeSlots() * $TOT_STACK / $g_i_TotLotSize)
    If $l_i_Room < $l_i_Lots Then $l_i_Lots = $l_i_Room
    Return $l_i_Lots
EndFunc

Func Tot_FreeSlots()
    Local $l_i_Free = 0
    For $l_i_Idx = 0 To UBound($g_ai_TotBags) - 1
        Local $l_i_Slots = Item_GetBagInfo($g_ai_TotBags[$l_i_Idx], "Slots")
        For $l_i_Slot = 1 To $l_i_Slots
            If Item_GetItemBySlot($g_ai_TotBags[$l_i_Idx], $l_i_Slot) = 0 Then $l_i_Free += 1
        Next
    Next
    Return $l_i_Free
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

; Most units one trade can hold: the item side is limited to 7 full stacks, and the
; paying side to 7 stacks of the currency, or 100k when paying in gold. Same both ways.
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

; "Selling 250 Trick or Treat Bag for 3 Ecto" or "Buying 250 Trick or Treat Bag for 3 Ecto"
Func Tot_Summary()
    Local $l_s_Verb = "Selling "
    If Tot_Buying() Then $l_s_Verb = "Buying "
    Return $l_s_Verb & $g_i_TotLotSize & " " & $g_s_TotItemName & " for " & Tot_Amount($g_i_TotPrice)
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
    If Tot_Buying() Then
        LogInfo("Low on " & $g_s_TotCurName & " or bag space. Opening the Xunlai chest.")
    Else
        LogInfo("Fewer than " & $TOT_LOW_STACKS & " " & $g_s_TotItemName & " stacks. Opening the Xunlai chest.")
    EndIf
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
        If Tot_Buying() Then
            ; Put away what we bought, then top up what we pay with.
            Tot_StoreModel($g_i_TotModel, $g_s_TotItemName)
            If $BotRunning And Not Tot_TradeWaiting() Then
                If $g_i_TotCurModel = 0 Then
                    Item_WithdrawGold() ; as much as storage has, up to 100k carried
                    Tot_Pause()
                Else
                    Tot_WithdrawModel($g_i_TotCurModel, $g_s_TotCurName, $TOT_MAX_TRADE_STACKS)
                EndIf
            EndIf
        Else
            If $g_i_TotCurModel = 0 Then
                Item_DepositGold()
            Else
                Tot_StoreModel($g_i_TotCurModel, $g_s_TotCurName)
            EndIf
            If $BotRunning And Not Tot_TradeWaiting() Then Tot_WithdrawModel($g_i_TotModel, $g_s_TotItemName)
        EndIf
    EndIf

    If $BotRunning And Tot_TradeWaiting() Then
        $g_b_TotRestockCut = True
        LogInfo("Someone wants to trade. Pausing the restock to serve them first.")
        Return True
    EndIf

    If Tot_Buying() Then Return Tot_BuyRestockDone()

    ; Completely out: nothing left to sell even after restocking. Always pause,
    ; whatever the keep running box says.
    If Tot_FullStacks() < 1 Then
        LogWarn("Out of " & $g_s_TotItemName & " - none left in the bags or the chest. Pausing.")
        $BotRunning = False
        Return False
    EndIf

    Local $l_ai_Fill = Tot_BagFill()
    If $l_ai_Fill[1] = 0 Or $l_ai_Fill[0] * 2 < $l_ai_Fill[1] Then
        If GUICtrlRead($g_ah_KeepRunning[$TOT_MODE_SELL]) = $GUI_CHECKED Then
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

; End of a buy-mode restock: stop if the bags are still full or we cannot pay for
; one unit. If we can pay for some but not a full-size trade, stop unless the Buy
; tab's keep running box is ticked.
Func Tot_BuyRestockDone()
    If Tot_FreeSlots() < 1 Then
        LogWarn("No bag space left for " & $g_s_TotItemName & " even after storing. Pausing.")
        $BotRunning = False
        Return False
    EndIf
    ; Completely out: cannot pay for even one trade unit after restocking.
    ; Always pause, whatever the keep running box says.
    If Tot_PayLots() < 1 Then
        LogWarn("Out of " & $g_s_TotCurName & " - not enough left to pay for " & $g_i_TotLotSize & " " & $g_s_TotItemName & ". Pausing.")
        $BotRunning = False
        Return False
    EndIf
    ; Low but not out: carry on only if the Buy tab's keep running box is ticked.
    If Tot_PayLots() < Tot_MaxLots() And GUICtrlRead($g_ah_KeepRunning[$TOT_MODE_BUY]) <> $GUI_CHECKED Then
        LogWarn("Low on " & $g_s_TotCurName & " - can only pay for " & Tot_PayLots() * $g_i_TotLotSize & " " & $g_s_TotItemName & " per trade. Pausing.")
        $BotRunning = False
        Return False
    EndIf
    If Not $BotRunning Then Return False
    LogInfo("Can pay " & Tot_Amount(Tot_PayableCurrency()) & ", buying up to " & Tot_BuyLots() * $g_i_TotLotSize & " " & $g_s_TotItemName & ".")
    Return True
EndFunc

; Moves every inventory stack of $a_i_Model into storage, topping up part stacks first.
Func Tot_StoreModel($a_i_Model, $a_s_Name)
    Local $l_ai_Ectos = Tot_ListItems($a_i_Model, 1)
    For $l_i_Idx = 1 To $l_ai_Ectos[0]
        If Not $BotRunning Or Tot_TradeWaiting() Then Return
        Local $l_i_Item = $l_ai_Ectos[$l_i_Idx]
        Local $l_i_Qty = Item_GetItemInfoByItemID($l_i_Item, "Quantity")
        Local $l_i_Tries = 0

        While $l_i_Qty > 0 And $l_i_Tries < 30
            $l_i_Tries += 1
            Local $l_ai_Partial = Tot_BestEctoSlot($a_i_Model)
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
                LogWarn("Could not stack " & $a_s_Name & " into storage.")
                ExitLoop
            EndIf
        WEnd

        If $l_i_Qty < 1 Then ContinueLoop
        Local $l_ai_Empty = Tot_EmptySlot($g_ai_TotStorage)
        If $l_ai_Empty[0] = 0 Then
            LogWarn("No storage space left for " & $a_s_Name & ".")
            Return
        EndIf
        Item_MoveItem($l_i_Item, $l_ai_Empty[0], $l_ai_Empty[1])
        Tot_Pause()
        If Item_GetItemBySlot($l_ai_Empty[0], $l_ai_Empty[1]) = 0 Then
            LogWarn("Could not move " & $a_s_Name & " into storage.")
            Return
        EndIf
    Next
EndFunc

; Moves stacks of $a_i_Model from storage into the bags, until the bags are full or,
; if $a_i_MaxStacks > 0, the bags hold that many stacks of it.
Func Tot_WithdrawModel($a_i_Model, $a_s_Name, $a_i_MaxStacks = 0)
    Local $l_ai_Have = Tot_ListItems($a_i_Model, 1)
    Local $l_i_Have = $l_ai_Have[0]
    Local $l_av_Storage = Item_GetStorageArray()
    For $l_i_Idx = 0 To UBound($l_av_Storage) - 1
        If Not $BotRunning Or Tot_TradeWaiting() Then Return
        If $a_i_MaxStacks > 0 And $l_i_Have >= $a_i_MaxStacks Then Return
        If $l_av_Storage[$l_i_Idx][$GC_I_INVENTORY_MODELID] <> $a_i_Model Then ContinueLoop
        Local $l_ai_Empty = Tot_EmptySlot($g_ai_TotBags)
        If $l_ai_Empty[0] = 0 Then Return
        Item_MoveItem($l_av_Storage[$l_i_Idx][$GC_I_INVENTORY_ITEMID], $l_ai_Empty[0], $l_ai_Empty[1])
        Tot_Pause()
        If Item_GetItemBySlot($l_ai_Empty[0], $l_ai_Empty[1]) = 0 Then
            LogWarn("Could not move " & $a_s_Name & " out of storage.")
            Return
        EndIf
        $l_i_Have += 1
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
    Local $l_s_Earned = Tot_Tally($g_o_TotEarned)
    LogInfo("Trade completed: " & $a_i_Stacks * $g_i_TotLotSize & " " & $g_s_TotItemName & " for " & Tot_Amount($a_i_Ectos) & ". Total: " & $g_i_TotSales & " trade(s)" & $l_s_Earned & ".")
    Tot_UpdateTitle()
EndFunc

Func Tot_RecordBuy($a_i_Lots, $a_i_Paid)
    $g_i_TotOutcome = 1
    $g_i_TotBuys += 1
    $g_i_TotItemsBought += $a_i_Lots * $g_i_TotLotSize
    $g_o_TotSpent.Item($g_s_TotCurName) = $g_o_TotSpent.Item($g_s_TotCurName) + $a_i_Paid
    LogInfo("Trade completed: bought " & $a_i_Lots * $g_i_TotLotSize & " " & $g_s_TotItemName & " for " & Tot_Amount($a_i_Paid) & ". Total: " & $g_i_TotBuys & " buy(s), " & Tot_Thousands($g_i_TotItemsBought) & " items, spent " & StringTrimLeft(Tot_Tally($g_o_TotSpent), 2) & ".")
    Tot_UpdateTitle()
EndFunc

; ", 30 Ecto, 5,000 Gold"
Func Tot_Tally($a_o_Dict)
    Local $l_s_Out = ""
    For $l_s_Cur In $a_o_Dict.Keys
        $l_s_Out &= ", " & Tot_Thousands($a_o_Dict.Item($l_s_Cur)) & " " & $l_s_Cur
    Next
    Return $l_s_Out
EndFunc

; "ToT Trader - Name - Sell - 3 trades, 9 Ecto" or "ToT Trader - Name - Buy - 2 buys, 500 items, spent 6 Ecto"
Func Tot_UpdateTitle()
    Local $l_s_Title = $BotTitle & " - " & player_GetCharname() & " - " & Tot_ModeName()
    If Tot_Buying() Then
        If $g_i_TotBuys > 0 Then $l_s_Title &= " - " & $g_i_TotBuys & " buys, " & Tot_Thousands($g_i_TotItemsBought) & " items, spent " & StringTrimLeft(Tot_Tally($g_o_TotSpent), 2)
    ElseIf $g_i_TotSales > 0 Then
        $l_s_Title &= " - " & $g_i_TotSales & " trades" & Tot_Tally($g_o_TotEarned)
    EndIf
    WinSetTitle($MainGui, "", $l_s_Title)
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

; Storage part stack of $a_i_Model with the least room left (to fill it up first).
Func Tot_BestEctoSlot($a_i_Model)
    Local $l_i_Bag = 0
    Local $l_i_Slot = 0
    Local $l_i_Room = $TOT_STACK
    For $l_i_BagIdx = 0 To UBound($g_ai_TotStorage) - 1
        Local $l_i_Slots = Item_GetBagInfo($g_ai_TotStorage[$l_i_BagIdx], "Slots")
        For $l_i_TrySlot = 1 To $l_i_Slots
            Local $l_p_Item = Item_GetItemBySlot($g_ai_TotStorage[$l_i_BagIdx], $l_i_TrySlot)
            If $l_p_Item = 0 Then ContinueLoop
            If Item_GetItemInfoByPtr($l_p_Item, "ModelID") <> $a_i_Model Then ContinueLoop
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
