
-- static popups
StaticPopupDialogs["CALENDAR_DELETE_EVENT"] = {
	text = "%s",
	button1 = OKAY,
	button2 = CANCEL,
	whileDead = 1,
	OnAccept = function (self)
		C_Calendar.ContextMenuEventRemove();
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
CALENDAR_FRAME_EXTRA_WIDTH = 20;
UIPanelWindows["CalendarFrame"] = { area = "doublewide", pushable = 0, whileDead = 1, yOffset = 20, extraWidth = CALENDAR_FRAME_EXTRA_WIDTH };

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

CalendarEventTypeNames =
{
	[Enum.CalendarEventType.Raid] = CALENDAR_TYPE_RAID,
	[Enum.CalendarEventType.Dungeon] = CALENDAR_TYPE_DUNGEON,
	[Enum.CalendarEventType.PvP] = CALENDAR_TYPE_PVP,
	[Enum.CalendarEventType.Meeting] = CALENDAR_TYPE_MEETING,
	[Enum.CalendarEventType.Other] = CALENDAR_TYPE_OTHER,
	[Enum.CalendarEventType.HeroicDeprecated] = CALENDAR_TYPE_DUNGEON,
};

-- this function will attempt to close the first open menu in the CalendarMenus table
function CloseCalendarMenus()
	for _, menuName in next, CalendarMenus do
		local menu = _G[menuName];
		if ( menu and menu:IsShown() ) then
			if ( menu == CalendarFrame_GetEventFrame() ) then
				CalendarFrame_CloseEvent();
				PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
			else
				menu:Hide();
			end
			return true;
		end
	end
	return false;
end

-- tab handling
local tabFocusGroup = nil;
function CalendarOnEditBoxTab(editBox)
	if not tabFocusGroup then
		tabFocusGroup = CreateTabGroup(
			CalendarCreateEventTitleEdit,
			CalendarCreateEventDescriptionContainer.ScrollingEditBox:GetEditBox(),
			CalendarCreateEventInviteEdit
		);
	end
	local preventFocusWrap = false;
	tabFocusGroup:OnTabPressed(preventFocusWrap);
end

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
local CALENDAR_CREATEEVENTFRAME_DEFAULT_TYPE			= Enum.CalendarEventType.Other;
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

local CALENDAR_EVENTCOLOR_MODERATOR = {r=0.54, g=0.75, b=1.0};

local CALENDAR_CALENDARTYPE_TOOLTIP_NAMEFORMAT = {
	["PLAYER"] = {
		[""]				= "%s",
	},
	["GUILD_ANNOUNCEMENT"] = {
		[""]				= "%s",
	},
	["GUILD_EVENT"] = {
		[""]				= "%s",
	},
	["COMMUNITY_EVENT"] = {
		[""]				= "%s",
	},
	["SYSTEM"] = {
		[""]				= "%s",
	},
	["HOLIDAY"] = {
		["START"]			= CALENDAR_EVENTNAME_FORMAT_START,
		["END"]				= CALENDAR_EVENTNAME_FORMAT_END,
		[""]				= "%s",
		["ONGOING"]			= "%s",
	},
	["RAID_LOCKOUT"] = {
		[""]				= CALENDAR_EVENTNAME_FORMAT_RAID_LOCKOUT,
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
	["COMMUNITY_EVENT"] = {
		[""]				= "%s",
	},
	["SYSTEM"] = {
		[""]				= "%s",
	},
	["HOLIDAY"] = {
		["START"]			= "%s",
		["END"]				= "%s",
		[""]				= "%s",
		["ONGOING"]			= "%s",
	},
	["RAID_LOCKOUT"] = {
		[""]				= CALENDAR_EVENTNAME_FORMAT_RAID_LOCKOUT,
	},
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
	["COMMUNITY_EVENT"] = {
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
	["COMMUNITY_EVENT"] = {
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
};
local CALENDAR_CALENDARTYPE_COLORS = {
--	["PLAYER"]				= ,
--	["GUILD_ANNOUNCEMENT"]	= ,
--	["GUILD_EVENT"]			= ,
	["SYSTEM"]				= YELLOW_FONT_COLOR,
	["HOLIDAY"]				= HIGHLIGHT_FONT_COLOR,
	["RAID_LOCKOUT"]		= HIGHLIGHT_FONT_COLOR,
};

local CALENDAR_CALENDARTYPE_COLORS_TOOLTIP = {
	["HOLIDAY"]				= NORMAL_FONT_COLOR,
};

local CALENDAR_EVENTTYPE_TEXTURES = {
	[Enum.CalendarEventType.Raid]		= "Interface\\LFGFrame\\LFGIcon-Raid",
	[Enum.CalendarEventType.Dungeon]	= "Interface\\LFGFrame\\LFGIcon-Dungeon",
	[Enum.CalendarEventType.PvP]		= "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[Enum.CalendarEventType.Meeting]	= "Interface\\Calendar\\MeetingIcon",
	[Enum.CalendarEventType.Other]		= "Interface\\Calendar\\UI-Calendar-Event-Other",
};
local CALENDAR_EVENTTYPE_TCOORDS = {
	[Enum.CalendarEventType.Raid] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[Enum.CalendarEventType.Dungeon] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[Enum.CalendarEventType.PvP] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[Enum.CalendarEventType.Meeting] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[Enum.CalendarEventType.Other] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
};
do
	-- set the pvp icon to the player's faction
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup and factionGroup ~= "Neutral" ) then
		-- need new texcoords too?
		if ( factionGroup == "Alliance" ) then
			CALENDAR_EVENTTYPE_TEXTURES[Enum.CalendarEventType.PvP] = "Interface\\Calendar\\UI-Calendar-Event-PVP02";
		else
			CALENDAR_EVENTTYPE_TEXTURES[Enum.CalendarEventType.PvP] = "Interface\\Calendar\\UI-Calendar-Event-PVP01";
		end
	end
end

local CALENDAR_FILTER_CVARS = {
	{text = CALENDAR_FILTER_HOLIDAYS,			cvar = "calendarShowHolidays"		},
	{text = CALENDAR_FILTER_DARKMOON,			cvar = "calendarShowDarkmoon"		},
	{text = CALENDAR_FILTER_RAID_LOCKOUTS,		cvar = "calendarShowLockouts"		},
	{text = CALENDAR_FILTER_WEEKLY_HOLIDAYS,	cvar = "calendarShowWeeklyHolidays"	},
	{text = CALENDAR_FILTER_BATTLEGROUND,		cvar = "calendarShowBattlegrounds"	},
};

-- local data

-- CalendarDayButtons is just a table of all the Calendar day buttons...the size of this table should
-- equal CALENDAR_MAX_DAYS_PER_MONTH once the CalendarFrame is done loading
local CalendarDayButtons = { };

-- CalendarEventDungeonCache gets updated whenever event type textures are requested (currently only
-- the Dungeon and Raid event types have texture lists)
local CalendarEventDungeonCache = { };
local CalendarEventDungeonCacheType = nil;

-- CalendarClassData gets updated whenever the current event's invite list is updated
local CalendarClassData = { };
do
	for i, class in ipairs(CLASS_SORT_ORDER) do
		CalendarClassData[class] = {
			name = nil,
			tcoords = CLASS_ICON_TCOORDS[class],
			counts = {
				[Enum.CalendarStatus.Invited]		= 0,
				[Enum.CalendarStatus.Available]	= 0,
				[Enum.CalendarStatus.Declined]	= 0,
				[Enum.CalendarStatus.Confirmed]	= 0,
				[Enum.CalendarStatus.Out]			= 0,
				[Enum.CalendarStatus.Standby]		= 0,
				[Enum.CalendarStatus.Signedup]	= 0,
				[Enum.CalendarStatus.NotSignedup]	= 0,
				[Enum.CalendarStatus.Tentative]	= 0,
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

local function _CalendarFrame_GetFullDateFromDateInfo(dateInfo)
	return _CalendarFrame_GetFullDate(dateInfo.weekday, dateInfo.month, dateInfo.monthDay, dateInfo.year);
end

local function _CalendarFrame_GetFullDateFromDay(dayButton)
	local weekday = _CalendarFrame_GetWeekdayIndex(dayButton:GetID());
	local monthInfo = C_Calendar.GetMonthInfo(dayButton.monthOffset);
	local day = dayButton.day;
	return _CalendarFrame_GetFullDate(weekday, monthInfo.month, day, monthInfo.year);
end

local function _CalendarFrame_IsTodayOrLater(month, day, year)
	local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
	local presentWeekday = currentCalendarTime.weekday;
	local presentMonth = currentCalendarTime.month;
	local presentDay = currentCalendarTime.monthDay;
	local presentYear = currentCalendarTime.year;
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
	local date = C_Calendar.GetMaxCreateDate();
	local maxWeekday = date.weekday;
	local maxMonth = date.month;
	local maxDay = date.monthDay;
	local maxYear = date.year;
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
		calendarType == "GUILD_EVENT" or
		calendarType == "COMMUNITY_EVENT";
end

local function _CalendarFrame_CanInviteeRSVP(inviteStatus)
	return
		inviteStatus == Enum.CalendarStatus.Invited or
		inviteStatus == Enum.CalendarStatus.Available or
		inviteStatus == Enum.CalendarStatus.Declined or
		inviteStatus == Enum.CalendarStatus.Signedup or
		inviteStatus == Enum.CalendarStatus.NotSignedup or
		inviteStatus == Enum.CalendarStatus.Tentative;
end

local function _CalendarFrame_IsSignUpEvent(calendarType, inviteType)
	return (calendarType == "GUILD_EVENT" or calendarType == "COMMUNITY_EVENT") and inviteType == Enum.CalendarInviteType.Signup;
end

local function _CalendarFrame_CanRemoveEvent(modStatus, calendarType, inviteType, inviteStatus)
	return
		modStatus ~= "CREATOR" and
		(calendarType == "PLAYER" or ((calendarType == "GUILD_EVENT" or calendarType == "COMMUNITY_EVENT") and inviteType == Enum.CalendarInviteType.Normal));
end

local function _CalendarFrame_CacheEventDungeons_Internal(eventType, textures)
	wipe(CalendarEventDungeonCache);

	local numTextures = #textures;
	if ( numTextures <= 0 ) then
		return false;
	end

	local overlappingMapIDs = (eventType == Enum.CalendarEventType.Raid or eventType == Enum.CalendarEventType.Dungeon) and {};

	local cacheIndex = 1;
	for textureIndex = 1, numTextures do
		if ( not CalendarEventDungeonCache[cacheIndex] ) then
			CalendarEventDungeonCache[cacheIndex] = { };
		end

		local textureInfo = textures[textureIndex];

		local title = textureInfo.title;
		local texture = textureInfo.iconTexture;
		local expansionLevel = textureInfo.expansionLevel;
		local difficultyID = textureInfo.difficultyId;
		local mapID = textureInfo.mapId;
		local isLFR = textureInfo.isLfr;
		local difficultyName, instanceType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID = GetDifficultyInfo(difficultyID);
		if not difficultyName then
			difficultyName = "";
		end

		if overlappingMapIDs and overlappingMapIDs[mapID] then
			-- Already exists a map, collapse the difficulty
			local firstCacheIndex = overlappingMapIDs[mapID];
			local cacheEntry = CalendarEventDungeonCache[firstCacheIndex];

			if cacheEntry.isLFR and not isLFR then
				-- Prefer a non-LFR name over a LFR name
				cacheEntry.title = title;
				cacheEntry.isLFR = nil;
			end

			if cacheEntry.displayHeroic or cacheEntry.displayMythic and (not displayHeroic and not displayMythic) then
				-- Prefer normal difficulty name over higher difficulty
				cacheEntry.title = title;
				cacheEntry.displayHeroic = nil;
				cacheEntry.displayMythic = nil;
			end

			table.insert(cacheEntry.difficulties, { textureIndex = textureIndex, difficultyName = difficultyName });
		else
			CalendarEventDungeonCache[cacheIndex].textureIndex = textureIndex;
			CalendarEventDungeonCache[cacheIndex].title = title;
			CalendarEventDungeonCache[cacheIndex].texture = texture;
			CalendarEventDungeonCache[cacheIndex].expansionLevel = expansionLevel;
			CalendarEventDungeonCache[cacheIndex].difficultyName = difficultyName;
			CalendarEventDungeonCache[cacheIndex].isLFR = isLFR;
			CalendarEventDungeonCache[cacheIndex].displayHeroic = displayHeroic;
			CalendarEventDungeonCache[cacheIndex].displayMythic = displayMythic;

			if overlappingMapIDs then
				if not overlappingMapIDs[mapID] then
					overlappingMapIDs[mapID] = cacheIndex;
				end
				CalendarEventDungeonCache[cacheIndex].difficulties = { { textureIndex = textureIndex, difficultyName = difficultyName } };
			end

			cacheIndex = cacheIndex + 1;
		end
	end

	local cacheIndex = 1;
	while cacheIndex < #CalendarEventDungeonCache do
		-- insert headers between expansion levels
		local entry = CalendarEventDungeonCache[cacheIndex];
		local prevEntry = CalendarEventDungeonCache[cacheIndex - 1];

		if ( entry.expansionLevel and (not prevEntry or (prevEntry.expansionLevel and prevEntry.expansionLevel ~= entry.expansionLevel)) ) then
			-- insert empty entry...
			if ( prevEntry ) then
				--...only if we had a previous entry
				table.insert(CalendarEventDungeonCache, cacheIndex, {});
				cacheIndex = cacheIndex + 1;
			end
			-- insert header
			table.insert(CalendarEventDungeonCache, cacheIndex, {
				title = _G["EXPANSION_NAME"..entry.expansionLevel],
				expansionLevel = entry.expansionLevel,
			});
			cacheIndex = cacheIndex + 1;
		end

		cacheIndex = cacheIndex + 1;
	end

	return true;
end

local function _CalendarFrame_CacheEventDungeons(eventType)
	if ( eventType ~= CalendarEventDungeonCacheType ) then
		CalendarEventDungeonCacheType = eventType;
		if ( eventType ) then
			return  _CalendarFrame_CacheEventDungeons_Internal(eventType, C_Calendar.EventGetTextures(eventType));
		end
	end
	return true;
end

local function _CalendarFrame_GetEventDungeonCacheEntry(index, eventType)
	if ( not _CalendarFrame_CacheEventDungeons(eventType) ) then
		return nil;
	end
	for cacheIndex = 1, #CalendarEventDungeonCache do
		local entry = CalendarEventDungeonCache[cacheIndex];
		if ( entry.difficulties ) then
			for i, difficultyInfo in ipairs(entry.difficulties) do
				if difficultyInfo.textureIndex == index then
					return entry, difficultyInfo;
				end
			end
		end
		if ( entry.textureIndex and index == entry.textureIndex ) then
			return entry;
		end
	end
	return nil;
end

local function _CalendarFrame_GetTextureCoords(calendarType, eventType)
	local tcoords;
	if ( calendarType == "HOLIDAY" ) then
		tcoords = CALENDAR_CALENDARTYPE_TCOORDS[calendarType];
	else
		tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
	end
	return tcoords;
end

local function _CalendarFrame_GetEventColor(calendarType, modStatus, inviteStatus, tooltip)
	if ( calendarType == "PLAYER" or calendarType == "GUILD_ANNOUNCEMENT" or calendarType == "GUILD_EVENT"  or calendarType == "COMMUNITY_EVENT") then
		if ( modStatus == "MODERATOR" or modStatus == "CREATOR" ) then
			return CALENDAR_EVENTCOLOR_MODERATOR;
		elseif ( inviteStatus and CALENDAR_INVITESTATUS_INFO[inviteStatus] ) then
			return CALENDAR_INVITESTATUS_INFO[inviteStatus].color;
		end
	elseif ( tooltip and CALENDAR_CALENDARTYPE_COLORS_TOOLTIP[calendarType] ) then
		return CALENDAR_CALENDARTYPE_COLORS_TOOLTIP[calendarType];
	elseif ( CALENDAR_CALENDARTYPE_COLORS[calendarType] ) then
		return CALENDAR_CALENDARTYPE_COLORS[calendarType];
	end
	-- default to normal color
	return NORMAL_FONT_COLOR;
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

	for i = 1, C_Calendar.GetNumInvites() do
		local inviteInfo = C_Calendar.EventGetInvite(i);
		if ( inviteInfo.classFilename and inviteInfo.classFilename ~= "" ) then
			CalendarClassData[inviteInfo.classFilename].counts[inviteInfo.inviteStatus] = (CalendarClassData[inviteInfo.classFilename].counts[inviteInfo.inviteStatus] or 0) + 1;
			-- HACK: doing this because we don't have class names in global strings
			CalendarClassData[inviteInfo.classFilename].name = inviteInfo.className;
		end
	end
end

local function _CalendarFrame_InviteToRaid(maxInviteCount)
	local inviteCount = 0;
	local i = 1;
	local playerName = UnitName("player");
	while ( inviteCount < maxInviteCount and i <= C_Calendar.GetNumInvites() ) do
		local inviteInfo = C_Calendar.EventGetInvite(i);
		if ( inviteInfo.name ~= playerName and not UnitInParty(inviteInfo.name) and not UnitInRaid(inviteInfo.name) and
			 (inviteInfo.inviteStatus == Enum.CalendarStatus.Available or
			 inviteInfo.inviteStatus == Enum.CalendarStatus.Confirmed or
			 inviteInfo.inviteStatus == Enum.CalendarStatus.Signedup or
			 inviteInfo.inviteStatus == Enum.CalendarStatus.Tentative)  ) then
			C_PartyInfo.InviteUnit(inviteInfo.name);
			inviteCount = inviteCount + 1;
		end
		i = i + 1;
	end
	return inviteCount;
end

local function _CalendarFrame_GetInviteToRaidCount(maxInviteCount)
	local inviteCount = 0;
	local i = 1;
	while ( inviteCount < maxInviteCount and i <= C_Calendar.GetNumInvites() ) do
		local inviteInfo = C_Calendar.EventGetInvite(i);
		if ( not UnitInParty(inviteInfo.name) and not UnitInRaid(inviteInfo.name) and
			 (inviteInfo.inviteStatus == Enum.CalendarStatus.Available or
			 inviteInfo.inviteStatus == Enum.CalendarStatus.Confirmed or
			 inviteInfo.inviteStatus == Enum.CalendarStatus.Signedup or
			 inviteInfo.inviteStatus == Enum.CalendarStatus.Tentative) ) then
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
			CalendarEventPickerFrame_Update();
		end
		CalendarFrame.militaryTime = militaryTime;
	end
end

function CalendarFrame_OnLoad(self)
	self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST");
--	self:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES");		-- event list updates are fired for invite status changes now
	self:RegisterEvent("CALENDAR_OPEN_EVENT");
	self:RegisterEvent("CALENDAR_UPDATE_ERROR");
	self:RegisterEvent("CALENDAR_UPDATE_ERROR_WITH_COUNT");
	self:RegisterEvent("CALENDAR_UPDATE_ERROR_WITH_PLAYER_NAME");

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
		elseif ( calendarType == "RAID_LOCKOUT" ) then
			CalendarFrame_ShowEventFrame(CalendarViewRaidFrame);
		else
			-- for now, it could only be a player-created type
			if ( C_Calendar.EventCanEdit() ) then
				CalendarCreateEventFrame.mode = "edit";
				CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
			else
				CalendarFrame_ShowEventFrame(CalendarViewEventFrame);
			end
		end
	elseif ( event == "CALENDAR_UPDATE_ERROR" ) then
		local message = ...;
		StaticPopup_Show("CALENDAR_ERROR", _G[message]);
	elseif ( event == "CALENDAR_UPDATE_ERROR_WITH_COUNT" ) then
		local message, count = ...;
		StaticPopup_Show("CALENDAR_ERROR", _G[message]:format(count));
	elseif ( event == "CALENDAR_UPDATE_ERROR_WITH_PLAYER_NAME" ) then
		local message, playerName = ...;
		StaticPopup_Show("CALENDAR_ERROR", _G[message]:format(playerName));
	end
end

function CalendarFrame_OnShow(self)
	-- an event could have stayed selected if the calendar closed without the player doing so explicitly
	-- (e.g. reloadui) so make sure that we're not selecting an event when the calendar comes back
	CalendarFrame_CloseEvent();

	self.militaryTime = GetCVarBool("timeMgrUseMilitaryTime");

	local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
	C_Calendar.SetAbsMonth(currentCalendarTime.month, currentCalendarTime.year);
	CalendarFrame_Update();

	C_Calendar.OpenCalendar();

	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
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

	C_Calendar.SetNextClubId(nil);
	PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE);
end

function CalendarFrame_OnMouseWheel(self, value)
	if ( value > 0 ) then
		if ( CalendarPrevMonthButton:IsEnabled() ) then
			CalendarPrevMonthButton_OnClick();
		end
	else
		if ( CalendarNextMonthButton:IsEnabled() ) then
			CalendarNextMonthButton_OnClick();
		end
	end
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
	local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
	local presentWeekday = currentCalendarTime.weekday;
	local presentMonth = currentCalendarTime.month;
	local presentDay = currentCalendarTime.monthDay;
	local presentYear = currentCalendarTime.year;
	local monthInfo = C_Calendar.GetMonthInfo(-1);
	local prevMonth = monthInfo.month;
	local prevYear = monthInfo.year;
	local prevNumDays = monthInfo.numDays;
	monthInfo = C_Calendar.GetMonthInfo(1);
	local nextMonth = monthInfo.month;
	local nextYear = monthInfo.year;
	local nextNumDays = monthInfo.numDays;
	monthInfo = C_Calendar.GetMonthInfo();
	local month = monthInfo.month;
	local year = monthInfo.year;
	local numDays = monthInfo.numDays;
	local firstWeekday = monthInfo.firstWeekday;

	-- update the viewed month
	CalendarFrame.viewedMonth = month;
	CalendarFrame.viewedYear = year;

	-- get selected elements
	local selectedMonth = CalendarFrame.selectedMonth;
	local selectedDay = CalendarFrame.selectedDay;
	local selectedYear = CalendarFrame.selectedYear;
	local indexInfo = C_Calendar.GetEventIndex();
	local selectedEventMonthOffset = indexInfo ~= nil and indexInfo.offsetMonths or 0;
	local selectedEventDay = indexInfo ~= nil and indexInfo.monthDay or 0;
	local selectedEventIndex = indexInfo ~= nil and indexInfo.eventIndex or 0;
	indexInfo = C_Calendar.ContextMenuGetEventIndex();
	local contextEventMonthOffset = indexInfo ~= nil and indexInfo.offsetMonths or 0;
	local contextEventDay = indexInfo ~= nil and indexInfo.monthDay or 0;
	local contextEventIndex = indexInfo ~= nil and indexInfo.eventIndex or 0;

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

local function ShouldDisplayEventOnCalendar(event)
	local shouldDisplayBeginEnd = event and event.sequenceType ~= "ONGOING";
	if ( event.sequenceType == "END" and event.dontDisplayEnd ) then
		shouldDisplayBeginEnd = false;
	end
	return shouldDisplayBeginEnd;
end

function CalendarFrame_UpdateDayEvents(index, day, monthOffset, selectedEventIndex, contextEventIndex)
	local dayButton = CalendarDayButtons[index];
	local dayButtonName = dayButton:GetName();

	local numEvents = C_Calendar.GetNumDayEvents(monthOffset, day);

	-- turn pending invite on if we have one on this day
	local pendingInviteIndex = C_Calendar.GetFirstPendingInvite(monthOffset, day);
	local pendingInviteTex = _G[dayButtonName.."PendingInviteTexture"];
	if ( pendingInviteIndex ) then
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
		local event = C_Calendar.GetDayEvent(monthOffset, day, i);
		if ( event ) then
			if ( event.calendarType == "HOLIDAY" and not firstHolidayIndex ) then
				-- record the first holiday index...the first holiday can have sequenceType "ONGOING"
				firstHolidayIndex = i;
			end
			if ( event.sequenceType ~= "ONGOING" ) then
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

		local event = C_Calendar.GetDayEvent(monthOffset, day, eventIndex);

		if ( ShouldDisplayEventOnCalendar(event) ) then
			local date = (event.sequenceType == "END") and event.endTime or event.startTime;
			-- set the event button if the sequence type is not ongoing

			-- record the event Index
			eventButton.eventIndex = eventIndex;

			-- Some events have custom titles; some have string keys
			local eventTitle = event.isCustomTitle and event.title or _G[event.title];

			-- set the event button size
			eventButton:SetHeight(buttonHeight);
			-- set the event time and title
			if ( event.calendarType == "HOLIDAY" ) then
				-- any event that does not display the time should go here
				eventButtonText2:Hide();
				eventButtonText1:SetFormattedText(CALENDAR_CALENDARTYPE_NAMEFORMAT[event.calendarType][event.sequenceType], eventTitle);
				eventButtonText1:ClearAllPoints();
				eventButtonText1:SetAllPoints(eventButton);
				eventButtonText1:Show();
			elseif ( event.calendarType == "RAID_LOCKOUT" ) then
				eventButtonText2:Hide();
				-- Lockouts pass in a title string; resets pass in a string key
				local title = GetDungeonNameWithDifficulty(eventTitle, event.difficultyName);
				eventButtonText1:SetFormattedText(CALENDAR_CALENDARTYPE_NAMEFORMAT[event.calendarType][event.sequenceType], title);
				eventButtonText1:ClearAllPoints();
				eventButtonText1:SetAllPoints(eventButton);
				eventButtonText1:Show();
			else
				eventButtonText2:SetText(GameTime_GetFormattedTime(date.hour, date.minute, showingBigEvents));
				eventButtonText2:ClearAllPoints();
				eventButtonText2:SetPoint(text2Point, eventButton, text2Point);
				eventButtonText2:SetJustifyH(text2JustifyH);
				eventButtonText2:Show();
				eventButtonText1:SetFormattedText(CALENDAR_CALENDARTYPE_NAMEFORMAT[event.calendarType][event.sequenceType], eventTitle);
				eventButtonText1:ClearAllPoints();
				eventButtonText1:SetPoint("TOPLEFT", eventButton, "TOPLEFT");
				if ( text1RelPoint ) then
					eventButtonText1:SetPoint("BOTTOMRIGHT", eventButtonText2, text1RelPoint);
				end
				eventButtonText1:Show();
			end
			-- set the event color
			eventColor = _CalendarFrame_GetEventColor(event.calendarType, event.modStatus, event.inviteStatus);
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
	local monthOffset, day = dayButton.monthOffset, dayButton.day;
	local tcoords;

	local eventBackgroundTex = _G[dayButtonName.."EventBackgroundTexture"];
	local eventTex = _G[dayButtonName.."EventTexture"];
	if ( firstEventButton ) then
		dayButton.firstEventButton = firstEventButton;

		-- anchor the top of the event background to the first event button since it is always
		-- the highest button
		eventBackgroundTex:SetPoint("TOP", firstEventButton, "TOP", 0, 40);
		eventBackgroundTex:SetPoint("BOTTOM", dayButton, "BOTTOM");
		eventBackgroundTex:Show();

		-- set day texture
		local event = C_Calendar.GetDayEvent(monthOffset, day, firstEventButton.eventIndex);
		eventTex:SetTexture();
		tcoords = _CalendarFrame_GetTextureCoords(event.calendarType, event.eventType);
		if ( event.iconTexture ) then
			eventTex:SetTexture(event.iconTexture);
			eventTex:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
			eventTex:Show();
		else
			eventTex:Hide();
		end
	else
		eventBackgroundTex:Hide();
		eventTex:Hide();
		dayButton.firstEventButton = nil;
	end

	-- set overlay texture
	local overlayTex = _G[dayButtonName.."OverlayFrameTexture"];
	if ( firstHolidayIndex ) then
		-- for now, the overlay texture is the first holiday's sequence texture
		local event = C_Calendar.GetDayEvent(monthOffset, day, firstHolidayIndex);
		if ( event.numSequenceDays > 2 and not event.dontDisplayBanner ) then
			-- by art/design request, we're not going to show sequence textures if the sequence only lasts up to 2 days
			overlayTex:SetTexture();
			tcoords = _CalendarFrame_GetTextureCoords(event.calendarType, event.eventType);
			if ( event.iconTexture ) then
				overlayTex:SetTexture(event.iconTexture);
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
	C_Calendar.OpenEvent(monthOffset, day, eventIndex);
end

function CalendarFrame_CloseEvent()
	C_Calendar.CloseEvent();
	CalendarFrame_HideEventFrame();
	CalendarDayEventButton_Click();
end

function CalendarFrame_OffsetMonth(offset)
	C_Calendar.SetMonth(offset);
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

	local date = C_Calendar.GetMinDate();
	local testWeekday = date.weekday;
	local testMonth = date.month;
	local testDate = date.monthDay;
	local testYear = date.year;
	CalendarPrevMonthButton:Enable();
	if ( CalendarFrame.viewedYear <= testYear ) then
		if ( CalendarFrame.viewedMonth <= testMonth ) then
			CalendarPrevMonthButton:Disable();
		end
	end
	-- the max create date is the max date we're going to allow people to view
	date = C_Calendar.GetMaxCreateDate();
	testWeekday = date.weekday;
	testMonth = date.month;
	testDay = date.monthDay;
	testYear = date.year;
	CalendarNextMonthButton:Enable();
	if ( CalendarFrame.viewedYear >= testYear ) then
		if ( CalendarFrame.viewedMonth >= testMonth ) then
			CalendarNextMonthButton:Disable();
		end
	end
end

function CalendarFrame_OpenToGuildEventIndex(guildEventIndex)
	if ( CalendarFrame and CalendarFrame:IsShown() ) then
		-- if the calendar is already open we need to do some work that's normally happening in CalendarFrame_OnShow
		local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
		C_Calendar.SetAbsMonth(currentCalendarTime.month, currentCalendarTime.year);
	else
		ToggleCalendar();
	end
	local info = C_Calendar.GetGuildEventSelectionInfo(guildEventIndex);
	local monthOffset = info.offsetMonth;
	local day = info.monthDay;
	local eventIndex = info.eventIndex;
	if ( monthOffset ) then
		C_Calendar.SetMonth(monthOffset);
	end
	-- need to highlight the proper day/event in calendar
	local monthInfo = C_Calendar.GetMonthInfo();
	local firstDay = monthInfo.firstWeekday;
	local buttonIndex = day + firstDay - CALENDAR_FIRST_WEEKDAY;
	if ( firstDay < CALENDAR_FIRST_WEEKDAY ) then
		buttonIndex = buttonIndex + 7;
	end
	local dayButton = _G["CalendarDayButton"..buttonIndex];
	CalendarDayButton_Click(dayButton);
	if ( eventIndex <= 4 ) then -- can only see 4 events per day
		local eventButton = _G["CalendarDayButton"..buttonIndex.."EventButton"..eventIndex];
		CalendarDayEventButton_Click(eventButton, true);	-- true to open the event
	else
		CalendarFrame_SetSelectedEvent();	-- clears any event highlights
		C_Calendar.OpenEvent(0, day, eventIndex);
	end
end

function CalendarPrevMonthButton_OnClick()
	PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
	CalendarFrame_OffsetMonth(-1);
end

function CalendarNextMonthButton_OnClick()
	PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
	CalendarFrame_OffsetMonth(1);
end

function CalendarFilterButton_OnMouseDown(self)
	ToggleDropDownMenu(1, nil, CalendarFilterDropDown, self, 0, 0);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
		info.isNotRadio = true;
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
	SetCVar(CALENDAR_FILTER_CVARS[self:GetID()].cvar, UIDropDownMenuButton_GetChecked(self) and "1" or "0");
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
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
		PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
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
	local monthInfo = C_Calendar.GetMonthInfo(monthOffset);
	local month = monthInfo.month;
	local year = monthInfo.year;

	-- record whether or not
	local isTodayOrLater = _CalendarFrame_IsTodayOrLater(month, day, year);
	local isAfterMaxDate = _CalendarFrame_IsAfterMaxCreateDate(month, day, year);
	local validCreationDate = isTodayOrLater and not isAfterMaxDate;

	local canPaste = validCreationDate and C_Calendar.ContextMenuEventClipboard();

	local showDay = validCreationDate and band(flags, CALENDAR_CONTEXTMENU_FLAG_SHOWDAY) ~= 0;
	local showEvent = eventButton and band(flags, CALENDAR_CONTEXTMENU_FLAG_SHOWEVENT) ~= 0;

	local needSpacer = false;
	if ( showDay ) then
		UIMenu_AddButton(self, CALENDAR_CREATE_EVENT, nil, CalendarDayContextMenu_CreateEvent);

		-- add guild selections if the player has a guild
		if ( IsInGuild() ) then
			UIMenu_AddButton(self, CALENDAR_CREATE_GUILD_EVENT, nil, CalendarDayContextMenu_CreateGuildEvent);

			if ( CanEditGuildEvent() ) then
				UIMenu_AddButton(self, CALENDAR_CREATE_GUILD_ANNOUNCEMENT, nil, CalendarDayContextMenu_CreateGuildAnnouncement);
			end
		end

		-- add community selections if the player is in a character community
		local clubs = C_Club.GetSubscribedClubs();
		for i, clubInfo in ipairs(clubs) do
			if clubInfo.clubType == Enum.ClubType.Character then
				UIMenu_AddButton(self, CALENDAR_CREATE_COMMUNITY_EVENT, nil, CalendarDayContextMenu_CreateCommunityEvent);
				break;
			end
		end

		needSpacer = true;
	end

	if ( showEvent ) then
		local eventIndex = eventButton.eventIndex;
		local event = C_Calendar.GetDayEvent(monthOffset, day, eventIndex);
		-- add context items for the selected event
		if ( _CalendarFrame_IsPlayerCreatedEvent(event.calendarType) ) then
			local canEdit = C_Calendar.ContextMenuEventCanEdit(monthOffset, day, eventIndex);
			local canRemove = C_Calendar.ContextMenuEventCanRemove(monthOffset, day, eventIndex);
			if ( canEdit ) then
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
			elseif ( canPaste ) then
				if ( needSpacer ) then
					UIMenu_AddButton(self, "");
				end
				-- paste
				UIMenu_AddButton(self, CALENDAR_PASTE_EVENT, nil, CalendarDayContextMenu_PasteEvent);
				needSpacer = true;
			end
			if ( canRemove ) then
				-- delete
				UIMenu_AddButton(self, CALENDAR_DELETE_EVENT, nil, CalendarDayContextMenu_DeleteEvent);
				needSpacer = true;
			end
			if ( event.calendarType ~= "GUILD_ANNOUNCEMENT" ) then
				if ( validCreationDate and _CalendarFrame_CanInviteeRSVP(event.inviteStatus) ) then
					-- spacer
					if ( _CalendarFrame_IsSignUpEvent(event.calendarType, event.inviteType) ) then
						-- We no longer show remove event in the dropdown, only Sign Up.
						if ( event.inviteStatus == Enum.CalendarStatus.NotSignedup ) then
							-- sign up
							if ( needSpacer ) then
								UIMenu_AddButton(self, "");
							end
							UIMenu_AddButton(self, CALENDAR_SIGNUP, nil, CalendarDayContextMenu_SignUp);
						end
					elseif ( event.modStatus ~= "CREATOR" ) then
						if ( needSpacer ) then
							UIMenu_AddButton(self, "");
						end
						-- accept invitation
						if ( event.inviteStatus ~= Enum.CalendarStatus.Available ) then
							UIMenu_AddButton(self, CALENDAR_ACCEPT_INVITATION, nil, CalendarDayContextMenu_AcceptInvite);
						end
						-- tentative invitation
						if ( event.inviteStatus ~= Enum.CalendarStatus.Tentative ) then
							UIMenu_AddButton(self, CALENDAR_TENTATIVE_INVITATION, nil, CalendarDayContextMenu_TentativeInvite);
						end
						-- decline invitation
						if ( event.inviteStatus ~= Enum.CalendarStatus.Declined ) then
							UIMenu_AddButton(self, CALENDAR_DECLINE_INVITATION, nil, CalendarDayContextMenu_DeclineInvite);
						end
					end
					needSpacer = false;
				end
				if ( _CalendarFrame_CanRemoveEvent(event.modStatus, event.calendarType, event.inviteType, event.inviteStatus) ) then
					-- spacer
					if ( needSpacer ) then
						UIMenu_AddButton(self, "");
					end
					-- remove event
					UIMenu_AddButton(self, CALENDAR_REMOVE_INVITATION, nil, CalendarDayContextMenu_RemoveInvite);
					needSpacer = true;
				end
			end
			if ( C_Calendar.ContextMenuEventCanComplain(monthOffset, day, eventIndex) ) then
				if ( needSpacer ) then
					UIMenu_AddButton(self, "");
				end
				-- report spam
				UIMenu_AddButton(self, REPORT_CALENDAR, nil, CalendarDayContextMenu_ReportSpam);
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
			C_Calendar.ContextMenuSelectEvent(monthOffset, day, eventButton.eventIndex);
			eventButton:LockHighlight();
		end
		return true;
	else
		-- show an error if they summoned a context menu that they could not create an event for, and
		-- there are no buttons on the context menu
		if ( not isTodayOrLater ) then
			StaticPopup_Show("CALENDAR_ERROR", CALENDAR_ERROR_CREATEDATE_BEFORE_TODAY);
		elseif ( isAfterMaxDate ) then
			StaticPopup_Show("CALENDAR_ERROR", format(CALENDAR_ERROR_CREATEDATE_AFTER_MAX, _CalendarFrame_GetFullDateFromDateInfo(C_Calendar.GetMaxCreateDate())));
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

function CalendarDayContextMenu_ClearEvent()
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
	C_Calendar.CloseEvent();
	CalendarFrame_HideEventFrame();
	CalendarDayButton_Click(CalendarContextMenu.dayButton);
end

function CalendarDayContextMenu_CreateEvent()
	CalendarDayContextMenu_ClearEvent();
	C_Calendar.CreatePlayerEvent();
	CalendarCreateEventFrame.mode = "create";
	CalendarCreateEventFrame.dayButton = CalendarContextMenu.dayButton;
	CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
end

function CalendarDayContextMenu_CreateGuildAnnouncement()
	CalendarDayContextMenu_ClearEvent();
	C_Calendar.CreateGuildAnnouncementEvent();
	CalendarCreateEventFrame.mode = "create";
	CalendarCreateEventFrame.dayButton = CalendarContextMenu.dayButton;
	CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
end

function CalendarDayContextMenu_CreateGuildEvent()
	CalendarDayContextMenu_ClearEvent();
	C_Calendar.CreateGuildSignUpEvent();
	CalendarCreateEventFrame.mode = "create";
	CalendarCreateEventFrame.dayButton = CalendarContextMenu.dayButton;
	CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
end

function CalendarDayContextMenu_CreateCommunityEvent()
	CalendarDayContextMenu_ClearEvent();
	C_Calendar.CreateCommunitySignUpEvent();
	CalendarCreateEventFrame.mode = "create";
	CalendarCreateEventFrame.dayButton = CalendarContextMenu.dayButton;
	CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
end

function CalendarDayContextMenu_CopyEvent()
	C_Calendar.ContextMenuEventCopy();
end

function CalendarDayContextMenu_PasteEvent()
	local dayButton = CalendarContextMenu.dayButton;
	C_Calendar.ContextMenuEventPaste(dayButton.monthOffset, dayButton.day);
end

function CalendarDayContextMenu_DeleteEvent()
	local text;
	local calendarType = C_Calendar.ContextMenuEventGetCalendarType();
	if ( calendarType == "GUILD_ANNOUNCEMENT" ) then
		text = CALENDAR_DELETE_ANNOUNCEMENT_CONFIRM;
	elseif ( calendarType == "GUILD_EVENT" ) then
		text = CALENDAR_DELETE_GUILD_EVENT_CONFIRM;
	elseif (calendarType == "COMMUNITY_EVENT") then
		text = CALENDAR_DELETE_COMMUNITY_EVENT_CONFIRM;
	else
		text = CALENDAR_DELETE_EVENT_CONFIRM;
	end
	StaticPopup_Show("CALENDAR_DELETE_EVENT", text);
end

function CalendarDayContextMenu_ReportSpam()
	reportInfo = ReportInfo:CreateReportInfoFromType(Enum.ReportType.Calendar);
	ReportFrame:InitiateReport(reportInfo);
end

function CalendarDayContextMenu_AcceptInvite()
	C_Calendar.ContextMenuInviteAvailable();
end

function CalendarDayContextMenu_TentativeInvite()
	C_Calendar.ContextMenuInviteTentative();
end

function CalendarDayContextMenu_DeclineInvite()
	C_Calendar.ContextMenuInviteDecline();
end

function CalendarDayContextMenu_RemoveInvite()
	C_Calendar.ContextMenuInviteRemove();
end

function CalendarDayContextMenu_SignUp()
	C_Calendar.ContextMenuEventSignUp();
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
	local numEvents = C_Calendar.GetNumDayEvents(monthOffset, day);
	if ( numEvents <= 0 ) then
		return;
	end

	local events = {};
	-- gather up the events we are going to show
	for i = 1, numEvents do
		local event = C_Calendar.GetDayEvent(monthOffset, day, i);
		if (event) then
			tinsert(events, event);
		end
	end
	-- sort by time, and ongoing events sort to the bottom
	table.sort(events, function(a, b)
		if ((a.sequenceType == "ONGOING") ~= (b.sequenceType == "ONGOING")) then
			return a.sequenceType ~= "ONGOING";
		elseif (a.sequenceType == "ONGOING" and a.sequenceIndex ~= b.sequenceIndex) then
			return a.sequenceIndex > b.sequenceIndex;
		end

		if (a.startTime.hour ~= b.startTime.hour) then
			return a.startTime.hour < b.startTime.hour;
		end

		return a.startTime.minute < b.startTime.minute;
	end)

	-- add events
	local eventTime, eventColor;
	local numShownEvents = 0;
	local numOngoingEvents = 0;
	for i, event in ipairs(events) do
		local title = event.title;
		if ( numShownEvents == 0 ) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:ClearLines();

			-- add date if we hit our first viewable event
			local fullDate = format(FULLDATE, _CalendarFrame_GetFullDateFromDay(self));
			GameTooltip:AddLine(fullDate, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			GameTooltip:AddLine(" ");
		elseif (numOngoingEvents == 0) then
			-- ongoing events don't have an extra space between them
			GameTooltip:AddLine(" ");
		end

		if (event.sequenceType == "ONGOING") then
			if (numOngoingEvents == 0) then
				-- Precede first ongoing event with Ongoing: label
				GameTooltip:AddLine(CALENDAR_TOOLTIP_ONGOING, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			end
			numOngoingEvents = numOngoingEvents + 1;
			-- display as date range
			eventTime = format(CALENDAR_TOOLTIP_DATE_RANGE, FormatShortDate(event.startTime.monthDay, event.startTime.month), FormatShortDate(event.endTime.monthDay, event.endTime.month));
		elseif (event.sequenceType == "END") then
			eventTime = GameTime_GetFormattedTime(event.endTime.hour, event.endTime.minute, true);
		else
			eventTime = GameTime_GetFormattedTime(event.startTime.hour, event.startTime.minute, true);
		end
		eventColor = _CalendarFrame_GetEventColor(event.calendarType, event.modStatus, event.inviteStatus, true);
		if ( event.calendarType == "RAID_LOCKOUT" ) then
			title = GetDungeonNameWithDifficulty(title, event.difficultyName);
		end
		GameTooltip:AddDoubleLine(
			format(CALENDAR_CALENDARTYPE_TOOLTIP_NAMEFORMAT[event.calendarType][event.sequenceType], title),
			eventTime,
			eventColor.r, eventColor.g, eventColor.b,
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
			1
		);
		if ( _CalendarFrame_IsPlayerCreatedEvent(event.calendarType) ) then
			local text;
			if ( UnitIsUnit("player", event.invitedBy) ) then
				if ( event.calendarType == "GUILD_ANNOUNCEMENT" ) then
					text = CALENDAR_ANNOUNCEMENT_CREATEDBY_YOURSELF;
				elseif ( event.calendarType == "GUILD_EVENT" ) then
					text = CALENDAR_GUILDEVENT_INVITEDBY_YOURSELF;
				elseif ( event.calendarType == "COMMUNITY_EVENT") then
					text = CALENDAR_COMMUNITYEVENT_INVITEDBY_YOURSELF;
				else
					text = CALENDAR_EVENT_INVITEDBY_YOURSELF;
				end
			else
				if ( _CalendarFrame_IsSignUpEvent(event.calendarType, event.inviteType) ) then
					local inviteStatusInfo = CalendarUtil.GetCalendarInviteStatusInfo(event.inviteStatus);
					if ( event.inviteStatus == Enum.CalendarStatus.NotSignedup or
							event.inviteStatus == Enum.CalendarStatus.Signedup ) then
						text = inviteStatusInfo.name;
					else
						text = format(CALENDAR_SIGNEDUP_FOR_GUILDEVENT_WITH_STATUS, inviteStatusInfo.name);
					end
				else
					if ( event.calendarType == "GUILD_ANNOUNCEMENT" ) then
						text = format(CALENDAR_ANNOUNCEMENT_CREATEDBY_PLAYER, _CalendarFrame_SafeGetName(event.invitedBy));
					else
						text = format(CALENDAR_EVENT_INVITEDBY_PLAYER, _CalendarFrame_SafeGetName(event.invitedBy));
					end
				end
			end
			GameTooltip:AddLine(text, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end

		numShownEvents = numShownEvents + 1;
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

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

-- CalendarDayButton_Click allows the OnClick for a day and its event buttons to do some of the same processing
function CalendarDayButton_Click(button)
	-- close the event picker if it doesn't belong to this day
	if ( CalendarEventPickerFrame.dayButton and CalendarEventPickerFrame.dayButton ~= button ) then
		CalendarEventPickerFrame_Hide();
	end

	local day, monthOffset = button.day, button.monthOffset;
	local monthInfo = C_Calendar.GetMonthInfo(monthOffset);
	local month = monthInfo.month;
	local year = monthInfo.year;
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
	local dayButton = self:GetParent();

	if ( button == "LeftButton" ) then
		CalendarDayButton_Click(dayButton);
		CalendarEventPickerFrame_Toggle(dayButton);
	elseif ( button == "RightButton" ) then
		local dayChanged = CalendarFrame.selectedDayButton ~= dayButton;

		local flags = CALENDAR_CONTEXTMENU_FLAG_SHOWDAY;
		if ( dayChanged ) then
			CalendarContextMenu_Show(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton);
		else
			CalendarContextMenu_Toggle(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton);
		end
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
	local indexInfo = C_Calendar.GetEventIndex();
	local selectedEventMonthOffset = indexInfo ~= nil and indexInfo.offsetMonths or 0;
	local selectedEventDay = indexInfo ~= nil and indexInfo.monthDay or 0;
	local selectedEventIndex = indexInfo ~= nil and indexInfo.eventIndex or 0;
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
	middleFrame:SetWidth(min(240, max(180, textFrame:GetWidth())));
	textFrame:SetWidth(middleFrame:GetWidth());
end


-- CalendarViewHolidayFrame

function CalendarViewHolidayFrame_Update()
	local indexInfo = C_Calendar.GetEventIndex();
	if(indexInfo) then
		local holidayInfo = C_Calendar.GetHolidayInfo(indexInfo.offsetMonths, indexInfo.monthDay, indexInfo.eventIndex);
		if (holidayInfo) then
			CalendarViewHolidayFrame.Header:Setup(holidayInfo.name);
			local description = holidayInfo.description;
			if (holidayInfo.startTime and holidayInfo.endTime) then
				description = format(CALENDAR_HOLIDAYFRAME_BEGINSENDS, description, FormatShortDate(holidayInfo.startTime.monthDay, holidayInfo.startTime.month), GameTime_GetFormattedTime(holidayInfo.startTime.hour, holidayInfo.startTime.minute, true), FormatShortDate(holidayInfo.endTime.monthDay, holidayInfo.endTime.month), GameTime_GetFormattedTime(holidayInfo.endTime.hour, holidayInfo.endTime.minute, true));
			end

			CalendarViewHolidayFrame.ScrollingFont:SetText(description);
			CalendarViewHolidayFrame.Texture:SetTexture();
			
			local texture = CALENDAR_CALENDARTYPE_TEXTURES["HOLIDAY"]["INFO"];
			local tcoords = CALENDAR_CALENDARTYPE_TCOORDS["HOLIDAY"];
			if ( texture ) then
				CalendarViewHolidayFrame.Texture:SetTexture(texture);
				CalendarViewHolidayFrame.Texture:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
				CalendarViewHolidayFrame.Texture:Show();
			else
				CalendarViewHolidayFrame.Texture:Hide();
			end
		end
	end
end

function CalendarViewHolidayFrame_OnLoad(self)
	self.update = CalendarViewHolidayFrame_Update;
	CalendarViewHolidayFrame.Texture:SetAlpha(0.4);
end

function CalendarViewHolidayFrame_OnShow(self)
	CalendarViewHolidayFrame_Update();
end

-- CalendarViewRaidFrame

function CalendarViewRaidFrame_OnLoad(self)
	self.update = CalendarViewRaidFrame_Update;
end

function CalendarViewRaidFrame_OnShow(self)
	CalendarViewRaidFrame_Update();
end

function CalendarViewRaidFrame_Update()
	local indexInfo = C_Calendar.GetEventIndex();
	local raidInfo = indexInfo and C_Calendar.GetRaidInfo(indexInfo.offsetMonths, indexInfo.monthDay, indexInfo.eventIndex);
	if raidInfo and raidInfo.calendarType == "RAID_LOCKOUT" then
		local name = GetDungeonNameWithDifficulty(raidInfo.name, raidInfo.difficultyName);
		CalendarViewRaidFrame.Header:Setup(name);

		CalendarViewRaidFrame.ScrollingFont:SetText(string.format(CALENDAR_RAID_LOCKOUT_DESCRIPTION, name, 
			GameTime_GetFormattedTime(raidInfo.time.hour, raidInfo.time.minute, true)));
	end
end

-- Calendar Event Templates

function CalendarEventCloseButton_OnClick(self)
	CalendarContextMenu_Hide();
	CalendarFrame_CloseEvent();
	PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
end

function CalendarEventInviteList_InitButtonShared(button, inviteIndex, inviteInfo)
	button.inviteIndex = inviteIndex;

	-- setup moderator status
	local buttonModIcon = button.ModIcon;
	if ( inviteInfo.modStatus == "CREATOR" ) then
		buttonModIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
		buttonModIcon:Show();
	elseif ( inviteInfo.modStatus == "MODERATOR" ) then
		buttonModIcon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
		buttonModIcon:Show();
	else
		buttonModIcon:SetTexture();
		buttonModIcon:Hide();
	end

	-- setup name
	-- NOTE: classFilename could be invalid when a character is being transferred
	local classColor = (inviteInfo.classFilename and RAID_CLASS_COLORS[inviteInfo.classFilename]) or NORMAL_FONT_COLOR;
	local buttonNameString = button.Name;
	buttonNameString:SetText(_CalendarFrame_SafeGetName(inviteInfo.name));
	buttonNameString:SetTextColor(classColor.r, classColor.g, classColor.b);

	-- setup class
	local buttonClass = button.Class;
	buttonClass:SetText(_CalendarFrame_SafeGetName(inviteInfo.className));
	buttonClass:SetTextColor(classColor.r, classColor.g, classColor.b);

	-- setup status
	local buttonStatus = button.Status;
	local inviteStatusInfo = CalendarUtil.GetCalendarInviteStatusInfo(inviteInfo.inviteStatus);
	buttonStatus:SetText(inviteStatusInfo.name);
	buttonStatus:SetTextColor(inviteStatusInfo.color.r, inviteStatusInfo.color.g, inviteStatusInfo.color.b);

	-- fixup anchors
	if ( buttonModIcon:IsShown() ) then
		buttonNameString:SetPoint("LEFT", buttonModIcon, "RIGHT");
	else
		buttonNameString:SetPoint("LEFT", button, "LEFT");
	end

	-- set the selected button
	local selectedInviteIndex = C_Calendar.EventGetSelectedInvite();
	if ( selectedInviteIndex and inviteIndex == selectedInviteIndex ) then
		CalendarCreateEventFrame_SetSelectedInvite(button);
	else
		button:UnlockHighlight();
	end
end

function CalendarEvent_InitManagedScrollBarVisibility(self, scrollBox, scrollBar)
	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
		CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -23, 3),
	};
	local scrollBoxAnchorsWithoutBar = {
		scrollBoxAnchorsWithBar[1],
		CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -5, 3),
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end

function CalendarCreateEventInviteList_OnLoad(self)
	self.sortButtons = {
		name = _G[self:GetName().."NameSortButton"],
		class = _G[self:GetName().."ClassSortButton"],
		status = _G[self:GetName().."StatusSortButton"],
	};

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CalendarCreateEventInviteListButtonTemplate", function(button, elementData)
		CalendarCreateEventInviteList_InitButton(button, elementData);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	CalendarEvent_InitManagedScrollBarVisibility(self, self.ScrollBox, self.ScrollBar);
end

function CalendarCreateEventInviteList_InitButton(button, elementData)
	local inviteIndex = elementData.index;
	local inviteInfo = C_Calendar.EventGetInvite(inviteIndex);
		
	CalendarEventInviteList_InitButtonShared(button, inviteIndex, inviteInfo);

	-- set the onclick handler based on the parent mode
	if ( CalendarCreateEventFrame.mode == "edit" ) then
		button:SetScript("OnEnter", CalendarEventInviteListButton_OnEnter);
	else
		button:SetScript("OnEnter", nil);
	end

	-- update class counts
	if ( inviteInfo.classFilename and inviteInfo.classFilename ~= "" ) then
		CalendarClassData[inviteInfo.classFilename].counts[inviteInfo.inviteStatus] = CalendarClassData[inviteInfo.classFilename].counts[inviteInfo.inviteStatus] + 1;
		-- MFS HACK: doing this because we don't have class names in global strings
		CalendarClassData[inviteInfo.classFilename].name = inviteInfo.className;
	end

	CalendarClassButtonContainer_Show(CalendarCreateEventFrame);
end

function CalendarViewEventInviteList_InitButton(button, elementData)
	local inviteIndex = elementData.index;
	local inviteInfo = C_Calendar.EventGetInvite(inviteIndex);

	CalendarEventInviteList_InitButtonShared(button, inviteIndex, inviteInfo);

	CalendarClassButtonContainer_Show(CalendarViewEventFrame);
end

function CalendarEventInviteList_AnchorSortButtons(inviteList)
	local frames = inviteList.ScrollBox:GetFrames();
	if #frames == 0 then
		return;
	end

	local inviteButton = frames[1];
	local nameSortButton = inviteList.sortButtons.name;
	local invitePartyIcon = inviteButton.PartyIcon;
	nameSortButton:SetPoint("LEFT", invitePartyIcon, "LEFT");
	
	local classSortButton = inviteList.sortButtons.class;
	local inviteClass = inviteButton.Class;
	classSortButton:SetPoint("LEFT", inviteClass, "LEFT");
	
	local statusSortButton = inviteList.sortButtons.status;
	local inviteSort = inviteButton.Status;
	statusSortButton:SetPoint("RIGHT", inviteSort, "RIGHT");
end

function CalendarEventInviteList_UpdateSortButtons(inviteList)
	local criterion, reverse = C_Calendar.EventGetInviteSortCriterion();
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
	C_Calendar.EventSortInvites(self.criterion, self.criterion == C_Calendar.EventGetInviteSortCriterion());
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	CalendarContextMenu_Hide(CalendarViewEventInviteContextMenu_Initialize);
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
end

function CalendarEventInviteListButton_OnEnter(self)
	if ( self.inviteIndex ) then
		local responseTime = C_Calendar.EventGetInviteResponseTime(self.inviteIndex);
		if ( responseTime and responseTime.weekday ~= 0 ) then
			GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
			GameTooltip:AddLine(CALENDAR_TOOLTIP_INVITE_RESPONDED);
			-- date
			GameTooltip:AddLine(
				format(FULLDATE, _CalendarFrame_GetFullDate(responseTime.weekday, responseTime.month, responseTime.monthDay, responseTime.year)),
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b
			);
			-- time
			GameTooltip:AddLine(
				GameTime_GetFormattedTime(responseTime.hour, responseTime.minute, true),
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
--	self:RegisterEvent("GROUP_ROSTER_UPDATE");

	self.update = CalendarViewEventFrame_Update;
	self.selectedInvite = nil;
	self.myInviteIndex = nil;

	self.defaultHeight = self:GetHeight();
end

function CalendarViewEventFrame_OnEvent(self, event, ...)
	if ( CalendarViewEventFrame:IsShown() ) then
		if ( event == "CALENDAR_UPDATE_EVENT" ) then
			CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
			if ( C_Calendar.EventCanEdit() ) then
				CalendarCreateEventFrame.mode = "edit";
				CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
			else
				CalendarViewEventFrame_Update();
			end
		elseif ( event == "CALENDAR_UPDATE_INVITE_LIST" ) then
			CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
			if ( C_Calendar.EventCanEdit() ) then
				CalendarCreateEventFrame.mode = "edit";
				CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
			else
				-- RSVP'ing to the event can induce an invite list update, so we
				-- need to do an RSVP update
				local eventInfo = C_Calendar.GetEventInfo();
				local month = eventInfo.time.month;
				local day = eventInfo.time.monthDay;
				local year = eventInfo.time.year;
				local pendingInvite = eventInfo.hasPendingInvite;
				local inviteStatus = eventInfo.inviteStatus;
				local inviteType = eventInfo.inviteType;
				local calendarType = eventInfo.calendarType;
				CalendarViewEventRSVP_Update(month, day, year, pendingInvite, inviteStatus, inviteType, calendarType);
				CalendarViewEventInviteList_Update(inviteType, calendarType);
			end
		elseif ( event == "CALENDAR_CLOSE_EVENT" ) then
			CalendarFrame_HideEventFrame(CalendarViewEventFrame);
		elseif ( event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_GUILD_UPDATE" ) then
			if ( C_Calendar.EventCanEdit() ) then
				-- our permissions changed and we can now edit this event
				CalendarCreateEventFrame.mode = "edit";
				CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
			end
--		elseif ( event == "GROUP_ROSTER_UPDATE" ) then
--			CalendarViewEventInviteList_Update();
		end
	end
end

function CalendarViewEventFrame_OnShow(self)
	CalendarViewEventFrame_Update();
end

function CalendarViewEventFrame_OnHide(self)
	CalendarContextMenu_Hide(CalendarViewEventInviteContextMenu_Initialize);
end

function CalendarViewEventDescriptionContainer_OnLoad(self)
	local scrollBox = self.ScrollingFont:GetScrollBox();
	ScrollUtil.InitScrollBar(scrollBox, self.ScrollBar);
	CalendarEvent_InitManagedScrollBarVisibility(self, scrollBox, self.ScrollBar);
end
 
function CalendarViewEventFrame_Update()
	local eventInfo = C_Calendar.GetEventInfo();
	if ( not eventInfo or not eventInfo.title ) then
		-- event was probably deleted
		CalendarFrame_HideEventFrame(CalendarViewEventFrame);
		CalendarClassButtonContainer_Hide();
		return;
	end
	-- record the invite type
	CalendarViewEventFrame.inviteType = eventInfo.inviteType;
	-- reset the flash timer to reinforce the visual feedback that the player is switching between events
	CalendarViewEventFlashTimer:Stop();
	-- set the icon
	CalendarViewEventIcon:SetTexture();
	local tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventInfo.eventType];
	CalendarViewEventIcon:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
	local dungeonCacheEntry, difficultyInfo = _CalendarFrame_GetEventDungeonCacheEntry(eventInfo.textureIndex, eventInfo.eventType);
	if ( dungeonCacheEntry ) then
		-- set the event type
		local name = dungeonCacheEntry.title;
		name = GetDungeonNameWithDifficulty(name, difficultyInfo and difficultyInfo.difficultyName or dungeonCacheEntry.difficultyName);
		CalendarViewEventTypeName:SetFormattedText(CALENDAR_VIEW_EVENTTYPE, CalendarEventTypeNames[eventInfo.eventType], name);
		-- set the dungeonCacheEntry texture
		if ( dungeonCacheEntry.texture ) then
			CalendarViewEventIcon:SetTexture(dungeonCacheEntry.texture);
		else
			CalendarViewEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventInfo.eventType]);
		end
	else
		-- set the event type
		CalendarViewEventTypeName:SetText(CalendarEventTypeNames[eventInfo.eventType]);
		CalendarViewEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventInfo.eventType]);
	end
	-- set the creator
	CalendarViewEventCreatorName:SetFormattedText(CALENDAR_EVENT_CREATORNAME, _CalendarFrame_SafeGetName(eventInfo.creator));
	-- set the date
	CalendarViewEventDateLabel:SetFormattedText(FULLDATE, _CalendarFrame_GetFullDate(eventInfo.time.weekday, eventInfo.time.month, eventInfo.time.monthDay, eventInfo.time.year));
	-- set the time
	CalendarViewEventTimeLabel:SetText(GameTime_GetFormattedTime(eventInfo.time.hour, eventInfo.time.minute, true));
	-- set the description
	CalendarViewEventDescriptionContainer.ScrollingFont:SetText(eventInfo.description);

	-- set the community or Guild name
	if ( eventInfo.calendarType == "GUILD_EVENT" or eventInfo.calendarType == "COMMUNITY_EVENT" ) then
		CalendarViewEventCommunityName:Show();
		CalendarViewEventCommunityName:SetText(eventInfo.communityName)
		CalendarViewEventTypeName:SetPoint("TOPLEFT", CalendarViewEventCommunityName, "BOTTOMLEFT")
		if ( eventInfo.calendarType == "GUILD_EVENT" ) then
			CalendarViewEventCommunityName:SetTextColor(GREEN_FONT_COLOR:GetRGB())
		else
			CalendarViewEventCommunityName:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
		end
	else
		CalendarViewEventCommunityName:Hide();
		CalendarViewEventTypeName:SetPoint("TOPLEFT", CalendarViewEventTitle, "BOTTOMLEFT")
	end

	-- change the look based on the locked status
	if ( eventInfo.isLocked ) then
		-- set the event title
		CalendarViewEventTitle:SetFormattedText(CALENDAR_VIEW_EVENTTITLE_LOCKED, eventInfo.title);
		SetDesaturation(CalendarViewEventIcon, true);
		CalendarViewEventTypeName:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		CalendarViewEventCreatorName:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		CalendarViewEventDescriptionContainer.ScrollingFont:SetTextColor(GRAY_FONT_COLOR);
	else
		-- set the event title
		CalendarViewEventTitle:SetText(eventInfo.title);
		SetDesaturation(CalendarViewEventIcon, false);
		CalendarViewEventTypeName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		CalendarViewEventCreatorName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		CalendarViewEventDescriptionContainer.ScrollingFont:SetTextColor(NORMAL_FONT_COLOR);
	end
	if ( eventInfo.calendarType == "GUILD_ANNOUNCEMENT" ) then
		CalendarViewEventFrame.Header:Setup(CALENDAR_VIEW_ANNOUNCEMENT);
		-- guild wide events don't have invite lists, auto approval, or event locks
		CalendarViewEventInviteListSection:Hide();
		CalendarViewEventFrame:SetHeight(CalendarViewEventFrame.defaultHeight - CalendarViewEventInviteListSection:GetHeight());
		CalendarClassButtonContainer_Hide();
	else
		if ( eventInfo.calendarType == "GUILD_EVENT" ) then
			CalendarViewEventFrame.Header:Setup(CALENDAR_VIEW_GUILD_EVENT);
		elseif ( eventInfo.calendarType == "COMMUNITY_EVENT" ) then
			CalendarViewEventFrame.Header:Setup(CALENDAR_VIEW_COMMUNITY_EVENT);
		else
			CalendarViewEventFrame.Header:Setup(CALENDAR_VIEW_EVENT);
		end
		CalendarViewEventInviteListSection:Show();
		CalendarViewEventFrame:SetHeight(CalendarViewEventFrame.defaultHeight);
		if ( eventInfo.isLocked ) then
			-- event locked...you cannot respond to the event
			CalendarViewEvent_SetEventButtons(eventInfo.inviteType, eventInfo.calendarType);
			CalendarViewEventAcceptButton:Disable();
			CalendarViewEventTentativeButton:Disable();
			CalendarViewEventDeclineButton:Disable();
			CalendarViewEventAcceptButtonFlashTexture:Hide();
			CalendarViewEventTentativeButtonFlashTexture:Hide();
			CalendarViewEventDeclineButtonFlashTexture:Hide()
			CalendarViewEventFrame:SetScript("OnUpdate", nil);
		else
			CalendarViewEventRSVP_Update(eventInfo.time.month, eventInfo.time.monthDay, eventInfo.time.year, eventInfo.hasPendingInvite, eventInfo.inviteStatus, eventInfo.inviteType, eventInfo.calendarType);
		end
		CalendarViewEventInviteList_Update(eventInfo.inviteType, eventInfo.calendarType);
	end
	CalendarEventFrameBlocker_Update();
end

function CalendarViewEventRSVPButton_OnUpdate(self)
	self.flashTexture:SetAlpha(CalendarViewEventFlashTimer:GetSmoothProgress());
end

function CalendarViewEventAcceptButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if ( CalendarViewEventFrame.inviteType == Enum.CalendarInviteType.Signup ) then
		GameTooltip:SetText(CALENDAR_TOOLTIP_SIGNUPBUTTON, nil, nil, nil, nil, true);
	else
		GameTooltip:SetText(CALENDAR_TOOLTIP_AVAILABLEBUTTON, nil, nil, nil, nil, true);
	end
	GameTooltip:Show();
end

function CalendarViewEventAcceptButton_OnClick(self)
	if ( CalendarViewEventFrame.inviteType == Enum.CalendarInviteType.Signup ) then
		C_Calendar.EventSignUp();
	else
		C_Calendar.EventAvailable();
	end
end

function CalendarViewEventTentativeButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(CALENDAR_TOOLTIP_TENTATIVEBUTTON, nil, nil, nil, nil, true);
	GameTooltip:Show();
end

function CalendarViewEventTentativeButton_OnClick(self)
	C_Calendar.EventTentative();
end

function CalendarViewEventDeclineButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(CALENDAR_TOOLTIP_DECLINEBUTTON, nil, nil, nil, nil, true);
	GameTooltip:Show();
end

function CalendarViewEventDeclineButton_OnClick(self)
	C_Calendar.EventDecline();
end

function CalendarViewEventRemoveButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if ( CalendarViewEventFrame.inviteType == Enum.CalendarInviteType.Signup ) then
		GameTooltip:SetText(CALENDAR_TOOLTIP_REMOVESIGNUPBUTTON, nil, nil, nil, nil, true);
	else
		GameTooltip:SetText(CALENDAR_TOOLTIP_REMOVEBUTTON, nil, nil, nil, nil, true);
	end
	GameTooltip:Show();
end

function CalendarViewEventRemoveButton_OnClick(self)
	C_Calendar.RemoveEvent();
end

function CalendarViewEventFrameHeaderFrame_OnEnter(self)
	local textElements = {
		CalendarViewEventTitle,
		CalendarViewEventCommunityName,
		CalendarViewEventTypeName,
		CalendarViewEventCreatorName,
		CalendarViewEventDateLabel,
		CalendarViewEventTimeLabel,
	};

	local showTooltip = false;
	for i = 1, #textElements do
		local textElement = textElements[i];
		if textElement:IsTruncated() then
			showTooltip = true;
			break;
		end
	end

	if showTooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		for i = 1, #textElements do
			local textElement = textElements[i];
			if textElement == CalendarViewEventTitle then
				GameTooltip_SetTitle(GameTooltip, textElement:GetText(), NORMAL_FONT_COLOR);
			elseif textElement == CalendarViewEventDateLabel or textElement == CalendarViewEventTimeLabel then
				GameTooltip_AddColoredLine(GameTooltip, textElement:GetText(), HIGHLIGHT_FONT_COLOR);
			else
				GameTooltip_AddNormalLine(GameTooltip, textElement:GetText());
			end
		end

		GameTooltip:Show();
	end
end

function CalendarViewEventRSVP_Update(month, day, year, pendingInvite, inviteStatus, inviteType, calendarType)
	-- record the invite type
	CalendarViewEventFrame.inviteType = inviteType;

	local isTodayOrLater = _CalendarFrame_IsTodayOrLater(month, day, year);

	CalendarViewEvent_SetEventButtons(inviteType, calendarType);

	if ( _CalendarFrame_IsSignUpEvent(calendarType, inviteType) ) then
		-- update shown buttons
		if ( isTodayOrLater ) then
			if ( inviteStatus == Enum.CalendarStatus.NotSignedup ) then
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
		-- update shown buttons
		local canRSVP = _CalendarFrame_CanInviteeRSVP(inviteStatus);
		if ( isTodayOrLater and canRSVP ) then
			if ( inviteStatus ~= Enum.CalendarStatus.Available ) then
				CalendarViewEventAcceptButton:Enable();
			else
				CalendarViewEventAcceptButton:Disable();
			end
			if ( inviteStatus ~= Enum.CalendarStatus.Tentative ) then
				CalendarViewEventTentativeButton:Enable();
			else
				CalendarViewEventTentativeButton:Disable();
			end
			if ( inviteStatus ~= Enum.CalendarStatus.Declined ) then
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

function CalendarViewEvent_SetEventButtons(inviteType, calendarType)
	if ( _CalendarFrame_IsSignUpEvent(calendarType, inviteType) ) then
		-- signup mode
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
	else
		-- normal mode
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
	end
end

function CalendarViewEventInviteList_Update(inviteType, calendarType)
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
	local namesReady = C_Calendar.AreNamesReady();
	if namesReady then
		local newDataProvider = CreateDataProvider();
		for index = 1, C_Calendar.GetNumInvites() do
			local inviteInfo = C_Calendar.EventGetInvite(index);
			if inviteInfo and inviteInfo.name then
				newDataProvider:Insert({index = index});
			end
		end

		CalendarViewEventInviteList.ScrollBox:SetDataProvider(newDataProvider);

		CalendarViewEventFrameRetrievingFrame:Hide();
	else
		CalendarViewEventFrameRetrievingFrame:Show();
	end

	CalendarViewEventFrame.myInviteIndex = nil;
end

function CalendarViewEventInviteList_OnLoad(self)
	self.sortButtons = {
		name = _G[self:GetName().."NameSortButton"],
		class = _G[self:GetName().."ClassSortButton"],
		status = _G[self:GetName().."StatusSortButton"],
	};

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CalendarViewEventInviteListButtonTemplate", function(button, elementData)
		CalendarViewEventInviteList_InitButton(button, elementData);
	end);
	local calculator = function(dataIndex, elementData)
		return buttonHeight;
	end;

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	CalendarEvent_InitManagedScrollBarVisibility(self, self.ScrollBox, self.ScrollBar);
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

		if ( C_Calendar.EventHasPendingInvite() and self.inviteIndex == CalendarViewEventFrame.myInviteIndex ) then
			if ( inviteChanged ) then
				CalendarContextMenu_Show(self, CalendarViewEventInviteContextMenu_Initialize, "cursor", 3, -3, self);
			else
				CalendarContextMenu_Toggle(self, CalendarViewEventInviteContextMenu_Initialize, "cursor", 3, -3, self);
			end
		end
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function CalendarViewEventInviteListButton_Click(button)
	C_Calendar.EventSelectInvite(button.inviteIndex);
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
--	self:RegisterEvent("GROUP_ROSTER_UPDATE");

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
	UIDropDownMenu_Initialize(CalendarCreateEventDifficultyOptionDropDown, CalendarCreateEventDifficultyOptionDropDown_Initialize);
	UIDropDownMenu_SetWidth(CalendarCreateEventDifficultyOptionDropDown, 100);
	UIDropDownMenu_Initialize(CalendarCreateEventCommunityDropDown, CalendarCreateEventCommunityDropDown_Initialize);
	UIDropDownMenu_SetWidth(CalendarCreateEventCommunityDropDown, 208);
end

function CalendarCreateEventFrame_OnEvent(self, event, ...)
	if ( CalendarCreateEventFrame:IsShown() ) then
		if ( event == "CALENDAR_UPDATE_EVENT" ) then
			if ( C_Calendar.EventCanEdit() ) then
				CalendarCreateEventFrame_Update();
			else
				CalendarFrame_ShowEventFrame(CalendarViewEventFrame);
			end
		elseif ( event == "CALENDAR_UPDATE_INVITE_LIST" ) then
			CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
			if ( not C_Calendar.EventCanEdit() ) then
				-- if we can't edit the event any more, show the view event frame immediately
				CalendarFrame_ShowEventFrame(CalendarViewEventFrame);
				return;
			end
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
				local canRequestRosterUpdate = ...;
				if ( canRequestRosterUpdate ) then
					C_GuildInfo.GuildRoster();
				end
			end
			if ( C_Calendar.EventCanEdit() ) then
				if ( CalendarCreateEventFrame.mode == "edit" ) then
					CalendarCreateEventFrame_Update();
				end
			else
				CalendarFrame_ShowEventFrame(CalendarViewEventFrame);
			end
--		elseif ( event == "GROUP_ROSTER_UPDATE" ) then
--			CalendarCreateEventInviteList_Update();
		end
	end
end

function CalendarCreateEventFrame_OnShow(self)
	CalendarCreateEventFrame_Update();
	SetUIPanelAttribute(CalendarFrame, "extraWidth", self:GetWidth() + CALENDAR_FRAME_EXTRA_WIDTH);
	UpdateUIPanelPositions(CalendarFrame);
end

function CalendarCreateEventFrame_OnHide(self)
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
	-- clear the raid invite button data so we don't get strange party-invite behavior next time we show this frame
	CalendarCreateEventRaidInviteButton.inviteLostMembers = false;
	CalendarCreateEventRaidInviteButton.inviteCount = 0;
	CalendarMassInviteFrame:Hide();
	SetUIPanelAttribute(CalendarFrame, "extraWidth", CALENDAR_FRAME_EXTRA_WIDTH);
	UpdateUIPanelPositions(CalendarFrame);
end

function CalendarCreateEventFrame_Update()
	if ( CalendarCreateEventFrame.mode == "create" ) then
		CalendarCreateEventCreateButton_SetText(CALENDAR_CREATE);

		-- set the event date based on the selected date
		local dayButton = CalendarCreateEventFrame.dayButton;
		CalendarCreateEventDateLabel:SetFormattedText(FULLDATE, _CalendarFrame_GetFullDateFromDay(dayButton));
		local monthInfo = C_Calendar.GetMonthInfo(dayButton.monthOffset);
		local month = monthInfo.month;
		local year = monthInfo.year;
		C_Calendar.EventSetDate(month, dayButton.day, year);
		-- deselect the selected event
		CalendarDayEventButton_Click();
		-- reset event title
		CalendarCreateEventTitleEdit:SetText(CALENDAR_CREATEEVENTFRAME_DEFAULT_TITLE);
		CalendarCreateEventTitleEdit:HighlightText();
		CalendarCreateEventTitleEdit:SetFocus();
		C_Calendar.EventSetTitle("");
		-- reset event description
		CalendarCreateEventDescriptionContainer.ScrollingEditBox:ClearText();
		C_Calendar.EventSetDescription("");
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
		C_Calendar.EventSetType(CalendarCreateEventFrame.selectedEventType);
		-- reset event texture (must come after event type)
		CalendarCreateEventFrame.selectedTextureIndex = nil;
		CalendarCreateEventFrame.calendarType = nil;
		CalendarCreateEventTexture_Update();
		-- hide the creator and the community name
		CalendarCreateEventCreatorName:Hide();
		CalendarCreateEventCommunityName:Hide();

		local calendarType = C_Calendar.EventGetCalendarType();

		CalendarCreateEventCommunityDropDown:SetShown(calendarType == "COMMUNITY_EVENT");

		if ( calendarType == "GUILD_ANNOUNCEMENT" ) then
			CalendarCreateEventFrame.Header:Setup(CALENDAR_CREATE_ANNOUNCEMENT);
			-- guild wide events don't have invites
			CalendarCreateEventInviteListSection:Hide();
			CalendarCreateEventMassInviteButton:Hide();
			CalendarCreateEventFrame:SetHeight(CalendarCreateEventFrame.defaultHeight - CalendarCreateEventInviteListSection:GetHeight());
			CalendarClassButtonContainer_Hide();
		else
			if ( calendarType == "GUILD_EVENT" ) then
				CalendarCreateEventFrame.Header:Setup(CALENDAR_CREATE_GUILD_EVENT);
				CalendarCreateEventMassInviteButton:Hide();
			elseif ( calendarType == "COMMUNITY_EVENT" ) then
				-- reset the community selected
				local nextClubId = C_Calendar.GetNextClubId();
				local clubInfo = nextClubId and C_Club.GetClubInfo(nextClubId) or nil;
				if clubInfo ~= nil then
					C_Calendar.EventSetClubId(nextClubId);
					UIDropDownMenu_SetSelectedValue(CalendarCreateEventCommunityDropDown, clubInfo.name);
					UIDropDownMenu_SetText(CalendarCreateEventCommunityDropDown, clubInfo.name);
				else
					C_Calendar.EventSetClubId(nil);
					UIDropDownMenu_SetSelectedValue(CalendarCreateEventCommunityDropDown, nil);
					UIDropDownMenu_SetText(CalendarCreateEventCommunityDropDown, CALENDER_INVITE_SELECT_COMMUNITY);
				end

				CalendarCreateEventFrame.Header:Setup(CALENDAR_CREATE_COMMUNITY_EVENT);
				CalendarCreateEventMassInviteButton:Hide();
			else
				CalendarCreateEventFrame.Header:Setup(CALENDAR_CREATE_EVENT);
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
		local eventInfo = C_Calendar.GetEventInfo();
		if ( not eventInfo.title ) then
			CalendarFrame_HideEventFrame(CalendarCreateEventFrame);
			CalendarClassButtonContainer_Hide();
			return;
		end

		CalendarCreateEventCreateButton_SetText(CALENDAR_UPDATE);

		-- update event title
		CalendarCreateEventTitleEdit:SetText(eventInfo.title);
		CalendarCreateEventTitleEdit:SetCursorPosition(0);
		CalendarCreateEventTitleEdit:ClearFocus();
		-- update description
		CalendarCreateEventDescriptionContainer.ScrollingEditBox:ClearFocus();
		CalendarCreateEventDescriptionContainer.ScrollingEditBox:SetText(eventInfo.description);
		-- update date
		CalendarCreateEventDateLabel:SetFormattedText(FULLDATE, _CalendarFrame_GetFullDate(eventInfo.time.weekday, eventInfo.time.month, eventInfo.time.monthDay, eventInfo.time.year));
		-- update time
		if ( CalendarFrame.militaryTime ) then
			CalendarCreateEventFrame.selectedHour = eventInfo.time.hour;
		else
			CalendarCreateEventFrame.selectedHour = GameTime_ComputeStandardTime(eventInfo.time.hour);
		end
		CalendarCreateEventFrame.selectedMinute = eventInfo.time.minute;
		CalendarCreateEventFrame.selectedAM = eventInfo.time.hour < 12;
		if ( CalendarFrame.militaryTime ) then
			CalendarCreateEventFrame.selectedHour = eventInfo.time.hour;
		else
			CalendarCreateEventFrame.selectedHour = GameTime_ComputeStandardTime(eventInfo.time.hour, CalendarCreateEventFrame.selectedAM);
		end
		CalendarCreateEvent_UpdateEventTime();
		-- update type
		CalendarCreateEventFrame.selectedEventType = eventInfo.eventType;
		CalendarCreateEvent_UpdateEventType();
		-- reset event texture (must come after event type)
		CalendarCreateEventFrame.selectedTextureIndex = eventInfo.textureIndex;
		CalendarCreateEventFrame.calendarType = eventInfo.calendarType;

		if eventInfo.calendarType == "COMMUNITY_EVENT" or eventInfo.calendarType == "GUILD_EVENT" then
			CalendarCreateEventCommunityName:Show();
			CalendarCreateEventCommunityName:SetText(eventInfo.communityName)
			if(eventInfo.calendarType == "GUILD_EVENT") then
				CalendarCreateEventCommunityName:SetTextColor(GREEN_FONT_COLOR:GetRGB())
			else
				CalendarCreateEventCommunityName:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
			end
		else
			CalendarCreateEventCommunityName:Hide();
		end

		CalendarCreateEventTexture_Update();
		-- update the creator (must come after event texture)
		CalendarCreateEventCreatorName:SetFormattedText(CALENDAR_EVENT_CREATORNAME, _CalendarFrame_SafeGetName(eventInfo.creator));
		CalendarCreateEventCreatorName:Show();

		--Hide the communitySelector
		CalendarCreateEventCommunityDropDown:SetShown(false);

		if ( eventInfo.calendarType == "GUILD_ANNOUNCEMENT" ) then
			CalendarCreateEventFrame.Header:Setup(CALENDAR_EDIT_ANNOUNCEMENT);
			-- guild wide events don't have invites
			CalendarCreateEventInviteListSection:Hide();
			CalendarCreateEventRaidInviteButton:Hide();
			CalendarCreateEventFrame:SetHeight(CalendarCreateEventFrame.defaultHeight - CalendarCreateEventInviteListSection:GetHeight());
			CalendarClassButtonContainer_Hide();
		else
			if ( eventInfo.calendarType == "GUILD_EVENT" ) then
				CalendarCreateEventFrame.Header:Setup(CALENDAR_EDIT_GUILD_EVENT);
			elseif ( eventInfo.calendarType == "COMMUNITY_EVENT" ) then
				CalendarCreateEventFrame.Header:Setup(CALENDAR_EDIT_COMMUNITY_EVENT);
			else
				CalendarCreateEventFrame.Header:Setup(CALENDAR_EDIT_EVENT);
			end
			-- update auto approve
			CalendarCreateEventAutoApproveCheck:SetChecked(eventInfo.isAutoApprove);
			-- update locked
			CalendarCreateEventLockEventCheck:SetChecked(eventInfo.isLocked);
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

function CalendarCreateEventTitleEdit_OnTextChanged(self, userChanged)
	if userChanged then
		local text = self:GetText();
		local trimmedText = strtrim(text);
		if ( trimmedText == "" or trimmedText == CALENDAR_CREATEEVENTFRAME_DEFAULT_TITLE ) then
			-- if the title is either the default or all whitespace, just set it to the empty string
			C_Calendar.EventSetTitle("");
		else
			C_Calendar.EventSetTitle(text);
		end
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

function CalendarCreateEventDescriptionContainer_OnLoad(self)
	local function OnTextChanged(o, editBox, userChanged)
		if userChanged then
			C_Calendar.EventSetDescription(editBox:GetInputText());
			CalendarCreateEventCreateButton_Update();
		end
	end;
	self.ScrollingEditBox:RegisterCallback("OnTextChanged", OnTextChanged, self);

	local function OnTabPressed(o, editBox)
		CalendarOnEditBoxTab(editBox);
	end;
	self.ScrollingEditBox:RegisterCallback("OnTabPressed", OnTabPressed, self);

	local scrollBox = self.ScrollingEditBox:GetScrollBox();
	ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, self.ScrollBar);
	
	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", self.ScrollingEditBox, "TOPLEFT", 0, 0),
		CreateAnchor("BOTTOMRIGHT", self.ScrollingEditBox, "BOTTOMRIGHT", -18, -1),
	};
	local scrollBoxAnchorsWithoutBar = {
		scrollBoxAnchorsWithBar[1],
		CreateAnchor("BOTTOMRIGHT", self.ScrollingEditBox, "BOTTOMRIGHT", -2, -1),
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end

function CalendarCreateEventCreatorName_Update()
	if ( CalendarCreateEventTextureName:IsShown() ) then
		CalendarCreateEventCreatorName:SetPoint("TOPLEFT", CalendarCreateEventTextureName, "BOTTOMLEFT");
	elseif ( CalendarCreateEventCommunityName:IsShown() ) then
		CalendarCreateEventCreatorName:SetPoint("TOPLEFT", CalendarCreateEventCommunityName, "BOTTOMLEFT");
	else
		CalendarCreateEventCreatorName:SetPoint("TOPLEFT", CalendarCreateEventIcon, "TOPRIGHT", 5, 0);
	end
end

function CalendarCreateEventTexture_Update()
	local eventType = CalendarCreateEventFrame.selectedEventType;
	local textureIndex = CalendarCreateEventFrame.selectedTextureIndex;

	local isGuildOrCommunityEvent = CalendarCreateEventFrame.calendarType == "COMMUNITY_EVENT" or CalendarCreateEventFrame.calendarType == "GUILD_EVENT";

	CalendarCreateEventIcon:SetTexture();
	local tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
	CalendarCreateEventIcon:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
	local dungeonCacheEntry, difficultyInfo = _CalendarFrame_GetEventDungeonCacheEntry(textureIndex, eventType);
	if ( dungeonCacheEntry ) then
		-- set the dungeonCacheEntry name since we have one
		local name = dungeonCacheEntry.title;
		CalendarCreateEventTextureName:SetText(GetDungeonNameWithDifficulty(name, difficultyInfo and difficultyInfo.difficultyName or dungeonCacheEntry.difficultyName));
		CalendarCreateEventTextureName:Show();

		if isGuildOrCommunityEvent then
			CalendarCreateEventTextureName:SetPoint("TOPLEFT", CalendarCreateEventCommunityName, "BOTTOMLEFT");
		else
			CalendarCreateEventTextureName:SetPoint("TOPLEFT", CalendarCreateEventIcon, "TOPRIGHT", 5, 0);
		end


		if CalendarCreateEventFrame.mode == "edit" then
			CalendarCreateEventCreatorName:SetPoint("TOPLEFT", CalendarCreateEventTextureName, "BOTTOMLEFT");
			CalendarCreateEventDateLabel:SetPoint("TOPLEFT", CalendarCreateEventCreatorName, "BOTTOMLEFT");
		else
			CalendarCreateEventDateLabel:SetPoint("TOPLEFT", CalendarCreateEventTextureName, "BOTTOMLEFT");
		end

		-- set the dungeonCacheEntry texture
		if ( dungeonCacheEntry.texture ) then
			CalendarCreateEventIcon:SetTexture(dungeonCacheEntry.texture);
		else
			CalendarCreateEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventType]);
		end
	else
		CalendarCreateEventTextureName:Hide();

		if CalendarCreateEventFrame.mode == "edit" then
			CalendarCreateEventCreatorName:SetPoint("TOPLEFT", CalendarCreateEventIcon, "TOPRIGHT", 5, 0);
			CalendarCreateEventDateLabel:SetPoint("TOPLEFT", CalendarCreateEventCreatorName, "BOTTOMLEFT");
		else
			CalendarCreateEventDateLabel:SetPoint("TOPLEFT", CalendarCreateEventIcon, "TOPRIGHT", 5, 0);
		end

		CalendarCreateEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventType]);
	end
	-- need to update the creator name at this point since it is affected by the texture name
	CalendarCreateEvent_UpdateEventType();
	CalendarCreateEventCreatorName_Update();
end

function CalendarCreateEventTypeDropDown_Initialize(self)
	local types = C_Calendar.EventGetTypesDisplayOrdered();
	CalendarCreateEventTypeDropDown_InitEventTypes(self, types);
end

function CalendarCreateEventTypeDropDown_InitEventTypes(self, types)
	local info = UIDropDownMenu_CreateInfo();
	for i = 1, #types, 1 do
		info.text = _G[types[i].displayString];
		info.value = types[i].eventType;
		info.func = CalendarCreateEventTypeDropDown_OnClick;
		if ( CalendarCreateEventFrame.selectedEventType == info.value ) then
			info.checked = 1;
			UIDropDownMenu_SetText(self, info.text);
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function CalendarCreateEventTypeDropDown_OnClick(self)
	local eventType = self.value;
	if ( eventType == Enum.CalendarEventType.Dungeon or eventType == Enum.CalendarEventType.Raid ) then
		CalendarTexturePickerFrame_Show(eventType);
	else
		CalendarCreateEventFrame.selectedTextureIndex = nil;
		CalendarCreateEventFrame.selectedEventType = eventType;
		CalendarCreateEvent_UpdateEventType();
		C_Calendar.EventSetType(eventType);

		CalendarCreateEventTexture_Update();

		CalendarCreateEventCreateButton_Update();
	end
end

function CalendarCreateEvent_UpdateEventType()
	UIDropDownMenu_Initialize(CalendarCreateEventTypeDropDown, CalendarCreateEventTypeDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(CalendarCreateEventTypeDropDown, CalendarCreateEventFrame.selectedEventType);

	local eventType = CalendarCreateEventFrame.selectedEventType;
	local textureIndex = CalendarCreateEventFrame.selectedTextureIndex;
	local dungeonCacheEntry, difficultyInfo = _CalendarFrame_GetEventDungeonCacheEntry(textureIndex, eventType);
	if ( dungeonCacheEntry and difficultyInfo and difficultyInfo.difficultyName ~= "") then
		UIDropDownMenu_Initialize(CalendarCreateEventDifficultyOptionDropDown, CalendarCreateEventDifficultyOptionDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(CalendarCreateEventDifficultyOptionDropDown, difficultyInfo.difficultyName);
		CalendarCreateEventDifficultyOptionDropDown:Show();
	else
		CalendarCreateEventDifficultyOptionDropDown:Hide();
	end
end

function CalendarCreateEvent_SetSelectedIndex(selectedTextureIndex, eventType)
	CalendarCreateEventFrame.selectedTextureIndex = selectedTextureIndex;
	CalendarCreateEventFrame.selectedEventType = eventType;
	if ( CalendarCreateEventFrame.selectedTextureIndex ) then
		-- now that we've selected a texture, we can set the create event data
		C_Calendar.EventSetType(eventType);
		C_Calendar.EventSetTextureID(CalendarCreateEventFrame.selectedTextureIndex);
		-- update the create event frame using our selection
		CalendarCreateEventFrame.selectedEventType = eventType;
		CalendarCreateEvent_UpdateEventType();
		CalendarCreateEventTexture_Update();
		CalendarTexturePickerFrame_Hide();

		CalendarCreateEventCreateButton_Update();
	end
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
			UIDropDownMenu_JustifyText(CalendarCreateEventHourDropDown, "CENTER");
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
			UIDropDownMenu_JustifyText(CalendarCreateEventMinuteDropDown, "CENTER");
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

function CalendarCreateEventDifficultyOptionDropDown_Initialize(self)
	local eventType = CalendarCreateEventFrame.selectedEventType;
	local textureIndex = CalendarCreateEventFrame.selectedTextureIndex;
	local dungeonCacheEntry = _CalendarFrame_GetEventDungeonCacheEntry(textureIndex, eventType);
	if ( dungeonCacheEntry ) then
		local info = UIDropDownMenu_CreateInfo();
		local alreadyAddedDifficulties = {};
		for i, difficultyInfo in ipairs(dungeonCacheEntry.difficulties) do
			if not alreadyAddedDifficulties[difficultyInfo.difficultyName] then
				info.text = difficultyInfo.difficultyName;
				info.arg1 = difficultyInfo.textureIndex;
				info.func = CalendarCreateEventDifficultyOptionDropDown_OnClick;
				info.checked = textureIndex == difficultyInfo.textureIndex or nil;
				UIDropDownMenu_AddButton(info);

				alreadyAddedDifficulties[difficultyInfo.difficultyName] = true;
			end
		end
	end
end

function CalendarCreateEventDifficultyOptionDropDown_OnClick(self, textureIndex)
	CalendarCreateEvent_SetSelectedIndex(textureIndex, CalendarCreateEventFrame.selectedEventType);
end

function CalendarCreateEventCommunityDropDown_Initialize(self)
	local clubs = C_Club.GetSubscribedClubs()
	local eventType = CalendarCreateEventFrame.selectedEventType;
	local selectedClubId = C_Calendar.EventGetClubId();
	if (eventType) then
		local info = UIDropDownMenu_CreateInfo();
		for i, clubInfo in ipairs(clubs) do
			if (clubInfo.clubType == Enum.ClubType.Character) then
				info.text = clubInfo.name;
				info.arg1 = clubInfo.clubId;
				info.func = CalendarCreateEventCommunityDropDown_OnClick;
				info.checked = clubInfo.clubId == selectedClubId;
				UIDropDownMenu_AddButton(info);
			end
		end
	end
end

function CalendarCreateEventCommunityDropDown_OnClick(self, clubId)
	local clubInfo = C_Club.GetClubInfo(clubId)
	if(clubInfo == nil) then
		return;
	end
	UIDropDownMenu_SetSelectedValue(CalendarCreateEventCommunityDropDown, clubInfo.name);
	C_Calendar.EventSetClubId(clubId);
	CalendarCreateEventCreateButton_Update();
end

function CalendarCreateEvent_SetEventTime()
	local hour = CalendarCreateEventFrame.selectedHour;
	if ( not CalendarFrame.militaryTime ) then
		hour = GameTime_ComputeMilitaryTime(hour, CalendarCreateEventFrame.selectedAM);
	end
	C_Calendar.EventSetTime(hour, CalendarCreateEventFrame.selectedMinute);
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

function CalendarCreateEventAutoApproveCheck_OnLoad(self)
	CalendarCreateEventAutoApproveCheckText:SetText(CALENDAR_AUTO_APPROVE);
	CalendarCreateEventAutoApproveCheckText:SetFontObject(GameFontNormalSmallLeft);
	self:SetHitRectInsets(0, -CalendarCreateEventAutoApproveCheckText:GetWidth(), 0, 0);
end

function CalendarCreateEventAutoApproveCheck_OnClick(self)
	CalendarCreateEvent_SetAutoApprove();
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
	CalendarCreateEventCreateButton_Update();
end

function CalendarCreateEvent_SetAutoApprove()
	if ( CalendarCreateEventAutoApproveCheck:GetChecked() ) then
		C_Calendar.EventSetAutoApprove();
	else
		C_Calendar.EventClearAutoApprove();
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
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
	CalendarCreateEventCreateButton_Update();
end

function CalendarCreateEvent_SetLockEvent()
	if ( CalendarCreateEventLockEventCheck:GetChecked() ) then
		C_Calendar.EventSetLocked();
	else
		C_Calendar.EventClearLocked();
	end
end

function CalendarCreateEventInviteList_Update()
	CalendarCreateEventInviteListScrollFrame_Update();
	CalendarEventInviteList_AnchorSortButtons(CalendarCreateEventInviteList);
	CalendarEventInviteList_UpdateSortButtons(CalendarCreateEventInviteList);
end

function CalendarCreateEventInviteListScrollFrame_Update()
	local namesReady = C_Calendar.AreNamesReady();
	if namesReady then
		local newDataProvider = CreateDataProvider();
		for index = 1, C_Calendar.GetNumInvites() do
			local inviteInfo = C_Calendar.EventGetInvite(index);
			if inviteInfo and inviteInfo.name then
				newDataProvider:Insert({index = index});
			end
		end

		CalendarCreateEventInviteList.ScrollBox:SetDataProvider(newDataProvider);

		CalendarCreateEventFrameRetrievingFrame:Hide();
	else
		CalendarCreateEventFrameRetrievingFrame:Show();
	end
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

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function CalendarCreateEventInviteListButton_Click(button)
	C_Calendar.EventSelectInvite(button.inviteIndex);
	CalendarCreateEventFrame_SetSelectedInvite(button);
end

function CalendarCreateEventInviteContextMenu_Initialize(self, inviteButton)
	UIMenu_Initialize(self);

	-- unlock old highlights
	CalendarInviteContextMenu_UnlockHighlights();

	-- record the invite button
	self.inviteButton = inviteButton;

	local inviteIndex = inviteButton.inviteIndex;
	local inviteInfo = C_Calendar.EventGetInvite(inviteIndex);

	local needSpacer = false;
	if ( inviteInfo.modStatus ~= "CREATOR" ) then
		-- remove invite
		UIMenu_AddButton(self, REMOVE, nil, CalendarInviteContextMenu_RemoveInvite);
		-- spacer
		--UIMenu_AddButton(self, "");
		if ( inviteInfo.modStatus == "MODERATOR" ) then
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

	if ( not UnitIsUnit("player", inviteInfo.name) and (not UnitInParty(inviteInfo.name) or not UnitInRaid(inviteInfo.name)) ) then
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
			inviteInfo.name);								-- value
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
	C_Calendar.EventRemoveInvite(inviteButton.inviteIndex);
end

function CalendarInviteContextMenu_SetModerator()
	local inviteButton = CalendarContextMenu.inviteButton;
	C_Calendar.EventSetModerator(inviteButton.inviteIndex);
end

function CalendarInviteContextMenu_ClearModerator()
	local inviteButton = CalendarContextMenu.inviteButton;
	C_Calendar.EventClearModerator(inviteButton.inviteIndex);
end

function CalendarInviteContextMenu_InviteToGroup(self)
	C_PartyInfo.InviteUnit(self.value);
end

function CalendarInviteStatusContextMenu_OnLoad(self)
	self:RegisterEvent("CALENDAR_UPDATE_EVENT");
	self.parentMenu = "CalendarContextMenu";
	self.onlyAutoHideSelf = true;
end

function CalendarInviteStatusContextMenu_OnShow(self)
	local statusOptions = C_Calendar.EventGetStatusOptions(CalendarContextMenu.inviteButton.inviteIndex);
	CalendarInviteStatusContextMenu_Initialize(self, statusOptions);
end

function CalendarInviteStatusContextMenu_OnEvent(self, event, ...)
	if ( event == "CALENDAR_UPDATE_EVENT" ) then
		if ( self:IsShown() ) then
			local statusOptions = C_Calendar.EventGetStatusOptions(CalendarContextMenu.inviteButton.inviteIndex);
			CalendarInviteStatusContextMenu_Initialize(self, statusOptions);
		end
	end
end

function CalendarInviteStatusContextMenu_Initialize(self, statusOptions)
	UIMenu_Initialize(self);

	for i = 1, #statusOptions, 1 do
		UIMenu_AddButton(
			self,													-- self
			_G[statusOptions[i].statusString],						-- text
			nil,													-- shortcut
			CalendarInviteStatusContextMenu_SetStatusOption,		-- func
			nil,													-- nested
			statusOptions[i].status									-- value
		);
	end

	return UIMenu_FinishInitializing(self);
end

function CalendarInviteStatusContextMenu_SetStatusOption(self)
	C_Calendar.EventSetInviteStatus(CalendarContextMenu.inviteButton.inviteIndex, self.value);
	-- hide parent
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
end

function CalendarCreateEventInviteEdit_OnEnterPressed(self)
	if ( not AutoCompleteEditBox_OnEnterPressed(self) ) then
		local text = strtrim(self:GetText());
		local trimmedText = strtrim(text);
		if ( trimmedText == "" or trimmedText == CALENDAR_PLAYER_NAME ) then
			self:ClearFocus();
		elseif ( C_Calendar.CanSendInvite() ) then
			C_Calendar.EventInvite(text);
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
		C_Calendar.EventInvite(text);
		CalendarCreateEventInviteEdit:SetText("");
		--CalendarCreateEventInviteEdit:ClearFocus();
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function CalendarCreateEventInviteButton_OnUpdate(self)
	CalendarCreateEventInviteButton_Update();
end

function CalendarCreateEventInviteButton_Update()
	if ( C_Calendar.CanSendInvite() ) then
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

	local clubs = C_Club.GetSubscribedClubs()

	if (#clubs > 0) then
		CalendarCreateEventMassInviteButton:Enable();
	else
		CalendarCreateEventMassInviteButton:Disable();
	end
end

function CalendarCreateEventRaidInviteButton_OnLoad(self)
	self:RegisterEvent("GROUP_ROSTER_UPDATE");

	self:SetWidth(self:GetTextWidth() + 40);
end

function CalendarCreateEventRaidInviteButton_OnEvent(self, event, ...)
	if ( self:IsShown() and self:GetParent():IsShown() ) then
		if ( event == "GROUP_ROSTER_UPDATE" ) then
			CalendarCreateEventRaidInviteButton_Update();
			if ( IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInRaid(LE_PARTY_CATEGORY_HOME) and self.inviteLostMembers ) then
				-- in case we weren't able to convert to a raid when the player clicked the raid invite button
				-- (which means the player was not in a party), we want to convert to a raid now since he has a party
				C_PartyInfo.ConvertToRaid();
			end
		end
	end
end

function CalendarCreateEventRaidInviteButton_OnClick(self)
	-- compute the max number of players that we should invite
	local maxInviteCount;
	local realNumGroupMembers = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
	if ( not IsInRaid(LE_PARTY_CATEGORY_HOME) ) then
		if ( realNumGroupMembers + self.inviteCount > MAX_PARTY_MEMBERS + 1 ) then
			-- if I can't invite the number of people that I'm supposed to...
			self.inviteLostMembers = true;
			if ( realNumGroupMembers > 0 ) then
				--...and I'm already in a party, then I need to form a raid first to fit everyone
				C_PartyInfo.ConvertToRaid();
				return;
			end
		end
		maxInviteCount = MAX_PARTY_MEMBERS + 1 - realNumGroupMembers;
	else
		maxInviteCount = MAX_RAID_MEMBERS - realNumGroupMembers;
	end

	_CalendarFrame_InviteToRaid(maxInviteCount);
end

function CalendarCreateEventRaidInviteButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if ( IsInRaid(LE_PARTY_CATEGORY_HOME) or GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) + self.inviteCount > MAX_PARTY_MEMBERS + 1) then
		GameTooltip:SetText(CALENDAR_TOOLTIP_INVITEMEMBERS_BUTTON_RAID, nil, nil, nil, nil, true);
	else
		GameTooltip:SetText(CALENDAR_TOOLTIP_INVITEMEMBERS_BUTTON_PARTY, nil, nil, nil, nil, true);
	end
	GameTooltip:Show();
end

function CalendarCreateEventRaidInviteButton_Update()
	-- NOTE: it might be an efficiency concern that we go through the list twice: once to get a count
	-- and once to do the actual inviting (that's in the OnClick), but I thought it would be better to
	-- go through the list twice than to take up extra space in memory and potentially cause a lot of
	-- garbage collection due to constantly rebuilding a saved table
	local maxInviteCount = MAX_RAID_MEMBERS - GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
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
		C_Calendar.AddEvent();
	elseif ( CalendarCreateEventFrame.mode == "edit" ) then
		C_Calendar.UpdateEvent();
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
		if ( C_Calendar.CanAddEvent() and (C_Calendar.EventGetCalendarType() ~= "COMMUNITY_EVENT" or  C_Calendar.EventGetClubId() ~= nil) ) then
			CalendarCreateEventCreateButton:Enable();
		else
			CalendarCreateEventCreateButton:Disable();
		end
	elseif ( CalendarCreateEventFrame.mode == "edit" ) then
		if ( C_Calendar.EventHaveSettingsChanged() and not C_Calendar.IsActionPending() ) then
			CalendarCreateEventCreateButton:Enable();
		else
			CalendarCreateEventCreateButton:Disable();
		end
	end
end


-- CalendarMassInviteFrame

function CalendarMassInviteFrame_OnLoad(self)
	self:RegisterEvent("CALENDAR_ACTION_PENDING");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");

	local filter = C_Calendar.GetDefaultGuildFilter();
	CalendarMassInviteMinLevelEdit:SetNumber(filter.minLevel);
	CalendarMassInviteMaxLevelEdit:SetNumber(filter.maxLevel);
	UIDropDownMenu_SetWidth(CalendarMassInviteRankMenu, 100);
	UIDropDownMenu_SetWidth(CalendarMassInviteCommunityDropDown, 200);
	UIDropDownMenu_Initialize(CalendarMassInviteCommunityDropDown, CalendarMassInviteCommunityDropDown_Initialize);

	-- try to fire off a guild roster event so we can properly update our guild options
	if ( IsInGuild() and GetNumGuildMembers() == 0 ) then
		C_GuildInfo.GuildRoster();
	end
end

function CalendarMassInviteFrame_OnShow(self)
	CalendarFrame_PushModal(self);
	CalendarMassInviteFrame.selectedClubId = nil;
	CalendarMassInvite_Update();

	UIDropDownMenu_Initialize(CalendarMassInviteRankMenu, CalendarMassInviteRankMenu_Initialize);
	UIDropDownMenu_SetSelectedValue(CalendarMassInviteCommunityDropDown, nil);
	UIDropDownMenu_SetText(CalendarMassInviteCommunityDropDown, CALENDER_INVITE_SELECT_COMMUNITY);
end

function CalendarMassInviteFrame_OnEvent(self, event, ...)
	if ( event == "GUILD_ROSTER_UPDATE" ) then
		local canRequestRosterUpdate = ...;
		if ( canRequestRosterUpdate ) then
			C_GuildInfo.GuildRoster();
		end
	end
	if ( self:IsShown() ) then
		if ( not CanEditGuildEvent() ) then
			-- if we are no longer in a guild, we can't mass invite
			CalendarMassInviteFrame:Hide();
			CalendarCreateEventMassInviteButton_Update();
		else
			if ( event == "CALENDAR_ACTION_PENDING" ) then
				CalendarMassInvite_Update();
			elseif ( event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_GUILD_UPDATE" ) then
				CalendarMassInvite_Update();
			end
		end
	end
end

function CalendarMassInviteFrame_OnUpdate(self)
	CalendarMassInvite_Update();
end

function CalendarMassInvite_Update()
	if ( C_Calendar.CanSendInvite() and CalendarMassInviteFrame.selectedClubId ) then
		-- enable the accept button
		CalendarMassInviteAcceptButton:Enable();
		-- set the selected rank
		if ( not CalendarMassInviteFrame.selectedRank or CalendarMassInviteFrame.selectedRank > GuildControlGetNumRanks() ) then
			local filter = C_Calendar.GetDefaultGuildFilter();
			CalendarMassInviteFrame.selectedRank = filter.rank;
		end
		-- enable and initialize the rank drop down
		local clubInfo = C_Club.GetClubInfo(CalendarMassInviteFrame.selectedClubId)
		--Handle guilds
		if (clubInfo and clubInfo.clubType == Enum.ClubType.Guild) then
			CalendarMassInviteRankMenu:Show();
			CalendarMassInviteRankText:Show();
			UIDropDownMenu_EnableDropDown(CalendarMassInviteRankMenu);
		else
			CalendarMassInviteRankMenu:Hide();
			CalendarMassInviteRankText:Hide();
		end
		-- set text color back to normal
		CalendarMassInviteLevelText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		CalendarMassInviteMinLevelEdit:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		CalendarMassInviteMaxLevelEdit:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		CalendarMassInviteRankText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	else
		-- disable the accept button
		CalendarMassInviteAcceptButton:Disable();
		CalendarMassInviteRankMenu:Hide();
		CalendarMassInviteRankText:Hide();
		-- disable the rank drop down
		UIDropDownMenu_DisableDropDown(CalendarMassInviteRankMenu);
		-- set text color to a disabled color
		CalendarMassInviteLevelText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		CalendarMassInviteMinLevelEdit:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		CalendarMassInviteMaxLevelEdit:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		CalendarMassInviteRankText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end

function CalendarMassInviteRankMenu_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	for i = 1, GuildControlGetNumRanks() do
		info.text = GuildControlGetRankName(i);
		info.func = CalendarMassInviteGuildRankMenu_OnClick;
		if ( i == CalendarMassInviteFrame.selectedRank ) then
			info.checked = 1;
			UIDropDownMenu_SetText(CalendarMassInviteRankMenu, info.text);
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function CalendarMassInviteGuildRankMenu_OnClick(self)
	CalendarMassInviteFrame.selectedRank = self:GetID();
	UIDropDownMenu_SetSelectedID(CalendarMassInviteRankMenu, CalendarMassInviteFrame.selectedRank);
end

function CalendarMassInviteCommunityDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	local clubs = C_Club.GetSubscribedClubs()
	for i, clubInfo in ipairs(clubs) do
		if (clubInfo.clubType ~= Enum.ClubType.BattleNet) then
			if (clubInfo.clubType == Enum.ClubType.Guild) then
				info.text = GREEN_FONT_COLOR:WrapTextInColorCode(clubInfo.name);
			else
				info.text = clubInfo.name;
			end
			info.arg1 = clubInfo.clubId;
			info.func = CalendarMassInviteCommunityDropDown_OnClick;
			info.checked = clubInfo.clubId == CalendarMassInviteFrame.selectedClubId;
			UIDropDownMenu_AddButton(info);
		end
	end
end

function CalendarMassInviteCommunityDropDown_OnClick(self, clubId)
	local clubInfo = C_Club.GetClubInfo(clubId)
	if(clubInfo == nil) then
		return;
	end

	UIDropDownMenu_SetSelectedValue(CalendarMassInviteCommunityDropDown, self:GetText());
	CalendarMassInviteFrame.selectedClubId = clubId;
	CalendarMassInvite_Update();
end

function CalendarMassInviteAcceptButton_OnClick(self)
	local minLevel = CalendarMassInviteMinLevelEdit:GetNumber();
	local maxLevel = CalendarMassInviteMaxLevelEdit:GetNumber();

	local clubInfo = C_Club.GetClubInfo(CalendarMassInviteFrame.selectedClubId)
	if (clubInfo and  clubInfo.clubType == Enum.ClubType.Guild) then
		C_Calendar.MassInviteGuild(minLevel, maxLevel, CalendarMassInviteFrame.selectedRank);
	else
		C_Calendar.MassInviteCommunity(CalendarMassInviteFrame.selectedClubId, minLevel, maxLevel)
	end
	CalendarMassInviteFrame:Hide();
end

-- CalendarEventPickerFrame

function CalendarEventPickerFrame_OnLoad(self)
	self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST");
	self.dayButton = nil;
	self.selectedEvent = nil;
	
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CalendarEventPickerButtonTemplate", function(button, elementData)
		CalendarEventPickerFrame_InitButton(button, elementData);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function CalendarEventPickerFrame_OnEvent(self, event, ...)
	if ( self:IsShown() and event == "CALENDAR_UPDATE_EVENT_LIST" and self.dayButton ) then
		CalendarEventPickerFrame_Update();
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
	CalendarEventPickerFrame_Update();
end

function CalendarEventPickerFrame_Hide()
	CalendarContextMenu_Hide(CalendarDayContextMenu_Initialize);
	CalendarEventPickerFrame.dayButton = nil;
	CalendarEventPickerFrame:Hide();
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

function CalendarEventPickerFrame_InitButton(button, elementData)
	local dayButton = CalendarEventPickerFrame.dayButton;
	local monthOffset = dayButton.monthOffset;
	local day = dayButton.day;
	local eventIndex = elementData.index;
	button.eventIndex = eventIndex;

	local event = C_Calendar.GetDayEvent(monthOffset, day, eventIndex);
	local title = event.title;
	local buttonIcon = button.Icon;
	local buttonTitle = button.Title;
	local buttonTime = button.Time;

	-- set event texture
	buttonIcon:SetTexture();
	if ( event.iconTexture ) then
		local tcoords = _CalendarFrame_GetTextureCoords(event.calendarType, event.eventType);
		buttonIcon:SetTexture(event.iconTexture);
		buttonIcon:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
		buttonIcon:Show();
		buttonTitle:SetPoint("TOPLEFT", buttonIcon, "TOPRIGHT");
	else
		buttonIcon:Hide();
		buttonTitle:SetPoint("TOPLEFT", button, "TOPLEFT");
	end

	-- set event title and time
	if ( event.calendarType == "HOLIDAY" ) then
		buttonTime:Hide();
		buttonTitle:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT");
	else
		if ( event.calendarType == "RAID_LOCKOUT" ) then
			title = GetDungeonNameWithDifficulty(title, event.difficultyName);
		end
		local date = (event.sequenceType == "END") and event.endTime or event.startTime;
		buttonTime:SetText(GameTime_GetFormattedTime(date.hour, date.minute, true));
		buttonTime:Show();
		buttonTitle:SetPoint("BOTTOMLEFT", buttonTime, "BOTTOMLEFT");
	end
	buttonTitle:SetFormattedText(CALENDAR_CALENDARTYPE_NAMEFORMAT[event.calendarType][event.sequenceType], title);
	
	-- set event color
	local eventColor = _CalendarFrame_GetEventColor(event.calendarType, event.modStatus, event.inviteStatus);
	buttonTitle:SetTextColor(eventColor.r, eventColor.g, eventColor.b);

	-- set selected event
	if ( selectedEventIndex and eventIndex == selectedEventIndex ) then
		CalendarEventPickerFrame_SetSelectedEvent(button);
	else
		button:UnlockHighlight();
	end
end

function CalendarEventPickerFrame_Update()
	local dayButton = CalendarEventPickerFrame.dayButton;
	if dayButton.numViewableEvents <= CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS then
		CalendarEventPickerFrame_Hide();
		return;
	end

	local monthOffset = dayButton.monthOffset;
	local day = dayButton.day;

	local newDataProvider = CreateDataProvider();
	for index = 1, C_Calendar.GetNumDayEvents(monthOffset, day) do
		local event = C_Calendar.GetDayEvent(monthOffset, day, index);
		if event.title and event.sequenceType ~= "ONGOING" then
			newDataProvider:Insert({index = index});
		end
	end

	CalendarEventPickerFrame.ScrollBox:SetDataProvider(newDataProvider);
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

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
	
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CalendarTexturePickerButtonTemplate", function(button, elementData)
		CalendarTexturePicker_InitButton(button, elementData);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function CalendarTexturePickerFrame_Show(eventType)
	if ( not eventType ) then
		return;
	end
	if ( eventType ~= CalendarTexturePickerFrame.eventType) then
		if ( not _CalendarFrame_CacheEventDungeons(eventType) ) then
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
	CalendarTexturePickerFrame_UpdateScrollBox();
end

function CalendarTexturePickerFrame_UpdateScrollBox()
	local newDataProvider = CreateDataProvider();
	for index = 1, #CalendarEventDungeonCache do
		newDataProvider:Insert({cacheIndex = index});
	end
	CalendarTexturePickerFrame.ScrollBox:SetDataProvider(newDataProvider);
end

function CalendarTexturePickerTitleFrame_Update()
	if ( CalendarTexturePickerFrame.eventType == Enum.CalendarEventType.Raid ) then
		CalendarTexturePickerFrame.Header:Setup(CALENDAR_TEXTURE_PICKER_TITLE_RAID);
	else
		CalendarTexturePickerFrame.Header:Setup(CALENDAR_TEXTURE_PICKER_TITLE_DUNGEON);
	end
end

function CalendarTexturePicker_InitButton(button, elementData)
	local cacheIndex = elementData.cacheIndex;
	local dungeonCacheEntry = CalendarEventDungeonCache[cacheIndex];
	local eventType = CalendarTexturePickerFrame.eventType;
	local selectedTextureIndex = CalendarTexturePickerFrame.selectedTextureIndex;
	
	if ( dungeonCacheEntry.textureIndex ) then
		-- this is a texture
		button.textureIndex = dungeonCacheEntry.textureIndex;

		if ( selectedTextureIndex and button.textureIndex == selectedTextureIndex ) then
			button:LockHighlight();
			CalendarTexturePickerFrame.selectedTexture = button;
		else
			button:UnlockHighlight();
		end

		local name = dungeonCacheEntry.title;
		button.Title:SetText(GetDungeonNameWithDifficulty(name, dungeonCacheEntry.difficulties == nil and dungeonCacheEntry.difficultyName or ""));
		button.Title:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		button.Title:ClearAllPoints();
		button.Title:SetPoint("LEFT", button.Icon, "RIGHT");
		button.Title:Show();
		button.Icon:SetTexture();
		local tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
		button.Icon:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
		if ( dungeonCacheEntry.texture ) then
			button.Icon:SetTexture(dungeonCacheEntry.texture);
		else
			button.Icon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventType]);
		end
		button.Icon:Show();
		button:Enable();
	elseif ( dungeonCacheEntry.expansionLevel and dungeonCacheEntry.expansionLevel >= 0 ) then
		-- this is a header
		button.textureIndex = dungeonCacheEntry.textureIndex;
		button.Title:SetText(dungeonCacheEntry.title);
		button.Title:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		button.Title:ClearAllPoints();
		button.Title:SetPoint("LEFT", button.Icon, "LEFT");
		button.Title:Show();
		button.Icon:Hide();
		button:Disable();
	else
		-- this is a blank space
		button.textureIndex = nil;

		button.Title:Hide();
		button.Icon:Hide();
		button:Disable();
	end
end

function CalendarTexturePickerAcceptButton_OnClick(self)
	CalendarCreateEvent_SetSelectedIndex(CalendarTexturePickerFrame.selectedTextureIndex, CalendarTexturePickerFrame.eventType);
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

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
		CalendarClassButtonContainer:SetPoint("TOPLEFT", parent, "TOPRIGHT", -4, -30);
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
		count = classData.counts[Enum.CalendarStatus.Confirmed] +
			classData.counts[Enum.CalendarStatus.Available] +
			classData.counts[Enum.CalendarStatus.Signedup];
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
	GameTooltip:SetText(classData.name, nil, nil, nil, nil, true);
	GameTooltip:Show();
end

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
	GameTooltip:SetText(CALENDAR_TOOLTIP_INVITE_TOTALS, nil, nil, nil, nil, true);
	GameTooltip:Show();
end

function CalendarEventRetrievingFrame_OnUpdate(self, elapsed)
	if ( not self.timer ) then
		self.timer = 0.3;
	elseif ( self.timer < 0 ) then
		local dotCount = self.dotCount or 0;
		dotCount = dotCount + 1;
		if ( dotCount > 3 ) then
			dotCount = 0;
		end
		self.dots:SetText(string.rep(".", dotCount));
		self.dotCount = dotCount;
		self.timer = 0.3;
	else
		self.timer = self.timer - elapsed;
	end
end
