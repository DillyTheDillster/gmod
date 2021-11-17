local last_input = CurTime()
hook.Add('KeyDown', 'IdleKeyDown', function()
    last_input = CurTime()
end)

lps.net.Hook('CheckIdle', function()
    lps.net.Start('PlayerIdle', (last_input - CurTime()) * -1)
end)