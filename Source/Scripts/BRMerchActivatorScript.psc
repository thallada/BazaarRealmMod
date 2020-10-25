scriptname BRMerchActivatorScript extends ObjectReference

Actor Property PlayerRef Auto

Event OnActivate(ObjectReference akActionRef)
    if akActionRef == PlayerRef
        Form merch = BRMerchandiseList.Buy(self)
        PlayerRef.AddItem(merch, 1)
    endif
EndEvent