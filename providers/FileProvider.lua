
settings = {
	path = {
		name = "Path",
		value = [[C:\Users\Crom\AppData\Roaming\Microsoft\Windows\Start Menu]],
		valueType = "Folder",
		description = "The base folder where files will be listed"
	},
	recursive = {
		name = "Recursive",
		value = "true",
		valueType = "Bool",
		description = "Search recursively in path"
	}
}


dirsep = package.config:sub(1,1) -- / on UNIX, \\ on Windows

function init()
	print("FileProvider.Init")
end


function getEntries()
	print("FileProvider.getEntries")

	ret = {}

	function recurseFileList(dirEntry, data, depth)
		require 'lfs'
		if lfs.attributes(dirEntry,"mode")=="file" then
			--TODO: dont seem to support TM character
			data[#data+1] = {
				name=baseName(dirEntry);
				fullName = string.sub(dirEntry, #(settings.path.value)+1);
			}
		elseif lfs.attributes(dirEntry,"mode")=="directory" then
			if settings.recursive.value=="false" and depth >=1 then
				return
			end

			for file in lfs.dir(dirEntry) do
				if file~="." and file~=".." then
					recurseFileList(dirEntry..dirsep..file, data, depth+1)
				end
			end
		end
	end


	recurseFileList(settings.path.value, ret, 0)
	return ret
end


function execute(entry)
	print("FileProvider.execute")

	fullPath = settings.path.value..entry["fullName"];
	if dirsep=="/" then
		-- Linux
		--os.execute('"'..entry["fullName"]..'"&')
		os.execute('xdg-open "'..fullPath..'"&')
	elseif dirsep=="\\" then
		-- Windows
		os.execute('START "'..fullPath..'" "'..fullPath..'"')
	end
end