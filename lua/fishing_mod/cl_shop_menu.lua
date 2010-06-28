do -- Upgrade button
	local PANEL = {}
	
	function PANEL:Init()
		self.left = vgui.Create("DSysButton", self)
		self.left:SetSize(20,20)
		self.left:SetType("left")
		self.left:SetTooltip("+0")
		
		self.left.DoClick = function()
			RunConsoleCommand("fishingmod_downgrade_"..self.command, "1")
		end
				
		self.right = vgui.Create("DSysButton", self)
		self.right:SetSize(20,20)
		self.right:SetType("right")		
		
		self.right.DoClick = function()
			RunConsoleCommand("fishingmod_upgrade_"..self.command, "1")
		end

		self.rightlabel = vgui.Create("DLabel", self)
		self.rightlabel:SetTextColor(Color(50,50,50,255))
		self.rightlabel:SetSize(100,30)
		
		self.leftlabel = vgui.Create("DLabel", self)
		self.leftlabel:SetTextColor(Color(50,50,50,255))
		self.leftlabel:SetSize(100,30)
		
		self.left:SetPos(0,0)
		self.leftlabel:SetPos(30,-4)
		self.rightlabel:SetPos(130,-4)
		self.right:SetPos(150,0)
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
end

do -- Upgrade window
	local PANEL = {}
	
	function PANEL:Init()
		local x,y = self:GetParent():GetSize()
		self:SetSize(x,y)			
		
		self.money = vgui.Create("DLabel", self)
		self.money:SetTextColor(Color(50,50,50,255))
		self.money.Think = function(self) self:SetText("Money: "..LocalPlayer().fishingmod.money) end
		self.money:SetSize(100,30)
		self.money:SetPos(10,10)
		
		self.length = vgui.Create("Fishingmod:UpgradeButton", self)
		self.length:SetType("Rod Length:", "length", "rod_length", fishingmod.RodLengthPrice)
		self.length:SetSize(x,y)
		self.length:SetPos(10,50)
		
		self.stringlength = vgui.Create("Fishingmod:UpgradeButton", self)
		self.stringlength:SetType("String Length:", "string_length", "string_length", fishingmod.StringLengthPrice)
		self.stringlength:SetSize(x,y)
		self.stringlength:SetPos(10,80)
		
		self.reelspeed = vgui.Create("Fishingmod:UpgradeButton", self)
		self.reelspeed:SetType("Reel Speed:", "reel_speed", "reel_speed", fishingmod.ReelSpeedPrice)
		self.reelspeed:SetSize(x,y)
		self.reelspeed:SetPos(10,110)
		
		self.force = vgui.Create("Fishingmod:UpgradeButton", self)
		self.force:SetType("Hook Force:", "force", "hook_force", fishingmod.HookForcePrice)
		self.force:SetSize(x,y)
		self.force:SetPos(10,140)
			
	end
	
	vgui.Register("Fishingmod:Upgrade", PANEL)
end

do -- Markup Tooltip
	local PANEL = {}
	
	function PANEL:Init()
		self.BaseClass.Init(self)
		self.percent = 0
	end
	
	function PANEL:SetSale(multiplier)
		self.percent = math.Round((multiplier*-1+1)*100)
	end
	
	function PANEL:SetGrey(bool)
		self.grey = bool
	end
	
	function PANEL:OnCursorEntered()
	
	end

	function PANEL:OnCursorExited()
	
	end

	function PANEL:PaintOver()
		draw.SimpleText( self.percent.."% OFF", "DefaultFixedOutline", 4, 2, HSVToColor(math.Clamp(self.percent+40,0,160),1,1), TEXT_ALIGN_LEFT,TEXT_ALIGN_LEFT)
		if self.grey then draw.RoundedBox( 6, 0, 0, 58, 58, Color( 100, 100, 100, 200 ) ) end
	end
	
	vgui.Register("Fishingmod:SpawnIcon", PANEL, "SpawnIcon")
end

do -- Bait Shop
	local PANEL = {}
	
	function PANEL:Init()
		self:StretchToParent(5,5,5,5)			
		
		self.list = vgui.Create("DPanelList", self)
		
		local list = self.list
		
		list:StretchToParent(3,3,3,45)
		list:EnableHorizontal(true)
		list:EnableVerticalScrollbar(true)
		
		local tbl = {}
		for key, data in pairs(fishingmod.BaitTable) do
			tbl[data.models[1]] = {price = data.price, name = key}
		end	
				
		for model, data in pairs(tbl) do
			local level = LocalPlayer().fishingmod.level
			local levelrequired = fishingmod.CatchTable[data.name].levelrequired
		
			local icon = vgui.Create("Fishingmod:SpawnIcon")
			icon:SetModel(model)
			icon:SetToolTip("This bait cost " .. data.price .. " and\nit is a level "..levelrequired.." bait.")
			icon:SetIconSize(58)
			fishingmod.BaitTable[data.name].icon = icon
			
			if level < levelrequired then
				icon:SetGrey(true)
			else
				icon.DoClick = function()
					RunConsoleCommand("fishing_mod_buy_bait", data.name)
				end
			end
			list:AddItem(icon)
		end
			
	end
	
	vgui.Register("Fishingmod:BaitShop", PANEL)
end

do -- Tab holder
	local PANEL = {}

	function PANEL:Init()
		self:SetSize(205, 230)
		self:MakePopup()
		self:Center()
		self:SetDeleteOnClose(false)
		self:SetTitle("Fishing Mod")
		
		self.baitshop = vgui.Create("Fishingmod:BaitShop", self)
		
		fishingmod.BaitIcons = self.baitshop.list:GetItems()
		
		self.upgrade = vgui.Create("Fishingmod:Upgrade", self)
		
		self.sheet = vgui.Create("DPropertySheet", self)
		self.sheet:SetPos(1,24)
		self.sheet:SetSize(self:GetWide()-2, self:GetTall()-23)
		
		self.sheet:AddSheet("Upgrade", self.upgrade, "gui/silkicons/star", false, false)
		self.sheet:AddSheet("Bait Shop", self.baitshop, "gui/silkicons/add", false, false)
		
		fishingmod.UpdateSales()
	end

	vgui.Register( "Fishingmod:ShopMenu", PANEL, "DFrame" )
end

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