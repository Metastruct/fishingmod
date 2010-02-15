ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.IsFishingModEntity = true

function ENT:SetupHook(event_name)
	hook.Add(event_name, event_name.." Event For Fishingmod Entity", function(...)
		for key, entity in pairs(ents.GetAll()) do
			if entity.IsFishingModEntity and entity[event_name] then
				entity[event_name](entity, ...)
			end
		end
	end)
end