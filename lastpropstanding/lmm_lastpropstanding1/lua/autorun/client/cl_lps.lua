surface.CreateFont( "LMMGUITitleFont", {
  font = "Arial",
  size = 20,
  weight = 5000,
  blursize = 0,
  scanlines = 0,
  antialias = true,
})

surface.CreateFont( "LMMGUIFontClose", {
  font = "Arial",
  size = 15,
  weight = 5000,
  blursize = 0,
  scanlines = 0,
  antialias = true,
})

function LMMGUIDarkThemeMainLPS(DFrame, title)
  DFrame.Paint = function( self, w, h )
    draw.RoundedBox(2, 0, 0, DFrame:GetWide(), DFrame:GetTall(), Color(35, 35, 35, 250))
    draw.RoundedBox(2, 0, 0, DFrame:GetWide(), 30, Color(40, 40, 40, 255))
    draw.SimpleText( title, "LMMGUITitleFont", DFrame:GetWide() / 2, 15, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end

  local frameclose = vgui.Create("DButton", DFrame)
  frameclose:SetSize(20, 20)
  frameclose:SetPos(DFrame:GetWide() - frameclose:GetWide() - 5, 5)
  frameclose:SetText("X");
  frameclose:SetTextColor(Color(0,0,0,255))
  frameclose:SetFont("LMMGUIFontClose")
  frameclose.hover = false
  frameclose.DoClick = function()
    DFrame:Close()
  end
  frameclose.OnCursorEntered = function(self)
    self.hover = true
  end
  frameclose.OnCursorExited = function(self)
    self.hover = false
  end
  function frameclose:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, (self.hover and Color(255,15,15,250)) or Color(255,255,255,255)) -- Paints on hover
    frameclose:SetTextColor(self.hover and Color(255,255,255,250) or Color(0,0,0,255))
  end
end

function LMMGUIDarkThemeBtnLPS(self, thecolor)
  self.OnCursorEntered = function(self)
    self.hover = true
  end
  self.OnCursorExited = function(self)
    self.hover = false
  end
  self.Paint = function( self, w, h )
    draw.RoundedBox(0, 0, 0, w, h, (self.hover and thecolor or Color(255,255,255,255))) -- Paints on hover
    self:SetTextColor(self.hover and Color(255,255,255,255) or Color(0,0,0,250))
  end
end

net.Receive("LastPropStandingAskIfWantsWeapon",function()
  local DFrame = vgui.Create( "DFrame" )
  DFrame:SetSize( 500, 95 )
  DFrame:SetDraggable( true )
  DFrame:MakePopup()
  DFrame:Center()
  DFrame:SetTitle( "" )
  DFrame:ShowCloseButton( false )
  LMMGUIDarkThemeMainLPS(DFrame, "Last Prop Standing!")

  local YesBtn = vgui.Create( "DButton", DFrame )
  YesBtn:SetPos( 10, 40 )
  YesBtn:SetSize( DFrame:GetWide() - 20,20 )
  YesBtn:SetText( "Yes, I want a weapon to kill these hunters!" )
  LMMGUIDarkThemeBtnLPS(YesBtn, Color(0,160,0,250))
  YesBtn.DoClick = function()
    net.Start("LastPropStandingAskIfWantsWeaponYes")
    net.SendToServer()
    DFrame:Close()
  end

  local NoBtn = vgui.Create( "DButton", DFrame )
  NoBtn:SetPos( 10, 65 )
  NoBtn:SetSize( DFrame:GetWide() - 20,20 )
  NoBtn:SetText( "No, I want to hide and make these hunters find me!" )
  LMMGUIDarkThemeBtnLPS(NoBtn, Color(160,0,0,250))
  NoBtn.DoClick = function()
    net.Start("LastPropStandingAskIfWantsWeaponNo")
    net.SendToServer()
    DFrame:Close()
  end
end)

net.Receive("LastPropStandingStartArrows",function()
  if LocalPlayer():Alive() then
    LocalPlayer().LPSArrowsShow = true
  end
end)

net.Receive("LastPropStandingEndArrows",function()
  LocalPlayer().LPSArrowsShow = false
  LocalPlayer().LPSIsGoldVIP = false
end)

net.Receive("LastPropStandingGiveGoldVIP",function()
  LocalPlayer().LPSArrowsShow = true
  LocalPlayer().LPSIsGoldVIP = true
end)

hook.Add("HUDPaint","LPSHUDPaint",function()
  local me = LocalPlayer()

  if me.LPSArrowsShow then
    for k,v in pairs(player.GetAll()) do
      if v != me and v:Alive() and v:Team() != me:Team() then
        if v.LPSIsGoldVIP then
          col = Color(255, 222, 0, 255)
        else
          col = team.GetColor(v:Team())
        end
        local brge = (SeekerBlinded) and 1850 or 1225
        local alp = 255

        local arrowpos = (v:LookupBone("ValveBiped.Bip01_Head1") != nil) and v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_Head1"))+Vector(0,0,12+math.Round(me:GetPos():Distance(v:GetPos())/50)) or v:GetPos()+Vector(0,0,78+math.Round(me:GetPos():Distance(v:GetPos())/50))
        local arrowscrpos = arrowpos:ToScreen()
        draw.SimpleTextOutlined("v","DermaLarge",tonumber(arrowscrpos.x),tonumber(arrowscrpos.y),Color(col.r,col.g,col.b,alp),1,1,2,Color(0,0,0,alp/3))
      end
    end
  end
end)
