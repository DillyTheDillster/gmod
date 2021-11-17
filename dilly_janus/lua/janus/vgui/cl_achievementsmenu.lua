--[[
	Name: sv_utils.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

local ScreenW = ScrW()
local ScreenH = ScrH()

Panel = {}
function Panel:Init()
	self:SetSize( 750, 550 )
	self:Center()
end

function Panel:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(Janus.Config.PerksMenuColor1[1], Janus.Config.PerksMenuColor1[2], Janus.Config.PerksMenuColor1[3], 230) )
	draw.RoundedBox( 0, 10, 40, w-20, h-50, Color(Janus.Config.PerksMenuColor2[1], Janus.Config.PerksMenuColor2[2], Janus.Config.PerksMenuColor2[3], 230))
	draw.DrawText('Janus - Achievements Menu', 'levelingFontBig', 375, 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end
vgui.Register( 'JanusAchievementsPanel', Panel, 'Panel' )

-- ----------------------------------------------------------------

Panel = {}
function Panel:Init()
	self:SetSize(580, 74)
	self:Center()
end

function Panel:Paint( w, h )
	if self.Completed then
		draw.RoundedBox( 0, 0, 0, w, h, Color(Janus.Config.PerksBoxColor1[1]/(self.Num+1), Janus.Config.PerksBoxColor1[2]/(self.Num+1), Janus.Config.PerksBoxColor1[3]/(self.Num+1), 230) )
		draw.RoundedBox( 0, 5, 5, 570, 64, Color(Janus.Config.PerksBoxColor2[1], Janus.Config.PerksBoxColor2[2], Janus.Config.PerksBoxColor2[3], 235) )
	else
		draw.RoundedBox( 0, 0, 0, w, h, Color(Janus.Config.PerksBoxColor1[1]/(self.Num+1), Janus.Config.PerksBoxColor1[2]/(self.Num+1), Janus.Config.PerksBoxColor1[3]/(self.Num+1), 230) )
		draw.RoundedBox( 0, 5, 5, 570, 64, Color(Janus.Config.PerksBoxColor2[1]/2, Janus.Config.PerksBoxColor2[2]/2, Janus.Config.PerksBoxColor2[3]/2, 235) )
	end
end
vgui.Register( 'JanusAchievementsCard', Panel, 'Panel' )

-- ----------------------------------------------------------------

Panel = {}
function Panel:Init()
	self:SetSize( 24, 24 )
	self:Center()
end

function Panel:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(Janus.Config.PerksBoxColor1[1], Janus.Config.PerksBoxColor1[2], Janus.Config.PerksBoxColor1[3], 230) )
end
vgui.Register( 'JanusAchievementsClose', Panel, 'DButton' )

-- ----------------------------------------------------------------

Panel = {}
function Panel:Init()
	self:SetSize( self:GetParent():GetWide(), 30 )
	self:Center()
end

function Panel:Paint( w, h )
	if Janus.SelectedButton and type(Janus.SelectedButton) == "table" then
		if self:GetText() == Janus.SelectedButton.Cat then
			draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(Janus.Config.PerksBoxColor1[1], Janus.Config.PerksBoxColor1[2], Janus.Config.PerksBoxColor1[3], 230))
		else
			draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(Janus.Config.PerksBoxColor1[1]/(self.Num+2), Janus.Config.PerksBoxColor1[2]/(self.Num+2), Janus.Config.PerksBoxColor1[3]/(self.Num+2), 230))
		end
	else
		draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(Janus.Config.PerksBoxColor1[1]/(self.Num+2), Janus.Config.PerksBoxColor1[2]/(self.Num+2), Janus.Config.PerksBoxColor1[3]/(self.Num+2), 230))
	end
end
vgui.Register( 'JanusAchievementsCategoryButton', Panel, 'DButton' )

-- ----------------------------------------------------------------

Panel = {}
function Panel:Init()
	gui.EnableScreenClicker(true)
	Janus.SelectedButton = nil

	self.m_pnlCanvas = vgui.Create( 'JanusAchievementsPanel' )
	local MainPanel = self.m_pnlCanvas
	
	self.m_pnlButtons = vgui.Create("DPanel", self.m_pnlCanvas)
	self.m_pnlButtons:SetPos(20,50)
	self.m_pnlButtons:SetSize(110,self.m_pnlCanvas:GetTall()-70)
	self.m_pnlButtons.Paint = function()
		draw.RoundedBox(0,0,0,self.m_pnlButtons:GetWide(),self.m_pnlButtons:GetTall(),Color(Janus.Config.PerksMenuColor1[1], Janus.Config.PerksMenuColor1[2], Janus.Config.PerksMenuColor1[3], 230))
	end
	
	self.m_pnlBtn = vgui.Create( 'JanusAchievementsClose', self.m_pnlCanvas )
	self.m_pnlBtn:SetSize( 24, 24 )
	self.m_pnlBtn:SetPos( 716, 10 )
	self.m_pnlBtn:SetText( 'X' )
	self.m_pnlBtn:SetTextColor(Color(0,200,0,255))
	self.m_pnlBtn.DoClick = function()
		gui.EnableScreenClicker(false)
		MainPanel:Hide()
	end
	
	self.m_pnlBackground = vgui.Create("DScrollPanel", self.m_pnlCanvas)
	self.m_pnlBackground:SetSize(self.m_pnlCanvas:GetWide()-40, self.m_pnlCanvas:GetTall()-70)
	self.m_pnlBackground:SetPos(150, 50)
	
	function self:DisplayAchievements(category)
		local num = 0
		self.DisplayTable = {}
		
		for k, v in pairs(Janus.m_tblAchievements) do
			if category then
				if not isnumber(category) then
					if v.Cat != category then
						continue 
					end
				else
					if not table.HasValue(Janus.m_tblCompletedAchievements, k) then
						continue
					end	
				end
			end
			
			local current = tonumber(Janus.m_tblAchievementsProgress[k]) or 0
			local outof = v.AmountRequired
			
			self.m_pnlAchievementCard = vgui.Create("JanusAchievementsCard", self.m_pnlBackground)
			self.m_pnlAchievementCard:SetPos(0, 74*num)
			self.m_pnlAchievementCard.Num = num
			if table.HasValue(Janus.m_tblCompletedAchievements, k) then
				self.m_pnlAchievementCard.Completed = true
			else
				self.m_pnlAchievementCard.Completed = false
			end
			table.insert(self.DisplayTable, self.m_pnlAchievementCard)
			
			self.m_pnlAchievementIcon = vgui.Create("DImage", self.m_pnlAchievementCard)
			self.m_pnlAchievementIcon:SetPos(5,5)
			self.m_pnlAchievementIcon:SetSize(64, 64)
			self.m_pnlAchievementIcon:SetImage(v.Icon or Janus.Config.DefaultIcon)
			if not table.HasValue(Janus.m_tblCompletedAchievements, k) then
				self.m_pnlAchievementIcon:SetImageColor(Color( 255, 255, 255, 255 ))
			end	
				
			self.m_pnlAchievementTitle = vgui.Create("DLabel", self.m_pnlAchievementCard)
			self.m_pnlAchievementTitle:SetText(v.PrintName)
			self.m_pnlAchievementTitle:SetTextColor( Color(240, 240, 255, 225) )
			self.m_pnlAchievementTitle:SetFont("Roboto25")
			self.m_pnlAchievementTitle:SetPos(74, 5)
			self.m_pnlAchievementTitle:SizeToContents()
				
			self.m_pnlAchievementDescriptionIcon = vgui.Create("DImage", self.m_pnlAchievementCard)
			self.m_pnlAchievementDescriptionIcon:SetImage("materials/icon16/information.png")
			self.m_pnlAchievementDescriptionIcon:SetSize(16, 16)
			self.m_pnlAchievementDescriptionIcon:SetPos(74, 30)
			
			self.m_pnlAchievementDesc = vgui.Create("DLabel", self.m_pnlAchievementCard)
			self.m_pnlAchievementDesc:SetText(v.Description)
			self.m_pnlAchievementDesc:SetTextColor( Color(240, 240, 255, 225) )
			self.m_pnlAchievementDesc:SetPos(92, 30)
			self.m_pnlAchievementDesc:SizeToContents()
			
			self.m_pnlAchievementAwardIcon = vgui.Create("DImage", self.m_pnlAchievementCard)
			self.m_pnlAchievementAwardIcon:SetImage("materials/icon16/award_star_gold_1.png")
			self.m_pnlAchievementAwardIcon:SetSize(16, 16)
			self.m_pnlAchievementAwardIcon:SetPos(74, 50)
			
			self.m_pnlAchievementAward = vgui.Create("DLabel", self.m_pnlAchievementCard)
			if not table.HasValue(Janus.m_tblCompletedAchievements, k) then
				if string.len(v.RewardName) != 0 then
					self.m_pnlAchievementAward:SetText(v.RewardName)
				else
					self.m_pnlAchievementAward:SetText("No reward!")
				end
			else
				self.m_pnlAchievementAward:SetText("Completed!")
			end
			self.m_pnlAchievementAward:SetTextColor( Color(240, 240, 255, 225) )
			self.m_pnlAchievementAward:SetPos(92, 50)
			self.m_pnlAchievementAward:SizeToContents()
			
			self.m_pnlAchievementProgress = vgui.Create("DButton", self.m_pnlAchievementCard)
			self.m_pnlAchievementProgress:SetSize(150, self.m_pnlAchievementCard:GetTall()-20)
			self.m_pnlAchievementProgress:SetPos(self.m_pnlAchievementCard:GetWide()-160,10)
			self.m_pnlAchievementProgress:SetColor(Color(240, 240, 255, 225))
			if not table.HasValue(Janus.m_tblCompletedAchievements, k) then
				self.m_pnlAchievementProgress:SetText(Janus.Utils:GetNiceNum(current) .. "/" .. Janus.Utils:GetNiceNum(outof))
			else
				self.m_pnlAchievementProgress:SetText(Janus.Utils:GetNiceNum(outof) .. "/" .. Janus.Utils:GetNiceNum(outof))
			end
			self.m_pnlAchievementProgress:SetFont("Bebas40")
			self.m_pnlAchievementProgress.Num = math.fmod(num, 2)
			if table.HasValue(Janus.m_tblCompletedAchievements, k) then
				self.m_pnlAchievementProgress.Paint = function()
					draw.RoundedBox(0,0,0,self.m_pnlAchievementProgress:GetWide(),self.m_pnlAchievementProgress:GetTall(),Color(Janus.Config.PerksBoxColor1[1]/(self.m_pnlAchievementProgress.Num+1), Janus.Config.PerksBoxColor1[2]/(self.m_pnlAchievementProgress.Num+1), Janus.Config.PerksBoxColor1[3]/(self.m_pnlAchievementProgress.Num+1), 230))
				end
			else
				self.m_pnlAchievementProgress.Paint = function()
					draw.RoundedBox(0,0,0,self.m_pnlAchievementProgress:GetWide(),self.m_pnlAchievementProgress:GetTall(),Color(Janus.Config.PerksBoxColor1[1]/(self.m_pnlAchievementProgress.Num+2), Janus.Config.PerksBoxColor1[2]/(self.m_pnlAchievementProgress.Num+2), Janus.Config.PerksBoxColor1[3]/(self.m_pnlAchievementProgress.Num+2), 230))
				end
			end
			num = num + 1
		end
	end
		
	local num_2 = 0
	local categories_made = {}
	for k, v in pairs(Janus.m_tblAchievements) do
		if not table.HasValue(categories_made, v.Cat) then
			self.m_pnlButtonsTable = vgui.Create("JanusAchievementsCategoryButton", self.m_pnlButtons)
			self.m_pnlButtonsTable:SetPos(0,num_2*30)
			self.m_pnlButtonsTable:SetText(v.Cat) 
			self.m_pnlButtonsTable:SetColor( Color(240, 240, 255, 225) )
			self.m_pnlButtonsTable.DoClick = function()
				for x, y in pairs(self.DisplayTable) do
					y:Remove()
				end
				self:DisplayAchievements(v.Cat)
				Janus.SelectedButton = v
			end
			self.m_pnlButtonsTable.Num = math.fmod(num_2, 2)
			table.insert(categories_made, v.Cat)
			num_2 = num_2 + 1
		end
	end
	
	self.m_pnlButtonsCompleted = vgui.Create("DButton", self.m_pnlButtons)
	self.m_pnlButtonsCompleted:SetSize(self.m_pnlButtons:GetWide(),30)
	self.m_pnlButtonsCompleted:SetPos(0,self.m_pnlButtons:GetTall()-60)
	self.m_pnlButtonsCompleted:SetText("Completed")
	self.m_pnlButtonsCompleted:SetColor(Color(240, 240, 255, 225))
	self.m_pnlButtonsCompleted.Paint = function()
		if Janus.SelectedButton and Janus.SelectedButton == 1 then
			draw.RoundedBox(0,0,0,self.m_pnlButtons:GetWide(),30,Color(Janus.Config.PerksBoxColor1[1], Janus.Config.PerksBoxColor1[2], Janus.Config.PerksBoxColor1[3], 230))
		else
			draw.RoundedBox(0,0,0,self.m_pnlButtons:GetWide(),30,Color(Janus.Config.PerksBoxColor1[1]/2, Janus.Config.PerksBoxColor1[2]/2, Janus.Config.PerksBoxColor1[3]/2, 230))
		end
	end
	self.m_pnlButtonsCompleted.DoClick = function()
		for x, y in pairs(self.DisplayTable) do
			y:Remove()
		end
		self:DisplayAchievements(1)
		Janus.SelectedButton = 1
	end
	
	self.m_pnlButtonsAll = vgui.Create("DButton", self.m_pnlButtons)
	self.m_pnlButtonsAll:SetSize(self.m_pnlButtons:GetWide(),30)
	self.m_pnlButtonsAll:SetPos(0,self.m_pnlButtons:GetTall()-30)
	self.m_pnlButtonsAll:SetText("All Achievements")
	self.m_pnlButtonsAll:SetColor(Color(240, 240, 255, 225))
	self.m_pnlButtonsAll.Paint = function()
		if Janus.SelectedButton then
			draw.RoundedBox(0,0,0,self.m_pnlButtons:GetWide(),30,Color(Janus.Config.PerksBoxColor1[1]/3, Janus.Config.PerksBoxColor1[2]/3, Janus.Config.PerksBoxColor1[3]/3, 230))
		else
			draw.RoundedBox(0,0,0,self.m_pnlButtons:GetWide(),30,Color(Janus.Config.PerksBoxColor1[1], Janus.Config.PerksBoxColor1[2], Janus.Config.PerksBoxColor1[3], 230))
		end
	end
	self.m_pnlButtonsAll.DoClick = function()
		self:DisplayAchievements(false)
		Janus.SelectedButton = nil
	end
	
	self:DisplayAchievements(false)
end
vgui.Register( 'JanusAchievementsMenu', Panel, 'Panel' )