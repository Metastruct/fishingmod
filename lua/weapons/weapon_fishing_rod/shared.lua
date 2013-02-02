SWEP.Author = "CapsAdmin"
SWEP.Category = "Fishing Mod"
SWEP.Instructions = "To reel down, hold left mouse button\nTo reel up, hold right mouse button\nTo reel faster, hold shift\nTo reel slower, hold alt\nTo release bait, press e\nTo release catch, press r\nTo access the menu, press B"
SWEP.Spawnable = true 
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.HoldType = "sword"
 
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
		if not IsValid(self.fishing_rod) or not IsValid(self.Owner) or not self.Owner.fishingmod then return end
		
		local speed = 5
		if self.Owner:KeyDown(IN_SPEED) then
			speed = 10 + self.Owner.fishingmod.reel_speed
		end
		if self.Owner:KeyDown(IN_WALK) then
			speed = 1
		end
		self.distance = math.Clamp(self.distance + speed, 0, 200+(self.Owner.fishingmod.string_length*368.54))
		self.fishing_rod:SetLength(self.distance)
	end
end

function SWEP:SecondaryAttack()
	if SERVER then
		if not IsValid(self.fishing_rod) then return end
		
		local speed = 5
		if self.Owner:KeyDown(IN_SPEED) then
			speed = 10 + self.Owner.fishingmod.reel_speed
		end
		if self.Owner:KeyDown(IN_WALK) then
			speed = 1
		end
		self.distance = math.Clamp(self.distance - speed, 0, 200+(self.Owner.fishingmod.string_length*368.54))
		self.fishing_rod:SetLength(self.distance)
	end
end

if CLIENT then
	SWEP.PrintName = "Fishing Rod"			
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair	= false
	
else
	
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom	= false
	
	function SWEP:Initialize()
		self.distance = 0
		self.lastowner=IsValid(self:GetOwner()) and self:GetOwner() or IsValid(self.Owner) and self.Owner or self.lastowner
	end

	function SWEP:Deploy()
		self.lastowner=IsValid(self:GetOwner()) and self:GetOwner() or IsValid(self.Owner) and self.Owner or self.lastowner
		if not IsValid(self.fishing_rod) then
			self.fishing_rod = ents.Create("entity_fishing_rod")
			self.fishing_rod.dt.rod_length = self.Owner.fishingmod.length / 10 + 1
			self.fishing_rod:Spawn()
			self.fishing_rod:AssignPlayer(self.Owner)
			self.Owner:SetNWEntity("fishing rod", self.fishing_rod)
			if self.fishing_rod.CPPISetOwner then self.fishing_rod:CPPISetOwner(ply) end
			return true
		end
	end

	function SWEP:KillRod()
		if IsValid(self) and IsValid(self.Owner) and IsValid(self.fishing_rod) then
			self.Owner:SetNWEntity("fishing rod", NULL)
			return true
		end
		if IsValid(self.fishing_rod) then
			self.fishing_rod:Remove()
			self.fishing_rod = nil
		end
	end

	function SWEP:OnRemove()
		self:KillRod()
	end
	function SWEP:Holster()
		self:KillRod()
	end
	
	function SWEP:OwnerChanged() 
		self.lastowner=IsValid(self:GetOwner()) and self:GetOwner() or IsValid(self.Owner) and self.Owner or self.lastowner
	end
	
	function SWEP:OnDrop() 
		self.lastowner=IsValid(self:GetOwner()) and self:GetOwner() or IsValid(self.Owner) and self.Owner or self.lastowner
		self.Owner=self.lastowner 
		if IsValid(self.Owner) then
		  self:KillRod() 
		end
		self:Remove() 
	end

end