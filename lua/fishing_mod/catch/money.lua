fishingmod.AddCatch{
	friendly = "Small Money",
	type = "fishing_mod_catch_money",
	rareness = 2000, 
	yank = 100, 
	mindepth = 0, 
	maxdepth = 20000,
	expgain = 50,
	levelrequired = 0,
	remove_on_release = false,
	cant_sell = true,
	bait = {
		"models/props_c17/cashregister01a.mdl",
		"models/props_misc/cash_register.mdl",
	}
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

function ENT:Initialize()
	self:SetModel("models/props/cs_assault/Money.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Use(ply)
	ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
	fishingmod.GiveMoney(ply, math.random(100,500))
	self:Remove()
end

scripted_ents.Register(ENT, "fishing_mod_catch_money", true)

fishingmod.AddCatch{
	cant_sell = true,
	friendly = "Big Money",
	type = "fishing_mod_catch_money_big",
	rareness = 20000, 
	yank = 100, 
	force = 0, 
	mindepth = 0, 
	maxdepth = 20000,
	expgain = 50,
	levelrequired = 0,
	remove_on_release = false,
	bait = {
		"models/props_c17/cashregister01a.mdl",
		"models/props_misc/cash_register.mdl",
	}
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

function ENT:Initialize()
	self:SetModel("models/props/cs_assault/MoneyPalletA.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Use(ply)
	timer.Create("Fishingmod:BigMoneyCatch"..ply:EntIndex(), 0.1, 50, function()
		if not IsValid(ply) then timer.Destroy("Fishingmod:BigMoneyCatch"..ply:EntIndex()) return end
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
	end)
	fishingmod.GiveMoney(ply, math.random(10000,15000))
	self:Remove()
end

scripted_ents.Register(ENT, "fishing_mod_catch_money_big", true)
