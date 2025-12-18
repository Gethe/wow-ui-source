local HeirloomInfo =
{
	Name = "HeirloomInfo",
	Type = "System",
	Namespace = "C_HeirloomInfo",
	Environment = "All",

	Functions =
	{
		{
			Name = "AreAllCollectionFiltersChecked",
			Type = "Function",

			Returns =
			{
				{ Name = "areAllCollectionFiltersChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AreAllSourceFiltersChecked",
			Type = "Function",

			Returns =
			{
				{ Name = "areAllSourceFiltersChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHeirloomSourceValid",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "source", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isHeirloomSourceValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUsingDefaultFilters",
			Type = "Function",

			Returns =
			{
				{ Name = "isUsingDefaultFilters", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAllCollectionFilters",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "checked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAllSourceFilters",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "checked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDefaultFilters",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "HeirloomUpgradeTargetingChanged",
			Type = "Event",
			LiteralName = "HEIRLOOM_UPGRADE_TARGETING_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "pendingHeirloomUpgradeSpellcast", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HeirloomsUpdated",
			Type = "Event",
			LiteralName = "HEIRLOOMS_UPDATED",
			SynchronousEvent = true,
			UniqueEvent = true,
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
				{ Name = "updateReason", Type = "cstring", Nilable = true },
				{ Name = "hideUntilLearned", Type = "bool", Nilable = true },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(HeirloomInfo);