scriptname BRQuestScript extends Quest

int property ModVersion = 1 auto
string property ApiUrl = "https://api.bazaarrealm.com" auto
string property ApiKey auto
actor property PlayerRef auto
int property OwnerId auto
; TODO: need to be able to create multiple shops
int property ShopId auto
; TODO: loop up interior refs by shop id instead of saving this
int property InteriorRefListId = 29 auto ; TODO: temp fixing to id 20
int property MerchandiseListId = 2 auto ; TODO: temp fixing to id 2
ObjectReference property ShopXMarker auto
bool property StartModFailed = false auto
UILIB_1 property UILib auto

int function GetVersion()
    return 1
endFunction

event OnInit()
    Debug.Trace("BRQuestScript OnInit")
    Maintenance()
endEvent

function Maintenance()
    Debug.Trace("BRQuestScript Maintenance")
    UILib = (Self as Form) as UILIB_1
    if !BRClient.Init()
        Debug.MessageBox("Failed to initialize Bazaar Realm client. Please ensure that the folder Documents\\My Games\\Skyrim Special Edition\\SKSE exists and is accessible by Skyrim.")
    endif
    int newVersion = GetVersion()
    if ModVersion < newVersion
        ModVersion = newVersion
        ; TODO: update tasks
        Debug.Notification("Bazaar Realm upgraded to version: " + ModVersion)
    endif
endFunction

bool function StartMod()
    Debug.Trace("BRQuestScript StartMod")
    StartModFailed = false
    bool result = BRClient.StatusCheck(ApiUrl, self)
    if !result
        Debug.MessageBox("Failed to initialize Bazaar Realm client. The API server might be down: " + ApiUrl)
        StartModFailed = true
    endif
    return result
endFunction

event OnStatusCheck(bool result)
    Debug.Trace("BRQuestScript OnStatusCheck result: " + result)
    if result
        ApiKey = BRClient.GenerateApiKey()
        Debug.Trace("apiKey: " + ApiKey)
        Debug.Trace("apiUrl: " + ApiUrl)
        string playerName = PlayerRef.GetBaseObject().GetName()
        bool ownerResult = BROwner.Create(ApiUrl, ApiKey, playerName, ModVersion, self)
        if !ownerResult
            Debug.MessageBox("Failed to initialize Bazaar Realm client. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
            StartModFailed = true
        endif
    else
        Debug.MessageBox("Failed to initialize Bazaar Realm client. The API server might be down: " + ApiUrl)
        StartModFailed = true
    endif
endEvent

event OnCreateOwner(int result)
    Debug.Trace("BRQuestScript OnCreateOwner result: " + result)
    string playerName = PlayerRef.GetBaseObject().GetName()
    if result > -1
        OwnerId = result
        bool shopResult = BRShop.Create(ApiUrl, ApiKey, playerName + "'s Shop", "", self)
        if !shopResult
            Debug.MessageBox("Failed to initialize Bazaar Realm client. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
            StartModFailed = true
        endif
    else
        Debug.MessageBox("Failed to initialize Bazaar Realm client. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
        StartModFailed = true
    endif
endEvent

event OnCreateShop(int result)
    Debug.Trace("BRQuestScript OnCreateShop result: " + result)
    if result > -1
        ShopId = result
        Debug.Notification("Initialized Bazaar Realm client")
    else
        Debug.MessageBox("Failed to initialize Bazaar Realm client. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
        StartModFailed = true
    endif
endEvent

bool function SaveInteriorRefs()
    ; TODO: this should not save anything if player is not currently in their shop
    bool result = BRInteriorRefList.Create(ApiUrl, ApiKey, ShopId, self)
    if result
        return true
    else
        Debug.MessageBox("Failed to save shop. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
        return false
    endif
endFunction

event OnCreateInteriorRefList(int result)
    Debug.Trace("BRQuestSCript OnCreateInteriorRefList result: " + result)
    if result > -1
        InteriorRefListId = result
        Debug.MessageBox("Successfully saved shop.")
    else
        Debug.MessageBox("Failed to save shop. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
    endif
endEvent

bool function LoadInteriorRefs()
    ; TODO: this should not save anything if player is not currently in their shop
    bool result = BRInteriorRefList.ClearCell()
    if !result
        Debug.MessageBox("Failed to load shop. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
    endif
    Debug.Trace("ClearCell result: " + result)

    result = BRInteriorRefList.Load(ApiUrl, ApiKey, InteriorRefListId, ShopXMarker, self)
    if result
        return true
    else
        Debug.MessageBox("Failed to load shop. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
        return false
    endif
endFunction

event OnLoadInteriorRefList(bool result)
    Debug.Trace("BRQuestSCript OnLoadInteriorRefList result: " + result)
    if result
        Debug.MessageBox("Successfully loaded shop")
    else
        Debug.MessageBox("Failed to load shop. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
    endif
endEvent

int function ListMerchandise()
    string[] options = new string[5]
    options[0] = "First Item"
    options[1] = "Second Item"
    options[2] = "Third Item"
    options[3] = "Fourth Item"
    options[4] = "Fifth Item"
    
    int selectedIndex = UILib.ShowList("Shop Merchandise", options, 0, 0)
    UILib.ShowNotification("Chose " + options[selectedIndex], "#74C56D")
endFunction

bool function LoadMerchandise()
    Debug.MessageBox("This no longer does anything, sorry.")
endFunction