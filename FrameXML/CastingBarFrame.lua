CASTING_BAR_ALPHA_STEP = 0.05;
CASTING_BAR_FLASH_STEP = 0.2;
CASTING_BAR_HOLD_TIME = 1;
CASTING_BAR_PLACEHOLDER_FILE_ID = 136235;

function CastingBarFrame_OnLoad(self, unit, showTradeSkills, showShield)
	CastingBarFrame_SetStartCastColor(self, 1.0, 0.7, 0.0);
	CastingBarFrame_SetStartChannelColor(self, 0.0, 1.0, 0.0);
	CastingBarFrame_SetFinishedCastColor(self, 0.0, 1.0, 0.0);
	CastingBarFrame_SetNonInterruptibleCastColor(self, 0.7, 0.7, 0.7);
	CastingBarFrame_SetFailedCastColor(self, 1.0, 0.0, 0.0);

	CastingBarFrame_SetUseStartColorForFinished(self, true);
	CastingBarFrame_SetUseStartColorForFlash(self, true);

	CastingBarFrame_SetUnit(self, unit, showTradeSkills, showShield);

	self.showCastbar = true;

	local point, relativeTo, relativePoint, offsetX, offsetY = self.Spark:GetPoint();
	if ( point == "CENTER" ) then
		self.Spark.offsetY = offsetY;
	end
end

function CastingBarFrame_SetStartCastColor(self, r, g, b)
	self.startCastColor = CreateColor(r, g, b);
end

function CastingBarFrame_SetStartChannelColor(self, r, g, b)
	self.startChannelColor = CreateColor(r, g, b);
end

function CastingBarFrame_SetFinishedCastColor(self, r, g, b)
	self.finishedCastColor = CreateColor(r, g, b);
end

function CastingBarFrame_SetFailedCastColor(self, r, g, b)
	self.failedCastColor = CreateColor(r, g, b);
end

function CastingBarFrame_SetNonInterruptibleCastColor(self, r, g, b)
	self.nonInterruptibleColor = CreateColor(r, g, b);
end

function CastingBarFrame_SetUseStartColorForFinished(self, finishedColorSameAsStart)
	self.finishedColorSameAsStart = finishedColorSameAsStart;
end

function CastingBarFrame_SetUseStartColorForFlash(self, flashColorSameAsStart)
	self.flashColorSameAsStart = flashColorSameAsStart;
end

-- Fades additional widgets along with the cast bar, in case these widgets are not parented or use ignoreParentAlpha
function CastingBarFrame_AddWidgetForFade(self, widget)
	if not self.additionalFadeWidgets then
		self.additionalFadeWidgets = {};
	end
	self.additionalFadeWidgets[widget] = true;
end

function CastingBarFrame_SetUnit(self, unit, showTradeSkills, showShield)
	if self.unit ~= unit then
		self.unit = unit;
		self.showTradeSkills = showTradeSkills;
		self.showShield = showShield;

		self.casting = nil;
		self.channeling = nil;
		self.holdTime = 0;
		self.fadeOut = nil;

		if unit then
			self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
			self:RegisterEvent("UNIT_SPELLCAST_DELAYED");
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
			self:RegisterEvent("PLAYER_ENTERING_WORLD");
			self:RegisterUnitEvent("UNIT_SPELLCAST_START", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit);

			CastingBarFrame_OnEvent(self, "PLAYER_ENTERING_WORLD")
		else
			self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
			self:UnregisterEvent("UNIT_SPELLCAST_DELAYED");
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
			self:UnregisterEvent("PLAYER_ENTERING_WORLD");
			self:UnregisterEvent("UNIT_SPELLCAST_START");
			self:UnregisterEvent("UNIT_SPELLCAST_STOP");
			self:UnregisterEvent("UNIT_SPELLCAST_FAILED");

			self:Hide();
		end
	end
end

function CastingBarFrame_OnShow(self)
	if ( self.unit ) then
		if ( self.casting ) then
			local _, _, _, startTime = UnitCastingInfo(self.unit);
			if ( startTime ) then
				self.value = (GetTime() - (startTime / 1000));
			end
		else
			local _, _, _, _, endTime = UnitChannelInfo(self.unit);
			if ( endTime ) then
				self.value = ((endTime / 1000) - GetTime());
			end
		end
	end
end

function CastingBarFrame_GetEffectiveStartColor(self, isChannel, notInterruptible)
	if self.nonInterruptibleColor and notInterruptible then
		return self.nonInterruptibleColor;
	end
	return isChannel and self.startChannelColor or self.startCastColor;
end

function CastingBarFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	
	local unit = self.unit;
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local nameChannel = UnitChannelInfo(unit);
		local nameSpell = UnitCastingInfo(unit);
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
	
	if ( event == "UNIT_SPELLCAST_START" ) then
		local name, text, texture, startTime, endTime, isTradeSkill, castID--[[, notInterruptible]] = UnitCastingInfo(unit);
		local notInterruptible = false;

		if ( not name or (not self.showTradeSkills and isTradeSkill)) then
			self:Hide();
			return;
		end

		local startColor = CastingBarFrame_GetEffectiveStartColor(self, false, notInterruptible);
		self:SetStatusBarColor(startColor:GetRGB());
		if self.flashColorSameAsStart then
			self.Flash:SetVertexColor(startColor:GetRGB());
		else
			self.Flash:SetVertexColor(1, 1, 1);
		end
		
		if ( self.Spark ) then
			self.Spark:Show();
		end
		self.value = (GetTime() - (startTime / 1000));
		self.maxValue = (endTime - startTime) / 1000;
		self:SetMinMaxValues(0, self.maxValue);
		self:SetValue(self.value);
		if ( self.Text ) then
			self.Text:SetText(text);
		end
		if ( self.Icon ) then
			CastingBarFrame_SetIcon(self, texture);
			if ( self.iconWhenNoninterruptible ) then
				self.Icon:SetShown(not notInterruptible);
			end
		end
		CastingBarFrame_ApplyAlpha(self, 1.0);
		self.holdTime = 0;
		self.casting = true;
		self.castID = castID;
		self.channeling = nil;
		self.fadeOut = nil;

		if ( self.BorderShield ) then
			if ( self.showShield and notInterruptible ) then
				self.BorderShield:Show();
				if ( self.BarBorder ) then
					self.BarBorder:Hide();
				end
			else
				self.BorderShield:Hide();
				if ( self.BarBorder ) then
					self.BarBorder:Show();
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
		if ( (self.casting and event == "UNIT_SPELLCAST_STOP" and select(2, ...) == self.castID) or
		     (self.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP") ) then
			if ( self.Spark ) then
				self.Spark:Hide();
			end
			if ( self.Flash ) then
				self.Flash:SetAlpha(0.0);
				self.Flash:Show();
			end
			self:SetValue(self.maxValue);
			if ( event == "UNIT_SPELLCAST_STOP" ) then
				self.casting = nil;
				if not self.finishedColorSameAsStart then
					self:SetStatusBarColor(self.finishedCastColor:GetRGB());
				end
			else
				self.channeling = nil;
			end
			self.flash = true;
			self.fadeOut = true;
			self.holdTime = 0;
		end
	elseif ( event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" ) then
		if ( self:IsShown() and
		     (self.casting and select(2, ...) == self.castID) and not self.fadeOut ) then
			self:SetValue(self.maxValue);
			self:SetStatusBarColor(self.failedCastColor:GetRGB());
			if ( self.Spark ) then
				self.Spark:Hide();
			end
			if ( self.Text ) then
				if ( event == "UNIT_SPELLCAST_FAILED" ) then
					self.Text:SetText(FAILED);
				else
					self.Text:SetText(INTERRUPTED);
				end
			end
			self.casting = nil;
			self.channeling = nil;
			self.fadeOut = true;
			self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
		end
	elseif ( event == "UNIT_SPELLCAST_DELAYED" ) then
		if ( self:IsShown() ) then
			local name, text, texture, startTime, endTime, isTradeSkill, castID--[[, notInterruptible]] = UnitCastingInfo(unit);
			local notInterruptible = false;

			if ( not name or (not self.showTradeSkills and isTradeSkill)) then
				-- if there is no name, there is no bar
				self:Hide();
				return;
			end
			self.value = (GetTime() - (startTime / 1000));
			self.maxValue = (endTime - startTime) / 1000;
			self:SetMinMaxValues(0, self.maxValue);
			if ( not self.casting ) then
				self:SetStatusBarColor(CastingBarFrame_GetEffectiveStartColor(self, false, notInterruptible):GetRGB());
				if ( self.Spark ) then
					self.Spark:Show();
				end
				if ( self.Flash ) then
					self.Flash:SetAlpha(0.0);
					self.Flash:Hide();
				end
				self.casting = true;
				self.channeling = nil;
				self.flash = nil;
				self.fadeOut = nil;
			end
		end
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_START" ) then
		local name, text, texture, startTime, endTime, isTradeSkill--[[, notInterruptible]], spellID = UnitChannelInfo(unit);
		local notInterruptible = false;

		if ( not name or (not self.showTradeSkills and isTradeSkill)) then
			-- if there is no name, there is no bar
			self:Hide();
			return;
		end

		local startColor = CastingBarFrame_GetEffectiveStartColor(self, true, notInterruptible);
		if self.flashColorSameAsStart then
			self.Flash:SetVertexColor(startColor:GetRGB());
		else
			self.Flash:SetVertexColor(1, 1, 1);
		end
		self:SetStatusBarColor(startColor:GetRGB());
		self.value = (endTime / 1000) - GetTime();
		self.maxValue = (endTime - startTime) / 1000;
		self:SetMinMaxValues(0, self.maxValue);
		self:SetValue(self.value);
		if ( self.Text ) then
			self.Text:SetText(text);
		end
		if ( self.Icon ) then
			CastingBarFrame_SetIcon(self, texture);
		end
		if ( self.Spark ) then
			self.Spark:Hide();
		end
		CastingBarFrame_ApplyAlpha(self, 1.0);
		self.holdTime = 0;
		self.casting = nil;
		self.channeling = true;
		self.fadeOut = nil;
		if ( self.BorderShield ) then
			if ( self.showShield and notInterruptible ) then
				self.BorderShield:Show();
				if ( self.BarBorder ) then
					self.BarBorder:Hide();
				end
			else
				self.BorderShield:Hide();
				if ( self.BarBorder ) then
					self.BarBorder:Show();
				end
			end
		end
		if ( self.showCastbar ) then
			self:Show();
		end
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" ) then
		if ( self:IsShown() ) then
			local name, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit);
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
	elseif ( event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" ) then
		CastingBarFrame_UpdateInterruptibleState(self, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE");
	end
end

function CastingBarFrame_UpdateInterruptibleState(self, notInterruptible)
	if ( self.casting or self.channeling ) then
		local startColor = CastingBarFrame_GetEffectiveStartColor(self, self.channeling, notInterruptible);
		self:SetStatusBarColor(startColor:GetRGB());

		if self.flashColorSameAsStart then
			self.Flash:SetVertexColor(startColor:GetRGB());
		end

		if ( self.BorderShield ) then
			if ( self.showShield and notInterruptible ) then
				self.BorderShield:Show();
				if ( self.BarBorder ) then
					self.BarBorder:Hide();
				end
			else
				self.BorderShield:Hide();
				if ( self.BarBorder ) then
					self.BarBorder:Show();
				end
			end
		end

		if ( self.Icon and self.iconWhenNoninterruptible ) then
			self.Icon:SetShown(not notInterruptible);
		end
	end
end

function CastingBarFrame_OnUpdate(self, elapsed)
	if ( self.casting ) then
		self.value = self.value + elapsed;
		if ( self.value >= self.maxValue ) then
			self:SetValue(self.maxValue);
			CastingBarFrame_FinishSpell(self, self.Spark, self.Flash);
			return;
		end
		self:SetValue(self.value);
		if ( self.Flash ) then
			self.Flash:Hide();
		end
		if ( self.Spark ) then
			local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
			self.Spark:SetPoint("CENTER", self, "LEFT", sparkPosition, self.Spark.offsetY or 2);
		end
	elseif ( self.channeling ) then
		self.value = self.value - elapsed;
		if ( self.value <= 0 ) then
			CastingBarFrame_FinishSpell(self, self.Spark, self.Flash);
			return;
		end
		self:SetValue(self.value);
		if ( self.Flash ) then
			self.Flash:Hide();
		end
	elseif ( GetTime() < self.holdTime ) then
		return;
	elseif ( self.flash ) then
		local alpha = 0;
		if ( self.Flash ) then
			alpha = self.Flash:GetAlpha() + CASTING_BAR_FLASH_STEP;
		end
		if ( alpha < 1 ) then
			if ( self.Flash ) then
				self.Flash:SetAlpha(alpha);
			end
		else
			if ( self.Flash ) then
				self.Flash:SetAlpha(1.0);
			end
			self.flash = nil;
		end
	elseif ( self.fadeOut ) then
		local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP;
		if ( alpha > 0 ) then
			CastingBarFrame_ApplyAlpha(self, alpha);
		else
			self.fadeOut = nil;
			self:Hide();
		end
	end
end

function CastingBarFrame_ApplyAlpha(self, alpha)
	self:SetAlpha(alpha);
	if self.additionalFadeWidgets then
		for widget in pairs(self.additionalFadeWidgets) do
			widget:SetAlpha(alpha);
		end
	end
end

function CastingBarFrame_FinishSpell(self)
	if not self.finishedColorSameAsStart then
		self:SetStatusBarColor(self.finishedCastColor:GetRGB());
	end
	if ( self.Spark ) then
		self.Spark:Hide();
	end
	if ( self.Flash ) then
		self.Flash:SetAlpha(0.0);
		self.Flash:Show();
	end
	self.flash = true;
	self.fadeOut = true;
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

function CastingBarFrame_SetLook(self, look)
	if ( look == "CLASSIC" ) then
		self:SetWidth(195);
		self:SetHeight(13);
		-- border
		self.Border:ClearAllPoints();
		self.Border:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border");
		self.Border:SetWidth(256);
		self.Border:SetHeight(64);
		self.Border:SetPoint("TOP", 0, 28);
		-- bordershield
		self.BorderShield:ClearAllPoints();
		self.BorderShield:SetWidth(256);
		self.BorderShield:SetHeight(64);
		self.BorderShield:SetPoint("TOP", 0, 28);
		-- text
		self.Text:ClearAllPoints();
		self.Text:SetWidth(185);
		self.Text:SetHeight(16);
		self.Text:SetPoint("TOP", 0, 5);
		self.Text:SetFontObject("GameFontHighlight");
		-- icon
		self.Icon:Hide();
		-- bar spark
		self.Spark.offsetY = 2;
		-- bar flash
		self.Flash:ClearAllPoints();
		self.Flash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash");
		self.Flash:SetWidth(256);
		self.Flash:SetHeight(64);
		self.Flash:SetPoint("TOP", 0, 28);
	elseif ( look == "UNITFRAME" ) then
		self:SetWidth(150);
		self:SetHeight(10);
		-- border
		self.Border:ClearAllPoints();
		self.Border:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small");
		self.Border:SetWidth(0);
		self.Border:SetHeight(49);
		self.Border:SetPoint("TOPLEFT", -23, 20);
		self.Border:SetPoint("TOPRIGHT", 23, 20);
		-- bordershield
		self.BorderShield:ClearAllPoints();
		self.BorderShield:SetWidth(0);
		self.BorderShield:SetHeight(49);
		self.BorderShield:SetPoint("TOPLEFT", -28, 20);
		self.BorderShield:SetPoint("TOPRIGHT", 18, 20);
		-- text
		self.Text:ClearAllPoints();
		self.Text:SetWidth(0);
		self.Text:SetHeight(16);
		self.Text:SetPoint("TOPLEFT", 0, 4);
		self.Text:SetPoint("TOPRIGHT", 0, 4);
		self.Text:SetFontObject("SystemFont_Shadow_Small");
		-- icon
		self.Icon:Show();
		-- bar spark
		self.Spark.offsetY = 0;
		-- bar flash
		self.Flash:ClearAllPoints();
		self.Flash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small");
		self.Flash:SetWidth(0);
		self.Flash:SetHeight(49);
		self.Flash:SetPoint("TOPLEFT", -23, 20);
		self.Flash:SetPoint("TOPRIGHT", 23, 20);
	end
end

function CastingBarFrame_SetIcon(self, icon)
	if (self.Icon) then
		if (icon == CASTING_BAR_PLACEHOLDER_FILE_ID) then
			icon = 0;
		end
		self.Icon:SetTexture(icon);
	end
end