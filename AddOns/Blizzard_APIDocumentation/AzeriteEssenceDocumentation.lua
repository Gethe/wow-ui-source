local AzeriteEssence =
{
	Name = "AzeriteEssence",
	Type = "System",
	Namespace = "C_AzeriteEssence",

	Functions =
	{
		{
			Name = "ActivateEssence",
			Type = "Function",

			Arguments =
			{
				{ Name = "essenceID", Type = "number", Nilable = false },
				{ Name = "slot", Type = "AzeriteEssence", Nilable = false },
			},
		},
		{
			Name = "CanActivateEssence",
			Type = "Function",

			Arguments =
			{
				{ Name = "essenceID", Type = "number", Nilable = false },
				{ Name = "slot", Type = "AzeriteEssence", Nilable = false },
			},

			Returns =
			{
				{ Name = "canActivate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanOpenUI",
			Type = "Function",

			Returns =
			{
				{ Name = "canOpen", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearPendingActivationEssence",
			Type = "Function",
		},
		{
			Name = "CloseForge",
			Type = "Function",
		},
		{
			Name = "GetActionSpell",
			Type = "Function",

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetActiveEssence",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "AzeriteEssence", Nilable = false },
			},

			Returns =
			{
				{ Name = "essenceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEssenceInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "essenceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "AzeriteEssenceInfo", Nilable = false },
			},
		},
		{
			Name = "GetEssences",
			Type = "Function",

			Returns =
			{
				{ Name = "essences", Type = "table", InnerType = "AzeriteEssenceInfo", Nilable = false },
			},
		},
		{
			Name = "GetPendingActivationEssence",
			Type = "Function",

			Returns =
			{
				{ Name = "essenceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSlotInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "AzeriteEssence", Nilable = false },
			},

			Returns =
			{
				{ Name = "locked", Type = "bool", Nilable = false, Default = false },
				{ Name = "unlockLevel", Type = "number", Nilable = false, Default = 0 },
				{ Name = "unlockDescription", Type = "string", Nilable = true },
			},
		},
		{
			Name = "HasPendingActivationEssence",
			Type = "Function",

			Returns =
			{
				{ Name = "hasEssence", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAtForge",
			Type = "Function",

			Returns =
			{
				{ Name = "isAtForge", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPendingActivationEssence",
			Type = "Function",

			Arguments =
			{
				{ Name = "essenceID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AzeriteEssenceActivated",
			Type = "Event",
			LiteralName = "AZERITE_ESSENCE_ACTIVATED",
			Payload =
			{
				{ Name = "slot", Type = "AzeriteEssence", Nilable = false },
				{ Name = "essenceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AzeriteEssenceActivationFailed",
			Type = "Event",
			LiteralName = "AZERITE_ESSENCE_ACTIVATION_FAILED",
			Payload =
			{
				{ Name = "slot", Type = "AzeriteEssence", Nilable = false },
				{ Name = "essenceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AzeriteEssenceChanged",
			Type = "Event",
			LiteralName = "AZERITE_ESSENCE_CHANGED",
			Payload =
			{
				{ Name = "essenceID", Type = "number", Nilable = false },
				{ Name = "newRank", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AzeriteEssenceForgeClose",
			Type = "Event",
			LiteralName = "AZERITE_ESSENCE_FORGE_CLOSE",
		},
		{
			Name = "AzeriteEssenceForgeOpen",
			Type = "Event",
			LiteralName = "AZERITE_ESSENCE_FORGE_OPEN",
		},
		{
			Name = "AzeriteEssenceUpdate",
			Type = "Event",
			LiteralName = "AZERITE_ESSENCE_UPDATE",
		},
		{
			Name = "PendingAzeriteEssenceChanged",
			Type = "Event",
			LiteralName = "PENDING_AZERITE_ESSENCE_CHANGED",
			Payload =
			{
				{ Name = "essenceID", Type = "number", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "AzeriteEssence",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "MainSlot", Type = "AzeriteEssence", EnumValue = 0 },
				{ Name = "PassiveOneSlot", Type = "AzeriteEssence", EnumValue = 1 },
				{ Name = "PassiveTwoSlot", Type = "AzeriteEssence", EnumValue = 2 },
			},
		},
		{
			Name = "AzeriteEssenceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = false },
				{ Name = "unlocked", Type = "bool", Nilable = false },
				{ Name = "valid", Type = "bool", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AzeriteEssence);