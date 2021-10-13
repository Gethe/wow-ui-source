local expirationWarningSoundKit = 15273;
local errorSecondsThreshold = 60;

KioskFrameMixin = {}

function KioskFrameMixin:OnLoad()
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_WARNING");
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_CHANGED");
	self.whitelistedMapIDs = { 1533 };
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
	end
end

KioskSessionFinishedDialogMixin = CreateFromMixins(BaseExpandableDialogMixin);

function KioskSessionFinishedDialogMixin:OnLoad()
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_CHANGED");
	self:RegisterEvent("KIOSK_SESSION_EXPIRED");

	self.Dialog.Title:SetText(KIOSK_SESSION_EXPIRED_TITLE);
	self.Dialog.SubTitle:SetText("Shadowlands");
	self.Dialog.Body:SetText(KIOSK_SESSION_EXPIRED_BODY);
end

function KioskSessionFinishedDialogMixin:OnEvent(event, ...)
	if event == "KIOSK_SESSION_EXPIRATION_CHANGED" then
		local reactivated = ...;
		if reactivated then
			self:Hide();
		end
	elseif event == "KIOSK_SESSION_EXPIRED" then
		self:Show();
	end
end