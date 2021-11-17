MINIGAMES = {};
MINIGAMES.games = {};

function MINIGAMES:RegisterMinigame(name)
	if(name == "Snake")then return; end
	MINIGAMES.games[name] = true;
end

if(SERVER)then
	util.AddNetworkString("Snakescore");
	util.AddNetworkString("SnakeTopscore");
	
	util.AddNetworkString("Masherscore");
	util.AddNetworkString("Masherscores");
	
	util.AddNetworkString("minigames_Start");
	util.AddNetworkString("minigames_End"); // TEMP
	util.AddNetworkString("minigame_Message");
	
	AddCSLuaFile("snake/cl_init.lua");
	AddCSLuaFile("buttonmasher/cl_init.lua");
	
	include("snake/sv_init.lua");
	include("buttonmasher/sv_init.lua");
	
	/*concommand.Add("minigame_Start", function()
		local pls = player.GetAll();
		local hunts = {};
		
		for i = 1, #pls do
			if(pls[i]:IsValid() && pls[i]:Team() == 2)then
				table.insert(hunts, pls[i]);
			end
		end
		
		net.Start("minigames_Start");
		net.Send(hunts);
	end)*/
	
	function MINIGAMES.query(str, callback)
		local res = sql.Query(str);
		if(callback)then callback(res); end
	end

	hook.Add("OBJHUNT_RoundEnd", 'Stop_Minigames', function()
		local pls = player.GetAll();
		local hunts = {};
		
		for i = 1, #pls do
			if(pls[i]:IsValid() && pls[i]:Team() == 2)then
				table.insert(hunts, pls[i]);
			end
		end
		
		net.Start("minigames_End");
		net.Send(hunts);
	end)
	
	hook.Add("OBJHUNT_RoundStart", 'Start_Minigames', function()
		local pls = player.GetAll();
		local hunts = {};
		
		for i = 1, #pls do
			if(pls[i]:IsValid() && pls[i]:Team() == 2)then
				table.insert(hunts, pls[i]);
			end
		end
		
		net.Start("minigames_Start");
		net.Send(hunts);
	end)
	
else
	surface.CreateFont('LPS80', {
		font = 'Roboto',
		weight = 800,
		size = 80,
		antialias = true
	})
	
	surface.CreateFont('LPS40', {
		font = 'Roboto',
		weight = 800,
		size = 40,
		antialias = true
	})

	surface.CreateFont('LPS16', {
		font = 'Roboto',
		weight = 800,
		size = 16,
		antialias = true
	})

	include("snake/cl_init.lua");
	include("buttonmasher/cl_init.lua");
	
	net.Receive("minigame_Message", function()
		local message = net.ReadTable();
		chat.AddText(unpack(message));
	end)
	
	net.Receive("minigames_End", function()
		if(LocalPlayer().current_MiniGame)then
			hook.Call('MinigameEndDraw', nil, LocalPlayer(), LocalPlayer().current_MiniGame);
			LocalPlayer().current_MiniGame = nil;
		end
	end)
	
	net.Receive("minigames_Start", function()
		local _, id = table.Random(MINIGAMES.games);
		if(id)then
			LocalPlayer().current_MiniGame = id;
		
			hook.Call('MinigameStartDraw', nil, LocalPlayer(), id);
		end
	end)
	
	hook.Add("Think", "minigame_CheckEnd", function()
		if(!LocalPlayer().current_MiniGame)then return; end
		
		if(!round.startTime)then return; end
		if(round.state != ROUND_IN)then return; end
		
		local textToDraw = round.startTime + round.timePad + OBJHUNT_HIDE_TIME - CurTime();
		textToDraw = math.Round(textToDraw, 0);
	
		if(LocalPlayer().current_MiniGame && textToDraw < 0 && LocalPlayer():Team() == TEAM_HUNTERS)then
			hook.Call('MinigameEndDraw', nil, LocalPlayer(), LocalPlayer().current_MiniGame);
			LocalPlayer().current_MiniGame = nil;
		end
	end)
	
	function util.Rainbow(saturation, value, alpha)
		saturation = saturation || 1
		value = value || 1
		alpha = alpha || 255
		local color = HSVToColor(math.abs(math.sin(0.3 * RealTime()) * 128), saturation, value)
		return Color(color.r, color.g, color.b, alpha)
	end
	
	function util.SetAlpha(color, alpha)
		return Color(color.r, color.g, color.b, alpha)
	end
	
	hook.Add("HUDPaint", "draw_miniGame", function()
		hook.Call('MinigameDraw', nil, LocalPlayer(), LocalPlayer().current_MiniGame||"");
	end)
end