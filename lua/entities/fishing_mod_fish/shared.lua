ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Angry Fish"


function ENT:SetupDataTables()
	self:DTVar("Float", 0, "scale")
end

if CLIENT then
	function ENT:Initialize()
		self:SetModelScale(Vector()*self.dt.scale)
	end
	function ENT:Draw()
		self:DrawModel()
	end
end