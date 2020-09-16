function fishingmod.DefaultUIColors()
	return {
		["uiText"] = Color(255, 255, 255, 255),
		["uiTextCaught"] = Color(0, 255, 0, 255),
		["uiTextBg"] = Color(160, 160, 160, 255),
		["uiButtonSelected"] = Color(0, 0, 0, 144),
		["uiButtonDeSelected"] = Color(0, 0, 0, 72),
		["uiButtonHovered"] = Color(120, 120, 120, 144),
		["uiButtonPressed"] = Color(0, 0, 0, 50),
		["uiBackground"] = Color(0, 0, 0, 225),
		["xpBarForeGr"] = Color(0, 200, 0, 255),
		["xpBarBackGr"] = Color(255, 255, 255, 55),
		["xpBarText"] = Color(0, 0, 0, 255),
		["crossHairColor"] = Color(255,255,255,127),
	}
end
local translation = {
	["uiText"] = "General Text",
	["uiTextCaught"] = "Catch Text",
	["uiTextBg"] = "Background Text",
	["uiButtonSelected"] = "Selected Button",
	["uiButtonDeSelected"] = "Button De-selected",
	["uiButtonHovered"] = "Button Hovered",
	["uiButtonPressed"] = "Button Pressed",
	["uiBackground"] = "Background",
	["xpBarForeGr"] = "XP Bar Foreground",
	["xpBarBackGr"] = "XP Bar Background",
	["xpBarText"] = "XP Bar Text",
	["crossHairColor"] = "Crosshair",
 -- both ways
	["General Text"] = "uiText",
	["Catch Text"] = "uiTextCaught",
	["Background Text"] = "uiTextBg",
	["Selected Button"] = "uiButtonSelected",
	["Button De-selected"] = "uiButtonDeSelected",
	["Button Hovered"] = "uiButtonHovered",
	["Button Pressed"] = "uiButtonPressed",
	["Background"] = "uiBackground",
	["XP Bar Foreground"] = "xpBarForeGr",
	["XP Bar Background"] = "xpBarBackGr",
	["XP Bar Text"] = "xpBarText",
	["Crosshair"] = "crossHairColor",
}
local fishingmodDataPath, fishingmodDataFileName = "fishingmod", "/ui_color_data.txt"
function fishingmod.SaveUIColors()
    if not file.Exists(fishingmodDataPath, "DATA") then
        file.CreateDir(fishingmodDataPath)
	end
	local newData = {}
	local returnData = fishingmod.DefaultUIColors()
	if fishingmod.ColorTable then
		for k, v in pairs(fishingmod.ColorTable) do
			newData[k] = tostring(v.r) .. " " .. tostring(v.g) .. " " .. tostring(v.b) .. " ".. tostring(v.a)
		end
		table.Merge(returnData, newData)
	end
	file.Write(fishingmodDataPath .. fishingmodDataFileName, util.TableToJSON(returnData, false))
	newData = nil
end
function fishingmod.LoadUIColors()
	local tempCol = Color(0, 0, 0, 72)
	if file.Exists(fishingmodDataPath, "DATA") then
		if file.Exists(fishingmodDataPath .. fishingmodDataFileName, "DATA") then
			local tempData = util.JSONToTable(file.Read(fishingmodDataPath .. fishingmodDataFileName, "DATA"))
			local returnData = fishingmod.DefaultUIColors()
			if tempData then
				for k, v in pairs(tempData) do
					if k and v then
						if #tostring(k) < 4 then return end
						if #tostring(v) < 4 then return end
						tempData[k] = string.ToColor(v) or tempCol
					end
				end
				table.Merge(returnData, tempData)
			end
			tempData = {}
			return returnData
		else
			return fishingmod.DefaultUIColors() -- return defaults if the file does not exist
		end
	else
		return fishingmod.DefaultUIColors() -- return defaults if the folder does not exist
	end
end
fishingmod.ColorTable = fishingmod.LoadUIColors()


if not fishingmod.ColorTable then
	fishingmod.ColorTable = fishingmod.DefaultUIColors()
end

local FishingMod_spriteMinus, a = Material("sprites/key_13")
local FishingMod_spritePlus, a = Material("sprites/key_12")
FishingMod_spriteMinus:SetInt("$flags", 2097152)
FishingMod_spritePlus:SetInt("$flags", 2097152)

local backGround = fishingmod.DefaultUIColors().uiBackground
local uiText = fishingmod.DefaultUIColors().uiText
local buttonNotSelected = fishingmod.DefaultUIColors().uiTextBg
local uiButtonHovered = fishingmod.DefaultUIColors().uiButtonHovered
local nopres = fishingmod.DefaultUIColors().uiButtonDeSelected
local pres = fishingmod.DefaultUIColors().uiButtonPressed
local masterX, masterY = 354, 224

local PANEL = {} -- Main panel

function PANEL:Init()
	if fishingmod.ColorTable then
		backGround = fishingmod.ColorTable.uiBackground or backGround
		uiText = fishingmod.ColorTable.uiText or uiText
		buttonNotSelected = fishingmod.ColorTable.uiTextBg or buttonNotSelected
		uiButtonHovered = fishingmod.ColorTable.uiButtonHovered or uiButtonHovered
		nopres = fishingmod.ColorTable.uiButtonDeSelected or nopres
		pres = fishingmod.ColorTable.uiButtonPressed or pres
	end
	self:MakePopup()
	self:SetDeleteOnClose(false)
	self:SetSizable(true)
	self:SetTitle("Fishing Mod")
	self.lblTitle:SetTextColor(uiText)
	self:ShowCloseButton(false)
	self:SetSize(masterX, masterY)
	self:Center()

	self.baitshop = vgui.Create("Fishingmod:BaitShop", self)
	
	fishingmod.BaitIcons = self.baitshop:GetItems()
	
	self.upgrade = vgui.Create("Fishingmod:Upgrade", self)

	self.customization = vgui.Create("Fishingmod:Customization", self)

	local xpx, xpy = self:GetSize()

	local upgradesbutton = vgui.Create("DButton", self) -- upgrades
	local baitsbutton = vgui.Create("DButton", self) -- baits shop
	local customizationbutton = vgui.Create("DButton", self) -- customization tab

	upgradesbutton.selected = true
	baitsbutton.selected = false
	upgradesbutton:SetPos(3, 24)
	upgradesbutton:SetSize((xpx - 6) / 3, 22)
	upgradesbutton:SetText("Upgrades")
	function upgradesbutton.Think()
		xpx, xpy = self:GetSize()
		upgradesbutton:SetSize((xpx - 6) / 3, 22)
	end
	upgradesbutton:SetTextColor(uiText)
	upgradesbutton.DoClick = function()
		upgradesbutton:SetColor(uiText)
		baitsbutton:SetColor(nopres)
		customizationbutton:SetColor(nopres)

		baitsbutton:SetTextColor(buttonNotSelected)
		customizationbutton:SetTextColor(buttonNotSelected)

		upgradesbutton.selected = true
		baitsbutton.selected = false
		customizationbutton.selected = false

		self.customization:Hide()
		self.upgrade:Show()
		self.baitshop:Hide()
	end
	upgradesbutton.Paint = function(self, w, h)
		if self.selected then
			upgradesbutton:SetColor(uiText)
		elseif not self.selected then
			upgradesbutton:SetColor(buttonNotSelected)
		end
		if upgradesbutton:IsHovered() then
			surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		elseif upgradesbutton.selected then
			surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		else
			surface.SetDrawColor(nopres.r, nopres.g, nopres.b, nopres.a)
		end
		surface.DrawRect(0, 0, w, h)
	end

	baitsbutton:SetPos(3 + (xpx - 6) / 3, 24) -- baits shop start of conf
	baitsbutton:SetSize((xpx - 6) / 3, 22)
	function baitsbutton.Think()
		xpx, xpy = self:GetSize()
		baitsbutton:SetSize((xpx - 6) / 3, 22)
		baitsbutton:SetPos(3 + (xpx - 6) / 3, 24)
	end
	baitsbutton:SetText("Bait Shop")
	baitsbutton:SetTextColor(buttonNotSelected)
	baitsbutton.DoClick = function()
		baitsbutton:SetColor(uiText)
		upgradesbutton:SetColor(nopres)
		customizationbutton:SetColor(nopres)

		upgradesbutton:SetTextColor(buttonNotSelected)
		customizationbutton:SetTextColor(buttonNotSelected)

		upgradesbutton.selected = false
		baitsbutton.selected = true
		customizationbutton.selected = false

		self.customization:Hide()
		self.upgrade:Hide()
		self.baitshop:Show()
	end
	baitsbutton.Paint = function(self, w, h)
		if self.selected then
			baitsbutton:SetColor(uiText)
		elseif not self.selected then
			baitsbutton:SetColor(buttonNotSelected)
		end
		if baitsbutton:IsHovered() then
			surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		elseif baitsbutton.selected then
			surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		else
			surface.SetDrawColor(nopres.r, nopres.g, nopres.b, nopres.a)
		end
		surface.DrawRect(0, 0, w, h)
	end


	customizationbutton:SetPos(3 + (xpx - 6) / 3, 24) -- baits shop start of conf
	customizationbutton:SetSize((xpx - 6) / 3, 22)
	
	function customizationbutton.Think()
		xpx, xpy = self:GetSize()
		if xpx % 3 == 2 then
			customizationbutton:SetSize(math.Round((xpx - 6) / 3) + 1 , 22)
			customizationbutton:SetPos(2 + (xpx - 6) / 3 * 2 , 24)
		elseif xpx % 3 == 1  then
			customizationbutton:SetSize(math.Round((xpx - 6) / 3) + 1, 22)
			customizationbutton:SetPos(3 + (xpx - 6) / 3 * 2 , 24)
		else
			customizationbutton:SetSize(math.Round((xpx - 6) / 3) , 22)
			customizationbutton:SetPos(3 + (xpx - 6) / 3 * 2 , 24)
		end
	end
	customizationbutton:SetText("Customize")
	customizationbutton:SetTextColor(buttonNotSelected)
	customizationbutton.DoClick = function()
		customizationbutton:SetColor(uiText)
		upgradesbutton:SetColor(nopres)
		baitsbutton:SetColor(nopres)

		upgradesbutton:SetTextColor(buttonNotSelected)
		baitsbutton:SetTextColor(buttonNotSelected)

		upgradesbutton.selected = false
		baitsbutton.selected = false
		customizationbutton.selected = true

		self.customization:Show()
		self.upgrade:Hide()
		self.baitshop:Hide()

	end
	customizationbutton.Paint = function(self, w, h)
		if self.selected then
			customizationbutton:SetColor(uiText)
		elseif not self.selected then
			customizationbutton:SetColor(buttonNotSelected)
		end
		if(customizationbutton:IsHovered()) then
			surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		elseif(customizationbutton.selected) then
			surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		else
			surface.SetDrawColor(nopres.r, nopres.g, nopres.b, nopres.a)
		end
		surface.DrawRect(0, 0, w, h)
	end


	function self:Paint()
		surface.SetTextColor(uiText.r, uiText.g, uiText.b, uiText.a)
		surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		return true
	end
	local closebutton = vgui.Create("DButton", self)
	local x, y = self:GetSize()
	closebutton.ButtonW = 60
	closebutton:SetSize(closebutton.ButtonW, 18)
	closebutton:SetText("Close")
	closebutton:SetTextColor(uiText)
	closebutton:SetPos(x - closebutton.ButtonW - 3, 3)
	closebutton.DoClick = function()
		self:Close()
	end
	function self:OnSizeChanged(x, y)
		closebutton:SetPos(math.max(x - closebutton.ButtonW - 3, 3), 3)
		closebutton:SetSize(math.min(closebutton.ButtonW, x - 6) , 18 )
	end
	closebutton.Paint = function(self, w, h)
		self:GetParent().lblTitle:SetTextColor(uiText)
		closebutton:SetTextColor(uiText)
		if(closebutton:IsDown() ) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(closebutton:IsHovered()) then
			surface.SetDrawColor(uiButtonHovered.r, uiButtonHovered.g, uiButtonHovered.b, uiButtonHovered.a)
		else
			surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		end
		surface.DrawRect(0, 0, w, h)
	end
	
	function self.baitshop:Paint()
		surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
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
		surface.SetTextColor(uiText.r, uiText.g, uiText.b, uiText.a)
		surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		self.money:SetTextColor(uiText)
		return true
	end

	self.money = vgui.Create("DLabel", self)
	self.money:SetTextColor(uiText)
	self.money.Think = function(self) self:SetText("Money: " .. math.Round(LocalPlayer().fishingmod.money)) end
	
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
	for key, data in pairs(fishingmod.BaitTable) do -- sorting by level required because it was semi-random before
		if(not model_seen[data.models[1]]) then
			model_seen[data.models[1]] = true -- the system is wack so i beat it back
			tol_tab[#tol_tab + 1] = {
				price = data.price,
				name = key,
				model = data.models[1],
				levelrequired = data.levelrequired
			}
		end
	end
	table.SortByMember(tol_tab, "levelrequired", true)

	-- Add baits
	for key, data in pairs(tol_tab) do
		local level = LocalPlayer().fishingmod.level
		local icon = vgui.Create("Fishingmod:SpawnIcon")
		icon:SetModel(data.model)
		icon:SetToolTip("This bait cost " .. data.price .. " and\nit is a_ level " .. data.levelrequired .. " bait.")
		icon:SetSize(58, 58)
		
		fishingmod.BaitTable[data.name].icon = icon
		
		if(level < data.levelrequired) then
			icon:SetGray(true)
		else
			icon.DoClick = function()
				RunConsoleCommand("fishing_mod_buy_bait", data.name)
			end
		end
		self:AddItem(icon)
	end
		
end

vgui.Register("Fishingmod:BaitShop", PANEL, "DPanelList")


-- Customization tab
local PANEL = {}

function PANEL:Init()
	local x, y = self:GetParent():GetSize()
	self:SetSize(x - 6, y - 3 - 46)
	self:SetPos(3, 46)
	self:SetVisible(false)
	function self:Think()
		x, y = self:GetParent():GetSize()
		self:SetSize(x - 6, y - 3 - 46)
		if fishingmod.ColorTable then
			backGround = fishingmod.ColorTable.uiBackground or backGround
			uiText = fishingmod.ColorTable.uiText or uiText
			buttonNotSelected = fishingmod.ColorTable.uiTextBg or buttonNotSelected
			uiButtonHovered = fishingmod.ColorTable.uiButtonHovered or uiButtonHovered
			nopres = fishingmod.ColorTable.uiButtonDeSelected or nopres
			pres = fishingmod.ColorTable.uiButtonPressed or pres
		else
			fishingmod.ColorTable = fishingmod.DefaultUIColors()
		end
	end

	local savebutton = vgui.Create("DButton", self)
	savebutton:SetPos(10, 50)
	savebutton:SetSize(120, 30)
	savebutton:SetTextColor(uiText)
	savebutton:SetText("Save")
	savebutton.Paint = function(self, w, h)
		savebutton:SetTextColor(uiText)
		surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		surface.DrawRect(0, 0, w, h)
	end

	savebutton.DoClick = function()
		if fishingmod.SaveUIColors then
			fishingmod.SaveUIColors()
			chat.AddText(Color(0, 255, 0, 255), "[Fishing Mod]", Color(255, 255, 255), ": Colors have been saved!")
		end
	end
	local resetbutton = vgui.Create("DButton", self)
	resetbutton:SetPos(10, 90)
	resetbutton:SetSize(120, 30)
	resetbutton:SetTextColor(uiText)
	resetbutton:SetText("Reset")
	resetbutton.Paint = function(self, w, h)
		resetbutton:SetTextColor(uiText)
		surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		surface.DrawRect(0, 0, w, h)
	end

	resetbutton.DoClick = function()
		if fishingmod.DefaultUIColors then
			fishingmod.ColorTable = fishingmod.DefaultUIColors()
			chat.AddText(Color(0, 255, 0, 255), "[Fishing Mod]", Color(255, 255, 255), ": Colors have been reset!")
		end
	end
	
	local combobox = vgui.Create("DComboBox", self )
	combobox:SetPos(10, 10)
	combobox:SetSize(120, 30)
	combobox:SetValue("Select element")
	if fishingmod.ColorTable then
		if fishingmod.LoadUIColors then
			for k, v in pairs(fishingmod.LoadUIColors()) do
				combobox:AddChoice(translation[k])
			end
		end
	end
	combobox.Paint = function(self, w, h)
		combobox:SetTextColor(uiText)
		if(combobox:IsDown()) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(combobox:IsHovered()) then
			surface.SetDrawColor(uiButtonHovered.r, uiButtonHovered.g, uiButtonHovered.b, uiButtonHovered.a)
		else
			surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		end
		surface.DrawRect(0, 0, w, h)
	end
	local colormixer = vgui.Create( "DColorMixer", self)
	local x, y = self:GetSize()
	colormixer:SetPos(120 + 20, 10)
	colormixer:SetWangs(true)
	colormixer:SetPalette(false)
	colormixer:SetSize(x - 10 - 120 - 20, y - 20)
	function colormixer:ValueChanged(col)
		if editable and editable != "" and fishingmod.DefaultUIColors()[editable] then
			fishingmod.ColorTable[editable] = Color(col.r, col.g, col.b, col.a)
		end
	end
	function combobox.OnSelect(self, val, str)
		if type(str)=="string" and str != "" then
			editable = translation[str]
			if fishingmod.ColorTable[editable] then
				colormixer:SetColor(fishingmod.ColorTable[editable])
			end
		end
	end
	
	function savebutton:Paint(w, h)
		savebutton:SetTextColor(uiText)
		if(savebutton:IsDown()) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(savebutton:IsHovered()) then
			surface.SetDrawColor(uiButtonHovered.r, uiButtonHovered.g, uiButtonHovered.b, uiButtonHovered.a)
		else
			surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		end
		surface.DrawRect(0, 0, w, h)
	end
	function resetbutton:Paint(w, h)
		resetbutton:SetTextColor(uiText)
		if(resetbutton:IsDown()) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(resetbutton:IsHovered()) then
			surface.SetDrawColor(uiButtonHovered.r, uiButtonHovered.g, uiButtonHovered.b, uiButtonHovered.a)
		else
			surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		end
		surface.DrawRect(0, 0, w, h)
	end
	function self:Paint()
		surface.SetTextColor(uiText.r, uiText.g, uiText.b, uiText.a)
		surface.SetDrawColor(backGround.r, backGround.g, backGround.b, backGround.a)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		return true
	end
	function self:OnSizeChanged(x, y)
		colormixer:SetSize(math.max(math.min(140, x - 20), x - 10 - 120 - 20), y - 20)
		colormixer:SetPos(math.min(120 + 20, math.max(x - 150, 10)), 10)
		combobox:SetSize(math.min(120, x - 170), math.min(30, y - 20))
		savebutton:SetSize(math.min(120, x - 170), math.min(30, y - 60))
		resetbutton:SetSize(math.min(120, x - 170), math.min(30, y - 100))
	end
end

vgui.Register("Fishingmod:Customization", PANEL, "DPanelList")




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
	self.rightlabel:SetTextColor(uiText)
	self.rightlabel:SetSize(100, 30)
	
	self.leftlabel = vgui.Create("DLabel", self)
	self.leftlabel:SetTextColor(uiText)
	self.leftlabel:SetSize(100, 30)
	
	self.left:Dock(LEFT)
	self.leftlabel:SetPos(30, - 2)
	self.rightlabel:SetPos(130, - 2)
	self.right:Dock(RIGHT)
	local selfleft = self.left
	function self.left:Paint() -- 'sell' skill button
		surface.SetFont("DebugFixed")
		surface.SetTextColor(uiText.r, uiText.g, uiText.b, uiText.a)
		if(selfleft:IsDown()) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(selfleft:IsHovered()) then
			surface.SetDrawColor(uiButtonHovered.r, uiButtonHovered.g, uiButtonHovered.b, uiButtonHovered.a)
		else
			surface.SetDrawColor(0, 0, 0, 100)
		end
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetDrawColor(uiText)
		surface.SetMaterial(FishingMod_spriteMinus)
		surface.DrawTexturedRect(1, 1, self:GetWide() - 2, self:GetTall() - 2)
		return true
	end
	local selfright = self.right
	function self.right:Paint() -- buy skill button
		surface.SetFont("DebugFixed")
		surface.SetTextColor(uiText.r, uiText.g, uiText.b, uiText.a)

		if(selfright:IsDown()) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(selfright:IsHovered()) then
			surface.SetDrawColor(uiButtonHovered.r, uiButtonHovered.g, uiButtonHovered.b, uiButtonHovered.a)
		else
			surface.SetDrawColor(0, 0, 0, 100)
		end
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetDrawColor(uiText)
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
	self.rightlabel:SetTextColor(uiText)
	self.leftlabel:SetTextColor(uiText)
	self.rightlabel:SetText(LocalPlayer().fishingmod[self.type])
end

vgui.Register("Fishingmod:UpgradeButton", PANEL)


-- Markup Tooltip
local PANEL = {}

function PANEL:Init()
	self.percent = 0
end

function PANEL:SetSale(multiplier)
	self.percent = math.Round((multiplier * - 1 + 1) * 100)
end

function PANEL:SetGray(bool)
	self.Grey = bool
end

function PANEL:PaintOver(w, h)
	self.BaseClass.PaintOver(self, w, h)

	draw.SimpleText( self.percent.."% OFF", "DermaDefault", 5, 3, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	draw.SimpleText( self.percent.."% OFF", "DermaDefault", 4, 2, HSVToColor(math.Clamp(self.percent + 40, 0, 160), 1, 1), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	if self.Grey then draw.RoundedBox( 6, 0, 0, 58, 58, Color( 100, 100, 100, 200 ) ) end
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
			bait.icon:SetToolTip(sale .. "\nYou need to be level " .. levelrequired .. " or higher to use this bait.")
			bait.icon:SetSale(bait.multiplier)
		end
	end
end
