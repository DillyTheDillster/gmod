--[[
	Name: sv_manifest.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

AddCSLuaFile "janus/cl_init.lua"
AddCSLuaFile "janus/cl_manifest.lua"
AddCSLuaFile "janus/cl_networking.lua"

AddCSLuaFile "janus/sh_init.lua"
AddCSLuaFile "janus/sh_config.lua"
AddCSLuaFile "janus/sh_utils.lua"

include "janus/sh_config.lua"
include "janus/sh_utils.lua"

include "janus/sv_config.lua"
include "janus/sv_networking.lua"
include "janus/sv_leveling.lua"
include "janus/sv_perks.lua"
include "janus/sv_mysql.lua"
include "janus/sv_mysql_player.lua"
include "janus/sv_achievements.lua"

--Load vgui
local foundFiles, foundFolders = file.Find( Janus.Config.ADDON_PATH.. "vgui/*.lua", "LUA" )
for k, v in pairs( foundFiles ) do
	AddCSLuaFile( Janus.Config.ADDON_PATH.. "vgui/".. v )
end

resource.AddFile('sound/janus/levelup.wav')
resource.AddFile('materials/janus/perklocked.png')
resource.AddFile('materials/janus/perkunlocked.png')
resource.AddFile('resource/fonts/FrancoisOne.ttf')