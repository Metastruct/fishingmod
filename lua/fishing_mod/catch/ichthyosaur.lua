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

if SERVER then

	ENT.Sounds = {
		
		Growl = {
			Sound("npc/ichthyosaur/attack_growl1.wav"),
			Sound("npc/ichthyosaur/attack_growl2.wav"),
			Sound("npc/ichthyosaur/attack_growl3.wav")
		}
		
	}

	function ENT:Initialize()
		self:InitializeData()
		self:SetModel("models/props_wasteland/rockcliff01g.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
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
		local ang = self:GetAngles()
		ang:RotateAroundAxis(self:GetRight(),90)
		self.body:SetAngles(ang)
		self.body:SetPos(self:GetPos() + self.body:GetForward()*64)
		self.body:SetParent(self)
		
		
		self.ShadowParams = {}
		self.ShadowParams.secondstoarrive = 8
		self.ShadowParams.maxangular = 15000
		self.ShadowParams.maxangulardamp = 20000
		self.ShadowParams.maxspeed = 2000000
		self.ShadowParams.maxspeeddamp = 10000
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
			self:EmitSound(table.Random(self.Sounds.Growl),150,math.random(70,80))
			return
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
				
			elseif IsValid(self.target) then --Target Move
				
				self.ShadowParams.secondstoarrive = self.random
				local gotoang = (self.target:GetPos()-self.body:GetPos()):Angle()
				gotoang:RotateAroundAxis(self:GetRight(),-90)
				
				self.ShadowParams.angle = gotoang
				
				local trace = util.QuickTrace(self.body:GetPos(), self.body:GetForward()*100, {self,self.body})
				
				local lerp = math.Clamp(self.body:GetPos():Distance(self.target:GetPos())/200, 0, 1)*trace.Fraction
				self.ShadowParams.pos = LerpVector(
					lerp,
					self.target:GetPos(),
					self.body:GetPos() + self.body:GetForward() * 200
				)
				
			else --Normal Move
				
				self.ShadowParams.secondstoarrive = 4
				
				local TR = util.QuickTrace(self.body:GetPos(), self.body:GetForward()*1000 - Vector(0,0,32), {self,self.body})
				
				local gotopos = Vector()
				if TR.Hit then
					gotopos = TR.HitPos + TR.HitNormal*500
				else
					gotopos = TR.HitPos
				end
				
				self.ShadowParams.pos = gotopos 
				
				local gotoang = Angle()
				if TR.Hit then
					gotoang = ((TR.HitPos + TR.HitNormal*500)-self.body:GetPos()):Angle()
				else
					gotoang = (TR.HitPos - self.body:GetPos()):Angle()
				end
				gotoang.p = 0
				gotoang.r = 0
				gotoang:RotateAroundAxis(self:GetRight(),-90)
				
				self.ShadowParams.angle = gotoang
				
			end
			
			self.ShadowParams.deltatime = deltatime
			phys:ComputeShadowControl(self.ShadowParams)
			
		else
			
			phys:AddVelocity(VectorRand()*50)
			phys:AddAngleVelocity(VectorRand()*100)
			
		end
		
	end

	function ENT:Think()
		if self.data.fried then
			self.body:SetColor(fishingmod.FriedToColor(self.data.fried))
		end
	
		if self.dead then --Dead Think
			
			self.body:SetPlaybackRate(1)
			self.body:ResetSequence(self.body:LookupSequence("attackstart"))
			self.body:SetCycle(7)
			self.body:SetPlaybackRate(0)
			
		elseif self:WaterLevel() >= 3 then --In water Think
			
			self.Sounds.Breath:Play()
			
			local speed = math.Clamp(self:GetVelocity():Length(),0,500)
			self.body:SetPlaybackRate(speed/500)
			self.body:ResetSequence(self.body:LookupSequence("swim"))
			
			for _,ent in pairs(ents.FindInSphere(self:GetPos(),1024)) do
				
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
		if not self.dead then
			for _,ent in pairs(ents.FindInSphere(self.body:GetPos()+self.body:GetForward()*84,12)) do
				
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
		end
		
		self:NextThink(CurTime()+0.5)
		return true
		
	end
	
else
	
	function ENT:Draw()
		self:DrawShadow(false)
		return false
	end

end

scripted_ents.Register(ENT, "fishing_mod_catch_ichthyosaur", true)