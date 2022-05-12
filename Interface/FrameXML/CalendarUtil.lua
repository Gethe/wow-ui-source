
CalendarUtil = {};

function CalendarUtil.FormatCalendarTimeWeekday(messageDate)
	return FULLDATE_NO_YEAR:format(CALENDAR_WEEKDAY_NAMES[messageDate.weekday], CALENDAR_FULLDATE_MONTH_NAMES[messageDate.month], messageDate.monthDay);
end

function CalendarUtil.AreDatesEqual(firstCalendarTime, secondCalendarTime)
	return firstCalendarTime.month == secondCalendarTime.month and
			firstCalendarTime.monthDay == secondCalendarTime.monthDay and
			firstCalendarTime.year == secondCalendarTime.year;
end
