AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.ply:GetModel())
	self:SetMoveType( MOVETYPE_NONE )
	self:SetPos(self.ply:GetPos())
	self:SetAngles(self.ply:GetAngles())
	--self:SetParent(self.ply)
	self:SetOwner(self.ply)
	self.dt.ply = self.ply
	self.ply:SetNWEntity("fishingmod avatar", self)
end

function ENT:Think()
	self:Animate()
	self:NextThink(CurTime())
	return true
end