--[[
	Name: cl_manifest.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

include "janus/sh_config.lua"
include "janus/sh_utils.lua"

include "janus/cl_networking.lua"

--Load vgui
local foundFiles, foundFolders = file.Find( Janus.Config.ADDON_PATH.. "vgui/*.lua", "LUA" )
for k, v in pairs( foundFiles ) do
	include( Janus.Config.ADDON_PATH.. "vgui/".. v )
end