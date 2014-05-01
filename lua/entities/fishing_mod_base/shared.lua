ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.IsFishingModEntity = true

local hooked = {}

-- TODO: Memory leak clientside
local recovertable = {}

if CLIENT then
	hook.Add("NetworkEntityCreated","FishingModRecover",function(e)
		local dat = recovertable[e]
		if dat then
			hooked[dat][e] = true
		end
	end)
end


local SERVER = SERVER
local cur_ent = false
local function process_ents(event_name,tbl,...)
	cur_ent = false
	for entity,_ in next,tbl do
		
		cur_ent = entity
		
		if not entity:IsValid() then
			tbl[entity] = nil
			if not SERVER then
				recovertable[entity] = event_name
			end
		else		
			local func = entity[event_name]
			if func then
				func( entity, ... )
			end
		end
	end
end

function ENT:SetupHook(event_name)
	local tbl = hooked[event_name]
	
	if not tbl then
		tbl = {}
		hooked[event_name]=tbl
		
		hook.Add(event_name, "FishingModHooks", function(...)
			local ok,err = xpcall(process_ents,debug.traceback,event_name,tbl,...)
			if not ok then
				local extra=""
				if cur_ent then
					tbl[cur_ent]=nil
					extra=" "..tostring(cur_ent)
					cur_ent = false
				end
				ErrorNoHalt("[FishingMod"..extra.."] "..tostring(err)..'\n')
			end
		end)
	end
	
	tbl[self] = true
	
end

function ENT:IsCatch()
	return self:GetNWBool("fishingmod catch")
end

function ENT:GetSize()
	return self:GetNWFloat("fishingmod scale", 1)
end