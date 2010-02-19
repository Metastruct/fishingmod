fishingmod.InfoTable = fishingmod.InfoTable or {}

local function RarenessToFriendly(number)
	if number < 500 then
		return "very common"
	elseif number < 1000 then
		return "common"
	elseif number < 1500 then
		return "not so common"
	elseif number < 2000 then
		return "not so rare"
	elseif number < 4000 then
		return "rare"
	elseif number < 7000 then
		return "very rare"
	elseif number < 10000 then
		return "super rare"
	elseif number < 20000 then
		return "golden"
	end
end

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
	ply.fishingmod_level = fishingmod.ExpToLevel(exp)
	if ply.fishingmod_level ~= 0 and ply.fishingmod_last_level ~= ply.fishingmod_level then
		ply:EmitSound("ambient/levels/canals/windchime2.wav", 100, 200)
	end
	ply.fishingmod_last_level = ply.fishingmod_level
	ply.fishingmod_percent = fishingmod.PercentToNextLevel(exp)
	ply.fishingmod_expleft = fishingmod.ExpLeft(exp)
	ply.fishingmod_exp = exp
	ply.fishingmod_catches = catch
end)

usermessage.Hook("Fishingmod:Entity", function(um) 
	local entity = um:ReadShort()
	local friendly = um:ReadString()
	-- local rareness = um:ReadLong()
	-- local mindepth = um:ReadShort()
	-- local maxdepth = um:ReadShort()
	-- local bait = um:ReadString()
	local caught = um:ReadLong()
	local owner = um:ReadString()
	local fried = um:ReadShort()

	fishingmod.InfoTable[entity] = {
		friendly = friendly,
		--rareness = RarenessToFriendly(rareness),
		--rarenessnumber = rarenessnumber,
		--mindepth = mindepth,
		--maxdepth = maxdepth,
		--bait = bait,
		caught = caught,
		owner = owner,
		cooked = FriedToFriendly(fried),
	}
	local text = Format([[
		This catch is called %s.
		%s caught this
		{TIME}
		This catch is %s
	]],
	friendly,
--	RarenessToFriendly(rareness),
	owner,
	-- mindepth,
	-- maxdepth,
	-- bait,
	FriedToFriendly(fried)
	)
	local time = string.gsub(os.date("on %A, the $%d of %B, %Y, at %I:%M%p", caught), "$(%d%d)", function(n) return tonumber(n)..STNDRD(n) end)
	local text = string.gsub(text, "{TIME}", time)
	fishingmod.InfoTable[entity].text = text
end)

hook.Add("Think", "Fishingmod:Think", function()
	for key, value in pairs(fishingmod.InfoTable or {}) do
		if not IsValid(Entity(key)) then
			print("invalid", Entity(key))
			fishingmod.InfoTable[key] = nil
		end
	end
end)