scriptname BRPublicMerchChestScript extends ObjectReference

Keyword property BRLinkMerchShelf auto
Actor property PlayerRef auto
Quest property BRQuest auto
FormList property BREmptyFormList auto

event OnInit()
    Debug.Trace("BRPublicMerchChestScript OnInit")
    AddInventoryEventFilter(BREmptyFormList)
endEvent

event OnMenuClose(string menuName)
    if menuName == "ContainerMenu"
        Debug.Trace("BRPublicMerchChestScript container menu closed")
        BRQuestScript BRScript = BRQuest as BRQuestScript
        if BRScript.ActiveShopId == BRScript.ShopId
            ; TODO: the assumption that player is in shop cell may be incorrect
            Cell shopCell = PlayerRef.GetParentCell()

            bool result = BRMerchandiseList.Create(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ShopId, shopCell, BRScript.ActiveShopShelves, self)
            if !result
                Debug.MessageBox("Failed to save shop merchandise.\n\n" + BRScript.BugReportCopy)
            endif
        endif
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
        Debug.Trace("BRPublicMerchChestScript container was opened")
        RegisterForMenu("ContainerMenu")
    endif
endEvent

Event OnItemAdded(Form baseItem, int itemCount, ObjectReference itemRef, ObjectReference sourceContainer)
    if sourceContainer == PlayerRef
        ; TODO: implement selling, for now it rejects all additions
        debug.Notification("Trade rejected")
        RemoveAllItems()
        PlayerRef.AddItem(baseItem, 1)
    endif
endEvent

event OnCreateMerchandiseSuccess(bool created)
    Debug.Trace("BRPublicMerchChestScript OnCreateMerchandiseSuccess created: " + created)
    if created
        BRQuestScript BRScript = BRQuest as BRQuestScript
        Debug.Notification("Saved merchandise successfully")

    else
        Debug.Trace("BRPublicMerchChestScript no container changes to save to the server")
    endif
endEvent

event OnCreateMerchandiseFail(string error)
    Debug.Trace("BRPublicMerchChestScript OnCreateMerchandiseFail error: " + error)
    BRQuestScript BRScript = BRQuest as BRQuestScript
    Debug.MessageBox("Failed to save shop merchandise.\n\n" + error + "\n\n" + BRScript.BugReportCopy)
endEvent