local PANEL = {} -- Main panel

local FishingMod_spriteMinus, a = Material("sprites/key_13")
local FishingMod_spritePlus, a = Material("sprites/key_12")
FishingMod_spriteMinus:SetInt("$flags", 2097152)
FishingMod_spritePlus:SetInt("$flags", 2097152)
local black = Color(0, 0, 0, 144)
local grey = Color(160, 160, 160, 255)
function PANEL:Init()

	self:MakePopup()
	self:SetDeleteOnClose(false)
	self:SetSizable(true)
	self:SetTitle("Fishing Mod")
	self:ShowCloseButton(false)
	self:SetSize(354, 224)
	self:Center()

	self.baitshop = vgui.Create("Fishingmod:BaitShop", self)
	
	fishingmod.BaitIcons = self.baitshop:GetItems()
	
	self.upgrade = vgui.Create("Fishingmod:Upgrade", self)

	local xpx, xpy = self:GetSize()

	local upgradesbutton = vgui.Create("DButton", self) -- upgrades
	local baitsbutton = vgui.Create("DButton", self) -- baits shop
	upgradesbutton.selected = true
	baitsbutton.selected = false
	upgradesbutton:SetPos(3, 24)
	upgradesbutton:SetSize((xpx - 6) / 2, 22)
	upgradesbutton:SetText("Upgrades")
	function upgradesbutton.Think()
		xpx, xpy = self:GetSize()
		upgradesbutton:SetSize((xpx - 6) / 2, 22)
	end
	upgradesbutton:SetTextColor(color_white)
	upgradesbutton.DoClick = function()
		baitsbutton:SetColor(grey)
		upgradesbutton:SetColor(selected)
		upgradesbutton.selected = true
		baitsbutton.selected = false
		self.upgrade:Show()
		self.baitshop:Hide()
	end
	upgradesbutton.Paint = function(self, w, h)
		if(upgradesbutton:IsHovered()) then
			surface.SetDrawColor(0, 0, 0, 144)
		elseif(upgradesbutton.selected) then
			surface.SetDrawColor(0, 0, 0, 144)
		else
			surface.SetDrawColor(0, 0, 0, 72)
		end
		surface.DrawRect(0, 0, w, h)
	end

	baitsbutton:SetPos(3 + (xpx - 6) / 2, 24) -- baits shop start of conf
	baitsbutton:SetSize((xpx - 6) / 2, 22)
	function baitsbutton.Think()
		xpx, xpy = self:GetSize()
		if(xpx % 2 == 1) then
			baitsbutton:SetSize((xpx - 6) / 2 + 1, 22) -- pixelperfect..
		else
			baitsbutton:SetSize((xpx - 6) / 2, 22)
		end
		baitsbutton:SetPos(3 + (xpx - 6) / 2, 24)
	end
	baitsbutton:SetText("Bait Shop")
	baitsbutton:SetTextColor(grey)
	baitsbutton.DoClick = function()
		baitsbutton:SetColor(selected)
		upgradesbutton:SetColor(grey)
		upgradesbutton.selected = false
		baitsbutton.selected = true
		self.upgrade:Hide()
		self.baitshop:Show()
	end
	baitsbutton.Paint = function(self, w, h)
		if(baitsbutton:IsHovered()) then
			surface.SetDrawColor(0, 0, 0, 144)
		elseif(baitsbutton.selected) then
			surface.SetDrawColor(0, 0, 0, 144)
		else
			surface.SetDrawColor(0, 0, 0, 72)
		end
		surface.DrawRect(0, 0, w, h)
	end

	function self:Paint()
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetDrawColor(0, 0, 0, 144)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		return true
	end
	local closebutton = vgui.Create("DButton", self)
	local x, y = self:GetSize()
	closebutton.ButtonW = 60
	closebutton:SetSize(closebutton.ButtonW, 18)
	closebutton:SetText("Close")
	closebutton:SetTextColor(selected)
	closebutton:SetPos(x - closebutton.ButtonW - 3, 3)
	closebutton.DoClick = function()
		self:Close()
	end
	function self:OnSizeChanged(x, y)
		closebutton:SetPos(math.max(x - closebutton.ButtonW - 3, 3), 3)
		closebutton:SetSize(math.min(closebutton.ButtonW, x - 6) , 18 )
	end
	closebutton.Paint = function(self, w, h)
		if(closebutton:IsDown() ) then
			surface.SetDrawColor(0, 0, 0, 72)
		elseif(closebutton:IsHovered()) then
			surface.SetDrawColor(155, 155, 155, 144)
		else
			surface.SetDrawColor(0, 0, 0, 144)
		end
		surface.DrawRect(0, 0, w, h)
	end
	
	function self.baitshop:Paint()
		surface.SetDrawColor(0, 0, 0, 144)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		return true
	end
	
	fishingmod.UpdateSales()
end

vgui.Register( "Fishingmod:ShopMenu", PANEL, "DFrame" )


-- Upgrade Tab 
local PANEL = {}

function PANEL:Init()
	local x, y = self:GetParent():GetSize()
	self:SetSize(x - 6 , y - 3 - 46)
	function self:Think()
		x, y = self:GetParent():GetSize()
		self:SetSize(x - 6, y - 3 - 46 )
	end
	self:SetPos(3, 46)
	self:SetPadding(10)
	function self:Paint()
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetDrawColor(0, 0, 0, 144)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		return true
	end

	self.money = vgui.Create("DLabel", self)
	self.money:SetTextColor(selected)
	self.money.Think = function(self) self:SetText("Money: " .. math.Round(LocalPlayer().fishingmod.money, 2)) end
	
	self:AddItem(self.money)
	
	self.length = vgui.Create("Fishingmod:UpgradeButton", self)
	self.length:SetType("Rod Length:", "length", "rod_length", fishingmod.RodLengthPrice)

	self:AddItem(self.length)
	
	self.stringlength = vgui.Create("Fishingmod:UpgradeButton", self)
	self.stringlength:SetType("String Length:", "string_length", "string_length", fishingmod.StringLengthPrice)

	self:AddItem(self.stringlength)
	
	self.reelspeed = vgui.Create("Fishingmod:UpgradeButton", self)
	self.reelspeed:SetType("Reel Speed:", "reel_speed", "reel_speed", fishingmod.ReelSpeedPrice)
	self:AddItem(self.reelspeed)
	
	self.force = vgui.Create("Fishingmod:UpgradeButton", self)
	self.force:SetType("Hook Force:", "force", "hook_force", fishingmod.HookForcePrice)
	self:AddItem(self.force)
end

vgui.Register("Fishingmod:Upgrade", PANEL, "DPanelList")
	
	
	
-- Bait Shop tab
local PANEL = {}

function PANEL:Init()
	
	local x, y = self:GetParent():GetSize()
	self:SetSize(x - 6, y - 3 - 46)
	local parent = self:GetParent()
	function self:Think()
		x, y = self:GetParent():GetSize()
		self:SetSize(x - 6, y - 3 - 46)
	end
	self:SetPos(3, 46)
	self:EnableHorizontal(true)
	self:EnableVerticalScrollbar(true)
	self:SetVisible(false)
	local tol_tab = {}
	local model_seen = {}
	for key, data in ipairs(fishingmod.BaitTable) do -- sorting by level required because it was semi-random before
		if(not model_seen[data.models[1]]) then
			model_seen[data.models[1]] = true -- the system is wack so i beat it back
			tol_tab[#tol_tab+1] = {
				price = data.price,
				name = key,
				model = data.models[1],
				levelrequired = data.levelrequired
			}
		end
	end
	table.SortByMember(tol_tab, "levelrequired", true)

	-- Add baits
	for key, data in ipairs(tol_tab) do
		local level = LocalPlayer().fishingmod.level
		local icon = vgui.Create("Fishingmod:SpawnIcon")
		icon:SetModel(data.model)
		icon:SetToolTip("This bait cost " .. data.price .. " and\nit is a_ level " .. data.levelrequired .. " bait.")
		icon:SetSize(58, 58)
		
		fishingmod.BaitTable[data.name].icon = icon
		
		if(level < data.levelrequired) then
			icon:SetGrey(true)
		else
			icon.DoClick = function()
				RunConsoleCommand("fishing_mod_buy_bait", data.name)
			end
		end
		self:AddItem(icon)
	end
		
end

vgui.Register("Fishingmod:BaitShop", PANEL, "DPanelList")


------------- Helper components --------------
	
-- Upgrade button
local PANEL = {}

function PANEL:Init()
	self.left = vgui.Create("DButton", self)
	self.left:SetSize(24, 20)
	self.left:SetTooltip("+0")
	self.left.DoClick = function()
		RunConsoleCommand("fishingmod_downgrade_"..self.command, "1")
	end
	
	self.right = vgui.Create("DButton", self)
	self.right:SetSize(24, 20)
	self.right.DoClick = function()
		RunConsoleCommand("fishingmod_upgrade_"..self.command, "1")
	end
	
	self.rightlabel = vgui.Create("DLabel", self)
	self.rightlabel:SetSize(100, 30)
	
	self.leftlabel = vgui.Create("DLabel", self)
	self.leftlabel:SetSize(100, 30)
	
	self.left:Dock(LEFT)
	self.leftlabel:SetPos(30, -2)
	self.rightlabel:SetPos(130, -2)
	self.right:Dock(RIGHT)
	local selfleft = self.left
	function self.left:Paint()
		surface.SetFont("DebugFixed")
		surface.SetTextColor(255, 255, 255, 255)
		if(selfleft:IsDown()) then
			surface.SetDrawColor(0, 0, 0, 50)
		elseif(selfleft:IsHovered()) then
			surface.SetDrawColor(155, 155, 155, 100)
		else
			surface.SetDrawColor(0, 0, 0, 100)
		end
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetDrawColor(selected)
		surface.SetMaterial(FishingMod_spriteMinus)
		surface.DrawTexturedRect(1, 1, self:GetWide() - 2, self:GetTall() - 2)
		return true
	end
	local selfright = self.right
	function self.right:Paint()
		surface.SetFont("DebugFixed")
		surface.SetTextColor(255, 255, 255, 255)

		if(selfright:IsDown()) then
			surface.SetDrawColor(0, 0, 0, 50)
		elseif(selfright:IsHovered()) then
			surface.SetDrawColor(155, 155, 155, 100)
		else
			surface.SetDrawColor(0, 0, 0, 100)
		end
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetDrawColor(selected)
		surface.SetMaterial(FishingMod_spritePlus)
		surface.DrawTexturedRect(1, 1, self:GetWide() - 2, self:GetTall() - 2)
		return true
	end
end

function PANEL:SetType(friendly, type, command, loss)
	self.friendly = friendly
	self.command = command
	self.type = type
	self.right:SetTooltip("-"..loss)
	self.set = true
	self.leftlabel:SetText(self.friendly)
end

function PANEL:Think()
	if not self.set then return end
	self.rightlabel:SetText(LocalPlayer().fishingmod[self.type])
end

vgui.Register("Fishingmod:UpgradeButton", PANEL)


-- Markup Tooltip
local PANEL = {}

function PANEL:Init()
	self.percent = 0
end

function PANEL:SetSale(multiplier)
	self.percent = math.Round((multiplier*-1+1)*100)
end

function PANEL:SetGrey(bool)
	self.grey = bool
end

function PANEL:PaintOver(w, h)
	self.BaseClass.PaintOver(self, w, h)

	draw.SimpleText( self.percent.."% OFF", "DermaDefault", 5, 3, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	draw.SimpleText( self.percent.."% OFF", "DermaDefault", 4, 2, HSVToColor(math.Clamp(self.percent + 40, 0, 160), 1, 1), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	if self.grey then draw.RoundedBox( 6, 0, 0, 58, 58, Color( 100, 100, 100, 200 ) ) end
end

vgui.Register("Fishingmod:SpawnIcon", PANEL, "SpawnIcon")




function fishingmod.UpdateSales()
	for key, bait in ipairs(fishingmod.BaitTable) do
		local levelrequired = fishingmod.CatchTable[key].levelrequired
		local saleprice = math.Round(bait.price * bait.multiplier)
		local sale = "This bait now cost " .. math.Round(bait.price * bait.multiplier) .. "!\nIts original price is " .. bait.price .. "."
		
		if saleprice == 0 then
			sale = "This bait is free! "
		end
		
		if IsValid(bait.icon) then
			bait.icon:SetToolTip(sale .. "\nYou need to be level " .. levelrequired .. " or higher to use this bait.")
			bait.icon:SetSale(bait.multiplier)
		end
	end
end
