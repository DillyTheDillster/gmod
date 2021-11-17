local Achievement = {}
Achievement.UID = "achex" -- UID, must be unique.
Achievement.PrintName = "Example Achievement" -- Print Name, this is displayed on the menu and such.
Achievement.Description = "Just a simple achievement."
Achievement.Icon = "materials/janus/ach_icons/ach_missing.png" -- Image to represent it
Achievement.Cat = "General" -- Category to place the achievement in
Achievement.Reward = 100 -- File name of pointshop item to give, change to a number to give points/money instead
Achievement.RewardName = "Example reward ($100)" -- Name of the reward you want displayed on the menu
Achievement.UseDarkRPMoneyAsReward = true -- Should players get RP money instead of pointshop points/items?
Achievement.Pointshop2_Prem = false -- Should players get premium PS points instead of normal points?
Achievement.AmountRequired = 1 -- How many times a player must do said task to get the achievement.

hook.Add("PlayerSpawn", "Janus_achex", function(pPlayer)
    Janus.Achievements:AddAchievementProgress( pPlayer, Achievement.UID, 1)
end)

Janus.Achievements:RegisterAchievement(Achievement)