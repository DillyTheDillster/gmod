
--[[---------------------------------------------------------
--   CONFIG
---------------------------------------------------------]]--
local dropChance = 0.1 -- 10% chance of a luckyblock drop!

--[[
-----------------------------------------------------------
--   How to add a luckyblock
-----------------------------------------------------------

list.Set("LuckyBlock", "MyLuckyBlock", { chance (between 100 and -100) , function(ent, ply)
    return 'This is my luckyblock!'
    you can also return false for a random string.
end })

]]--

list.Set("LuckyBlock", "HPAdded", { 40, function(ent, ply)
    ply:SetHealth(ply:Health() + 50)
    ply:ChatPrint("[Lucky Block] You got free 50+ HP!")
end })

list.Set("LuckyBlock", "HPReduced50", { -20, function(ent, ply)
    local dmgInfo = DamageInfo()
    dmgInfo:SetAttacker(ply)
    dmgInfo:SetDamage(50)
    dmgInfo:SetDamageType(DMG_GENERIC)
    ply:TakeDamageInfo(dmgInfo)
    return 'Aww... your health reduced by -50 HP, better luck next time!'
end })

list.Set("LuckyBlock", "HPReduced50%", { -40, function(ent, ply)
    local dmgInfo = DamageInfo()
    dmgInfo:SetAttacker(ply)
    dmgInfo:SetDamage(ply:Health()/2)
    dmgInfo:SetDamageType(DMG_GENERIC)
    ply:TakeDamageInfo(dmgInfo)
    return 'Aww... your health reduced by 50%, better luck next time!'
end})

list.Set("LuckyBlock", "Boom", { -10, function(ent, ply)
    local bomb = ents.Create("combine_mine")
    bomb:SetPos(Vector(ply:GetPos()))
    bomb:SetAngles(Angle(0,0,0))
    bomb:Spawn()
    bomb:Activate()
    bomb:SetOwner(ply)
    return 'BOOOOOOOOOOOOOOOOOOOOM!'
end})

list.Set("LuckyBlock", "RPG", { 10, function(ent, ply)
    if ply:HasWeapon("weapon_rpg") then return false end
    ply:Give("weapon_rpg")
    ply:SetAmmo(2, "RPG_Round")
    return "You got a free RPG!"
end})

list.Set("LuckyBlock", "Frag", { 20, function(ent, ply)
    ply:Give("weapon_frag")
    return "You got a free Frag!"
end})

list.Set("LuckyBlock", "Bugbait", { -60, function(ent, ply)
    if ply:HasWeapon("weapon_bugbait") then return false end
    ply:Give("weapon_bugbait")
    return "You got Bugbait for free... which does nothing. (unless you have a pet antlion)."
end})

list.Set("LuckyBlock", "Dance", { 50, function(ent, ply)
    ply:EmitSound('luckyblock_dance')
    ply:SendLua("RunConsoleCommand(\'act\', \'dance\')")
    net.Start('lucky_blockpp')
    net.WriteInt(1, 3)
    net.Send(ply)
    return "DANCE PARTTTTTTTY!"
end})

--[[---------------------------------------------------------
--    DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOUR DOING!   --
---------------------------------------------------------]]--

util.AddNetworkString('lucky_blockpp')

hook.Add("PropBreak", "PropBreakLuckyBlock", function(ply, ent)
    if (math.random() < dropChance) then
        local pos = ent:GetPos()
        local ent = ents.Create("lps_luckyblock")
        ent:SetPos(pos * 25)
        ent:Spawn()
        ent:Activate()
    end
end)