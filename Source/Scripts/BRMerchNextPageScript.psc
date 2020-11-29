scriptname BRMerchNextPageScript extends ObjectReference

Keyword property BRLinkMerchShelf auto
Actor property PlayerRef auto
Quest Property BRQuest Auto

event OnActivate(ObjectReference akActionRef)
    if akActionRef == PlayerRef
        ObjectReference MerchantShelf = self.GetLinkedRef(BRLinkMerchShelf)
        BRQuestScript BRScript = BRQuest as BRQuestScript
        debug.MessageBox("BRMerchandiseList.NextPage not implemented yet!")
        ; bool result = BRMerchandiseList.NextPage(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, MerchantShelf)
        ; Debug.Trace("BRMerchandiseList.NextPage result: " + result)
        ; if !result
        ;     Debug.MessageBox("Failed to load or clear shop merchandise.\n\n" + BRScript.BugReportCopy)
        ; endif
    endif
endEvent