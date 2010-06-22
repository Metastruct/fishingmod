fishingmod.AddCatch{
	friendly = "Explosive Barrel",
	type = "prop_physics",
	models = {
		"models/props_c17/oildrum001_explosive.mdl",
	},
	size = 8,
	rareness = 1000, 
	yank = 2000, 
	mindepth = 100, 
	maxdepth = 20000,
	expgain = 30,
	levelrequired = 2,
	value = 30,
	remove_on_release = false,
	bait = {
		"models/props_explosive/explosive_butane_can02.mdl",
		"models/props_explosive/explosive_butane_can.mdl",
		"models/weapons/w_c4_planted.mdl",		
	},
}