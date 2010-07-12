fishingmod.AddCatch{
	friendly = "Gold Ingot",
	type = "fishing_mod_catch_gold",
	rareness = 7500, 
	yank = 100, 
	mindepth = 300, 
	maxdepth = 30000,
	expgain = 500,
	levelrequired = 44,
	remove_on_release = false,
	bait = {
		"models/props_2fort/pick001.mdl"
	},
}

local ENT = {}

ENT.Type = "anim"

if SERVER then
	
	function ENT:Initialize()
		self.ThinkNext = 0
		self:SetModel("models/props_junk/PopCan01a.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		
		local w = 4 * 2
		local l = 4.5 * 2
		local h = 7 * 2
		
		local min=Vector(0-(w/2),0-(l/2),0-(h/2))
		local max=Vector(w/2,l/2,h/2)
		
		self:PhysicsInitBox(min,max)
		self:SetCollisionBounds(min,max)
		
		self:SetAngles(Angle(-90, 0, 180)) 
		
		self.bar = ents.Create("prop_physics")
		self.bar:SetModel("models/props_mining/ingot001.mdl")
		self.bar:SetPos(self:GetPos() - Vector(0, 0, 4))
		self.bar:SetParent(self)
		self.bar:Spawn()

	end
	
	function ENT:OnRemove()
	
		if IsValid(self.bar) then
			self.bar:Remove()
		end
	
	end
	
	function ENT:Think()
	
		if self.ThinkNext < CurTime() then
			self:EmitSound("ambient/levels/canals/windchime4.wav", 100, math.random(100, 255)) -- thanks to hunter for this sound
			self.ThinkNext = CurTime() + 2
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

	end

	function ENT:Think()

		if self.Timer < CurTime() then
		
			self.Timer = CurTime() + 2
		
			local particle = self.Emitter:Add( "particles/fire_glow", self:GetPos() + VectorRand() * 5 )
			local vecrand = VectorRand() * 20
			particle:SetVelocity( Vector(math.abs(vecrand.x), math.abs(vecrand.y), math.abs(vecrand.z)))
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

		if self.Emitter then
		
			self.Emitter:Finish()
		
		end

	end
  
	local matGlow = Material( "effects/blueflare1" ) 

	function ENT:Draw()
	
	end

end
	
scripted_ents.Register(ENT, "fishing_mod_catch_gold", true)