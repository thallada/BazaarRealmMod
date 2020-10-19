scriptname BRMerchNextPageScript extends ObjectReference

Keyword property BRLinkMerchShelf auto
Keyword property BRLinkMerchChest auto
Keyword property BRLinkItemRef auto
Keyword property BRLinkMerchToggle auto
Keyword property BRLinkMerchNext auto
Keyword property BRLinkMerchPrev auto
Activator property PlaceholderStatic auto
Actor property PlayerRef auto
Quest Property BRQuest Auto

event OnActivate(ObjectReference akActionRef)
    if akActionRef == PlayerRef
        ObjectReference MerchantShelf = self.GetLinkedRef(BRLinkMerchShelf)
        BRQuestScript BRScript = BRQuest as BRQuestScript
        bool result = BRMerchandiseList.NextPage(BRScript.ApiUrl, BRScript.ApiKey, BRScript.MerchandiseListId, MerchantShelf, PlaceholderStatic, BRLinkMerchShelf, BRLinkMerchChest, BRLinkItemRef, BRLinkMerchToggle, BRLinkMerchNext, BRLinkMerchPrev)
        Debug.Trace("BRMerchandiseList.NextPage result: " + result)
        if !result
            Debug.MessageBox("Failed to load or clear shop merchandise.\n\n" + BRScript.BugReportCopy)
        endif
    endif
endEvent