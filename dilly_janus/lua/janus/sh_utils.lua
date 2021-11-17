--[[
	Name: sv_utils.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

Janus.Utils = Janus.Utils or {}

function Janus.Utils:DeepCopy( object )
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function Janus.Utils:PerksShouldRemove( name, tblPerks )
	for _, v in pairs( tblPerks ) do
		if name == v.Name then return false end
	end
	return true
end

function Janus.Utils:GetAllDetectives(alive_only)
	local tbl = {}
	
	for k, v in pairs(player.GetAll()) do
		if v:GetRole() == ROLE_DETECTIVE then
			if not alive_only then
				table.insert(tbl,v)
			else
				if v:Alive() then
					table.insert(tbl,v)
				end
			end
		end
	end
	
	return tbl 
end

function Janus.Utils:GetAllInnoocents(alive_only)
	local tbl = {}
	
	for k, v in pairs(player.GetAll()) do
		if v:GetRole() == ROLE_INNOCENT then
			if not alive_only then
				table.insert(tbl,v)
			else
				if v:Alive() then
					table.insert(tbl,v)
				end
			end
		end
	end
	
	return tbl 
end

function Janus.Utils:GetAllTraitors(alive_only)
	local tbl = {}
	
	for k, v in pairs(player.GetAll()) do
		if v:GetRole() == ROLE_TRAITOR then
			if not alive_only then
				table.insert(tbl,v)
			else
				if v:Alive() then
					table.insert(tbl,v)
				end
			end
		end
	end
	
	return tbl 
end

function Janus.Utils:IsPlayingTTT()
	if TEAM_TERROR != nil then
		return true
	end
	
	return false
end

function Janus.Utils:GetNiceNum(num)
	if tonumber(num) >= 1000 then
		num = math.Round(num/1000) .. "K"
	elseif tonumber(num) >= 1000000 then
		num = math.Round(num/1000000) .. "M"
	end
	
	return num
end