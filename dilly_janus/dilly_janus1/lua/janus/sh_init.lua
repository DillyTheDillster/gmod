--[[
	Name: sh_init.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

Janus = Janus or {}

function Janus:PrintDebug( intLevel, ... )
	--ErrorNoHalt( "[Janus] ".. ... .. "\n" )
end

hook.Add( "Initialize", "Janus:Init", function()
	Janus:Initialize( false )
end )

include( SERVER and "sv_manifest.lua" or "cl_manifest.lua" )