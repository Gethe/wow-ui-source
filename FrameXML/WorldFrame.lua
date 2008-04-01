
FRAMERATE_FREQUENCY = 0.25;

function ToggleFramerate()
	if ( FramerateText:IsVisible() ) then
		FramerateLabel:Hide();
		FramerateText:Hide();
	else
		FramerateLabel:Show();
		FramerateText:Show();
	end
	WorldFrame.fpsTime = 0;
end

function WorldFrame_OnUpdate(elapsed)
	if ( FramerateText:IsVisible() ) then
		local timeLeft = this.fpsTime - elapsed
		if ( timeLeft <= 0 ) then
			this.fpsTime = FRAMERATE_FREQUENCY;
			FramerateText:SetText(format("%.1f", GetFramerate()));
		else
			this.fpsTime = timeLeft;
		end
	end
end

SCREENSHOT_STATUS_FADETIME = 1.5;

function TakeScreenshot()
	if ( ScreenshotStatus:IsVisible() ) then
		ScreenshotStatus:Hide();
	end
	Screenshot();
end

function ScreenshotStatus_OnLoad()
	this:RegisterEvent("SCREENSHOT_SUCCEEDED");
	this:RegisterEvent("SCREENSHOT_FAILED");
end

function ScreenshotStatus_OnEvent(event)
	this.startTime = GetTime();
	this:SetAlpha(1.0);
	if ( event == "SCREENSHOT_SUCCEEDED" ) then
		ScreenshotStatusText:SetText(TEXT(SCREENSHOT_SUCCESS));
	end
	if ( event == "SCREENSHOT_FAILED" ) then
		ScreenshotStatusText:SetText(TEXT(SCREENSHOT_FAILURE));
	end
	this:Show();
end

function ScreenshotStatus_OnUpdate(elapsed)
	elapsed = GetTime() - this.startTime;
	if ( elapsed < SCREENSHOT_STATUS_FADETIME ) then
		local alpha = 1.0 - (elapsed / SCREENSHOT_STATUS_FADETIME);
		this:SetAlpha(alpha);
		return;
	end
	this:Hide();
end


