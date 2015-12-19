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


private:
	Provider[] providers;
}


class Provider{
	this(in DirEntry file){
		luaFile = file;

		lua = new LuaState;
		lua.openLibs();

		lua.doFile(luaFile);
		lua.doString("init()");
	}
	void execute(Entry entry){
		lua.get!LuaFunction("execute").call(entry.luaEntry);
	}

	immutable DirEntry luaFile;

package:
	Entry[] entries(){
		import std.stdio;
		LuaEntry[] ret = lua
			.get!LuaFunction("getEntries")
			.call!(LuaEntry[])();

		//lua.doString("entries = getEntries()");
		//ret ~= lua.get!LuaTable("entries").toStruct!LuaEntry;

		return ret.map!((e){return Entry(e, this);}).array;
	}

private:
	LuaState lua;
}