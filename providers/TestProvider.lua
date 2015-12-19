
settings = {
	path = {
		fullName = "Path",
		value = "",
		valueType = "folder"
	}
}


function init()
	print("TestProvider.Init")
end


function getEntries()
	print("TestProvider.getEntries")
	return {
		{
			name = "EntryExample";
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