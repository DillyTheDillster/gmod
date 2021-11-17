local GAME = {};

function GAME:Init()
	self.keyDelay = 0.8;
	self.nextKeyTime = 0;
	self.keyName = "";
	self.matchText = "";
	self.keyID = nil;
	self.needNewKey = false;
	
	self.keys = {
		{key=KEY_RIGHT, name="RIGHTARROW"},
		{key=KEY_LEFT,	name="LEFTARROW"},
		{key=KEY_UP, 	name="UPARROW"},
		{key=KEY_DOWN, 	name="DOWNARROW"},
	}
	
	self.intructions = {
		"--Hit the correct button",
		"--Wrong button = 20% score loss",
		"--Points earned go to the pointshop",
		"--1st place gets bonus points",
		"--1st place has a chance to win a"..(BLINDGAMES.boundItemID || "Hat").."!",
	}
	
	self:pickRandomKey();
end

function GAME:pickRandomKey()
	local copy = table.Copy(self.keys);
	for i, v in pairs(copy)do
		if(v.key == self.keyID)then
			table.remove(copy, i);
			break;
		end
	end

	
	local newKey = table.Random(copy);
	self.keyID = newKey.key;
	self.keyName = newKey.name;
end

function GAME:Tick()
	if(CLIENT)then
		if((self.nextKeyTime || CurTime()) > CurTime() || !LocalPlayer():isPlayingGame())then return; end
		
		if(self.needNewKey)then
			self:pickRandomKey();
			self.needNewKey = false;
			self.matchText = "";
		end
		
		if(input.IsKeyDown(self.keyID || 0))then
			self.matchText = "Correct";
			self.nextKeyTime = CurTime() + self.keyDelay;
			self.needNewKey = true;
			
			net.Start("bgames_onScoreAdded");
				net.WriteFloat(1);
			net.SendToServer();
		else
			local str = KEY_FIRST;
			local last = KEY_LAST;
			
			for i = str, last - str do
				if(input.IsKeyDown(i))then
					self.needNewKey = true;
					self.nextKeyTime = CurTime() + self.keyDelay;
					self.matchText = "Incorrect";
					
					net.Start("bgames_onScoreAdded");
						net.WriteFloat(LocalPlayer():getGameScore() * -0.2);
					net.SendToServer();
					break;
				end
			end
		end
	end
end

function GAME:Render()
	if(!LocalPlayer():isPlayingGame())then return; end
	draw.SimpleText(self.keyName||"", "GAMEFONT_BIG", ScrW()/2, ScrH()/1.8, BLINDGAMES.keyTextColor || Color(238,130,238), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
	draw.SimpleText(self.matchText||"", "GAMEFONT_BIG", ScrW()/2, ScrH()/1.5, BLINDGAMES.matchedTextColor || Color(0, 200, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
	draw.SimpleText("How To Play", "GAMEFONT_SMALL", ScrW() / 1.26, ScrH() / 2, BLINDGAMES.howToPlayColor || Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
	
	local yOff = 0;
	for i=1, #self.intructions do
		surface.SetFont("GAMEFONT_EXSMALL");
		local textW, textH = surface.GetTextSize(self.intructions[i]);
		
		draw.SimpleText(self.intructions[i], "GAMEFONT_EXSMALL", ScrW() / 1.26, (ScrH() / 1.9) + yOff, BLINDGAMES.instructionsTextColor || Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		yOff = yOff + textH;
	end
	
	for i, b in pairs(player.GetAll())do
		if(!b:isPlayingGame())then continue; end
		local boxW = ScrW() * 0.05;
		local boxH = b:getGameScore()*(ScrH() * 0.002);
		
		draw.RoundedBox(0, (i-1) * boxW*1.1, 0, boxW, math.Clamp(boxH * 7, 0, ScrH()/2), BLINDGAMES.barColor || Color(0, 198, 0));
	end
end

KEY_GAME = BLINDGAMES.addGame("Button Game", GAME);
