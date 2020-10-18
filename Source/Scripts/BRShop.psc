scriptname BRShop

bool function Create(string apiUrl, string apiKey, string name, string description = "", quest quest) global native
bool function Update(string apiUrl, string apiKey, int id, string name, string description = "", quest quest) global native
bool function Get(string apiUrl, string apiKey, int id, quest quest) global native