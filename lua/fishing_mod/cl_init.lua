include("cl_networking.lua")

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

hook.Add( "HUDPaint", "Fishingmod:HUDPaint", function()
	local trace = LocalPlayer():GetEyeTrace().Entity
	if IsValid(trace.Entity) and (trace.Entity:GetPos() - LocalPlayer():GetShootPos()):Length() < 120 then
		local data = fishingmod.InfoTable[trace.Entity:EntIndex()]
		if data and data.text then
			local width = 250
			local height = 60
			draw.RoundedBox( 8, ScrW() / 2 - (width/2.2), ScrH() / 2 - 5, width, height, Color( 100, 100, 100, 100 ) )
			draw.DrawText(data.text, "DefaultSmallDropShadow", ScrW() / 2, ScrH() / 2, Color(255,255,255,255),1)
		end
	end
end)

hook.Add("RenderScene", "Fishingmod:RenderScene", function() 
	for key, entity in pairs(ents.GetAll()) do
		local size = entity:GetNWFloat("fishingmod size")
		if entity:GetNWBool("fishingmod catch") and size ~= 0 then
			entity:SetModelScale(Vector()*size/entity:BoundingRadius())
		end
	end
end)

hook.Add("CalcView", "Fishingmod:CalcView", function(ply,offset,angles,fov)
	if ply:GetFishingRod() and not ply:InVehicle() then
					
		local offset = ply:GetShootPos() + 
			(ply:EyeAngles():Right() * 50) + 
			(Angle(0,ply:EyeAngles().y,0):Forward() * -150) + 
			(Angle(0,0,ply:EyeAngles().z):Up() * 20)
		angles.p = math.Clamp(angles.p-30, -70, 15)			
		
		return GAMEMODE:CalcView(ply,offset,angles,fov)
	end
end)