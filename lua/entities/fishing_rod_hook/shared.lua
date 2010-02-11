ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Bobber"

if CLIENT then

	function ENT:Draw()
		self:SetModelScale(Vector()*0.3)
		self:DrawModel()
	end

end