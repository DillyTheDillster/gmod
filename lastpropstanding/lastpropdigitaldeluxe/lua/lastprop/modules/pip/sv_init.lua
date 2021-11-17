pip = pip or {}

function pip:GetTargets(ply)
    local targets = {}
    for _, prop in pairs(player.GetAll()) do
        if (prop:Alive()) and (prop:Team() == TEAM.PROPS) and (prop ~= ply) then
            table.insert(targets, prop)
        end
    end
    return targets
end

function pip:GetNextTarget(ply)
    local ent = ply:GetNWEntity('pip', nil)
    local targets = self:GetTargets(ply)
    if (table.Count(targets) > 0) then
        return table.FindNext(targets, ent)
    end
end

function pip:GetPrevTarget(ply)
    local ent = ply:GetNWEntity('pip', nil)
    local targets = self:GetTargets(ply)
    if (table.Count(targets) > 0) then
        return table.FindPrev(targets, ent)
    end
end

-- Ensure pip ent is always in the player's PVS.
hook.Add('SetupPlayerVisibility', 'PIP:SetupPlayerVisibility', function(ply)
    local ent = ply:GetNWEntity('pip', nil)
    if (IsValid(ent)) then
        AddOriginToPVS(ent:GetPos())
    end
end)

hook.Add('PlayerDeath', 'PIP:PlayerDeath', function(ply)
    local ent = ply:GetNWEntity('pip', nil)
    if (IsValid(ent)) then
        ply:SetNWEntity('pip', ply)
    end

    for _, prop in pairs(player.GetAll()) do
        if (prop:GetNWEntity('pip', nil) == ply) then
            local target = pip:GetNextTarget(prop)
            if (IsValid(target)) then
                prop:SetNWEntity('pip', target)
            end
        end
    end
end)

concommand.Add('lps_pipnext', function(ply, cmd, args, str)
    local target = pip:GetNextTarget(ply)
    if (IsValid(target)) then
        ply:SetNWEntity('pip', target)
    end
end)

concommand.Add('lps_pipprev', function(ply, cmd, args, str)
    local target = pip:GetPrevTarget(ply)
    if (IsValid(target)) then
        ply:SetNWEntity('pip', target)
    end
end)

concommand.Add('lps_piptoggle', function(ply, cmd, args, str)
    local target = ply:GetNWEntity('pip', nil)
    if (not IsValid(target) or target == ply) then
        local newTarget = pip:GetNextTarget(ply)
        if (IsValid(newTarget)) then
            ply:SetNWEntity('pip', newTarget)
        end
    else
        ply:SetNWEntity('pip', ply)
    end
end)
