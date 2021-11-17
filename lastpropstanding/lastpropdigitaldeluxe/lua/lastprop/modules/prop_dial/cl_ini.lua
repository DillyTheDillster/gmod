
CreateClientConVar('lps_propdial', '1', true, true) -- Hide dial

hook.Add('GetGameOptions', 'GetGameOptions:PropDial',  function(settings)
    table.insert(settings.visuals.settings,{
        convar = 'lps_propdial',
        type = 'bool',
        name = 'Prop Dial Enabled',
    })
end)

hook.Add('ResetConvars', 'ResetConvars:PropDial',  function(settings)
    RunConsoleCommand('lps_propdial', '1')
end)

local dial = surface.GetTextureID( "vgui/lps/dial" )
local hand = surface.GetTextureID( "vgui/lps/hand" )
hook.Add('HUDPaint', 'HUDPaint:PropDial', function()
    local localPlayer = LocalPlayer()
    if (not IsValid(localPlayer) or not localPlayer:Alive() or GetConVar('lps_hidehud'):GetBool() or not GetConVar('lps_propdial'):GetBool() or IsValid(localPlayer:GetActiveWeapon())) then return end

    local disguise =  localPlayer:GetDisguise()
    if (not IsValid(disguise)) then return end

    local angle = math.Round( disguise:GetAngles().p )
    local y = 30

    surface.SetTexture( dial )
    surface.SetDrawColor( Color( 0, 0, 0, 10 ) )
    surface.DrawTexturedRect( (( ScrW() / 2 ) - 128), ( ScrH() - 256 ) + y, 256, 256 )

    surface.SetTexture( hand )
    surface.SetDrawColor( Color( 0, 0, 0, 10 ) )
    surface.DrawTexturedRectRotated( ( ScrW() / 2 ), ( ScrH() - 128 ) + y, 256, 256, -angle )

    draw.DrawText( angle, "LPS18", ( ScrW() / 2 ), ( ScrH() - 137 ) + y , Color( 255, 255, 255, 240 ), TEXT_ALIGN_CENTER )
end)
