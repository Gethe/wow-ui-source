ACTION_STATUS_FADETIME = 2.0;

function ActionStatus_OnLoad(self)
	self:RegisterEvent("SCREENSHOT_STARTED");
	self:RegisterEvent("SCREENSHOT_SUCCEEDED");
	self:RegisterEvent("SCREENSHOT_FAILED");
	self:RegisterEvent("GLUE_SCREENSHOT_STARTED");
	self:RegisterEvent("GLUE_SCREENSHOT_SUCCEEDED");
	self:RegisterEvent("GLUE_SCREENSHOT_FAILED");
end

function ActionStatus_OnEvent(self, event, ...)
	if ( event == "SCREENSHOT_STARTED" or event == "GLUE_SCREENSHOT_STARTED" ) then
		self:Hide();
	else
		self.startTime = GetTime();
		self:SetAlpha(1.0);
		if ( event == "SCREENSHOT_SUCCEEDED" or event == "GLUE_SCREENSHOT_SUCCEEDED" ) then
			ActionStatus_DisplayMessage(SCREENSHOT_SUCCESS, true);
		end
		if ( event == "SCREENSHOT_FAILED" or event == "GLUE_SCREENSHOT_FAILED" ) then
			ActionStatus_DisplayMessage(SCREENSHOT_FAILURE, true);
		end
		self:Show();
	end
end

function ActionStatus_DisplayMessage(text, ignoreNewbieTooltipSetting)
	if ( ignoreNewbieTooltipSetting or GetCVar("showNewbieTips") == "1" ) then
		local self = ActionStatus;
		self.startTime = GetTime();
		self:SetAlpha(1.0);
		ActionStatusText:SetText(text);
		self:Show();
	end
end

function ActionStatus_OnUpdate(self)
	local elapsed = GetTime() - self.startTime;
	if ( elapsed < ACTION_STATUS_FADETIME ) then
		local alpha = 1.0 - (elapsed / ACTION_STATUS_FADETIME);
		self:SetAlpha(alpha);
		return;
	end
	self:Hide();
end
