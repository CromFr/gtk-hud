import provider;

struct LuaEntry{
	string name;
	string fullName;

	string shortcut;

	ubyte[] customData;
}



struct Entry{
	LuaEntry luaEntry;
	alias luaEntry this;//make luaEntry members directly accessible 

	Provider provider;
}