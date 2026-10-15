local originalTimeManagerClockButtonOnLoad = TimeManagerClockButton_OnLoad;
function TimeManagerClockButton_OnLoad(self)
	originalTimeManagerClockButtonOnLoad(self);

	TimeManagerClockButton:ClearAllPoints();
	TimeManagerClockButton:SetPoint("RIGHT", MinimapCluster.ZoneTextButton, "RIGHT", -3, -1);
	TimeManagerClockButton:SetFrameLevel(11);

	TimeManagerClockTicker:ClearAllPoints();
	TimeManagerClockTicker:SetPoint("CENTER", 3, 0);
end

local originalTimeManagerFireAlarm = TimeManager_FireAlarm;
function TimeManager_FireAlarm()
	originalTimeManagerFireAlarm();

	UIFrameFlashStop(TimeManagerAlarmFiredTexture);
	TimeManagerAlarmFiredTexture:SetAlpha(1.0);
	TimeManagerAlarmFiredTexture:Hide();

	UIFrameFlash(TimeManagerClockTicker, 0.5, 0.5, -1);
end

local originalTimeManagerTurnOffAlarm = TimeManager_TurnOffAlarm;
function TimeManager_TurnOffAlarm()
	originalTimeManagerTurnOffAlarm();

	UIFrameFlashStop(TimeManagerClockTicker);
	TimeManagerClockTicker:SetAlpha(1.0);
	TimeManagerClockTicker:Show();
end
