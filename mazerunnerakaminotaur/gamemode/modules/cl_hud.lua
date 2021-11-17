local offset = ScreenScale(8)

local elementTable = {
	["CHudAmmo"] = true,
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudSuitPower"] = true,
	["CHudCrosshair"] = true
}

hook.Add("HUDShouldDraw", "HideHUDElements", function(e)
	if(elementTable[e]) then return false end
end)

surface.CreateFont("HUD", {font = "Roboto Light", size = ScreenScale(10), weight = 100})
surface.CreateFont("HUDBar", {font = "Roboto Light", size = ScreenScale(7), weight = 100})
surface.CreateFont("HUDBarLabel", {font = "Roboto Light", size = ScreenScale(5), weight = 100})

local function drawBar(x, y, w, h, val, col, label, r)
	draw.RoundedBox(4, x, y, w, h, Color(0, 0, 0, 200))
	draw.RoundedBox(6, x+3, y+3, w-6, h-6, Color(255, 255, 255, 10))

	local barVal = math.Clamp(val, 0, 1)

	local dx = x
	if(r) then dx = x + w - w*barVal end

	draw.RoundedBox(6, dx+3, y+3, w*barVal-6, h-6, col)

	val = val * LocalPlayer():GetMaxHealth() || 100
	val = math.Clamp(val, 0, math.huge)
	val = math.Round(val)

	draw.SimpleText(val.."%", "HUDBar", x+(r&&w-5||5),y+h/2,Color(255, 255, 255, 255),r&&TEXT_ALIGN_RIGHT||TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	draw.SimpleText(label, "HUDBarLabel", x+(r&&w-5||5),y,Color(255, 255, 255, 255),r&&TEXT_ALIGN_RIGHT||TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM)
end

local hpAnim = 0
local barW, barH = ScreenScale(50), ScreenScale(10)
local function drawHealth()
	local hp = LocalPlayer():Health() || 0
	hpAnim = Lerp(FrameTime() * 5, hpAnim, hp)

	local x, y = (ScrW()/2-offset/2) - barW, ScrH()-offset-barH
	drawBar(x, y, barW, barH, hpAnim/100, Color(192, 57, 43), "Health", true)
end

local armorAnim = 0
local function drawArmor()
	local armor = LocalPlayer():Armor() || 0
	armorAnim = Lerp(FrameTime() * 5, armorAnim, armor)

	local x, y = ScrW()/2+offset/2, ScrH()-offset-barH
	drawBar(x, y, barW, barH, armorAnim/100, Color(41, 128, 185), "Armor")
end

local function drawAmmo()
	local wep = LocalPlayer():GetActiveWeapon()

	if(!IsValid(wep)) then return end
	if(!wep:Clip1() || wep:Clip1() == -1) then return end

	local mag = wep:Clip1()
	local reserve = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())

	local txt = mag.."/"..reserve

	draw.SimpleText(txt, "HUD", ScrW()-offset, ScrH()-offset, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
end

local function drawMeta()
	local name = LocalPlayer():Nick() || ""
	local teamName = team.GetName(LocalPlayer():Team()) || ""
	local lives = "Lives: "..(LocalPlayer():GetLives() || 0)

	local x, y = offset, ScrH() - offset
	surface.SetFont("HUD")

	//Lives
	if(LocalPlayer():Team() != 2) then
		local w, h = surface.GetTextSize(lives)
		draw.SimpleText(lives, "HUD", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		y = y - h
	end

	//Team Name
	local w, h = surface.GetTextSize(teamName)
	draw.SimpleText(teamName, "HUD", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	y = y - h

	//Player Name
	draw.SimpleText(name, "HUD", x, y, team.GetColor(LocalPlayer():Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	y = y - h
end

function GM:HUDPaint()
	self.BaseClass.HUDPaint(self)

	if(LocalPlayer():Team() == 2) then
		if(self:GetRoundState() == STATE_INPROGRESS) then
			self:SpectatorHUD()
			return
		end
	else
		self:FlashlightHUD()
	end

	drawMeta()
	drawHealth()
	drawArmor()
	drawAmmo()
end

surface.CreateFont("DisplayNameFont", {font = "Open Sans", size = 120})
surface.CreateFont("DisplayJobFont", {font = "Open Sans", size = 80})

local function drawPlayerInfo(ply)
	if(!IsValid(ply)) then return end
	if(ply == LocalPlayer()) then return end
	if(!ply:Alive()) then return end
	if(LocalPlayer():InVehicle()) then return end

	local distance = LocalPlayer():GetPos():Distance(ply:GetPos())

	local toCheck = 400

	if(distance > toCheck) then return end

	local offset = Vector(0, 0, 15)
	local ang = LocalPlayer():EyeAngles()

	local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
	local pos = ply:GetBonePosition(bone)
	pos = pos + offset + ang:Up()

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)

	local alpha = math.Clamp(math.Remap(distance, toCheck/4, toCheck, 255, 0), 0, 255)

	cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.05)
		draw.DrawText(ply:Nick(), "DisplayNameFont", 0, -100, ColorAlpha(team.GetColor(ply:Team()), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		draw.DrawText(team.GetName(ply:Team()), "DisplayJobFont", 0, 0, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		draw.DrawText(ply:GetLives(), "DisplayJobFont", 0, 100, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		draw.DrawText(ply:Health(), "DisplayJobFont", 0, 200, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	cam.End3D2D()
end

function GM:PreDrawTranslucentRenderables()
	if(LocalPlayer():Team() == 2 && self:GetRoundState() == STATE_INPROGRESS) then return end

	for k, v in pairs(player.GetAll()) do
		drawPlayerInfo(v)
	end
end

function GM:HUDDrawTargetID() end

local dist = math.pow(MR_CONFIG.HaloDistance, 2)
function GM:PreDrawHalos()
	if(LocalPlayer():Team() != 0) then return end

	for k, v in pairs(team.GetPlayers(1)) do
		local distance = LocalPlayer():GetPos():DistToSqr(v:GetPos())
		
		if(distance > dist) then
			local fade = math.Remap(distance, dist, dist*2, 0, 255)	
			halo.Add({v}, ColorAlpha(team.GetColor(v:Team()), fade), 1, 1, 2, true, true)
		end
	end
end