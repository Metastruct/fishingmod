fishingmod.AddCatch{
	friendly = "Present",
	type = "fishing_mod_catch_present",
	rareness = 20000, 
	yank = 100, 
	force = 0, 
	mindepth = 0, 
	maxdepth = 20000,
	expgain = 50,
	levelrequired = 0,
	remove_on_release = false,
	bait = "none"
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

function ENT:Initialize()
	local num = math.random(1,4)
	self:SetModel("models/effects/bday_gib0"..num..".mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Use(ply)
	fishingmod.GiveMoney(ply, math.random(100, 2000))
	timer.Create("Fishingmod:Present"..ply:EntIndex(), 0.2, 20, function()
		if not IsValid(ply) then timer.Destroy("Fishingmod:Present"..ply:EntIndex()) return end
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
	end)
	self:Remove()
end

scripted_ents.Register(ENT, "fishing_mod_catch_present", true)
