
TempMaxHealthLossMixin = {};

function TempMaxHealthLossMixin:InitalizeMaxHealthLossBar(healthBarsContainer, healthBar, optionalTempMaxHealthLossDivider)
	self.myHealthBarContainer = healthBarsContainer;
	self.healthBar = healthBar;
	self:SetFillStyle(Enum.StatusBarFillStyle.Reverse);
	self:SetMinMaxValues(0, 1);
	
	if(optionalTempMaxHealthLossDivider) then
		self.tempMaxHealthLossDivider = optionalTempMaxHealthLossDivider;
		--Added 1px height stretch on the mask to remove a gap at the bottom of the divider, Remove this if this atlas changes: "UI-HUD-UnitFrame-Player-PortraitOn-Bar-TempHPLoss-Divider"
		self.tempMaxHealthLossDivider.TempHPLossDividerMask:SetHeight(self.tempMaxHealthLossDivider.TempHPLossDividerMask:GetHeight() + 1);
	end

	self.initialized = true;
end

function TempMaxHealthLossMixin:SetShouldAdjustHealthBarAnchor(xOffset, yOffset)
	self.ShouldAdjustHealthBarAnchor = true;
	self.xAnchorOffset = xOffset;
	self.yAnchorOffset = yOffset;
end

function TempMaxHealthLossMixin:OnMaxHealthModifiersChanged(value)
	--current UI implementation only cares about showing max health loss, not gain
	local clampedValue = Clamp(value, 0, 1);
	--disable / enable all tempMaxHealth loss bars with CVar
	if (GetCVarBool("showTempMaxHealthLoss")) then

		self:Update_MaxHealthLoss(clampedValue);
	end
end

function TempMaxHealthLossMixin:Update_MaxHealthLoss(fillPercent)
	local fullWidth = self.myHealthBarContainer:GetWidth();
	if ( self.ShouldAdjustHealthBarAnchor ) then
		self.healthBar:SetPoint("BOTTOMRIGHT", self.myHealthBarContainer, "BOTTOMRIGHT", ((fullWidth*(fillPercent))*-1) + self.xAnchorOffset, self.yAnchorOffset);
	else
		self.healthBar:SetWidth(fullWidth*(1-fillPercent));
	end
	self:Show();
	self:SetValue(fillPercent);

	if (self.tempMaxHealthLossDivider) then
		local MIN_PERCENT_SHOW_DIVIDER = 0.015;
		if(fillPercent > MIN_PERCENT_SHOW_DIVIDER) then
			self.tempMaxHealthLossDivider:SetXPosition(fullWidth*(1-fillPercent));
		else
			self.tempMaxHealthLossDivider:SetXPosition(0);
		end
	end
end
