include("shared.lua")

local rope_material = Material("cable/rope")

function ENT:Draw()
	if ValidEntity(self:GetBobber()) then
		render.SetMaterial(rope_material)
		render.DrawBeam(self:LocalToWorld(self.RopeOffset), self:GetBobber():GetPos(), 0.1, 0, 0, Color(255,200,200,50))
	end
	self:DrawModel()
end

function ENT:RenderScene()
	local ply = self:GetPlayer()
	if ply then
		ply:SetAngles(Angle(0,ply:EyeAngles().y,0))
	end
	local position, angles = self.dt.avatar:GetBonePosition(self.dt.avatar:LookupBone("ValveBiped.Bip01_R_Hand"))
	local new_position, new_angles = LocalToWorld(self.PlayerOffset, self.PlayerAngles, position, angles)
	self:SetPos(new_position)
	self:SetAngles(new_angles)
	self:SetRenderBounds(Vector()*-1000, Vector()*1000)
	self:SetModelScale(self.ModelScale)
end

function ENT:KeyRelease(ply, key)
	if ply:GetFishingRod() and key == IN_USE then
		RunConsoleCommand("fishing_mod_drop_bait")
	end
	if ply:GetFishingRod() and key == IN_RELOAD then
		RunConsoleCommand("fishing_mod_drop_catch")
	end	
end

function ENT:ShouldDrawLocalPlayer(ply)
	if ply:GetFishingRod() then
		return true
	end
end

function ENT:HUDPaint()
	if not self:GetPlayer().fishingmod_catches then return end
		
	local xy = (self:GetBobber():GetPos() + Vector(0,0,10)):ToScreen()
	
	local depth = ""
	if self:GetHook() and self:GetHook():WaterLevel() >= 1 then
		depth =  "\nDepth: " .. tostring(math.Round((self:GetDepth()*2.54)/100*10)/10)
	end
	
	local catch = ""
	local hooked_entity = self:GetHook() and self:GetHook():GetHookedEntity()
	if hooked_entity and hooked_entity:WaterLevel() == 0 and hooked_entity:GetPos():Distance(LocalPlayer():EyePos()) < 500 then
		catch = "\nCatch: " .. hooked_entity:GetNWString("fishingmod friendly")
	end
	draw.DrawText(self:GetPlayer():Nick(), "ChatFont" ,xy.x, xy.y-95, color_white, 1)
	draw.RoundedBox( 0, xy.x-50, xy.y-68, 100, 23, Color( 255, 255, 255, 100 ) )
	draw.RoundedBox( 0, xy.x-50, xy.y-68, self:GetPlayer().fishingmod_percent, 23, Color( 0, 255, 0, 150 ) )
	draw.DrawText(tostring(math.Round(self:GetPlayer().fishingmod_expleft)), "HudSelectionText" ,xy.x, xy.y-65, color_black, 1)
	draw.DrawText("Total Catch: " .. self:GetPlayer().fishingmod_catches .. "\nLevel: " .. self:GetPlayer().fishingmod_level .. "\nLength: " .. tostring(math.Round((self:GetLength()*2.54)/100*10)/10) .. depth .. catch, "HudSelectionText", xy.x,xy.y-40, hooked_entity and Color(0,255,0,255) or color_white,1)
end

function ENT:Initialize()
	self.sound_rope = CreateSound(self, "weapons/tripwire/ropeshoot.wav")
	self.sound_rope:Play()
	self.sound_rope:ChangePitch(0)
	
	self.sound_reel = CreateSound(self, "fishingrod/reel.wav")
	self.sound_reel:Play()
	self.sound_reel:ChangePitch(0)
	self.last_length = 0
	self:SetupHook("RenderScene")
	self:SetupHook("HUDPaint")
	self:SetupHook("ShouldDrawLocalPlayer")
	self:SetupHook("KeyRelease")
	self:SetupHook("CalcView")
end

function ENT:Think()
	local delta = self.dt.length - self.last_length

	local velocity_length = IsValid(self.dt.attach) and self.dt.attach:GetVelocity():Length() or 0
	local pitch = velocity_length/10 - 0.1
	local volume = velocity_length/1000 - 0.1
	local reel_velocity = self.dt.length - self.last_length
	
	local on = (delta ~= 0) and 1 or 0
	self.sound_reel:ChangePitch(math.Clamp(math.abs(100+delta*10),80,200))
	self.sound_reel:ChangeVolume(on)
		
	self.sound_rope:ChangePitch(math.Clamp(pitch, 50, 255))
	self.sound_rope:ChangeVolume(math.Clamp(volume, 0, 1))
	
	self.last_length = self.dt.length
	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	self.sound_reel:Stop()
	self.sound_rope:Stop()
end