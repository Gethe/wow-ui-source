DruidComboPointBarMixin = {};

function DruidComboPointBarMixin:ShouldShowBar()
	local showBar = false;
	local unit = self:GetUnit();
	local _, myclass = UnitClass(unit);
	if myclass == "DRUID" then
		local powerType = UnitPowerType(unit);
		showBar = (powerType == Enum.PowerType.Energy);
	end
	return showBar;
end

function DruidComboPointBarMixin:UpdatePower()
	local comboPoints = UnitPower(self:GetUnit(), self.powerType);

	for i = 1, #self.classResourceButtonTable do
		self.classResourceButtonTable[i]:SetActive(i <= comboPoints);
	end
end

DruidComboPointMixin = {};

function DruidComboPointMixin:Setup()
	self.isActive = nil;
	self:ResetVisuals();
	self:Show();
end

function DruidComboPointMixin.OnRelease(framePool, self)
	self:ResetVisuals();
	Pool_HideAndClearAnchors(framePool, self);
end

function DruidComboPointMixin:SetActive(isActive)
	if self.isActive == isActive then
		return;
	end
	
	self.isActive = isActive;

	self:ResetVisuals();

	if self.isActive then
		self.FB_Slash:Show();
		self.activateAnim:Restart();
	else
		self.deactivateAnim:Restart();
	end
end

function DruidComboPointMixin:ResetVisuals()
	self.activateAnim:Stop();
	self.deactivateAnim:Stop();

	self.FB_Slash:Hide();

	for _, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetAlpha(0);
	end
end