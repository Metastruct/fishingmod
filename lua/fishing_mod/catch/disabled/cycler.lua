fishingmod.AddCatch{
	friendly = "Animated model",
	type = "cycler",
	models = {
		"models/alyx.mdl",
		"models/Barney.mdl",
		"models/breen.mdl",
		"models/gman_high.mdl",
		"models/Kleiner.mdl",
		"models/monk.mdl",
		"models/mossman.mdl",
		"models/odessa.mdl",
		"models/Police.mdl",
		"models/vortigaunt.mdl",
		"models/Combine_Super_Soldier.mdl",
		"models/Combine_Soldier_PrisonGuard.mdl",
		"models/dog.mdl"
	},
	rareness = 3000,
	yank = 1000,
	mindepth = 200,
	maxdepth = 20000,
	remove_on_release = false,
	expgain = 80,
	levelrequired = 10,
	value = 200,
	bait = {
		"models/props_lab/hevplate.mdl"
	}
}
LastCyclerUse = CurTime()

function CatchCyclerUse(ply, ent)
	if IsValid(ply) and IsValid(ent) and ent:GetClass() == "cycler" then
		if LastCyclerUse < CurTime() then
			ent:TakeDamage(1)
			LastCyclerUse = CurTime() + 1
		end
		return false
	end
end
hook.Add("PlayerUse", "FishingCyclerUse", CatchCyclerUse)