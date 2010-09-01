
-- static popups
StaticPopupDialogs["CALENDAR_DELETE_EVENT"] = {
	text = "%s",
	button1 = OKAY,
	button2 = CANCEL,
	whileDead = 1,
	OnAccept = function (self)
		CalendarContextEventRemove();
	end,
	OnShow = function (self)
		CalendarFrame_PushModal(self);
	end,
	OnHide = function (self)
		CalendarFrame_PopModal();
	end,
	timeout = 0,
	hideOnEscape = 1,
	enterClicksFirstButton = 1,
};
StaticPopupDialogs["CALENDAR_ERROR"] = {
	text = CALENDAR_ERROR,
	button1 = OKAY,
	whileDead = 1,
	OnShow = function (self)
		--CalendarFrame_PushModal(self);
	end,
	OnHide = function (self)
		--CalendarFrame_PopModal();
	end,
	timeout = 0,
	showAlert = 1,
	hideOnEscape = 1,
	enterClicksFirstButton = 1,
};


-- UIParent integration
tinsert(UIMenus, "CalendarContextMenu");
UIPanelWindows["CalendarFrame"] = { area = "doublewide", pushable = 0, width = 840,	whileDead = 1, yOffset = 20 };

-- CalendarMenus is an ORDERED table of frames, one of which will close when you press Escape.
local CalendarMenus = {
	"CalendarEventPickerFrame",
	"CalendarTexturePickerFrame",
	"CalendarMassInviteFrame",
	"CalendarCreateEventFrame",
	"CalendarViewEventFrame",
	"CalendarViewHolidayFrame",
	"CalendarViewRaidFrame"
};
-- this function will attempt to close the first open menu in the CalendarMenus table
function CloseCalendarMenus()
	for _, menuName in next, CalendarMenus do
		local menu = _G[menuName];
		if ( menu and menu:IsShown() ) then
			if ( menu == CalendarFrame_GetEventFrame() ) then
				CalendarFrame_CloseEvent();
				PlaySound("igMainMenuQuit");
			else
				menu:Hide();
			end
			return true;
		end
	end
	return false;
end


-- tab handling
CALENDAR_CREATEEVENTFRAME_TAB_LIST = {
	"CalendarCreateEventTitleEdit",
	"CalendarCreateEventDescriptionEdit",
	"CalendarCreateEventInviteEdit",
};


-- speed optimizations
local next = next;
local date = date;
local abs = abs;
local min = min;
local max = max;
local floor = floor;
local mod = mod;
local tonumber = tonumber;
local random = random;
local format = format;
local select = select;
local tinsert = tinsert;
local band = bit.band;
local cos = math.cos;
local strtrim = strtrim;
local GetCVarBool = GetCVarBool;
local PI = PI;
local TWOPI = PI * 2.0;

-- dev constants
CALENDAR_USE_SEQUENCE_FOR_EVENT_TEXTURE		= true;
CALENDAR_USE_SEQUENCE_FOR_OVERLAY_TEXTURE	= false;

-- local constants
local CALENDAR_MAX_DAYS_PER_MONTH			= 42;		-- 6 weeks
local CALENDAR_MAX_DARKDAYS_PER_MONTH		= 14;		-- max days from the previous and next months when viewing the current month

-- Weekday constants
local CALENDAR_WEEKDAY_NORMALIZED_TEX_LEFT		= 0.0;
local CALENDAR_WEEKDAY_NORMALIZED_TEX_TOP		= 180 / 256;
local CALENDAR_WEEKDAY_NORMALIZED_TEX_WIDTH		= 90 / 256 - 0.001; -- fudge factor to prevent texture seams
local CALENDAR_WEEKDAY_NORMALIZED_TEX_HEIGHT	= 28 / 256 - 0.001; -- fudge factor to prevent texture seams

-- DayButton constants
local CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH	= 90 / 256 - 0.001; -- fudge factor to prevent texture seams
local CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT	= 90 / 256 - 0.001; -- fudge factor to prevent texture seams
local CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS		= 4;
local CALENDAR_DAYBUTTON_MAX_VISIBLE_BIGEVENTS	= 2;
local CALENDAR_DAYBUTTON_MAX_TOOLTIP_EVENTS		= 30;
local CALENDAR_DAYBUTTON_SELECTION_ALPHA		= 1.0;
local CALENDAR_DAYBUTTON_HIGHLIGHT_ALPHA		= 0.5;

-- DayEventButton constants
local CALENDAR_DAYEVENTBUTTON_HEIGHT	= 12;
local CALENDAR_DAYEVENTBUTTON_BIGHEIGHT	= 24;
local CALENDAR_DAYEVENTBUTTON_XOFFSET	= 4;
local CALENDAR_DAYEVENTBUTTON_YOFFSET	= -3;

-- ContextMenu flags
local CALENDAR_CONTEXTMENU_FLAG_SHOWDAY			= 0x01;
local CALENDAR_CONTEXTMENU_FLAG_SHOWEVENT		= 0x02;

-- CreateEventFrame constants
local CALENDAR_CREATEEVENTFRAME_DEFAULT_TITLE			= CALENDAR_EVENT_NAME;
local CALENDAR_CREATEEVENTFRAME_DEFAULT_DESCRIPTION		= CALENDAR_EVENT_DESCRIPTION;
local CALENDAR_CREATEEVENTFRAME_DEFAULT_TYPE			= CALENDAR_EVENTTYPE_OTHER;
local CALENDAR_CREATEEVENTFRAME_DEFAULT_REPEAT_OPTION	= 1;
local CALENDAR_CREATEEVENTFRAME_DEFAULT_HOUR			= 12;		-- default is standard (not military) time
local CALENDAR_CREATEEVENTFRAME_DEFAULT_MINUTE			= 0;
local CALENDAR_CREATEEVENTFRAME_DEFAULT_AM				= true;
local CALENDAR_CREATEEVENTFRAME_DEFAULT_AUTOAPPROVE		= nil;
local CALENDAR_CREATEEVENTFRAME_DEFAULT_LOCK			= nil;

-- ViewEventFrame constants
local CALENDAR_VIEWEVENTFRAME_EVENT_RSVPBUTTON_WIDTH		= 128;
local CALENDAR_VIEWEVENTFRAME_GUILDEVENT_RSVPBUTTON_WIDTH	= 94;
local CALENDAR_VIEWEVENTFRAME_EVENT_INVITELIST_HEIGHT		= 230;
local CALENDAR_VIEWEVENTFRAME_GUILDEVENT_INVITELIST_HEIGHT	= 250;

-- dark flags
local DARKFLAG_PREVMONTH			= 0x0001;
local DARKFLAG_NEXTMONTH			= 0x0002;
local DARKFLAG_CORNER				= 0x0004;
local DARKFLAG_SIDE_LEFT			= 0x0008;
local DARKFLAG_SIDE_RIGHT			= 0x0010;
local DARKFLAG_SIDE_TOP				= 0x0020;
local DARKFLAG_SIDE_BOTTOM			= 0x0040;
-- top flags
local DARKFLAG_PREVMONTH_TOP				= DARKFLAG_PREVMONTH + DARKFLAG_SIDE_TOP;
local DARKFLAG_PREVMONTH_TOPLEFT			= DARKFLAG_PREVMONTH_TOP + DARKFLAG_SIDE_LEFT;
local DARKFLAG_PREVMONTH_TOPRIGHT			= DARKFLAG_PREVMONTH_TOP + DARKFLAG_SIDE_RIGHT;
local DARKFLAG_PREVMONTH_TOPLEFTRIGHT		= DARKFLAG_PREVMONTH_TOPLEFT + DARKFLAG_SIDE_RIGHT;
local DARKFLAG_NEXTMONTH_TOP				= DARKFLAG_NEXTMONTH + DARKFLAG_SIDE_TOP;
local DARKFLAG_NEXTMONTH_TOPLEFT			= DARKFLAG_NEXTMONTH_TOP + DARKFLAG_SIDE_LEFT;
local DARKFLAG_NEXTMONTH_TOPRIGHT			= DARKFLAG_NEXTMONTH_TOP + DARKFLAG_SIDE_RIGHT;
-- corner flags
local DARKFLAG_NEXTMONTH_CORNER				= DARKFLAG_NEXTMONTH + DARKFLAG_CORNER;							-- day 8 of next month
local DARKFLAG_NEXTMONTH_CORNER_TOP			= DARKFLAG_NEXTMONTH_CORNER + DARKFLAG_SIDE_TOP;				-- day 7 of next month
local DARKFLAG_NEXTMONTH_CORNER_RIGHT		= DARKFLAG_NEXTMONTH_CORNER + DARKFLAG_SIDE_RIGHT;				-- day 8 of next month, index 42
local DARKFLAG_NEXTMONTH_CORNER_TOPLEFT		= DARKFLAG_NEXTMONTH_CORNER_TOP + DARKFLAG_SIDE_LEFT;			-- day 1 of next month
local DARKFLAG_NEXTMONTH_CORNER_TOPLEFTRIGHT	= DARKFLAG_NEXTMONTH_CORNER_TOPLEFT + DARKFLAG_SIDE_RIGHT;	-- day 1 of next month, 7th day of the week
-- bottom flags
local DARKFLAG_PREVMONTH_BOTTOM				= DARKFLAG_PREVMONTH + DARKFLAG_SIDE_BOTTOM;
local DARKFLAG_PREVMONTH_BOTTOMLEFT			= DARKFLAG_PREVMONTH_BOTTOM + DARKFLAG_SIDE_LEFT;
local DARKFLAG_PREVMONTH_BOTTOMRIGHT		= DARKFLAG_PREVMONTH_BOTTOM + DARKFLAG_SIDE_RIGHT;
local DARKFLAG_PREVMONTH_BOTTOMLEFTRIGHT	= DARKFLAG_PREVMONTH_BOTTOMLEFT + DARKFLAG_SIDE_RIGHT;
local DARKFLAG_NEXTMONTH_BOTTOM				= DARKFLAG_NEXTMONTH + DARKFLAG_SIDE_BOTTOM;
local DARKFLAG_NEXTMONTH_BOTTOMLEFT			= DARKFLAG_NEXTMONTH_BOTTOM + DARKFLAG_SIDE_LEFT;
local DARKFLAG_NEXTMONTH_BOTTOMRIGHT		= DARKFLAG_NEXTMONTH_BOTTOM + DARKFLAG_SIDE_RIGHT;
local DARKFLAG_NEXTMONTH_BOTTOMLEFTRIGHT	= DARKFLAG_NEXTMONTH_BOTTOMLEFT + DARKFLAG_SIDE_RIGHT;
local DARKFLAG_NEXTMONTH_LEFTRIGHT			= DARKFLAG_NEXTMONTH + DARKFLAG_SIDE_LEFT + DARKFLAG_SIDE_RIGHT; -- day 1 of next month, 7th day of the week, not index 42
-- shared flags
local DARKFLAG_NEXTMONTH_LEFT				= DARKFLAG_NEXTMONTH + DARKFLAG_SIDE_LEFT;
local DARKFLAG_NEXTMONTH_RIGHT				= DARKFLAG_NEXTMONTH + DARKFLAG_SIDE_RIGHT;
-- the dark day tcoord tables simplify tex coord setup for dark days
local DARKDAY_TOP_TCOORDS = {
	[DARKFLAG_PREVMONTH_TOP] = {
		left	= 90 / 512,
		right	= 180 / 512,
		top		= 0.0,
		bottom	= 45 / 256,
	},
	[DARKFLAG_PREVMONTH_TOPLEFT] = {
		left	= 0.0,
		right	= 90 / 512,
		top		= 0.0,
		bottom	= 45 / 256 - 0.001,		-- fudge factor to prevent texture seams
	},
	[DARKFLAG_PREVMONTH_TOPRIGHT] = {
		left	= 90 / 512,
		right	= 0.0,
		top		= 0.0,
		bottom	= 45 / 256 - 0.001,		-- fudge factor to prevent texture seams
	},
	[DARKFLAG_PREVMONTH_TOPLEFTRIGHT] = {
		left	= 0.0,
		right	= 90 / 512,
		top		= 180 / 256,
		bottom	= 225 / 256 - 0.001,	-- fudge factor to prevent texture seams
	},

	-- next 3 are same as DARKDAY_BOTTOM_TCOORDS (blank, left, right--no difference between top & bottom)
	[DARKFLAG_NEXTMONTH] = {	-- no drop shadowing
		left	= 90 / 512,
		right	= 180 / 512,
		top		= 45 / 256,
		bottom	= 90 / 256,
	},
	[DARKFLAG_NEXTMONTH_LEFT] = {
		left	= 90 / 512,
		right	= 0.0,
		top		= 90 / 256,
		bottom	= 135 / 256,
	},
	[DARKFLAG_NEXTMONTH_RIGHT] = {
		left	= 0.0,
		right	= 90 / 512,
		top		= 90 / 256,
		bottom	= 135 / 256 - 0.001,	-- fudge factor to prevent texture seams
	},

	[DARKFLAG_NEXTMONTH_TOP] = {
		left	= 90 / 512,
		right	= 180 / 512,
		top		= 0.0,
		bottom	= 45 / 256,
	},
	[DARKFLAG_NEXTMONTH_TOPLEFT] = {
		left	= 0.0,
		right	= 90 / 512,
		top		= 0.0,
		bottom	= 45 / 256 - 0.001,		-- fudge factor to prevent texture seams
	},
	[DARKFLAG_NEXTMONTH_TOPRIGHT] = {
		left	= 90 / 512,
		right	= 0.0,
		top		= 0.0,
		bottom	= 45 / 256 - 0.001,		-- fudge factor to prevent texture seams
	},

	-- day 8 of next month
	[DARKFLAG_NEXTMONTH_CORNER] = {
		left	= 90 / 512,
		right	= 180 / 512 - 0.001,	-- fudge factor to prevent texture seams
		top		= 135 / 256,
		bottom	= 180 / 256,
	},
	-- day 7 of next month
	[DARKFLAG_NEXTMONTH_CORNER_TOP] = {
		left	= 0.0,
		right	= 90 / 512,
		top		= 135 / 256,
		bottom	= 180 / 256 - 0.001,	-- fudge factor to prevent texture seams
	},
	-- day 8 of next month, index 42
	[DARKFLAG_NEXTMONTH_CORNER_RIGHT] = {
		left	= 180 / 512,
		right	= 270 / 512 - 0.001,	-- fudge factor to prevent texture seams
		top		= 45 / 256,
		bottom	= 90 / 256 - 0.001,		-- fudge factor to prevent texture seams
	},
	-- day 1 of next month
	[DARKFLAG_NEXTMONTH_CORNER_TOPLEFT] = {
		left	= 0.0,
		right	= 90 / 512,
		top		= 45 / 256,
		bottom	= 90 / 256,
	},
	-- day 1 of next month, 7th day of the week
	[DARKFLAG_NEXTMONTH_CORNER_TOPLEFTRIGHT] = {
		left	= 180 / 512,
		right	= 90 / 512,
		top		= 225 / 256,
		bottom	= 180 / 256,
	},
};
local DARKDAY_BOTTOM_TCOORDS = {
	[DARKFLAG_PREVMONTH_BOTTOM] = {
		left	= 90 / 512,
		right	= 180 / 512,
		top		= 45 / 256,
		bottom	= 0.0,
	},
	[DARKFLAG_PREVMONTH_BOTTOMLEFT] = {
		left	= 0.0,
		right	= 90 / 512,
		top		= 45 / 256 - 0.001,		-- fudge factor to prevent texture seams
		bottom	= 0.0,
	},
	[DARKFLAG_PREVMONTH_BOTTOMRIGHT] = {
		left	= 90 / 512,
		right	= 0.0,
		top		= 90 / 256,
		bottom	= 45 / 256,
	},
	[DARKFLAG_PREVMONTH_BOTTOMLEFTRIGHT] = {
		left	= 90 / 512,
		right	= 180 / 512,
		top		= 180 / 256,
		bottom	= 225 / 256,
	},

	-- next 3 are same as DARKDAY_TOP_TCOORDS (blank, left, right--no difference between top & bottom)
	[DARKFLAG_NEXTMONTH] = {	-- no drop shadowing
		left	= 90 / 512,
		right	= 180 / 512,
		top		= 45 / 256,
		bottom	= 90 / 256,
	},
	[DARKFLAG_NEXTMONTH_LEFT] = {
		left	= 90 / 512,
		right	= 0.0,
		top		= 90 / 256,
		bottom	= 135 / 256,
	},
	[DARKFLAG_NEXTMONTH_RIGHT] = {
		left	= 0.0,
		right	= 90 / 512,
		top		= 90 / 256,
		bottom	= 135 / 256,
	},

	[DARKFLAG_NEXTMONTH_BOTTOM] = {
		left	= 90 / 512,
		right	= 180 / 512,
		top		= 45 / 256,
		bottom	= 0.0,
	},
	[DARKFLAG_NEXTMONTH_BOTTOMLEFT] = {
		left	= 0.0,
		right	= 90 / 512,
		top		= 45 / 256 - 0.001,		-- fudge factor to prevent texture seams
		bottom	= 0.0,
	},
	[DARKFLAG_NEXTMONTH_BOTTOMRIGHT] = {
		left	= 90 / 512,
		right	= 0.0,
		top		= 45 / 256 - 0.001,		-- fudge factor to prevent texture seams
		bottom	= 0.0,
	},
	[DARKFLAG_NEXTMONTH_BOTTOMLEFTRIGHT] = {
		left	= 0.0,
		right	= 90 / 512,
		top		= 225 / 256,
		bottom	= 180 / 256,
	},

	-- day 1 of next month, 7th day of the week, not index 42
	[DARKFLAG_NEXTMONTH_LEFTRIGHT] = {
		left	= 180 / 512,
		right	= 270 / 512 - 0.001,	-- fudge factor to prevent texture seams
		top		= 0.0,
		bottom	= 45 / 256,
	},
};

-- more local constants
local CALENDAR_MONTH_NAMES = {
	MONTH_JANUARY,
	MONTH_FEBRUARY,
	MONTH_MARCH,
	MONTH_APRIL,
	MONTH_MAY,
	MONTH_JUNE,
	MONTH_JULY,
	MONTH_AUGUST,
	MONTH_SEPTEMBER,
	MONTH_OCTOBER,
	MONTH_NOVEMBER,
	MONTH_DECEMBER,
};

-- month names show up differently for full date displays in some languages
local CALENDAR_FULLDATE_MONTH_NAMES = {
	FULLDATE_MONTH_JANUARY,
	FULLDATE_MONTH_FEBRUARY,
	FULLDATE_MONTH_MARCH,
	FULLDATE_MONTH_APRIL,
	FULLDATE_MONTH_MAY,
	FULLDATE_MONTH_JUNE,
	FULLDATE_MONTH_JULY,
	FULLDATE_MONTH_AUGUST,
	FULLDATE_MONTH_SEPTEMBER,
	FULLDATE_MONTH_OCTOBER,
	FULLDATE_MONTH_NOVEMBER,
	FULLDATE_MONTH_DECEMBER,
};

local CALENDAR_EVENTCOLOR_MODERATOR = {r=0.54, g=0.75, b=1.0};

local CALENDAR_INVITESTATUS_INFO = {
	["UNKNOWN"] = {
		name		= UNKNOWN,
		color		= NORMAL_FONT_COLOR,
--		colorCode	= NORMAL_FONT_COLOR_CODE,
	},
	[CALENDAR_INVITESTATUS_CONFIRMED] = {
		name		= CALENDAR_STATUS_CONFIRMED,
		color		= GREEN_FONT_COLOR,
--		colorCode	= GREEN_FONT_COLOR_CODE,
	},
	[CALENDAR_INVITESTATUS_ACCEPTED] = {
		name		= CALENDAR_STATUS_ACCEPTED,
		color		= GREEN_FONT_COLOR,
--		colorCode	= GREEN_FONT_COLOR_CODE,
	},
	[CALENDAR_INVITESTATUS_DECLINED] = {
		name		= CALENDAR_STATUS_DECLINED,
		color		= RED_FONT_COLOR,
--		colorCode	= RED_FONT_COLOR_CODE,
	},
	[CALENDAR_INVITESTATUS_OUT] = {
		name		= CALENDAR_STATUS_OUT,
		color		= RED_FONT_COLOR,
--		colorCode	= RED_FONT_COLOR_CODE,
	},
	[CALENDAR_INVITESTATUS_STANDBY] = {
		name		= CALENDAR_STATUS_STANDBY,
		color		= ORANGE_FONT_COLOR,
--		colorCode	= ORANGE_FONT_COLOR_CODE,
	},
	[CALENDAR_INVITESTATUS_INVITED] = {
		name		= CALENDAR_STATUS_INVITED,
		color		= NORMAL_FONT_COLOR,
--		colorCode	= NORMAL_FONT_COLOR_CODE,
	},
	[CALENDAR_INVITESTATUS_SIGNEDUP] = {
		name		= CALENDAR_STATUS_SIGNEDUP,
		color		= GREEN_FONT_COLOR,
--		colorCode	= GREEN_FONT_COLOR_CODE,
	},
	[CALENDAR_INVITESTATUS_NOT_SIGNEDUP] = {
		name		= CALENDAR_STATUS_NOT_SIGNEDUP,
		color		= NORMAL_FONT_COLOR,
--		colorCode	= NORMAL_FONT_COLOR_CODE,
	},
	[CALENDAR_INVITESTATUS_TENTATIVE] = {
		name		= CALENDAR_STATUS_TENTATIVE,
		color		= ORANGE_FONT_COLOR,
--		colorCode	= ORANGE_FONT_COLOR_CODE,
	},
};

local CALENDAR_CALENDARTYPE_NAMEFORMAT = {
	["PLAYER"] = {
		[""]				= "%s",
	},
	["GUILD_ANNOUNCEMENT"] = {
		[""]				= "%s",
	},
	["GUILD_EVENT"] = {
		[""]				= "%s",
	},
	["SYSTEM"] = {
		[""]				= "%s",
	},
	["HOLIDAY"] = {
		["START"]			= CALENDAR_EVENTNAME_FORMAT_START,
		["END"]				= CALENDAR_EVENTNAME_FORMAT_END,
		[""]				= "%s",
	},
	["RAID_LOCKOUT"] = {
		[""]				= CALENDAR_EVENTNAME_FORMAT_RAID_LOCKOUT,
	},
	["RAID_RESET"] = {
		[""]				= CALENDAR_EVENTNAME_FORMAT_RAID_RESET,
	},
};
local CALENDAR_CALENDARTYPE_TEXTURE_PATHS = {
--	["PLAYER"]				= "",
--	["GUILD_ANNOUNCEMENT"]	= "",
--	["GUILD_EVENT"]			= "",
--	["SYSTEM"]				= "",
	["HOLIDAY"]				= "Interface\\Calendar\\Holidays\\",
--	["RAID_LOCKOUT"]		= "",
--	["RAID_RESET"]			= "",
};
local CALENDAR_CALENDARTYPE_TEXTURES = {
	["PLAYER"] = {
--		[""]				= "",
	},
	["GUILD_ANNOUNCEMENT"] = {
--		[""]				= "",
	},
	["GUILD_EVENT"] = {
--		[""]				= "",
	},
	["SYSTEM"] = {
--		[""]				= "",
	},
	["HOLIDAY"] = {
		["START"]			= "Interface\\Calendar\\Holidays\\Calendar_DefaultHoliday",
--		["ONGOING"]			= "",
		["END"]				= "Interface\\Calendar\\Holidays\\Calendar_DefaultHoliday",
		["INFO"]			= "Interface\\Calendar\\Holidays\\Calendar_DefaultHoliday",
--		[""]				= "",
	},
	["RAID_LOCKOUT"] = {
--		[""]				= "",
	},
	["RAID_RESET"] = {
--		[""]				= "",
	},
};
local CALENDAR_CALENDARTYPE_TEXTURE_APPEND = {
--	["PLAYER"] = {
--	},
--	["GUILD_ANNOUNCEMENT"] = {
--	},
--	["GUILD_EVENT"] = {
--	},
--	["SYSTEM"] = {
--	},
	["HOLIDAY"] = {
		["START"]			= "Start",
		["ONGOING"]			= "Ongoing",
		["END"]				= "End",
		["INFO"]			= "Info",
		[""]				= "",
	},
--	["RAID_LOCKOUT"] = {
--	},
--	["RAID_RESET"] = {
--	},
};
local CALENDAR_CALENDARTYPE_TCOORDS = {
	["PLAYER"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["GUILD_ANNOUNCEMENT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["GUILD_EVENT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["SYSTEM"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["HOLIDAY"] = {
		left	= 0.0,
		right	= 0.7109375,
		top		= 0.0,
		bottom	= 0.7109375,
	},
	["RAID_LOCKOUT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["RAID_RESET"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
};
local CALENDAR_CALENDARTYPE_COLORS = {
--	["PLAYER"]				= ,
--	["GUILD_ANNOUNCEMENT"]	= ,
--	["GUILD_EVENT"]			= ,
	["SYSTEM"]				= YELLOW_FONT_COLOR,
	["HOLIDAY"]				= HIGHLIGHT_FONT_COLOR,
	["RAID_LOCKOUT"]		= HIGHLIGHT_FONT_COLOR,
	["RAID_RESET"]			= HIGHLIGHT_FONT_COLOR,
};

local CALENDAR_EVENTTYPE_TEXTURE_PATHS = {
	[CALENDAR_EVENTTYPE_RAID]		= "Interface\\LFGFrame\\LFGIcon-",
	[CALENDAR_EVENTTYPE_DUNGEON]	= "Interface\\LFGFrame\\LFGIcon-",
--	[CALENDAR_EVENTTYPE_PVP]		= "",
--	[CALENDAR_EVENTTYPE_MEETING]	= "",
--	[CALENDAR_EVENTTYPE_OTHER]		= "",
};
local CALENDAR_EVENTTYPE_TEXTURES = {
	[CALENDAR_EVENTTYPE_RAID]		= "Interface\\LFGFrame\\LFGIcon-Raid",
	[CALENDAR_EVENTTYPE_DUNGEON]	= "Interface\\LFGFrame\\LFGIcon-Dungeon",
	[CALENDAR_EVENTTYPE_PVP]		= "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[CALENDAR_EVENTTYPE_MEETING]	= "Interface\\Calendar\\MeetingIcon",
	[CALENDAR_EVENTTYPE_OTHER]		= "Interface\\Calendar\\UI-Calendar-Event-Other",
};
local CALENDAR_EVENTTYPE_TCOORDS = {
	[CALENDAR_EVENTTYPE_RAID] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[CALENDAR_EVENTTYPE_DUNGEON] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[CALENDAR_EVENTTYPE_PVP] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[CALENDAR_EVENTTYPE_MEETING] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[CALENDAR_EVENTTYPE_OTHER] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
};
do
	-- set the pvp icon to the player's faction
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup ) then
		-- need new texcoords too?
		if ( factionGroup == "Alliance" ) then
			CALENDAR_EVENTTYPE_TEXTURES[CALENDAR_EVENTTYPE_PVP] = "Interface\\Calendar\\UI-Calendar-Event-PVP02";
		else
			CALENDAR_EVENTTYPE_TEXTURES[CALENDAR_EVENTTYPE_PVP] = "Interface\\Calendar\\UI-Calendar-Event-PVP01";
		end
	end
end

local CALENDAR_FILTER_CVARS = {
	{text = CALENDAR_FILTER_BATTLEGROUND,		cvar = "calendarShowBattlegrounds"	},
	{text = CALENDAR_FILTER_DARKMOON,			cvar = "calendarShowDarkmoon"		},
	{text = CALENDAR_FILTER_RAID_LOCKOUTS,		cvar = "calendarShowLockouts"		},
	{text = CALENDAR_FILTER_RAID_RESETS,		cvar = "calendarShowResets"			},
	{text = CALENDAR_FILTER_WEEKLY_HOLIDAYS,	cvar = "calendarShowWeeklyHolidays"	},
};

-- local data

-- CalendarDayButtons is just a table of all the Calendar day buttons...the size of this table should
-- equal CALENDAR_MAX_DAYS_PER_MONTH once the CalendarFrame is done loading
local CalendarDayButtons = { };

-- CalendarEventTextureCache gets updated whenever event type textures are requested (currently only
-- the Dungeon and Raid event types have texture lists)
local CalendarEventTextureCache = { };

-- CalendarClassData gets updated whenever the current event's invite list is updated
local CalendarClassData = { };
do
	for i, class in ipairs(CLASS_SORT_ORDER) do
		CalendarClassData[class] = {
			name = nil,
			tcoords = CLASS_ICON_TCOORDS[class],
			counts = {
				[CALENDAR_INVITESTATUS_INVITED]		= 0,
				[CALENDAR_INVITESTATUS_ACCEPTED]	= 0,
				[CALENDAR_INVITESTATUS_DECLINED]	= 0,
				[CALENDAR_INVITESTATUS_CONFIRMED]	= 0,
				[CALENDAR_INVITESTATUS_OUT]			= 0,
				[CALENDAR_INVITESTATUS_STANDBY]		= 0,
				[CALENDAR_INVITESTATUS_SIGNEDUP]	= 0,
				[CALENDAR_INVITESTATUS_NOT_SIGNEDUP]	= 0,
				[CALENDAR_INVITESTATUS_TENTATIVE]	= 0,
			},
		};
	end
end

-- CalendarModalStack is a stack of modal dialog frames. The reason why we use a stack (instead of a single
-- frame), for the modal system is because modal dialogs can stack on top of each other...for example,
-- try deleting an event from the event picker frame. The stack will have two elements: the bottom element
-- is the event picker frame and the top element is the delete confirmation popup.
local CalendarModalStack = { };


-- local helper functions

local function safeselect(index, ...)
	local count = select("#", ...);
	if ( count > 0 and index <= count ) then
		return select(index, ...);
	else
		return nil;
	end
end

local function _CalendarFrame_SafeGetName(name)
	if ( not name or name == "" ) then
		return UNKNOWN;
	end
	return name;
end

local function _CalendarFrame_GetDayOfWeek(index)
	return mod(index - 1, 7) + 1;
end

-- _CalendarFrame_GetWeekdayIndex takes an index in the range [1, n] and maps it to a weekday starting
-- at CALENDAR_FIRST_WEEKDAY. For example,
-- CALENDAR_FIRST_WEEKDAY = 1 => [SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY]
-- CALENDAR_FIRST_WEEKDAY = 2 => [MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY]
-- CALENDAR_FIRST_WEEKDAY = 6 => [FRIDAY, SATURDAY, SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY]
local function _CalendarFrame_GetWeekdayIndex(index)
	-- the expanded form for the left input to mod() is:
	-- (index - 1) + (CALENDAR_FIRST_WEEKDAY - 1)
	-- why the - 1 and then + 1 before return? because lua has 1-based indexes! awesome!
	return mod(index - 2 + CALENDAR_FIRST_WEEKDAY, 7) + 1;
end

local function _CalendarFrame_GetFullDate(weekday, month, day, year)
	local weekdayName = CALENDAR_WEEKDAY_NAMES[weekday];
	local monthName = CALENDAR_FULLDATE_MONTH_NAMES[month];
	return weekdayName, monthName, day, year, month;
end

local function _CalendarFrame_GetFullDateFromDay(dayButton)
	local weekday = _CalendarFrame_GetWeekdayIndex(dayButton:GetID());
	local month, year = CalendarGetMonth(dayButton.monthOffset);
	local day = dayButton.day;
	return _CalendarFrame_GetFullDate(weekday, month, day, year);
end

local function _CalendarFrame_IsTodayOrLater(month, day, year)
	local presentWeekday, presentMonth, presentDay, presentYear = CalendarGetDate();
	local todayOrLater = false;
	if ( year > presentYear ) then
		todayOrLater = true;
	elseif ( year == presentYear ) then
		if ( month > presentMonth ) then
			todayOrLater = true;
		elseif ( month == presentMonth ) then
			todayOrLater = day >= presentDay;
		end
	end
	return todayOrLater;
end

local function _CalendarFrame_IsAfterMaxCreateDate(month, day, year)
	local maxWeekday, maxMonth, maxDay, maxYear = CalendarGetMaxCreateDate();
	local afterMaxDate = false;
	if ( year > maxYear ) then
		afterMaxDate = true;
	elseif ( year == maxYear ) then
		if ( month > maxMonth ) then
			afterMaxDate = true;
		elseif ( month == maxMonth ) then
			afterMaxDate = day > maxDay;
		end
	end
	return afterMaxDate;
end

local function _CalendarFrame_IsPlayerCreatedEvent(calendarType)
	return
		calendarType == "PLAYER" or
		calendarType == "GUILD_ANNOUNCEMENT" or
		calendarType == "GUILD_EVENT";
end

local function _CalendarFrame_CanInviteeRSVP(inviteStatus)
	return
		inviteStatus == CALENDAR_INVITESTATUS_INVITED or
		inviteStatus == CALENDAR_INVITESTATUS_ACCEPTED or
		inviteStatus == CALENDAR_INVITESTATUS_DECLINED or
		inviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP or
		inviteStatus == CALENDAR_INVITESTATUS_NOT_SIGNEDUP or
		inviteStatus == CALENDAR_INVITESTATUS_TENTATIVE;
end

local function _CalendarFrame_IsSignUpEvent(calendarType, inviteType)
	return calendarType == "GUILD_EVENT" and inviteType == CALENDAR_INVITETYPE_SIGNUP;
end

local function _CalendarFrame_CanRemoveEvent(modStatus, calendarType, inviteType, inviteStatus)
	return
		modStatus ~= "CREATOR" and
		(calendarType == "PLAYER" or (calendarType == "GUILD_EVENT" and inviteType == CALENDAR_INVITETYPE_NORMAL));
end

local function _CalendarFrame_CacheEventTextures_Internal(...)
	local numTextures = select("#", ...) / 4;
	if ( numTextures <= 0 ) then
		CalendarEventTextureCache.eventType = nil;
		return false;
	end

	while ( #CalendarEventTextureCache > numTextures ) do
		tremove(CalendarEventTextureCache);
	end

	local param = 1;
	local cacheIndex = 1;
	for textureIndex = 1, numTextures do
		if ( not CalendarEventTextureCache[cacheIndex] ) then
			CalendarEventTextureCache[cacheIndex] = { };
		end

		-- insert texture
		CalendarEventTextureCache[cacheIndex].textureIndex = textureIndex;
		CalendarEventTextureCache[cacheIndex].title = select(param, ...);
		param = param + 1;
		CalendarEventTextureCache[cacheIndex].texture = select(param, ...);
		param = param + 1;
		CalendarEventTextureCache[cacheIndex].expansionLevel = select(param, ...);
		param = param + 1;
		CalendarEventTextureCache[cacheIndex].difficultyName = select(param, ...);
		param = param + 1;

		-- insert headers between expansion levels
		local entry = CalendarEventTextureCache[cacheIndex];
		local prevEntry = CalendarEventTextureCache[cacheIndex - 1];
		if ( not prevEntry or (prevEntry and prevEntry.expansionLevel ~= entry.expansionLevel) ) then
			-- insert empty entry...
			if ( prevEntry ) then
				--...only if we had a previous entry
				CalendarEventTextureCache[cacheIndex] = { };
				cacheIndex = cacheIndex + 1;
			end
			-- insert header
			CalendarEventTextureCache[cacheIndex] = {
				title = _G["EXPANSION_NAME"..entry.expansionLevel],
				expansionLevel = entry.expansionLevel,
			};
			cacheIndex = cacheIndex + 1;
			-- make the current entry the next entry
			CalendarEventTextureCache[cacheIndex] = entry;
		end

		cacheIndex = cacheIndex + 1;
	end
	return true;
end

local function _CalendarFrame_CacheEventTextures(eventType)
	if ( eventType ~= CalendarEventTextureCache.eventType ) then
		CalendarEventTextureCache.eventType = eventType
		if ( eventType ) then
			return _CalendarFrame_CacheEventTextures_Internal(CalendarEventGetTextures(eventType));
		end
	end
	return true;
end

local function _CalendarFrame_GetEventTexture(index, eventType)
	if ( not _CalendarFrame_CacheEventTextures(eventType) ) then
		return nil;
	end
	for cacheIndex = 1, #CalendarEventTextureCache do
		local entry = CalendarEventTextureCache[cacheIndex];
		if ( entry.textureIndex and index == entry.textureIndex ) then
			return entry;
		end
	end
	return nil;
end

local function _CalendarFrame_GetTextureFile(textureName, calendarType, sequenceType, eventType)
	local texture, tcoords;
	if ( textureName and textureName ~= "" ) then
		if ( CALENDAR_CALENDARTYPE_TEXTURE_PATHS[calendarType] ) then
			texture = CALENDAR_CALENDARTYPE_TEXTURE_PATHS[calendarType]..textureName;
			if ( CALENDAR_CALENDARTYPE_TEXTURE_APPEND[calendarType] ) then
				texture = texture..CALENDAR_CALENDARTYPE_TEXTURE_APPEND[calendarType][sequenceType];
			end
			tcoords = CALENDAR_CALENDARTYPE_TCOORDS[calendarType];
		elseif ( CALENDAR_EVENTTYPE_TEXTURE_PATHS[eventType] ) then
			texture = CALENDAR_EVENTTYPE_TEXTURE_PATHS[eventType]..textureName;
			tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
		elseif ( CALENDAR_CALENDARTYPE_TEXTURES[calendarType][sequenceType] ) then
			texture = CALENDAR_CALENDARTYPE_TEXTURES[calendarType][sequenceType];
			tcoords = CALENDAR_CALENDARTYPE_TCOORDS[calendarType];
		elseif ( CALENDAR_EVENTTYPE_TEXTURES[eventType] ) then
			texture = CALENDAR_EVENTTYPE_TEXTURES[eventType];
			tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
		end
	elseif ( CALENDAR_CALENDARTYPE_TEXTURES[calendarType][sequenceType] ) then
		texture = CALENDAR_CALENDARTYPE_TEXTURES[calendarType][sequenceType];
		tcoords = CALENDAR_CALENDARTYPE_TCOORDS[calendarType];
	elseif ( CALENDAR_EVENTTYPE_TEXTURES[eventType] ) then
		texture = CALENDAR_EVENTTYPE_TEXTURES[eventType];
		tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
	end
	return texture, tcoords;
end

local function _CalendarFrame_GetEventColor(calendarType, modStatus, inviteStatus)
	if ( calendarType == "PLAYER" or calendarType == "GUILD_ANNOUNCEMENT" or calendarType == "GUILD_EVENT" ) then
		if ( modStatus == "MODERATOR" or modStatus == "CREATOR" ) then
			return CALENDAR_EVENTCOLOR_MODERATOR;
		elseif ( inviteStatus and CALENDAR_INVITESTATUS_INFO[inviteStatus] ) then
			return CALENDAR_INVITESTATUS_INFO[inviteStatus].color;
		end
	elseif ( CALENDAR_CALENDARTYPE_COLORS[calendarType] ) then
		return CALENDAR_CALENDARTYPE_COLORS[calendarType];
	end
	-- default to normal color
	return NORMAL_FONT_COLOR;
end

local function _CalendarFrame_SafeGetInviteStatusInfo(inviteStatus)
	return CALENDAR_INVITESTATUS_INFO[inviteStatus] or CALENDAR_INVITESTATUS_INFO["UNKNOWN"];
end

local function _CalendarFrame_ResetClassData()
	for _, classData in next, CalendarClassData do
		for i in next, classData.counts do
			classData.counts[i] = 0;
		end
	end
end

local function _CalendarFrame_UpdateClassData()
	_CalendarFrame_ResetClassData();

	for i = 1, CalendarEventGetNumInvites() do
		local _, _, className, classFilename, inviteStatus = CalendarEventGetInvite(i);
		if ( classFilename and classFilename ~= "" ) then
			CalendarClassData[classFilename].counts[inviteStatus] = CalendarClassData[classFilename].counts[inviteStatus] + 1;
			-- HACK: doing this because we don't have class names in global strings
			CalendarClassData[classFilename].name = className;
		end
	end
end

local function _CalendarFrame_InviteToRaid(maxInviteCount)
	local inviteCount = 0;
	local i = 1;
	while ( inviteCount < maxInviteCount and i <= CalendarEventGetNumInvites() ) do
		local name, level, className, classFilename, inviteStatus = CalendarEventGetInvite(i);
		if ( not UnitInParty(name) and not UnitInRaid(name) and
			 (inviteStatus == CALENDAR_INVITESTATUS_ACCEPTED or
			 inviteStatus == CALENDAR_INVITESTATUS_CONFIRMED or
			 inviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP) ) then
			InviteUnit(name);
			inviteCount = inviteCount + 1;
		end
		i = i + 1;
	end
	return inviteCount;
end

local function _CalendarFrame_GetInviteToRaidCount(maxInviteCount)
	local inviteCount = 0;
	local i = 1;
	while ( inviteCount < maxInviteCount and i <= CalendarEventGetNumInvites() ) do
		local name, level, className, classFilename, inviteStatus = CalendarEventGetInvite(i);
		if ( not UnitInParty(name) and not UnitInRaid(name) and
			 (inviteStatus == CALENDAR_INVITESTATUS_ACCEPTED or
			 inviteStatus == CALENDAR_INVITESTATUS_CONFIRMED or
			 inviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP) ) then
			inviteCount = inviteCount + 1;
		end
		i = i + 1;
	end
	return inviteCount;
end


-- CalendarFrame

function Calendar_Toggle()
	if ( CalendarFrame:IsShown() ) then
		Calendar_Hide();
	else
		Calendar_Show();
	end
end

function Calendar_Hide()
	HideUIPanel(CalendarFrame);
end

function Calendar_Show()
	ShowUIPanel(CalendarFrame);
end

function CalendarFrame_ShowEventFrame(frame)
	if ( frame == CalendarFrame.eventFrame ) then
		if ( frame ) then
			if ( not frame:IsShown() ) then
				frame:Show();
				CalendarEventFrameBlocker:Show();
			elseif ( frame.update ) then
				frame.update();
				CalendarEventFrameBlocker:Show();
			end
		end
	else
		if ( CalendarFrame.eventFrame ) then
			CalendarFrame.eventFrame:Hide();
			CalendarEventFrameBlocker:Hide();
		end
		CalendarFrame.eventFrame = frame;
		if ( frame ) then
			frame:Show();
			CalendarEventFrameBlocker:Show();
		end
	end
end

function CalendarFrame_HideEventFrame(frame)
	if ( not frame or frame and frame == CalendarFrame.eventFrame ) then
		CalendarFrame_ShowEventFrame(nil);
	end
end

function CalendarFrame_GetEventFrame()
	return CalendarFrame.eventFrame;
end

function CalendarFrame_UpdateTimeFormat()
	-- update all frames that display a time
	local militaryTime = GetCVarBool("timeMgrUseMilitaryTime");
	if ( CalendarFrame:IsShown() and militaryTime ~= CalendarFrame.militaryTime ) then
		-- update the main frame
		CalendarFrame_Update();
		local eventFrame = CalendarFrame.eventFrame;
		if ( eventFrame ) then
			-- update the event frame
			if ( eventFrame == CalendarCreateEventFrame ) then
				-- the create event frame is handled specially because a full update could potentially clobber
				-- a player's changes if he is creating or editing an event
				CalendarCreateEvent_UpdateTimeFormat();
			elseif ( eventFrame.update ) then
				eventFrame.update();
			end
		end
		if ( CalendarEventPickerFrame:IsShown() ) then
			-- update the event picker frame
			CalendarEventPickerScrollFrame_Update();
		end
		CalendarFrame.militaryTime = militaryTime;
	end
end

function CalendarFrame_OnLoad(self)
	self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST");
--	self:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES");		-- event list updates are fired for invite status changes now
	self:RegisterEvent("CALENDAR_OPEN_EVENT");
	self:RegisterEvent("CALENDAR_UPDATE_ERROR");

	-- initialize weekdays
	for i = 1, 7 do
		CalendarFrame_InitWeekday(i);
	end

	-- initialize day buttons
	for i = 1, CALENDAR_MAX_DAYS_PER_MONTH do
		CalendarDayButtons[i] = CreateFrame("Button", "CalendarDayButton"..i, self, "CalendarDayButtonTemplate");
		CalendarFrame_InitDay(i);
	end

	-- initialize the selected date
	self.selectedMonth = nil;
	self.selectedDay = nil;
	self.selectedYear = nil;

	-- initialize the viewed date
	self.viewedMonth = nil;
	self.viewedYear = nil;

	-- initialize modal dialog handling
	self.modalFrame = nil;
end

function CalendarFrame_OnEvent(self, event, ...)
	if ( event == "CALENDAR_UPDATE_EVENT_LIST" ) then
		CalendarFrame_Update();
	elseif ( event == "CALENDAR_OPEN_EVENT" ) then
		-- hide the invite context menu right off the bat, since it's probably going to be invalid
		CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
		-- now open the event based on its calendar type
		local calendarType = ...;
		if ( calendarType == "HOLIDAY" ) then
			CalendarFrame_ShowEventFrame(CalendarViewHolidayFrame);
		elseif ( calendarType == "RAID_RESET" or calendarType == "RAID_LOCKOUT" ) then
			CalendarFrame_ShowEventFrame(CalendarViewRaidFrame);
		else
			-- for now, it could only be a player-created type
			if ( CalendarEventCanEdit() ) then
				CalendarCreateEventFrame.mode = "edit";
				CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
			else
				CalendarFrame_ShowEventFrame(CalendarViewEventFrame);
			end
		end
	elseif ( event == "CALENDAR_UPDATE_ERROR" ) then
		local message = ...;
		StaticPopup_Show("CALENDAR_ERROR", message);
	end
end

function CalendarFrame_OnShow(self)
	-- an event could have stayed selected if the calendar closed without the player doing so explicitly
	-- (e.g. reloadui) so make sure that we're not selecting an event when the calendar comes back
	CalendarFrame_CloseEvent();

	self.militaryTime = GetCVarBool("timeMgrUseMilitaryTime");

	local weekday, month, day, year = CalendarGetDate();
	CalendarSetAbsMonth(month, year);
	CalendarFrame_Update();

	OpenCalendar();

	PlaySound("igSpellBookOpen");
end

function CalendarFrame_OnHide(self)
	-- close the event now...the reason is that the calendar may clear the current event data next time
	-- the frame opens up
	CalendarFrame_CloseEvent();
	CalendarEventPickerFrame_Hide();
	CalendarTexturePickerFrame_Hide();
	CalendarContextMenu_Reset();
	HideDropDownMenu(1);
	StaticPopup_Hide("CALENDAR_DELETE_EVENT");
	StaticPopup_Hide("CALENDAR_ERROR");
	-- pop all modal frames as a fail safe, just in case we somehow end up in a state where modal frames
	-- are left shown, which shouldn't happen
	CalendarFrame_PopModal(true);

	-- clean up texture references
	local dayButton, dayButtonName;
	for i = 1, CALENDAR_MAX_DAYS_PER_MONTH do
		dayButton = CalendarDayButtons[i];
		dayButtonName = dayButton:GetName();
		_G[dayButtonName.."EventTexture"]:SetTexture();
		_G[dayButtonName.."OverlayFrameTexture"]:SetTexture();
	end

	PlaySound("igSpellBookClose");
end

function CalendarFrame_InitWeekday(index)
	local backgroundName = "CalendarWeekday"..index.."Background";
	local background = _G[backgroundName];

	local left = (band(index, 1) * CALENDAR_WEEKDAY_NORMALIZED_TEX_WIDTH) + CALENDAR_WEEKDAY_NORMALIZED_TEX_LEFT;		-- mod(index, 2) * width
	local right = left + CALENDAR_WEEKDAY_NORMALIZED_TEX_WIDTH;
	local top = CALENDAR_WEEKDAY_NORMALIZED_TEX_TOP;
	local bottom = top + CALENDAR_WEEKDAY_NORMALIZED_TEX_HEIGHT;
	background:SetTexCoord(left, right, top, bottom);
end

function CalendarFrame_InitDay(buttonIndex)
	local button = CalendarDayButtons[buttonIndex];
	local buttonName = button:GetName();

	button:SetID(buttonIndex);

	-- set anchors
	button:ClearAllPoints();
	if ( buttonIndex == 1 ) then
		button:SetPoint("TOPLEFT", CalendarWeekday1Background, "BOTTOMLEFT", 0, 0);
	elseif ( mod(buttonIndex, 7) == 1 ) then
		button:SetPoint("TOPLEFT", CalendarDayButtons[buttonIndex - 7], "BOTTOMLEFT", 0, 0);
	else
		button:SetPoint("TOPLEFT", CalendarDayButtons[buttonIndex - 1], "TOPRIGHT", 0, 0);
	end

	-- set the normal texture to be the background
	local tex = button:GetNormalTexture();
	tex:SetDrawLayer("BACKGROUND");
	local texLeft = random(0,1) * CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH;
	local texRight = texLeft + CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH;
	local texTop = random(0,1) * CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT;
	local texBottom = texTop + CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT;
	tex:SetTexCoord(texLeft, texRight, texTop, texBottom);
	-- adjust the highlight texture layer
	tex = button:GetHighlightTexture();
	tex:SetAlpha(CALENDAR_DAYBUTTON_HIGHLIGHT_ALPHA);

	-- create event buttons
	local eventButtonPrefix = buttonName.."EventButton";
	-- anchor first event button to the parent...
	local eventButton = CreateFrame("Button", buttonName.."EventButton1", button, "CalendarDayEventButtonTemplate");
	eventButton:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", CALENDAR_DAYEVENTBUTTON_XOFFSET, -CALENDAR_DAYEVENTBUTTON_YOFFSET);
	-- ...anchor the rest to the previous event button
	for i = 2, CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS do
		eventButton = CreateFrame("Button", eventButtonPrefix..i, button, "CalendarDayEventButtonTemplate");
		eventButton:SetPoint("BOTTOMLEFT", eventButtonPrefix..(i-1), "TOPLEFT", 0, CALENDAR_DAYEVENTBUTTON_YOFFSET);
		eventButton:Hide();
	end
end

function CalendarFrame_Update()
	local presentWeekday, presentMonth, presentDay, presentYear = CalendarGetDate();
	local prevMonth, prevYear, prevNumDays = CalendarGetMonth(-1);
	local nextMonth, nextYear, nextNumDays = CalendarGetMonth(1);
	local month, year, numDays, firstWeekday = CalendarGetMonth();

	-- update the viewed month
	CalendarFrame.viewedMonth = month;
	CalendarFrame.viewedYear = year;

	-- get selected elements
	local selectedMonth = CalendarFrame.selectedMonth;
	local selectedDay = CalendarFrame.selectedDay;
	local selectedYear = CalendarFrame.selectedYear;
	local selectedEventMonthOffset, selectedEventDay, selectedEventIndex = CalendarGetEventIndex();
	local contextEventMonthOffset, contextEventDay, contextEventIndex = CalendarContextGetEventIndex();

	-- set title
	CalendarFrame_UpdateTitle();
	-- update the prev/next month buttons in case we hit a min or max month
	CalendarFrame_UpdateMonthOffsetButtons();

	-- initialize weekdays
	for i = 1, 7 do
		local weekday = _CalendarFrame_GetWeekdayIndex(i);
		_G["CalendarWeekday"..i.."Name"]:SetText(CALENDAR_WEEKDAY_NAMES[weekday]);
	end

	-- initialize hidden attributes
	CalendarTodayFrame:Hide();
	CalendarWeekdaySelectedTexture:Hide();
	CalendarLastDayDarkTexture:Hide();
	CalendarFrame_SetSelectedEvent();

	local buttonIndex = 1;
	local darkTexIndex = 1;
	local darkTopFlags = 0;
	local darkBottomFlags = 0;
	local isSelectedDay, isSelectedMonth;
	local isToday, isThisMonth;
	local isContextEventDay;
	local isSelectedEventMonthOffset;
	local isContextEventMonthOffset;
	local day;

	-- adjust the first week day
	--firstWeekday = _CalendarFrame_GetWeekdayIndex(firstWeekday);

	-- set the previous month's days before the first day of the week
	local viewablePrevMonthDays = mod((firstWeekday - CALENDAR_FIRST_WEEKDAY - 1) + 7, 7);
	day = prevNumDays - viewablePrevMonthDays;
	isSelectedMonth = selectedMonth == prevMonth and selectedYear == prevYear;
	isThisMonth = presentMonth == prevMonth and presentYear == prevYear;
	isSelectedEventMonthOffset = selectedEventMonthOffset == -1;
	isContextEventMonthOffset = contextEventMonthOffset == -1;
	while ( _CalendarFrame_GetWeekdayIndex(buttonIndex) ~= firstWeekday ) do
		darkTopFlags = DARKFLAG_PREVMONTH + DARKFLAG_SIDE_TOP;
		darkBottomFlags = DARKFLAG_PREVMONTH + DARKFLAG_SIDE_BOTTOM;
		if ( buttonIndex == 1 ) then
			darkTopFlags = darkTopFlags + DARKFLAG_SIDE_LEFT;
			darkBottomFlags = darkBottomFlags + DARKFLAG_SIDE_LEFT;
		end
		if ( buttonIndex == (firstWeekday - 1) ) then
			darkTopFlags = darkTopFlags + DARKFLAG_SIDE_RIGHT;
			darkBottomFlags = darkBottomFlags + DARKFLAG_SIDE_RIGHT;
		end

		isSelectedDay = isSelectedMonth and selectedDay == day;
		isToday = isThisMonth and presentDay == day;
		isContextEventDay = isContextEventMonthOffset and contextEventDay == day;

		CalendarFrame_UpdateDay(buttonIndex, day, -1, isSelectedDay, isContextEventDay, isToday, darkTopFlags, darkBottomFlags);
		CalendarFrame_UpdateDayEvents(buttonIndex, day, -1,
			isSelectedEventMonthOffset and selectedEventDay == day and selectedEventIndex,
			isContextEventDay and contextEventIndex);

		day = day + 1;
		darkTexIndex = darkTexIndex + 1;
		buttonIndex = buttonIndex + 1;
	end
	-- set the days of this month
	day = 1;
	isSelectedMonth = selectedMonth == month and selectedYear == year;
	isThisMonth = presentMonth == month and presentYear == year;
	isSelectedEventMonthOffset = selectedEventMonthOffset == 0;
	isContextEventMonthOffset = contextEventMonthOffset == 0;
	while ( day <= numDays ) do
		isSelectedDay = isSelectedMonth and selectedDay == day;
		isToday = isThisMonth and presentDay == day;
		isContextEventDay = isContextEventMonthOffset and contextEventDay == day;

		CalendarFrame_UpdateDay(buttonIndex, day, 0, isSelectedDay, isContextEventDay, isToday);
		CalendarFrame_UpdateDayEvents(buttonIndex, day, 0,
			isSelectedEventMonthOffset and selectedEventDay == day and selectedEventIndex,
			isContextEventDay and contextEventIndex);

		day = day + 1;
		buttonIndex = buttonIndex + 1;
	end
	-- set the special last-day-of-month texture
	if ( buttonIndex < 36 and mod(buttonIndex - 1, 7) ~= 0 ) then
		-- if we are not the last day of the week then we set a special corner texture
		-- to match up with the dark textures of the following month
		CalendarFrame_SetLastDay(CalendarDayButtons[buttonIndex - 1], numDays);
	end
	-- set the first days of the next month
	day = 1;
	isSelectedMonth = selectedMonth == nextMonth and selectedYear == nextYear;
	isThisMonth = presentMonth == nextMonth and presentYear == nextYear;
	isSelectedEventMonthOffset = selectedEventMonthOffset == 1;
	local dayOfWeek;
	local checkCorners = mod(buttonIndex, 7) ~= 1;	-- last day of the viewed month is not the last day of the week
	while ( buttonIndex <= CALENDAR_MAX_DAYS_PER_MONTH ) do
		darkTopFlags = DARKFLAG_NEXTMONTH;
		darkBottomFlags = DARKFLAG_NEXTMONTH;
		-- left darkness
		dayOfWeek = _CalendarFrame_GetDayOfWeek(buttonIndex);
		if ( dayOfWeek == 1 or day == 1 ) then
			darkTopFlags = darkTopFlags + DARKFLAG_SIDE_LEFT;
			darkBottomFlags = darkBottomFlags + DARKFLAG_SIDE_LEFT;
		end
		-- right darkness
		if ( dayOfWeek == 7 ) then
			darkTopFlags = darkTopFlags + DARKFLAG_SIDE_RIGHT;
			darkBottomFlags = darkBottomFlags + DARKFLAG_SIDE_RIGHT;
		end
		-- top darkness
		if ( not CalendarDayButtons[buttonIndex - 7].dark ) then
			-- this day last week was not dark
			darkTopFlags = darkTopFlags + DARKFLAG_SIDE_TOP;
		end
		-- bottom darkness
		if ( not CalendarDayButtons[buttonIndex + 7] ) then
			-- this day next week does not exist
			darkBottomFlags = darkBottomFlags + DARKFLAG_SIDE_BOTTOM;
		end
		-- corner stuff
		if ( checkCorners and (day == 1 or day == 7 or day == 8) ) then
			darkTopFlags = darkTopFlags + DARKFLAG_CORNER;
		end

		isSelectedDay = isSelectedMonth and selectedDay == day;
		isToday = isThisMonth and presentDay == day;
		isContextEventDay = isContextEventMonthOffset and contextEventDay == day;

		CalendarFrame_UpdateDay(buttonIndex, day, 1, isSelectedDay, isContextEventDay, isToday, darkTopFlags, darkBottomFlags);
		CalendarFrame_UpdateDayEvents(buttonIndex, day, 1,
			isSelectedEventMonthOffset and selectedEventDay == day and selectedEventIndex,
			isContextEventDay and contextEventIndex);

		day = day + 1;
		darkTexIndex = darkTexIndex + 1;
		buttonIndex = buttonIndex + 1;
	end

	-- if this month didn't have a selected event...
	if ( not CalendarFrame.selectedEventButton ) then
		local eventFrame = CalendarFrame_GetEventFrame();
		if ( eventFrame and (eventFrame ~= CalendarCreateEventFrame or eventFrame.mode ~= "create") ) then
			--...and the event frame was open and not in create mode, hide the event frame
			CalendarFrame_CloseEvent();
		end
	end

	-- if the context menu was set to an event...
	if ( CalendarContextMenu.eventButton and
		 CalendarContextMenu.func == CalendarDayContextMenu_Initialize ) then
		if ( contextEventDay == 0 ) then
			--...and the context event no longer exists
			-- hide the context menu
			CalendarContextMenu_Hide();
			-- hide the event deletion popup
			-- this might seem kludgy, but it takes just as long, if not longer, to check visibility of the popup
			-- as it does to just hide it, that's why we don't check visibility first
			StaticPopup_Hide("CALENDAR_DELETE_EVENT");
		elseif ( CalendarContextMenu:IsShown() ) then
			local dayButton = CalendarContextMenu.dayButton;
			local eventButton = CalendarContextMenu.eventButton;
			if ( dayButton.monthOffset ~= contextEventMonthOffset or
				 dayButton.day ~= contextEventDay or
				 eventButton.eventIndex ~= contextEventIndex ) then
				--...and the event index changed, hide the context menu
				-- you might be thinking "why don't we just reanchor the context menu to the proper day?"
				-- great question! we don't do this because we don't want the UI to jump around on the user
				-- like that, especially since calendar updates are not always caused by the user
				CalendarContextMenu_Hide();
			end
		end
	end
end

function CalendarFrame_UpdateTitle()
	CalendarMonthName:SetText(CALENDAR_MONTH_NAMES[CalendarFrame.viewedMonth]);
	CalendarYearName:SetText(CalendarFrame.viewedYear);
end

function CalendarFrame_UpdateDay(index, day, monthOffset, isSelected, isContext, isToday, darkTopFlags, darkBottomFlags)
	local button = CalendarDayButtons[index];
	local buttonName = button:GetName();
	local dateLabel = _G[buttonName.."DateFrameDate"];
	local darkTop = _G[buttonName.."DarkFrameTop"];
	local darkBottom = _G[buttonName.."DarkFrameBottom"];
	local darkFrame = darkTop:GetParent();	-- darkBottom:GetParent() also works

	-- set date
	dateLabel:SetText(day);
	button.day = day;
	button.monthOffset = monthOffset;

	-- set darkened textures, these are for days not in the viewed month
	button.dark = darkTopFlags and darkBottomFlags;
	if ( button.dark ) then
		local tcoords;
		tcoords = DARKDAY_TOP_TCOORDS[darkTopFlags];
		darkTop:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
		tcoords = DARKDAY_BOTTOM_TCOORDS[darkBottomFlags];
		darkBottom:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
		darkFrame:Show();
	else
		darkFrame:Hide();
	end

	-- highlight the button if it is the selected day
	if ( isSelected ) then
		CalendarFrame_SetSelectedDay(button);
	else
		if ( not isContext ) then
			button:UnlockHighlight();
		end
	end

	-- highlight the button if it is today
	if ( isToday ) then
		--CalendarFrame_SetToday(button, dateLabel);
		CalendarFrame_SetToday(button);
	end
end

function CalendarFrame_UpdateDayEvents(index, day, monthOffset, selectedEventIndex, contextEventIndex)
	local dayButton = CalendarDayButtons[index];
	local dayButtonName = dayButton:GetName();

	local numEvents = CalendarGetNumDayEvents(monthOffset, day);

	-- turn pending invite on if we have one on this day
	local pendingInviteIndex = CalendarGetFirstPendingInvite(monthOffset, day);
	local pendingInviteTex = _G[dayButtonName.."PendingInviteTexture"];
	if ( pendingInviteIndex > 0 ) then
		pendingInviteTex:Show();
	else
		pendingInviteTex:Hide();
	end

	-- first pass:
	-- record the number of viewable events
	-- record first holiday index
	local numViewableEvents = 0;
	local firstHolidayIndex;
	for i = 1, numEvents do
		local title, hour, minute, calendarType, sequenceType = CalendarGetDayEvent(monthOffset, day, i);
		if ( title ) then
			if ( calendarType == "HOLIDAY" and not firstHolidayIndex ) then
				-- record the first holiday index...the first holiday can have sequenceType "ONGOING"
				firstHolidayIndex = i;
			end
			if ( sequenceType ~= "ONGOING" ) then
				numViewableEvents = numViewableEvents + 1;
			end
		end
	end
	dayButton.numViewableEvents = numViewableEvents;

	-- setup for second pass:
	-- adjust the event buttons based on the number of viewable events in the day
	-- also, determine whether or not we need the more events button
	local moreEventsButton = _G[dayButtonName.."MoreEventsButton"];
	moreEventsButton:Hide();
	local buttonHeight;
	local text1RelPoint, text2Point, text2JustifyH;
	local showingBigEvents = numViewableEvents <= CALENDAR_DAYBUTTON_MAX_VISIBLE_BIGEVENTS;
	if ( numViewableEvents > 0 ) then
		if ( showingBigEvents ) then
			buttonHeight = CALENDAR_DAYEVENTBUTTON_BIGHEIGHT;
			--text1RelPoint = nil;
			text2Point = "BOTTOMLEFT";
			text2JustifyH = "LEFT";
		else
			if ( numViewableEvents > CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS ) then
				-- we have more viewable events than we have buttons
				moreEventsButton:Show();
			end
			buttonHeight = CALENDAR_DAYEVENTBUTTON_HEIGHT;
			text1RelPoint = "BOTTOMLEFT";
			text2Point = "RIGHT";
			text2JustifyH = "RIGHT";
		end
	end

	-- second pass:
	-- record the first event button
	-- show viewable events
	local firstEventButton;
	local eventIndex = 1;
	local eventButtonIndex = 1;
	local eventButton, eventButtonName, eventButtonBackground, eventButtonText1, eventButtonText2, eventColor;
	local prevEventButton;
	while ( eventButtonIndex <= CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS and eventIndex <= numEvents ) do
		eventButton = _G[dayButtonName.."EventButton"..eventButtonIndex];
		eventButtonName = eventButton:GetName();
		eventButtonText1 = _G[eventButtonName.."Text1"];
		eventButtonText2 = _G[eventButtonName.."Text2"];

		local title, hour, minute, calendarType, sequenceType, eventType, texture,
			modStatus, inviteStatus, invitedBy, difficulty, inviteType,
			sequenceIndex, numSequenceDays, difficultyName = CalendarGetDayEvent(monthOffset, day, eventIndex);
		if ( title and sequenceType ~= "ONGOING" ) then
			-- set the event button if the sequence type is not ongoing

			-- record the event Index
			eventButton.eventIndex = eventIndex;

			-- set the event button size
			eventButton:SetHeight(buttonHeight);
			-- set the event time and title
			if ( calendarType == "HOLIDAY" ) then
				-- any event that does not display the time should go here
				eventButtonText2:Hide();
				eventButtonText1:SetFormattedText(CALENDAR_CALENDARTYPE_NAMEFORMAT[calendarType][sequenceType], title);
				eventButtonText1:ClearAllPoints();
				eventButtonText1:SetAllPoints(eventButton);
				eventButtonText1:Show();
			elseif ( calendarType == "RAID_LOCKOUT" or calendarType == "RAID_RESET" ) then
				eventButtonText2:Hide();
				title = GetDungeonNameWithDifficulty(title, difficultyName);
				eventButtonText1:SetFormattedText(CALENDAR_CALENDARTYPE_NAMEFORMAT[calendarType][sequenceType], title);
				eventButtonText1:ClearAllPoints();
				eventButtonText1:SetAllPoints(eventButton);
				eventButtonText1:Show();
			else
				eventButtonText2:SetText(GameTime_GetFormattedTime(hour, minute, showingBigEvents));
				eventButtonText2:ClearAllPoints();
				eventButtonText2:SetPoint(text2Point, eventButton, text2Point);
				eventButtonText2:SetJustifyH(text2JustifyH);
				eventButtonText2:Show();
				eventButtonText1:SetFormattedText(CALENDAR_CALENDARTYPE_NAMEFORMAT[calendarType][sequenceType], title);
				eventButtonText1:ClearAllPoints();
				eventButtonText1:SetPoint("TOPLEFT", eventButton, "TOPLEFT");
				if ( text1RelPoint ) then
					eventButtonText1:SetPoint("BOTTOMRIGHT", eventButtonText2, text1RelPoint);
				end
				eventButtonText1:Show();
			end
			-- set the event color
			eventColor = _CalendarFrame_GetEventColor(calendarType, modStatus, inviteStatus);
			eventButtonText1:SetTextColor(eventColor.r, eventColor.g, eventColor.b);

			-- anchor the event button
			eventButton:SetPoint("BOTTOMLEFT", dayButton, "BOTTOMLEFT", CALENDAR_DAYEVENTBUTTON_XOFFSET, -CALENDAR_DAYEVENTBUTTON_YOFFSET);
			if ( prevEventButton ) then
				-- anchor the prev event button to this one...this makes the latest event stay at the bottom
				prevEventButton:SetPoint("BOTTOMLEFT", eventButton, "TOPLEFT", 0, -CALENDAR_DAYEVENTBUTTON_YOFFSET);
			end
			prevEventButton = eventButton;

			-- highlight the selected event
			if ( selectedEventIndex and eventIndex == selectedEventIndex ) then
				CalendarFrame_SetSelectedEvent(eventButton);
			else
				-- only unlock the highlight if this is not the context event
				if ( not contextEventIndex or eventIndex ~= contextEventIndex ) then
					eventButton:UnlockHighlight();
				end
			end

			-- show the event button
			eventButton:Show();

			-- record the first event button
			firstEventButton = firstEventButton or eventButton;

			eventButtonIndex = eventButtonIndex + 1;
		end

		eventIndex = eventIndex + 1;
	end
	-- hide unused event buttons
	while ( eventButtonIndex <= CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS ) do
		eventButton = _G[dayButtonName.."EventButton"..eventButtonIndex];
		eventButton.eventIndex = nil;
		eventButton:Hide();
		eventButtonIndex = eventButtonIndex + 1;
	end

	-- update day textures
	CalendarFrame_UpdateDayTextures(dayButton, numEvents, firstEventButton, firstHolidayIndex);
end

function CalendarFrame_UpdateDayTextures(dayButton, numEvents, firstEventButton, firstHolidayIndex)
	local dayButtonName = dayButton:GetName();

--	local dateBackground = _G[dayButtonName.."DateFrameBackground"];
--	if ( dayButton.numViewableEvents > 0 ) then
--		dateBackground:Show();
--	else
--		dateBackground:Hide();
--	end

	local monthOffset, day = dayButton.monthOffset, dayButton.day;
	local texturePath, tcoords;

	-- set event textures
	local eventBackground = _G[dayButtonName.."EventBackgroundTexture"];
	local eventTex = _G[dayButtonName.."EventTexture"];
	if ( firstEventButton ) then
		dayButton.firstEventButton = firstEventButton;

		-- anchor the top of the event background to the first event button since it is always
		-- the highest button
		eventBackground:SetPoint("TOP", firstEventButton, "TOP", 0, 40);
		eventBackground:SetPoint("BOTTOM", dayButton, "BOTTOM");
		eventBackground:Show();

		-- set day texture
		local title, hour, minute, calendarType, sequenceType, eventType, texture =
			CalendarGetDayEvent(monthOffset, day, firstEventButton.eventIndex);
		eventTex:SetTexture();
		if ( CALENDAR_USE_SEQUENCE_FOR_EVENT_TEXTURE ) then
			texturePath, tcoords = _CalendarFrame_GetTextureFile(texture, calendarType, sequenceType, eventType);
		else
			texturePath, tcoords = _CalendarFrame_GetTextureFile(texture, calendarType, "", eventType);
		end
		if ( texturePath ) then
			eventTex:SetTexture(texturePath);
			eventTex:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
			eventTex:Show();
		else
			eventTex:Hide();
		end
	else
		eventBackground:Hide();
		eventTex:Hide();
		dayButton.firstEventButton = nil;
	end

	-- set overlay texture
	local overlayTex = _G[dayButtonName.."OverlayFrameTexture"];
	if ( firstHolidayIndex ) then
		-- for now, the overlay texture is the first holiday's sequence texture
		local title, hour, minute, calendarType, sequenceType, eventType, texture,
			modStatus, inviteStatus, invitedBy, difficulty, inviteType,
			sequenceIndex, numSequenceDays = CalendarGetDayEvent(monthOffset, day, firstHolidayIndex);
--		local sequenceIndex, numSequenceDays, sequenceType = CalendarGetDayEventSequenceInfo(monthOffset, day, firstHolidayIndex);
		if ( numSequenceDays > 2 ) then
			-- by art/design request, we're not going to show sequence textures if the sequence only lasts up to 2 days
			overlayTex:SetTexture();
			if ( CALENDAR_USE_SEQUENCE_FOR_OVERLAY_TEXTURE ) then
				texturePath, tcoords = _CalendarFrame_GetTextureFile(texture, calendarType, sequenceType, eventType);
			else
				texturePath, tcoords = _CalendarFrame_GetTextureFile(texture, calendarType, "ONGOING", eventType);
			end
			if ( texturePath ) then
				overlayTex:SetTexture(texturePath);
				overlayTex:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
				overlayTex:GetParent():Show();
				return;
			end
		end
	end
	overlayTex:GetParent():Hide();
end

function CalendarFrame_SetSelectedDay(dayButton)
	local prevSelectedDayButton = CalendarFrame.selectedDayButton;
	if ( prevSelectedDayButton ) then
		prevSelectedDayButton:UnlockHighlight();
		prevSelectedDayButton:GetHighlightTexture():SetAlpha(CALENDAR_DAYBUTTON_HIGHLIGHT_ALPHA);
	end
	dayButton:LockHighlight();
	dayButton:GetHighlightTexture():SetAlpha(CALENDAR_DAYBUTTON_SELECTION_ALPHA);
	CalendarFrame.selectedDayButton = dayButton;

	-- highlight the weekday label at this point too
	local weekdayBackground = _G["CalendarWeekday".._CalendarFrame_GetDayOfWeek(dayButton:GetID()).."Background"];
	CalendarWeekdaySelectedTexture:ClearAllPoints();
	CalendarWeekdaySelectedTexture:SetPoint("CENTER", weekdayBackground, "CENTER");
	CalendarWeekdaySelectedTexture:Show();
end

function CalendarFrame_SetToday(dayButton)
	--CalendarTodayTexture:SetParent(dayButton);
	--CalendarTodayTexture:ClearAllPoints();
	--CalendarTodayTexture:SetPoint("CENTER", anchor, "CENTER");
	--CalendarTodayTexture:Show();
	CalendarTodayFrame:SetParent(dayButton);
	CalendarTodayFrame:ClearAllPoints();
	CalendarTodayFrame:SetPoint("CENTER", dayButton, "CENTER");
	CalendarTodayFrame:Show();
	local darkFrame = _G[dayButton:GetName().."DarkFrame"];
	CalendarTodayFrame:SetFrameLevel(darkFrame:GetFrameLevel() + 1);
end

function CalendarTodayFrame_OnUpdate(self, elapsed)
	self.timer = self.timer - elapsed;
	if (self.timer < 0) then
		self.timer = self.fadeTime;
		if (self.fadein) then
			self.fadein = false;
		else
			self.fadein = true;
		end
	else
		if (self.fadein) then
			CalendarTodayTextureGlow:SetAlpha(1-(self.timer/self.fadeTime));
		else
			CalendarTodayTextureGlow:SetAlpha(self.timer/self.fadeTime);
		end
	end
end

function CalendarFrame_SetLastDay(dayButton, day)
	CalendarLastDayDarkTexture:SetParent(dayButton);
	CalendarLastDayDarkTexture:ClearAllPoints();
	CalendarLastDayDarkTexture:SetPoint("BOTTOMRIGHT", dayButton, "BOTTOMRIGHT");
	CalendarLastDayDarkTexture:Show();
end

function CalendarFrame_SetSelectedEvent(eventButton)
	if ( CalendarFrame.selectedEventButton ) then
		CalendarFrame.selectedEventButton:UnlockHighlight();
		CalendarFrame.selectedEventButton.black:Hide();
	end
	CalendarFrame.selectedEventButton = eventButton;
	if ( CalendarFrame.selectedEventButton ) then
		CalendarFrame.selectedEventButton:LockHighlight();
		CalendarFrame.selectedEventButton.black:Show();
	end
end

function CalendarFrame_OpenEvent(dayButton, eventIndex)
	local day = dayButton.day;
	local monthOffset = dayButton.monthOffset;
	CalendarOpenEvent(monthOffset, day, eventIndex);
end

function CalendarFrame_CloseEvent()
	CalendarCloseEvent();
	CalendarFrame_HideEventFrame();
	CalendarDayEventButton_Click();
end

function CalendarFrame_OffsetMonth(offset)
	CalendarSetMonth(offset);
	CalendarContextMenu_Hide();
	StaticPopup_Hide("CALENDAR_DELETE_EVENT");
	CalendarEventPickerFrame_Hide();
	CalendarTexturePickerFrame_Hide();
	CalendarFrame_Update();
end

function CalendarFrame_UpdateMonthOffsetButtons()
	if ( CalendarFrame_GetModal() ) then
		CalendarPrevMonthButton:Disable();
		CalendarNextMonthButton:Disable();
		return;
	end

	local testWeekday, testMonth, testDay, testYear = CalendarGetMinDate();
	CalendarPrevMonthButton:Enable();
	if ( CalendarFrame.viewedYear <= testYear ) then
		if ( CalendarFrame.viewedMonth <= testMonth ) then
			CalendarPrevMonthButton:Disable();
		end
	end
	-- the max create date is the max date we're going to allow people to view
	testWeekday, testMonth, testDay, testYear = CalendarGetMaxCreateDate();
	CalendarNextMonthButton:Enable();
	if ( CalendarFrame.viewedYear >= testYear ) then
		if ( CalendarFrame.viewedMonth >= testMonth ) then
			CalendarNextMonthButton:Disable();
		end
	end
end

function CalendarPrevMonthButton_OnClick()
	PlaySound("igAbiliityPageTurn");
	CalendarFrame_OffsetMonth(-1);
end

function CalendarNextMonthButton_OnClick()
	PlaySound("igAbiliityPageTurn");
	CalendarFrame_OffsetMonth(1);
end

function CalendarFilterButton_OnClick(self)
	ToggleDropDownMenu(1, nil, CalendarFilterDropDown, self, 0, 0);
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function CalendarFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, CalendarFilterDropDown_Initialize);
	UIDropDownMenu_SetText(self, CALENDAR_FILTERS);
	UIDropDownMenu_SetAnchor(self, 0, 0, "TOPRIGHT", CalendarFilterButton, "BOTTOMRIGHT");
end

function CalendarFilterDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();

	info.keepShownOnClick = 1;
	for index, value in next, CALENDAR_FILTER_CVARS do
		info.text = value.text;
		info.func = CalendarFilterDropDown_OnClick;
		if ( GetCVarBool(value.cvar) ) then
			info.checked = 1;
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function CalendarFilterDropDown_OnClick(self)
	SetCVar(CALENDAR_FILTER_CVARS[self:GetID()].cvar, UIDropDownMenuButton_GetChecked(self));
	CalendarFrame_Update();
end

function CalendarFrame_UpdateFilter()
	if ( CalendarFrame_GetModal() ) then
		HideDropDownMenu(1);
		CalendarFilterButton:Disable();
	else
		CalendarFilterButton:Enable();
	end
end


-- Modal Dialog Support

function CalendarFrame_PushModal(frame)
	local numModalDialogs = #CalendarModalStack;
	local changed = numModalDialogs == 0 or CalendarModalStack[numModalDialogs] ~= frame;
	if ( changed and frame ) then
		tinsert(CalendarModalStack, frame);
		CalendarModalDummy:SetParent(frame);
		CalendarModalDummy:SetFrameLevel(frame:GetFrameLevel() - 1);
		CalendarModalDummy_Show();
		PlaySound("igMainMenuOptionCheckBoxOn");
	end
end

function CalendarFrame_PopModal(popAll)
	local numModalDialogs = #CalendarModalStack;
	if ( numModalDialogs > 0 ) then
		if ( popAll ) then
			wipe(CalendarModalStack);
		else
			tremove(CalendarModalStack);
		end

		numModalDialogs = #CalendarModalStack;
		if ( numModalDialogs == 0 ) then
			-- if we have no more modal dialogs, undo the modal state...
			CalendarModalDummy:SetParent(CalendarFrame);
			--CalendarModalDummy:SetFrameLevel(CalendarFrame:GetFrameLevel());
			CalendarModalDummy_Hide();
		else
			--...otherwise reparent to the new top
			local top = CalendarModalStack[numModalDialogs];
			CalendarModalDummy:SetParent(top);
			CalendarModalDummy:SetFrameLevel(top:GetFrameLevel() - 1);
			CalendarModalDummy_Show();
		end
		PlaySound("igMainMenuQuit");
	end
end

function CalendarFrame_GetModal()
	return CalendarModalStack[#CalendarModalStack];
end

function CalendarModalDummy_Show(self)
	CalendarFrameModalOverlay:Show();
	CalendarEventFrameBlocker:Show();
	CalendarFrame_UpdateMonthOffsetButtons();
	CalendarFrame_UpdateFilter();
	CalendarClassButtonContainer_Update();
	CalendarModalDummy:Show();
end

function CalendarModalDummy_Hide(self)
	CalendarFrameModalOverlay:Hide();
	CalendarEventFrameBlocker:Hide();
	CalendarFrame_UpdateMonthOffsetButtons();
	CalendarFrame_UpdateFilter();
	CalendarClassButtonContainer_Update();
	CalendarModalDummy:Hide();
end

function CalendarEventFrameBlocker_OnShow(self)
	local eventFrame = CalendarFrame_GetEventFrame();
	if ( eventFrame and eventFrame:IsShown() ) then
		-- can't do SetAllPoints because the eventFrame anchors haven't been determined yet
		--CalendarEventFrameBlocker:SetAllPoints(eventFrame);
		CalendarEventFrameBlocker:SetWidth(eventFrame:GetWidth());
		CalendarEventFrameBlocker:SetHeight(eventFrame:GetHeight());

		local eventFrameOverlay = _G[eventFrame:GetName().."ModalOverlay"];
		if ( eventFrameOverlay ) then
			eventFrameOverlay:Show();
		end
	else
		CalendarEventFrameBlocker:Hide();
	end
end

function CalendarEventFrameBlocker_OnHide(self)
	local eventFrame = CalendarFrame_GetEventFrame();
	if ( eventFrame ) then
		local eventFrameOverlay = _G[eventFrame:GetName().."ModalOverlay"];
		if ( eventFrameOverlay ) then
			eventFrameOverlay:Hide();
		end
	end
end

function CalendarEventFrameBlocker_Update()
	local eventFrame = CalendarFrame_GetEventFrame();
	if ( CalendarFrame_GetModal() ) then
		if ( eventFrame and eventFrame:IsShown() ) then
			-- can't do SetAllPoints because the eventFrame anchors haven't been determined yet
			--CalendarEventFrameBlocker:SetAllPoints(eventFrame);
			CalendarEventFrameBlocker:SetWidth(eventFrame:GetWidth());
			CalendarEventFrameBlocker:SetHeight(eventFrame:GetHeight());
			CalendarEventFrameBlocker:Show();

			local eventFrameOverlay = _G[eventFrame:GetName().."ModalOverlay"];
			if ( eventFrameOverlay ) then
				eventFrameOverlay:Show();
			end
		end
	else
		if ( eventFrame ) then
			local eventFrameOverlay = _G[eventFrame:GetName().."ModalOverlay"];
			if ( eventFrameOverlay ) then
				eventFrameOverlay:Hide();
			end
		end
		CalendarEventFrameBlocker:Hide();
	end
end


-- CalendarContextMenu

function CalendarContextMenu_Show(attachFrame, func, anchorName, xOffset, yOffset, ...)
	local uiScale;
	local uiParentScale = UIParent:GetScale();
	if ( GetCVarBool("useUIScale") ) then
		uiScale = tonumber(GetCVar("uiscale"));
		if ( uiParentScale < uiScale ) then
			uiScale = uiParentScale;
		end
	else
		uiScale = uiParentScale;
	end
	--CalendarContextMenu:SetScale(uiScale);

	local point = "TOPLEFT";
	local relativePoint = "BOTTOMLEFT";
	local relativeTo;
	if ( anchorName == "cursor" ) then
		relativeTo = nil;
		local cursorX, cursorY = GetCursorPosition();
		cursorX = cursorX / uiScale;
		cursorY =  cursorY / uiScale;

		if ( not xOffset ) then
			xOffset = 0;
		end
		if ( not yOffset ) then
			yOffset = 0;
		end
		xOffset = cursorX + xOffset;
		yOffset = cursorY + yOffset;
	else
		relativeTo = anchorName;
	end
	local subMenu = _G[CalendarContextMenu.subMenu];
	if ( subMenu ) then
		subMenu:Hide();
	end
	CalendarContextMenu:ClearAllPoints();
	CalendarContextMenu:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
	CalendarContextMenu.attachFrame = attachFrame;
	CalendarContextMenu.func = func;
	if ( func(CalendarContextMenu, ...) ) then
		CalendarContextMenu:Show();
	else
		CalendarContextMenu:Hide();
	end
end

function CalendarContextMenu_Toggle(attachFrame, func, anchorName, xOffset, yOffset, ...)
	if ( CalendarContextMenu:IsShown() ) then
		if ( not func or func == CalendarContextMenu.func ) then
			CalendarContextMenu_Hide();
		else
			CalendarContextMenu_Show(attachFrame, func, anchorName, xOffset, yOffset, ...);
		end
	else
		CalendarContextMenu_Show(attachFrame, func, anchorName, xOffset, yOffset, ...);
	end
end

function CalendarContextMenu_Hide(func)
	if ( not func or func == CalendarContextMenu.func ) then
		CalendarContextMenu:Hide();
	end
end

function CalendarContextMenu_Reset()
	CalendarContextMenu.func = nil;
	CalendarContextMenu.dayButton = nil;
	CalendarContextMenu.eventButton = nil;
end

function CalendarContextMenu_OnLoad(self)
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");

	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end

function CalendarContextMenu_OnEvent(self, event, ...)
	if ( event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_GUILD_UPDATE" ) then
		CalendarDayContextMenu_RefreshEvent();
	end
end

function CalendarContextMenu_OnHide(self)
	-- fail safe: unlock old highlights
	CalendarDayContextMenu_UnlockHighlights();
	CalendarInviteContextMenu_UnlockHighlights();
	-- fail safe: always hide nested menus
	CalendarArenaTeamContextMenu:Hide();
	CalendarInviteStatusContextMenu:Hide();
end


-- CalendarDayContextMenu

function CalendarDayContextMenu_Initialize(self, flags, dayButton, eventButton)
	UIMenu_Initialize(self);

	-- unlock old highlights
	CalendarDayContextMenu_UnlockHighlights();

	-- record the new day and event buttons
	self.dayButton = dayButton;
	self.eventButton = eventButton;
	self.flags = flags;

	local day = dayButton.day;
	local monthOffset = dayButton.monthOffset;
	local month, year = CalendarGetMonth(monthOffset);

	-- record whether or not
	local isTodayOrLater = _CalendarFrame_IsTodayOrLater(month, day, year);
	local isAfterMaxDate = _CalendarFrame_IsAfterMaxCreateDate(month, day, year);
	local validCreationDate = isTodayOrLater and not isAfterMaxDate;

	local canPaste = validCreationDate and CalendarContextEventClipboard();

	local showDay = validCreationDate and band(flags, CALENDAR_CONTEXTMENU_FLAG_SHOWDAY) ~= 0;
	local showEvent = eventButton and band(flags, CALENDAR_CONTEXTMENU_FLAG_SHOWEVENT) ~= 0;

	local needSpacer = false;
	if ( showDay ) then
		-- add guild selections if the player has a guild
		UIMenu_AddButton(self, CALENDAR_CREATE_EVENT, nil, CalendarDayContextMenu_CreateEvent);
		if ( CanEditGuildEvent() ) then
--			UIMenu_AddButton(self, CALENDAR_CREATE_GUILDWIDE_EVENT, nil, CalendarDayContextMenu_CreateGuildWideEvent);
			UIMenu_AddButton(self, CALENDAR_CREATE_GUILD_EVENT, nil, CalendarDayContextMenu_CreateGuildEvent);
			UIMenu_AddButton(self, CALENDAR_CREATE_GUILD_ANNOUNCEMENT, nil, CalendarDayContextMenu_CreateGuildAnnouncement);
		end
--[[
		-- add arena team selection if the player has an arena team
		if ( IsInArenaTeam() ) then
			--UIMenu_AddButton(self, CALENDAR_CREATE_ARENATEAM_EVENT, nil, nil, "CalendarArenaTeamContextMenu");
		end
--]]
		needSpacer = true;
	end

	if ( showEvent ) then
		local eventIndex = eventButton.eventIndex;
		local title, hour, minute, calendarType, sequenceType, eventType, texture,
			modStatus, inviteStatus, invitedBy, difficulty, inviteType = CalendarGetDayEvent(monthOffset, day, eventIndex);
		-- add context items for the selected event
		if ( _CalendarFrame_IsPlayerCreatedEvent(calendarType) ) then
			if ( CalendarContextEventCanEdit(monthOffset, day, eventIndex) ) then
				-- spacer
				if ( needSpacer ) then
					UIMenu_AddButton(self, "");
				end
				-- copy
				UIMenu_AddButton(self, CALENDAR_COPY_EVENT, nil, CalendarDayContextMenu_CopyEvent);
				-- paste
				if ( canPaste ) then
					UIMenu_AddButton(self, CALENDAR_PASTE_EVENT, nil, CalendarDayContextMenu_PasteEvent);
				end
				-- delete
				UIMenu_AddButton(self, CALENDAR_DELETE_EVENT, nil, CalendarDayContextMenu_DeleteEvent);
				needSpacer = true;
			elseif ( canPaste ) then
				if ( needSpacer ) then
					UIMenu_AddButton(self, "");
				end
				-- paste
				UIMenu_AddButton(self, CALENDAR_PASTE_EVENT, nil, CalendarDayContextMenu_PasteEvent);
				needSpacer = true;
			end
			if ( calendarType ~= "GUILD_ANNOUNCEMENT" ) then
				if ( validCreationDate and _CalendarFrame_CanInviteeRSVP(inviteStatus) ) then
					-- spacer
					if ( _CalendarFrame_IsSignUpEvent(calendarType, inviteType) ) then
						if ( inviteStatus == CALENDAR_INVITESTATUS_NOT_SIGNEDUP ) then
							-- sign up
							if ( needSpacer ) then
								UIMenu_AddButton(self, "");
							end
							UIMenu_AddButton(self, CALENDAR_SIGNUP, nil, CalendarDayContextMenu_SignUp);
						else
							-- cancel sign up
							if ( needSpacer ) then
								UIMenu_AddButton(self, "");
							end
							UIMenu_AddButton(self, CALENDAR_REMOVE_SIGNUP, nil, CalendarDayContextMenu_RemoveInvite);
						end
					else
						if ( needSpacer ) then
							UIMenu_AddButton(self, "");
						end
						-- accept invitation
						if ( inviteStatus ~= CALENDAR_INVITESTATUS_ACCEPTED ) then
							UIMenu_AddButton(self, CALENDAR_ACCEPT_INVITATION, nil, CalendarDayContextMenu_AcceptInvite);
						end
						-- tentative invitation
						if ( inviteStatus ~= CALENDAR_INVITESTATUS_TENTATIVE ) then
							UIMenu_AddButton(self, CALENDAR_TENTATIVE_INVITATION, nil, CalendarDayContextMenu_TentativeInvite);
						end
						-- decline invitation
						if ( inviteStatus ~= CALENDAR_INVITESTATUS_DECLINED ) then
							UIMenu_AddButton(self, CALENDAR_DECLINE_INVITATION, nil, CalendarDayContextMenu_DeclineInvite);
						end
					end
					needSpacer = false;
				end
				if ( _CalendarFrame_CanRemoveEvent(modStatus, calendarType, inviteType, inviteStatus) ) then
					-- spacer
					if ( needSpacer ) then
						UIMenu_AddButton(self, "");
					end
					-- remove event
					UIMenu_AddButton(self, CALENDAR_REMOVE_INVITATION, nil, CalendarDayContextMenu_RemoveInvite);
					needSpacer = true;
				end
			end
			if ( CalendarContextEventCanComplain(monthOffset, day, eventIndex) ) then
				if ( needSpacer ) then
					UIMenu_AddButton(self, "");
				end
				-- report spam
				UIMenu_AddButton(self, REPORT_SPAM, nil, CalendarDayContextMenu_ReportSpam);
				needSpacer = true;
			end
		elseif ( canPaste ) then
			-- add paste if we have a clipboard
			if ( needSpacer ) then
				UIMenu_AddButton(self, "");
			end
			UIMenu_AddButton(self, CALENDAR_PASTE_EVENT, nil, CalendarDayContextMenu_PasteEvent);
		end
	elseif ( canPaste ) then
		-- add paste if we have a clipboard
		if ( needSpacer ) then
			UIMenu_AddButton(self, "");
		end
		UIMenu_AddButton(self, CALENDAR_PASTE_EVENT, nil, CalendarDayContextMenu_PasteEvent);
	end

	if ( UIMenu_FinishInitializing(self) ) then
		-- lock new highlights
		if ( dayButton ) then
			dayButton:LockHighlight();
		end
		if ( eventButton ) then
			-- if we're highlighting an event, then register it with the context selection system
			CalendarContextSelectEvent(monthOffset, day, eventButton.eventIndex);
			eventButton:LockHighlight();
		end
		return true;
	else
		-- show an error if they summoned a context menu that they could not create an event for, and
		-- there are no buttons on the context menu
		if ( not isTodayOrLater ) then
			StaticPopup_Show("CALENDAR_ERROR", CALENDAR_ERROR_CREATEDATE_BEFORE_TODAY);
		elseif ( isAfterMaxDate ) then
			StaticPopup_Show("CALENDAR_ERROR", format(CALENDAR_ERROR_CREATEDATE_AFTER_MAX, _CalendarFrame_GetFullDate(CalendarGetMaxCreateDate())));
		end
		return false;
	end
end

function CalendarDayContextMenu_RefreshEvent()
	-- this function assumes that the CalendarContextMenu is already attached to an event
	local menu = CalendarContextMenu;
	if ( menu:IsShown() and menu.func == CalendarDayContextMenu_Initialize ) then
		CalendarContextMenu_Show(menu.attachFrame, menu.func, "cursor", 3, -3, menu.flags, menu.dayButton, menu.eventButton);
	end
end

function CalendarDayContextMenu_UnlockHighlights()
	local dayButton = CalendarContextMenu.dayButton;
	local eventButton = CalendarContextMenu.eventButton;
	if ( dayButton and
		 dayButton ~= CalendarFrame.selectedDayButton and
		 dayButton ~= GameTooltip:GetOwner() ) then
		dayButton:UnlockHighlight();
	end
	if ( eventButton and
		 eventButton ~= CalendarFrame.selectedEventButton and
		 eventButton ~= CalendarEventPickerFrame.selectedEventButton ) then
		eventButton:UnlockHighlight();
	end
end

function CalendarDayContextMenu_CreateEvent()
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
	CalendarCloseEvent();
	CalendarFrame_HideEventFrame();
	CalendarDayButton_Click(CalendarContextMenu.dayButton);

	CalendarNewEvent();
	CalendarCreateEventFrame.mode = "create";
	CalendarCreateEventFrame.dayButton = CalendarContextMenu.dayButton;
	CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
end

function CalendarDayContextMenu_CreateGuildAnnouncement()
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
	CalendarCloseEvent();
	CalendarFrame_HideEventFrame();
	CalendarDayButton_Click(CalendarContextMenu.dayButton);

	CalendarNewGuildAnnouncement();
	CalendarCreateEventFrame.mode = "create";
	CalendarCreateEventFrame.dayButton = CalendarContextMenu.dayButton;
	CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
end

function CalendarDayContextMenu_CreateGuildEvent()
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
	CalendarCloseEvent();
	CalendarFrame_HideEventFrame();
	CalendarDayButton_Click(CalendarContextMenu.dayButton);

	CalendarNewGuildEvent();
	CalendarCreateEventFrame.mode = "create";
	CalendarCreateEventFrame.dayButton = CalendarContextMenu.dayButton;
	CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
end

function CalendarDayContextMenu_CopyEvent()
	CalendarContextEventCopy();
end

function CalendarDayContextMenu_PasteEvent()
	local dayButton = CalendarContextMenu.dayButton;
	CalendarContextEventPaste(dayButton.monthOffset, dayButton.day);
end

function CalendarDayContextMenu_DeleteEvent()
	local text;
	local calendarType = CalendarContextEventGetCalendarType();
	if ( calendarType == "GUILD_ANNOUNCEMENT" ) then
		text = CALENDAR_DELETE_ANNOUNCEMENT_CONFIRM;
	elseif ( calendarType == "GUILD_EVENT" ) then
		text = CALENDAR_DELETE_GUILD_EVENT_CONFIRM;
	else
		text = CALENDAR_DELETE_EVENT_CONFIRM;
	end
	StaticPopup_Show("CALENDAR_DELETE_EVENT", text);
end

function CalendarDayContextMenu_ReportSpam()
	CalendarContextEventComplain();
end

function CalendarDayContextMenu_AcceptInvite()
	CalendarContextInviteAvailable();
end

function CalendarDayContextMenu_TentativeInvite()
	CalendarContextInviteTentative();
end

function CalendarDayContextMenu_DeclineInvite()
	CalendarContextInviteDecline();
end

function CalendarDayContextMenu_RemoveInvite()
	CalendarContextInviteRemove();
end

function CalendarDayContextMenu_SignUp()
	CalendarContextEventSignUp();
end

function CalendarArenaTeamContextMenu_OnLoad(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	-- get updated arena team info for the context menu
	self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE");
	for i = 1, MAX_ARENA_TEAMS do
		ArenaTeamRoster(i);
	end
	self.parentMenu = "CalendarContextMenu";
	self.onlyAutoHideSelf = true;
end

function CalendarArenaTeamContextMenu_OnShow(self)
	CalendarArenaTeamContextMenu_Initialize(self);
end

function CalendarArenaTeamContextMenu_OnEvent(self, event, ...)
	if ( event == "ARENA_TEAM_ROSTER_UPDATE" ) then
		CalendarArenaTeamContextMenu_Initialize(self);
	end
end

function CalendarArenaTeamContextMenu_Initialize(self)
	UIMenu_Initialize(self);
	local teamName, teamSize;
	for i = 1, MAX_ARENA_TEAMS do
		teamName, teamSize = GetArenaTeam(i);
		if ( teamName ) then
			UIMenu_AddButton(
				CalendarArenaTeamContextMenu,								-- menu
				format(PVP_TEAMSIZE, teamSize, teamSize),					-- text
				nil,														-- shortcut
				CalendarArenaTeamContextMenuButton_OnClick_CreateArenaTeamEvent,	-- func
				nil,														-- nested
				i);															-- value
		end
	end
	return UIMenu_FinishInitializing(self);
end

function CalendarArenaTeamContextMenuButton_OnClick_CreateArenaTeamEvent(self)
	-- hide parent menu
	CalendarContextMenu_Hide(CalendarDayContextMenu_Initialize);
	CalendarCloseEvent();
	CalendarFrame_HideEventFrame();
	CalendarDayButton_Click(CalendarContextMenu.dayButton)

	CalendarNewArenaTeamEvent(self.value);
	CalendarCreateEventFrame.mode = "create";
	CalendarCreateEventFrame.dayButton = CalendarContextMenu.dayButton;
	CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
end


-- CalendarDayButtonTemplate

function CalendarDayButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function CalendarDayButton_OnEnter(self)
	if ( not self.day ) then
		-- not yet updated
		return;
	end

	local monthOffset = self.monthOffset;
	local day = self.day;
	local numEvents = CalendarGetNumDayEvents(monthOffset, day);
	if ( numEvents <= 0 ) then
		return;
	end

	-- add events
	local eventTime, eventColor;
	local numShownEvents = 0;
	for i = 1, numEvents do
		local title, hour, minute, calendarType, sequenceType, eventType, texture,
			modStatus, inviteStatus, invitedBy, difficulty, inviteType,
			sequenceIndex, numSequenceDays, difficultyName = CalendarGetDayEvent(monthOffset, day, i);
		if ( title and sequenceType ~= "ONGOING" ) then
			if ( numShownEvents == 0 ) then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
				GameTooltip:ClearLines();

				-- add date if we hit our first viewable event
				local fullDate = format(FULLDATE, _CalendarFrame_GetFullDateFromDay(self));
				GameTooltip:AddLine(fullDate, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				GameTooltip:AddLine(" ");
			else
				GameTooltip:AddLine(" ");
			end

			eventTime = GameTime_GetFormattedTime(hour, minute, true);
			eventColor = _CalendarFrame_GetEventColor(calendarType, modStatus, inviteStatus);
			if ( calendarType == "RAID_RESET" or calendarType == "RAID_LOCKOUT" ) then
				title = GetDungeonNameWithDifficulty(title, difficultyName);
			end
			GameTooltip:AddDoubleLine(
				format(CALENDAR_CALENDARTYPE_NAMEFORMAT[calendarType][sequenceType], title),
				eventTime,
				eventColor.r, eventColor.g, eventColor.b,
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
				1
			);
			if ( _CalendarFrame_IsPlayerCreatedEvent(calendarType) ) then
				local text;
				if ( UnitIsUnit("player", invitedBy) ) then
					if ( calendarType == "GUILD_ANNOUNCEMENT" ) then
						text = CALENDAR_ANNOUNCEMENT_CREATEDBY_YOURSELF;
					elseif ( calendarType == "GUILD_EVENT" ) then
						text = CALENDAR_GUILDEVENT_INVITEDBY_YOURSELF;
					else
						text = CALENDAR_EVENT_INVITEDBY_YOURSELF;
					end
				else
					if ( _CalendarFrame_IsSignUpEvent(calendarType, inviteType) ) then
						local inviteStatusInfo = _CalendarFrame_SafeGetInviteStatusInfo(inviteStatus);
						if ( inviteStatus == CALENDAR_INVITESTATUS_NOT_SIGNEDUP or
							 inviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP ) then
							text = inviteStatusInfo.name;
						else
							text = format(CALENDAR_SIGNEDUP_FOR_GUILDEVENT_WITH_STATUS, inviteStatusInfo.name);
						end
					else
						if ( calendarType == "GUILD_ANNOUNCEMENT" ) then
							text = format(CALENDAR_ANNOUNCEMENT_CREATEDBY_PLAYER, _CalendarFrame_SafeGetName(invitedBy));
						else
							text = format(CALENDAR_EVENT_INVITEDBY_PLAYER, _CalendarFrame_SafeGetName(invitedBy));
						end
					end
				end
				GameTooltip:AddLine(text, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			end

			numShownEvents = numShownEvents + 1;
		end
	end
	if ( numShownEvents > 0 ) then
		GameTooltip:Show();
	end
end

function CalendarDayButton_OnLeave(self)
	GameTooltip:Hide();
	if ( self ~= CalendarFrame.selectedDayButton and
		 (not CalendarContextMenu:IsShown() or self ~= CalendarContextMenu.dayButton) ) then
		self:UnlockHighlight();
	end
end

function CalendarDayButton_OnClick(self, button)
--[[
	local month, year = CalendarGetMonth(self.monthOffset);
	local dayChanged = month ~= CalendarFrame.selectedMonth or self.day ~= CalendarFrame.selectedDay or year ~= CalendarFrame.selectedYear;
	CalendarDayButton_Click(self);

	if ( button == "LeftButton" ) then
		CalendarContextMenu_Hide();
	elseif ( button == "RightButton" ) then
		local flags = CALENDAR_CONTEXTMENU_FLAG_SHOWDAY;
		if ( dayChanged ) then
			CalendarContextMenu_Show(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, self);
		else
			CalendarContextMenu_Toggle(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, self);
		end
	end
--]]
	if ( self.firstEventButton ) then
		CalendarDayEventButton_OnClick(self.firstEventButton, button);
	else
		if ( button == "LeftButton" ) then
			local dayChanged = self ~= CalendarFrame.selectedDayButton;

			CalendarDayButton_Click(self);
			if ( dayChanged ) then
				CalendarFrame_CloseEvent();
			end
			CalendarContextMenu_Hide();
		elseif ( button == "RightButton" ) then
			local dayChanged = self ~= CalendarContextMenu.dayButton;

			local flags = CALENDAR_CONTEXTMENU_FLAG_SHOWDAY;
			if ( dayChanged ) then
				CalendarContextMenu_Show(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, self);
			else
				CalendarContextMenu_Toggle(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, self);
			end
		end
	end

	PlaySound("igMainMenuOptionCheckBoxOn");
end

-- CalendarDayButton_Click allows the OnClick for a day and its event buttons to do some of the same processing
function CalendarDayButton_Click(button)
	-- close the event picker if it doesn't belong to this day
	if ( CalendarEventPickerFrame.dayButton and CalendarEventPickerFrame.dayButton ~= button ) then
		CalendarEventPickerFrame_Hide();
	end

	local day, monthOffset = button.day, button.monthOffset;
	local month, year = CalendarGetMonth(monthOffset);
	if ( day ~= CalendarFrame.selectedDay or month ~= CalendarFrame.selectedMonth or year ~= CalendarFrame.selectedYear ) then
		-- a new day has been selected
		CalendarFrame.selectedDay = day;
		CalendarFrame.selectedMonth = month;
		CalendarFrame.selectedYear = year;
		CalendarFrame_SetSelectedDay(button);
	end
end

function CalendarDayButtonMoreEventsButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function CalendarDayButtonMoreEventsButton_OnEnter(self)
	local dayButton = self:GetParent();
	CalendarDayButton_OnEnter(dayButton);
	dayButton:LockHighlight();
end

function CalendarDayButtonMoreEventsButton_OnLeave(self)
	local dayButton = self:GetParent();
	CalendarDayButton_OnLeave(dayButton);
end

function CalendarDayButtonMoreEventsButton_OnClick(self, button)
--[[
	local dayButton = self:GetParent();
	local dayChanged = CalendarFrame.selectedDayButton ~= dayButton;

	CalendarDayButton_Click(dayButton);

	if ( button == "LeftButton" ) then
		CalendarEventPickerFrame_Toggle(dayButton);
	elseif ( button == "RightButton" ) then
		local flags = CALENDAR_CONTEXTMENU_FLAG_SHOWDAY;
		if ( dayChanged ) then
			CalendarContextMenu_Show(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton);
		else
			CalendarContextMenu_Toggle(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton);
		end
	end
--]]
	local dayButton = self:GetParent();

	if ( button == "LeftButton" ) then
		CalendarDayButton_Click(dayButton);
		CalendarEventPickerFrame_Toggle(dayButton);
	elseif ( button == "RightButton" ) then
		local dayChanged = CalendarFrame.selectedDayButton ~= dayButton;

		local flags = CALENDAR_CONTEXTMENU_FLAG_SHOWDAY;
		if ( firstEventButton ) then
			local eventChanged =
				CalendarContextMenu.eventButton ~= self or
				CalendarContextMenu.dayButton ~= dayButton;

			local flags = CALENDAR_CONTEXTMENU_FLAG_SHOWDAY + CALENDAR_CONTEXTMENU_FLAG_SHOWEVENT;
			if ( eventChanged ) then
				CalendarContextMenu_Show(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton, self);
			else
				CalendarContextMenu_Toggle(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton, self);
			end
			flags = flags + CALENDAR_CONTEXTMENU_FLAG_SHOWEVENT;

		else
			if ( dayChanged ) then
				CalendarContextMenu_Show(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton);
			else
				CalendarContextMenu_Toggle(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton);
			end
		end
	end

	PlaySound("igMainMenuOptionCheckBoxOn");
end


-- CalendarDayEventButtonTemplate

function CalendarDayEventButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self.black = _G[self:GetName().."Black"];
	self.black:SetAlpha(0.7);
end

function CalendarDayEventButton_OnEnter(self)
	local dayButton = self:GetParent();
	CalendarDayButton_OnEnter(dayButton);
	dayButton:LockHighlight();
end

function CalendarDayEventButton_OnLeave(self)
	local dayButton = self:GetParent();
	CalendarDayButton_OnLeave(dayButton);
end

function CalendarDayEventButton_OnClick(self, button)
	local dayButton = self:GetParent();

	if ( button == "LeftButton" ) then
		CalendarDayButton_Click(dayButton);
		CalendarDayEventButton_Click(self, true);
		CalendarContextMenu_Hide();
	elseif ( button == "RightButton" ) then
		local eventChanged =
			CalendarContextMenu.eventButton ~= self or
			CalendarContextMenu.dayButton ~= dayButton;

		local flags = CALENDAR_CONTEXTMENU_FLAG_SHOWDAY + CALENDAR_CONTEXTMENU_FLAG_SHOWEVENT;
		if ( eventChanged ) then
			CalendarContextMenu_Show(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton, self);
		else
			CalendarContextMenu_Toggle(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton, self);
		end
	end

	PlaySound("igMainMenuOptionCheckBoxOn");
end

function CalendarDayEventButton_Click(button, openEvent)
	if ( not button ) then
		StaticPopup_Hide("CALENDAR_DELETE_EVENT");
		CalendarFrame_SetSelectedEvent();
		return;
	end

	local dayButton = button:GetParent();
	local day = dayButton.day;
	local monthOffset = dayButton.monthOffset;
	local eventIndex = button.eventIndex;
	local selectedEventMonthOffset, selectedEventDay, selectedEventIndex = CalendarGetEventIndex();
	if ( selectedEventIndex ~= eventIndex or selectedEventDay ~= day or selectedEventMonthOffset ~= monthOffset ) then
		StaticPopup_Hide("CALENDAR_DELETE_EVENT");
	end
	CalendarFrame_SetSelectedEvent(button);

	if ( openEvent ) then
		CalendarFrame_OpenEvent(dayButton, eventIndex);
	end
end


-- Calendar Misc Templates
function CalendarTitleFrame_SetText(titleFrame, text)
	local name = titleFrame:GetName();
	local textFrame = _G[name.."Text"];
	local middleFrame = _G[name.."BackgroundMiddle"];
	textFrame:SetWidth(0);
	textFrame:SetText(text);
	middleFrame:SetWidth(min(240, max(140, textFrame:GetWidth())));
	textFrame:SetWidth(middleFrame:GetWidth());
end


-- CalendarViewHolidayFrame

function CalendarViewHolidayFrame_OnLoad(self)
	self.update = CalendarViewHolidayFrame_Update;
	CalendarViewHolidayInfoTexture:SetAlpha(0.4);
end

function CalendarViewHolidayFrame_OnShow(self)
	CalendarViewHolidayFrame_Update();
end

function CalendarViewHolidayFrame_OnHide(self)
end

function CalendarViewHolidayFrame_Update()
	local name, description, texture = CalendarGetHolidayInfo(CalendarGetEventIndex());
	CalendarTitleFrame_SetText(CalendarViewHolidayTitleFrame, name);
	CalendarViewHolidayDescription:SetText(description);
	CalendarViewHolidayInfoTexture:SetTexture();
	-- mschweitzer NOTE: we're going to use the default texture here until we can get real INFO art
	local texture = CALENDAR_CALENDARTYPE_TEXTURES["HOLIDAY"]["INFO"];
	local tcoords = CALENDAR_CALENDARTYPE_TCOORDS["HOLIDAY"];
--	local texture, tcoords = _CalendarFrame_GetTextureFile(texture, "HOLIDAY", "INFO", 0);
	if ( texture ) then
		CalendarViewHolidayInfoTexture:SetTexture(texture);
		CalendarViewHolidayInfoTexture:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
		CalendarViewHolidayInfoTexture:Show();
	else
		CalendarViewHolidayInfoTexture:Hide();
	end
end


-- CalendarViewRaidFrame

function CalendarViewRaidFrame_OnLoad(self)
	self.update = CalendarViewRaidFrame_Update;
end

function CalendarViewRaidFrame_OnShow(self)
	CalendarViewRaidFrame_Update();
end

function CalendarViewRaidFrame_OnHide(self)
end

function CalendarViewRaidFrame_Update()
	local name, calendarType, raidID, hour, minute, difficulty, difficultyName = CalendarGetRaidInfo(CalendarGetEventIndex());
	name = GetDungeonNameWithDifficulty(name, difficultyName);
	CalendarTitleFrame_SetText(CalendarViewRaidTitleFrame, name);
	if ( calendarType == "RAID_LOCKOUT" ) then
		CalendarViewRaidDescription:SetFormattedText(CALENDAR_RAID_LOCKOUT_DESCRIPTION, name, GameTime_GetFormattedTime(hour, minute, true));
	else
		-- calendarType should be "RAID_RESET"
		CalendarViewRaidDescription:SetFormattedText(CALENDAR_RAID_RESET_DESCRIPTION, name, GameTime_GetFormattedTime(hour, minute, true));
	end
end


-- Calendar Event Templates

function CalendarEventCloseButton_OnClick(self)
	CalendarContextMenu_Hide();
	CalendarFrame_CloseEvent();
	PlaySound("igMainMenuQuit");
end

function CalendarEventDescriptionScrollFrame_OnLoad(self)
	ScrollFrame_OnLoad(self);

	-- we need to mess with the size of the scroll bar and the position of the up and down buttons
	-- in order to get the thumb texture to stop closer to the up and down buttons
	-- first: resize the scrollbar
	local scrollBar = _G[self:GetName().."ScrollBar"];
	scrollBar:ClearAllPoints();
	scrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -10);
	scrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 0, 10);
	-- second: reposition the up and down buttons
	_G[self:GetName().."ScrollBarScrollDownButton"]:SetPoint("TOP", scrollBar, "BOTTOM", 0, 4);
	_G[self:GetName().."ScrollBarScrollUpButton"]:SetPoint("BOTTOM", scrollBar, "TOP", 0, -4);
	-- now save off the scroll bar for convenience's sake
	self.scrollBar = scrollBar;
	-- make the scroll bar hideable and force it to start off hidden so positioning calculations can be done
	-- as soon as it needs to be shown
	self.scrollBarHideable = 1;
	scrollBar:Hide();

	-- register the addon loaded event for post-load fixups
	self:RegisterEvent("ADDON_LOADED");
	self:SetScript("OnEvent", CalendarEventDescriptionScrollFrame_OnEvent);
end

function CalendarEventDescriptionScrollFrame_OnEvent(self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		local addonName = ...;
		if ( not addonName or (addonName and addonName ~= "Blizzard_Calendar") ) then
			return;
		end

		-- NOTE: this function expects the scroll frame to have a .content member, which should be the
		-- stuff we're scrolling on (scroll frame's scroll child's frame)!
		if ( self.content ) then
			local scrollBar = self.scrollBar;
			scrollBar.Show =
				function (self)
					local scrollFrame = self:GetParent();
					-- adjust scroll frame width
					scrollFrame:SetPoint("BOTTOMRIGHT", scrollFrame:GetParent(), "BOTTOMRIGHT", -4 - self:GetWidth(), 4);
					scrollFrame:GetScrollChild():SetWidth(scrollFrame:GetWidth());
					-- adjust content width
					scrollFrame.content:SetWidth(scrollFrame.defaultContentWidth);
					getmetatable(self).__index.Show(self);
				end
			scrollBar.Hide =
				function (self)
					local scrollFrame = self:GetParent();
					-- adjust scroll frame width
					scrollFrame:SetPoint("BOTTOMRIGHT", scrollFrame:GetParent(), "BOTTOMRIGHT", -4, 4);
					scrollFrame:GetScrollChild():SetWidth(scrollFrame:GetWidth());
					-- adjust content width
					scrollFrame.content:SetWidth(scrollFrame.defaultContentWidth + self:GetWidth());
					getmetatable(self).__index.Hide(self);
				end

			self.defaultContentWidth = self.content:GetWidth();
		end

		-- we don't need this event any more
		self:UnregisterEvent(event)
	end
end

function CalendarEventInviteList_OnLoad(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(0.0, 0.0, 0.0, 0.9);

	self.sortButtons = {
		name = _G[self:GetName().."NameSortButton"],
		class = _G[self:GetName().."ClassSortButton"],
		status = _G[self:GetName().."StatusSortButton"],
	};

	-- register the addon loaded event for post-load fixups
	self:RegisterEvent("ADDON_LOADED");
	self:SetScript("OnEvent", CalendarEventInviteList_OnEvent);
end

function CalendarEventInviteList_OnEvent(self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		local addonName = ...;
		if ( not addonName or (addonName and addonName ~= "Blizzard_Calendar") ) then
			return;
		end

		local scrollBar = self.scrollFrame.scrollBar;
		scrollBar.Show =
			function (self)
				local scrollFrame = self:GetParent();
				local scrollFrameParent = scrollFrame:GetParent();
				local scrollBarWidth = scrollFrameParent.scrollBarWidth;
				-- adjust scroll frame width
				scrollFrame:SetPoint("BOTTOMRIGHT", scrollFrameParent, "BOTTOMRIGHT", -scrollBarWidth, 3);
				scrollFrame.scrollChild:SetWidth(scrollFrame:GetWidth());
				-- adjust button width
				local buttonWidth = scrollFrameParent.defaultButtonWidth - scrollBarWidth;
				for _, button in next, scrollFrame.buttons do
					button:SetWidth(buttonWidth);
				end
				getmetatable(self).__index.Show(self);
			end
		scrollBar.Hide =
			function (self)
				local scrollFrame = self:GetParent();
				local scrollFrameParent = scrollFrame:GetParent();
				-- adjust scroll frame width
				scrollFrame:SetPoint("BOTTOMRIGHT", scrollFrameParent, "BOTTOMRIGHT", 0, 3);
				scrollFrame.scrollChild:SetWidth(scrollFrame:GetWidth());
				-- adjust button width
				local buttonWidth = scrollFrameParent.defaultButtonWidth;
				for _, button in next, scrollFrame.buttons do
					button:SetWidth(buttonWidth);
				end
				getmetatable(self).__index.Hide(self);
			end

		-- kinda cheesy...might wanna unify the create and view invite lists more at some point...
		self.scrollFrame.update = _G[self.scrollFrame:GetName().."_Update"];
		HybridScrollFrame_CreateButtons(self.scrollFrame, self:GetName().."ButtonTemplate");

		self.scrollBarWidth = 25;	-- looks better than actual scroll bar width
		self.defaultButtonWidth = self.scrollFrame.buttons[1]:GetWidth() + self.scrollBarWidth;

		-- we don't need this event any more
		self:UnregisterEvent(event);
	end
end

function CalendarEventInviteList_AnchorSortButtons(inviteList)
	local scrollFrame = inviteList.scrollFrame;
	if ( not scrollFrame.buttons or not scrollFrame.buttons[1] ) then
		return;
	end
	local inviteButton = scrollFrame.buttons[1];
	local inviteButtonName = inviteButton:GetName();

	local nameSortButton = inviteList.sortButtons.name;
	if ( inviteList.partyMode ) then
		local inviteName = _G[inviteButtonName.."Name"];
		nameSortButton:SetPoint("LEFT", inviteName, "LEFT");
	else
		local invitePartyIcon = _G[inviteButtonName.."PartyIcon"];
		nameSortButton:SetPoint("LEFT", invitePartyIcon, "LEFT");
	end

	local classSortButton = inviteList.sortButtons.class;
	local inviteClass = _G[inviteButtonName.."Class"];
	classSortButton:SetPoint("LEFT", inviteClass, "LEFT");

	local statusSortButton = inviteList.sortButtons.status;
	local inviteSort = _G[inviteButtonName.."Status"];
	statusSortButton:SetPoint("RIGHT", inviteSort, "RIGHT");
end

function CalendarEventInviteList_UpdateSortButtons(inviteList)
	local criterion, reverse = CalendarEventGetInviteSortCriterion();
	for index, button in pairs(inviteList.sortButtons) do
		local direction = _G[button:GetName().."Direction"];
		if ( button.criterion == criterion ) then
			if ( reverse ) then
				direction:SetTexCoord(0.0, 0.9375, 0.0, 0.6875);
			else
				direction:SetTexCoord(0.0, 0.9375, 0.6875, 0.0);
			end
			direction:Show();
			button:SetWidth(button:GetTextWidth() + direction:GetWidth());
		else
			direction:Hide();
			button:SetWidth(button:GetTextWidth());
		end
	end
end

function CalendarEventInviteSortButton_OnLoad(self)
	local width = self:GetTextWidth() + _G[self:GetName().."Direction"]:GetWidth();
	self:SetWidth(width);
end

function CalendarEventInviteSortButton_OnClick(self)
	CalendarEventSortInvites(self.criterion, self.criterion == CalendarEventGetInviteSortCriterion());
	PlaySound("igMainMenuOptionCheckBoxOn");
	CalendarContextMenu_Hide(CalendarViewEventInviteContextMenu_Initialize);
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
end

function CalendarEventInviteListButton_OnEnter(self)
	if ( self.inviteIndex ) then
		local weekday, month, day, year, hour, minute = CalendarEventGetInviteResponseTime(self.inviteIndex);
		if ( weekday ~= 0 ) then
			GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
			GameTooltip:AddLine(CALENDAR_TOOLTIP_INVITE_RESPONDED);
			-- date
			GameTooltip:AddLine(
				format(FULLDATE, _CalendarFrame_GetFullDate(weekday, month, day, year)),
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b
			);
			-- time
			GameTooltip:AddLine(
				GameTime_GetFormattedTime(hour, minute, true),
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b
			);
			GameTooltip:Show();
		end
	end
end


-- CalendarViewEventFrame

function CalendarViewEventFrame_OnLoad(self)
	self:RegisterEvent("CALENDAR_UPDATE_EVENT");
	self:RegisterEvent("CALENDAR_UPDATE_INVITE_LIST");
	self:RegisterEvent("CALENDAR_CLOSE_EVENT");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
--	self:RegisterEvent("PARTY_MEMBERS_CHANGED");

	self.update = CalendarViewEventFrame_Update;
	self.selectedInvite = nil;
	self.myInviteIndex = nil;

	self.defaultHeight = self:GetHeight();
end

function CalendarViewEventFrame_OnEvent(self, event, ...)
	if ( CalendarViewEventFrame:IsShown() ) then
		if ( event == "CALENDAR_UPDATE_EVENT" ) then
			CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
			if ( CalendarEventCanEdit() ) then
				CalendarCreateEventFrame.mode = "edit";
				CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
			else
				CalendarViewEventFrame_Update();
			end
		elseif ( event == "CALENDAR_UPDATE_INVITE_LIST" ) then
			CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
			if ( CalendarEventCanEdit() ) then
				CalendarCreateEventFrame.mode = "edit";
				CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
			else
				-- RSVP'ing to the event can induce an invite list update, so we
				-- need to do an RSVP update
				local title, description, creator, eventType, repeatOption, maxSize, textureIndex,
					weekday, month, day, year, hour, minute,
					lockoutWeekday, lockoutMonth, lockoutDay, lockoutYear, lockoutHour, lockoutMinute,
					locked, autoApprove, pendingInvite, inviteStatus, inviteType, calendarType = CalendarGetEventInfo();
				CalendarViewEventRSVP_Update(month, day, year, pendingInvite, inviteStatus, inviteType, calendarType);
				CalendarViewEventInviteList_Update(inviteType, calendarType);
			end
		elseif ( event == "CALENDAR_CLOSE_EVENT" ) then
			CalendarFrame_HideEventFrame(CalendarViewEventFrame);
		elseif ( event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_GUILD_UPDATE" ) then
			if ( CalendarEventCanEdit() ) then
				-- our permissions changed and we can now edit this event
				CalendarCreateEventFrame.mode = "edit";
				CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
			end
--		elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
--			CalendarViewEventInviteList_Update();
		end
	end
end

function CalendarViewEventFrame_OnShow(self)
	CalendarViewEventFrame_Update();
end

function CalendarViewEventFrame_OnHide(self)
	CalendarContextMenu_Hide(CalendarViewEventInviteContextMenu_Initialize);
	--CalendarDayEventButton_Click();
end

function CalendarViewEventFrame_Update()
	local title, description, creator, eventType, repeatOption, maxSize, textureIndex,
		weekday, month, day, year, hour, minute,
		lockoutWeekday, lockoutMonth, lockoutDay, lockoutYear, lockoutHour, lockoutMinute,
		locked, autoApprove, pendingInvite, inviteStatus, inviteType, calendarType = CalendarGetEventInfo();
	if ( not title ) then
		-- event was probably deleted
		CalendarFrame_HideEventFrame(CalendarViewEventFrame);
		CalendarClassButtonContainer_Hide();
		return;
	end
	-- record the invite type
	CalendarViewEventFrame.inviteType = inviteType;
	-- reset the flash timer to reinforce the visual feedback that the player is switching between events
	CalendarViewEventFlashTimer:Stop();
	-- set the icon
	CalendarViewEventIcon:SetTexture();
	local tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
	CalendarViewEventIcon:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
	local eventTex = _CalendarFrame_GetEventTexture(textureIndex, eventType);
	if ( eventTex ) then
		-- set the event type
		local name = eventTex.title;
		name = GetDungeonNameWithDifficulty(name, eventTex.difficultyName);
		CalendarViewEventTypeName:SetFormattedText(CALENDAR_VIEW_EVENTTYPE, safeselect(eventType, CalendarEventGetTypes()), name);
		-- set the eventTex texture
		if ( eventTex.texture ~= "" ) then
			CalendarViewEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURE_PATHS[eventType]..eventTex.texture);
		else
			CalendarViewEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventType]);
		end
	else
		-- set the event type
		CalendarViewEventTypeName:SetText(safeselect(eventType, CalendarEventGetTypes()));
		CalendarViewEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventType]);
	end
	-- set the creator
	CalendarViewEventCreatorName:SetFormattedText(CALENDAR_EVENT_CREATORNAME, _CalendarFrame_SafeGetName(creator));
	-- set the date
	CalendarViewEventDateLabel:SetFormattedText(FULLDATE, _CalendarFrame_GetFullDate(weekday, month, day, year));
	-- set the time
	CalendarViewEventTimeLabel:SetText(GameTime_GetFormattedTime(hour, minute, true));
	-- set the description
	CalendarViewEventDescription:SetText(description);
	CalendarViewEventDescriptionScrollFrame:SetVerticalScroll(0);
	-- change the look based on the locked status
	if ( locked ) then
		-- set the event title
		CalendarViewEventTitle:SetFormattedText(CALENDAR_VIEW_EVENTTITLE_LOCKED, title);
		SetDesaturation(CalendarViewEventIcon, true);
		CalendarViewEventTypeName:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		CalendarViewEventCreatorName:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		--CalendarViewEventDateLabel:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		--CalendarViewEventTimeLabel:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		CalendarViewEventDescription:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	else
		-- set the event title
		CalendarViewEventTitle:SetText(title);
		SetDesaturation(CalendarViewEventIcon, false);
		CalendarViewEventTypeName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		CalendarViewEventCreatorName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		--CalendarViewEventDateLabel:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		--CalendarViewEventTimeLabel:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		CalendarViewEventDescription:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	if ( calendarType == "GUILD_ANNOUNCEMENT" ) then
		CalendarTitleFrame_SetText(CalendarViewEventTitleFrame, CALENDAR_VIEW_ANNOUNCEMENT);
		-- guild wide events don't have invite lists, auto approval, or event locks
		CalendarViewEventInviteListSection:Hide();
		CalendarViewEventFrame:SetHeight(CalendarViewEventFrame.defaultHeight - CalendarViewEventInviteListSection:GetHeight());
		CalendarClassButtonContainer_Hide();
	else
		if ( calendarType == "GUILD_EVENT" ) then
			CalendarTitleFrame_SetText(CalendarViewEventTitleFrame, CALENDAR_VIEW_GUILD_EVENT);
		else
			CalendarTitleFrame_SetText(CalendarViewEventTitleFrame, CALENDAR_VIEW_EVENT);
		end
		CalendarViewEventInviteListSection:Show();
		CalendarViewEventFrame:SetHeight(CalendarViewEventFrame.defaultHeight);
		if ( locked ) then
			-- event locked...you cannot respond to the event
			CalendarViewEventAcceptButton:Disable();
			CalendarViewEventTentativeButton:Disable();
			CalendarViewEventDeclineButton:Disable();
			CalendarViewEventAcceptButtonFlashTexture:Hide();
			CalendarViewEventTentativeButtonFlashTexture:Hide();
			CalendarViewEventDeclineButtonFlashTexture:Hide()
			CalendarViewEventFrame:SetScript("OnUpdate", nil);
		else
			CalendarViewEventRSVP_Update(month, day, year, pendingInvite, inviteStatus, inviteType, calendarType);
		end

		CalendarViewEventInviteList_Update(inviteType, calendarType);
	end
	CalendarEventFrameBlocker_Update();
end

function CalendarViewEventDescriptionScrollFrame_OnLoad(self)
	self.content = CalendarViewEventDescription;
	CalendarEventDescriptionScrollFrame_OnLoad(self);
end

function CalendarViewEventRSVPButton_OnUpdate(self)
	self.flashTexture:SetAlpha(CalendarViewEventFlashTimer:GetSmoothProgress());
end

function CalendarViewEventAcceptButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if ( CalendarViewEventFrame.inviteType == CALENDAR_INVITETYPE_SIGNUP ) then
		GameTooltip:SetText(CALENDAR_TOOLTIP_SIGNUPBUTTON, nil, nil, nil, nil, 1);
	else
		GameTooltip:SetText(CALENDAR_TOOLTIP_AVAILABLEBUTTON, nil, nil, nil, nil, 1);
	end
	GameTooltip:Show();
	--GameTooltip_AddNewbieTip(self, nil, 1.0, 1.0, 1.0, CALENDAR_TOOLTIP_AVAILABLEBUTTON, 1);
end

function CalendarViewEventAcceptButton_OnClick(self)
	if ( CalendarViewEventFrame.inviteType == CALENDAR_INVITETYPE_SIGNUP ) then
		CalendarEventSignUp();
	else
		CalendarEventAvailable();
	end
end

function CalendarViewEventTentativeButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(CALENDAR_TOOLTIP_TENTATIVEBUTTON, nil, nil, nil, nil, 1);
	GameTooltip:Show();
	--GameTooltip_AddNewbieTip(self, nil, 1.0, 1.0, 1.0, CALENDAR_TOOLTIP_TENTATIVEBUTTON, 1);
end

function CalendarViewEventTentativeButton_OnClick(self)
	CalendarEventTentative();
end

function CalendarViewEventDeclineButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(CALENDAR_TOOLTIP_DECLINEBUTTON, nil, nil, nil, nil, 1);
	GameTooltip:Show();
	--GameTooltip_AddNewbieTip(self, nil, 1.0, 1.0, 1.0, CALENDAR_TOOLTIP_DECLINEBUTTON, 1);
end

function CalendarViewEventDeclineButton_OnClick(self)
	CalendarEventDecline();
end

function CalendarViewEventRemoveButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if ( CalendarViewEventFrame.inviteType == CALENDAR_INVITETYPE_SIGNUP ) then
		GameTooltip:SetText(CALENDAR_TOOLTIP_REMOVESIGNUPBUTTON, nil, nil, nil, nil, 1);
	else
		GameTooltip:SetText(CALENDAR_TOOLTIP_REMOVEBUTTON, nil, nil, nil, nil, 1);
	end
	GameTooltip:Show();
	--GameTooltip_AddNewbieTip(self, nil, 1.0, 1.0, 1.0, CALENDAR_TOOLTIP_REMOVEBUTTON, 1);
end

function CalendarViewEventRemoveButton_OnClick(self)
	CalendarRemoveEvent();
end

function CalendarViewEventRSVP_Update(month, day, year, pendingInvite, inviteStatus, inviteType, calendarType)
	-- record the invite type
	CalendarViewEventFrame.inviteType = inviteType;

	local isTodayOrLater = _CalendarFrame_IsTodayOrLater(month, day, year);
	if ( _CalendarFrame_IsSignUpEvent(calendarType, inviteType) ) then
		-- set buttons to sign up mode
		CalendarViewEventAcceptButton:SetText(CALENDAR_SIGNUP);
		CalendarViewEventAcceptButton:ClearAllPoints();
		CalendarViewEventAcceptButton:SetPoint("TOPLEFT", CalendarViewEventTentativeButton:GetParent(), "TOPLEFT", 14, 0);
		CalendarViewEventAcceptButton:SetWidth(CALENDAR_VIEWEVENTFRAME_GUILDEVENT_RSVPBUTTON_WIDTH);
		CalendarViewEventAcceptButtonFlashTexture:Hide();
		CalendarViewEventTentativeButton:ClearAllPoints();
		CalendarViewEventTentativeButton:SetPoint("TOP", CalendarViewEventTentativeButton:GetParent(), "TOP", 0, 0);
		CalendarViewEventTentativeButton:SetWidth(CALENDAR_VIEWEVENTFRAME_GUILDEVENT_RSVPBUTTON_WIDTH);
		CalendarViewEventTentativeButtonFlashTexture:Hide();
		CalendarViewEventRemoveButton:ClearAllPoints();
		CalendarViewEventRemoveButton:SetWidth(CALENDAR_VIEWEVENTFRAME_GUILDEVENT_RSVPBUTTON_WIDTH);
		CalendarViewEventRemoveButton:SetPoint("TOPRIGHT", CalendarViewEventRemoveButton:GetParent(), "TOPRIGHT", -14, 0);
		CalendarViewEventDeclineButton:Hide();
		-- update shown buttons
		if ( isTodayOrLater ) then
			if ( inviteStatus == CALENDAR_INVITESTATUS_NOT_SIGNEDUP ) then
				CalendarViewEventAcceptButton:Enable();
				CalendarViewEventTentativeButton:Enable();
				CalendarViewEventRemoveButton:Disable();
			else
				CalendarViewEventAcceptButton:Disable();
				CalendarViewEventTentativeButton:Disable();
				CalendarViewEventRemoveButton:Enable();
			end
		else
			CalendarViewEventAcceptButton:Disable();
			CalendarViewEventTentativeButton:Disable();
			CalendarViewEventRemoveButton:Disable();
		end
		CalendarViewEventFrame:SetScript("OnUpdate", nil);
	else
		-- set buttons to normal mode
		CalendarViewEventAcceptButton:ClearAllPoints();
		CalendarViewEventAcceptButton:SetPoint("TOPRIGHT", CalendarViewEventTentativeButton:GetParent(), "TOP", -10, 4);
		CalendarViewEventAcceptButton:SetWidth(CALENDAR_VIEWEVENTFRAME_EVENT_RSVPBUTTON_WIDTH);
		CalendarViewEventAcceptButton:SetText(ACCEPT);
		CalendarViewEventTentativeButton:ClearAllPoints();
		CalendarViewEventTentativeButton:SetPoint("TOPLEFT", CalendarViewEventTentativeButton:GetParent(), "TOP", 10, 4);
		CalendarViewEventTentativeButton:SetWidth(CALENDAR_VIEWEVENTFRAME_EVENT_RSVPBUTTON_WIDTH);
		CalendarViewEventDeclineButton:Show();
		CalendarViewEventRemoveButton:ClearAllPoints();
		CalendarViewEventRemoveButton:SetPoint("TOPLEFT", CalendarViewEventRemoveButton:GetParent(), "TOP", 10, -26);
		CalendarViewEventRemoveButton:SetWidth(CALENDAR_VIEWEVENTFRAME_EVENT_RSVPBUTTON_WIDTH);
		-- update shown buttons
		local canRSVP = _CalendarFrame_CanInviteeRSVP(inviteStatus);
		if ( isTodayOrLater and canRSVP ) then
			if ( inviteStatus ~= CALENDAR_INVITESTATUS_ACCEPTED ) then
				CalendarViewEventAcceptButton:Enable();
			else
				CalendarViewEventAcceptButton:Disable();
			end
			if ( inviteStatus ~= CALENDAR_INVITESTATUS_TENTATIVE ) then
				CalendarViewEventTentativeButton:Enable();
			else
				CalendarViewEventTentativeButton:Disable();
			end
			if ( inviteStatus ~= CALENDAR_INVITESTATUS_DECLINED ) then
				CalendarViewEventDeclineButton:Enable();
			else
				CalendarViewEventDeclineButton:Disable();
			end
			if ( pendingInvite ) then
				CalendarViewEventAcceptButtonFlashTexture:Show();
				CalendarViewEventTentativeButtonFlashTexture:Show();
				CalendarViewEventDeclineButtonFlashTexture:Show()
			else
				CalendarViewEventAcceptButtonFlashTexture:Hide();
				CalendarViewEventTentativeButtonFlashTexture:Hide();
				CalendarViewEventDeclineButtonFlashTexture:Hide()
			end
			CalendarViewEventFlashTimer:Play();
		else
			CalendarViewEventAcceptButton:Disable();
			CalendarViewEventTentativeButton:Disable();
			CalendarViewEventDeclineButton:Disable();
			CalendarViewEventAcceptButtonFlashTexture:Hide();
			CalendarViewEventTentativeButtonFlashTexture:Hide();
			CalendarViewEventDeclineButtonFlashTexture:Hide()
			CalendarViewEventFlashTimer:Stop();
		end
	end
end

function CalendarViewEventInviteList_Update(inviteType, calendarType)
--	CalendarViewEventInviteList.partyMode = GetRealNumPartyMembers() > 0 or GetRealNumRaidMembers() > 0;
	CalendarViewEventInviteList.partyMode = false;

	if ( _CalendarFrame_IsSignUpEvent(calendarType, inviteType) ) then
		-- expand the event list so there is not so much empty space around the buttons
		CalendarViewEventDivider:SetPoint("TOPLEFT", CalendarViewEventDivider:GetParent(), "TOPLEFT", 10, -30);
		CalendarViewEventInviteList:SetPoint("TOP", CalendarViewEventInviteList:GetParent(), "TOP", 0, -60);
		CalendarViewEventInviteList:SetHeight(CALENDAR_VIEWEVENTFRAME_GUILDEVENT_INVITELIST_HEIGHT);
	else
		-- shrink the event list to make room for the buttons
		CalendarViewEventDivider:SetPoint("TOPLEFT", CalendarViewEventDivider:GetParent(), "TOPLEFT", 10, -50);
		CalendarViewEventInviteList:SetPoint("TOP", CalendarViewEventInviteList:GetParent(), "TOP", 0, -80);
		CalendarViewEventInviteList:SetHeight(CALENDAR_VIEWEVENTFRAME_EVENT_INVITELIST_HEIGHT);
	end

	CalendarViewEventInviteListScrollFrame_Update();
	CalendarEventInviteList_AnchorSortButtons(CalendarViewEventInviteList);
	CalendarEventInviteList_UpdateSortButtons(CalendarViewEventInviteList);
end

function CalendarViewEventInviteListScrollFrame_Update()
	local buttons = CalendarViewEventInviteListScrollFrame.buttons;
	local numInvites = CalendarEventGetNumInvites();
	local numButtons = #buttons;
	local buttonHeight = buttons[1]:GetHeight();

	CalendarViewEventFrame.myInviteIndex = nil;

	local selectedInviteIndex = CalendarEventGetSelectedInvite();
	if ( selectedInviteIndex <= 0 ) then
		selectedInviteIndex = nil;
	end

	local displayedHeight = 0;
	local selectedInvite = CalendarViewEventFrame.selectedInvite;
	local offset = HybridScrollFrame_GetOffset(CalendarViewEventInviteListScrollFrame);
	for i = 1, numButtons do
		-- get current button info
		local button = buttons[i];
		local buttonName = button:GetName();
		local inviteIndex = i + offset;
		local name, level, className, classFilename, inviteStatus, modStatus, inviteIsMine = CalendarEventGetInvite(inviteIndex);
		if ( name ) then
			button.inviteIndex = inviteIndex;
			-- setup moderator status
			local buttonModIcon = _G[buttonName.."ModIcon"];
			if ( modStatus == "CREATOR" ) then
				buttonModIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
				buttonModIcon:Show();
			elseif ( modStatus == "MODERATOR" ) then
				buttonModIcon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
				buttonModIcon:Show();
			else
				buttonModIcon:SetTexture();
				buttonModIcon:Hide();
			end
--[[
			-- setup party status
			buttonPartyIcon = _G[buttonName.."PartyIcon"];
			if ( not CalendarViewEventInviteList.partyMode or not UnitInParty(name) or not UnitInRaid(name) ) then
				buttonPartyIcon:Hide();
			else
				buttonPartyIcon:Show();
				-- the party icon overrides the mod icon
				buttonModIcon:Hide();
			end
--]]
			-- setup name
			-- NOTE: classFilename could be invalid when a character is being transferred
			local classColor = (classFilename and RAID_CLASS_COLORS[classFilename]) or NORMAL_FONT_COLOR;
			local buttonNameString = _G[buttonName.."Name"];
			buttonNameString:SetText(_CalendarFrame_SafeGetName(name));
			buttonNameString:SetTextColor(classColor.r, classColor.g, classColor.b);
			-- setup class
			local buttonClass = _G[buttonName.."Class"];
			buttonClass:SetText(_CalendarFrame_SafeGetName(className));
			buttonClass:SetTextColor(classColor.r, classColor.g, classColor.b);
			-- setup status
			local buttonStatus = _G[buttonName.."Status"];
			local inviteStatusInfo = _CalendarFrame_SafeGetInviteStatusInfo(inviteStatus);
			buttonStatus:SetText(inviteStatusInfo.name);
			buttonStatus:SetTextColor(inviteStatusInfo.color.r, inviteStatusInfo.color.g, inviteStatusInfo.color.b);

			-- fixup anchors
			if ( CalendarViewEventInviteList.partyMode ) then
				buttonNameString:SetPoint("LEFT", buttonPartyIcon, "RIGHT");
				--buttonClass:SetPoint("LEFT", buttonNameString, "RIGHT", -buttonPartyIcon:GetWidth(), 0);
			elseif ( buttonModIcon:IsShown() ) then
				buttonNameString:SetPoint("LEFT", buttonModIcon, "RIGHT");
				--buttonClass:SetPoint("LEFT", buttonNameString, "RIGHT", -buttonModIcon:GetWidth(), 0);
			else
				buttonNameString:SetPoint("LEFT", button, "LEFT");
				--buttonClass:SetPoint("LEFT", buttonNameString, "RIGHT", 0, 0);
			end

			-- set the selected button
			if ( selectedInviteIndex and inviteIndex == selectedInviteIndex ) then
				CalendarViewEventFrame_SetSelectedInvite(button);
			else
				button:UnlockHighlight();
			end

			button:Show();
		else
			button.inviteIndex = nil;
			button:Hide();
		end
		displayedHeight = displayedHeight + buttonHeight;
	end
	CalendarClassButtonContainer_Show(CalendarViewEventFrame);
	local totalHeight = numInvites * buttonHeight;
	HybridScrollFrame_Update(CalendarViewEventInviteListScrollFrame, totalHeight, displayedHeight);
end

function CalendarViewEventFrame_SetSelectedInvite(inviteButton)
	if ( CalendarViewEventFrame.selectedInvite ) then
		CalendarViewEventFrame.selectedInvite:UnlockHighlight();
	end
	CalendarViewEventFrame.selectedInvite = inviteButton;
	if ( CalendarViewEventFrame.selectedInvite ) then
		CalendarViewEventFrame.selectedInvite:LockHighlight();
	end
end

function CalendarViewEventInviteListButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		--CalendarViewEventInviteListButton_Click(self);
		CalendarContextMenu_Hide();
	elseif ( button == "RightButton" ) then
		local inviteChanged = CalendarContextMenu.inviteButton ~= self;

		if ( CalendarEventHasPendingInvite() and self.inviteIndex == CalendarViewEventFrame.myInviteIndex ) then
			if ( inviteChanged ) then
				CalendarContextMenu_Show(self, CalendarViewEventInviteContextMenu_Initialize, "cursor", 3, -3, self);
			else
				CalendarContextMenu_Toggle(self, CalendarViewEventInviteContextMenu_Initialize, "cursor", 3, -3, self);
			end
		end
	end

	PlaySound("igMainMenuOptionCheckBoxOn");
end

function CalendarViewEventInviteListButton_Click(button)
	CalendarEventSelectInvite(button.inviteIndex);
	CalendarViewEventFrame_SetSelectedInvite(button);
end

function CalendarViewEventInviteContextMenu_Initialize(self, inviteButton)
	UIMenu_Initialize(self);

	-- unlock old highlights
	CalendarInviteContextMenu_UnlockHighlights();

	-- record the invite button
	self.inviteButton = inviteButton;

	-- set invite status submenu
	UIMenu_AddButton(self, CALENDAR_SET_INVITE_STATUS, nil, nil, "CalendarInviteStatusContextMenu");

	-- lock new highlights
	inviteButton:LockHighlight();

	return UIMenu_FinishInitializing(self);
end


-- CalendarCreateEventFrame

function CalendarCreateEventFrame_OnLoad(self)
	self:RegisterEvent("CALENDAR_UPDATE_EVENT");
	self:RegisterEvent("CALENDAR_UPDATE_INVITE_LIST");
	self:RegisterEvent("CALENDAR_NEW_EVENT");
	self:RegisterEvent("CALENDAR_CLOSE_EVENT");
--	self:RegisterEvent("CALENDAR_ACTION_PENDING");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
--	self:RegisterEvent("PARTY_MEMBERS_CHANGED");

	-- used to update the frame when it is shown via CalendarFrame_ShowEventFrame
	self.update = CalendarCreateEventFrame_Update;

	-- record the default (non-guild-wide) frame size
	self.defaultHeight = self:GetHeight();

	-- initialize UI elements
	UIDropDownMenu_Initialize(CalendarCreateEventTypeDropDown, CalendarCreateEventTypeDropDown_Initialize);
	UIDropDownMenu_SetWidth(CalendarCreateEventTypeDropDown, 100);
	UIDropDownMenu_Initialize(CalendarCreateEventHourDropDown, CalendarCreateEventHourDropDown_Initialize);
	UIDropDownMenu_SetWidth(CalendarCreateEventHourDropDown, 30, 40);
	UIDropDownMenu_Initialize(CalendarCreateEventMinuteDropDown, CalendarCreateEventMinuteDropDown_Initialize);
	UIDropDownMenu_SetWidth(CalendarCreateEventMinuteDropDown, 30, 40);
	UIDropDownMenu_Initialize(CalendarCreateEventAMPMDropDown, CalendarCreateEventAMPMDropDown_Initialize);
	UIDropDownMenu_SetWidth(CalendarCreateEventAMPMDropDown, 40, 40);
	UIDropDownMenu_Initialize(CalendarCreateEventRepeatOptionDropDown, CalendarCreateEventRepeatOptionDropDown_Initialize);
	UIDropDownMenu_SetWidth(CalendarCreateEventRepeatOptionDropDown, 80);
end

function CalendarCreateEventFrame_OnEvent(self, event, ...)
	if ( CalendarCreateEventFrame:IsShown() ) then
		if ( event == "CALENDAR_UPDATE_EVENT" ) then
			if ( CalendarEventCanEdit() ) then
				CalendarCreateEventFrame_Update();
			else
				CalendarFrame_ShowEventFrame(CalendarViewEventFrame);
			end
		elseif ( event == "CALENDAR_UPDATE_INVITE_LIST" ) then
			CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
			if ( not CalendarEventCanEdit() ) then
				-- if we can't edit the event any more, show the view event frame immediately
				CalendarFrame_ShowEventFrame(CalendarViewEventFrame);
				return;
			end
--[[
			local initialList = ...;
			if ( initialList ) then
				-- in this case, a new event was made and the initial invite list is now ready
				-- we need to update the new event with data now
				CalendarCreateEventFrame_Update();
			else
				CalendarCreateEventInviteListScrollFrame_Update();
			end
--]]
			CalendarCreateEventInviteList_Update();
			CalendarCreateEventRaidInviteButton_Update();
		elseif ( event == "CALENDAR_NEW_EVENT" ) then
			local isCopy = ...;
			-- the CALENDAR_NEW_EVENT event gets fired when you successfully create a calendar event,
			-- so to provide feedback to the player, we close the current event frame when we get this
			-- event...the other part of the feedback is that the event shows up on their calendar
			-- (that part gets picked up by a CALENDAR_UPDATE_EVENT_LIST event)
			if ( not isCopy ) then
				CalendarFrame_HideEventFrame(CalendarCreateEventFrame);
			end
		elseif ( event == "CALENDAR_CLOSE_EVENT" ) then
			CalendarFrame_HideEventFrame(CalendarCreateEventFrame);
--[[
		elseif ( event == "CALENDAR_ACTION_PENDING" ) then
			CalendarCreateEventInviteButton_Update();
			CalendarCreateEventCreateButton_Update();
--]]
		elseif ( event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_GUILD_UPDATE" ) then
			if ( event == "GUILD_ROSTER_UPDATE" ) then
				local arg1 = ...;
				if ( arg1 ) then
					GuildRoster();
				end
			end
			if ( CalendarEventCanEdit() ) then
				if ( CalendarCreateEventFrame.mode == "edit" ) then
					CalendarCreateEventFrame_Update();
				end
			else
				CalendarFrame_ShowEventFrame(CalendarViewEventFrame);
			end
--		elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
--			CalendarCreateEventInviteList_Update();
		end
	end
end

function CalendarCreateEventFrame_OnShow(self)
	CalendarCreateEventFrame_Update();
end

function CalendarCreateEventFrame_OnHide(self)
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
	-- clear the raid invite button data so we don't get strange party-invite behavior next time we show this frame
	CalendarCreateEventRaidInviteButton.inviteLostMembers = false;
	CalendarCreateEventRaidInviteButton.inviteCount = 0;
	CalendarMassInviteFrame:Hide();
end

function CalendarCreateEventFrame_Update()
	if ( CalendarCreateEventFrame.mode == "create" ) then
		CalendarCreateEventCreateButton_SetText(CALENDAR_CREATE);

		-- set the event date based on the selected date
		local dayButton = CalendarCreateEventFrame.dayButton;
		CalendarCreateEventDateLabel:SetFormattedText(FULLDATE, _CalendarFrame_GetFullDateFromDay(dayButton));
		local month, year = CalendarGetMonth(dayButton.monthOffset);
		CalendarEventSetDate(month, dayButton.day, year);
		-- deselect the selected event
		CalendarDayEventButton_Click();
		-- reset event title
		CalendarCreateEventTitleEdit:SetText(CALENDAR_CREATEEVENTFRAME_DEFAULT_TITLE);
		CalendarCreateEventTitleEdit:HighlightText();
		CalendarCreateEventTitleEdit:SetFocus();
		CalendarEventSetTitle("");
		-- reset event description
		CalendarCreateEventDescriptionEdit:SetText(CALENDAR_CREATEEVENTFRAME_DEFAULT_DESCRIPTION);
		CalendarEventSetDescription("");
		-- reset event time
		CalendarCreateEventFrame.selectedMinute = CALENDAR_CREATEEVENTFRAME_DEFAULT_MINUTE;
		CalendarCreateEventFrame.selectedAM = CALENDAR_CREATEEVENTFRAME_DEFAULT_AM;
		if ( CalendarFrame.militaryTime ) then
			CalendarCreateEventFrame.selectedHour = GameTime_ComputeMilitaryTime(CALENDAR_CREATEEVENTFRAME_DEFAULT_HOUR, CalendarCreateEventFrame.selectedAM);
		else
			CalendarCreateEventFrame.selectedHour = CALENDAR_CREATEEVENTFRAME_DEFAULT_HOUR;
		end
		CalendarCreateEvent_UpdateEventTime();
		CalendarCreateEvent_SetEventTime();
		-- reset event type
		CalendarCreateEventFrame.selectedEventType = CALENDAR_CREATEEVENTFRAME_DEFAULT_TYPE;
		CalendarCreateEvent_UpdateEventType();
		CalendarEventSetType(CalendarCreateEventFrame.selectedEventType);
		-- reset event texture (must come after event type)
		CalendarCreateEventFrame.selectedTextureIndex = nil;
		CalendarCreateEventTexture_Update();
		-- hide the creator
		CalendarCreateEventCreatorName:Hide();
		-- reset repeat option
		CalendarCreateEventFrame.selectedRepeatOption = CALENDAR_CREATEEVENTFRAME_DEFAULT_REPEAT_OPTION;
		CalendarCreateEvent_UpdateRepeatOption();
		CalendarEventSetRepeatOption(CalendarCreateEventFrame.selectedRepeatOption);
		local calendarType = CalendarEventGetCalendarType();
		if ( calendarType == "GUILD_ANNOUNCEMENT" ) then
			CalendarTitleFrame_SetText(CalendarCreateEventTitleFrame, CALENDAR_CREATE_ANNOUNCEMENT);
			-- guild wide events don't have invites
			CalendarCreateEventInviteListSection:Hide();
			CalendarCreateEventMassInviteButton:Hide();
			CalendarCreateEventFrame:SetHeight(CalendarCreateEventFrame.defaultHeight - CalendarCreateEventInviteListSection:GetHeight());
			CalendarClassButtonContainer_Hide();
		else
			if ( calendarType == "GUILD_EVENT" ) then
				CalendarTitleFrame_SetText(CalendarCreateEventTitleFrame, CALENDAR_CREATE_GUILD_EVENT);
				CalendarCreateEventMassInviteButton:Hide();
			else
				CalendarTitleFrame_SetText(CalendarCreateEventTitleFrame, CALENDAR_CREATE_EVENT);
				-- update mass invite button
				CalendarCreateEventMassInviteButton_Update();
				CalendarCreateEventMassInviteButton:Show();
			end
			-- reset auto-approve
			CalendarCreateEventAutoApproveCheck:SetChecked(CALENDAR_CREATEEVENTFRAME_DEFAULT_AUTOAPPROVE);
			CalendarCreateEvent_SetAutoApprove();
			-- reset lock event
			CalendarCreateEventLockEventCheck:SetChecked(CALENDAR_CREATEEVENTFRAME_DEFAULT_LOCKEVENT);
			CalendarCreateEvent_SetLockEvent();
			-- update invite list
			CalendarCreateEventInviteList_Update();
			CalendarCreateEventInviteListSection:Show();
			CalendarCreateEventFrame:SetHeight(CalendarCreateEventFrame.defaultHeight);
		end
		-- hide the raid invite button, it is only used when editing events
		CalendarCreateEventRaidInviteButton:Hide();
		-- update the modal frame blocker
		CalendarEventFrameBlocker_Update();
	elseif ( CalendarCreateEventFrame.mode == "edit" ) then
		local title, description, creator, eventType, repeatOption, maxSize, textureIndex,
			weekday, month, day, year, hour, minute,
			lockoutWeekday, lockoutMonth, lockoutDay, lockoutYear, lockoutHour, lockoutMinute,
			locked, autoApprove, pendingInvite, inviteStatus, inviteType, calendarType = CalendarGetEventInfo();
		if ( not title ) then
			CalendarFrame_HideEventFrame(CalendarCreateEventFrame);
			CalendarClassButtonContainer_Hide();
			return;
		end

		CalendarCreateEventCreateButton_SetText(CALENDAR_UPDATE);

		-- update event title
		CalendarCreateEventTitleEdit:SetText(title);
		CalendarCreateEventTitleEdit:SetCursorPosition(0);
		CalendarCreateEventTitleEdit:ClearFocus();
		-- update description
		CalendarCreateEventDescriptionEdit:SetText(description);
		CalendarCreateEventDescriptionEdit:SetCursorPosition(0);
		CalendarCreateEventDescriptionEdit:ClearFocus();
		CalendarCreateEventDescriptionScrollFrame:SetVerticalScroll(0);
		-- update date
		CalendarCreateEventDateLabel:SetFormattedText(FULLDATE, _CalendarFrame_GetFullDate(weekday, month, day, year));
		-- update time
		if ( CalendarFrame.militaryTime ) then
			CalendarCreateEventFrame.selectedHour = hour;
		else
			CalendarCreateEventFrame.selectedHour = GameTime_ComputeStandardTime(hour);
		end
		CalendarCreateEventFrame.selectedMinute = minute;
		CalendarCreateEventFrame.selectedAM = hour < 12;
		if ( CalendarFrame.militaryTime ) then
			CalendarCreateEventFrame.selectedHour = hour;
		else
			CalendarCreateEventFrame.selectedHour = GameTime_ComputeStandardTime(hour, CalendarCreateEventFrame.selectedAM);
		end
		CalendarCreateEvent_UpdateEventTime();
		-- update type
		CalendarCreateEventFrame.selectedEventType = eventType;
		CalendarCreateEvent_UpdateEventType();
		-- reset event texture (must come after event type)
		CalendarCreateEventFrame.selectedTextureIndex = textureIndex > 0 and textureIndex;
		CalendarCreateEventTexture_Update();
		-- update the creator (must come after event texture)
		CalendarCreateEventCreatorName:SetFormattedText(CALENDAR_EVENT_CREATORNAME, _CalendarFrame_SafeGetName(creator));
		CalendarCreateEventCreatorName:Show();
		-- update repeat option
		CalendarCreateEventFrame.selectedRepeatOption = repeatOption;
		CalendarCreateEvent_UpdateRepeatOption();
		if ( calendarType == "GUILD_ANNOUNCEMENT" ) then
			CalendarTitleFrame_SetText(CalendarCreateEventTitleFrame, CALENDAR_EDIT_ANNOUNCEMENT);
			-- guild wide events don't have invites
			CalendarCreateEventInviteListSection:Hide();
			CalendarCreateEventRaidInviteButton:Hide();
			CalendarCreateEventFrame:SetHeight(CalendarCreateEventFrame.defaultHeight - CalendarCreateEventInviteListSection:GetHeight());
			CalendarClassButtonContainer_Hide();
		else
			if ( calendarType == "GUILD_EVENT" ) then
				CalendarTitleFrame_SetText(CalendarCreateEventTitleFrame, CALENDAR_EDIT_GUILD_EVENT);
			else
				CalendarTitleFrame_SetText(CalendarCreateEventTitleFrame, CALENDAR_EDIT_EVENT);
			end
			-- update auto approve
			CalendarCreateEventAutoApproveCheck:SetChecked(autoApprove);
			-- update locked
			CalendarCreateEventLockEventCheck:SetChecked(locked);
			-- update invite list
			CalendarCreateEventInviteList_Update();
			-- update raid invite button
			CalendarCreateEventRaidInviteButton_Update();
			CalendarCreateEventInviteListSection:Show();
			CalendarCreateEventRaidInviteButton:Show();
			CalendarCreateEventFrame:SetHeight(CalendarCreateEventFrame.defaultHeight);
		end
		-- we're not able to mass invite after an event is created...
		CalendarCreateEventMassInviteButton:Hide();
		-- update the modal frame blocker
		CalendarEventFrameBlocker_Update();
	end
end

function CalendarCreateEventTitleEdit_OnTextChanged(self)
	local text = self:GetText();
	local trimmedText = strtrim(text);
	if ( trimmedText == "" or trimmedText == CALENDAR_CREATEEVENTFRAME_DEFAULT_TITLE ) then
		-- if the title is either the default or all whitespace, just set it to the empty string
		CalendarEventSetTitle("");
	else
		CalendarEventSetTitle(text);
	end
	CalendarCreateEventCreateButton_Update();
end

function CalendarCreateEventTitleEdit_OnEditFocusLost(self)
	local text = self:GetText();
	if ( strtrim(text) == "" ) then
		self:SetText(CALENDAR_CREATEEVENTFRAME_DEFAULT_TITLE);
	end
	self:HighlightText(0, 0);
end

function CalendarCreateEventCreatorName_Update()
	if ( CalendarCreateEventTextureName:IsShown() ) then
		CalendarCreateEventCreatorName:SetPoint("TOPLEFT", CalendarCreateEventTextureName, "BOTTOMLEFT");
	else
		CalendarCreateEventCreatorName:SetPoint("TOPLEFT", CalendarCreateEventDateLabel, "BOTTOMLEFT");
	end
end

function CalendarCreateEventTexture_Update()
	local eventType = CalendarCreateEventFrame.selectedEventType;
	local textureIndex = CalendarCreateEventFrame.selectedTextureIndex;

	CalendarCreateEventIcon:SetTexture();
	local tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
	CalendarCreateEventIcon:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
	local eventTex = _CalendarFrame_GetEventTexture(textureIndex, eventType);
	if ( eventTex ) then
		-- set the eventTex name since we have one
		local name = eventTex.title;
		CalendarCreateEventTextureName:SetText(GetDungeonNameWithDifficulty(name, eventTex.difficultyName));
		CalendarCreateEventTextureName:Show();
		-- set the eventTex texture
		if ( eventTex.texture ~= "" ) then
			CalendarCreateEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURE_PATHS[eventType]..eventTex.texture);
		else
			CalendarCreateEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventType]);
		end
	else
		CalendarCreateEventTextureName:Hide();
		CalendarCreateEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventType]);
	end
	-- need to update the creator name at this point since it is affected by the texture name
	CalendarCreateEventCreatorName_Update();
end

function CalendarCreateEventTypeDropDown_Initialize(self)
	CalendarCreateEventTypeDropDown_InitEventTypes(self, CalendarEventGetTypes());
end

function CalendarCreateEventTypeDropDown_InitEventTypes(self, ...)
	local info = UIDropDownMenu_CreateInfo();
	for i = 1, select("#", ...) do
		info.text = select(i, ...);
		info.func = CalendarCreateEventTypeDropDown_OnClick;
		if ( CalendarCreateEventFrame.selectedEventType == i ) then
			info.checked = 1;
			UIDropDownMenu_SetText(self, info.text);
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function CalendarCreateEventTypeDropDown_OnClick(self)
	local id = self:GetID();
	if ( id == CALENDAR_EVENTTYPE_DUNGEON or id == CALENDAR_EVENTTYPE_RAID ) then
		CalendarTexturePickerFrame_Show(id);
	else
		UIDropDownMenu_SetSelectedID(CalendarCreateEventTypeDropDown, id);
		CalendarCreateEventFrame.selectedEventType = id;
		CalendarEventSetType(id);
		-- NOTE: clear the texture selection for non-dungeon types since those don't have texture selections
		CalendarCreateEventFrame.selectedTextureIndex = nil;
		CalendarCreateEventTexture_Update();

		CalendarCreateEventCreateButton_Update();
	end
end

function CalendarCreateEvent_UpdateEventType()
	UIDropDownMenu_Initialize(CalendarCreateEventTypeDropDown, CalendarCreateEventTypeDropDown_Initialize);
	UIDropDownMenu_SetSelectedID(CalendarCreateEventTypeDropDown, CalendarCreateEventFrame.selectedEventType);
end

function CalendarCreateEventRepeatOptionDropDown_Initialize(self)
	CalendarCreateEventTypeDropDown_InitRepeatOptions(self, CalendarEventGetRepeatOptions());
end

function CalendarCreateEventTypeDropDown_InitRepeatOptions(self, ...)
	local info = UIDropDownMenu_CreateInfo();
	for i = 1, select("#", ...) do
		info.text = select(i, ...);
		info.func = CalendarCreateEventRepeatOptionDropDown_OnClick;
		if ( CalendarCreateEventFrame.selectedRepeatOption == i ) then
			info.checked = 1;
			UIDropDownMenu_SetText(self, info.text);
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function CalendarCreateEventRepeatOptionDropDown_OnClick(self)
	local id = self:GetID();
	UIDropDownMenu_SetSelectedID(CalendarCreateEventRepeatOptionDropDown, id);
	CalendarCreateEventFrame.selectedRepeatOption = id;
	CalendarEventSetRepeatOption(id);

	CalendarCreateEventCreateButton_Update();
end

function CalendarCreateEvent_UpdateRepeatOption()
	UIDropDownMenu_Initialize(CalendarCreateEventRepeatOptionDropDown, CalendarCreateEventRepeatOptionDropDown_Initialize);
	UIDropDownMenu_SetSelectedID(CalendarCreateEventRepeatOptionDropDown, CalendarCreateEventFrame.selectedRepeatOption);
end

function CalendarCreateEventHourDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();

	local militaryTime = GetCVarBool("timeMgrUseMilitaryTime");

	local hourMin, hourMax;
	if ( militaryTime ) then
		hourMin = 0;
		hourMax = 23;
	else
		hourMin = 1;
		hourMax = 12;
	end
	for hour = hourMin, hourMax, 1 do
		info.value = hour;
		if ( militaryTime ) then
			info.text = format(TIMEMANAGER_24HOUR, hour);
		else
			info.text = hour;
			info.justifyH = "RIGHT";
		end
		info.func = CalendarCreateEventHourDropDown_OnClick;
		if ( hour == CalendarCreateEventFrame.selectedHour ) then
			info.checked = 1;
			UIDropDownMenu_SetText(self, info.text);
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function CalendarCreateEventHourDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(CalendarCreateEventHourDropDown, self.value);
	CalendarCreateEventFrame.selectedHour = self.value;
	CalendarCreateEvent_SetEventTime();

	CalendarCreateEventCreateButton_Update();
end

function CalendarCreateEventMinuteDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();

	for minute = 0, 55, 5 do
		info.value = minute;
		info.text = format(TIMEMANAGER_MINUTE, minute);
		info.func = CalendarCreateEventMinuteDropDown_OnClick;
		if ( minute == CalendarCreateEventFrame.selectedMinute ) then
			info.checked = 1;
			UIDropDownMenu_SetText(self, info.text);
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function CalendarCreateEventMinuteDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(CalendarCreateEventMinuteDropDown, self.value);
	CalendarCreateEventFrame.selectedMinute = self.value;
	CalendarCreateEvent_SetEventTime();

	CalendarCreateEventCreateButton_Update();
end

function CalendarCreateEventAMPMDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();

	info.text = TIMEMANAGER_AM;
	info.func = CalendarCreateEventAMPMDropDown_OnClick;
	if ( CalendarCreateEventFrame.selectedAM ) then
		info.checked = 1;
		UIDropDownMenu_SetText(self, info.text);
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.text = TIMEMANAGER_PM;
	info.func = CalendarCreateEventAMPMDropDown_OnClick;
	if ( CalendarCreateEventFrame.selectedAM ) then
		info.checked = nil;
	else
		info.checked = 1;
		UIDropDownMenu_SetText(self, info.text);
	end
	UIDropDownMenu_AddButton(info);
end

function CalendarCreateEventAMPMDropDown_OnClick(self)
	local id = self:GetID();
	UIDropDownMenu_SetSelectedID(CalendarCreateEventAMPMDropDown, id);
	CalendarCreateEventFrame.selectedAM = id == 1;
	CalendarCreateEvent_SetEventTime();

	CalendarCreateEventCreateButton_Update();
end

function CalendarCreateEvent_SetEventTime()
	local hour = CalendarCreateEventFrame.selectedHour;
	if ( not CalendarFrame.militaryTime ) then
		hour = GameTime_ComputeMilitaryTime(hour, CalendarCreateEventFrame.selectedAM);
	end
	CalendarEventSetTime(hour, CalendarCreateEventFrame.selectedMinute);
end

function CalendarCreateEvent_UpdateEventTime()
	if ( CalendarFrame.militaryTime ) then
		CalendarCreateEventAMPMDropDown:Hide();
	else
		CalendarCreateEventAMPMDropDown:Show();
		UIDropDownMenu_Initialize(CalendarCreateEventAMPMDropDown, CalendarCreateEventAMPMDropDown_Initialize);
		if ( CalendarCreateEventFrame.selectedAM ) then
			UIDropDownMenu_SetSelectedID(CalendarCreateEventAMPMDropDown, 1);
		else
			UIDropDownMenu_SetSelectedID(CalendarCreateEventAMPMDropDown, 2);
		end
	end
	UIDropDownMenu_Initialize(CalendarCreateEventHourDropDown, CalendarCreateEventHourDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(CalendarCreateEventHourDropDown, CalendarCreateEventFrame.selectedHour);
	UIDropDownMenu_Initialize(CalendarCreateEventMinuteDropDown, CalendarCreateEventMinuteDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(CalendarCreateEventMinuteDropDown, CalendarCreateEventFrame.selectedMinute);
end

function CalendarCreateEvent_UpdateTimeFormat()
	local hour, am = CalendarCreateEventFrame.selectedHour, CalendarCreateEventFrame.selectedAM;
	local militaryTime = GetCVarBool("timeMgrUseMilitaryTime");
	if ( militaryTime ) then
		if ( not CalendarFrame.militaryTime ) then
			-- need to convert from 12hr to 24hr
			CalendarCreateEventFrame.selectedHour = GameTime_ComputeMilitaryTime(hour, am);
			CalendarCreateEventAMPMDropDown:Hide();
		end
	else
		if ( CalendarFrame.militaryTime ) then
			-- need to convert from 24hr to 12hr
			CalendarCreateEventFrame.selectedHour, CalendarCreateEventFrame.selectedAM = GameTime_ComputeStandardTime(hour);
			CalendarCreateEventAMPMDropDown:Show();
		end
		UIDropDownMenu_Initialize(CalendarCreateEventAMPMDropDown, CalendarCreateEventAMPMDropDown_Initialize);
		if ( CalendarCreateEventFrame.selectedAM ) then
			UIDropDownMenu_SetSelectedID(CalendarCreateEventAMPMDropDown, 1);
		else
			UIDropDownMenu_SetSelectedID(CalendarCreateEventAMPMDropDown, 2);
		end
	end
	CalendarFrame.militaryTime = militaryTime;
	UIDropDownMenu_Initialize(CalendarCreateEventHourDropDown, CalendarCreateEventHourDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(CalendarCreateEventHourDropDown, CalendarCreateEventFrame.selectedHour);
	UIDropDownMenu_Initialize(CalendarCreateEventMinuteDropDown, CalendarCreateEventMinuteDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(CalendarCreateEventMinuteDropDown, CalendarCreateEventFrame.selectedMinute);
end

function CalendarCreateEventDescriptionScrollFrame_OnLoad(self)
	self.content = CalendarCreateEventDescriptionEdit;
	CalendarEventDescriptionScrollFrame_OnLoad(self);
end

function CalendarCreateEventAutoApproveCheck_OnLoad(self)
	CalendarCreateEventAutoApproveCheckText:SetText(CALENDAR_AUTO_APPROVE);
	CalendarCreateEventAutoApproveCheckText:SetFontObject(GameFontNormalSmallLeft);
	self:SetHitRectInsets(0, -CalendarCreateEventAutoApproveCheckText:GetWidth(), 0, 0);
end

function CalendarCreateEventAutoApproveCheck_OnClick(self)
	CalendarCreateEvent_SetAutoApprove();
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
	CalendarCreateEventCreateButton_Update();
end

function CalendarCreateEvent_SetAutoApprove()
	if ( CalendarCreateEventAutoApproveCheck:GetChecked() ) then
		CalendarEventSetAutoApprove();
	else
		CalendarEventClearAutoApprove();
	end
end

function CalendarCreateEventLockEventCheck_OnLoad(self)
	CalendarCreateEventLockEventCheckText:SetText(CALENDAR_LOCK_EVENT);
	CalendarCreateEventLockEventCheckText:SetFontObject(GameFontNormalSmallLeft);
	self:SetHitRectInsets(0, -CalendarCreateEventLockEventCheckText:GetWidth(), 0, 0);
end

function CalendarCreateEventLockEventCheck_OnClick(self)
	CalendarCreateEvent_SetLockEvent();
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
	CalendarCreateEventCreateButton_Update();
end

function CalendarCreateEvent_SetLockEvent()
	if ( CalendarCreateEventLockEventCheck:GetChecked() ) then
		CalendarEventSetLocked();
	else
		CalendarEventClearLocked();
	end
end

function CalendarCreateEventInviteList_Update()
--	CalendarCreateEventInviteList.partyMode = CalendarCreateEventFrame.mode == "edit" and GetRealNumPartyMembers() > 0 and GetRealNumRaidMembers() > 0;
	CalendarCreateEventInviteList.partyMode = false;

	CalendarCreateEventInviteListScrollFrame_Update();
	CalendarEventInviteList_AnchorSortButtons(CalendarCreateEventInviteList);
	CalendarEventInviteList_UpdateSortButtons(CalendarCreateEventInviteList);
end

function CalendarCreateEventInviteListScrollFrame_Update()
	local buttons = CalendarCreateEventInviteListScrollFrame.buttons;
	local numInvites = CalendarEventGetNumInvites();
	local numButtons = #buttons;
	local buttonHeight = buttons[1]:GetHeight();

	local selectedInviteIndex = CalendarEventGetSelectedInvite();
	if ( selectedInviteIndex <= 0 ) then
		selectedInviteIndex = nil;
	end

	local isEditMode = CalendarCreateEventFrame.mode == "edit";

	local displayedHeight = 0;
	local offset = HybridScrollFrame_GetOffset(CalendarCreateEventInviteListScrollFrame);
	for i = 1, numButtons do
		-- get current button info
		local button = buttons[i];
		local buttonName = button:GetName();
		local inviteIndex = i + offset;
		-- NOTE: if we ever end up storing invites in a cache rather than getting it from C, then be sure to
		-- add a flag that stores whether or not we can invite the player to a party; that would make the
		-- CalendarCreateEventRaidInviteButton code more efficient as well
		local name, level, className, classFilename, inviteStatus, modStatus, inviteIsMine = CalendarEventGetInvite(inviteIndex);
		if ( name ) then
			-- set the button index
			button.inviteIndex = inviteIndex;
			-- setup moderator status
			local buttonModIcon = _G[buttonName.."ModIcon"];
			if ( modStatus == "CREATOR" ) then
				buttonModIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
				buttonModIcon:Show();
			elseif ( modStatus == "MODERATOR" ) then
				buttonModIcon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
				buttonModIcon:Show();
			else
				buttonModIcon:SetTexture();
				buttonModIcon:Hide();
			end
--[[
			-- setup party status
			buttonPartyIcon = _G[buttonName.."PartyIcon"];
			if ( not CalendarCreateEventInviteList.partyMode or not UnitInParty(name) or not UnitInRaid(name) ) then
				buttonPartyIcon:Hide();
			else
				buttonPartyIcon:Show();
				-- the party icon overrides the mod icon
				buttonModIcon:Hide();
			end
--]]
			-- setup name
			-- NOTE: classFilename could be invalid when a character is being transferred
			local classColor = (classFilename and RAID_CLASS_COLORS[classFilename]) or NORMAL_FONT_COLOR;
			local buttonNameString = _G[buttonName.."Name"];
			buttonNameString:SetText(_CalendarFrame_SafeGetName(name));
			buttonNameString:SetTextColor(classColor.r, classColor.g, classColor.b);
			-- setup class
			local buttonClass = _G[buttonName.."Class"];
			buttonClass:SetText(_CalendarFrame_SafeGetName(className));
			buttonClass:SetTextColor(classColor.r, classColor.g, classColor.b);
			-- setup status
			local buttonStatus = _G[buttonName.."Status"];
			local inviteStatusInfo = _CalendarFrame_SafeGetInviteStatusInfo(inviteStatus);
			buttonStatus:SetText(inviteStatusInfo.name);
			buttonStatus:SetTextColor(inviteStatusInfo.color.r, inviteStatusInfo.color.g, inviteStatusInfo.color.b);

			-- fixup anchors
			if ( CalendarCreateEventInviteList.partyMode ) then
				buttonNameString:SetPoint("LEFT", buttonPartyIcon, "RIGHT");
				--buttonClass:SetPoint("LEFT", buttonNameString, "RIGHT", -buttonPartyIcon:GetWidth(), 0);
			elseif ( buttonModIcon:IsShown() ) then
				buttonNameString:SetPoint("LEFT", buttonModIcon, "RIGHT");
				--buttonClass:SetPoint("LEFT", buttonNameString, "RIGHT", -buttonModIcon:GetWidth(), 0);
			else
				buttonNameString:SetPoint("LEFT", button, "LEFT");
				--buttonClass:SetPoint("LEFT", buttonNameString, "RIGHT", 0, 0);
			end

			-- set the selected button
			if ( selectedInviteIndex and inviteIndex == selectedInviteIndex ) then
				CalendarCreateEventFrame_SetSelectedInvite(button);
			else
				button:UnlockHighlight();
			end

			-- set the onclick handler based on the parent mode
			if ( isEditMode ) then
				button:SetScript("OnEnter", CalendarEventInviteListButton_OnEnter);
			else
				button:SetScript("OnEnter", nil);
			end

			-- update class counts
			if ( classFilename ~= "" ) then
				CalendarClassData[classFilename].counts[inviteStatus] = CalendarClassData[classFilename].counts[inviteStatus] + 1;
				-- MFS HACK: doing this because we don't have class names in global strings
				CalendarClassData[classFilename].name = className;
			end

			button:Show();
		else
			button.inviteIndex = nil;
			button:Hide();
		end
		displayedHeight = displayedHeight + buttonHeight;
	end
	CalendarClassButtonContainer_Show(CalendarCreateEventFrame);
	local totalHeight = numInvites * buttonHeight;
	HybridScrollFrame_Update(CalendarCreateEventInviteListScrollFrame, totalHeight, displayedHeight);
end

function CalendarCreateEventFrame_SetSelectedInvite(inviteButton)
	if ( CalendarCreateEventFrame.selectedInvite ) then
		CalendarCreateEventFrame.selectedInvite:UnlockHighlight();
	end
	CalendarCreateEventFrame.selectedInvite = inviteButton;
	if ( CalendarCreateEventFrame.selectedInvite ) then
		CalendarCreateEventFrame.selectedInvite:LockHighlight();
	end
end

function CalendarCreateEventInviteListButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		--CalendarCreateEventInviteListButton_Click(self);
		CalendarContextMenu_Hide();
	elseif ( button == "RightButton" ) then
		local inviteChanged = CalendarContextMenu.inviteButton ~= self;

		if ( inviteChanged ) then
			CalendarContextMenu_Show(self, CalendarCreateEventInviteContextMenu_Initialize, "cursor", 3, -3, self);
		else
			CalendarContextMenu_Toggle(self, CalendarCreateEventInviteContextMenu_Initialize, "cursor", 3, -3, self);
		end
	end

	PlaySound("igMainMenuOptionCheckBoxOn");
end

function CalendarCreateEventInviteListButton_Click(button)
	CalendarEventSelectInvite(button.inviteIndex);
	CalendarCreateEventFrame_SetSelectedInvite(button);
end

function CalendarCreateEventInviteContextMenu_Initialize(self, inviteButton)
	UIMenu_Initialize(self);

	-- unlock old highlights
	CalendarInviteContextMenu_UnlockHighlights();

	-- record the invite button
	self.inviteButton = inviteButton;

	local inviteIndex = inviteButton.inviteIndex;
	local name, _, _, _, _, modStatus = CalendarEventGetInvite(inviteIndex);

	local needSpacer = false;
	if ( modStatus ~= "CREATOR" ) then
		-- remove invite
		UIMenu_AddButton(self, REMOVE, nil, CalendarInviteContextMenu_RemoveInvite);
		-- spacer
		--UIMenu_AddButton(self, "");
		if ( modStatus == "MODERATOR" ) then
			-- clear moderator status
			UIMenu_AddButton(self, CALENDAR_INVITELIST_CLEARMODERATOR, nil, CalendarInviteContextMenu_ClearModerator);
		else
			-- set moderator status
			UIMenu_AddButton(self, CALENDAR_INVITELIST_SETMODERATOR, nil, CalendarInviteContextMenu_SetModerator);
		end
	end
	if ( CalendarCreateEventFrame.mode == "edit" ) then
		if ( needSpacer ) then
			UIMenu_AddButton(self);
		end
		-- set invite status submenu
		UIMenu_AddButton(self, CALENDAR_INVITELIST_SETINVITESTATUS, nil, nil, "CalendarInviteStatusContextMenu");
		needSpacer = true;
	end

	if ( not UnitIsUnit("player", name) and (not UnitInParty(name) or not UnitInRaid(name)) ) then
		-- spacer
		if ( needSpacer ) then
			UIMenu_AddButton(self, "");
		end
		UIMenu_AddButton(
			self,											-- self
			CALENDAR_INVITELIST_INVITETORAID,				-- text
			nil,											-- shortcut
			CalendarInviteContextMenu_InviteToGroup,		-- func
			nil,											-- nested self name
			name);											-- value
	end

	if ( UIMenu_FinishInitializing(self) ) then
		-- lock new highlights
		inviteButton:LockHighlight();
		return true;
	else
		return false;
	end
end

function CalendarInviteContextMenu_UnlockHighlights()
	local inviteButton = CalendarContextMenu.inviteButton;
	if ( inviteButton and
		 inviteButton ~= CalendarViewEventFrame.selectedInvite and
		 inviteButton ~= CalendarCreateEventFrame.selectedInvite ) then
		inviteButton:UnlockHighlight();
	end
end

function CalendarInviteContextMenu_RemoveInvite()
	local inviteButton = CalendarContextMenu.inviteButton;
	CalendarEventRemoveInvite(inviteButton.inviteIndex);
end

function CalendarInviteContextMenu_SetModerator()
	local inviteButton = CalendarContextMenu.inviteButton;
	CalendarEventSetModerator(inviteButton.inviteIndex);
end

function CalendarInviteContextMenu_ClearModerator()
	local inviteButton = CalendarContextMenu.inviteButton;
	CalendarEventClearModerator(inviteButton.inviteIndex);
end

function CalendarInviteContextMenu_InviteToGroup(self)
	InviteUnit(self.value);
end

function CalendarInviteStatusContextMenu_OnLoad(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	self:RegisterEvent("CALENDAR_UPDATE_EVENT");
	self.parentMenu = "CalendarContextMenu";
	self.onlyAutoHideSelf = true;
end

function CalendarInviteStatusContextMenu_OnShow(self)
	CalendarInviteStatusContextMenu_Initialize(self, CalendarEventGetStatusOptions(CalendarContextMenu.inviteButton.inviteIndex));
end

function CalendarInviteStatusContextMenu_OnEvent(self, event, ...)
	if ( event == "CALENDAR_UPDATE_EVENT" ) then
		if ( self:IsShown() ) then
			CalendarInviteStatusContextMenu_Initialize(self, CalendarEventGetStatusOptions(CalendarContextMenu.inviteButton.inviteIndex));
		end
	end
end

function CalendarInviteStatusContextMenu_Initialize(self, ...)
	UIMenu_Initialize(self);

	local statusIndex, statusName;
	for i = 1, select("#", ...), 2 do
		statusIndex = select(i, ...);
		statusName = select(i + 1, ...);
		UIMenu_AddButton(
			self,													-- self
			statusName,												-- text
			nil,													-- shortcut
			CalendarInviteStatusContextMenu_SetStatusOption,		-- func
			nil,													-- nested
			statusIndex												-- value
		);
	end

	return UIMenu_FinishInitializing(self);
end

function CalendarInviteStatusContextMenu_SetStatusOption(self)
	CalendarEventSetStatus(CalendarContextMenu.inviteButton.inviteIndex, self.value);
	-- hide parent
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
end

function CalendarCreateEventInviteEdit_OnEnterPressed(self)
	if ( not AutoCompleteEditBox_OnEnterPressed(self) ) then
		local text = strtrim(self:GetText());
		local trimmedText = strtrim(text);
		if ( trimmedText == "" or trimmedText == CALENDAR_PLAYER_NAME ) then
			self:ClearFocus();
		elseif ( CalendarCanSendInvite() ) then
			CalendarEventInvite(text);
			self:SetText("");
		end
	end
end

function CalendarCreateEventInviteEdit_OnEditFocusLost(self)
	AutoCompleteEditBox_OnEditFocusLost(self);
	self:HighlightText(0, 0);
	local trimmedText = strtrim(self:GetText());
	if ( trimmedText == "" ) then
		self:SetText(CALENDAR_PLAYER_NAME);
	end
end

function CalendarCreateEventInviteButton_OnClick(self)
	local text = strtrim(CalendarCreateEventInviteEdit:GetText());
	local trimmedText = strtrim(text);
	if ( trimmedText == "" or trimmedText == CALENDAR_PLAYER_NAME ) then
		CalendarCreateEventInviteEdit:ClearFocus();
	else
		CalendarEventInvite(text);
		CalendarCreateEventInviteEdit:SetText("");
		--CalendarCreateEventInviteEdit:ClearFocus();
	end

	PlaySound("igMainMenuOptionCheckBoxOn");
end

function CalendarCreateEventInviteButton_OnUpdate(self)
	CalendarCreateEventInviteButton_Update();
end

function CalendarCreateEventInviteButton_Update()
	if ( CalendarCanSendInvite() ) then
		CalendarCreateEventInviteButton:Enable();
	else
		CalendarCreateEventInviteButton:Disable();
	end
end

function CalendarCreateEventMassInviteButton_OnClick()
	CalendarMassInviteFrame:Show();
end

function CalendarCreateEventMassInviteButton_OnUpdate(self)
	CalendarCreateEventMassInviteButton_Update();
end

function CalendarCreateEventMassInviteButton_Update()
	if ( CalendarCanSendInvite() and (CanEditGuildEvent() or IsInArenaTeam()) ) then
		CalendarCreateEventMassInviteButton:Enable();
	else
		CalendarCreateEventMassInviteButton:Disable();
	end
end

function CalendarCreateEventRaidInviteButton_OnLoad(self)
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PARTY_CONVERTED_TO_RAID");

	self:SetWidth(self:GetTextWidth() + 40);
end

function CalendarCreateEventRaidInviteButton_OnEvent(self, event, ...)
	if ( self:IsShown() and self:GetParent():IsShown() ) then
		if ( event == "PARTY_MEMBERS_CHANGED" ) then
			CalendarCreateEventRaidInviteButton_Update();
			if ( GetRealNumRaidMembers() == 0 and GetRealNumPartyMembers() >= 1 and self.inviteLostMembers ) then
				-- in case we weren't able to convert to a raid when the player clicked the raid invite button
				-- (which means the player was not in a party), we want to convert to a raid now since he has a party
				ConvertToRaid();
			end
		elseif ( event == "PARTY_CONVERTED_TO_RAID" ) then
			CalendarCreateEventRaidInviteButton_Update();
			if ( self.inviteLostMembers ) then
				-- should already be in a raid at this point, invite members who were not invited due to the party to raid conversion
				local maxInviteCount = MAX_RAID_MEMBERS - GetRealNumRaidMembers();
				local inviteCount = _CalendarFrame_InviteToRaid(maxInviteCount);
				self.inviteLostMembers = false;
			end
		end
	end
end

function CalendarCreateEventRaidInviteButton_OnClick(self)
	-- compute the max number of players that we should invite
	local maxInviteCount;
	local realNumRaidMembers = GetRealNumRaidMembers();
	local realNumPartyMembers = GetRealNumPartyMembers();
	if ( realNumRaidMembers == 0 ) then
		if ( realNumPartyMembers + self.inviteCount > MAX_PARTY_MEMBERS ) then
			-- if I can't invite the number of people that I'm supposed to...
			self.inviteLostMembers = true;
			if ( realNumPartyMembers > 0 ) then
				--...and I'm already in a party, then I need to form a raid first to fit everyone
				ConvertToRaid();
				return;
			end
			--...and I'm NOT already in a party, then I need to form a party first (happens below),
			-- then form a raid to fit everyone (happens in response to the PARTY_CONVERTED_TO_RAID event)
		end
		maxInviteCount = MAX_PARTY_MEMBERS - realNumPartyMembers;
	else
		maxInviteCount = MAX_RAID_MEMBERS - realNumRaidMembers;
	end

	_CalendarFrame_InviteToRaid(maxInviteCount);
end

function CalendarCreateEventRaidInviteButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if ( GetRealNumRaidMembers() > 0 or GetRealNumPartyMembers() + self.inviteCount > MAX_PARTY_MEMBERS ) then
		GameTooltip:SetText(CALENDAR_TOOLTIP_INVITEMEMBERS_BUTTON_RAID, nil, nil, nil, nil, 1);
	else
		GameTooltip:SetText(CALENDAR_TOOLTIP_INVITEMEMBERS_BUTTON_PARTY, nil, nil, nil, nil, 1);
	end
	GameTooltip:Show();
	--GameTooltip_AddNewbieTip(self, nil, 1.0, 1.0, 1.0, CALENDAR_TOOLTIP_INVITETORAID_BUTTON, 1);
end

function CalendarCreateEventRaidInviteButton_Update()
	-- NOTE: it might be an efficiency concern that we go through the list twice: once to get a count
	-- and once to do the actual inviting (that's in the OnClick), but I thought it would be better to
	-- go through the list twice than to take up extra space in memory and potentially cause a lot of
	-- garbage collection due to constantly rebuilding a saved table
	local maxInviteCount = MAX_RAID_MEMBERS - GetRealNumRaidMembers();
	local inviteCount = _CalendarFrame_GetInviteToRaidCount(maxInviteCount);
	if ( inviteCount > 0 ) then
		CalendarCreateEventRaidInviteButton:Enable();
	else
		CalendarCreateEventRaidInviteButton:Disable();
	end
	CalendarCreateEventRaidInviteButton.inviteCount = inviteCount;
end

function CalendarCreateEventCreateButton_OnClick(self)
	if ( CalendarCreateEventFrame.mode == "create" ) then
		CalendarAddEvent();
	elseif ( CalendarCreateEventFrame.mode == "edit" ) then
		CalendarUpdateEvent();
	end
end

function CalendarCreateEventCreateButton_OnUpdate(self)
	CalendarCreateEventCreateButton_Update();
end

function CalendarCreateEventCreateButton_SetText(text)
	local button = CalendarCreateEventCreateButton;
	button:SetText(text);
	button:SetWidth(button:GetTextWidth() + 40);
end

function CalendarCreateEventCreateButton_Update()
	if ( CalendarCreateEventFrame.mode == "create" ) then
		if ( CalendarCanAddEvent() ) then
			CalendarCreateEventCreateButton:Enable();
		else
			CalendarCreateEventCreateButton:Disable();
		end
		--CalendarCreateEventCreateButton_SetText(CALENDAR_CREATE);
	elseif ( CalendarCreateEventFrame.mode == "edit" ) then
		if ( CalendarEventHaveSettingsChanged() and not CalendarIsActionPending() ) then
			CalendarCreateEventCreateButton:Enable();
		else
			CalendarCreateEventCreateButton:Disable();
		end
		--CalendarCreateEventCreateButton_SetText(CALENDAR_UPDATE);
	end
end


-- CalendarMassInviteFrame

function CalendarMassInviteFrame_OnLoad(self)
	self:RegisterEvent("CALENDAR_ACTION_PENDING");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("ARENA_TEAM_UPDATE");

	local minLevel, maxLevel = CalendarDefaultGuildFilter();
	CalendarMassInviteGuildMinLevelEdit:SetNumber(minLevel);
	CalendarMassInviteGuildMaxLevelEdit:SetNumber(maxLevel);
	UIDropDownMenu_SetWidth(CalendarMassInviteGuildRankMenu, 100);

	-- try to fire off a guild roster event so we can properly update our guild options
	if ( IsInGuild() and GetNumGuildMembers() == 0 ) then
		GuildRoster();
	end
	-- do the same for arena teams
	for i = 1, MAX_ARENA_TEAMS do
		ArenaTeamRoster(i);
	end
	-- update the arena team section in order to fill initial data
	CalendarMassInviteArena_Update();
end

function CalendarMassInviteFrame_OnShow(self)
	CalendarFrame_PushModal(self);
	CalendarMassInviteGuild_Update();
	CalendarMassInviteArena_Update();
end

function CalendarMassInviteFrame_OnEvent(self, event, ...)
	if ( event == "GUILD_ROSTER_UPDATE" ) then
		local arg1 = ...;
		if ( arg1 ) then
			GuildRoster();
		end
	end
	if ( self:IsShown() ) then
		if ( not CanEditGuildEvent() and not IsInArenaTeam() ) then
			-- if we are no longer in a guild OR an arena team, we can't mass invite
			CalendarMassInviteFrame:Hide();
			CalendarCreateEventMassInviteButton_Update();
		else
			if ( event == "CALENDAR_ACTION_PENDING" ) then
				CalendarMassInviteGuild_Update();
				CalendarMassInviteArena_Update();
			elseif ( event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_GUILD_UPDATE" ) then
				CalendarMassInviteGuild_Update();
			elseif ( event == "ARENA_TEAM_UPDATE" ) then
				CalendarMassInviteArena_Update();
			end
		end
	end
end

function CalendarMassInviteFrame_OnUpdate(self)
	CalendarMassInviteGuild_Update();
	CalendarMassInviteArena_Update();
end

function CalendarMassInviteGuild_Update()
	if ( CalendarCanSendInvite() and CanEditGuildEvent() ) then
		-- enable the accept button
		CalendarMassInviteGuildAcceptButton:Enable();
		-- set the selected rank
		if ( not CalendarMassInviteFrame.selectedRank or CalendarMassInviteFrame.selectedRank > GuildControlGetNumRanks() ) then
			local _, _, rank = CalendarDefaultGuildFilter();
			CalendarMassInviteFrame.selectedRank = rank;
		end
		-- enable and initialize the rank drop down
		UIDropDownMenu_EnableDropDown(CalendarMassInviteGuildRankMenu);
		UIDropDownMenu_Initialize(CalendarMassInviteGuildRankMenu, CalendarMassInviteGuildRankMenu_Initialize);
		-- set text color back to normal
		CalendarMassInviteGuildLevelText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		CalendarMassInviteGuildMinLevelEdit:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		CalendarMassInviteGuildMaxLevelEdit:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		CalendarMassInviteGuildRankText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	else
		-- disable the accept button
		CalendarMassInviteGuildAcceptButton:Disable();
		-- disable the rank drop down
		UIDropDownMenu_DisableDropDown(CalendarMassInviteGuildRankMenu);
		-- set text color to a disabled color
		CalendarMassInviteGuildLevelText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		CalendarMassInviteGuildMinLevelEdit:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		CalendarMassInviteGuildMaxLevelEdit:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		CalendarMassInviteGuildRankText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end

function CalendarMassInviteGuildRankMenu_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	for i = 1, GuildControlGetNumRanks() do
		info.text = GuildControlGetRankName(i);
		info.func = CalendarMassInviteGuildRankMenu_OnClick;
		if ( i == CalendarMassInviteFrame.selectedRank ) then
			info.checked = 1;
			UIDropDownMenu_SetText(CalendarMassInviteGuildRankMenu, info.text);
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function CalendarMassInviteGuildRankMenu_OnClick(self)
	CalendarMassInviteFrame.selectedRank = self:GetID();
	UIDropDownMenu_SetSelectedID(CalendarMassInviteGuildRankMenu, CalendarMassInviteFrame.selectedRank);
end

function CalendarMassInviteGuildAcceptButton_OnClick(self)
	local minLevel = CalendarMassInviteGuildMinLevelEdit:GetNumber();
	local maxLevel = CalendarMassInviteGuildMaxLevelEdit:GetNumber();
	CalendarMassInviteGuild(minLevel, maxLevel, CalendarMassInviteFrame.selectedRank);
	CalendarMassInviteFrame:Hide();
end

local ARENA_TEAMS = {2, 3, 5};
function CalendarMassInviteArena_Update()
	-- initialize the teams
	local teamName, teamSize;
	local button;
	for i = 1, MAX_ARENA_TEAMS do
		button = _G["CalendarMassInviteArenaButton"..ARENA_TEAMS[i]];
		button.teamName = nil;
		button:Disable();
	end

	-- set the teams
	local canSendInvite = CalendarCanSendInvite();
	for i = 1, MAX_ARENA_TEAMS do
		teamName, teamSize = GetArenaTeam(i);
		if ( canSendInvite and teamName ) then
			button = _G["CalendarMassInviteArenaButton"..teamSize];
			button:SetFormattedText(PVP_TEAMTYPE, teamSize, teamSize);
			button.teamName = teamName;
			button:SetID(i);
			button:Enable();
		end
	end

	-- optimization note: using two separate init and set loops yields less redundancy and less branches than two nested loops
end

function CalendarMassInviteArenaButton_OnLoad(self)
	local teamSize = ARENA_TEAMS[self:GetID()];
	self:SetFormattedText(PVP_TEAMTYPE, teamSize, teamSize);
end

function CalendarMassInviteArenaButton_OnClick(self)
	CalendarMassInviteArenaTeam(self:GetID());
	CalendarMassInviteFrame:Hide();
end

function CalendarMassInviteArenaButton_OnEnter(self)
	if ( self.teamName ) then
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
		GameTooltip:SetText(self.teamName);
	end
end


-- CalendarEventPickerFrame

function CalendarEventPickerFrame_OnLoad(self)
	self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST");
	self.dayButton = nil;
	self.selectedEvent = nil;
end

function CalendarEventPickerFrame_OnEvent(self, event, ...)
	if ( self:IsShown() and event == "CALENDAR_UPDATE_EVENT_LIST" and self.dayButton ) then
		CalendarEventPickerScrollFrame_Update();
	end
end

function CalendarEventPickerFrame_Show(dayButton)
	CalendarEventPickerFrame.dayButton = dayButton;
	CalendarEventPickerFrame:ClearAllPoints();
	if ( _CalendarFrame_GetDayOfWeek(dayButton:GetID()) > 4 ) then
		CalendarEventPickerFrame:SetPoint("TOPRIGHT", dayButton, "TOPLEFT");
	else
		CalendarEventPickerFrame:SetPoint("TOPLEFT", dayButton, "TOPRIGHT");
	end
	CalendarContextMenu_Hide();
	CalendarEventPickerFrame:Show();
	CalendarEventPickerScrollBar:SetValue(0);
	CalendarEventPickerScrollFrame_Update();
end

function CalendarEventPickerFrame_Hide()
	CalendarContextMenu_Hide(CalendarDayContextMenu_Initialize);
	CalendarEventPickerFrame.dayButton = nil;
	CalendarEventPickerFrame:Hide();
	-- clean up texture references
	for i = 1, #CalendarEventPickerScrollFrame.buttons do
		_G[CalendarEventPickerScrollFrame.buttons[i]:GetName().."Icon"]:SetTexture();
	end
end

function CalendarEventPickerFrame_Toggle(dayButton)
	if ( CalendarEventPickerFrame:IsShown() ) then
		CalendarEventPickerFrame_Hide();
	else
		CalendarEventPickerFrame_Show(dayButton);
	end
end

function CalendarEventPickerFrame_SetSelectedEvent(eventButton)
	if ( CalendarEventPickerFrame.selectedEventButton ) then
		CalendarEventPickerFrame.selectedEventButton:UnlockHighlight();
	end
	CalendarEventPickerFrame.selectedEventButton = eventButton;
	if ( CalendarEventPickerFrame.selectedEventButton ) then
		CalendarEventPickerFrame.selectedEventButton:LockHighlight();
	end
end

function CalendarEventPickerScrollFrame_OnLoad(self)
	HybridScrollFrame_OnLoad(self);
	-- register the addon loaded event for post-load fixups
	self:RegisterEvent("ADDON_LOADED");
	self:SetScript("OnEvent", CalendarEventPickerScrollFrame_OnEvent);
end

function CalendarEventPickerScrollFrame_OnEvent(self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		local addonName = ...;
		if ( not addonName or (addonName and addonName ~= "Blizzard_Calendar") ) then
			return;
		end

		local scrollBar = self.scrollBar;
		scrollBar.Show =
			function (self)
				local scrollFrame = self:GetParent();
				local scrollBarWidth = self:GetWidth();
				-- adjust scroll frame width
				local scrollFrameWidth = scrollFrame.defaultWidth - scrollBarWidth;
				scrollFrame:SetWidth(scrollFrameWidth);
				scrollFrame.scrollChild:SetWidth(scrollFrameWidth);
				-- adjust button width
				local buttonWidth = scrollFrame.defaultButtonWidth - scrollBarWidth;
				for _, button in next, scrollFrame.buttons do
					button:SetWidth(buttonWidth);
				end
				getmetatable(self).__index.Show(self);
			end
		scrollBar.Hide =
			function (self)
				local scrollFrame = self:GetParent();
				-- adjust scroll frame width
				local scrollFrameWidth = scrollFrame.defaultWidth;
				scrollFrame:SetWidth(scrollFrameWidth);
				scrollFrame.scrollChild:SetWidth(scrollFrameWidth);
				-- adjust button width
				local buttonWidth = scrollFrame.defaultButtonWidth;
				for _, button in next, scrollFrame.buttons do
					button:SetWidth(buttonWidth);
				end
				getmetatable(self).__index.Hide(self);
			end

		self.update = CalendarEventPickerScrollFrame_Update;
		HybridScrollFrame_CreateButtons(self, "CalendarEventPickerButtonTemplate");

		local scrollBarWidth = scrollBar:GetWidth();
		self.defaultWidth = self:GetWidth() + scrollBarWidth;
		self.defaultButtonWidth = self.buttons[1]:GetWidth() + scrollBarWidth;

		-- we don't need this event any more
		self:UnregisterEvent(event);
	end
end

function CalendarEventPickerScrollFrame_Update()
	local dayButton = CalendarEventPickerFrame.dayButton;
	local monthOffset = dayButton.monthOffset;
	local day = dayButton.day;
	local numViewableEvents = dayButton.numViewableEvents;
	if ( numViewableEvents <= CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS ) then
		CalendarEventPickerFrame_Hide();
		return;
	end

	-- since we aren't displaying ongoing events, we need to count all ongoing events towards the offset
	-- if they come before the offset
	local offset = HybridScrollFrame_GetOffset(CalendarEventPickerScrollFrame);
	local eventIndex = 1 + offset;
	for i=1, offset do
		local title, hour, minute, calendarType, sequenceType = CalendarGetDayEvent(monthOffset, day, i);
		if ( title and sequenceType == "ONGOING" ) then
			eventIndex = eventIndex + 1;
		end
	end

	-- only check the selected event index if we're looking at the right month
	local selectedEventMonthOffset, selectedEventDay, selectedEventIndex = CalendarGetEventIndex();
	if ( selectedEventIndex <= 0 or
		 day ~= selectedEventDay or monthOffset ~= selectedEventMonthOffset ) then
		selectedEventIndex = nil;
	end

	-- now fill in the buttons starting from the already-offset event index
	local buttons = CalendarEventPickerScrollFrame.buttons;
	local numButtons = #buttons;
	local buttonHeight = buttons[1]:GetHeight();
	local displayedHeight = 0;

	local numEvents = CalendarGetNumDayEvents(monthOffset, day);

	local button, buttonName, buttonIcon, buttonTitle, buttonTime;
	local texturePath, tcoords;
	local eventColor;
	local i = 1;
	while ( i <= numButtons and eventIndex <= numEvents ) do
		local title, hour, minute, calendarType, sequenceType, eventType, texture,
			modStatus, inviteStatus, invitedBy, difficulty, inviteType,
			sequenceIndex, numSequenceDays, difficultyName = CalendarGetDayEvent(monthOffset, day, eventIndex);
		if ( sequenceType ~= "ONGOING" ) then
			-- pretend like ongoing events aren't even in the event list
			button = buttons[i];
			if ( title ) then
				buttonName = button:GetName();
				buttonIcon = _G[buttonName.."Icon"];
				buttonTitle = _G[buttonName.."Title"];
				buttonTime = _G[buttonName.."Time"];

				button.eventIndex = eventIndex;

				-- set event texture
				buttonIcon:SetTexture();
				texturePath, tcoords = _CalendarFrame_GetTextureFile(texture, calendarType, sequenceType, eventType);
				if ( texturePath and texturePath ~= "" ) then
					buttonIcon:SetTexture(texturePath);
					buttonIcon:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
					buttonIcon:Show();
					buttonTitle:SetPoint("TOPLEFT", buttonIcon, "TOPRIGHT");
				else
					buttonIcon:Hide();
					buttonTitle:SetPoint("TOPLEFT", button, "TOPLEFT");
				end

				-- set event title and time
				if ( calendarType == "HOLIDAY" ) then
					buttonTime:Hide();
					buttonTitle:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT");
				else
					if ( calendarType == "RAID_RESET" or calendarType == "RAID_LOCKOUT" ) then
						title = GetDungeonNameWithDifficulty(title, difficultyName);
					end
					buttonTime:SetText(GameTime_GetFormattedTime(hour, minute, true));
					buttonTime:Show();
					buttonTitle:SetPoint("BOTTOMLEFT", buttonTime, "BOTTOMLEFT");
				end
				buttonTitle:SetFormattedText(CALENDAR_CALENDARTYPE_NAMEFORMAT[calendarType][sequenceType], title);
				-- set event color
				eventColor = _CalendarFrame_GetEventColor(calendarType, modStatus, inviteStatus);
				buttonTitle:SetTextColor(eventColor.r, eventColor.g, eventColor.b);

				-- set selected event
				if ( selectedEventIndex and eventIndex == selectedEventIndex ) then
					CalendarEventPickerFrame_SetSelectedEvent(button);
				else
					button:UnlockHighlight();
				end

				button:Show();
			else
				-- non-existent events, unlike ongoing events, will take up button slots to indicate
				-- holes in the event list (though the holes should all be at the end)
				button.eventIndex = nil;
				button:Hide();
			end
			i = i + 1;
			displayedHeight = displayedHeight + buttonHeight;
		end
		eventIndex = eventIndex + 1;
	end
	-- hide any unused buttons
	while ( i <= numButtons ) do
		button = buttons[i];
		button.eventIndex = nil;
		button:Hide();
		i = i + 1;
	end
	local totalHeight = numViewableEvents * buttonHeight;
	HybridScrollFrame_Update(CalendarEventPickerScrollFrame, totalHeight, displayedHeight);
end

function CalendarEventPickerCloseButton_OnClick()
	CalendarEventPickerFrame_Hide();
end

function CalendarEventPickerButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function CalendarEventPickerButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		CalendarEventPickerButton_Click(self);
		CalendarContextMenu_Hide();
	elseif ( button == "RightButton" ) then
		local dayButton = CalendarEventPickerFrame.dayButton;

		local eventChanged =
			CalendarContextMenu.eventButton ~= self or
			CalendarContextMenu.dayButton ~= dayButton;

		local flags = CALENDAR_CONTEXTMENU_FLAG_SHOWEVENT;
		if ( eventChanged ) then
			CalendarContextMenu_Show(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton, self);
		else
			CalendarContextMenu_Toggle(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton, self);
		end
	end

	PlaySound("igMainMenuOptionCheckBoxOn");
end

function CalendarEventPickerButton_Click(button)
	-- select the event
	CalendarEventPickerFrame_SetSelectedEvent(button);

	local eventIndex = button.eventIndex;
	local dayButton = CalendarEventPickerFrame.dayButton;

	-- search for the corresponding event button on the calendar frame if the event changed
	local dayButtonName = dayButton:GetName();
	local dayEventButton;
	for i = 1, CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS do
		local curDayEventButton = _G[dayButtonName.."EventButton"..i];
		if ( curDayEventButton.eventIndex and curDayEventButton.eventIndex == eventIndex ) then
			dayEventButton = curDayEventButton;
			break;
		end
	end
	if ( dayEventButton ) then
		-- if we found the day event button then click it...
		CalendarDayEventButton_Click(dayEventButton, true);
	else
		CalendarFrame_SetSelectedEvent();
		--...otherwise this event is not visible on the calendar, only the picker, so we need to do the selection
		-- work that would have otherwise happened by clicking the calendar event button
		StaticPopup_Hide("CALENDAR_DELETE_EVENT");
		CalendarFrame_OpenEvent(dayButton, eventIndex);
	end
end

function CalendarEventPickerButton_OnDoubleClick(self, button)
	CalendarEventPickerButton_OnClick(self, button);
	CalendarEventPickerCloseButton_OnClick();
end


-- CalendarTexturePickerFrame

function CalendarTexturePickerFrame_OnLoad(self)
	self.selectedTextureIndex = nil;
	CalendarTexturePickerScrollFrame.update = CalendarTexturePickerScrollFrame_Update;
	HybridScrollFrame_CreateButtons(CalendarTexturePickerScrollFrame, "CalendarTexturePickerButtonTemplate");
end

function CalendarTexturePickerFrame_Show(eventType)
	if ( not eventType ) then
		return;
	end
	if ( eventType ~= CalendarTexturePickerFrame.eventType) then
		if ( not _CalendarFrame_CacheEventTextures(eventType) ) then
			return;
		end
		-- new event type...reset the selected texture
		CalendarTexturePickerFrame.selectedTextureIndex = nil;
		CalendarTexturePickerFrame.eventType = eventType;
	else
		CalendarTexturePickerFrame.selectedTextureIndex = CalendarCreateEventFrame.selectedTextureIndex;
	end
	CalendarTexturePickerFrame:Show();
	CalendarTexturePickerFrame_Update();
end

function CalendarTexturePickerFrame_Hide()
	CalendarTexturePickerFrame.eventType = nil;
	CalendarTexturePickerFrame.selectedTextureIndex = nil;
	CalendarTexturePickerFrame:Hide();
	-- clean up texture references
	for i = 1, #CalendarTexturePickerScrollFrame.buttons do
		_G[CalendarTexturePickerScrollFrame.buttons[i]:GetName().."Icon"]:SetTexture();
	end
end

function CalendarTexturePickerFrame_Toggle(eventType)
	if ( CalendarTexturePickerFrame:IsShown() ) then
		CalendarTexturePickerFrame_Hide();
	else
		CalendarTexturePickerFrame_Show(eventType);
	end
end

function CalendarTexturePickerFrame_Update()
	if ( not CalendarTexturePickerFrame.eventType ) then
		CalendarTexturePickerFrame_Hide();
		return;
	end

	CalendarTexturePickerTitleFrame_Update();
	CalendarTexturePickerScrollFrame_Update();
end

function CalendarTexturePickerTitleFrame_Update()
	if ( CalendarTexturePickerFrame.eventType == CALENDAR_EVENTTYPE_RAID ) then
		CalendarTitleFrame_SetText(CalendarTexturePickerTitleFrame, CALENDAR_TEXTURE_PICKER_TITLE_RAID);
	else
		CalendarTitleFrame_SetText(CalendarTexturePickerTitleFrame, CALENDAR_TEXTURE_PICKER_TITLE_DUNGEON);
	end
end

function CalendarTexturePickerScrollFrame_OnLoad(self)
	HybridScrollFrame_OnLoad(self);
	-- register the addon loaded event for post-load fixups
	self:RegisterEvent("ADDON_LOADED");
	self:SetScript("OnEvent", CalendarTexturePickerScrollFrame_OnEvent);
end

function CalendarTexturePickerScrollFrame_OnEvent(self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		local addonName = ...;
		if ( not addonName or (addonName and addonName ~= "Blizzard_Calendar") ) then
			return;
		end

		local scrollBar = self.scrollBar;
		scrollBar.Show =
			function (self)
				local scrollFrame = self:GetParent();
				local scrollBarWidth = self:GetWidth();
				-- adjust scroll frame width
				local scrollFrameWidth = scrollFrame.defaultWidth - scrollBarWidth;
				scrollFrame:SetWidth(scrollFrameWidth);
				scrollFrame.scrollChild:SetWidth(scrollFrameWidth);
				-- adjust button width
				local buttonWidth = scrollFrame.defaultButtonWidth - scrollBarWidth;
				for _, button in next, scrollFrame.buttons do
					button:SetWidth(buttonWidth);
				end
				getmetatable(self).__index.Show(self);
			end
		scrollBar.Hide =
			function (self)
				local scrollFrame = self:GetParent();
				-- adjust scroll frame width
				local scrollFrameWidth = scrollFrame.defaultWidth;
				scrollFrame:SetWidth(scrollFrameWidth);
				scrollFrame.scrollChild:SetWidth(scrollFrameWidth);
				-- adjust button width
				local buttonWidth = scrollFrame.defaultButtonWidth;
				for _, button in next, scrollFrame.buttons do
					button:SetWidth(buttonWidth);
				end
				getmetatable(self).__index.Hide(self);
			end

		self.update = CalendarTexturePickerScrollFrame_Update;
		HybridScrollFrame_CreateButtons(self, "CalendarTexturePickerButtonTemplate");

		local scrollBarWidth = scrollBar:GetWidth();
		self.defaultWidth = self:GetWidth() + scrollBarWidth;
		self.defaultButtonWidth = self.buttons[1]:GetWidth() + scrollBarWidth;

		-- we don't need this event any more
		self:UnregisterEvent(event);
	end
end

function CalendarTexturePickerScrollFrame_Update()
	local buttons = CalendarTexturePickerScrollFrame.buttons;
	local numButtons = #buttons;
	local buttonHeight = buttons[1]:GetHeight();
	local displayedHeight = 0;

	local button, buttonName, buttonIcon, buttonTitle;
	local eventTex, textureIndex;
	local selectedTextureIndex = CalendarTexturePickerFrame.selectedTextureIndex;
	local eventType = CalendarTexturePickerFrame.eventType;
	local numTextures = #CalendarEventTextureCache;
	local offset = HybridScrollFrame_GetOffset(CalendarTexturePickerScrollFrame);
	for i = 1, numButtons do
		button = buttons[i];
		buttonName = button:GetName();
		textureIndex = i + offset;
		eventTex = CalendarEventTextureCache[textureIndex];
		if ( eventTex ) then
			buttonIcon = _G[buttonName.."Icon"];
			buttonTitle = _G[buttonName.."Title"];

			if ( eventTex.textureIndex ) then
				-- this is a texture

				-- record the textureIndex in the button
				button.textureIndex = eventTex.textureIndex;
				-- set the selected dungeon
				if ( selectedTextureIndex and button.textureIndex == selectedTextureIndex ) then
					button:LockHighlight();
					CalendarTexturePickerFrame.selectedTexture = button;
				else
					button:UnlockHighlight();
				end

				-- set the eventTex title
				local name = eventTex.title;
				buttonTitle:SetText(GetDungeonNameWithDifficulty(name, eventTex.difficultyName));
				buttonTitle:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				buttonTitle:ClearAllPoints();
				buttonTitle:SetPoint("LEFT", buttonIcon, "RIGHT");
				buttonTitle:Show();
				-- set the eventTex icon
				buttonIcon:SetTexture();
				local tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
				buttonIcon:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
				if ( eventTex.texture ~= "" ) then
					buttonIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURE_PATHS[eventType]..eventTex.texture);
				else
					buttonIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventType]);
				end
				buttonIcon:Show();
				-- make this button selectable
				button:Enable();
			elseif ( eventTex.expansionLevel and eventTex.expansionLevel >= 0 ) then
				-- this is a header

				-- record the textureIndex in the button
				button.textureIndex = eventTex.textureIndex;

				-- set the header title
				buttonTitle:SetText(eventTex.title);
				buttonTitle:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				buttonTitle:ClearAllPoints();
				buttonTitle:SetPoint("LEFT", buttonIcon, "LEFT");
				buttonTitle:Show();
				-- hide the icon
				buttonIcon:Hide();
				-- make this button unselectable
				button:Disable();
			else
				-- this is a blank space
				buttonTitle:Hide();
				buttonIcon:Hide();
				button:Disable();
			end

			button:Show();
		else
			button.textureIndex = nil;
			button:Hide();
		end
		displayedHeight = displayedHeight + buttonHeight;
	end
	local totalHeight = numTextures * buttonHeight;
	HybridScrollFrame_Update(CalendarTexturePickerScrollFrame, totalHeight, displayedHeight);
end

function CalendarTexturePickerAcceptButton_OnClick(self)
	CalendarCreateEventFrame.selectedTextureIndex = CalendarTexturePickerFrame.selectedTextureIndex;
	if ( CalendarCreateEventFrame.selectedTextureIndex ) then
		-- now that we've selected a texture, we can set the create event data
		local eventType = CalendarTexturePickerFrame.eventType;
		CalendarEventSetType(eventType);
		CalendarEventSetTextureID(CalendarCreateEventFrame.selectedTextureIndex);
		-- update the create event frame using our selection
		UIDropDownMenu_SetSelectedID(CalendarCreateEventTypeDropDown, eventType);
		CalendarCreateEventFrame.selectedEventType = eventType;
		CalendarCreateEventTexture_Update();
		CalendarTexturePickerFrame:Hide();

		CalendarCreateEventCreateButton_Update();
	end
end

function CalendarTexturePickerButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function CalendarTexturePickerButton_OnClick(self, button)
	if ( CalendarTexturePickerFrame.selectedTexture ) then
		CalendarTexturePickerFrame.selectedTexture:UnlockHighlight();
	end
	CalendarTexturePickerFrame.selectedTexture = self;
	CalendarTexturePickerFrame.selectedTextureIndex = self.textureIndex;
	self:LockHighlight();

	PlaySound("igMainMenuOptionCheckBoxOn");
end

function CalendarTexturePickerButton_OnDoubleClick(self, button)
	CalendarTexturePickerButton_OnClick(self, button);
	CalendarTexturePickerAcceptButton_OnClick(self);
end


-- Calendar Class Buttons

function CalendarClassButtonContainer_Show(parent)
	if ( CalendarClassButtonContainer:GetParent() ~= parent ) then
		CalendarClassButtonContainer:SetParent(parent);
		CalendarClassButtonContainer:ClearAllPoints();
		CalendarClassButtonContainer:SetPoint("TOPLEFT", parent, "TOPRIGHT", -2, -30);
	end
	CalendarClassButtonContainer:Show();
	_CalendarFrame_UpdateClassData();
	CalendarClassButtonContainer_Update();
end

function CalendarClassButtonContainer_Hide()
	CalendarClassButtonContainer:SetParent(nil);
	CalendarClassButtonContainer:Hide();
end

function CalendarClassButtonContainer_Update()
	if ( not CalendarClassButtonContainer:IsShown() ) then
		return;
	end

	local isModal = CalendarFrame_GetModal();

	local button, buttonName, buttonIcon, buttonCount;
	local classData, count;
	local totalCount = 0;
	for i, class in ipairs(CLASS_SORT_ORDER) do
		button = _G["CalendarClassButton"..i];
		buttonName = button:GetName();
		buttonCount = _G[buttonName.."Count"];
		buttonIcon = button:GetNormalTexture();
		-- set the count
		classData = CalendarClassData[class];
		count = classData.counts[CALENDAR_INVITESTATUS_CONFIRMED] + 
			classData.counts[CALENDAR_INVITESTATUS_ACCEPTED] + 
			classData.counts[CALENDAR_INVITESTATUS_SIGNEDUP];
		buttonCount:SetText(count);
		if ( count > 0 ) then
			buttonCount:Show();
			if ( isModal ) then
				SetDesaturation(buttonIcon, true);
				button:Disable();
			else
				SetDesaturation(buttonIcon, false);
				button:Enable();
			end
		else
			buttonCount:Hide();
			SetDesaturation(buttonIcon, true);
			button:Disable();
		end
		-- adjust the total
		totalCount = totalCount + count;
	end

	-- set the total
	CalendarClassTotalsText:SetText(totalCount);
	CalendarClassTotalsButton_Update();
end

function CalendarClassButtonContainer_OnLoad(self)
	local button, buttonName, buttonIcon;
	local classData, tcoords;

	for i, class in ipairs(CLASS_SORT_ORDER) do
		-- create button
		button = CreateFrame("Button", "CalendarClassButton"..i, self, "CalendarClassButtonTemplate");
		if ( i == 1 ) then
			button:SetPoint("TOPLEFT", self, "TOPLEFT");
		else
			button:SetPoint("TOPLEFT", "CalendarClassButton"..(i-1), "BOTTOMLEFT", 0, -12);
		end
		-- get class data
		classData = CalendarClassData[class];
		-- set texture
		buttonIcon = button:GetNormalTexture();
		buttonIcon:SetDrawLayer("BORDER");
		tcoords = classData.tcoords;
		buttonIcon:SetTexCoord(tcoords[1], tcoords[2], tcoords[3], tcoords[4]);
		-- set class
		button.class = class;
	end
	CalendarClassTotalsButton:SetPoint("TOPLEFT", "CalendarClassButton"..MAX_CLASSES, "BOTTOMLEFT", 0, -12);
end

function CalendarClassButton_OnLoad(self)
	self:Disable();
end

function CalendarClassButton_OnEnter(self)
	-- TODO: set detailed counts info
	local classData = CalendarClassData[self.class];
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(classData.name, nil, nil, nil, nil, 1);
	GameTooltip:Show();
end
--[[
function CalendarClassTotalsButton_OnLoad(self)
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
end

function CalendarClassTotalsButton_OnEvent(self, event, ...)
	if ( self:IsShown() and event == "PARTY_MEMBERS_CHANGED" ) then
		if ( CalendarEventGetNumInvites() > MAX_PARTY_MEMBERS + 1 and GetRealNumPartyMembers() >= 1 and GetRealNumRaidMembers() == 0 ) then
			-- we don't have a good way of knowing in advance whether or not we need a raid to accomodate all our invites
			-- so we're going to create a raid as soon as possible
			ConvertToRaid();
		end
		CalendarClassTotalsButton_Update();
	end
end

function CalendarClassTotalsButton_Update()
	if ( CalendarFrame_GetModal() ) then
		CalendarClassTotalsButton:Disable();
		CalendarInviteToGroupDropDown:Hide();
		CalendarClassTotalsButton:SetDisabledFontObject(GameFontDisableSmall);
		CalendarClassTotalsButtonOnEnterDummy:Hide();
	else
		if ( CalendarClassButtonContainer:GetParent() == CalendarCreateEventFrame and
			 CalendarCreateEventFrame.mode == "edit" and
			 GetRealNumPartyMembers() == 0 and GetRealNumRaidMembers() == 0 ) then
			CalendarClassTotalsButton:Enable();
			CalendarClassTotalsButtonOnEnterDummy:Hide();
		else
			CalendarClassTotalsButton:Disable();
			CalendarInviteToGroupDropDown:Hide();
			CalendarClassTotalsButtonOnEnterDummy:Show();
		end
		CalendarClassTotalsButton:SetDisabledFontObject(GameFontGreenSmall);
	end
end

function CalendarClassTotalsButton_OnClick(self)
	ToggleDropDownMenu(1, nil, CalendarInviteToGroupDropDown, self, 0, 0);
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function CalendarClassTotalsButtonOnEnterDummy_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(CALENDAR_TOOLTIP_INVITE_TOTALS, nil, nil, nil, nil, 1);
	GameTooltip:Show();
end

function CalendarClassTotalsButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if ( CalendarEventGetNumInvites() > MAX_PARTY_MEMBERS + 1 ) then
		GameTooltip:SetText(CALENDAR_TOOLTIP_INVITEMEMBERS_BUTTON_RAID, nil, nil, nil, nil, 1);
	else
		GameTooltip:SetText(CALENDAR_TOOLTIP_INVITEMEMBERS_BUTTON_PARTY, nil, nil, nil, nil, 1);
	end
	GameTooltip:Show();
end

function CalendarInviteToGroupDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(CalendarInviteToGroupDropDown, CalendarInviteToGroupDropDown_Initialize, "MENU");
	UIDropDownMenu_SetWidth(CalendarInviteToGroupDropDown, 100);
end

function CalendarInviteToGroupDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = CALENDAR_INVITE_CONFIRMED;
	info.func = CalendarInviteToGroupDropDown_Confirmed_OnClick;
	UIDropDownMenu_AddButton(info);

	info.text = CALENDAR_INVITE_ALL;
	info.func = CalendarInviteToGroupDropDown_All_OnClick;
	UIDropDownMenu_AddButton(info);
end

function CalendarInviteToGroupDropDown_Confirmed_OnClick(self)
	local name, level, className, classFilename, inviteStatus, modStatus;
	local inviteCount = min(MAX_RAID_MEMBERS - GetRealNumRaidMembers(), CalendarEventGetNumInvites());
	for i = 1, inviteCount do
		name, level, className, classFilename, inviteStatus, modStatus = CalendarEventGetInvite(i);
		if ( not UnitInParty(name) and not UnitInRaid(name) and
			 (inviteStatus == CALENDAR_INVITESTATUS_ACCEPTED or inviteStatus == CALENDAR_INVITESTATUS_CONFIRMED) ) then
			InviteUnit(name);
		end
	end
end

function CalendarInviteToGroupDropDown_All_OnClick(self)
	local inviteCount = min(MAX_RAID_MEMBERS - GetRealNumRaidMembers(), CalendarEventGetNumInvites());
	for i = 1, inviteCount do
		local name = CalendarEventGetInvite(i);
		if ( not UnitInParty(name) and not UnitInRaid(name) ) then
			InviteUnit(name);
		end
	end
end
--]]

function CalendarClassTotalsButton_Update()
	if ( CalendarFrame_GetModal() ) then
		CalendarClassTotalsButton:Disable();
		CalendarClassTotalsText:SetFontObject(GameFontDisableSmall);
	else
		CalendarClassTotalsButton:Enable();
		CalendarClassTotalsText:SetFontObject(GameFontGreenSmall);
	end
end

function CalendarClassTotalsButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(CALENDAR_TOOLTIP_INVITE_TOTALS, nil, nil, nil, nil, 1);
	GameTooltip:Show();
end

