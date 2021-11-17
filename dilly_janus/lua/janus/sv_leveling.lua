--[[
	Name: sv_leveling.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

Janus.Levels = Janus.Levels or {}

function Janus.Levels:LoadLevelingConditions()
	Janus:LoadFiles( "janus/conditions/" )
end

function Janus.Levels:SetLevel(pPlayer, level)
	if not (level or pPlayer:IsPlayer()) then return end
	SetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", (level))
	Janus.Net:PlayerLevelUp( pPlayer, level )
end

function Janus.Levels:SetXP(pPlayer, xp)
	if not (xp or pPlayer:IsPlayer()) then return end
	SetGlobalInt(SQLStr(pPlayer:SteamID64()).."XP", (xp))
end

function Janus.Levels:AddXP(pPlayer, amount)
	local PlayerLevel = (GetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", 0))
	local PlayerXP = (GetGlobalInt(SQLStr(pPlayer:SteamID64()).."XP", 0))
	amount = tonumber(amount)

	if (not amount or not IsValid(pPlayer) or not PlayerLevel or not PlayerXP or PlayerLevel >= Janus.Config.MaxLevel) then return 0 end
	if (not carryOver) then
		if (pPlayer.VXScaleXP) then
			amount = (amount*tonumber(pPlayer.VXScaleXP))
		end
	end
	
	local TotalXP = PlayerXP + amount

	if (TotalXP>=self:GetMaxXP(pPlayer)) then
		PlayerLevel = PlayerLevel + 1

		local RemainingXP = (TotalXP-self:GetMaxXP(pPlayer))
		if(Janus.Config.ContinueXP) then
			if(RemainingXP>0) then
				self:SetXP(pPlayer, 0)
				self:SetLevel(pPlayer, PlayerLevel)
				return pPlayer:AddXP(pPlayer, RemainingXP, true, true)
			end
		end
		
		self:SetLevel(pPlayer, PlayerLevel)
		self:SetXP(pPlayer, 0)
		
		self:StoreData(pPlayer,PlayerLevel,0)
	else
		self:StoreData(pPlayer,PlayerLevel,(TotalXP or 0))
		self:SetXP(pPlayer, math.max(0,TotalXP))

	end
	return (amount or 0)
end

function Janus.Levels:GetMaxXP(pPlayer)
	return (((10+(((GetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", 0) or 1)*((GetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", 0) or 1)+1)*90))))*Janus.Config.XPMult)
end

function Janus.Levels:AddLevels(levels)
	if ((GetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", 0) or 1) == Janus.Config.MaxLevel) then
		return false
	end
	if (((GetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", 0) or 1) +levels)>Janus.Config.MaxLevel) then
		// Determine how many levels we can add.
		local levelsCan = ((((GetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", 0) or 1)+levels))-Janus.Config.MaxLevel)
		if (levelsCan == 0) then
			return 0
		else
			self:StoreData(pPlayer, Janus.Config.MaxLevel, 0)
			SetGlobalInt(SQLStr(pPlayer:SteamID64()).."XP", 0)
			SetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", Janus.Config.MaxLevel)
			Janus.Net:PlayerLevelUp( pPlayer, levelsCan )
			return levelsCan
		end
	else
		self:StoreData(pPlayer,((GetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", 0) or 1) +levels), (GetGlobalInt(SQLStr(pPlayer:SteamID64()).."XP", 0) or 0))
		SetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", (GetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", 0) or 1) + levels)
		Janus.Net:PlayerLevelUp( pPlayer, levels )
		return levels
	end
end

function Janus.Levels:HasLevel(level)
	return ((pPlayer.level) >= level)
end

function Janus.Levels:CreatePlayerLevelData(pPlayer, transaction)
	transaction:Query(([[INSERT INTO player_levels SET steamID='%s']]):format(pPlayer:SteamID64()))
	transaction:Start(function(transaction, status, err)
		if (!status) then error(err) end
	end)
end

function Janus.Levels:RetrievePlayerLevelData(pPlayer)
	local transaction = Janus.SQL.db:CreateTransaction()
	transaction:Query(([[SELECT level,xp FROM player_levels WHERE steamID = '%s']]):format(pPlayer:SteamID64()))
	transaction:Start(function (transaction, status, err)
		if (!status) then error(err) end
		if not IsValid(pPlayer) then return end
		local info = transaction:getQueries()[1]:getData()
		if #info < 1 then
			Janus.Levels:CreatePlayerLevelData(pPlayer, transaction)
		end
		info.xp = (info[1].xp or 0)
		info.level = (info[1].level or 1)
		SetGlobalInt(SQLStr(pPlayer:SteamID64()).."XP", tonumber(info.xp))
		SetGlobalInt(SQLStr(pPlayer:SteamID64()).."Level", tonumber(info.level))
	end)
end

function Janus.Levels:StoreData(pPlayer, level, xp)
	xp = math.max(xp, 0)
	local transaction = Janus.SQL.db:CreateTransaction()
	transaction:Query(([[UPDATE player_levels SET level = %d WHERE steamID = '%s']]):format(level, pPlayer:SteamID64()))
	transaction:Query(([[UPDATE player_levels SET xp = %d WHERE steamID = '%s']]):format(xp, pPlayer:SteamID64()))
	transaction:Start(function(transaction, status, err)
		if (!status) then error(err) end
	end)
end