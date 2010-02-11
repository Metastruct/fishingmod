concommand.Add("fishing_mod_drop_catch", function(ply) 
	print(ply)
	local fishing_rod = ply:GetFishingRod()
	if fishing_rod then
		fishing_rod:GetHook():UnHook()
	end
end)

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

hook.Add("SetPlayerAnimation", "Fishing Rod Animation", function(ply)
	if ply:GetFishingRod() then
	
		for key, parameter in pairs(pose_parameters) do
			ply:SetPoseParameter(parameter, 0)
		end
		ply:SetPoseParameter("move_yaw", math.AngleDifference(ply:GetVelocity():Angle().y, ply:GetLocalAngles().y))
		ply:SetPoseParameter("aim_pitch", ply:EyeAngles().p)

		local moving = ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)
		local running = ply:KeyDown(IN_SPEED)
		local sequence = "idle_melee2"
		
		if moving then
			sequence = "walk_melee2"
			if running then
				sequence = "run_melee2"
			end
		end
		
		if ply:Crouching() then
			sequence = "cidle_melee2"
			if moving then
				sequence = "cwalk_melee2"
			end
		end
		
		ply:SetSequence(ply:LookupSequence(sequence))
		return true
	end
end)

fishingmod.CatchTable = {}

function fishingmod.AddCatch(name, rareness, yank)
	fishingmod.CatchTable[name] = {name = name, rareness = rareness, yank = yank}
end

function fishingmod.RemoveCatch(name)
	fishingmod.CatchTable[name] = nil
end

fishingmod.AddCatch("models/props_junk/Shoe001a.mdl", 500, 150)


hook.Add("Think", "Fishing Mod Think", function() 
	for key, ply in pairs(player.GetAll()) do
		local rod = ply:GetFishingRod()
		if rod then
			for key, value in pairs(fishingmod.CatchTable) do
				local random = math.random(value.rareness)
				if random == 1 then
					print(rod:GetHook():GetHookedEntity(), rod:GetHook():WaterLevel())
					if not rod:GetHook():GetHookedEntity() and rod:GetHook():WaterLevel() >= 1 then
						print("yanking")
						rod:GetHook():Hook(value.name)
						rod:GetBobber():Yank(value.yank)
					end
				end
			end
		end
	end
end)