local mat_ColorMod = Material( "pp/colour" )
mat_ColorMod:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )
net.Receive("lucky_blockpp", function()
    local pp = net.ReadInt(3)
    if (pp == 1) then
        timer.Simple(16, function()
            hook.Remove('RenderScreenspaceEffects', 'DanceParty')
        end)
        hook.Add('RenderScreenspaceEffects', 'DanceParty', function()
            local c = HSVToColor(math.abs(math.sin(RealTime()) * 120), 1, .5)
            render.UpdateScreenEffectTexture()
            local tab = {
                [ "$pp_colour_addr" ] = 0.0,
                [ "$pp_colour_addg" ] = 0.0,
                [ "$pp_colour_addb" ] = 0.0,
                [ "$pp_colour_brightness" ] = 0.0,
                [ "$pp_colour_contrast" ] = 1.0,
                [ "$pp_colour_colour" ] = 0.0,
                [ "$pp_colour_mulr" ] = c.r * 0.1,
                [ "$pp_colour_mulg" ] = c.g * 0.1,
                [ "$pp_colour_mulb" ] = c.b * 0.1,
            }
            for k, v in pairs( tab ) do
                mat_ColorMod:SetFloat( k, v )
            end
            render.SetMaterial( mat_ColorMod )
            render.DrawScreenQuad()
        end)
    end
end)