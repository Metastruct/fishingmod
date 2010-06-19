fishingmod.AddCatch{
	friendly = "Ichthyosaur",
	type = "fishing_mod_catch_ichthyosaur",
	rareness = 8000, 
	yank = 100, 
	mindepth = 700, 
	maxdepth = 20000,
	expgain = 7000,
	levelrequired = 40,
	remove_on_release = false,
	value = 800,
	bait = {
		"models/Gibs/Antlion_gib_Large_1.mdl",
		"models/Gibs/Antlion_gib_Large_2.mdl",
		"models/Gibs/Antlion_gib_Large_3.mdl",
		"models/Gibs/Strider_Gib1.mdl",
		"models/Gibs/Strider_Gib2.mdl"
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

ENT.Sounds = {
	
	Growl = {
		Sound("npc/ichthyosaur/attack_growl1.wav"),
		Sound("npc/ichthyosaur/attack_growl2.wav"),
		Sound("npc/ichthyosaur/attack_growl3.wav")
	}
	
}

function ENT:Initialize()
	self:InitializeData()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInitSphere(48)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
	self:StartMotionController()
	
	self:SetColor(0,0,0,0)
	
	self.InAttack = 1
	
	self.is_recatchable = true
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(2000)
		phys:Wake()
		phys:SetBuoyancyRatio( 0 )
		phys:SetMaterial("flesh")
	end
	
	self.body = ents.Create("prop_dynamic")
	self.body:SetModel("models/ichthyosaur.mdl")
	self.body:SetAngles(Angle(0,90,0))
	self.body:SetPos(self:GetPos() + self.body:GetForward()*32)
	self.body:SetParent(self)
	
	self.NextMove = 1
	self.ShadowParams = {}
	self.ShadowParams.secondstoarrive = 8
	self.ShadowParams.maxangular = 10000
	self.ShadowParams.maxangulardamp = 50000
	self.ShadowParams.maxspeed = 2000000
	self.ShadowParams.maxspeeddamp = 100000
	self.ShadowParams.dampfactor = 1
	self.ShadowParams.teleportdistance = 0
	
	self.dead = false
	self.health = 500
	
	self.Sounds.Breath = CreateSound(self, "npc/ichthyosaur/water_breath.wav")
	self.Sounds.Breath:SetSoundLevel(70)
	self.NextGrowl = 1
	self.NextAttackGrowl = 1
	
	self.random = math.Rand (0.2,1.3)
	
end

function ENT:Revive()
	self.health = 500
	self.dead = false
end

function ENT:OnTakeDamage(dmginfo)
	
	self:TakePhysicsDamage(dmginfo)
	if self.dead then return end
	
	self.health = self.health - dmginfo:GetDamage()
	if self.health <= 0 then
		self.dead = true
		self.health = 0
		self.Sounds.Breath:Stop()
		self:EmitSound(table.Random(self.Sounds.Growl),150,math.random(80,90))
	end
	
end

function ENT:OnRemove()
	
	self.body:Remove()
	self.Sounds.Breath:Stop()
	
end

function ENT:PhysicsSimulate(phys,deltatime)
	if self.dead then return end
	
	phys:Wake()
	
	if self:WaterLevel() >= 3 then
		
		if constraint.FindConstraint(self, "Weld") then --hooked Move
			phys:AddVelocity(VectorRand()*100)
			phys:AddAngleVelocity(VectorRand()*200)
			return
		end
		
		self.ShadowParams.secondstoarrive = 8
		
		local TR = {}
		TR.start = self:GetPos()
		TR.endpos = TR.start + self.body:GetForward()*1000
		TR.filter = {self,self.body}
		TR = util.TraceLine(TR)
		
		if IsValid(self.target) then --Target Move
			
			self.ShadowParams.secondstoarrive = self.random
			local gotoang = (self.target:GetPos()-self:GetPos()):Angle()
			gotoang:RotateAroundAxis(self:GetUp(),-90)
			self.ShadowParams.angle = gotoang
			
			local trace = util.QuickTrace(self:GetPos(), self.body:GetForward()*100, {self,self.body})
			
			local lerp = math.Clamp(self:GetPos():Distance(self.target:GetPos())/200, 0, 1)*trace.Fraction
			self.ShadowParams.pos = LerpVector(
				lerp,
				self.target:GetPos(),
				self:GetPos() + self.body:GetForward() * 200
			)
			
		else --Normal Move
			
			self.ShadowParams.pos = TR.HitPos+TR.HitNormal*32
			if self.NextMove < CurTime() then
				
				self.ShadowParams.angle = Angle( 0, math.random(0,360), math.random(-10,0) )
				self.ShadowParams.deltatime = deltatime
				
				self.NextMove=CurTime()+5
				
			end
			
		end
		
		phys:ComputeShadowControl(self.ShadowParams)
		
	else
		phys:AddVelocity(VectorRand()*50)
		phys:AddAngleVelocity(VectorRand()*100)
	end
	
end

function ENT:Think()
	if self.dead then --Dead Think
		self.body:SetPlaybackRate(0)
		self.body:ResetSequence(self.body:LookupSequence("attackmiss"))
		self.body:SetCycle(100)
		return
	end
	if self:WaterLevel() >= 3 then --In water Think
		
		self.Sounds.Breath:Play()
		
		local speed = math.Clamp(self:GetVelocity():Length(),0,500)
		self.body:SetPlaybackRate(speed/500)
		self.body:ResetSequence(self.body:LookupSequence("swim"))
		
		for _,ent in pairs(ents.FindInSphere(self:GetPos(),1000)) do
			
			if ent:IsPlayer() and ent:WaterLevel()>=3 and ent:Alive() then
				self.target = ent
				break
			end
			if ent:GetClass()=="prop_physics" and ent:WaterLevel()>=3 and string.find(ent:GetModel():lower() or "","gib", 0, true) then
				self.target = ent
			else
				self.target = nil
			end
			
		end
		
	else --Out of water Think
		
		self.target = nil
		
		self.Sounds.Breath:Stop()
		if self.NextGrowl <= CurTime() then
			self:EmitSound(table.Random(self.Sounds.Growl),150,math.random(90,110))
			self.NextGrowl = CurTime()+math.random(2,8)
		end
		
		self.body:SetPlaybackRate(1)
		self.body:ResetSequence(self.body:LookupSequence("thrash"))
		
	end
	for _,ent in pairs(ents.FindInSphere(self.body:GetPos()+self.body:GetForward()*16,12)) do
		
		if ent:IsPlayer() and ent:Alive() then
			self.body:SetPlaybackRate(1)
			self.body:ResetSequence(self.body:LookupSequence("attackstart"))
			if self.NextAttackGrowl <= CurTime() then
				self:EmitSound(table.Random(self.Sounds.Growl),150,math.random(90,110))
				self.NextAttackGrowl = CurTime()+2
			end
			ent:Kill()
		end
		
	end
	
	self:NextThink(CurTime()+0.5)
	return true
	
end

scripted_ents.Register(ENT, "fishing_mod_catch_ichthyosaur", true)