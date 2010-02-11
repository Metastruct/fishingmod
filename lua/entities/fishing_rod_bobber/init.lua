AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/pottery01a.mdl")
	self:PhysicsInitSphere(1)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:StartMotionController()
	self:GetPhysicsObject():EnableGravity(false)
	
	self.last_velocity = Vector(0)
	self.last_angular_velocity = Vector(0)
		
	local fish_hook = ents.Create("fishing_rod_hook")
	fish_hook.bobber = self
	timer.Simple(0.1, function() if ValidEntity(fish_hook) then fish_hook:SetPos(self:GetPos()) end end)
	fish_hook:Spawn()
	self.dt.hook = fish_hook
end

function ENT:Yank( force )
	force = force or math.random( 50, 100 )
	self:GetPhysicsObject():AddVelocity( Vector( 0, 0, -force ) )
	self:EmitSound( "ambient/water/water_splash"..math.random(1,3)..".wav", 100, 255 )
end

function ENT:OnRemove()
	self.dt.hook:Remove()
end

function ENT:PhysicsSimulate(phys, deltatime)	
	phys:Wake()

	local data = {}
	
	data.start = self:GetPos()
	data.endpos = self:GetPos()+Vector(0,0,-30)
	data.filter = self
	data.mask = CONTENTS_WATER
	
	local trace = util.TraceLine(data)
	
	local force_fraction = (trace.Fraction * -1 + 1)

	local damp_fraction = math.Clamp((trace.Fraction * -1 + 1), 0, 1) * 20
		
	local linear_delta = phys:GetVelocity() * -(4+damp_fraction) + (phys:GetVelocity() - self.last_velocity * 20)

	local linear = linear_delta / 8
	
	local angular_delta = (phys:GetAngleVelocity() * -50 + (phys:GetAngleVelocity() - self.last_angular_velocity * 5))
			
	local angular = angular_delta
	
	self.last_velocity = phys:GetVelocity()
	self.last_angular_velocity = phys:GetAngleVelocity()
		
	linear = linear + (Vector(0,0,1500) * force_fraction)
	
--	print(self.rod:GetPlayer(), linear_delta:Length())
	
	phys:AddVelocity(linear*deltatime + Vector(0,0,-20))
	phys:AddAngleVelocity(angular*deltatime)
end