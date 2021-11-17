STATE_INPROGRESS = 0
STATE_COOLDOWN = 1
STATE_LOBBY = 2

function GM:SetRoundState(state)
	SetGlobalInt("RoundState", state)
end

function GM:GetRoundState()
	return GetGlobalInt("RoundState")
end

if(CLIENT) then
	function GM:RoundBegun()
		chat.AddText("Round Begin")
	end

	function GM:RoundEnded()
		chat.AddText("Round End")
	end

	function GM:RoundLobby()
		chat.AddText("Round Lobby")
	end

	net.Receive("RoundBegun", GM.RoundBegun)
	net.Receive("RoundEnded", GM.RoundEnded)
	net.Receive("RoundLobby", GM.RoundLobby)

	return
end

util.AddNetworkString("RoundBegun")
util.AddNetworkString("RoundEnded")
util.AddNetworkString("RoundLobby")

local cdDuration = MR_CONFIG.RoundCooldown

function GM:StartRound()
	game.CleanUpMap()

	self:SetRoundState(STATE_INPROGRESS)
	self:SetupTeams()

	net.Start("RoundBegun")
	net.Broadcast()
end

function GM:EndRound()
	game.CleanUpMap()

	self:SetRoundState(STATE_COOLDOWN)
	self:Spectatorify()

	net.Start("RoundEnded")
	net.Broadcast()
end

function GM:Lobby()
	if(self:GetRoundState() == STATE_INPROGRESS) then
		self:EndRound()
	end

	self:SetRoundState(STATE_LOBBY)

	net.Start("RoundLobby")
	net.Broadcast()
end

GM:Lobby()

local cd = CurTime()
function GM:Tick()
	local state = self:GetRoundState()

	if(state == STATE_LOBBY && CurTime() > cd) then
		if(#player.GetAll() < MR_CONFIG.MinPlayers) then
			self:Notify("Not enough players to start the round!")
			cd = CurTime() + 8
		else
			self:StartRound()
			cd = CurTime()
		end
	end

	if(state == STATE_INPROGRESS && CurTime() > cd) then
		cd = CurTime() + 0.5

		local minotaurs = team.GetPlayers(0)
		local runners = team.GetPlayers(1)

		local m = 0
		for k, v in pairs(minotaurs) do
			m = m + v:GetLives()
		end

		local r = 0
		for k, v in pairs(runners) do
			r = r + v:GetLives()
		end

		if(m == 0 || r == 0) then
			if(m == 0) then self:RunnersWin()
			elseif(r == 0) then self:MinotaursWin() end

			self:EndRound()
			cd = CurTime() + cdDuration
		end
	end

	if(state == STATE_COOLDOWN && CurTime() > cd) then
		self:Lobby()
	end
end

function GM:RunnersWin()
	print("Runners Win")
end

function GM:MinotaursWin()
	print("Minotaurs Win")
end