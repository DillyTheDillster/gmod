MINIGAMES:RegisterMinigame('Snake')

local GAMESTATE = {
    STARTING = 1,
    PAUSED = 2,
    PLAYING = 3,
}

snake = snake || {
    score = 0,
    topscore = 0,
    topPlayer = '',
    speed = 200,
    squarew = 15,
    state = GAMESTATE.STARTING,
    lastState = CurTime(),
    text = '',
    egg = {
        x = math.Round(math.random(20,ScrW()-20)),
        y = math.Round(math.random(20,ScrH()-ScrH()*0.125))
    },
    snake =  {
        headx = ScrW()/2,
        heady = ScrH()/2,
        dirx = 0,
        diry = 0,
        length = 0,
        tail = {}
    }
}

function snake:Restart()
    if self.score > 0 then
        self.text = 'You died! Final score: ' .. self.score .. '!'
    end
    self.speed = 200
    self.score = 0
    self.snake = {
        headx = ScrW()/2,
        heady = ScrH()/2,
        dirx = 0,
        diry = 0,
        length = 0,
        tail = {}
    }
    self:MoveEgg()
    self.state = GAMESTATE.STARTING
    self.lastState = CurTime()
end

function snake:MoveEgg()
    self.egg.x = math.Round(math.random(20,ScrW()-20))
    self.egg.y = math.Round(math.random(20,ScrH()-ScrH()*0.125))
end

function snake:Eat()
    self.snake.length = self.snake.length + self.squarew -- lol
    self:MoveEgg()
    self.speed = math.min(self.speed * 1.02, 600) -- 300 at ~20 eggs, 400 at ~35, 500 at 45-50, 600 at ~55; perhaps linear would be better?
    self.score = self.score + math.Round(self.speed/150) -- 1 until 225, 2 until 375, 3 until 525, etc.
    net.Start('Snakescore')
		net.WriteTable({self.score});
	net.SendToServer();
end

function snake:Update()
    -- Check movement changes
    local up, down, left, right =
          input.IsKeyDown(KEY_UP) || input.IsKeyDown(KEY_W),
          input.IsKeyDown(KEY_DOWN) || input.IsKeyDown(KEY_S),
          input.IsKeyDown(KEY_LEFT) || input.IsKeyDown(KEY_A),
          input.IsKeyDown(KEY_RIGHT) || input.IsKeyDown(KEY_D)
	
    if (up || down) && (self.snake.diry == 0) then
        self.snake.diry = (up) && -1 || 1
        self.snake.dirx = 0
    elseif (left || right) && (self.snake.dirx == 0) then
        self.snake.dirx = (left) && -1 || 1
        self.snake.diry = 0
    end

    -- Update tail
    table.insert(self.snake.tail, 1, {x = self.snake.headx, y = self.snake.heady})
    if #self.snake.tail > self.snake.length then
        table.remove(self.snake.tail, #self.snake.tail)
    end

    -- Update snake pos
    local changex = self.snake.dirx * self.speed * FrameTime()
    local changey = self.snake.diry * self.speed * FrameTime()

    self.snake.headx = self.snake.headx + changex
    self.snake.heady = self.snake.heady + changey

    -- Check if snake is outside the window
    if (self.snake.headx <= 0) || (self.snake.heady <= 0) || (self.snake.heady + self.squarew >= ScrH()) || (self.snake.headx + self.squarew >= ScrW()) then
        self:Restart()
    end

    -- Check if snake is eating the egg
    if (self.egg.x <= self.snake.headx + self.squarew) && (self.snake.headx <= self.egg.x + self.squarew) && (self.egg.y <= self.snake.heady + self.squarew) && (self.snake.heady <= self.egg.y + self.squarew) then
        self:Eat()
    end
end

function snake:Draw()
    local col = math.abs(math.sin(CurTime() * 2.5))

    if self.state == GAMESTATE.PLAYING then
        self:Update()
    end

    --Draw Background
    surface.SetDrawColor(0, 0, 0)
    surface.DrawRect(0, 0, ScrW(), ScrH())

    -- Draw egg
    surface.SetDrawColor(120 + (135 * col), 50, 0, 255)
    surface.DrawRect(self.egg.x, self.egg.y, self.squarew, self.squarew)

    -- Draw tail
    surface.SetDrawColor(255,255,255)
    for i = 1, #self.snake.tail do
        local tile = self.snake.tail[i]
        if not tile then break end
        surface.DrawRect(tile.x, tile.y, self.squarew, self.squarew)
        if (i > self.squarew*3) && (tile.x >= self.snake.headx) && (tile.x <= self.snake.headx + self.squarew) && (tile.y >= self.snake.heady) && (tile.y <= self.snake.heady + self.squarew) then -- trust me
            self:Restart()
        end
    end

    -- Draw snake
    surface.SetDrawColor(255,255,255)
    surface.DrawRect(self.snake.headx, self.snake.heady, self.squarew, self.squarew)

    -- Draw score
    surface.SetTextColor(255,255,255,140)
    local text = 'score: ' .. self.score
    surface.SetFont('LPS40')
    local w, h = surface.GetTextSize(text)
    surface.SetTextPos(ScrW() * 0.1 - w, ScrH() * 0.05)
    surface.DrawText(text)

    local text = 'Top score: ' .. (self.topPlayer || 'Nobody') .. ' ' .. (self.topscore || '0')
    local w, h = surface.GetTextSize(text)
    surface.SetTextPos(ScrW() * 0.95 - w, ScrH() * 0.05)
    surface.DrawText(text)

    if (self.state == GAMESTATE.PAUSED) then
        surface.SetTextColor(Color(255,255,255,100))
        local text = 'PAUSED'
        surface.SetFont('LPS80')
        local w, h = surface.GetTextSize(text)
        surface.SetTextPos((ScrW()/2) - (w/2), (ScrH()/2) - (h/2))
        surface.DrawText(text)

        surface.SetTextColor(Color(255,255,255, (255 * col)))
        local text = 'Press [SPACE] to resume!'
        surface.SetFont('LPS40')
        local w, h = surface.GetTextSize(text)
        surface.SetTextPos(ScrW()/2 - w/2, ScrH() - (h + 100))
        surface.DrawText(text)
    elseif (self.state == GAMESTATE.STARTING) then
        surface.SetTextColor(Color(255,255,255, (255 * col)))
        local text = 'Press [SPACE] to Start!'
        surface.SetFont('LPS40')
        local w, h = surface.GetTextSize(text)
        surface.SetTextPos(ScrW()/2 - w/2, ScrH() - (h + 100))
        surface.DrawText(text)
    end

    if ((self.lastState + .3) < CurTime()) && (self.state == GAMESTATE.STARTING || self.state == GAMESTATE.PAUSED) && input.IsKeyDown(KEY_SPACE) then
        self.state = GAMESTATE.PLAYING
        self.lastState = CurTime()
    elseif ((self.lastState + .3) < CurTime()) && (self.state == GAMESTATE.PLAYING) && input.IsKeyDown(KEY_SPACE) then
        self.state = GAMESTATE.PAUSED
        self.lastState = CurTime()
    end
end

net.Receive('SnakeTopscore', function()
	local data = net.ReadTable();
	snake.topPlayer = (data && data[1]) || "";
    snake.topscore = (data && data[2]) || "";
end)

hook.Add('MinigameDraw', 'MinigameDraw:Snake', function(ply, minigame)
	if (minigame ~= 'Snake') then return end
    snake:Draw()
end)

hook.Add('MinigameEndDraw', 'MinigameEndDraw:Snake', function(ply, minigame)
    if (minigame ~= 'Snake') then return end
    if(snake.state == GAMESTATE.PLAYING) then
        snake.state = GAMESTATE.PAUSED
    end
end)