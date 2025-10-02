
StaticPopupDialogs["WOW_SURVEY"] = {
	text = USER_SURVEY_DIALOG_TEXT,
	button1 = YES,
	button2 = LATER,
	button3 = NO,
	selectCallbackByIndex = true,
	OnShow = function(dialog, data)
		WowSurveyStatusFrame:Hide();
	end,
	OnButton1 = function(dialog, data)
		C_WowSurvey.OpenSurvey();
		dialog.accepted = true;
	end,
	OnButton2 = function(dialog, data)
		-- do nothing, just close the dialog
		dialog.accepted = false;
	end,
	OnButton3 = function(dialog, data)
		dialog.accepted = true;
	end,
	OnHide = function(dialog, data)
		if not dialog.accepted then
			WowSurveyStatusFrame:Show();
		end
		dialog.accepted = nil;
	end,
	whileDead = 1,
	hideOnEscape = 1
};

WowSurveyStatusMixin = {};

function WowSurveyStatusMixin:OnLoad()
	self.TitleText:SetText(USER_SURVEY_STATUS_READY);
	self.SubtitleText:SetText(USER_SURVEY_STATUS_READY_DESCRIPTION);
	StatusUIMixin.OnLoad(self);

	self:RegisterEvent("SURVEY_DELIVERED")
end

function WowSurveyStatusMixin:OnEvent(event, ...)
	if event == "SURVEY_DELIVERED" then
		self:Show();
	end
end

function WowSurveyStatusMixin:OnClick()
	StaticPopup_Show("WOW_SURVEY");
end
