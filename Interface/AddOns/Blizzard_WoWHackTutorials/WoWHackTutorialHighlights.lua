
WoWHackTutorialHighlightMixin = {};

function WoWHackTutorialHighlightMixin:SetHighlightShown(shown)
	local target = self:GetParent();
	local isShown = shown and target:IsVisible();
	self:SetShown(isShown);
	if isShown and self.pulse then
		if not self.PulseAnim:IsPlaying() then
			self.PulseAnim:Play();
		end
	elseif self.PulseAnim:IsPlaying() then
		self.PulseAnim:Stop();
	end
end
