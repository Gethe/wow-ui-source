AzeriteEmpoweredItemTierMixin = {};

function AzeriteEmpoweredItemTierMixin:Reset()
	self.azeritePowerButtons = {};
	self.selectedPowerID = nil;
end

function AzeriteEmpoweredItemTierMixin:Setup(empoweredItemLocation, tierInfo, azeriteItemPowerLevel, previousTier, powerPool)
	self:Reset();
	self.previousTier = previousTier;
	self.meetsPowerLevelRequirement = azeriteItemPowerLevel >= tierInfo.unlockLevel;

	self.TierLabel:SetText(tierInfo.unlockLevel);

	for powerIndex, azeritePowerID in ipairs(tierInfo.azeritePowerIDs) do
		local azeritePowerButton = powerPool:Acquire();
		table.insert(self.azeritePowerButtons, azeritePowerButton);

		local azeritePowerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(empoweredItemLocation, azeritePowerID);
		azeritePowerButton:Setup(empoweredItemLocation, azeritePowerInfo);

		if azeritePowerButton:IsSelected() then
			self.selectedPowerID = azeritePowerButton:GetAzeritePowerID();
		end
	end
	
	local isSelectionActive = self:IsSelectionActive();
	local specID = GetSpecializationInfo(GetSpecialization())
	for i, azeritePowerButton in ipairs(self.azeritePowerButtons) do
		local isSpecAllowed = C_AzeriteEmpoweredItem.IsPowerAvailableForSpec(azeritePowerButton:GetAzeritePowerID(), specID);
		azeritePowerButton:SetCanBeSelected(isSelectionActive and isSpecAllowed);
	end

	self.Bg:SetAlpha(isSelectionActive and .25 or .1);
	self.TierLabel:SetFontObject(isSelectionActive and GameFontNormalLargeOutline or GameFontDisableLarge)

	self:Layout();
end

function AzeriteEmpoweredItemTierMixin:Layout()
	local buttonWidth = 0;
	local SPACING = 25;
	for i, azeritePowerButton in ipairs(self.azeritePowerButtons) do
		buttonWidth = buttonWidth + azeritePowerButton:GetWidth();
	end
	buttonWidth = buttonWidth + math.max(0, #self.azeritePowerButtons - 1) * SPACING;

	local widthLeft = math.max(0, self:GetWidth() - buttonWidth);
	local leftStart = widthLeft / 2;

	for i, azeritePowerButton in ipairs(self.azeritePowerButtons) do
		azeritePowerButton:SetPoint("LEFT", self, "LEFT", leftStart + (i - 1) * (azeritePowerButton:GetWidth() + SPACING), 0);
		azeritePowerButton:Show();
	end
end

function AzeriteEmpoweredItemTierMixin:HasAnySelected()
	return self.selectedPowerID ~= nil;
end

function AzeriteEmpoweredItemTierMixin:IsSelectionActive()
	if self:HasAnySelected() then
		return false;
	end

	if self.previousTier then
		if not self.previousTier:HasAnySelected() then
			return false;
		end
	end

	return self.meetsPowerLevelRequirement;
end