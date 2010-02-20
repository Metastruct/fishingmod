ENT.Type = "anim"
ENT.Base = "fishing_mod_base"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "ply")
end

function ENT:Animate()
	self:SetPos(self.dt.ply:GetPos())
	self:SetAngles(Angle(0,self.dt.ply:EyeAngles().y,0))
	self:SetPoseParameter("move_yaw", math.AngleDifference(self.dt.ply:GetVelocity():Angle().y, self.dt.ply:GetLocalAngles().y))
	self:SetPoseParameter("aim_pitch", self.dt.ply:EyeAngles().p)

	local moving = self.dt.ply:KeyDown(IN_FORWARD) or self.dt.ply:KeyDown(IN_BACK) or self.dt.ply:KeyDown(IN_MOVELEFT) or self.dt.ply:KeyDown(IN_MOVERIGHT)
	local running = self.dt.ply:KeyDown(IN_SPEED)
	local sequence = "idle_melee2"

	if moving then
		sequence = "walk_melee2"
		if running then
			sequence = "run_melee2"
		end
	end

	if self.dt.ply:Crouching() then
		sequence = "cidle_melee2"
		if moving then
			sequence = "cwalk_melee2"
		end
	end
	
	local seat = self.dt.ply:GetNWEntity("weapon seat")
	if IsValid(seat) then
		sequence = "sit_melee2"
		local angles = seat:GetAngles()
		angles:RotateAroundAxis(seat:GetUp(), 90)
		self:SetAngles(angles)
		if SERVER then
			local angle = math.NormalizeAngle(self.dt.ply:EyeAngles().y-180)/180
			self:SetPoseParameter("body_yaw", angle*29.7)
			self:SetPoseParameter("spine_yaw", angle*30.7)
			self:SetPoseParameter("aim_yaw", angle*52.5)
			self:SetPoseParameter("head_yaw", angle*30.7)
		end
	end
	
	self:SetCycle(self.dt.ply:GetCycle())
	self:SetPlaybackRate(1)
	self:SetSequence(self:LookupSequence(sequence))
end

function ENT:OnRemove()
	if not IsValid(self.dt.ply) then return end
	self.dt.ply:SetNoDraw(false)
	self.dt.ply:SetMaterial("")
	self.dt.ply:SetNWEntity("fishingmod avatar", NULL)
	if CLIENT then
		self.dt.ply:SetModelScale(self.oldscale)
	end
end

local player_meta = FindMetaTable( "Entity" )

FMOldGetBonePosition = FMOldGetBonePosition or player_meta.GetBonePosition

function player_meta:GetBonePosition(index)
	local entity = self:GetNWEntity("fishingmod avatar")
	if IsValid(entity) then
		return entity:GetBonePosition( index )
	else
		return FMOldGetBonePosition( self, index )
	end
end