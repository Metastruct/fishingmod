AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')
require("glon")

function ENT:SpawnFunction(ply, trace)
	
	if ply.has_shelf then return end
	
	local entity = ents.Create("fishing_mod_shelf")
	entity.uniqueid = ply:UniqueID()
	entity:Spawn()
	local angle = (ply:GetAimVector()*-1):Angle()
	angle.p = 0
	entity:SetAngles(angle)
	entity:SetPos(trace.HitPos + Vector(0,0,entity:BoundingRadius()))
	shelf = entity
	ply.has_shelf = true
	return entity
end

function ENT:OnRemove()
	local ply = player.GetByUniqueID(self.uniqueid)
	if IsValid(ply) then
		ply.has_shelf = false
	end
	
	for key, item in pairs(self.shelf_storage) do
		if IsValid(item.entity) then
			item.entity:Remove()
		end
	end
end

function ENT:SaveShelf()
	if not IsValid(player.GetByUniqueID(self.uniqueid)) then return end
	player.GetByUniqueID(self.uniqueid):SetPData("fishing mod shelf", glon.encode(self.shelf_storage))
end

function ENT:LoadShelf()
	if not IsValid(player.GetByUniqueID(self.uniqueid)) then return end
	local storage = glon.decode(player.GetByUniqueID(self.uniqueid):GetPData("fishing mod shelf"))
	if not storage then return end
	for key, value in pairs(storage) do
		local entity = ents.Create(value.class)
		entity:SetModel(value.model)
		entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		entity:PhysicsInitSphere(10/entity:BoundingRadius())
		entity.is_catch = true
		entity:SetOwner(self)
		entity:Spawn()
		fishingmod.SetData(entity, value.data)
		timer.Simple(0.1, function() if IsValid(entity) then fishingmod.SetClientInfo(entity) end end)
		self:AddItemByIndex(value.index, entity)
	end
end

function ENT:Initialize()
	self:SetModel( "models/props_interiors/Furniture_shelf01a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self.shelf_storage = {}
	
    local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableMotion(false)
	end
	self:LoadShelf()
end

function ENT:Think()

	for key, entity in pairs( ents.FindInBox( self:GetPos() + Vector( 6, -15, 37 ), self:GetPos() + Vector( 25, 15, -37 ) ) ) do
		if entity.is_catch and not entity.shelf_stored and entity:GetClass() ~= "prop_ragdoll" then
			self:AddItem( entity )
		end
	end
	
end

function ENT:AddItemByIndex(index, entity)
	local data = self.storage[index]
	
	entity:SetNWBool("in fishing shelf", true)
	entity.weld_broke = false
	
	self.shelf_storage[index] = {entity = entity, index = index, class = entity:GetClass(), model = entity:GetModel(), data = entity.data}
	
	entity.shelf_stored = true
	timer.Simple(0.1, function()
		if IsValid(self) and IsValid(entity) then
			entity:SetAngles( self:GetAngles() )
			entity:SetPos( self:GetPos() + ( self:GetUp() * data.position.z ) + ( self:GetRight() * data.position.x ) + ( self:GetForward() * data.position.y ) - (entity:OBBCenter()*entity:GetNWFloat("fishingmod size")/entity:BoundingRadius()))
			entity.weld = constraint.Weld(self, entity, 0, 0, 0, true)
			entity.weld:CallOnRemove("detach from shelf", function()
				if IsValid(self) then
					self:SaveShelf()
				end
				local item = entity
				timer.Simple(1, function() 
					if IsValid(item) then 
						item.shelf_stored = nil
					end
					if IsValid(self) then
						self.shelf_storage[index] = nil
					end
				end)
			end)
			entity:CallOnRemove("FishingMod:Shelf", function()
				if IsValid(item) then 
					item.shelf_stored = nil
				end
				if IsValid(self) then
					self.shelf_storage[index] = nil
				end
			end)
			self:SaveShelf()
		end
	end)
end

function ENT:AddItem( entity )

	local closest = {index = nil, distance = 200}
	
	for key, value in pairs( self.storage ) do
		if not value.shelf_stored then
			local distance = entity:GetPos():Distance( self:GetPos() + ( self:GetUp() * value.position.z ) + ( self:GetRight() * value.position.x ) + ( self:GetForward() * value.position.y ) )
			if distance < closest.distance then
				closest = { distance = distance, index = key }
			end
		end
	end
	
	if closest.index then
		local index, data = closest.index, self.storage[closest.index]
		
		entity:SetNWBool("in fishing shelf", true)
		entity.weld_broke = false
		
		self.shelf_storage[index] = {entity = entity, index = index, class = entity:GetClass(), model = entity:GetModel(), data = entity.data}
		
		entity.shelf_stored = true
				
		timer.Simple(0.1, function()
			if IsValid(self) and IsValid(entity) then
				entity:SetAngles( self:GetAngles() )
				entity:SetPos( self:GetPos() + ( self:GetUp() * data.position.z ) + ( self:GetRight() * data.position.x ) + ( self:GetForward() * data.position.y ) - self:OBBCenter())
				entity.weld = constraint.Weld(self, entity, 0, 0, 0, true)
				entity.weld:CallOnRemove("detach from shelf", function()
					if IsValid(self) then
						self:SaveShelf()
					end
					local item = entity
					timer.Simple(1, function() 
						if IsValid(item) then 
							item.shelf_stored = nil
						end
						if IsValid(self) then
							self.shelf_storage[index] = nil
						end
					end)
				end)
				self:SaveShelf()
			end
		end)
	end

	closest = nil
	
end