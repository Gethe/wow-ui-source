TravelerManaPipMixin = {};

function TravelerManaPipMixin:Setup()
	self.isActive = false;
	self:ResetVisuals();
	self:Show();
end

function TravelerManaPipMixin.OnRelease(framePool, self)
	self:ResetVisuals();
	Pool_HideAndClearAnchors(framePool, self);
end

function TravelerManaPipMixin:SetActive(isActive)
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

function TravelerManaPipMixin:SetActiveNoAnimation(isActive)
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

function TravelerManaPipMixin:ResetVisuals()
	self.activateAnim:Stop();
	self.deactivateAnim:Stop();
	self.instantActivateAnim:Stop();
	self.instantDeactivateAnim:Stop();

	for _, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetAlpha(0);
	end
end
