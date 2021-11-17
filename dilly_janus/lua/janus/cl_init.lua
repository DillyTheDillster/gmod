--[[
	Name: cl_init.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

include "sh_init.lua"

Janus.m_tblPerks = Janus.m_tblPerks or {}
Janus.m_tblActivePerks = Janus.m_tblActivePerks or {}
Janus.m_tblRequestedPerks = Janus.m_tblRequestedPerks or {}
Janus.m_tblAchievements = Janus.m_tblAchievements or {}
Janus.m_tblAchievementsProgress = Janus.m_tblAchievementsProgress or {}
Janus.m_tblCompletedAchievements = Janus.m_tblCompletedAchievements or {}

function Janus:Load()	
	self:PrintDebug( 0, "Loading Janus" )
end

function Janus:Initialize( bReload )
	self.Net:Initialize()
end

Janus:Load()

hook.Add( "OnPlayerChat", "Janus:PerksMenuCommand", function( ply, strText, bTeam, bDead )
	strText = string.lower( strText )
	if ( strText == "!perks" ) then
		if ValidPanel( Janus.m_pnlPerks ) then
			Janus.m_pnlPerks:Remove()
		end

		Janus.m_pnlPerks = vgui.Create( "JanusPerksMenu" )
		Janus.m_pnlPerks:Center()
	elseif ( strText == "!achievements" ) then
		if ValidPanel( Janus.m_pnlAchievements ) then
			Janus.m_pnlAchievements:Remove()
		end

		Janus.m_pnlAchievements = vgui.Create( "JanusAchievementsMenu" )
		Janus.m_pnlAchievements:Center()
	end
end )