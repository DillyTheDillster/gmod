CreateClientConVar('lps_vicons', '1', true, true) -- Hide Icons

hook.Add('GetGameOptions', 'GetGameOptions:VoiceIcons',  function(settings)
    table.insert(settings.visuals.settings,{
        convar = 'lps_vicons',
        type = 'bool',
        name = 'Voice Icons Enabled',
    })
end)

hook.Add('ResetConvars', 'ResetConvars:VoiceIcons',  function(settings)
    RunConsoleCommand('lps_vicons', '1')
end)

local icon =  Material('chat/icon')
hook.Add('HUDPaint', 'HUDPaint:VoiceIcons', function()
    local localPlayer = LocalPlayer()
    if (not IsValid(localPlayer) or GetConVar('lps_hidehud'):GetBool() or not GetConVar('lps_vicons'):GetBool()) then return end

    local padding = 10

    for _, ply in pairs(player.GetAll()) do
        if (ply ~= localPlayer) and (ply:Alive()) and (not ply:IsObserver()) and (ply:IsSpeaking()) and (ply:Team() == localPlayer:Team()) then
            local height = 72 + padding
            if (ply:IsDisguised()) then
                local disguise = ply:GetDisguise()
                if (IsValid(disguise)) then
                    local hullxy_max, hullxy_min, hullz = disguise:GetSize()
                    height = hullz + padding
                end
            end
            cam.Start3D()
                render.SetMaterial(icon)
                render.DrawSprite(ply:GetPos() + Vector(0,  0, height), 16, 16, util.SetAlpha(team.GetColor(localPlayer:Team()), 16))
            cam.End3D()
        end
    end
end)