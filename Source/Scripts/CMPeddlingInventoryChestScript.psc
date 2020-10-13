Scriptname CMPeddlingInventoryChestScript extends ObjectReference

Actor Property PlayerRef Auto
ObjectReference Property CMPeddlingChestRef Auto
Armor Property CMPeddlingInventory Auto
Container Property CMPeddlingChest Auto
Quest Property CMFetchQuest Auto

Event OnEquipped(Actor akActor)
    if akActor == PlayerRef
        Game.DisablePlayerControls(False, False, False, False, False, True)
        PlayerRef.EquipItem(CMPeddlingInventory, True, True)
        Utility.Wait(0.01)
        PlayerRef.UnequipItem(CMPeddlingInventory, False, True)
        Game.EnablePlayerControls(False, False, False, False, False, True)

        debug.Trace("CMPeddlingChest: " + CMPeddlingChest as Form)
        CMPeddlingChest.RegisterForMenu("ContainerMenu")
        CMPeddlingChestRef.Activate(akActor)
    endif
endEvent