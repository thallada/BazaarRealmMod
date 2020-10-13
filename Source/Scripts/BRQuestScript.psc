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
    BRClient.Init()
    int newVersion = GetVersion()
    if ModVersion < newVersion
        ModVersion = newVersion
        ; TODO: update tasks
        Debug.Notification("Bazaar Realm upgraded to version: " + ModVersion)
    endif
endFunction

bool function StartMod()
    debug.Trace("BRQuestScript StartMod")
    bool result = BRClient.StatusCheck(ApiUrl)
    if result
        ApiKey = BRClient.GenerateApiKey()
        Debug.Trace("apiKey: " + ApiKey)
        Debug.Trace("apiUrl: " + ApiUrl)
        string playerName = Game.GetPlayer().GetBaseObject().GetName()
        OwnerId = BROwner.Create(ApiUrl, ApiKey, playerName, ModVersion)
        if OwnerId > -1
            ShopId = BRShop.Create(ApiUrl, ApiKey, playerName + "'s Shop")
            if ShopId > -1
                Debug.Notification("Initialized Bazaar Realm client")
            else
                result = false
                Debug.MessageBox("Failed to initialize Bazaar Realm client. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
            endif
        else
            result = false
            Debug.MessageBox("Failed to initialize Bazaar Realm client. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
        endif
    else
        Debug.MessageBox("Failed to initialize Bazaar Realm client. The API server might be down: " + ApiUrl)
    endif
    return result
endFunction

bool function SaveInteriorRefs()
    ; TODO: this should not save anything if player is not currently in their shop
    Cell currentCell = PlayerRef.GetParentCell()
    InteriorRefListId = BRInteriorRefList.Create(ApiUrl, ApiKey, ShopId, currentCell)
    Debug.Trace("Interior ref list id: " + interiorRefListId)
    ; Int numRefs = currentCell.GetNumRefs()
    ; debug.Trace("Num of refs in current cell: " + numRefs)
    ; Int refIndex = 0
    ; while refIndex <= numRefs
    ;     ObjectReference ref = currentCell.GetNthRef(refIndex)
    ;     ; if ref != None && ref.IsEnabled()
    ;     ;     Form a_form = ref.GetBaseObject()
    ;     ;     debug.Trace("Ref " + refIndex + ": " + ref.GetDisplayName())
    ;     ;     debug.Trace("Ref position: " + ref.X + ", " + ref.Y + ", " + ref.Z)
    ;     ;     debug.Trace("Ref angle: " + ref.getAngleX() + ", " + ref.getAngleY() + ", " + ref.getAngleZ())
    ;     ;     debug.Trace("Ref scale: " + ref.GetScale())
    ;     ;     debug.Trace("Ref Base Object Name: " + a_form.GetName() + " (" + a_form.GetType() + ")")
    ;     ;     Int formId = a_form.GetFormID()
    ;     ;     if (formId < 0)
    ;     ;         ; GetFormId is broken for light mods, so we have to fix this ourselves
    ;     ;         formId = formId + 2147483647 ; formId + INT_MAX
    ;     ;         debug.Trace("Ref (light) form id: " + formId)
    ;     ;         Int localFormId = Math.LogicalAnd(formId, 4095) + 1 ; (formId & 0xfff) + 1
    ;     ;         debug.Trace("Ref (light) local form id: " + localFormId)
    ;     ;         Int modIndex = Math.LogicalAnd(Math.RightShift(formId, 12), 4095) ; (formId >> 12) & 0xfff
    ;     ;         debug.Trace("Light mod index: " + modIndex)
    ;     ;         String modName = Game.GetLightModName(modIndex)
    ;     ;         debug.Trace("Light mod name: " + modName)
    ;     ;     else
    ;     ;         debug.Trace("Ref form id: " + formId)
    ;     ;         Int localFormId = Math.LogicalAnd(formId, 16777215); formId & 0xffffff
    ;     ;         debug.Trace("Ref local form id: " + localFormId)
    ;     ;         Int modIndex = Math.RightShift(formId, 24)
    ;     ;         debug.Trace("Mod index: " + modIndex)
    ;     ;         String modName = Game.GetModName(modIndex)
    ;     ;         debug.Trace("Mod name: " + modName)
    ;     ;     endIf
    ;     ; endIf
    ;     debug.Trace("Ref " + refIndex)
    ;     refIndex += 1
    ; endWhile
    debug.Trace("Done looping through refs")
    if InteriorRefListId > -1
        return true
    else
        Debug.MessageBox("Failed to save shop. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
        return false
    endif
endFunction

bool function LoadInteriorRefs()
    ; TODO: this should not save anything if player is not currently in their shop
    Cell currentCell = PlayerRef.GetParentCell()
    bool result = BRInteriorRefList.ClearCell(currentCell)
    debug.Trace("ClearCell result: " + result)
    result = BRInteriorRefList.Load(ApiUrl, ApiKey, InteriorRefListId, currentCell, ShopXMarker)
    debug.Trace("Done loading interior refs from API")
    if result
        return true
    else
        Debug.MessageBox("Failed to load shop. Please submit a bug on Nexus Mods with the contents of BazaarRealmPlugin.log and BazaarRealmClient.log usually located in C:\\Users\\<your user>\\Documents\\My Games\\Skyrim Special Edition\\SKSE.")
        return false
    endif
endFunction

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