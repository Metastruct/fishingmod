AddCSLuaFile("cl_networking.lua")

function fishingmod.SetClientInfo(entity, ply)

	local rp = RecipientFilter()
	if not ply then 
		rp:AddAllPlayers()
	else 
		rp:AddPlayer(ply) 
	end
	
	umsg.Start("Fishingmod:Entity", rp)
		umsg.Short(entity:EntIndex() or 0)
		umsg.String(entity.data.friendly or "unknown")
		-- umsg.Long(entity.data.rareness or 0)
		-- umsg.Short(entity.data.mindepth or 0)
		-- umsg.Short(entity.data.maxdepth or 0)
		-- umsg.String(entity.data.friendlybait or "nothing")
		umsg.Long(entity.data.caught or 0)
		umsg.String(entity.data.owner or "unknown")
		umsg.Short(entity.data.fried or 0)
	umsg.End()
end

function fishingmod.UpdatePlayerInfo(ply)
	umsg.Start("Fishingmod:Player")
		umsg.Entity(ply)
		umsg.Long(ply.fishingmod_exp)
		umsg.Long(ply.fishingmod_catches)
	umsg.End()	
end