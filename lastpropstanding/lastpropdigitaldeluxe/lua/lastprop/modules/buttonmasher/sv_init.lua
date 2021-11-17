masher = masher or {
    scores = {},
}

hook.Add('OnRoundStart', 'OnRoundStart:ButtonMasher', function()
    local topID, topScore = nil, 0
    for id, score in pairs(masher.scores) do
        if (score > 0 and score > topScore) then
            topScore = score
            topID = id
        end
    end
    if (topScore and topID) then
        local ply = Player(topID)
         util.Notify(nil,
         NOTIFY.GREEN, IsValid(ply) and ply:Nick() or 'Disconnected Player',
         NOTIFY.WHITE, ' won the Button Masher game with a score of ',
         NOTIFY.RED, topScore,
         NOTIFY.WHITE, '! Congtats!')
    end
    masher.scores = {}
end)

lps.net.Hook('MasherScore', function(ply, data)
    if (not masher.scores[ply:UserID()]) then
         masher.scores[ply:UserID()] = 0
    end
    if (data[1] == 'add') then
        masher.scores[ply:UserID()] = masher.scores[ply:UserID()] + 1
    end
    if (data[1] == 'sub') then
        if (masher.scores[ply:UserID()] > 0) then
            masher.scores[ply:UserID()] = masher.scores[ply:UserID()] - 1
        end
    end
    lps.net.Start(nil, 'MasherScores', masher.scores)
end)