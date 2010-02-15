AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:SpawnFunction(ply, trace)
	
	local entity = ents.Create("fishing_mod_boat")
	entity:Spawn()
	entity:SetPos(trace.HitPos + Vector(0,0,entity:BoundingRadius()))
	
	return entity
end

function ENT:Use(ply)
	local velocity = ply:GetAimVector()*10
	velocity.z = 0
	self:GetPhysicsObject():AddVelocity(velocity)
end

function ENT:Initialize()
	self:SetModel("models/props_wasteland/boat_fishing02a.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:StartMotionController()
	self.keepupright = emts
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(50000)
		phys:SetDamping(0,100)
	end
end

function ENT:PhysicsSimulate(phys)
	local data = {}
	
	data.start = self:GetPos()
	data.endpos = self:GetPos() + Vector(0,0,-240)
	--data.filter = self
	data.mask = CONTENTS_WATER
	
	local trace = util.TraceLine(data)
		
	local invert_fraction = (trace.Fraction * -1 + 1)
	
	phys:SetDamping(invert_fraction*20, 50)
	phys:AddVelocity(Vector(0,0,100) * invert_fraction)
end