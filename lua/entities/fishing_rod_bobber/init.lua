AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/lamp001a.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:StartMotionController()
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(60)
		phys:SetDamping(0,100)
		phys:SetMaterial("wood")
	end
end

function ENT:CanTool() return false end
function ENT:CanProperty() return false end

function ENT:Yank( force )
	force = force or math.random( 50, 100 )
	self:GetPhysicsObject():AddVelocity( Vector( 0, 0, -force ) )
	self:EmitSound( "ambient/water/water_splash"..math.random(1,3)..".wav", 100, 255 )
	local data = EffectData()
	data:SetOrigin(self:GetPos())
	data:SetScale(force*0.01)
	util.Effect("WaterSplash", data)
end

function ENT:PhysicsSimulate(phys)
	local data = {}
	
	data.start = self:GetPos()
	data.endpos = self:GetPos()+Vector(0,0,-30)
	data.filter = self
	data.mask = CONTENTS_WATER
	
	local trace = util.TraceLine(data)
	
	local invert_fraction = (trace.Fraction * -1 + 1)
	
	phys:SetDamping(invert_fraction*20, 100)
	phys:AddVelocity(Vector(0,0,19) * invert_fraction)

	if math.random() > 0.99 and trace.Hit then
		local data = EffectData()
		data:SetOrigin(trace.HitPos)
		data:SetScale(5)
		util.Effect("WaterRipple", data)
	end
end