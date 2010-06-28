AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:InitializeData()
	for key, value in pairs(fishingmod.CatchTable) do
		if type(value.type) == "string" then self.data = fishingmod.CatchTable[value.friendly] break end
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

function ENT:PostEntityPaste()
	self:Remove()
end

function ENT:PreHook(ply, recatch) end
function ENT:PreRelease(ply) end
function ENT:PreSell(ply) end

function ENT:PostHook(ply, recatch) end
function ENT:PostRelease(ply) end