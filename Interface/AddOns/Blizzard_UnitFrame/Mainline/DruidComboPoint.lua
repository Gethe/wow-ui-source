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
		self.activateAnim:Restart();
	else
		self.deactivateAnim:Restart();
	end
end

function DruidComboPointMixin:SetActiveNoAnimation(isActive)
	if self.isActive == isActive then
		return;
	end

	self.isActive = isActive;
	self:ResetVisuals();

	if self.isActive then
		self.instantActivateAnim:Play();
		self.instantActivateAnim:Finish();
	else
		self.instantDeactivateAnim:Play();
		self.instantDeactivateAnim:Finish();
	end
end

function DruidComboPointMixin:ResetVisuals()
	self.activateAnim:Stop();
	self.deactivateAnim:Stop();
	self.instantActivateAnim:Stop();
	self.instantDeactivateAnim:Stop();

	for _, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetAlpha(0);
	end
end
