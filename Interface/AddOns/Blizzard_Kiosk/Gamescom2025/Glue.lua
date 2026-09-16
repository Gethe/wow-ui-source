-- Move required code from Unused.lua to here as needed.
GlueKioskFrameMixin = {};

function GlueKioskFrameMixin:OnEvent(event, ...)
	KioskFrameMixin.OnEvent(self, event, ...);

	if event == "KIOSK_SESSION_EXPIRATION_CHANGED" then
		if UIErrorsFrame then
			UIErrorsFrame:AddExternalWarningMessage(KIOSK_SESSION_TIMER_CHANGED);
		end

		StaticPopup_Show("OKAY", KIOSK_SESSION_TIMER_CHANGED);
	end
end
