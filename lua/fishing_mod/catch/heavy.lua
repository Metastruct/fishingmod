local heavy_enabled = CreateConVar("fish_heavy", "1", FCVAR_ARCHIVE)
if util.IsValidRagdoll("models/player/heavy.mdl") and heavy_enabled:GetBool() then
	fishingmod.AddCatch{
		friendly = "Stoned Heavy",
		type = "fishing_mod_catch_heavy",
		size = 8,
		rareness = 3500, 
		yank = 100000, 
		mindepth = 100, 
		maxdepth = 20000,
		expgain = 70,
		value = 300,
		levelrequired = 8,
		remove_on_release = false,
		bait = {
			"models/weapons/c_models/c_sandwich/c_sandwich.mdl",
		},
	}
end

local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "Heavy")
	self:DTVar("Bool", 0, "dead")
end

if SERVER then

	local max_health = 400

	function ENT:Initialize()
		self:InitializeData()
		self.is_ragdoll = true
		self:SetupHook("EntityTakeDamage")
		self:SetModel("models/props_junk/PopCan01a.mdl")
		self:SetNoDraw(true)
		self.Heavy = ents.Create("prop_ragdoll")
		local heavy = self.Heavy
		heavy:SetModel("models/player/heavy.mdl")
		heavy:SetPos(self:GetPos())
		heavy:Spawn()
		self:SetParent(self.Heavy)
		heavy:SetNWEntity("FMRedirect", self)
		self.dt.Heavy = heavy
		self.health = max_health
	end
	
	function ENT:PreHook(player)
		if IsValid(player.FMHeavy) then
			player:EmitSound("buttons/button8.wav")
			return false
		end
	end
	
	function ENT:PostHook(player)
		local number = math.random(17)
		if number < 10 then
			number = "0"..number
		end
		self:PlaySound("vo/heavy_sandwichtaunt"..number..".mp3")
		self.target = player
		self.Heavy.owner = player
		player.FMHeavy = self.Heavy
		if self.Heavy.CPPISetOwner then self.Heavy:CPPISetOwner(player) end
	end
	
	function ENT:PlaySound(path)
		if not self.busysound then
			self.Heavy:EmitSound(path, 100, math.random(90,110))
			self.busysound = true
		end
		timer.Simple(SoundDuration(path), function()
			if not IsValid(self) then return end
			self.busysound = false
		end)
	end	
	
	function ENT:EntityTakeDamage(entity, data)
		if entity ~= self.Heavy then return end
		local amount=data:GetDamage() > 50 and 50 or data:GetDamage()
		
		if self.health > 0 then
			self:PlaySound("vo/heavy_painsharp0"..math.random(5)..".mp3")
			self.health = self.health - amount
		else
			self:PlaySound("vo/heavy_painsevere0"..math.random(3)..".mp3")
			self.dt.dead = true
			local heavy = self.Heavy
			for i=0,15 do
				local phys = heavy:GetPhysicsObjectNum(i)
				phys:EnableGravity(true)	
			end
		end
	end 

	function ENT:Think()
		self.Heavy:SetColor(self:GetColor())
		
		if self.dt.dead or self.health ~= max_health then 
			for key, entity in pairs(ents.FindInSphere(self.Heavy:GetPos(), 50)) do
				if entity:GetModel() and string.find(entity:GetModel():lower(), "medkit") then
					entity:Remove()
					self.dt.dead = false
					self.health = max_health
					self:PlaySound("vo/heavy_positivevocalization0"..math.random(5)..".mp3")
				end
			end
			
			if math.random() > 0.9 then
				self:PlaySound("vo/heavy_medic0"..math.random(3).."mp3")
			end
			return 
		end
		
		for key, seagull in pairs(ents.FindByClass("fishing_mod_seagull")) do
			local handpos = self.Heavy:GetBonePosition(self.Heavy:LookupBone("bip_hand_l"))
			local distance = seagull:GetPos():Distance(handpos)
			if distance < 4000 then
				self.target = seagull
			end
			
			if distance < 60 then
				local data = DamageInfo()
				data:SetAttacker(self.Heavy.owner)
				data:SetInflictor(self)
				data:SetDamageType(DMG_BULLET)
				data:SetDamage(10)
				self.target:TakeDamageInfo(data)
				for key, ragdoll in pairs(ents.FindInSphere(handpos, 200)) do
					if string.lower(ragdoll:GetModel() or "") == "models/seagull.mdl" then
						ragdoll:GetPhysicsObjectNum(0):SetPos(handpos)
						ragdoll:SetOwner(self.Heavy)
						constraint.Weld(self.Heavy, ragdoll, 11, 0)
					end
				end
			end
		end
		
		if not IsValid(self.target) then self.target = self.Heavy.owner end
	
		local target = self.target
		if IsValid(target) then
			local heavy = self.Heavy
			
			for i=0, heavy:GetFlexNum() do
				heavy:SetFlexWeight(i, math.random()*0.4)
			end
			
			if math.random() > 0.999 then
				self:PlaySound("vo/heavy_positivevocalization0"..math.random(5)..".mp3")
			end
		
			local head = heavy:GetPhysicsObjectNum(14)
			local lefthand = heavy:GetPhysicsObjectNum(11)
			local righthand = heavy:GetPhysicsObjectNum(13)
			local rightfoot = heavy:GetPhysicsObjectNum(15)
			local leftfoot = heavy:GetPhysicsObjectNum(5)
			local pelvis = heavy:GetPhysicsObjectNum(0)
			
			local velocity = (target:IsPlayer() and target:GetShootPos() or target:GetPos()) - heavy:GetPos()
			
			if target:IsPlayer() and target:GetShootPos():Distance(heavy:GetPos()) < 200 then
				velocity = Vector()
				
				constraint.RemoveAll(self.Heavy)
			end
			
			if target:GetClass() == "fishing_mod_seagull" then velocity = velocity:GetNormalized() * 1000 end
			
			local gravity = Vector(0,0,-20)
			
			head:AddVelocity(velocity)
			lefthand:AddVelocity(velocity)
			righthand:AddVelocity(velocity)
			
			head:AddAngleVelocity(Vector(-100,0,0))
			-- leftfoot:AddVelocity(gravity)
			
			for i=0,15 do
				local phys = heavy:GetPhysicsObject()
				phys:EnableGravity(false)
				local phys = heavy:GetPhysicsObjectNum(i)
				phys:EnableGravity(false)	
				if self.target:GetClass() ~= "fishing_mod_seagull" then phys:AddVelocity(phys:GetVelocity()*-0.1) end
			end
			
			--rightfoot:AddVelocity(gravity)
			--leftfoot:AddVelocity(gravity)
		end		
		self:NextThink(CurTime())
		return true
	end
	
	function ENT:OnRemove()
		if IsValid(self.Heavy) then self.Heavy:Remove() end
	end

else
	function ENT:Initialize()
		self.emitter = ParticleEmitter(self.dt.Heavy:GetPos())
	end

	local bones = {
		"bip_foot_r",
		"bip_foot_l",
	}
	
	function ENT:Think()
		if self.dt.dead then return end
		
		local heavy = self.dt.Heavy
		
		for key, bone in pairs(bones) do
			local bone = heavy:LookupBone(bone)
			if bone then -- ???
				local position = heavy:GetBonePosition(bone)
				
				local particle = self.emitter:Add( "effects/yellowflare", position )
				particle:SetVelocity( VectorRand() * 10 )
				particle:SetDieTime( 5 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 4 )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand( -360, 360 ) )
				particle:SetRollDelta( math.Rand( -30, 30 ) )
				particle:SetBounce( 1.0 )
			end
		end
	end
end

scripted_ents.Register(ENT, "fishing_mod_catch_heavy", true)

if SERVER and false then
	All"fishing_mod_catch_heavy":Remove()

	local me = nero.GetPlayer("Caps")
	local hitpos = me:GetEyeTrace().HitPos + Vector(0,0,200)
	
	if IsValid(heavy) then heavy:Remove() end
	heavy = ents.Create("fishing_mod_catch_heavy")
	heavy:SetPos(hitpos)
	heavy:Spawn()
	heavy:PostHook(me)
	
	local random = VectorRand()*1000
	random.z = math.abs(random.z)
	
	if IsValid(sandwich) then sandwich:Remove() end
	sandwich = ents.Create("prop_physics")
	sandwich:SetModel("models/weapons/c_models/c_sandwich/c_sandwich.mdl")
	sandwich:SetPos(hitpos+random)
	sandwich:Spawn()
		
	if IsValid(seagull) then seagull:Remove() end
	seagull = ents.Create("fishing_mod_seagull")
	seagull:SetTargetOwner(me)
	seagull:SetTarget(sandwich)
	seagull:SetPos(hitpos+random)
	seagull:Spawn()
	
end
