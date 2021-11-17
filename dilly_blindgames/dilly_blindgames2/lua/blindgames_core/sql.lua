function BLINDGAMES.sql.makeTable(tabName, format)
    if(!sql.TableExists(tabName))then
        local query = format;
        result = sql.Query(query);
        
        if(!sql.TableExists(tabName))then
			ErrorNoHalt("SQL ERROR: "..sql.LastError(result));
		end  
    end
end

function BLINDGAMES.sql.createSQL()
    BLINDGAMES.sql.makeTable("bgames_userscores", "CREATE TABLE bgames_userscores(userID varchar(255), snakeScore INTEGER DEFAULT 0, buttonScore INTEGER DEFAULT 0, name STRING)");
end

function BLINDGAMES.sql.loadUser(pl, tbl)
	if(pl:Nick() != tbl.name)then
		sql.Query("UPDATE bgames_userscores SET 'name'='"..pl:Nick().."' WHERE userID='" ..pl:SteamID().. "'");
	end

    pl:SetNWInt("games_SnakeHighScore", tonumber(tbl.snakeScore) || 0);
    pl:SetNWInt("games_ButtonHighScore", tonumber(tbl.buttonScore) || 0);
end

function BLINDGAMES.sql.updateUserScore(id, scoreID, val)
	local result = sql.Query("SELECT * from bgames_userscores WHERE userID = '"..tostring(id).."'");
	if(result)then
        sql.Query("UPDATE bgames_userscores SET '"..scoreID.."'='"..val.."' WHERE userID='" ..id.. "'");
	end
end

function BLINDGAMES.sql.getHighScore(valName)
	local val = sql.Query("SELECT name, MAX("..valName..") AS topScore FROM bgames_userscores");
	return val[1] || 0;
end

hook.Add("InitPostEntity", "games.LoadSQL", function()
    BLINDGAMES.sql.createSQL();
	
	local snakeData = BLINDGAMES.sql.getHighScore("snakeScore");
	local keyData = BLINDGAMES.sql.getHighScore("buttonScore")
		
	SetGlobalInt("SnakeHighScore", snakeData.topScore);
	SetGlobalInt("KeysHighScore", keyData.topScore);
		
	SetGlobalString("KeysHighScoreName", keyData.name);
	SetGlobalString("SnakeHighScoreName", snakeData.name);	
end)

hook.Add("PlayerInitialSpawn", "games.onSpawnCheckSQL", function(pl)
    timer.Simple(0.1, function()
        local res = sql.Query("SELECT * from bgames_userscores WHERE userID = '"..tostring(pl:SteamID()).."'");
		local loadInfo = {};
		
        if(!res)then
            sql.Query("INSERT INTO bgames_userscores VALUES('"..tostring(pl:SteamID()).."', '0', '0', '"..pl:Nick().."')"); 
        else
			if(res[1])then
				loadInfo = res[1];
			end
        end
		BLINDGAMES.sql.loadUser(pl, loadInfo);
    end)
end)