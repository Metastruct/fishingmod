fishingmod.AddCatch{
	friendly = "Annoying Country Radio",
	type = "fishing_mod_catch_aradio",
	rareness = 1000, 
	yank = 100, 
	mindepth = 100, 
	maxdepth = 20000,
	expgain = 25,
	levelrequired = 2,
	remove_on_release = false,
	value = 50,
	bait = {
		"models/props_radiostation/radio_antenna01_stay.mdl",
		--"models/props_misc/antenna03.mdl",
	},
}
local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

if SERVER then
	function ENT:Initialize()

		self:SetModel("models/props_lab/citizenradio.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self.sound = CreateSound(self, "ambient/music/country_rock_am_radio_loop.wav")
		self.sound:SetSoundLevel(150)
		self.sound:ChangeVolume(500)
		self.sound:Play()
		self.sound:ChangePitch(math.random(100,110))
	end

	function ENT:Use()
		self.sound:Play()
		self.sound:ChangePitch(math.random(100,110))
	end

	function ENT:OnTakeDamage()
		self.sound:Play()
		self.sound:ChangePitch(math.random(100,110))
		self.shot = 100
	end

	function ENT:Think()
	
		if self.shot and self.shot <=100 then
			for key, entity in pairs(ents.FindInSphere(self:GetPos(), 20)) do
				if entity:GetModel() and string.find(entity:GetModel():lower(), "wrench") then
					local effectdata = EffectData()
					effectdata:SetOrigin( self:GetPos() + (self:GetUp() * 5) )
					effectdata:SetMagnitude( 4 )
					effectdata:SetScale( 1 )
					effectdata:SetRadius( 1 ) 
					util.Effect( "Sparks", effectdata )
					entity:Remove()
					self.shot = 101
					self.sound:ChangePitch(self.shot)
				end
			end
		end
		
		if self.shot and self.shot <=100 then
			self.shot = math.Clamp(self.shot - 1, 0, 255)
			self.sound:ChangePitch(self.shot)
		end
		self:NextThink(CurTime())
		return true
	end

	function ENT:OnRemove()
		self.sound:Stop()
	end
	
end

scripted_ents.Register(ENT, "fishing_mod_catch_aradio", true)