
BlizzardStopwatchOptions = BlizzardStopwatchOptions or nil;

-- speed optimizations (mostly so update functions are faster)
local _G = getfenv(0);
local date = _G.date;
local abs = _G.abs;
local min = _G.min;
local max = _G.max;
local floor = _G.floor;
local mod = _G.mod;
local tonumber = _G.tonumber;
local gsub = _G.gsub;
local GetCVar = _G.GetCVar;
local SetCVar = _G.SetCVar;
local GetGameTime = _G.GetGameTime;

-- private data
local SEC_TO_MINUTE_FACTOR = 1/60;
local SEC_TO_HOUR_FACTOR = SEC_TO_MINUTE_FACTOR*SEC_TO_MINUTE_FACTOR;

local WARNING_SOUND_TRIGGER_OFFSET = -2 * SEC_TO_MINUTE_FACTOR;	-- play warning sound 2 sec before alarm sound

local Settings = {
	militaryTime = false;
	localTime = false;

	alarmHour = 12;
	alarmMinute = 00;
	alarmAM = true;
	alarmMessage = "";
	alarmEnabled = false;
};

local CVAR_USE_MILITARY_TIME = "timeMgrUseMilitaryTime";
local CVAR_USE_LOCAL_TIME = "timeMgrUseLocalTime";
local CVAR_ALARM_TIME = "timeMgrAlarmTime";
local CVAR_ALARM_MESSAGE = "timeMgrAlarmMessage";
local CVAR_ALARM_ENABLED = "timeMgrAlarmEnabled";


-- public data
MAX_TIMER_SEC = 99*3600 + 59*60 + 59;	-- 99:59:59


local function _TimeManager_GetCurrentMinutes(localTime)
	local currTime;
	if ( localTime ) then
		local dateInfo = date("*t");
		local hour, minute = dateInfo.hour, dateInfo.min;
		currTime = minute + hour*60;
	else
		local hour, minute = GetGameTime();
		currTime = minute + hour*60;
	end
	return currTime;
end

-- CVar helpers
local function _TimeManager_Setting_SetBool(cvar, field, value)
	if ( value ) then
		SetCVar(cvar, "1");
	else
		SetCVar(cvar, "0");
	end
	Settings[field] = value;
end

local function _TimeManager_Setting_Set(cvar, field, value)
	SetCVar(cvar, value);
	Settings[field] = GetCVar(cvar);
end

local function _TimeManager_Setting_SetTime()
	local alarmTime = GameTime_ComputeMinutes(Settings.alarmHour, Settings.alarmMinute, Settings.militaryTime, Settings.alarmAM);
	SetCVar(CVAR_ALARM_TIME, alarmTime);
end


-- TimeManagerFrame

function TimeManager_Toggle()
	if ( TimeManagerFrame:IsShown() ) then
		TimeManagerFrame:Hide();
	else
		TimeManagerFrame:Show();
	end
end

function TimeManagerFrame_OnLoad(self)
	Settings.militaryTime = GetCVar(CVAR_USE_MILITARY_TIME) == "1";
	Settings.localTime = GetCVar(CVAR_USE_LOCAL_TIME) == "1";
	local alarmTime = tonumber(GetCVar(CVAR_ALARM_TIME));
	Settings.alarmHour = floor(alarmTime / 60);
	Settings.alarmMinute = max(min(alarmTime - Settings.alarmHour*60, 59), 0);
	Settings.alarmHour = max(min(Settings.alarmHour, 23), 0);
	if ( not Settings.militaryTime ) then
		if ( Settings.alarmHour == 0 ) then
			Settings.alarmHour = 12;
			Settings.alarmAM = true;
		elseif ( Settings.alarmHour < 12 ) then
			Settings.alarmAM = true;
		elseif ( Settings.alarmHour == 12 ) then
			Settings.alarmAM = false;
		else
			Settings.alarmHour = Settings.alarmHour - 12;
			Settings.alarmAM = false;
		end
	end
	Settings.alarmMessage = GetCVar(CVAR_ALARM_MESSAGE);
	Settings.alarmEnabled = GetCVar(CVAR_ALARM_ENABLED) == "1";

	self:SetFrameLevel(self:GetFrameLevel() + 2);

	ButtonFrameTemplate_HideButtonBar(self);

	TimeManager_Update();
end

function TimeManagerFrame_OnUpdate(self, elapsed)
	TimeManager_UpdateTimeTicker();
end

function TimeManagerFrame_SetupHourDropdown(self)
	local function IsSelected(hour)
		return Settings.alarmHour == hour;
	end

	local function SetSelected(hour)
		local oldValue = Settings.alarmHour;
		Settings.alarmHour = hour;
		if ( Settings.alarmHour ~= oldValue ) then
			TimeManager_StartCheckingAlarm();
		end
		_TimeManager_Setting_SetTime();
	end

	local hourMin, hourMax;
	if Settings.militaryTime then
		hourMin, hourMax = 0, 23;
	else
		hourMin, hourMax = 1, 12;
	end

	local width = 61;
	self.AlarmTimeFrame.HourDropdown:SetWidth(width);
	self.AlarmTimeFrame.HourDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_TIME_MANAGER_HOUR");

		for hour = hourMin, hourMax, 1 do
			local text = militaryTime and format(TIMEMANAGER_24HOUR, hour) or hour;
			rootDescription:CreateRadio(text, IsSelected, SetSelected, hour);
		end
		rootDescription:SetMaximumWidth(width);
	end);
end

function TimeManagerFrame_SetupMinuteDropdown(self)
	local function IsSelected(minute)
		return Settings.alarmMinute == minute;
	end

	local function SetSelected(minute)
		local oldValue = Settings.alarmMinute;
		Settings.alarmMinute = minute;
		if ( Settings.alarmMinute ~= oldValue ) then
			TimeManager_StartCheckingAlarm();
		end
		_TimeManager_Setting_SetTime();
	end

	local width = 61;
	self.AlarmTimeFrame.MinuteDropdown:SetWidth(width);
	self.AlarmTimeFrame.MinuteDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_TIME_MANAGER_MINUTE");

		for minute = 0, 55, 5 do
			rootDescription:CreateRadio(format(TIMEMANAGER_MINUTE, minute), IsSelected, SetSelected, minute);
		end
		rootDescription:SetMaximumWidth(width);
	end);
end

function TimeManagerFrame_SetupAMPMDropdown(self)
	local function IsSelected(isAM)
		return Settings.alarmAM == isAM;
	end

	local function SetSelected(isAM)
		Settings.alarmAM = isAM;
		TimeManager_StartCheckingAlarm();
	end

	local width = 65;
	self.AlarmTimeFrame.AMPMDropdown:SetWidth(width);
	self.AlarmTimeFrame.AMPMDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_TIME_MANAGER_AMPM");

		rootDescription:CreateRadio(TIMEMANAGER_AM, IsSelected, SetSelected, true);
		rootDescription:CreateRadio(TIMEMANAGER_PM, IsSelected, SetSelected, false);
		rootDescription:SetMaximumWidth(width);
	end);
end

function TimeManagerFrame_OnShow(self)
	TimeManager_Update();
	TimeManagerStopwatchCheck:SetChecked(StopwatchFrame:IsShown());
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	TimeManager_UpdateAlarmTime();
end

function TimeManagerFrame_OnHide(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function TimeManagerCloseButton_OnClick()
	TimeManagerFrame:Hide();
end

function TimeManagerStopwatchCheck_OnClick(self)
	Stopwatch_Toggle();
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
	end
end

function TimeManager_Update()
	TimeManager_UpdateTimeTicker();
	TimeManager_UpdateAlarmTime();
	TimeManagerAlarmMessageEditBox:SetText(Settings.alarmMessage);
	TimeManagerAlarmEnabledButton:SetChecked(Settings.alarmEnabled);
	TimeManagerMilitaryTimeCheck:SetChecked(Settings.militaryTime);
	TimeManagerLocalTimeCheck:SetChecked(Settings.localTime);
end

function TimeManager_UpdateAlarmTime()
	TimeManagerFrame_SetupHourDropdown(TimeManagerFrame);
	TimeManagerFrame_SetupMinuteDropdown(TimeManagerFrame);
	TimeManagerFrame_SetupAMPMDropdown(TimeManagerFrame);

	TimeManagerFrame.AlarmTimeFrame.AMPMDropdown:SetShown(not Settings.militaryTime);
end

function TimeManager_UpdateTimeTicker()
	TimeManagerFrameTicker:SetText(GameTime_GetTime(false));
end

function TimeManagerAlarmMessageEditBox_OnEnterPressed(self)
	self:ClearFocus();
end

function TimeManagerAlarmMessageEditBox_OnEscapePressed(self)
	self:ClearFocus();
end

function TimeManagerAlarmMessageEditBox_OnEditFocusLost(self)
	_TimeManager_Setting_Set(CVAR_ALARM_MESSAGE, "alarmMessage", TimeManagerAlarmMessageEditBox:GetText());
end

function TimeManagerAlarmEnabledButton_OnClick(self)
	_TimeManager_Setting_SetBool(CVAR_ALARM_ENABLED, "alarmEnabled", not Settings.alarmEnabled);
	if ( Settings.alarmEnabled ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		TimeManager_StartCheckingAlarm();
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		if ( TimeManagerClockButton.alarmFiring ) then
			TimeManager_TurnOffAlarm();
		end
	end
end

function TimeManagerMilitaryTimeCheck_OnClick(self)
	TimeManager_ToggleTimeFormat();
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

function TimeManager_ToggleTimeFormat()
	local alarmHour = Settings.alarmHour;
	if ( Settings.militaryTime ) then
		_TimeManager_Setting_SetBool(CVAR_USE_MILITARY_TIME, "militaryTime", false);
		Settings.alarmHour, Settings.alarmAM = GameTime_ComputeStandardTime(Settings.alarmHour);
	else
		_TimeManager_Setting_SetBool(CVAR_USE_MILITARY_TIME, "militaryTime", true);
		Settings.alarmHour = GameTime_ComputeMilitaryTime(Settings.alarmHour, Settings.alarmAM);
	end
	_TimeManager_Setting_SetTime();
	TimeManager_UpdateAlarmTime();
	-- TimeManagerFrame_OnUpdate will pick up the time ticker change
	-- TimeManagerClockButton_OnUpdate will pick up the clock change
	if ( CalendarFrame_UpdateTimeFormat ) then
		-- update the Calendar's time format if it's available
		CalendarFrame_UpdateTimeFormat();
	end
end

function TimeManagerLocalTimeCheck_OnClick(self)
	TimeManager_ToggleLocalTime();
	-- since we're changing which time type we're checking, we need to check the alarm now
	TimeManager_StartCheckingAlarm();
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

function TimeManager_ToggleLocalTime()
	_TimeManager_Setting_SetBool(CVAR_USE_LOCAL_TIME, "localTime", not Settings.localTime);
	-- TimeManagerFrame_OnUpdate will pick up the time ticker change
	-- TimeManagerClockButton_OnUpdate will pick up the clock change
end

-- TimeManagerClockButton
function TimeManagerClockButton_OnLoad(self)
	if ( CLOCK_TICKER_Y_OVERRIDE ) then
		TimeManagerClockTicker:SetPoint("CENTER", select(4, TimeManagerClockTicker:GetPoint(1)), CLOCK_TICKER_Y_OVERRIDE);
	end

	self:SetFrameLevel(self:GetFrameLevel() + 2);
	TimeManagerClockButton_Update();
	if ( Settings.alarmEnabled ) then
		TimeManager_StartCheckingAlarm();
	end
	self:RegisterForClicks("AnyUp");

	-- Update ClockButton only once a second to reduce perf cost.
	self.onUpdate = TimeManagerClockButton_OnUpdate;
	self.lastUpdate = GetTime();
	C_Timer.NewTicker(1, function()
		local time = GetTime();
		local elapsed = time - self.lastUpdate;
		self:onUpdate(elapsed);
		self.lastUpdate = time;
	end);

	TimeManagerClockButton_UpdateShowClockSetting();
end

function TimeManagerClockButton_UpdateShowClockSetting()
	if ( GetCVar("showMinimapClock") == "1" ) then
		TimeManagerClockButton:Show();
		-- If the user is about to cancel an alarm, prepare to keep us shown.
		TimeManagerClockButton.prevShown = true;
	else
		if (not TimeManagerClockButton.alarmFiring) then
			TimeManagerClockButton:Hide();
		end
		-- If the user is about to cancel an alarm, prepare to hide us.
		TimeManagerClockButton.prevShown = false;
	end
end

function TimeManagerClockButton_Update()
	local currentText = TimeManagerClockTicker:GetText();
	local newText = GameTime_GetTime(false);
	if currentText ~= newText then
		TimeManagerClockTicker:SetText(newText);
	end
end

function TimeManagerClockButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	self.onUpdate = TimeManagerClockButton_OnUpdateWithTooltip;
end

function TimeManagerClockButton_OnLeave(self)
	GameTooltip:Hide();
	self.onUpdate = TimeManagerClockButton_OnUpdate;
end

function TimeManagerClockButton_OnClick(self)
	if ( self.alarmFiring ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
		TimeManager_TurnOffAlarm();
	else
		TimeManager_Toggle();
	end
end

function TimeManagerClockButton_OnUpdate(self, elapsed)
	TimeManagerClockButton_Update();
	if ( self.checkAlarm and Settings.alarmEnabled ) then
		TimeManager_CheckAlarm(elapsed);
	end
end

function TimeManagerClockButton_OnUpdateWithTooltip(self, elapsed)
	TimeManagerClockButton_OnUpdate(self, elapsed);
	TimeManagerClockButton_UpdateTooltip();
end

function TimeManager_ShouldCheckAlarm()
	return TimeManagerClockButton.checkAlarm and Settings.alarmEnabled;
end

function TimeManager_StartCheckingAlarm()
	TimeManagerClockButton.checkAlarm = true;

	-- set the time to play the warning sound
	local alarmTime = GameTime_ComputeMinutes(Settings.alarmHour, Settings.alarmMinute, Settings.militaryTime, Settings.alarmAM);
	local warningTime = alarmTime + WARNING_SOUND_TRIGGER_OFFSET;
	-- max minutes per day = 24*60 = 1440
	if ( warningTime < 0 ) then
		warningTime = warningTime + 1440;
	elseif ( warningTime > 1440 ) then
		warningTime = warningTime - 1440;
	end
	TimeManagerClockButton.warningTime = warningTime;
	TimeManagerClockButton.checkAlarmWarning = true;
	-- since game time isn't available in seconds, we have to keep track of the previous minute
	-- in order to play our alarm warning sound at the right time
	TimeManagerClockButton.currentMinute = _TimeManager_GetCurrentMinutes(Settings.localTime);
	TimeManagerClockButton.currentMinuteCounter = 0;
end

function TimeManager_CheckAlarm(elapsed)
	local currTime = _TimeManager_GetCurrentMinutes(Settings.localTime);
	local alarmTime = GameTime_ComputeMinutes(Settings.alarmHour, Settings.alarmMinute, Settings.militaryTime, Settings.alarmAM);

	-- check for the warning sound
	local clockButton = TimeManagerClockButton;
	if ( clockButton.checkAlarmWarning ) then
		if ( clockButton.currentMinute ~= currTime ) then
			clockButton.currentMinute = currTime;
			clockButton.currentMinuteCounter = 0;
		end
		local secOffset = floor(clockButton.currentMinuteCounter) * SEC_TO_MINUTE_FACTOR;
		if ( (currTime + secOffset) == clockButton.warningTime ) then
			TimeManager_FireAlarmWarning();
		end
		clockButton.currentMinuteCounter = clockButton.currentMinuteCounter + elapsed;
	end
	-- check for the alarm sound
	if ( currTime == alarmTime ) then
		TimeManager_FireAlarm();
	end
end

function TimeManager_FireAlarmWarning()
	TimeManagerClockButton.checkAlarmWarning = false;

	PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_1);
end

function TimeManager_FireAlarm()
	TimeManagerClockButton.alarmFiring = true;
	TimeManagerClockButton.checkAlarm = false;

	-- do a bunch of crazy stuff to get the player's attention
	if ( gsub(Settings.alarmMessage, "%s", "") ~= "" ) then
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(Settings.alarmMessage, info.r, info.g, info.b, info.id);
		RaidNotice_AddMessage(RaidWarningFrame, Settings.alarmMessage, ChatTypeInfo["RAID_WARNING"]);
	end
	PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_2);
	UIFrameFlash(TimeManagerAlarmFiredTexture, 0.5, 0.5, -1);
	-- show the clock if necessary, but record its current state so it can return to that state after
	-- the player turns the alarm off
	TimeManagerClockButton.prevShown = TimeManagerClockButton:IsShown();
	TimeManagerClockButton:Show();
end

function TimeManager_TurnOffAlarm()
	UIFrameFlashStop(TimeManagerAlarmFiredTexture);
	if ( not TimeManagerClockButton.prevShown ) then
		TimeManagerClockButton:Hide();
	end

	TimeManagerClockButton.alarmFiring = false;
end

function TimeManager_IsAlarmFiring()
	return TimeManagerClockButton.alarmFiring;
end

function TimeManagerClockButton_UpdateTooltip()
	GameTooltip:ClearLines();

	if ( TimeManagerClockButton.alarmFiring ) then
		if ( gsub(Settings.alarmMessage, "%s", "") ~= "" ) then
			GameTooltip:AddLine(Settings.alarmMessage, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
			GameTooltip:AddLine(" ");
		end
		GameTooltip:AddLine(TIMEMANAGER_ALARM_TOOLTIP_TURN_OFF);
	else
		GameTime_UpdateTooltip();
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(GAMETIME_TOOLTIP_TOGGLE_CLOCK);
	end

	-- readjust tooltip size
	GameTooltip:Show();
end

-- StopwatchFrame

function Stopwatch_Toggle()
	if ( StopwatchFrame:IsShown() ) then
		StopwatchFrame:Hide();
	else
		StopwatchFrame:Show();
	end
end

function Stopwatch_StartCountdown(hour, minute, second)
	local sec = 0;
	if ( hour ) then
		sec = hour * 3600;
	end
	if ( minute ) then
		sec = sec + minute * 60;
	end
	if ( second ) then
		sec = sec + second;
	end
	if ( sec == 0 ) then
		Stopwatch_Toggle();
		return;
	end
	if ( sec > MAX_TIMER_SEC ) then
		StopwatchTicker.timer = MAX_TIMER_SEC;
	elseif ( sec < 0 ) then
		StopwatchTicker.timer = 0;
	else
		StopwatchTicker.timer = sec;
	end
	StopwatchTicker_Update();
	StopwatchTicker.reverse = sec > 0;
	StopwatchFrame:Show();
end

function Stopwatch_Play()
	if ( StopwatchPlayPauseButton.playing ) then
		return;
	end
	StopwatchPlayPauseButton.playing = true;
	StopwatchTicker:SetScript("OnUpdate", StopwatchTicker_OnUpdate);
	StopwatchPlayPauseButton:SetNormalTexture("Interface\\TimeManager\\PauseButton");
end

function Stopwatch_Pause()
	if ( not StopwatchPlayPauseButton.playing ) then
		return;
	end
	StopwatchPlayPauseButton.playing = false;
	StopwatchTicker:SetScript("OnUpdate", nil);
	StopwatchPlayPauseButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
end

function Stopwatch_IsPlaying()
	return StopwatchPlayPauseButton.playing;
end

function Stopwatch_Clear()
	StopwatchTicker.timer = 0;
	StopwatchTicker.reverse = false;
	StopwatchTicker:SetScript("OnUpdate", nil);
	StopwatchTicker_Update();
	StopwatchPlayPauseButton.playing = false;
	StopwatchPlayPauseButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
end

function Stopwatch_FinishCountdown()
	Stopwatch_Clear();
	PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3);
end

function StopwatchCloseButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
	StopwatchFrame:Hide();
end

function StopwatchFrame_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("PLAYER_LOGOUT");
	self:RegisterForDrag("LeftButton");
	StopwatchTabFrame:SetAlpha(0);
	Stopwatch_Clear();
end

function StopwatchFrame_OnEvent(self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		local name = ...;
		if ( name == "Blizzard_TimeManager" ) then
			if ( not BlizzardStopwatchOptions ) then
				BlizzardStopwatchOptions = {};
			end

			if ( BlizzardStopwatchOptions.position ) then
				StopwatchFrame:ClearAllPoints();
				StopwatchFrame:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", BlizzardStopwatchOptions.position.x, BlizzardStopwatchOptions.position.y);
				StopwatchFrame:SetUserPlaced(true);
			else
				StopwatchFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -250, -300);
			end
		end
	elseif ( event == "PLAYER_LOGOUT" ) then
		if ( StopwatchFrame:IsUserPlaced() ) then
			if ( not BlizzardStopwatchOptions.position ) then
				BlizzardStopwatchOptions.position = {};
			end
			BlizzardStopwatchOptions.position.x, BlizzardStopwatchOptions.position.y = StopwatchFrame:GetCenter();
			StopwatchFrame:SetUserPlaced(false);
		else
			BlizzardStopwatchOptions.position = nil;
		end
	end
end

function StopwatchFrame_OnUpdate(self)
	if ( self.prevMouseIsOver ) then
		if ( not self:IsMouseOver() ) then
			UIFrameFadeOut(StopwatchTabFrame, CHAT_FRAME_FADE_TIME);
			self.prevMouseIsOver = false;
		end
	else
		if ( self:IsMouseOver() ) then
			UIFrameFadeIn(StopwatchTabFrame, CHAT_FRAME_FADE_TIME);
			self.prevMouseIsOver = true;
		end
	end
end

function StopwatchFrame_OnShow(self)
	TimeManagerStopwatchCheck:SetChecked(true);
end

function StopwatchFrame_OnHide(self)
	UIFrameFadeRemoveFrame(StopwatchTabFrame);
	StopwatchTabFrame:SetAlpha(0);
	self.prevMouseIsOver = false;
	TimeManagerStopwatchCheck:SetChecked(false);
end

function StopwatchFrame_OnMouseDown(self)
	self:SetScript("OnUpdate", nil);
end

function StopwatchFrame_OnMouseUp(self)
	self:SetScript("OnUpdate", StopwatchFrame_OnUpdate);
end

function StopwatchFrame_OnDragStart(self)
	self:StartMoving();
end

function StopwatchFrame_OnDragStop(self)
	StopwatchFrame_OnMouseUp(self);		-- OnMouseUp won't fire if OnDragStart fired after OnMouseDown
	self:StopMovingOrSizing();
end

function StopwatchTicker_OnUpdate(self, elapsed)
	if ( self.reverse ) then
		self.timer = self.timer - elapsed;
		if ( self.timer <= 0 ) then
			Stopwatch_FinishCountdown();
			return;
		end
	else
		self.timer = self.timer + elapsed;
	end
	StopwatchTicker_Update();
end

function StopwatchTicker_Update()
	local timer = StopwatchTicker.timer;
	local hour = min(floor(timer*SEC_TO_HOUR_FACTOR), 99);
	local minute = mod(timer*SEC_TO_MINUTE_FACTOR, 60);
	local second = mod(timer, 60);
	StopwatchTickerHour:SetFormattedText(STOPWATCH_TIME_UNIT, hour);
	StopwatchTickerMinute:SetFormattedText(STOPWATCH_TIME_UNIT, minute);
	StopwatchTickerSecond:SetFormattedText(STOPWATCH_TIME_UNIT, second);
end

function StopwatchResetButton_OnClick()
	Stopwatch_Clear();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
end

function StopwatchPlayPauseButton_OnClick(self)
	if ( self.playing ) then
		Stopwatch_Pause();
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	else
		Stopwatch_Play();
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end
