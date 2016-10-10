local PANEL = {} -- Main panel

function PANEL:Init()

	self:MakePopup()
	self:SetDeleteOnClose(false)
	self:SetSizable(true)
	self:SetTitle("Fishing Mod")

	
	self.baitshop = vgui.Create("Fishingmod:BaitShop", self)
	
	fishingmod.BaitIcons = self.baitshop:GetItems()
	
	self.upgrade = vgui.Create("Fishingmod:Upgrade", self)
	
	self.sheet = vgui.Create("DPropertySheet", self)
	self:DockPadding(3,21+3,3,3)
	self.sheet:Dock(FILL)
	self:SetSize(300, 400)self:Center()
	
	
	self.sheet:AddSheet("Upgrade", self.upgrade, "icon16/star.png", false, false)
	self.sheet:AddSheet("Bait Shop", self.baitshop, "icon16/add.png", false, false)
	
	fishingmod.UpdateSales()
	
end
vgui.Register( "Fishingmod:ShopMenu", PANEL, "DFrame" )


-- Upgrade Tab 
local PANEL = {}

function PANEL:Init()
	local x,y = self:GetParent():GetSize()
	self:SetSize(x,y)			
	self:SetPadding(5)
	self:SetPadding(5)
	
	self.money = vgui.Create("DLabel", self)
	self.money.Think = function(self) self:SetText("Money: "..LocalPlayer().fishingmod.money) end
	
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

vgui.Register("Fishingmod:Upgrade", PANEL,"DPanelList")
	
	
	
-- Bait Shop tab
local PANEL = {}

function PANEL:Init()
	
	self:Dock(FILL)
	self:EnableHorizontal(true)
	self:EnableVerticalScrollbar(true)
	
	local tbl = {}
	for key, data in pairs(fishingmod.BaitTable) do
		tbl[data.models[1]] = {price = data.price, name = key}
	end	
	
	-- Add baits
	for model, data in pairs(tbl) do
		local level = LocalPlayer().fishingmod.level
		local levelrequired = fishingmod.CatchTable[data.name].levelrequired
	
		local icon = vgui.Create("Fishingmod:SpawnIcon")
		icon:SetModel(model)
		icon:SetToolTip("This bait cost " .. data.price .. " and\nit is a level "..levelrequired.." bait.")
		icon:SetSize(58,58)
		
		fishingmod.BaitTable[data.name].icon = icon
		
		if level < levelrequired then
			icon:SetGrey(true)
		else
			icon.DoClick = function()
				RunConsoleCommand("fishing_mod_buy_bait", data.name)
			end
		end
		self:AddItem(icon)
	end
		
end
	
vgui.Register("Fishingmod:BaitShop", PANEL,"DPanelList")


------------- Helper components --------------
	
-- Upgrade button
local PANEL = {}

function PANEL:Init()
	self.left = vgui.Create("DButton", self)
	self.left:SetSize(20,20)
	self.left:SetText("<<")
	self.left:SetTooltip("+0")
	
	self.left.DoClick = function()
		RunConsoleCommand("fishingmod_downgrade_"..self.command, "1")
	end
			
	self.right = vgui.Create("DButton", self)
	self.right:SetSize(20,20)
	self.right:SetText(">>")		
	
	self.right.DoClick = function()
		RunConsoleCommand("fishingmod_upgrade_"..self.command, "1")
	end

	self.rightlabel = vgui.Create("DLabel", self)
	self.rightlabel:SetSize(100,30)
	
	self.leftlabel = vgui.Create("DLabel", self)
	self.leftlabel:SetSize(100,30)
	
	self.left:Dock(LEFT)
	self.leftlabel:SetPos(30,-4)
	self.rightlabel:SetPos(130,-4)
	self.right:Dock(RIGHT)
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

	draw.SimpleText( self.percent.."% OFF", "DermaDefault", 5, 3, color_black, TEXT_ALIGN_LEFT,TEXT_ALIGN_LEFT)
	draw.SimpleText( self.percent.."% OFF", "DermaDefault", 4, 2, HSVToColor(math.Clamp(self.percent+40,0,160),1,1), TEXT_ALIGN_LEFT,TEXT_ALIGN_LEFT)
	if self.grey then draw.RoundedBox( 6, 0, 0, 58, 58, Color( 100, 100, 100, 200 ) ) end
end

vgui.Register("Fishingmod:SpawnIcon", PANEL, "SpawnIcon")




function fishingmod.UpdateSales()
	for key, bait in pairs(fishingmod.BaitTable) do
		local levelrequired = fishingmod.CatchTable[key].levelrequired
		local saleprice = math.Round(bait.price * bait.multiplier)
		local sale = "This bait now cost " .. math.Round(bait.price * bait.multiplier) .. "!\nIts original price is " .. bait.price .. "."
		
		if saleprice == 0 then
			sale = "This bait is free! "
		end
		
		if IsValid(bait.icon) then
			bait.icon:SetToolTip(sale .. "\nYou need to be level "..levelrequired.." or higher to use this bait.")
			bait.icon:SetSale(bait.multiplier)
		end
	end
end
