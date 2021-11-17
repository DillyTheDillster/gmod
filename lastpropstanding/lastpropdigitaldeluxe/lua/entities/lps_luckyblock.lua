if (SERVER) then
    AddCSLuaFile()
    sound.Add({
        name = "luckyblock_loop",
        channel = CHAN_ITEM,
        volume = 0.1,
        level = 80,
        sound = "entities/luckyblock/loop.wav"
    })

    sound.Add({
        name = "luckyblock_activate",
        channel = CHAN_ITEM,
        volume = 1.0,
        level = 80,
        sound = "entities/luckyblock/activate.wav"
    })

    sound.Add({
        name = "luckyblock_dance",
        channel = CHAN_ITEM,
        volume = 1.0,
        level = 80,
        sound = "entities/luckyblock/dance.mp3"
    })
end

ENT.Type      = "anim"
ENT.Base      = "base_anim"
ENT.Author	  = "Nerdism"
ENT.Category  = "LPS"
ENT.RenderGroup	= RENDERGROUP_BOTH
ENT.Spawnable = true

if (SERVER) then

    function ENT:Initialize()
        self:SetModel('models/hunter/blocks/cube05x05x05.mdl')
        self:SetMaterial('entities/luckyblock')
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WORLD)

        self:SetUseType(SIMPLE_USE)

        self:SetColor(Color(255, 255, 255, 253))
        self:SetRenderMode(RENDERMODE_TRANSALPHA)

        self:SetNWInt('luck', math.floor(math.Rand(-100, 100)))

        self.sound = CreateSound(self, 'luckyblock_loop',RecipientFilter():AddAllPlayers())
        self.sound:Play()
    end

    local texts = {
        "Congrats, you just won the Internet!",
        "My vision is augmented.",
        "Trolling is \'A\' Art",
        "Unicorn produce rainbows you know... with 20% cooler.",
        "You know what's better than Lamborghini? K.N.O.W.L.E.D.G.E",
        "0813-6928",
        "SHUT UP NURSE!!",
        "A fish with a cone hat.",
        "A blueberry wolfy hangs around.",
        "He once used this \'gamemode\', then never again.",
        "The blueberry wolfy tried to swim in lava when mining a diamond.",
        "Uncharted: The Game within The Game.",
        "Look, Ma! I said look! Top of the world... again!",
        "He always, stays patiently over 400 years to make a changes.",
        "John Freeman whose Gordon Freeman\'s Brother!",
        "John Freeman looked underground and found WEPONS!",
        "When you go to space, there is a hiding crystal inside a \'box\'.",
        "It\'s so fancy! even people didn\'t find 5 buttons and 2 Doritos!",
        "What a shame.",
        "PILLS HERE!",
        ":3",
        "Here's some text to occupy you.",
        "Have you seen the NannerMan?",
        "I once saw a man with green septic eyes.",
        "I once saw a man with a pink mustache.",
        "There was Obsidian and it had a Conflict.",
        "We all just need a bit of Synergy in our lives.",
        "sudo apt-get moo",
        "\"Have you mooed today?\"",
        "Someone could do well on the stage, we just need to find him.",
        "So much to do, so little time.",
        "You don't realise that (nearly) all those were actually easter eggs? :P"
    }

    function ENT:DoLuck(ply, func)
        self:EmitSound('luckyblock_activate')
        if (not func) then
            ply:ChatPrint("[Lucky Block] Nothing Happend!")
        else
            local text = func(self, ply)
            if (type(text) == 'string') then
                ply:ChatPrint(string.format('[Lucky Block] %s', text))
            elseif (text == false) then
                ply:ChatPrint(string.format('[Lucky Block] %s', table.Random(texts)))
            else
                ply:ChatPrint("[Lucky Block] Nothing Happend!")
            end
        end
        self:Remove()
    end

    function ENT:Use(ply)
        if (ply:Alive()) then
            local luck = self:GetNWInt('luck', 0)
            local items = list.Get('LuckyBlock')
            if (table.Count(items) > 0) then
                local funcs = {}
                for _, item in pairs(items) do
                    if (luck > 0 and item[1] > 0 and  luck < item[1]) or (luck < 0 and item[1] < 0 and luck > item[1]) then
                        table.insert(funcs, item[2])
                    end
                end
                self:DoLuck(ply, table.Random(funcs))
            else
                print('No lucky block functions!')
                self:DoLuck(ply)
            end
        end
	end

    function ENT:OnRemove()
        self.sound:Stop()
    end
else
    function ENT:Initialize()
        self.emitter = ParticleEmitter(self:GetPos())
    end

    function ENT:OnRemove()
        self.emitter:Finish()
    end

    local nextEmit = CurTime()
    function ENT:Think()
        local dlight = DynamicLight( self:EntIndex() )
		if (dlight) then
			local c = HSVToColor(math.abs(math.sin(0.5 * RealTime()) * 128), 1, 1)
            local size = 512
            local brightness = 2
			dlight.Pos = self:GetPos()
			dlight.r = c.r
			dlight.g = c.g
			dlight.b = c.b
			dlight.Brightness = brightness
			dlight.Decay = size * 5
			dlight.Size = size
			dlight.DieTime = CurTime() + 1
		end

        if (self.emitter and nextEmit <  CurTime()) then
            self.emitter:SetPos(self:GetPos())
            local part = self.emitter:Add('effects/spark', self:GetPos() + VectorRand())
            part:SetAirResistance(100)
            part:SetBounce(0.3)
            part:SetCollide(true)
            part:SetColor(math.random(10, 250), math.random(10, 250), math.random(10, 250), 255)
            part:SetDieTime(1)
            part:SetEndAlpha(0)
            part:SetEndSize(0)
            part:SetGravity(Vector(0, 0, -250))
            part:SetRoll(math.Rand(0, 360))
            part:SetRollDelta(math.Rand(-7,7))
            part:SetStartAlpha(math.Rand(80, 250))
            part:SetStartSize(math.Rand(6, 12))
            part:SetVelocity(VectorRand() * 75)
            nextEmit = CurTime() + 0.01
        end
    end
    function ENT:DrawTranslucent()
        self:DrawModel()
        self:SetAngles(Angle(0, (RealTime() * 360) * 0.2, 0))
    end
end

