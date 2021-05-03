language.Add("entity_fishing_rod", "Fishing Rod")

include("shared.lua")


fishingmod.ColorTable = fishingmod.LoadUIColors()

local ui_text = fishingmod.DefaultUIColors().ui_text
local ui_text_caught = fishingmod.DefaultUIColors().ui_text_caught
local ui_background = fishingmod.DefaultUIColors().ui_background
local xp_bar_fg = fishingmod.DefaultUIColors().xp_bar_fg
local xp_bar_bg = fishingmod.DefaultUIColors().xp_bar_bg
local xp_bar_text = fishingmod.DefaultUIColors().xp_bar_text

local height_offset = 40
local margin_from_border = 16         -- 16 pixels from the top and bottom border of the screen/game window
local inner_box_xy = 3                -- padding of the 2 shades of background
local bg_heightdepthcatch = 0         -- if a catch or depth exist elongate the box
local minwid = 50                     -- minimum width of dark background box
local markup = 0
local stripped_name_width = 0

local depth, catch = "", ""

local temp_nick, team_col = "", ""
local box_below_w, box_below_h = 0, 0
local xy = {x = 0, y = 0, visible = false}
local xhypo, yhypo = 0, 0

local bg_x, bg_width = 0, 0
local bg_y, bg_height = 0, 0
local ecbg_x, ecbg_width = 0, 0

local rope_material = Material("cable/rope")

function ENT:Draw()
	if IsValid(self:GetBobber()) then
		render.SetMaterial(rope_material)
		render.DrawBeam(self:LocalToWorld(Vector(40,0,0) * self.dt.rod_length), self:GetBobber():LocalToWorld(self:GetBobber().TopOffset), 0.1, 0, 0, Color(255,200,200,50))
	end
	self:DrawShadow(false) -- a massive shadow... it's quite disturbing... no thanks ?
	self:DrawModel()
end

function ENT:RenderScene()
	local ply = self:GetPlayer()
	
	if ply then
		ply:SetAngles(Angle(0,ply:EyeAngles().y,0))
	end
	
	if not IsValid(self.dt.ply) then return end
	
	local idx = self.dt.ply:LookupBone("ValveBiped.Bip01_R_Hand")
	if not idx then return end
	
	local position, angles = self.dt.ply:GetBonePosition(idx)
	local new_position, new_angles = LocalToWorld(Vector(26.5-(self.dt.rod_length/13),-0.17,-44) * self.dt.rod_length, Angle(60,0,90), position, angles)
	self:SetPos(new_position)
	self:SetAngles(new_angles)
	self:SetRenderBounds(Vector(1,1,1)*-1000, Vector(1,1,1)*1000)
	self:SetModelScale(self.dt.rod_length, 0)
end

function ENT:HUDPaint()
	local ply = self:GetPlayer()
	if fishingmod.ColorTable then
		ui_text = fishingmod.ColorTable.ui_text or ui_text
		ui_text_caught = fishingmod.ColorTable.ui_text_caught or ui_text_caught
		ui_background = fishingmod.ColorTable.ui_background or ui_background
		xp_bar_fg = fishingmod.ColorTable.xp_bar_fg or xp_bar_fg
		xp_bar_bg = fishingmod.ColorTable.xp_bar_bg or xp_bar_bg
		xp_bar_text = fishingmod.ColorTable.xp_bar_text or xp_bar_text
	end

	
	if not IsValid(ply) or (ply and not ply.fishingmod) then return end
	if ply ~= LocalPlayer() and self:GetHook() and self:GetHook():GetPos():Distance(LocalPlayer():EyePos()) > 1500 then return end
		
	xy = ((self:GetBobber() and self:GetBobber():GetPos() or Vector()) + Vector(0,0,10)):ToScreen() -- kinda unsure about this Vec'0,0,+10'
	
	temp_nick = ply:Nick()
	team_col = team.GetColor(ply:Team())

	if EasyChat then 
		markup = ec_markup.AdvancedParse(temp_nick, {
			nick = true,
			default_color = team_col,
			default_font = "fixed_name_font",
			default_shadow_font = "fixed_name_font",
		}) 
		stripped_name_width = markup:GetWidth()
	end
	bg_heightdepthcatch = 0
	if self:GetHook() and self:GetHook():WaterLevel() >= 1 then
		depth = "\nDepth: " .. tostring(math.Round((self:GetDepth() * 2.54) / 100 * 10) / 10) or 0
		bg_heightdepthcatch = bg_heightdepthcatch + 13
    else
        depth = ""
    end

	local hooked_entity = self:GetHook() and self:GetHook():GetHookedEntity()
	if hooked_entity and hooked_entity:WaterLevel() == 0 and hooked_entity:GetPos():Distance(LocalPlayer():EyePos()) < 500 then
		catch = "\nCatch: " .. string.Trim(hooked_entity:GetNWString("fishingmod friendly")) -- the catch had 2 spaces before it
		bg_heightdepthcatch = bg_heightdepthcatch + 13
    else
        catch = ""
    end

	surface.SetFont("fixed_height_font")
	local text_below = "Total Catch: " .. ply.fishingmod.catches .. "\nMoney: " .. (math.Round(ply.fishingmod.money) or "0") .. "\nLevel: " .. ply.fishingmod.level .. "\nLength: " .. tostring(math.Round((self:GetLength() * 2.54) / 100 * 10) / 10) .. depth .. catch
	box_below_w, box_below_h = surface.GetTextSize(text_below)

	surface.SetFont("fixed_name_font")
	xhypo, yhypo = surface.GetTextSize(temp_nick)
	
	xy.y = math.Clamp(xy.y - height_offset, 120 + height_offset + margin_from_border, ScrH() + height_offset - margin_from_border - bg_heightdepthcatch)

	bg_x, bg_width = xy.x - math.max(minwid, xhypo / 2, box_below_w / 2) - 10, (math.max(minwid, xhypo / 2, box_below_w / 2) + 10) * 2
	bg_y, bg_height = xy.y - 120 - height_offset, 70 + box_below_h
	ecbg_x, ecbg_width = xy.x - math.max(minwid, stripped_name_width / 2, ( box_below_w / 2)) - 10, (math.max(minwid, stripped_name_width / 2, box_below_w / 2) + 10) * 2

	surface.SetDrawColor(ui_background.r, ui_background.g, ui_background.b, ui_background.a)

	if EasyChat then
		surface.DrawRect(ecbg_x, bg_y, ecbg_width, bg_height)
		surface.DrawRect(ecbg_x + inner_box_xy, bg_y + inner_box_xy, ecbg_width - (2 * inner_box_xy), bg_height - (2 * inner_box_xy))
		markup:Draw(xy.x - (stripped_name_width / 2), xy.y - 102 - height_offset - markup:GetHeight()/2)
	else
		surface.DrawRect(bg_x, bg_y, bg_width, bg_height)
		surface.DrawRect(bg_x + inner_box_xy, bg_y + inner_box_xy, bg_width - (2 * inner_box_xy), bg_height - (2 * inner_box_xy) )
		draw.DrawText(temp_nick, "fixed_name_font", xy.x, xy.y - 112 - height_offset, team_col, 1)
	end
	draw.RoundedBox(1, xy.x - 50, xy.y - 88 - height_offset, 100, 23, xp_bar_bg)
	draw.RoundedBox(1, xy.x - 50, xy.y - 88 - height_offset, math.min(ply.fishingmod.percent, 100), 23, xp_bar_fg)
	draw.DrawText(tostring(math.Round(ply.fishingmod.expleft)), "fixed_height_font" , xy.x, xy.y - 84 - height_offset, xp_bar_text, 1)
	draw.DrawText(text_below, "fixed_height_font", xy.x, xy.y - 60 - height_offset, hooked_entity and ui_text_caught or ui_text, 1)
end

function ENT:Initialize()
	self.sound_rope = CreateSound(self, "weapons/tripwire/ropeshoot.wav")
	self.sound_rope:Play()
	self.sound_rope:ChangePitch(0, 0)
	
	self.sound_reel = CreateSound(self, "fishingrod/reel.wav")
	self.sound_reel:Play()
	self.sound_reel:ChangePitch(0, 0)
	self.last_length = 0
	
	local ply = self:GetPlayer()
	
	if LocalPlayer() == ply and not ValidPanel(fishingmod.UpgradeMenu) then 
		fishingmod.UpgradeMenu = vgui.Create("Fishingmod:ShopMenu") 
		fishingmod.UpgradeMenu:SetVisible(false)
	end
	
	self:SetupHook("RenderScene")
	self:SetupHook("HUDPaint")
end
 
function ENT:Think()	
	local delta = self.dt.length - self.last_length

	local velocity_length = IsValid(self.dt.attach) and self.dt.attach:GetVelocity():Length() or 0
	local pitch = velocity_length/10 - 0.1
	local volume = velocity_length/1000 - 0.1
	local reel_velocity = self.dt.length - self.last_length
	
	local on = (delta ~= 0) and 1 or 0
	self.sound_reel:ChangePitch(math.Clamp(math.abs(100+delta*10),80,200), 0)
	self.sound_reel:ChangeVolume(on, 0)
		
	self.sound_rope:ChangePitch(math.Clamp(pitch, 50, 255), 0)
	self.sound_rope:ChangeVolume(math.Clamp(volume, 0, 1), 0)
	
	self.last_length = self.dt.length
	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	local ply = self:GetPlayer()
	
	if LocalPlayer() == ply then 
		if IsValid(fishingmod.UpgradeMenu) then
			fishingmod.UpgradeMenu:Remove()
		end
	end

	self.sound_reel:Stop()
	self.sound_rope:Stop()
end
