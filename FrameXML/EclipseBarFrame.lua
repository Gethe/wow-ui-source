
ECLIPSE_BAR_TRAVEL = 38;

ECLIPSE_BAR_SOLAR_BUFF_ID = 48517;
ECLIPSE_BAR_LUNAR_BUFF_ID = 48518;



ECLIPSE_ICONS =  {};
ECLIPSE_ICONS["moon"] = { 
												norm = { x=23, y=23, left=0.55859375, right=0.64843750, top=0.57031250, bottom=0.75000000 } ,
												dark  = { x=23, y=23, left=0.55859375, right=0.64843750, top=0.37500000, bottom=0.55468750 } ,
												big    = { x=43, y=45, left=0.73437500, right=0.90234375, top=0.00781250, bottom=0.35937500 } ,
											}
ECLIPSE_ICONS["sun"] = { 
												norm = { x=23, y=23, left=0.65625000, right=0.74609375, top=0.37500000, bottom=0.55468750 } ,
												dark  = { x=23, y=23, left=0.55859375, right=0.64843750, top=0.76562500, bottom=0.94531250 } ,
												big    = { x=43, y=45, left=0.55859375, right=0.72656250, top=0.00781250, bottom=0.35937500 } ,
											}
											
											
ECLIPSE_MARKER_COORDS =  {};
ECLIPSE_MARKER_COORDS["none"] 		= { 0.914, 1.0, 0.82, 1.0 }; 
ECLIPSE_MARKER_COORDS["sun"] 		= { 0.914, 1.0, 0.641, 0.82 }; 
ECLIPSE_MARKER_COORDS["moon"] 	= { 1.0, 0.914, 0.641, 0.82 }; 


function EclipseBar_UpdateShown(self)
	if VehicleMenuBar:IsShown() then
		return;
	end

	-- Disable rune frame if not a DRUID.
	local _, class = UnitClass("player");
	local form  = GetShapeshiftFormID();
	
	if  class == "DRUID" and (form == MOONKIN_FORM or not form) then
		if GetPrimaryTalentTree() == 1 then
			self.showPercent = GetCVarBool("statusTextPercentage");	
			if GetCVarBool("playerStatusText") then
				self.powerText:Show();
				self.lockShow = true;
			else
				self.powerText:Hide();
				self.lockShow = false;
			end
			self:Show();
		else
			self:Hide();
		end
	else
		self:Hide();
		return;
	end
end

function EclipseBar_Update(self)
	local power = UnitPower( self:GetParent().unit, SPELL_POWER_ECLIPSE );
	local maxPower = UnitPowerMax( self:GetParent().unit, SPELL_POWER_ECLIPSE );
	if self.showPercent then 
		self.powerText:SetText(abs(power/maxPower*100).."%");
	else
		self.powerText:SetText(abs(power));
	end
	
	local xpos =  ECLIPSE_BAR_TRAVEL*(power/maxPower)
	self.marker:SetPoint("CENTER", xpos, 0);
end





function EclipseBar_OnLoad(self)
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("CVAR_UPDATE");	
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("ECLIPSE_DIRECTION_CHANGE");
end




function EclipseBar_OnShow(self)

	local direction = GetEclipseDirection();
	if direction then
		self.marker:SetTexCoord( unpack(ECLIPSE_MARKER_COORDS[direction]));
	end
	
	local hasLunarEclipse = false;
	local hasSolarEclipse = false;
	
	local unit = PlayerFrame.unit;
	local j = 1;
	local name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
	while name do 
		if spellID == ECLIPSE_BAR_SOLAR_BUFF_ID then
			hasSolarEclipse = true;
		elseif spellID == ECLIPSE_BAR_LUNAR_BUFF_ID then
			hasLunarEclipse = true;
		end
		j=j+1;
		name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
	end
	
	if hasLunarEclipse then
		self.glow:ClearAllPoints();
		local glowInfo = ECLIPSE_ICONS["moon"].big;
		self.glow:SetPoint("CENTER", self.moon, "CENTER", 0, 0);
		self.glow:SetWidth(glowInfo.x);
		self.glow:SetHeight(glowInfo.y);
		self.glow:SetTexCoord(glowInfo.left, glowInfo.right, glowInfo.top, glowInfo.bottom);
		self.sunBar:SetAlpha(0);
		self.darkMoon:SetAlpha(0);
		self.moonBar:SetAlpha(1);
		self.darkSun:SetAlpha(1);
		self.glow:SetAlpha(1);
		self.glow.pulse:Play();	
	elseif hasSolarEclipse then
		self.glow:ClearAllPoints();
		local glowInfo = ECLIPSE_ICONS["sun"].big;
		self.glow:SetPoint("CENTER", self.sun, "CENTER", 0, 0);
		self.glow:SetWidth(glowInfo.x);
		self.glow:SetHeight(glowInfo.y);
		self.glow:SetTexCoord(glowInfo.left, glowInfo.right, glowInfo.top, glowInfo.bottom);
		self.moonBar:SetAlpha(0);
		self.darkSun:SetAlpha(0);
		self.sunBar:SetAlpha(1);
		self.darkMoon:SetAlpha(1);
		self.glow:SetAlpha(1);
		self.glow.pulse:Play();
	else
		self.sunBar:SetAlpha(0);
		self.moonBar:SetAlpha(0);
		self.darkSun:SetAlpha(0);
		self.darkMoon:SetAlpha(0);
		self.glow:SetAlpha(0);
	end
	
	self.hasLunarEclipse = hasLunarEclipse;
	self.hasSolarEclipse = hasSolarEclipse;
	
	EclipseBar_Update(self);
end




function EclipseBar_CheckBuffs(self) 
	if not self:IsShown() then
		return;
	end

	local hasLunarEclipse = false;
	local hasSolarEclipse = false;
	
	local unit = PlayerFrame.unit;
	local j = 1;
	local name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
	while name do 
		if spellID == ECLIPSE_BAR_SOLAR_BUFF_ID then
			hasSolarEclipse = true;
		elseif spellID == ECLIPSE_BAR_LUNAR_BUFF_ID then
			hasLunarEclipse = true;
		end
		j=j+1;
		name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
	end
	
	if hasLunarEclipse then
		self.glow:ClearAllPoints();
		local glowInfo = ECLIPSE_ICONS["moon"].big;
		self.glow:SetPoint("CENTER", self.moon, "CENTER", 0, 0);
		self.glow:SetWidth(glowInfo.x);
		self.glow:SetHeight(glowInfo.y);
		self.glow:SetTexCoord(glowInfo.left, glowInfo.right, glowInfo.top, glowInfo.bottom);
		 
		if self.moonDeactivate:IsPlaying() then
			self.moonDeactivate:Stop();
		end
		
		if not self.moonActivate:IsPlaying() and hasLunarEclipse ~= self.hasLunarEclipse then
			self.moonActivate:Play();
		end
	else
		if self.moonActivate:IsPlaying() then
			self.moonActivate:Stop();
		end
		
		if not self.moonDeactivate:IsPlaying() and hasLunarEclipse ~= self.hasLunarEclipse then
			self.moonDeactivate:Play();
		end
	end

	if hasSolarEclipse then
		self.glow:ClearAllPoints();
		local glowInfo = ECLIPSE_ICONS["sun"].big;
		self.glow:SetPoint("CENTER", self.sun, "CENTER", 0, 0);
		self.glow:SetWidth(glowInfo.x);
		self.glow:SetHeight(glowInfo.y);
		self.glow:SetTexCoord(glowInfo.left, glowInfo.right, glowInfo.top, glowInfo.bottom);
		
		if self.sunDeactivate:IsPlaying() then
			self.sunDeactivate:Stop();
		end
		
		if not self.sunActivate:IsPlaying() and hasSolarEclipse ~= self.hasSolarEclipse then
			self.sunActivate:Play();
		end
	else
		if self.sunActivate:IsPlaying() then
			self.sunActivate:Stop();
		end
		
		if not self.sunDeactivate:IsPlaying() and hasSolarEclipse ~= self.hasSolarEclipse then
			self.sunDeactivate:Play();
		end
	end
	
	self.hasLunarEclipse = hasLunarEclipse;
	self.hasSolarEclipse = hasSolarEclipse;
end 



function EclipseBar_OnEvent(self, event, ...)
	if event == "UNIT_AURA" then
		local arg1 = ...;
		if arg1 ==  PlayerFrame.unit then
			EclipseBar_CheckBuffs(self);
		end
	elseif event == "ECLIPSE_DIRECTION_CHANGE" then
		local isLunar = ...;
		if isLunar then
			self.marker:SetTexCoord( unpack(ECLIPSE_MARKER_COORDS["sun"]));
		else
			self.marker:SetTexCoord( unpack(ECLIPSE_MARKER_COORDS["moon"]));
		end
	else
		EclipseBar_UpdateShown(self);
	end
end



