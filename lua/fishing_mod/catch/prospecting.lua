fishingmod.AddCatch{
	cant_sell = true,
	friendly = "Rock",
	type = "fishing_mod_catch_rock",
	rareness = 2000, 
	yank = 100, 
	force = 0,
	mindepth = 0, 
	maxdepth = 30000,
	expgain = 50, 
	levelrequired = 44,
	remove_on_release = false,
	bait = {
		"models/props_2fort/pick001.mdl"
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
	
	ENT.Models = {"models/props_junk/Rock001a.mdl",
				"models/props_debris/concrete_chunk05g.mdl",
				"models/props_debris/concrete_chunk04a.mdl",
				"models/props_combine/breenbust_chunk02.mdl",
				"models/props_combine/breenbust_chunk03.mdl",
				"models/props_combine/breenbust_chunk04.mdl",
				"models/props_combine/breenbust_chunk05.mdl",
				"models/props_combine/breenbust_chunk06.mdl"
	}
	
	function ENT:Initialize()

		self:SetModel(table.Random(self.Models))
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		
	end
	
	function ENT:Use(ply)
		local num = math.random(1, 100)
		if not fishingmod.Sell(ply, self, num) then return end
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
		self:Remove()
	end
	
end
	
scripted_ents.Register(ENT, "fishing_mod_catch_rock", true)

------------------------------------------------
------------------------------------------------

fishingmod.AddCatch{
	cant_sell = true,
	friendly = "Copper Ingot",
	type = "fishing_mod_catch_copper",
	rareness = 3750, 
	yank = 100, 
	force = 0,
	mindepth = 0, 
	maxdepth = 30000,
	expgain = 125,
	levelrequired = 44,
	remove_on_release = false,
	bait = {
		"models/props_2fort/pick001.mdl"
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
	
	function ENT:Initialize()
		self:SetModel("models/props_mining/ingot001.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		
		self:SetColor(Color(184, 115, 51, 255))

	end
	
	function ENT:Use(ply)
		local num = math.random(500, 1000) 
		if not fishingmod.Sell(ply, self, num) then return end
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
		self:Remove()
	end

end
	
scripted_ents.Register(ENT, "fishing_mod_catch_copper", true)

------------------------------------------------
------------------------------------------------

fishingmod.AddCatch{
	cant_sell = true,
	friendly = "Iron Ingot",
	type = "fishing_mod_catch_iron",
	rareness = 4250, 
	yank = 100, 
	force = 0,
	mindepth = 0, 
	maxdepth = 30000,
	expgain = 150,
	levelrequired = 44,
	remove_on_release = false,
	bait = {
		"models/props_2fort/pick001.mdl"
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
	
	function ENT:Initialize()
		self:SetModel("models/props_mining/ingot001.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		
		self:SetMaterial("models/props_combine/metal_combinebridge001")

	end
	
	function ENT:Use(ply)
		local num = math.random(750, 1250) 
		if not fishingmod.Sell(ply, self, num) then return end
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
		self:Remove()
	end

end
	
scripted_ents.Register(ENT, "fishing_mod_catch_iron", true) 

------------------------------------------------
------------------------------------------------

fishingmod.AddCatch{
	cant_sell = true,
	friendly = "Steel Ingot",
	type = "fishing_mod_catch_steel",
	rareness = 4750, 
	yank = 100, 
	force = 0,
	mindepth = 0, 
	maxdepth = 30000,
	expgain = 175,
	levelrequired = 44,
	remove_on_release = false,
	bait = {
		"models/props_2fort/pick001.mdl"
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
	
	function ENT:Initialize()
		self:SetModel("models/props_mining/ingot001.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		
		self:SetMaterial("models/shiny")
		self:SetColor(100, 100, 100, 255)

	end
	
	function ENT:Use(ply)
		local num = math.random(1000, 1500) 
		if not fishingmod.Sell(ply, self, num) then return end
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
		self:Remove()
	end

end
	
scripted_ents.Register(ENT, "fishing_mod_catch_steel", true)

------------------------------------------------
------------------------------------------------

fishingmod.AddCatch{
	cant_sell = true,
	friendly = "Silver Ingot",
	type = "fishing_mod_catch_silver",
	rareness = 5500, 
	yank = 100, 
	force = 0,
	mindepth = 0, 
	maxdepth = 30000,
	expgain = 200,
	levelrequired = 44,
	remove_on_release = false,
	bait = {
		"models/props_2fort/pick001.mdl"
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
	
	function ENT:Initialize()
		self.ThinkNext = 0
		self:SetModel("models/props_mining/ingot001.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		
		self:SetMaterial("models/shiny")
		self:SetColor(Color(164, 164, 164, 255))

	end
	
	function ENT:Think()
	
		if self.ThinkNext < CurTime() then
			self:EmitSound("ambient/levels/canals/windchime4.wav", 75, math.random(100, 255)) -- thanks to hunter for this sound
			self.ThinkNext = CurTime() + 3
		end
	
	end
	
	function ENT:Use(ply)
		local num = math.random(2000, 4000) 
		if not fishingmod.Sell(ply, self, num) then return end
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
		self:Remove()
	end

else

	function ENT:Initialize()

		self.Emitter = ParticleEmitter( self:GetPos() )
		self.Timer = 0
		self.Alpha = 0

	end

	function ENT:Think()

		if self.Timer < CurTime() then
		
			self.Timer = CurTime() + 3
		
			local particle = self.Emitter:Add( "effects/yellowflare", self:GetPos() + VectorRand() * 5 )
			local vecrand = VectorRand() * 20
			particle:SetVelocity( Vector(vecrand.x, vecrand.y, math.abs(vecrand.z) + 10))
			particle:SetColor( 255, 255, 255 )
			particle:SetDieTime( 4 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 1 )
			particle:SetEndSize( 6 )
			particle:SetRoll( math.Rand( -360, 360 ) )
			particle:SetRollDelta( math.random( -30, 30 ) )
			particle:SetCollide( true )
			particle:SetBounce( 0.1 )
			particle:SetGravity(Vector(0, 0, -20))
		
		end

	end

	function ENT:OnRemove()

	end
	
	local glow = Material("effects/yellowflare") -- "particles/fire_glow
	glow:SetInt( "$ignorez", 1 ) 

	
	function ENT:Draw()
		
		self.Alpha = math.Clamp(100 + math.sin( CurTime() ) * 100, 50, 255)

		render.SetMaterial( glow )
		render.DrawSprite( self:GetPos() - (self:GetForward() * 2), 25 + math.sin( CurTime() * 6 ) * 5, 25 + math.sin( CurTime() * 6 ) * 5, Color( 255, 255, 255, self.Alpha ) )
		render.DrawSprite( self:GetPos() - (self:GetForward() * 7 ), 25 + math.sin( CurTime() * 6 ) * 5, 25 + math.sin( CurTime() * 6 ) * 5, Color( 255, 255, 255, self.Alpha ) )
		render.DrawSprite( self:GetPos() + (self:GetForward() * 7 ), 25 + math.sin( CurTime() * 6 ) * 5, 25 + math.sin( CurTime() * 6 ) * 5, Color( 255, 255, 255, self.Alpha ) )
		
		self:DrawModel()
		
	end
	
	

end
	
scripted_ents.Register(ENT, "fishing_mod_catch_silver", true)

------------------------------------------------
------------------------------------------------

fishingmod.AddCatch{
	cant_sell = true,
	friendly = "Gold Ingot",
	type = "fishing_mod_catch_gold",
	rareness = 8000, 
	yank = 100, 
	force = 0,
	mindepth = 0, 
	maxdepth = 30000,
	expgain = 475,
	levelrequired = 44,
	remove_on_release = false,
	bait = {
		"models/props_2fort/pick001.mdl"
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
	
	function ENT:Initialize()
		self.ThinkNext = 0
		self:SetModel("models/props_mining/ingot001.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
	end
	
	function ENT:Think()
	
		if self.ThinkNext < CurTime() then
			self:EmitSound("ambient/levels/canals/windchime4.wav", 75, math.random(100, 255)) -- thanks to hunter for this sound
			self.ThinkNext = CurTime() + 1
		end
	
	end
	
	function ENT:Use(ply)
		local num = math.random(3000, 6000) 
		if not fishingmod.Sell(ply, self, num) then return end
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
		self:Remove()
	end

else

	function ENT:Initialize()

		self.Emitter = ParticleEmitter( self:GetPos() )
		self.Timer = 0
		self.Alpha = 0

	end

	function ENT:Think()

		if self.Timer < CurTime() then
		
			self.Timer = CurTime() + 1
		
			local particle = self.Emitter:Add( "effects/yellowflare", self:GetPos() + VectorRand() * 5 )
			local vecrand = VectorRand() * 20
			particle:SetVelocity( Vector(vecrand.x, vecrand.y, math.abs(vecrand.z) + 10))
			particle:SetColor( 164, 164, 16 )
			particle:SetDieTime( 4 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 1 )
			particle:SetEndSize( 6 )
			particle:SetRoll( math.Rand( -360, 360 ) )
			particle:SetRollDelta( math.random( -30, 30 ) )
			particle:SetCollide( true )
			particle:SetBounce( 0.1 )
			particle:SetGravity(Vector(0, 0, -20))
		
		end

	end

	function ENT:OnRemove()

	end
	
	local glow = Material("effects/yellowflare") -- "particles/fire_glow
		glow:SetInt( "$ignorez", 1 ) 
	function ENT:Draw()
		
		self.Alpha = math.Clamp(100 + math.sin( CurTime() ) * 100, 50, 255)

		render.SetMaterial( glow )
		render.DrawSprite( self:GetPos() - (self:GetForward() * 2), 60 + math.sin( CurTime() * 6 ) * 5, 60 + math.sin( CurTime() * 6 ) * 5, Color( 200, 200, 150, self.Alpha ) )
		render.DrawSprite( self:GetPos() - (self:GetForward() * 7 ), 60 + math.sin( CurTime() * 6 ) * 5, 60 + math.sin( CurTime() * 6 ) * 5, Color( 200, 200, 150, self.Alpha ) )
		render.DrawSprite( self:GetPos() + (self:GetForward() * 7 ), 60 + math.sin( CurTime() * 6 ) * 5, 60 + math.sin( CurTime() * 6 ) * 5, Color( 200, 200, 150, self.Alpha ) )
		
		self:DrawModel()
		
	end
	
	

end
	
scripted_ents.Register(ENT, "fishing_mod_catch_gold", true)

------------------------------------------------
------------------------------------------------

fishingmod.AddCatch{
	cant_sell = true,
	friendly = "Platinum Ingot",
	type = "fishing_mod_catch_platinum",
	rareness = 15000, 
	yank = 100, 
	force = 0,
	mindepth = 0, 
	maxdepth = 30000,
	expgain = 1000,
	levelrequired = 44,
	remove_on_release = false,
	bait = {
		"models/props_2fort/pick001.mdl"
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
	
	function ENT:Initialize()
		self.ThinkNext = 0
		self:SetModel("models/props_mining/ingot001.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		
		self:SetMaterial("models/shiny")
		self:SetColor(Color(164, 164, 164, 255))
		
	end
	
	function ENT:Think()
	
		if self.ThinkNext < CurTime() then
			self:EmitSound("ambient/levels/canals/windchime4.wav", 75, math.random(100, 255)) -- thanks to hunter for this sound
			self.ThinkNext = CurTime() + 0.5
		end
	
	end
	
	function ENT:Use(ply)
		local num = math.random(6000, 17500) 
		if not fishingmod.Sell(ply, self, num) then return end
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
		self:Remove()
	end

else

	function ENT:Initialize()

		self.Emitter = ParticleEmitter( self:GetPos() )
		self.Timer = 0
		self.Alpha = 0

	end

	function ENT:Think()

		if self.Timer < CurTime() then
		
			self.Timer = CurTime() + 0.5
		
			local particle = self.Emitter:Add( "effects/yellowflare", self:GetPos() + VectorRand() * 5 )
			local vecrand = VectorRand() * 20
			particle:SetVelocity( Vector(vecrand.x, vecrand.y, math.abs(vecrand.z) + 10))
			particle:SetColor( 255, 255, 255 )
			particle:SetDieTime( 4 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 4 )
			particle:SetEndSize( 12 )
			particle:SetRoll( math.Rand( -360, 360 ) )
			particle:SetRollDelta( math.random( -30, 30 ) )
			particle:SetCollide( true )
			particle:SetBounce( 0.1 )
			particle:SetGravity(Vector(0, 0, -20))
		
		end

	end

	function ENT:OnRemove()

	end
	
	local glow = Material("effects/yellowflare") -- "particles/fire_glow
		glow:SetInt( "$ignorez", 1 ) 
	
	function ENT:Draw()
		
		self.Alpha = math.Clamp(100 + math.sin( CurTime() ) * 100, 50, 255)

		render.SetMaterial( glow )
		render.DrawSprite( self:GetPos() - (self:GetForward() * 2), 75 + math.sin( CurTime() * 6 ) * 10, 75 + math.sin( CurTime() * 6 ) * 10, Color( 255, 255, 255, self.Alpha ) )
		render.DrawSprite( self:GetPos() - (self:GetForward() * 7 ), 75 + math.sin( CurTime() * 6 ) * 10, 75 + math.sin( CurTime() * 6 ) * 10, Color( 255, 255, 255, self.Alpha ) )
		render.DrawSprite( self:GetPos() + (self:GetForward() * 7 ), 75 + math.sin( CurTime() * 6 ) * 10, 75 + math.sin( CurTime() * 6 ) * 10, Color( 255, 255, 255, self.Alpha ) )
		
		self:DrawModel()
		
	end
	
	

end
	
scripted_ents.Register(ENT, "fishing_mod_catch_platinum", true)

------------------------------------------------
------------------------------------------------

fishingmod.AddCatch{
	cant_sell = true,
	friendly = "Diamond",
	type = "fishing_mod_catch_diamond",
	rareness = 27500, 
	yank = 100, 
	force = 0,
	mindepth = 0, 
	maxdepth = 30000,
	expgain = 2500, 
	levelrequired = 44,
	remove_on_release = false,
	bait = {
		"models/props_2fort/pick001.mdl"
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
	
	function ENT:Initialize()

		self:SetModel("models/props_debris/concrete_chunk05g.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		
		self:SetMaterial("models/props_vents/borealis_vent001")

	end
	
	function ENT:Use(ply)
		local num = math.random(32000, 44000)
		if not fishingmod.Sell(ply, self, num) then return end
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
		self:Remove()
	end
	
else

	function ENT:Draw()

		render.SetMaterial( Material("effects/yellowflare") )
		render.DrawSprite( self:GetPos(), 15 + math.sin(CurTime()) * 5, 15 + math.sin(CurTime()) * 5, Color( 255, 255, 255, 255 ) )
		
		self:DrawModel()
		
	end
	
end
	
scripted_ents.Register(ENT, "fishing_mod_catch_diamond", true)

------------------------------------------------
------------------------------------------------

fishingmod.AddCatch{
	cant_sell = true,
	friendly = "Ancient Pottery",
	type = "fishing_mod_catch_pottery",
	rareness = 4000, 
	yank = 100, 
	force = 0,
	mindepth = 0, 
	maxdepth = 30000,
	expgain = 75, 
	levelrequired = 44,
	remove_on_release = false,
	bait = {
		"models/props_2fort/pick001.mdl"
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
	
	function ENT:Initialize()

		self:SetModel("models/props_c17/pottery0"..math.random(1, 8).."a.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		
	end
	
	function ENT:Use(ply)
		local num = math.random(1, 750)
		if not fishingmod.Sell(ply, self, num) then return end
		ply:EmitSound("ambient/levels/labs/coinslot1.wav", 100, math.random(90,110))
		self:Remove()
	end
	
end
	
scripted_ents.Register(ENT, "fishing_mod_catch_pottery", true)

------------------------------------------------
------------------------------------------------

fishingmod.AddCatch{
	friendly = "PICKAXE VALUE PLACEHOLDER", -- this is to give the pickaxe bait a price
	type = "prop_physics",
	models = {
		"models/props_junk/Shoe001a.mdl"	
	},
	size = 10,
	rareness = 10000, 
	yank = 100, 
	mindepth = 233233, 
	maxdepth = 233234,
	expgain = 20,
	value = 25000,
	levelrequired = 44,
	remove_on_release = true,
		bait = {
		"models/props_2fort/pick001.mdl"
	}
}
