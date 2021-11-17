_DILLY = _DILLY || {}
_DILLY.CONFIG = _DILLY.CONFIG || {}

AddCSLuaFile("dilly_levels_config.lua")
AddCSLuaFile("dilly_levels_core/cl_main.lua")
AddCSLuaFile("dilly_levels_core/cl_vgui.lua")
AddCSLuaFile("dilly_levels_core/cl_hud.lua")

include("dilly_levels_config.lua")

if (SERVER) then
	include("dilly_levels_core/sv_main.lua")
	include("dilly_levels_core/sv_networking.lua")
end

if (CLIENT) then
	include("dilly_levels_core/cl_main.lua")
	include("dilly_levels_core/cl_vgui.lua")
	include("dilly_levels_core/cl_hud.lua")
end

print("[D_Levels] Initiated")