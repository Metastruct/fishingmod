include("shared.lua")

function ENT:Initialize( )
	self.oldscale = self.dt.ply:GetModelScale()
	self:SetupHook("RenderScene")
end

function ENT:Draw()
	if not ValidEntity(self.dt.ply) then return end
	self:DrawModel()
	self.dt.ply:SetModelScale(Vector(0))
	-- Draw is too slow, use RenderScene.
end

function ENT:RenderScene(a,b)
	self:Animate()
end