import std.file;
import std.conv : to;
import std.algorithm;
import std.array;
import std.string;
import std.typecons;
import luad.all;

import settings;

public import entry;



class Provider{
	this(in DirEntry file){
		import std.path;
		luaFile = file;
		name = file.baseName.stripExtension;
		reloadFile();
	}
	void reloadFile(){
		import luaapi;

		if(lua !is null)lua.destroy();
		lua = new LuaState;
		lua.openLibs();
		lua.luaapiSetupState();

		lua.doFile(luaFile);
		lua.doString("init()");

		settings.destroy();
		auto settingsLua = lua.get!(Setting[string])("settings");
		foreach(code, setting ; settingsLua){
			setting.code = code;
			settings~=setting;
		}
	}

	void execute(Entry entry){
		lua.get!LuaFunction("execute").call(entry.luaEntry);
	}

	void setSettingValue(in string code, in string value){
		//TODO
		//lua["settings"][code]["value"] = value;
	}
	const Setting[] getSettings(){return settings.dup;}

	immutable string name;
	

	Entry[] entries(){
		import std.stdio;
		LuaEntry[] ret = lua
			.get!LuaFunction("getEntries")
			.call!(LuaEntry[])();

		return ret.map!((e){return Entry(e, this);}).array;
	}

private:
	DirEntry luaFile;
	LuaState lua;
	Setting[] settings;
}