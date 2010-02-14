include("shared.lua")

function ENT:Draw()
	if not ValidEntity(self.dt.ply) then return end
	self.dt.ply:SetNoDraw(true)
	self.dt.ply:SetMaterial("Models/effects/vol_light001")
	self:DrawModel()
	self:SetPos(self.dt.ply:GetPos())
	self:SetAngles(Angle(0,self.dt.ply:EyeAngles().y,0))
	self:SetPoseParameter("move_yaw", math.AngleDifference(self.dt.ply:GetVelocity():Angle().y, self.dt.ply:GetLocalAngles().y))
	self:SetPoseParameter("aim_pitch", self.dt.ply:EyeAngles().p)
	
	local moving = self.dt.ply:KeyDown(IN_FORWARD) or self.dt.ply:KeyDown(IN_BACK) or self.dt.ply:KeyDown(IN_MOVELEFT) or self.dt.ply:KeyDown(IN_MOVERIGHT)
	local running = self.dt.ply:KeyDown(IN_SPEED)
	local sequence = "idle_melee2"
	
	if moving then
		sequence = "walk_melee2"
		if running then
			sequence = "run_melee2"
		end
	end
	
	if self.dt.ply:Crouching() then
		sequence = "cidle_melee2"
		if moving then
			sequence = "cwalk_melee2"
		end
	end
	self:SetCycle(self.dt.ply:GetCycle())
	self:SetSequence(self:LookupSequence(sequence))
end

function ENT:OnRemove()
	self.dt.ply:SetNoDraw(false)
	self.dt.ply:SetMaterial("")
end