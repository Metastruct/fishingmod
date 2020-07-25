language.Add("entity_fishing_rod","Fishing Rod")

include("shared.lua")

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
	
	if not IsValid(ply) or (ply and not ply.fishingmod) then return end
	if ply ~= LocalPlayer() and self:GetHook() and self:GetHook():GetPos():Distance(LocalPlayer():EyePos()) > 1500 then return end
		
	local xy = ((self:GetBobber() and self:GetBobber():GetPos() or Vector()) + Vector(0,0,10)):ToScreen() -- kinda unsure about this Vec'0,0,+10'

	local height_offset 		= 40 			-- kinda unsure about this but ok -- it was here before
	local marginFromBorder 		= 16 			-- 16 pixels from the top and bottom border of the screen/game window
	local innerBoxXY 			= 3  			-- padding of the 2 shades of background
	local bg_heightdepthcatch 	= 0  			-- if a catch or depth exist elongate the box
	local minwid 				= 54 			-- minimum width of dark background box
	local nickLenLimit 			= 32 			-- Nick Character Limit
	local tempNick 				= ply:Nick() 	-- temporary nickname manipulation
	local cntemp2 				= ""
	local tempNickEC 			= ""

	if EasyChat then -- i know the code looks REAL NASTY but it works with <c=987654> and <color=255,99,9> tags xd dont hate me
		-- im not a string.professional so i got to create pron
		local cntemp1 = string.split(string.replace(tempNick,">","<"),"<") -- this is prongarf
		cntemp2 = ""
		for k,v in pairs(cntemp1) do -- make all colors into COLOR=R,G,B
			if string.find(v,"c=") then 
				r,g,b = tonumber("0x" .. string.sub(v,3,4)),tonumber("0x" .. string.sub(v,5,6)),tonumber("0x" .. string.sub(v,7,8)) -- replace hexers
				v = "COLOR=" .. r .. "," .. g .. "," .. b
			elseif(string.find(v,"color=")) then
				v = "COLOR=" .. string.sub(v,7)
			else
				tempNickEC = tempNickEC .. v -- create nickname in the meantime
			end
			cntemp2 = cntemp2 .. v .. "\n"
		end
	end
	
	local depth = ""
	if self:GetHook() and self:GetHook():WaterLevel() >= 1 then
		depth =  "\nDepth: " .. tostring(math.Round((self:GetDepth()*2.54)/100*10)/10)
		bg_heightdepthcatch = bg_heightdepthcatch + 10
	end

	local catch = ""
	local hooked_entity = self:GetHook() and self:GetHook():GetHookedEntity()
	if hooked_entity and hooked_entity:WaterLevel() == 0 and hooked_entity:GetPos():Distance(LocalPlayer():EyePos()) < 500 then
		catch = "\nCatch: " .. hooked_entity:GetNWString("fishingmod friendly")
		bg_heightdepthcatch = bg_heightdepthcatch + 10
	end
	
	if UndecorateNick then -- might be useful? xd
		tempNick = UndecorateNick(tempNick)
	end
	if #tempNick > nickLenLimit then
		tempNick = string.trim(string.sub(tempNick, 1, nickLenLimit)) .. "... "
	end
	if #tempNickEC > nickLenLimit then
		tempNickEC = string.trim(string.sub(tempNickEC, 1, nickLenLimit)) .. "... "
	end
	surface.SetFont("ChatFont")
	local xhypo,yhypo = surface.GetTextSize(tempNick)
	local ecx,ecy = surface.GetTextSize(tempNickEC)

	xy.y = math.Clamp(xy.y-height_offset, 120+height_offset+marginFromBorder, ScrH()+height_offset-marginFromBorder-bg_heightdepthcatch) -- brain tumour but works fine dont touch

	local bg_x, bg_width = xy.x-math.max(minwid,xhypo/2)-10 , (math.max(minwid,xhypo/2)+10)*2
	local bg_y,bg_height = xy.y-120-height_offset			, bg_heightdepthcatch+50*2.4
	local ecbg_x, ecbg_width = xy.x-math.max(minwid,ecx/2)-10 , (math.max(minwid,ecy/2)+10)*2

	surface.SetDrawColor(0, 0, 0, 128)
	surface.SetTextColor(255, 255, 255, 255)
	if EasyChat then
		surface.DrawRect(ecbg_x             , bg_y              , ecbg_width                  , bg_height                   )
		surface.DrawRect(ecbg_x + innerBoxXY, bg_y + innerBoxXY , ecbg_width - (2*innerBoxXY) , bg_height - (2*innerBoxXY ) ) -- just design i guess
		surface.SetFont("ChatFont") -- just in case
		surface.SetTextPos(xy.x-(ecx/2), xy.y-115-height_offset) -- support colors ...
		local col = { [1]=255, [2]=255,	[3]=255	}
		for k,v in pairs(string.split(cntemp2,"\n")) do
			if string.find(v,"COLOR=") then
				col = string.split(string.sub(v,7),",")
			else
				surface.SetTextColor(col[1], col[2], col[3], 255)
				surface.DrawText(v)
			end
		end
	else
		surface.DrawRect(bg_x             , bg_y              , bg_width                  , bg_height                   )
		surface.DrawRect(bg_x + innerBoxXY, bg_y + innerBoxXY , bg_width - (2*innerBoxXY) , bg_height - (2*innerBoxXY ) ) -- just design i guess
		draw.DrawText(tempNick, "ChatFont" ,xy.x, xy.y-115-height_offset, color_white, 1)
	end
	draw.RoundedBox( 0, xy.x-50, xy.y-88-height_offset, 100, 23, Color( 255, 255, 255, 100 ) )
	draw.RoundedBox( 0, xy.x-50, xy.y-88-height_offset, ply.fishingmod.percent, 23, Color( 0, 255, 0, 150 ) )
	draw.DrawText(tostring(math.Round(ply.fishingmod.expleft)), "HudSelectionText" ,xy.x, xy.y-85-height_offset, color_black, 1)
	draw.DrawText("Total Catch: " .. ply.fishingmod.catches .. "\nMoney: " .. (ply.fishingmod.money or "0") .. "\nLevel: " .. ply.fishingmod.level .. "\nLength: " .. tostring(math.Round((self:GetLength()*2.54)/100*10)/10) .. depth .. catch, "HudSelectionText", xy.x,xy.y-60-height_offset, hooked_entity and Color(0,255,0,255) or color_white,1)
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
