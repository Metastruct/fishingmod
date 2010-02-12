ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Angry Fish"

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end