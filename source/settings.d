module settings;

import std.conv : to, ConvException;

struct LuaSetting{
	string name;
	string description;
	string valueType;
	string value;
	string min;
	string max;
}

class Setting{
	this(in LuaSetting luaSetting){
		data = luaSetting;
		defaultValue = data.value;
	}

	LuaSetting data;
	alias data this;

	@property{
		const string value(){return data.value;}
		const T value(T)(){
			try return data.value.to!T;
			catch(ConvException e) throw new SettingValueException("Could not convert '"~data.value~"' to "~T.stringof, __FILE__, __LINE__, e);
		}
		void value(in string newvalue){
			import std.file : exists, isDir, isFile, FileException;

			final switch(valueType.to!SettingType) with(SettingType){
				case Folder:{
					//try{
					//	if(!exists(newvalue))
					//		throw new SettingValueException("Path '"~newvalue.to!string~"' does not exist");
					//	if(!isDir(newvalue))
					//		throw new SettingValueException("Path '"~newvalue.to!string~"' is not a directory");
					//}catch(FileException e){
					//	throw new SettingValueException("File exception", __FILE__, __LINE__, e);
					//}
				}break;
				case File:{
					//try{
					//	if(!exists(newvalue))
					//		throw new SettingValueException("Path '"~newvalue.to!string~"' does not exist");
					//	if(!isFile(newvalue))
					//		throw new SettingValueException("Path '"~newvalue.to!string~"' is not a directory");
					//}catch(FileException e){
					//	throw new SettingValueException("File exception", __FILE__, __LINE__, e);
					//}
				}break;
				case Path:{
					//try{
					//	if(!exists(newvalue))
					//		throw new SettingValueException("Path '"~newvalue.to!string~"' does not exist");
					//}catch(FileException e){
					//	throw new SettingValueException("File exception", __FILE__, __LINE__, e);
					//}
				}break;
				case String:{
				}break;
				case Int:{
					long valueInt;
					try valueInt = newvalue.to!long;
					catch(ConvException e)
						throw new SettingValueException("Can't convert "~newvalue~" to long", __FILE__, __LINE__, e);
					if(min !is null && valueInt<min.to!long)
						throw new SettingValueException("Value "~newvalue~" is lower than minimum ("~min~")");
					if(max !is null && valueInt>max.to!long)
						throw new SettingValueException("Value "~newvalue~" is larger than maximum ("~max~")");
				}break;

				case Float:{
					double valueFloat;
					try valueFloat = newvalue.to!double;
					catch(ConvException e)
						throw new SettingValueException("Can't convert "~newvalue~" to double", __FILE__, __LINE__, e);
					if(min !is null && valueFloat<min.to!double)
						throw new SettingValueException("Value "~newvalue~" is lower than minimum ("~min~")");
					if(max !is null && valueFloat>max.to!double)
						throw new SettingValueException("Value "~newvalue~" is larger than maximum ("~max~")");
				}break;

				case Bool:{
					try newvalue.to!bool;
					catch(ConvException e)
						throw new SettingValueException("Can't convert "~newvalue~" to bool", __FILE__, __LINE__, e);
				}break;

				case Combo:{
					//TODO
				}break;
			}

			data.value = newvalue;
			if(owner !is null){
				owner.notifyChange(name);
			}
		}
	}
	immutable string defaultValue;

package:

	//Sets an oner that will be notified if setting value changes
	void bindOwner(Settings settings){
		owner = settings;
	}

private:
	Settings owner = null;

}

enum SettingType{
	///Path to an existing folder
	Folder,

	///Path to an existing file
	File,

	///Path to a file or a folder
	Path,

	///String, possibly multi-line
	String,

	///Signed integer (long)
	Int,

	///Signed floating number (double)
	Float,

	///true/false
	Bool,

	///Choice between multiple strings (via a Combo box)
	Combo,
}

class Settings{
	import std.file;
	import std.json;

	this(LuaSetting[string] luaSettingList){
		foreach(key, luaSetting ; luaSettingList){
			auto setting = new Setting(luaSetting);
			settings[key] = setting;
			setting.bindOwner(this);
		}
	}

	void overrideSettings(in string[string] values){
		foreach(name, value ; values){
			if(name in settings){
				settings[name].value = value;
			}
			else
				throw new SettingValueException("'"~name~"' is not in settings list: "~settings.keys.to!string);
		}
	}

	//Once binded, any change to any setting will be saved on the file
	void bindFile(in DirEntry userSettingsFile){
		file = userSettingsFile;
		binded = true;
	}


	alias settings this;
	Setting[string] settings;

package:
	void notifyChange(string settingName){
		//Save to file
		import std.file : fwrite = write;
		import std.algorithm : each;

		JSONValue json;
		settings.each!((key, setting){
				if(setting.value != setting.defaultValue)
					json[key] = setting.value;
			});

		if(binded){
			//TODO: add timeout until write to avoid writing too often (5 sec?)
			file.fwrite(json.toPrettyString());
		}
	}

private:
	bool binded = false;
	DirEntry file;

}






class SettingValueException : Exception{
	public @safe pure nothrow 
	this(string message, string file =__FILE__, size_t line = __LINE__, Throwable next = null){
		super(message, file, line, next);
	}
}