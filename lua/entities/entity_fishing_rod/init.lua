AddCSLuaFile( "shared.lua" )
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/harpoon002a.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():SetMass(100)
	--self:SetGravity(0)
	self:StartMotionController()

	self.shadow_params = {}
	
end

function ENT:PhysicsSimulate( phys, deltatime )
  
	phys:Wake()
	self:GetBobber():PhysWake()
	
	local position, angles = self.dt.avatar:GetBonePosition(self.dt.avatar:LookupBone("ValveBiped.Bip01_R_Hand"))
	local new_position, new_angles = LocalToWorld(self.PlayerOffset, self.PlayerAngles, position, angles)
	
	self.shadow_params.secondstoarrive = 0.0001
	self.shadow_params.pos = new_position
	self.shadow_params.angle = new_angles
	self.shadow_params.maxangular = 5000
	self.shadow_params.maxangulardamp = 10000
	self.shadow_params.maxspeed = 1000000
	self.shadow_params.maxspeeddamp = 10000
	self.shadow_params.dampfactor = 0.99
	self.shadow_params.teleportdistance = 200
	self.shadow_params.deltatime = deltatime
 
	phys:ComputeShadowControl(self.shadow_params)
 
end

function ENT:SetLength(length)
	self.physical_rope:Fire("SetSpringLength", length)
	
	local damping = math.Clamp(self.dt.attach:GetPos():Distance(self:LocalToWorld(self.RopeOffset))/100*-10+2, 0, 2)
	local length_damping = math.Clamp(length/10000*-2+2, 0, 1)
	self.dt.attach.damping = damping+length_damping
	self.length = length
	self.dt.length = length
end

function ENT:AttachRope()

	local constant =  math.min( self:GetPhysicsObject():GetMass(), self.dt.attach:GetPhysicsObject():GetMass() ) * 100
	local damp = constant * 0.2
	
	self.physical_rope, self.dt.rope = constraint.Elastic( self, self.dt.attach, 0, 0, self:LocalToWorld(self.RopeOffset), Vector(0,0,0), 6000, 1200, 0, "cable/rope", 0.3, 1 )
	
end

function ENT:AssignPlayer(ply)
	self:SetOwner(ply)
	--self:SetParent(ply)
	self.dt.ply = ply
	
	local entity = ents.Create("fishing_rod_bobber")
	timer.Simple(0.1, function() if ValidEntity(entity) then entity:SetPos(ply:GetShootPos()) end end)
	entity:SetOwner(ply)
	entity:Spawn()
	entity.rod = self
	
	self.avatar = ents.Create("fishing_mod_avatar")
	self.avatar.ply = ply
	self.avatar:Spawn()
	self.dt.avatar = self.avatar
	
	self:AttachEntity(entity)
	self:SetLength(100)
end

function ENT:AttachEntity(entity)
	self.dt.attach= entity
	self.dt.attach.parent = self	
	self:AttachRope()
end

function ENT:Think()
	if not ValidEntity(self.dt.ply) or not self.dt.ply:Alive() or not ValidEntity(self.dt.ply:GetNWEntity("fishing rod")) then self:Remove() return end
	--debugoverlay.Cross(self:GetPos(), 50, 0, Color(0,0,255,255))
	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	self.dt.attach:Remove()
	self.physical_rope:Remove()
	self.avatar:Remove()
end