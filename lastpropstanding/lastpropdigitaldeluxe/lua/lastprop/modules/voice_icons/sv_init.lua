
hook.Add('Initialize', 'VoiceIcons:Initialize', function(ply)
    RunConsoleCommand('mp_show_voice_icons', 0)
end)