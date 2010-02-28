function fishingmod.SavePlayerInfo(ply, name, data)
	file.Write("fishingmod/"..ply:UniqueID().."/"..name..".txt", data)
end

function fishingmod.LoadPlayerInfo(ply, name)
	return file.Read("fishingmod/"..ply:UniqueID().."/"..name..".txt")
end

function fishingmod.GainEXP(ply, amount)
	ply.fishingmod.exp = ply.fishingmod.exp + amount
	ply.fishingmod.catches = ply.fishingmod.catches + 1
	fishingmod.SavePlayerInfo(ply, "exp", ply.fishingmod.exp)
	fishingmod.SavePlayerInfo(ply, "catches", ply.fishingmod.catches)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.GiveMoney(ply, amount)
	ply.fishingmod.money = ply.fishingmod.money + amount
	fishingmod.SavePlayerInfo(ply, "money", ply.fishingmod.money)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.TakeMoney(ply, amount)
	ply.fishingmod.money = ply.fishingmod.money - amount
	fishingmod.SavePlayerInfo(ply, "money", ply.fishingmod.money)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.SetRodLength(ply, length, add_or_sub)
	if add_or_sub == "add" then
		ply.fishingmod.length = ply.fishingmod.length + length
	elseif add_or_sub == "sub" then
		ply.fishingmod.length = ply.fishingmod.length - length
	else
		ply.fishingmod.length = length
	end
	fishingmod.SavePlayerInfo(ply, "length", ply.fishingmod.length)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.SetRodReelSpeed(ply, speed, add_or_sub)
	if add_or_sub == "add" then
		ply.fishingmod.reel_speed = ply.fishingmod.reel_speed + speed
	elseif add_or_sub == "sub" then
		ply.fishingmod.reel_speed = ply.fishingmod.reel_speed - speed
	else
		ply.fishingmod.reel_speed = speed
	end
	fishingmod.SavePlayerInfo(ply, "reel_speed", ply.fishingmod.reel_speed)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.SetRodStringLength(ply, length, add_or_sub)
	if add_or_sub == "add" then
		ply.fishingmod.string_length = ply.fishingmod.string_length + length
	elseif add_or_sub == "sub" then
		ply.fishingmod.string_length = ply.fishingmod.string_length - length
	else
		ply.fishingmod.string_length = length
	end
	fishingmod.SavePlayerInfo(ply, "string_length", ply.fishingmod.string_length)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.SetHookForce(ply, force, add_or_sub)
	if add_or_sub == "add" then
		ply.fishingmod.force = ply.fishingmod.force + force
	elseif add_or_sub == "sub" then
		ply.fishingmod.force = ply.fishingmod.force - force
	else
		ply.fishingmod.force = force
	end
	fishingmod.SavePlayerInfo(ply, "force", ply.fishingmod.force)
	fishingmod.UpdatePlayerInfo(ply)
end

hook.Add("PlayerInitialSpawn", "Fishingmod:ExpPlayerJoined", function( ply )
	timer.Simple(3, function()
		if not IsValid(ply) then return end
		ply.fishingmod = {
			catches = tonumber(fishingmod.LoadPlayerInfo(ply, "catches") or 0),
			exp = tonumber(fishingmod.LoadPlayerInfo(ply, "exp") or 0),
			money = tonumber(fishingmod.LoadPlayerInfo(ply, "money") or 0),
			length = tonumber(fishingmod.LoadPlayerInfo(ply, "length") or 0),
			reel_speed = tonumber(fishingmod.LoadPlayerInfo(ply, "reel_speed") or 0),
			string_length = tonumber(fishingmod.LoadPlayerInfo(ply, "string_length") or 0),
			force = tonumber(fishingmod.LoadPlayerInfo(ply, "force") or 0),	
		}
		fishingmod.UpdatePlayerInfo(ply, true)
	end)
end)