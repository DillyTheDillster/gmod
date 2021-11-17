--[[
	Name: sv_perks.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

Janus.Perks = Janus.Perks or {}
Janus.Perks.m_tblPerks = Janus.Perks.m_tblPerks or {}

function Janus.Perks:LoadPerks()
	Janus:LoadFiles( "janus/perks/" )
end

function Janus.Perks:RegisterPerk( tblPerk )
	tblPerk.ActivePlayers = {}
	function tblPerk:IsValid()
		return true
	end
	table.insert(self.m_tblPerks, tblPerk)
	if tblPerk.FunctionHook and tblPerk.Function then
		hook.Add(tblPerk.FunctionHook, tblPerk, tblPerk.Function)
	end
end

function Janus.Perks:GetPerks()
	return self.m_tblPerks
end

function Janus.Perks:GetPlayerPerks( pPlayer )
	local m_tblPlayerPerks = {}
	for k, v in pairs(self.m_tblPerks) do
		if v.UnlockLevel <= GetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", 0) then
			table.insert(m_tblPlayerPerks, v)
		end
	end
	return m_tblPlayerPerks
end

function Janus.Perks:SetPlayerActivePerk( pPlayer, perkName )
	for k, v in pairs(self.m_tblPerks) do
		if v.Name == perkName then
			v.ActivePlayers[pPlayer:SteamID64()] = true
			v:OnActivate( pPlayer )
		end
	end
end

function Janus.Perks:GetPlayerActivePerks( pPlayer )
	local m_tblPlayerPerks = {}
	for _, v in pairs(self.m_tblPerks) do
		if v.ActivePlayers[pPlayer:SteamID64()] then
			table.insert(m_tblPlayerPerks, v)
		end
	end
	return m_tblPlayerPerks
end

function Janus.Perks:RemovePlayerActivePerk( pPlayer, perkName )
	for k, v in pairs(self.m_tblPerks) do
		if v.Name == perkName then
			v.ActivePlayers[pPlayer:SteamID64()] = nil
			v:OnDeactivate( pPlayer )
		end
	end
end