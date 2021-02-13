scriptname BRShop

bool function Create(string apiUrl, string apiKey, string name, string description = "", quest quest) global native
bool function Update(string apiUrl, string apiKey, int id, string name, string description = "", int gold = 0, string shop_type = "general_store", Keyword[] keywords, bool keywords_excludes = true, quest quest) global native
bool function Get(string apiUrl, string apiKey, int id, quest quest) global native
bool function List(string apiUrl, string apiKey, quest quest) global native
Keyword[] function GetKeywordsSubArray(Keyword[] flatKeywordsArray, int subArrayIndex) global native
bool function SetVendorKeywords(Keyword[] keywords, bool keywordsExclude) global native
bool function RefreshGold(string apiUrl, string apiKey, int id, ObjectReference privateMerchantChest) global native