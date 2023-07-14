local numMirrorTimerTypes = 3;

MirrorTimerAtlas = {
	EXHAUSTION = "ui-castingbar-filling-standard",
	BREATH = "ui-castingbar-filling-applyingcrafting",
	DEATH = "ui-castingbar-filling-standard",
	FEIGNDEATH = "ui-castingbar-filling-channel",
};

MirrorTimerContainerMixin = {};

function MirrorTimerContainerMixin:OnLoad()
	self.activeTimers = {};

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("MIRROR_TIMER_START");
	self:RegisterEvent("MIRROR_TIMER_STOP");
	self:RegisterEvent("MIRROR_TIMER_PAUSE");
end

function MirrorTimerContainerMixin:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		for i = 1, numMirrorTimerTypes do
			local timer, value, maxvalue, _, paused, label = GetMirrorTimerInfo(i);
			if timer ~= "UNKNOWN" then
				self:SetupTimer(timer, value, maxvalue, paused, label);
			end
		end
	elseif event == "MIRROR_TIMER_START" then
		local timer, value, maxvalue, _, paused, label = ...;
		self:SetupTimer(timer, value, maxvalue, paused, label);
	elseif event == "MIRROR_TIMER_STOP" then
		local timer = ...;
		self:ClearTimer(timer);
	elseif event == "MIRROR_TIMER_PAUSE" then
		local timer, paused = ...;
		local activeTimer =	self:GetActiveTimer(timer);
		if activeTimer then
			activeTimer:SetPaused(paused);
		end
	end
end

function MirrorTimerContainerMixin:SetupTimer(timer, value, maxvalue, paused, label)
	local availableTimerFrame = self:GetAvailableTimer(timer);
	if not availableTimerFrame then
		return;
	end

	availableTimerFrame:Setup(timer, value, maxvalue, paused, label);
	self.activeTimers[timer] = availableTimerFrame;
end

function MirrorTimerContainerMixin:ClearTimer(timer)
	local activeTimer = self.activeTimers[timer];
	if activeTimer then
		activeTimer:Clear();
		self.activeTimers[timer] = nil;
	end
end

function MirrorTimerContainerMixin:GetActiveTimer(timer)
	return self.activeTimers[timer];
end

function MirrorTimerContainerMixin:GetAvailableTimer(timer)
	local activeTimer =	self:GetActiveTimer(timer);
	if activeTimer then
		return activeTimer;
	end

	for index, timerFrame in ipairs(self.mirrorTimers) do
		if not timerFrame:HasTimer() then
			return timerFrame;
		end
	end
end

function MirrorTimerContainerMixin:ForceUpdateTimers()
	for _, activeTimer in pairs(self.activeTimers) do
		activeTimer:OnUpdate();
	end
end

function MirrorTimerContainerMixin:SetIsInEditMode(isInEditMode)
	for index, timerFrame in ipairs(self.mirrorTimers) do
		timerFrame:SetIsInEditMode(isInEditMode);
	end
end

function MirrorTimerContainerMixin:HasAnyTimersShowing()
	for index, timerFrame in ipairs(self.mirrorTimers) do
		if timerFrame:IsShown() then
			return true;
		end
	end
	return false;
end

MirrorTimerMixin = {};

function MirrorTimerMixin:OnUpdate(elapsed)
	if not self.timer then
		return;
	end

	self:UpdateStatusBarValue();
end

function MirrorTimerMixin:OnShow()
	MirrorTimerContainer:Layout();
end

function MirrorTimerMixin:OnHide()
	MirrorTimerContainer:Layout();
end

function MirrorTimerMixin:Setup(timer, value, maxvalue, paused, label)
	self.timer = timer;

	self.StatusBar:SetStatusBarTexture(MirrorTimerAtlas[timer]);
	self.StatusBar:SetMinMaxValues(0, (maxvalue / 1000));
	self:UpdateStatusBarValue(value);

	self:SetPaused(paused);

	self.Text:SetText(label);

	self:UpdateShownState();
end

function MirrorTimerMixin:Clear()
	self:SetScript("OnUpdate", nil);
	self.timer = nil;
	self:UpdateShownState();
end

function MirrorTimerMixin:SetPaused(paused)
	if paused then
		self:SetScript("OnUpdate", nil);
	else
		self:SetScript("OnUpdate", self.OnUpdate);
	end
end

function MirrorTimerMixin:UpdateStatusBarValue(value)
	self.StatusBar:SetValue((value or GetMirrorTimerProgress(self.timer))  / 1000);
end

function MirrorTimerMixin:HasTimer()
	return self.timer;
end

function MirrorTimerMixin:SetIsInEditMode(isInEditMode)
	self.isInEditMode = isInEditMode;
	self:UpdateShownState();
end

function MirrorTimerMixin:UpdateShownState()
	self:SetShown(self.isInEditMode or self.timer);
end