if (SERVER) then
  MsgC(Color(255,0,0), "[", Color(255,255,255), "XxLMM13xXgaming", Color(255,0,0), "] ", Color(255,255,255), "Last prop standing loaded!\n")
  AddCSLuaFile("lps_config.lua")
  include("lps_config.lua")
end

if (CLIENT) then
  MsgC(Color(255,0,0), "[", Color(255,255,255), "XxLMM13xXgaming", Color(255,0,0), "] ", Color(255,255,255), "Last prop standing loaded!\n")
  include("lps_config.lua")
end
