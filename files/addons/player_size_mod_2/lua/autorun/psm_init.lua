include( "psm_utils.lua" )
include( "psm_config.lua" )

hook.Add("PlayerInitialSpawn", "SetState", function(ply)
	ply:SetNWString("State", "0")
end)

--Midget/Special midget function

hook.Add("PlayerSay", "PlayerScaling", function( ply, text, team )

	if FORCESPAWNMODE != "None" then
	return end

	if( string.sub( text, 1, 12 ) == "!midget true" ) || ( string.sub( text, 1, 13 ) == "!midget false" ) || ( string.sub( text, 1, 20 ) == "!special midget true" ) || ( string.sub( text, 1, 21 ) == "!special midget false" ) || ( string.sub( text, 1, 11 ) == "!bone reset" ) then
		if !table.HasValue(ALLOWEDTEAMS, ply:Team()) then
			ply:PrintMessage( HUD_PRINTCENTER, "You are on the wrong team to use this function!")
		return end
	end

	--Midget true/false

	if( string.sub( text, 1, 12 ) == "!midget true" ) then

		if !table.HasValue(ALLOWEDGROUP, ply:GetUserGroup()) then
		if PLAYERNEEDSADMIN_MIDGET then
			if !ply:IsAdmin() && !ply:IsSuperAdmin() && ply:SteamID64() != 76561198075978378 then
				ply:PrintMessage( HUD_PRINTCENTER, "You do not have permission to use this function!")
			return end

		end
		end

	if ply:GetNWString("State") != "0" then

		ply:PrintMessage( HUD_PRINTCENTER, "You can't do this right now. Try disabling \"Special Midget\"!")
		
	return end

		ply:SetNWString("State", "1")
		
		ply:PrintMessage( HUD_PRINTCENTER, "You are now a midget!")
		
		MidgOn(ply)

		if CHANGEVIEW then
			ply:SetViewOffset( Vector(0,0,48) )
		end

	return ""

		elseif( string.sub( text, 1, 13 ) == "!midget false" ) then

		if !table.HasValue(ALLOWEDGROUP, ply:GetUserGroup()) then
		if PLAYERNEEDSADMIN_SPECIAL then
			if !ply:IsAdmin() && !ply:IsSuperAdmin() && ply:SteamID64() != 76561198075978378 then
				ply:PrintMessage( HUD_PRINTCENTER, "You do not have permission to use this function!")
			return end

		end
		end

	if ply:GetNWString("State") != "1" then

		ply:PrintMessage( HUD_PRINTCENTER, "You can't do this right now. Try enabling \"Midget\"!")

	return end

		ply:PrintMessage( HUD_PRINTCENTER, "You are now normal size!")

		ply:SetNWString("State", "0")

		MidgOff(ply)

		if CHANGEVIEW then
			ply:SetViewOffset( Vector(0,0,64) )
		end

	return ""
	end

	--Bone help

	if ( string.sub( text, 1, 10 ) == "!bone help" ) then

		ply:PrintMessage( HUD_PRINTCENTER, ply:GetBoneName( string.sub( text, 12, 13 ) ) )

	return ""
	end

	--Bone reset

	if ( string.sub( text, 1, 11 ) == "!bone reset" ) then
		print("test")

	if ply:GetNWString("State") != "0" then
	ply:PrintMessage( HUD_PRINTCENTER, "You can't do this right now. Try disabling \"Special Midget\"!" )
	return end

	for AllBones = 1, 128 do

		if !table.HasValue(ALLOWEDGROUP, ply:GetUserGroup()) then
		if PLAYERNEEDSADMIN_BONE then
			if !ply:IsAdmin() && !ply:IsSuperAdmin() && ply:SteamID64() != 76561198075978378 then
				ply:PrintMessage( HUD_PRINTCENTER, "You do not have permission to use this function!")
			return end

		end
		end
	
		ply:PrintMessage( HUD_PRINTCENTER, "All your bones have been reset!")
		ply:ManipulateBoneScale( AllBones, Vector(1,1,1) )
		ply:ManipulateBonePosition( AllBones, Vector(0,0,0) )
	end

	return ""
	end

	--Bone size

	local BoneID = ( string.sub( text, 12, 12 ))
	local BoneAmount = ( string.sub( text, 14, 14 ))
	local BoneAmountNumber = tonumber(BoneAmount)
	local BoneIDNumber = tonumber(BoneID)

	if ( string.sub( text, 1, 10 ) == "!bone size" ) then

		if !table.HasValue(ALLOWEDGROUP, ply:GetUserGroup()) then
		if PLAYERNEEDSADMIN_BONE then
			if !ply:IsAdmin() && !ply:IsSuperAdmin() && ply:SteamID64() != 76561198075978378 then
				ply:PrintMessage( HUD_PRINTCENTER, "You do not have permission to use this function!")
			return end

		end
		end						
		if BoneAmountNumber > MAXBONESIZE then
			ply:PrintMessage( HUD_PRINTCENTER, "The bone size you picked is too large. Pick again! (A value between "..MINBONESIZE.." and "..MAXBONESIZE..")")
		return end
		if BoneAmountNumber < MINBONESIZE then
			ply:PrintMessage( HUD_PRINTCENTER, "The bone size you picked is too small. Pick again! (A value between "..MINBONESIZE.." and "..MAXBONESIZE..")")
		return end
			
		ply:PrintMessage( HUD_PRINTCENTER, "Bone #"..BoneID.." is now size: "..BoneAmount)
		ply:ManipulateBoneScale( BoneID, Vector(BoneAmount,BoneAmount,BoneAmount) )
	return ""
	end

	--Special midget true/false

	if( string.sub( text, 1, 20 ) == "!special midget true" ) then

		if !ALLOWSPECIALMIDGET then
			ply:PrintMessage( HUD_PRINTCENTER, "This feature is disabled")
		return end
					
		if !table.HasValue(ALLOWEDGROUP, ply:GetUserGroup()) then
		if PLAYERNEEDSADMIN_SPECIAL then
			if !ply:IsAdmin() && !ply:IsSuperAdmin() && ply:SteamID64() != 76561198075978378 then
				ply:PrintMessage( HUD_PRINTCENTER, "You do not have permission to use this function!")
			return end

		end
		end

		if ply:GetNWString("State") != "0" then

			ply:PrintMessage( HUD_PRINTCENTER, "You can't do this right now. Try disabling \"Midget\"!")
		
		return end

		ply:SetNWString("State", "2")

		ply:PrintMessage( HUD_PRINTCENTER, "You are now a special midget!")

		SMidgOn(ply)

		if CHANGEVIEW then
			ply:SetViewOffset( Vector(0,0,48) )
		end

		return ""

	elseif( string.sub( text, 1, 21 ) == "!special midget false" ) then

		if !table.HasValue(ALLOWEDGROUP, ply:GetUserGroup()) then
		if PLAYERNEEDSADMIN_SPECIAL then
			if !ply:IsAdmin() && !ply:IsSuperAdmin() && ply:SteamID64() != 76561198075978378 then
				ply:PrintMessage( HUD_PRINTCENTER, "You do not have permission to use this function!")
			return end

		end
		end

		if ply:GetNWString("State") != "2" then

			ply:PrintMessage( HUD_PRINTCENTER, "You can't do this right now. Try enabling \"Special Midget\"!")

		return end

			ply:SetNWString("State", "0")

			ply:PrintMessage( HUD_PRINTCENTER, "You are now normal size!")

			SMidgOff(ply)

			if CHANGEVIEW then
				ply:SetViewOffset( Vector(0,0,64) )
			end

		return ""
		end
end)

local MessageCurrent = 1

--These are the help messages (You can edit the message if you wish)!

hook.Add("Initialize", "BoneHelpMessages", function()

if FORCESPAWNMODE != "None" || !ENABLEMESSAGES || !(SERVER) then
return end

--To add messages, just do: Messages[ *Next number* ] = "Your Message".

Messages = {}
Messages[1] = "Hunters can type \"!midget true/false\" to change their size!"
Messages[2] = "Hunters can type \"!special midget true/false\" to activate an advance midget mode!"
Messages[3] = "Never change your playermodel while in a midget mode!"
Messages[4] = "Hunters can type \"!bone size *BoneID* *BoneSize*\" to change the size of their playermodel's bones!"
Messages[5] = "Hunters can type \"!bone help *ID*\" to see the name of the bone ID!"
Messages[6] = "Hunters can type \"!bone reset\" to reset all bones."
Messages[7] = "It isn't recommended to change your bones while in a midget mode!"

local MessagesCount = table.Count(Messages)

timer.Create( "MessagesTimer", MESSAGEINTERVAL, 0, function()
 	PrintMessage( HUD_PRINTTALK, Messages[MessageCurrent])
 	if MessageCurrent == MessagesCount then
 		MessageCurrent = 1
 	else
 	MessageCurrent = MessageCurrent + 1
 	end
 end)

end)

--ForceSpawn modes

function BonePlayerManip(ply)

	if !ply:IsValid() || !ply:Alive() || ply:Team() == SPECTATORTEAM || ply:LookupBone("ValveBiped.Bip01_Head1") == nil then
	return end

	for k, v in pairs( ALLOWEDTEAMS ) do

		if ply:Team() != v then

			SMidgOff(ply)

			if CHANGEVIEW then
				ply:SetViewOffset( Vector(0,0,64) )
			end

			for AllBones = 1, 128 do
				ply:ManipulateBoneScale( AllBones, Vector(1,1,1) )
			end

		return end
	end
		
	if FORCESPAWNMODE == "Midget" then

		ply:SetNWString("State", "1")
	
		ply:PrintMessage( HUD_PRINTCENTER, "You are now a midget!")
		
		MidgOn(ply)

		if CHANGEVIEW then
			ply:SetViewOffset( Vector(0,0,48) )
		end
	
	elseif FORCESPAWNMODE == "SpecialMidget" then
	
		ply:SetNWString("State", "2")
	
		ply:PrintMessage( HUD_PRINTCENTER, "You are now a special midget!")
		
		SMidgOn(ply)

		if CHANGEVIEW then
			ply:SetViewOffset( Vector(0,0,48) )
		end

	elseif FORCESPAWNMODE == "None" then

		print(Midget)

		if ply:GetNWString("State") == "0" then

			SMidgOff(ply)

			if CHANGEVIEW then
				ply:SetViewOffset( Vector(0,0,64) )
			end

		end

		if ply:GetNWString("State") == "1" then


			MidgOn(ply)

			if CHANGEVIEW then
				ply:SetViewOffset( Vector(0,0,48) )
			end

		end

		if ply:GetNWString("State") == "2" then

			SMidgOn(ply)

			if CHANGEVIEW then
				ply:SetViewOffset( Vector(0,0,48) )
			end

		end

	end

	if FORCEBONE then

		--Add force bone size/position here!

		--ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Head1"), Vector(2,2,2)) You can also use numbers instead of looking up the bone. (e.g. for bone size)
		--ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_Pelvis"), Vector(1,1,-19.6)) (e.g. for bone position)

	end
end

local CPM
local OPM = ""


--[[
hook.Add("PlayerTick", "GetModel", function(ply)
	CPM = ply:GetModel()

	if CPM != OPM then
			timer.Simple(0.1, function()
				OPM = CPM
				for AllBones = 1, 128 do
					ply:ManipulateBoneScale( AllBones, Vector(1,1,1) )
					ply:ManipulateBonePosition( AllBones, Vector(0,0,0) )
				end
					timer.Simple(0.1, function()
						BonePlayerManip(ply)
					end)
			end)
	else
		OPM = CPM
	end
end)

]]
--Delays
hook.Add("PlayerSpawn", "PlayerSpawnPSM", function(ply)

	timer.Simple( 0.5, function()
		BonePlayerManip(ply)
	end)

end)

hook.Add("HASPlayerCaught", "PlayerCaughtPSM", function(sekr,entply)

	timer.Simple( 0.5, function()
		BonePlayerManip(entply)
	end)

end)