
GAMETIME_AM = true;
GAMETIME_PM = false;

local GAMETIME_DAWN = ( 5 * 60) + 30;		-- 5:30 AM
local GAMETIME_DUSK = (21 * 60) +  0;		-- 9:00 PM

local _G = getfenv(0);
local date = _G.date;
local getglobal = _G.getglobal;
local format = _G.format;


-- general GameTime functions
function GameTime_GetFormattedTime(hour, minute, wantAMPM)
	if ( GetCVarBool("timeMgrUseMilitaryTime") ) then
		return format(TIMEMANAGER_TICKER_24HOUR, hour, minute);
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
			return format(timeFormat, hour, minute);
		else
			if ( hour == 0 ) then
				hour = 12;
			elseif ( hour > 12 ) then
				hour = hour - 12;
			end
			return format(TIMEMANAGER_TICKER_12HOUR, hour, minute);
		end
	end
end

function GameTime_ComputeMinutes(hour, minute, militaryTime, am)
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

-- GameTime_ComputeStandardTime assumes the given time is military
function GameTime_ComputeStandardTime(hour)
	if ( hour > 12 ) then
		return hour - 12, GAMETIME_PM;
	elseif ( hour == 0 ) then
		return 12, GAMETIME_AM;
	else
		return hour, GAMETIME_AM;
	end
end

-- GameTime_ComputeMilitaryTime assumes the given time is standard
function GameTime_ComputeMilitaryTime(hour, am)
	if ( am and hour == 12 ) then
		return 0;
	elseif ( not am and hour < 12 ) then
		return hour + 12;
	else
		return hour;
	end
end

function GameTime_GetLocalTime(wantAMPM)
	local hour, minute = tonumber(date("%H")), tonumber(date("%M"));
	return GameTime_GetFormattedTime(hour, minute, wantAMPM), hour, minute;
end

function GameTime_GetGameTime(wantAMPM)
	local hour, minute = GetGameTime();
	return GameTime_GetFormattedTime(hour, minute, wantAMPM), hour, minute;
end

function GameTime_GetTime(showAMPM)
	if( GetCVarBool("timeMgrUseLocalTime") ) then
		return GameTime_GetLocalTime(showAMPM);
	else
		return GameTime_GetGameTime(showAMPM);
	end
end

function GameTime_UpdateTooltip()
	-- title
	GameTooltip:AddLine(TIMEMANAGER_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	-- realm time
	GameTooltip:AddDoubleLine(
		TIMEMANAGER_TOOLTIP_REALMTIME,
		GameTime_GetGameTime(true),
		NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
		HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	-- local time
	GameTooltip:AddDoubleLine(
		TIMEMANAGER_TOOLTIP_LOCALTIME,
		GameTime_GetLocalTime(true),
		NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
		HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
end


-- GameTimeFrame functions

function GameTimeFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES");
	self:RegisterEvent("CALENDAR_EVENT_ALARM");
	self:RegisterForClicks("AnyUp");

	-- adjust button texture layers to not interfere with overlaid textures
	local tex;
	tex = self:GetNormalTexture();
	tex:SetDrawLayer("BACKGROUND");
	tex = self:GetPushedTexture();
	tex:SetDrawLayer("BACKGROUND");

	self:GetFontString():SetDrawLayer("BACKGROUND");

	self.timeOfDay = 0;
	self:SetFrameLevel(self:GetFrameLevel() + 2);
	self.pendingCalendarInvites = 0;
	self.hour = 0;
	GameTimeFrame_OnUpdate(self);
end

function GameTimeFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
end

function GameTimeFrame_OnEvent(self, event, ...)
	if ( event == "CALENDAR_UPDATE_PENDING_INVITES" or event == "PLAYER_ENTERING_WORLD" ) then
		local pendingCalendarInvites = CalendarGetNumPendingInvites();
		if ( pendingCalendarInvites > self.pendingCalendarInvites ) then
			if ( not CalendarFrame or (CalendarFrame and not CalendarFrame:IsShown()) ) then
				GameTimeCalendarInvitesTexture:Show();
				UIFrameFlash(GameTimeCalendarInvitesTexture, 1.0, 1.0, -1);
				self.pendingCalendarInvites = pendingCalendarInvites;
			end
		elseif ( pendingCalendarInvites == 0 ) then
				GameTimeCalendarInvitesTexture:Hide();
				UIFrameFlashStop(GameTimeCalendarInvitesTexture);
				self.pendingCalendarInvites = 0;
		end
		GameTimeFrame_SetDate();
	elseif ( event == "CALENDAR_EVENT_ALARM" ) then
		local title, hour, minute = ...;
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(format(CALENDAR_EVENT_ALARM_MESSAGE, title), info.r, info.g, info.b, info.id);
		--UIFrameFlash(GameTimeCalendarEventAlarmTexture, 1.0, 1.0, 6);
	end
end

function GameTimeFrame_OnUpdate(self, elapsed)
	local hour, minute = GetGameTime();
	local time = (hour * 60) + minute;
	if ( time ~= self.timeOfDay ) then
		self.timeOfDay = time;
		local minx = 0;
		local maxx = 50/128;
		local miny = 0;
		local maxy = 50/64;
		if(time < GAMETIME_DAWN or time >= GAMETIME_DUSK) then
			minx = minx + 0.5;
			maxx = maxx + 0.5;
		end
		if ( hour ~= self.hour ) then
			self.hour = hour;
			GameTimeFrame_SetDate();
		end
		GameTimeTexture:SetTexCoord(minx, maxx, miny, maxy);
	end
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:ClearLines();
		if ( GameTimeCalendarInvitesTexture:IsShown() ) then
			GameTooltip:AddLine(GAMETIME_TOOLTIP_CALENDAR_INVITES);
			if ( CalendarFrame and not CalendarFrame:IsShown() ) then
				GameTooltip:AddLine(" ");
				GameTooltip:AddLine(GAMETIME_TOOLTIP_TOGGLE_CALENDAR);
			end
		else
			if ( not TimeManagerClockButton or not TimeManagerClockButton:IsVisible() or TimeManager_IsAlarmFiring() ) then
				GameTooltip:AddLine(GameTime_GetGameTime(true), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				GameTooltip:AddLine(" ");
			end
			GameTooltip:AddLine(GAMETIME_TOOLTIP_TOGGLE_CALENDAR);
		end
		GameTooltip:Show();
	end
end

function GameTimeFrame_OnClick(self)
	if ( GameTimeCalendarInvitesTexture:IsShown() ) then
		Calendar_LoadUI();
		if ( Calendar_Show ) then
			Calendar_Show();
		end
		GameTimeCalendarInvitesTexture:Hide();
		self.pendingCalendarInvites = 0;
		UIFrameFlashStop(GameTimeCalendarInvitesTexture);
	else
		ToggleCalendar();
	end
end

function GameTimeFrame_SetDate()
	local _, _, day = CalendarGetDate();
	GameTimeFrame:SetText(day);
end

