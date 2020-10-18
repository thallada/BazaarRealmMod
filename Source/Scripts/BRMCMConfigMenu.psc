scriptname BRMCMConfigMenu extends SKI_ConfigBase

BRQuestScript property BR auto

bool modStarted = false

int function GetVersion()
	return 1
endFunction

event OnPageReset(string page)
    SetCursorFillMode(LEFT_TO_RIGHT)
    AddHeaderOption("Server Config")
    SetCursorPosition(2)
    AddTextOptionST("SERVER_URL_LABEL", "API Server URL: ", "", OPTION_FLAG_DISABLED)
    if modStarted
        AddInputOptionST("SERVER_URL_VALUE", "", BR.ApiUrl, OPTION_FLAG_DISABLED)
    else
        AddInputOptionST("SERVER_URL_VALUE", "", BR.ApiUrl)
    endif

    if modStarted
        AddTextOptionST("API_KEY", "Reveal API key", "")
    endif

    SetCursorPosition(5)
    if modStarted
        AddToggleOptionST("START_MOD", "Mod Started", modStarted, OPTION_FLAG_DISABLED)
    else
        AddToggleOptionST("START_MOD", "Start Mod", modStarted)
    endif


    SetCursorPosition(8)
    if modStarted
        AddHeaderOption("Shop Config")
        SetCursorPosition(10)
        AddTextOptionST("SHOP_NAME_LABEL", "Shop name: ", "", OPTION_FLAG_DISABLED)
        AddInputOptionST("SHOP_NAME", "", BR.ShopName)
        AddTextOptionST("SHOP_DESC_LABEL", "Shop description: ", "", OPTION_FLAG_DISABLED)
        AddInputOptionST("SHOP_DESC", "", BR.ShopDescription)
        AddTextOptionST("LOAD_SHOP_CONFIG", "Load shop config from server", "")

        SetCursorPosition(18)
        AddHeaderOption("Shop Actions")
        SetCursorPosition(20)
        AddTextOptionST("SAVE_REFS", "Save current shop state", "")
        AddTextOptionST("LOAD_REFS", "Load saved shop state", "")
    endif
endEvent

state SERVER_URL_VALUE
    event OnInputOpenST()
        SetInputDialogStartText(BR.ApiUrl)
    endEvent

    event OnInputAcceptST(string textInput)
        BR.ApiUrl = textInput
        SetInputOptionValueST(textInput)
    endEvent

    event OnHighlightST()
        SetInfoText("The Bazaar Realm Server URL. Leave this at the default value to play on the main server with other players. If you would like to use your own private server, read the README for instructions on how to set one up, and then set this value to your server's URL.")
    endEvent

    event OnDefaultST()
        BR.ApiUrl = "https://api.bazaarrealm.com"
        SetInputOptionValueST(BR.ApiUrl)
    endEvent
endState

state API_KEY
    event OnHighlightST()
        SetInfoText("Click to see your unique server API key. Keep it secret since it allows modifying your shop data.")
    endEvent

    event OnSelectST()
        ShowMessage(BR.ApiKey)
    endEvent
endState

state START_MOD
    event OnSelectST()
        if BR.StartMod()
            int attempts = 0
            while BR.ShopId == 0 && !BR.StartModFailed && attempts < 100
                attempts += 1
                Utility.WaitMenuMode(0.1)
            endWhile

            if attempts >= 100
                Debug.Trace("BRMCMConfigMenu StartMod failed. ShopId still unset after 100 polls (10 seconds)")
            endif

            if BR.StartModFailed
                Debug.Trace("BRMCMConfigMenu StartMod failed. BR.StartModFailed == true")
            else
                Debug.Trace("BRMCMConfigMenu StartMod succeeded")
                modStarted = true
                SetToggleOptionValueST(true, true)
                SetOptionFlagsST(OPTION_FLAG_DISABLED, true)
                SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "SERVER_URL_VALUE")
            endif
        endif
        ForcePageReset()
    endEvent

    event OnHighlightST()
        SetInfoText("Starts the mod on the configured server. WARNING: You cannot change the server URL once the mod is started.")
    endEvent
endState

state SAVE_REFS
    event OnSelectST()
        BR.SaveInteriorRefs()
    endEvent

    event OnHighlightST()
        SetInfoText("If you are currently in your shop, clicking this will save the current state of its interior to the server.")
    endEvent
endState

state LOAD_REFS
    event OnSelectST()
        BR.LoadInteriorRefs()
    endEvent

    event OnHighlightST()
        SetInfoText("If you are currently in your shop, clicking this will load the last saved state of its interior from the server.")
    endEvent
endState

state SHOP_NAME
    event OnInputOpenST()
        SetInputDialogStartText(BR.ShopName)
    endEvent

    event OnInputAcceptST(string textInput)
        Debug.Trace("BRMCMConfigMenu BRQuest properties: ShopId: " + BR.ShopId + " ShopName: " + BR.ShopName + " ShopDescription: " + BR.ShopDescription)
        SetInputOptionValueST("Updating...")
        BR.UpdateShop(BR.ShopId, textInput, BR.ShopDescription)

        int attempts = 0
        while !BR.UpdateShopComplete && attempts < 100
            attempts += 1
            Utility.WaitMenuMode(0.1)
        endWhile

        if attempts >= 100
            Debug.Trace("BRMCMConfigMenu BR.UpdateShop failed. BR.UpdateShopComplete still unset after 100 polls (10 seconds)")
        endif

        SetInputOptionValueST(BR.ShopName)
    endEvent

    event OnHighlightST()
        SetInfoText("The name of your shop. This is displayed to other players in the shop menu.")
    endEvent

    event OnDefaultST()
        SetInputOptionValueST("Updating...")
        BR.UpdateShop(BR.ShopId, Game.GetPlayer().GetBaseObject().GetName() + "'s Shop", BR.ShopDescription)

        int attempts = 0
        while !BR.UpdateShopComplete && attempts < 100
            attempts += 1
            Utility.WaitMenuMode(0.1)
        endWhile

        if attempts >= 100
            Debug.Trace("BRMCMConfigMenu BR.UpdateShop failed. BR.UpdateShopComplete still unset after 100 polls (10 seconds)")
        endif

        SetInputOptionValueST(BR.ShopName)
    endEvent
endState

state SHOP_DESC
    event OnInputOpenST()
        SetInputDialogStartText(BR.ShopDescription)
    endEvent

    event OnInputAcceptST(string textInput)
        SetInputOptionValueST("Updating...")
        BR.UpdateShop(BR.ShopId, BR.ShopName, textInput)

        int attempts = 0
        while !BR.UpdateShopComplete && attempts < 100
            attempts += 1
            Utility.WaitMenuMode(0.1)
        endWhile

        if attempts >= 100
            Debug.Trace("BRMCMConfigMenu BR.UpdateShop failed. BR.UpdateShopComplete still unset after 100 polls (10 seconds)")
        endif

        SetInputOptionValueST(BR.ShopDescription)
    endEvent

    event OnHighlightST()
        SetInfoText("The description of your shop. This is displayed to other players in the shop menu. This is a useful place to advertise what your shop sells.")
    endEvent

    event OnDefaultST()
        SetInputOptionValueST("Updating...")
        BR.UpdateShop(BR.ShopId, BR.ShopName, "")

        int attempts = 0
        while !BR.UpdateShopComplete && attempts < 100
            attempts += 1
            Utility.WaitMenuMode(0.1)
        endWhile

        if attempts >= 100
            Debug.Trace("BRMCMConfigMenu BR.UpdateShop failed. BR.UpdateShopComplete still unset after 100 polls (10 seconds)")
        endif

        SetInputOptionValueST(BR.ShopDescription)
    endEvent
endState

state LOAD_SHOP_CONFIG
    event OnSelectST()
        SetTextOptionValueST("Fetching...")
        BR.GetShop(BR.ShopId)

        int attempts = 0
        while !BR.GetShopComplete && attempts < 100
            attempts += 1
            Utility.WaitMenuMode(0.1)
        endWhile

        if attempts >= 100
            Debug.Trace("BRMCMConfigMenu BR.GetShop failed. BR.GetShopComplete still unset after 100 polls (10 seconds)")
        endif

        ForcePageReset()
    endEvent

    event OnHighlightST()
        SetInfoText("Overwrites the shop name and description with values saved on the server. Run this after updating any of your shop config values on the website.")
    endEvent
endState