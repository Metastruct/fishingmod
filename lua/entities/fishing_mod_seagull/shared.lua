ENT.Type = "anim"
ENT.Base = "fishing_mod_base"
ENT.AutomaticFrameAdvance = true

if CLIENT then
	function ENT:Think()
		--self:SetModelScale(Vector(1,1,1)*10)
		self.cycle = self.cycle or 0
		self.cycle = self.cycle + FrameTime() * 4
		
		self:SetCycle(self.cycle%2)
		self:ResetSequence(self:LookupSequence("fly"))
		--self:SetPlaybackRate(10)
		self:NextThink(CurTime())
		return true
	end

end