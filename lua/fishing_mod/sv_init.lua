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
	friendly = "Junk",
	type = {
		"models/props_junk/Shoe001a.mdl",
		"models/props_junk/garbage_coffeemug001a.mdl",
		"models/props_junk/garbage_coffeemug001a_chunk01.mdl",
		"models/props_junk/garbage_glassbottle001a.mdl",
		"models/props_junk/garbage_glassbottle001a_chunk01.mdl",
		"models/props_junk/garbage_glassbottle003a.mdl",
		"models/props_junk/garbage_metalcan001a.mdl",
		"models/props_junk/garbage_milkcarton001a.mdl",
		"models/props_junk/garbage_metalcan002a.mdl",
		"models/props_junk/garbage_milkcarton001a.mdl",
		"models/props_junk/garbage_milkcarton002a.mdl",
		"models/props_junk/garbage_newspaper001a.mdl",
		"models/props_junk/garbage_plasticbottle001a.mdl",
		"models/props_junk/garbage_plasticbottle002a.mdl",
		"models/props_junk/garbage_plasticbottle003a.mdl",
		"models/props_junk/garbage_takeoutcarton001a.mdl",
		"models/props_junk/GlassBottle01a.mdl",
		"models/props_junk/glassbottle01a_chunk01a.mdl",
		"models/props_junk/glassjug01.mdl",
		"models/props_junk/glassjug01_chunk02.mdl",
		"models/props_junk/PopCan01a.mdl",
		"models/props_junk/PropaneCanister001a.mdl",
		"models/props_junk/propane_tank001a.mdl",		
	},
	size = 10,
	rareness = 500, 
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
	rareness = 700, 
	yank = 500, 
	force = 0, 
	mindepth = 200, 
	maxdepth = 20000,
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
	rareness = 1000, 
	yank = 2000, 
	force = 0, 
	mindepth = 100, 
	maxdepth = 20000,
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
	rareness = 2000, 
	yank = 0, 
	force = 0, 
	mindepth = 200, 
	maxdepth = 20000,
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

fishingmod.AddCatch{
	friendly = "Weapons",
	type = {
		"weapon_crowbar",
		"weapon_pistol",
		"weapon_smg1",
		"weapon_frag",
		"weapon_physcannon",
		"weapon_crossbow",
		"weapon_shotgun",
		"weapon_357",
		"weapon_rpg",
		"weapon_ar2",
		"gmod_tool",
		"gmod_camera",
		"weapon_physgun",
		"weapon_fishing_rod",
		"weapon_stunstick",
	},
	rareness = 1500, 
	yank = 150, 
	force = 0, 
	mindepth = 200, 
	maxdepth = 20000,
	remove_on_release = false,
	friendlybait = "Ammo",
	bait = {
		"models/Items/357ammo.mdl",
		"models/Items/357ammobox.mdl",
		"models/Items/grenadeAmmo.mdl",
		"models/Items/combine_rifle_ammo01.mdl",
		"models/Items/BoxBuckshot.mdl",
		"models/Items/BoxMRounds.mdl",
		"models/Items/BoxFlares.mdl",
		"models/Items/AR2_Grenade.mdl",
	},
}

fishingmod.AddCatch{
	friendly = "Weapons",
	type = {
		"Pistol", 
		"SMG1", 
		"grenade", 
		"Buckshot", 
		"357", 
		"XBowBolt", 
		"AR2Fire", 
		"rpg_round",
		"AR2AltFire", 
		"smg1_grenade", 
		"slam", 
	},
	rareness = 1500, 
	yank = 150, 
	force = 0, 
	mindepth = 200, 
	maxdepth = 20000,
	remove_on_release = false,
	friendlybait = "weapons",
	bait = {
		"models/weapons/w_crowbar.mdl", 
		"models/weapons/w_pistol.mdl",
		"models/weapons/w_smg1.mdl",
		"models/weapons/w_grenade.mdl",
		"models/weapons/w_physcannon.mdl", 
		"models/weapons/w_crossbow.mdl",
		"models/weapons/w_shotgun.mdl",
		"models/weapons/w_357.mdl",
		"models/weapons/w_rpg.mdl",
		"models/weapons/w_irifle.mdl",
		"models/weapons/w_toolgun.mdl", 
		"models/weapons/w_pistol.mdl",
		"models/weapons/w_superphyscannon.mdl",
		"models/weapons/w_stunstick.mdl",
	},
}


local divider = CreateConVar("fishing_mod_divider", 1, true, false)

--[[ 			local dynamite = (rod:GetHook():GetHookedEntity() and rod:GetHook():GetHookedEntity():GetClass() == "gmod_dynamite") and rod:GetHook():GetHookedEntity() or false
			--print(rod:GetHook():GetHookedEntity(), rod:GetHook():GetHookedEntity() and rod:GetHook():GetHookedEntity():GetClass() == "gmod_dynamite" , rod:GetHook():GetHookedEntity())
			--print(dynamite)
			local explode
			if dynamite and not dynamite.OldExplode then
				dynamite.OldExplode = dynamite.Explode
				function dynamite.Explode(self, delay, ply)
					explode = self:GetPos()
					dynamite.OldExplode(self, delay, ply)
				end
			end
				if explode and rod:GetHook():GetHookedEntity() and rod:GetHook():WaterLevel() >= 1 then
					for i=1, math.random(7) do
						local entity = ents.Create(data.type)
						if not IsValid(entity) then
							entity = ents.Create("prop_physics")
							entity:SetModel(data.type)
						end
						entity.data = data
						entity:SetPos(explode+VectorRand()*100)
						entity:Spawn()						
					end
				end
 ]]
hook.Add("Think", "Fishing Mod Think", function()
	for key, fire in pairs(ents.GetAll()) do 
		if fire:IsOnFire() then
			for key, catch in pairs(ents.FindInSphere(fire:GetPos(), fire:BoundingRadius()*2)) do
				if catch:GetNWBool("fishingmod catch") then
					local distance = math.max(catch:GetPos():Distance(fire:GetPos()) * -1 + fire:BoundingRadius()*2, 0) / 50
					catch.data.fried = catch.data.fried or 0
					catch.data.fried = math.Clamp(catch.data.fried + math.Ceil(distance), 0, 1000)
					local colorvalue = math.Clamp(catch.data.fried/800*-255+255, 0, 255)
					local redvalue = math.Clamp(catch.data.fried/1000*-255+255, 0, 255)
					local r,g,b = redvalue, colorvalue, colorvalue
					catch:SetColor(r,g,b,255)
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

function fishingmod.SetClientInfo(entity, ply)

	local rp = RecipientFilter()
	if not ply then 
		rp:AddAllPlayers()
	else 
		rp:AddPlayer(ply) 
	end
	
	umsg.Start("Fishingmod", rp)
		umsg.Short(entity:EntIndex() or 0)
		umsg.String(entity.data.friendly or "unknown")
		umsg.Long(entity.data.rareness or 0)
		umsg.Short(entity.data.mindepth or 0)
		umsg.Short(entity.data.maxdepth or 0)
		umsg.String(entity.data.friendlybait or "nothing")
		umsg.Long(entity.data.caught or 0)
		umsg.String(entity.data.owner or "unknown")
		umsg.Short(entity.data.fried or 0)
	umsg.End()
end

hook.Add("PlayerInitialSpawn", "Update Client Info", function(ply)
	timer.Simple(3, function()
		if not IsValid(ply) then return end
		for key, entity in pairs(ents.GetAll()) do
			if entity:GetNWBool("fishingmod catch") then
				fishingmod.SetClientInfo(entity, ply)
			end
		end
	end)
end)