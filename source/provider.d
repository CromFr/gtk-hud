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

	
	Entry[] menuList(){
		Entry[] ret;
		foreach(p ; providers){
			ret ~= p.menuList;
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
	Entry[] menuList(){
		import std.stdio;
		Entry[] ret;
		ret = lua.get!LuaFunction("getMenuList").call!(Entry[])();
		//lua.doString("menuList = getMenuList()");
		//ret ~= lua.get!LuaTable("menuList").toStruct!Entry;


		return ret;
	}

	void execMenu(ref Entry menu){
	}


		

private:
	LuaState lua;
}