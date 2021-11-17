local frame

local PANEL = {}

local w, h = ScrW()/3, ScrH()/1.5

local bgCol = Color(255, 255, 255, 100)

surface.CreateFont("SBTitle", {font = "Open Sans", size = ScreenScale(10)})
surface.CreateFont("SBPlayer", {font = "Roboto", size = ScreenScale(8)})
surface.CreateFont("SBHint", {font = "Open Sans", size = ScreenScale(7)})

function PANEL:Init()
	self:SetSize(w, h)
	self:Center()

	self:SetAlpha(0)
	self:AlphaTo(255, .2)

	self.RCHint = vgui.Create("DLabel", self)
	self.RCHint:Dock(TOP)
	self.RCHint:SetFont("SBHint")
	self.RCHint:SetText("Right Click to Access Cursor")
	self.RCHint:SetAlpha(0)
	self.RCHint:AlphaTo(255, 2)

	self.List = vgui.Create("DPanelList", self)
	self.List:Dock(FILL)
	self.List:SetSpacing(3)
	self.List:EnableVerticalScrollbar()

	local barPaintFn = function(s, w, h)
		draw.RoundedBox(0, w/3, 0, w/1.5, h, bgCol)
	end

	local vbar = self.List.VBar
	vbar.Paint = nil
	vbar.btnUp.Paint = barPaintFn
	vbar.btnDown.Paint = barPaintFn
	vbar.btnGrip.Paint = barPaintFn

	for _, v in pairs({0, 1}) do
		if(#team.GetPlayers(v) < 1) then continue end

		local title = vgui.Create("DPanel")
		title:SetTall(ScreenScale(10))
		title.Paint = function(s, w, h)
			draw.RoundedBox(0, 0, 0, w, h, team.GetColor(v))
			draw.SimpleText(team.GetName(v), "SBTitle", w/2, h/2, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		self.List:AddItem(title)

		for _, ply in pairs(team.GetPlayers(v)) do
			local pnl = vgui.Create("DPanel")
			pnl:SetTall(ScreenScale(8))

			pnl.Paint = function(s, w, h)
				draw.RoundedBox(0, 0, 0, w, h, bgCol)
				draw.SimpleText(ply:Nick(), "SBPlayer", w/2, h/2, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			self.List:AddItem(pnl)
		end
	end
end

function PANEL:DisableRCLabel()
	self.RCHint:SetVisible(false)
end

vgui.Register("Scoreboard", PANEL, "Panel")

function GM:ScoreboardShow()
	self:ScoreboardHide()
	frame = vgui.Create("Scoreboard")
end

function GM:ScoreboardHide()
    if(IsValid(frame)) then frame:Remove() end
end

hook.Add("PlayerBindPress", "RightclickOpenScoreboard", function(ply, bind, pressed)
	if(bind == "+attack2" && IsValid(frame) && frame:IsVisible()) then
		frame:MakePopup()
		frame:DisableRCLabel()
		return true
	end
end)
