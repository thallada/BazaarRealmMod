scriptname BRMerchPrevPageScript extends ObjectReference

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
        bool result = BRMerchandiseList.PrevPage(BRScript.ApiUrl, BRScript.ApiKey, BRScript.MerchandiseListId, MerchantShelf, PlaceholderStatic, BRLinkMerchShelf, BRLinkMerchChest, BRLinkItemRef, BRLinkMerchToggle, BRLinkMerchNext, BRLinkMerchPrev)
        Debug.Trace("BRMerchandiseList.PrevPage result: " + result)
        if !result
            Debug.MessageBox("Failed to load shop merchandise. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
        endif
    endif
endEvent