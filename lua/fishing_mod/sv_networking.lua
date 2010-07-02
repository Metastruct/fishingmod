function fishingmod.SetCatchInfo(entity, ply)
	local rp = RecipientFilter()
	if not ply then 
		rp:AddAllPlayers()
	else 
		rp:AddPlayer(ply) 
	end
	
	entity.data = entity.data or {}
	
	umsg.Start("Fishingmod:Catch", rp)
		umsg.Short(entity:EntIndex() or 0)
		umsg.String(entity.data.friendly or "unknown")
		umsg.Long(entity.data.caught or 0)
		umsg.String(entity.data.owner.Nick and entity.data.owner:Nick() or entity.data.owner or "unknown")
		umsg.Short(entity.data.fried or 0)
		umsg.Long(entity.data.value or 0)
	umsg.End()
end

function fishingmod.SetBaitInfo(entity, ply)
	local rp = RecipientFilter()
	if not ply then 
		rp:AddAllPlayers()
	else 
		rp:AddPlayer(ply) 
	end
	
	entity.data = entity.data or {}
	
	umsg.Start("Fishingmod:Bait", rp)
		umsg.Short(entity:EntIndex() or 0)
		--umsg.String(entity.data.friendly or "unknown")
		umsg.String(entity.data.ownerid or "unknown")
	umsg.End()
end

function fishingmod.UpdatePlayerInfo(ply, spawned)
	umsg.Start("Fishingmod:Player")
		umsg.Entity(ply)
		umsg.Long(ply.fishingmod.exp)
		umsg.Long(ply.fishingmod.catches)
		umsg.Long(ply.fishingmod.money)
		umsg.Char(ply.fishingmod.length)
		umsg.Char(ply.fishingmod.reel_speed)
		umsg.Short(ply.fishingmod.string_length)
		umsg.Short(ply.fishingmod.force)
		umsg.Bool(spawned or false)
	umsg.End()	
end

function fishingmod.SetBaitSale(bait, multiplier, ply)
	fishingmod.BaitTable[bait].multiplier = multiplier
	umsg.Start("Fishingmod:BaitPrices", ply)
		umsg.String(bait)
		umsg.Float(multiplier)
	umsg.End()
end