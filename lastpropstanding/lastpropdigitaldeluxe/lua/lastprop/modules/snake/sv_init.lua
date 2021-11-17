local snake = snake or {
    topPlayer = '',
    topPlayerID = '',
    topScore = 0,
}

lps.net.Hook('SnakeScore', function(ply, data)
    if (data[1] > snake.topScore) then
        snake.topScore = data[1]
        snake.topPlayer = ply:Nick()
        snake.topPlayerID = ply:SteamID()
        lps.net.Start(nil, 'SnakeTopScore', {snake.topPlayer, snake.topScore})
    end

    if (not lps.sql:IsConnected()) then return end
    local queryObj = lps.sql:Select('snake')
    queryObj:Where('steam_id', ply:SteamID())
    queryObj:Callback(function(result, status, lastID)
        if (type(result) ~= 'table' and #result < 0 and tonumber(result[1].top_score) > data[1]) then return end
        local updateObj = lps.sql:Update('snake')
        updateObj:Update('name', ply:Name())
        updateObj:Update('top_score', data[1])
        updateObj:Where('steam_id', ply:SteamID())
        updateObj:Execute()
    end)
    queryObj:Execute()

end)

--[[---------------------------------------------------------
--   Hook: SNAKE:DBConnected()
---------------------------------------------------------]]--
hook.Add('DBConnected', 'SNAKE:DBConnected', function(ply)
    local queryObj = lps.sql:Create('snake')
    queryObj:Create('steam_id', 'VARCHAR(25) NOT NULL')
    queryObj:Create('name', 'VARCHAR(255) NOT NULL')
    queryObj:Create('top_score', 'INT NOT NULL')
    queryObj:PrimaryKey('steam_id')
	queryObj:Execute()
end)

--[[---------------------------------------------------------
--   Hook: SNAKE:PlayerInitialSpawn
---------------------------------------------------------]]--
hook.Add('PlayerInitialSpawn', 'SNAKE:PlayerInitialSpawn', function(ply)
    if (not lps.sql:IsConnected() or not IsValid(ply) or ply:IsBot()) then return end

    lps.net.Start(ply, 'SnakeTopScore', {snake.topPlayer, snake.topScore})

    local queryObj = lps.sql:Select('snake')
    queryObj:Where('steam_id', ply:SteamID())
    queryObj:Callback(function(result, status, lastID)
        if (type(result) == 'table' and #result > 0) then
            local updateObj = lps.sql:Update('snake')
            updateObj:Update('name', ply:Name())
            updateObj:Where('steam_id', ply:SteamID())
            updateObj:Execute()
        else
            local insertObj = lps.sql:Insert('snake')
            insertObj:Insert('name', ply:Name())
            insertObj:Insert('steam_id', ply:SteamID())
            insertObj:Insert('top_score', 0)
            insertObj:Execute()
        end
    end)
    queryObj:Execute()
end)