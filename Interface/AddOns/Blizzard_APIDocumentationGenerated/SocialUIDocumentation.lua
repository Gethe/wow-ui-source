local SocialUI =
{
	Name = "SocialUI",
	Type = "System",
	Namespace = "C_SocialUI",
	Environment = "All",

	Functions =
	{
		{
			Name = "IsSystemEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isSocialUISystemEnabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SocialUISystemStatusUpdated",
			Type = "Event",
			LiteralName = "SOCIAL_UI_SYSTEM_STATUS_UPDATED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "SocialSystemType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Friends", Type = "SocialSystemType", EnumValue = 0 },
				{ Name = "QuickJoin", Type = "SocialSystemType", EnumValue = 1 },
				{ Name = "RaidList", Type = "SocialSystemType", EnumValue = 2 },
				{ Name = "RecruitAFriend", Type = "SocialSystemType", EnumValue = 3 },
				{ Name = "RecentAllies", Type = "SocialSystemType", EnumValue = 4 },
			},
		},
		{
			Name = "SocialUIBlockType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "SocialUIBlockType", EnumValue = 0 },
				{ Name = "Ignore", Type = "SocialUIBlockType", EnumValue = 1 },
				{ Name = "BattleNetInviteBlock", Type = "SocialUIBlockType", EnumValue = 2 },
			},
		},
		{
			Name = "SocialUIPresenceType",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Unknown", Type = "SocialUIPresenceType", EnumValue = 0 },
				{ Name = "Online", Type = "SocialUIPresenceType", EnumValue = 1 },
				{ Name = "Offline", Type = "SocialUIPresenceType", EnumValue = 2 },
				{ Name = "Away", Type = "SocialUIPresenceType", EnumValue = 3 },
				{ Name = "Busy", Type = "SocialUIPresenceType", EnumValue = 4 },
				{ Name = "AppearOffline", Type = "SocialUIPresenceType", EnumValue = 5 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SocialUI);