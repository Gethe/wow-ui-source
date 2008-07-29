

-- speed optimizations
local _G = getfenv(0);
local next = _G.next;
local date = _G.date;
local abs = _G.abs;
local min = _G.min;
local max = _G.max;
local floor = _G.floor;
local mod = _G.mod;
local tonumber = _G.tonumber;
local getglobal = _G.getglobal;
local random = _G.random;
local format = _G.format;
local select = _G.select;
local bit_band = _G.bit.band;
local bit_bor = _G.bit.bor;
local cos = _G.math.cos;
local PI = _G.PI;
local TWOPI = PI * 2.0;


-- static popups
StaticPopupDialogs["CALENDAR_INVITE"] = {
	text = CALENDAR_INVITE_LABEL,
	button1 = OKAY,
	button2 = CANCEL,
	whileDead = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnAccept = function(self)
		CalendarEventInvite(self.editBox:GetText());
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		CalendarEventInvite(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	OnShow = function (self)
		self.editBox:SetFocus();
		CalendarFrame_SetModal(self);
	end,
	OnHide = function (self)
		self.editBox:SetText("");
		CalendarFrame_SetModal(nil);
	end,
	timeout = 0,
	hideOnEscape = 1,
};
StaticPopupDialogs["CALENDAR_DELETE_EVENT"] = {
	text = CALENDAR_DELETE_EVENT_CONFIRM,
	button1 = OKAY,
	button2 = CANCEL,
	whileDead = 1,
	OnAccept = function(self)
		CalendarFrame_HideEventFrame();
		local dayButton = CalendarContextMenu.dayButton;
		local eventButton = CalendarContextMenu.eventButton;
		CalendarContextEventRemove(dayButton.monthOffset, dayButton.day, eventButton.eventIndex);
		if ( CalendarFrame.selectedEventButton == eventButton ) then
			CalendarDayEventButton_Click();
		end
	end,
	OnShow = function (self)
		CalendarFrame_SetModal(self);
	end,
	OnHide = function (self)
		CalendarFrame_SetModal(nil);
	end,
	timeout = 0,
	hideOnEscape = 1,
};
StaticPopupDialogs["CALENDAR_SET_DESCRIPTION"] = {
	text = CALENDAR_SET_DESCRIPTION_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 256,
	hasWideEditBox = 1,
	OnAccept = function(self)
		local text = self.wideEditBox:GetText();
		CalendarEventSetDescription(text);
		CalendarCreateEventDescription:SetText(text);
	end,
	OnShow = function(self)
		local text = CalendarCreateEventDescription:GetText();
		if ( text ~= CALENDAR_EVENT_DESCRIPTION ) then
			if ( text ) then
				self.wideEditBox:SetText(text);
			else
				self.wideEditBox:SetText("");
			end
		end
		self.wideEditBox:HighlightText();
		self.wideEditBox:SetFocus();
		CalendarFrame_SetModal(self);
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.wideEditBox:SetText("");
		CalendarFrame_SetModal(nil);
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		local text = parent.wideEditBox:GetText();
		CalendarCreateEventDescription:SetText(text);
		CalendarEventSetDescription(text);
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
};
StaticPopupDialogs["CALENDAR_ERROR"] = {
	text = CALENDAR_ERROR,
	button1 = OKAY,
	whileDead = 1,
	OnShow = function (self)
		--CalendarFrame_SetModal(self);
	end,
	OnHide = function (self)
		--CalendarFrame_SetModal(nil);
	end,
	timeout = 0,
	showAlert = 1,
	hideOnEscape = 1,
};

-- make the Calendar part of the UIParent menuing system
tinsert(UIMenus, "CalendarContextMenu");
UIPanelWindows["CalendarFrame"] = { area = "doublewide", pushable = 0, width = 840,	whileDead = 1, yOffset = 20 };
-- this table will attempt to close the first open menu in the list...ORDER IS IMPORTANT!
local CalendarMenus = {
	"CalendarEventPickerFrame",
	"CalendarDungeonPickerFrame",
	"CalendarMassInviteFrame",
	"CalendarCreateEventFrame",
	"CalendarViewEventFrame",
};
function CloseCalendarMenus()
	for _, menuName in next, CalendarMenus do
		local menu = getglobal(menuName);
		if ( menu and menu:IsShown() ) then
			if ( menu == CalendarFrame.eventFrame ) then
				CalendarFrame_HideEventFrame(menu);
			else
				menu:Hide();
			end
			return true;
		end
	end
	return false;
end


-- constants
local CALENDAR_MAX_DAYS_PER_MONTH			= 42;
local CALENDAR_MAX_DARKDAYS_PER_MONTH		= 14;

local CALENDAR_MAX_ADVANCE_SCHEDULING_DAYS	= 35;
local CALENDAR_MAX_HISTORY_DAYS				= 35;

-- Event Types
local CALENDAR_EVENTTYPE_RAID		= 1;
local CALENDAR_EVENTTYPE_DUNGEON	= 2;
local CALENDAR_EVENTTYPE_PVP		= 3;
local CALENDAR_EVENTTYPE_MEETING	= 4;
local CALENDAR_EVENTTYPE_OTHER		= 5;

-- Invite Statuses
local CALENDAR_INVITESTATUS_INVITED		= 1;
local CALENDAR_INVITESTATUS_ACCEPTED	= 2;
local CALENDAR_INVITESTATUS_DECLINED	= 3;
local CALENDAR_INVITESTATUS_CONFIRMED	= 4;
local CALENDAR_INVITESTATUS_OUT			= 5;
local CALENDAR_INVITESTATUS_STANDBY		= 6;

-- DayButton constants
local CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH	= 91 / 256;
local CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT	= 91 / 256;
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
local CALENDAR_DAYEVENTBUTTON_BACKDROP = {
	bgFile		= "Interface\\Calendar\\EventButtonBackdropBackground",
	edgeFile	= "Interface\\Calendar\\EventButtonBackdropBorder",
	tile		= false,
	tileSize	= 8,
	edgeSize	= 8,
	insets = {
		left	= 0,
		right	= 0,
		top		= 0,
		bottom	= 0,
	},
};

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
local CALENDAR_CREATEEVENTFRAME_DEFAULT_AUTOAPPROVE		= 1;
local CALENDAR_CREATEEVENTFRAME_DEFAULT_LOCK			= nil;

-- ViewEventFrame constants
local CALENDAR_VIEWEVENTFRAME_PULSE_SEC			= 0.7;
local CALENDAR_VIEWEVENTFRAME_OOPULSE_SEC		= 1.0 / (2.0*CALENDAR_VIEWEVENTFRAME_PULSE_SEC);	-- mul by 2 so the pulse constant counts for half a flash

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
local DARKFLAG_NEXTMONTH_CORNER_TOP			= DARKFLAG_NEXTMONTH_CORNER + DARKFLAG_SIDE_TOP;					-- day 7 of next month
local DARKFLAG_NEXTMONTH_CORNER_RIGHT		= DARKFLAG_NEXTMONTH_CORNER + DARKFLAG_SIDE_RIGHT;				-- day 8 of next month, index 42
local DARKFLAG_NEXTMONTH_CORNER_TOPLEFT		= DARKFLAG_NEXTMONTH_CORNER_TOP + DARKFLAG_SIDE_LEFT;				-- day 1 of next month
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
-- the dark day texture maps simplify tex coord setup for dark days
local DARKDAY_TOP_TCOORDS = {
	[DARKFLAG_PREVMONTH_TOP] = {
		left	= 0.177734375,
		right	= 0.35546875,
		top		= 0.0,
		bottom	= 0.1796875,
	},
	[DARKFLAG_PREVMONTH_TOPLEFT] = {
		left	= 0.0,
		right	= 0.177734375,
		top		= 0.0,
		bottom	= 0.1796875,
	},
	[DARKFLAG_PREVMONTH_TOPRIGHT] = {
		left	= 0.177734375,
		right	= 0.0,
		top		= 0.0,
		bottom	= 0.1796875,
	},
	[DARKFLAG_PREVMONTH_TOPLEFTRIGHT] = {
		left	= 0.0,
		right	= 0.177734375,
		top		= 0.71875,
		bottom	= 0.8984375,
	},

	-- next 3 are same as bottom (blank, left, right so no top/bottom changes)
	[DARKFLAG_NEXTMONTH] = {	-- no drop shadowing
		left	= 0.177734375,
		right	= 0.35546875,
		top		= 0.1796875,
		bottom	= 0.359375,
	},
	[DARKFLAG_NEXTMONTH_LEFT] = {
		left	= 0.177734375,
		right	= 0.0,
		top		= 0.359375,
		bottom	= 0.5390625,
	},
	[DARKFLAG_NEXTMONTH_RIGHT] = {
		left	= 0.0,
		right	= 0.177734375,
		top		= 0.359375,
		bottom	= 0.5390625,
	},

	[DARKFLAG_NEXTMONTH_TOP] = {
		left	= 0.177734375,
		right	= 0.35546875,
		top		= 0.0,
		bottom	= 0.1796875,
	},
	[DARKFLAG_NEXTMONTH_TOPLEFT] = {
		left	= 0.0,
		right	= 0.177734375,
		top		= 0.0,
		bottom	= 0.1796875,
	},
	[DARKFLAG_NEXTMONTH_TOPRIGHT] = {
		left	= 0.177734375,
		right	= 0.0,
		top		= 0.0,
		bottom	= 0.1796875,
	},

	-- day 8 of next month
	[DARKFLAG_NEXTMONTH_CORNER] = {
		left	= 0.177734375,
		right	= 0.35546875,
		top		= 0.5390625,
		bottom	= 0.71875,
	},
	-- day 7 of next month
	[DARKFLAG_NEXTMONTH_CORNER_TOP] = {
		left	= 0.0,
		right	= 0.177734375,
		top		= 0.5390625,
		bottom	= 0.71875,
	},
	-- day 8 of next month, index 42
	[DARKFLAG_NEXTMONTH_CORNER_RIGHT] = {
		left	= 0.35546875,
		right	= 0.533203125,
		top		= 0.1796875,
		bottom	= 0.359375,
	},
	-- day 1 of next month
	[DARKFLAG_NEXTMONTH_CORNER_TOPLEFT] = {
		left	= 0.0,
		right	= 0.177734375,
		top		= 0.1796875,
		bottom	= 0.359375,
	},
	-- day 1 of next month, 7th day of the week
	[DARKFLAG_NEXTMONTH_CORNER_TOPLEFTRIGHT] = {
		left	= 0.35546875,
		right	= 0.177734375,
		top		= 0.8984375,
		bottom	= 0.71875,
	},
};
local DARKDAY_BOTTOM_TCOORDS = {
	[DARKFLAG_PREVMONTH_BOTTOM] = {
		left	= 0.177734375,
		right	= 0.35546875,
		top		= 0.1796875,
		bottom	= 0.0,
	},
	[DARKFLAG_PREVMONTH_BOTTOMLEFT] = {
		left	= 0.0,
		right	= 0.177734375,
		top		= 0.1796875,
		bottom	= 0.0,
	},
	[DARKFLAG_PREVMONTH_BOTTOMRIGHT] = {
		left	= 0.177734375,
		right	= 0.0,
		top		= 0.359375,
		bottom	= 0.1796875,
	},
	[DARKFLAG_PREVMONTH_BOTTOMLEFTRIGHT] = {
		left	= 0.177734375,
		right	= 0.35546875,
		top		= 0.71875,
		bottom	= 0.8984375,
	},

	-- next 3 are same as top (blank, left, right--no difference between top & bottom)
	[DARKFLAG_NEXTMONTH] = {	-- no drop shadowing
		left	= 0.177734375,
		right	= 0.35546875,
		top		= 0.1796875,
		bottom	= 0.359375,
	},
	[DARKFLAG_NEXTMONTH_LEFT] = {
		left	= 0.177734375,
		right	= 0.0,
		top		= 0.359375,
		bottom	= 0.5390625,
	},
	[DARKFLAG_NEXTMONTH_RIGHT] = {
		left	= 0.0,
		right	= 0.177734375,
		top		= 0.359375,
		bottom	= 0.5390625,
	},

	[DARKFLAG_NEXTMONTH_BOTTOM] = {
		left	= 0.177734375,
		right	= 0.35546875,
		top		= 0.1796875,
		bottom	= 0.0,
	},
	[DARKFLAG_NEXTMONTH_BOTTOMLEFT] = {
		left	= 0.0,
		right	= 0.177734375,
		top		= 0.1796875,
		bottom	= 0.0,
	},
	[DARKFLAG_NEXTMONTH_BOTTOMRIGHT] = {
		left	= 0.177734375,
		right	= 0.0,
		top		= 0.1796875,
		bottom	= 0.0,
	},
	[DARKFLAG_NEXTMONTH_BOTTOMLEFTRIGHT] = {
		left	= 0.0,
		right	= 0.177734375,
		top		= 0.8984375,
		bottom	= 0.71875,
	},

	-- day 1 of next month, 7th day of the week, not index 42
	[DARKFLAG_NEXTMONTH_LEFTRIGHT] = {
		left	= 0.35546875,
		right	= 0.533203125,
		top		= 0.0,
		bottom	= 0.1796875,
	},
};

-- more local constants
local CALENDAR_MONTH_NAMES = {
	CALENDAR_MONTH_JANUARY,
	CALENDAR_MONTH_FEBRUARY,
	CALENDAR_MONTH_MARCH,
	CALENDAR_MONTH_APRIL,
	CALENDAR_MONTH_MAY,
	CALENDAR_MONTH_JUNE,
	CALENDAR_MONTH_JULY,
	CALENDAR_MONTH_AUGUST,
	CALENDAR_MONTH_SEPTEMBER,
	CALENDAR_MONTH_OCTOBER,
	CALENDAR_MONTH_NOVEMBER,
	CALENDAR_MONTH_DECEMBER
};

local CALENDAR_WEEKDAY_NAMES = {
	CALENDAR_WEEKDAY_SUNDAY,
	CALENDAR_WEEKDAY_MONDAY,
	CALENDAR_WEEKDAY_TUESDAY,
	CALENDAR_WEEKDAY_WEDNESDAY,
	CALENDAR_WEEKDAY_THURSDAY,
	CALENDAR_WEEKDAY_FRIDAY,
	CALENDAR_WEEKDAY_SATURDAY,
};

local CALENDAR_INVITESTATUS_NAMES = {
	[CALENDAR_INVITESTATUS_INVITED]		= CALENDAR_STATUS_INVITED,
	[CALENDAR_INVITESTATUS_ACCEPTED]	= CALENDAR_STATUS_ACCEPTED,
	[CALENDAR_INVITESTATUS_DECLINED]	= CALENDAR_STATUS_DECLINED,
	[CALENDAR_INVITESTATUS_CONFIRMED]	= CALENDAR_STATUS_CONFIRMED,
	[CALENDAR_INVITESTATUS_OUT]			= CALENDAR_STATUS_OUT,
	[CALENDAR_INVITESTATUS_STANDBY]		= CALENDAR_STATUS_STANDBY,
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
	[CALENDAR_EVENTTYPE_PVP]		= "Interface\\Icons\\Ability_Warrior_OffensiveStance",
	[CALENDAR_EVENTTYPE_MEETING]	= "Interface\\Calendar\\MeetingIcon",
	[CALENDAR_EVENTTYPE_OTHER]		= "Interface\\Icons\\INV_Misc_Bag_10",
};
local CALENDAR_EVENTTYPE_TCOORDS = {
	[CALENDAR_EVENTTYPE_RAID] = {
		left	= 0.0,
		right	= 0.796875,
		top		= 0.0,
		bottom	= 0.71875,
	},
	[CALENDAR_EVENTTYPE_DUNGEON] = {
		left	= 0.0,
		right	= 0.796875,
		top		= 0.0,
		bottom	= 0.71875,
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
			CALENDAR_EVENTTYPE_TEXTURES[CALENDAR_EVENTTYPE_PVP] = "Interface\\Icons\\INV_BannerPVP_02";
		else
			CALENDAR_EVENTTYPE_TEXTURES[CALENDAR_EVENTTYPE_PVP] = "Interface\\Icons\\INV_BannerPVP_01";
		end
	end
end

local CALENDAR_CALENDARTYPE_NAMEFORMAT = {
	["PLAYER"] = {
--		["START"]			= "%s",
--		["END"]				= "%s",
		[""]				= "%s",
	},
	["GUILD"] = {
--		["START"]			= "%s",
--		["END"]				= "%s",
		[""]				= "%s",
	},
	["SYSTEM"] = {
--		["START"]			= "%s",
--		["END"]				= "%s",
		[""]				= "%s",
	},
	["HOLIDAY"] = {
		["START"]			= CALENDAR_EVENTNAME_FORMAT_START,
		["END"]				= CALENDAR_EVENTNAME_FORMAT_END,
	},
	["RAID_LOCKOUT"] = {
--		["START"]			= "%s",
--		["END"]				= "%s",
		[""]				= "%s",
	},
	["ARENA"] = {
--		["START"]			= "%s",
--		["END"]				= "%s",
		[""]				= "%s",
	},
};
local CALENDAR_CALENDARTYPE_TEXTURE_PATHS = {
--	["PLAYER"]				= "",
--	["GUILD"]				= "",
--	["SYSTEM"]				= "",
	["HOLIDAY"]				= "",
--	["RAID_LOCKOUT"]		= "",
--	["ARENA"]				= "",
};
local CALENDAR_CALENDARTYPE_TEXTURES = {
--	["PLAYER"]				= "",
--	["GUILD"]				= "",
--	["SYSTEM"]				= "",
	["HOLIDAY"]				= "",
--	["RAID_LOCKOUT"]		= "",
--	["ARENA"]				= "",
};
local CALENDAR_CALENDARTYPE_TCOORDS = {
	["PLAYER"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["GUILD"] = {
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
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["RAID_LOCKOUT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["ARENA"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
};

-- local data
local CalendarDayButtons = { };


-- debugging
local function _Calendar_Debug_ErrorHandler(message)
	ChatFrame1:AddMessage("------ERROR------");
	ChatFrame1:AddMessage(message);
	ChatFrame1:AddMessage("--Stack Trace--");
	ChatFrame1:AddMessage(debugstack(2));
	ChatFrame1:AddMessage(" ");
end

local function _Calendar_Debug_GetFlagString(darkFlags)
	local str = "";
	if ( bit_band(darkFlags, DARKFLAG_PREVMONTH) ~= 0 ) then
		str = str.."DARKFLAG_PREVMONTH ";
	end
	if ( bit_band(darkFlags, DARKFLAG_NEXTMONTH) ~= 0 ) then
		str = str.."DARKFLAG_NEXTMONTH ";
	end
	if ( bit_band(darkFlags, DARKFLAG_CORNER) ~= 0 ) then
		str = str.."DARKFLAG_CORNER ";
	end
	if ( bit_band(darkFlags, DARKFLAG_SIDE_LEFT) ~= 0 ) then
		str = str.."DARKFLAG_SIDE_LEFT ";
	end
	if ( bit_band(darkFlags, DARKFLAG_SIDE_RIGHT) ~= 0 ) then
		str = str.."DARKFLAG_SIDE_RIGHT ";
	end
	if ( bit_band(darkFlags, DARKFLAG_SIDE_TOP) ~= 0 ) then
		str = str.."DARKFLAG_SIDE_TOP ";
	end
	if ( bit_band(darkFlags, DARKFLAG_SIDE_BOTTOM) ~= 0 ) then
		str = str.."DARKFLAG_SIDE_BOTTOM ";
	end
	return str;
end

local function _Calendar_Debug_PrintDarkFlags(index, day, darkTopFlags, darkBottomFlags)
	local button = CalendarDayButtons[index];
	debugprint(button:GetName().." Day"..day..":");
	debugprint("topflags=".._Calendar_Debug_GetFlagString(darkTopFlags));
	debugprint("botflags=".._Calendar_Debug_GetFlagString(darkBottomFlags));
end


-- local helper functions

local function safeselect(index, ...)
	local count = select("#", ...);
	if ( count > 0 and index <= count ) then
		return select(index, ...);
	else
		return nil;
	end
end

local function _Calendar_GetWeekdayIndex(dayButtonIndex)
	return mod(dayButtonIndex - 1, 7) + 1;
end

local function _CalendarFrame_GetFullDate(weekday, month, day, year)
	local weekdayName = CALENDAR_WEEKDAY_NAMES[weekday];
	local monthName = CALENDAR_MONTH_NAMES[month];
	return weekdayName, monthName, day, year, month;
end

local function _CalendarFrame_GetFullDateFromDay(dayButton)
	local month, year = CalendarGetMonth(dayButton.monthOffset);
	local weekday = _Calendar_GetWeekdayIndex(dayButton:GetID());
	local day = dayButton.day;
	return _CalendarFrame_GetFullDate(weekday, month, day, year);
end

local function _CalendarFrame_IsTodayOrLater(month, day, year)
	-- we can't make events for days that have already past...
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

local function _CalendarFrame_CanInviteeRSVP(inviteStatus)
	return
		inviteStatus == CALENDAR_INVITESTATUS_INVITED or
		inviteStatus == CALENDAR_INVITESTATUS_ACCEPTED or
		inviteStatus == CALENDAR_INVITESTATUS_DECLINED;
end

local function _CalendarFrame_GetEventTextureNameAndPath(textureIndex, eventType)
	if ( not textureIndex or not eventType ) then
		return;
	end
	local index = textureIndex*2 - 1;
	return safeselect(index, CalendarEventGetTextures(eventType));
end

local function _CalendarFrame_GetTextureFile(textureName, calendarType, eventType)
	local texture, tcoords;
	if ( textureName and textureName ~= "" ) then
		if ( CALENDAR_CALENDARTYPE_TEXTURE_PATHS[calendarType] ) then
			texture = CALENDAR_CALENDARTYPE_TEXTURE_PATHS[calendarType]..textureName;
			tcoords = CALENDAR_CALENDARTYPE_TCOORDS[calendarType];
		elseif ( CALENDAR_EVENTTYPE_TEXTURE_PATHS[eventType] ) then
			texture = CALENDAR_EVENTTYPE_TEXTURE_PATHS[eventType]..textureName;
			tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
		elseif ( CALENDAR_CALENDARTYPE_TEXTURES[calendarType] ) then
			texture = CALENDAR_CALENDARTYPE_TEXTURES[calendarType];
			tcoords = CALENDAR_CALENDARTYPE_TCOORDS[calendarType];
		elseif ( CALENDAR_EVENTTYPE_TEXTURES[eventType] ) then
			texture = CALENDAR_EVENTTYPE_TEXTURES[eventType];
			tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
		end
	elseif ( CALENDAR_CALENDARTYPE_TEXTURES[calendarType] ) then
		texture = CALENDAR_CALENDARTYPE_TEXTURES[calendarType];
		tcoords = CALENDAR_CALENDARTYPE_TCOORDS[calendarType];
	elseif ( CALENDAR_EVENTTYPE_TEXTURES[eventType] ) then
		texture = CALENDAR_EVENTTYPE_TEXTURES[eventType];
		tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
	end
	return texture, tcoords;
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
			end
			if ( frame.update ) then
				frame.update();
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

function CalendarFrame_OnLoad(self)
	self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST");
	self:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES");
	self:RegisterEvent("CALENDAR_OPEN_EVENT");
	self:RegisterEvent("CALENDAR_UPDATE_ERROR");

	-- initialize day buttons
	for i = 1, CALENDAR_MAX_DAYS_PER_MONTH do
		CalendarDayButtons[i] = CreateFrame("Button", "CalendarDayButton"..i, self, "CalendarDayButtonTemplate");
		CalendarFrame_InitDay(i);
	end

	-- initialize the selected date
	self.selectedMonth = nil;
	self.selectedDay = nil;
	self.selectedYear = nil;

	-- initialize the viewed date to the current date
	self.viewedMonth = self.selectedMonth;
	self.viewedYear = self.selectedYear;

	-- initialize modal dialog handling
	self.modalFrame = nil;

	--seterrorhandler(_Calendar_Debug_ErrorHandler);
end

function CalendarFrame_OnEvent(self, event, ...)
	if ( event == "CALENDAR_UPDATE_EVENT_LIST" ) then
		CalendarFrame_Update();
	elseif ( event == "CALENDAR_UPDATE_PENDING_INVITES" ) then
		CalendarFrame_Update();
	elseif ( event == "CALENDAR_OPEN_EVENT" ) then
		CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
		if ( CalendarEventIsModerator() ) then
			CalendarCreateEventFrame.mode = "edit";
			CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
			CalendarCreateEventFrame_Update();
		else
			CalendarFrame_ShowEventFrame(CalendarViewEventFrame);
		end
	elseif ( event == "CALENDAR_UPDATE_ERROR" ) then
		local message = ...;
		StaticPopup_Show("CALENDAR_ERROR", message);
	end
end

function CalendarFrame_OnShow(self)
	local weekday, month, day, year = CalendarGetDate();
	CalendarSetAbsMonth(month, year);
	CalendarFrame_Update();
end

function CalendarFrame_OnHide(self)
	-- hide everything now...the reason is that the calendar may clear the current event data next time
	-- the frame opens up
	CalendarFrame_HideEventFrame();
	CalendarDayEventButton_Click();
	CalendarEventPickerFrame_Hide();
	CalendarDungeonPickerFrame_Hide();
	CalendarContextMenu_Reset();
	StaticPopup_Hide("CALENDAR_SET_DESCRIPTION");
	StaticPopup_Hide("CALENDAR_DELETE_EVENT");
	StaticPopup_Hide("CALENDAR_ERROR");
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
	local texTop = random(0,1) * CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT;
	local texRight = texLeft + CALENDAR_DAYBUTTON_NORMALIZED_TEX_WIDTH;
	local texBottom = texTop + CALENDAR_DAYBUTTON_NORMALIZED_TEX_HEIGHT;
	tex:SetTexCoord(texLeft, texRight, texTop, texBottom);
	-- adjust the highlight texture layer
	tex = button:GetHighlightTexture();
	tex:SetAlpha(CALENDAR_DAYBUTTON_HIGHLIGHT_ALPHA);

	-- create event buttons
	local eventButton;
	for i = 1, CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS do
		eventButton = CreateFrame("Button", buttonName.."EventButton"..i, button, "CalendarDayEventButtonTemplate");
		if ( i == 1 ) then
			-- anchor first event button to the parent...
			eventButton:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", CALENDAR_DAYEVENTBUTTON_XOFFSET, -CALENDAR_DAYEVENTBUTTON_YOFFSET);
		else
			-- ...anchor the rest to the previous event button
			eventButton:SetPoint("BOTTOMLEFT", buttonName.."EventButton"..(i-1), "TOPLEFT", 0, CALENDAR_DAYEVENTBUTTON_YOFFSET);
		end
		eventButton:Hide();
	end
end

function CalendarFrame_Update()
	local presentWeekday, presentMonth, presentDay, presentYear = CalendarGetDate();
	local prevMonth, prevYear, prevNumDays = CalendarGetMonth(-1);
	local nextMonth, nextYear, nextNumDays = CalendarGetMonth(1);
	local month, year, numDays, firstWeekday = CalendarGetMonth();
	local selectedMonth = CalendarFrame.selectedMonth;
	local selectedDay = CalendarFrame.selectedDay;
	local selectedYear = CalendarFrame.selectedYear;

	CalendarFrame.viewedMonth = month;
	CalendarFrame.viewedYear = year;

	-- init textures to be hidden
	CalendarTodayTexture:Hide();
	CalendarDayButtonSelectedTexture:Hide();
	CalendarWeekdaySelectedTexture:Hide();
	CalendarLastDayDarkTexture:Hide();

	-- set title
	CalendarFrame_UpdateTitle();

	local buttonIndex = 1;
	local darkTexIndex = 1;
	local darkTopFlags = 0;
	local darkBottomFlags = 0;
	local isSelected, isSelectedMonth;
	local isToday, isThisMonth;
	local day;

	-- set the previous month's days before the first day of the week
	day = prevNumDays - (firstWeekday - 2);
	isSelectedMonth = selectedMonth == prevMonth and selectedYear == prevYear;
	isThisMonth = presentMonth == prevMonth and presentYear == prevYear;
	while ( buttonIndex < firstWeekday ) do
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
		isSelected = isSelectedMonth and selectedDay == day;
		isToday = isThisMonth and presentDay == day;

		CalendarFrame_UpdateDay(buttonIndex, day, -1, isSelected, isToday, darkTopFlags, darkBottomFlags);
		CalendarFrame_UpdateDayEvents(-1, buttonIndex, day);

		day = day + 1;
		darkTexIndex = darkTexIndex + 1;
		buttonIndex = buttonIndex + 1;
	end
	-- set the days of this month
	day = 1;
	isSelectedMonth = selectedMonth == month and selectedYear == year;
	isThisMonth = presentMonth == month and presentYear == year;
	while ( day <= numDays ) do
		isSelected = isSelectedMonth and selectedDay == day;
		isToday = isThisMonth and presentDay == day;

		CalendarFrame_UpdateDay(buttonIndex, day, 0, isSelected, isToday);
		CalendarFrame_UpdateDayEvents(0, buttonIndex, day);

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
	local dayOfWeek;
	local checkCorners = mod(buttonIndex, 7) ~= 1;	-- last day of the viewed month is not the last day of the week
	while ( buttonIndex <= CALENDAR_MAX_DAYS_PER_MONTH ) do
		darkTopFlags = DARKFLAG_NEXTMONTH;
		darkBottomFlags = DARKFLAG_NEXTMONTH;
		-- left darkness
		dayOfWeek = _Calendar_GetWeekdayIndex(buttonIndex);
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

		isSelected = isSelectedMonth and selectedDay == day;
		isToday = isThisMonth and presentDay == day;

		CalendarFrame_UpdateDay(buttonIndex, day, 1, isSelected, isToday, darkTopFlags, darkBottomFlags);
		CalendarFrame_UpdateDayEvents(1, buttonIndex, day);

		day = day + 1;
		darkTexIndex = darkTexIndex + 1;
		buttonIndex = buttonIndex + 1;
	end
end

function CalendarFrame_UpdateTitle()
	CalendarTitle:SetText(CALENDAR_MONTH_NAMES[CalendarFrame.viewedMonth]);
end

function CalendarFrame_UpdateDay(index, day, monthOffset, isSelected, isToday, darkTopFlags, darkBottomFlags)
	local button = CalendarDayButtons[index];
	local buttonName = button:GetName();
	local dateLabel = getglobal(buttonName.."DateFrameDate");
	local darkTop = getglobal(buttonName.."DarkFrameTop");
	local darkBottom = getglobal(buttonName.."DarkFrameBottom");
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
		button:UnlockHighlight();
	end

	-- highlight the button if it is today
	if ( isToday ) then
		--CalendarFrame_SetToday(button, dateLabel);
		CalendarFrame_SetToday(button, button);
	end
end

function CalendarFrame_UpdateDayEvents(monthOffset, index, day)
	local dayButton = CalendarDayButtons[index];
	local dayButtonName = dayButton:GetName();

	local numEvents = CalendarGetNumDayEvents(monthOffset, day);

	-- turn date background on if there is an event on this day
	local dateBackground = getglobal(dayButtonName.."DateFrameBackground");
	if ( numEvents > 0 ) then
		dateBackground:Show();
	else
		dateBackground:Hide();
	end

	-- get day info
	local pendingInviteIndex, calendarType, eventType, dayTexture = CalendarGetDay(monthOffset, day);

	-- set day texture
	local eventTex = getglobal(dayButtonName.."EventTexture");
	eventTex:SetTexture("");
	local texture, tcoords = _CalendarFrame_GetTextureFile(dayTexture, calendarType, eventType);
	if ( texture ) then
		eventTex:SetTexture(texture);
		eventTex:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
		eventTex:Show();
	else
		eventTex:Hide();
	end

	-- turn pending invite on if we have one on this day
	local pendingInviteTex = getglobal(dayButtonName.."PendingInviteTexture");
	if ( pendingInviteIndex > 0 ) then
		pendingInviteTex:Show();
	else
		pendingInviteTex:Hide();
	end

	-- store variables to adjust the individual event buttons based on the number of events in the day
	-- also, determine whether or not we need the more events button
	local moreEventsButton = getglobal(dayButtonName.."MoreEventsButton");
	local buttonHeight, textWidth;
	local text1RelPoint, text2Point, text2JustifyH;
	if ( numEvents <= CALENDAR_DAYBUTTON_MAX_VISIBLE_BIGEVENTS ) then
		moreEventsButton:Hide();
		buttonHeight = CALENDAR_DAYEVENTBUTTON_BIGHEIGHT;
		text1RelPoint = nil;
		text2Point = "BOTTOMLEFT";
		text2JustifyH = "LEFT";
	else
		-- while we're checking the number of events, show or hide the more events button
		if ( numEvents > CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS ) then
			moreEventsButton:Show();
		else
			moreEventsButton:Hide();
		end
		buttonHeight = CALENDAR_DAYEVENTBUTTON_HEIGHT;
		text1RelPoint = "BOTTOMLEFT";
		text2Point = "RIGHT";
		text2JustifyH = "RIGHT";
	end

	-- set a selected event index only if the selected day matches this day
	local selectedEventIndex;
	if ( CalendarFrame.selectedEventIndex and 
		 day == CalendarFrame.selectedEventDay and
		 CalendarFrame.viewedMonth == CalendarFrame.selectedEventMonth and
		 CalendarFrame.viewedYear == CalendarFrame.selectedEventYear ) then
		selectedEventIndex = CalendarFrame.selectedEventIndex;
	end

	local eventButton, eventButtonName, eventButtonBackground, eventButtonText1, eventButtonText2;
	local firstEventButton, prevEventButton;
	local title, hour, minute, calendarType, sequenceType, eventType, texture, modStatus;
	local i = 1;	-- event button index
	local j = 1;	-- event index
	while ( i <= CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS and j <= numEvents ) do
		title, hour, minute, calendarType, sequenceType, eventType, texture, modStatus = CalendarGetDayEvent(monthOffset, day, j);
		if ( title ) then
			eventButton = getglobal(dayButtonName.."EventButton"..i);
			eventButtonName = eventButton:GetName();
			--eventButtonBackground = getglobal(eventButtonName.."Background");
			eventButtonText1 = getglobal(eventButtonName.."Text1");
			eventButtonText2 = getglobal(eventButtonName.."Text2");

			-- record the eventIndex in the event button
			eventButton.eventIndex = j;

			-- record the first event button so we can anchor the event background to it
			if ( not firstEventButton ) then
				firstEventButton = eventButton;
			end

			-- anchor to the button
			eventButton:SetPoint("BOTTOMLEFT", dayButton, "BOTTOMLEFT", CALENDAR_DAYEVENTBUTTON_XOFFSET, -CALENDAR_DAYEVENTBUTTON_YOFFSET);
			if ( prevEventButton ) then
				-- anchor the prev button to this one...this makes the latest event stay at the bottom
				prevEventButton:SetPoint("BOTTOMLEFT", eventButton, "TOPLEFT", 0, -CALENDAR_DAYEVENTBUTTON_YOFFSET);
			end

			-- set the event button size
			eventButton:SetHeight(buttonHeight);

			-- set the event time and title
			if ( calendarType == "HOLIDAY" ) then
				-- holidays do not display the time, instead they allow the title text to expand
				-- to fill up the space where the time would have been
				eventButtonText1:Hide();
				eventButtonText2:SetFormattedText(CALENDAR_CALENDARTYPE_NAMEFORMAT[calendarType][sequenceType], title);
				eventButtonText2:ClearAllPoints();
				eventButtonText2:SetAllPoints(eventButton);
				eventButtonText2:SetJustifyH("LEFT");
				--eventButtonText2:SetJustifyV("BOTTOM");
				--eventButtonBackground:Hide();
				--eventButton:SetBackdrop(nil);
			else
				eventButtonText2:SetText(GameTime_GetFormattedTime(hour, minute, false));
				eventButtonText2:ClearAllPoints();
				eventButtonText2:SetPoint(text2Point, eventButton, text2Point);
				eventButtonText2:SetJustifyH(text2JustifyH);
				eventButtonText1:SetFormattedText(CALENDAR_CALENDARTYPE_NAMEFORMAT[calendarType][sequenceType], title);
				eventButtonText1:ClearAllPoints();
				eventButtonText1:SetPoint("TOPLEFT", eventButton, "TOPLEFT");
				if ( text1RelPoint ) then
					eventButtonText1:SetPoint("BOTTOMRIGHT", eventButtonText2, text1RelPoint);
				end
				if ( modStatus == "CREATOR" or modStatus == "MODERATOR" ) then
					eventButtonText1:SetFontObject(GameFontGreenSmall);
				else
					eventButtonText1:SetFontObject(GameFontNormalSmall);
				end
				eventButtonText1:Show();
				--eventButtonBackground:Show();
				--eventButton:SetBackdrop(CALENDAR_DAYEVENTBUTTON_BACKDROP);
			end

			if ( j == selectedEventIndex ) then
				CalendarFrame_SetSelectedEvent(eventButton);
			else
				eventButton:UnlockHighlight();
			end

			eventButton:Show();
			prevEventButton = eventButton;
			i = i + 1;
		end
		j = j + 1;
	end
	-- hide the remaining event buttons
	while ( i <= CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS ) do
		eventButton = getglobal(dayButtonName.."EventButton"..i);
		eventButton.eventIndex = nil;
		eventButton:Hide();
		i = i + 1;
	end

	-- record the first event
	local eventBackground = getglobal(dayButtonName.."EventBackgroundTexture");
	if ( firstEventButton ) then
		-- anchor the top of the event background to the first event button since it is always
		-- the highest in the list
		eventBackground:SetPoint("TOP", firstEventButton, "TOP", 0, 20);
		eventBackground:SetPoint("BOTTOM", dayButton, "BOTTOM");
		eventBackground:Show();
		dayButton.firstEventButton = firstEventButton;
	else
		eventBackground:Hide();
		dayButton.firstEventButton = nil;
	end
end

function CalendarFrame_SetSelectedDay(dayButton)
	--CalendarDayButtonSelectedTexture:SetParent(dayButton);
	--CalendarDayButtonSelectedTexture:ClearAllPoints();
	--CalendarDayButtonSelectedTexture:SetPoint("CENTER", dayButton, "CENTER");
	--CalendarDayButtonSelectedTexture:Show();
	local prevSelectedDayButton = CalendarFrame.selectedDayButton;
	if ( prevSelectedDayButton ) then
		prevSelectedDayButton:UnlockHighlight();
		prevSelectedDayButton:GetHighlightTexture():SetAlpha(CALENDAR_DAYBUTTON_HIGHLIGHT_ALPHA);
	end
	dayButton:LockHighlight();
	dayButton:GetHighlightTexture():SetAlpha(CALENDAR_DAYBUTTON_SELECTION_ALPHA);
	CalendarFrame.selectedDayButton = dayButton;

	-- highlight the weekday label at this point too
	local weekdayBackground = getglobal("CalendarWeekday".._Calendar_GetWeekdayIndex(dayButton:GetID()).."Background");
	CalendarWeekdaySelectedTexture:ClearAllPoints();
	CalendarWeekdaySelectedTexture:SetPoint("CENTER", weekdayBackground, "CENTER");
	CalendarWeekdaySelectedTexture:Show();
end

function CalendarFrame_SetToday(dayButton, anchor)
	CalendarTodayTexture:SetParent(dayButton);
	CalendarTodayTexture:ClearAllPoints();
	CalendarTodayTexture:SetPoint("CENTER", anchor, "CENTER");
	CalendarTodayTexture:Show();
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
	end
	CalendarFrame.selectedEventButton = eventButton;
	if ( CalendarFrame.selectedEventButton ) then
		CalendarFrame.selectedEventButton:LockHighlight();
	end
end

function CalendarFrame_OpenEvent(dayButton, eventIndex)
	local day = dayButton.day;
	local monthOffset = dayButton.monthOffset;
	local title, hour, minute, calendarType = CalendarGetDayEvent(monthOffset, day, eventIndex);
	if ( calendarType == "HOLIDAY" ) then
		CalendarFrame_ShowEventFrame(CalendarViewHolidayFrame);
	else
		CalendarGetEvent(monthOffset, day, eventIndex);
	end
end

function CalendarPrevMonthButton_OnClick()
	CalendarSetMonth(-1);
	CalendarContextMenu_Hide();
	StaticPopup_Hide("CALENDAR_DELETE_EVENT");
	CalendarEventPickerFrame_Hide();
	CalendarDungeonPickerFrame_Hide();
	CalendarDayEventButton_Click();
	CalendarFrame_HideEventFrame();
	CalendarFrame_Update();
end

function CalendarNextMonthButton_OnClick()
	CalendarSetMonth(1);
	CalendarContextMenu_Hide();
	StaticPopup_Hide("CALENDAR_DELETE_EVENT");
	CalendarEventPickerFrame_Hide();
	CalendarDungeonPickerFrame_Hide();
	CalendarFrame_HideEventFrame();
	CalendarDayEventButton_Click();
	CalendarFrame_Update();
end


-- Modal Dialog Support

function CalendarFrame_SetModal(frame)
	local changed = CalendarFrame.modalFrame ~= frame;
	if ( changed ) then
		CalendarFrame.modalFrame = frame;
		if ( frame ) then
			CalendarModalDummy:SetParent(frame);
			CalendarModalDummy:SetFrameLevel(frame:GetFrameLevel() - 1);
			CalendarModalDummy:Show();
		else
			CalendarModalDummy:SetParent(CalendarFrame);
			--CalendarModalDummy:SetFrameLevel(CalendarFrame:GetFrameLevel());
			CalendarModalDummy:Hide();
		end
	end
end

function CalendarModalDummy_OnShow(self)
	CalendarFrameModalOverlay:Show();
	CalendarPrevMonthButton:Disable();
	CalendarNextMonthButton:Disable();
	CalendarEventFrameBlocker:Show();
end

function CalendarModalDummy_OnHide(self)
	CalendarFrameModalOverlay:Hide();
	CalendarEventFrameBlocker:Hide();
	CalendarPrevMonthButton:Enable();
	CalendarNextMonthButton:Enable();
end

function CalendarEventFrameBlocker_OnShow(self)
	local eventFrame = CalendarFrame.eventFrame;
	if ( eventFrame and eventFrame:IsShown() ) then
		-- can't do SetAllPoints because the eventFrame anchors haven't been determined yet
		--CalendarEventFrameBlocker:SetAllPoints(eventFrame);
		CalendarEventFrameBlocker:SetWidth(eventFrame:GetWidth());
		CalendarEventFrameBlocker:SetHeight(eventFrame:GetHeight());

		local eventFrameOverlay = getglobal(eventFrame:GetName().."ModalOverlay");
		if ( eventFrameOverlay ) then
			eventFrameOverlay:Show();
		end
	else
		CalendarEventFrameBlocker:Hide();
	end
end

function CalendarEventFrameBlocker_OnHide(self)
	local eventFrame = CalendarFrame.eventFrame;
	if ( eventFrame ) then
		local eventFrameOverlay = getglobal(eventFrame:GetName().."ModalOverlay");
		if ( eventFrameOverlay ) then
			eventFrameOverlay:Hide();
		end
	end
end

function CalendarEventFrameBlocker_Update()
	local eventFrame = CalendarFrame.eventFrame;
	local modalFrame = CalendarFrame.modalFrame;
	if ( modalFrame ) then
		if ( eventFrame and eventFrame:IsShown() ) then
			-- can't do SetAllPoints because the eventFrame anchors haven't been determined yet
			--CalendarEventFrameBlocker:SetAllPoints(eventFrame);
			CalendarEventFrameBlocker:SetWidth(eventFrame:GetWidth());
			CalendarEventFrameBlocker:SetHeight(eventFrame:GetHeight());
			CalendarEventFrameBlocker:Show();

			local eventFrameOverlay = getglobal(eventFrame:GetName().."ModalOverlay");
			if ( eventFrameOverlay ) then
				eventFrameOverlay:Show();
			end
		end
	else
		if ( eventFrame ) then
			local eventFrameOverlay = getglobal(eventFrame:GetName().."ModalOverlay");
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
	local subMenu = getglobal(CalendarContextMenu.subMenu);
	if ( subMenu ) then
		subMenu:Hide();
	end
	CalendarContextMenu:ClearAllPoints();
	CalendarContextMenu:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
	CalendarContextMenu.attachFrame = attachFrame;
	CalendarContextMenu.func = func;
	CalendarContextMenu:Show();
	func(CalendarContextMenu, ...);
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

	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end

function CalendarContextMenu_OnEvent(self, event, ...)
	if ( event == "GUILD_ROSTER_UPDATE" ) then
		if ( self:IsShown() and self.func == CalendarDayContextMenu_Initialize ) then
			CalendarContextMenu_Show(self.attachFrame, self.func, "cursor", 3, -3, self.flags, self.dayButton, self.eventButton);
		end
	end
end

function CalendarContextMenu_OnHide(self)
	-- fail safe: unlock old highlights
	if ( self.dayButton and
		 self.dayButton ~= CalendarFrame.selectedDayButton ) then
		self.dayButton:UnlockHighlight();
		--self.dayButton = nil;
	end
	if ( self.eventButton and
		 self.eventButton ~= CalendarFrame.selectedEventButton and
		 self.eventButton ~= CalendarEventPickerFrame.selectedEventButton ) then
		self.eventButton:UnlockHighlight();
		--self.eventButton = nil;
		-- in order to avoid a strange behavior where the day unhighlights here,
		-- we are going to forcibly lock its highlight if the mouse is still over
		-- the event
		if ( self.dayButton ) then
			self.dayButton:LockHighlight();
		end
	end
	-- fail safe: always hide nested menus when this hides
	CalendarArenaTeamContextMenu:Hide();
	CalendarInviteStatusContextMenu:Hide();
end


-- CalendarDayContextMenu

function CalendarDayContextMenu_Initialize(menu, flags, dayButton, eventButton)
	UIMenu_Initialize(menu);

	-- unlock old highlights
	if ( menu.dayButton and
		 menu.dayButton ~= CalendarFrame.selectedDayButton ) then
		menu.dayButton:UnlockHighlight();
	end
	if ( menu.eventButton and
		 menu.eventButton ~= CalendarFrame.selectedEventButton and
		 menu.eventButton ~= CalendarEventPickerFrame.selectedEventButton ) then
		menu.eventButton:UnlockHighlight();
	end
	-- lock new highlights
	if ( dayButton ) then
		dayButton:LockHighlight();
	end
	if ( eventButton ) then
		eventButton:LockHighlight();
	end

	-- record the new day and event buttons
	menu.dayButton = dayButton;
	menu.eventButton = eventButton;
	menu.flags = flags;

	local day = dayButton.day;
	local monthOffset = dayButton.monthOffset;
	local month, year = CalendarGetMonth(monthOffset);

	local canCreateEvent = _CalendarFrame_IsTodayOrLater(month, day, year);

	local showDay = canCreateEvent and bit_band(flags, CALENDAR_CONTEXTMENU_FLAG_SHOWDAY) ~= 0;
	local showEvent = eventButton and bit_band(flags, CALENDAR_CONTEXTMENU_FLAG_SHOWEVENT) ~= 0;

	local needSpacer = false;
	if ( showDay ) then
		-- add guild selections if the player has a guild
		UIMenu_AddButton(menu, CALENDAR_CREATE_EVENT, nil, CalendarDayContextMenu_CreateEvent);
		if ( CanEditGuildEvent() ) then
			--UIMenu_AddButton(menu, CALENDAR_CREATE_GUILD_EVENT, nil, CalendarDayContextMenu_CreateGuildEvent);
			--UIMenu_AddButton(menu, CALENDAR_CREATE_GUILDWIDE_EVENT, nil, CalendarDayContextMenu_CreateGuildWideEvent);
			UIMenu_AddButton(menu, CALENDAR_CREATE_GUILD_ANNOUNCEMENT, nil, CalendarDayContextMenu_CreateGuildAnnouncement);
			needSpacer = true;
		end
		-- add arena team selection if the player has an arena team
		if ( IsInArenaTeam() ) then
			--UIMenu_AddButton(menu, CALENDAR_CREATE_ARENATEAM_EVENT, nil, nil, "CalendarArenaTeamContextMenu");
			needSpacer = true;
		end
	end
	if ( showEvent ) then
		local eventIndex = eventButton.eventIndex;
		local title, hour, minute, calendarType, sequenceType, eventType, texture, modStatus = CalendarGetDayEvent(monthOffset, day, eventIndex);
		-- add context items for the selected event
		if ( calendarType == "PLAYER" or calendarType == "GUILD" or calendarType == "ARENA" ) then
			if ( modStatus == "CREATOR" or modStatus == "MODERATOR" ) then
				-- spacer
				if ( needSpacer ) then
					UIMenu_AddButton(menu, "");
				end
				-- copy
				UIMenu_AddButton(menu, CALENDAR_COPY_EVENT, nil, CalendarDayContextMenu_CopyEvent);
				-- paste
				if ( CalendarContextEventClipboard() ) then
					UIMenu_AddButton(menu, CALENDAR_PASTE_EVENT, nil, CalendarDayContextMenu_PasteEvent);
				end
				-- delete
				UIMenu_AddButton(menu, CALENDAR_DELETE_EVENT, nil, CalendarDayContextMenu_DeleteEvent);
				-- report spam
				if ( CalendarEventCanComplain(monthOffset, day, eventIndex) ) then
					UIMenu_AddButton(menu, REPORT_SPAM, nil, CalendarDayContextMenu_ReportSpam);
				end
				needSpacer = true;
			elseif ( CalendarContextEventClipboard() ) then
				if ( needSpacer ) then
					UIMenu_AddButton(menu, "");
				end
				-- paste
				UIMenu_AddButton(menu, CALENDAR_PASTE_EVENT, nil, CalendarDayContextMenu_PasteEvent);
				-- report spam
				if ( CalendarEventCanComplain(monthOffset, day, eventIndex) ) then
					UIMenu_AddButton(menu, REPORT_SPAM, nil, CalendarDayContextMenu_ReportSpam);
				end
				needSpacer = true;
			elseif ( CalendarEventCanComplain(monthOffset, day, eventIndex) ) then
				if ( needSpacer ) then
					UIMenu_AddButton(menu, "");
				end
				-- report spam
				UIMenu_AddButton(menu, REPORT_SPAM, nil, CalendarDayContextMenu_ReportSpam);
				needSpacer = true;
			end
			local inviteStatus = CalendarContextInviteStatus(monthOffset, day, eventIndex);
			if ( canCreateEvent and _CalendarFrame_CanInviteeRSVP(inviteStatus) ) then
				-- spacer
				if ( needSpacer ) then
					UIMenu_AddButton(menu, "");
				end
				-- accept invitation
				if ( inviteStatus ~= CALENDAR_INVITESTATUS_ACCEPTED ) then
					UIMenu_AddButton(menu, CALENDAR_ACCEPT_INVITATION, nil, CalendarDayContextMenu_AcceptInvite);
				end
				-- decline invitation
				if ( inviteStatus ~= CALENDAR_INVITESTATUS_DECLINED ) then
					UIMenu_AddButton(menu, CALENDAR_DECLINE_INVITATION, nil, CalendarDayContextMenu_DeclineInvite);
				end
				needSpacer = false;
			end
			if ( modStatus ~= "CREATOR" and not CalendarContextEventIsGuildWide(monthOffset, day, eventIndex) ) then
				-- spacer
				if ( needSpacer ) then
					UIMenu_AddButton(menu, "");
				end
				-- remove event
				UIMenu_AddButton(menu, CALENDAR_REMOVE_INVITATION, nil, CalendarDayContextMenu_RemoveInvite);
			end
		end
	elseif ( canCreateEvent and CalendarContextEventClipboard() ) then
		-- add paste if we have a clipboard
		if ( needSpacer ) then
			UIMenu_AddButton(menu, "");
		end
		UIMenu_AddButton(menu, CALENDAR_PASTE_EVENT, nil, CalendarDayContextMenu_PasteEvent);
	end

	-- show an error if they summoned a context menu that they could not create an event for
	if ( UIMenu_GetNumButtons(menu) == 0 and
		 bit_band(flags, CALENDAR_CONTEXTMENU_FLAG_SHOWDAY) ~= 0 and
		 bit_band(flags, CALENDAR_CONTEXTMENU_FLAG_SHOWEVENT) == 0 ) then
		if ( not canCreateEvent ) then
			StaticPopup_Show("CALENDAR_ERROR", format(CALENDAR_ERROR_CREATEDATE_BEFORE_TODAY, _CalendarFrame_GetFullDate(CalendarGetDate())));
		end
	end

	UIMenu_FinishInitializing(menu);
end

function CalendarDayContextMenu_CreateEvent()
	CalendarNewEvent();
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
	CalendarDayButton_Click(CalendarContextMenu.dayButton)
	CalendarCreateEventFrame.mode = "create";
	CalendarCreateEventFrame.dayButton = CalendarContextMenu.dayButton;
	CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
	-- TEMP: this is done because this option doesn't generate a "CALENDAR_UPDATE_INVITE_LIST" event
	CalendarCreateEventFrame_Update();
end

function CalendarDayContextMenu_CreateGuildEvent()
	CalendarMassInviteFrame.dayButton = CalendarContextMenu.dayButton;
	CalendarFrame_ShowEventFrame(CalendarMassInviteFrame);
end

function CalendarDayContextMenu_CreateGuildAnnouncement()
	CalendarNewGuildWideEvent();
	CalendarDayButton_Click(CalendarContextMenu.dayButton)
	CalendarCreateEventFrame.mode = "create";
	CalendarCreateEventFrame.dayButton = CalendarContextMenu.dayButton;
	CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
	-- TEMP: this is done because this option doesn't generate a "CALENDAR_UPDATE_INVITE_LIST" event
	CalendarCreateEventFrame_Update();
end

function CalendarDayContextMenu_CopyEvent()
	local dayButton = CalendarContextMenu.dayButton;
	CalendarContextEventCopy(dayButton.monthOffset, dayButton.day, CalendarContextMenu.eventButton.eventIndex);
end

function CalendarDayContextMenu_PasteEvent()
	local dayButton = CalendarContextMenu.dayButton;
	CalendarContextEventPaste(dayButton.monthOffset, dayButton.day);
end

function CalendarDayContextMenu_DeleteEvent()
	StaticPopup_Show("CALENDAR_DELETE_EVENT");
end

function CalendarDayContextMenu_ReportSpam()
	local dayButton = CalendarContextMenu.dayButton;
	CalendarEventComplain(dayButton.monthOffset, dayButton.day, CalendarContextMenu.eventButton.eventIndex);
end

function CalendarDayContextMenu_AcceptInvite()
	local dayButton = CalendarContextMenu.dayButton;
	CalendarContextInviteAvailable(dayButton.monthOffset, dayButton.day, CalendarContextMenu.eventButton.eventIndex);
end

function CalendarDayContextMenu_DeclineInvite()
	local dayButton = CalendarContextMenu.dayButton;
	CalendarContextInviteDecline(dayButton.monthOffset, dayButton.day, CalendarContextMenu.eventButton.eventIndex);
end

function CalendarDayContextMenu_RemoveInvite()
	local dayButton = CalendarContextMenu.dayButton;
	CalendarContextInviteRemove(dayButton.monthOffset, dayButton.day, CalendarContextMenu.eventButton.eventIndex);
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
	UIMenu_FinishInitializing(self);
end

function CalendarArenaTeamContextMenuButton_OnClick_CreateArenaTeamEvent(self)
	CalendarNewArenaTeamEvent(self.value);
	-- hide parent menu
	CalendarContextMenu_Hide(CalendarDayContextMenu_Initialize);
	CalendarDayButton_Click(CalendarContextMenu.dayButton)
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

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:ClearLines();

	-- add date
	local fullDate = format(CALENDAR_EVENT_FULLDATE, _CalendarFrame_GetFullDateFromDay(self));
	GameTooltip:AddLine(fullDate, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine(" ");
	-- add events
	local title, hour, minute, calendarType, sequenceType, eventType, texture, modStatus;
	local eventTime;
	for i = 1, numEvents do
		title, hour, minute, calendarType, sequenceType, eventType, texture, modStatus = CalendarGetDayEvent(monthOffset, day, i);
		if ( title ) then
			if ( calendarType == "HOLIDAY" ) then
				-- holidays do not display the time
				GameTooltip:AddLine(
					format(CALENDAR_CALENDARTYPE_NAMEFORMAT[calendarType][sequenceType], title),
					HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			else
				eventTime = GameTime_GetFormattedTime(hour, minute, true);
				if ( modStatus == "CREATOR" or modStatus == "MODERATOR" ) then
					GameTooltip:AddDoubleLine(
						format(CALENDAR_CALENDARTYPE_NAMEFORMAT[calendarType][sequenceType], title),
						eventTime,
						GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b,
						HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
						1
					);
				else
					GameTooltip:AddDoubleLine(
						format(CALENDAR_CALENDARTYPE_NAMEFORMAT[calendarType][sequenceType], title),
						eventTime,
						NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
						HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
						1
					);
				end
			end
		end
	end
	GameTooltip:Show();
end

function CalendarDayButton_OnLeave(self)
	GameTooltip:Hide();
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
				CalendarDayEventButton_Click();
				CalendarFrame_HideEventFrame();
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
	if ( dayButton ~= CalendarFrame.selectedDayButton ) then
		dayButton:UnlockHighlight();
	end
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
end


-- CalendarDayEventButtonTemplate

function CalendarDayEventButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function CalendarDayEventButton_OnEnter(self)
	local dayButton = self:GetParent();
	CalendarDayButton_OnEnter(dayButton);
	dayButton:LockHighlight();
end

function CalendarDayEventButton_OnLeave(self)
	local dayButton = self:GetParent();
	CalendarDayButton_OnLeave(dayButton);
	if ( dayButton ~= CalendarFrame.selectedDayButton ) then
		dayButton:UnlockHighlight();
	end
end

function CalendarDayEventButton_OnClick(self, button)
--[[
	local dayButton = self:GetParent();
	local day = dayButton.day;
	local month, year = CalendarGetMonth(dayButton.monthOffset);
	local dayChanged = month ~= CalendarFrame.selectedMonth or day ~= CalendarFrame.selectedDay or year ~= CalendarFrame.selectedYear;
	CalendarDayButton_Click(dayButton);

	local day = dayButton.day;
	local month, year = CalendarGetMonth(dayButton.monthOffset);
	local eventChanged =
		CalendarFrame.selectedEventIndex ~= self.eventIndex or
		CalendarFrame.selectedEventDay ~= day or CalendarFrame.selectedEventMonth ~= month or CalendarFrame.selectedEventYear ~= year;

	if ( button == "LeftButton" ) then
		CalendarDayEventButton_Click(self, true);
		CalendarContextMenu_Hide();
	elseif ( button == "RightButton" ) then
		CalendarDayEventButton_Click(self, false);
		local flags = CALENDAR_CONTEXTMENU_FLAG_SHOWDAY + CALENDAR_CONTEXTMENU_FLAG_SHOWEVENT;
		if ( eventChanged ) then
			CalendarContextMenu_Show(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton, self);
		else
			CalendarContextMenu_Toggle(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton, self);
		end
	end
--]]
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
end

function CalendarDayEventButton_Click(button, openEvent)
	if ( not button ) then
		StaticPopup_Hide("CALENDAR_DELETE_EVENT");
		CalendarFrame.selectedEventIndex = nil;
		CalendarFrame.selectedEventMonth = nil;
		CalendarFrame.selectedEventDay = nil;
		CalendarFrame.selectedEventYear = nil;
		CalendarFrame_SetSelectedEvent();
		return;
	end

	local dayButton = button:GetParent();
	local day = dayButton.day;
	local month, year = CalendarGetMonth(dayButton.monthOffset);
	local eventIndex = button.eventIndex;
	if ( CalendarFrame.selectedEventIndex ~= eventIndex or
		 CalendarFrame.selectedEventDay ~= day or CalendarFrame.selectedEventMonth ~= month or CalendarFrame.selectedEventYear ~= year ) then
		StaticPopup_Hide("CALENDAR_DELETE_EVENT");
		CalendarFrame.selectedEventIndex = eventIndex;
		CalendarFrame.selectedEventMonth = month;
		CalendarFrame.selectedEventDay = day;
		CalendarFrame.selectedEventYear = year;
		CalendarFrame_SetSelectedEvent(button);
	end
	if ( CalendarEventPickerFrame:IsShown() ) then
		CalendarEventPickerScrollFrame_Update();
	end

	if ( openEvent ) then
		CalendarFrame_OpenEvent(dayButton, eventIndex);
	end
end


-- CalendarViewHolidayFrame

function CalendarViewHolidayFrame_OnLoad(self)
	self.update = CalendarViewHolidayFrame_Update;
end

function CalendarViewHolidayFrame_OnShow(self)
	CalendarViewHolidayFrame_Update();
end

function CalendarViewHolidayFrame_Update()
	local dayButton = CalendarFrame.selectedDayButton;
	local name, description, texture = CalendarGetHolidayInfo(dayButton.monthOffset, dayButton.day, CalendarFrame.selectedEventIndex);
	CalendarViewHolidayFrameTitle:SetText(name);
	CalendarViewHolidayFrameTitleBackgroundMiddle:SetWidth(max(140, CalendarViewHolidayFrameTitle:GetWidth()));
	CalendarViewHolidayDescription:SetText(description);
	if ( texture ) then
		CalendarViewHolidayBackground:SetTexture("");
		if ( CALENDAR_CALENDARTYPE_TEXTURE_PATHS["HOLIDAY"] ) then
			CalendarViewHolidayBackground:SetTexture(CALENDAR_CALENDARTYPE_TEXTURE_PATHS["HOLIDAY"]..texture);
			CalendarViewHolidayBackground:Show();
		elseif ( CALENDAR_CALENDARTYPE_TEXTURES["HOLIDAY"] ) then
			CalendarViewHolidayBackground:SetTexture(CALENDAR_CALENDARTYPE_TEXTURES["HOLIDAY"]);
			CalendarViewHolidayBackground:Show();
		else
			CalendarViewHolidayBackground:Hide();
		end
	else
		CalendarViewHolidayBackground:Hide();
	end
end


-- CalendarViewEventFrame

function CalendarViewEventFrame_OnLoad(self)
	self:RegisterEvent("CALENDAR_UPDATE_EVENT");
	self:RegisterEvent("CALENDAR_UPDATE_INVITE_LIST");
	self:RegisterEvent("CALENDAR_CLOSE_EVENT");

	self.update = CalendarViewEventFrame_Update;
	self.selectedInvite = nil;
	self.selectedInviteIndex = nil;
	self.myInviteIndex = nil;
	self.flashValue = 1.0
	self.flashTimer = 0.0;

	self.defaultHeight = self:GetHeight();

	CalendarViewEventInviteListScrollFrame.update = CalendarViewEventInviteListScrollFrame_Update;
	HybridScrollFrame_CreateButtons(CalendarViewEventInviteListScrollFrame, "CalendarViewEventInviteListButtonTemplate");
end

function CalendarViewEventFrame_OnEvent(self, event, ...)
	if ( CalendarViewEventFrame:IsShown() ) then
		if ( event == "CALENDAR_UPDATE_EVENT" ) then
			CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
			if ( CalendarEventIsModerator() ) then
				CalendarCreateEventFrame.mode = "edit";
				CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
			else
				CalendarViewEventFrame_Update();
			end
		elseif ( event == "CALENDAR_UPDATE_INVITE_LIST" ) then
			CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
			if ( CalendarEventIsModerator() ) then
				CalendarCreateEventFrame.mode = "edit";
				CalendarFrame_ShowEventFrame(CalendarCreateEventFrame);
			else
				-- RSVP'ing to the event can induce an invite list update, so we
				-- need to do an RSVP update
				CalendarViewEventRSVP_Update();
				CalendarViewEventInviteListScrollFrame_Update();
			end
		elseif ( event == "CALENDAR_CLOSE_EVENT" ) then
			CalendarFrame_HideEventFrame(CalendarViewEventFrame);
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

function CalendarViewEventFrame_OnUpdate(self, elapsed)
	local flashIndex = TWOPI * self.flashTimer * CALENDAR_VIEWEVENTFRAME_OOPULSE_SEC;
	self.flashValue = max(0.0, 0.5 + 0.5*cos(flashIndex));
	if ( flashIndex >= TWOPI ) then
		self.flashTimer = 0.0;
	else
		self.flashTimer = self.flashTimer + elapsed;
	end
end

function CalendarViewEventFrame_Update()
	local title, description, eventType, repeatOption, maxSize, textureIndex,
		weekday, month, day, year, hour, minute,
		lockoutWeekday, lockoutMonth, lockoutDay, lockoutYear, lockoutHour, lockoutMinute,
		locked, autoApprove, pendingInvite, inviteStatus = CalendarGetEventInfo();
	if ( not title ) then
		-- event was probably deleted
		CalendarFrame_HideEventFrame(CalendarViewEventFrame);
		return;
	end
	-- reset the flash timer to reinforce the visual feedback that the player is switching between events
	CalendarViewEventFrame.flashTimer = 0.0;
	-- set the event type
	CalendarViewEventTypeName:SetText(safeselect(eventType, CalendarEventGetTypes()));
	-- set the icon
	CalendarViewEventIcon:SetTexture("");
	local tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
	CalendarViewEventIcon:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
	if ( textureIndex > 0 ) then
		-- set the dungeon name since we have one
		local dungeonName, dungeonTexture = _CalendarFrame_GetEventTextureNameAndPath(textureIndex, eventType);
		CalendarViewEventDungeonName:SetText(dungeonName);
		CalendarViewEventDungeonName:Show();
		-- set the point of the next element to the dungeon name since we are showing it now
		CalendarViewEventDateLabel:SetPoint("TOPLEFT", CalendarViewEventDungeonName, "BOTTOMLEFT");
		-- set the dungeon texture
		if ( dungeonTexture ~= "" ) then
			CalendarViewEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURE_PATHS[eventType]..dungeonTexture);
		else
			CalendarViewEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventType]);
		end
	else
		CalendarViewEventDungeonName:Hide();
		CalendarViewEventDateLabel:SetPoint("TOPLEFT", CalendarViewEventTypeName, "BOTTOMLEFT");
		CalendarViewEventIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventType]);
	end
	-- set the date
	CalendarViewEventDateLabel:SetFormattedText(CALENDAR_EVENT_FULLDATE, _CalendarFrame_GetFullDate(weekday, month, day, year));
	-- set the time
	CalendarViewEventTimeLabel:SetText(GameTime_GetFormattedTime(hour, minute, true));
	-- set the description
	CalendarViewEventDescription:SetText(description);
	-- change the look based on the locked status
	if ( locked ) then
		-- set the event title
		CalendarViewEventTitle:SetFormattedText(CALENDAR_VIEW_EVENTTITLE_LOCKED, title);
		SetTextureDesaturated(CalendarViewEventIcon, true);
		CalendarViewEventTypeName:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		--CalendarViewEventDungeonName:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		--CalendarViewEventDateLabel:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		--CalendarViewEventTimeLabel:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		CalendarViewEventDescription:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	else
		-- set the event title
		CalendarViewEventTitle:SetText(title);
		SetTextureDesaturated(CalendarViewEventIcon, false);
		CalendarViewEventTypeName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		--CalendarViewEventDungeonName:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		--CalendarViewEventDateLabel:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		--CalendarViewEventTimeLabel:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		CalendarViewEventDescription:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	if ( CalendarEventIsGuildWide() ) then
		CalendarViewEventFrameTitle:SetText(CALENDAR_VIEW_ANNOUNCEMENT);
		-- guild wide events don't have invite lists, auto approval, or event locks
		CalendarViewEventInviteListFrame:Hide();
		CalendarViewEventFrame:SetHeight(CalendarViewEventFrame.defaultHeight - CalendarViewEventInviteListFrame:GetHeight());
	else
		CalendarViewEventFrameTitle:SetText(CALENDAR_VIEW_EVENT);
		CalendarViewEventInviteListFrame:Show();
		CalendarViewEventFrame:SetHeight(CalendarViewEventFrame.defaultHeight);
		if ( locked ) then
			-- event locked...you cannot respond to the event
			--CalendarViewEventSetStatus:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			CalendarViewEventAvailableButton:Disable();
			CalendarViewEventDeclineButton:Disable();
			CalendarViewEventAvailableButtonFlashTexture:Hide();
			CalendarViewEventDeclineButtonFlashTexture:Hide()
			CalendarViewEventFrame:SetScript("OnUpdate", nil);
		else
			CalendarViewEventRSVP_Update();
		end

		CalendarViewEventInviteListScrollFrame_Update();
	end
end

function CalendarViewEventAvailableButton_OnUpdate(self)
	CalendarViewEventAvailableButtonFlashTexture:SetAlpha(CalendarViewEventFrame.flashValue);
end

function CalendarViewEventAvailableButton_OnClick(self)
	CalendarEventAvailable();
end

function CalendarViewEventDeclineButton_OnUpdate(self)
	CalendarViewEventDeclineButtonFlashTexture:SetAlpha(CalendarViewEventFrame.flashValue);
end

function CalendarViewEventDeclineButton_OnClick(self)
	CalendarEventDecline();
end

function CalendarViewEventRemoveButton_OnClick(self)
	CalendarRemoveEvent();
	CalendarFrame_HideEventFrame(CalendarViewEventFrame);
end

function CalendarViewEventRSVP_Update()
	local title, description, eventType, repeatOption, maxSize, textureIndex,
		weekday, month, day, year, hour, minute,
		lockoutWeekday, lockoutMonth, lockoutDay, lockoutYear, lockoutHour, lockoutMinute,
		locked, autoApprove, pendingInvite, inviteStatus = CalendarGetEventInfo();
	if ( _CalendarFrame_IsTodayOrLater(month, day, year) and _CalendarFrame_CanInviteeRSVP(inviteStatus) ) then
		--CalendarViewEventSetStatus:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		if ( inviteStatus ~= CALENDAR_INVITESTATUS_ACCEPTED ) then
			CalendarViewEventAvailableButton:Enable();
		else
			CalendarViewEventAvailableButton:Disable();
		end
		if ( inviteStatus ~= CALENDAR_INVITESTATUS_DECLINED ) then
			CalendarViewEventDeclineButton:Enable();
		else
			CalendarViewEventDeclineButton:Disable();
		end
		if ( CalendarEventHasPendingInvite() ) then
			CalendarViewEventAvailableButtonFlashTexture:Show();
			CalendarViewEventDeclineButtonFlashTexture:Show()
		else
			CalendarViewEventAvailableButtonFlashTexture:Hide();
			CalendarViewEventDeclineButtonFlashTexture:Hide()
		end
		CalendarViewEventFrame:SetScript("OnUpdate", CalendarViewEventFrame_OnUpdate);
	else
		--CalendarViewEventSetStatus:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		CalendarViewEventAvailableButton:Disable();
		CalendarViewEventDeclineButton:Disable();
		CalendarViewEventAvailableButtonFlashTexture:Hide();
		CalendarViewEventDeclineButtonFlashTexture:Hide()
		CalendarViewEventFrame:SetScript("OnUpdate", nil);
	end
end

function CalendarViewEventInviteListScrollFrame_Update()
	local buttons = CalendarViewEventInviteListScrollFrame.buttons;
	local numInvites = CalendarEventGetNumInvites();
	local numButtons = #buttons;
	local totalHeight = numInvites * buttons[1]:GetHeight();

	CalendarViewEventFrame.myInviteIndex = nil;

	local button, buttonName, classColor, buttonTexture, buttonNameString, buttonClass, buttonStatus;
	local name, level, className, inviteStatus, modStatus, inviteIsMine;
	local displayedHeight = 0;
	local inviteIndex = 0;
	local selectedInvite = CalendarViewEventFrame.selectedInvite;
	local offset = HybridScrollFrame_GetOffset(CalendarViewEventInviteListScrollFrame);
	for i = 1, numButtons do
		-- get current button info
		button = buttons[i];
		buttonName = button:GetName();
		inviteIndex = i + offset;
		name, level, className, classFilename, inviteStatus, modStatus, inviteIsMine = CalendarEventGetInvite(inviteIndex);
		if ( name ) then
			button.inviteIndex = inviteIndex;
			-- setup button text
			buttonTexture = getglobal(buttonName.."Texture");
			classColor = RAID_CLASS_COLORS[classFilename];
			buttonNameString = getglobal(buttonName.."Name");
			buttonNameString:SetText(name);
			buttonNameString:SetTextColor(classColor.r, classColor.g, classColor.b);
			if ( modStatus == "CREATOR" ) then
				buttonTexture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
				buttonTexture:Show();
				buttonNameString:SetPoint("LEFT", buttonTexture, "RIGHT");
			elseif ( modStatus == "MODERATOR" ) then
				buttonTexture:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
				buttonTexture:Show();
				buttonNameString:SetPoint("LEFT", buttonTexture, "RIGHT");
			else
				buttonTexture:Hide();
				buttonNameString:SetPoint("LEFT", buttonTexture, "LEFT");
			end
			buttonClass = getglobal(buttonName.."Class");
			buttonClass:SetText(className);
			buttonClass:SetTextColor(classColor.r, classColor.g, classColor.b);
			buttonStatus = getglobal(buttonName.."Status");
			buttonStatus:SetText(CALENDAR_INVITESTATUS_NAMES[inviteStatus]);
			buttonStatus:SetTextColor(classColor.r, classColor.g, classColor.b);
			-- set the selected button
			if ( selectedInviteIndex and inviteIndex == selectedInviteIndex ) then
				button:LockHighlight();
				CalendarViewEventFrame.selectedInvite = button;
			else
				button:UnlockHighlight();
			end
			if ( inviteIsMine ) then
				-- we need to know which invite belongs to the player because this is the only invite that
				-- gets context menu options
				-- MFS NOTE: uncomment this line to show the context menu for your own invite
				--CalendarViewEventFrame.myInviteIndex = inviteIndex;
			end
			button:Show();
		else
			button.inviteIndex = nil;
			button:Hide();
		end
		displayedHeight = displayedHeight + button:GetHeight();
	end

	HybridScrollFrame_Update(CalendarViewEventInviteListScrollFrame, numInvites, totalHeight, displayedHeight);
end

function CalendarViewEventInviteListButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function CalendarViewEventInviteListButton_OnClick(self, button)
	local inviteIndex = self.inviteIndex;
	local selectionChanged = inviteIndex ~= CalendarViewEventFrame.selectedInviteIndex;
	if ( CalendarViewEventFrame.selectedInvite ) then
		CalendarViewEventFrame.selectedInvite:UnlockHighlight();
	end
	CalendarViewEventFrame.selectedInvite = self;
	CalendarViewEventFrame.selectedInviteIndex = inviteIndex;
	self:LockHighlight();

	if ( CalendarEventHasPendingInvite() and inviteIndex == CalendarViewEventFrame.myInviteIndex ) then
		if ( button == "RightButton" ) then
			if ( selectionChanged ) then
				CalendarContextMenu_Show(self, CalendarViewEventInviteContextMenu_Initialize, "cursor", 3, -3, inviteIndex);
			else
				CalendarContextMenu_Toggle(self, CalendarViewEventInviteContextMenu_Initialize, "cursor", 3, -3, inviteIndex);
			end
		end
	end
end

function CalendarViewEventInviteContextMenu_Initialize(menu)
	UIMenu_Initialize(menu);

	-- set invite status submenu
	UIMenu_AddButton(menu, CALENDAR_SET_INVITE_STATUS, nil, nil, "CalendarInviteStatusContextMenu");

	UIMenu_AutoSize(menu);
end


-- CalendarCreateEventFrame

function CalendarCreateEventFrame_OnLoad(self)
	self:RegisterEvent("CALENDAR_UPDATE_EVENT");
	self:RegisterEvent("CALENDAR_UPDATE_INVITE_LIST");
	self:RegisterEvent("CALENDAR_NEW_EVENT");
	self:RegisterEvent("CALENDAR_CLOSE_EVENT");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE");

	-- used to update the frame when it is shown via CalendarFrame_ShowEventFrame
	self.update = CalendarCreateEventFrame_Update;

	CalendarCreateEventFrame.militaryTime = GetCVarBool("timeMgrMilitaryTime");
	CalendarCreateEventFrame.selectedInviteIndex = nil;

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
	CalendarCreateEventInviteListScrollFrame.update = CalendarCreateEventInviteListScrollFrame_Update;
	HybridScrollFrame_CreateButtons(CalendarCreateEventInviteListScrollFrame, "CalendarCreateEventInviteListButtonTemplate");
end

function CalendarCreateEventFrame_OnEvent(self, event, ...)
	if ( CalendarCreateEventFrame:IsShown() ) then
		if ( event == "CALENDAR_UPDATE_EVENT" ) then
			if ( CalendarEventIsModerator() ) then
				CalendarCreateEventFrame_Update();
			else
				CalendarFrame_ShowEventFrame(CalendarViewEventFrame);
			end
		elseif ( event == "CALENDAR_UPDATE_INVITE_LIST" ) then
			CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
			if ( not CalendarEventIsModerator() ) then
				-- if we're not a moderator any more then show the view event frame immediately
				CalendarFrame_ShowEventFrame(CalendarViewEventFrame);
				return;
			end
			local initialList = ...;
			--[[
			if ( initialList ) then
				-- in this case, a new event was made and the initial invite list is now ready
				-- we need to update the new event with data now
				CalendarCreateEventFrame_Update();
			else
				CalendarCreateEventInviteListScrollFrame_Update();
			end
			--]]
			CalendarCreateEventInviteListScrollFrame_Update();
		elseif ( event == "CALENDAR_NEW_EVENT" or event == "CALENDAR_CLOSE_EVENT" ) then
			-- the CALENDAR_NEW_EVENT event gets fired when you successfully create a calendar event,
			-- so to provide feedback to the player, we close the create event frame when we get this
			-- event...the other part of the feedback is that the event shows up on their calendar
			-- (that part gets picked up by a CALENDAR_UPDATE_EVENT_LIST event)
			CalendarFrame_HideEventFrame(CalendarCreateEventFrame);
		elseif ( event == "GUILD_ROSTER_UPDATE" or event == "ARENA_TEAM_ROSTER_UPDATE" ) then
			CalendarCreateEventMassInviteButton_Update();
		end
	end
end

function CalendarCreateEventFrame_OnShow(self)
	--CalendarCreateEventFrame_Update();
end

function CalendarCreateEventFrame_OnHide(self)
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
	CalendarMassInviteFrame:Hide();
	--CalendarDayEventButton_Click();
end

function CalendarCreateEventFrame_Update()
	CalendarCreateEventFrame.militaryTime = GetCVarBool("timeMgrMilitaryTime");
	if ( CalendarCreateEventFrame.mode == "create" ) then
		CalendarCreateEventAcceptButton:SetText(CREATE);

		-- set the event date based on the selected date
		local dayButton = CalendarCreateEventFrame.dayButton;
		CalendarCreateEventDateLabel:SetFormattedText(CALENDAR_EVENT_FULLDATE, _CalendarFrame_GetFullDateFromDay(dayButton));
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
		CalendarCreateEventDescription:SetText(CALENDAR_CREATEEVENTFRAME_DEFAULT_DESCRIPTION);
		CalendarEventSetDescription("");
		-- reset event time
		CalendarCreateEventFrame.militaryTime = GetCVarBool("timeMgrMilitaryTime");
		CalendarCreateEventFrame.selectedMinute = CALENDAR_CREATEEVENTFRAME_DEFAULT_MINUTE;
		CalendarCreateEventFrame.selectedAM = CALENDAR_CREATEEVENTFRAME_DEFAULT_AM;
		if ( CalendarCreateEventFrame.militaryTime ) then
			CalendarCreateEventFrame.selectedHour = GameTime_ComputeMilitaryTime(CALENDAR_CREATEEVENTFRAME_DEFAULT_HOUR, CalendarCreateEventFrame.selectedAM);
		else
			CalendarCreateEventFrame.selectedHour = CALENDAR_CREATEEVENTFRAME_DEFAULT_HOUR;
		end
		CalendarCreateEvent_UpdateEventTime();
		CalendarCreateEvent_SetEventTime();
		-- reset event type
		CalendarCreateEventFrame.selectedEventType = CALENDAR_CREATEEVENTFRAME_DEFAULT_TYPE;
		CalendarCreateEventFrame.selectedDungeonIndex = nil;
		CalendarCreateEvent_UpdateEventType();
		CalendarEventSetType(CalendarCreateEventFrame.selectedEventType);
		-- reset repeat option
		CalendarCreateEventFrame.selectedRepeatOption = CALENDAR_CREATEEVENTFRAME_DEFAULT_REPEAT_OPTION;
		CalendarCreateEvent_UpdateRepeatOption();
		CalendarEventSetRepeatOption(CalendarCreateEventFrame.selectedRepeatOption);
		if ( CalendarEventIsGuildWide() ) then
			CalendarCreateEventFrameTitle:SetText(CALENDAR_CREATE_ANNOUNCEMENT);
			-- guild wide events don't have invites
			CalendarCreateEventInviteListFrame:Hide();
			CalendarCreateEventMassInviteButton:Hide();
			CalendarCreateEventFrame:SetHeight(CalendarCreateEventFrame.defaultHeight - CalendarCreateEventInviteListFrame:GetHeight());
		else
			CalendarCreateEventFrameTitle:SetText(CALENDAR_CREATE_EVENT);
			-- reset auto-approve
			CalendarCreateEventAutoApproveCheck:SetChecked(CALENDAR_CREATEEVENTFRAME_DEFAULT_AUTOAPPROVE);
			CalendarCreateEvent_SetAutoApprove();
			-- reset lock event
			CalendarCreateEventLockEventCheck:SetChecked(CALENDAR_CREATEEVENTFRAME_DEFAULT_LOCKEVENT);
			CalendarCreateEvent_SetLockEvent();
			-- update invite list
			CalendarCreateEventInviteListScrollFrame_Update();
			-- update mass invite button
			CalendarCreateEventMassInviteButton_Update();
			CalendarCreateEventInviteListFrame:Show();
			CalendarCreateEventMassInviteButton:Show();
			CalendarCreateEventFrame:SetHeight(CalendarCreateEventFrame.defaultHeight);
		end
	elseif ( CalendarCreateEventFrame.mode == "edit" ) then
		local title, description, eventType, repeatOption, maxSize, textureIndex,
			weekday, month, day, year, hour, minute,
			lockoutWeekday, lockoutMonth, lockoutDay, lockoutYear, lockoutHour, lockoutMinute,
			locked, autoApprove = CalendarGetEventInfo();
		if ( not title ) then
			CalendarFrame_HideEventFrame(CalendarCreateEventFrame);
			return;
		end

		CalendarCreateEventFrameTitle:SetText(CALENDAR_EDIT_EVENT);
		CalendarCreateEventAcceptButton:SetText(UPDATE);

		-- update event title
		CalendarCreateEventTitleEdit:SetText(title);
		CalendarCreateEventTitleEdit:SetCursorPosition(0);
		CalendarCreateEventTitleEdit:ClearFocus();
		-- update description
		CalendarCreateEventDescription:SetText(description);
		-- update date
		CalendarCreateEventDateLabel:SetFormattedText(CALENDAR_EVENT_FULLDATE, CALENDAR_WEEKDAY_NAMES[weekday], CALENDAR_MONTH_NAMES[month], day, year, month);
		-- update time
		if ( CalendarCreateEventFrame.militaryTime ) then
			CalendarCreateEventFrame.selectedHour = hour;
		else
			CalendarCreateEventFrame.selectedHour = GameTime_ComputeStandardTime(hour);
		end
		CalendarCreateEventFrame.selectedMinute = minute;
		CalendarCreateEventFrame.selectedAM = hour < 12;
		if ( CalendarCreateEventFrame.militaryTime ) then
			CalendarCreateEventFrame.selectedHour = hour;
		else
			CalendarCreateEventFrame.selectedHour = GameTime_ComputeStandardTime(hour, CalendarCreateEventFrame.selectedAM);
		end
		CalendarCreateEvent_UpdateEventTime();
		-- update type
		CalendarCreateEventFrame.selectedEventType = eventType;
		if ( textureIndex > 0 ) then
			CalendarCreateEventFrame.selectedDungeonIndex = textureIndex;
		else
			CalendarCreateEventFrame.selectedDungeonIndex = nil;
		end
		CalendarCreateEvent_UpdateEventType();
		-- update repeat option
		CalendarCreateEventFrame.selectedRepeatOption = repeatOption;
		CalendarCreateEvent_UpdateRepeatOption();
		if ( CalendarEventIsGuildWide() ) then
			CalendarCreateEventFrameTitle:SetText(CALENDAR_EDIT_ANNOUNCEMENT);
			-- guild wide events don't have invites
			CalendarCreateEventInviteListFrame:Hide();
			CalendarCreateEventFrame:SetHeight(CalendarCreateEventFrame.defaultHeight - CalendarCreateEventInviteListFrame:GetHeight());
		else
			CalendarCreateEventFrameTitle:SetText(CALENDAR_EDIT_EVENT);
			-- update auto approve
			CalendarCreateEventAutoApproveCheck:SetChecked(autoApprove);
			-- update locked
			CalendarCreateEventLockEventCheck:SetChecked(locked);
			-- update invite list
			CalendarCreateEventInviteListScrollFrame_Update();
			-- update mass invite button
			CalendarCreateEventMassInviteButton_Update();
			CalendarCreateEventInviteListFrame:Show();
			CalendarCreateEventFrame:SetHeight(CalendarCreateEventFrame.defaultHeight);
		end
		-- we're not able to mass invite after an event is created...
		CalendarCreateEventMassInviteButton:Hide();
	end
end

function CalendarCreateEventDungeon_Update()
	if ( CalendarCreateEventFrame.selectedDungeonIndex ) then
		local name = _CalendarFrame_GetEventTextureNameAndPath(CalendarCreateEventFrame.selectedDungeonIndex, CalendarCreateEventFrame.selectedEventType);
		CalendarCreateEventDungeonName:SetText(name);
		CalendarCreateEventDungeonName:Show();
	else
		CalendarCreateEventDungeonName:Hide();
	end
end

function CalendarCreateEventTypeDropDown_Initialize()
	CalendarCreateEventTypeDropDown_InitEventTypes(CalendarEventGetTypes());
end

function CalendarCreateEventTypeDropDown_InitEventTypes(...)
	local info = UIDropDownMenu_CreateInfo();
	for i = 1, select("#", ...) do
		info.text = select(i, ...);
		info.func = CalendarCreateEventTypeDropDown_OnClick;
		if ( CalendarCreateEventFrame.selectedEventType == i ) then
			info.checked = 1;
			UIDropDownMenu_SetText(CalendarCreateEventTypeDropDown, info.text);
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function CalendarCreateEventTypeDropDown_OnClick(self)
	local id = self:GetID();
	if ( id == CALENDAR_EVENTTYPE_DUNGEON or id == CALENDAR_EVENTTYPE_RAID ) then
		CalendarDungeonPickerFrame_Show(id);
	else
		UIDropDownMenu_SetSelectedID(CalendarCreateEventTypeDropDown, id);
		CalendarCreateEventFrame.selectedEventType = id;
		CalendarEventSetType(id);
		-- clear the dungeon selection for non-dungeon types
		CalendarCreateEventFrame.selectedDungeonIndex = nil;
		CalendarCreateEventDungeon_Update();
	end
end

function CalendarCreateEvent_UpdateEventType()
	UIDropDownMenu_Initialize(CalendarCreateEventTypeDropDown, CalendarCreateEventTypeDropDown_Initialize);
	UIDropDownMenu_SetSelectedID(CalendarCreateEventTypeDropDown, CalendarCreateEventFrame.selectedEventType);
	CalendarCreateEventDungeon_Update();
end

function CalendarCreateEventRepeatOptionDropDown_Initialize()
	CalendarCreateEventTypeDropDown_InitRepeatOptions(CalendarEventGetRepeatOptions());
end

function CalendarCreateEventTypeDropDown_InitRepeatOptions(...)
	local info = UIDropDownMenu_CreateInfo();
	for i = 1, select("#", ...) do
		info.text = select(i, ...);
		info.func = CalendarCreateEventRepeatOptionDropDown_OnClick;
		if ( CalendarCreateEventFrame.selectedRepeatOption == i ) then
			info.checked = 1;
			UIDropDownMenu_SetText(CalendarCreateEventRepeatOptionDropDown, info.text);
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
end

function CalendarCreateEvent_UpdateRepeatOption()
	UIDropDownMenu_Initialize(CalendarCreateEventRepeatOptionDropDown, CalendarCreateEventRepeatOptionDropDown_Initialize);
	UIDropDownMenu_SetSelectedID(CalendarCreateEventRepeatOptionDropDown, CalendarCreateEventFrame.selectedRepeatOption);
end

function CalendarCreateEventHourDropDown_Initialize()
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
			UIDropDownMenu_SetText(CalendarCreateEventHourDropDown, info.text);
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
end

function CalendarCreateEventMinuteDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	for minute = 0, 55, 5 do
		info.value = minute;
		info.text = format(TIMEMANAGER_MINUTE, minute);
		info.func = CalendarCreateEventMinuteDropDown_OnClick;
		if ( minute == CalendarCreateEventFrame.selectedMinute ) then
			info.checked = 1;
			UIDropDownMenu_SetText(CalendarCreateEventMinuteDropDown, info.text);
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
end

function CalendarCreateEventAMPMDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = TIMEMANAGER_AM;
	info.func = CalendarCreateEventAMPMDropDown_OnClick;
	if ( CalendarCreateEventFrame.selectedAM ) then
		info.checked = 1;
		UIDropDownMenu_SetText(CalendarCreateEventAMPMDropDown, info.text);
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
		UIDropDownMenu_SetText(CalendarCreateEventAMPMDropDown, info.text);
	end
	UIDropDownMenu_AddButton(info);
end

function CalendarCreateEventAMPMDropDown_OnClick(self)
	local id = self:GetID();
	UIDropDownMenu_SetSelectedID(CalendarCreateEventAMPMDropDown, id);
	CalendarCreateEventFrame.selectedAM = id == 1;
	CalendarCreateEvent_SetEventTime();
end

function CalendarCreateEvent_SetEventTime()
	local hour = CalendarCreateEventFrame.selectedHour;
	if ( not CalendarCreateEventFrame.militaryTime ) then
		hour = GameTime_ComputeMilitaryTime(hour, CalendarCreateEventFrame.selectedAM);
	end
	CalendarEventSetTime(hour, CalendarCreateEventFrame.selectedMinute);
end

function CalendarCreateEvent_UpdateEventTime()
	if ( CalendarCreateEventFrame.militaryTime ) then
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
		if ( not CalendarCreateEventFrame.militaryTime ) then
			-- need to convert from 12hr to 24hr
			CalendarCreateEventFrame.selectedHour = GameTime_ComputeMilitaryTime(hour, am);
			CalendarCreateEventAMPMDropDown:Hide();
		end
	else
		if ( CalendarCreateEventFrame.militaryTime ) then
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
	CalendarCreateEventFrame.militaryTime = militaryTime;
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
end

function CalendarCreateEvent_SetLockEvent()
	if ( CalendarCreateEventLockEventCheck:GetChecked() ) then
		CalendarEventSetLocked();
	else
		CalendarEventClearLocked();
	end
end

function CalendarCreateEventInviteListScrollFrame_Update()
	local buttons = CalendarCreateEventInviteListScrollFrame.buttons;
	local numInvites = CalendarEventGetNumInvites();
	local numButtons = #buttons;
	local totalHeight = numInvites * buttons[1]:GetHeight();

	local selectedInviteIndex = CalendarCreateEventFrame.selectedInviteIndex;
	if ( CalendarCreateEventFrame.selectedInviteIndex and CalendarCreateEventFrame.selectedInviteIndex > numInvites ) then
		CalendarCreateEventFrame.selectedInviteIndex = nil;
	end

	local button, buttonName, classColor, buttonTexture, buttonNameString, buttonClass, buttonStatus;
	local name, level, className, inviteStatus, modStatus, inviteIsMine;
	local displayedHeight = 0;
	local inviteIndex = 0;
	local offset = HybridScrollFrame_GetOffset(CalendarCreateEventInviteListScrollFrame);
	for i = 1, numButtons do
		-- get current button info
		button = buttons[i];
		buttonName = button:GetName();
		inviteIndex = i + offset;
		name, level, className, classFilename, inviteStatus, modStatus = CalendarEventGetInvite(inviteIndex);
		if ( name ) then
			-- set the button index
			button.inviteIndex = inviteIndex;
			-- setup the button
			buttonTexture = getglobal(buttonName.."Texture");
			classColor = RAID_CLASS_COLORS[classFilename];
			buttonNameString = getglobal(buttonName.."Name");
			buttonNameString:SetText(name);
			buttonNameString:SetTextColor(classColor.r, classColor.g, classColor.b);
			if ( modStatus == "CREATOR" ) then
				buttonTexture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
				buttonTexture:Show();
				buttonNameString:SetPoint("LEFT", buttonTexture, "RIGHT");
			elseif ( modStatus == "MODERATOR" ) then
				buttonTexture:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
				buttonTexture:Show();
				buttonNameString:SetPoint("LEFT", buttonTexture, "RIGHT");
			else
				buttonTexture:Hide();
				buttonNameString:SetPoint("LEFT", buttonTexture, "LEFT");
			end
			buttonClass = getglobal(buttonName.."Class");
			buttonClass:SetText(className);
			buttonClass:SetTextColor(classColor.r, classColor.g, classColor.b);
			buttonStatus = getglobal(buttonName.."Status");
			buttonStatus:SetText(CALENDAR_INVITESTATUS_NAMES[inviteStatus]);
			buttonStatus:SetTextColor(classColor.r, classColor.g, classColor.b);
			-- set the selected button
			if ( selectedInviteIndex and inviteIndex == selectedInviteIndex ) then
				button:LockHighlight();
				CalendarCreateEventFrame.selectedInvite = button;
			else
				button:UnlockHighlight();
			end
			button:Show();
		else
			button.inviteIndex = nil;
			button:Hide();
		end
		displayedHeight = displayedHeight + button:GetHeight();
	end

	HybridScrollFrame_Update(CalendarCreateEventInviteListScrollFrame, numInvites, totalHeight, displayedHeight);
end

function CalendarCreateEventInviteListButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function CalendarCreateEventInviteListButton_OnClick(self, button)
	local inviteIndex = self.inviteIndex;
	local selectionChanged = inviteIndex ~= CalendarCreateEventFrame.selectedInviteIndex;
	if ( CalendarCreateEventFrame.selectedInvite ) then
		CalendarCreateEventFrame.selectedInvite:UnlockHighlight();
	end
	CalendarCreateEventFrame.selectedInvite = self;
	CalendarCreateEventFrame.selectedInviteIndex = inviteIndex;
	self:LockHighlight();

	if ( button == "LeftButton" ) then
		CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
	elseif ( button == "RightButton" ) then
		if ( selectionChanged ) then
			CalendarContextMenu_Show(self, CalendarCreateEventInviteContextMenu_Initialize, "cursor", 3, -3, inviteIndex);
		else
			CalendarContextMenu_Toggle(self, CalendarCreateEventInviteContextMenu_Initialize, "cursor", 3, -3, inviteIndex);
		end
	end
end

function CalendarCreateEventInviteContextMenu_Initialize(menu, inviteIndex)
	UIMenu_Initialize(menu);

	menu.inviteIndex = inviteIndex;

	local _, _, _, _, _, modStatus = CalendarEventGetInvite(inviteIndex);

	if ( modStatus ~= "CREATOR" ) then
		-- remove invite
		UIMenu_AddButton(menu, REMOVE, nil, CalendarInviteContextMenu_RemoveInvite);
		if ( modStatus == "MODERATOR" ) then
			-- clear moderator status
			UIMenu_AddButton(menu, CALENDAR_INVITELIST_CLEARMODERATOR, nil, CalendarInviteContextMenu_ClearModerator);
		else
			-- set moderator status
			UIMenu_AddButton(menu, CALENDAR_INVITELIST_SETMODERATOR, nil, CalendarInviteContextMenu_SetModerator);
		end
	end
	if ( CalendarCreateEventFrame.mode == "edit" ) then
		-- set invite status submenu
		UIMenu_AddButton(menu, CALENDAR_SET_INVITE_STATUS, nil, nil, "CalendarInviteStatusContextMenu");
	end

	UIMenu_FinishInitializing(menu);
end

function CalendarInviteContextMenu_RemoveInvite()
	CalendarEventRemoveInvite(CalendarCreateEventFrame.selectedInviteIndex);
end

function CalendarInviteContextMenu_SetModerator()
	CalendarEventSetModerator(CalendarCreateEventFrame.selectedInviteIndex);
end

function CalendarInviteContextMenu_ClearModerator()
	CalendarEventClearModerator(CalendarCreateEventFrame.selectedInviteIndex);
end

function CalendarInviteStatusContextMenu_OnLoad(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	self:RegisterEvent("CALENDAR_UPDATE_EVENT");
	self.parentMenu = "CalendarContextMenu";
	self.onlyAutoHideSelf = true;
end

function CalendarInviteStatusContextMenu_OnShow(self)
	CalendarInviteStatusContextMenu_Initialize(self);
end

function CalendarInviteStatusContextMenu_OnEvent(self, event, ...)
	if ( event == "CALENDAR_UPDATE_EVENT" ) then
		if ( self:IsShown() ) then
			CalendarInviteStatusContextMenu_Initialize(self);
		end
	end
end

function CalendarInviteStatusContextMenu_Initialize(menu, inviteIndex)
	UIMenu_Initialize(CalendarInviteStatusContextMenu);

	local _, _, _, _, inviteStatus = CalendarEventGetInvite(menu:GetParent().inviteIndex);

	for i = 1, #CALENDAR_INVITESTATUS_NAMES do
		local statusName = CALENDAR_INVITESTATUS_NAMES[i];
		if ( i ~= CALENDAR_INVITESTATUS_INVITED and i ~= inviteStatus ) then
			UIMenu_AddButton(
				menu,													-- menu
				statusName,												-- text
				nil,													-- shortcut
				CalendarInviteStatusContextMenu_SetStatusOption,		-- func
				nil,													-- nested
				i);														-- value
		end
	end

	UIMenu_FinishInitializing(CalendarInviteStatusContextMenu);
end

function CalendarInviteStatusContextMenu_SetStatusOption(self)
	CalendarEventSetStatus(CalendarCreateEventFrame.selectedInviteIndex, self.value);
	-- hide parent
	CalendarContextMenu_Hide(CalendarCreateEventInviteContextMenu_Initialize);
end

function CalendarCreateEventMassInviteButton_OnClick()
	CalendarMassInviteFrame:Show();
end

function CalendarCreateEventMassInviteButton_Update()
	if ( CanEditGuildEvent() or IsInArenaTeam() ) then
		CalendarCreateEventMassInviteButton:Enable();
	else
		CalendarCreateEventMassInviteButton:Disable();
	end
end

function CalendarCreateEventAcceptButton_OnClick(self)
	if ( CalendarCreateEventFrame.mode == "create" ) then
		CalendarAddEvent();
		--CalendarFrame_HideEventFrame(CalendarCreateEventFrame);
	elseif ( CalendarCreateEventFrame.mode == "edit" ) then
		CalendarUpdateEvent();
		CalendarFrame_HideEventFrame(CalendarCreateEventFrame);
	end
end


-- CalendarMassInviteFrame

function CalendarMassInviteFrame_OnLoad(self)
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE");

	local minLevel, maxLevel = CalendarDefaultGuildFilter();
	CalendarMassInviteGuildMinLevelEdit:SetNumber(minLevel);
	CalendarMassInviteGuildMaxLevelEdit:SetNumber(maxLevel);
	UIDropDownMenu_SetWidth(CalendarMassInviteGuildRankMenu, 100);

	-- try to fire off a guild roster event so we can properly update our guild options and...
	if ( IsInGuild() and GetNumGuildMembers() == 0 ) then
		GuildRoster();
	end
	--...do the same for arena teams
	for i = 1, MAX_ARENA_TEAMS do
		ArenaTeamRoster(i);
	end
	-- update the arena team section in order to fill initial data
	CalendarMassInviteArena_Update();
end

function CalendarMassInviteFrame_OnShow(self)
	CalendarFrame_SetModal(self);
	CalendarMassInviteGuild_Update();
	CalendarMassInviteArena_Update();
end

function CalendarMassInviteFrame_OnEvent(self, event, ...)
	if ( self:IsShown() ) then
		if ( not CanEditGuildEvent() and not IsInArenaTeam() ) then
			-- if we are no longer in a guild OR an arena team, we can't mass invite
			CalendarMassInviteFrame:Hide();
			CalendarCreateEventMassInviteButton_Update();
		else
			-- these need to be run even if the frame is hidden because we don't want to show the arena
			if ( event == "GUILD_ROSTER_UPDATE" ) then
				CalendarMassInviteGuild_Update();
			elseif ( event == "ARENA_TEAM_ROSTER_UPDATE" ) then
				CalendarMassInviteArena_Update();
			end
		end
	end
end

function CalendarMassInviteGuild_Update()
	if ( CanEditGuildEvent() ) then
		CalendarMassInviteGuildAcceptButton:Enable();
		if ( not CalendarMassInviteFrame.selectedRank or CalendarMassInviteFrame.selectedRank > GuildControlGetNumRanks() ) then
			local _, _, rank = CalendarDefaultGuildFilter();
			CalendarMassInviteFrame.selectedRank = rank;
		end
		UIDropDownMenu_Initialize(CalendarMassInviteGuildRankMenu, CalendarMassInviteGuildRankMenu_Initialize);
	else
		CalendarMassInviteGuildAcceptButton:Disable();
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
	CalendarNewGuildEvent(minLevel, maxLevel, CalendarMassInviteFrame.selectedRank);
	CalendarMassInviteFrame:Hide();
end

local ARENA_TEAMS = {2, 3, 5};
function CalendarMassInviteArena_Update()
	local teamName, teamSize;
	local button;
	for i = 1, MAX_ARENA_TEAMS do
		button = getglobal("CalendarMassInviteArenaButton"..i);
		teamName, teamSize = GetArenaTeam(i);
		if ( teamName ) then
			button:SetFormattedText(PVP_TEAMTYPE, teamSize, teamSize);
			button:SetID(i);
			button.teamName = teamName;
			button:Enable();
		else
			button:SetFormattedText(PVP_TEAMTYPE, ARENA_TEAMS[i], ARENA_TEAMS[i]);
			button:SetID(0);
			button.teamName = nil;
			button:Disable();
		end
	end
end

function CalendarMassInviteArenaButton_OnClick(self)
	CalendarNewArenaTeamEvent(self:GetID());
	CalendarMassInviteFrame:Hide();
end


-- CalendarEventPickerFrame

function CalendarEventPickerFrame_OnLoad(self)
	self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST");
	self.dayButton = nil;
	self.selectedEvent = nil;
	CalendarEventPickerScrollFrame.update = CalendarEventPickerScrollFrame_Update;
	HybridScrollFrame_CreateButtons(CalendarEventPickerScrollFrame, "CalendarEventPickerButtonTemplate");
end

function CalendarEventPickerFrame_OnEvent(self, event, ...)
	if ( event == "CALENDAR_UPDATE_EVENT_LIST" ) then
		if ( self.dayButton ) then
			CalendarEventPickerScrollFrame_Update();
		end
	end
end

function CalendarEventPickerFrame_Show(dayButton)
	CalendarEventPickerFrame.dayButton = dayButton;
	if ( _Calendar_GetWeekdayIndex(dayButton:GetID()) > 3 ) then
		CalendarEventPickerFrame:SetPoint("TOPRIGHT", dayButton, "TOPLEFT");
	else
		CalendarEventPickerFrame:SetPoint("TOPLEFT", dayButton, "TOPRIGHT");
	end
	CalendarEventPickerFrame:Show();
	CalendarContextMenu_Hide();
	CalendarEventPickerScrollFrame_Update();
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

function CalendarEventPickerScrollFrame_Update()
	local dayButton = CalendarEventPickerFrame.dayButton;
	local monthOffset = dayButton.monthOffset;
	local day = dayButton.day;
	local numEvents = CalendarGetNumDayEvents(monthOffset, day);
	if ( numEvents <= CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS ) then
		CalendarEventPickerFrame_Hide();
		return;
	end

	local selectedEventIndex;
	local month, year = CalendarGetMonth(dayButton.monthOffset);
	if ( CalendarFrame.selectedEventIndex and
		 day == CalendarFrame.selectedEventDay and month == CalendarFrame.selectedEventMonth and year == CalendarFrame.selectedEventYear ) then
		selectedEventIndex = CalendarFrame.selectedEventIndex;
	end

	local buttons = CalendarEventPickerScrollFrame.buttons;
	local numButtons = #buttons;
	local totalHeight = numEvents * buttons[1]:GetHeight();

	local button, buttonName, buttonIcon, buttonTitle, buttonTime;
	local title, hour, minute, calendarType, sequenceType, eventType, texture, modStatus;
	local tex, tcoords;
	local displayedHeight = 0;
	local eventIndex = 0;
	local offset = HybridScrollFrame_GetOffset(CalendarEventPickerScrollFrame);
	for i = 1, numButtons do
		button = buttons[i];
		buttonName = button:GetName();
		eventIndex = i + offset;
		title, hour, minute, calendarType, sequenceType, eventType, texture, modStatus = CalendarGetDayEvent(monthOffset, day, eventIndex);
		if ( title ) then
			buttonIcon = getglobal(buttonName.."Icon");
			buttonTitle = getglobal(buttonName.."Title");
			buttonTime = getglobal(buttonName.."Time");

			button.eventIndex = eventIndex;

			-- set event texture
			buttonIcon:SetTexture("");
			tex, tcoords = _CalendarFrame_GetTextureFile(texture, calendarType, eventType);
			if ( tex ) then
				buttonIcon:SetTexture(tex);
				buttonIcon:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
				buttonIcon:Show();
			else
				buttonIcon:Hide();
			end

			-- set event title and time
			buttonTitle:SetFormattedText(CALENDAR_CALENDARTYPE_NAMEFORMAT[calendarType][sequenceType], title);
			if ( calendarType == "HOLIDAY" ) then
				buttonTitle:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				buttonTime:Hide();
			else
				if ( modStatus == "CREATOR" or modStatus == "MODERATOR" ) then
					buttonTitle:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				else
					buttonTitle:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end
				buttonTime:SetText(GameTime_GetFormattedTime(hour, minute, true));
				buttonTime:Show();
			end

			-- set selected event
			if ( selectedEventIndex and eventIndex == selectedEventIndex ) then
				CalendarEventPickerFrame_SetSelectedEvent(button);
			else
				button:UnlockHighlight();
			end
			button:Show();
		else
			button.eventIndex = nil;
			button:Hide();
		end
		displayedHeight = displayedHeight + button:GetHeight();
	end
	HybridScrollFrame_Update(CalendarEventPickerScrollFrame, numEvents, totalHeight, displayedHeight);
end

function CalendarEventPickerButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function CalendarEventPickerButton_OnClick(self, button)
--[[
	-- cache the event index
	local eventIndex = self.eventIndex;
	-- select the event
	CalendarEventPickerFrame_SetSelectedEvent(self);

	local dayButton = CalendarEventPickerFrame.dayButton;
	local day = dayButton.day;
	local monthOffset = dayButton.monthOffset;
	local month, year = CalendarGetMonth(monthOffset);
	local eventChanged = CalendarFrame.selectedEventIndex ~= eventIndex or
		CalendarFrame.selectedEventDay ~= day or CalendarFrame.selectedEventMonth ~= month or CalendarFrame.selectedEventYear ~= year;
	if ( eventChanged ) then
		-- search for the corresponding event button on the calendar frame if the event changed
		local dayButtonName = dayButton:GetName();
		local dayEventButton;
		for i = 1, CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS do
			local curDayEventButton = getglobal(dayButtonName.."EventButton"..i);
			if ( curDayEventButton.eventIndex and curDayEventButton.eventIndex == eventIndex ) then
				dayEventButton = curDayEventButton;
				break;
			end
		end
		if ( dayEventButton ) then
			-- if we found the button then click it...
			CalendarDayEventButton_Click(dayEventButton, true);
		else
			CalendarFrame_SetSelectedEvent();
			-- otherwise this event is not visible on the calendar, only the picker, so we need to do the selection
			-- work that would have otherwise happened by clicking the calendar event button
			StaticPopup_Hide("CALENDAR_DELETE_EVENT");
			CalendarFrame.selectedEventIndex = eventIndex;
			CalendarFrame.selectedEventMonth = month;
			CalendarFrame.selectedEventDay = day;
			CalendarFrame.selectedEventYear = year;
			CalendarFrame_OpenEvent(CalendarEventPickerFrame.dayButton, eventIndex);
		end
	end

	if ( button == "LeftButton" ) then
		CalendarContextMenu_Hide(CalendarDayContextMenu_Initialize);
	elseif ( button == "RightButton" ) then
		local flags = CALENDAR_CONTEXTMENU_FLAG_SHOWEVENT;
		if ( eventChanged ) then
			CalendarContextMenu_Show(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton, self);
		else
			CalendarContextMenu_Toggle(self, CalendarDayContextMenu_Initialize, "cursor", 3, -3, flags, dayButton, self);
		end
	end
--]]

	if ( button == "LeftButton" ) then
		CalendarEventPickerButton_Click(self);
		CalendarContextMenu_Hide(CalendarDayContextMenu_Initialize);
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
end

function CalendarEventPickerButton_Click(button)
	-- cache the event index
	local eventIndex = button.eventIndex;
	-- select the event
	CalendarEventPickerFrame_SetSelectedEvent(button);

	local dayButton = CalendarEventPickerFrame.dayButton;

	-- search for the corresponding event button on the calendar frame if the event changed
	local dayButtonName = dayButton:GetName();
	local dayEventButton;
	for i = 1, CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS do
		local curDayEventButton = getglobal(dayButtonName.."EventButton"..i);
		if ( curDayEventButton.eventIndex and curDayEventButton.eventIndex == eventIndex ) then
			dayEventButton = curDayEventButton;
			break;
		end
	end
	if ( dayEventButton ) then
		-- if we found the button then click it...
		CalendarDayEventButton_Click(dayEventButton, true);
	else
		local day = dayButton.day;
		local monthOffset = dayButton.monthOffset;
		local month, year = CalendarGetMonth(monthOffset);

		CalendarFrame_SetSelectedEvent();
		-- otherwise this event is not visible on the calendar, only the picker, so we need to do the selection
		-- work that would have otherwise happened by clicking the calendar event button
		StaticPopup_Hide("CALENDAR_DELETE_EVENT");
		CalendarFrame.selectedEventIndex = eventIndex;
		CalendarFrame.selectedEventMonth = month;
		CalendarFrame.selectedEventDay = day;
		CalendarFrame.selectedEventYear = year;
		CalendarFrame_OpenEvent(CalendarEventPickerFrame.dayButton, eventIndex);
	end
end


-- CalendarDungeonPickerFrame

local CalendarDungeonPickerListCache = { };

function CalendarDungeonPickerFrame_OnLoad(self)
	self.selectedDungeonIndex = nil;
	CalendarDungeonPickerScrollFrame.update = CalendarDungeonPickerScrollFrame_Update;
	HybridScrollFrame_CreateButtons(CalendarDungeonPickerScrollFrame, "CalendarDungeonPickerButtonTemplate");
end

function CalendarDungeonPickerFrame_Show(eventType)
	if ( not eventType ) then
		return;
	end
	if ( eventType ~= CalendarDungeonPickerFrame.eventType) then
		if ( not CalendarDungeonPickerFrame_CacheList(CalendarEventGetTextures(eventType)) ) then
			return;
		end
		CalendarDungeonPickerFrame.dungeonIndex = CalendarCreateEventFrame.selectedDungeonIndex;
		CalendarDungeonPickerFrame.eventType = eventType;
	end
	CalendarDungeonPickerFrame:Show();
	CalendarDungeonPickerScrollFrame_Update();
end

function CalendarDungeonPickerFrame_Hide()
	CalendarDungeonPickerFrame.eventType = nil;
	CalendarDungeonPickerFrame.dungeonIndex = nil;
	CalendarDungeonPickerFrame:Hide();
end

function CalendarDungeonPickerFrame_Toggle(eventType)
	if ( CalendarDungeonPickerFrame:IsShown() ) then
		CalendarDungeonPickerFrame_Hide();
	else
		CalendarDungeonPickerFrame_Show(eventType);
	end
end

function CalendarDungeonPickerFrame_CacheList(...)
	local numDungeons = select("#", ...) / 2;
	if ( numDungeons <= 0 ) then
		return false;
	end

	while ( #CalendarDungeonPickerListCache > numDungeons ) do
		tremove(CalendarDungeonPickerListCache);
	end

	local index = 1;
	local i = 1;
	while ( index <= numDungeons ) do
		if ( not CalendarDungeonPickerListCache[index] ) then
			CalendarDungeonPickerListCache[index] = { };
		end

		CalendarDungeonPickerListCache[index].title = select(i, ...);
		i = i + 1;
		CalendarDungeonPickerListCache[index].texture = select(i, ...);
		i = i + 1;

		index = index + 1;
	end
	return true;
end

function CalendarDungeonPickerScrollFrame_Update()
	if ( not CalendarDungeonPickerFrame.eventType ) then
		CalendarDungeonPickerFrame_Hide();
		return;
	end

	local buttons = CalendarDungeonPickerScrollFrame.buttons;
	local numButtons = #buttons;
	local numDungeons = #CalendarDungeonPickerListCache;
	local totalHeight = numDungeons * buttons[1]:GetHeight();

	local button, buttonName, buttonIcon, buttonTitle;
	local dungeon;
	local displayedHeight = 0;
	local selectedDungeonIndex = CalendarDungeonPickerFrame.dungeonIndex;
	local eventType = CalendarDungeonPickerFrame.eventType;
	local offset = HybridScrollFrame_GetOffset(CalendarDungeonPickerScrollFrame);
	local dungeonIndex = 0;
	for i = 1, numButtons do
		button = buttons[i];
		buttonName = button:GetName();
		dungeonIndex = i + offset;
		dungeon = CalendarDungeonPickerListCache[dungeonIndex];
		if ( dungeon ) then
			buttonIcon = getglobal(buttonName.."Icon");
			buttonTitle = getglobal(buttonName.."Title");
			-- record the dungeonIndex in the button
			button.dungeonIndex = dungeonIndex;
			-- set the dungeon name
			buttonTitle:SetText(dungeon.title);
			-- set the dungeon icon
			buttonIcon:SetTexture("");
			local tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
			buttonIcon:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
			if ( dungeon.texture and dungeon.texture ~= "" ) then
				buttonIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURE_PATHS[eventType]..dungeon.texture);
			else
				buttonIcon:SetTexture(CALENDAR_EVENTTYPE_TEXTURES[eventType]);
			end
			-- set the selected dungeon
			if ( selectedDungeonIndex and dungeonIndex == selectedDungeonIndex ) then
				button:LockHighlight();
				CalendarDungeonPickerFrame.selectedDungeon = button;
			else
				button:UnlockHighlight();
			end
			button:Show();
			dungeonIndex = dungeonIndex + 1;
		else
			button.dungeonIndex = nil;
			button:Hide();
		end
		displayedHeight = displayedHeight + button:GetHeight();
	end
	HybridScrollFrame_Update(CalendarDungeonPickerScrollFrame, numDungeons, totalHeight, displayedHeight);
end

function CalendarDungeonPickerAcceptButton_OnClick(self)
	CalendarCreateEventFrame.selectedDungeonIndex = CalendarDungeonPickerFrame.dungeonIndex;
	if ( CalendarCreateEventFrame.selectedDungeonIndex ) then
		-- now that we've selected a dungeon, we can set the create event data
		local eventType = CalendarDungeonPickerFrame.eventType;
		CalendarEventSetType(eventType);
		CalendarEventSetTextureID(CalendarCreateEventFrame.selectedDungeonIndex);
		-- update the create event frame using our selection
		UIDropDownMenu_SetSelectedID(CalendarCreateEventTypeDropDown, eventType);
		CalendarCreateEventFrame.selectedEventType = eventType;
		CalendarCreateEventDungeon_Update();
		CalendarDungeonPickerFrame:Hide();
	end
end

function CalendarDungeonPickerButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function CalendarDungeonPickerButton_OnClick(self, button)
	if ( CalendarDungeonPickerFrame.selectedDungeon ) then
		CalendarDungeonPickerFrame.selectedDungeon:UnlockHighlight();
	end
	CalendarDungeonPickerFrame.selectedDungeon = self;
	CalendarDungeonPickerFrame.dungeonIndex = self.dungeonIndex;
	self:LockHighlight();
end

