fishingmod = fishingmod or {}

include("sv_networking.lua")
include("sv_player_stats.lua")
include("sv_upgrades.lua")

function fishingmod.SetData(entity, data)
	entity.data = data
	entity:SetColor(fishingmod.FriedToColor(data.fried or 0))
	entity:SetNWBool("fishingmod catch", true)
	entity:SetNWFloat("fishingmod size", data.size)
end

fishingmod.CatchTable = {}

function fishingmod.AddCatch(data)
	data.value = data.value or 0
	fishingmod.CatchTable[data.friendly] = data
end

function fishingmod.RemoveCatch(name)
	fishingmod.CatchTable[name] = nil
end
for key, name in pairs(file.Find("lua/fishing_mod/catch/*.lua", "GAME")) do
	local path = "fishing_mod/catch/"..name
	include(path)
	AddCSLuaFile(path)
end

local function BreakWeld(ply, entity)
	if entity.shelf_stored then
		constraint.RemoveAll(entity)
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
		
	if trace.Entity:GetClass() == "prop_physics" and trace.Entity.is_bait then
		return false		
	end
end)
fishingmod.bait_spawn_delay = 0.625
concommand.Add("fishing_mod_buy_bait", function(ply, command, arguments)
	ply.fishingmod.last_bait_spawn = ply.fishingmod.last_bait_spawn or 0
	if CurTime() >= ply.fishingmod.last_bait_spawn + fishingmod.bait_spawn_delay then
		local type = table.concat(arguments, " ")
		local rod = ply:GetFishingRod()
		if not rod then return end

		local hooky = rod:GetHook()
		local data = fishingmod.BaitTable[type]
		if not data then return end

		if fishingmod.ExpToLevel(ply.fishingmod.exp) < data.levelrequired then return end
		if not fishingmod.Pay(ply, math.Round(data.price * data.multiplier)) then return end
		
		local bait = ents.Create("prop_physics")
		bait.data = {}
		bait.is_bait = true
		bait.data.owner = ply
		bait.data.ownerid = ply:UniqueID()
		bait.data.friendly = type
		bait:SetModel(table.Random(data.models))
		bait:SetPos(util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 100, ply).HitPos + Vector(0, 0, 32))
		bait:Spawn()
		if bait:IsValid() then
			bait:GetPhysicsObject():SetMass(math.min(bait:GetPhysicsObject():GetMass(), 100))
		end

		hook.Run("PlayerSpawnedProp", ply, bait:GetModel(), bait)

		if not util.IsValidProp(bait:GetModel():lower()) then bait:PhysicsInitBox(Vector(1, 1, 1 ) * -7,Vector(1, 1, 1) * 7) end
		
		fishingmod.SetBaitInfo(bait)
        if hooky then
    		hooky:SetPos(hooky:GetPos() + Vector(0, 0, (1 - util.QuickTrace(hooky:GetPos(), Vector(0, 0, -16) ).Fraction) * 16 ) )
    		fishingmod.HookBait(ply, bait, hooky)
        end
		ply.fishingmod.last_bait_spawn = CurTime()
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

function fishingmod.HookBait(ply, entity, hook)
	if not hook then return end
	if entity.is_bait and player.GetByUniqueID(entity.data.ownerid) == ply then
		if ply:GetFishingRod() and ply:GetFishingRod():GetHook():WaterLevel() == 0 then
			ply:GetFishingRod():GetHook():HookBait(entity)
		end
	end
end

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
				if string.lower(bait) == model and entity.is_bait then
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
    local choice = (r_func or math.random)() * max
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
        return size_category.min + math.random() * (size_category.max - size_category.min), size_category.n, choice
    else
        return 1, "", choice
    end
end

function fishingmod.Sell(ply, entity, value)
	if player.GetByUniqueID(entity.data.ownerid) ~= ply then return end
	if entity.PreSell and entity:PreSell(ply, value) == false then return false end
	entity:Remove()
	fishingmod.GiveMoney(ply, value or 0)
	ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90, 110))
	return true
end


hook.Add("KeyPress", "Fishingmod:KeyPress", function(ply, key)
	local entity = ply:GetEyeTrace().Entity
	entity = IsValid(entity) and IsValid(entity:GetNWEntity("FMRedirect")) and entity:GetNWEntity("FMRedirect") or entity
	if IsValid(entity) and key == IN_RELOAD and entity:GetPos():Distance(ply:GetShootPos()) < 120 and entity:GetNWBool("fishingmod catch") then
		local owner = player.GetByUniqueID(entity.data.ownerid)
		if owner ~= ply then return end
		--if entity.data.cant_sell and entity.Use then pcall(entity.Use,entity,ply) return end
        fishingmod.Sell(ply, entity, entity.data.value or 0)
	end
end)


hook.Add("FishingModCaught", "FishingMod:Seagull", function(ply, entity)
	--print("player",ply,"catch",entity)
	if IsValid(ply) and IsValid(entity) then
		--print("BEFORE RANDOM")
		if math.random(150) < math.Clamp(ply.fishingmod.seagull_deter or 1, 1, 100) then return end
		--print("AFTER RANDOM")
		local random = VectorRand()*2000
		random.z = math.abs(random.z)
		
		local position = ply:GetPos()+random
		
		if not util.IsInWorld(position) then return end
		--print("NOT IN WORLD")
		
		local seagull = ents.Create("fishing_mod_seagull")
		seagull:SetPos(position)
		seagull:SetTarget(entity)
		seagull:SetTargetOwner(ply)
		seagull:Spawn()
		
		--print("SUCCESS")
	end
end)

function fishingmod.FriedToMultiplier(number)
	local tri = ((1-math.abs((number/1000-0.5)*2))*8) + 1
	
	if number > 500 then
		tri = tri - (number/1000)
	end
	
	return tri
end

local divider = CreateConVar("fishing_mod_divider", 1, true, false)

timer.Create("FishingMod:Think",1,0,function()
	for key, ply in pairs(player.GetAll()) do
		local rod = ply:GetFishingRod()
		local bobber = rod and rod:GetBobber()
		if bobber then
			for key, data in RandomPairs(fishingmod.CatchTable) do
				if not data.type then continue end
				
				local chance=math.random(
								math.max(
									data.rareness 
									- 
									math.min( math.ceil( bobber:GetVelocity():Length()/4 ), data.rareness/2 ) 
									-
									math.min(
										math.ceil(
											rod:GetBobber():GetPos():Distance(ply:GetShootPos()/4)
										,
											data.rareness/2 
										)
									,
										1
									) / divider:GetFloat()
								,
									1
								)
							)
				if (rod:GetHook() and not rod:GetHook():GetHookedEntity() and rod:GetHook():WaterLevel() >= 1) and
					fishingmod.LevelToExp(data.levelrequired) <= tonumber(ply.fishingmod.exp) and chance <75 and
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
	if ply.fishingmod and ply.fishing_mod_spawned then return end
	for key, entity in pairs(ents.GetAll()) do
		if entity:GetNWBool("fishingmod catch") then
			fishingmod.SetCatchInfo(entity, ply)
		end
	end
	
	for bait, data in pairs(fishingmod.BaitTable) do
		fishingmod.SetBaitSale(bait, data.multiplier, ply)
	end
	
	fishingmod.InitPlayerStats(ply)
	
	ply.fishing_mod_spawned = true
end)

local lasttime = 0

function fishingmod.SetRandomSale()
	for bait, data in pairs(fishingmod.BaitTable) do
		fishingmod.SetBaitSale(bait, math.random())
	end
end

hook.Add("Tick", "FishingMod:UpdateSales", function()
	local time = math.Round(os.time()/300)*300
	if time ~= lasttime then
		fishingmod.SetRandomSale()
		lasttime = time
	end
end)

hook.Add("InitPostEntity", "FishingMod:SetSales", function()
	fishingmod.SetRandomSale()
end)