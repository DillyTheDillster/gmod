if not SERVER then return end

util.AddNetworkString("LastProp_OpenMenu")
util.AddNetworkString("LastProp_Action")
util.AddNetworkString("LPSText")
local LPSblock = false

function GetLivingPlayers( onTeam )
	local allPly = team.GetPlayers( onTeam )
	local livingPly = {}
	for _, v in pairs(allPly) do
		if( IsValid(v) && v:Alive() ) then
			livingPly[#livingPly + 1] = v
		end
	end
	return livingPly
end

function AmmoToGive(ammo)
	if ammo == "SMG1" then
		return 25
	else
		return 6
	end
end

function LastProp:Check()
	if LPSblock then return end
	if timer.Exists("lastpropChecker") && timer.TimeLeft("lastpropChecker") != nil then
		if timer.TimeLeft("lastpropChecker") > 0 then
		return end
	end
	local props = 0
	local hunters = 0
	local target
	for _, ply in pairs(player.GetAll()) do
		if not ply:Alive() then continue end
		if ply:Team() == TEAM_PROPS then
			props = props + 1
			if not ply.LastProp_Mode then
				target = ply
			end
		elseif ply:Team() == TEAM_HUNTERS then
			hunters = hunters + 1
		end
	end

	if props == 1 and hunters > 0 and target and IsValid(target) then
		LPSblock = true
		net.Start("LastProp_OpenMenu")
		net.Send(target)
		--target:SetViewOffset(Vector(0,0,target.propHeight))
	end
end

net.Receive("LastProp_Action", function(len, ply)
	local give = net.ReadBool()
	if not give then timer.Remove("checkpropLPS") return end
	for k, v in pairs(player.GetAll()) do
		--local Wid = ScrW()/2
		--local Hig = ScrH()/2
		net.Start("LPSText")
		net.Send(v)
	end
	ply.LPStrail = util.SpriteTrail(ply, 0, team.GetColor(ply:Team()), false, 15, 1, 4, 1/(15+1)*0.5, "trails/plasma.vmt")
	--draw.DrawText( "Hello there!", "TargetID", ScrW() * 0.5, ScrH() * 0.25, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	local props = 0
	local hunters = 0
	for _, ply in pairs(player.GetAll()) do
		if not ply:Alive() then continue end
		if ply:Team() == TEAM_PROPS then
			props = props + 1
		elseif ply:Team() == TEAM_HUNTERS then
			hunters = hunters + 1
		end
	end

	if props == 1 and hunters > 0 then
		local wep = table.Random(LastProp.Config.PossibleGuns)
		ply.LastProp_Mode = true
		ply:SendLua("LocalPlayer().LastProp_Mode = true")
		ply:Give(wep, true)
		if LastProp.Config.AmmoType[wep] then
			ply:RemoveAllAmmo()
			ply:StripAmmo()
			ply:SetAmmo( 0, LastProp.Config.AmmoType[wep] )
			timer.Simple(0.5,function()
				ply:GiveAmmo(#GetLivingPlayers(TEAM_HUNTERS) * 8 - AmmoToGive(LastProp.Config.AmmoType[wep]), LastProp.Config.AmmoType[wep], true)
			end)
		end
		ply:SetNWBool("DisableThirdPerson", true)
	end
end)

hook.Add("OBJHUNT_RoundEnd", "LastProp_Check", function()
	timer.Remove("LastProp_Check")
	timer.Remove("lastpropChecker")
	timer.Remove("checkpropLPS")
	LPSblock = false
end)

hook.Add("OBJHUNT_RoundStart", "LastProp_Check", function()
	if not timer.Exists("checkpropLPS") then
		timer.Create("checkpropLPS",10,0,function()
			timer.Simple(0.1, LastProp.Check)
		end)
	end
	for _, ply in pairs(player.GetAll()) do
		ply.LastProp_Mode = false
		ply:SendLua("LocalPlayer().LastProp_Mode = false")
		ply:SetNWBool("DisableThirdPerson", false)
	end

	timer.Create("lastpropChecker",30,1,LastProp.Check) -- GetConVar("ph_hunter_blindlock_time"):GetInt()
	LPSblock = false
end)

hook.Add("PlayerDeath", "LastProp_Check", function(victim, inflictor, attacker)
	if victim:Team() == 1 then timer.Simple(0.1, LastProp.Check) end

	if attacker.LastProp_Mode && attacker:Team() != victim:Team() then
		LastProp.Config.RewardFunc(attacker)
	elseif victim.LastProp_Mode && attacker:Team() != victim:Team() then
		LastProp.Config.RewardFunc2(attacker)
	end
end)

hook.Add("PostGamemodeLoaded", "Hook_PropHunt", function()
	local GM = gmod.GetGamemode()

	-- Called when player tries to pickup a weapon
	function GM:PlayerCanPickupWeapon(pl, ent)
		if pl:Team() != TEAM_HUNTERS and not pl.LastProp_Mode then
			return false
		end

		return true
	end

	local PlayerShouldTakeDamage = GM.PlayerShouldTakeDamage
	function GM:PlayerShouldTakeDamage(ply, attacker)
		if ply:Team() == attacker:Team() then return false end

		return PlayerShouldTakeDamage(ply, attacker) or (attacker and IsValid(attacker) and attacker:Team() == TEAM_PROPS and attacker.LastProp_Mode)
	end
end)

hook.Add("PlayerTick", "view", function(ply)
	--if ply.LastProp_Mode then
	if ply.propHeight == nil || ply:Team() != TEAM_PROPS || not ply.LastProp_Mode then
		ply:SetViewOffsetDucked(Vector(ply:GetViewOffset().x,ply:GetViewOffset().y,math.Clamp(ply:GetViewOffset().z - 32, 0, 64)))
	elseif ply.propHeight != nil && ply:Team() == TEAM_PROPS && ply.LastProp_Mode then
	 	if ply:GetViewOffset() != Vector(0,0,math.Clamp(ply.propHeight*1, 0, 70)) then
			ply:SetViewOffset(Vector(0,0,math.Clamp(ply.propHeight*1, 0, 70)))
		end
	end
end)