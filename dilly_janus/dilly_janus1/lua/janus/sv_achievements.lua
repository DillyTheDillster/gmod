--[[
	Name: sv_achievements.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

Janus.Achievements = Janus.Achievements or {}
Janus.Achievements.m_tblAchievements = Janus.Achievements.m_tblAchievements or {}

function Janus.Achievements:LoadAchievements()
	Janus:LoadFiles( "janus/achievements/" )
end

function Janus.Achievements:RegisterAchievement( tblAchievements )
	self.m_tblAchievements[tblAchievements.UID] = tblAchievements
end

function Janus.Achievements:GetAchievement(uid)
	return self.m_tblAchievements[uid]
end

function Janus.Achievements:CreatePlayerAchievementsData(pPlayer, transaction)
	transaction:Query(([[INSERT INTO player_levels SET steamID='%s']]):format(pPlayer:SteamID64()))
	transaction:Start(function(transaction, status, err)
		if (!status) then error(err) end
	end)
end

function Janus.Achievements:RetrievePlayerAchievementsData(pPlayer)
	local transaction = Janus.SQL.db:CreateTransaction()
	transaction:Query(([[SELECT achievements FROM player_levels WHERE steamID = '%s']]):format(pPlayer:SteamID64()))
	transaction:Start(function (transaction, status, err)
		if (!status) then error(err) end
		if not IsValid(pPlayer) then return end
		local info = transaction:getQueries()[1]:getData()
		if #info < 1 then
			Janus.Achievements:CreatePlayerAchievementsData(pPlayer, transaction)
		end
		info.achievements = (info[1].achievements or "")
		
		pPlayer.AchievementsData = util.JSONToTable(info.achievements)		
		pPlayer.CompletedAchievements = {}
		
		if pPlayer.AchievementsData then
			for k, v in pairs(pPlayer.AchievementsData) do
				if v >= self.m_tblAchievements[k].AmountRequired then
					table.insert(pPlayer.CompletedAchievements, k)
				end
			end
		else
			pPlayer.AchievementsData = {}
		end
	
		Janus.Net:SendCompletedAchievements( pPlayer )
	end)
end

function Janus.Achievements:StoreData(pPlayer)
	local transaction = Janus.SQL.db:CreateTransaction()
	transaction:Query(([[UPDATE player_levels SET achievements = '%s' WHERE steamID = '%s']]):format(util.TableToJSON(pPlayer.AchievementsData), pPlayer:SteamID64()))
	transaction:Start(function(transaction, status, err)
		if (!status) then error(err) end
	end)
end

function Janus.Achievements:GetAchievementProgress( pPlayer, uid )
	if pPlayer.AchievementsData then
		return pPlayer.AchievementsData[uid] or 0
	end
end

function Janus.Achievements:SetAchievementCompleted( pPlayer, uid )
	if pPlayer.CompletedAchievements then
		table.insert(pPlayer.CompletedAchievements, uid)
	end
	self:StoreData(pPlayer)
end

function Janus.Achievements:HasAchievement( pPlayer, name )
	if pPlayer.CompletedAchievements then
		if table.HasValue(pPlayer.CompletedAchievements, name) then
			return true
		end
	end
	
	return false
end

function Janus.Achievements:GiveReward( pPlayer, tblAchievements )
	local reward = tblAchievements.Reward

	if not tblAchievements.UseDarkRPMoneyAsReward then
		if Janus.Config.Pointshop then
			if isnumber(reward) then
				if not Janus.Config.Pointshop2 then
					pPlayer:PS_GivePoints(reward)
				else
					if not tblAchievements.Pointshop2_Prem then
						pPlayer:PS2_AddStandardPoints(reward, "",true)
					else
						pPlayer:PS2_AddPremiumPoints(reward)
					end
				end
			else
				pPlayer:PS_GiveItem(reward)
			end
		end
	else
		pPlayer:addMoney(reward)
	end
	
	hook.Call("Janus.Achievements_GiveReward", GAMEMODE, pPlayer, tblAchievements)
end

function Janus.Achievements:AddAchievementProgress( pPlayer, uid, amount )
	if not isnumber(amount) then
		error("[ACHIEVEMENTS] Trying to add non-number progression to "..self.m_tblAchievements[uid].PrintName.."!")
	end
	
	if pPlayer.AchievementsData then
		if self.m_tblAchievements[uid].RequiresPreviousUnlock then
			if not self:HasAchievement(pPlayer, self.m_tblAchievements[uid].RequiresPreviousUnlock) then return end
		end

		if not self:HasAchievement(pPlayer, uid) then
			pPlayer.AchievementsData[uid] = self:GetAchievementProgress(pPlayer, uid) + amount
			Janus.Net:SendProgression(pPlayer, uid, pPlayer.AchievementsData[uid])
			
			if self:GetAchievementProgress(pPlayer, uid) >= self.m_tblAchievements[uid].AmountRequired then
				self:StoreData(pPlayer)
				Janus.Net:NotifyCompleted(pPlayer, uid)
				self:SetAchievementCompleted(pPlayer, uid)
				self:GiveReward(pPlayer, self.m_tblAchievements[uid])
			end	
		end
	end
end