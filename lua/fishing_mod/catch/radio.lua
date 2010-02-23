fishingmod.AddCatch{
	friendly = "Annoying Country Radio",
	type = "fishing_mod_catch_radio",
	rareness = 1000, 
	yank = 777, 
	force = 0, 
	mindepth = 100, 
	maxdepth = 20000,
	expgain = 40,
	levelrequired = 2,
	remove_on_release = false,
	bait = {
		"models/props_radiostation/radio_antenna01_skybox.mdl",
		"models/props_misc/antenna03.mdl",
		"models/props/de_dust/du_antenna_A.mdl",
		"models/props/de_dust/du_antenna_A_skybox.mdl",
		"models/props_hydro/satellite_antenna01.mdl",
		
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

function ENT:Initialize()
	self:SetModel("models/props_lab/citizenradio.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.sound = CreateSound(self, "ambient/music/country_rock_am_radio_loop.wav")
	self.sound:PlayEx(100, math.random(90,110))
end

function ENT:OnRemove()
	self.sound:Stop()
end

scripted_ents.Register(ENT, "fishing_mod_catch_radio", true)