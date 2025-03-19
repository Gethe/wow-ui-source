
CalendarUtil = {};

function CalendarUtil.GetCalendarInviteStatusInfo(inviteStatus)
	return CALENDAR_INVITESTATUS_INFO[inviteStatus] or CALENDAR_INVITESTATUS_INFO["UNKNOWN"];
end

local function InternalGetEventBroadcastText(event, ongoing)
	local startTime = GameTime_GetFormattedTime(event.startTime.hour, event.startTime.minute, true);
	local inviteStatusInfo = CalendarUtil.GetCalendarInviteStatusInfo(event.inviteStatus);
	local eventIndexInfo = C_Calendar.GetEventIndexInfo(event.eventID, nil, event.monthDay);
	local eventLinkText = GetCalendarEventLink(eventIndexInfo.offsetMonths, eventIndexInfo.monthDay, eventIndexInfo.eventIndex);
	local eventLink = LINK_FONT_COLOR:WrapTextInColorCode(COMMUNITIES_CALENDAR_CHAT_EVENT_TITLE_FORMAT:format(eventLinkText));
	local inviteStatus = inviteStatusInfo.color:WrapTextInColorCode(inviteStatusInfo.name);
	local eventTime = nil;
	if ongoing then
		eventTime = YELLOW_FONT_COLOR:WrapTextInColorCode(COMMUNITIES_CALENDAR_ONGOING_EVENT_PREFIX);
	else
		local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
		local weekday = currentCalendarTime.weekday == event.startTime.weekday and COMMUNITIES_CALENDAR_TODAY or CALENDAR_WEEKDAY_NAMES[event.startTime.weekday];
		eventTime = YELLOW_FONT_COLOR:WrapTextInColorCode(COMMUNITIES_CALENDAR_EVENT_FORMAT:format(weekday, startTime));
	end
	return COMMUNITIES_CALENDAR_CHAT_EVENT_BROADCAST_FORMAT:format(eventTime, eventLink, inviteStatus);
end

function CalendarUtil.GetEventBroadcastText(event)
	local ongoing = false;
	return InternalGetEventBroadcastText(event, ongoing);
end

function CalendarUtil.GetOngoingEventBroadcastText(event)
	local ongoing = true;
	return InternalGetEventBroadcastText(event, ongoing);
end

function CalendarUtil.FormatCalendarTimeWeekday(messageDate)
	return FULLDATE_NO_YEAR:format(CALENDAR_WEEKDAY_NAMES[messageDate.weekday], CALENDAR_FULLDATE_MONTH_NAMES[messageDate.month], messageDate.monthDay);
end

function CalendarUtil.AreDatesEqual(firstCalendarTime, secondCalendarTime)
	return firstCalendarTime.month == secondCalendarTime.month and
			firstCalendarTime.monthDay == secondCalendarTime.monthDay and
			firstCalendarTime.year == secondCalendarTime.year;
end
