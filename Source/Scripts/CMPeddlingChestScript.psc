Scriptname CMPeddlingChestScript extends Form

Quest Property CMPeddling Auto

event OnMenuClose(string menuName)
    if menuName == "ContainerMenu"
        debug.Trace("Peddling container menu closed")
        CMPeddlingScript questScript = CMPeddling as CMPeddlingScript
        debug.Trace("CMPeddling: " + CMPeddling)
        debug.Trace("questScript: " + questScript)
        questScript.ReweighPeddlingInventory()
        UnregisterForMenu("ContainerMenu")
    endif
endEvent
