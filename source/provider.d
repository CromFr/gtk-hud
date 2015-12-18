import std.file;
import std.conv : to;
import std.algorithm;
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
		lua = new LuaState;
		lua.openLibs();

		lua.doFile(file);
		lua.doString("init()");
	}


	package
	Entry[] entries(){
		import std.stdio;
		Entry[] ret;
		ret = lua.get!LuaFunction("getEntries").call!(Entry[])();
		//lua.doString("entries = getEntries()");
		//ret ~= lua.get!LuaTable("entries").toStruct!Entry;


		return ret;
	}

	void execMenu(ref Entry menu){
	}


		

private:
	LuaState lua;
}