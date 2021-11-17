function _DILLY:InitiateLevelTable()
	sql.Query("CREATE TABLE IF NOT EXISTS dilly_levels(SteamID TEXT, experience INTEGER, level INTEGER)")
end

function _DILLY:InitiatePly(ply)
	if (!ply || type(ply) != "Player") then return end
	
	local steamid = ply:SteamID()
	sql.Query("INSERT INTO dilly_levels(SteamID, experience, level) VALUES('" .. steamid .. "', 0, 0)")
end

function _DILLY:GetPlyData(ply, which)
	if (!ply || type(ply) != "Player") then return end

	local steamid = ply:SteamID()
	local stuff = sql.Query("SELECT experience, level FROM dilly_levels WHERE SteamID='" .. steamid .. "'")
	
	if (!which) then
		return stuff[1].experience, stuff[1].level
	elseif (which == "exp") then
		return stuff[1].experience
	elseif (which == "lvl") then
		return stuff[1].level
	end
end

function _DILLY:UpdatePlyData(ply, experience, level)
	if (!ply || type(ply) != "Player") then return end
	
	local steamid = ply:SteamID()
	sql.Query("UPDATE dilly_levels SET experience=" .. experience .. "")
	hook.Run("_dillyExperienceUpdate", ply, experience)
	
	if (!level) then return end
	sql.Query("UPDATE dilly_levels SET level=" .. level .. "")
	hook.Run("_dillyLevelUpdate", ply, level)
end

function _DILLY:GetTopLevels()
	local highestLvl = {}

	for _, ply in pairs(player.GetAll()) do
		highestLvl[#highestLvl + 1] = {name = ply:Nick(), level = ply:GetLvl()}
	end

	table.SortByMember(highestLvl, level)
	return util.TableToJSON(highestLvl)
end

_DILLY:GetTopLevels()

function _DILLY:GetPlyFromName(name)
	local targetPly = {}
	for k,v in pairs(player.GetAll()) do
		if string.match(string.lower(v:Nick()), name) then
			table.insert(targetPly, v)
		end
	end

	if (#targetPly > 1) then ply:ChatPrint("There is more than one player with that name!") return end
	if (#targetPly == 0) then ply:ChatPrint("There is nobody online with that name!") return end

	return targetPly[1]
end

function _DILLY:GetExperienceBracket(level)
	level = tonumber(level)

	if (level >= 0 && level <= 10) then
		return _DILLY.CONFIG.experienceRequiredPerLevel["1-10"]
	elseif (level >= 11 && level <= 20) then
		return _DILLY.CONFIG.experienceRequiredPerLevel["11-20"]
	elseif (level >= 21 && level <= 30) then
		return _DILLY.CONFIG.experienceRequiredPerLevel["21-30"]
	elseif (level >= 31 && level <= 40) then
		return _DILLY.CONFIG.experienceRequiredPerLevel["31-40"]
	elseif (level >= 41 && level <= 50) then
		return _DILLY.CONFIG.experienceRequiredPerLevel["41-50"]
	elseif (level >= 51 && level <= 60) then
		return _DILLY.CONFIG.experienceRequiredPerLevel["51-60"]
	elseif (level >= 61 && level <= 70) then
		return _DILLY.CONFIG.experienceRequiredPerLevel["61-70"]
	elseif (level >= 71 && level <= 80) then
		return _DILLY.CONFIG.experienceRequiredPerLevel["71-80"]
	elseif (level >= 81 && level <= 90) then
		return _DILLY.CONFIG.experienceRequiredPerLevel["81-90"]
	elseif (level >= 91 && level <= 100) then
		return _DILLY.CONFIG.experienceRequiredPerLevel["91-100"]
	elseif (level >= 101) then
		return _DILLY.CONFIG.experienceRequiredPerLevel["100+"]
	end
end

local plyMeta = FindMetaTable("Player")

function plyMeta:GetLvl()
	local level = tonumber(_DILLY:GetPlyData(self, "lvl"))
	return level || 0
end

function plyMeta:AddExpPoints(amount)
	local expBracket = _DILLY:GetExperienceBracket(self:GetLvl())
	local currentExp = _DILLY:GetPlyData(self, "exp")
	local newExp = currentExp + amount

	if (newExp >= expBracket) then
		hook.Run("_dillyLevelUp", self)
		_DILLY:UpdatePlyData(self, 0, self:GetLvl() + 1)
	else
		_DILLY:UpdatePlyData(self, newExp)
	end
end

hook.Add("PlayerInitialSpawn", "_dilly first join add ply to db", function(ply)
	local steamid = ply:SteamID()
	local plyInDB = sql.Query("SELECT SteamID FROM dilly_levels WHERE SteamID='" .. steamid .. "'")

	if (!plyInDB) then
		_DILLY:InitiatePly(ply)
		print(string.format("[D_Levels] %s has been succesfully initialized in the database.", ply:Nick()))
	end

	ply:SetNWString("_dillyPlyLevel", _DILLY:GetPlyData(ply, "lvl"))
	ply:SetNWString("_dillyPlyExperience", _DILLY:GetPlyData(ply, "exp"))
	local expBracket = _DILLY:GetExperienceBracket(ply:GetLvl())
	ply:SetNWString("_dillyPlyExpBracket", expBracket)

	if (ply:GetLvl() < 100) then
		timer.Create(steamid .. "xpTimer", _DILLY.CONFIG.timeIntervalExperienceReward, 0, function()
			ply:AddExpPoints(_DILLY.CONFIG.experienceRewardForTime)
			_DILLY:SendNotification(ply, "You have gained " .. _DILLY.CONFIG.experienceRewardForTime .. " experience for playing!", 0)
		end)
	end
end)

hook.Add("PlayerDisconnected", "_dilly remove timer", function(ply)
	local steamid = ply:SteamID()
	if (timer.Exists(steamid .. "xpTimer")) then print("got it") timer.Remove(steamid .. "xpTimer") end
end)

concommand.Add("set_player_level", function(ply, cmd, args)
	if (!ply:IsSuperAdmin()) then
		ply:ChatPrint("You shouldn't be using this command.")
		return
	end

	local name = string.lower(args[1])
	local lvl = tonumber(args[2])
	local exp = sql.Query("SELECT experience FROM dilly_levels WHERE steamid='" .. ply:SteamID() .. "'")[1].experience

	local target = _DILLY:GetPlyFromName(name)
	if (!target || type(target) != "Player") then return end
	local steamid = target:SteamID()

	sql.Query("UPDATE dilly_levels SET level=" .. lvl .. " WHERE SteamID='" .. steamid .. "'")
	ply:AddExpPoints(-exp)
	hook.Run("_dillyLevelUpdate", target, lvl, true)
	hook.Run("_dillyExperienceUpdate", target, 0)
	_DILLY:SendNotification(target, string.format("Your level has been set to %s by %s.", lvl, ply:Nick()), 0)
	ply:ChatPrint(string.format("Succesfully set %s's level to %s.", target:Nick(), lvl))
end)