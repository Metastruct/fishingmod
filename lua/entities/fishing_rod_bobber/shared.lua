ENT.Type = "anim"
ENT.Base = "fishing_mod_base"
ENT.PrintName = "Bobber"
ENT.TopOffset = Vector(0,0,4)
ENT.BottomOffset = Vector(0,0,-5)

function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "hook")
end
