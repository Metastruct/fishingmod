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
	entity:SetColor(fishingmod.FriedToColor(data.fried))
	entity:SetNWBool("fishingmod catch", true)
	entity:SetNWFloat("fishingmod size", data.size)
end