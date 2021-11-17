DSPECTATE = {};
include("spectate_config.lua");

if(SERVER)then
	AddCSLuaFile("spectate_config.lua");
	
	util.AddNetworkString("spectate_SendSpectPlayers");
	util.AddNetworkString("spectate_onNextObserver");
	util.AddNetworkString("spectate_onPrevObserver");
	util.AddNetworkString("spectate_Message");
	
	local pMeta = debug.getregistry().Player;

	function pMeta:sendSpectatePlayers(tab)
		net.Start("spectate_SendSpectPlayers");
			net.WriteTable(tab || {});
		net.Send(self);
	end
	
	function pMeta:sendSpectateMessage(mes)
		net.Start("spectate_Message");
			net.WriteString(mes || "");
		net.Send(self);
	end
	
	function setUpSpectate(pl, ent)
		ent.spectators = ent.spectators || {};
		
		if(ent != NULL)then	
			if(pl.oldSpect && pl.oldSpect != ent && pl.oldSpect.spectators)then
				pl.oldSpect.spectators[pl:SteamID()] = nil;
				pl.oldSpect:sendSpectatePlayers(pl.oldSpect.spectators);
			end
		
			ent.spectators[pl:SteamID()] = pl:Nick();
			ent:sendSpectatePlayers(ent.spectators);
			pl.oldSpect = ent;
		end
	end
	
	function removeOldSpectate(pl)
		if(pl.oldSpect)then
			pl.oldSpect.spectators[pl:SteamID()] = nil;
			pl.oldSpect:sendSpectatePlayers(pl.oldSpect.spectators);
		end
	end
	
	pMeta.oldSpec = pMeta.oldSpec || pMeta.SpectateEntity;
	function pMeta:SpectateEntity(ent)
		self:oldSpec(ent);
		setUpSpectate(self, ent);
	end
	
	pMeta.oldUnSpec = pMeta.oldUnSpec || pMeta.UnSpectate;
	function pMeta:UnSpectate()
		self:oldUnSpec();
		removeOldSpectate(self);
	end
	
	local function findSpectTarget(info)
		local pls = player.GetAll();
		
		for k, v in pairs(pls) do
			if tonumber(info) == v:UserID() then
				return v
			end
		end
		
		for k, v in pairs(pls) do
			if  info:upper() == v:SteamID() then
				return v;
			end
		end

		for k, v in pairs(pls) do
			if string.find(string.lower(v:Name()), string.lower(tostring(info))) ~= nil then
				return v;
			end
		end
		return nil
	end
	
	local function canSpectTarget(pl, ent)
		if(!IsValid(ent))then return false; end
		if(ent == pl ) then return false; end
		//if(!table.HasValue(((GAMEMODE && GAMEMODE:GetValidSpectatorEntityNames(pl)) || {}), ent:GetClass()))then return false; end
		if(ent:IsPlayer() && !ent:Alive())then return false; end
		if(ent:IsPlayer() && pl:Team() != ent:Team())then return false; end
		return true;
	end
	
	local function findNextObserver(pl, ent)
		local temTab = team.GetPlayers(pl:Team());
		table.RemoveByValue(temTab, pl);
		local found = table.FindNext(temTab, ent);
		return found;
	end
	
	local function findPrevObserver(pl, ent)
		local temTab = team.GetPlayers(pl:Team());
		table.RemoveByValue(temTab, pl);
		local found = table.FindPrev(temTab, ent);
		return found;
	end
	
	net.Receive("spectate_onNextObserver", function(len, cli)
		if(!cli:IsValid())then return; end
		local nex = findNextObserver(cli, cli:GetNWEntity("spect_observingTarget", NULL));
		removeOldSpectate(cli);
		setUpSpectate(cli, nex);
		cli:SetNWEntity("spect_observingTarget", nex);
	end)
	
	net.Receive("spectate_onPrevObserver", function(len, cli)
		if(!cli:IsValid())then return; end
		local nex = findPrevObserver(cli, cli:GetNWEntity("spect_observingTarget", NULL))
		removeOldSpectate(cli);
		setUpSpectate(cli, nex);
		cli:SetNWEntity("spect_observingTarget", nex);
	end)
	
	hook.Add("PlayerSay", "spectate_CommandCheck", function(pl, txt, _)
		if(string.StartWith(txt,DSPECTATE.comamnd || "!ob"))then
			if(pl:GetNWEntity("spect_observingTarget", NULL)==NULL)then
				local args = string.Explode(" ", txt);
				if(#args >= 2)then
					local tar = findSpectTarget(args[2]);
					if(tar && canSpectTarget(pl, tar))then
						pl:SetNWEntity("spect_observingTarget", tar);
						setUpSpectate(pl, tar);
						pl:sendSpectateMessage("You've started  to observe "..tar:Nick());
					else
						pl:sendSpectateMessage("Target is not allowed.");
					end
				end
			else
				removeOldSpectate(pl);
				pl:SetNWEntity("spect_observingTarget", NULL);
				pl:sendSpectateMessage("You've stopped observing.");
			end
			return "";
		end
	end)
	
	hook.Add("PlayerDeath", "spectate_NullObseervation", function(pl)
		pl:SetNWEntity("spect_observingTarget", NULL);
	end)
	
	hook.Add("PlayerSpawn", "spectate_NullObseervation", function(pl)
		pl:SetNWEntity("spect_observingTarget", NULL);
	end)
	
	hook.Add("PlayerDisconnected", "spectate_NullObseervation", function(pl)
		pl:SetNWEntity("spect_observingTarget", NULL);
		if(pl.oldSpect && pl.oldSpect.spectators)then
			pl.oldSpect.spectators[pl:SteamID()] = nil;
		end
	end)
else
	net.Receive("spectate_SendSpectPlayers", function()
		LocalPlayer().spectators = (net.ReadTable() || {});
	end)
	
	
	net.Receive("spectate_Message", function()
		local mes = net.ReadString();
		chat.AddText(DSPECTATE.tagColor || Color(200, 100, 50), "[OB]: ", DSPECTATE.messageTextColor || Color(255, 255, 255), mes);
	end)

	surface.CreateFont("spectName_title", {
		font="Arial",
		size=ScreenScale(8),
		weight = 600
	})
	
	surface.CreateFont("spectName_users", {
		font="Arial",
		size=ScreenScale(6),
		weight = 600
	})
	
	hook.Add("HUDPaint", "draw_spectatname", function()
		local spectators = LocalPlayer().spectators||{};
		if(table.Count(spectators) <= 0)then return; end
		
		local titleText = (DSPECTATE.spectateText || "Spectators:");
		
		local yOffset = ScrH() / 2;
		draw.SimpleText(titleText, "spectName_title", 0, yOffset, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		
		surface.SetFont("spectName_title");
		local w, h = surface.GetTextSize(titleText);
		
		yOffset = yOffset + h;
		
		for _,v in pairs(spectators) do
			draw.SimpleText(v, "spectName_users", 0, yOffset, DSPECTATE.nameTextColor || color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
			surface.SetFont("spectName_users");
			local w, h = surface.GetTextSize(v);
			
			yOffset = yOffset + h
		end
	end)
	
	hook.Add("Think", "observe_keyChecker", function()
		if((LocalPlayer().nextObserveKeyPress || 0) > CurTime())then return; end 
		
		if(input.IsKeyDown(KEY_RIGHT))then
			net.Start("spectate_onNextObserver");
			net.SendToServer();
			LocalPlayer().nextObserveKeyPress = CurTime() + (DSPECTATE.switchDelay || 0.4);
		elseif(input.IsKeyDown(KEY_LEFT))then
			net.Start("spectate_onPrevObserver");
			net.SendToServer();
			LocalPlayer().nextObserveKeyPress = CurTime() + (DSPECTATE.switchDelay || 0.4);
		end
	end)
	
	hook.Add("CalcView", "observe_customSpect", function(pl, origin, angles, fov)
		local view = {};
		
		if(pl:GetNWEntity("spect_observingTarget", nil)!=NULL)then
			local p = pl:GetNWEntity("spect_observingTarget"):EyePos();
			view.origin  = p-(angles:Forward()*(DSPECTATE.camBack || 100));
			return view;
		end
	end)
end