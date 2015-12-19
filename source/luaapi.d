module luaapi;

import std.traits;
import luad.all;

void luaapiSetupState(LuaState lua){
	foreach(member ; __traits(allMembers, mixin(__MODULE__))){
		static if(isCallable!(mixin(member)) && member!=__FUNCTION__){
			lua[member] = mixin("&"~member);
		}
	}
}



string baseName(in string file){
	import std.path;
	return file.baseName;
}