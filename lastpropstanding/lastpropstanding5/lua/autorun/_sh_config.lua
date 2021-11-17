LastProp = LastProp or {}

function LastProp:LoadConfig()
	hook.Remove("Think", "LastProp_LoadConfig")
	
	LastProp.Config = {}
	LastProp.Config.PossibleGuns = { -- Guns that you can get
		--[["m9k_deagle",
		"ptp_tridagger",
		"m9k_browningauto5",
		"m9k_remington1858",
		"m9k_damascus",
		"m9k_machete",
		"m9k_intervention",]]
		"weapon_357",
		"weapon_smg1",
		"weapon_crowbar",
		"weapon_shotgun",
		"weapon_pistol",
	}
	LastProp.Config.AmmoType = { -- Ammo type for guns to have more ammo
		--["m9k_browningauto5"] = "Buckshot",
		--["m9k_remington1858"] = "357",
		--["m9k_deagle"] = "357",
		["weapon_357"] = "357",
		["weapon_shotgun"] = "Buckshot",
		["weapon_smg1"] = "SMG1",
		["weapon_pistol"] = "Pistol",
	}
	LastProp.Config.ChangeToFirstPerson = true -- When you get gun, change to first person?
	LastProp.Config.RewardFunc = function(ply)
		ply:PS2_AddStandardPoints(100, "Award for killing a hunter!", false) -- (AMOUNT, MESSAGE, SMALL MESSAGE)
	end
	LastProp.Config.RewardFunc2 = function(ply)
		ply:PS2_AddStandardPoints(100, "Award for killing the last prop!", false) -- (AMOUNT, MESSAGE, SMALL MESSAGE)
	end
end
hook.Add("Think", "LastProp_LoadConfig", LastProp.LoadConfig)
