include("shared.lua")

local rope_material = Material("cable/rope")

function ENT:Draw()
	if ValidEntity(self:GetBobber()) then
		render.SetMaterial(rope_material)
		render.DrawBeam(self:LocalToWorld(self.RopeOffset), self:GetBobber():GetPos(), 0.1, 0, 0, Color(255,200,200,50))
	end
	self:SetRenderBounds(Vector()*-1000, Vector()*1000)
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