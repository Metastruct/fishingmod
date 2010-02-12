fishingmod = {}

function _R.Player:GetFishingRod()
	return ValidEntity(self:GetNWEntity("fishing rod")) and self:GetNWEntity("fishing rod") or false
end

concommand.Add("fishing_mod_drop_catch", function(ply)
	local fishing_rod = ply:GetFishingRod()
	if fishing_rod then
		fishing_rod:GetHook():UnHook()
	end
end)

fishingmod.CatchTable = {}

function fishingmod.AddCatch(name, rareness, yank, force)
	fishingmod.CatchTable[name] = {name = name, rareness = rareness, yank = yank, force = force}
end

function fishingmod.RemoveCatch(name)
	fishingmod.CatchTable[name] = nil
end

fishingmod.AddCatch("models/props_junk/Shoe001a.mdl", 1200, 150, 700)
fishingmod.AddCatch("fishing_mod_fish", 2500, 500, 2500)

hook.Add("Think", "Fishing Mod Think", function() 
	for key, ply in pairs(player.GetAll()) do
		local rod = ply:GetFishingRod()
		if rod then
			for key, value in pairs(fishingmod.CatchTable) do
				if math.random(math.max(value.rareness-math.min(math.ceil(rod:GetBobber():GetVelocity():Length()/4),100),1)) == 1 then
					if not rod:GetHook():GetHookedEntity() and rod:GetHook():WaterLevel() >= 1 then
						rod:GetHook():Hook(value.name, value.force)
						rod:GetBobber():Yank(value.yank)
					end
				end
			end
		end
	end
end)