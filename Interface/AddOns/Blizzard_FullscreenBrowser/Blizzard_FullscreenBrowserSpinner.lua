FullscreenBrowserSpinnerMixin = { };

function FullscreenBrowserSpinnerMixin:OnLoad()
	self:RegisterEvent("FULLSCREEN_BROWSER_SPINNER_SHOW");
	self:RegisterEvent("FULLSCREEN_BROWSER_SPINNER_HIDE");
end

function FullscreenBrowserSpinnerMixin:SetSpinnerShown(shown)
	if shown then
		if self.FadeOutAnim:IsPlaying() then
			self.FadeOutAnim:Stop();
		end

		self:SetAlpha(1.0);
		self:SetShown(true);
		self.Spinner:SetShown(true);
	else
		if self:IsShown() then
			self.FadeOutAnim:Play();
		end
	end
end


function FullscreenBrowserSpinnerMixin:OnEvent(event, ...)
	if event == "FULLSCREEN_BROWSER_SPINNER_SHOW" then
		self:SetSpinnerShown(true);
	elseif event == "FULLSCREEN_BROWSER_SPINNER_HIDE" then
		self:SetSpinnerShown(false);
	end
end

FullscreenBrowserSpinnerFadeOutAnimMixin = { };

function FullscreenBrowserSpinnerFadeOutAnimMixin:OnFadeOutFinished()
	local spinner = self:GetParent();
	spinner:SetShown(false);
	spinner.Spinner:SetShown(false);
	spinner:SetAlpha(1.0);
end
