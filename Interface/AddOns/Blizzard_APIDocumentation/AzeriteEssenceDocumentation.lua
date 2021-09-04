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
				{ Name = "milestoneID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CanActivateEssence",
			Type = "Function",

			Arguments =
			{
				{ Name = "essenceID", Type = "number", Nilable = false },
				{ Name = "milestoneID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canActivate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanDeactivateEssence",
			Type = "Function",

			Arguments =
			{
				{ Name = "milestoneID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canDeactivate", Type = "bool", Nilable = false },
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
			Name = "GetEssenceHyperlink",
			Type = "Function",

			Arguments =
			{
				{ Name = "essenceID", Type = "number", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
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
			Name = "GetMilestoneEssence",
			Type = "Function",

			Arguments =
			{
				{ Name = "milestoneID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "essenceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMilestoneInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "milestoneID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "AzeriteMilestoneInfo", Nilable = false },
			},
		},
		{
			Name = "GetMilestoneSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "milestoneID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMilestones",
			Type = "Function",

			Returns =
			{
				{ Name = "milestones", Type = "table", InnerType = "AzeriteMilestoneInfo", Nilable = false },
			},
		},
		{
			Name = "GetNumUnlockedEssences",
			Type = "Function",

			Returns =
			{
				{ Name = "numUnlockedEssences", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumUsableEssences",
			Type = "Function",

			Returns =
			{
				{ Name = "numUsableEssences", Type = "number", Nilable = false },
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
			Name = "HasNeverActivatedAnyEssences",
			Type = "Function",

			Returns =
			{
				{ Name = "hasNeverActivatedAnyEssences", Type = "bool", Nilable = false },
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
		{
			Name = "UnlockMilestone",
			Type = "Function",

			Arguments =
			{
				{ Name = "milestoneID", Type = "number", Nilable = false },
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
			Name = "AzeriteEssenceMilestoneUnlocked",
			Type = "Event",
			LiteralName = "AZERITE_ESSENCE_MILESTONE_UNLOCKED",
			Payload =
			{
				{ Name = "milestoneID", Type = "number", Nilable = false },
			},
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
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "MainSlot", Type = "AzeriteEssence", EnumValue = 0 },
				{ Name = "PassiveOneSlot", Type = "AzeriteEssence", EnumValue = 1 },
				{ Name = "PassiveTwoSlot", Type = "AzeriteEssence", EnumValue = 2 },
				{ Name = "PassiveThreeSlot", Type = "AzeriteEssence", EnumValue = 3 },
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
		{
			Name = "AzeriteMilestoneInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "requiredLevel", Type = "number", Nilable = false },
				{ Name = "canUnlock", Type = "bool", Nilable = false },
				{ Name = "unlocked", Type = "bool", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = true },
				{ Name = "slot", Type = "AzeriteEssence", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AzeriteEssence);