scriptname BRMerchNextPageScript extends ObjectReference

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
        bool result = BRMerchandiseList.NextPage(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, MerchantShelf, ActivatorStatic, BRLinkMerchShelf, BRLinkMerchChest, BRLinkItemRef, BRLinkActivatorRef, BRLinkMerchToggle, BRLinkMerchNext, BRLinkMerchPrev)
        Debug.Trace("BRMerchandiseList.NextPage result: " + result)
        if !result
            Debug.MessageBox("Failed to load or clear shop merchandise.\n\n" + BRScript.BugReportCopy)
        endif
    endif
endEvent