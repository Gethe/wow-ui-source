CASTING_BAR_ALPHA_STEP = 0.05;
CASTING_BAR_FLASH_STEP = 0.2;
CASTING_BAR_HOLD_TIME = 1;

function CastingBarFrame_OnLoad (self, unit, showTradeSkills, showShield)
	self:RegisterEvent("UNIT_SPELLCAST_START");
	self:RegisterEvent("UNIT_SPELLCAST_STOP");
	self:RegisterEvent("UNIT_SPELLCAST_FAILED");
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	self:RegisterEvent("UNIT_SPELLCAST_DELAYED");
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE");
	self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	self.unit = unit;
	self.showTradeSkills = showTradeSkills;
	self.showShield = showShield;
	self.casting = nil;
	self.channeling = nil;
	self.holdTime = 0;
	self.showCastbar = true;

	local barIcon = _G[self:GetName().."Icon"];
	if ( barIcon ) then
		barIcon:Hide();
	end
end

function CastingBarFrame_OnShow (self)
	if ( self.casting ) then
		local _, _, _, _, startTime = UnitCastingInfo(self.unit);
		if ( startTime ) then
			self.value = (GetTime() - (startTime / 1000));
		end
	else
		local _, _, _, _, _, endTime = UnitChannelInfo(self.unit);
		if ( endTime ) then
			self.value = ((endTime / 1000) - GetTime());
		end
	end
end

function CastingBarFrame_OnEvent (self, event, ...)
	local arg1 = ...;
	
	local unit = self.unit;
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local nameChannel  = UnitChannelInfo(unit);
		local nameSpell  = UnitCastingInfo(unit);
		if ( nameChannel ) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = unit;
		elseif ( nameSpell ) then
			event = "UNIT_SPELLCAST_START";
			arg1 = unit;
		else
		    CastingBarFrame_FinishSpell(self);
		end
	end

	if ( arg1 ~= unit ) then
		return;
	end
	
	local selfName = self:GetName();
	local barSpark = _G[selfName.."Spark"];
	local barText = _G[selfName.."Text"];
	local barFlash = _G[selfName.."Flash"];
	local barIcon = _G[selfName.."Icon"];
	local barBorder = _G[selfName.."Border"];
	local barBorderShield = _G[selfName.."BorderShield"];
	if ( event == "UNIT_SPELLCAST_START" ) then
		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit);
		if ( not name or (not self.showTradeSkills and isTradeSkill)) then
			self:Hide();
			return;
		end

		self:SetStatusBarColor(1.0, 0.7, 0.0);
		if ( barSpark ) then
			barSpark:Show();
		end
		self.value = (GetTime() - (startTime / 1000));
		self.maxValue = (endTime - startTime) / 1000;
		self:SetMinMaxValues(0, self.maxValue);
		self:SetValue(self.value);
		if ( barText ) then
			barText:SetText(text);
		end
		if ( barIcon ) then
			barIcon:SetTexture(texture);
		end
		self:SetAlpha(1.0);
		self.holdTime = 0;
		self.casting = 1;
		self.castID = castID;
		self.channeling = nil;
		self.fadeOut = nil;
		if ( barBorderShield ) then
			if ( self.showShield and notInterruptible ) then
				barBorderShield:Show();
				if ( barBorder ) then
					barBorder:Hide();
				end
			else
				barBorderShield:Hide();
				if ( barBorder ) then
					barBorder:Show();
				end
			end
		end
		if ( self.showCastbar ) then
			self:Show();
		end

	elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then
		if ( not self:IsVisible() ) then
			self:Hide();
		end
		if ( (self.casting and event == "UNIT_SPELLCAST_STOP" and select(4, ...) == self.castID) or
		     (self.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP") ) then
			if ( barSpark ) then
				barSpark:Hide();
			end
			if ( barFlash ) then
				barFlash:SetAlpha(0.0);
				barFlash:Show();
			end
			self:SetValue(self.maxValue);
			if ( event == "UNIT_SPELLCAST_STOP" ) then
				self.casting = nil;
				self:SetStatusBarColor(0.0, 1.0, 0.0);
			else
				self.channeling = nil;
			end
			self.flash = 1;
			self.fadeOut = 1;
			self.holdTime = 0;
		end
	elseif ( event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" ) then
		if ( self:IsShown() and
		     (self.casting and select(4, ...) == self.castID) and not self.fadeOut ) then
			self:SetValue(self.maxValue);
			self:SetStatusBarColor(1.0, 0.0, 0.0);
			if ( barSpark ) then
				barSpark:Hide();
			end
			if ( barText ) then
				if ( event == "UNIT_SPELLCAST_FAILED" ) then
					barText:SetText(FAILED);
				else
					barText:SetText(INTERRUPTED);
				end
			end
			self.casting = nil;
			self.channeling = nil;
			self.fadeOut = 1;
			self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
		end
	elseif ( event == "UNIT_SPELLCAST_DELAYED" ) then
		if ( self:IsShown() ) then
			local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
			if ( not name or (not self.showTradeSkills and isTradeSkill)) then
				-- if there is no name, there is no bar
				self:Hide();
				return;
			end
			self.value = (GetTime() - (startTime / 1000));
			self.maxValue = (endTime - startTime) / 1000;
			self:SetMinMaxValues(0, self.maxValue);
			if ( not self.casting ) then
				self:SetStatusBarColor(1.0, 0.7, 0.0);
				if ( barSpark ) then
					barSpark:Show();
				end
				if ( barFlash ) then
					barFlash:SetAlpha(0.0);
					barFlash:Hide();
				end
				self.casting = 1;
				self.channeling = nil;
				self.flash = 0;
				self.fadeOut = 0;
			end
		end
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_START" ) then
		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit);
		if ( not name or (not self.showTradeSkills and isTradeSkill)) then
			-- if there is no name, there is no bar
			self:Hide();
			return;
		end

		self:SetStatusBarColor(0.0, 1.0, 0.0);
		self.value = ((endTime / 1000) - GetTime());
		self.maxValue = (endTime - startTime) / 1000;
		self:SetMinMaxValues(0, self.maxValue);
		self:SetValue(self.value);
		if ( barText ) then
			barText:SetText(text);
		end
		if ( barIcon ) then
			barIcon:SetTexture(texture);
		end
		if ( barSpark ) then
			barSpark:Hide();
		end
		self:SetAlpha(1.0);
		self.holdTime = 0;
		self.casting = nil;
		self.channeling = 1;
		self.fadeOut = nil;
		if ( barBorderShield ) then
			if ( self.showShield and notInterruptible ) then
				barBorderShield:Show();
				if ( barBorder ) then
					barBorder:Hide();
				end
			else
				barBorderShield:Hide();
				if ( barBorder ) then
					barBorder:Show();
				end
			end
		end
		if ( self.showCastbar ) then
			self:Show();
		end
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" ) then
		if ( self:IsShown() ) then
			local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit);
			if ( not name or (not self.showTradeSkills and isTradeSkill)) then
				-- if there is no name, there is no bar
				self:Hide();
				return;
			end
			self.value = ((endTime / 1000) - GetTime());
			self.maxValue = (endTime - startTime) / 1000;
			self:SetMinMaxValues(0, self.maxValue);
			self:SetValue(self.value);
		end
	elseif ( self.showShield and event == "UNIT_SPELLCAST_INTERRUPTIBLE" ) then
		if ( barBorderShield ) then
			barBorderShield:Hide();
			if ( barBorder ) then
				barBorder:Show();
			end
		end
	elseif ( self.showShield and event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" ) then
		if ( barBorderShield ) then
			barBorderShield:Show();
			if ( barBorder ) then
				barBorder:Hide();
			end
		end
	end
end

function CastingBarFrame_OnUpdate (self, elapsed)
	local barSpark = _G[self:GetName().."Spark"];
	local barFlash = _G[self:GetName().."Flash"];

	if ( self.casting ) then
		self.value = self.value + elapsed;
		if ( self.value >= self.maxValue ) then
			self:SetValue(self.maxValue);
			CastingBarFrame_FinishSpell(self, barSpark, barFlash);
			return;
		end
		self:SetValue(self.value);
		if ( barFlash ) then
			barFlash:Hide();
		end
		if ( barSpark ) then
			local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
			barSpark:SetPoint("CENTER", self, "LEFT", sparkPosition, 2);
		end
	elseif ( self.channeling ) then
		self.value = self.value - elapsed;
		if ( self.value <= 0 ) then
			CastingBarFrame_FinishSpell(self, barSpark, barFlash);
			return;
		end
		self:SetValue(self.value);
		if ( barFlash ) then
			barFlash:Hide();
		end
	elseif ( GetTime() < self.holdTime ) then
		return;
	elseif ( self.flash ) then
		local alpha = 0;
		if ( barFlash ) then
			alpha = barFlash:GetAlpha() + CASTING_BAR_FLASH_STEP;
		end
		if ( alpha < 1 ) then
			if ( barFlash ) then
				barFlash:SetAlpha(alpha);
			end
		else
			if ( barFlash ) then
				barFlash:SetAlpha(1.0);
			end
			self.flash = nil;
		end
	elseif ( self.fadeOut ) then
		local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP;
		if ( alpha > 0 ) then
			self:SetAlpha(alpha);
		else
			self.fadeOut = nil;
			self:Hide();
		end
	end
end

function CastingBarFrame_FinishSpell (self, barSpark, barFlash)
	self:SetStatusBarColor(0.0, 1.0, 0.0);
	if ( barSpark ) then
		barSpark:Hide();
	end
	if ( barFlash ) then
		barFlash:SetAlpha(0.0);
		barFlash:Show();
	end
	self.flash = 1;
	self.fadeOut = 1;
	self.casting = nil;
	self.channeling = nil;
end

function CastingBarFrame_UpdateIsShown(self)
	if ( self.casting and self.showCastbar ) then
		CastingBarFrame_OnEvent(self, "PLAYER_ENTERING_WORLD")
	else
		self:Hide();
	end
end
