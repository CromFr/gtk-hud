
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


function getMenuList()
	print("TestProvider.getMenuList")
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