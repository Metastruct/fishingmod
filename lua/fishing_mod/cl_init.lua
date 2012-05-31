fishingmod = fishingmod or {}

include("cl_networking.lua")
include("cl_shop_menu.lua")

fishingmod.CatchTable = {}

function fishingmod.AddCatch(data)
	data.value = data.value or 0
	fishingmod.CatchTable[data.friendly] = data
end

function fishingmod.RemoveCatch(name)
	fishingmod.CatchTable[name] = nil
end
if VERSION >= 150 then
	for key, name in pairs(file.Find("fishing_mod/catch/*.lua", LUA_PATH)) do
		include("fishing_mod/catch/"..name)
	end
else
	for key, name in pairs(file.FindInLua("fishing_mod/catch/*.lua")) do
		include("fishing_mod/catch/"..name)
	end
end

hook.Add("InitPostEntity", "Init Fish Mod", function()
	RunConsoleCommand("fishing_mod_request_init")
	
	FMOldCalcVehicleThirdPersonView = FMOldCalcVehicleThirdPersonView or GAMEMODE.CalcVehicleThirdPersonView

	function GAMEMODE:CalcVehicleThirdPersonView(vehicle, ply, position, angles, fov)
		if ply:GetFishingRod() and IsValid(ply:GetNWEntity("weapon seat")) then
			local view = {}
			view.origin = ply:GetShootPos() + 
				(ply:EyeAngles():Right() * 50) + 
				(Angle(0,ply:EyeAngles().y,0):Forward() * -150) + 
				(Angle(0,0,ply:EyeAngles().z):Up() * 20)
			
			
			view.angles = Angle(math.Clamp(ply:EyeAngles().p-30, -70, 15), ply:EyeAngles().y, 0)		
			
			return view
		end
		return FMOldCalcVehicleThirdPersonView(self, vehicle, ply, position, angles, fov)
	end

end)

hook.Add( "HUDPaint", "Fishingmod:HUDPaint", function()
	local entity = LocalPlayer():GetEyeTrace().Entity
	entity = IsValid(entity) and IsValid(entity:GetNWEntity("FMRedirect")) and entity:GetNWEntity("FMRedirect") or entity
	
	if IsValid(entity) and (entity:GetPos() - LocalPlayer():GetShootPos()):Length() < 120 then
		local data = fishingmod.InfoTable.Catch[entity:EntIndex()]
		if data and data.text then
			local width = 250
			local height = 85
			draw.RoundedBox( 8, ScrW() / 2 - (width/2.2), ScrH() / 2 - 5, width, height, Color( 100, 100, 100, 100 ) )
			draw.DrawText(data.text, "DefaultSmallDropShadow", ScrW() / 2, ScrH() / 2, Color(255,255,255,255),1)
		end
		local data = fishingmod.InfoTable.Bait[entity:EntIndex()]
		if data and data.text then
			local width = 200
			local height = 20
			draw.RoundedBox( 8, ScrW() / 2 - (width/2.2), ScrH() / 2 - 5, width, height, Color( 100, 100, 100, 100 ) )
			draw.DrawText(data.text, "DefaultSmallDropShadow", ScrW() / 2, ScrH() / 2, Color(255,255,255,255),1)
		end
	end
end)

hook.Add("Think", "Fishingmod.Keys:Think", function()
	local ply = LocalPlayer()
	if ply:GetFishingRod() and not vgui.CursorVisible() then
		if input.IsKeyDown(KEY_B) then
			local menu = fishingmod.UpgradeMenu
			if not menu:IsVisible() then
				menu:SetVisible(true)
				menu:MakePopup()
			end
		end	
		if input.IsKeyDown(KEY_E) then
			RunConsoleCommand("fishing_mod_drop_bait")
		end
		if input.IsKeyDown(KEY_R) then
			RunConsoleCommand("fishing_mod_drop_catch")
		end	
	end
end)

hook.Add("ShouldDrawLocalPlayer", "Fishingmod:ShouldDrawLocalPlayer", function(ply)
	if ply and ply:GetFishingRod() then
		return true
	end
end)

timer.Create("Fishingmod:Tick", 2, 0, function()
	for key, entity in pairs(ents.GetAll()) do
		if entity:GetNWBool("fishingmod scalable") then
			entity:SetModelScale(Vector()*entity:GetNWFloat("fishingmod scale", 1))
		end
		local size = entity:GetNWFloat("fishingmod size")
		if entity:GetNWBool("in fishing shelf") and size ~= 0 then
			entity:SetModelScale(Vector()*size/entity:BoundingRadius())
		end
	end
end)

hook.Add("CalcView", "Fishingmod:CalcView", function(ply,offset,angles,fov)
	if GetViewEntity() ~= ply then return end
	if ply:GetFishingRod() and not ply:InVehicle() then
					
		local offset = ply:GetShootPos() + 
			(ply:EyeAngles():Right() * 50) + 
			(Angle(0,ply:EyeAngles().y,0):Forward() * -150) + 
			(Angle(0,0,ply:EyeAngles().z):Up() * 20)
		angles.p = math.Clamp(angles.p-30, -70, 15)			
		
		return GAMEMODE:CalcView(ply,offset,angles,fov)
	end
end)