
settings = {
	path = {
		fullName = "Path",
		value = [[C:\Users\Crom\AppData\Roaming\Microsoft\Windows\Start Menu]],
		valueType = "folder"
	}
}


dirsep = package.config:sub(1,1) -- / on UNIX, \\ on Windows

function init()
	print("FileProvider.Init")
end


function getEntries()
	print("FileProvider.getEntries")

	ret = {}

	function recurseFileList(dirEntry, data)
		require 'lfs'
		if lfs.attributes(dirEntry,"mode")=="file" then
			--TODO: dont seem to support TM character
			data[#data+1] = {
				name=baseName(dirEntry);
				fullName = string.sub(dirEntry, #(settings.path.value)+1);
			}
		elseif lfs.attributes(dirEntry,"mode")=="directory" then
			for file in lfs.dir(dirEntry) do
				if file~="." and file~=".." then
					recurseFileList(dirEntry..dirsep..file, data)
				end
			end
		end
	end


	recurseFileList(settings.path.value, ret)
	return ret
end


function execute(entry)
	print("FileProvider.execute")

	if dirsep=="/" then
		-- Linux
		os.execute('"'..entry["fullName"]..'"&')
	elseif dirsep=="\\" then
		-- Windows
		os.execute('START "'..entry["fullName"]..'" "'..entry["fullName"]..'"')
	end
end