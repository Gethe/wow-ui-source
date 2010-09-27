
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
	Settings[field] = value;
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

	UIDropDownMenu_Initialize(TimeManagerAlarmHourDropDown, TimeManagerAlarmHourDropDown_Initialize);
	UIDropDownMenu_SetWidth(TimeManagerAlarmHourDropDown, 30, 40);

	UIDropDownMenu_Initialize(TimeManagerAlarmMinuteDropDown, TimeManagerAlarmMinuteDropDown_Initialize);
	UIDropDownMenu_SetWidth(TimeManagerAlarmMinuteDropDown, 30, 40);

	UIDropDownMenu_Initialize(TimeManagerAlarmAMPMDropDown, TimeManagerAlarmAMPMDropDown_Initialize);
	-- some languages have long am/pm strings so we may have to readjust the ampm dropdown width plus do some reanchoring if the text is too wide
	local maxAMPMWidth;
	TimeManagerAMPMDummyText:SetText(TIMEMANAGER_AM);
	maxAMPMWidth = TimeManagerAMPMDummyText:GetWidth();
	TimeManagerAMPMDummyText:SetText(TIMEMANAGER_PM);
	if ( maxAMPMWidth < TimeManagerAMPMDummyText:GetWidth() ) then
		maxAMPMWidth = TimeManagerAMPMDummyText:GetWidth();
	end
	maxAMPMWidth = ceil(maxAMPMWidth);
	if ( maxAMPMWidth > 40 ) then
		UIDropDownMenu_SetWidth(TimeManagerAlarmAMPMDropDown, maxAMPMWidth + 20, 40);
		TimeManagerAlarmAMPMDropDown:SetScript("OnShow", TimeManagerAlarmAMPMDropDown_OnShow);
		TimeManagerAlarmAMPMDropDown:SetScript("OnHide", TimeManagerAlarmAMPMDropDown_OnHide);
	else
		UIDropDownMenu_SetWidth(TimeManagerAlarmAMPMDropDown, 40, 40);
	end

	TimeManager_Update();
end

function TimeManagerFrame_OnUpdate(self, elapsed)
	TimeManager_UpdateTimeTicker();
end

function TimeManagerFrame_OnShow(self)
	TimeManager_Update();
	TimeManagerStopwatchCheck:SetChecked(StopwatchFrame:IsShown());
	PlaySound("igCharacterInfoOpen");
end

function TimeManagerFrame_OnHide(self)
	PlaySound("igCharacterInfoClose");
end

function TimeManagerCloseButton_OnClick()
	TimeManagerFrame:Hide();
end

function TimeManagerStopwatchCheck_OnClick(self)
	Stopwatch_Toggle();
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuQuit");
	end
end

function TimeManagerAlarmHourDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	local alarmHour = Settings.alarmHour;
	local militaryTime = Settings.militaryTime;

	local hourMin, hourMax;
	if ( militaryTime ) then
		hourMin = 0;
		hourMax = 23;
	else
		hourMin = 1;
		hourMax = 12;
	end
	for hour = hourMin, hourMax, 1 do
		info.value = hour;
		if ( militaryTime ) then
			info.text = format(TIMEMANAGER_24HOUR, hour);
		else
			info.text = hour;
			info.justifyH = "RIGHT";
		end
		info.func = TimeManagerAlarmHourDropDown_OnClick;
		if ( hour == alarmHour ) then
			info.checked = 1;
			UIDropDownMenu_SetText(TimeManagerAlarmHourDropDown, info.text);
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function TimeManagerAlarmMinuteDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	local alarmMinute = Settings.alarmMinute;
	for minute = 0, 55, 5 do
		info.value = minute;
		info.text = format(TIMEMANAGER_MINUTE, minute);
		info.func = TimeManagerAlarmMinuteDropDown_OnClick;
		if ( minute == alarmMinute ) then
			info.checked = 1;
			UIDropDownMenu_SetText(TimeManagerAlarmMinuteDropDown, info.text);
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function TimeManagerAlarmAMPMDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	local pm = (Settings.militaryTime and Settings.alarmHour >= 12) or not Settings.alarmAM;

	info.value = 1;
	info.text = TIMEMANAGER_AM;
	info.func = TimeManagerAlarmAMPMDropDown_OnClick;
	if ( not pm ) then
		info.checked = 1;
		UIDropDownMenu_SetText(TimeManagerAlarmAMPMDropDown, info.text);
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.value = 0;
	info.text = TIMEMANAGER_PM;
	info.func = TimeManagerAlarmAMPMDropDown_OnClick;
	if ( pm ) then
		info.checked = 1;
		UIDropDownMenu_SetText(TimeManagerAlarmAMPMDropDown, info.text);
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);
end

function TimeManagerAlarmHourDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(TimeManagerAlarmHourDropDown, self.value);
	local oldValue = Settings.alarmHour;
	Settings.alarmHour = self.value;
	if ( Settings.alarmHour ~= oldValue ) then
		TimeManager_StartCheckingAlarm();
	end
	_TimeManager_Setting_SetTime();
end

function TimeManagerAlarmMinuteDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(TimeManagerAlarmMinuteDropDown, self.value);
	local oldValue = Settings.alarmMinute;
	Settings.alarmMinute = self.value;
	if ( Settings.alarmMinute ~= oldValue ) then
		TimeManager_StartCheckingAlarm();
	end
	_TimeManager_Setting_SetTime();
end

function TimeManagerAlarmAMPMDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(TimeManagerAlarmAMPMDropDown, self.value);
	if ( self.value == 1 ) then
		if ( not Settings.alarmAM ) then
			Settings.alarmAM = true;
			TimeManager_StartCheckingAlarm();
		end
	else
		if ( Settings.alarmAM ) then
			Settings.alarmAM = false;
			TimeManager_StartCheckingAlarm();
		end
	end
	_TimeManager_Setting_SetTime();
end

function TimeManagerAlarmAMPMDropDown_OnShow()
	-- readjust the size of and reanchor TimeManagerAlarmAMPMDropDown and all frames below it
	TimeManagerAlarmAMPMDropDown:SetPoint("TOPLEFT", TimeManagerAlarmHourDropDown, "BOTTOMLEFT", 0, 5);
	TimeManagerAlarmMessageFrame:SetPoint("TOPLEFT", TimeManagerAlarmHourDropDown, "BOTTOMLEFT", 20, -23);
	TimeManagerAlarmEnabledButton:SetPoint("CENTER", TimeManagerFrame, "CENTER", -20, -69);
	TimeManagerMilitaryTimeCheck:SetPoint("TOPLEFT", TimeManagerFrame, "TOPLEFT", 174, -207);
end

function TimeManagerAlarmAMPMDropDown_OnHide()
	-- readjust the size of and reanchor TimeManagerAlarmAMPMDropDown and all frames below it
	TimeManagerAlarmAMPMDropDown:SetPoint("LEFT", TimeManagerAlarmHourDropDown, "RIGHT", -22, 0);
	TimeManagerAlarmMessageFrame:SetPoint("TOPLEFT", TimeManagerAlarmHourDropDown, "BOTTOMLEFT", 20, 0);
	TimeManagerAlarmEnabledButton:SetPoint("CENTER", TimeManagerFrame, "CENTER", -20, -50);
	TimeManagerMilitaryTimeCheck:SetPoint("TOPLEFT", TimeManagerFrame, "TOPLEFT", 174, -207);
end

function TimeManager_Update()
	TimeManager_UpdateTimeTicker();
	TimeManager_UpdateAlarmTime();
	TimeManagerAlarmEnabledButton_Update();
	TimeManagerAlarmMessageEditBox:SetText(Settings.alarmMessage);
	TimeManagerMilitaryTimeCheck:SetChecked(Settings.militaryTime);
	TimeManagerLocalTimeCheck:SetChecked(Settings.localTime);
end

function TimeManager_UpdateAlarmTime()
	UIDropDownMenu_SetSelectedValue(TimeManagerAlarmHourDropDown, Settings.alarmHour);
	UIDropDownMenu_SetSelectedValue(TimeManagerAlarmMinuteDropDown, Settings.alarmMinute);
	UIDropDownMenu_SetText(TimeManagerAlarmMinuteDropDown, format(TIMEMANAGER_MINUTE, Settings.alarmMinute));
	if ( Settings.militaryTime ) then
		TimeManagerAlarmAMPMDropDown:Hide();
		UIDropDownMenu_SetText(TimeManagerAlarmHourDropDown, format(TIMEMANAGER_24HOUR, Settings.alarmHour));
	else
		TimeManagerAlarmAMPMDropDown:Show();
		UIDropDownMenu_SetText(TimeManagerAlarmHourDropDown, Settings.alarmHour);
		if ( Settings.alarmAM ) then
			UIDropDownMenu_SetSelectedValue(TimeManagerAlarmAMPMDropDown, 1);
			UIDropDownMenu_SetText(TimeManagerAlarmAMPMDropDown, TIMEMANAGER_AM);
		else
			UIDropDownMenu_SetSelectedValue(TimeManagerAlarmAMPMDropDown, 0);
			UIDropDownMenu_SetText(TimeManagerAlarmAMPMDropDown, TIMEMANAGER_PM);
		end
	end
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

function TimeManagerAlarmEnabledButton_Update()
	if ( Settings.alarmEnabled ) then
		TimeManagerAlarmEnabledButton:SetText(TIMEMANAGER_ALARM_ENABLED);
		TimeManagerAlarmEnabledButton:SetNormalFontObject(GameFontNormal);
		TimeManagerAlarmEnabledButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up");
		TimeManagerAlarmEnabledButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down");
	else
		TimeManagerAlarmEnabledButton:SetText(TIMEMANAGER_ALARM_DISABLED);
		TimeManagerAlarmEnabledButton:SetNormalFontObject(GameFontHighlight);
		TimeManagerAlarmEnabledButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Disabled");
		TimeManagerAlarmEnabledButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Disabled-Down");
	end
end

function TimeManagerAlarmEnabledButton_OnClick(self)
	_TimeManager_Setting_SetBool(CVAR_ALARM_ENABLED, "alarmEnabled", not Settings.alarmEnabled);
	if ( Settings.alarmEnabled ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		TimeManager_StartCheckingAlarm();
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
		if ( TimeManagerClockButton.alarmFiring ) then
			TimeManager_TurnOffAlarm();
		end
	end
	TimeManagerAlarmEnabledButton_Update();
end

function TimeManagerMilitaryTimeCheck_OnClick(self)
	TimeManager_ToggleTimeFormat();
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
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
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
end

function TimeManager_ToggleLocalTime()
	_TimeManager_Setting_SetBool(CVAR_USE_LOCAL_TIME, "localTime", not Settings.localTime);
	-- TimeManagerFrame_OnUpdate will pick up the time ticker change
	-- TimeManagerClockButton_OnUpdate will pick up the clock change
end

-- TimeManagerClockButton
function TimeManagerClockButton_OnLoad(self)
	self:SetFrameLevel(self:GetFrameLevel() + 2);
	TimeManagerClockButton_Update();
	if ( Settings.alarmEnabled ) then
		TimeManager_StartCheckingAlarm();
	end
	self:RegisterForClicks("AnyUp");
end

function TimeManagerClockButton_Update()
	TimeManagerClockTicker:SetText(GameTime_GetTime(false));
end

function TimeManagerClockButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	TimeManagerClockButton:SetScript("OnUpdate", TimeManagerClockButton_OnUpdateWithTooltip);
end

function TimeManagerClockButton_OnLeave(self)
	GameTooltip:Hide();
	TimeManagerClockButton:SetScript("OnUpdate", TimeManagerClockButton_OnUpdate);
end

function TimeManagerClockButton_OnClick(self)
	if ( self.alarmFiring ) then
		PlaySound("igMainMenuQuit");
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

	PlaySound("AlarmClockWarning1");
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
	PlaySound("AlarmClockWarning2");
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
			GameTooltip:AddLine(Settings.alarmMessage, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
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
	PlaySound("AlarmClockWarning3");
end

function StopwatchCloseButton_OnClick()
	PlaySound("igMainMenuQuit");
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
	TimeManagerStopwatchCheck:SetChecked(1);
end

function StopwatchFrame_OnHide(self)
	UIFrameFadeRemoveFrame(StopwatchTabFrame);
	StopwatchTabFrame:SetAlpha(0);
	self.prevMouseIsOver = false;
	TimeManagerStopwatchCheck:SetChecked(nil);
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
	PlaySound("igMainMenuOptionCheckBoxOff");
end

function StopwatchPlayPauseButton_OnClick(self)
	if ( self.playing ) then
		Stopwatch_Pause();
		PlaySound("igMainMenuOptionCheckBoxOff");
	else
		Stopwatch_Play();
		PlaySound("igMainMenuOptionCheckBoxOn");
	end
end

