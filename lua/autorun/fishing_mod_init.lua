if SERVER then
	AddCSLuaFile("autorun/fishing_mod_init.lua")
	AddCSLuaFile("fishing_mod/sh_init.lua")
	AddCSLuaFile("fishing_mod/cl_init.lua")
	AddCSLuaFile("fishing_mod/cl_networking.lua")
	AddCSLuaFile("fishing_mod/cl_shop_menu.lua")
	include("fishing_mod/sv_init.lua")
	resource.AddFile("sound/fishingrod/reel.wav")
else
	include("fishing_mod/cl_init.lua")
end

include("fishing_mod/sh_init.lua")