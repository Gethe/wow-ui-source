local PartyInfoSystemStatus =
{
	Name = "PartyInfoSystemStatus",
	Type = "System",
	Namespace = "C_PartyInfo",
	Environment = "All",

	Functions =
	{
		{
			Name = "IsRaidListEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isRaidListEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRaidListSupported",
			Type = "Function",

			Returns =
			{
				{ Name = "isRaidListSupported", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SocialUIRaidListSystemStatusUpdated",
			Type = "Event",
			LiteralName = "SOCIAL_UI_RAID_LIST_SYSTEM_STATUS_UPDATED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PartyInfoSystemStatus);