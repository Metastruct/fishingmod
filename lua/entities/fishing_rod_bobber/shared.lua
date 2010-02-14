ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Bobber"

function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "hook")
end
