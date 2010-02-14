include("shared.lua")

local rope_material = Material("cable/rope")

function ENT:Draw()
	self:SetModelScale(Vector()*0.5)
	self:DrawModel()
	self:SetRenderBounds(Vector()*-1000, Vector()*1000)
	if ValidEntity(self.dt.hook) then
		render.SetMaterial(rope_material)
		render.DrawBeam(self:LocalToWorld(Vector(0,0,4)), self.dt.hook:LocalToWorld(Vector(0,1.3,6)), 0.1, 0, 0, Color(255,200,200,50))
	end
end