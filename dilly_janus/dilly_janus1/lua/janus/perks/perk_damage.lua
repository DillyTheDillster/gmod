--[[
	Name: perk_damage.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
	
	THIS IS AN EXAMPLE PERK FILE, FEEL FREE TO MODIFY IT
]]--

local Perk = {}
Perk.Name = "Damage I"
Perk.Type = "Damage"
Perk.Rank = 1
Perk.UnlockLevel = 1
Perk.Description = "You make 10x more damage on every attack."
Perk.OnActivate = function( tblPerkTable, pPlayer )
end
Perk.OnDeactivate = function( tblPerkTable, pPlayer )
end
Perk.Function = function( tblPerkTable, target, dmginfo )
	if not IsValid(dmginfo:GetAttacker()) or not dmginfo:GetAttacker():IsPlayer() then return end
	if tblPerkTable.ActivePlayers[dmginfo:GetAttacker():SteamID64()] then
		dmginfo:SetDamage(dmginfo:GetDamage()*10)
	end
end
Perk.FunctionHook = "EntityTakeDamage"
Janus.Perks:RegisterPerk( Perk )

local Perk = {}
Perk.Name = "Damage II"
Perk.Type = "Damage"
Perk.Rank = 2
Perk.UnlockLevel = 4
Perk.Description = "You make 20x more damage on every attack."
Perk.OnActivate = function( tblPerkTable, pPlayer )
end
Perk.OnDeactivate = function( tblPerkTable, pPlayer )
end
Perk.Function = function( tblPerkTable, target, dmginfo )
	if not IsValid(dmginfo:GetAttacker()) or not dmginfo:GetAttacker():IsPlayer() then return end
	if tblPerkTable.ActivePlayers[dmginfo:GetAttacker():SteamID64()] then
		dmginfo:SetDamage(dmginfo:GetDamage()*20)
	end
end
Perk.FunctionHook = "EntityTakeDamage"
Janus.Perks:RegisterPerk( Perk )