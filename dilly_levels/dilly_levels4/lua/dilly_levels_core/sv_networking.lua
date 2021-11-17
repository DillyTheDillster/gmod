util.AddNetworkString("_dillyNotification")
util.AddNetworkString("_dillyOpenTopLvlsFrame")

function _DILLY:SendNotification(ply, text, typeof)
	net.Start("_dillyNotification")
	net.WriteString(text)
	net.WriteInt(typeof, 32)
	net.Send(ply)
end

hook.Add("_dillyLevelUpdate", "_dillySetNWVar", function(ply, level, forced)
	ply:SetNWString("_dillyPlyLevel", level)
	ply:SetNWString("_dillyPlyExpBracket", _DILLY:GetExperienceBracket(level))

	if (!forced) then
		_DILLY:SendNotification(ply, "You leveled up!", 0)
	end
end)

hook.Add("_dillyExperienceUpdate", "_dillySetNWVar", function(ply, exp)
	ply:SetNWString("_dillyPlyExperience", exp)
end)

hook.Add("PlayerDeath", "_dillyAddKillExp", function(victim, inflictor, attacker)
	if (type(attacker) == "Player") then
		attacker:AddExpPoints(_DILLY.CONFIG.experiencePerKill)
	end
end)

hook.Add("PlayerSay", "_dillyOpenTopLvlsFrame", function(ply, text)
	text = string.lower(text)
	if (_DILLY.CONFIG.chatMessage[text]) then
		net.Start("_dillyOpenTopLvlsFrame")
		net.WriteString(_DILLY:GetTopLevels())
		net.Send(ply)
		return ''
	end
end)