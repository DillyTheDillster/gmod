--[[
	Name: sv_mysql_player.lua
	For: Menzoberranzan
	By: ♕ Dilly ✄
]]--

Janus.SQL = Janus.SQL or {}
Janus.SQL.m_tblDiffFlags = Janus.SQL.m_tblDiffFlags or {}
Janus.SQL.m_tblDecoded = Janus.SQL.m_tblDecoded or {}

function Janus.SQL:Initialize()
	self.db = mysqloo.CreateDatabase(Janus.Config.MySQL_Host, Janus.Config.MySQL_Username, Janus.Config.MySQL_Password, Janus.Config.MySQL_Database, Janus.Config.MySQL_Port)
	self:InitJanusTables()
end

function Janus.SQL:LogMsg( str )
	ErrorNoHalt( "[SQL] ".. str, "\n" )
end

function Janus.SQL:LogDev( str, ... )
	if not self.m_bVerbose then return end
	ErrorNoHalt( "[SQL-DEBUG] ".. str, ..., "\n" )
end

function Janus.SQL:LogPlayerQuery( intCharID, strQuery )
	if true then return end
	
	if not file.IsDir( "sql_log", "DATA" ) then file.CreateDir( "sql_log" ) end
	if not file.Exists( "sql_log/log_".. intCharID.. ".txt", "DATA" ) then
		file.Write( "sql_log/log_".. intCharID.. ".txt", "" )
	end

	file.Append( "sql_log/log_".. intCharID.. ".txt", os.date().. " - ".. strQuery.. "\n\n" )
end

function Janus.SQL:LogPlayerDiff( strSID64, strData )
	if true then return end
	
	if not file.IsDir( "sql_diff_log", "DATA" ) then file.CreateDir( "sql_diff_log" ) end
	if not file.Exists( "sql_diff_log/log_".. strSID64.. ".txt", "DATA" ) then
		file.Write( "sql_diff_log/log_".. strSID64.. ".txt", "" )
	end

	file.Append( "sql_diff_log/log_".. strSID64.. ".txt", os.date().. " - ".. strData.. "\n\n" )
end

function Janus.SQL:InitJanusTables()
	local transaction = self.db:CreateTransaction()
	self:LogMsg( "Initializing Janus tables..." )
	transaction:Query( [[CREATE TABLE IF NOT EXISTS `player_levels` (
		`steamID` varchar(255) NOT NULL,
		`level` int(255) unsigned NOT NULL DEFAULT '1',
		`xp` int(255) unsigned NOT NULL DEFAULT '0',
		`achievements` longtext,
		PRIMARY KEY (`steamID`)
		) ENGINE=InnoDB AUTO_INCREMENT=720 DEFAULT CHARSET=utf8;]] )

	transaction:Start(function(transaction, status, err)
		if (!status) then Janus.SQL:LogMsg( "Couldn't connect to database! Error: "..err ) end
		Janus.SQL:LogMsg( "Tables initialized correctly!" )
	end)
end