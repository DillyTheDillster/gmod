local snake = snake || {
    topPlayer = '',
    topPlayerID = '',
    topscore = 0,
}

hook.Add('Initialize', 'Initialize:Snake', function(ply, minigame)
    MINIGAMES:RegisterMinigame('Snake')
	
	MINIGAMES.query("CREATE TABLE IF NOT EXISTS snake (steam_id VARCHAR(25) NOT NULL PRIMARY KEY, name VARCHAR(255) NOT NULL, top_score INT NOT NULL)");
end)

net.Receive('Snakescore', function(l, ply)
	local data = net.ReadTable();

    if (data[1] > snake.topscore) then
        snake.topscore = data[1]
        snake.topPlayer = ply:Nick()
        snake.topPlayerID = ply:SteamID()
		
		net.Start('SnakeTopscore');
			net.WriteTable({snake.topPlayer, snake.topscore});
		net.Broadcast();
	end

	MINIGAMES.query("SELECT * FROM snake WHERE steam_id = '"..ply:SteamID().."'", function(result)
		if (type(result) ~= 'table' && #result < 0 && tonumber(result[1].top_score) > data[1]) then return end
    	
		MINIGAMES.query("UPDATE snake SET top_score = '"..data[1].."' WHERE steam_id = '"..ply:SteamID().."'");
	end)
end)

hook.Add("PlayerInitialSpawn", "load_snakeData", function(pl)
	net.Start('SnakeTopscore');
		net.WriteTable({snake.topPlayer, snake.topscore});
	net.Send(pl);

	MINIGAMES.query("SELECT * FROM snake WHERE steam_id = '"..pl:SteamID().."'", function(result)
		if(type(result) == "table" && #result > 0)then
			MINIGAMES.query("UPDATE snake SET name = '"..pl:Name().."' WHERE steam_id = "..pl:SteamID());
		else
			MINIGAMES.query("INSERT INTO snake(name, steam_id, top_score) VALUES ('"..pl:Name().."', '"..pl:SteamID().."', 0)");
		end
	end)
end)