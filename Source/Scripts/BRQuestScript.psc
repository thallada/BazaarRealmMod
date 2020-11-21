scriptname BRQuestScript extends Quest

; Mod Data
int property ModVersion = 1 auto
; Client config
string property ApiUrl = "https://api.bazaarrealm.com" auto
string property ApiKey auto
; Owner data (for the shop the player owns)
int property OwnerId auto
; TODO: need to be able to create multiple shops (make these arrays?)
int property ShopId auto
string property ShopName auto
string property ShopDescription auto
; TODO: look up interior refs and merch by shop id instead of saving this?
int property InteriorRefListId auto
int property MerchandiseListId auto
; Active shop data (for the currently loaded shop)
int property ActiveOwnerId auto
int property ActiveShopId auto
string property ActiveShopName auto
string property ActiveShopDescription auto
; references
Actor property PlayerRef auto
ObjectReference property ShopXMarker auto
ObjectReference property PrivateChest auto
ObjectReference property PublicChest auto
; messages
Message property ShopDetailMessage auto
Message property BuyMerchandiseMessage auto
; message replacement refs
ObjectReference property SelectedMerchandise auto
; UI sync properties
bool property StartModFailed = false auto
bool property UpdateShopComplete = false auto
bool property GetShopComplete = false auto
bool property ListShopsComplete = false auto
UILIB_1 property UILib auto
string property BugReportCopy = "Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE." auto

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
        Debug.MessageBox("Failed to initialize Bazaar Realm client.\n\nPlease ensure that the folder Documents\\My Games\\Skyrim Special Edition\\SKSE exists and is accessible by Skyrim.")
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
        Debug.MessageBox("Failed to initialize Bazaar Realm client.\n\nThe API server might be down: " + ApiUrl)
        StartModFailed = true
    endif
    return result
endFunction

event OnStatusCheckSuccess(bool result)
    Debug.Trace("BRQuestScript OnStatusCheckSuccess result: " + result)
    if result
        ApiKey = BRClient.GenerateApiKey()
        Debug.Trace("apiKey: " + ApiKey)
        Debug.Trace("apiUrl: " + ApiUrl)
        string playerName = PlayerRef.GetBaseObject().GetName()
        bool ownerResult = BROwner.Create(ApiUrl, ApiKey, playerName, ModVersion, self)
        if !ownerResult
            Debug.MessageBox("Failed to create new owner in the API.\n\n" + BugReportCopy)
            StartModFailed = true
        endif
    endif
endEvent

event OnStatusCheckFail(string error)
    Debug.Trace("BRQuestScript OnStatusCheckFail error: " + error)
    Debug.MessageBox("Failed to initialize Bazaar Realm client.\n\n" + error + "\n\nThe API server might be down: " + ApiUrl)
    StartModFailed = true
endEvent

event OnCreateOwnerSuccess(int id)
    Debug.Trace("BRQuestScript OnCreateOwnerSuccess id: " + id)
    string playerName = PlayerRef.GetBaseObject().GetName()
    OwnerId = id
    bool shopResult = BRShop.Create(ApiUrl, ApiKey, playerName + "'s Shop", "", self)
    if !shopResult
        Debug.MessageBox("Failed to create new shop in the API.\n\n" + BugReportCopy)
        StartModFailed = true
    endif
endEvent

event OnCreateOwnerFail(string error)
    Debug.Trace("BRQuestScript OnCreateOwnerFail error: " + error)
    Debug.MessageBox("Failed to create new owner in the API.\n\n" + error + "\n\n" + BugReportCopy)
    StartModFailed = true
endEvent

event OnCreateShopSuccess(int id, string name, string description)
    Debug.Trace("BRQuestScript OnCreateShopSucess id: " + id + " name: " + name + " description: " + description)
    ShopId = id
    ShopName = name
    ShopDescription = description
    Debug.Notification("Initialized Bazaar Realm client")
endEvent

event OnCreateShopFail(string error)
    Debug.Trace("BRQuestScript OnCreateShopFail error: " + error)
    Debug.MessageBox("Failed to initialize Bazaar Realm client.\n\n" + error + "\n\n" + BugReportCopy)
    StartModFailed = true
endEvent

bool function SaveInteriorRefs()
    ; TODO: this should not save anything if player is not currently in their shop
    bool result = BRInteriorRefList.Create(ApiUrl, ApiKey, ShopId, self)
    if result
        return true
    else
        Debug.MessageBox("Failed to save shop.\n\n" + BugReportCopy)
        return false
    endif
endFunction

event OnCreateInteriorRefListSuccess(int id)
    Debug.Trace("BRQuestScript OnCreateInteriorRefListSuccess id: " + id)
    InteriorRefListId = id
    Debug.MessageBox("Successfully saved shop.")
endEvent

event OnCreateInteriorRefListFail(string error)
    Debug.Trace("BRQuestScript OnCreateInteriorRefListFail error: " + error)
    Debug.MessageBox("Failed to save shop.\n\n" + error + "\n\n" + BugReportCopy)
endEvent

bool function LoadInteriorRefs()
    ; TODO: this should not load anything if player is not currently in their shop
    bool result = BRInteriorRefList.ClearCell()
    if !result
        Debug.MessageBox("Failed to clear existing shop before loading in new shop.\n\n" + BugReportCopy)
    endif
    Debug.Trace("ClearCell result: " + result)

    result = BRInteriorRefList.Load(ApiUrl, ApiKey, InteriorRefListId, ShopXMarker, PrivateChest, PublicChest, self)
    if result
        return true
    else
        Debug.MessageBox("Failed to load shop.\n\n" + BugReportCopy)
        return false
    endif
endFunction

event OnLoadInteriorRefListSuccess(bool result)
    Debug.Trace("BRQuestScript OnLoadInteriorRefListSuccess result: " + result)
    ActiveShopId = ShopId
    ActiveShopName = ShopName
    ActiveShopDescription = ShopDescription
    Debug.MessageBox("Successfully loaded shop")
endEvent

event OnLoadInteriorRefListFail(string error)
    Debug.Trace("BRQuestScript OnLoadInteriorRefListFail error: " + error)
    Debug.MessageBox("Failed to load shop.\n\n" + error + "\n\n" + BugReportCopy)
endEvent

; currently unused, was testing out UILib
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

function UpdateShop(int id, string name, string description)
    Debug.Trace("BRQuestScript UpdateShop id: " + id + " name: " + name + " description: " + description)
    UpdateShopComplete = false
    bool result = BRShop.Update(ApiUrl, ApiKey, id, name, description, self)
    if !result
        Debug.MessageBox("Failed to update shop.\n\n" + BugReportCopy)
        UpdateShopComplete = true
    endif
endFunction

event OnUpdateShopSuccess(int id, string name, string description)
    Debug.Trace("BRQuestScript OnUpdateShopSucess id: " + id + " name: " + name + " description: " + description)
    ShopId = id
    ShopName = name
    ShopDescription = description
    UpdateShopComplete = true
endEvent

event OnUpdateShopFail(string error)
    Debug.Trace("BRQuestScript OnUpdateShopFail error: " + error)
    Debug.MessageBox("Failed to update shop.\n\n" + error + "\n\n" + BugReportCopy)
    UpdateShopComplete = true
endEvent

function GetShop(int id)
    Debug.Trace("BRQuestScript GetShop id: " + id)
    GetShopComplete = false
    bool result = BRShop.Get(ApiUrl, ApiKey, id, self)
    if !result
        Debug.MessageBox("Failed to get shop.\n\n" + BugReportCopy)
        GetShopComplete = true
    endif
endFunction

event OnGetShopSuccess(int id, string name, string description)
    Debug.Trace("BRQuestScript OnGetShopSucess id: " + id + " name: " + name + " description: " + description)
    ShopId = id
    ShopName = name
    ShopDescription = description
    GetShopComplete = true
endEvent

event OnGetShopFail(string error)
    Debug.Trace("BRQuestScript OnGetShopFail error: " + error)
    Debug.MessageBox("Failed to get shop.\n\n" + error + "\n\n" + BugReportCopy)
    GetShopComplete = true
endEvent

function ListShops()
    Debug.Trace("BRQuestScript ListShops")
    ListShopsComplete = false
    bool result = BRShop.List(ApiUrl, ApiKey, self)
    if !result
        Debug.MessageBox("Failed to list shops.\n\n" + BugReportCopy)
        ListShopsComplete = true
    endif
endFunction

event OnListShopsSuccess(int[] ids, string[] names, string[] descriptions)
    Debug.Trace("BRQuestScript OnListShopsSuccess ids.length: " + ids.Length + " names.length: " + names.Length + " descriptions.length: " + descriptions.Length)
    int index = 0
    int selectedIndex = UILib.ShowList("Shop Merchandise", names, 0, 0)
    ListShopsComplete = true
    if ShopDetailMessage.Show() == 0
        Debug.MessageBox(names[selectedIndex] + " (ID: " + ids[selectedIndex] + ")\n\n" + descriptions[selectedIndex])
        ActiveShopId = ids[selectedIndex]
        ActiveShopName = names[selectedIndex]
        ActiveShopDescription = descriptions[selectedIndex]
        ShopDetailMessage.SetName(names[selectedIndex])
        bool result = BRInteriorRefList.ClearCell()
        if !result
            Debug.MessageBox("Failed to clear existing shop before loading in new shop.\n\n" + BugReportCopy)
        endif
        Debug.Trace("ClearCell result: " + result)

        result = BRInteriorRefList.LoadByShopId(ApiUrl, ApiKey, ActiveShopId, ShopXMarker, PrivateChest, PublicChest, self)
        if !result
            Debug.MessageBox("Failed to load shop.\n\n" + BugReportCopy)
        endif
    endif
endEvent

event OnListShopsFail(string error)
    Debug.Trace("BRQuestScript OnListShopsFail error: " + error)
    Debug.MessageBox("Failed to list shops.\n\n" + error + "\n\n" + BugReportCopy)
    ListShopsComplete = true
endEvent