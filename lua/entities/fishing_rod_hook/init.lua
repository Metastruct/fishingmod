AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/meathook001a.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(60)
		phys:SetDamping(1,1)
		phys:Wake()
	end
	
	self.is_hook = true
	self.last_velocity = Vector()
	self.last_angular_velocity = Vector()
	
	self.physical_rope = constraint.Elastic( self, self.bobber, 0, 0, Vector(0,1.2,10), Vector(), 6000, 1200, 0, "", 0, 1 )
	self.physical_rope:Fire("SetSpringLength", 50)

end

function ENT:StartTouch(entity)
	if fishingmod.IsBait(entity) then
		self:HookBait(entity)
	end
	fishingmod.HookBait(self.bobber.rod:GetPlayer(), entity)
end

function ENT:HookBait(bait)
	if not IsValid(self.dt.bait) then
		local phys = bait:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(true)
			phys:Wake()
		end
		bait:SetPos(self:GetPos())
		self.dt.bait = bait
		constraint.Weld(self, self.dt.bait, 0, 0, 0, false, false)
	end
end

function ENT:DropBait()
	if IsValid(self.dt.bait) then
		constraint.RemoveConstraints(self.dt.bait, "Weld")
		self.dt.bait = nil
	end
end

function ENT:GetHookedBait()
	return IsValid(self.dt.bait) and self.dt.bait or false
end

function ENT:Hook( entity, data )
	if IsValid(self.dt.hooked) then return end
	if IsValid(self.dt.bait) then
		self.dt.bait:Remove()
	end
		
	data = data or {}
	
	local ply = self.bobber.rod:GetPlayer()
		
	if IsEntity(entity) and IsValid(entity) then
        if entity.PreHook and entity:PreHook(ply, true) == false then return end
		local oldname = entity:GetNWString("fishingmod friendly")
		entity:SetNWString("fishingmod friendly", oldname ~= "" and oldname or data.friendly or "Unknown")
		entity:SetNWBool("fishingmod catch", true)
		if data.size then
			entity:SetNWFloat("fishingmod size", data.size)
		end
		entity.is_catch = true
		entity.data = data
		entity.data.caught = os.time()
		entity.data.owner = ply
		entity.data.ownerid = ply:UniqueID()
		
		entity:SetPos(self:GetPos())
		entity:SetOwner(self)
		entity.is_catch = true
		if entity:IsNPC() then
			entity.oldmovetype = entity:GetMoveType()
			entity:SetMoveType(MOVETYPE_NONE)
			entity:SetParent(self)
		else
			constraint.Weld(entity, self, 0, 0, ply.fishingmod.force * 700 + 1000 )
		end
		fishingmod.SetCatchInfo(entity)
		self.dt.hooked = entity
        if entity.PostHook then entity:PostHook(ply, true) end
		hook.Run("FishingModCaught", ply, entity)
		if entity.CPPISetOwner then entity:CPPISetOwner(ply) end
	else
		entity = ents.Create(data.type or "")
        if entity.PreHook and entity:PreHook(ply, false) == false then entity:Remove() return end
		local size, name = 1, ""
		
		if data.scalable then 
			size, name = fishingmod.GenerateSize()
		end
		
		if not IsValid(entity) then return end
		
		if data.models then
			entity:SetModel(table.Random(data.models) or "error.mdl")
		end
		
		entity:SetPos(self:GetPos())
		entity:SetOwner(self)
		entity:Spawn()
		
		if not entity:IsNPC() and not (util.IsValidProp(entity:GetModel():lower()) or util.IsValidRagdoll(entity:GetModel():lower())) then			
			entity:PhysicsInitBox(Vector(1,1,1)*-7,Vector(1,1,1)*7) 
		end
		
		if data.scalable == "box" then
			entity:PhysicsInitBox(entity:OBBMins()*size,entity:OBBMaxs()*size)
			entity:SetNWFloat("fishingmod scale", size)
		elseif data.scalable == "sphere" then
			entity:PhysicsInitSphere(entity:BoundingRadius()*(size or 1))
			entity:SetNWFloat("fishingmod scale",(size or 1)*(data.scalable_extra or 1))
		end
		if data.scalable then
			entity:SetNWBool("fishingmod scalable", true)
			if entity.Initialize then entity:Initialize() end
		end
		
		hook.Run("PlayerSpawnedSENT", ply, entity)
		
		if entity:IsNPC() then
			entity:Activate()
			entity:SetParent(self)
			entity.oldmovetype = entity:GetMoveType()
			entity:SetMoveType(MOVETYPE_NONE)
		else
			constraint.Weld(entity, self, 0, 0, ply.fishingmod.force * 700 + 1000 )
		end
		
		entity.data = table.Copy(data)
		entity.data.caught = os.time()
		entity.data.owner = ply
		entity.data.ownerid = ply:UniqueID()
		entity.data.value = (entity.data.value or 0) * (size*1.5)
		entity.data.friendly = name .. " " .. entity.data.friendly
		
		entity:SetNWString("fishingmod friendly", entity.data.friendly)
		
		entity:SetNWBool("fishingmod catch", true)
		
		if data.size then
			entity:SetNWFloat("fishingmod size", data.size)
		end
				
		if data.remove_on_release then
			self.remove_on_release = entity
		end
		
		entity.is_catch = true
		fishingmod.SetCatchInfo(entity)
		self.dt.hooked = entity
        if entity.PostHook then entity:PostHook(ply, false) end
		hook.Run("FishingModCaught", ply, entity)
		if entity.CPPISetOwner then entity:CPPISetOwner(ply) end
	end
end

function ENT:GetHookedEntity()
	return IsValid(self.dt.hooked) and self.dt.hooked or false
end

function ENT:UnHook()
    local entity = self.dt.hooked
	if IsValid(entity) then
        if entity.PreRelease and entity:PreRelease(self.bobber.rod:GetPlayer()) == false then return end
		if entity.remove_on_release then
			self.remove_on_release = entity
		end
		entity.just_unhooked = true
		local entity = entity
		timer.Simple(1, function() if IsValid(entity) then entity.just_unhooked = false end end)
		if entity:IsNPC() then
			entity:SetAngles(Angle())
			entity:SetMoveType(entity.oldmovetype)
			entity:SetParent()
		else
			constraint.RemoveConstraints(entity, "Weld")
		end
        if entity.PostRelease then entity:PostRelease(self.bobber.rod:GetPlayer()) end
		entity = nil
	end
end

function ENT:OnRemove()
	if IsValid(self.dt.hooked) then
		self.dt.hooked:SetParent()
	end
	self.physical_rope:Remove()
end

function ENT:Think()
	for key, entity in pairs(ents.FindInSphere(self:GetPos(), 20)) do
		if entity.is_recatchable and not self.just_released and not entity.just_unhooked then
			self:Hook(entity, entity.data)
			self.just_released = true
			timer.Simple(1.5, function() if IsValid(self) then self.just_released = false end end)
		end
	end
	if not constraint.FindConstraint(self.dt.hooked, "Weld") and not self.dt.hooked:IsNPC() then
		self.dt.hooked = nil
	end
	if self.dt.hooked and not IsValid(self.dt.hooked) then
		self.dt.hooked = nil
	end
	if IsValid(self.remove_on_release) and not IsValid(self.dt.hooked) then
		if self.remove_on_release:WaterLevel() >= 1 then
			local effect_data = EffectData()
			effect_data:SetOrigin(self.remove_on_release:GetPos())
			effect_data:SetScale(self.remove_on_release:BoundingRadius())
			util.Effect("gunshotsplash", effect_data)
			self.remove_on_release:Remove()
		end
	end
	self:NextThink(CurTime())
	return true
end