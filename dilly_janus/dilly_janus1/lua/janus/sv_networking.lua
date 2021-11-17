--[[
	Name: sv_networking.lua
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

util.AddNetworkString "Janus_netmsg"

function Janus.Net:Initialize()
	net.Receive( "Janus_netmsg", function( intMsgLen, pPlayer, ... )
		local id, name = net.ReadUInt( 8 ), net.ReadString()
		if not id or not name then return end
		if self.m_bVerbose then print( pPlayer, id, name ) end

		local event_data = Janus.Net:GetEventHandleByID( id, name )
		if not event_data then
			ServerLog( ("Invalid net message header sent by %s! Got protocol[%s]:id[%s]\n"):format(pPlayer:Nick(), id, name) )
			return
		end

		--lprof.PushScope()
		if event_data.meta then
			event_data.func( event_data.meta, intMsgLen, pPlayer, ... )
		else
			event_data.func( intMsgLen, pPlayer, ... )
		end
		--lprof.PopScope( "Janus_netmsg:(".. pPlayer:Nick().. ")[".. id.. "][".. name.. "]" )
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
	self.m_strCurProtocol = strProtocol
	self.m_strCurName = strMsgName

	net.Start( "Janus_netmsg" )
	net.WriteUInt( self:GetProtocolIDByName(strProtocol), 8 )
	net.WriteString( strMsgName )
end

function Janus.Net:FireEvent( pPlayer )
	if self.m_bVerbose and type(pPlayer) ~= "table" then print( ("Sending outbound net message to %s"):format(pPlayer:Nick()) ) end
	if DBugR then
		DBugR.Profilers.Net:AddNetData( "Janus.Net[".. self.m_strCurProtocol.. "][".. self.m_strCurName.. "]", net.BytesWritten() )
	end

	net.Send( pPlayer )
end

function Janus.Net:BroadcastEvent()
	if DBugR then
		DBugR.Profilers.Net:AddNetData( "Janus.Net[".. self.m_strCurProtocol.. "][".. self.m_strCurName.. "]", net.BytesWritten() )
	end
	net.Broadcast()
end

-- ----------------------------------------------------------------
-- Leveling Netcode
-- ----------------------------------------------------------------
Janus.Net:AddProtocol( "leveling", 0 )

function Janus.Net:PlayerLevelUp( pPlayer, currLevel )
	self:NewEvent( "leveling", "plu" )
	self:FireEvent( pPlayer )
end

-- ----------------------------------------------------------------
-- Perks Netcode
-- ----------------------------------------------------------------
Janus.Net:AddProtocol( "perks", 1 )

function Janus.Net:SendPerks( pPlayer )
	local tblPerks = Janus.Utils:DeepCopy( Janus.Perks.m_tblPerks )
	for k, v in pairs(tblPerks) do
		if v.ActivePlayers then
			v.ActivePlayers = nil
		end
		
		if v.OnActivate then
			v.OnActivate = nil
		end
		
		if v.OnDeactivate then
			v.OnDeactivate = nil
		end
		
		if v.Function then
			v.Function = nil
		end
		
		if v.FunctionHook then
			v.FunctionHook = nil
		end
		
		if v.IsValid then
			v.IsValid = nil
		end
	end
	self:NewEvent( "perks", "sp" )
		net.WriteTable( tblPerks )
	self:FireEvent( pPlayer )
end

function Janus.Net:SendActivePerks( pPlayer )
	local tblPerks = Janus.Utils:DeepCopy( Janus.Perks:GetPlayerActivePerks( pPlayer ) )
	for k, v in pairs(tblPerks) do
		if v.ActivePlayers then
			v.ActivePlayers = nil
		end
		
		if v.OnActivate then
			v.OnActivate = nil
		end
		
		if v.OnDeactivate then
			v.OnDeactivate = nil
		end
		
		if v.Function then
			v.Function = nil
		end
		
		if v.FunctionHook then
			v.FunctionHook = nil
		end
		
		if v.IsValid then
			v.IsValid = nil
		end
	end
	self:NewEvent( "perks", "sap" )
		net.WriteTable( tblPerks )
	self:FireEvent( pPlayer )
end

Janus.Net:RegisterEventHandle( "perks", "rap", function( intMsgLen, pPlayer )
	local tblPerks = net.ReadTable()
	
	for _, v in pairs(Janus.Perks:GetPlayerActivePerks( pPlayer )) do
		if Janus.Utils:PerksShouldRemove( v.Name, tblPerks ) then
			Janus.Perks:RemovePlayerActivePerk( pPlayer, v.Name )
		end
	end
	
	for k,v in pairs(tblPerks) do
		if #Janus.Perks:GetPlayerActivePerks( pPlayer ) >= Janus.Config.MaxPerks then continue end
		Janus.Perks:SetPlayerActivePerk( pPlayer, v.Name )
	end
	Janus.Net:SendActivePerks( pPlayer )
end)

-- ----------------------------------------------------------------
-- Achievements Netcode
-- ----------------------------------------------------------------
Janus.Net:AddProtocol( "achievements", 2 )

function Janus.Net:SendAchievements( pPlayer )
	local tblAchievements = Janus.Achievements.m_tblAchievements
	self:NewEvent( "achievements", "sa" )
		net.WriteTable( tblAchievements )
	self:FireEvent( pPlayer )
end

function Janus.Net:SendCompletedAchievements( pPlayer )
	local tblAchievements = pPlayer.CompletedAchievements
	self:NewEvent( "achievements", "sca" )
		net.WriteTable( tblAchievements )
	self:FireEvent( pPlayer )
end

function Janus.Net:NotifyAllCompleted( pPlayer, name )
	self:NewEvent( "achievements", "nac" )
		net.WriteString( pPlayer:Nick() )
		net.WriteString( name )
	self:BroadcastEvent()
end

function Janus.Net:SendProgression( pPlayer, uid, data )
	self:NewEvent( "achievements", "sp" )
		net.WriteString( uid )
		net.WriteString( data )
	self:FireEvent( pPlayer )
end

function Janus.Net:NotifyCompleted( pPlayer, uid )
	local m_tblAchievement = Janus.Achievements.m_tblAchievements[uid]
	self:NewEvent( "achievements", "nc" )
		net.WriteString(uid)
		net.WriteString(m_tblAchievement.RewardName)
		net.WriteString(m_tblAchievement.PrintName)
		net.WriteString(m_tblAchievement.Icon or Janus.Config.DefaultIcon)
	self:FireEvent( pPlayer )
end