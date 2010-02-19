SWEP.Author = "CapsAdmin"
SWEP.Category = "Fishing Mod"
SWEP.Instructions = "Left click to start fishing"
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
		local speed = 5
		if self.Owner:KeyDown(IN_SPEED) then
			speed = 40
		end
		if self.Owner:KeyDown(IN_WALK) then
			speed = 1
		end
		self.distance = math.Clamp(self.distance + speed, 0, 10000)
		self.fishing_rod:SetLength(self.distance)
	end
end

function SWEP:SecondaryAttack()
	if SERVER then
		local speed = 5
		if self.Owner:KeyDown(IN_SPEED) then
			speed = 40
		end
		if self.Owner:KeyDown(IN_WALK) then
			speed = 1
		end
		self.distance = math.Clamp(self.distance - speed, 0, 10000)
		self.fishing_rod:SetLength(self.distance)
	end
end

function SWEP:Reload()
	if CLIENT or SinglePlayer() then
		RunConsoleCommand("fishing_mod_drop_catch")
	end
end

if CLIENT then
	SWEP.PrintName = "Fishing Rod"			
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair	= false
	
else
	
	function SWEP:Initialize()
		self.distance = 0
	end
	
	function SWEP:Deploy()
		if not ValidEntity(self.fishing_rod) then
			self.fishing_rod = ents.Create("entity_fishing_rod")
			self.fishing_rod:Spawn()
			self.fishing_rod:AssignPlayer(self.Owner)
			self.Owner:SetNWEntity("fishing rod", self.fishing_rod)
			return true
		end
	end
	
	function SWEP:Holster()
		if ValidEntity(self) and ValidEntity(self.Owner) then
			self.Owner:SetNWEntity("fishing rod", NULL)
			self.fishing_rod:Remove()
			self.fishing_rod = nil
			return true
		end
	end
		
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom	= false
end