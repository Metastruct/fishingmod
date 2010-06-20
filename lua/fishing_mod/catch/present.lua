if SERVER then
	fishingmod.AddCatch{
		cant_sell = true,
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
end
local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

PrecacheParticleSystem("bday_confetti")

if SERVER then
	function ENT:Initialize()
		local num = math.random(1,4)
		self:SetModel("models/effects/bday_gib0"..num..".mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	end

	function ENT:Use(ply)
		ParticleEffect("bday_confetti",ply:GetPos(),Angle(0,0,0),ply)
		ply:EmitSound("misc/happy_birthday.wav",100,100)
		local num = math.random(100, 2000)
		if not fishingmod.Sell(ply, self, num) then return end
		timer.Create("Fishingmod:Present"..ply:EntIndex(), 0.2, math.Round(num/100), function()
			if not IsValid(ply) then timer.Destroy("Fishingmod:Present"..ply:EntIndex()) return end
			ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
		end)
		self:Remove()
	end
end
scripted_ents.Register(ENT, "fishing_mod_catch_present", true)
