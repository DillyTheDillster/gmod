include("psm_config.lua")

function MidgOn(ply)

	ply:SetModelScale(MIDGETSIZE, MIDGETSIZE)

	if ALLOWSHORTHULL == true then

		ply:SetHull( Vector( -16, -16, 0 ), Vector( 16, 16, 36 ) )
		ply:SetHullDuck( Vector( -16, -16, 0 ), Vector( 16, 16, 18 ) )

	end
end

function SMidgOn(ply)

	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_Pelvis"), Vector(1,1,-19.6))

	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_L_Calf"), Vector(0.2,1,1))
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Calf"), Vector(-12,0,0))
		
	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Calf"), Vector(0.2,1,1))
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Calf"), Vector(-12,0,0))
		
	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_L_Thigh"), Vector(0.2,1,0.8))
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Thigh"), Vector(0,-0.8,-2))

	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Thigh"), Vector(0.2,1,0.8))
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Thigh"), Vector(0,-0.8,-2))

	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_L_Foot"), Vector(1,1,1))
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Foot"), Vector(-12,0,0))
	
	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Foot"), Vector(1,1,1))
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Foot"), Vector(-12,0,0))

	ply:SetModelScale(SPECIALMIDGETSIZE, SPECIALMIDGETSIZE)

	if ALLOWSHORTHULL == true then

		ply:SetHull( Vector( -16, -16, 0 ), Vector( 16, 16, 36 ) )
		ply:SetHullDuck( Vector( -16, -16, 0 ), Vector( 16, 16, 18 ) )

	end
	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Head1"), Vector(2,2,2))

end

function MidgOff(ply)

	ply:SetModelScale(1, 1)

	if ALLOWSHORTHULL == true then

		ply:SetHull( Vector( -16, -16, 0 ), Vector( 16, 16, 72 ) )
		ply:SetHullDuck( Vector( -16, -16, 0 ), Vector( 16, 16, 36 ) )

	end

end

function SMidgOff(ply)

	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_Pelvis"), Vector(0,0,0))

	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_L_Calf"), Vector(1,1,1))
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Calf"), Vector(0,0,0))
		
	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Calf"), Vector(1,1,1))
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Calf"), Vector(0,0,0))
		
	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_L_Thigh"), Vector(1,1,1))
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Thigh"), Vector(0,0,0))

	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Thigh"), Vector(1,1,1))
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Thigh"), Vector(0,0,0))

	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_L_Foot"), Vector(1,1,1))
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Foot"), Vector(0,0,0))
	
	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Foot"), Vector(1,1,1))
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Foot"), Vector(0,0,0))

	ply:SetModelScale(1, 1)

	if ALLOWSHORTHULL == true then

		ply:SetHull( Vector( -16, -16, 0 ), Vector( 16, 16, 72 ) )
		ply:SetHullDuck( Vector( -16, -16, 0 ), Vector( 16, 16, 36 ) )

	end
	ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Head1"), Vector(1,1,1))


end