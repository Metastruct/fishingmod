ENT.Type = "anim"
ENT.Base = "fishing_mod_base"
--ENT.Length = 1
--ENT.ModelScale = Vector(1*ENT.Length,1,1)
-- ENT.PlayerOffset = Vector(25,-1,-42) * ENT.Length
-- ENT.PlayerAngles = Angle(60,0,90)
-- ENT.RopeOffset = Vector(40,0,0) * ENT.Length

function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "ply")
	self:DTVar("Entity", 1, "attach")
	self:DTVar("Entity", 2, "avatar")
	self:DTVar("Int", 0, "length")
	self:DTVar("Float", 0, "rod_length")
end

function ENT:GetBobber()
	return ValidEntity(self.dt.attach) and self.dt.attach or false
end

function ENT:GetHook()
	return ValidEntity(self.dt.attach.dt.hook) and self.dt.attach.dt.hook or false
end

function ENT:GetBait()
	return ValidEntity(self.dt.attach.dt.hook.dt.bait) and self.dt.attach.dt.hook.dt.bait or false
end

function ENT:GetPlayer()
	return ValidEntity(self.dt.ply) and self.dt.ply or false
end

function ENT:GetAvatar()
	return ValidEntity(self.dt.avatar) and self.dt.avatar or false
end

function ENT:GetLength()
	return self.dt.length or 0
end

function ENT:GetDepth()
	if self:GetPlayer():WaterLevel() >= 1 then return 0 end
	local fish_hook = self.dt.attach.dt.hook
	if ValidEntity(fish_hook) and fish_hook or false then
		local data = {}
		local position = fish_hook:GetPos()
		data.start = position
		data.endpos = position+Vector(0,0,-self.dt.length)
		data.mask = CONTENTS_SOLID
		
		local trace = util.TraceLine(data)
		return ((trace.StartPos - trace.HitPos) + (trace.HitPos - self:GetBobber():GetPos())):Length()
	end
	return 0
end