masher = masher or {
    keys = {
        { text = 'UP', keys = {KEY_UP}},
        { text = 'DOWN', keys = {KEY_DOWN}},
        { text = 'LEFT', keys = {KEY_LEFT}},
        { text = 'RIGHT', keys = {KEY_RIGHT}},
        { text = 'SHIFT', keys = {KEY_LSHIFT, KEY_RSHIFT}},
        { text = 'SPACE', keys = {KEY_SPACE}},
        { text = 'ALT', keys = {KEY_RALT, KEY_LALT}},
        { text = 'CONTROL', keys = {KEY_LCONTROL, KEY_RCONTROL}},
        { text = 'ENTER', keys = {KEY_ENTER}},
        { text = 'BACKSPACE', keys = {KEY_BACKSPACE}},
    },
    key = {},
    active = false,
    flash = CurTime(),
    scores = {},
    colors = {},
}

hook.Add('Initialize', 'Initialize:ButtonMasher', function(ply, minigame)
    GAMEMODE:RegisterMinigame('Button Masher')
    for i=1, 4 do
        for j=0, 6 do
            table.insert(masher.colors, HSVToColor(j * 60, 1, 1))
        end
    end
end)

hook.Add('MinigameStartDraw', 'MinigameStartDraw:ButtonMasher', function(ply, minigame)
    if (minigame ~= 'Button Masher') then return end
    masher.key = table.Random(masher.keys)
    masher.active = true
end)

hook.Add('MinigameDraw', 'MinigameDraw:ButtonMasher', function(ply, minigame)
    if (minigame ~= 'Button Masher') then return end

    --Draw Background
    surface.SetDrawColor(0, 0, 0)
    surface.DrawRect(0, 0, ScrW(), ScrH())

    --Draw Scores
    local i = 0
    for id, score in pairs(masher.scores) do
        draw.RoundedBox(4, 10, 10 + (i * 30), ScrW() - 20, 20, Color(25, 25, 25))
        draw.RoundedBox(4, 10, 10 + (i * 30), score * 10, 20, util.SetAlpha(masher.colors[i + 1], 80))
        local ply = Player(id)
        local name = IsValid(ply) and ply:Nick() or 'Player'
        draw.DrawText(string.format('%s [%s]', name, score), 'LPS16', 21, 13 + (i * 30), Color(0,0,0,200), TEXT_ALIGN_LEFT)
        draw.DrawText(string.format('%s [%s]', name, score), 'LPS16', 20, 12 + (i * 30), Color(255,255,255,200), TEXT_ALIGN_LEFT)
        i = i + 1
    end

    --Draw text
    draw.DrawText(masher.key.text, 'LPS80', (ScrW()/2), (ScrH()/2) - 80, util.Rainbow(), TEXT_ALIGN_CENTER)

    --Draw flash
    if (masher.flash > CurTime()) then
        draw.DrawText(masher.key.text, 'LPS80', (ScrW()/2), (ScrH()/2) - 80, Color(255,255,255, ((masher.flash - CurTime())/0.3) * 255), TEXT_ALIGN_CENTER)
    end

end)

hook.Add('MinigameEndDraw', 'MinigameEndDraw:ButtonMasher', function(ply, minigame)
    if (minigame ~= 'Button Masher') then return end
    masher.active = false
end)

hook.Add('KeyDown', 'KeyDown:ButtonMasher', function(key, keycode, char, keytype, busy, cursor)
    if (not masher.active or keytype == INPUT.MOUSE) then return end

    for i=1, #masher.key.keys do
        if (key == masher.key.keys[i]) then
            local oldKey = masher.key.text
            repeat
                masher.key = table.Random(masher.keys)
            until
                masher.key.text ~= oldKey

            lps.net.Start('MasherScore', {'add'})
            return
        end
    end

    for i=1, #masher.keys do
        for j=1, #masher.keys[i].keys do
            if (key == masher.keys[i].keys[j]) then
                lps.net.Start('MasherScore', {'sub'})
                masher.flash = CurTime() + 0.3
                return
            end
        end
    end
end)

lps.net.Hook('MasherScores', function(data)
    masher.scores = data
end)