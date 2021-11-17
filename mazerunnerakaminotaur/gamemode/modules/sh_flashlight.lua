if(SERVER) then
	util.AddNetworkString("flashlight_charge")

	hook.Add("Think", "FlashlightThink", function()
		local decay = FrameTime() / MR_CONFIG.FlashlightTime

		for k, ply in pairs(player.GetAll()) do
			if ply:Alive() then
				if ply:FlashlightIsOn() then
					ply:SetFlashlightCharge(math.Clamp(ply:GetFlashlightCharge() - decay, 0, 1))
				else
					ply:SetFlashlightCharge(math.Clamp(ply:GetFlashlightCharge() + decay / MR_CONFIG.FlashlightRegenFactor, 0, 1))
				end
			end
		end
	end)

	function GM:PlayerSwitchFlashlight(ply, turningOn)
		if(ply:Team() == 2) then return false end

		if turningOn then
			if ply.FlashlightPenalty && ply.FlashlightPenalty > CurTime() then
				return false
			end
		end
		return true
	end

	local PlayerMeta = FindMetaTable("Player")
	function PlayerMeta:GetFlashlightCharge()
		return self.FlashlightCharge or 1
	end

	function PlayerMeta:SetFlashlightCharge(charge)
		self.FlashlightCharge = charge
		if charge <= 0 then
			self.FlashlightPenalty = CurTime() + 1.5
			if self:FlashlightIsOn() then
				self:Flashlight(false)
			end
		end
		net.Start("flashlight_charge")
		net.WriteFloat(self.FlashlightCharge)
		net.Send(self)
	end

	hook.Add("PlayerSpawn", "ResetFlashlight", function(ply)
		ply:SetFlashlightCharge(1)
	end)
end

if(CLIENT) then
	function GM:GetFlashlightCharge()
		return self.FlashlightCharge or 1
	end

	net.Receive("flashlight_charge", function (len)
		GAMEMODE.FlashlightCharge = net.ReadFloat()
	end)

	local alpha = 0
	local val = 0

	function GM:FlashlightHUD()
		val = Lerp(FrameTime()*5, val, GAMEMODE:GetFlashlightCharge())

		local w, h = ScreenScale(50), 12
		local x, y = ScrW()/2-w/2, ScrH()-ScrH()/8-h

		surface.SetDrawColor(40, 40, 40, 180)
		surface.DrawRect(x, y, w, h)

		surface.SetDrawColor(255-val*255, val*255, 0, 255)
		surface.DrawRect(x, y, w*val, h)
		surface.DrawOutlinedRect(x, y, w, h)
	end
end
