MagePowerBar = {};

function MagePowerBar:UpdatePower()
	local numCharges = UnitPower(self:GetUnit(), self.powerType, true);
	for i = 1, #self.classResourceButtonTable do
		self.classResourceButtonTable[i]:SetActive(i <= numCharges);
	end
end


ArcaneChargeMixin = { };

function ArcaneChargeMixin:Setup()
	self.isActive = nil;
	self:ResetVisuals();
	self:Show();
end

function ArcaneChargeMixin.OnRelease(framePool, self)
	self:ResetVisuals();
	Pool_HideAndClearAnchors(framePool, self);
end

function ArcaneChargeMixin:SetActive(isActive)
	if self.isActive == isActive then
		return;
	end

	self.isActive = isActive;

	self:ResetVisuals();

	if self.isActive then
		self.activateAnim:Restart();
	else
		self.deactivateAnim:Restart();
	end
end

function ArcaneChargeMixin:ResetVisuals()
	self.activateAnim:Stop();
	self.deactivateAnim:Stop();

	for _, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetAlpha(0);
	end
end