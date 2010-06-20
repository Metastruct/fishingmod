fishingmod = fishingmod or {}

include("sv_networking.lua")
include("sv_player_stats.lua")
include("sv_upgrades.lua")

local servertags = GetConVarString("sv_tags") --Thanks PHX!

function fishingmod.SetData(entity, data)
	entity.data = data
	entity:SetColor(fishingmod.FriedToColor(data.fried or 0))
	entity:SetNWBool("fishingmod catch", true)
	entity:SetNWFloat("fishingmod size", data.size)
end

if servertags == nil then
	RunConsoleCommand("sv_tags", "fishingmod")
elseif not string.find(servertags, "fishingmod") then
	RunConsoleCommand("sv_tags", "fishingmod," .. servertags)
end

fishingmod.CatchTable = {}

function fishingmod.AddCatch(data)
	fishingmod.CatchTable[data.friendly] = data
end

function fishingmod.RemoveCatch(name)
	fishingmod.CatchTable[name] = nil
end

for key, name in pairs(file.FindInLua("fishing_mod/catch/*.lua")) do
	local path = "fishing_mod/catch/"..name
	include(path)
	AddCSLuaFile(path)
end

local function BreakWeld(ply,entity)
	if entity.shelf_stored and IsValid(entity.weld) then
		entity.weld:Fire("break")
		entity.weld_broke = true
	end
end

hook.Add("GravGunOnPickedUp", "Fishingmod:GravGunOnPickedUp", BreakWeld)
hook.Add("PhysgunPickup", "Fishingmod:PhysgunPickup", BreakWeld)

hook.Add("OnPhysgunFreeze", "Fishingmod:OnPhysgunFreeze", function(weapon, phys, entity, ply)
	if string.find(entity:GetClass(), "fishing_rod") then
		return false
	end
end)

hook.Add("CanTool", "Fishingmod:CanTool", function(ply, trace, tool)
	if not IsValid(trace.Entity) then return end
	if string.find(trace.Entity:GetClass(), "fishing_rod") then
		return false
	end
end)

concommand.Add("fishing_mod_drop_catch", function(ply)
	local fishing_rod = ply:GetFishingRod()
	if fishing_rod then
		fishing_rod:GetHook():UnHook()
	end
end)

concommand.Add("fishing_mod_drop_bait", function(ply)
	local fishing_rod = ply:GetFishingRod()
	if fishing_rod then
		fishing_rod:GetHook():DropBait()
	end
end)

function fishingmod.CheckBait(name, entity)
	local bait = fishingmod.CatchTable[name].bait
	if bait == "none" then return true end
	if not entity then return false end
	local model
	if entity.AttachedEntity then
		model = (entity.AttachedEntity and string.lower(entity.AttachedEntity:GetModel())) or "none"
	else
		model = (entity and string.lower(entity:GetModel())) or "none"
	end
	if bait then
		for key, value in pairs(bait) do
			if string.lower(value) == model then
				return true
			end
		end
	end
	return false
end

function fishingmod.IsBait(entity)
	if not IsValid(entity) then return end
	local model
	if entity.AttachedEntity then
		model = (entity.AttachedEntity and string.lower(entity.AttachedEntity:GetModel())) or "none"
	else
		model = (entity and string.lower(entity:GetModel())) or "none"
	end
	for name, catch in pairs(fishingmod.CatchTable) do
		if type(catch.bait) == "table" then
			for key, bait in pairs(catch.bait) do
				if string.lower(bait) == model then 
					return true 
				end
			end
		end
	end
	return false
end

local function RouletteRandom(t, r_func)
    local max = 0
    for pos, v in pairs(t) do
        if tonumber(pos) and tonumber(pos) > max then
            max = pos
        end
    end
    if max == 0 then return end
    local choice = (r_func or math.random)()*max
    local biggest, best = -1
    for pos, v in pairs(t) do
        local k = tonumber(pos)
        if k and k <= choice and k > biggest then
            biggest = k
            best = v
        end
    end
    return best, choice
end

local exp = 1.6677992676221

local sizes = {
    [exp^9] = {n = "Nano"       , min = 0.3, max = 0.4},
    [exp^8.5] = {n = "Micro"      , min = 0.4, max = 0.5},
    [exp^8]  = {n = "Mini"       , min = 0.5, max = 0.8},
    [exp^7.7]  = {n = "Small"      , min = 0.8, max = 1.1},
    [exp^7.5]  = {n = "Medium"     , min = 1.1, max = 1.4},
    [exp^5]  = {n = "Big-ish"    , min = 1.4, max = 1.8},
    [exp^4.5]  = {n = "Large"      , min = 1.8, max = 2.5},
    [exp^3]  = {n = "Huge"       , min = 2.5, max = 3.2},
    [exp^2.5]  = {n = "Gigantic"   , min = 3.2, max = 4.0},
    [exp^2]  = {n = "Humongous"  , min = 4.0, max = 7.0},
    [exp^1.5]  = {n = "Colossal"	, min = 7.0, max = 10.0},
}

function fishingmod.GenerateSize()
    local size_category, choice = RouletteRandom(sizes)
    if size_category then
        return size_category.min+math.random()*(size_category.max-size_category.min), size_category.n, choice
    else
        return nil, nil, choice
    end
end

function fishingmod.Sell(ply, entity, value)
	if entity.PreSell and entity:PreSell(ply, value) == false then return false end
	entity:Remove()
	fishingmod.GiveMoney(ply, value or 0)
	return true
end


hook.Add("KeyPress", "Fishingmod:KeyPress", function(ply, key)
	local entity = ply:GetEyeTrace().Entity
	if IsValid(entity) and key == IN_USE and entity:GetPos():Distance(ply:GetShootPos()) < 120 and entity:GetNWBool("fishingmod catch") and ply:KeyDown(IN_RELOAD) then
		local owner = player.GetByUniqueID(entity.data.ownerid)
		if owner ~= ply then return end
		if entity.data.cant_sell and entity.Use then entity:Use(ply) return end
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
        fishingmod.Sell(ply, entity, entity.data.value or 0)
	end
end)

hook.Add("FishingModCaught", "FishingMod:Seagull", function(ply, entity)
	if math.random(5) ~= 1 then return end

	local random = VectorRand()*2000
	random.z = math.abs(random.z)
	
	if not util.IsInWorld(random) then return end
	
	local seagull = ents.Create("fishing_mod_seagull")
	seagull:SetPos(ply:GetPos()+random)
	seagull:SetTarget(entity)
	seagull:SetTargetOwner(ply)
	seagull:Spawn()
		
end)

local divider = CreateConVar("fishing_mod_divider", 1, true, false)

hook.Add("Think","FishingMod:Think", function()
	for key, fire in pairs(ents.GetAll()) do 
		if fire:IsOnFire() then
			for key, catch in pairs(ents.FindInSphere(fire:GetPos(), fire:BoundingRadius()*2)) do
				if catch:GetNWBool("fishingmod catch") then
					local distance = math.max((catch:GetPos()+catch:OBBCenter()):Distance(fire:GetPos()) * -1 + fire:BoundingRadius()*2, 0) / 50
					if distance ~= 0 then
						catch.data.fried = catch.data.fried or 0
						catch.data.fried = math.Clamp(catch.data.fried + math.ceil(distance), 0, 1000)

						catch:SetColor(fishingmod.FriedToColor(catch.data.fried))
						timer.Create("Resend Fishingmod Info"..catch:EntIndex(), 0.1, 1, function()	
							if not catch.data then return end
							catch.data.originalvalue = catch.data.originalvalue or catch.data.value
							catch.data.value = catch.data.originalvalue * ((2-math.abs((catch.data.fried/1000-0.5)*2))*4)
							fishingmod.SetClientInfo(catch)
						end)
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
					fishingmod.LevelToExp(data.levelrequired) <= tonumber(ply.fishingmod.exp) and
					
					math.random(math.max(math.max(data.rareness-
						math.min(math.ceil(rod:GetBobber():GetVelocity():Length()/4),data.rareness/2)-
						math.min(math.ceil(rod:GetBobber():GetPos():Distance(ply:GetShootPos()/4),data.rareness/2)
					,1)/divider:GetFloat(),1))) == 1 and
					
					rod:GetDepth() < data.maxdepth and rod:GetDepth() > data.mindepth and
					fishingmod.CheckBait(data.friendly, rod:GetHook():GetHookedBait())
				then
					rod:GetHook():Hook(data.type, data)
					fishingmod.GainEXP(ply, data.expgain)
					rod:GetBobber():Yank(data.yank)
				end
			end
		end
	end
end)

concommand.Add("fishing_mod_request_init", function(ply)
	if ply.fishing_mod_spawned then return end
	for key, entity in pairs(ents.GetAll()) do
		if entity:GetNWBool("fishingmod catch") then
			fishingmod.SetClientInfo(entity, ply)
		end
	end
	ply.fishing_mod_spawned = true
end)

hook.Add("PlayerSpawnedProp", "Fishingmod:PlayerSpawnedProp", function(ply, model, entity)
	if ply:GetFishingRod() and fishingmod.IsBait(entity) and ply:GetFishingRod():GetHook():WaterLevel() == 0 then
		ply:GetFishingRod():GetHook():HookBait(entity)
	end
end)