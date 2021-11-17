local root = GM.FolderName .. "/gamemode/modules/"
local files = file.Find(root.."*", "LUA")

AddCSLuaFile("config.lua")
include("config.lua")

MsgC(Color(0, 255, 0), "\n----- Started Module Load -----\n")
for k, f in SortedPairs(files, true) do
	local path = root..f

	if(f:StartWith("sv_")) then
		MsgC(Color(255, 255, 255, 255), "Included serverside file ", Color(0, 255, 255), f, "\n")
		include(path)
	end

	if(f:StartWith("cl_")) then
		MsgC(Color(255, 255, 255, 255), "Sent clientside file ", Color(255, 255, 0), f, "\n")
		AddCSLuaFile(path)
	end

	if(f:StartWith("sh_")) then
		MsgC(Color(255, 255, 255, 255), "Included and sent shared file ", Color(0, 0, 255), f, "\n")
		AddCSLuaFile(path)
		include(path)
	end
end
MsgC(Color(0, 255, 0), "----- Completed Module Load -----\n\n")
