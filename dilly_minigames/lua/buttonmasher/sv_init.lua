masher = {
    scores = {},
}

hook.Add('Initialize', 'Initialize:ButtonMasher', function(ply, minigame)
    MINIGAMES:RegisterMinigame('Button Masher')
end)

hook.Add("Think", "ButtomMasher:Think", function()
	if(!round || round.state != ROUND_IN)then return; end
	
	local roundTime = CurTime() - round.startTime
	if(roundTime > OBJHUNT_HIDE_TIME)then
		for _, v in pairs(player.GetAll()) do
			if(v:Team() != TEAM_HUNTERS)then continue; end
			hook.Call("OBJHUNT_UnBlind", nil, v);
		end
	end
end)

hook.Add('OBJHUNT_UnBlind', 'OnRoundStart:ButtonMasher', function()
	local topID, topScore = nil, 0;
    for id, score in pairs(masher.scores) do
        if(score > 0 && (score||0) > topScore)then
            topID = id;
			topScore = score||0;
        end
    end
    
	if(topScore && topID)then
		print(topScore);
	
        local ply = Player(topID);
		net.Start("minigame_Message");
		net.WriteTable({
		Color(0, 200, 0), IsValid(ply) && ply:Nick() || 'Disconnected Player',
		color_white, ' won the Button Masher game with a score of ',
		Color(235, 0, 0), tostring(topScore),
		color_white, '! Congtats!'});
		net.Broadcast();
    end
	
    masher.scores = {};
	net.Start('Masherscores');
		net.WriteTable(masher.scores);
	net.Broadcast();
end)

net.Receive('Masherscore', function(_, ply)
	local data = net.ReadTable();
    if(!masher.scores[ply:UserID()])then
		masher.scores[ply:UserID()] = 0;
    end
	
    if(data[1] == 'add')then
		masher.scores[ply:UserID()] = masher.scores[ply:UserID()] + 1;
    end
	
    if(data[1] == 'sub')then
        if(masher.scores[ply:UserID()] > 0)then
			masher.scores[ply:UserID()] = masher.scores[ply:UserID()] - 1;
        end
    end
	
    net.Start('Masherscores');
		net.WriteTable(masher.scores);
	net.Broadcast();
end)