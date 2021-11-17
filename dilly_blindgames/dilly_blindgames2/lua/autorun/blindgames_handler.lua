BLINDGAMES = {};
BLINDGAMES.games = {};
BLINDGAMES.sql = {};

function BLINDGAMES.includeGameFiles()
	// These are all shared.
	local fol = "blindgames_games/";
	local files, folders = file.Find(fol .. "*.lua", "LUA")

	for k, v in pairs(files) do
		local dir = fol..v;
		print(dir);
		if(SERVER)then
			AddCSLuaFile(dir);
			include(dir);
		else
			include(dir);
		end
	end
end

function BLINDGAMES.addGame(name, gameTbl)
	for i,v in pairs(BLINDGAMES.games) do
		if(v.name == name)then
			table.remove(BLINDGAMES.games, i);
		end
	end
	
	gameTbl:Init();
	table.insert(BLINDGAMES.games, {name = name, gameTbl = gameTbl});
	return #BLINDGAMES.games;
end

if(SERVER)then
	util.AddNetworkString("bgames_onScoreAdded");
	util.AddNetworkString("bgames_onGameFinished");
	util.AddNetworkString("bgames_onGameChanged");
	
	AddCSLuaFile("blindgames_core/hooks.lua");
	AddCSLuaFile("blindgames_core/meta.lua");
	AddCSLuaFile("blindgames_core/menu.lua");
	
	include("blindgames_core/meta.lua");
	include("blindgames_core/hooks.lua");	
	include("blindgames_core/sql.lua");	
	include("blindgames_core/net.lua");	
elseif(CLIENT)then
	include("blindgames_core/meta.lua");
	include("blindgames_core/menu.lua");
	include("blindgames_core/hooks.lua");

	surface.CreateFont("GAMEFONT_BIG", {
		font = "Arial",
		size = ScreenScale(16),
		weight = 600,
		italic = true
	});
	
	surface.CreateFont("GAMEFONT_EXTRABIG", {
		font = "Arial",
		size = ScreenScale(20),
		weight = 600,
		italic = false
	});
	
	surface.CreateFont("GAMEFONT_MEDIUM", {
		font = "Arial",
		size = ScreenScale(24),
		weight = 600,
		italic = true
	});
	
	surface.CreateFont("GAMEFONT_SMALL", {
		font = "Arial",
		size = ScreenScale(10),
		weight = 600,
		italic = true
	});
	
	surface.CreateFont("GAMEFONT_EXSMALL", {
		font = "Arial",
		size = ScreenScale(7),
		weight = 600,
		italic = true
	});
end

BLINDGAMES.includeGameFiles();
