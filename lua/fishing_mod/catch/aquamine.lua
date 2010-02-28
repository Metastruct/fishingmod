fishingmod.AddCatch{
	friendly = "Aquamine",
	type = "fishing_mod_catch_aquamine",
	rareness = 2000, 
	yank = 0, 
	mindepth = 200, 
	maxdepth = 20000,
	expgain = 30,
	levelrequired = 3,
	remove_on_release = false,
	value = 300,
	bait = {
		"models/props_junk/watermelon01.mdl",
		"models/props_junk/watermelon01_chunk01a.mdl",
		"models/props_junk/watermelon01_chunk01b.mdl",
		"models/props_junk/watermelon01_chunk01c.mdl",
		"models/props_junk/watermelon01_chunk02a.mdl",
		"models/props_junk/watermelon01_chunk02b.mdl",
		"models/props_junk/watermelon01_chunk02b.mdl",
		"models/props_junk/watermelon01_chunk02c.mdl",
	},
}

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

function ENT:Initialize()
	self:InitializeData()
	self:SetModel("models/Roller.mdl")
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
	self:StartMotionController()
	
	self.is_recatchable = true
	
	self.NextShock = CurTime()+5
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMaterial("zombieflesh")
		phys:SetMass(100)
		phys:SetDamping(0,0)
		phys:Wake()
		phys:SetBuoyancyRatio( 0 )
	end	
end

timer.Create("AquaMine:FindTarget", 1, 0, function() 
	local number_of_mines = #ents.FindByClass("fishing_mod_catch_aquamine")
	if number_of_mines == 0 then return end
	local mine = ents.FindByClass("fishing_mod_catch_aquamine")[math.random(number_of_mines)]
	for key, entity in pairs(ents.FindInSphere(mine:GetPos(), 10000)) do
		if entity:GetClass() == "fishing_mod_catch_angry_baby" and not entity.dead and entity:WaterLevel() >= 1 then
			fishingmod.AquaMineTarget = entity
			return
		else
			fishingmod.AquaMineTarget = nil
		end
	end		
end)

local smoothmove = Vector()
local function MoveSmooth(NewVec)
	smoothmove = LerpVector(0.05,smoothmove,NewVec)
	return smoothmove
end
function ENT:PhysicsSimulate(phys, deltatime)
	if self.dead then return end
	phys:Wake()

	if self:WaterLevel() >= 3 then
		phys:SetDamping(3,3)
		if constraint.FindConstraint(self, "Weld") then
			phys:AddVelocity(VectorRand()*40)
			phys:AddAngleVelocity(VectorRand()*20)
			return
		end
	
		if ValidEntity(self.target) then
			phys:AddVelocity((self.target:GetPos() - self:GetPos()):Normalize()*10)
			phys:AddAngleVelocity(VectorRand()*10)
		else
			phys:AddVelocity(MoveSmooth(VectorRand())*20 + Vector(0,0,-1))
			phys:AddAngleVelocity(VectorRand()*10)
		end
	else
		phys:SetDamping(1, 0)
		if math.random() > 0.95 then
			if ValidEntity(self.target) then
				phys:AddVelocity((self.target:GetPos() - self:GetPos()):Normalize()*10)
				phys:AddAngleVelocity(VectorRand()*10)
			else
				phys:AddVelocity(VectorRand()*20)
				phys:AddAngleVelocity(VectorRand()*10)
			end
		end
	end
end

function ENT:Revive()
	self.dead = false
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	if (dmginfo:GetDamageType() == DMG_BURN or dmginfo:GetDamage() > 10) and not self.dead then
		self.dead = true
		self:GetPhysicsObject():SetDamping(0,0)
		self:GetPhysicsObject():SetBuoyancyRatio( 1 )
		self:GetPhysicsObject():SetMass( 100 )
		self:EmitSound("buttons/combine_button5.wav", 120, math.random(90,110))
	end
end

function ENT:Think()
	if self.dead then return end
	
	self.target = fishingmod.AquaMineTarget
	
	self:GetPhysicsObject():Wake()
	
	if self.NextShock < CurTime() then
		local entsphere = ents.FindInSphere(self:GetPos(), 16)
		for _,ent in pairs(entsphere) do
			if ent:GetClass() == "fishing_mod_catch_angry_baby" or ent:IsPlayer() then
				local dmg = DamageInfo()
				dmg:SetDamage(math.random(8,13))
				dmg:SetAttacker(self)
				dmg:SetInflictor(self)
				dmg:SetDamageType(DMG_SHOCK)
				dmg:SetDamageForce((ent:GetPos() - self:GetPos()):Normalize()*50)
				ent:TakeDamageInfo(dmg)
				
				ent:EmitSound("ambient/energy/spark"..math.random(1,6)..".wav", 100, math.random(90,110))
				
				local ED = EffectData()
				ED:SetOrigin(ent:LocalToWorld(ent:OBBCenter()))
				ED:SetNormal((self:GetPos()-ent:GetPos()):Normalize()*2)
				ED:SetMagnitude(1)
				ED:SetScale(2)
				ED:SetRadius(2)
				util.Effect("Sparks", ED)
				
				self.NextShock = CurTime()+5
			end
		end
	end
	
	self:NextThink(CurTime()+0.3)
	return true
end

scripted_ents.Register(ENT, "fishing_mod_catch_aquamine", true)