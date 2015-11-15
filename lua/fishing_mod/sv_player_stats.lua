--[[ Format:
	0x00  : VERSION (currently: 0x01)
	0x00+1: catches
	0x08+1: exp
	0x10+1: money
	0x18+1: length
	0x20+1: reel_speed
	0x28+1: string_length
	0x30+1: force
]]

local VERSION = 0x01

local POS_VERSION    = 0x00
local POS_CATCHES    = 0x00 + 1
local POS_EXP        = 0x08 + 1
local POS_MONEY      = 0x10 + 1
local POS_LENGTH     = 0x18 + 1
local POS_REEL_SPEED = 0x20 + 1
local POS_STRING_LEN = 0x28 + 1
local POS_FORCE      = 0x30 + 1

local POSITIONS = {
	catches       = POS_CATCHES,
	exp           = POS_EXP,
	money         = POS_MONEY,
	length        = POS_LENGTH,
	reel_speed    = POS_REEL_SPEED,
	string_length = POS_STRING_LEN,
	force         = POS_FORCE
}

-- MIGRATION
	local MIGRATION = {}
	
	local function MIGRATION_SAVE_NEW_DATA (ply, data)
		local uid = ply:UniqueID()
		file.CreateDir("fishingmod")
		file.CreateDir("fishingmod/"..uid:sub(1,1))
		
		local fh = file.Open("fishingmod/"..uid:sub(1,1).."/"..uid..".txt", "wb", "DATA")
		assert (fh, "Error opening file for player "..tostring(ply))
		fh:WriteByte(VERSION)
		
		fh:WriteDouble(data.catches       or 0)
		fh:WriteDouble(data.exp           or 0)
		fh:WriteDouble(data.money         or 0)
		fh:WriteDouble(data.length        or 0)
		fh:WriteDouble(data.reel_speed    or 0)
		fh:WriteDouble(data.string_length or 0)
		fh:WriteDouble(data.force         or 0)
		fh:Close()
	end
	
	-- old fishingmod
		MIGRATION.legacy = {
			check = function (ply)
				return file.IsDir("fishingmod/"..ply:UniqueID(), "DATA")
			end,
			read = function (ply)
				local data = {}
				for _, name in next, (file.Find("fishingmod/"..ply:UniqueID().."/*.txt", "DATA")) do
					data [name:sub(1,-5)] = tonumber(file.Read("fishingmod/"..ply:UniqueID().."/"..name, "DATA")) or 0
				end
				return data
			end,
			cleanup = function (ply)
				for _, name in next, (file.Find("fishingmod/"..ply:UniqueID().."/*.txt", "DATA")) do
					file.Delete("fishingmod/"..ply:UniqueID().."/"..name)
				end
				file.Delete("fishingmod/"..ply:UniqueID())
			end
		}
	-- / old fishingmod
-- / MIGRATION

function fishingmod.LoadPlayerInfo(ply, name)
	if name then assert(POSITIONS[name], "Unknown data name '"..tostring(name).."'") end
	
	if MIGRATION.legacy.check (ply) then
		Msg ("[fishingmod] ") print ("Can migrate legacy fishingmod data from player: "..tostring(ply).."...")
		local data = MIGRATION.legacy.read (ply)
		PrintTable (data)
		MIGRATION_SAVE_NEW_DATA (ply, data)
		MIGRATION.legacy.cleanup (ply)
		print ("Success.")
	end
	
	local uid = ply:UniqueID()
	local filep = "fishingmod/"..uid:sub(1,1).."/"..uid..".txt"
	
	if file.Exists(filep, "DATA") then
		local fh = file.Open(filep, "rb", "DATA")
		assert (fh, "Error opening file for player "..tostring(ply))
		local version = fh:ReadByte()
		if not version then
			fh:Close() ErrorNoHalt("[fishingmod] File is empty.") return
		elseif version ~= VERSION then
			fh:Close() error("Unsupported version: "..version)
		end
	
		if name then -- read single info
			fh:Seek(POSITIONS[name])
			local data = fh:ReadDouble()
			fh:Close()
			return data
		else -- read all info
			local data = {}
			
			for info_n, info_p in next, POSITIONS do
				fh:Seek(info_p)
				data [info_n] = fh:ReadDouble()
			end
			
			fh:Close()
			return data
		end
	end
end

function fishingmod.SavePlayerInfo(ply, name, data)
	assert(POSITIONS[name], "Unknown data name '"..tostring(name).."'")
	local uid = ply:UniqueID()
	file.CreateDir("fishingmod")
	file.CreateDir("fishingmod/"..uid:sub(1,1))
	
	local p_data = fishingmod.LoadPlayerInfo(ply) or {}
	p_data [name] = data
	
	local fh = file.Open("fishingmod/"..uid:sub(1,1).."/"..uid..".txt", "wb", "DATA")
	assert (fh, "Error opening file for player "..tostring(ply))
	fh:WriteByte(VERSION)
	
	fh:WriteDouble(p_data.catches       or 0)
	fh:WriteDouble(p_data.exp           or 0)
	fh:WriteDouble(p_data.money         or 0)
	fh:WriteDouble(p_data.length        or 0)
	fh:WriteDouble(p_data.reel_speed    or 0)
	fh:WriteDouble(p_data.string_length or 0)
	fh:WriteDouble(p_data.force         or 0)
	fh:Close()
end

function fishingmod.GainEXP(ply, amount)
	ply.fishingmod.exp = ply.fishingmod.exp + amount
	ply.fishingmod.catches = ply.fishingmod.catches + 1
	fishingmod.SavePlayerInfo(ply, "exp", ply.fishingmod.exp)
	fishingmod.SavePlayerInfo(ply, "catches", ply.fishingmod.catches)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.GiveMoney(ply, amount)
	ply.fishingmod.money=ply.fishingmod.money or 0
	ply.fishingmod.money = ply.fishingmod.money + amount
	fishingmod.SavePlayerInfo(ply, "money", ply.fishingmod.money)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.Pay(ply, money)
	if ply.fishingmod.money > money then
		fishingmod.TakeMoney(ply, money)
		return true
	end
	return false
end

function fishingmod.TakeMoney(ply, amount)
	ply.fishingmod.money = ply.fishingmod.money - amount
	fishingmod.SavePlayerInfo(ply, "money", ply.fishingmod.money)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.SetRodLength(ply, length, add_or_sub)
	if add_or_sub == "add" then
		ply.fishingmod.length = ply.fishingmod.length + length
	elseif add_or_sub == "sub" then
		ply.fishingmod.length = ply.fishingmod.length - length
	else
		ply.fishingmod.length = length
	end
	fishingmod.SavePlayerInfo(ply, "length", ply.fishingmod.length)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.SetRodReelSpeed(ply, speed, add_or_sub)
	if add_or_sub == "add" then
		ply.fishingmod.reel_speed = ply.fishingmod.reel_speed + speed
	elseif add_or_sub == "sub" then
		ply.fishingmod.reel_speed = ply.fishingmod.reel_speed - speed
	else
		ply.fishingmod.reel_speed = speed
	end
	fishingmod.SavePlayerInfo(ply, "reel_speed", ply.fishingmod.reel_speed)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.SetRodStringLength(ply, length, add_or_sub)
	if add_or_sub == "add" then
		ply.fishingmod.string_length = ply.fishingmod.string_length + length
	elseif add_or_sub == "sub" then
		ply.fishingmod.string_length = ply.fishingmod.string_length - length
	else
		ply.fishingmod.string_length = length
	end
	fishingmod.SavePlayerInfo(ply, "string_length", ply.fishingmod.string_length)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.SetHookForce(ply, force, add_or_sub)
	if add_or_sub == "add" then
		ply.fishingmod.force = ply.fishingmod.force + force
	elseif add_or_sub == "sub" then
		ply.fishingmod.force = ply.fishingmod.force - force
	else
		ply.fishingmod.force = force
	end
	fishingmod.SavePlayerInfo(ply, "force", ply.fishingmod.force)
	fishingmod.UpdatePlayerInfo(ply)
end

function fishingmod.InitPlayerStats(ply)
	if not IsValid(ply) then return end
	ply.fishingmod = fishingmod.LoadPlayerInfo(ply)
	if not istable (ply.fishingmod) then
		ply.fishingmod = {}
		for index in next, POSITIONS do
			ply.fishingmod[index] = 0
		end
	end
	fishingmod.UpdatePlayerInfo(ply, true)
end