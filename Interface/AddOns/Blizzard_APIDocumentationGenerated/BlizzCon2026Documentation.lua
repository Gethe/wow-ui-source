local BlizzCon2026 =
{
	Name = "BlizzCon2026Scripts",
	Type = "System",
	Namespace = "C_BlizzCon2026",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetExperience",
			Type = "Function",

			Returns =
			{
				{ Name = "experience", Type = "Bc26Experience", Nilable = false },
			},
		},
		{
			Name = "IsActive",
			Type = "Function",

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsColdSwapFeatureEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetExperience",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "experience", Type = "Bc26Experience", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "Bc26ColdSwapFeatureEnabledChanged",
			Type = "Event",
			LiteralName = "BC_26_COLD_SWAP_FEATURE_ENABLED_CHANGED",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "newEnabled", Type = "bool", Nilable = false },
				{ Name = "oldEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Bc26ExperienceChanged",
			Type = "Event",
			LiteralName = "BC_26_EXPERIENCE_CHANGED",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "newExperience", Type = "Bc26Experience", Nilable = false },
				{ Name = "oldExperience", Type = "Bc26Experience", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "Bc26Experience",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Skyborne", Type = "Bc26Experience", EnumValue = 0 },
				{ Name = "Dungeon", Type = "Bc26Experience", EnumValue = 1 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(BlizzCon2026);