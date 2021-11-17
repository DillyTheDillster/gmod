timer.Create('IdleTimer', 60, 0, function()
    lps.net.Start(nil, 'CheckIdle')
end)

local config = {
    spectator = 300, -- Time is seconds to move player to TEAM.SPECTATORS
    kick = 900 -- Time in seconds to kick player, set to 0 to disable.
}

lps.net.Hook('PlayerIdle', function(ply, data)
    if (ply:IsAdmin() or ply:IsSuperAdmin()) then return end
    if (data > config.spectator and table.HasValue({TEAM.HUNTERS, TEAM.PROPS}, ply:Team())) then
        ply:SetTeam(TEAM.SPECTATORS)
        GAMEMODE:PlayerSpawnAsSpectator(ply)
        util.Notify(ply, 'You\'ve been moved to spectators for being idle to long.')
    end
    if (config.kick > 0 and data > config.kick and ply:IsSpec()) then
        util.Notify(nil, ply:Nick() .. ' has been kicked for being idle to long.')
        ply:Kick('You\'ve been kicked for being idle to long')
    end
end)

