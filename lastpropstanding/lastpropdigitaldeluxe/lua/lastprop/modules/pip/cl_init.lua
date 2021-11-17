hook.Add('HUDPaint', 'PIP:HUDPaint', function()
    local ply = LocalPlayer()
    if (not IsValid(ply) or not ply:Alive() or ply:Team() ~= TEAM.PROPS or ply:GetVar('lastMan', false) or IsValid(ply:GetActiveWeapon())) then return end

    local ent = ply:GetNWEntity('pip', nil)
    if (not IsValid(ent) or not ent:IsPlayer() or not ent:Alive() or ent:Team() ~= TEAM.PROPS or ent == ply) then return end

    local angles = ply:EyeAngles()
    local view = {
        angles = angles,
        x = 0,
        y = 0,
        w = ScrW() / 3,
        h = ScrH() / 3,
        dopostprocess = false,
    }

    local trData = {
        start   = ent:GetShootPos(),
        endpos  = ent:GetShootPos() + ( angles:Forward() * -100),
        filter  = function(ent)
            if (table.HasValue({'lps_disguise', 'player'}, ent:GetClass())) then return false end
            return true
        end,
        mins    = Vector(-4, -4, -4),
        maxs    = Vector(4, 4, 4)
    }

    local tr  = util.TraceHull(trData)
    view.origin = tr.HitPos

    render.RenderView( view)
    draw.DrawText( ent:Nick(), 'LPS16', 11, ( ScrH() / 3) - 24,  Color(0,0,0), TEXT_ALIGN_LEFT)
    draw.DrawText( ent:Nick(), 'LPS16', 10, ( ScrH() / 3) - 25,  Color(255,255,255), TEXT_ALIGN_LEFT)
end)

hook.Add( 'RegisterBindings', 'PIP:RegisterBindings', function ()
    lps.bindings:Register('prop', 'pipToggle', KEY_SLASH, INPUT.KEY, 'PIP Toggle', 'Toggles the PiP (Picture in Picture) screen.')
    lps.bindings:Register('prop', 'pipNext', KEY_PERIOD, INPUT.KEY, 'PIP Next', 'Displays the next the PiP (Picture in Picture) screen target.')
    lps.bindings:Register('prop', 'pipPrev', KEY_COMMA, INPUT.KEY, 'PIP Previous', 'Displays the previous the PiP (Picture in Picture) screen target.')
end)

hook.Add( 'KeyDown', 'PIP:KeyDown', function (key, keycode, char, keytype, busy, cursor)
    local ply = LocalPlayer()
    if (not IsValid(ply) or busy or cursor or ply:GetVar('lastMan', false) or not ply:Alive() or IsValid(ply:GetActiveWeapon())) then return end

    local pipToggle = lps.bindings:GetKey('prop', 'pipToggle')
    local pipNext = lps.bindings:GetKey('prop', 'pipNext')
    local pipPrev = lps.bindings:GetKey('prop', 'pipPrev')

    if (key == pipToggle.key and keytype == pipToggle.type) then
        RunConsoleCommand('lps_piptoggle')
    elseif (key == pipNext.key and keytype == pipNext.type) then
        RunConsoleCommand('lps_pipnext')
    elseif (key == pipPrev.key and keytype == pipPrev.type) then
        RunConsoleCommand('lps_pipprev')
    end
end)

