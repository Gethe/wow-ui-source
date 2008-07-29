
-- speed optimizations (mostly so update functions are faster)
local _G = getfenv(0);
local date = _G.date;
local abs = _G.abs;
local min = _G.min;
local max = _G.max;
local floor = _G.floor;
local mod = _G.mod;
local tonumber = _G.tonumber;
local GetCVar = _G.GetCVar;
local SetCVar = _G.SetCVar;
local GetGameTime = _G.GetGameTime;

-- private data
local SEC_TO_MINUTE_FACTOR = 1/60;
local SEC_TO_HOUR_FACTOR = SEC_TO_MINUTE_FACTOR*SEC_TO_MINUTE_FACTOR;

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


local function _TimeManager_GetTimeAndFormat(hour, minute, wantAMPM)
	if ( Settings.militaryTime ) then
		return TIMEMANAGER_TICKER_24HOUR, hour, minute;
	else
		if ( wantAMPM ) then
			local timeFormat = TIME_TWELVEHOURAM;
			if ( hour == 0 ) then
				hour = 12;
			elseif ( hour == 12 ) then
				timeFormat = TIME_TWELVEHOURPM;
			elseif ( hour > 12 ) then
				timeFormat = TIME_TWELVEHOURPM;
				hour = hour - 12;
			end
			return timeFormat, hour, minute;
		else
			if ( hour == 0 ) then
				hour = 12;
			elseif ( hour == 12 ) then
				timeFormat = TIME_TWELVEHOURPM;
			elseif ( hour > 12 ) then
				hour = hour - 12;
			end
			return TIMEMANAGER_TICKER_12HOUR, hour, minute;
		end
	end
end

local function _TimeManager_GetLocalTime(wantAMPM)
	local dateInfo = date("*t");
	local hour, minute = dateInfo.hour, dateInfo.min;
	return _TimeManager_GetTimeAndFormat(hour, minute, wantAMPM);
end

local function _TimeManager_GetGameTime(wantAMPM)
	local hour, minute = GetGameTime();
	return _TimeManager_GetTimeAndFormat(hour, minute, wantAMPM);
end

local function _TimeManager_ComputeMinutes(hour, minute, militaryTime, am)
	local minutes;
	if ( militaryTime ) then
		minutes = minute + hour*60;
	else
		local h = hour;
		if ( am ) then
			if ( h == 12 ) then
				h = 0;
			end
		else
			if ( h ~= 12 ) then
				h = h + 12;
			end
		end
		minutes = minute + h*60;
	end
	return minutes;
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
	local alarmTime = _TimeManager_ComputeMinutes(Settings.alarmHour, Settings.alarmMinute, Settings.militaryTime, Settings.alarmAM);
	SetCVar(CVAR_ALARM_TIME, alarmTime);
end


-- TimeManagerFrame

function TimeManager_Show()
	TimeManagerClockButton:Show();
end

function TimeManager_Hide()
	TimeManagerFrame:Hide();
	TimeManagerClockButton:Hide();
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
	UIDropDownMenu_SetWidth(30, TimeManagerAlarmHourDropDown, 40);

	UIDropDownMenu_Initialize(TimeManagerAlarmMinuteDropDown, TimeManagerAlarmMinuteDropDown_Initialize);
	UIDropDownMenu_SetWidth(30, TimeManagerAlarmMinuteDropDown, 40);

	UIDropDownMenu_Initialize(TimeManagerAlarmAMPMDropDown, TimeManagerAlarmAMPMDropDown_Initialize);
	-- some languages have ridonculously long am/pm strings (i'm looking at you French) so we may have to
	-- readjust the ampm dropdown width plus do some reanchoring if the text is too wide
	local maxAMPMWidth;
	TimeManagerAMPMDummyText:SetText(TIMEMANAGER_AM);
	maxAMPMWidth = TimeManagerAMPMDummyText:GetWidth();
	TimeManagerAMPMDummyText:SetText(TIMEMANAGER_PM);
	if ( maxAMPMWidth < TimeManagerAMPMDummyText:GetWidth() ) then
		maxAMPMWidth = TimeManagerAMPMDummyText:GetWidth();
	end
	maxAMPMWidth = ceil(maxAMPMWidth);
	if ( maxAMPMWidth > 40 ) then
		UIDropDownMenu_SetWidth(maxAMPMWidth + 20, TimeManagerAlarmAMPMDropDown, 40);
		TimeManagerAlarmAMPMDropDown:SetScript("OnShow", TimeManagerAlarmAMPMDropDown_OnShow);
		TimeManagerAlarmAMPMDropDown:SetScript("OnHide", TimeManagerAlarmAMPMDropDown_OnHide);
	else
		UIDropDownMenu_SetWidth(40, TimeManagerAlarmAMPMDropDown, 40);
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
		PlaySound("igMainMenuOptionCheckBoxOff");
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
			UIDropDownMenu_SetText(info.text, TimeManagerAlarmHourDropDown);
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
			UIDropDownMenu_SetText(info.text, TimeManagerAlarmMinuteDropDown);
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
		UIDropDownMenu_SetText(info.text, TimeManagerAlarmAMPMDropDown);
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.value = 0;
	info.text = TIMEMANAGER_PM;
	info.func = TimeManagerAlarmAMPMDropDown_OnClick;
	if ( pm ) then
		info.checked = 1;
		UIDropDownMenu_SetText(info.text, TimeManagerAlarmAMPMDropDown);
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);
end

function TimeManagerAlarmHourDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(TimeManagerAlarmHourDropDown, this.value);
	if ( Settings.alarmHour ~= this.value ) then
		TimeManagerClockButton.checkAlarm = true;
	end
	Settings.alarmHour = this.value;
	_TimeManager_Setting_SetTime();
end

function TimeManagerAlarmMinuteDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(TimeManagerAlarmMinuteDropDown, this.value);
	if ( Settings.alarmMinute ~= this.value ) then
		TimeManagerClockButton.checkAlarm = true;
	end
	Settings.alarmMinute = this.value;
	_TimeManager_Setting_SetTime();
end

function TimeManagerAlarmAMPMDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(TimeManagerAlarmAMPMDropDown, this.value);
	if ( this.value == 1 ) then
		if ( not Settings.alarmAM ) then
			TimeManagerClockButton.checkAlarm = true;
			Settings.alarmAM = true;
		end
	else
		if ( Settings.alarmAM ) then
			TimeManagerClockButton.checkAlarm = true;
			Settings.alarmAM = false;
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
	UIDropDownMenu_SetText(format(TIMEMANAGER_MINUTE, Settings.alarmMinute), TimeManagerAlarmMinuteDropDown);
	if ( Settings.militaryTime ) then
		TimeManagerAlarmAMPMDropDown:Hide();
		UIDropDownMenu_SetText(format(TIMEMANAGER_24HOUR, Settings.alarmHour), TimeManagerAlarmHourDropDown);
	else
		TimeManagerAlarmAMPMDropDown:Show();
		UIDropDownMenu_SetText(Settings.alarmHour, TimeManagerAlarmHourDropDown);
		if ( Settings.alarmAM ) then
			UIDropDownMenu_SetSelectedValue(TimeManagerAlarmAMPMDropDown, 1);
			UIDropDownMenu_SetText(TIMEMANAGER_AM, TimeManagerAlarmAMPMDropDown);
		else
			UIDropDownMenu_SetSelectedValue(TimeManagerAlarmAMPMDropDown, 0);
			UIDropDownMenu_SetText(TIMEMANAGER_PM, TimeManagerAlarmAMPMDropDown);
		end
	end
end

function TimeManager_UpdateTimeTicker()
	if ( Settings.localTime ) then
		TimeManagerFrameTicker:SetFormattedText(_TimeManager_GetLocalTime());
	else
		TimeManagerFrameTicker:SetFormattedText(_TimeManager_GetGameTime());
	end
end

function TimeManagerAlarmMessageEditBox_OnEnterPressed(self)
	self:ClearFocus();
end

function TimeManagerAlarmMessageEditBox_OnEscapePressed(self)
	TimeManagerAlarmMessageEditBox:SetText(Settings.alarmMessage);
	self:ClearFocus();
end

function TimeManagerAlarmMessageEditBox_OnEditFocusLost(self)
	_TimeManager_Setting_Set(CVAR_ALARM_MESSAGE, "alarmMessage", TimeManagerAlarmMessageEditBox:GetText());
end

function TimeManagerAlarmEnabledButton_Update()
	if ( Settings.alarmEnabled ) then
		TimeManagerAlarmEnabledButton:SetText(TIMEMANAGER_ALARM_ENABLED);
		TimeManagerAlarmEnabledButton:SetTextFontObject("GameFontNormal");
		TimeManagerAlarmEnabledButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up");
		TimeManagerAlarmEnabledButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down");
	else
		TimeManagerAlarmEnabledButton:SetText(TIMEMANAGER_ALARM_DISABLED);
		TimeManagerAlarmEnabledButton:SetTextFontObject("GameFontHighlight");
		TimeManagerAlarmEnabledButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Disabled");
		TimeManagerAlarmEnabledButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Disabled-Down");
	end
end

function TimeManagerAlarmEnabledButton_OnClick(self)
	_TimeManager_Setting_SetBool(CVAR_ALARM_ENABLED, "alarmEnabled", not Settings.alarmEnabled);
	if ( Settings.alarmEnabled ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		TimeManagerClockButton.checkAlarm = true;
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
end

function TimeManager_ToggleTimeFormat()
	local alarmHour = Settings.alarmHour;
	if ( Settings.militaryTime ) then
		_TimeManager_Setting_SetBool(CVAR_USE_MILITARY_TIME, "militaryTime", false);
		if ( alarmHour > 12 ) then
			Settings.alarmHour = alarmHour - 12;
			Settings.alarmAM = false;
		elseif ( alarmHour == 12 ) then
			Settings.alarmAM = false;
		elseif ( alarmHour == 0 ) then
			Settings.alarmHour = 12;
			Settings.alarmAM = true;
		else
			Settings.alarmAM = true;
		end
	else
		_TimeManager_Setting_SetBool(CVAR_USE_MILITARY_TIME, "militaryTime", true);
		if ( Settings.alarmAM ) then
			if ( alarmHour == 12 ) then
				Settings.alarmHour = 0;
			end
		else
			if ( alarmHour ~= 12 ) then
				Settings.alarmHour = alarmHour + 12;
			end
		end
	end
	_TimeManager_Setting_SetTime();
	TimeManager_UpdateAlarmTime();
	-- TimeManagerFrame_OnUpdate will pick up the time ticker change
	-- TimeManagerClockButton_OnUpdate will pick up the clock change
end

function TimeManagerLocalTimeCheck_OnClick(self)
	TimeManager_ToggleLocalTime();
	TimeManagerClockButton.checkAlarm = true;
end

function TimeManager_ToggleLocalTime()
	_TimeManager_Setting_SetBool(CVAR_USE_LOCAL_TIME, "localTime", not Settings.localTime);
	-- TimeManagerFrame_OnUpdate will pick up the time ticker change
	-- TimeManagerClockButton_OnUpdate will pick up the clock change
end

-- TimeManagerClockButton

function TimeManagerClockButton_Show()
	TimeManagerClockButton:Show();
end

function TimeManagerClockButton_Hide()
	TimeManagerClockButton:Hide();
end

function TimeManager_Toggle()
	if ( TimeManagerFrame:IsShown() ) then
		TimeManagerFrame:Hide();
	else
		TimeManagerFrame:Show();
	end
end

function TimeManagerClockButton_Update()
	if ( Settings.localTime ) then
		TimeManagerClockTicker:SetFormattedText(_TimeManager_GetLocalTime());
	else
		TimeManagerClockTicker:SetFormattedText(_TimeManager_GetGameTime());
	end
end

function TimeManagerClockButton_OnEnter(self)
	if ( Minimap:IsShown() ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	else
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	end
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
		TimeManager_CheckAlarm(self, elapsed);
	end
end

function TimeManagerClockButton_OnUpdateWithTooltip(self, elapsed)
	TimeManagerClockButton_OnUpdate(self, elapsed);
	TimeManagerClockButton_UpdateTooltip();
end

function TimeManager_CheckAlarm()
	local currTime;
	if ( Settings.localTime ) then
		local dateInfo = date("*t");
		local hour, minute = dateInfo.hour, dateInfo.min;
		currTime = minute + hour*60;
	else
		local hour, minute = GetGameTime();
		currTime = minute + hour*60;
	end

	local alarmTime = _TimeManager_ComputeMinutes(Settings.alarmHour, Settings.alarmMinute, Settings.militaryTime, Settings.alarmAM);

	if ( currTime == alarmTime ) then
		TimeManager_FireAlarm();
		TimeManagerClockButton.checkAlarm = false;
	end
end

function TimeManager_FireAlarm()
	TimeManagerClockButton.alarmFiring = true;

	DEFAULT_CHAT_FRAME:AddMessage(Settings.alarmMessage);
	PlaySound("PVPTHROUGHQUEUE");
	UIFrameFlash(TimeManagerAlarmFiredTexture, 0.5, 0.5, -1);
end

function TimeManager_TurnOffAlarm()
	UIFrameFlashStop(TimeManagerAlarmFiredTexture);

	TimeManagerClockButton.alarmFiring = false;
end

function TimeManagerClockButton_UpdateTooltip()
	GameTooltip:ClearLines();

	if ( TimeManagerClockButton.alarmFiring ) then
		GameTooltip:AddLine(Settings.alarmMessage, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(TIMEMANAGER_ALARM_TOOLTIP_TURN_OFF);
	else
		-- title
		GameTooltip:AddLine(TIMEMANAGER_CLOCK_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		-- realm time
		local realmFormatString, realmHour, realmMinute = _TimeManager_GetGameTime(true);
		GameTooltip:AddDoubleLine(
			TIMEMANAGER_CLOCK_TOOLTIP_REALMTIME,
			format(realmFormatString, realmHour, realmMinute),
			NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		-- local time (only shown if there is a 10 min delta between realm time and local time)
		local localFormatString, localHour, localMinute = _TimeManager_GetLocalTime(true);
		GameTooltip:AddDoubleLine(
			TIMEMANAGER_CLOCK_TOOLTIP_LOCALTIME,
			format(localFormatString, localHour, localMinute),
			NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end

	-- readjust tooltip size
	GameTooltip:Show();
end

function TimeManagerClockButton_AdjustPosition()
	if ( Minimap:IsShown() ) then
		TimeManagerClockButton:SetPoint("CENTER", MinimapCluster, "CENTER", 8, -72);
	else
		TimeManagerClockButton:SetPoint("CENTER", MinimapCluster, "CENTER", 75, 20);
	end
end

-- StopwatchFrame

function Stopwatch_Toggle()
	if ( StopwatchFrame:IsShown() ) then
		StopwatchFrame:Hide();
	else
		StopwatchFrame:Show();
	end
end

function Stopwatch_ShowCountdown(hour, minute, second)
	local sec = 0;
	if ( hour ) then
		sec = hour * 60 * 60;
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
	StopwatchTicker.timer = sec;
	StopwatchTicker_Update();
	StopwatchTicker.reverse = sec > 0;
	StopwatchFrame:Show();
end

function StopwatchCloseButton_OnClick()
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
		if ( not MouseIsOver(self, 20, -8, -8, 20) ) then
			UIFrameFadeOut(StopwatchTabFrame, CHAT_FRAME_FADE_TIME);
			self.prevMouseIsOver = false;
		end
	else
		if ( MouseIsOver(self, 20, -8, -8, 20) ) then
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
			Stopwatch_Clear();
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

function Stopwatch_Play()
	StopwatchPlayPauseButton.playing = true;
	StopwatchTicker:SetScript("OnUpdate", StopwatchTicker_OnUpdate);
	StopwatchPlayPauseButton:SetNormalTexture("Interface\\TimeManager\\PauseButton");
end

function Stopwatch_Pause()
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

function StopwatchResetButton_OnClick()
	Stopwatch_Clear();
end

function StopwatchPlayPauseButton_OnClick(self)
	if ( self.playing ) then
		Stopwatch_Pause();
	else
		Stopwatch_Play();
	end
end

