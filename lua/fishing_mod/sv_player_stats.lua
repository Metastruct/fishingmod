-- configuration:

--  file format version (used to track compatibility)
local VERSION = 0x01
--  path generator version (used to select active path generator version)
local PATH_GENERATOR_VER = 4
--  path generator migration (used to enable/disable migration support from a different path generator version)
local PATH_GENERATOR_MIGRATION_ENABLED = {
	[1] = true,
	-- 2 was never used in production
	[3] = true
}

-- BINARY FORMAT
	local FORMAT = {}

	FORMAT [0x01] = {
		POSITIONS = {
			catches       = 0x00 + 1,
			exp           = 0x08 + 1,
			money         = 0x10 + 1,
			length        = 0x18 + 1,
			reel_speed    = 0x20 + 1,
			string_length = 0x28 + 1,
			force         = 0x30 + 1,
		},
		read = function (self, fh, name)
			if name then -- read single info
				fh:Seek(self.POSITIONS[name])
				local data = fh:ReadDouble()
				fh:Close()
				return data
			else -- read all info
				local data = {}

				for info_n, info_p in next, self.POSITIONS do
					fh:Seek(info_p)
					data [info_n] = fh:ReadDouble()
				end

				fh:Close()
				return data
			end
		end,
		write = function (self, filename, data)
			local fh = file.Open(filename, "wb", "DATA")
			if not fh then return false end
			fh:WriteByte(0x01)

			fh:WriteDouble(data.catches       or 0)
			fh:WriteDouble(data.exp           or 0)
			fh:WriteDouble(data.money         or 0)
			fh:WriteDouble(data.length        or 0)
			fh:WriteDouble(data.reel_speed    or 0)
			fh:WriteDouble(data.string_length or 0)
			fh:WriteDouble(data.force         or 0)
			fh:Close()
			return true
		end
	}

	local BINARY_READ = function (filename, name)
		local fh = file.Open(filename, "rb", "DATA")
		assert (fh, "Error opening file for player "..tostring(ply))
		local version = fh:ReadByte()
		if not version then
			fh:Close() ErrorNoHalt("[fishingmod] File is empty.") return
		elseif not istable(FORMAT[version]) then
			fh:Close() error("Unsupported file format version: "..version)
		end
		return FORMAT[version]:read(fh, name)
	end
-- / BINARY FORMAT

-- STORAGE INTERFACE
	local PATH_GENERATOR     = {}

	-- fishingmod/[first digit of UniqueID]/[UniqueID].txt
	PATH_GENERATOR[1] = setmetatable({
		init = function (ply)
			file.CreateDir("fishingmod")
			file.CreateDir("fishingmod/"..ply:UniqueID():sub(1,1))
		end
	}, {
		__call = function (tab, ply)
			local uid = ply:UniqueID()
			return "fishingmod/"..uid:sub(1,1).."/"..uid..".txt"
		end
	})

	-- fishingmod/[B]/[A]_[B]_[CDEF...].txt
	--   (assuming STEAM_A:B:CDEF...)
	PATH_GENERATOR[2] = setmetatable({
		init = function (ply)
			file.CreateDir("fishingmod")
			file.CreateDir("fishingmod/"..ply:Steam():sub(9,9))
		end
	}, {
		__call = function (tab, ply)
			return "fishingmod/"..ply:SteamID():sub(7):gsub("^(.):(.):(.+)$","%2/%1_%2_%3")..".txt"
		end
	})

	-- semi-balanced radix tree (the annoying edition; superseded by v4)
	--   case C  = 1: fishingmod/STEAM_[A]/[B]/1/[D]/[EF...].txt
	--   case C != 1: fishingmod/STEAM_[A]/[B]/[C]/[DEF...].txt
	--     (assuming STEAM_A:B:CDEF...)
	PATH_GENERATOR[3] = setmetatable({
		init = function (ply)
			local A, B, C, D = ply:SteamID():match("^STEAM_(.):(.):(.)(.)")
			file.CreateDir("fishingmod")
			file.CreateDir("fishingmod/steam_"..A)
			file.CreateDir("fishingmod/steam_"..A.."/"..B)
			file.CreateDir("fishingmod/steam_"..A.."/"..B.."/"..C)
			if C == "1" then
				file.CreateDir("fishingmod/steam_"..A.."/"..B.."/1/"..D)
			end
		end
	}, {
		__call = function (tab, ply)
			if game.SinglePlayer() then
				return "fishingmod/singleplayer.txt"
			end
			local A, B, C, D, EF = ply:SteamID():match("^STEAM_(.):(.):(.)(.)(.+)$")
			if C == "1" then
				return "fishingmod/steam_"..A.."/"..B.."/1/"..D.."/"..EF..".txt"
			else
				return "fishingmod/steam_"..A.."/"..B.."/"..C.."/"..D..EF..".txt"
			end
		end
	})

	-- semi-balanced radix tree (fixed variant)
	--   case C  = 1: fishingmod/STEAM_[A]_[B]/1/[D]/[EF...].txt
	--   case C != 1: fishingmod/STEAM_[A]_[B]/[C]/[DEF...].txt
	--     (assuming STEAM_A:B:CDEF...)
	PATH_GENERATOR[4] = setmetatable({
		init = function (ply)
			local A, B, C, D = ply:SteamID():match("^STEAM_(.):(.):(.)(.)")
			file.CreateDir("fishingmod")
			file.CreateDir("fishingmod/steam_"..A.."_"..B)
			file.CreateDir("fishingmod/steam_"..A.."_"..B.."/"..C)
			if C == "1" then
				file.CreateDir("fishingmod/steam_"..A.."_"..B.."/1/"..D)
			end
		end
	}, {
		__call = function (tab, ply)
			if game.SinglePlayer() then
				return "fishingmod/singleplayer.txt"
			end
			local A, B, C, D, EF = ply:SteamID():match("^STEAM_(.):(.):(.)(.)(.+)$")
			if C == "1" then
				return "fishingmod/steam_"..A.."_"..B.."/1/"..D.."/"..EF..".txt"
			else
				return "fishingmod/steam_"..A.."_"..B.."/"..C.."/"..D..EF..".txt"
			end
		end
	})

	--- STORAGE CONTROLLERS

	-- old fishingmod / legacy
	--  PATH: fishingmod/[UniqueID]/[fieldname].txt
	--  DEPRECATED
	local STORAGE_LEGACY = {
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
	-- / old fishingmod / legacy

	-- Binary Storage Controller
	local STORAGE_BINARY = {
		check = function (ply, path_version)
			return file.Exists(PATH_GENERATOR[path_version or PATH_GENERATOR_VER](ply), "DATA")
		end,
		read = function (ply, name)
			local filep = PATH_GENERATOR[PATH_GENERATOR_VER](ply)

			if file.Exists(filep, "DATA") then
				return BINARY_READ(filep, name)
			end
		end,
		write = function (ply, data)
			PATH_GENERATOR[PATH_GENERATOR_VER].init(ply)
			return FORMAT[VERSION]:write(PATH_GENERATOR[PATH_GENERATOR_VER](ply), data)
		end,
		migrate = function (ply, path_version)
			local filep = PATH_GENERATOR[path_version](ply)

			if file.Exists(filep, "DATA") then
				local data = BINARY_READ(filep)
				if data then
					FORMAT[VERSION]:write(PATH_GENERATOR[PATH_GENERATOR_VER](ply), data)
				end
				file.Delete(filep)
				return tobool(data)
			end
			return false
		end,
		cleanup = function (ply, path_version)
			local filep = PATH_GENERATOR[path_version](ply)

			if file.Exists(filep, "DATA") then
				return file.Delete(filep)
			end
		end
	}
-- / STORAGE INTERFACE

function fishingmod.LoadPlayerInfo(ply, name)
	if name then assert(FORMAT[VERSION].POSITIONS[name], "Unknown data name '"..tostring(name).."'") end

	-- migration from STORAGE_LEGACY
	if STORAGE_LEGACY.check (ply) then
		if STORAGE_BINARY.check (ply) then
			Msg ("[fishingmod] ") print ("Found legacy fishingmod data of player: "..tostring(ply)..", but new data exists. Deleting...")
			STORAGE_LEGACY.cleanup (ply)
			print ("Success.")
		else
			Msg ("[fishingmod] ") print ("Can migrate legacy fishingmod data of player: "..tostring(ply).."...")
			local data = STORAGE_LEGACY.read (ply)
			PrintTable (data)
			STORAGE_BINARY.write (ply, data)
			STORAGE_LEGACY.cleanup (ply)
			print ("Success.")
		end
	end

	-- migration *within* STORAGE_BINARY, but across different path generators
	-- (migrating from any of enabled PATH_GENERATOR_MIGRATION_ENABLED to currently active PATH_GENERATOR_VER)
	for ver in ipairs (PATH_GENERATOR) do
		if PATH_GENERATOR_MIGRATION_ENABLED[ver] and ver ~= PATH_GENERATOR_VER and STORAGE_BINARY.check (ply, ver) then
			if STORAGE_BINARY.check (ply) then
				Msg ("[fishingmod] ") print ("Found duplicate fishingmod data of player: "..tostring(ply).." in path v"..ver..". Deleting...")
				STORAGE_BINARY.cleanup (ply, ver)
				print ("Success.")
			else
				if STORAGE_BINARY.migrate (ply, ver) then
					Msg ("[fishingmod] ") print ("Migrated fishingmod data from path v"..ver.." to v"..PATH_GENERATOR_VER.." of player: "..tostring(ply))
				end
			end
		end
	end

	return STORAGE_BINARY.read (ply, name)
end

function fishingmod.SavePlayerInfo(ply, name, data)
	assert(FORMAT[VERSION].POSITIONS[name], "Unknown data name '"..tostring(name).."'")
	local uid = ply:UniqueID()
	file.CreateDir("fishingmod")
	file.CreateDir("fishingmod/"..uid:sub(1,1))

	local p_data = fishingmod.LoadPlayerInfo(ply) or {}
	p_data [name] = data

	return STORAGE_BINARY.write (ply, p_data)
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

local fieldnames = {
	"catches",
	"exp",
	"money",
	"length",
	"reel_speed",
	"string_length",
	"force"
}

function fishingmod.InitPlayerStats(ply)
	if not IsValid(ply) then return end
	ply.fishingmod = fishingmod.LoadPlayerInfo(ply)
	if not istable (ply.fishingmod) then
		ply.fishingmod = {}
		for _, index in next, fieldnames do
			ply.fishingmod[index] = 0
		end
	end
	fishingmod.UpdatePlayerInfo(ply, true)
end