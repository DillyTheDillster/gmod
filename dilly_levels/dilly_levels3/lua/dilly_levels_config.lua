-- console commands
-- set_player_level name lvl

-- BACKEND STUFF --

_DILLY.CONFIG.levelCap 							= 100 -- false for no level cap

_DILLY.CONFIG.timeIntervalExperienceReward		= 5 -- in seconds how often a player should be rewarded experience for playing continuosly
_DILLY.CONFIG.experienceRewardForTime			= 50 -- Amount of experience rewarded for however often the timer interval is set to

_DILLY.CONFIG.experiencePerKill					= 50 -- Amount of experience rewarded

_DILLY.CONFIG.experienceRequiredPerLevel = {
	["1-10"]									= 1000,
	["11-20"]									= 1500,
	["21-30"]									= 2000,
	["31-40"]									= 2500,
	["41-50"]									= 3000,
	["51-60"]									= 3500,
	["61-70"]									= 4000,
	["71-80"]									= 4500,
	["81-90"]									= 5000,
	["91-100"]									= 5500,
	["101+"]									= false -- set to number if there is no level cap
}

-- Add or remove chat commands to open the level leaderboard
_DILLY.CONFIG.chatMessage = {
	["!level"]									= true,
	["!lvl"]									= true,
	["!experience"]								= true,
	["!exp"]									= true,
	["/level"]									= true,
	["/lvl"]									= true,
	["/experience"]								= true,
	["/exp"]									= true
}

-- HUD STUFF --

-- RBG color code generator
-- http://www.rapidtables.com/web/color/RGB_Color.htm
_DILLY.CONFIG.xpBarOutline						= Color(40, 40, 40)
_DILLY.CONFIG.xpBarBackground					= Color(180, 180, 180)
_DILLY.CONFIG.xpBarUnfilled						= Color(90, 90, 90)
_DILLY.CONFIG.xpBarFilled						= Color(135, 135, 135)

_DILLY.CONFIG.topOrBottom						= 1 -- 0 for top, 1 for bottom
_DILLY.CONFIG.padding							= 15 -- how many pixels off the edge of screen