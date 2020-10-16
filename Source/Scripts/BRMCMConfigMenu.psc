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
    SetCursorPosition(7)

    if modStarted
        AddToggleOptionST("START_MOD", "Mod Started", modStarted, OPTION_FLAG_DISABLED)
    else
        AddToggleOptionST("START_MOD", "Start Mod", modStarted)
    endif

    AddHeaderOption("Shop Actions")
    SetCursorPosition(10)
    AddTextOptionST("SAVE_REFS", "Save current shop state", "")
    AddTextOptionST("LOAD_REFS", "Load saved shop state", "")
    AddTextOptionST("LIST_MERCH", "Show shop merchandise", "")
    AddTextOptionST("LOAD_MERCH", "Load shop merchandise", "")
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
            Debug.Notification("Starting mod...")
            modStarted = true
            SetToggleOptionValueST(true, true)
            SetOptionFlagsST(OPTION_FLAG_DISABLED, true)
            SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "SERVER_URL_VALUE")
        endif
        ForcePageReset()
    endEvent

    event OnHighlightST()
        SetInfoText("Starts the mod on the configured server. WARNING: You cannot change the server URL once the mod is started.")
    endEvent
endState

state SAVE_REFS
    event OnSelectST()
        if BR.SaveInteriorRefs()
            Debug.Notification("Saving shop...")
        endif
    endEvent

    event OnHighlightST()
        SetInfoText("If you are currently in your shop, clicking this will save the current state of its interior to the server.")
    endEvent
endState

state LOAD_REFS
    event OnSelectST()
        if BR.LoadInteriorRefs()
            Debug.Notification("Loading shop...")
        endif
    endEvent

    event OnHighlightST()
        SetInfoText("If you are currently in your shop, clicking this will load the last saved state of its interior from the server.")
    endEvent
endState

state LIST_MERCH
    event OnSelectST()
        BR.ListMerchandise()
    endEvent

    event OnHighlightST()
        SetInfoText("Open a list of every item currently up for sale in your shop's merchandise inventory.")
    endEvent
endState

state LOAD_MERCH
    event OnSelectST()
        BR.LoadMerchandise()
    endEvent

    event OnHighlightST()
        SetInfoText("Load shop merchandise onto the merchant shelf of the shop.")
    endEvent
endState

event OnShopCreate(int result)
    Debug.Trace("BRMCMConfigMenu OnShopCreate result: " + result)
endEvent