--[[==============]]--
--[[GENERAL CONFIG]]--
--[[==============]]--


--If the player needs admin privileges to ajust bone scale.
PLAYERNEEDSADMIN_BONE		= true --true/false

--If the player needs admin privileges to set "Midget" mode.
PLAYERNEEDSADMIN_MIDGET		= false --true/false

--If the player needs admin privileges to set "Special Midget" mode
PLAYERNEEDSADMIN_SPECIAL 	= true --true/false

--Enable help messages.
ENABLEMESSAGES 				= false --true/false

--Enable "Special Midget" mode.
--(This mode can sometimes be glitchy so you may want no one to be able to use it)
ALLOWSPECIALMIDGET 			= true --true/false

--Force certain bone size. (bones can be added in the psm_init.lua)
FORCEBONE 					= false --true/false

--Maximum size you can set bones to.
MAXBONESIZE 				= 4 --Makes a limit for people adjusting bones.

--Minimum size you can set bones to.
MINBONESIZE		 			= 1 --Makes a limit for people adjusting bones.

--How frequently help messages are sent.
MESSAGEINTERVAL 			= 20 --Sets the message frequency.

--Add a group that you want to give special permission to all addon functions.
ALLOWEDGROUP 				= { "donators" } --Name of your allowed group.

--What team the help messages will say can use the addon's features.
TEAMDISPLAY 				= "Hunters/Seekers" --Name of allowed team.

--What mode to set you when you spawn.
FORCESPAWNMODE				= "None" --"None"/"Midget"/"SpecialMidget"

--Teams that can use this addon's features.
ALLOWEDTEAMS 				= { 2 } --Allowed team ID (only numbers). (1 Hunters (PH), 2 Hunters (ObjHunt), 2 Hiders (HNS), 1001 (Sandbox default team {all players}))

--Teams that don't spawn with bones (e.g. the spectator's team since they have no body).
SPECTATORTEAM 				= { 3 } --Disallowed team ID.

--Whether or not you want the players view to change with his size.
CHANGEVIEW					= true --true/false

--Whether or not you want the players physical height to change with his size.
ALLOWSHORTHULL				= true --true/false (This can cause you to get stuck more often).

--How big the midget should be.
MIDGETSIZE 					= 0.5 --If you change this, you may want to go into psm_utils.lua to modify the player's hull.

--How big the special midget should be.
SPECIALMIDGETSIZE 			= 0.8 --If you change this, you may want to go into psm_utils.lua to modify the player's hull.