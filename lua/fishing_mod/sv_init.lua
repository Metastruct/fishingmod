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
	local fishing_rod = ply:GetFishingRod()
	if fishing_rod then
		fishing_rod:GetHook():DropBait()
	end
end)

fishingmod.CatchTable = {}

function fishingmod.AddCatch(data)
	fishingmod.CatchTable[data.friendly] = data
end

function fishingmod.RemoveCatch(name)
	fishingmod.CatchTable[name] = nil
end

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
fishingmod.AddCatch{
	friendly = "Shoe",
	type = {
		"models/props_junk/Shoe001a.mdl",
	},
	size = 10,
	rareness = 300, 
	yank = 1000, 
	force = 2000, 
	mindepth = 0, 
	maxdepth = 500,
	remove_on_release = true,
}

fishingmod.AddCatch{
	friendly = "Headcrab",
	type = {
		"npc_headcrab",
		"npc_headcrab_black",
		"npc_headcrab_fast",
	},
	size = 10,
	rareness = 300, 
	yank = 500, 
	force = 0, 
	mindepth = 200, 
	maxdepth = 1000,
	remove_on_release = false,
	friendlybait = "Heads",
	bait = {
		"models/props/cs_office/Snowman_head.mdl",
		"models/Gibs/HGIBS.mdl",
	},
}

fishingmod.AddCatch{
	friendly = "Explosive Barrel",
	type = {
		"models/props_c17/oildrum001_explosive.mdl",
	},
	size = 8,
	rareness = 300, 
	yank = 2000, 
	force = 0, 
	mindepth = 100, 
	maxdepth = 1000,
	remove_on_release = false,
	friendlybait = "Explosives",
	bait = {
		"models/props_explosive/explosive_butane_can02.mdl",
		"models/props_explosive/explosive_butane_can.mdl",
		"models/weapons/w_c4_planted.mdl",		
	},
}

fishingmod.AddCatch{
	friendly = "Angry Baby",
	type = {
		"fishing_mod_angry_baby",
	},
	rareness = 300, 
	yank = 0, 
	force = 10000, 
	mindepth = 200, 
	maxdepth = 1000,
	remove_on_release = false,
	friendlybait = "Melons",
	bait = {
		"models/props_junk/watermelon01.mdl",
		"models/props_junk/watermelon01_chunk01a.mdl",
		"models/props_junk/watermelon01_chunk01b.mdl",
		"models/props_junk/watermelon01_chunk01c.mdl",
		"models/props_junk/watermelon01_chunk02a.mdl",
		"models/props_junk/watermelon01_chunk02b.mdl",
		"models/props_junk/watermelon01_chunk02b.mdl",
		"models/props_junk/watermelon01_chunk02c.mdl",
	},
}

hook.Add("Think", "Fishing Mod Think", function() 
	for key, ply in pairs(player.GetAll()) do
		local rod = ply:GetFishingRod()
		if rod then
			for key, data in pairs(fishingmod.CatchTable) do
 				if 
					not rod:GetHook():GetHookedEntity() and rod:GetHook():WaterLevel() >= 1 and 
					math.random(math.max(data.rareness-math.min(math.ceil(rod:GetBobber():GetVelocity():Length()/4),data.rareness/2),1)) == 1 and
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

function fishingmod.SetClientInfo(entity)
	print(entity.data.friendly, ValidEntity(entity), entity:EntIndex())
	umsg.Start("Fishingmod Set Data Info")
		umsg.Entity(entity)
		umsg.String(entity.data.friendly)
		umsg.Long(entity.data.rareness)
		umsg.Short(entity.data.mindepth)
		umsg.Short(entity.data.maxdepth)
		umsg.String(entity.data.friendlybait or "nothing")
	umsg.End()
end