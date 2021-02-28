scriptname BRMerchChestScript extends ObjectReference

Keyword property BRLinkItemRef auto
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
bool property pendingTransaction auto

event OnInit()
    debug.Trace("BRMerchChestScript OnInit")
    AddInventoryEventFilter(BREmptyFormList)
endEvent

event OnMenuClose(string menuName)
    if menuName == "BarterMenu"
        debug.Trace("BRMerchChestScript barter menu closed, stop listending to add/remove events")
        AddInventoryEventFilter(BREmptyFormList)
        UnregisterForMenu("BarterMenu")
    elseif menuName == "ContainerMenu"
        debug.Trace("BRMerchChestScript container menu closed")
        BRQuestScript BRScript = BRQuest as BRQuestScript
        if BRScript.ActiveShopId == BRScript.ShopId
            int gold = self.GetItemCount(Gold001)
            if gold != BRScript.ShopGold
                BRScript.UpdateShop(BRScript.ShopId, BRScript.ShopName, BRScript.ShopDescription, gold, BRScript.ShopType, BRScript.ShopKeywords, BRScript.ShopKeywordsExclude)
            endif
            ; TODO: the assumption that player is in shop cell may be incorrect
            Cell shopCell = PlayerRef.GetParentCell()

            bool result = BRMerchandiseList.Create(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ShopId, shopCell, BRScript.ActiveShopShelves, self)
            if !result
                Debug.MessageBox("Failed to save shop merchandise.\n\n" + BRScript.BugReportCopy)
            endif
        endif
        UnregisterForMenu("ContainerMenu")
    endif
endEvent

event OnMenuOpen(string menuName)
    if menuName == "BarterMenu"
        debug.Trace("BRMerchChestScript barter menu opened, start listening to add/remove events")
        RemoveAllInventoryEventFilters()
    elseif menuName == "ContainerMenu"
        debug.Trace("BRMerchChestScript container menu opened")
    endif
endEvent

Event OnItemRemoved(Form baseItem, int itemCount, ObjectReference itemRef, ObjectReference destContainer)
    if destContainer == PlayerRef
        debug.Trace("BRMerchChestScript item moved to player: " + itemRef + " " + baseItem + " " + itemCount)
        if pendingTransaction
            debug.Notification("Previous transaction still in progress! Cancelling new transaction.")
            ; TODO: undo transaction
            ; PlayerRef.RemoveItem(baseItem, itemCount, self)
        else
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
    endif
endEvent

Event OnItemAdded(Form baseItem, int itemCount, ObjectReference itemRef, ObjectReference sourceContainer)
    if sourceContainer == PlayerRef
        debug.Trace("BRMerchChestScript item moved to container from player: " + itemRef + " " + baseItem + " " + itemCount)
        if pendingTransaction
            ; self.RemoveItem(baseItem, itemCount, PlayerRef)
            ; TODO: undo transaction
        else
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
    endif
endEvent

function MaybeCreateTransaction()
    if boughtAmount > 0 && boughtItemBase && boughtItemQuantity > 0
        debug.Trace("BRMerchChestScript MaybeCreateTransaction creating buy transaction")
        BRQuestScript BRScript = BRQuest as BRQuestScript
        pendingTransaction = true
        bool result = BRTransaction.CreateFromVendorSale(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, false, boughtItemQuantity, boughtAmount, boughtItemBase, self)
        if !result
            Debug.MessageBox("Failed to buy merchandise.\n\n" + BRScript.BugReportCopy)
        endif
    elseif soldAmount > 0 && soldItemBase && soldItemQuantity > 0
        debug.Trace("BRMerchChestScript MaybeCreateTransaction creating sell transaction")
        BRQuestScript BRScript = BRQuest as BRQuestScript
        pendingTransaction = true
        bool result = BRTransaction.CreateFromVendorSale(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, true, soldItemQuantity, soldAmount, soldItemBase, self)
        if !result
            Debug.MessageBox("Failed to sell merchandise.\n\n" + BRScript.BugReportCopy)
        endif
    else
        debug.Trace("BRMerchChestScript MaybeCreateTransaction sale not yet finalized")
    endif
endFunction

function RefreshMerchandise()
    BRQuestScript BRScript = BRQuest as BRQuestScript

    ; TODO: the assumption that player is in shop cell may be incorrect
    Cell shopCell = PlayerRef.GetParentCell()
    if !BRMerchandiseList.Load(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, shopCell, BRScript.ActiveShopShelves, self)
        Debug.MessageBox("Failed to load shop merchandise.\n\n" + BRScript.BugReportCopy)
    endif
endFunction

event OnCreateMerchandiseSuccess(bool created)
    Debug.Trace("BRMerchChestScript OnCreateMerchandiseSuccess created: " + created)
    if created
        BRQuestScript BRScript = BRQuest as BRQuestScript
        Debug.Notification("Saved merchandise successfully")
    else
        Debug.Trace("BRMerchChestScript no container changes to save to the server")
    endif
endEvent

event OnCreateMerchandiseFail(bool isServerError, int status, string title, string detail, string otherError)
    BRQuestScript BRScript = BRQuest as BRQuestScript
    if isServerError
        Debug.Trace("BRMerchChestScript OnCreateMerchandiseFail server error: " + status + " " + title + ": " + detail)
        Debug.MessageBox("Failed to save shop merchandise.\n\nServer " + status + " " + title + ": " + detail + "\n\n" + BRScript.BugReportCopy)
    else
        Debug.Trace("BRMerchChestScript OnCreateMerchandiseFail other error: " + otherError)
        Debug.MessageBox("Failed to save shop merchandise.\n\n" + otherError + "\n\n" + BRScript.BugReportCopy)
    endif
endEvent

event OnCreateTransactionSuccess(int id, int quantity, int amount)
    debug.Trace("BRMerchChestScript OnCreateTransactionSuccess id: " + id + " quantity: " + quantity + " amount: " + amount)
    ObjectReference merchRef = self.GetLinkedRef(BRLinkItemRef)
    RefreshMerchandise()
    pendingTransaction = false
    boughtAmount = 0
    boughtItemBase = None
    boughtItemRef = None
    boughtItemQuantity = 0
    soldAmount = 0
    soldItemBase = None
    soldItemRef = None
    soldItemQuantity = 0
endEvent

; TODO: gracefully handle expected error cases (e.g. someone else buys all of item before this player can buy them)
Event OnCreateTransactionFail(bool isServerError, int status, string title, string detail, string otherError)
    BRQuestScript BRScript = BRQuest as BRQuestScript
    if isServerError
        Debug.Trace("BRMerchChestScript OnCreateTransactionFail server error: " + status + " " + title + ": " + detail)
        Debug.MessageBox("Failed to buy or sell merchandise.\n\nServer " + status + " " + title + ": " + detail + "\n\n" + BRScript.BugReportCopy)
    else
        Debug.Trace("BRMerchChestScript OnCreateTransactionFail other error: " + otherError)
        Debug.MessageBox("Failed to buy or sell merchandise.\n\n" + otherError + "\n\n" + BRScript.BugReportCopy)
    endif
    ; TODO Undo transaction
    ; if boughtItemBase
        ; PlayerRef.RemoveItem(boughtItemBase, boughtItemQuantity, self)
        ; PlayerRef.AddItem(Gold001, boughtAmount)
    ; elseif soldItemBase
        ; self.RemoveItem(soldItemBase, soldItemQuantity, PlayerRef)
        ; self.AddItem(Gold001, soldAmount)
    ; endif
    pendingTransaction = false
    boughtAmount = 0
    boughtItemBase = None
    boughtItemRef = None
    boughtItemQuantity = 0
    soldAmount = 0
    soldItemBase = None
    soldItemRef = None
    soldItemQuantity = 0
    RefreshMerchandise()
endEvent

event OnLoadMerchandiseSuccess(bool result)
    Debug.Trace("BRMerchChestScript OnLoadMerchandiseSuccess result: " + result)
    debug.MessageBox("Successfully loaded shop merchandise")
    BRQuestScript BRScript = BRQuest as BRQuestScript
    if !BRShop.RefreshGold(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, self)
        Debug.MessageBox("Failed to refresh shop gold.\n\n" + BRScript.BugReportCopy)
    endif

    ; TODO: the assumption that player is in shop cell may be incorrect
    Cell shopCell = PlayerRef.GetParentCell()
    while !BRMerchandiseList.ReplaceAll3D(shopCell)
        Debug.Trace("BRMerchandiseList.Replace3D returned false, waiting and trying again")
        Utility.Wait(0.05)
    endWhile
endEvent

event OnLoadMerchandiseFail(bool isServerError, int status, string title, string detail, string otherError)
    BRQuestScript BRScript = BRQuest as BRQuestScript
    if isServerError
        Debug.Trace("BRMerchChestScript OnLoadMerchandiseFail server error: " + status + " " + title + ": " + detail)
        Debug.MessageBox("Failed to load or clear shop merchandise.\n\nServer " + status + " " + title + ": " + detail + "\n\n" + BRScript.BugReportCopy)
    else
        Debug.Trace("BRMerchChestScript OnLoadMerchandiseFail other error: " + otherError)
        Debug.MessageBox("Failed to load or clear shop merchandise.\n\n" + otherError + "\n\n" + BRScript.BugReportCopy)
    endif
endEvent

event OnLoadShelfPageSuccess(bool result)
    Debug.Trace("BRMerchChestScript OnLoadShelfPageSuccess result: " + result)

    ; TODO: the assumption that player is in shop cell may be incorrect
    Cell shopCell = PlayerRef.GetParentCell()
    while !BRMerchandiseList.ReplaceAll3D(shopCell) ; replace all 3D or only refs linked to this chest's shelf?
        Debug.Trace("BRMerchandiseList.Replace3D returned false, waiting and trying again")
        Utility.Wait(0.05)
    endWhile
endEvent

event OnLoadShelfPageFail(bool isServerError, int status, string title, string detail, string otherError)
    BRQuestScript BRScript = BRQuest as BRQuestScript
    if isServerError
        Debug.Trace("BRMerchChestScript OnLoadShelfPageFail server error: " + status + " " + title + ": " + detail)
        Debug.MessageBox("Failed to load or clear page of shelf merchandise.\n\nServer " + status + " " + title + ": " + detail + "\n\n" + BRScript.BugReportCopy)
    else
        Debug.Trace("BRMerchChestScript OnLoadShelfPageFail other error: " + otherError)
        Debug.MessageBox("Failed to load or clear page of shelf merchandise.\n\n" + otherError + "\n\n" + BRScript.BugReportCopy)
    endif
endEvent

event OnRefreshShopGoldSuccess(int gold)
    Debug.Trace("BRMerchChestScript OnRefreshShopGoldSuccess gold: " + gold)
    BRQuestScript BRScript = BRQuest as BRQuestScript
    BRScript.ActiveShopGold = gold
    if BRScript.ActiveShopId == BRScript.ShopId
        BRScript.ShopGold = gold
    endif
endEvent

event OnRefreshShopGoldFail(bool isServerError, int status, string title, string detail, string otherError)
    BRQuestScript BRScript = BRQuest as BRQuestScript
    if isServerError
        Debug.Trace("BRMerchChestScript OnRefreshShopGoldFail server error: " + status + " " + title + ": " + detail)
        Debug.MessageBox("Failed to refresh shop gold.\n\nServer " + status + " " + title + ": " + detail + "\n\n" + BRScript.BugReportCopy)
    else
        Debug.Trace("BRMerchChestScript OnRefreshShopGoldFail other error: " + otherError)
        Debug.MessageBox("Failed to refresh shop gold.\n\n" + otherError + "\n\n" + BRScript.BugReportCopy)
    endif
endEvent