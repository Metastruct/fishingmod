include("shared.lua")
AddCSLuaFile("shared.lua")

function ENT:Initialize()
	self.is_ragdoll = true
	self:SetModel("models/seagull.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:StartMotionController()
	self:PhysWake()
	
	if not IsValid(self.target) then self:PickTarget() end
	
	self:SetupHook("EntityTakeDamage")
	
	bird = self
	
	local phys = self:GetPhysicsObject()
	
	if IsValid(phys) then
		phys:SetMass(1000)
	end
	
	timer.Create("SeagullRemove "..self:EntIndex(), 200, 1, function()
		if IsValid(self) then
			self:Remove()
		end
	end)
end

function ENT:PickTarget()
	for key, catch in RandomPairs(ents.GetAll()) do
		local owner 
		if catch.data then
			owner = catch:GetOwner()
		end
		if 
			catch:GetNWBool("fishingmod catch") and 
			catch.data and 
			util.TraceLine({start = self:GetPos(), endpos = catch:GetPos(), filter = self}).Entity == catch and 
			owner and 
			owner:GetPos():Distance(catch:GetPos()) < 5000 and
			catch:WaterLevel() == 0
		then
			constraint.RemoveAll(self)
			constraint.RemoveAll(catch)
			self.target = catch
			self.owner = owner
			break
		end
	end
end

function ENT:Think()
	if not IsValid(self.target) then self:PickTarget() end
	self:NextThink(CurTime()+3)
	return true
end

function ENT:SetTarget(entity)
	self.target = entity
end

function ENT:SetTargetOwner(player)
	self.owner = player
end

function ENT:PhysicsSimulate(phys)
	
	local target = IsValid(self.target) and self.target
	local owner = IsValid(self.owner) and self.owner
			
	phys:Wake()
	phys:EnableMotion(true)
	
	if owner and target and owner:GetPos():Distance(self:GetPos()) > 13000 then 
		self:Remove()
	end
					
	if not target then self:Remove() return end
			
	local params = {}
	
	if constraint.FindConstraint(self, "Weld") and IsValid(owner) then
		params.secondstoarrive = 0.5
		
		local trace_forward = util.QuickTrace(self:GetPos(), self:GetForward()*5000, {self, target})
		
		params.angle = (self:GetForward() + trace_forward.HitNormal):Angle()
		params.pos = self:GetPos() + (self:GetForward() + trace_forward.HitNormal) * 100
		params.dampfactor = 0.1
	else
		local direction = target:GetPos()-self:GetPos()
		params.secondstoarrive = 1
		params.pos = target:GetPos()
		params.angle = direction:Angle()
		params.dampfactor = 0.4
	end
	
	params.maxangular = 5000 
	params.maxangulardamp = 10000
	params.maxspeed = 1000000
	params.maxspeeddamp = 10000
	params.teleportdistance = 0 
 
	phys:ComputeShadowControl(params)
end

function ENT:Touch(entity)
	if entity == self.target then
		constraint.Weld(entity, self, 0, 0, 40000)
	end
end

function ENT:EntityTakeDamage(ent, inflictor, attacker, amount, data)
  data=inflictor
  inflictor=data:GetInflictor()
  attacker=data:GetAttacker()
  amount=data:GetDamage()
  
	if ent ~= self then return end
	if data:IsBulletDamage() and attacker:IsPlayer() then
		local ragdoll = ents.Create("prop_ragdoll")
		ragdoll:SetModel(self:GetModel())
		ragdoll:SetPos(self:GetPos())
		ragdoll:SetAngles(self:GetAngles())
		ragdoll.data = {
			value = 1000, 
			friendly = "Dead Seagull",
			caught = os.time(),
			owner = attacker:Nick(),
			ownerid = attacker:UniqueID(),
		}
		ragdoll:SetNWBool("fishingmod catch", true)
		ragdoll:Spawn()
		if ragdoll.CPPISetOwner then ragdoll:CPPISetOwner(attacker) end
		fishingmod.SetCatchInfo(ragdoll)
		self:Remove()
	end
end