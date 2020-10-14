Scriptname BRMerchChestScript extends ObjectReference

Actor Property PlayerRef Auto
Quest Property BRQuest Auto

event OnMenuClose(string menuName)
    if menuName == "ContainerMenu"
        debug.Trace("BRMerchChestScript container menu closed")
        BRQuestScript BRScript = BRQuest as BRQuestScript
        int result = BRMerchandiseList.Create(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ShopId, self)
        if result == -2
            Debug.Trace("BRMerchChestScript no container changes to save to the server")
        elseif result == -1
            Debug.MessageBox("Failed to save shop merchandise. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
        else
            BRScript.MerchandiseListId = result;
            Debug.Notification("Saved merchandise successfully")
        endif
        UnregisterForMenu("ContainerMenu")
    endif
endEvent

event OnActivate(ObjectReference akActionRef)
    if akActionRef == PlayerRef
        debug.Trace("BRMerchChestScript container was opened")
        RegisterForMenu("ContainerMenu")
    endif
endEvent