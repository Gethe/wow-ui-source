-- All unused but retained for ease of reference by the next developer working on Kiosk.
GameKioskSessionFinishedDialogMixin = {};

function GameKioskSessionFinishedDialogMixin:OnLoad()
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_CHANGED");

	self.Bg:SetAtlas("ClassTrial-End-Frame", true);

	self.Content:SetSize(563, 345);

	self.Content.Title:SetText(KIOSK_SESSION_EXPIRED_TITLE);
	self.Content.SubTitle:SetText(KIOSK_SESSION_EXPIRED_SUBTITLE);
	self.Content.Body:SetText(KIOSK_SESSION_EXPIRED_BODY);
end

function GameKioskSessionFinishedDialogMixin:OnEvent(event, ...)
	if event == "KIOSK_SESSION_EXPIRATION_CHANGED" then
		local reactivated = ...;
		if reactivated then
			self:Hide();
		end
	elseif event == "KIOSK_SESSION_EXPIRED" then
		GameKioskSessionStartedDialog:Hide();

		self:Show();
	end
end
