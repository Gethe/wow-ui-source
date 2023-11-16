local expirationWarningSoundKit = 15273;
local errorSecondsThreshold = 60;

KioskFrameMixin = {}

function KioskFrameMixin:OnLoad()
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_WARNING");
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_CHANGED");
	self:RegisterEvent("KIOSK_SESSION_SHUTDOWN");
	self.whitelistedMapIDs = { };
end

function KioskFrameMixin:HasWhitelistedMaps()
	return #self.whitelistedMapIDs > 0;
end

function KioskFrameMixin:GetWhitelistedMapIDs()
	return self.whitelistedMapIDs;
end

function KioskFrameMixin:OnEvent(event, ...)
	if event == "KIOSK_SESSION_EXPIRATION_WARNING" then
		local seconds = ...;
		local msg = string.format(KIOSK_SESSION_EXPIRE_WARNING, seconds / 60);

		if seconds > errorSecondsThreshold then
			UIErrorsFrame:AddExternalWarningMessage(msg);
		end

		ChatFrame_DisplaySystemMessageInCurrent(msg);

		PlaySound(expirationWarningSoundKit);
	elseif event == "KIOSK_SESSION_EXPIRATION_CHANGED" then
		UIErrorsFrame:AddExternalWarningMessage(KIOSK_SESSION_TIMER_CHANGED);
	elseif event == "KIOSK_SESSION_SHUTDOWN" then
		SettingsPanel:SetAllSettingsToDefaults();
	end
end

KioskSessionStartedDialogButtonMixin = {}

function KioskSessionStartedDialogButtonMixin:OnClick()
	KioskSessionStartedDialog:Hide();
end

KioskSessionFinishedDialogMixin = CreateFromMixins(BaseExpandableDialogMixin);

function KioskSessionFinishedDialogMixin:OnLoad()
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_CHANGED");
	self:RegisterEvent("KIOSK_SESSION_EXPIRED");
end

function KioskSessionFinishedDialogMixin:OnEvent(event, ...)
	if event == "KIOSK_SESSION_EXPIRATION_CHANGED" then
		local reactivated = ...;
		if reactivated then
			self:Hide();
		end
	elseif event == "KIOSK_SESSION_EXPIRED" then
		-- Clear starting dialog if still showing.
		KioskSessionStartedDialog:Hide();
		self:Show();
	end
end