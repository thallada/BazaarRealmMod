scriptname BRPublicMerchChestScript extends ObjectReference

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
            bool result = BRMerchandiseList.Create(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ShopId, self)
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

event OnCreateMerchandiseSuccess(bool created, int id)
    Debug.Trace("BRPublicMerchChestScript OnCreateMerchandiseSuccess created: " + created + " id: " + id)
    if created
        BRQuestScript BRScript = BRQuest as BRQuestScript
        BRScript.MerchandiseListId = id;
        Debug.Notification("Saved merchandise successfully")

        ObjectReference merchantShelf = self.GetLinkedRef(BRLinkMerchShelf)
        if !BRMerchandiseList.Refresh(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, merchantShelf, ActivatorStatic, BRLinkMerchShelf, BRLinkMerchChest, BRLinkItemRef, BRLinkActivatorRef, BRLinkMerchToggle, BRLinkMerchNext, BRLinkMerchPrev)
            Debug.MessageBox("Failed refresh merchandise.\n\n" + BRScript.BugReportCopy)
        endif
    else
        Debug.Trace("BRPublicMerchChestScript no container changes to save to the server")
    endif
endEvent

event OnCreateMerchandiseFail(string error)
    Debug.Trace("BRPublicMerchChestScript OnCreateMerchandiseFail error: " + error)
    BRQuestScript BRScript = BRQuest as BRQuestScript
    Debug.MessageBox("Failed to save shop merchandise.\n\n" + error + "\n\n" + BRScript.BugReportCopy)
endEvent