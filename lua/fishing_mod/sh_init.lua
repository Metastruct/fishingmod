fishingmod = fishingmod or {}

--Prices for upgrades
 
fishingmod.RodLengthPrice = 800
fishingmod.MaxRodLength = 30

fishingmod.StringLengthPrice = 500

fishingmod.ReelSpeedPrice = 800
fishingmod.MaxReelSpeed = 100

fishingmod.HookForcePrice = 600

function _R.Player:GetFishingRod()
	return ValidEntity(self:GetNWEntity("fishing rod")) and self:GetNWEntity("fishing rod") or false
end

function fishingmod.FriedToColor(amount)
	local colorvalue = math.Clamp(amount/800*-255+255, 0, 255)
	local redvalue = math.Clamp(amount/1000*-255+255, 0, 255)
	return redvalue, colorvalue, colorvalue, 255
end

local pow = 1.4
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