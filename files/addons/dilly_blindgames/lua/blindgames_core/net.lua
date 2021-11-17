net.Receive("bgames_onScoreAdded", function(len, cli)
	local amt = math.Round(net.ReadFloat());
	cli:setGameScore(cli:getGameScore() + amt);
end)

net.Receive("bgames_onGameFinished", function(len, cli)
	local curScore = tonumber(cli:getGameScore());
	local id = "";
	local sqlID = "";
	
	if(cli:getCurGameID() == SNAKE_GAME)then
		id = "games_SnakeHighScore";
		sqlID = "snakeScore"
	elseif(cli:getCurGameID() == KEY_GAME)then
		id = "games_ButtonHighScore";
		sqlID = "buttonScore";
	end
	
	local highScore = cli:GetNWInt(id, 0);
	
	if(curScore > highScore)then
		BLINDGAMES.sql.updateUserScore(cli:SteamID(), sqlID, curScore);
		cli:SetNWInt(id, curScore);
	end
	
	local globalID = string.Replace(id, "games_", "");
	
	if(tonumber(GetGlobalInt(globalID)) < curScore)then
		SetGlobalInt(globalID, curScore);
		SetGlobalString(globalID.."Name", cli:Nick());
	end
	
	cli:setGameScore(0);
end)

net.Receive("bgames_onGameChanged", function(l, cli)
	local gameID = math.Round(net.ReadFloat());
	
	cli:setCurGame(gameID);
	cli:setGameScore(0);
end)