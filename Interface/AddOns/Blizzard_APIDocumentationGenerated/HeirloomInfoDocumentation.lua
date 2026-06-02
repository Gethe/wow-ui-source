local HeirloomInfo =
{
	Name = "HeirloomInfo",
	Type = "System",
	Namespace = "C_HeirloomInfo",
	Environment = "All",

	Functions =
	{
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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(HeirloomInfo);