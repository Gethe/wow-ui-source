
CalendarUtil = {};

function CalendarUtil.GetCalendarInviteStatusInfo(inviteStatus)
	return CALENDAR_INVITESTATUS_INFO[inviteStatus] or CALENDAR_INVITESTATUS_INFO["UNKNOWN"];
end
