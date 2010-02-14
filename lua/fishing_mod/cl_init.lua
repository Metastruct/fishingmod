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
--hook.Add("InitPostEntity", "Fishing Mod Init Vehicle CalcView", function()
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
--end)

hook.Add("RenderScene", "Render Fishing Rods", function()
	for key, entity in pairs(ents.GetAll()) do
		local size = entity:GetNWFloat("fishingmod size")
		if entity:GetNWBool("fishingmod catch") and size ~= 0 then
			entity:SetModelScale(Vector()*size/entity:BoundingRadius())
		end
	end
	
	for key, entity in pairs(ents.FindByClass("fishing_mod_avatar")) do
		entity:Animate()
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

local function RarenessToFriendly(number)
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

local function FriedToFriendly(number)
	if number == 0 then
		return "not cooked at all"
	elseif number < 200 then
		return "rare"
	elseif number < 300 then
		return "medium rare"
	elseif number < 500 then
		return "medium"
	elseif number < 600 then
		return "medium well"
	elseif number < 700 then
		return "well done"
	elseif number == 1000 then
		return "burnt"
	end
end

function fishingmod.TimeFormat(s)
	local time = os.date("!*t", s)
	local last_time = {}
	last_time.seconds = {seconds = time.sec}
	last_time.minutes = {minutes = time.min}
	last_time.hours = {hours = time.hour}
	last_time.days = {days = time.day-1}
	last_time.months = {months = time.month-1}
	last_time.years = {years = time.year-1970}

	local new_string = ""
	for key, value in pairs(last_time) do
		if value.minutes or 60 > 60 then
			last_time.seconds = nil
		end
		if value.hours or 60 > 60 then
			last_time.minutes = nil
		end
		if value.days or 1 > 1 then
			last_time.hours = nil
		end
		if value.months or 1 > 1 then
			last_time.days = nil
		end
		if value.years or 1 > 1 then
			last_time.months = nil
		end
	end
	
	PrintTable(last_time)
	return new_string
end

fishingmod.InfoTable = fishingmod.InfoTable or {}

usermessage.Hook("Fishingmod", function(um) 
	local entity = um:ReadShort()
	local friendly = um:ReadString()
	local rareness = um:ReadLong()
	local mindepth = um:ReadShort()
	local maxdepth = um:ReadShort()
	local bait = um:ReadString()
	local caught = um:ReadLong()
	local owner = um:ReadString()
	local fried = um:ReadShort()
	print("Incomming mesasEEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWsge", entity, Entity(entity), IsValid(Entity(entity)))
	fishingmod.InfoTable[entity] = {
		friendly = friendly,
		rareness = RarenessToFriendly(rareness),
		rarenessnumber = rarenessnumber,
		mindepth = mindepth,
		maxdepth = maxdepth,
		bait = bait,
		caught = caught,
		owner = owner,
		cooked = FriedToFriendly(fried),
	}
	local text = Format([[
		<font=Default>
			This catch is called <font=DefaultUnderline>%s</font> and it's <font=DefaultUnderline>%s</font>.
			<font=DefaultUnderline>%s</font> caught this
			<font=DefaultUnderline>{TIME}</font>
			It can be caught at a depth between <font=DefaultUnderline>%u</font> to <font=DefaultUnderline>%s</font> units.
			This catch likes <font=DefaultUnderline>%s</font>.
			It is <font=DefaultUnderline>%s</font>.
		</font>
	]],
	friendly,
	RarenessToFriendly(rareness),
	owner,
	mindepth,
	maxdepth,
	bait,
	FriedToFriendly(fried)
	)
	local time = string.gsub(os.date("on %A, the $%d of %B, %Y, at %I:%M%p", caught), "$(%d%d)", function(n) return tonumber(n)..STNDRD(n) end)
	local text = string.gsub(text, "{TIME}", time)
	fishingmod.InfoTable[entity].mark_up = markup.Parse(text, ScrW()/4)
end)

hook.Add("Think", "Fishing Mod Think Client", function()
	for key, value in pairs(fishingmod.InfoTable) do
		if not IsValid(Entity(key)) then
			print("invalid", Entity(key))
			fishingmod.InfoTable[key] = nil
		end
	end
end)

hook.Add( "HUDPaint", "Fishing Mod Draw HUD", function()
	local trace = LocalPlayer():GetEyeTrace().Entity
	if IsValid(trace.Entity) and (trace.Entity:GetPos() - LocalPlayer():GetShootPos()):Length() < 120 then
		local data = fishingmod.InfoTable[trace.Entity:EntIndex()]
		if data and data.mark_up then
			local size = 20
			local width = data.mark_up:GetWidth()
			draw.RoundedBox( 6, ScrW()/2-(width/4)-(size/2), ScrH()/2-(size/2) + 100, width -(width/4) + size, data.mark_up:GetHeight() + size, Color(0,0,0,230))
			data.mark_up:Draw(ScrW()/2-(width/8), ScrH()/2 + 100, 1, 0, 200)
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