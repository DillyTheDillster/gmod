MR_CONFIG = MR_CONFIG || {}
local cfg = MR_CONFIG
//--------------------------------

//First one will always be minotaur, second one will always be runner
cfg.TeamSetup = {
	{
		name = "Minotaur",
		color = Color(231, 76, 60),
		model = "models/player/breen.mdl",
		lives = 1,
		walkspeed = 100,
		runspeed = 200,
		health = 1000,
		armor = 1000,
		weps = {
			"cw_ar15"
		},
		ammo = {
			["5.56x45MM"] = 90
		}
	},
	{
		name = "Runner",
		color = Color(52, 152, 219),
		model = "models/player/barney.mdl",
		lives = 10,
		walkspeed = 200,
		runspeed = 300,
		health = 100,
		armor = 100,
		weps = {
			"cw_ar15"
		},
		ammo = {
			["5.56x45MM"] = 900
		}
	},
	{
		name = "Spectator",
		color = Color(255, 255, 255, 255),
		model = "models/player/p2_chell.mdl",
		walkspeed = 300,
		runspeed = 300,
		health = 100,
		armor = 100,
		weps = {},
		ammo = {}
	}
}

//Amount of seconds someone is unable to respawn for
cfg.RespawnTime = 5

//Minimum amount of players required for round to start
cfg.MinPlayers = 2

//Seconds to lobby in between rounds
cfg.RoundCooldown = 5

cfg.FlashlightTime = 15 //seconds
cfg.FlashlightRegenFactor = 5 //how many times over you need the flashlighttime to pass for it to fully regen

cfg.CanSuicide = true //Can players kill themselves?

cfg.HaloDistance = 1000 //source engine units to start drawing minotaur outlines at

cfg.MinotaurMovesound = "ui/buttonclick.wav"