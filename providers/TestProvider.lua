
settings = {
	folder = {
		name = "Test folder",
		valueType = "Folder",
		value = "a",
		description = "tooltip example"
	},
	file = {
		name = "Test file",
		valueType = "File",
		value = "a",
	},
	path = {
		name = "Test path",
		valueType = "Path",
		value = "defpath",
	},
	string = {
		name = "Test string",
		valueType = "String",
		value = "This is a string !",
	},
	int = {
		name = "Test int",
		valueType = "Int",
		value = "0",
	},
	intbis = {
		name = "Test int with min",
		valueType = "Int",
		value = "500",
		min = "9"
	},
	intter = {
		name = "Test int with min & max",
		valueType = "Int",
		value = "20",
		min = "9",
		max = "42"
	},
	float = {
		name = "Test float",
		valueType = "Float",
		value = "1.0",
	},
	bool = {
		name = "Test bool",
		valueType = "Bool",
		value = "true",
	},
	-- combo = {
	-- 	name = "Test combo",
	-- 	valueType = "Combo:[a,b,c]"
	-- 	value = "",
	-- }
}


function init()
	print("TestProvider.Init")
end


function getEntries()
	print("TestProvider.getEntries")
	return {
		{
			name = "EntryExample 1";
			fullName = "/c/.../yolo";
			-- shortcut = "";
			-- customData = nil;
		},{
			name = "EntryExample 2";
			fullName = "/c/.../yolo2";
			shortcut = "CTRL+C";
			-- customData = nil;
		}
	}
end


function execute(entry)
	print("TestProvider.execute")
	print("executing: "..entry["name"].." ("..entry["fullName"]..")")
end