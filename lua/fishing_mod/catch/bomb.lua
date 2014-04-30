fishingmod.AddCatch{
	friendly = "Helicopter Bomb",
	type = "fishing_mod_catch_helibomb",
	rareness = 2000, 
	yank = 0, 
	mindepth = 50, 
	maxdepth = 1250,
	expgain = 125,
	levelrequired = 9,
	remove_on_release = false,
	value = 100,
	bait = {
		"models/Combine_Helicopter/bomb_debris_1.mdl",
		"models/Combine_Helicopter/bomb_debris_2.mdl",
		"models/Combine_Helicopter/bomb_debris_3.mdl",
	},
}
local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		self.triggered = false
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(100)
			phys:Wake()
			phys:SetBuoyancyRatio( 0 )  
		end

	end

	function ENT:Think()
		self:NextThink(CurTime() + 0.25)
		if self:IsOnFire() and not self.triggered then
			self.triggered = true
			
			for _,bombs in pairs(ents.FindInSphere(self:GetPos(), 512)) do
				if bombs:GetClass() == "fishing_mod_catch_helibomb" then
					timer.Simple(2,function(bombs) bombs:Ignite(1) end, bombs)
				end
			end
			
			timer.Create("triggered_explode"..self:EntIndex(), 2, 1, function(ent) 
				timer.Destroy("Resend Fishingmod Info"..ent:EntIndex()) 
				ent:Remove() 
				util.BlastDamage(ent, ent, ent:GetPos(), 512, 250) 
				local effectdata = EffectData() 
				effectdata:SetStart( ent:GetPos() )
				effectdata:SetOrigin( ent:GetPos() )
				effectdata:SetScale( 1 )
				util.Effect( "HelicopterMegaBomb", effectdata )	
				WorldSound("ambient/explosions/explode_4.wav", ent:GetPos(), 75, 100)
			end, self.Entity)
		end
	end
end

scripted_ents.Register(ENT, "fishing_mod_catch_helibomb", true)

-- language.Add( "fishing_mod_catch_helibomb", "Helicopter Bomb" )