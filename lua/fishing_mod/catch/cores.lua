fishingmod.AddCatch{
	friendly = "Personality Core",
	type = "fishing_mod_catch_cores",
	rareness = 2500,
	yank = 0,
	mindepth = 400,
	maxdepth = 20000,
	expgain = 80,
	levelrequired = 20,
	remove_on_release = false,
	value = 100,
	bait = {
		"models/props/sphere.mdl",
	}
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

function ENT:SetupDataTables()
	self:DTVar("Int", 0, "Core")
end

if SERVER then
	
	function ENT:Initialize()
		
		self:SetModel("models/props_bts/glados_ball_reference.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		self:SetColor(0,0,0,0)
		
		self.dt.Core = math.random(0,3)
		
		self.body = ents.Create("prop_dynamic")
		self.body:SetModel("models/props_bts/glados_ball_reference.mdl")
		self.body:SetAngles(self:GetAngles())
		self.body:SetPos(self:GetPos())
		self.body:SetParent(self)
		
		self.body:SetSkin(self.dt.Core)
		
		if self.dt.Core == 0 then
			self.Anim = self:LookupSequence("idle")
		else
			self.Anim = self:LookupSequence("Look_0"..self.dt.Core+1)
		end
		
	end
	
	function ENT:Think()
		
		self.body:ResetSequence(self.Anim)
		
	end
	
	function ENT:OnRemove()
		
		self.body:Remove()
		
	end
	
else
	
	ENT.Sounds = {
		[1]={},
		[2]={},
		[3]={}
	}

	for i=1,17 do
		if i<=9 then
			ENT.Sounds[1][i] = "vo/aperture_ai/escape_02_sphere_curiosity-0"..i..".wav"
		else
			ENT.Sounds[1][i] = "vo/aperture_ai/escape_02_sphere_curiosity-"..i..".wav"
		end
	end

	for i=0, 21 do
		if i<=9 then
			ENT.Sounds[2][i] = "vo/aperture_ai/escape_02_sphere_anger-0"..i..".wav"
		else
			ENT.Sounds[2][i] = "vo/aperture_ai/escape_02_sphere_anger-"..i..".wav"
		end
	end

	for i=1,41 do
		if i<=9 then
			ENT.Sounds[3][i] = "vo/aperture_ai/escape_02_sphere_cakemix-0"..i..".wav"
		else
			ENT.Sounds[3][i] = "vo/aperture_ai/escape_02_sphere_cakemix-"..i..".wav"
		end
	end
	
	function ENT:Initialize()
		
		self.LastSound = 1
		
	end
	
	function ENT:Think()
		
		if self.LastSound <= CurTime() and not self.dt.Core == 0 then
				local curSound = table.Random(self.Sounds[self.dt.Core])
				
				self:EmitSound(curSound, 80, 100)
				
				self.LastSound = CurTime()+SoundDuration(curSound)+0.1
		end
		
	end
	
end
	
scripted_ents.Register(ENT, "fishing_mod_catch_cores", true)
