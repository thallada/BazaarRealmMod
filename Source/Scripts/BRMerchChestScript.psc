scriptname BRMerchChestScript extends ObjectReference

Keyword property BRLinkMerchShelf auto
Keyword property BRLinkMerchChest auto
Keyword property BRLinkItemRef auto
Keyword property BRLinkActivatorRef auto
Keyword property BRLinkMerchToggle auto
Keyword property BRLinkMerchNext auto
Keyword property BRLinkMerchPrev auto
Activator property ActivatorStatic auto
Actor property PlayerRef auto
Quest property BRQuest auto
MiscObject property Gold001 auto
FormList property BREmptyFormList auto

ObjectReference property boughtItemRef auto
Form property boughtItemBase auto
int property boughtItemQuantity auto
int property boughtAmount auto
ObjectReference property soldItemRef auto
Form property soldItemBase auto
int property soldItemQuantity auto
int property soldAmount auto

event OnInit()
    debug.Trace("BRMerchChestScript OnInit")
    AddInventoryEventFilter(BREmptyFormList)
endEvent

event OnMenuClose(string menuName)
    if menuName == "BarterMenu"
        debug.Trace("BRMerchChestScript barter menu closed, stop listending to add/remove events")
        AddInventoryEventFilter(BREmptyFormList)
        UnregisterForMenu("BarterMenu")
    endif
endEvent

event OnMenuOpen(string menuName)
    if menuName == "BarterMenu"
        debug.Trace("BRMerchChestScript barter menu opened, start listening to add/remove events")
        RemoveAllInventoryEventFilters()
    endif
endEvent

Event OnItemRemoved(Form baseItem, int itemCount, ObjectReference itemRef, ObjectReference destContainer)
    if destContainer == PlayerRef
        debug.Trace("BRMerchChestScript item moved to player: " + itemRef + " " + baseItem + " " + itemCount)
        if baseItem == Gold001 as Form
            soldAmount = itemCount
            MaybeCreateTransaction()
        else
            boughtItemRef = itemRef
            boughtItemBase = baseItem
            boughtItemQuantity = itemCount
            MaybeCreateTransaction()
        endif
    endif
endEvent

Event OnItemAdded(Form baseItem, int itemCount, ObjectReference itemRef, ObjectReference sourceContainer)
    if sourceContainer == PlayerRef
        debug.Trace("BRMerchChestScript item moved to container from player: " + itemRef + " " + baseItem + " " + itemCount)
        if baseItem == Gold001 as Form
            boughtAmount = itemCount
            MaybeCreateTransaction()
        else
            soldItemRef = itemRef
            soldItemBase = baseItem
            soldItemQuantity = itemCount
            MaybeCreateTransaction()
        endif
    endif
endEvent

function MaybeCreateTransaction()
    if boughtAmount > 0 && boughtItemBase && boughtItemQuantity > 0
        debug.Trace("BRMerchChestScript MaybeCreateTransaction creating buy transaction")
        BRQuestScript BRScript = BRQuest as BRQuestScript
        bool result = BRTransaction.CreateFromVendorSale(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, false, boughtItemQuantity, boughtAmount, boughtItemBase, self)
        if !result
            Debug.MessageBox("Failed to buy merchandise.\n\n" + BRScript.BugReportCopy)
        endif
        boughtAmount = 0
        boughtItemBase = None
        boughtItemRef = None
        boughtItemQuantity = 0
    elseif soldAmount > 0 && soldItemBase && soldItemQuantity > 0
        debug.Trace("BRMerchChestScript MaybeCreateTransaction creating sell transaction")
        BRQuestScript BRScript = BRQuest as BRQuestScript
        bool result = BRTransaction.CreateFromVendorSale(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, false, boughtItemQuantity, soldAmount, soldItemBase, self)
        if !result
            Debug.MessageBox("Failed to buy merchandise.\n\n" + BRScript.BugReportCopy)
        endif
        soldAmount = 0
        soldItemBase = None
        soldItemRef = None
        soldItemQuantity = 0
    else
        debug.Trace("BRMerchChestScript MaybeCreateTransaction sale not yet finalized")
    endif
endFunction

function RefreshMerchandise()
    BRQuestScript BRScript = BRQuest as BRQuestScript
    ObjectReference merchantShelf = self.GetLinkedRef(BRLinkMerchShelf)
    if !BRMerchandiseList.Refresh(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, merchantShelf, ActivatorStatic, BRLinkMerchShelf, BRLinkMerchChest, BRLinkItemRef, BRLinkActivatorRef, BRLinkMerchToggle, BRLinkMerchNext, BRLinkMerchPrev)
        Debug.MessageBox("Failed refresh merchandise.\n\n" + BRScript.BugReportCopy)
    endif
endFunction

event OnCreateTransactionSuccess(int id, int quantity, int amount)
    debug.Trace("BRMerchChestScript OnCreateTransactionSuccess id: " + id + " quantity: " + quantity + " amount: " + amount)
    ObjectReference merchRef = self.GetLinkedRef(BRLinkItemRef)
    RefreshMerchandise()
endEvent

; TODO: gracefully handle expected error cases (e.g. someone else buys all of item before this player can buy them)
Event OnCreateTransactionFail(string error)
    Debug.Trace("BRMerchChestScript OnCreateTransactionFail error: " + error)
    BRQuestScript BRScript = BRQuest as BRQuestScript
    Debug.MessageBox("Failed to buy merchandise.\n\n" + error + "\n\n" + BRScript.BugReportCopy)
    RefreshMerchandise()
endEvent