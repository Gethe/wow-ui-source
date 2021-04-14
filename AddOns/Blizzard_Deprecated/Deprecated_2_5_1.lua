
-- These are functions are deprecated, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- 8.1.0 deprecations related to C_DateAndTime
do
	local function ConvertToOldStyleDate(calendarTime)
		calendarTime.weekDay = calendarTime.weekday;
		calendarTime.day = calendarTime.monthDay;
		calendarTime.minute = nil;
		calendarTime.hour = nil;
		calendarTime.monthDay = nil;
		calendarTime.weekday = nil;
		return calendarTime;
	end

	-- Use C_DateAndTime.GetCalendarTimeFromEpoch() instead.
	C_DateAndTime.GetDateFromEpoch = function(epoch)
		local currentCalendarTime = C_DateAndTime.GetCalendarTimeFromEpoch(epoch);
		return ConvertToOldStyleDate(currentCalendarTime);
	end

	-- Use C_DateAndTime.GetCurrentCalendarTime() instead.
	C_DateAndTime.GetTodaysDate = function()
		local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
		return ConvertToOldStyleDate(currentCalendarTime);
	end

	-- Use C_DateAndTime.GetCurrentCalendarTime() and C_DateAndTime.AdjustTimeByDays instead.
	C_DateAndTime.GetYesterdaysDate = function()
		local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
		currentCalendarTime = C_DateAndTime.AdjustTimeByDays(currentCalendarTime, -1);
		return ConvertToOldStyleDate(currentCalendarTime);
	end
end