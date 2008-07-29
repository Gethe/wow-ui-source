
local GAMETIME_DAWN = ( 5 * 60) + 30;		-- 5:30 AM
local GAMETIME_DUSK = (21 * 60) +  0;		-- 9:00 PM

-- general GameTime functions
function GameTime_GetFormattedTime(hour, minute, wantAMPM)
	if ( GetCVar("timeMgrUseMilitaryTime") == "1" ) then
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

function GameTime_GetLocalTime(wantAMPM)
	local dateInfo = date("*t");
	local hour, minute = dateInfo.hour, dateInfo.min;
	return GameTime_GetFormattedTime(hour, minute, wantAMPM), hour, minute;
end

function GameTime_GetGameTime(wantAMPM)
	local hour, minute = GetGameTime();
	return GameTime_GetFormattedTime(hour, minute, wantAMPM), hour, minute;
end

function GameTime_GetTime(showAMPM)
	if( GetCVar("timeMgrUseLocalTime") == "1" ) then
		return GameTime_GetLocalTime(showAMPM);
	else
		return GameTime_GetGameTime(showAMPM);
	end
end

function GameTime_UpdateTooltip()
	--GameTooltip:SetText(GameTime_Text(hour, minute));
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
	self:RegisterForClicks("AnyDown");
	self.timeOfDay = 0;
	self:SetFrameLevel(self:GetFrameLevel() + 2);
	GameTimeFrame_Update(self);
end

function GameTimeFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
end

function GameTimeFrame_Update(self)
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
		GameTimeTexture:SetTexCoord(minx, maxx, miny, maxy);
	end
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:ClearLines();
		if ( not TimeManagerClockButton or not TimeManagerClockButton:IsVisible() or TimeManager_IsAlarmFiring() ) then
			GameTime_UpdateTooltip();
			GameTooltip:AddLine(" ");
		end
		GameTooltip:AddLine(TIMEMANAGER_TOOLTIP_TOGGLE_CLOCK_SETTINGS);
		GameTooltip:Show();
	end
end

function GameTimeFrame_OnClick(self, button)
	ToggleTimeManager();
end

