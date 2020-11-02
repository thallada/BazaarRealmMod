scriptname BRMerchActivatorScript extends ObjectReference

Keyword property BRLinkMerchShelf auto
Keyword property BRLinkMerchChest auto
Keyword property BRLinkItemRef auto
Keyword property BRLinkActivatorRef auto
Keyword property BRLinkMerchToggle auto
Keyword property BRLinkMerchNext auto
Keyword property BRLinkMerchPrev auto
Activator property ActivatorStatic auto
Actor property PlayerRef auto
Quest property BRQuest auto
MiscObject property Gold001 auto

event OnActivate(ObjectReference akActionRef)
    if akActionRef == PlayerRef
        debug.Trace("BRMerchActivatorScript OnActivate by PlayerRef")
        int totalQuantity = BRMerchandiseList.GetQuantity(self)
        int price = BRMerchandiseList.GetPrice(self)

        BRQuestScript BRScript = BRQuest as BRQuestScript
        ObjectReference merchRef = self.GetLinkedRef(BRLinkItemRef)
        Form selectedMerchandiseRepl = BRScript.SelectedMerchandise.GetBaseObject()
        selectedMerchandiseRepl.SetName(merchRef.GetBaseObject().GetName())
        bool inBuyMenu = true
        int quantity = 1
        while inBuyMenu
            int amount = quantity * price
            int choice = BRScript.BuyMerchandiseMessage.Show(quantity as float, totalQuantity as float, amount as float, price as float)
            if choice == 0
                bool result = BRTransaction.Create(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, false, quantity, amount, BRLinkItemRef, self)
                if !result
                    Debug.MessageBox("Failed to buy merchandise.\n\n" + BRScript.BugReportCopy)
                endif
                inBuyMenu = false
            elseif choice == 1
                bool result = BRTransaction.Create(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, false, totalQuantity, totalQuantity * price, BRLinkItemRef, self)
                if !result
                    Debug.MessageBox("Failed to buy merchandise.\n\n" + BRScript.BugReportCopy)
                endif
                inBuyMenu = false
            elseif choice == 2
                string enteredQuantity = BRScript.UILib.ShowTextInput("Enter Quantity", "")
                if enteredQuantity as int == 0
                    debug.Notification("Failed to parse a valid quantity. Enter a number between 1 and " + totalQuantity)
                elseif enteredQuantity < 1
                    debug.Notification("Entered quantity less than minimum quantity: 1. Setting quantity to 1")
                    quantity = 1
                elseif enteredQuantity as int > totalQuantity
                    debug.Notification("Entered quantity greater than maximum quantity: " + totalQuantity + ". Setting quantity to " + totalQuantity)
                    quantity = totalQuantity
                else
                    quantity = enteredQuantity as int
                endif
            else
                inBuyMenu = false
            endif
        endWhile
        selectedMerchandiseRepl.SetName("Selected Merchandise")
    endif
endEvent

function RefreshMerchandise()
    BRQuestScript BRScript = BRQuest as BRQuestScript
    ObjectReference merchantShelf = self.GetLinkedRef(BRLinkMerchShelf)
    if !BRMerchandiseList.Refresh(BRScript.ApiUrl, BRScript.ApiKey, BRScript.ActiveShopId, merchantShelf, ActivatorStatic, BRLinkMerchShelf, BRLinkMerchChest, BRLinkItemRef, BRLinkActivatorRef, BRLinkMerchToggle, BRLinkMerchNext, BRLinkMerchPrev)
        Debug.MessageBox("Failed refresh merchandise.\n\n" + BRScript.BugReportCopy)
    endif
endFunction

event OnCreateTransactionSuccess(int id, int quantity, int amount)
    debug.Trace("BRMerchActivatorScript OnCreateTransactionSuccess id: " + id + " quantity: " + quantity + " amount: " + amount)
    ObjectReference merchRef = self.GetLinkedRef(BRLinkItemRef)
    PlayerRef.RemoveItem(Gold001, amount)
    PlayerRef.AddItem(merchRef.GetBaseObject(), quantity)
    RefreshMerchandise()
endEvent

; TODO: gracefully handle expected error cases (e.g. someone else buys all of item before this player can buy them)
Event OnCreateTransactionFail(string error)
    Debug.Trace("BRMerchActivatorScript OnCreateTransactionFail error: " + error)
    BRQuestScript BRScript = BRQuest as BRQuestScript
    Debug.MessageBox("Failed to buy merchandise.\n\n" + error + "\n\n" + BRScript.BugReportCopy)
    RefreshMerchandise()
endEvent