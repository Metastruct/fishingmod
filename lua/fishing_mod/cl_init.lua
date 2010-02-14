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
	local fishing_rod = ply:GetFishingRod()
	if fishing_rod and ValidEntity(fishing_rod.GetBobber and fishing_rod:GetBobber()) then
					
		local offset = ply:GetShootPos() + 
			(ply:EyeAngles():Right() * 50) + 
			(Angle(0,ply:EyeAngles().y,0):Forward() * -150) + 
			(Angle(0,0,ply:EyeAngles().z):Up() * 20)
		angles.p = math.Clamp(angles.p-30, -70, 15)			
		local direction = LerpVector(0.7, fishing_rod:GetBobber():GetPos() + Vector(0,0,-50) - offset, ply:GetShootPos() - offset)
		
		return GAMEMODE:CalcView(ply,offset,angles,fov)
	end
end)

hook.Add("RenderScene", "Render Fishing Rods", function()
	for key, entity in pairs(ents.GetAll()) do
		local size = entity:GetNWFloat("fishingmod size")
		if entity:GetNWBool("fishingmod catch") and size ~= 0 then
			entity:SetModelScale(Vector()*size/entity:BoundingRadius())
		end
	end
	
	for key, entity in pairs(ents.FindByClass("entity_fishing_rod")) do
		local ply = entity:GetPlayer()
		if ply then
			ply:SetAngles(Angle(0,ply:EyeAngles().y,0))
		end
		local position, angles = entity.dt.avatar:GetBonePosition(entity.dt.avatar:LookupBone("ValveBiped.Bip01_R_Hand"))
		local new_position, new_angles = LocalToWorld(entity.PlayerOffset, entity.PlayerAngles, position, angles)
		entity:SetPos(new_position)
		entity:SetAngles(new_angles)
	end
end)

local function RarenessToText(number)
	if number < 500 then
		return "very common"
	elseif number < 1000 then
		return "common"
	elseif number < 1500 then
		return "not so common"
	elseif number < 2000 then
		return "not so rare"
	elseif number < 4000 then
		return "rare"
	elseif number < 7000 then
		return "very rare"
	elseif number < 10000 then
		return "super rare"
	elseif number < 20000 then
		return "golden"
	end
end

fishingmod.InfoTable = fishingmod.InfoTable or {}

usermessage.Hook("Fishingmod Set Data Info", function(um) 
	local entity = um:ReadEntity()
	local friendly = um:ReadString()
	local rareness = um:ReadLong()
	local mindepth = um:ReadShort()
	local maxdepth = um:ReadShort()
	local bait = um:ReadString()
	fishingmod.InfoTable[entity:EntIndex()] = {
		friendly = friendly,
		rareness = RarenessToText(rareness),
		rarenessnumber = rarenessnumber,
		mindepth = mindepth,
		maxdepth = maxdepth,
		bait = bait,
	}
end)

hook.Add( "HUDPaint", "Fishing Mod Draw HUD", function()
	local trace = LocalPlayer():GetEyeTrace().Entity
	if IsValid(trace.Entity) and (trace.Entity:GetPos() - LocalPlayer():GetShootPos()):Length() < 120 then
		local data = fishingmod.InfoTable[trace.Entity:EntIndex()]
		if data then
			local text = Format([[
				
				This catch is called %s and it's %s.
				It can be caught at a depth between %u to %s units. 
				This catch likes %s
			]],
			data.friendly,
			data.rareness,
			data.mindepth,
			data.maxdepth,
			data.bait
			)
			local wide = 170
			draw.RoundedBox( 6, ScrW()/2-wide+5, ScrH()/2+50, wide*2, 60, Color(255,255,200,100) )
			draw.DrawText(text, "DefaultFixedOutline", ScrW()/2, ScrH()/2+50, color_white, 1)
		end
	end

	for key, entity in pairs(ents.FindByClass("entity_fishing_rod")) do
		local xy = (entity:GetBobber():GetPos() + Vector(0,0,10)):ToScreen()

		local depth = ""
		if entity:GetHook():WaterLevel() >= 1 then
			depth =  "\nDepth: " .. math.ceil(entity:GetDepth())
		end
		
		local catch = ""
		local hooked_entity = entity:GetHook():GetHookedEntity()
		if hooked_entity and hooked_entity:WaterLevel() == 0 and hooked_entity:GetPos():Distance(LocalPlayer():EyePos()) < 500 then
			catch = "\nCatch: " .. hooked_entity:GetNWString("fishingmod friendly")
		end
		
		draw.DrawText(entity:GetPlayer():Nick() .. "\nLength: " .. entity:GetLength() .. depth .. catch, "HudSelectionText", xy.x,xy.y, hooked_entity and Color(0,255,0,255) or color_white,1)
	end
end)