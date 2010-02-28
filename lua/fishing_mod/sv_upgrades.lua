--Rod Length

function fishingmod.UpgradeRodLength(ply, amount)
	if ply.fishingmod.length + amount > fishingmod.MaxRodLength then return end --50 is the maximum rod length allowed
	local cost = amount * fishingmod.RodLengthPrice --10 is the price per unit
	if cost > ply.fishingmod.money then return end
	fishingmod.TakeMoney(ply, cost)
	fishingmod.SetRodLength(ply, amount, "add")
end

function fishingmod.DowngradeRodLength(ply, amount)
	amount = math.max(amount, 1)
	if amount >= ply.fishingmod.length then return end
	fishingmod.SetRodLength(ply, amount, "sub")
end

concommand.Add("fishingmod_upgrade_rod_length", function(ply, command, arguments)
	fishingmod.UpgradeRodLength(ply, arguments[1])
end)

concommand.Add("fishingmod_downgrade_rod_length", function(ply, command, arguments)
	fishingmod.DowngradeRodLength(ply, arguments[1])
end)

--String length

function fishingmod.UpgradeStringLength(ply, amount)
	local cost = amount * fishingmod.StringLengthPrice
	if cost > ply.fishingmod.money then return end
	fishingmod.TakeMoney(ply, cost)
	fishingmod.SetRodStringLength(ply, amount, "add")
end

function fishingmod.DowngradeStringLength(ply, amount)
	amount = math.max(amount, 1)
	if amount >= ply.fishingmod.string_length then return end
	fishingmod.SetRodStringLength(ply, amount, "sub")
end

concommand.Add("fishingmod_upgrade_string_length", function(ply, command, arguments)
	fishingmod.UpgradeStringLength(ply, arguments[1])
end)

concommand.Add("fishingmod_downgrade_string_length", function(ply, command, arguments)
	fishingmod.DowngradeStringLength(ply, arguments[1])
end)

--Reel speed

function fishingmod.UpgradeReelSpeed(ply, amount)
	local cost = amount * fishingmod.ReelSpeedPrice
	if ply.fishingmod.reel_speed + amount > fishingmod.MaxReelSpeed then return end
	if cost > ply.fishingmod.money then return end
	fishingmod.TakeMoney(ply, cost)
	fishingmod.SetRodReelSpeed(ply, amount, "add")
end

function fishingmod.DowngradeReelSpeed(ply, amount)
	amount = math.max(amount, 1)
	if amount >= ply.fishingmod.string_length then return end
	fishingmod.SetRodReelSpeed(ply, amount, "sub")
end

concommand.Add("fishingmod_upgrade_reel_speed", function(ply, command, arguments)
	fishingmod.UpgradeReelSpeed(ply, arguments[1])
end)

concommand.Add("fishingmod_downgrade_reel_speed", function(ply, command, arguments)
	fishingmod.DowngradeReelSpeed(ply, arguments[1])
end)

--Force

function fishingmod.UpgradeHookForce(ply, amount)
	local cost = amount * fishingmod.HookForcePrice
	if cost > ply.fishingmod.money then return end
	fishingmod.TakeMoney(ply, cost)
	fishingmod.SetHookForce(ply, amount, "add")
end

function fishingmod.DowngradeHookForce(ply, amount)
	amount = math.max(length, 1)
	if amount >= ply.fishingmod.string_length then return end
	fishingmod.SetHookForce(ply, amount, "sub")
end

concommand.Add("fishingmod_upgrade_hook_force", function(ply, command, arguments)
	fishingmod.UpgradeHookForce(ply, arguments[1])
end)

concommand.Add("fishingmod_downgrade_hook_force", function(ply, command, arguments)
	fishingmod.DowngradeHookForce(ply, arguments[1])
end)