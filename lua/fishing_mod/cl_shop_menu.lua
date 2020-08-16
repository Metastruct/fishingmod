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
	local t = fishingmod.DefaultUIColors()
	if fishingmod.ColorTable then
		for k, v in pairs(fishingmod.ColorTable) do
			newData[k] = tostring(v.r) .. " " .. tostring(v.g) .. " " .. tostring(v.b) .. " ".. tostring(v.a)
		end
		table.Merge(t, newData)
	end
	file.Write(fishingmodDataPath .. fishingmodDataFileName, util.TableToJSON(t, false))
	newData = nil
end
function fishingmod.LoadUIColors()
	local tempCol = Color(0, 0, 0, 72)
	if file.Exists(fishingmodDataPath, "DATA") then
		if file.Exists(fishingmodDataPath .. fishingmodDataFileName, "DATA") then
			local t_ = util.JSONToTable(file.Read(fishingmodDataPath .. fishingmodDataFileName, "DATA"))
			local t = fishingmod.DefaultUIColors()
			if t_ then
				for k, v in pairs(t_) do
					if k and v then
						if #tostring(k) < 4 then return end
						if #tostring(v) < 4 then return end
						t_[k] = string.ToColor(v) or tempCol
					end
				end
				table.Merge(t, t_)
			end
			t_ = {}
			return t
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

local bg = fishingmod.DefaultUIColors().uiBackground
local sel = fishingmod.DefaultUIColors().uiText
local nosel = fishingmod.DefaultUIColors().uiTextBg
local hov = fishingmod.DefaultUIColors().uiButtonHovered
local nopres = fishingmod.DefaultUIColors().uiButtonDeSelected
local pres = fishingmod.DefaultUIColors().uiButtonPressed
local masterX, masterY = 354, 224

local PANEL = {} -- Main panel

function PANEL:Init()
	if fishingmod.ColorTable then
		bg = fishingmod.ColorTable.uiBackground or bg
		sel = fishingmod.ColorTable.uiText or sel
		nosel = fishingmod.ColorTable.uiTextBg or nosel
		hov = fishingmod.ColorTable.uiButtonHovered or hov
		nopres = fishingmod.ColorTable.uiButtonDeSelected or nopres
		pres = fishingmod.ColorTable.uiButtonPressed or pres
	end
	self:MakePopup()
	self:SetDeleteOnClose(false)
	self:SetSizable(true)
	self:SetTitle("Fishing Mod")
	self.lblTitle:SetTextColor(sel)
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
	local cus = vgui.Create("DButton", self) -- customization tab

	upgradesbutton.sel = true
	baitsbutton.sel = false
	upgradesbutton:SetPos(3, 24)
	upgradesbutton:SetSize((xpx - 6) / 3, 22)
	upgradesbutton:SetText("Upgrades")
	function upgradesbutton.Think()
		xpx, xpy = self:GetSize()
		upgradesbutton:SetSize((xpx - 6) / 3, 22)
	end
	upgradesbutton:SetTextColor(sel)
	upgradesbutton.DoClick = function()
		upgradesbutton:SetColor(sel)
		baitsbutton:SetColor(nopres)
		cus:SetColor(nopres)

		baitsbutton:SetTextColor(nosel)
		cus:SetTextColor(nosel)

		upgradesbutton.sel = true
		baitsbutton.sel = false
		cus.sel = false

		self.customization:Hide()
		self.upgrade:Show()
		self.baitshop:Hide()
	end
	upgradesbutton.Paint = function(self, w, h)
		if self.sel then
			upgradesbutton:SetColor(sel)
		elseif not self.sel then
			upgradesbutton:SetColor(nosel)
		end
		if(upgradesbutton:IsHovered()) then
			surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		elseif(upgradesbutton.sel) then
			surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
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
	baitsbutton:SetTextColor(nosel)
	baitsbutton.DoClick = function()
		baitsbutton:SetColor(sel)
		upgradesbutton:SetColor(nopres)
		cus:SetColor(nopres)

		upgradesbutton:SetTextColor(nosel)
		cus:SetTextColor(nosel)

		upgradesbutton.sel = false
		baitsbutton.sel = true
		cus.sel = false

		self.customization:Hide()
		self.upgrade:Hide()
		self.baitshop:Show()
	end
	baitsbutton.Paint = function(self, w, h)
		if self.sel then
			baitsbutton:SetColor(sel)
		elseif not self.sel then
			baitsbutton:SetColor(nosel)
		end
		if(baitsbutton:IsHovered()) then
			surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		elseif(baitsbutton.sel) then
			surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		else
			surface.SetDrawColor(nopres.r, nopres.g, nopres.b, nopres.a)
		end
		surface.DrawRect(0, 0, w, h)
	end


	cus:SetPos(3 + (xpx - 6) / 3, 24) -- baits shop start of conf
	cus:SetSize((xpx - 6) / 3, 22)
	
	function cus.Think()
		xpx, xpy = self:GetSize()
		if(xpx % 3 == 2) then
			cus:SetSize(math.Round((xpx - 6) / 3) + 1 , 22)
			cus:SetPos(2 + (xpx - 6) / 3 * 2 , 24)
		elseif(xpx % 3 == 1 ) then
			cus:SetSize(math.Round((xpx - 6) / 3) + 1, 22)
			cus:SetPos(3 + (xpx - 6) / 3 * 2 , 24)
		else
			cus:SetSize(math.Round((xpx - 6) / 3) , 22)
			cus:SetPos(3 + (xpx - 6) / 3 * 2 , 24)
		end
	end
	cus:SetText("Customize")
	cus:SetTextColor(nosel)
	cus.DoClick = function()
		cus:SetColor(sel)
		upgradesbutton:SetColor(nopres)
		baitsbutton:SetColor(nopres)

		upgradesbutton:SetTextColor(nosel)
		baitsbutton:SetTextColor(nosel)

		upgradesbutton.sel = false
		baitsbutton.sel = false
		cus.sel = true

		self.customization:Show()
		self.upgrade:Hide()
		self.baitshop:Hide()

	end
	cus.Paint = function(self, w, h)
		if self.sel then
			cus:SetColor(sel)
		elseif not self.sel then
			cus:SetColor(nosel)
		end
		if(cus:IsHovered()) then
			surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		elseif(cus.sel) then
			surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		else
			surface.SetDrawColor(nopres.r, nopres.g, nopres.b, nopres.a)
		end
		surface.DrawRect(0, 0, w, h)
	end


	function self:Paint()
		surface.SetTextColor(sel.r, sel.g, sel.b, sel.a)
		surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		return true
	end
	local closebutton = vgui.Create("DButton", self)
	local x, y = self:GetSize()
	closebutton.ButtonW = 60
	closebutton:SetSize(closebutton.ButtonW, 18)
	closebutton:SetText("Close")
	closebutton:SetTextColor(sel)
	closebutton:SetPos(x - closebutton.ButtonW - 3, 3)
	closebutton.DoClick = function()
		self:Close()
	end
	function self:OnSizeChanged(x, y)
		closebutton:SetPos(math.max(x - closebutton.ButtonW - 3, 3), 3)
		closebutton:SetSize(math.min(closebutton.ButtonW, x - 6) , 18 )
	end
	closebutton.Paint = function(self, w, h)
		self:GetParent().lblTitle:SetTextColor(sel)
		closebutton:SetTextColor(sel)
		if(closebutton:IsDown() ) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(closebutton:IsHovered()) then
			surface.SetDrawColor(hov.r, hov.g, hov.b, hov.a)
		else
			surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		end
		surface.DrawRect(0, 0, w, h)
	end
	
	function self.baitshop:Paint()
		surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
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
		surface.SetTextColor(sel.r, sel.g, sel.b, sel.a)
		surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		self.money:SetTextColor(sel)
		return true
	end

	self.money = vgui.Create("DLabel", self)
	self.money:SetTextColor(sel)
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
			icon:Setnosel(true)
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
			bg = fishingmod.ColorTable.uiBackground or bg
			sel = fishingmod.ColorTable.uiText or sel
			nosel = fishingmod.ColorTable.uiTextBg or nosel
			hov = fishingmod.ColorTable.uiButtonHovered or hov
			nopres = fishingmod.ColorTable.uiButtonDeSelected or nopres
			pres = fishingmod.ColorTable.uiButtonPressed or pres
		else
			fishingmod.ColorTable = fishingmod.DefaultUIColors()
		end
	end

	local saveb = vgui.Create("DButton", self)
	saveb:SetPos(10, 50)
	saveb:SetSize(120, 30)
	saveb:SetTextColor(sel)
	saveb:SetText("Save")
	saveb.Paint = function(self, w, h)
		saveb:SetTextColor(sel)
		surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		surface.DrawRect(0, 0, w, h)
	end

	saveb.DoClick = function()
		if fishingmod.SaveUIColors then
			fishingmod.SaveUIColors()
			chat.AddText(Color(0, 255, 0, 255), "[Fishing Mod]", Color(255, 255, 255), ": Colors have been Saved!")
		end
	end
	local Reset = vgui.Create("DButton", self)
	Reset:SetPos(10, 90)
	Reset:SetSize(120, 30)
	Reset:SetTextColor(sel)
	Reset:SetText("Reset")
	Reset.Paint = function(self, w, h)
		Reset:SetTextColor(sel)
		surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		surface.DrawRect(0, 0, w, h)
	end

	Reset.DoClick = function()
		if fishingmod.DefaultUIColors then
			fishingmod.ColorTable = fishingmod.DefaultUIColors()
			chat.AddText(Color(0, 255, 0, 255), "[Fishing Mod]", Color(255, 255, 255), ": Colors have been Reset!")
		end
	end
	
	local cbox = vgui.Create("DComboBox", self )
	cbox:SetPos(10, 10)
	cbox:SetSize(120, 30)
	cbox:SetValue("Select element")
	if fishingmod.ColorTable then
		if fishingmod.LoadUIColors then
			for k, v in pairs(fishingmod.LoadUIColors()) do
				cbox:AddChoice(translation[k])
			end
		end
	end
	cbox.Paint = function(self, w, h)
		cbox:SetTextColor(sel)
		if(cbox:IsDown()) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(cbox:IsHovered()) then
			surface.SetDrawColor(hov.r, hov.g, hov.b, hov.a)
		else
			surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		end
		surface.DrawRect(0, 0, w, h)
	end
	local dcm = vgui.Create( "DColorMixer", self)
	local x, y = self:GetSize()
	dcm:SetPos(120 + 20, 10)
	dcm:SetWangs(true)
	dcm:SetPalette(false)
	dcm:SetSize(x - 10 - 120 - 20, y - 20)
	function dcm:ValueChanged(col)
		if editable and editable != "" and fishingmod.DefaultUIColors()[editable] then
			fishingmod.ColorTable[editable] = Color(col.r, col.g, col.b, col.a)
		end
	end
	function cbox.OnSelect(self, val, str)
		if type(str)=="string" and str != "" then
			editable = translation[str]
			if fishingmod.ColorTable[editable] then
				dcm:SetColor(fishingmod.ColorTable[editable])
			end
		end
	end
	
	function saveb:Paint(w, h)
		saveb:SetTextColor(sel)
		if(saveb:IsDown()) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(saveb:IsHovered()) then
			surface.SetDrawColor(hov.r, hov.g, hov.b, hov.a)
		else
			surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		end
		surface.DrawRect(0, 0, w, h)
	end
	function Reset:Paint(w, h)
		Reset:SetTextColor(sel)
		if(Reset:IsDown()) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(Reset:IsHovered()) then
			surface.SetDrawColor(hov.r, hov.g, hov.b, hov.a)
		else
			surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		end
		surface.DrawRect(0, 0, w, h)
	end
	function self:Paint()
		surface.SetTextColor(sel.r, sel.g, sel.b, sel.a)
		surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		return true
	end
	function self:OnSizeChanged(x, y)
		dcm:SetSize(math.max(math.min(140, x - 20), x - 10 - 120 - 20), y - 20)
		dcm:SetPos(math.min(120 + 20, math.max(x - 150, 10)), 10)
		cbox:SetSize(math.min(120, x - 170), math.min(30, y - 20))
		saveb:SetSize(math.min(120, x - 170), math.min(30, y - 60))
		Reset:SetSize(math.min(120, x - 170), math.min(30, y - 100))
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
	self.rightlabel:SetTextColor(sel)
	self.rightlabel:SetSize(100, 30)
	
	self.leftlabel = vgui.Create("DLabel", self)
	self.leftlabel:SetTextColor(sel)
	self.leftlabel:SetSize(100, 30)
	
	self.left:Dock(LEFT)
	self.leftlabel:SetPos(30, - 2)
	self.rightlabel:SetPos(130, - 2)
	self.right:Dock(RIGHT)
	local selfleft = self.left
	function self.left:Paint() -- 'sell' skill button
		surface.SetFont("DebugFixed")
		surface.SetTextColor(sel.r, sel.g, sel.b, sel.a)
		if(selfleft:IsDown()) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(selfleft:IsHovered()) then
			surface.SetDrawColor(hov.r, hov.g, hov.b, hov.a)
		else
			surface.SetDrawColor(0, 0, 0, 100)
		end
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetDrawColor(sel)
		surface.SetMaterial(FishingMod_spriteMinus)
		surface.DrawTexturedRect(1, 1, self:GetWide() - 2, self:GetTall() - 2)
		return true
	end
	local selfright = self.right
	function self.right:Paint() -- buy skill button
		surface.SetFont("DebugFixed")
		surface.SetTextColor(sel.r, sel.g, sel.b, sel.a)

		if(selfright:IsDown()) then
			surface.SetDrawColor(pres.r, pres.g, pres.b, pres.a)
		elseif(selfright:IsHovered()) then
			surface.SetDrawColor(hov.r, hov.g, hov.b, hov.a)
		else
			surface.SetDrawColor(0, 0, 0, 100)
		end
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetDrawColor(sel)
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
	self.rightlabel:SetTextColor(sel)
	self.leftlabel:SetTextColor(sel)
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

function PANEL:Setnosel(bool)
	self.nosel = bool
end

function PANEL:PaintOver(w, h)
	self.BaseClass.PaintOver(self, w, h)

	draw.SimpleText( self.percent.."% OFF", "DermaDefault", 5, 3, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	draw.SimpleText( self.percent.."% OFF", "DermaDefault", 4, 2, HSVToColor(math.Clamp(self.percent + 40, 0, 160), 1, 1), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	if self.nosel then draw.RoundedBox( 6, 0, 0, 58, 58, Color( 100, 100, 100, 200 ) ) end
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
