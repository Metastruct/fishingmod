AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

ENT.MaxScale = 5

function ENT:Initialize()
	self:SetModel("models/props_c17/doll01.mdl")
	self.dt.scale = math.Clamp(math.random()*self.MaxScale,0.3, self.MaxScale)
	self:PhysicsInitBox( Vector(0.5,0.5,1)*-self.dt.scale * 5, Vector(0.5,0.5,1)*self.dt.scale * 5 )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetDamping(0,0)
		phys:SetMass(self.dt.scale*self.MaxScale)
		phys:Wake()
	end

end

function ENT:PhysicsSimulate(phys, deltatime)
	phys:Wake()
	debugoverlay.Cross(self:GetPos(), 100, 0, Color(255,255,255,255), true)
	if self:WaterLevel() >= 3 then
	
		if constraint.FindConstraint(self, "Weld") then
			phys:AddVelocity(VectorRand()*500)
			phys:AddAngleVelocity(VectorRand()*5000)
			return
		end
		
		for key, entity in pairs(ents.FindInSphere(self:GetPos(), 300)) do
			if entity ~= self and entity:GetClass() ~= "fishing_mod_fish" and entity:GetVelocity():Length() > 20 then
				self.target = entity
			end
		end

		if ValidEntity(self.target) then
			phys:AddVelocity((self.target:GetPos() - self:GetPos()):Normalize()*100)
		else
			phys:AddVelocity(VectorRand()*200)
			phys:AddAngleVelocity(VectorRand()*2000)
		end
	else
		if math.random() > 0.99 then
			phys:AddVelocity(VectorRand()*200)
			phys:AddAngleVelocity(VectorRand()*2000)
		end
	end
end


function ENT:Think()
	if ValidEntity(self.target) and not constraint.FindConstraint(self, "Weld") and (self.target and self.target:GetClass() == "fishing_rod_hook") and self.target:GetPos():Distance(self:GetPos()) < 5 then
		self.target:Hook(self, 2500, true)
	end
	self:NextThink(CurTime()+0.1)
	return true
end
--lua_run Entity(1):GetFishingRod():GetHook():Hook("fishing_mod_fish")