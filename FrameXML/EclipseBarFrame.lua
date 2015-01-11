
ECLIPSE_BAR_TRAVEL = 38;

ECLIPSE_BAR_SOLAR_BUFF_ID = 48517;
ECLIPSE_BAR_LUNAR_BUFF_ID = 48518;

EQUINOX_TALENT_SPELL_ID = 152220;

ECLIPSE_ICONS =  {};
													
ECLIPSE_MARKER_COORDS =  {};
ECLIPSE_MARKER_COORDS["none"] 		= { 0.914, 1.0, 0.82, 1.0 }; 
ECLIPSE_MARKER_COORDS["sun"] 		= { 0, 1, 0, 1 }; 
ECLIPSE_MARKER_COORDS["moon"] 	= { 1, 0, 0, 1 }; 


function EclipseBar_UpdateShown(self)
	if OverrideActionBar:IsShown() then
		return;
	end

	-- Disable rune frame if not a DRUID.
	local _, class = UnitClass("player");
	local form  = GetShapeshiftFormID();
	
	if  class == "DRUID" and (form == MOONKIN_FORM or not form) then
		if GetSpecialization() == 1 then
			self.textDisplay = GetCVar("statusTextDisplay");	
			if GetCVarBool("playerStatusText") then
				self.PowerText:Show();
				self.lockShow = true;
			else
				self.PowerText:Hide();
				self.lockShow = false;
			end
			self:Show();
		else
			self:Hide();
		end
	else
		self:Hide();
	end
	PlayerFrame_AdjustAttachments();
end

function EclipseBar_Update(self)
	local power = UnitPower( self:GetParent().unit, SPELL_POWER_ECLIPSE );
	local maxPower = UnitPowerMax( self:GetParent().unit, SPELL_POWER_ECLIPSE );
	if (maxPower == 0) then
		return;--catch divide by zero
	end
	
	self.PowerText:SetText(abs(power));
	
	local xpos = ECLIPSE_BAR_TRAVEL * (power / maxPower);
	self.Marker:SetPoint("CENTER", xpos, 0);
end

function EclipseBar_OnLoad(self)
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("ECLIPSE_DIRECTION_CHANGE");
	self:RegisterUnitEvent("UNIT_AURA", "player", "vehicle");
	
	ECLIPSE_ICONS["moon"] = { atlas="DruidEclipse-LunarMoon", anchor=EclipseBarFrame.Moon }
	ECLIPSE_ICONS["sun"] = { atlas="DruidEclipse-SolarSun", anchor=EclipseBarFrame.Sun}
end

function EclipseBar_OnShow(self)
	local hasLunarEclipse = false;
	local hasSolarEclipse = false;
	
	local unit = PlayerFrame.unit;
	local j = 1;
	local name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
	while name do 
		if (spellID == ECLIPSE_BAR_SOLAR_BUFF_ID) then
			hasSolarEclipse = true;
		elseif (spellID == ECLIPSE_BAR_LUNAR_BUFF_ID) then
			hasLunarEclipse = true;
		end
		j=j+1;
		name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
	end
	
	if (hasLunarEclipse) then
		EclipseBar_SetGlow(self, "moon");
		self.SunBar:SetAlpha(0);
		self.DarkMoon:SetAlpha(0);
		self.MoonBar:SetAlpha(1);
		self.DarkSun:SetAlpha(1);
		self.Glow:SetAlpha(1);
		self.SunCover:SetAlpha(1);
		if (IsPlayerSpell(EQUINOX_TALENT_SPELL_ID)) then
			self.SunCover:Show();
		end
		self.pulse:Play();	
	elseif (hasSolarEclipse) then
		EclipseBar_SetGlow(self, "sun");
		self.MoonBar:SetAlpha(0);
		self.DarkSun:SetAlpha(0);
		self.SunBar:SetAlpha(1);
		self.DarkMoon:SetAlpha(1);
		self.Glow:SetAlpha(1);
		self.MoonCover:SetAlpha(1);
		if (IsPlayerSpell(EQUINOX_TALENT_SPELL_ID)) then
			self.MoonCover:Show();
		end
		self.pulse:Play();
	else
		self.SunBar:SetAlpha(0);
		self.MoonBar:SetAlpha(0);
		self.DarkSun:SetAlpha(0);
		self.DarkMoon:SetAlpha(0);
		self.Glow:SetAlpha(0);
	end
	
	self.hasLunarEclipse = hasLunarEclipse;
	self.hasSolarEclipse = hasSolarEclipse;
	
	EclipseBar_Update(self);
	EclipseBar_SetDirection(self, GetEclipseDirection());
end

function EclipseBar_SetGlow(self, icon)
	self.Glow:ClearAllPoints();
	local glowInfo = ECLIPSE_ICONS[icon];
	self.Glow:SetAtlas(glowInfo.atlas, true);
	self.Glow:SetPoint("CENTER", glowInfo.anchor, "CENTER", 0, 0);
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
		if (spellID == ECLIPSE_BAR_SOLAR_BUFF_ID) then
			hasSolarEclipse = true;
		elseif (spellID == ECLIPSE_BAR_LUNAR_BUFF_ID) then
			hasLunarEclipse = true;
		end
		j=j+1;
		name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
	end
	
	local hasEquinox = IsPlayerSpell(EQUINOX_TALENT_SPELL_ID);
	
	if (hasLunarEclipse) then
		EclipseBar_SetGlow(self, "moon");
		
		if (hasEquinox) then
			self.SunCover:Show();
		else
			self.SunCover:Hide();
		end
		
		if (self.moonDeactivate:IsPlaying()) then
			self.moonDeactivate:Stop();
		end
		
		if (hasEquinox and self.hasSolarEclipse) then
			self.switchToMoon:Play();
		elseif (not self.moonActivate:IsPlaying() and hasLunarEclipse ~= self.hasLunarEclipse) then
			self.moonActivate:Play();
		end
	else
		if (self.moonActivate:IsPlaying()) then
			self.moonActivate:Stop();
		end
		
		if (not hasSolarEclipse and not self.moonDeactivate:IsPlaying() and hasLunarEclipse ~= self.hasLunarEclipse) then
			self.moonDeactivate:Play();
		end
	end

	if (hasSolarEclipse) then
		EclipseBar_SetGlow(self, "sun");
		
		if (hasEquinox) then
			self.MoonCover:Show();
		else
			self.MoonCover:Hide();
		end
		
		if (self.sunDeactivate:IsPlaying()) then
			self.sunDeactivate:Stop();
		end
		
		if (hasEquinox and self.hasLunarEclipse) then
			self.switchToSun:Play();
		elseif (not self.sunActivate:IsPlaying() and hasSolarEclipse ~= self.hasSolarEclipse) then
			self.sunActivate:Play();
		end
	else
		if (self.sunActivate:IsPlaying()) then
			self.sunActivate:Stop();
		end
		
		if (not hasLunarEclipse and not self.sunDeactivate:IsPlaying() and hasSolarEclipse ~= self.hasSolarEclipse) then
			self.sunDeactivate:Play();
		end
	end
	
	self.hasLunarEclipse = hasLunarEclipse;
	self.hasSolarEclipse = hasSolarEclipse;
end 

function EclipseBar_SetDirection(self, direction)
	if not direction or direction == "none" then
		self.Marker:SetAtlas("DruidEclipse-Diamond");
	else
		self.Marker:SetAtlas("DruidEclipse-Arrow");
		self.Marker:SetTexCoord(unpack(ECLIPSE_MARKER_COORDS[direction]));
	end
end

function EclipseBar_OnEvent(self, event, ...)
	if (event == "UNIT_AURA") then
		local arg1 = ...;
		if arg1 ==  PlayerFrame.unit then
			EclipseBar_CheckBuffs(self);
		end
	elseif (event == "ECLIPSE_DIRECTION_CHANGE") then
		local direction = ...;
		EclipseBar_SetDirection(self, direction);
	else
		EclipseBar_UpdateShown(self);
	end
end

