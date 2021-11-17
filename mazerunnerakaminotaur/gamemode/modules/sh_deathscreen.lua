if(SERVER) then
	util.AddNetworkString("StartDeathscreen")
	util.AddNetworkString("StopDeathscreen")

	function GM:DeathscreenDeath(ply, inf, attacker)
		ply.ApplyDeathscreen = true

		net.Start("StartDeathscreen")
			if(attacker) then net.WriteEntity(attacker) end
		net.Send(ply)
	end

	function GM:DeathscreenSpawn(ply)
		if(ply.ApplyDeathscreen) then
			net.Start("StopDeathscreen")
			net.Send(ply)

			ply.ApplyDeathscreen = false
		end
	end
else
	local screen = nil

	surface.CreateFont("DeathscreenTitle", {font = "Open Sans", size = ScreenScale(30)})
	surface.CreateFont("DeathscreenSubtitle", {font = "Open Sans", size = ScreenScale(20)})

	net.Receive("StartDeathscreen", function()
		local attacker = net.ReadEntity()
		local aliveAt = CurTime() + MR_CONFIG.RespawnTime

		screen = vgui.Create("DPanel")
		screen:SetSize(ScrW(), ScrH())
		screen:SetPos(0, 0)
		screen.Paint = function(s, w, h)
			surface.SetDrawColor(0, 0, 0, 220)
			surface.DrawRect(0, 0, w, h)
		
			local respawnIn = aliveAt - CurTime()
			respawnIn = math.Round(respawnIn, 1)

			draw.SimpleText("You are dead!", "DeathscreenTitle", ScrW()/2, ScrH()/3, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("You are dead!", "DeathscreenTitle", ScrW()/2, ScrH()/3, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Lives Remaining: "..LocalPlayer():GetLives(), "DeathscreenSubtitle", ScrW()/2, ScrH()/1.5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("You will respawn in: "..respawnIn.."s", "DeathscreenSubtitle", ScrW()/2, ScrH()/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end)

	net.Receive("StopDeathscreen", function()
		if(IsValid(screen)) then screen:Remove() end
	end)
end