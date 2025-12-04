-- Displays the info about the unit to which the nameplate is attached.
-- This mixin is a child of a frame that has been created in code and is using NamePlateBaseMixin.
NamePlateRaidTargetMixin = CreateFromMixins(NamePlateComponentMixin);

function NamePlateRaidTargetMixin:SetRaidTargetIndex(raidTargetIndex)
	if self.raidTargetIndex == raidTargetIndex then
		return;
	end

	self.raidTargetIndex = raidTargetIndex;

	if self.raidTargetIndex ~= nil then
		SetRaidTargetIconTexture(self.RaidTargetIcon, self.raidTargetIndex);
	end

	self:UpdateShownState();
end

function NamePlateRaidTargetMixin:ShouldBeShown()
	if self.raidTargetIndex == nil then
		return false;
	end

	if self:IsWidgetsOnlyMode() then
		return false;
	end

	return true;
end

function NamePlateRaidTargetMixin:UpdateShownState()
	if self:ShouldBeShown() == true then
		self:Show();
	else
		self:Hide();
	end
end
