fishingmod.AddCatch{
	friendly = "Dumb Fish",
	type = "fishing_mod_catch_fish",
	rareness = 4000, 
	yank = 0, 
	mindepth = 50, 
	maxdepth = 700,
	expgain = 300,
	levelrequired = 10,
	remove_on_release = false,
	scalable = "box",
	value = 700,
	bait = {
		"models/weapons/w_bugbait.mdl",
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

ENT.ThinkTime = 0.07

ENT.Models = {
	"models/props/cs_militia/fishriver01.mdl",
	"models/props/de_inferno/GoldFish.mdl",
}

function ENT:SpawnFunction(ply, trace)
	
	local entity = ents.Create("fishing_mod_fish")
	entity:Spawn()
	entity:SetPos(trace.HitPos + Vector(0,0,entity:BoundingRadius()*10))
	return entity
end


function ENT:Initialize()
	self:InitializeData()
	self:SetModel(table.Random(self.Models))
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:StartMotionController()
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
	self.avoider_angles = Angle(0)
	self.swim_down = Vector(0)	
	self.avoid = Angle(0)
	self.bothhit = false
	self.is_recatchable = true
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(10)
		phys:Wake()
	end

end

function ENT:CalculateAvoider(distance, eyesight, speed, target)
	target = target or NULL
	local aim = self:GetAngles():Forward()*distance
	local pos = self:GetPos()
	
	local radius = self:GetRight()*eyesight
	
	local trace_left = util.QuickTrace(pos, aim+(self:GetRight()*-eyesight), {self, target})
	local trace_right = util.QuickTrace(pos, aim+(self:GetRight()*eyesight), {self, target})
	local trace_up = util.QuickTrace(pos, (vector_up*-eyesight*2), {self, target})
	local trace_down = util.QuickTrace(pos, (vector_up*eyesight*2), {self, target})
	local trace_forward = util.QuickTrace(pos, aim, {self, target})

	local data = {}
	data.start = pos+Vector(0,0,500)
	data.endpos = pos
	data.mask = MASK_WATER
	data.filter = {self, target}
	local trace_water = util.TraceLine(data)
	
	if trace_forward.Fraction < 0.2 then
		debugoverlay.Line(pos, trace_forward.HitPos, self.ThinkTime, Color(255,0,0), true)
		self.avoider_angles.y = self.avoider_angles.y + speed
		
		return self.avoider_angles, true
	else
		debugoverlay.Line(pos, trace_forward.HitPos, self.ThinkTime,Color(255,255,255), true)
	end
	
	if trace_left.Hit then
		debugoverlay.Line(pos, trace_left.HitPos, self.ThinkTime, Color(255,0,0), true)
		self.avoider_angles.y = self.avoider_angles.y - speed
	else
		debugoverlay.Line(pos, trace_left.HitPos, self.ThinkTime,Color(255,255,255), true)
	end
	
	if trace_right.Hit then
		debugoverlay.Line(pos, trace_right.HitPos, self.ThinkTime, Color(255,0,0), true)
		self.avoider_angles.y = self.avoider_angles.y + speed
	else
		debugoverlay.Line(pos, trace_right.HitPos, self.ThinkTime,Color(255,255,255), true)
	end
	
	if trace_water.Fraction > 0.90 then
		debugoverlay.Line(pos, trace_water.HitPos, self.ThinkTime, Color(255,0,0), true)
		self.avoider_angles.p = self.avoider_angles.p - speed
	end
	
	if trace_up.Hit then
		debugoverlay.Line(pos, trace_up.HitPos, self.ThinkTime, Color(255,0,0), true)
		self.avoider_angles.p = self.avoider_angles.p + speed
	else
		debugoverlay.Line(pos, trace_up.HitPos, self.ThinkTime,Color(255,255,255), true)
	end
	
	if trace_down.Hit then
		debugoverlay.Line(pos, trace_down.HitPos, self.ThinkTime, Color(255,0,0), true)
		self.avoider_angles.p = self.avoider_angles.p - speed
	else
		debugoverlay.Line(pos, trace_down.HitPos, self.ThinkTime,Color(255,255,255), true)
	end
	
	if trace_right.Hit and trace_left.Hit then
		if trace_right.HitPos:Distance(pos) < trace_left.HitPos:Distance(pos) then
			self.avoider_angles.y = self.avoider_angles.y + (speed * 0.3)
		else
			self.avoider_angles.y = self.avoider_angles.y - (speed * 0.3)
		end
	end
	
	return self.avoider_angles, trace_right.Hit and trace_left.Hit
end

function ENT:CalculateLinear(phys, deltatime)
	self.last_velocity = phys:GetVelocity()
	local linear_delta = phys:GetVelocity() * -1 + (phys:GetVelocity() - self.last_velocity * 20)

	local linear = Vector(0)

	phys:AddVelocity(linear*deltatime)
end

function ENT:PhysicsSimulate(phys, deltatime)
	if self.dead then return end
	phys:Wake()
	
	if self:WaterLevel() >= 3 then	
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio( 0 )
		
		if constraint.FindConstraint(self, "Weld") then
			phys:AddVelocity(VectorRand()*1000)
			phys:AddAngleVelocity(VectorRand()*5000)
			return
		end
		
		self.target = nil
		self.avoid_target = nil
		
		for key, entity in pairs(ents.FindInSphere(self:GetPos(), 200)) do
			if entity:GetClass() == "fishing_rod_hook" and IsValid(entity.dt.bait) and entity.dt.bait:GetModel() == "models/weapons/w_bugbait.mdl" or entity:GetModel() == "models/weapons/w_bugbait.mdl" and entity:GetVelocity():Length() > 0 then
				self.target = entity
			end
			if entity:IsPlayer() then
				self.avoid_target = entity
			end
		end
				
		self.shadow = {}
		self.shadow.secondstoarrive = 0.5
		if IsValid(self.avoid_target) then
			self.shadow.pos = self:GetPos() + (self:GetPos() - self.avoid_target:GetPos()):Normalize() * 100 + self.swim_down
		elseif IsValid(self.target) then
			self.shadow.pos = self:GetPos() + (self.target:GetPos() - self:GetPos()):Normalize() * 50 + self.swim_down
		else
			self.shadow.pos = self:GetPos() +  self.avoid:Forward() * (not self.bothhit and 50 or -5) + self.swim_down
		end
		self.shadow.angle = phys:GetVelocity():Angle() 
		self.shadow.maxangular = 5000 
		self.shadow.maxangulardamp = 10000
		self.shadow.maxspeed = 1000000
		self.shadow.maxspeeddamp = 10000
		self.shadow.dampfactor = 0.8 
		self.shadow.teleportdistance = 200 
		self.shadow.deltatime = deltatime
	 
		phys:ComputeShadowControl(self.shadow)

	else
		self.swim_down = Vector(0,0,-10)
		timer.Create("Fish should swim down"..self:EntIndex(), 1, 1, function() if IsValid(self) then self.swim_down = Vector(0) end end)
		phys:EnableGravity(true)
		if math.random() > 0.99 then
			phys:AddAngleVelocity(VectorRand()*6000)
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	if dmginfo:GetDamage() > 10 and not self.dead then
		self.dead = true
		self:GetPhysicsObject():SetBuoyancyRatio( 1 )
		self:GetPhysicsObject():EnableGravity( true )
	end
end

function ENT:Think()
	if self.dead then return end
	self.avoid, self.bothhit = self:CalculateAvoider(50, 20, 2, self.target)
	self:NextThink(CurTime()+self.ThinkTime)
	return true
end

scripted_ents.Register(ENT, "fishing_mod_catch_fish", true)