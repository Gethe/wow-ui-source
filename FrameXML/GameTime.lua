
GAMETIME_DAWN = ( 5 * 60) + 30;		-- 5:30 AM
GAMETIME_DUSK = (21 * 60) +  0;		-- 9:00 PM

function GameTimeFrame_Update()
	local hour, minute = GetGameTime();
	local time = (hour * 60) + minute;
	if(time ~= this.timeOfDay) then
		this.timeOfDay = time;
		local minx = 0;
		local maxx = 50/128;
		local miny = 0;
		local maxy = 50/64;
		if(time < GAMETIME_DAWN or time >= GAMETIME_DUSK) then
			minx = minx + 0.5;
			maxx = maxx + 0.5;
		end
		GameTimeTexture:SetTexCoord(minx, maxx, miny, maxy);

		if(GameTooltip:IsOwned(this)) then
			GameTimeFrame_UpdateTooltip(hour, minute);
		end
	end
end

function GameTimeFrame_UpdateTooltip(hours, minutes)
	if(TwentyFourHourTime) then
		GameTooltip:SetText(format(TEXT(TIME_TWENTYFOURHOURS), hours, minutes));
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
			GameTooltip:SetText(format(TEXT(TIME_TWELVEHOURAM), hours, minutes));
		else
			GameTooltip:SetText(format(TEXT(TIME_TWELVEHOURPM), hours, minutes));
		end
	end
end

function GameTime_GetTime()
	local hour, minute = GetGameTime();

	if(TwentyFourHourTime) then
		return format(TEXT(TIME_TWENTYFOURHOURS), hour, minute);
	else
		local pm = 0;
		if(hour >= 12) then
			pm = 1;
		end
		if(hour > 12) then
			hour = hour - 12;
		end
		if(hour == 0) then
			hour = 12;
		end
		if(pm == 0) then
			return format(TEXT(TIME_TWELVEHOURAM), hour, minute);
		else
			return format(TEXT(TIME_TWELVEHOURPM), hour, minute);
		end
	end
end
