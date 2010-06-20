fishingmod.InfoTable = fishingmod.InfoTable or {}

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

usermessage.Hook("Fishingmod:Entity", function(um) 
	local entity = um:ReadShort()
	local friendly = um:ReadString()
	local caught = um:ReadLong()
	local owner = um:ReadString()
	local fried = um:ReadShort()
	local value = um:ReadLong()
	
	value = value == 0 and "????" or value

	fishingmod.InfoTable[entity] = {
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
		You can sell this catch by holding
		reload and press use for $%s.
	]],
	friendly,
	FriedToFriendly(fried),
	owner,
	value
	)
	local time = string.gsub(os.date("on %A, the $%d of %B, %Y, at %I:%M%p", caught), "$(%d%d)", function(n) return tonumber(n)..STNDRD(n) end)
	local text = string.gsub(text, "{TIME}", time)
	fishingmod.InfoTable[entity].text = text
end)

hook.Add("Think", "Fishingmod:Think", function()
	for key, value in pairs(fishingmod.InfoTable or {}) do
		if not IsValid(Entity(key)) then
			fishingmod.InfoTable[key] = nil
		end
	end
end)