scriptname BRPublicMerchChestScript extends ObjectReference

Keyword property BRLinkMerchChest auto
Actor property PlayerRef auto
Quest property BRQuest auto
FormList property BREmptyFormList auto
Message property BRSellMerchandise auto
MiscObject property Gold001 auto

event OnInit()
    Debug.Trace("BRPublicMerchChestScript OnInit")
    AddInventoryEventFilter(BREmptyFormList)
endEvent

event OnMenuClose(string menuName)
    if menuName == "ContainerMenu"
        Debug.Trace("BRPublicMerchChestScript container menu closed")
        UnregisterForMenu("ContainerMenu")
        AddInventoryEventFilter(BREmptyFormList)
    endif
endEvent

event OnMenuOpen(string menuName)
    if menuName == "ContainerMenu"
        debug.Trace("BRPublicMerchChestScript container menu opened, start listening to add/remove events")
        BRQuestScript BRScript = BRQuest as BRQuestScript
        if BRScript.ActiveShopId != BRScript.ShopId
            debug.Notification("Add items to chest to sell them to this shop")
            RemoveAllInventoryEventFilters()
        endif
    endif
endEvent

event OnActivate(ObjectReference akActionRef)
    if akActionRef == PlayerRef
        Debug.Trace("BRPublicMerchChestScript container was activated")
    endif
endEvent

Event OnItemAdded(Form baseItem, int itemCount, ObjectReference itemRef, ObjectReference sourceContainer)
    if sourceContainer == PlayerRef
        BRQuestScript BRScript = BRQuest as BRQuestScript
        Form selectedMerchandiseRepl = BRScript.SelectedMerchandise.GetBaseObject()
        selectedMerchandiseRepl.SetName(baseItem.GetName())
        ObjectReference privateChest = GetLinkedRef(BRLinkMerchChest)
        int price = BRMerchandiseList.GetSellPrice(baseItem)
        if BRSellMerchandise.Show(itemCount, price * itemCount, price) == 0
            debug.Trace("BRPublicMerchChestScript creating sell transaction")
            bool result = BRTransaction.CreateFromVendorSale(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, true, itemCount, price * itemCount, baseItem, privateChest)
            if !result
                Debug.MessageBox("Failed to sell merchandise.\n\n" + BRScript.BugReportCopy)
            else
                RemoveAllItems()
                PlayerRef.AddItem(Gold001, price * itemCount)
            endif
        else
            debug.Notification("Trade cancelled")
            RemoveAllItems()
            PlayerRef.AddItem(baseItem, itemCount)
        endif
        ; TODO: trade rejection
    endif
endEvent