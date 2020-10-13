scriptname BRMerchandiseList

; TODO: a save function that saves the merch to the server, load should load from server
bool function Toggle(string apiUrl, string apiKey, int merchandise_list_id, ObjectReference merchantShelf, Form placeholderStatic, Keyword shelfKeyword, Keyword chestKeyword, Keyword itemKeyword, Keyword toggleKeyword, Keyword nextKeyword, Keyword prevKeyword) global native
bool function NextPage(string apiUrl, string apiKey, int merchandise_list_id, ObjectReference merchantShelf, Form placeholderStatic, Keyword shelfKeyword, Keyword chestKeyword, Keyword itemKeyword, Keyword toggleKeyword, Keyword nextKeyword, Keyword prevKeyword) global native
bool function PrevPage(string apiUrl, string apiKey, int merchandise_list_id, ObjectReference merchantShelf, Form placeholderStatic, Keyword shelfKeyword, Keyword chestKeyword, Keyword itemKeyword, Keyword toggleKeyword, Keyword nextKeyword, Keyword prevKeyword) global native

bool function Replace3D(ObjectReference merchantShelf, Form placeholderStatic, Keyword shelfKeyword, Keyword itemKeyword) global native

Form function Buy(ObjectReference merchandisePlaceholder) global native

int function Create(string apiUrl, string apiKey, int shopId, ObjectReference merchantChest) global native