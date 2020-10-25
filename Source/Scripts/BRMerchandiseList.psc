scriptname BRMerchandiseList

; TODO: a save function that saves the merch to the server, load should load from server
bool function Toggle(string apiUrl, string apiKey, int shop_id, ObjectReference merchantShelf, Form activatorStatic, Keyword shelfKeyword, Keyword chestKeyword, Keyword itemKeyword, Keyword activatorKeyword, Keyword toggleKeyword, Keyword nextKeyword, Keyword prevKeyword) global native
bool function NextPage(string apiUrl, string apiKey, int shop_id, ObjectReference merchantShelf, Form activatorStatic, Keyword shelfKeyword, Keyword chestKeyword, Keyword itemKeyword, Keyword activatorKeyword, Keyword toggleKeyword, Keyword nextKeyword, Keyword prevKeyword) global native
bool function PrevPage(string apiUrl, string apiKey, int shop_id, ObjectReference merchantShelf, Form activatorStatic, Keyword shelfKeyword, Keyword chestKeyword, Keyword itemKeyword, Keyword activatorKeyword, Keyword toggleKeyword, Keyword nextKeyword, Keyword prevKeyword) global native

bool function Replace3D(ObjectReference merchantShelf, Form activatorStatic, Keyword shelfKeyword, Keyword itemKeyword) global native

Form function Buy(ObjectReference merchandiseActivator) global native

bool function Create(string apiUrl, string apiKey, int shopId, ObjectReference merchantChest) global native