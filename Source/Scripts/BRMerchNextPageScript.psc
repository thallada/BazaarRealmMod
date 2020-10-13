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

Event OnActivate(ObjectReference akActionRef)
    if akActionRef == PlayerRef
        ObjectReference MerchantShelf = self.GetLinkedRef(BRLinkMerchShelf)
        BRQuestScript BRScript = BRQuest as BRQuestScript
        bool result = BRMerchandiseList.NextPage(BRScript.ApiUrl, BRScript.ApiKey, BRScript.MerchandiseListId, MerchantShelf, PlaceholderStatic, BRLinkMerchShelf, BRLinkMerchChest, BRLinkItemRef, BRLinkMerchToggle, BRLinkMerchNext, BRLinkMerchPrev)
        debug.Trace("BRMerchandiseList.NextPage result: " + result)
        if result
            while !BRMerchandiseList.Replace3D(MerchantShelf, PlaceholderStatic, BRLinkMerchShelf, BRLinkItemRef)
                Debug.Trace("BRMerchandiseList.Replace3D returned false, waiting and trying again")
                Utility.Wait(0.05)
            endWhile
        else
            Debug.MessageBox("Failed to load shop merchandise. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
        endif
    endif
EndEvent