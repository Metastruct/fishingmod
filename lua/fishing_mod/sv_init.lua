include("sv_networking.lua")

fishingmod.CatchTable = {}

function fishingmod.AddCatch(data)
	fishingmod.CatchTable[data.friendly] = data
end

function fishingmod.RemoveCatch(name)
	fishingmod.CatchTable[name] = nil
end

for key, name in pairs(file.FindInLua("fishing_mod/catch/*.lua")) do
	include("fishing_mod/catch/"..name)
end


local function BreakWeld(ply,entity)
	if entity.shelf_stored and IsValid(entity.weld) then
		entity.weld:Fire("break")
		entity.weld_broke = true
	end
end

hook.Add("GravGunOnPickedUp", "Fishing Mod Pick From Shelf", BreakWeld)

hook.Add("PhysgunPickup", "Fishing Mod Pick From Shelf", BreakWeld)


concommand.Add("fishing_mod_drop_catch", function(ply)
	local fishing_rod = ply:GetFishingRod()
	if fishing_rod then
		fishing_rod:GetHook():UnHook()
	end
end)

concommand.Add("fishing_mod_drop_bait", function(ply)
	print(ply)
	local fishing_rod = ply:GetFishingRod()
	if fishing_rod then
		fishing_rod:GetHook():DropBait()
	end
end)

function fishingmod.CheckBait(name, entity)
	if not name then return false end
	local model = (entity and string.lower(entity:GetModel())) or "none"
	local bait = fishingmod.CatchTable[name].bait
	if bait then
		for key, value in pairs(bait) do
			if string.lower(value) == model then
				return true
			end
		end
	else
		return true
	end
	return false
end

function fishingmod.IsBait(entity)
	if not IsValid(entity) then return end
	local model = string.lower(entity:GetModel()) or ""
	for name, catch in pairs(fishingmod.CatchTable) do
		if catch.bait then
			for key, bait in pairs(catch.bait) do
				if string.lower(bait) == model then 
					return true 
				end
			end
		end
	end
	return false
end

local divider = CreateConVar("fishing_mod_divider", 1, true, false)

hook.Add("Think", "Fishing Mod Think", function()
	for key, fire in pairs(ents.GetAll()) do 
		if fire:IsOnFire() then
			for key, catch in pairs(ents.FindInSphere(fire:GetPos(), fire:BoundingRadius()*2)) do
				if catch:GetNWBool("fishingmod catch") then
					local distance = math.max((catch:GetPos()+catch:OBBCenter()):Distance(fire:GetPos()) * -1 + fire:BoundingRadius()*2, 0) / 50
					if distance ~= 0 then
						catch.data.fried = catch.data.fried or 0
						catch.data.fried = math.Clamp(catch.data.fried + math.ceil(distance), 0, 1000)

						catch:SetColor(fishingmod.FriedToColor(catch.data.fried))
						timer.Create("Resend Fishingmod Info"..catch:EntIndex(), 0.1, 1, fishingmod.SetClientInfo, catch)
					end
				end
			end
		end
	end
	
	for key, ply in pairs(player.GetAll()) do
		local rod = ply:GetFishingRod()
		if rod then
			for key, data in RandomPairs(fishingmod.CatchTable) do
 				if 
					not rod:GetHook():GetHookedEntity() and rod:GetHook():WaterLevel() >= 1 and 
					math.random(math.max(math.max(data.rareness-math.min(math.ceil(rod:GetBobber():GetVelocity():Length()/4),data.rareness/2),1)/divider:GetFloat(),1)) == 1 and
					rod:GetDepth() < data.maxdepth and rod:GetDepth() > data.mindepth and
					fishingmod.CheckBait(data.friendly, rod:GetHook():GetHookedBait())
				then
					rod:GetHook():Hook(table.Random(data.type), data)
					rod:GetBobber():Yank(data.yank)
				end
			end
		end
	end
end)

hook.Add("PlayerInitialSpawn", "Update Client Info", function(ply)
	timer.Simple(3, function()
		if not IsValid(ply) then return end
		for key, entity in pairs(ents.GetAll()) do
			if IsValid(entity:GetNWEntity("fishingmod catch")) then
				fishingmod.SetClientInfo(entity, ply)
			end
		end
	end)
end)