fishingmod.AddCatch{
	friendly = "Sawray",
	type = "fishing_mod_catch_sawray",
	rareness = 3500, 
	yank = 0, 
	mindepth = 640, 
	maxdepth = 20000,
	expgain = 60,
	levelrequired = 8,
	remove_on_release = false,
	value = 300,
	scalable = "sphere",
	bait = {
		"models/props_junk/watermelon01.mdl",
		"models/props_junk/watermelon01_chunk01a.mdl",
		"models/props_junk/watermelon01_chunk01b.mdl",
		"models/props_junk/watermelon01_chunk01c.mdl",
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"
if SERVER then
	function ENT:Initialize()
		self:InitializeData()
		self:SetModel("models/props_junk/sawblade001a.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		self:StartMotionController()
		
		self.is_recatchable = true
		
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMaterial("zombieflesh")
			phys:SetMass(60)
			phys:SetDamping(0,0)
			phys:Wake()
			phys:SetBuoyancyRatio( 0 )
		end	
	end

	timer.Create("Sawray:FindTarget", 1, 0, function() 
		local number_of_sawrays = #ents.FindByClass("fishing_mod_catch_sawray")
		if number_of_sawrays == 0 then return end
		local saw = ents.FindByClass("fishing_mod_catch_sawray")[math.random(number_of_sawrays)]
		for key, entity in pairs(ents.FindInSphere(saw:GetPos(), 10000)) do
			if entity:GetClass() == "prop_physics" and entity:WaterLevel() >= 1 and string.find(entity:GetModel() or "", "melon") then
				fishingmod.SawRayTarget = entity
				return
			end
		end		
	end)

	function ENT:PhysicsSimulate(phys, deltatime)
		if self.dead then return end
		phys:Wake()
		
		if self:WaterLevel() >= 3 then
			phys:SetDamping(3,0)
			if constraint.FindConstraint(self, "Weld") then
				phys:AddVelocity(VectorRand()*100)
				phys:AddAngleVelocity(VectorRand()*80)
				return
			end
			
			if ValidEntity(self.target) then
				phys:AddVelocity((self.target:GetPos() - self:GetPos()):Normalize()*80)
				phys:AddAngleVelocity(Vector(0,0,360))
			else
				phys:AddVelocity(self:GetForward()*20 - Vector(0,0,4))
				phys:AddAngleVelocity(Vector(0,0,math.random(-180,180)))
				
				local TD = {}
				TD.start = self:GetPos()
				TD.endpos = self:GetPos()-Vector(0,0,8)
				TD.filter = self
				local TR = util.TraceLine(TD)
				
				if TR.Hit then
					phys:AddVelocity((self:GetPos()-TR.HitPos)*10)
				end
			end
			
		else
			phys:SetDamping(1, 0)
			if math.random() > 0.95 then
				phys:AddVelocity(VectorRand()*50)
				phys:AddAngleVelocity(Vector(0,0,360))
			end
		end
	end

	function ENT:Revive()
		self.dead = false
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		if (dmginfo:GetDamageType() == DMG_BURN or dmginfo:GetDamage() > 15) and not self.dead then
			self.dead = true
			self:GetPhysicsObject():SetBuoyancyRatio( 1 )
			self:GetPhysicsObject():SetDamping(0, 0)
			self:EmitSound("ambient/creatures/teddy.wav", 100, math.random(60,80))
		end
	end

	function ENT:Think()
		if self.dead then return end
		
		self.target = fishingmod.SawRayTarget
		
		self:GetPhysicsObject():Wake()
		
		self:NextThink(CurTime()+0.3)
		return true
	end
end
scripted_ents.Register(ENT, "fishing_mod_catch_sawray", true)