KioskModeSplashEndMixin = {};

function KioskModeSplashEndMixin:OnLoad()
	self:SetParent(GetAppropriateTopLevelParent());
	self:SetFrameStrata("FULLSCREEN");

	self.Background:SetTexture(KIOSK_SPLASH_END_BACKGROUND);

	self.BodyText1:SetText(KIOSK_SPLASH_END_BODY1_TEXT);

	self.FooterText:SetText(KIOSK_SPLASH_END_FOOTER1_TEXT);
end

KioskFrameMixin = {}

function KioskFrameMixin:OnLoad()
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_WARNING");
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_CHANGED");
	self:RegisterEvent("KIOSK_SESSION_STARTED");
	self:RegisterEvent("KIOSK_SESSION_EXPIRED");
	self:RegisterEvent("KIOSK_SESSION_SHUTDOWN");
	self:RegisterEvent("KIOSK_SESSION_RESTART");
	self:RegisterEvent("TOGGLE_CONSOLE");
	self:RegisterEvent("DEBUG_MENU_TOGGLED");
end

function KioskFrameMixin:OnEvent(event, ...)
	if event == "TOGGLE_CONSOLE" then
		if DeveloperConsole and DeveloperConsole:IsShown() then
			local shownRequested = false;
			DeveloperConsole:Toggle(shownRequested);
		end
	elseif event == "DEBUG_MENU_TOGGLED" then
		if DebugMenu.IsVisible() then
			DebugMenu.SetDebugMenuShown(false);
		end
	elseif event == "KIOSK_SESSION_EXPIRATION_CHANGED" then
		if UIErrorsFrame then
			UIErrorsFrame:AddExternalWarningMessage(KIOSK_SESSION_TIMER_CHANGED);
		end

		StaticPopup_Show("OKAY", KIOSK_SESSION_TIMER_CHANGED);

		KioskModeSplashEnd:Hide();
	elseif event == "KIOSK_SESSION_EXPIRATION_WARNING" then
		local secondsRemaining = ...;
		local msg = string.format(KIOSK_SESSION_EXPIRE_WARNING, secondsRemaining / 60);

		if UIErrorsFrame and secondsRemaining > 60 then
			UIErrorsFrame:AddExternalWarningMessage(msg);
		end

		ChatFrameUtil.DisplaySystemMessageInCurrent(msg);

		PlaySound(Kiosk.ExpirationWarningSoundKit);
	elseif event == "KIOSK_SESSION_SHUTDOWN" then
		SettingsPanel:SetAllSettingsToDefaults();
	elseif event == "KIOSK_SESSION_EXPIRED" then
		KioskModeSplashEnd:Show();
	end
end

function KioskFrameMixin:HasAllowedMaps()
	return #Kiosk.AllowedMapIDs > 0;
end

function KioskFrameMixin:GetAllowedMapIDs()
	return Kiosk.AllowedMapIDs;
end
