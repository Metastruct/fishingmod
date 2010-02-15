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

usermessage.Hook("Fishingmod", function(um) 
	local entity = um:ReadShort()
	local friendly = um:ReadString()
	local rareness = um:ReadLong()
	local mindepth = um:ReadShort()
	local maxdepth = um:ReadShort()
	local bait = um:ReadString()
	local caught = um:ReadLong()
	local owner = um:ReadString()
	local fried = um:ReadShort()

	fishingmod.InfoTable[entity] = {
		friendly = friendly,
		rareness = RarenessToFriendly(rareness),
		rarenessnumber = rarenessnumber,
		mindepth = mindepth,
		maxdepth = maxdepth,
		bait = bait,
		caught = caught,
		owner = owner,
		cooked = FriedToFriendly(fried),
	}
	local text = Format([[
		<font=Default>
			This catch is called <font=DefaultUnderline>%s</font> and it's <font=DefaultUnderline>%s</font>.
			<font=DefaultUnderline>%s</font> caught this
			<font=DefaultUnderline>{TIME}</font>
			It can be caught at a depth between <font=DefaultUnderline>%u</font> to <font=DefaultUnderline>%s</font> units.
			This catch likes <font=DefaultUnderline>%s</font>.
			The catch is <font=DefaultUnderline>%s</font>.
		</font>
	]],
	friendly,
	RarenessToFriendly(rareness),
	owner,
	mindepth,
	maxdepth,
	bait,
	FriedToFriendly(fried)
	)
	local time = string.gsub(os.date("on %A, the $%d of %B, %Y, at %I:%M%p", caught), "$(%d%d)", function(n) return tonumber(n)..STNDRD(n) end)
	local text = string.gsub(text, "{TIME}", time)
	fishingmod.InfoTable[entity].mark_up = markup.Parse(text, ScrW()/4)
end)

hook.Add("Think", "Fishing Mod Think Client", function()
	for key, value in pairs(fishingmod.InfoTable or {}) do
		if not IsValid(Entity(key)) then
			print("invalid", Entity(key))
			fishingmod.InfoTable[key] = nil
		end
	end
end)