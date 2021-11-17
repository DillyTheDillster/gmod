if SERVER then
	hook.Add("PlayerLevelUp", "leveling:PlayerLevelUp", function(ply)
		if ply:Alive() then ply:EmitSound("leveling/levelup.wav", 500, 120) end
	end)
end