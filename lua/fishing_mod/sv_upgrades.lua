--Rod Length

function fishingmod.UpgradeRodLength(ply, amount)
	if amount <= 0 then return end
	if ply.fishingmod.length + amount > fishingmod.MaxRodLength then return end --50 is the maximum rod length allowed
	local cost = amount * fishingmod.RodLengthPrice --10 is the price per unit
	if cost > ply.fishingmod.money then return end
	fishingmod.TakeMoney(ply, cost)
	fishingmod.SetRodLength(ply, amount, "add")
end

function fishingmod.DowngradeRodLength(ply, amount)
	amount = math.Clamp(amount, 1, ply.fishingmod.length)
	if amount >= ply.fishingmod.length then return end
	fishingmod.SetRodLength(ply, amount, "sub")
end

concommand.Add("fishingmod_upgrade_rod_length", function(ply, command, arguments)
	local amount = tonumber(arguments[1])
	if not amount then ply:PrintMessage(HUD_PRINTTALK, "Invalid amount") return end
	fishingmod.UpgradeRodLength(ply, amount)
end)

concommand.Add("fishingmod_downgrade_rod_length", function(ply, command, arguments)
	local amount = tonumber(arguments[1])
	if not amount then ply:PrintMessage(HUD_PRINTTALK, "Invalid amount") return end
	fishingmod.DowngradeRodLength(ply, amount)
end)

--String length

function fishingmod.UpgradeStringLength(ply, amount)
	if amount <= 0 then return end
	local cost = amount * fishingmod.StringLengthPrice
	if cost > ply.fishingmod.money then return end
	fishingmod.TakeMoney(ply, cost)
	fishingmod.SetRodStringLength(ply, amount, "add")
end

function fishingmod.DowngradeStringLength(ply, amount)
	amount = math.Clamp(amount, 1, ply.fishingmod.string_length)
	if amount >= ply.fishingmod.string_length then return end
	fishingmod.SetRodStringLength(ply, amount, "sub")
end

concommand.Add("fishingmod_upgrade_string_length", function(ply, command, arguments)
	local amount = tonumber(arguments[1])
	if not amount then ply:PrintMessage(HUD_PRINTTALK, "Invalid amount") return end
	fishingmod.UpgradeStringLength(ply, amount)
end)

concommand.Add("fishingmod_downgrade_string_length", function(ply, command, arguments)
	local amount = tonumber(arguments[1])
	if not amount then ply:PrintMessage(HUD_PRINTTALK, "Invalid amount") return end
	fishingmod.DowngradeStringLength(ply, amount)
end)

--Reel speed

function fishingmod.UpgradeReelSpeed(ply, amount)
	if amount <= 0 then return end
	local cost = amount * fishingmod.ReelSpeedPrice
	if ply.fishingmod.reel_speed + amount > fishingmod.MaxReelSpeed then return end
	if cost > ply.fishingmod.money then return end
	fishingmod.TakeMoney(ply, cost)
	fishingmod.SetRodReelSpeed(ply, amount, "add")
end

function fishingmod.DowngradeReelSpeed(ply, amount)
	amount = math.Clamp(amount, 1, ply.fishingmod.reel_speed)
	if amount >= ply.fishingmod.reel_speed then return end
	fishingmod.SetRodReelSpeed(ply, amount, "sub")
end

concommand.Add("fishingmod_upgrade_reel_speed", function(ply, command, arguments)
	local amount = tonumber(arguments[1])
	if not amount then ply:PrintMessage(HUD_PRINTTALK, "Invalid amount") return end
	fishingmod.UpgradeReelSpeed(ply, amount)
end)

concommand.Add("fishingmod_downgrade_reel_speed", function(ply, command, arguments)
	local amount = tonumber(arguments[1])
	if not amount then ply:PrintMessage(HUD_PRINTTALK, "Invalid amount") return end
	fishingmod.DowngradeReelSpeed(ply, amount)
end)

--Force

function fishingmod.UpgradeHookForce(ply, amount)
	if amount <= 0 then return end
	local cost = amount * fishingmod.HookForcePrice
	if cost > ply.fishingmod.money then return end
	fishingmod.TakeMoney(ply, cost)
	fishingmod.SetHookForce(ply, amount, "add")
end

function fishingmod.DowngradeHookForce(ply, amount)
	amount = math.Clamp(amount, 0, ply.fishingmod.force)
	if amount >= ply.fishingmod.force then return end
	fishingmod.SetHookForce(ply, amount, "sub")
end

concommand.Add("fishingmod_upgrade_hook_force", function(ply, command, arguments)
	local amount = tonumber(arguments[1])
	if not amount then ply:PrintMessage(HUD_PRINTTALK, "Invalid amount") return end
	fishingmod.UpgradeHookForce(ply, amount)
end)

concommand.Add("fishingmod_downgrade_hook_force", function(ply, command, arguments)
	local amount = tonumber(arguments[1])
	if not amount then ply:PrintMessage(HUD_PRINTTALK, "Invalid amount") return end
	fishingmod.DowngradeHookForce(ply, amount)
end)

