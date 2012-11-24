language.Add("fishing_rod_bobber","Fishing Bobber")

include("shared.lua")

local rope_material = Material("cable/rope")

function ENT:Draw()
	self:SetModelScale(Vector(0.5,0.5,0.5))
	self:DrawModel()
	self:SetRenderBounds(Vector(1,1,1)*-1000, Vector(1,1,1)*1000)
	if IsValid(self.dt.hook) then
		render.SetMaterial(rope_material)
		render.DrawBeam(self:LocalToWorld(self.BottomOffset), self.dt.hook:LocalToWorld(Vector(0,1.3,6)), 0.1, 0, 0, Color(255,200,200,50))
	end
end