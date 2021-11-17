function levelingLoadModules()
	local fs, dirs = file.Find( 'leveling/modules/*', 'LUA' )
	for i=1,#dirs do

		print( 'leveling/modules/' .. dirs[i] )
		AddCSLuaFile( 'leveling/modules/' .. dirs[i] .. '/module.lua' )	
		include( 'leveling/modules/' .. dirs[i] .. '/module.lua' )
	end
	if (#fs > 0) then print( 'Found unused files in modules' ) end
end