include("shared.lua")

local rope_material = Material("cable/rope")

function ENT:Draw()
	if ValidEntity(self:GetBobber()) then
		render.SetMaterial(rope_material)
		render.DrawBeam(self:LocalToWorld(Vector(40,0,0) * self.dt.rod_length), self:GetBobber():LocalToWorld(self:GetBobber().TopOffset), 0.1, 0, 0, Color(255,200,200,50))
	end
	self:DrawModel()
end

function ENT:RenderScene()
	local ply = self:GetPlayer()
	if ply then
		ply:SetAngles(Angle(0,ply:EyeAngles().y,0))
	end
	if not IsValid(self.dt.ply) then return end
	local position, angles = self.dt.ply:GetBonePosition(self.dt.ply:LookupBone("ValveBiped.Bip01_R_Hand"))
	local new_position, new_angles = LocalToWorld(Vector(26.5-(self.dt.rod_length/13),-0.17,-44) * self.dt.rod_length, Angle(60,0,90), position, angles)
	self:SetPos(new_position)
	self:SetAngles(new_angles)
	self:SetRenderBounds(Vector()*-1000, Vector()*1000)
	self:SetModelScale(Vector(1*self.dt.rod_length,1,1))
end

function ENT:KeyRelease(ply, key)
	if ply:GetFishingRod() and (key == IN_USE and ply:KeyDown(IN_RELOAD)) or (key == IN_RELOAD and ply:KeyDown(IN_USE)) and ((fishingmod.UpgradeMenu and not fishingmod.UpgradeMenu:IsVisible()) or not IsValid(fishingmod.UpgradeMenu)) then
		if fishingmod.UpgradeMenu then fishingmod.UpgradeMenu:Remove() end
		fishingmod.UpgradeMenu = vgui.Create("Fishingmod:ShopMenu")
	end	
	if ply:GetFishingRod() and key == IN_USE then
		RunConsoleCommand("fishing_mod_drop_bait")
	end
	if ply:GetFishingRod() and key == IN_RELOAD then
		RunConsoleCommand("fishing_mod_drop_catch")
	end	
end

function ENT:HUDPaint()
	if self:GetPlayer() and not self:GetPlayer().fishingmod then return end
	
	if self:GetPlayer() ~= LocalPlayer() and self:GetHook() and self:GetHook():GetPos():Distance(LocalPlayer():EyePos()) > 1500 then return end
		
	local xy = ((self:GetBobber() and self:GetBobber():GetPos() or Vector(0)) + Vector(0,0,10)):ToScreen()
	
	local depth = ""
	if self:GetHook() and self:GetHook():WaterLevel() >= 1 then
		depth =  "\nDepth: " .. tostring(math.Round((self:GetDepth()*2.54)/100*10)/10)
	end
	
	local catch = ""
	local hooked_entity = self:GetHook() and self:GetHook():GetHookedEntity()
	if hooked_entity and hooked_entity:WaterLevel() == 0 and hooked_entity:GetPos():Distance(LocalPlayer():EyePos()) < 500 then
		catch = "\nCatch: " .. hooked_entity:GetNWString("fishingmod friendly")
	end
	local height_offset = 50
	draw.DrawText(self:GetPlayer():Nick(), "ChatFont" ,xy.x, xy.y-115-height_offset, color_white, 1)
	draw.RoundedBox( 0, xy.x-50, xy.y-88-height_offset, 100, 23, Color( 255, 255, 255, 100 ) )
	draw.RoundedBox( 0, xy.x-50, xy.y-88-height_offset, self:GetPlayer().fishingmod.percent, 23, Color( 0, 255, 0, 150 ) )
	draw.DrawText(tostring(math.Round(self:GetPlayer().fishingmod.expleft)), "HudSelectionText" ,xy.x, xy.y-85-height_offset, color_black, 1)
	draw.DrawText("Total Catch: " .. self:GetPlayer().fishingmod.catches .. "\nMoney: " .. (self:GetPlayer().fishingmod.money or "0") .. "\nLevel: " .. self:GetPlayer().fishingmod.level .. "\nLength: " .. tostring(math.Round((self:GetLength()*2.54)/100*10)/10) .. depth .. catch, "HudSelectionText", xy.x,xy.y-60-height_offset, hooked_entity and Color(0,255,0,255) or color_white,1)
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
	self:SetupHook("KeyRelease")
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