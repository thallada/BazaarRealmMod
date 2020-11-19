scriptname BRVendorScript extends Actor

ObjectReference property BRMerchChest auto

event OnActivate(ObjectReference akActionRef)
    debug.Trace("BRVendorScript OnActivate")
    BRMerchChest.RegisterForMenu("BarterMenu")
    RegisterForMenu("Dialogue Menu")
endEvent

event OnMenuClose(string menuName)
    if menuName == "Dialogue Menu"
        debug.Trace("BRVendorScript OnMenuClose Dialogue Menu")
        BRMerchChest.UnregisterForMenu("BarterMenu")
        UnregisterForMenu("Dialogue Menu")
    endif
endEvent