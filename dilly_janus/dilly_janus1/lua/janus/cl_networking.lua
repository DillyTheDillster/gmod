--[[
	Name: cl_networking.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

Janus.Net = Janus.Net or {}
Janus.Net.m_bVerbose = false
Janus.Net.m_tblProtocols = Janus.Net.m_tblProtocols or { Names = {}, IDs = {} }
Janus.Net.m_tblVarLookup = {
	Write = {
		["UInt4"] = { func = net.WriteUInt, size = 4 },
		["UInt8"] = { func = net.WriteUInt, size = 8 },
		["UInt16"] = { func = net.WriteUInt, size = 16 },
		["UInt32"] = { func = net.WriteUInt, size = 32 },
		["Int4"] = { func = net.WriteInt, size = 4 },
		["Int8"] = { func = net.WriteInt, size = 8 },
		["Int16"] = { func = net.WriteInt, size = 16 },
		["Int32"] = { func = net.WriteInt, size = 32 },
		["Angle"] = { func = net.WriteAngle },
		["Bit"] = { func = net.WriteBit },
		["Bool"] = { func = net.WriteBool },
		["Color"] = { func = net.WriteColor },
		["Double"] = { func = net.WriteDouble },
		["Entity"] = { func = net.WriteEntity },
		["Float"] = { func = net.WriteFloat },
		["Normal"] = { func = net.WriteNormal },
		["String"] = { func = net.WriteString },
		["Table"] = { func = net.WriteTable },
		["Vector"] = { func = net.WriteVector },
	},
	Read = {
		["UInt4"] = { func = net.ReadUInt, size = 4 },
		["UInt8"] = { func = net.ReadUInt, size = 8 },
		["UInt16"] = { func = net.ReadUInt, size = 16 },
		["UInt32"] = { func = net.ReadUInt, size = 32 },
		["Int4"] = { func = net.ReadInt, size = 4 },
		["Int8"] = { func = net.ReadInt, size = 8 },
		["Int16"] = { func = net.ReadInt, size = 16 },
		["Int32"] = { func = net.ReadInt, size = 32 },
		["Angle"] = { func = net.ReadAngle },
		["Bit"] = { func = net.ReadBit },
		["Bool"] = { func = net.ReadBool },
		["Color"] = { func = net.ReadColor },
		["Double"] = { func = net.ReadDouble },
		["Entity"] = { func = net.ReadEntity },
		["Float"] = { func = net.ReadFloat },
		["Normal"] = { func = net.ReadNormal },
		["String"] = { func = net.ReadString },
		["Table"] = { func = net.ReadTable },
		["Vector"] = { func = net.ReadVector },
	},
}

function Janus.Net:Initialize()
	net.Receive( "janus_netmsg", function( intMsgLen, ... )
		local id, name = net.ReadUInt( 8 ), net.ReadString()
		if not id or not name then return end
		if self.m_bVerbose then print( intMsgLen, id, name ) end

		local event_data = Janus.Net:GetEventHandleByID( id, name )
		if not event_data then return end
		if event_data.meta then
			event_data.func( event_data.meta, intMsgLen, ... )
		else
			event_data.func( intMsgLen, ... )
		end
	end )
end

function Janus.Net:AddProtocol( strProtocol, intNetID )
	if self.m_tblProtocols.Names[strProtocol] then return end
	self.m_tblProtocols.Names[strProtocol] = { ID = intNetID, Events = {} }
	self.m_tblProtocols.IDs[intNetID] = self.m_tblProtocols.Names[strProtocol]
end

function Janus.Net:IsProtocol( strProtocol )
	return self.m_tblProtocols.Names[strProtocol] and true or false
end

function Janus.Net:RegisterEventHandle( strProtocol, strMsgName, funcHandle, tblHandleMeta )
	if not self:IsProtocol( strProtocol ) then
		return
	end

	self.m_tblProtocols.Names[strProtocol].Events[strMsgName] = { func = funcHandle, meta = tblHandleMeta }
end

function Janus.Net:GetEventHandle( strProtocol, strMsgName )
	if not self:IsProtocol( strProtocol ) then return end
	return self.m_tblProtocols.Names[strProtocol].Events[strMsgName]
end

function Janus.Net:GetEventHandleByID( intNetID, strMsgName )
	return self.m_tblProtocols.IDs[intNetID].Events[strMsgName]
end

function Janus.Net:GetProtocolIDByName( strProtocol )
	return self.m_tblProtocols.Names[strProtocol].ID
end

function Janus.Net:NewEvent( strProtocol, strMsgName )
	if self.m_bVerbose then print( "New outbound net message: ".. strProtocol.. ":".. strMsgName ) end
	net.Start( "janus_netmsg" )
	net.WriteUInt( self:GetProtocolIDByName(strProtocol), 8 )
	net.WriteString( strMsgName )
end

function Janus.Net:FireEvent()
	if self.m_bVerbose then print( "Sending outbound net message to server." ) end
	net.SendToServer()
end

-- ----------------------------------------------------------------
-- Leveling Netcode
-- ----------------------------------------------------------------
Janus.Net:AddProtocol( "leveling", 0 )

Janus.Net:RegisterEventHandle( "leveling", "plu", function( intMsgLen, pPlayer )
end)

-- ----------------------------------------------------------------
-- Perks Netcode
-- ----------------------------------------------------------------
Janus.Net:AddProtocol( "perks", 1 )

Janus.Net:RegisterEventHandle( "perks", "sp", function( intMsgLen, pPlayer )
	Janus.m_tblPerks = net.ReadTable()
end)

Janus.Net:RegisterEventHandle( "perks", "sap", function( intMsgLen, pPlayer )
	Janus.m_tblActivePerks = net.ReadTable()
end)

function Janus.Net:RequestActivatePerks()
	self:NewEvent( "perks", "rap" )
		net.WriteTable( Janus.m_tblRequestedPerks )
	self:FireEvent()
end

-- ----------------------------------------------------------------
-- Achievements Netcode
-- ----------------------------------------------------------------
Janus.Net:AddProtocol( "achievements", 2 )

Janus.Net:RegisterEventHandle( "achievements", "sa", function( intMsgLen, pPlayer )
	Janus.m_tblAchievements = net.ReadTable()
end)

Janus.Net:RegisterEventHandle( "achievements", "sca", function( intMsgLen, pPlayer )
	Janus.m_tblCompletedAchievements = net.ReadTable()
end)

Janus.Net:RegisterEventHandle( "achievements", "nac", function( intMsgLen, pPlayer )
	Janus.m_tblAchievements = net.ReadString()
	Janus.m_tblAchievements = net.ReadString()
end)

Janus.Net:RegisterEventHandle( "achievements", "sp", function( intMsgLen, pPlayer )
	local uid = net.ReadString()
	local data = net.ReadString()
	Janus.m_tblAchievementsProgress[uid] = data
end)

Janus.Net:RegisterEventHandle( "achievements", "nc", function( intMsgLen, pPlayer )
	local compach = net.ReadString()
	local reward = net.ReadString()

	table.insert(Janus.m_tblCompletedAchievements, compach)
	if string.len(reward) != 0 then
		chat.AddText(Color(255,60,60),"[ACHIEVEMENTS] ", Color(255,255,255), "You were given ", Color(98,177,255), reward, Color(255,255,255), " for completing this achievement!")
	end
	
	if Janus.Config.DisplayCompletion then
		local string_a = net.ReadString()
		local string_b = net.ReadString()
		
		
		
		local frame = vgui.Create("DFrame")
		frame:SetTitle("")
		frame:ShowCloseButton(false)
		frame:SetSize(300, 104)
		frame.Paint = function()
			surface.SetDrawColor(Color(Janus.Config.PerksBoxColor1[1], Janus.Config.PerksBoxColor1[2], Janus.Config.PerksBoxColor1[3], 230))
			surface.DrawRect(0, 0, 300, 104)
		end
		
		frame:SetPos(ScrW()-300, ScrH()+104)
		frame:MoveTo(ScrW()-300, ScrH()-104, Janus.Config.SlideInTime, 0, 5)
		
		timer.Simple(Janus.Config.StayTime or 5, function()
			frame:MoveTo(ScrW()-300, ScrH()+104, Janus.Config.SlideOutTime, 0, 5)
		end)

		local background = vgui.Create("DPanel", frame)
		background:SetSize(74, 74)
		background:SetPos(15, 15)
		background.Paint = function()
			surface.SetDrawColor(Color(Janus.Config.PerksBoxColor1[1]/2, Janus.Config.PerksBoxColor1[2]/2, Janus.Config.PerksBoxColor1[3]/2, 230))
			surface.DrawRect(0, 0, 74, 74)
		end
		
		local background1 = vgui.Create("DPanel", background)
		background1:SetSize(64, 64)
		background1:SetPos(5, 5)
		background1.Paint = function()
			surface.SetDrawColor(Color(Janus.Config.PerksBoxColor1[1]/3, Janus.Config.PerksBoxColor1[2]/3, Janus.Config.PerksBoxColor1[3]/3, 230))
			surface.DrawRect(0, 0, 64, 64)
		end
		
		local icon = vgui.Create("DImage", frame)
		icon:SetSize(64, 64)
		icon:SetPos(20, 20)
		icon:SetImage(string_b)
		
		local text = vgui.Create("DLabel", frame)
		text:SetText("Achievement completed!")
		text:SizeToContents()
		text:SetPos(20+64+20, 20+10)
		
		local achievement = vgui.Create("DLabel", frame)
		achievement:SetText(string_a)
		achievement:SetPos(20+64+20, 20+20+10)
		achievement:SetFont("Roboto25")
		achievement:SizeToContents()
	end
end)