AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:InitializeData()
	for key, value in pairs(fishingmod.CatchTable) do
		for key, type in pairs(value.type) do
			if type == self:GetClass() then
				self.data = fishingmod.CatchTable[value.friendly]
				break
			end
		end
	end
end

function ENT:StoreData(name, variable)
	self.data[name] = variable
end

function ENT:GetData(name)
	return self.data[name]
end