Scriptname BRMerchChestScript extends ObjectReference

Keyword property BRLinkMerchShelf auto
Keyword property BRLinkMerchChest auto
Keyword property BRLinkItemRef auto
Keyword property BRLinkActivatorRef auto
Keyword property BRLinkMerchToggle auto
Keyword property BRLinkMerchNext auto
Keyword property BRLinkMerchPrev auto
Activator property ActivatorStatic auto
Actor Property PlayerRef Auto
Quest Property BRQuest Auto

event OnMenuClose(string menuName)
    if menuName == "ContainerMenu"
        Debug.Trace("BRMerchChestScript container menu closed")
        BRQuestScript BRScript = BRQuest as BRQuestScript
        bool result = BRMerchandiseList.Create(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ShopId, self)
        if !result
            Debug.MessageBox("Failed to save shop merchandise.\n\n" + BRScript.BugReportCopy)
        endif
        UnregisterForMenu("ContainerMenu")
    endif
endEvent

event OnActivate(ObjectReference akActionRef)
    if akActionRef == PlayerRef
        Debug.Trace("BRMerchChestScript container was opened")
        RegisterForMenu("ContainerMenu")
    endif
endEvent

event OnCreateMerchandiseSuccess(bool created, int id)
    Debug.Trace("BRMerchChestScript OnCreateMerchandiseSuccess created: " + created + " id: " + id)
    if created
        BRQuestScript BRScript = BRQuest as BRQuestScript
        BRScript.MerchandiseListId = id;
        Debug.Notification("Saved merchandise successfully")

        ObjectReference merchantShelf = self.GetLinkedRef(BRLinkMerchShelf)
        if !BRMerchandiseList.Refresh(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, merchantShelf, ActivatorStatic, BRLinkMerchShelf, BRLinkMerchChest, BRLinkItemRef, BRLinkActivatorRef, BRLinkMerchToggle, BRLinkMerchNext, BRLinkMerchPrev)
            Debug.MessageBox("Failed refresh merchandise.\n\n" + BRScript.BugReportCopy)
        endif
    else
        Debug.Trace("BRMerchChestScript no container changes to save to the server")
    endif
endEvent

event OnCreateMerchandiseFail(string error)
    Debug.Trace("BRMerchChestScript OnCreateMerchandiseFail error: " + error)
    BRQuestScript BRScript = BRQuest as BRQuestScript
    Debug.MessageBox("Failed to save shop merchandise.\n\n" + error + "\n\n" + BRScript.BugReportCopy)
endEvent