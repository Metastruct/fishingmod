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

for key, name in pairs(file.Find("fishing_mod/catch/*.lua", "LUA")) do
	include("fishing_mod/catch/"..name)
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
			draw.RoundedBox( 8, ScrW() / 2 - (width/2), ScrH() / 2 - 3, width, height, Color( 100, 100, 100, 100 ) )
			draw.DrawText(data.text, "DermaDefault", ScrW() / 2 - (width/3), ScrH() / 2, Color(255,255,255,255),1)
		end
		local data = fishingmod.InfoTable.Bait[entity:EntIndex()]
		if data and data.text then
			local width = 240
			local height = 20
			draw.RoundedBox( 8, ScrW() / 2 - (width/2), ScrH() / 2 - 3, width, height, Color( 100, 100, 100, 100 ) )
			draw.DrawText(data.text, "DermaDefault", ScrW() / 2 - (width/3), ScrH() / 2, Color(255,255,255,255),1)
		end
	end
end)

hook.Add("Think", "Fishingmod.Keys:Think", function()
	local ply = LocalPlayer()
	if ply:GetFishingRod() and not vgui.CursorVisible() then
		if input.IsKeyDown(KEY_B) then
			local menu = fishingmod.UpgradeMenu
			if ValidPanel(menu) and not menu:IsVisible() then
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
			entity:SetModelScale(entity:GetNWFloat("fishingmod scale", 1), 0)
		end
		local size = entity:GetNWFloat("fishingmod size")
		if entity:GetNWBool("in fishing shelf") and size ~= 0 then
			entity:SetModelScale(size/entity:BoundingRadius(), 0)
		end
	end
end)

hook.Add("CalcView", "Fishingmod:CalcView", function(ply,offset,angles,fov)
	if GetViewEntity() ~= ply then return end
	local fishingRod = ply:GetFishingRod()
	if fishingRod and not ply:InVehicle() then

		local view = {}
		view.origin		= offset
		view.angles		= angles
		view.fov		= fov

		local startview = ply:GetShootPos() + 
			(ply:EyeAngles():Right() * 50) + 
			(Angle(0,ply:EyeAngles().y,0):Forward() * -150) + 
			(Angle(0,0,ply:EyeAngles().r):Up() * 20)

		-- Trace back from the original eye position, so we don't clip through walls/objects
		local fbobber = ( fishingRod.GetBobber != nil and IsValid(fishingRod:GetBobber()) ) and fishingRod:GetBobber()
		local fhook = ( fishingRod.GetHook != nil and IsValid(fishingRod:GetHook()) ) and fishingRod:GetHook()
		local WallOffset = 4

		local tr = util.TraceHull( {
			start = view.origin,
			endpos = startview,
			filter = { ply, fishingRod, fbobber, fhook },
			mins = Vector( -WallOffset, -WallOffset, -WallOffset ),
			maxs = Vector( WallOffset, WallOffset, WallOffset ),
		} )

		view.origin = tr.HitPos
		view.angles.p = math.Clamp(view.angles.p-30, -70, 15)

		return view

	end
end)
