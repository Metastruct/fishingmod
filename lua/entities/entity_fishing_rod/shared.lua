ENT.Type = "anim"
ENT.Base = "fishing_mod_base"
ENT.ModelScale = Vector(3,1,1)
ENT.PlayerOffset = Vector(76,-1,-128)
ENT.PlayerAngles = Angle(60,0,0)
ENT.RopeOffset = Vector(120,0,0)

function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "ply")
	self:DTVar("Entity", 1, "attach")
	self:DTVar("Entity", 2, "avatar")
	self:DTVar("Int", 0, "length")
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
	local fish_hook = self.dt.attach.dt.hook
	if ValidEntity(fish_hook) and fish_hook or false then
		local data = {}
		local position = fish_hook:GetPos()
		data.start = position
		data.endpos = position+Vector(0,0,-10000)
		data.mask = CONTENTS_SOLID
		
		local trace = util.TraceLine(data)
		return (trace.StartPos - trace.HitPos):Length()
	end
	return 0
end