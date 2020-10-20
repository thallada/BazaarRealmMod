scriptname BRInteriorRefList

bool function Create(string apiUrl, string apiKey, int shop_id, quest quest) global native
bool function ClearCell() global native
bool function Load(string apiUrl, string apiKey, int interior_ref_id, ObjectReference player, quest quest) global native
bool function LoadByShopId(string apiUrl, string apiKey, int shop_id, ObjectReference player, quest quest) global native