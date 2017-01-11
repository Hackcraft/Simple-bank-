
if SERVER then
	include("bank/init.lua")
	AddCSLuaFile("bank/cl_init.lua")
else
	include("bank/cl_init.lua")
end
