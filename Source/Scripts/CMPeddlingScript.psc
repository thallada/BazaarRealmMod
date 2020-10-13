Scriptname CMPeddlingScript extends Quest

import Math

Message Property CMPeddlingHaggleStart Auto
Message Property CMPeddlingHaggleStartAdjust Auto
Message Property CMPeddlingHaggleCounter Auto
Message Property CMPeddlingHaggleCounterStart Auto
Message Property CMPeddlingHaggleCountChange Auto
Actor Property PlayerRef Auto
ObjectReference Property CMPeddlingChestRef Auto
Armor Property CMPeddlingInventory Auto
MiscObject Property Gold001 Auto
Keyword Property ClothingRich Auto
Keyword Property ClothingPoor Auto
Keyword Property JewelryExpensive Auto
Faction Property JobMerchantFaction Auto
Faction Property JobHostlerFaction Auto
Faction Property KhajiitCaravanFaction Auto
Faction Property JobInnkeeperFaction Auto
Faction Property JobBardFaction Auto
Faction Property JobFarmerFaction Auto
Faction Property JobMinerFaction Auto
Faction Property JobPriestFaction Auto
Faction Property JobCarriageFaction Auto
Faction Property JobFenceFaction Auto
Faction Property JobJarlFaction Auto
Faction Property JobStewardFaction Auto
Faction Property JobHousecarlFaction Auto
Faction Property JobCourtWizardFaction Auto
Faction Property FavorJobsBeggarsFaction Auto
Faction Property FavorJobsDrunksFaction Auto
Faction Property GuardDialogueFaction Auto

Float version

event OnInit()
    debug.Trace("CMPeddlingScript OnInit")
    MyClass.Init()
    String uuid = MyClass.CreateUuid()
    debug.Trace("uuid: " + uuid)
    debug.Notification("Your uuid: " + uuid)
    Maintenance()
endEvent

function Maintenance()
    debug.Trace("CMPeddlingScript Maintenance!")
    if version < 0.01
        version = 0.01
        debug.Notification("Now running Shopkeeper version: " + version)
    endif
    ReweighPeddlingInventory()
endFunction

function ReweighPeddlingInventory()
    Float totalWeight = 0
    Int formIndex = CMPeddlingChestRef.GetNumItems()
    debug.Trace("Merchandise has " + formIndex + " items, reweighing...")
    while formIndex > 0
        formIndex -= 1
        Form nthForm = CMPeddlingChestRef.GetNthForm(formIndex)
        Int numOfForm = CMPeddlingChestRef.GetItemCount(nthForm)
        totalWeight += nthForm.GetWeight() * numOfForm

        ; Serialize testing
        Int formId = nthForm.GetFormID()
        if (formId < 0)
            ; GetFormId is broken for light mods, so we have to fix this ourselves
            formId = formId + 2147483647 ; formId + INT_MAX
            debug.Trace("Thing (light) form id: " + formId)
            Int localFormId = Math.LogicalAnd(formId, 4095) + 1 ; (formId & 0xfff) + 1
            debug.Trace("Thing (light) local form id: " + localFormId)
            Int modIndex = Math.LogicalAnd(Math.RightShift(formId, 12), 4095) ; (formId >> 12) & 0xfff
            debug.Trace("Light mod index: " + modIndex)
            String modName = Game.GetLightModName(modIndex)
            debug.Trace("Light mod name: " + modName)
        else
            debug.Trace("Thing form id: " + formId)
            Int localFormId = Math.LogicalAnd(formId, 16777215); formId & 0xffffff
            debug.Trace("Thing (light) local form id: " + localFormId)
            Int modIndex = Math.RightShift(formId, 24)
            debug.Trace("Mod index: " + modIndex)
            String modName = Game.GetModName(modIndex)
            debug.Trace("Mod name: " + modName)
        endIf
    endWhile
    debug.Trace("Setting merchandise weight to " + totalWeight)
    CMPeddlingInventory.SetWeight(totalWeight)

    ; Deserialize test
    if CMPeddlingChestRef.GetNumItems() != 0
        debug.Trace("CMPeddlingScript chest empty")
        Bool isLightMod = True
        String modName = "Dovah Nord Weapons.esp"
        Int localFormId = 2053
        Form formToAdd = Game.GetFormFromFile(localFormId, modName)
        debug.Trace("Adding form to chest: " + formToAdd)
        CmPeddlingChestRef.AddItem(formToAdd, 1)
        
        isLightMod = True
        modName = "Dunmeri Leaf Sword.esp"
        localFormId = 2048
        formToAdd = Game.GetFormFromFile(localFormId, modName)
        debug.Trace("Adding form to chest: " + formToAdd)
        CmPeddlingChestRef.AddItem(formToAdd, 1)

        isLightMod = False
        modName = "Evening Star.esp"
        localFormId = 3426
        formToAdd = Game.GetFormFromFile(localFormId, modName)
        debug.Trace("Adding form to chest: " + formToAdd)
        CmPeddlingChestRef.AddItem(formToAdd, 1)
    endIf

    debug.Trace("Dunmeri Leaf Sword.esp: " + Game.GetModByName("Dunmeri Leaf Sword.esp"))
    debug.Trace("Evening Star.esp: " + Game.GetModByName("Evening Star.esp"))
    debug.Trace("Dovah Nord Weapons.esp: " + Game.GetModByName("Dovah Nord Weapons.esp"))

    ; Test spawning user placed references
    Form candlestickForm = Game.GetFormEx(934623)
    ObjectReference candlestickRef = PlayerRef.PlaceAtMe(candlestickForm, 1, false, true)
    candlestickRef.SetPosition(-62.375675, -437.171265, 78.617851)
    candlestickRef.SetAngle(93.194153, 42.144417, -109.048126)
    candlestickRef.SetScale(1.0)
    candleStickRef.Enable()

    ; Test scanning and serializing reference positions
    Cell currentCell = PlayerRef.GetParentCell()
    Int numRefs = currentCell.GetNumRefs()
    debug.Trace("Num of refs in current cell: " + numRefs)
    Int refIndex = 0
    while refIndex <= numRefs
        ObjectReference ref = currentCell.GetNthRef(refIndex)
        if ref != None
            debug.Trace("Ref " + refIndex + ": " + ref.GetBaseObject().GetType())
            debug.Trace("Ref " + refIndex + ": " + ref.GetBaseObject().GetName())
        endIf
        if ref != None && ref.GetDisplayName() == "Candlestick"
            debug.Trace("Ref " + refIndex + ": " + ref.GetDisplayName())
            debug.Trace("Ref position: " + ref.X + ", " + ref.Y + ", " + ref.Z)
            debug.Trace("Ref angle: " + ref.getAngleX() + ", " + ref.getAngleY() + ", " + ref.getAngleZ())
            debug.Trace("Ref scale: " + ref.GetScale())
            debug.Trace("Ref enabled: " + ref.IsEnabled())
            debug.Trace("Ref Base Object Name: " + ref.GetBaseObject().GetName() + " (" + ref.GetBaseObject().GetType() + ")")
        endIf
        refIndex += 1
    endWhile
    debug.Trace("Done looping through refs")
endFunction

function Peddle(Actor buyer)
    Int buyerWealth = GetNPCWealth(buyer)
    debug.Trace("Buyer wealth: " + buyerWealth)
    Int totalItems = CMPeddlingChestRef.GetNumItems()
    String buyerName = buyer.GetBaseObject().GetName()
    debug.Trace("Chest total items " + totalItems)
    debug.Trace("Buyer: " + buyer)
    debug.Trace("Buyer BaseObject: " + buyer.GetBaseObject())
    debug.Trace("Buyer Name: " + buyer.GetBaseObject().GetName())
    debug.Trace("Buyer gold: " + buyer.GetItemCount(Gold001))
    Float buyerSpeech = buyer.GetAV("Speechcraft")
    debug.Trace("Buyer speechcraft: " + buyerSpeech)
    Float playerSpeech = PlayerRef.GetAV("Speechcraft")
    debug.Trace("Player speechcraft: " + playerSpeech)
    if totalItems > 0
        Int randomItemIndex = Utility.RandomInt(0, totalItems - 1)
        Form formToSell = CMPeddlingChestRef.GetNthForm(randomItemIndex)
        debug.Trace("formToSell" + formToSell + " " + formToSell.GetName())
        Int numOfForm = CMPeddlingChestRef.GetItemCount(formToSell)
        debug.Trace("Chest has " + numOfForm)
        Int numOfFormToSell = Utility.RandomInt(1, numOfForm)
        debug.Trace("Selling " + numOfFormToSell)
        Int formPrice = GetFormGoldValue(formToSell)
        Int formTotal = formPrice * numOfFormToSell
        debug.Trace("For gold: " + formTotal)
        String formName = formToSell.GetName()

        debug.Notification(buyerName + " wants to buy " + numOfFormToSell + " " + \
                           formName + "(s).")
        Int[] playerDecision = HaggleMenu(numOfFormToSell, formPrice, formTotal, formName, buyerName)
        Int outcome = playerDecision[0]
        Int bidPrice = playerDecision[1]
        Int offerPrice = playerDecision[1]
        Int haggleNumOfForm = numOfFormToSell
        Int[] buyerDecision
        while outcome
            buyerDecision = BuyerAcceptRejectOrCounter(buyerWealth, buyerSpeech, playerSpeech, formToSell, \
                                                       numOfFormToSell, numOfForm, formPrice, bidPrice)
            outcome = buyerDecision[0]
            haggleNumOfForm = buyerDecision[1]
            bidPrice = buyerDecision[2]
            if buyerDecision[0] == 0 ; Buyer Reject
            elseif buyerDecision[0] == 1 ; Buyer Accept
                Int haggleGold = numOfFormToSell * bidPrice
                CMPeddlingChestRef.RemoveItem(formToSell, numOfFormToSell)
                buyer.AddItem(formToSell, numOfFormToSell)
                PlayerRef.AddItem(Gold001, haggleGold)
                ReweighPeddlingInventory()

                debug.Notification(numOfFormToSell + " " + formName + "(s) removed from Merchandise")
                return
            elseif buyerDecision[0] == 2 ; Buyer Counterbid
                playerDecision = HaggleMenuCounter(haggleNumOfForm, formPrice, formTotal, bidPrice, offerPrice, \
                                                   formName, buyerName)
                outcome = playerDecision[0]
                bidPrice = playerDecision[1]
            elseif buyerDecision[0] == 3 ; Buyer Counter num
                Int haggleFormTotal = formPrice * haggleNumOfForm
                Bool playerChoice = HaggleMenuCountChange(numOfFormToSell, haggleNumOfForm, formPrice, \
                                                          haggleFormTotal, bidPrice, formName, buyerName)
                if playerChoice ; Player Accept
                    Int haggleGold = haggleNumOfForm * bidPrice
                    CMPeddlingChestRef.RemoveItem(formToSell, haggleNumOfForm)
                    buyer.AddItem(formToSell, haggleNumOfForm)
                    PlayerRef.AddItem(Gold001, haggleGold)
                    ReweighPeddlingInventory()

                    debug.Notification(haggleNumOfForm + " " + formName + "(s) removed from Merchandise")
                else ; Player Reject
                    outcome = 0
                endif
            endif
        endWhile
        debug.Notification("Trade rejected.")
    else
        debug.Notification("You have no merchandise to sell.")
    endif
endFunction

Int[] function HaggleMenu(Int numOfFormToSell, Int formPrice, Int formTotal, String formName, String buyerName)
    Int haggleDelta = 0
    Int hagglePrice = formPrice + haggleDelta
    Int haggleTotal = hagglePrice * numOfFormToSell
    Int profitGold = haggleTotal - formTotal
    Float profitPercent = GetProfitPercent(profitGold, formTotal)
    Bool menuOpen = true
    Int[] decision = new Int[2]
    Int buttonPressed = 8

    while buttonPressed == 8
        buttonPressed = CMPeddlingHaggleStart.Show(numOfFormToSell, formPrice, hagglePrice, \
                                                   haggleTotal, profitPercent, profitGold)
        if buttonPressed == 8
            debug.Notification(buyerName + " wants to buy " + numOfFormToSell + " " + \
                               formName + "(s).")
        endif
    endWhile

    while menuOpen
        if buttonPressed == -1
        elseif buttonPressed == 0
            menuOpen = false
            decision[0] = 0
            decision[1] = hagglePrice
            return decision
        elseif buttonPressed == 1
            haggleDelta -= 100
            hagglePrice = formPrice + haggleDelta
            if hagglePrice < 0
                haggleDelta -= hagglePrice
                hagglePrice = 0
            endif
            haggleTotal = hagglePrice * numOfFormToSell
            profitGold = haggleTotal - formTotal
            profitPercent = GetProfitPercent(profitGold, formTotal)
            buttonPressed = CMPeddlingHaggleStartAdjust.Show(haggleDelta, numOfFormToSell, formPrice, hagglePrice, \
                                                             haggleTotal, profitPercent, profitGold)
        elseif buttonPressed == 2
            haggleDelta -= 10
            hagglePrice = formPrice + haggleDelta
            if hagglePrice < 0
                haggleDelta -= hagglePrice
                hagglePrice = 0
            endif
            haggleTotal = hagglePrice * numOfFormToSell
            profitGold = haggleTotal - formTotal
            profitPercent = GetProfitPercent(profitGold, formTotal)
            buttonPressed = CMPeddlingHaggleStartAdjust.Show(haggleDelta, numOfFormToSell, formPrice, hagglePrice, \
                                                             haggleTotal, profitPercent, profitGold)
        elseif buttonPressed == 3
            haggleDelta -= 1
            hagglePrice = formPrice + haggleDelta
            if hagglePrice < 0
                haggleDelta -= hagglePrice
                hagglePrice = 0
            endif
            haggleTotal = hagglePrice * numOfFormToSell
            profitGold = haggleTotal - formTotal
            profitPercent = GetProfitPercent(profitGold, formTotal)
            buttonPressed = CMPeddlingHaggleStartAdjust.Show(haggleDelta, numOfFormToSell, formPrice, hagglePrice, \
                                                             haggleTotal, profitPercent, profitGold)
        elseif buttonPressed == 4
            ; TODO: Auto Haggle
            menuOpen = false
            decision[0] = 0
            decision[1] = hagglePrice
            return decision
        elseif buttonPressed == 5
            haggleDelta += 1
            hagglePrice = formPrice + haggleDelta
            haggleTotal = hagglePrice * numOfFormToSell
            profitGold = haggleTotal - formTotal
            profitPercent = GetProfitPercent(profitGold, formTotal)
            buttonPressed = CMPeddlingHaggleStartAdjust.Show(haggleDelta, numOfFormToSell, formPrice, hagglePrice, \
                                                             haggleTotal, profitPercent, profitGold)
        elseif buttonPressed == 6
            haggleDelta += 10
            hagglePrice = formPrice + haggleDelta
            haggleTotal = hagglePrice * numOfFormToSell
            profitGold = haggleTotal - formTotal
            profitPercent = GetProfitPercent(profitGold, formTotal)
            buttonPressed = CMPeddlingHaggleStartAdjust.Show(haggleDelta, numOfFormToSell, formPrice, hagglePrice, \
                                                             haggleTotal, profitPercent, profitGold)
        elseif buttonPressed == 7
            haggleDelta += 100
            hagglePrice = formPrice + haggleDelta
            haggleTotal = hagglePrice * numOfFormToSell
            profitGold = haggleTotal - formTotal
            profitPercent = GetProfitPercent(profitGold, formTotal)
            buttonPressed = CMPeddlingHaggleStartAdjust.Show(haggleDelta, numOfFormToSell, formPrice, hagglePrice, \
                                                             haggleTotal, profitPercent, profitGold)
        elseif buttonPressed == 8
            debug.Notification(buyerName + " wants to buy " + numOfFormToSell + " " + \
                               formName + "(s).")
            buttonPressed = CMPeddlingHaggleStartAdjust.Show(haggleDelta, numOfFormToSell, formPrice, hagglePrice, \
                                                             haggleTotal, profitPercent, profitGold)
        elseif buttonPressed == 9
            menuOpen = false
            decision[0] = 1
            decision[1] = hagglePrice
            return decision
        endif
    endWhile
endFunction

Int[] function HaggleMenuCounter(Int numOfFormToSell, Int formPrice, Int formTotal, Int buyerPrice, \
                                 Int offerPrice, String formName, String buyerName)
    Int buyerTotal = buyerPrice * numOfFormToSell
    Int haggleDelta = 0
    Int hagglePrice = buyerPrice + haggleDelta
    Int haggleTotal = hagglePrice * numOfFormToSell
    Int profitGold = haggleTotal - formTotal
    Float profitPercent = GetProfitPercent(profitGold, formTotal)
    Int offerTotal = offerPrice * numOfFormToSell
    Int buyerDelta = buyerPrice - offerPrice
    Bool menuOpen = true
    Int[] decision = new Int[2]
    Int buttonPressed = 8

    while buttonPressed == 8
        buttonPressed = CMPeddlingHaggleCounterStart.Show(buyerDelta, numOfFormToSell, formPrice, offerPrice, \
                                                          offerTotal, hagglePrice, buyerTotal, profitPercent, \
                                                          profitGold)
        if buttonPressed == 8
            debug.Notification(buyerName + " wants to buy " + numOfFormToSell + " " + \
                               formName + "(s).")
        endif
    endWhile

    while menuOpen
        if buttonPressed == -1
        elseif buttonPressed == 0
            menuOpen = false
            decision[0] = 0
            decision[1] = hagglePrice
            return decision
        elseif buttonPressed == 1
            haggleDelta -= 100
            hagglePrice = buyerPrice + haggleDelta
            if hagglePrice < 0
                haggleDelta -= hagglePrice
                hagglePrice = 0
            endif
            haggleTotal = hagglePrice * numOfFormToSell
            profitGold = haggleTotal - formTotal
            profitPercent = GetProfitPercent(profitGold, formTotal)
            buttonPressed = CMPeddlingHaggleCounter.Show(haggleDelta, numOfFormToSell, formPrice, buyerPrice, \
                                                         buyerTotal, hagglePrice, haggleTotal, profitPercent, \
                                                         profitGold)
        elseif buttonPressed == 2
            haggleDelta -= 10
            hagglePrice = buyerPrice + haggleDelta
            if hagglePrice < 0
                haggleDelta -= hagglePrice
                hagglePrice = 0
            endif
            haggleTotal = hagglePrice * numOfFormToSell
            profitGold = haggleTotal - formTotal
            profitPercent = GetProfitPercent(profitGold, formTotal)
            buttonPressed = CMPeddlingHaggleCounter.Show(haggleDelta, numOfFormToSell, formPrice, buyerPrice, \
                                                         buyerTotal, hagglePrice, haggleTotal, profitPercent, \
                                                         profitGold)
        elseif buttonPressed == 3
            haggleDelta -= 1
            hagglePrice = buyerPrice + haggleDelta
            if hagglePrice < 0
                haggleDelta -= hagglePrice
                hagglePrice = 0
            endif
            haggleTotal = hagglePrice * numOfFormToSell
            profitGold = haggleTotal - formTotal
            profitPercent = GetProfitPercent(profitGold, formTotal)
            buttonPressed = CMPeddlingHaggleCounter.Show(haggleDelta, numOfFormToSell, formPrice, buyerPrice, \
                                                         buyerTotal, hagglePrice, haggleTotal, profitPercent, \
                                                         profitGold)
        elseif buttonPressed == 4
            ; TODO: Auto Haggle
            menuOpen = false
            decision[0] = 0
            decision[1] = hagglePrice
        elseif buttonPressed == 5
            haggleDelta += 1
            hagglePrice = buyerPrice + haggleDelta
            haggleTotal = hagglePrice * numOfFormToSell
            profitGold = haggleTotal - formTotal
            profitPercent = GetProfitPercent(profitGold, formTotal)
            buttonPressed = CMPeddlingHaggleCounter.Show(haggleDelta, numOfFormToSell, formPrice, buyerPrice, \
                                                         buyerTotal, hagglePrice, haggleTotal, profitPercent, \
                                                         profitGold)
        elseif buttonPressed == 6
            haggleDelta += 10
            hagglePrice = buyerPrice + haggleDelta
            haggleTotal = hagglePrice * numOfFormToSell
            profitGold = haggleTotal - formTotal
            profitPercent = GetProfitPercent(profitGold, formTotal)
            buttonPressed = CMPeddlingHaggleCounter.Show(haggleDelta, numOfFormToSell, formPrice, buyerPrice, \
                                                         buyerTotal, hagglePrice, haggleTotal, profitPercent, \
                                                         profitGold)
        elseif buttonPressed == 7
            haggleDelta += 100
            hagglePrice = buyerPrice + haggleDelta
            haggleTotal = hagglePrice * numOfFormToSell
            profitGold = haggleTotal - formTotal
            profitPercent = GetProfitPercent(profitGold, formTotal)
            buttonPressed = CMPeddlingHaggleCounter.Show(haggleDelta, numOfFormToSell, formPrice, buyerPrice, \
                                                         buyerTotal, hagglePrice, haggleTotal, profitPercent, \
                                                         profitGold)
        elseif buttonPressed == 8
            debug.Notification(buyerName + " wants to buy " + numOfFormToSell + " " + \
                               formName + "(s).")
            buttonPressed = CMPeddlingHaggleCounter.Show(haggleDelta, numOfFormToSell, formPrice, buyerPrice, \
                                                         buyerTotal, hagglePrice, haggleTotal, profitPercent, \
                                                         profitGold)
        elseif buttonPressed == 9
            menuOpen = false
            decision[0] = 1
            decision[1] = hagglePrice
            return decision
        endif
    endWhile
endFunction


Bool function HaggleMenuCountChange(Int numOfFormToSell, Int haggleNumOfForm, Int formPrice, Int formTotal, \
                                    Int bidPrice, String formName, String buyerName)
    Int haggleGold = haggleNumOfForm * bidPrice
    Int profitGold = haggleGold - formTotal
    Float profitPercent = GetProfitPercent(profitGold, formTotal)
    Int buyerItemCountDelta = haggleNumOfForm - numOfFormToSell
    Bool menuOpen = true
    Int buttonPressed = 8

    while buttonPressed == 8
        buttonPressed = CMPeddlingHaggleCountChange.Show(buyerItemCountDelta, haggleNumOfForm, formPrice, \
                                                         bidPrice, haggleGold, profitPercent, profitGold)
        if buttonPressed == 8
            debug.Notification(buyerName + " wants to buy " + haggleNumOfForm + " " + \
                               formName + "(s).")
        endif
    endWhile

    while menuOpen
        if buttonPressed == 0 ; Player Reject
            menuOpen = false
            return false
        elseif buttonPressed == 1
            debug.Notification(buyerName + " wants to buy " + numOfFormToSell + " " + \
                               formName + "(s).")
            buttonPressed = CMPeddlingHaggleCountChange.Show(buyerItemCountDelta, haggleNumOfForm, formPrice, \
                                                             bidPrice, haggleGold, profitPercent, profitGold)
        elseif buttonPressed == 2 ; Player Accept
            menuOpen = false
            return true
        endif
    endWhile
endFunction

Int[] function BuyerAcceptRejectOrCounter(Int buyerWealth, Float buyerSpeech, Float playerSpeech, Form formToBuy, \
                                          Int numOfFormToBuy, Int numOfFormAvailable, Int formPrice, Int bidPrice)
    Int[] decisionValues = new Int[3]
    Int decision = Utility.RandomInt(0, 3)
    Float speechDelta = buyerSpeech - playerSpeech
    debug.Trace("speechDelta: " + priceToWealthRatio)
    Int haggleDelta = bidPrice - formPrice
    debug.Trace("haggleDelta: " + priceToWealthRatio)
    Int totalPrice = bidPrice * numOfFormToBuy
    debug.Trace("totalPrice: " + priceToWealthRatio)
    Float priceToWealthRatio = totalPrice / buyerWealth
    debug.Trace("priceToWealthRatio: " + priceToWealthRatio)
    Float haggleToPriceRatio = haggleDelta / formPrice
    debug.Trace("haggleToPriceRatio: " + haggleToPriceRatio)
    Float speechRatio = speechDelta / playerSpeech
    debug.Trace("speechRatio: " + haggleToPriceRatio)
    Float priceFairness = haggleToPriceRatio + speechRatio
    debug.Trace("priceFairness: " + priceFairness)
    if priceFairness < 0
        ; Good price
        if priceToWealthRatio < 0.5 && (numOfFormToBuy < numOfFormAvailable)
            ; Stock up, increase count
            Int countMax = ((0.75 * buyerWealth) / bidPrice) as Int
            if countMax < 1
                ; Reject
                decisionValues[0] = 0
                decisionValues[1] = numOfFormToBuy
                decisionValues[2] = bidPrice
                return decisionValues
            endif
            ; Because Math.min is not a thing aparently??
            Int max = countMax
            if numOfFormAvailable > countMax
                max = numOfFormAvailable
            endif
            Int newCount = Utility.RandomInt(numOfFormToBuy, max)
            decisionValues[0] = 3
            decisionValues[1] = newCount
            decisionValues[2] = bidPrice
            return decisionValues
        elseif priceToWealthRatio > 0.75
            if numOfFormToBuy > 1
                ; Decrease count
                Int countMax = (0.75 * buyerWealth) as Int / bidPrice as Int
                if countMax < 1
                    ; Reject
                    decisionValues[0] = 0
                    decisionValues[1] = numOfFormToBuy
                    decisionValues[2] = bidPrice
                    return decisionValues
                endif
                Int newCount = Utility.RandomInt(1, countMax)
                decisionValues[0] = 3
                decisionValues[1] = newCount
                decisionValues[2] = bidPrice
                return decisionValues
            else
                ; Reject
                decisionValues[0] = 0
                decisionValues[1] = numOfFormToBuy
                decisionValues[2] = bidPrice
                return decisionValues
            endif
        endif
    elseif priceFairness > 2.0
        ; price too absurd
        ; Reject
        decisionValues[0] = 0
        decisionValues[1] = numOfFormToBuy
        decisionValues[2] = bidPrice
        return decisionValues
    elseif priceFairness > 0.2
        ; Price unfair
        ; Counter
        Int newBid = ((0.2 - speechRatio) * formPrice) as Int + formPrice as Int
        decisionValues[0] = decision
        decisionValues[1] = numOfFormToBuy
        decisionValues[2] = newBid
        return decisionValues
    else
        ; Price fair
        if priceToWealthRatio > 0.5
            if numOfFormToBuy > 1
                ; Decrease count
                Int countMax = (0.5 * buyerWealth) as Int / bidPrice as Int
                Int newCount = Utility.RandomInt(0, countMax)
                if newCount > 0
                    decisionValues[0] = 3
                    decisionValues[1] = newCount
                    decisionValues[2] = bidPrice
                    return decisionValues
                else
                    ; Reject
                    decisionValues[0] = 0
                    decisionValues[1] = numOfFormToBuy
                    decisionValues[2] = bidPrice
                    return decisionValues
                endif
            else
                ; Reject
                decisionValues[0] = 0
                decisionValues[1] = numOfFormToBuy
                decisionValues[2] = bidPrice
                return decisionValues
            endif
        endif
    endif

    ; Accept
    decisionValues[0] = 1
    decisionValues[1] = numOfFormToBuy
    decisionValues[2] = bidPrice
    return decisionValues
endFunction

; Thanks to Puff The Magic Dragon for the idea for this calculation from their breezehome store mod:
; https://www.nexusmods.com/skyrim/mods/60466/
; https://forums.nexusmods.com/index.php?/topic/2323334-getgoldvalue-on-enchantedupgraded-items/?p=20447629
Int function GetFormGoldValue(Form theForm)
    Armor anArmor = theForm as Armor
    Weapon aWeapon = theForm as Weapon
    Enchantment ench
    Int enchValue = 0
    Int charge = 0
    Int goldValue = theForm.GetGoldValue()
    if anArmor || aWeapon
        ObjectReference droppedItem = CMPeddlingChestRef.dropObject(theForm, 1)
        CMPeddlingChestRef.AddItem(theForm, 1)
        goldValue = droppedItem.GetGoldValue()
        if anArmor
            ench = anArmor.GetEnchantment()
            enchValue = ench.GetGoldValue()
        elseif aWeapon
            ench = aWeapon.GetEnchantment()
            charge = droppedItem.GetItemCharge() as Int
            enchValue = (ench.GetGoldValue() * 8) + (charge * 0.12) as Int
        endif
        droppedItem.Delete()
        droppedItem = None
        goldValue += enchValue
    endif
    return goldValue
; Alternative calculation that doesn't work :(
;    if ench
;        Int index = 0
;        while index < ench.GetNumEffects()
;            MagicEffect effect = ench.GetNthEffectMagicEffect(index)
;            Float effectBaseCost = effect.GetBaseCost()
;            Float mag = ench.GetNthEffectMagnitude(index)
;            Int dur = ench.GetNthEffectDuration(index)
;            goldValue = goldValue + ( (effectBaseCost * 8) * (Math.pow(mag, 1.1)) * (Math.pow(dur / 10, 1.1)) ) as Int
;            index += 1
;        endWhile
;    endif
endFunction

Float function GetProfitPercent(Int profitGold, Int formTotal)
    Float profitPercent
    if formTotal == 0
        profitPercent = profitGold * 100 as Float
    else
        profitPercent = (profitGold as Float / formTotal as Float) * 100
    endif
    return profitPercent
endFunction

Int function GetNPCWealth(Actor npc)
    Int wealth = 0
    wealth += npc.GetGoldAmount()
    wealth += npc.GetBribeAmount()
    Int level = npc.GetLevel()
    wealth += Utility.RandomInt(level, level * 4)

    if npc.IsInFaction(JobJarlFaction)
        wealth += 700
    elseif npc.IsInFaction(JobStewardFaction)
        wealth += 600
    elseif npc.IsInFaction(JobHousecarlFaction)
        wealth += 550
    elseif npc.IsInFaction(JobCourtWizardFaction)
        wealth += 550
    elseif npc.IsInFaction(JobMerchantFaction)
        wealth += 500
    elseif npc.IsInFaction(JobHostlerFaction)
        wealth += 400
    elseif npc.IsInFaction(JobFenceFaction)
        wealth += 350
    elseif npc.IsInFaction(KhajiitCaravanFaction)
        wealth += 300
    elseif npc.IsInFaction(JobInnkeeperFaction)
        wealth += 300
    elseif npc.IsInFaction(JobCarriageFaction)
        wealth += 250
    elseif npc.IsInFaction(JobBardFaction)
        wealth += 200
    elseif npc.IsInFaction(GuardDialogueFaction)
        wealth += 200
    elseif npc.IsInFaction(JobFarmerFaction)
        wealth += 100
    elseif npc.IsInFaction(JobMinerFaction)
        wealth += 100
    elseif npc.IsInFaction(JobPriestFaction)
        wealth += 100
    elseif npc.IsInFaction(FavorJobsBeggarsFaction)
        wealth -= 100
    elseif npc.IsInFaction(FavorJobsDrunksFaction)
        wealth -= 100
    endif

    Int totalItemValue = 0
    Int formIndex = npc.GetNumItems()
    while formIndex > 0
        formIndex -= 1
        Form nthForm = npc.GetNthForm(formIndex)
        Int numOfForm = npc.GetItemCount(nthForm)
        totalItemValue += nthForm.GetGoldValue() * numOfForm
    endWhile
    wealth += totalItemValue

    if npc.WornHasKeyword(ClothingRich)
        wealth += 100
    endif
    if npc.WornHasKeyword(ClothingPoor)
        wealth -= 100
    endif
    if npc.WornHasKeyword(JewelryExpensive)
        wealth += 100
    endif

    if wealth < 0
        wealth = Utility.RandomInt(0, 25)
    endif
    return wealth
endFunction
