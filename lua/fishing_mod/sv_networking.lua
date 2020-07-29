util.AddNetworkString("Fishingmod:Catch")
util.AddNetworkString("Fishingmod:Bait")
util.AddNetworkString("Fishingmod:Player")
util.AddNetworkString("Fishingmod:BaitPrices")

function fishingmod.SetCatchInfo(entity, ply)
	local rp = RecipientFilter()
	if not ply then 
		rp:AddAllPlayers()
	else 
		rp:AddPlayer(ply) 
	end
	
	entity.data = entity.data or {}
	
	net.Start("Fishingmod:Catch")
		net.WriteInt(entity:EntIndex() or 0, 16)
		net.WriteString(entity.data.friendly or "unknown")
		net.WriteInt(entity.data.caught or 0, 32)
		net.WriteString(
			entity.data.owner and (
			type(entity.data.owner)=="string" and entity.data.owner or 
			
				IsValid(entity.data.owner) and 
				entity.data.owner:Nick()
			) or 
			"Unknown")
		net.WriteInt(entity.data.fried or 0, 16)
		net.WriteInt(entity.data.value or 0, 32)
	net.Send(rp)
end

function fishingmod.SetBaitInfo(entity, ply)
	local rp = RecipientFilter()
	if not ply then 
		rp:AddAllPlayers()
	else 
		rp:AddPlayer(ply) 
	end
	
	entity.data = entity.data or {}
	
	net.Start("Fishingmod:Bait")
		net.WriteInt(entity:EntIndex() or 0, 16)
		net.WriteString(entity.data.ownerid or "unknown")
	net.Send(rp)
end

function fishingmod.UpdatePlayerInfo(ply, spawned)
	net.Start("Fishingmod:Player")
		net.WriteEntity(ply)
		net.WriteDouble(ply.fishingmod.exp)
		net.WriteDouble(ply.fishingmod.catches)
		net.WriteDouble(ply.fishingmod.money)
		net.WriteDouble(ply.fishingmod.length)
		net.WriteDouble(ply.fishingmod.reel_speed)
		net.WriteDouble(ply.fishingmod.string_length)
		net.WriteDouble(ply.fishingmod.force)
		net.WriteBool(spawned or false)
	net.Broadcast()	
end

function fishingmod.SetBaitSale(bait, multiplier, ply)
	fishingmod.BaitTable[bait].multiplier = multiplier
	local hasplayers = player.GetHumans()[1]
	
	if not IsValid(ply) and not hasplayers then return end
	
	net.Start("Fishingmod:BaitPrices")
	net.WriteString(bait)
	net.WriteFloat(multiplier) 
	
	if IsValid(ply) then
		net.Send(ply)
	elseif hasplayers then
		net.Broadcast()
	end
end
