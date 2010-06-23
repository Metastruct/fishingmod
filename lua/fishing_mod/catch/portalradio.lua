fishingmod.AddCatch{
	friendly = "Portal Radio",
	type = "fishing_mod_catch_portalradio",
	rareness = 1000, 
	yank = 777, 
	mindepth = 100, 
	maxdepth = 20000,
	expgain = 40,
	levelrequired = 22,
	remove_on_release = false,
	value = 50,
	bait = {
		"models/props_misc/antenna03.mdl",
		"models/props/de_dust/du_antenna_A.mdl",
		"models/props_hydro/satellite_antenna01.mdl",
		
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/props/radio_reference.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self.shot = false
		self.sound = CreateSound(self, "ambient/music/looping_radio_mix.wav")
		self.sound:SetSoundLevel(100)
		self.sound:Play()
	end

	ENT.DeathSounds = {
		"models/props_misc/antenna03.mdl",
		"models/props_radiostation/radio_antenna01_stay.mdl",
	}
	
	function ENT:Think()
		for key, entity in pairs(ents.FindInSphere(self:GetPos(), 50)) do
			if entity:GetModel() and string.find(entity:GetModel():lower(), "wrench") then
					entity:Remove()
					self.shot = false
					self.sound = CreateSound(self, "ambient/music/looping_radio_mix.wav")
					self.sound:SetSoundLevel(100)
					self.sound:Play()
			end
		end
	end

	function ENT:OnTakeDamage()
		self.shot = true
		self.sound:Stop()
		self:EmitSound(table.Random(self.DeathSounds),70,100)
	end

	function ENT:OnRemove()
		self.sound:Stop()
		if not self.shot then
			self:EmitSound(table.Random(self.DeathSounds),50,100)
		end
	end
end

scripted_ents.Register(ENT, "fishing_mod_catch_portalradio", true)