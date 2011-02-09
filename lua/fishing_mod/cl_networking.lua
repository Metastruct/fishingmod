fishingmod.InfoTable = fishingmod.InfoTable or {}
fishingmod.InfoTable.Catch = fishingmod.InfoTable.Catch or {}
fishingmod.InfoTable.Bait = fishingmod.InfoTable.Bait or {}

local function FriedToFriendly(number)
	if number == 0 then
		return "not cooked at all"
	elseif number < 200 then
		return "cooked rare"
	elseif number < 300 then
		return "cooked medium rare"
	elseif number < 500 then
		return "cooked medium"
	elseif number < 600 then
		return "cooked medium well"
	elseif number < 700 then
		return "cooked well done"
	elseif number < 900 then
		return "almost burnt" 
	elseif number <= 1000 then
		return "burnt"
	end
end

usermessage.Hook("Fishingmod:BaitPrices", function(um)
	local name = um:ReadString()
	local multiplier = um:ReadFloat()
	if not fishingmod.BaitTable[name] then return end
	fishingmod.BaitTable[name].multiplier = multiplier
	fishingmod.UpdateSales()
end)

usermessage.Hook("Fishingmod:Player", function(um) 
	local ply = um:ReadEntity()
	local exp = um:ReadLong()
	local catch = um:ReadLong()
	local money = um:ReadLong()
	local length = um:ReadChar()
	local reel_speed = um:ReadChar()
	local string_length = um:ReadShort()
	local force = um:ReadShort()
	local spawned = um:ReadBool()
	
	ply.fishingmod = ply.fishingmod or {}
	
	ply.fishingmod.length = length
	ply.fishingmod.reel_speed = reel_speed
	ply.fishingmod.string_length = string_length
	ply.fishingmod.force = force
	
	ply.fishingmod.money = money
	ply.fishingmod.level = fishingmod.ExpToLevel(exp)
	ply.fishingmod.last_level = ply.fishingmod.level
	ply.fishingmod.percent = fishingmod.PercentToNextLevel(exp)
	ply.fishingmod.expleft = fishingmod.ExpLeft(exp)
	ply.fishingmod.exp = exp
	ply.fishingmod.catches = catch

	if ply.fishingmod.level ~= 0 and ply.fishingmod.last_level ~= ply.fishingmod.level and not spawned then
		ply:EmitSound("ambient/levels/canals/windchime2.wav", 100, 200)
	end
end)

usermessage.Hook("Fishingmod:Catch", function(um) 
	local entity = um:ReadShort()
	local friendly = um:ReadString()
	local caught = um:ReadLong()
	local owner = um:ReadString()
	local fried = um:ReadShort()
	local value = um:ReadLong()
	
	value = value == 0 and "????" or value

	fishingmod.InfoTable.Catch[entity] = {
		friendly = friendly,
		caught = caught,
		owner = owner,
		cooked = FriedToFriendly(fried),
		value = value,
	}
	local text = Format([[
		This catch is called %s 
		and it is %s
		%s caught this
		{TIME}
		You can sell this catch 
		by pressing reload for $%s.
	]],
	friendly,
	FriedToFriendly(fried),
	owner,
	value
	)
	local time = string.gsub(os.date("on %A, the $%d of %B, %Y, at %I:%M%p", caught), "$(%d%d)", function(n) return n..STNDRD(tonumber(n)) end)
	local text = string.gsub(text, "{TIME}", time)
	fishingmod.InfoTable.Catch[entity].text = text
end)

usermessage.Hook("Fishingmod:Bait", function(um) 
	local entity = um:ReadShort()
	local owner = um:ReadString()
	
	local ply = SinglePlayer() and LocalPlayer() or player.GetByUniqueID(owner)
	
	if not IsValid(ply) then return end

	fishingmod.InfoTable.Bait[entity] = {
		owner = owner,
	}
	local text = Format([[
		This bait is owned by %s.
	]],
	ply:Nick()
	)
	fishingmod.InfoTable.Bait[entity].text = text
end)

hook.Add("Tick", "Fishingmod.CleanInfo:Tick", function()
	for key, value in pairs(fishingmod.InfoTable.Catch) do
		if not IsValid(Entity(key)) then
			fishingmod.InfoTable.Catch[key] = nil
		end
	end
	for key, value in pairs(fishingmod.InfoTable.Bait) do
		if not IsValid(Entity(key)) then
			fishingmod.InfoTable.Bait[key] = nil
		end
	end
end)