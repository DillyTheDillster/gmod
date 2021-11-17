local DIR = {
	UP = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 3
}

local GAME = {};
function GAME:Init()
	self.updateRate = BLINDGAMES.updateRate || 0.1;
	self.nextUpDate = nil;
	self.nextFood = CurTime();
	self.direct = DIR.RIGHT;
	self.food = nil;
	self.isAlive = true;
	self.curScore = 0;
	if(CLIENT)then
		self:makeSnake();
		self.head = self.bodyParts[1];
	end
end

function GAME:makeSnake()
	self.bodyParts = {};
	
	for i=1, 2 do
		table.insert(self.bodyParts, {
			x=0,
			y=0,
			w=ScrW()/90,
			h=ScrH()/50
		})
	end
end

function GAME:spawnFood()
	self.food = {};
	
	local foodW = ScrW()/95;
	local foodH = ScrH()/55;

	self.food.w=foodW;
	self.food.h=foodH;
	self.food.y=math.random(20, ScrH()-foodH) - (foodW / 2);
	self.food.x=math.random(20, ScrW()-foodW) - (foodH / 2);
end

function GAME:addNewPart()
	table.insert(self.bodyParts, {
		x=0,
		y=0,
		w=ScrW()/90,
		h=ScrH()/50,
		startRender = CurTime() + 0.2
	})
end

function GAME:moveSnake()
	local lastx, lasty = self.head.x,self.head.y;
	
	local dir = self.direct;
	if(dir == DIR.UP)then
		self.head.y = self.head.y - self.head.h;
	elseif(dir == DIR.DOWN)then
		self.head.y = self.head.y + self.head.h;
	elseif(dir == DIR.LEFT)then
		self.head.x = self.head.x - self.head.w;
	elseif(dir == DIR.RIGHT)then
		self.head.x = self.head.x + self.head.w;
	end
	
	for i, v in pairs(self.bodyParts || {}) do
		if(v == self.head)then continue; end
			
		local oldX = v.x;
		local oldY = v.y;
			
		v.x = lastx;
		v.y = lasty;
		
		lastx, lasty = oldX, oldY;
	end
end

function GAME:checkDirChange()
	if(input.IsKeyDown(KEY_DOWN))then
		self.direct = DIR.DOWN;
	elseif(input.IsKeyDown(KEY_UP))then
		self.direct = DIR.UP;
	elseif(input.IsKeyDown(KEY_RIGHT))then
		self.direct = DIR.RIGHT;
	elseif(input.IsKeyDown(KEY_LEFT))then
		self.direct = DIR.LEFT;
	end
end

function GAME:checkCollide(p, p2)
	if(p.x + p.w < p2.x)then return false; end
	if(p.y + p.h < p2.y)then return false; end
	if(p.x > p2.x + p2.w)then return false; end
	if(p.y > p2.y + p2.h)then return false; end
	
	return true;
end

function GAME:checkHeadCollide(p2)
	local w = self.head.w /2;
	local h = self.head.h / 1.4;
	local x = self.head.x + (self.head.w / 2) - (w/2);
	local y = self.head.y + (self.head.h / 2) - (h/2);
	local newBox = {x=x,y=y,w=w,h=h};
	
	return self:checkCollide(newBox, p2);
end

function GAME:outOfBounds()
	if(self.head.x < 0 || self.head.x > ScrW())then return true; end
	if(self.head.y < 0 || self.head.y > ScrH())then return true; end
	
	return false;
end

function GAME:Tick()
	if(SERVER)then
		local highScore = 0;
		local higestName = "";
		local steam = "";
		for _,v in pairs(player.GetAll())do
			if(v:isPlayingGame())then
				if(highScore < v:getGameScore())then
					highScore = v:getGameScore();
					higestName = v:Nick();
					steam = v:SteamID();
				end
			end
		end
		
		SetGlobalInt("snake_highestScore", highScore);
		SetGlobalString("snake_highestScoreName", higestName);
		SetGlobalString("snake_highestScoreSteam", steam);
	else
		if(((self.nextUpDate || CurTime()) > CurTime()) || !self.isAlive || !LocalPlayer():isPlayingGame())then return; end
	
		if(!self.food)then
			self:spawnFood();
		end
		
		self:checkDirChange();
		
		if(((self.nextUpDate || CurTime()) > CurTime()) || !self.isAlive)then return; end
		
		local died = false;
		for i,v in pairs(self.bodyParts)do
			if(i<3)then
				if(self:outOfBounds())then
					died = true;
					break;
				end
			elseif(self:checkHeadCollide(v))then
				died = true;
				break;
			end
		end
		
		if(died)then
			self:Finish();
			return;
		end
		
		self:moveSnake();
		
		if(self:checkCollide(self.food, self.head))then
			self.curScore = self.curScore + 1;
			self.food = nil;
			
			net.Start("bgames_onScoreAdded");
				net.WriteFloat(1);
			net.SendToServer();
			
			self:addNewPart();
		end
		
		self.nextUpDate = CurTime() + self.updateRate;
	end
end

function GAME:Finish()
	net.Start("bgames_onGameFinished");
	net.SendToServer();
	
	self:Init();
end

function GAME:Render()
	if(!LocalPlayer():isPlayingGame())then return; end
	
	if(self.food != nil)then
		draw.RoundedBox(0, self.food.x, self.food.y, self.food.w, self.food.h, Color(255, 255, 0));
	end
	
	for i, v in pairs(self.bodyParts) do
		local col = (BLINDGAMES.bodyColor || Color(255, 255, 255));
		if(i == 1)then col = (BLINDGAMES.headColor || Color(0, 255, 0)); end
		if((v.startRender || CurTime()) > CurTime())then continue; end
		
		draw.RoundedBox(0, v.x, v.y, v.w, v.h, col);
	end
	
	local highScore = GetGlobalInt("SnakeHighScore", 0);
	local highScoreName = GetGlobalString("SnakeHighScoreName", "NONE");
	
	draw.SimpleText("Monthly High Score: "..highScore.."("..highScoreName..")", "GAMEFONT_BIG", ScrW() / 2, ScrH() / 40, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
	draw.SimpleText("High Score: "..GetGlobalInt("snake_highestScore").."("..GetGlobalString("snake_highestScoreName", "")..")", "GAMEFONT_BIG", ScrW() / 2, ScrH() / 11, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
	draw.SimpleText("Score: "..LocalPlayer():getGameScore(), "GAMEFONT_BIG", ScrW() / 2, ScrH() / 8, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);

	if(!self.isAlive)then
		draw.SimpleText("Game over", "GAMEFONT_EXTRABIG", ScrW() / 2, ScrH() / 6, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
	end
end

SNAKE_GAME = BLINDGAMES.addGame("Snake", GAME);
