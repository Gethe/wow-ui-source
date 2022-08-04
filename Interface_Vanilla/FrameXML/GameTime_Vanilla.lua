GAMETIME_DAWN = ( 5 * 60) + 30;		-- 5:30 AM
GAMETIME_DUSK = (21 * 60) +  0;		-- 9:00 PM

local GAMETIME_DAWN = ( 5 * 60) + 30;		-- 5:30 AM
local GAMETIME_DUSK = (21 * 60) +  0;		-- 9:00 PM

local date = date;
local format = format;
local GetCVarBool = GetCVarBool;
local tonumber = tonumber;

-- General GameTime functions are currently defined GameTime_Shared.lua

-- GameTimeFrame functions

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
