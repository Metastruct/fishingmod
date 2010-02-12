AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/meathook001a.mdl")
	self:SetOwner(self.bobber:GetOwner())
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(60)
		phys:SetDamping(1,1)
		phys:Wake()
	end

	self.last_velocity = Vector(0)
	self.last_angular_velocity = Vector(0)

	local constant =  math.min( self:GetPhysicsObject():GetMass(), self.bobber:GetPhysicsObject():GetMass() ) * 100
	local damp = constant * 0.2
	
	self.physical_rope = constraint.Elastic( self, self.bobber, 0, 0, Vector(0,1.2,6), Vector(0,0,4), 6000, 1200, 0, "cable/rope", 0.3, 1 )
	self.physical_rope:Fire("SetSpringLength", 50)

	fish_hook = self
end

function ENT:Hook( entity_to_create, force, existing )
	if ValidEntity(self.hooked) then return end
	force = force or 0
	if existing then
		self.hooked = entity_to_create
		entity_to_create:SetPos(self:GetPos())
		entity_to_create:SetOwner(self)
		if entity_to_create:IsNPC() then
			entity_to_create.oldmovetype = entity_to_create:GetMoveType()
			entity_to_create:SetMoveType(MOVETYPE_NONE)
			entity_to_create:SetParent(self)
		else
			constraint.Weld(entity_to_create, self, 0, 0, force)
		end
	else
		local entity = ents.Create(entity_to_create)
		if not ValidEntity(entity) then
			entity = ents.Create("prop_physics")
			entity:SetModel(entity_to_create)
		end
		entity:SetPos(self:GetPos())
		entity:SetOwner(self)
		entity:Spawn()
		if entity:IsNPC() then
			entity:SetParent(self)
			entity.oldmovetype = entity:GetMoveType()
			entity:SetMoveType(MOVETYPE_NONE)
		else
			constraint.Weld(entity, self, 0, 0, force)
		end
		self.hooked = entity
	end
end

function ENT:GetHookedEntity()
	return ValidEntity(self.hooked) and self.hooked or false
end

function ENT:UnHook()
	if self.hooked then
		self.hooked:SetOwner()
		if self.hooked:IsNPC() then
			self.hooked:SetAngles(Angle(0))
			self.hooked:SetMoveType(self.hooked.oldmovetype)
			self.hooked:SetParent()
		else
			constraint.RemoveConstraints(self.hooked, "Weld")
		end
		self.hooked = nil
	end
end

function ENT:OnRemove()
	self.hooked:SetParent()
	self.physical_rope:Remove()
end

function ENT:Think()
	if not constraint.FindConstraint(self.hooked, "Weld") then
		self.hooked = nil
	end
	if self.hooked and not ValidEntity(self.hooked) then
		self.hooked = nil
	end
	self:NextThink(CurTime())
	return true
end

function ENT:PhysicsSimulate(phys, deltatime)
	phys:Wake()
	if true then return end
	local linear_delta = phys:GetVelocity() * -20 + (phys:GetVelocity() - self.last_velocity * 20)

	local linear = linear_delta + phys:GetVelocity() * 4
	
	local angular_delta = (phys:GetAngleVelocity() * -50 + (phys:GetAngleVelocity() - self.last_angular_velocity * 5))
	
	local angular = angular_delta
	
	self.last_velocity = phys:GetVelocity()
	self.last_angular_velocity = phys:GetAngleVelocity()
		
	phys:AddVelocity(linear*deltatime)
	phys:AddAngleVelocity(angular*deltatime)
end