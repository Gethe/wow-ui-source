PlayerChoiceTimeRemainingMixin = {};

function PlayerChoiceTimeRemainingMixin:HideTimer()
	self:Hide();
	self:SetScript("OnUpdate", nil);

	local toggleButton = PlayerChoiceToggle_GetActiveToggle();
	if toggleButton and toggleButton:IsShown() then
		toggleButton:UpdateButtonState();
	end
end

function PlayerChoiceTimeRemainingMixin:TryShow()
	local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo();
	if not choiceInfo then
		self:HideTimer();
		return;
	end

	local kitInfo = PlayerChoiceGetTextureKitInfo(choiceInfo.uiTextureKit);

	local remainingTime = C_PlayerChoice.GetRemainingTime();
	if remainingTime ~= nil then
		local toggleButton = PlayerChoiceToggle_GetActiveToggle();
		if toggleButton and kitInfo.timerXOffset and kitInfo.timerYOffset then
			self:ClearAllPoints();
			self:SetPoint("TOP", toggleButton, "BOTTOM", kitInfo.timerXOffset, kitInfo.timerYOffset);
		end
		self:Show();
		self:SetScript("OnUpdate", self.OnUpdate);
	else
		self:HideTimer();
	end
end

function PlayerChoiceTimeRemainingMixin:OnUpdate()
	local remainingTime = C_PlayerChoice.GetRemainingTime();
	if remainingTime ~= nil then
		self.TimerText:SetText(TIME_REMAINING.." "..SecondsToClock(remainingTime));
	else
		self:HideTimer();
	end
end