
GAMETIME_DAWN = ( 5 * 60) + 30;		-- 5:30 AM
GAMETIME_DUSK = (21 * 60) +  0;		-- 9:00 PM

local GAMETIME_DAWN = ( 5 * 60) + 30;		-- 5:30 AM
local GAMETIME_DUSK = (21 * 60) +  0;		-- 9:00 PM


local date = date;
local format = format;
local GetCVarBool = GetCVarBool;
local tonumber = tonumber;

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

-- GameTime_ComputeStandardTime assumes the given time is military (24 hour)
function GameTime_ComputeStandardTime(hour)
	if ( hour > 12 ) then
		return hour - 12, GAMETIME_PM;
	elseif ( hour == 0 ) then
		return 12, GAMETIME_AM;
	else
		return hour, GAMETIME_AM;
	end
end

-- GameTime_ComputeMilitaryTime assumes the given time is standard (12 hour)
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
	if ( GetCVarBool("timeMgrUseLocalTime") ) then
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

function GameTimeFrame_Update(self, elapsed)
	local hour, minute = GetGameTime();
	local time = (hour * 60) + minute;
	if(time ~= self.timeOfDay) then
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

		if(GameTooltip:IsOwned(self)) then
			GameTimeFrame_UpdateTooltip(hour, minute);
		end
	end
end

function GameTimeFrame_UpdateTooltip(self, hours, minutes)
	if ( GetCVarBool("timeMgrUseMilitaryTime") ) then
		GameTooltip:SetText(format(TIME_TWENTYFOURHOURS, hours, minutes));
	else
		local pm = 0;
		if(hours >= 12) then
			pm = 1;
		end
		if(hours > 12) then
			hours = hours - 12;
		end
		if(hours == 0) then
			hours = 12;
		end
		if(pm == 0) then
			GameTooltip:SetText(format(TIME_TWELVEHOURAM, hours, minutes));
		else
			GameTooltip:SetText(format(TIME_TWELVEHOURPM, hours, minutes));
		end
	end
end
