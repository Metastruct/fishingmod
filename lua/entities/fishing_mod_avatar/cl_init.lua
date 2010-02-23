include("shared.lua")

function ENT:Initialize( )
	self.oldscale = self.dt.ply:GetModelScale()
end

function ENT:Draw()
	if not ValidEntity(self.dt.ply) then return end
	self:DrawModel()
	self.dt.ply:SetModelScale(Vector(0))
	self:Animate()
end