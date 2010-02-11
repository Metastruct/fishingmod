fishingmod = {}

function _R.Player:GetFishingRod()
	return ValidEntity(self:GetNWEntity("fishing rod")) and self:GetNWEntity("fishing rod") or false
end

if CLIENT then
	local pose_parameters = {
		--"move_yaw",
		"aim_yaw",
		--"aim_pitch", override this
		"body_yaw",
		"spine_yaw",
		"head_yaw",
		"head_pitch",
		"head_roll",
		"breathing",
		"vertical_velocity",
		"vehicle_steer",
	}

	hook.Add("UpdateAnimation", "Fishing Rod Fix Spazz", function(ply)
		if ply:GetFishingRod() then
			for key, ply in pairs(player.GetAll()) do
				for key, parameter in pairs(pose_parameters) do
					ply:SetPoseParameter(parameter, 0)
				end
				ply:SetPoseParameter("move_yaw", math.AngleDifference(ply:GetVelocity():Angle().y, ply:GetLocalAngles().y))
				ply:SetPoseParameter("aim_pitch", ply:EyeAngles().p)
			end
			return true
		end
	end)

	hook.Add("ShouldDrawLocalPlayer", "MyHax ShouldDrawLocalPlayer", function(ply)
		if ply:GetFishingRod() then
			return true
		end
	end)

	local smooth_position = Vector(0)
	local smooth_direction = Vector(0)

	hook.Add("CalcView", "Fishing Rod Thirdperson", function(ply,position,angles,fov)
		local fishing_rod = ply:GetFishingRod()
		if fishing_rod and ValidEntity(fishing_rod.GetBobber and fishing_rod:GetBobber()) then
			local offset = ply:GetShootPos() + (ply:GetAngles():Right() * 10) + (Angle(0,ply:EyeAngles().y,0):Forward() * -100)
			local direction = LerpVector(0.7, fishing_rod:GetBobber():GetPos() + Vector(0,0,-50) - smooth_position, ply:GetShootPos() - smooth_position)
			fov = 50
			smooth_direction = smooth_direction + ((direction - smooth_direction) * 0.1)
			smooth_position = smooth_position + ((offset - smooth_position) * 0.1 )
			return GAMEMODE:CalcView(ply,smooth_position,smooth_direction:Angle(),fov)
		end
	end)

	hook.Add("RenderScene", "Render Fishing Rods", function()
		for key, entity in pairs(ents.FindByClass("entity_fishing_rod")) do
			local ply = entity:GetPlayer()
			if ply then
				ply:SetAngles(Angle(0,ply:EyeAngles().y,0))
			end
			local position, angles = entity.dt.ply:GetBonePosition(entity.dt.ply:LookupBone("ValveBiped.Bip01_R_Hand"))
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