--[[
	Name: init.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

include "sh_init.lua"

Janus.m_tblLoadedPlayers = Janus.m_tblLoadedPlayers or {}

function Janus:Load()
	self:PrintDebug( 0, "Loading Janus" )
	self.Perks:LoadPerks()
	self.Achievements:LoadAchievements()
	self.Levels:LoadLevelingConditions()
end

function Janus:Initialize( bReload )
	self.Net:Initialize()
	self.SQL:Initialize()
end

function Janus:LoadFiles( directory )
	local files, dirs = file.Find( directory .. "*", "LUA" )
	for k,v in pairs(files) do
		self:PrintDebug(0, directory .. "" .. v )
		include( directory .. "" .. v )
	end

	for _,v in pairs(dirs) do
		local perks = file.Find( directory .. "" .. v .. "/*.lua", "LUA" )
		for _,v2 in pairs(perks) do	
			self:PrintDebug(0, directory .. "" .. v .. "/" .. v2 )
			include( directory .. "" .. v .. "/" .. v2)
		end
	end
end

Janus:Load()

hook.Add("PlayerInitialSpawn", "Janus:PlayerInitialSpawn", function (pPlayer)
	print("[Janus] Retrieving info for player: "..pPlayer:Name())
	Janus.Levels:RetrievePlayerLevelData( pPlayer )
	Janus.Achievements:RetrievePlayerAchievementsData( pPlayer )
	Janus.Net:SendAchievements( pPlayer )
	Janus.Net:SendPerks( pPlayer )
	Janus.m_tblLoadedPlayers[pPlayer:SteamID64()] = true
end)

hook.Add("PlayerDisconnected", "Janus:PlayerInitialSpawn", function (pPlayer)
	local PlayerLevel = (GetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", 0))
	local PlayerXP = (GetGlobalInt(SQLStr(pPlayer:SteamID64()).."XP", 0))
	Janus.Achievements:StoreData(pPlayer)
	Janus.Levels:StoreData(pPlayer,PlayerLevel,(PlayerXP or 0))
end)

concommand.Add( "janus", function( pPlayer, strCmd, tblArgs )
	print("Leveling System by @Heracles421")
end )