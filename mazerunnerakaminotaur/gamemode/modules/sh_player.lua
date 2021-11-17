local meta = FindMetaTable("Player")

function meta:GetLives()
	return self:GetNWInt("Lives")
end

function meta:GetConfigTable()
	return MR_CONFIG.TeamSetup[self:Team()+1]
end

if(CLIENT) then return end

function meta:SetLives(amt)
	self:SetNWInt("Lives", amt)
end

function meta:AddLives(amt)
	self:SetNWInt("Lives", self:GetLives() + amt)
end

function GM:PlayerSpawn(ply)
	self.BaseClass.PlayerSpawn(self, ply)
	self:DeathscreenSpawn(ply)

	ply:DrawShadow(ply:Team() != 2 || self:GetRoundState() != STATE_INPROGRESS)
end

function GM:PlayerLoadout(ply)
	local info = ply:GetConfigTable()
	local weps, ammo = info.weps, info.ammo

	ply:SetWalkSpeed(info.walkspeed)
	ply:SetRunSpeed(info.runspeed)
	ply:SetCrouchedWalkSpeed(0.5)

	ply:SetMaxHealth(info.health || 100)

	ply:SetHealth(info.health || 100)
	ply:SetArmor(info.armor || 0)

	for k, v in pairs(weps) do
		ply:Give(v)
	end

	for k, v in pairs(ammo) do
		ply:SetAmmo(v, k)
	end
end

function GM:PlayerSetModel(ply)
	local model = ply:GetConfigTable().model
	
	if(istable(model)) then
		model = model[math.Rand(1, #model)]
	end

	ply:SetModel(model)
end

function GM:PlayerDeath(ply, inflictor, attacker)
	self.BaseClass.PlayerDeath(self, ply, inflictor, attacker)
	self:DeathscreenDeath(ply, inflictor, attacker)

	local lives = ply:GetLives() - 1

	if(lives <= 0) then
		self:Spectatorify(ply)
	end

	ply.nextSpawn = CurTime() + MR_CONFIG.RespawnTime
	ply:SetLives(lives)
end

function GM:PlayerDeathThink(ply)
	if(CurTime() < ply.nextSpawn) then return false end
	ply:Spawn()
end

function GM:GetFallDamage(ply, speed)
	return speed/15
end

function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(2)
	ply:SetCustomCollisionCheck(true)
end

function GM:PlayerNoClip(ply)
	return ply:Team() == 2
end

function GM:AllowPlayerPickup(ply)
	return ply:Team() != 2
end

function GM:PlayerCanPickupItem(ply)
	return ply:Team() != 2
end

function GM:CanPlayerSuicide(ply)
	return MR_CONFIG.CanSuicide
end

function GM:CanPlayerEnterVehicle(ply)
	return ply:Team() != 2
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
	return listener:Team() == talker:Team(), true
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	if(ply:Team() == 2) then return false end

	if(IsValid(attacker) && attacker:IsPlayer()) then
		return ply:Team() != attacker:Team()
	end
end

if(SERVER) then
	function GM:Move(ply, mv)
		if(ply:Team() == 0 && mv:GetVelocity():Length() > 0) then
			if(ply.MoveSoundDelay && CurTime() < ply.MoveSoundDelay) then return end

			ply:EmitSound(MR_CONFIG.MinotaurMovesound)
			ply.MoveSoundDelay = CurTime() + 0.4
		end
	end
end