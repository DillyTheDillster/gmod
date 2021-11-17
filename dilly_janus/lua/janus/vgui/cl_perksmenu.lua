--[[
	Name: cl_perksmenu.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

local ScreenW = ScrW()
local ScreenH = ScrH()

Panel = {}

function Panel:Init()
	self:SetSize( 425, 650 )
	self:Center()
end

function Panel:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(Janus.Config.PerksMenuColor1[1], Janus.Config.PerksMenuColor1[2], Janus.Config.PerksMenuColor1[3], 230) )
	draw.RoundedBox( 0, 10, 40, w-20, h-50, Color(Janus.Config.PerksMenuColor2[1], Janus.Config.PerksMenuColor2[2], Janus.Config.PerksMenuColor2[3], 230))
	draw.DrawText('Janus - Perks Menu', 'levelingFontBig', 210, 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end
vgui.Register( 'JanusPerksPanel', Panel, 'Panel' )

-- ----------------------------------------------------------------

Panel = {}

function Panel:Init()
	self:SetSize( 390, 64 )
	self:Center()
end

function Panel:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(Janus.Config.PerksBoxColor1[1], Janus.Config.PerksBoxColor1[2], Janus.Config.PerksBoxColor1[3], 230) )

	draw.RoundedBox( 0, 5, 5, 54, 54, Color(Janus.Config.PerksBoxColor2[1], Janus.Config.PerksBoxColor2[2], Janus.Config.PerksBoxColor2[3], 235) )
	draw.RoundedBox( 0, 64, 5, w-69, 54, Color(Janus.Config.PerksBoxColor2[1], Janus.Config.PerksBoxColor2[2], Janus.Config.PerksBoxColor2[3], 235) )
end
vgui.Register( 'JanusPerkCard', Panel, 'Panel' )

-- ----------------------------------------------------------------

Panel = {}
function Panel:Init()
	self:SetSize( 24, 24 )
	self:Center()
end

function Panel:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(Janus.Config.PerksBoxColor1[1], Janus.Config.PerksBoxColor1[2], Janus.Config.PerksBoxColor1[3], 230) )
end
vgui.Register( 'JanusPerksClose', Panel, 'DButton' )

-- ----------------------------------------------------------------

local Panel = {}
function Panel:Init()
	gui.EnableScreenClicker(true)
	self.m_pnlCanvas = vgui.Create( 'JanusPerksPanel' )
	local MainPanel = self.m_pnlCanvas
	
	self.m_pnlBtn = vgui.Create( 'JanusPerksClose', self.m_pnlCanvas )
	self.m_pnlBtn:SetSize( 24, 24 )
	self.m_pnlBtn:SetPos( 395, 10 )
	self.m_pnlBtn:SetText( 'X' )
	self.m_pnlBtn:SetTextColor(Color(0,200,0,255))
	self.m_pnlBtn.DoClick = function()
		Janus.Net:RequestActivatePerks()
		gui.EnableScreenClicker(false)
		MainPanel:Hide()
	end

	self.m_pnlScrollPanel = vgui.Create( 'DScrollPanel', self.m_pnlCanvas )
	self.m_pnlScrollPanel:SetSize( 410, 580 )
	self.m_pnlScrollPanel:SetPos( 5, 50 )

	local PerksScrollBar = self.m_pnlScrollPanel:GetVBar()

	function PerksScrollBar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(Janus.Config.PerksBoxColor2[1], Janus.Config.PerksBoxColor2[2], Janus.Config.PerksBoxColor2[3], 235) )
	end

	function PerksScrollBar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(Janus.Config.PerksBoxColor1[1]-20, Janus.Config.PerksBoxColor1[2]-20, Janus.Config.PerksBoxColor1[3]-20, 230) )
	end

	function PerksScrollBar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(Janus.Config.PerksBoxColor1[1]-20, Janus.Config.PerksBoxColor1[2]-20, Janus.Config.PerksBoxColor1[3]-20, 230) )
	end

	function PerksScrollBar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(Janus.Config.PerksBoxColor1[1], Janus.Config.PerksBoxColor1[2], Janus.Config.PerksBoxColor1[3], 230) )
	end
	
	for k,v in pairs(Janus.m_tblPerks) do
		self.m_pnlPerkCard = vgui.Create( 'JanusPerkCard', self.m_pnlScrollPanel )
		self.m_pnlPerkCard:SetPos( 15, (k-1) * 74 )

		self.m_pnlPerkImage = vgui.Create( 'DImage', self.m_pnlPerkCard )
		self.m_pnlPerkImage:SetSize( 50, 50 )
		self.m_pnlPerkImage:SetPos( 7, 7 )

		if (v.UnlockLevel <= tonumber((GetGlobalInt(SQLStr(LocalPlayer():SteamID64()).."Level", 0) or 0))) then
			self.m_pnlPerkImage:SetImage( 'janus/perkunlocked.png' )
		else
			self.m_pnlPerkImage:SetImage( 'janus/perklocked.png' )
		end

		self.m_pnlPerkName = vgui.Create( 'DLabel', self.m_pnlPerkCard )
		self.m_pnlPerkName:SetSize( 286, 16 )
		self.m_pnlPerkName:SetPos( 70, 7 )
		self.m_pnlPerkName:SetText( v.Name )		
		self.m_pnlPerkName:SetFont( 'levelingFont' )
		self.m_pnlPerkName:SetTextColor( Color(240, 240, 255, 225) )
		self.m_pnlPerkName:SetContentAlignment( 4 )

		self.m_pnlPerkDescription = vgui.Create( 'DLabel', self.m_pnlPerkCard )
		self.m_pnlPerkDescription:SetSize( 286, 28 )
		self.m_pnlPerkDescription:SetPos( 70, 20 )
		self.m_pnlPerkDescription:SetText( v.Description )
		self.m_pnlPerkDescription:SetFont( 'levelingFontSmall' )
		self.m_pnlPerkDescription:SetTextColor( Color(240, 240, 255, 225) )
		self.m_pnlPerkDescription:SetContentAlignment( 4 )

		self.m_pnlPerkLevel = vgui.Create( 'DLabel', self.m_pnlPerkCard )
		self.m_pnlPerkLevel:SetSize( 286, 28 )
		self.m_pnlPerkLevel:SetPos( 70, 33 )
		self.m_pnlPerkLevel:SetText( 'Lv. ' .. v.UnlockLevel )
		self.m_pnlPerkLevel:SetFont( 'levelingFontSmall' )
		self.m_pnlPerkLevel:SetTextColor( Color(240, 240, 255, 225) )
		self.m_pnlPerkLevel:SetContentAlignment( 4 )
		
		if (v.UnlockLevel <= tonumber((GetGlobalInt(SQLStr(LocalPlayer():SteamID64()).."Level", 0) or 0))) then
			self.m_pnlPerkActive = vgui.Create( "DCheckBoxLabel", self.m_pnlPerkCard )
			self.m_pnlPerkActive:SetSize( 286, 28 )
			self.m_pnlPerkActive:SetPos( 350, 26 )
			self.m_pnlPerkActive:SetText( "" )
			
			local PerkActive = self.m_pnlPerkActive
			for _, perk in pairs(Janus.m_tblActivePerks) do
				if v.Name == perk.Name then
					PerkActive:SetChecked( true )
					break
				end
			end
			
			function self.m_pnlPerkActive:OnChange( bVal )
				local count = 0
				for k,v in pairs(Janus.m_tblRequestedPerks) do
					count = count + 1
				end
				if ( bVal and count < Janus.Config.MaxPerks) then
					table.insert(Janus.m_tblRequestedPerks, v)
					PerkActive:SetChecked( true )
				else
					for i, perk in pairs(Janus.m_tblRequestedPerks) do
						if v.Name == perk.Name then
							table.remove(Janus.m_tblRequestedPerks, i)
							break
						end
					end
					PerkActive:SetChecked( false )
				end
			end
		end
	end
end
vgui.Register( "JanusPerksMenu", Panel, "Panel" )