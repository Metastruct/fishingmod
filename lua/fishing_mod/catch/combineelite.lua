local size = 8
local rareness = 12000
local yank = 500
local force = 0
local mindepth = 200
local maxdepth = 20000
local remove_on_release = false
local expgain = 600
local levelrequired = 100
local value = 2200
local bait = {
	"models/Items/combine_rifle_ammo01.mdl",
}

fishingmod.AddCatch{
	friendly = "Thumper",
	type = "prop_thumper",
	size = size,
	rareness = rareness, 
	yank = yank, 
	mindepth = mindepth, 
	maxdepth = maxdepth,
	expgain = expgain,
	value = value,
	levelrequired = levelrequired,
	remove_on_release = remove_on_release,
	bait = bait,

}

fishingmod.AddCatch{
	friendly = "Claw Scanner",
	type = "npc_clawscanner",
	size = size,
	rareness = rareness, 
	yank = yank, 
	mindepth = mindepth, 
	maxdepth = maxdepth,
	expgain = expgain,
	value = value,
	levelrequired = levelrequired,
	remove_on_release = remove_on_release,
	bait = bait,

}

fishingmod.AddCatch{
	friendly = "Hopper Mine",
	type = "combine_mine",
	size = size,
	rareness = rareness, 
	yank = yank, 
	mindepth = mindepth, 
	maxdepth = maxdepth,
	expgain = expgain,
	value = value,
	levelrequired = levelrequired,
	remove_on_release = remove_on_release,
	bait = bait,

}
