local plymeta = FindMetaTable("Player")
thereisalastprop = false
therecanbeapropstanding = false

util.AddNetworkString("LastPropStandingAskIfWantsWeapon")
util.AddNetworkString("LastPropStandingAskIfWantsWeaponYes")
util.AddNetworkString("LastPropStandingAskIfWantsWeaponNo")
util.AddNetworkString("LastPropStandingStartArrows")
util.AddNetworkString("LastPropStandingEndArrows")
util.AddNetworkString("LastPropStandingGiveGoldVIP")

function plymeta:LastPropStandingIsLPS()
  if !thereisalastprop and therecanbeapropstanding then
    thereisalastprop = true
    self:ChatPrint("You are the last prop standing!")
    for k, v in pairs(player.GetAll()) do
      v:ChatPrint(self:Nick().." is the last prop standing!")
    end
    net.Start("LastPropStandingAskIfWantsWeapon")
    net.Send(self)
  end
end

hook.Add("PlayerDeath","LastPropStandingDeathHook",function(victim,inflictor,attacker)
  if thereisalastprop and victim:Team() == 1 then
    for k, v in pairs(player.GetAll()) do
      v:ChatPrint("The last prop standing has died!")
    end
    thereisalastprop = false
    net.Start("LastPropStandingEndArrows")
    net.Broadcast()
    if LPSConfig.TrailEnabled then
      victim.LPSTrail:Remove()
    end
    if victim != attacker then
      attacker:PS2_AddStandardPoints(LPSConfig.PointsToGiveLPSKiller, "You the last prop stadning!", false)
    end
    net.Start("LastPropStandingEndArrows")
    net.Broadcast()
  elseif thereisalastprop and victim:Team() == 2 and victim != attacker then
    local haalive = false
    for k, v in pairs(player.GetAll()) do
      if v:Alive() and v:Team() == 2 then haalive = true end
      v:ChatPrint("The last prop standing has killed a hunter!")
    end
    attacker:PS2_AddStandardPoints(LPSConfig.PointsToGiveToLPSAfterKill, "You killed a hunter!", false)
    if !haalive then
      thereisalastprop = false
      net.Start("LastPropStandingEndArrows")
      net.Broadcast()
    end
  end
  net.Start("LastPropStandingEndArrows")
  net.Broadcast()
end)

hook.Add("PlayerCanPickupWeapon","LPSPlayerCanPickupWeapon",function(ply, wep)
  if thereisalastprop and ply:Team() == 1 and table.HasValue(LPSConfig.WeaponToGiveLPS,wep:GetClass()) then
    return true
  end
end)

hook.Add("PlayerShouldTakeDamage","LPSPlayerShouldTakeDamage",function(ply, attacker)
  if thereisalastprop then
    return true
  end
end)

hook.Add("OBJHUNT_RoundStart","LPSOBJHUNT_RoundStart",function()
  thereisalastprop = false
  therecanbeapropstanding = false
  net.Start("LastPropStandingEndArrows")
  net.Broadcast()
  timer.Simple(LPSConfig.TimeUntilThereCanBeALPS,function()
    therecanbeapropstanding = true
  end)
end)

timer.Create("LastPropStandingCheckForLastProp",1,0,function()
  if !thereisalastprop then
    local props = 0
    for k, v in pairs(player.GetAll()) do
      if v:Team() == 1 and v:Alive() then
        props = props + 1
      end
    end
    if props == 1 then
      for k, v in pairs(player.GetAll()) do
        if v:Team() == 1 and v:Alive() and props == 1 then
          v:LastPropStandingIsLPS()
        end
      end
    end
  end
end)

net.Receive("LastPropStandingAskIfWantsWeaponYes",function(len, ply)
  if thereisalastprop and ply:Team() == 1 then
    ply:Give(LPSConfig.WeaponToGiveLPS[math.random(1,#LPSConfig.WeaponToGiveLPS)])
    local thevip = false
    for k, v in pairs(player.GetAll()) do
      if !v:IsBot() and v:Alive() and v:Team() == 2 then
        if thevip == false then
          thevip = {v, theplyspoints}
        else
          if theplyspoints > thevip[2] then
            thevip = {v, theplyspoints}
          end
        end
      end
    end
    for k, v in pairs(player.GetAll()) do
      net.Start("LastPropStandingStartArrows")
      net.Send(v)
      if thevip != false then
        if v == thevip[1] or table.HasValue(LPSConfig.GoldHuntersRankNeeded,v:GetUserGroup()) then
          net.Start("LastPropStandingStartArrows")
          net.Send(v)
          net.Start("LastPropStandingGiveGoldVIP")
          net.Send(v)
        end
      end
    end
  end
  if LPSConfig.TrailEnabled then
    ply.LPSTrail = util.SpriteTrail(ply, 0, team.GetColor(ply:Team()), false, 15, 1, 4, 1/(15+1)*0.5, LPSConfig.TrailMat)
  end
end)

concommand.Add("lpsamion",function(ply)
  ply:ChatPrint("Aye: "..tostring(thereisalastprop))
  ply:ChatPrint(LPSConfig.TrailMat)
end)

concommand.Add("lpsteams",function(ply)
  if ply:IsSuperAdmin() then
    local ayeho = false
    for k, v in pairs(player.GetAll()) do
      if ayeho then
        v:SetTeam(1)
        ayeho = false
      elseif !ayeho then
        v:SetTeam(2)
        ayeho = true
      end
    end
  end
end)
