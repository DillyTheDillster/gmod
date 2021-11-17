--[[
	Name: sv_config.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

Janus.Config = Janus.Config or {}

--[[ MySQL Config ]]--
Janus.Config.MySQL_Host = "localhost" // database host(can be an ip or a URL)
Janus.Config.MySQL_Port = 3306 // port to the database, you probably wont need to change this unless you get told to
Janus.Config.MySQL_Database = "janus" // name of the database
Janus.Config.MySQL_Username = "root" // username which you use to access it
Janus.Config.MySQL_Password = "" // password of the username