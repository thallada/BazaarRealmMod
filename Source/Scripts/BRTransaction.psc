scriptname BRTransaction

bool function Create(string apiUrl, string apiKey, int shop_id, bool is_sell, int quantity, int amount, Keyword item_keyword, ObjectReference activator) global native
bool function CreateFromVendorSale(string apiUrl, string apiKey, int shop_id, bool is_sell, int quantity, int amount, Form merch_base, ObjectReference merch_chest) global native