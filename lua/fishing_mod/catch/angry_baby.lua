if SERVER then
	fishingmod.AddCatch{
		friendly = "Angry Baby",
		type = "fishing_mod_catch_angry_baby",
		rareness = 2000, 
		yank = 0, 
		mindepth = 200, 
		maxdepth = 20000,
		expgain = 50,
		levelrequired = 3,
		remove_on_release = false,
		value = 150,
		scalable = "box",
		bait = {
			"models/props_junk/watermelon01.mdl",
			"models/props_junk/watermelon01_chunk01a.mdl",
			"models/props_junk/watermelon01_chunk01b.mdl",
			"models/props_junk/watermelon01_chunk01c.mdl",
			"models/props_junk/watermelon01_chunk02a.mdl",
			"models/props_junk/watermelon01_chunk02b.mdl",
			"models/props_junk/watermelon01_chunk02b.mdl",
			"models/props_junk/watermelon01_chunk02c.mdl",
		},
	}
end

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then

	function ENT:Initialize()
		self:InitializeData()
		self:SetModel("models/props_c17/doll01.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		self:StartMotionController()
		self.is_recatchable = true
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(100)
			phys:SetDamping(0,0)
			phys:Wake()
			phys:SetBuoyancyRatio( 0 )
		end	
	end

	timer.Create("AngryBaby:FindTarget", 1, 0, function() 
		local number_of_babies = #ents.FindByClass("fishing_mod_catch_angry_baby")
		if number_of_babies == 0 then return end
		local baby = ents.FindByClass("fishing_mod_catch_angry_baby")[math.random(number_of_babies)]
		for key, entity in pairs(ents.FindInSphere(baby:GetPos(), 10000)) do
			if entity:GetClass() == "prop_physics" and entity:WaterLevel() >= 1 and string.find(entity:GetModel() or "", "melon") then
				fishingmod.AngryBabyTarget = entity
				return
			end
			if entity:GetClass() == "prop_physics" and string.find(entity:GetModel() or "", "melon") then
				fishingmod.AngryBabyTarget = entity
				return
			end
			if IsValid(entity) and entity:GetClass() == "prop_physics" and (entity:GetClass() ~= "fishing_mod_catch_angry_baby" and entity:GetVelocity():Length() > 20) then
				fishingmod.AngryBabyTarget = entity
			end
		end		
	end)

	function ENT:PhysicsSimulate(phys, deltatime)
		if self.dead then return end
		phys:Wake()

		if self:WaterLevel() >= 3 then
			phys:SetDamping(3,0)
			if constraint.FindConstraint(self, "Weld") then
				phys:AddVelocity(VectorRand()*1000)
				phys:AddAngleVelocity(VectorRand()*5000)
				return
			end
		
			if ValidEntity(self.target) then
				phys:AddVelocity((self.target:GetPos() - self:GetPos()))
				phys:AddAngleVelocity(VectorRand()*2000)
			else
				phys:AddVelocity(VectorRand()*200)
				phys:AddAngleVelocity(VectorRand()*2000)
			end
		else
			phys:SetDamping(1, 0)
			if math.random() > 0.95 then
				if ValidEntity(self.target) then
					phys:AddVelocity((self.target:GetPos() - self:GetPos()):Normalize()*100)
					phys:AddAngleVelocity(VectorRand()*2000)
				else
					phys:AddVelocity(VectorRand()*200)
					phys:AddAngleVelocity(VectorRand()*2000)
				end
			end
		end
	end

	function ENT:Revive()
		self.dead = false
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		if (dmginfo:GetDamageType() == DMG_BURN or dmginfo:GetDamage() > 10) and not self.dead then
			self.dead = true
			self:GetPhysicsObject():SetBuoyancyRatio( 1 )
			self:EmitSound("ambient/creatures/teddy.wav", 100, math.random(90,110))
		end
	end

	function ENT:Think()
		if self.dead then return end
		
		self.target = fishingmod.AngryBabyTarget
		
		self:PhysWake()
			
		self:NextThink(CurTime()+0.3)
		return true
	end

end

scripted_ents.Register(ENT, "fishing_mod_catch_angry_baby", true)