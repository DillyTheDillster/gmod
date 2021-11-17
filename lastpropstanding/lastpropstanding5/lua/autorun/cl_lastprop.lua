if not CLIENT then return end

local bgClr = Color(30, 30, 30)
local getgunClr = Color(100, 200, 0)
local keephidingClr = Color(200, 70, 0)

function LastProp:OpenMenu()
	surface.CreateFont("LastProp_BtnFont", {
		name = "Roboto",
		size = 24,
		weight = 400,
	})

	surface.CreateFont("LastProp_DescFont", {
		name = "Roboto",
		size = 18,
		weight = 400,
	})

	local desctext = [[If you choose to get a gun, you may:NEWLINE:kill the hunters, or you can choose:NEWLINE:to remain hiding!]]
	local frame = vgui.Create("DFrame")
	frame:SetSize(270, 150)
	frame:SetTitle("")
	frame:Center()
	frame:MakePopup()
	frame.Paint = function(self, w, h)
		surface.SetDrawColor(bgClr)
		surface.DrawRect(0, 0, w, h)

		surface.SetTextColor(color_white)
		surface.SetFont("LastProp_DescFont")

		local y = 10
		for _, text in pairs(string.Explode(":NEWLINE:", desctext)) do
			local textx, texty = surface.GetTextSize(text)
			surface.SetTextPos(10, y)
			surface.DrawText(text)
			y = y + texty
		end
	end
	frame:ShowCloseButton(false)

	local getgun = vgui.Create("DButton", frame)
	getgun:SetSize(120, 50)
	getgun:SetPos(10, 90)
	getgun:SetText("")
	getgun.Paint = function(self, w, h)
		surface.SetDrawColor(getgunClr)
		surface.DrawRect(0, 0, w, h)

		local text = "Get Gun"
		surface.SetFont("LastProp_BtnFont")
		local textx, texty = surface.GetTextSize(text)
		surface.SetTextPos(w / 2 - textx / 2, h / 2 - texty / 2)
		surface.SetTextColor(color_white)
		surface.DrawText(text)
	end
	getgun.DoClick = function()
		frame:Remove()
		net.Start("LastProp_Action")
			net.WriteBool(true)
		net.SendToServer()
	end

	local keephiding = vgui.Create("DButton", frame)
	keephiding:SetSize(120, 50)
	keephiding:SetPos(10 + 120 + 10, 90)
	keephiding:SetText("")
	keephiding.Paint = function(self, w, h)
		surface.SetDrawColor(keephidingClr)
		surface.DrawRect(0, 0, w, h)

		local text = "Keep Hiding"
		surface.SetFont("LastProp_BtnFont")
		local textx, texty = surface.GetTextSize(text)
		surface.SetTextPos(w / 2 - textx / 2, h / 2 - texty / 2)
		surface.SetTextColor(color_white)
		surface.DrawText(text)
	end
	keephiding.DoClick = function()
		frame:Remove()
		net.Start("LastProp_Action")
			net.WriteBool(false)
		net.SendToServer()
	end
end

--[[function CalcView(pl, origin, angles, fov)
	local view = {}

	view.origin = origin
	view.angles	= angles
	view.fov = fov

	if pl:GetNWBool("DisableThirdPerson", false) and LastProp.Config.ChangeToFirstPerson and pl:Team() == TEAM_PROPS and pl == LocalPlayer() then
		return view
	end

	if blind then
		view.origin = Vector(20000, 0, 0)
		view.angles = Angle(0, 0, 0)
		view.fov = fov

		return view
	end

	if pl:Team() == TEAM_PROPS && pl:Alive() then
		hullz = pl.propHeight
		if GetConVar("ph_prop_camera_collisions"):GetBool() then
			local trace = {}
			local TraceOffset = math.Clamp(hullz, 0, 4)

			if hullz <= 32 then
				hullz = 36
			end

			trace.start = origin + Vector(0, 0, hullz - 60)
			trace.endpos = origin + Vector(0, 0, hullz - 60) + (angles:Forward() * -80)
			trace.filter = client_prop_model && ents.FindByClass("ph_prop")
			trace.mins = Vector(-TraceOffset, -TraceOffset, -TraceOffset)
			trace.maxs = Vector(TraceOffset, TraceOffset, TraceOffset)
			local tr = util.TraceLine(trace)

			view.origin = tr.HitPos
		else
			view.origin = origin + Vector(0, 0, hullz - 60) + (angles:Forward() * -80)
		end
	else
		local wep = pl:GetActiveWeapon()
		if wep && wep != NULL then
			local func = wep.GetViewModelPosition
			if func then
				view.vm_origin, view.vm_angles = func(wep, origin*1, angles*1) -- Note: *1 to copy the object so the child function can't edit it.
			end

			local func = wep.CalcView
			if func then
				view.origin, view.angles, view.fov = func(wep, pl, origin*1, angles*1, fov) -- Note: *1 to copy the object so the child function can't edit it.
			end
		end
	end

	return view
end]]

function CalcView( ply, pos, angles, fov )
	if ply.propHeight != nil && not ply.wantThirdPerson then
		local view = {}

		view.origin = Vector(pos.x,pos.y,pos.z)
		if not ply.LastProp_Mode then view.origin = Vector(pos.x,pos.y,pos.z + math.Clamp(ply.propHeight,0,64)) end
		view.angles	= angles
		view.fov = fov
		local wep = ply:GetActiveWeapon()
		function wep:GetViewModelPosition( pos, ang )
			pos = Vector(pos.x,pos.y,pos.z)
			--ang:RotateAroundAxis( ang:Forward(), 90 )
			return pos--, ang
		end
		ply.viewOrigin = view.origin
		if ply:Team() == TEAM_PROPS then return view end
		--[[if not ply.wantThirdPerson and ply.LastProp_Mode and ply:Team() == TEAM_PROPS and ply == LocalPlayer() then
			if ply:GetViewOffset() != Vector(0,0,64) then
				ply:SetViewOffset(Vector(0,0,64))
			end
			local wep = ply:GetActiveWeapon()
			    function wep:GetViewModelPosition( pos, ang )
			    	pos = Vector(pos.x,pos.y,pos.z + 64)
					ang:RotateAroundAxis( ang:Forward(), 90 )
					return pos, ang
				end
			if wep && wep != NULL then
				local func = wep.GetViewModelPosition
				if func then
					view.vm_origin, view.vm_angles = func(wep, origin*1, angles*1) -- Note: *1 to copy the object so the child function can't edit it.
				end

				local func = wep.CalcView
				if func then
					view.origin, view.angles, view.fov = func(wep, pl, origin*1, angles*1, fov) -- Note: *1 to copy the object so the child function can't edit it.
				end
			end
			view.origin = Vector(view.origin.x,view.origin.y,view.origin.z + 64)
			print(ply.propHeight)
			ply.viewOrigin = view.origin
			return view
		end]]
	end
	-- disable custom viewing if we're dead, this fixes spec bug
	if( !ply:Alive() ) then return true end


	-- this needs to be here otherwise some people get errors for some unknown reason
	if( ply.wantThirdPerson == nil ) then return end

	local view = {}
	view.angles = angles
	view.fov = fov
	view.drawviewer = ply.wantThirdPerson

	-- blinding the player
	if ( ply:Team() == TEAM_HUNTERS ) && ( round.state == 2 ) && ( ( CurTime() - round.startTime ) < OBJHUNT_HIDE_TIME ) then
		view.origin = Vector( 0, 0, 34343 )
		return view

	elseif( ply.wantThirdPerson ) then
		local trace = {}
		local addToPlayer
		if( ply:Team() == TEAM_PROPS ) then
			addToPlayer = Vector(0, 0, ply.propHeight)
		else
			addToPlayer = Vector(0, 0, 64 )
		end
		local viewDist = THIRDPERSON_DISTANCE

		trace.start = ply:GetPos() + addToPlayer
		trace.endpos = trace.start + view.angles:Forward() * -viewDist
		trace.mask = MASK_SOLID_BRUSHONLY
		tr = util.TraceLine(trace)

		-- efficient check when not hitting walls
		if(tr.Fraction < 1) then
			viewDist = viewDist * tr.Fraction
		end

		view.origin = trace.start + view.angles:Forward() * -viewDist
		if ply.propHeight != nil && ply.propHeight > 64 && ply:Team() == 1 then
			view.origin = Vector(view.origin.x, view.origin.y, math.Clamp((view.origin.z - (ply.propHeight - 64)), ply:GetPos().z, ply:GetPos().z + 70)  )
		end
		ply.viewOrigin = view.origin
		return view
	elseif( ply:Team() == TEAM_PROPS ) then
		local height = math.max( ply.propHeight || 64, VIEW_MIN_Z )
		view.origin = ply:GetPos() + Vector(0,0, height)
		if ply.propHeight != nil && ply.propHeight > 64 then
			view.origin = Vector(view.origin.x, view.origin.y, math.Clamp((view.origin.z - (ply.propHeight - 64)), ply:GetPos().z, ply:GetPos().z + 70)  )
		end
		ply.viewOrigin = view.origin
		return view
	end
end

hook.Add("CalcView", "LastProp_CalcView", CalcView)

net.Receive("LastProp_OpenMenu", function()
	LastProp:OpenMenu()
end)

LPSshowText = false

net.Receive("LPSText", function()
	LPSshowText = true
	timer.Simple(8, function()
		LPSshowText = false
	end)
end)

hook.Add("HUDPaint", "LPSHUDPaint", function()
	if not LPSshowText then return end
	draw.DrawText("Last Prop Standing", "PowerRoundsNameFont", PowerRounds.InfoPos.W, PowerRounds.InfoPos.H, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	draw.DrawText("The last Prop alive picked up a weapon! Kill him before he kills you!", "PowerRoundsDescriptionFont", PowerRounds.InfoPos.W, PowerRounds.InfoPos.H + 50, Color(255, 255, 255), TEXT_ALIGN_CENTER)
end)