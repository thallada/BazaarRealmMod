scriptname BRMerchToggleScript extends ObjectReference

Keyword property BRLinkMerchShelf auto
Keyword property BRLinkMerchChest auto
Keyword property BRLinkItemRef auto
Keyword property BRLinkActivatorRef auto
Keyword property BRLinkMerchToggle auto
Keyword property BRLinkMerchNext auto
Keyword property BRLinkMerchPrev auto
Activator property ActivatorStatic auto
Actor property PlayerRef auto
Quest Property BRQuest Auto

event OnActivate(ObjectReference akActionRef)
    if akActionRef == PlayerRef
        ObjectReference MerchantShelf = self.GetLinkedRef(BRLinkMerchShelf)
        BRQuestScript BRScript = BRQuest as BRQuestScript
        bool result = BRMerchandiseList.Toggle(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, MerchantShelf, ActivatorStatic, BRLinkMerchShelf, BRLinkMerchChest, BRLinkItemRef, BRLinkActivatorRef, BRLinkMerchToggle, BRLinkMerchNext, BRLinkMerchPrev)
        Debug.Trace("BRMerchandiseList.Toggle result: " + result)
        if !result
            Debug.MessageBox("Failed to load or clear shop merchandise.\n\n" + BRScript.BugReportCopy)
        endif
    endif
endEvent

event OnLoadMerchandiseSuccess(bool result)
    Debug.Trace("BRMerchToggleScript OnLoadMerchandiseSuccess result: " + result)
    ObjectReference MerchantShelf = self.GetLinkedRef(BRLinkMerchShelf)
    while !BRMerchandiseList.Replace3D(MerchantShelf, ActivatorStatic, BRLinkMerchShelf, BRLinkItemRef)
        Debug.Trace("BRMerchandiseList.Replace3D returned false, waiting and trying again")
        Utility.Wait(0.05)
    endWhile
endEvent

event OnLoadMerchandiseFail(string error)
    Debug.Trace("BRMerchToggleScript OnLoadMerchandiseFail error: " + error)
    BRQuestScript BRScript = BRQuest as BRQuestScript
    Debug.MessageBox("Failed to load or clear shop merchandise.\n\n" + error + "\n\n" + BRScript.BugReportCopy)
endEvent