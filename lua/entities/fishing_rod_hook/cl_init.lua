language.Add("fishing_rod_hook","Fishing SOMETHING")

include("shared.lua")

function ENT:Initialize()
	self:SetModelScale(Vector()*0.3)
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:GetHookedEntity()
	return ValidEntity(self.dt.hooked) and self.dt.hooked or false
end