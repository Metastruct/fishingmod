language.Add("fishing_rod_hook","Fishing SOMETHING")

include("shared.lua")

function ENT:Initialize()
	self:SetModelScale(Vector(1,1,1)*0.3)
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:GetHookedEntity()
	return IsValid(self.dt.hooked) and self.dt.hooked or false
end