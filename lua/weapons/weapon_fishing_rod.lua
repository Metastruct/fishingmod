SWEP.Author = "CapsAdmin"
SWEP.Category = "Fishing Mod"
SWEP.Instructions = "To reel down, hold left mouse button\nTo reel up, hold right mouse button\nTo reel faster, hold shift\nTo reel slower, hold alt\nTo release bait, press e\nTo release catch, press r\nTo access the menu, press B"
SWEP.Spawnable = true 
SWEP.ViewModel = Model("models/weapons/v_hands.mdl")
SWEP.WorldModel = ""
 
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
 
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:PrimaryAttack()
	if SERVER then
		if not IsValid(self.fishing_rod) or not IsValid(self:GetOwner()) or not self:GetOwner().fishingmod then return end
		
		local speed = 5
		if self:GetOwner():KeyDown(IN_SPEED) then
			speed = 10 + self:GetOwner().fishingmod.reel_speed
		end
		if self:GetOwner():KeyDown(IN_WALK) then
			speed = 1
		end
		self.distance = math.Clamp(self.distance + speed, 0, 200+(self:GetOwner().fishingmod.string_length*368.54))
		self.fishing_rod:SetLength(self.distance)
		self:SetHoldType("melee2")
	end
end

function SWEP:SecondaryAttack()
	
	
	if SERVER then
		if not IsValid(self.fishing_rod) or not IsValid(self:GetOwner()) or not self:GetOwner().fishingmod then return end
		
		local speed = 5
		if self:GetOwner():KeyDown(IN_SPEED) then
			speed = 10 + self:GetOwner().fishingmod.reel_speed
		end
		if self:GetOwner():KeyDown(IN_WALK) then
			speed = 1
		end
		self.distance = math.Clamp(self.distance - speed, 0, 200+(self:GetOwner().fishingmod.string_length*368.54))
		self.fishing_rod:SetLength(self.distance)
		self:SetHoldType("melee2")
	end
end

if CLIENT then
	SWEP.PrintName = "Fishing Rod"			
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair	= false
	
else
	
	AddCSLuaFile()
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom	= false
	
	function SWEP:Initialize()
		self.distance = 0
		self.lastowner=IsValid(self:GetOwner()) and self:GetOwner() or IsValid(self:GetOwner()) and self:GetOwner() or self.lastowner
		self:SetHoldType("pistol")
	end

	function SWEP:Deploy()
		self.lastowner=IsValid(self:GetOwner()) and self:GetOwner() or IsValid(self:GetOwner()) and self:GetOwner() or self.lastowner
		if not IsValid(self.fishing_rod) then
			self.fishing_rod = ents.Create("entity_fishing_rod")
			if not self.fishing_rod or not self.fishing_rod:IsValid() or not self:GetOwner().fishingmod then
				Msg"[FishingMod] Broken for "print(self:GetOwner(),self)
				self:Remove()
				return
			end
			self.fishing_rod.dt.rod_length = self:GetOwner().fishingmod.length / 10 + 1
			self.fishing_rod:Spawn()
			self.fishing_rod:AssignPlayer(self:GetOwner())
			self:GetOwner():SetNWEntity("fishing rod", self.fishing_rod)
			if self.fishing_rod.CPPISetOwner then self.fishing_rod:CPPISetOwner(self:GetOwner()) end
			return true
		end
	end

	function SWEP:KillRod()
		if IsValid(self) and IsValid(self:GetOwner()) and IsValid(self.fishing_rod) then
			self:GetOwner():SetNWEntity("fishing rod", NULL)
			return true
		end
		if IsValid(self.fishing_rod) then
			self.fishing_rod:Remove()
			self.fishing_rod = nil
		end
	end
	function SWEP:Think()
		if not IsValid(self.fishing_rod) or not IsValid(self:GetOwner()) or not self:GetOwner().fishingmod then
			self:Remove()
		elseif not self:GetOwner():KeyDown(IN_ATTACK) or not self:GetOwner():KeyDown(IN_ATTACK2) then
			self:SetHoldType("pistol")
		end
	end
	
	function SWEP:OnRemove()
		self:KillRod()
	end
	function SWEP:Holster()
		self:KillRod()
		return true
	end
	
	function SWEP:OwnerChanged() 
		self.lastowner=IsValid(self:GetOwner()) and self:GetOwner() or IsValid(self:GetOwner()) and self:GetOwner() or self.lastowner
	end
	
	function SWEP:OnDrop() 
		self.lastowner=IsValid(self:GetOwner()) and self:GetOwner() or IsValid(self:GetOwner()) and self:GetOwner() or self.lastowner
		if IsValid(self:GetOwner()) then
		  self:KillRod() 
		end
		self:Remove() 
	end

end
