fishingmod = fishingmod or {}

function _R.Player:GetFishingRod()
	return ValidEntity(self:GetNWEntity("fishing rod")) and self:GetNWEntity("fishing rod") or false
end

function fishingmod.GetNWInfo(entity, typ, unique)
	entity.fishingmod_nw = entity.fishingmod_nw or {}
	if not entity.fishingmod_nw[typ] then return nil end
	if not entity.fishingmod_nw[typ][unique] then return nil end
	return entity.fishingmod_nw[typ][unique]
end

function fishingmod.FriedToColor(amount)
	local colorvalue = math.Clamp(amount/800*-255+255, 0, 255)
	local redvalue = math.Clamp(amount/1000*-255+255, 0, 255)
	return redvalue, colorvalue, colorvalue, 255
end

function fishingmod.SetData(entity, data)
	entity.data = data
	entity:SetColor(fishingmod.FriedToColor(data.fried or 0))
	entity:SetNWBool("fishingmod catch", true)
	entity:SetNWFloat("fishingmod size", data.size)
end

local pow = 1.8
local mult = 100

function fishingmod.ExpToLevel(exp)
	local unpow = 1/pow
	return math.floor((exp/mult) ^ unpow)
end

function fishingmod.LevelToExp(level)
	return level^pow * mult
end

function fishingmod.ExpLeft(exp, level)
	if level then return fishingmod.LevelToExp(level) - exp end
	return fishingmod.LevelToExp(fishingmod.ExpToLevel(exp) + 1) - exp
end

function fishingmod.PercentToNextLevel(exp)
	return fishingmod.ExpLeft(exp) / (fishingmod.LevelToExp(fishingmod.ExpToLevel(exp) + 1) - fishingmod.LevelToExp(fishingmod.ExpToLevel(exp))) * -100 + 100
end

--[[ This doesn't work very well. (as in it being slow on large data) SetPData + glon ftw!

function fishingmod.StorePlayerData(ply, name, data)
	print(ply,name)
	PrintTable(data)
	if not data or data == {} then
		file.Delete("fishingmod/"..ply:UniqueID().."/"..name..".txt")
		print("deleting")
	return end
	file.Write("fishingmod/"..ply:UniqueID().."/"..name..".txt", TableToKeyValues(table.Sanitise(data)))
	file.Write("fishingmod/"..ply:UniqueID().."/"..string.gsub(player.GetByUniqueID(ply:UniqueID()):Nick(), "%W", "")..".txt", "the owner")
end

function fishingmod.GetPlayerData(ply, name)
	return table.DeSanitise(KeyValuesToTable(file.Read("fishingmod/"..ply:UniqueID().."/"..name..".txt") or ""))
end

]]