include("sv_networking.lua")
include("sv_player_stats.lua")
include("sv_upgrades.lua")
AddCSLuaFile("cl_shop_menu.lua")

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
	include("fishing_mod/catch/"..name)
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
	local model = string.lower(entity:GetModel()) or ""
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

hook.Add("KeyPress", "Fishingmod:KeyPress", function(ply, key)
	local entity = ply:GetEyeTrace().Entity
	if key == IN_USE and entity:GetPos():Distance(ply:GetShootPos()) < 120 and entity:GetNWBool("fishingmod catch") and ply:KeyDown(IN_RELOAD) then
		entity:Remove()
		fishingmod.GiveMoney(ply, entity.data.value or 0)
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
	end
end)

local divider = CreateConVar("fishing_mod_divider", 1, true, false)

hook.Add("Think", "Fishingmod:Think", function()
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
--[[ 			print(	
					"friendly\n\n\n\n\n",
					data.friendly,
					"\nwater",
					not rod:GetHook():GetHookedEntity() and rod:GetHook():WaterLevel() >= 1 , 
					"\nlevel",
					fishingmod.LevelToExp(data.levelrequired) <= ply.fishingmod_exp,
					"\nrandom",
					math.random(math.max(math.max(data.rareness-math.min(math.ceil(rod:GetBobber():GetVelocity():Length()/4),data.rareness/2),1)/divider:GetFloat(),1)) == 1,
					"\ndepth",
					rod:GetDepth() < data.maxdepth and rod:GetDepth() > data.mindepth ,
					"\nbait",
					fishingmod.CheckBait(data.friendly, rod:GetHook():GetHookedBait())
				) ]]
 				if 
					not rod:GetHook():GetHookedEntity() and rod:GetHook():WaterLevel() >= 1 and 
					fishingmod.LevelToExp(data.levelrequired) <= tonumber(ply.fishingmod.exp) and
					math.random(math.max(math.max(data.rareness-math.min(math.ceil(rod:GetBobber():GetVelocity():Length()/4),data.rareness/2),1)/divider:GetFloat(),1)) == 1 and
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

hook.Add("PlayerInitialSpawn", "Fishingmod:PlayerInitialSpawn", function(ply)
	timer.Simple(3, function()
		if not IsValid(ply) then return end
		for key, entity in pairs(ents.GetAll()) do
			if entity:GetNWBool("fishingmod catch") then
				fishingmod.SetClientInfo(entity, ply)
			end
		end
	end)
end)

hook.Add("PlayerSpawnedProp", "Fishingmod:PlayerSpawnedProp", function(ply, model, entity)
	if ply:GetFishingRod() and fishingmod.IsBait(entity) then
		ply:GetFishingRod():GetHook():HookBait(entity)
	end
end)