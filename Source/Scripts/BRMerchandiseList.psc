scriptname BRMerchandiseList

; TODO: a save function that saves the merch to the server, load should load from server
; bool function Toggle(string apiUrl, string apiKey, int shop_id, ObjectReference merchantShelf) global native
bool function NextPage(ObjectReference merchantShelf) global native
bool function PrevPage(ObjectReference merchantShelf) global native
bool function Load(string apiUrl, string apiKey, int shop_id, Cell shopCell, ObjectReference[] merchantShelves, ObjectReference merchantChest) global native
; bool function Refresh(string apiUrl, string apiKey, int shop_id, ObjectReference merchantShelf) global native

bool function Replace3D(ObjectReference merchantShelf) global native
bool function ReplaceAll3D(Cell shopCell) global native

bool function Create(string apiUrl, string apiKey, int shopId, Cell shopCell, ObjectReference[] merchantShelves, ObjectReference merchantChest) global native

int function GetQuantity(ObjectReference activator) global native
int function GetPrice(ObjectReference activator) global native