ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.IsFishingModEntity = true

function ENT:SetupHook(event_name)
	hook.Add(event_name, "FishingmodEntity:"..event_name, function(...)
		for key, entity in pairs(ents.GetAll()) do
			if entity.IsFishingModEntity and entity[event_name] then
				--[[ return ]] entity[event_name](entity, ...) --can't return here, it won't work.
			end
		end
	end)
end

function ENT:IsCatch()
	return self:GetNWBool("fishingmod catch")
end

function ENT:GetSize()
	return entity:GetNWFloat("fishingmod scale", 1)
end