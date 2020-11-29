scriptname BRMerchToggleScript extends ObjectReference

Keyword property BRLinkMerchShelf auto
Actor property PlayerRef auto
Quest Property BRQuest Auto

event OnActivate(ObjectReference akActionRef)
    if akActionRef == PlayerRef
        ObjectReference MerchantShelf = self.GetLinkedRef(BRLinkMerchShelf)
        BRQuestScript BRScript = BRQuest as BRQuestScript
        debug.MessageBox("BRMerchandiseList.Toggle not implemented yet!")
        ; bool result = BRMerchandiseList.Toggle(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, MerchantShelf)
        ; Debug.Trace("BRMerchandiseList.Toggle result: " + result)
        ; if !result
        ;     Debug.MessageBox("Failed to load or clear shop merchandise.\n\n" + BRScript.BugReportCopy)
        ; endif
    endif
endEvent

; event OnLoadMerchandiseSuccess(bool result)
;     Debug.Trace("BRMerchToggleScript OnLoadMerchandiseSuccess result: " + result)
;     ObjectReference MerchantShelf = self.GetLinkedRef(BRLinkMerchShelf)
;     debug.MessageBox("BRMerchandiseList.Replace3D not implemented yet!")
;     ; while !BRMerchandiseList.Replace3D(MerchantShelf)
;     ;     Debug.Trace("BRMerchandiseList.Replace3D returned false, waiting and trying again")
;     ;     Utility.Wait(0.05)
;     ; endWhile
; endEvent

; event OnLoadMerchandiseFail(string error)
;     Debug.Trace("BRMerchToggleScript OnLoadMerchandiseFail error: " + error)
;     BRQuestScript BRScript = BRQuest as BRQuestScript
;     Debug.MessageBox("Failed to load or clear shop merchandise.\n\n" + error + "\n\n" + BRScript.BugReportCopy)
; endEvent