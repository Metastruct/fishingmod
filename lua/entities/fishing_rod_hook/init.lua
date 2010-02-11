AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/meathook001a.mdl")
	self:PhysicsInitBox(Vector()*-1,Vector())
	self:PhysWake()
	self:SetOwner(self.bobber:GetOwner())
	self:GetPhysicsObject():SetMass(10)
	self:StartMotionController()

	self.last_velocity = Vector(0)
	self.last_angular_velocity = Vector(0)
	
	self.physical_rope = ents.Create("phys_spring")
	self.physical_rope:SetPhysConstraintObjects( self:GetPhysicsObject(), self.bobber:GetPhysicsObject() )
	self.physical_rope:SetPos( self:LocalToWorld(Vector(0,0,0)) )
	self.physical_rope:SetKeyValue( "springaxis", tostring(Vector(0,0,0)) )
	self.physical_rope:SetKeyValue( "constant", 2000 )
	self.physical_rope:SetKeyValue( "damping", 0 )
	self.physical_rope:SetKeyValue( "rdamping", 1 )
	self.physical_rope:SetKeyValue( "spawnflags", 1)
	self.physical_rope:Spawn()
	self.physical_rope:Activate()
	self.physical_rope:Fire("SetSpringLength", 50)

	fish_hook = self
end

function ENT:Hook( entity_to_create )
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
		constraint.Weld(entity, self)
	end

	self.hooked = entity
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
	self.physical_rope:Remove()
end

function ENT:Think()
	if self.hooked and not ValidEntity(self.hooked) then
		self.hooked = nil
	end
	self:NextThink(CurTime())
	return true
end

function ENT:PhysicsSimulate(phys, deltatime)
	phys:Wake()
	local linear_delta = phys:GetVelocity() * -5 + (phys:GetVelocity() - self.last_velocity * 20)

	local linear = linear_delta + phys:GetVelocity() * 20
	
	local angular_delta = (phys:GetAngleVelocity() * -50 + (phys:GetAngleVelocity() - self.last_angular_velocity * 5))
	
	local angular = angular_delta
	
	self.last_velocity = phys:GetVelocity()
	self.last_angular_velocity = phys:GetAngleVelocity()
		
	phys:AddVelocity(linear*deltatime)
	phys:AddAngleVelocity(angular*deltatime)
end