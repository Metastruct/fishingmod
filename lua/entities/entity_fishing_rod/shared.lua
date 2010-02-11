ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.PrintName = "fishng rod"
ENT.ModelScale = Vector(3,1,1)
ENT.PlayerOffset = Vector(76,-1,-128)
ENT.PlayerAngles = Angle(60,0,0)
ENT.RopeOffset = Vector(120,0,0)


function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "ply")
	self:DTVar("Entity", 1, "attach")
	self:DTVar("Entity", 2, "avatar")
	self:DTVar("Int", 0, "length")
end

function ENT:GetBobber()
	return ValidEntity(self.dt.attach) and self.dt.attach or false
end

function ENT:GetHook()
	return ValidEntity(self.dt.attach.dt.hook) and self.dt.attach.dt.hook or false
end

function ENT:GetPlayer()
	return ValidEntity(self.dt.ply) and self.dt.ply or false
end

function ENT:GetAvatar()
	return ValidEntity(self.dt.avatar) and self.dt.avatar or false
end

function ENT:GetLength()
	return self.dt.length or 0
end

function ENT:GetDepth()
	local fish_hook = self.dt.attach.dt.hook
	if ValidEntity(fish_hook) and fish_hook or false then
		local trace = util.QuickTrace(fish_hook:GetPos(), Vector(0,0,-10000), fish_hook)
		return (trace.StartPos - trace.HitPos):Length()
	end
	return 0
end

if CLIENT then
	local rope_material = Material("cable/rope")
	
	function ENT:Draw()
		if ValidEntity(self:GetBobber()) then
			self:SetRenderBounds(Vector()*-1000, Vector()*1000)
			render.SetMaterial(rope_material)
			render.DrawBeam(self:LocalToWorld(self.RopeOffset), self:GetBobber():LocalToWorld(Vector(0,0,0)), 0.1, 0, 0, Color(255,200,200,50))
		end
		self:DrawModel()
		self:SetModelScale(self.ModelScale)
	end
	
	function ENT:Initialize()
		self.sound_rope = CreateSound(self, "weapons/tripwire/ropeshoot.wav")
		self.sound_rope:Play()
		self.sound_rope:ChangePitch(0)
		
		self.sound_reel = CreateSound(self, "fishingrod/reel.wav")
		self.sound_reel:Play()
		self.sound_reel:ChangePitch(0)
		self.last_length = 0
	end
	
	function ENT:Think()
	 	local delta = self.dt.length - self.last_length
	
		local velocity_length = self.dt.attach:GetVelocity():Length()
		local pitch = velocity_length/10 - 0.1
		local volume = velocity_length/1000 - 0.1
		local reel_velocity = self.dt.length - self.last_length
		
		local on = (delta ~= 0) and 1 or 0
		self.sound_reel:ChangePitch(math.Clamp(math.abs(100+delta*10),80,200))
		self.sound_reel:ChangeVolume(on)
			
		self.sound_rope:ChangePitch(math.Clamp(pitch, 50, 255))
		self.sound_rope:ChangeVolume(math.Clamp(volume, 0, 1))
		
		self.last_length = self.dt.length
		self:NextThink(CurTime())
		return true
	end
	
	function ENT:OnRemove()
		self.sound_reel:Stop()
		self.sound_rope:Stop()
	end
end