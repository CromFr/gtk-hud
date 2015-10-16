module provider;

import std.file;
import std.conv : to;
import std.algorithm;
import std.string;
import std.typecons;
import core.sys.posix.dlfcn;

struct MenuEntry{
	string path;
	string shortcut;
	c_MenuEntry* c_entry;
}
extern(C){
	
	struct c_MenuEntry{
		char* path;
		char* shortcut;
		void* data;
	}
	struct c_MenuList{
		c_MenuEntry* menus;
		uint length;
	}
}

class ProviderList{
	this(in string providerPath){
		import std.path;
		dirEntries(providerPath, "*.so", SpanMode.depth)
			.each!((file){
				providers ~= new Provider(file);
			});
	}

	
	Tuple!(MenuEntry[],"list", Provider,"provider") menuList(){
		foreach(p ; providers){
			auto list = p.menuList;
			if(list !is null)
				return Tuple!(MenuEntry[],"list", Provider,"provider")(list, p);
		}
		return Tuple!(MenuEntry[],"list", Provider,"provider")(null, null);
	}


private:
	Provider[] providers;


}


class Provider{
	this(in DirEntry file){

		libhdl = dlopen(file.name.toStringz, RTLD_NOW);
		if(!libhdl){
			throw new Exception("Failed to load: "~dlerror.to!string);
		}

		c_getMenuList = cast(typeof(c_getMenuList)) dlsym(libhdl, "getMenuList".toStringz);
		if(char* e=dlerror()){
			throw new Exception(e.to!string);
		}
		c_freeMenuList = cast(typeof(c_freeMenuList)) dlsym(libhdl, "freeMenuList".toStringz);
		if(char* e=dlerror()){
			throw new Exception(e.to!string);
		}
		c_execMenu = cast(typeof(c_execMenu)) dlsym(libhdl, "execMenu".toStringz);
		if(char* e=dlerror()){
			throw new Exception(e.to!string);
		}

	}


	package
	MenuEntry[] menuList(){
		MenuEntry[] ret;

		c_menuList = c_getMenuList();

		if(c_menuList==null)
			return null;

		foreach(i ; 0..c_menuList.length){
			auto c_menu = c_menuList.menus[i];
			ret~=MenuEntry(
				c_menu.path.to!string,
				c_menu.shortcut.to!string,
				&c_menu
			);
		}

		return ret;
	}

	void execMenu(ref MenuEntry menu){
		c_execMenu(menu.c_entry);
	}

	void freeMenuList(){
		if(c_menuList !is null)
			c_freeMenuList(c_menuList);
	}


		



private:

	void* libhdl;
	c_MenuList* function() c_getMenuList;
	void function(c_MenuList*) c_freeMenuList;
	void function(c_MenuEntry*) c_execMenu;

	c_MenuList* c_menuList = null;
}