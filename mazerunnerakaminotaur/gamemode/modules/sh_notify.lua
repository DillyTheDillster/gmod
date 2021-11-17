if(SERVER) then
	util.AddNetworkString("Notify")

	local meta = FindMetaTable("Player")

	local function notify(text, notiftype, length)
		text = text || ""
		notiftype = notiftype || 0
		length = length || 3

		net.WriteString(text)
		net.WriteInt(notiftype, 8)
		net.WriteInt(length, 8)
	end

	function meta:Notify(text, notiftype, length)
		net.Start("Notify")
			notify(text, notiftype, length)
		net.Send(self)
	end

	function GM:Notify(text, tbl, type, length)
		net.Start("Notify")
			notify(text, notiftype, length)
		if(tbl) then net.Send(tbl) else net.Broadcast() end
	end
else
	net.Receive("Notify", function()
		surface.PlaySound("ui/buttonclick.wav")
		notification.AddLegacy(net.ReadString(), net.ReadInt(8), net.ReadInt(8))
	end)
end