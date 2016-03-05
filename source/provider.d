import std.file;
import std.conv : to;
import std.algorithm;
import std.array;
import std.string;
import std.typecons;
import luad.all;

import config;
import settings;

public import entry;



class Provider{
	this(in DirEntry file){
		import std.path;
		luaFile = file;
		name = file.baseName.stripExtension;

		//TODO load value from config
		enabled = true;

		reloadFile();
	}
	void reloadFile(){
		import luaapi;

		if(lua !is null)
			lua.destroy();
		lua = new LuaState;
		lua.openLibs();
		lua.luaapiSetupState();

		lua.doFile(luaFile);
		lua.doString("init()");

		settings = null;//TODO: maybe destroy?
		settings = new Settings(lua.get!(LuaSetting[string])("settings"));

		auto settingsPath = CFG_PATH_USERCFG~"/providers/"~name~".json";
		if(!settingsPath.exists)std.file.write(settingsPath, null);

		import std.json;
		JSONValue jsonSettings = parseJSON(settingsPath.readText);
		if(jsonSettings.type == JSON_TYPE.OBJECT){
			string[string] jsonSettingsAA;
			foreach(key, value ; jsonSettings.object){
				jsonSettingsAA[key] = value.str;
			}
			settings.overrideSettings(jsonSettingsAA);
		}
		else{
			assert(jsonSettings.isNull, settingsPath~" is not a valid setting file. Try removing it.");
		}

		settings.bindFile(DirEntry(settingsPath));
	}

	void execute(Entry entry){
		lua.get!LuaFunction("execute").call(entry.luaEntry);
	}


	immutable string name;
	bool enabled;
	Settings settings;
	

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
}