if(CLIENT) then
	local spectating = 1
	local cd = CurTime()

	function GM:GetSpectatablePlys()
		local m, r = team.GetPlayers(0), team.GetPlayers(1)
		return table.Add(m, r)
	end

	function GM:KeyPress(ply, key)
		if(ply:Team() != 2 || self:GetRoundState() != STATE_INPROGRESS) then return end

		if(CurTime() > cd) then cd = CurTime() + 0.2 else return end

		if(key == IN_ATTACK) then
			if(self:GetSpectatablePlys()[spectating + 1]) then
				spectating = spectating + 1
			else spectating = 1 end
		end
	end

	function GM:SpectatorHUD()
		if(LocalPlayer():Team() != 2 || self:GetRoundState() != STATE_INPROGRESS) then return end

		local ply = self:GetSpectatablePlys()[spectating]
		if(!ply) then return end
		
		draw.SimpleText(ply:Nick(), "DermaLarge", ScrW()/2, ScrH()/1.7, team.GetColor(ply:Team()), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(team.GetName(ply:Team()), "Trebuchet24", ScrW()/2, ScrH()/1.7 + 20, team.GetColor(ply:Team()), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Health: "..ply:Health().."%", "Trebuchet18", ScrW()/2, ScrH()/1.7 + 40, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Armor: "..ply:Armor().."%", "Trebuchet18", ScrW()/2, ScrH()/1.7 + 54, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function GM:CalcView(lp, origin, angles, fov)
		if(LocalPlayer():Team() != 2 || self:GetRoundState() != STATE_INPROGRESS) then return end
		local ply = self:GetSpectatablePlys()[spectating]

		if(!ply) then return end

		local tr = util.TraceLine({
			start = ply:EyePos(),
			endpos = ply:EyePos() - angles:Forward() * 80,
			filter = ply
		})

		local view = {}
		view.origin = tr.HitPos
		view.angles = angles
		view.fov = fov

		return view
	end

	function GM:PrePlayerDraw(ply)
		return LocalPlayer():Team() != 2 && ply:Team() == 2
	end
end

function GM:StartCommand(ply, ucmd)
	if(ply:Team() == 2 && self:GetRoundState() == STATE_INPROGRESS) then
		ucmd:ClearMovement()
		ucmd:RemoveKey(IN_JUMP)
		ucmd:RemoveKey(IN_DUCK)
	end
end

function GM:ShouldCollide(ent1, ent2)
	if(IsValid(ent1) and IsValid(ent2) and ent1:IsPlayer() and ent2:IsPlayer()) then
		if(ent1:Team() == ent2:Team()) then return false end
		if(ent1:Team() == 2 || ent2:Team() == 2) then return false end 
	end
	
	return true
end