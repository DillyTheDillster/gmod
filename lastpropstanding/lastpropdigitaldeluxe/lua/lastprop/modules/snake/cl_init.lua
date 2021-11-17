--ripped and modified from https://github.com/glua/gmod-menu-plugins/blob/master/lua/menu_plugins/default/snake.lua, repo states its under MIT

local GAMESTATE = {
    STARTING = 1,
    PAUSED = 2,
    PLAYING = 3,
}

snake = snake or {
    score = 0,
    topScore = 0,
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
    lps.net.Start('SnakeScore', {self.score})
end

function snake:Update()
    -- Check movement changes
    local up, down, left, right =
          input.IsKeyDown(KEY_UP) or input.IsKeyDown(KEY_W),
          input.IsKeyDown(KEY_DOWN) or input.IsKeyDown(KEY_S),
          input.IsKeyDown(KEY_LEFT) or input.IsKeyDown(KEY_A),
          input.IsKeyDown(KEY_RIGHT) or input.IsKeyDown(KEY_D)

    if (up or down) and (self.snake.diry == 0) then
        self.snake.diry = (up) and -1 or 1
        self.snake.dirx = 0
    elseif (left or right) and (self.snake.dirx == 0) then
        self.snake.dirx = (left) and -1 or 1
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
    if (self.snake.headx <= 0) or (self.snake.heady <= 0) or (self.snake.heady + self.squarew >= ScrH()) or (self.snake.headx + self.squarew >= ScrW()) then
        self:Restart()
    end

    -- Check if snake is eating the egg
    if (self.egg.x <= self.snake.headx + self.squarew) and (self.snake.headx <= self.egg.x + self.squarew) and (self.egg.y <= self.snake.heady + self.squarew) and (self.snake.heady <= self.egg.y + self.squarew) then
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
        if (i > self.squarew*3) and (tile.x >= self.snake.headx) and (tile.x <= self.snake.headx + self.squarew) and (tile.y >= self.snake.heady) and (tile.y <= self.snake.heady + self.squarew) then -- trust me
            self:Restart()
        end
    end

    -- Draw snake
    surface.SetDrawColor(255,255,255)
    surface.DrawRect(self.snake.headx, self.snake.heady, self.squarew, self.squarew)

    -- Draw score
    surface.SetTextColor(255,255,255,140)
    local text = 'Score: ' .. self.score
    surface.SetFont('LPS40')
    local w, h = surface.GetTextSize(text)
    surface.SetTextPos(ScrW() * 0.1 - w, ScrH() * 0.05)
    surface.DrawText(text)

    local text = 'Top Score: ' .. (self.topPlayer or 'Nobody') .. ' ' .. (self.topScore or '0')
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

    if ((self.lastState + .3) < CurTime()) and (self.state == GAMESTATE.STARTING or self.state == GAMESTATE.PAUSED) and input.IsKeyDown(KEY_SPACE) then
        self.state = GAMESTATE.PLAYING
        self.lastState = CurTime()
    elseif ((self.lastState + .3) < CurTime()) and (self.state == GAMESTATE.PLAYING) and input.IsKeyDown(KEY_SPACE) then
        self.state = GAMESTATE.PAUSED
        self.lastState = CurTime()
    end
end

lps.net.Hook('SnakeTopScore', function(data)
    snake.topPlayer = data[1]
    snake.topScore = data[2]
end)

hook.Add('Initialize', 'Initialize:Snake', function(ply, minigame)
    GAMEMODE:RegisterMinigame('Snake')
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