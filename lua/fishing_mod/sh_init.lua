fishingmod = {}

function _R.Player:GetFishingRod()
	return ValidEntity(self:GetNWEntity("fishing rod")) and self:GetNWEntity("fishing rod") or false
end