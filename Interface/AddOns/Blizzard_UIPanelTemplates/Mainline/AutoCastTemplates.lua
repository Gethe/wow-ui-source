AutoCastOverlayMixin = {};

function AutoCastOverlayMixin:ShowAutoCastEnabled(isEnabled)
	self.autoCastEnabled = isEnabled;
	self:UpdateShineAnim();
end

function AutoCastOverlayMixin:OnShow()
	self:UpdateShineAnim();
end

function AutoCastOverlayMixin:OnHide()
	self:UpdateShineAnim();
end

function AutoCastOverlayMixin:UpdateShineAnim()
	local shouldPlayShineAnim = self.autoCastEnabled and self:IsShown();
	local isPlaying = self.Shine.Anim:IsPlaying();

	if shouldPlayShineAnim and not isPlaying then
		self.Shine.Anim:Play();
	elseif not shouldPlayShineAnim and isPlaying then
		self.Shine.Anim:Stop();
	end
	self.Shine:SetShown(shouldPlayShineAnim);
end