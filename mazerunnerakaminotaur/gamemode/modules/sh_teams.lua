for k, v in pairs(MR_CONFIG.TeamSetup) do
	team.SetUp(k-1, v.name, v.color)
end

if(CLIENT) then return end

local meta = FindMetaTable("Player")

local function shuffleTable(t)
    local rand = math.random
    assert(t, "shuffleTable() expected a table, got nil")
    local iterations = #t
    local j

    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

function GM:SetupTeams()
	local plys = player.GetAll()
	shuffleTable(plys)

	local amt = #plys <= 10 && 1 || 2

	for i = 1, amt do
		local minotaur = table.remove(plys, math.random(1, #plys))
		if(!minotaur) then continue end
		minotaur:SetTeam(0)
		minotaur:SetLives(minotaur:GetConfigTable().lives)
		minotaur:Spawn()
		print("m", minotaur)
	end

	for k, v in pairs(plys) do
		v:SetTeam(1)
		v:SetLives(v:GetConfigTable().lives)
		v:Spawn()
		print("r", v)
	end
end

function GM:Spectatorify(ply)
	if(ply && !istable(ply)) then ply = {ply} end

	for k, v in pairs(ply || player.GetAll()) do
		v:SetTeam(2)
		v:Spawn()

		v:StripWeapons()
		v:StripAmmo()
	end
end
