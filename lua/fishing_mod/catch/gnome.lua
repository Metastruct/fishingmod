fishingmod.AddCatch{
	friendly = "Gnome",
	type = "fishing_mod_catch_gnome",
	rareness = 4000, 
	yank = 0, 
	mindepth = 400, 
	maxdepth = 800,
	expgain = 80,
	levelrequired = 15,
	remove_on_release = false,
	value = 500,
	scalable = "box",
	bait = {
		"models/weapons/w_bugbait.mdl",
		"models/props_gameplay/bottle001.mdl",
		"models/props_junk/garbage_glassbottle001a.mdl",
		"models/props_junk/garbage_glassbottle002a.mdl",
		"models/weapons/w_models/w_bottle.mdl",
		"models/props_junk/GlassBottle01a.mdl",
		"models/props_junk/glassjug01.mdl",
		"models/props_junk/garbage_glassbottle003a.mdl",
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

function ENT:Initialize()
	self:InitializeData()
	self:SetModel("models/props_junk/gnome.mdl")
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
	self:StartMotionController()
	
	self.TauntTime = 0
	self.is_recatchable = false
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetDamping(0,0)
		phys:Wake()
		phys:SetBuoyancyRatio( 1 )
	end
	
end

function ENT:Talk()
	
	local num = math.random(1,19)
	if num <= 9 then
		num = "0"..num
	end	
	
	self:EmitSound("vo/taunts/heavy_taunts"..num..".wav", 100, math.random(110,120))
	
	self.TauntTime = CurTime()+10
	
end

function ENT:Use(activator, caller)
	if self.dead then return end
	
	if self.TauntTime <= CurTime() then
		
		self:Talk()
		
	end
	
end
	
function ENT:PhysicsSimulate(phys, deltatime)
	if self.dead then return end
	phys:Wake()
	
	if self:WaterLevel() >= 3 then
		
		if constraint.FindConstraint(self, "Weld") then
			phys:AddVelocity(VectorRand()*100)
			phys:AddAngleVelocity(VectorRand()*80)
			return
		end
		
		local force = VectorRand()*80
		force.z = 100
		phys:AddVelocity(force)
		phys:AddAngleVelocity(Vector(0,0,360))
		
	else
		phys:AddVelocity(VectorRand()*10)
	end
end

function ENT:Revive()
	self.dead = false
end

ENT.DeathSound = {
	"vo/heavy_paincrticialdeath01.wav",
	"vo/heavy_paincrticialdeath02.wav",
	"vo/heavy_paincrticialdeath03.wav",
	"vo/heavy_painsevere01.wav",
	"vo/heavy_painsevere02.wav",
	"vo/heavy_painsevere03.wav",
	"vo/heavy_painsharp01.wav",
	"vo/heavy_painsharp02.wav",
	"vo/heavy_painsharp04.wav"
}

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	if (dmginfo:GetDamageType() == DMG_BURN or dmginfo:GetDamage() > 50) and not self.dead then
		self.dead = true
		self:EmitSound(table.Random(self.DeathSound), 100, math.random(110,120))
	end
end

function ENT:Think()
	if self.dead then return end
	
	if self:WaterLevel() < 3 then
		
		if math.random() > 0.95 and self.TauntTime <= CurTime() then
			
			self:Talk()
			
		end
		
	end
	self:NextThink(CurTime()+0.5)
	return true
	
end

scripted_ents.Register(ENT, "fishing_mod_catch_gnome", true)