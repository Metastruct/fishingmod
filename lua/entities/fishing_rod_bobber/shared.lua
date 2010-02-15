ENT.Type = "anim"
ENT.Base = "fishing_mod_base"
ENT.PrintName = "Bobber"

function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "hook")
end
