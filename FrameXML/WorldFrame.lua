
FRAMERATE_FREQUENCY = 0.25;

function ToggleFramerate(benchmark)
	FramerateText.benchmark = benchmark;
	if ( FramerateText:IsShown() ) then
		FramerateLabel:Hide();
		FramerateText:Hide();
	else
		FramerateLabel:Show();
		FramerateText:Show();
	end
	WorldFrame.fpsTime = 0;
end

function WorldFrame_OnUpdate(self, elapsed)
	if ( FramerateText:IsShown() ) then
		local timeLeft = self.fpsTime - elapsed
		if ( timeLeft <= 0 ) then
			self.fpsTime = FRAMERATE_FREQUENCY;
			FramerateText:SetFormattedText("%.1f", GetFramerate());
		else
			self.fpsTime = timeLeft;
		end
	end
	-- Process dialog onUpdates if the map is up or the ui is hidden
	local dialog;
	for i = 1, STATICPOPUP_NUMDIALOGS, 1 do
		dialog = getglobal("StaticPopup"..i);
		if ( dialog and dialog:IsShown() and not dialog:IsVisible() ) then
			StaticPopup_OnUpdate(dialog, elapsed);
		end
	end

	-- Process breathbar onUpdates if the map is up or the ui is hidden
	local bar;
	for i=1, MIRRORTIMER_NUMTIMERS do
		bar = getglobal("MirrorTimer"..i);
		if ( bar and bar:IsShown() and not bar:IsVisible() ) then
			MirrorTimerFrame_OnUpdate(bar, elapsed);
		end
	end

	-- Process item translation onUpdates if the map is up or the ui is hidden
	if ( ItemTextFrame:IsShown() and not ItemTextFrame:IsVisible() ) then
		ItemTextFrame_OnUpdate(elapsed);
	end

	-- Process time manager alarm onUpdates in order to allow the alarm to go off without the clock
	-- being visible
	if ( TimeManagerClockButton and not TimeManagerClockButton:IsVisible() and TimeManager_ShouldCheckAlarm() ) then
		TimeManager_CheckAlarm(elapsed);
	end
end

SCREENSHOT_STATUS_FADETIME = 1.5;

function TakeScreenshot()
	if ( ScreenshotStatus:IsShown() ) then
		ScreenshotStatus:Hide();
	end
	Screenshot();
end

function ScreenshotStatus_OnLoad(self)
	self:RegisterEvent("SCREENSHOT_SUCCEEDED");
	self:RegisterEvent("SCREENSHOT_FAILED");
end

function ScreenshotStatus_OnEvent(self, event, ...)
	self.startTime = GetTime();
	self:SetAlpha(1.0);
	if ( event == "SCREENSHOT_SUCCEEDED" ) then
		ScreenshotStatusText:SetText(SCREENSHOT_SUCCESS);
	end
	if ( event == "SCREENSHOT_FAILED" ) then
		ScreenshotStatusText:SetText(SCREENSHOT_FAILURE);
	end
	self:Show();
end

function ScreenshotStatus_OnUpdate(self, elapsed)
	elapsed = GetTime() - self.startTime;
	if ( elapsed < SCREENSHOT_STATUS_FADETIME ) then
		local alpha = 1.0 - (elapsed / SCREENSHOT_STATUS_FADETIME);
		self:SetAlpha(alpha);
		return;
	end
	self:Hide();
end


