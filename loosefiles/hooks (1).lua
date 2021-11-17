if(SERVER)then
	// Only called on serverside
	hook.Add("OnBlind", "games.onBlind", function(pl, b, forced)
		forced = forced || false;
		if(!forced && (pl:Team() != TEAM_HUNTERS && pl:Team() != TEAM_SPEC))then return; end
		local curGame = pl:getCurGame();
		
		if(!curGame || curGame == 0)then return; end;
		
		local gameTable = curGame.gameTbl;
		if(b)then
			if(!pl:isPlayingGame() || false)then
				pl:setPlayingGame(true);
				gameTable:Init();
			end
		else
			if(pl:isPlayingGame())then
				local curScore = tonumber(pl:getGameScore());
				local id = "";
				local sqlID = "";
				
				if(pl:getCurGameID() == SNAKE_GAME)then
					id = "games_SnakeHighScore";
					sqlID = "snakeScore"
				elseif(pl:getCurGameID() == KEY_GAME)then
					id = "games_ButtonHighScore";
					sqlID = "buttonScore";
				end
				
				local highScore = pl:GetNWInt(id, 0);
				
				if(curScore > highScore)then
					BLINDGAMES.sql.updateUserScore(pl:SteamID(), sqlID, curScore);
					pl:SetNWInt(id, curScore);
				end
				
				local globalID = string.Replace(id, "games_", "");
				
				if(tonumber(GetGlobalInt(globalID)) < curScore)then
					SetGlobalInt(globalID, curScore);
					SetGlobalString(globalID.."Name", pl:Nick());
				end
				
				if(#player.GetAll() > 1)then
					pl:PS2_AddStandardPoints(pl:getGameScore() * (BLINDGAMES.pointsPerScore || 1));
					if(pl:SteamID() == GetGlobalString("snake_highestScoreSteam", ""))then
						pl:PS2_AddStandardPoints(BLINDGAMES.firstPlaceBonus || 0);
					
						if(math.random(0, 100) <= (BLINDGAMES.bounsItemPercent || 30))then
							local item = Pointshop2.GetItemClassByPrintName( BLINDGAMES.boundItemID )
							if not item then
								error( "Invalid item " .. tostring( BLINDGAMES.boundItemID ) )
							end
							pl:PS2_EasyAddItem( item.className );
						end
					end
				end

				
				pl:setGameScore(0);
			end
			pl:setPlayingGame(false);
		end
	end)

	hook.Add("PlayerDeath", "games.onPlayerDeath", function(pl)
		if(GAMEMODE.Name == "Trouble in Terrorist Town")then
			timer.Simple(1, function()
			if(pl:Team() == TEAM_SPEC)then
				hook.Call("OnBlind", nil, pl, true);
			else
				hook.Call("OnBlind", nil, pl, false);
			end
			end);
		end
	end)

	hook.Add("PlayerSpawn", "games.CheckBlidSpawn", function(pl)
		//print("PLAYER", pl:isPlayingGame());
		if(pl:isPlayingGame())then
			if(GAMEMODE.Name == "Trouble in Terrorist Town")then
				hook.Call("OnBlind", nil, pl, false, true);
			end
		end
	end)
	
	hook.Add("PlayerInitialSpawn", "games.OnPlayerFirstJoin", function(pl)
		// Inital start up, just pause and wait.
		pl:setCurGame(1);
		pl:setPlayingGame(false);
	end)
	
	hook.Add("PlayerSay", "games.OnPlayerOptions", function(pl, text)
	local len = (string.len("play") + 1)
    	if ((string.lower(string.sub(text, 1, len)) == "!".."play") || ((string.lower(string.sub(text, 1, len))) == "/".."play")) then
    		if (string.lower(string.sub(text, (len + 2), (len + 8)))== "options") then
    			pl:ConCommand("games_openMenu");
    			return ""
    		elseif (string.lower(string.sub(text, (len + 2), (len + 6)))== "snake") then
    			for i, v in pairs(BLINDGAMES.games || {}) do
    				if string.lower(v.name) == "snake" then
    					pl:setCurGame(i);
    					pl:setPlayingGame(true);
    				end
    			end
    			//pl:setCurGame(2);
				//hook.Call("OnBlind", nil, pl, false, true);
				//pl:setPlayingGame(true);
				return ""
			elseif (string.lower(string.sub(text, (len + 2), (len + 5)))== "keys") then
				for i, v in pairs(BLINDGAMES.games || {}) do
    				if string.lower(v.name) == "button game" then
    					pl:setCurGame(i);
    					pl:setPlayingGame(true);
    				end
    			end
				return ""
			elseif (string.lower(string.sub(text, (len + 2), (len + 8)))== "disable") then
				for i, v in pairs(BLINDGAMES.games || {}) do
    				if string.lower(v.name) == "no games" then
    					pl:setCurGame(i);
    					pl:setPlayingGame(true);
    				end
    			end
				return ""
    		end

    		pl:ChatPrint("Available Commmands:")
    		pl:ChatPrint("! or / can be used to run commands")
    		pl:ChatPrint("!play options - opens the options menu")
    		pl:ChatPrint("!play snake/keys - plays/sets specific game")
    		pl:ChatPrint("!play disable - disables games")

			return ""
		end
	end)
end

hook.Add("KeyPress", "keypress_disable_BG", function(ply, key)
	if(ply:isPlayingGame())then
		if ( key == IN_JUMP ) then
			if(GAMEMODE.Name == "Trouble in Terrorist Town")then
				hook.Call("OnBlind", nil, ply, false, true);
			else
				hook.Call("OnBlind", nil, ply);
			end
		end
	end
end)

hook.Add("Think", "games.OnTick", function()
	if(CLIENT)then
		local curGame = LocalPlayer():getCurGame();

		if(curGame && curGame != nil)then
			local gameInfo = curGame.gameTbl;
			gameInfo:Tick();
		end
	else
		for _,v in pairs(player.GetAll())do
			local curGame = v:getCurGame();

			if(curGame && curGame != nil)then
				local gameInfo = curGame.gameTbl;
				gameInfo:Tick();
			end
		end
	end
end)
	

// These only are needed via client.
if(CLIENT)then
	hook.Add("HUDPaint", "games.HudPaint", function()
		local curGame = LocalPlayer():getCurGame();
		
		if(curGame && curGame != nil)then
			local gameInfo = curGame.gameTbl;
			gameInfo:Render();
		end
	end)
	
	local hideHUDElements = {
		["CHudAmmo"] 				= true,
		["CHudHealth"] 				= true,
		["CHudBattery"] 			= true,
		["CHudSecondaryAmmo"]	 	= true,
	}

	-- this is the code that actually disables the drawing.
	hook.Add("HUDShouldDraw", "games.HideHudForGame", function(name)
		if not LocalPlayer().isPlayingGame then return; end
		if(!LocalPlayer():isPlayingGame())then return; end
		if hideHUDElements[name]then return false end
	end)
	
	concommand.Add("games_openMenu", function(user)
		BLINDGAMES.makeMenu();
	end)
end

hook.Add("StopGame", "endgame", function(ply)

	hook.Call("OnBlind", nil, ply);

end)

hook.Add("StartGame", "playgame", function(pl)

	--hook.Call("OnBlind", nil, pl, false, true);
		for i, v in pairs(BLINDGAMES.games || {}) do
			pl:setCurGame(i);
			pl:setPlayingGame(true);
		end

end)