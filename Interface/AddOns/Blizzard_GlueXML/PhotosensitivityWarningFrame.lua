
PhotosensitivityWarningFrameMixin = {};

function PhotosensitivityWarningFrameMixin:OnLoad()
	local function OnFadeOutFinished()
		self:ShowNextFrame();
	end

	self.FadeOut:SetScript("OnFinished", OnFadeOutFinished)
end	

function PhotosensitivityWarningFrameMixin:OnShow()
	self:TryShow();
end

function PhotosensitivityWarningFrameMixin:TryShow()
	StopGlueMusic();
	StopGlueAmbience();

	local localizedWarningFrameShowing = ShouldShowRegulationOverlay();
	self.lockedByOtherWarning = localizedWarningFrameShowing;
	self.WarningIcon:SetShown(not localizedWarningFrameShowing);
	self.WarningTitle:SetShown(not localizedWarningFrameShowing);
	self.WarningText:SetShown(not localizedWarningFrameShowing);
	self.ContinueText:SetShown(not localizedWarningFrameShowing);

	if not localizedWarningFrameShowing then
		self.FadeOut:Play();
	end
end

function PhotosensitivityWarningFrameMixin:GetLockedByOtherWarning()
	return self.lockedByOtherWarning;
end

function PhotosensitivityWarningFrameMixin:OnClick()
	self:ShowNextFrame();
end

function PhotosensitivityWarningFrameMixin:OnKeyDown()
	self:ShowNextFrame();
end

function PhotosensitivityWarningFrameMixin:ShowNextFrame()
	if self.lockedByOtherWarning then
		return;
	end

	self.FadeOut:Stop();
	self:SetAlpha(1.0);
	self:Hide();

	GlueParent_CloseSecondaryScreen();

	GlueParent_UpdateDialogs();
	GlueParent_CheckCinematic();
	if ( AccountLogin:IsVisible() ) then
		SetExpansionLogo(AccountLogin.UI.GameLogo, GetClientDisplayExpansionLevel());
	end
end