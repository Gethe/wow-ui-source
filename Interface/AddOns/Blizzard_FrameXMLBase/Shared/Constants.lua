MAX_RAID_MEMBERS = 40;
NUM_RAID_GROUPS = 8;
MEMBERS_PER_RAID_GROUP = 5;

CALENDAR_INVITESTATUS_INFO = {
	["UNKNOWN"] = {
		name		= UNKNOWN,
		color		= NORMAL_FONT_COLOR,
	},
	[Enum.CalendarStatus.Confirmed] = {
		name		= CALENDAR_STATUS_CONFIRMED,
		color		= GREEN_FONT_COLOR,
	},
	[Enum.CalendarStatus.Available] = {
		name		= CALENDAR_STATUS_ACCEPTED,
		color		= GREEN_FONT_COLOR,
	},
	[Enum.CalendarStatus.Declined] = {
		name		= CALENDAR_STATUS_DECLINED,
		color		= RED_FONT_COLOR,
	},
	[Enum.CalendarStatus.Out] = {
		name		= CALENDAR_STATUS_OUT,
		color		= RED_FONT_COLOR,
	},
	[Enum.CalendarStatus.Standby] = {
		name		= CALENDAR_STATUS_STANDBY,
		color		= ORANGE_FONT_COLOR,
	},
	[Enum.CalendarStatus.Invited] = {
		name		= CALENDAR_STATUS_INVITED,
		color		= NORMAL_FONT_COLOR,
	},
	[Enum.CalendarStatus.Signedup] = {
		name		= CALENDAR_STATUS_SIGNEDUP,
		color		= GREEN_FONT_COLOR,
	},
	[Enum.CalendarStatus.NotSignedup] = {
		name		= CALENDAR_STATUS_NOT_SIGNEDUP,
		color		= GRAY_FONT_COLOR,
	},
	[Enum.CalendarStatus.Tentative] = {
		name		= CALENDAR_STATUS_TENTATIVE,
		color		= ORANGE_FONT_COLOR,
	},
};