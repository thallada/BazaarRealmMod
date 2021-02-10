scriptname BRMerchChestActivatorScript extends ObjectReference

Keyword property BRLinkMerchChest auto
Keyword property BRLinkPublicMerchChest auto
Actor property PlayerRef auto
Quest property BRQuest auto

event OnActivate(ObjectReference akActionRef)
    if akActionRef == PlayerRef
        Debug.Trace("BRMerchChestActivatorScript activator was activated")
        BRQuestScript BRScript = BRQuest as BRQuestScript
        if BRScript.ActiveShopId == BRScript.ShopId
            ObjectReference privateChest = GetLinkedRef(BRLinkMerchChest)
            privateChest.RegisterForMenu("ContainerMenu")
            privateChest.Activate(akActionRef)
        else
            ObjectReference publicChest = GetLinkedRef(BRLinkPublicMerchChest)
            publicChest.RegisterForMenu("ContainerMenu")
            publicChest.Activate(akActionRef)
        endif
    endif
endEvent