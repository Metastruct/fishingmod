AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/harpoon002a.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:StartMotionController()
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(100)
		phys:Wake()
	end

	self.shadow_params = {}
	
end

function ENT:PhysicsSimulate( phys, deltatime )
  
	phys:Wake()
	local bobber = self:GetBobber()
	if bobber then
		bobber:PhysWake()
	end
	
	local position, angles = self.dt.ply:GetBonePosition(self.dt.ply:LookupBone("ValveBiped.Bip01_R_Hand"))
	local new_position, new_angles = LocalToWorld(Vector(25,0,-42) * self.dt.rod_length + Vector(-2,-1,0) * self.dt.rod_length, Angle(60,0,90), position, angles)
	
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
	if not IsValid(self.physical_rope) then return end
	self.physical_rope:Fire("SetSpringLength", length/2+10)
	self:GetHook().physical_rope:Fire("SetSpringLength", length/2+10)
	self.dt.length = length
end

function ENT:AssignPlayer(ply)
	self:SetOwner(ply)

	self.dt.ply = ply
	
	local position = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Hand"))
	
	local bobber = ents.Create("fishing_rod_bobber")
	bobber.rod = self
	bobber:SetOwner(ply)
	bobber:SetPos(position)
	bobber:Spawn()
	hook.Call("PlayerSpawnedSENT", gmod.GetGamemode(), ply, bobber)
	if bobber.CPPISetOwner then bobber:CPPISetOwner(ply) end
	
	self.dt.attach = bobber
	
	local fish_hook = ents.Create("fishing_rod_hook")
	fish_hook.bobber = bobber
	fish_hook:SetOwner(ply)
	fish_hook:SetPos(position)
	fish_hook:Spawn()
	hook.Call("PlayerSpawnedSENT", gmod.GetGamemode(), ply, fish_hook)
	if fish_hook.CPPISetOwner then fish_hook:CPPISetOwner(ply) end
	
	local bait = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector()*400, {ply, self, bobber, fish_hook}).Entity
	if IsValid(bait) then
		fishingmod.HookBait(ply, bait, fish_hook)
	end
	
	bobber.dt.hook = fish_hook
			
	self.dt.attach.parent = self
	
	self.physical_rope, self.dt.rope = constraint.Elastic( self, self.dt.attach, 0, 0, self:LocalToWorld(Vector(40,0,0) * self.dt.rod_length), Vector(0,0,0), 6000, 1200, 0, "", 0, 1 )
	
	self:SetLength(100)

	ply:SetEyeAngles(Angle(10,ply:EyeAngles().y,0))
	
	fishingmod.UpdatePlayerInfo(ply)
	
end

function ENT:Think()
	if not ValidEntity(self.dt.ply) or not self.dt.ply:Alive() or not ValidEntity(self.dt.ply:GetNWEntity("fishing rod")) then self:Remove() return end
	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	SafeRemoveEntity(self.dt.attach)
	SafeRemoveEntity(self.physical_rope)
	SafeRemoveEntity(self.avatar)
	SafeRemoveEntity(self.dt.attach.dt.hook)
end