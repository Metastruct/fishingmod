
fishingmod.AddCatch{
	friendly = "Stove",
	type = "fishing_mod_catch_stove",
	rareness = 2500, 
	yank = 1000, 
	force = 0, 
	mindepth = 0, 
	value = 600,
	maxdepth = 20000,
	expgain = 150,
	levelrequired = 5,
	bait = {"models/props_c17/metalPot002a.mdl"}
}

local margin = 3
local color_white = color_white or Color(255, 255, 255, 255)
local ENT = {}

ENT.Type = "anim"
ENT.Base = "fishing_mod_base"

function ENT:SetupStorage()
	self.storage = {
		[1] = { item = false, position = Vector( 11, 3, 20) },
		[2] = { item = false, position = Vector( -11, 3, 20) },
		[3] = { item = false, position = Vector( 11, -10, 20) },
		[4] = { item = false, position = Vector( -11, -10, 20) },
	}
end

ENT:SetupStorage()

function ENT:SetupDataTables()
	self:DTVar("Int", 0, "heat")
end

if CLIENT then
	local sprite = Material( "sprites/splodesprite" )
	function ENT:Initialize()
		self.emitter = ParticleEmitter(self:GetPos())
		self.sound = CreateSound(self, "ambient/fire/fire_small_loop2.wav")
		self.sound:SetSoundLevel(0)
		self.sound:PlayEx(0,100)
		
		timer.Simple(0.1,function() 
			self.sound:Stop()
			self.sound:SetSoundLevel(70) 
			self.sound:PlayEx(0,100) 
		end)
		
		self.stoves = {}
		for key, data in pairs(self.storage) do
			if key == 1 or key == 2 then
				local pan = ClientsideModel("models/props_c17/metalPot002a.mdl")
				pan:SetModelScale(0.7, 0)
				pan:SetPos(self:GetPos() + self:GetForward() * 3 + ( self:GetUp() * (data.position.z + 1) ) + ( self:GetRight() * data.position.x ) + ( self:GetForward() * data.position.y))
				local angles = pan:GetAngles()
				angles:RotateAroundAxis(angles:Up(), 180)
				pan:SetAngles(angles)
				pan:SetParent(self)
				self.stoves[key] = pan
			elseif key == 3 or key == 4 then
				local pan = ClientsideModel("models/props_c17/metalPot001a.mdl")
				pan:SetModelScale(0.7, 0)
				pan:SetPos(self:GetPos() + ( self:GetUp() * (data.position.z + 4.5) ) + ( self:GetRight() * data.position.x ) + ( self:GetForward() * data.position.y))
				local angles = pan:GetAngles()
				angles:RotateAroundAxis(angles:Up(), 90)
				pan:SetAngles(angles)
				self.stoves[key] = pan
			end
			self.stoves[key]:SetParent(self)
		end
	end
	
	function ENT:OnRemove()
		self.sound:Stop()
		for key, stove in pairs(self.stoves) do
			stove:Remove()
		end
	end
	
	local smoke = { 
		"particle/smokesprites_0001",
		"particle/smokesprites_0002",
		"particle/smokesprites_0003",
		"particle/smokesprites_0004",
		"particle/smokesprites_0005",
		"particle/smokesprites_0006",
		"particle/smokesprites_0007",
		"particle/smokesprites_0008",
		"particle/smokesprites_0009",
		"particle/smokesprites_0010",
		"particle/smokesprites_0012",
		"particle/smokesprites_0013",
		"particle/smokesprites_0014",
		"particle/smokesprites_0015",
		"particle/smokesprites_0016"
	}

	local heat = CreateClientConVar("fishingmod_stove_heat", 50, true, true)
	
	local function RandomSphere()
		return Angle(math.Rand(-180,180),math.Rand(-180,180),math.Rand(-180,180)):Forward()
	end

	function ENT:Draw()
		for key, data in pairs(self.storage) do
			local smoke = self.emitter:Add( 
				table.Random(smoke), 
					self:GetPos() + 
					( self:GetUp() * data.position.z ) + 
					( self:GetRight() * data.position.x ) + 
					( self:GetForward() * data.position.y)
			)
			if smoke then
				local color = 255 * self.dt.heat/100 * -1 + 1
				smoke:SetVelocity(RandomSphere()*2)
				smoke:SetDieTime( math.random()*5 )
				smoke:SetAngles(Angle(math.random(360),math.random(360),math.random(360)))
				smoke:SetStartSize( 0 )
				smoke:SetStartAlpha(math.max(self.dt.heat/100*255-100, 0) )
				smoke:SetColor(color,color,color)
				smoke:SetEndSize( math.Rand(10,20) )
				smoke:SetRoll( math.Rand(-0.5, 0.5) )
				smoke:SetRollDelta( math.Rand(-0.5, 0.5) )
				smoke:SetGravity(Vector(math.Rand(-10,10),math.Rand(-10,10),20))
				smoke:SetCollide(true)
				smoke:SetBounce(0.2)
			end
		end
		
		self:DrawModel()
		self.sound:ChangeVolume(self.dt.heat/100, 0)
		render.SetMaterial( sprite )
		for k, v in pairs( self.storage ) do
			render.DrawSprite( self:GetPos() + ( self:GetUp() * v.position.z ) + ( self:GetRight() * v.position.x ) + ( self:GetForward() * v.position.y ), 1, 1, Color( 255, 255, 255, 255 ) )
		end
	end

	function ENT:ShowHeatAdjuster()
		local background = fishingmod.DefaultUIColors().ui_background
		local button_not_selected = fishingmod.DefaultUIColors().ui_button_deselected
		local ui_button_selected = fishingmod.DefaultUIColors().ui_button_selected
		local ui_button_hovered = fishingmod.DefaultUIColors().ui_button_hovered
		local ui_text = fishingmod.DefaultUIColors().ui_text
		if fishingmod.ColorTable then
			background = fishingmod.ColorTable.ui_background or background
			button_not_selected = fishingmod.ColorTable.ui_button_deselected or button_not_selected
			ui_button_selected = fishingmod.ColorTable.ui_button_selected or ui_button_selected
			ui_button_hovered = fishingmod.ColorTable.ui_button_hovered or ui_button_hovered
			ui_text = fishingmod.ColorTable.ui_text or ui_text
		else
			fishingmod.ColorTable = fishingmod.DefaultUIColors()
		end
		local frame = vgui.Create("DFrame")
		frame.Paint = function(s, x, y)
			
			surface.SetDrawColor(background.r, background.g, background.b, background.a)
			surface.DrawRect(0, 0, x, y)
			surface.DrawRect(margin, 24, x - margin * 2, y - 24 - margin)
		end
		frame:Showclose_button(false)
		local close_button = vgui.Create("DButton", frame)
		local x, y = frame:GetSize()
		close_button.ButtonW = 60
		close_button:SetSize(close_button.ButtonW, 18)
		close_button:SetText("Close")
		close_button:SetTextColor(ui_text)
		close_button:SetPos(x - close_button.ButtonW - margin, margin)
		close_button.DoClick = function()
			frame:Close()
		end
		close_button.Paint = function(self, w, h)
			
			if(close_button:IsDown() ) then
				surface.SetDrawColor(button_not_selected.r, button_not_selected.g, button_not_selected.b, button_not_selected.a)
			elseif(close_button:IsHovered()) then
				surface.SetDrawColor(ui_button_hovered.r, ui_button_hovered.g, ui_button_hovered.b, ui_button_hovered.a)
			else
				surface.SetDrawColor(background.r, background.g, background.b, background.a)
			end
			surface.DrawRect(0, 0, w, h)
		end
		function frame:OnSizeChanged(x, y)
			close_button:SetPos(math.max(x - close_button.ButtonW - margin, margin), margin)
			close_button:SetSize(math.min(close_button.ButtonW, x - margin * 2) , 18 )
		end
		frame:SetSize(300, 80)
		frame.lblTitle:SetTextColor(ui_text)
		frame:Center()
		local p = LocalPlayer()

		frame:MakePopup()
		frame:SetTitle("Stove Heat")
		
		local slider = vgui.Create("DNumSlider", frame)
		slider:SetPos(15, 35)
		slider:SetWide(285)
		slider:SetMin(0)
		slider:SetMax(100)
		slider:SetText("Heat")
		slider:SetConVar("fishingmod_stove_heat")
		slider.Label:SetTextColor(ui_text)
		slider.Wang.m_Skin.colTextEntryText = ui_text
	end
	
	
	
	usermessage.Hook("FishingMod:Stove", function(umr)
		local entity = umr:ReadEntity()
		
		if not IsValid(entity) then return end
		
		entity:ShowHeatAdjuster()
	end)
	
else
	function ENT:Initialize()
		self:SetModel( "models/props_c17/furnitureStove001a.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType(SIMPLE_USE)
		self:PhysWake()
		self.smoothheat = 1
	end
	
	function ENT:PreSell(ply)
		--[[ if self.cvarheat ~= 0 then
			ply:ChatPrint("The stove's heat needs to be 0 for you to sell it!")
			return false
		end ]]
	end
	
	function ENT:Use(ply)
		if player.GetByUniqueID(self.data.ownerid) == ply then
			umsg.Start("FishingMod:Stove", ply)
				umsg.Entity(self)
			umsg.End()

			self.data.owner = ply
		end
	end
	
	function ENT:Think()
		local owner = self.data.owner
		local cvar = IsValid(owner) and owner:GetInfoNum("fishingmod_stove_heat", 0) or 0
		self.cvarheat = cvar
		local heat = math.Clamp(cvar * -1 + 100, 0, 100)		
		
		self.smoothheat = self.smoothheat + ((heat - self.smoothheat) / 1000)
		
		self.dt.heat = self.smoothheat * -1 + 100
		
		for key, data in pairs(self.storage) do
		
			local catch = data.item
			
			catch = IsValid(catch) and IsValid(catch:GetNWEntity("FMRedirect")) and catch:GetNWEntity("FMRedirect") or catch
				
			if catch and #constraint.FindConstraints(catch) == 0 then 
				catch.shelf_stored = nil
				self.storage[key].item = nil
			end
			
			if catch and cvar > 0 then			
				if catch:IsOnFire() then catch.data.fried = 1000 end
								
				catch.data.fried = catch.data.fried or 0
				catch.data.fried = math.Clamp(catch.data.fried + (catch.data.fried * self.dt.heat / 700), 1, 1000)
				
--[[ 				if (lastprint or 0) < CurTime() then 
					print(catch.data.fried, self.smoothheat)
					print(key, catch)
					lastprint = CurTime() + 0.2
				end ]]
				
				if catch.data.fried == 1000 and not catch:IsOnFire() then catch:Ignite(1000) end

				catch:SetColor(fishingmod.FriedToColor(catch.data.fried))
				
				if (catch.last_sent or 0) < CurTime() then
					catch.data.originalvalue = catch.data.originalvalue or catch.data.value or 0
					catch.data.value = math.max(catch.data.originalvalue * fishingmod.FriedToMultiplier(catch.data.fried), 1)
					fishingmod.SetCatchInfo(catch)
					catch.last_sent = CurTime() + 0.3
				end
			end
		end
	
		if (self.next_search or 0) < CurTime() then
		
			for key, entity in pairs( ents.FindInBox( self:GetPos() + self:OBBMins(), self:GetPos() + self:OBBMaxs() * Vector(1, 1, 1.2) ) ) do
				if entity.data and entity ~= self and not entity.shelf_stored and entity:GetClass() ~= "fishing_mod_catch_stove" and not entity.is_bait then
					self:AddItem( entity )
				end
			end
			
			self.next_search = CurTime() + 1
		end
		
		self:NextThink(CurTime())
		return true
	end

	function ENT:AddItem( entity )
	
		local closest = {distance = 200}
		
		for key, value in pairs( self.storage ) do
			if not value.shelf_stored then
				local distance = entity:GetPos():Distance( self:GetPos() + ( self:GetUp() * value.position.z ) + ( self:GetRight() * value.position.x ) + ( self:GetForward() * value.position.y ) )
				if distance < closest.distance then
					closest = { distance = distance, index = key }
					self.storage[key].item = entity
				end
			end
		end
		
		if closest.index then
			local index, data = closest.index, self.storage[closest.index]
			
			entity.weld_broke = false

			entity.shelf_stored = true
								
			timer.Simple(0.1, function()
				if IsValid(self) and IsValid(entity) then
					local isragdoll = entity:GetClass() == "prop_ragdoll" or entity.is_ragdoll or false
					entity = IsValid(entity) and IsValid(entity:GetNWEntity("FMRedirect")) and entity:GetNWEntity("FMRedirect") or entity
					local phys = entity:GetPhysicsObject()
					if IsValid(phys) then
						phys:SetAngles( self:GetAngles() )
						phys:SetPos( self:GetPos() + ( self:GetUp() * (data.position.z + 3) ) + ( self:GetRight() * data.position.x ) + ( self:GetForward() * data.position.y ) - self:OBBCenter())
					end
					constraint.Weld(self, entity, 0, 0, 2500, true)
				end
			end)
		end
		
	end
	
end

scripted_ents.Register(ENT, "fishing_mod_catch_stove", true)