import std.file;
import std.conv : to;
import std.algorithm;
import std.array;
import std.string;
import std.typecons;
import luad.all;

import entry;


class ProviderList{
	this(in string providerPath){
		import std.path;
		dirEntries(providerPath, "*.lua", SpanMode.depth)
			.each!((file){
				providers ~= new Provider(file);
			});
	}

	
	Entry[] entries(){
		Entry[] ret;
		foreach(p ; providers){
			ret ~= p.entries;
		}
		return ret;
	}


	Provider[] providers;
}


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


	struct Setting{
		string name;
		string description;
		string type;
		string value;
		string code;
	}
	enum SettingType : string{
		FOLDER = "folder",
		FILE   = "file",
		PATH   = "path",
		STRING = "string",
		INT    = "int",
		FLOAT  = "float",
		BOOL  = "bool",
	}

package:
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