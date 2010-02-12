AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/pottery01a.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
		
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(60)
		phys:SetDamping(0,1)
		phys:SetBuoyancyRatio(1)
		phys:SetMaterial("wood")
	end
			
end

function ENT:Yank( force )
	force = force or math.random( 50, 100 )
	self:GetPhysicsObject():AddVelocity( Vector( 0, 0, -force ) )
	self:EmitSound( "ambient/water/water_splash"..math.random(1,3)..".wav", 100, 255 )
end