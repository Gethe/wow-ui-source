CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.INFO_DISPLAY_CVAR);

NamePlateHealthBarMixin = CreateFromMixins(TextStatusBarMixin, NamePlateComponentMixin);

function NamePlateHealthBarMixin:OnLoad()
	-- Disable the TextStatusBarMixin behavior to force show text when hovering over the bar.
	self:EnableMouse(false);

	self:InitializeTextStatusBar();

	-- Show only current value when displaying numeric values.
	self.disableMaxValue = true;

	-- Prevent TextStatusBarMixin from changing the value determined by UpdateShownState.
	self.controlsShownState = false;

	-- Intentionally swapping the LeftText and RightText compared to what SetBarText expects to
	-- visually match the desired order when both are displayed.
	self:SetBarText(self.Text, self.RightText, self.LeftText);

	-- Use AbbreviateLargeNumbers for large values.
	self.capNumericDisplay = true;

	self:UpdateTextDisplay();

	CVarCallbackRegistry:RegisterCallback(NamePlateConstants.INFO_DISPLAY_CVAR, self.OnInfoDisplayCVarChanged, self);
end

function NamePlateHealthBarMixin:OnInfoDisplayCVarChanged()
	self:UpdateTextDisplay();
end

function NamePlateHealthBarMixin:SetUnit(unitToken)
	self.isGameObject = unitToken ~= nil and UnitIsGameObject(unitToken);

	self:UpdateShownState();
end

function NamePlateHealthBarMixin:IsGameObject()
	return self.isGameObject == true;
end

function NamePlateHealthBarMixin:SetUnitNameFontString(unitNameFontString)
	self.unitNameFontString = unitNameFontString;

	-- Leverage the logic in CompactUnitFrame_UpdateName adjusting the shown state of unit name
	-- to determine if the health text should be shown.
	do
		self.unitNameFontString:SetScript("OnShow", function()
			self:UpdateTextDisplay();
		end);

		self.unitNameFontString:SetScript("OnHide", function()
			self:UpdateTextDisplay();
		end);
	end
end

function NamePlateHealthBarMixin:ShouldTextBeShown()
	-- Don't display any health text for units with simplified nameplates unless they're the player's current target.
	if self:IsSimplified() and not self:IsTarget() then
		return false;
	end

	-- Don't display health text if the unit name is hidden to leverage the existing logic in CompactUnitFrame_UpdateName.
	if self.unitNameFontString and not self.unitNameFontString:IsShown() then
		return false;
	end

	return true;
end

function NamePlateHealthBarMixin:UpdateTextDisplay()
	if self:ShouldTextBeShown() then
		self.showPercentage = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.INFO_DISPLAY_CVAR, Enum.NamePlateInfoDisplay.CurrentHealthPercent);
		self.showNumeric = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.INFO_DISPLAY_CVAR, Enum.NamePlateInfoDisplay.CurrentHealthValue);
		self.forceShow = self.showPercentage == true or self.showNumeric == true;
	else
		self.showPercentage = false;
		self.showNumeric = false;
		self.forceShow = false;
	end

	self:UpdateTextString();
end

function NamePlateHealthBarMixin:UpdateSelectionBorder()
	local isTarget = self:IsTarget();
	local isFocus = self:IsFocus();

	self.selectedBorder:SetShown(isTarget or isFocus);

	local borderColor = nil;
	if isTarget then
		borderColor = NamePlateConstants.TARGET_BORDER_COLOR;
	elseif isFocus then
		borderColor = NamePlateConstants.FOCUS_TARGET_BORDER_COLOR;
	end

	if borderColor then
		self.selectedBorder:SetVertexColor(borderColor.r, borderColor.g, borderColor.b);
	end

	-- Slightly darken the health bar of any unit that's not the target or focus to make it easier to
	-- distinguish those states.
	self.deselectedOverlay:SetShown(not isTarget and not isFocus);
end

function NamePlateHealthBarMixin:IsPlayer()
	return self.isPlayer == true;
end

function NamePlateHealthBarMixin:SetIsPlayer(isPlayer)
	self.isPlayer = isPlayer;

	self:UpdateShownState();
end

function NamePlateHealthBarMixin:IsDead()
	return self.isDead == true;
end

function NamePlateHealthBarMixin:SetIsDead(isDead)
	self.isDead = isDead;

	self:UpdateShownState();
end

function NamePlateHealthBarMixin:IsSimplified()
	return self.isSimplified;
end

function NamePlateHealthBarMixin:SetIsSimplified(isSimplified)
	self.isSimplified = isSimplified;

	self:UpdateTextDisplay();
end

function NamePlateHealthBarMixin:IsTarget()
	return self.isTarget;
end

function NamePlateHealthBarMixin:SetIsTarget(isTarget)
	self.isTarget = isTarget;

	self:UpdateTextDisplay();
	self:UpdateSelectionBorder();
end

function NamePlateHealthBarMixin:IsFocus()
	return self.isFocus;
end

function NamePlateHealthBarMixin:SetIsFocus(isFocus)
	self.isFocus = isFocus;

	self:UpdateSelectionBorder();
end

function NamePlateHealthBarMixin:ShouldBeShown()
	if self:IsWidgetsOnlyMode() then
		return false;
	end

	-- Health bars for dead NPCs are hidden.
	if self:IsPlayer() == false and self:IsDead() then
		return false;
	end

	if self:IsGameObject() then
		return false;
	end

	return true;
end

function NamePlateHealthBarMixin:UpdateShownState()
	if self:ShouldBeShown() == true then
		self:Show();
	else
		self:Hide();
	end
end
