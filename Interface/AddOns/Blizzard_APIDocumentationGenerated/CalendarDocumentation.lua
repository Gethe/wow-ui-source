local Calendar =
{
	Name = "Calendar",
	Type = "System",
	Namespace = "C_Calendar",
	Environment = "All",

	Functions =
	{
		{
			Name = "AddEvent",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "AreNamesReady",
			Type = "Function",

			Returns =
			{
				{ Name = "ready", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanAddEvent",
			Type = "Function",

			Returns =
			{
				{ Name = "canAddEvent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanSendInvite",
			Type = "Function",

			Returns =
			{
				{ Name = "canSendInvite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CloseEvent",
			Type = "Function",
		},
		{
			Name = "ContextMenuEventCanComplain",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetMonths", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
				{ Name = "eventIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "canComplain", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ContextMenuEventCanEdit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetMonths", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
				{ Name = "eventIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "canEdit", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ContextMenuEventCanRemove",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetMonths", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
				{ Name = "eventIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "canRemove", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ContextMenuEventClipboard",
			Type = "Function",

			Returns =
			{
				{ Name = "exists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ContextMenuEventCopy",
			Type = "Function",
		},
		{
			Name = "ContextMenuEventGetCalendarType",
			Type = "Function",

			Returns =
			{
				{ Name = "calendarType", Type = "string", Nilable = true },
			},
		},
		{
			Name = "ContextMenuEventPaste",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetMonths", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "ContextMenuEventRemove",
			Type = "Function",
		},
		{
			Name = "ContextMenuEventSignUp",
			Type = "Function",
		},
		{
			Name = "ContextMenuGetEventIndex",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "info", Type = "CalendarEventIndexInfo", Nilable = false },
			},
		},
		{
			Name = "ContextMenuInviteAvailable",
			Type = "Function",
		},
		{
			Name = "ContextMenuInviteDecline",
			Type = "Function",
		},
		{
			Name = "ContextMenuInviteRemove",
			Type = "Function",
		},
		{
			Name = "ContextMenuInviteTentative",
			Type = "Function",
		},
		{
			Name = "ContextMenuSelectEvent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetMonths", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
				{ Name = "eventIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "CreateCommunitySignUpEvent",
			Type = "Function",
		},
		{
			Name = "CreateGuildAnnouncementEvent",
			Type = "Function",
		},
		{
			Name = "CreateGuildSignUpEvent",
			Type = "Function",
		},
		{
			Name = "CreatePlayerEvent",
			Type = "Function",
		},
		{
			Name = "EventAvailable",
			Type = "Function",
		},
		{
			Name = "EventCanEdit",
			Type = "Function",

			Returns =
			{
				{ Name = "canEdit", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EventClearAutoApprove",
			Type = "Function",
		},
		{
			Name = "EventClearLocked",
			Type = "Function",
		},
		{
			Name = "EventClearModerator",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "inviteIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "EventDecline",
			Type = "Function",
		},
		{
			Name = "EventGetCalendarType",
			Type = "Function",

			Returns =
			{
				{ Name = "calendarType", Type = "string", Nilable = true },
			},
		},
		{
			Name = "EventGetClubId",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "ClubId", Nilable = true },
			},
		},
		{
			Name = "EventGetInvite",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CalendarEventInviteInfo", Nilable = false },
			},
		},
		{
			Name = "EventGetInviteResponseTime",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "time", Type = "CalendarTime", Nilable = false },
			},
		},
		{
			Name = "EventGetInviteSortCriterion",
			Type = "Function",

			Returns =
			{
				{ Name = "criterion", Type = "string", Nilable = false },
				{ Name = "reverse", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EventGetSelectedInvite",
			Type = "Function",

			Returns =
			{
				{ Name = "inviteIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "EventGetStatusOptions",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "options", Type = "table", InnerType = "CalendarEventStatusOption", Nilable = false },
			},
		},
		{
			Name = "EventGetTextures",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventType", Type = "CalendarEventType", Nilable = false },
			},

			Returns =
			{
				{ Name = "textures", Type = "table", InnerType = "CalendarEventTextureInfo", Nilable = false },
			},
		},
		{
			Name = "EventGetTypes",
			Type = "Function",

			Returns =
			{
				{ Name = "types", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "EventGetTypesDisplayOrdered",
			Type = "Function",

			Returns =
			{
				{ Name = "infos", Type = "table", InnerType = "CalendarEventTypeDisplayInfo", Nilable = false },
			},
		},
		{
			Name = "EventHasPendingInvite",
			Type = "Function",

			Returns =
			{
				{ Name = "hasPendingInvite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EventHaveSettingsChanged",
			Type = "Function",

			Returns =
			{
				{ Name = "haveSettingsChanged", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EventInvite",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "EventRemoveInvite",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "inviteIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "EventRemoveInviteByGuid",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "EventSelectInvite",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "inviteIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "EventSetAutoApprove",
			Type = "Function",
		},
		{
			Name = "EventSetClubId",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = true },
			},
		},
		{
			Name = "EventSetDate",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "month", Type = "luaIndex", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
				{ Name = "year", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EventSetDescription",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "description", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "EventSetInviteStatus",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventIndex", Type = "luaIndex", Nilable = false },
				{ Name = "status", Type = "CalendarStatus", Nilable = false },
			},
		},
		{
			Name = "EventSetLocked",
			Type = "Function",
		},
		{
			Name = "EventSetModerator",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "inviteIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "EventSetTextureID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "textureIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "EventSetTime",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "hour", Type = "number", Nilable = false },
				{ Name = "minute", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EventSetTitle",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "title", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "EventSetType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "typeIndex", Type = "CalendarEventType", Nilable = false },
			},
		},
		{
			Name = "EventSignUp",
			Type = "Function",
		},
		{
			Name = "EventSortInvites",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "criterion", Type = "cstring", Nilable = false },
				{ Name = "reverse", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EventTentative",
			Type = "Function",
		},
		{
			Name = "GetClubCalendarEvents",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "startTime", Type = "CalendarTime", Nilable = false },
				{ Name = "endTime", Type = "CalendarTime", Nilable = false },
			},

			Returns =
			{
				{ Name = "events", Type = "table", InnerType = "CalendarDayEvent", Nilable = false },
			},
		},
		{
			Name = "GetDayEvent",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "monthOffset", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "event", Type = "CalendarDayEvent", Nilable = false },
			},
		},
		{
			Name = "GetDefaultGuildFilter",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "CalendarGuildFilterInfo", Nilable = false },
			},
		},
		{
			Name = "GetEventIndex",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "info", Type = "CalendarEventIndexInfo", Nilable = false },
			},
		},
		{
			Name = "GetEventIndexInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventID", Type = "CalendarEventID", Nilable = false },
				{ Name = "monthOffset", Type = "number", Nilable = true },
				{ Name = "monthDay", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "eventIndexInfo", Type = "CalendarEventIndexInfo", Nilable = true },
			},
		},
		{
			Name = "GetEventInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "info", Type = "CalendarEventInfo", Nilable = false },
			},
		},
		{
			Name = "GetFirstPendingInvite",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetMonths", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "firstPendingInvite", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "GetGuildEventInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CalendarGuildEventInfo", Nilable = false },
			},
		},
		{
			Name = "GetGuildEventSelectionInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CalendarEventIndexInfo", Nilable = false },
			},
		},
		{
			Name = "GetHolidayInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "monthOffset", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "event", Type = "CalendarHolidayInfo", Nilable = false },
			},
		},
		{
			Name = "GetMaxCreateDate",
			Type = "Function",

			Returns =
			{
				{ Name = "maxCreateDate", Type = "CalendarTime", Nilable = false },
			},
		},
		{
			Name = "GetMinDate",
			Type = "Function",

			Returns =
			{
				{ Name = "minDate", Type = "CalendarTime", Nilable = false },
			},
		},
		{
			Name = "GetMonthInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetMonths", Type = "number", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "monthInfo", Type = "CalendarMonthInfo", Nilable = false },
			},
		},
		{
			Name = "GetNextClubId",
			Type = "Function",

			Returns =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = true },
			},
		},
		{
			Name = "GetNumDayEvents",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetMonths", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "numDayEvents", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumGuildEvents",
			Type = "Function",

			Returns =
			{
				{ Name = "numGuildEvents", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumInvites",
			Type = "Function",

			Returns =
			{
				{ Name = "num", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumPendingInvites",
			Type = "Function",

			Returns =
			{
				{ Name = "num", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRaidInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetMonths", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
				{ Name = "eventIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CalendarRaidInfo", Nilable = false },
			},
		},
		{
			Name = "IsActionPending",
			Type = "Function",

			Returns =
			{
				{ Name = "actionPending", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEventOpen",
			Type = "Function",

			Returns =
			{
				{ Name = "isOpen", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MassInviteCommunity",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = false },
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
				{ Name = "maxRankOrder", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "MassInviteGuild",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
				{ Name = "maxRankOrder", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "OpenCalendar",
			Type = "Function",
		},
		{
			Name = "OpenEvent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetMonths", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveEvent",
			Type = "Function",
		},
		{
			Name = "SetAbsMonth",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "month", Type = "luaIndex", Nilable = false },
				{ Name = "year", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMonth",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offsetMonths", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetNextClubId",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "clubId", Type = "ClubId", Nilable = true },
			},
		},
		{
			Name = "UpdateEvent",
			Type = "Function",
			HasRestrictions = true,
		},
	},

	Events =
	{
		{
			Name = "CalendarActionPending",
			Type = "Event",
			LiteralName = "CALENDAR_ACTION_PENDING",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "pending", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CalendarCloseEvent",
			Type = "Event",
			LiteralName = "CALENDAR_CLOSE_EVENT",
			SynchronousEvent = true,
		},
		{
			Name = "CalendarEventAlarm",
			Type = "Event",
			LiteralName = "CALENDAR_EVENT_ALARM",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "title", Type = "cstring", Nilable = false },
				{ Name = "hour", Type = "number", Nilable = false },
				{ Name = "minute", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CalendarNewEvent",
			Type = "Event",
			LiteralName = "CALENDAR_NEW_EVENT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isCopy", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CalendarOpenEvent",
			Type = "Event",
			LiteralName = "CALENDAR_OPEN_EVENT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "calendarType", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "CalendarUpdateError",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_ERROR",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "errorReason", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "CalendarUpdateErrorWithCount",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_ERROR_WITH_COUNT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "errorReason", Type = "cstring", Nilable = false },
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CalendarUpdateErrorWithPlayerName",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_ERROR_WITH_PLAYER_NAME",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "errorReason", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "CalendarUpdateEvent",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_EVENT",
			SynchronousEvent = true,
		},
		{
			Name = "CalendarUpdateEventList",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_EVENT_LIST",
			SynchronousEvent = true,
			UniqueEvent = true,
		},
		{
			Name = "CalendarUpdateGuildEvents",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_GUILD_EVENTS",
			SynchronousEvent = true,
		},
		{
			Name = "CalendarUpdateInviteList",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_INVITE_LIST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "hasCompleteList", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "CalendarUpdatePendingInvites",
			Type = "Event",
			LiteralName = "CALENDAR_UPDATE_PENDING_INVITES",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "CalendarDayEvent",
			Type = "Structure",
			Fields =
			{
				{ Name = "eventID", Type = "CalendarEventID", Nilable = false },
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "isCustomTitle", Type = "bool", Nilable = false },
				{ Name = "startTime", Type = "CalendarTime", Nilable = false },
				{ Name = "endTime", Type = "CalendarTime", Nilable = false },
				{ Name = "calendarType", Type = "cstring", Nilable = false },
				{ Name = "sequenceType", Type = "cstring", Nilable = false },
				{ Name = "eventType", Type = "CalendarEventType", Nilable = false },
				{ Name = "iconTexture", Type = "fileID", Nilable = true },
				{ Name = "modStatus", Type = "cstring", Nilable = false },
				{ Name = "inviteStatus", Type = "CalendarStatus", Nilable = false },
				{ Name = "invitedBy", Type = "string", Nilable = false },
				{ Name = "difficulty", Type = "number", Nilable = false },
				{ Name = "inviteType", Type = "CalendarInviteType", Nilable = false },
				{ Name = "sequenceIndex", Type = "luaIndex", Nilable = false },
				{ Name = "numSequenceDays", Type = "number", Nilable = false },
				{ Name = "difficultyName", Type = "cstring", Nilable = false },
				{ Name = "dontDisplayBanner", Type = "bool", Nilable = false },
				{ Name = "dontDisplayEnd", Type = "bool", Nilable = false },
				{ Name = "clubID", Type = "ClubId", Nilable = false },
				{ Name = "isLocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CalendarEventIndexInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "offsetMonths", Type = "number", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
				{ Name = "eventIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "CalendarEventInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "creator", Type = "string", Nilable = true },
				{ Name = "eventType", Type = "CalendarEventType", Nilable = false },
				{ Name = "repeatOption", Type = "CalendarEventRepeatOptions", Nilable = false },
				{ Name = "maxSize", Type = "number", Nilable = false },
				{ Name = "textureIndex", Type = "luaIndex", Nilable = true },
				{ Name = "time", Type = "CalendarTime", Nilable = false },
				{ Name = "lockoutTime", Type = "CalendarTime", Nilable = false },
				{ Name = "isLocked", Type = "bool", Nilable = false },
				{ Name = "isAutoApprove", Type = "bool", Nilable = false },
				{ Name = "hasPendingInvite", Type = "bool", Nilable = false },
				{ Name = "inviteStatus", Type = "CalendarStatus", Nilable = true },
				{ Name = "inviteType", Type = "CalendarInviteType", Nilable = true },
				{ Name = "calendarType", Type = "string", Nilable = false },
				{ Name = "communityName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "CalendarEventInviteInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "className", Type = "string", Nilable = true },
				{ Name = "classFilename", Type = "string", Nilable = true },
				{ Name = "inviteStatus", Type = "CalendarStatus", Nilable = true },
				{ Name = "modStatus", Type = "string", Nilable = true },
				{ Name = "inviteIsMine", Type = "bool", Nilable = false },
				{ Name = "type", Type = "CalendarInviteType", Nilable = false },
				{ Name = "notes", Type = "string", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = true },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "CalendarEventStatusOption",
			Type = "Structure",
			Fields =
			{
				{ Name = "status", Type = "CalendarStatus", Nilable = false },
				{ Name = "statusString", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CalendarEventTextureInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "iconTexture", Type = "fileID", Nilable = false },
				{ Name = "expansionLevel", Type = "number", Nilable = false },
				{ Name = "difficultyId", Type = "number", Nilable = true },
				{ Name = "mapId", Type = "number", Nilable = true },
				{ Name = "isLfr", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "CalendarEventTypeDisplayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "displayString", Type = "string", Nilable = false },
				{ Name = "eventType", Type = "CalendarEventType", Nilable = false },
			},
		},
		{
			Name = "CalendarGuildEventInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "eventID", Type = "CalendarEventID", Nilable = false },
				{ Name = "year", Type = "number", Nilable = false },
				{ Name = "month", Type = "luaIndex", Nilable = false },
				{ Name = "monthDay", Type = "luaIndex", Nilable = false },
				{ Name = "weekday", Type = "luaIndex", Nilable = false },
				{ Name = "hour", Type = "number", Nilable = false },
				{ Name = "minute", Type = "number", Nilable = false },
				{ Name = "eventType", Type = "CalendarEventType", Nilable = false },
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "calendarType", Type = "string", Nilable = false },
				{ Name = "texture", Type = "fileID", Nilable = false },
				{ Name = "inviteStatus", Type = "CalendarStatus", Nilable = false },
				{ Name = "clubID", Type = "ClubId", Nilable = false },
			},
		},
		{
			Name = "CalendarGuildFilterInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CalendarHolidayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "texture", Type = "fileID", Nilable = false },
				{ Name = "startTime", Type = "CalendarTime", Nilable = true },
				{ Name = "endTime", Type = "CalendarTime", Nilable = true },
			},
		},
		{
			Name = "CalendarMonthInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "month", Type = "luaIndex", Nilable = false },
				{ Name = "year", Type = "number", Nilable = false },
				{ Name = "numDays", Type = "number", Nilable = false },
				{ Name = "firstWeekday", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "CalendarRaidInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "calendarType", Type = "string", Nilable = false },
				{ Name = "raidID", Type = "number", Nilable = false },
				{ Name = "time", Type = "CalendarTime", Nilable = false },
				{ Name = "difficulty", Type = "number", Nilable = false },
				{ Name = "difficultyName", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Calendar);