include("cl_networking.lua")

hook.Add("KeyPress", "Fishing Mod KeyPress", function(ply, key)
	if ply:GetFishingRod() and key == IN_USE then
		RunConsoleCommand("fishing_mod_drop_bait")
	end
end)

hook.Add("ShouldDrawLocalPlayer", "MyHax ShouldDrawLocalPlayer", function(ply)
	if ply:GetFishingRod() then
		return true
	end
end)

hook.Add("CalcView", "Fishing Rod Thirdperson", function(ply,position,angles,fov)
	if ply:GetFishingRod() and not ply:InVehicle() then
					
		local offset = ply:GetShootPos() + 
			(ply:EyeAngles():Right() * 50) + 
			(Angle(0,ply:EyeAngles().y,0):Forward() * -150) + 
			(Angle(0,0,ply:EyeAngles().z):Up() * 20)
		angles.p = math.Clamp(angles.p-30, -70, 15)			
		
		return GAMEMODE:CalcView(ply,offset,angles,fov)
	end
end)

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
	return -1
end

hook.Add( "HUDPaint", "Fishing Mod Draw HUD", function()
	local trace = LocalPlayer():GetEyeTrace().Entity
	if IsValid(trace.Entity) and (trace.Entity:GetPos() - LocalPlayer():GetShootPos()):Length() < 120 then
		local data = fishingmod.InfoTable[trace.Entity:EntIndex()]
		if data and data.mark_up then
			local size = 20
			local width = data.mark_up:GetWidth()
			draw.RoundedBox( 6, ScrW()/2-(width/4)-(size/2) - 10, ScrH()/2-(size/2) + 100, width -(width/4) + size - 40, data.mark_up:GetHeight() + size, Color(0,0,0,230))
			data.mark_up:Draw(ScrW()/2-(width/8), ScrH()/2 + 100, 1, 0, 200)
		end
	end
end)