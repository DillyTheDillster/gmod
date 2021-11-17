--[[
	Name: sh_config.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

DEV_SERVER = true

Janus.Config = Janus.Config or {}

Janus.Config.ADDON_PATH = "janus/"

--[[ HUD Config ]]--
Janus.Config.EnableHUD = true // Is the HUD enabled?

--[[ HUD Colors ]]--
Janus.Config.LevelColor = Color(255,255,255,255) // The color of the "Level: 1" HUD element. White looks best.
Janus.Config.XPTextColor = Color(255,255,255,255) // The color of the XP percentage HUD element.
Janus.Config.LevelBarColor = {230,161,14} // The color of the XP bar.
Janus.Config.PerksMenuColor1 = {82,85,100} // The background color of the perks menu
Janus.Config.PerksMenuColor2 = {116,130,143} // The secondary color of the perks menu
Janus.Config.PerksBoxColor1 = {190,185,181} // The color of the main box that holds the perk information
Janus.Config.PerksBoxColor2 = {194,91,86} // The color of the secondary boxes that hold the perk information

--[[ Leveling Config ]]--
Janus.Config.XPMult = 1 // How hard it is to level up. 2 would require twice as much XP, ect. NOTE: XP formula already sets the required XP exponentialy: (10+((currLevel)*((currLevel)+1)*90))*XPMult
Janus.Config.MaxLevel = 99 // The max level
Janus.Config.MaxPerks = 10 // The max ammount of active perks
Janus.Config.ContinueXP = false // If remaining XP continues over to next levels. I recommend this to be false. Seriously.
Janus.Config.ShowPlayerLevel = true // Show other player's level above their heads
Janus.Config.AlwaysShowPlayerLevel = false // Show other player's level regardless of weather we're looking at them or not

--[[ Achievements Config ]]--
Janus.Config.Pointshop = false -- Should we use pointshop rewards?
Janus.Config.Pointshop2 = true -- Are we using pointshop 2 (If false we'll attempt to use PS 1)?
Janus.Config.DefaultIcon = "materials/janus/ach_icons/ach_missing.png" -- Path to the default icon we should use
Janus.Config.DisplayCompletion = true -- Should we display a card when the user completes an achievement?
Janus.Config.SlideInTime = 1 -- Time it takes for the completed achievement card to slide in
Janus.Config.StayTime = 5 -- Time the completed achievement card stays on the HUD
Janus.Config.SlideOutTime = 1 -- Time it takes for the completed achievement card to slide out