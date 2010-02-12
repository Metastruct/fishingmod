AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_c17/doll01.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS ) 
	self:GetPhysicsObject():SetDamping(5,100)
	self:StartMotionController()
end

function ENT:PhysicsSimulate(phys, deltatime)
	phys:Wake()
	debugoverlay.Cross(self:GetPos(), 100, 0, Color(255,255,255,255), true)
	if self:WaterLevel() >= 1 then
	
		if constraint.FindConstraint(self, "Weld") then
			phys:AddVelocity(VectorRand()*500)
			return
		end
		
		local target
		for key, entity in pairs(ents.FindInSphere(self:GetPos(), 300)) do
			if entity ~= self and entity:GetClass() ~= "fishing_mod_fish" and entity:GetVelocity():Length() > 20 then
				target = entity
			end
		end
		if target and target:GetClass() == "fishing_rod_hook" and target:GetPos():Distance(self:GetPos()) < 20 and not constraint.FindConstraint(self, "Weld") then
			--target:Hook(self, true) crashes
		end
		if target then
			phys:AddVelocity((target:GetPos() - self:GetPos()):Normalize()*100)
		else
			phys:AddVelocity(VectorRand()*200)
		end
	end
end

--lua_run Entity(1):GetFishingRod():GetHook():Hook("fishing_mod_fish")