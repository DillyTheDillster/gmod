local plymeta = FindMetaTable("Player")
thereisalastprop = false

util.AddNetworkString("LastPropStandingAskIfWantsWeapon")
util.AddNetworkString("LastPropStandingAskIfWantsWeaponYes")
util.AddNetworkString("LastPropStandingAskIfWantsWeaponNo")
util.AddNetworkString("LastPropStandingStartArrows")
util.AddNetworkString("LastPropStandingEndArrows")
util.AddNetworkString("LastPropStandingGiveGoldVIP")

function plymeta:LastPropStandingIsLPS()
  if !thereisalastprop then
    thereisalastprop = true
    self:ChatPrint("You are the last prop standing!")
    LPSTesting(self)
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
      attacker:PS2_AddStandardPoints(LPSConfig.PointsToGiveLPSKiller, "You killed the last prop standing!", false)
    end
  elseif thereisalastprop and victim:Team() == 2 and victim != attacker then
    local haalive = false
    for k, v in pairs(player.GetAll()) do
      if v:Alive() and v:Team() == 2 then haalive = true end
      v:ChatPrint("The last prop standing has killed a hunter!")
    end
    attacker:PS2_AddStandardPoints(LPSConfig.PointsToGiveLPSKiller, "You killed the last prop standing!", false)
    if !haalive then
      thereisalastprop = false
      net.Start("LastPropStandingEndArrows")
      net.Broadcast()
    end
  end
end)

hook.Add("PlayerCanPickupWeapon","LPSPlayerCanPickupWeapon",function(ply, wep)
  if thereisalastprop and ply:Team() == 1 and table.HasValue(LPSConfig.WeaponToGiveLPS,wep:GetClass()) then
    return true
  end
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

function LPSTesting(ply)
  if thereisalastprop and ply:Team() == 1 then
    ply:Give(LPSConfig.WeaponToGiveLPS[math.random(1,#LPSConfig.WeaponToGiveLPS)])
    local thevip = false
    for k, v in pairs(player.GetAll()) do
      if v:Alive() and v:Team() == 2 then
        if thevip == false then
          thevip = {v, v.PS2_Wallet.points}
        else
          if v.PS2_Wallet.points > thevip[2] then
            thevip = {v, v.PS2_Wallet.points}
          end
        end
      end
    end
    for k, v in pairs(player.GetAll()) do
      net.Start("LastPropStandingStartArrows")
      net.Send(v)
      if v == thevip[1] or table.HasValue(LPSConfig.GoldHuntersRankNeeded,v:GetUserGroup()) then
        net.Start("LastPropStandingStartArrows")
        net.Send(v)
        net.Start("LastPropStandingGiveGoldVIP")
        net.Send(v)
      end
    end
  end
end

net.Receive("LastPropStandingAskIfWantsWeaponYes",function(len, ply)
  if thereisalastprop and ply:Team() == 1 then
    ply:Give(LPSConfig.WeaponToGiveLPS[math.random(1,#LPSConfig.WeaponToGiveLPS)])
    local thevip = false
    for k, v in pairs(player.GetAll()) do
      if v:Alive() and v:Team() == 2 then
        if thevip == false then
          thevip = {v, v.PS2_Wallet.points}
        else
          if v.PS2_Wallet.points > thevip[2] then
            thevip = {v, v.PS2_Wallet.points}
          end
        end
      end
    end
    for k, v in pairs(player.GetAll()) do
      net.Start("LastPropStandingStartArrows")
      net.Send(v)
      if v == thevip[1] or table.HasValue(LPSConfig.GoldHuntersRankNeeded,v:GetUserGroup()) then
        net.Start("LastPropStandingStartArrows")
        net.Send(v)
        net.Start("LastPropStandingGiveGoldVIP")
        net.Send(v)
      end
    end
    if LPSConfig.TrailEnabled then
      ply.LPSTrail = util.SpriteTrail(ply, 0, team.GetColor(ply:Team()), false, 15, 1, 4, 1/(15+1)*0.5, LPSConfig.TrialMat)
    end
  end
end)
