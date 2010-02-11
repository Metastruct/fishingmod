fishingmod = {}

function _R.Player:GetFishingRod()
	return ValidEntity(self:GetNWEntity("fishing rod")) and self:GetNWEntity("fishing rod") or false
end

if CLIENT then

	hook.Add("ShouldDrawLocalPlayer", "MyHax ShouldDrawLocalPlayer", function(ply)
		if ply:GetFishingRod() then
			return true
		end
	end)

	hook.Add("CalcView", "Fishing Rod Thirdperson", function(ply,position,angles,fov)
		local fishing_rod = ply:GetFishingRod()
		if fishing_rod and ValidEntity(fishing_rod.GetBobber and fishing_rod:GetBobber()) then
		
			local offset = ply:GetShootPos() + 
				(ply:EyeAngles():Right() * 50) + 
				(Angle(0,ply:EyeAngles().y,0):Forward() * -70) + 
				(Angle(0,0,ply:EyeAngles().z):Up() * 20) +
				(ply:GetShootPos() - fishing_rod:GetBobber():GetPos()):Normalize()*30
			
			local direction = LerpVector(0.7, fishing_rod:GetBobber():GetPos() + Vector(0,0,-50) - offset, ply:GetShootPos() - offset)
			return GAMEMODE:CalcView(ply,offset,direction:Angle(),fov)
		end
	end)

	hook.Add("RenderScene", "Render Fishing Rods", function()
		for key, entity in pairs(ents.FindByClass("entity_fishing_rod")) do
			local ply = entity:GetPlayer()
			if ply then
				ply:SetAngles(Angle(0,ply:EyeAngles().y,0))
			end
			local position, angles = entity.dt.avatar:GetBonePosition(entity.dt.avatar:LookupBone("ValveBiped.Bip01_R_Hand"))
			local new_position, new_angles = LocalToWorld(entity.PlayerOffset, entity.PlayerAngles, position, angles)
			entity:SetPos(new_position)
			entity:SetAngles(new_angles)
			local fish_hook = entity:GetHook()
			if fish_hook then
				fish_hook:SetAngles(Angle(0,0,0))
			end
		end
	end)
	hook.Add( "HUDPaint", "Fishing Mod Draw HUD", function()
		for key, entity in pairs(ents.FindByClass("entity_fishing_rod")) do
			local xy = (entity:GetBobber():GetPos() + Vector(0,0,10)):ToScreen()
			draw.DrawText("Length: " .. entity:GetLength(), "ChatFont", xy.x,xy.y, Color(255,255,255,255),1)
		end
	end)
	
end