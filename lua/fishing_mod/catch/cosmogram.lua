fishingmod.AddCatch{
	friendly = "Tribal Cosmogram",
	type = "fishing_mod_catch_cosmogram",
	rareness = 4000, 
	yank = 100, 
	mindepth = 300, 
	maxdepth = 30000,
	expgain = 200,
	levelrequired = 36,
	remove_on_release = false,
	value = 750,
	bait = {
		"models/props_lab/huladoll.mdl"
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
 
	ENT.Sounds = {"ambient/machines/teleport4.wav",
			  "ambient/machines/teleport3.wav",
			  "ambient/machines/teleport1.wav"
	}

	function ENT:Initialize()
		self:SetModel("models/props_combine/breenglobe.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self.trail = util.SpriteTrail(self, 0, Color(255,255,0), false, 16, 0, 0.25, 1/(16+0)*0.5, "trails/smoke.vmt")
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(10)
			phys:Wake()
			phys:SetBuoyancyRatio( 1.5 )
		end
	end
     
	function ENT:ChooseDestination(ply)
		local random
		repeat
			random = VectorRand()*16000
		until util.IsInWorld(random)
		
		return util.TraceHull({start = random, endpos = random + Vector(0,0,-16000), filter = ply, mins = ply:OBBMins(), maxs = ply:OBBMaxs()}).HitPos
	end
		
	function ENT:Use(activator, caller)
	
		if activator:IsPlayer() then
			activator:SetPos(self:ChooseDestination(activator))
			activator:EmitSound("ambient/machines/teleport4.wav", 100, 100)
			self:EmitSound("ambient/machines/teleport4.wav", 100, 100)
		end
	end

else


	function ENT:Initialize()

		self.Emitter = ParticleEmitter( self:GetPos() )
		self.Pos = self:GetPos()
		self.Timer = 0
		self.Alpha = 0

	end

	function ENT:Think()

		if self.Timer < CurTime() then
		
			self.Timer = CurTime() + 0.1
		
			local particle = self.Emitter:Add( "effects/yellowflare", self.Pos + VectorRand() * 20 )
			particle:SetVelocity( VectorRand() * 40 + Vector(0, 0, 10) )
			particle:SetColor( 150, 150, 0 )
			particle:SetDieTime( 5 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 4 )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand( -360, 360 ) )
			particle:SetRollDelta( math.Rand( -30, 30 ) )
			particle:SetCollide( true )
			particle:SetBounce( 1.0 )
			particle:SetThinkFunction( PartThink )
			particle:SetNextThink( CurTime() + 0.1 )
			particle.Pos = self.Pos
			self.Pos = self:GetPos()
		
		end

	end

	function PartThink( part )

		local dir = ( part.Pos - part:GetPos() ):GetNormalized()
		
		part:SetNextThink( CurTime() + 0.1 )
		part:SetGravity( dir * 250 )

	end

	function ENT:OnRemove()

		if self.Emitter then
		
			self.Emitter:Finish()
		
		end

	end
  
	local matGlow = Material( "effects/blueflare1" ) 

	function ENT:Draw()
		
		self.Alpha = 100 + math.sin( CurTime() ) * 100

		render.SetMaterial( matGlow )
		render.DrawSprite( self:GetPos() + (self:GetUp() * 3), 50 + math.sin( CurTime() * 6 ) * 5, 50 + math.sin( CurTime() * 6 ) * 5, Color( 255, 255, 0, self.Alpha ) )
		
		self:DrawModel()
		
	end


end

scripted_ents.Register(ENT, "fishing_mod_catch_cosmogram", true)