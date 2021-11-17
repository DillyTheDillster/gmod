if (SERVER) then

	util.AddNetworkString("StartHelp")

	hook.Add("PlayerInitialSpawn", "SendHelp", function(ply)

		net.Start("StartHelp")
		net.Send(ply)

	end)

end