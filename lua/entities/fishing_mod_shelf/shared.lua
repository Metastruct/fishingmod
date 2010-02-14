ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.Category = "Fishing Mod"
ENT.PrintName = "Shelf Storage"

function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "ply")
end

function ENT:SetupStorage()
	local divider = 1.2
	self.storage = {
	[1] = { item = false, position = Vector( -16, 0, 40/divider) },
	[2] = { item = false, position = Vector( -8, 0, 40/divider) },
	[3] = { item = false, position = Vector( 0, 0, 40/divider) },
	[4] = { item = false, position = Vector( 8, 0, 40/divider) },
	[5] = { item = false, position = Vector( 16, 0, 40/divider) },
	
	[6] = { item = false, position = Vector( -16, 0, 20/divider) },
	[7] = { item = false, position = Vector( -8, 0, 20/divider) },
	[8] = { item = false, position = Vector( 0, 0, 20/divider) },
	[9] = { item = false, position = Vector( 8, 0, 20/divider) },
	[10] = { item = false, position = Vector( 16, 0, 20/divider) },
	
	[11] = { item = false, position = Vector( -16, 0, 0) },
	[12] = { item = false, position = Vector( -8, 0, 0) },
	[13] = { item = false, position = Vector( 0, 0, 0 ) },
	[14] = { item = false, position = Vector( 8, 0, 0) },
	[15] = { item = false, position = Vector( 16, 0, 0) },
	
	[16] = { item = false, position = Vector( -16, 0, -20/divider) },
	[17] = { item = false, position = Vector( -8, 0, -20/divider) },
	[18] = { item = false, position = Vector( 0, 0, -20/divider) },
	[19] = { item = false, position = Vector( 8, 0, -20/divider) },
	[20] = { item = false, position = Vector( 16, 0, -20/divider) },
	
	[21] = { item = false, position = Vector( -16, 0, -40/divider) },
	[22] = { item = false, position = Vector( -8, 0, -40/divider) },
	[23] = { item = false, position = Vector( 0, 0, -40/divider) },
	[24] = { item = false, position = Vector( 8, 0, -40/divider) },
	[25] = { item = false, position = Vector( 16, 0, -40/divider) },
	}
end

ENT:SetupStorage()