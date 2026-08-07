FullscreenBrowserSpinnerMixin = { };

function FullscreenBrowserSpinnerMixin:OnLoad()
	self:RegisterEvent("FULLSCREEN_BROWSER_SPINNER_SHOW");
	self:RegisterEvent("FULLSCREEN_BROWSER_SPINNER_HIDE");
end

function FullscreenBrowserSpinnerMixin:SetSpinnerShown(shown)
	self.Spinner:SetShown(shown);
	self.LoadingText:SetShown(shown);

	if shown then
		if self.FadeOutAnim:IsPlaying() then
			self.FadeOutAnim:Stop();
		end

		self:SetAlpha(1.0);
		self:SetShown(true);
	else
		if self:IsShown() then
			if not self.FadeOutAnim:IsPlaying() then
				self.FadeOutAnim:Play();
			end
		end
	end
end


function FullscreenBrowserSpinnerMixin:OnEvent(event, ...)
	if event == "FULLSCREEN_BROWSER_SPINNER_SHOW" then
		StopAutoRun();
		self:SetSpinnerShown(true);
	elseif event == "FULLSCREEN_BROWSER_SPINNER_HIDE" then
		self:SetSpinnerShown(false);
	end
end

function FullscreenBrowserSpinnerMixin:OnKeyDown(key)
	if (key == "ESCAPE") then
		C_Browser.CloseFullscreenBrowser();
		self.FadeOutAnim:Stop();
		self:Hide();
	end
end

FullscreenBrowserSpinnerFadeOutAnimMixin = { };

function FullscreenBrowserSpinnerFadeOutAnimMixin:OnFadeOutFinished()
	local spinner = self:GetParent();
	spinner:SetShown(false);
	spinner.Spinner:SetShown(false);
	spinner:SetAlpha(1.0);
end
