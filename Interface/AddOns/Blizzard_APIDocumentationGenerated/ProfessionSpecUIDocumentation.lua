local ProfessionSpecUI =
{
	Name = "ProfessionSpecUI",
	Type = "System",
	Namespace = "C_ProfSpecs",

	Functions =
	{
		{
			Name = "CanRefundPath",
			Type = "Function",

			Arguments =
			{
				{ Name = "pathID", Type = "number", Nilable = false },
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canRefund", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanUnlockTab",
			Type = "Function",

			Arguments =
			{
				{ Name = "tabTreeID", Type = "number", Nilable = false },
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canUnlock", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetChildrenForPath",
			Type = "Function",

			Arguments =
			{
				{ Name = "pathID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "childIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetConfigIDForSkillLine",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyInfoForSkillLine",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "SpecializationCurrencyInfo", Nilable = false },
			},
		},
		{
			Name = "GetDefaultSpecSkillLine",
			Type = "Function",

			Returns =
			{
				{ Name = "defaultSpecSkillLine", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetDescriptionForPath",
			Type = "Function",

			Arguments =
			{
				{ Name = "pathID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetDescriptionForPerk",
			Type = "Function",

			Arguments =
			{
				{ Name = "perkID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "description", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetEntryIDForPerk",
			Type = "Function",

			Arguments =
			{
				{ Name = "perkID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "entryID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNewSpecReminderProfName",
			Type = "Function",

			Returns =
			{
				{ Name = "profName", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GetPerksForPath",
			Type = "Function",

			Arguments =
			{
				{ Name = "pathID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "perkInfos", Type = "table", InnerType = "SpecPerkInfo", Nilable = false },
			},
		},
		{
			Name = "GetRootPathForTab",
			Type = "Function",

			Arguments =
			{
				{ Name = "tabTreeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rootPathID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSourceTextForPath",
			Type = "Function",

			Arguments =
			{
				{ Name = "pathID", Type = "number", Nilable = false },
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sourceText", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetSpecTabIDsForSkillLine",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "specTabIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpecTabInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "specTabInfo", Type = "SpecializationTabInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpendCurrencyForPath",
			Type = "Function",

			Arguments =
			{
				{ Name = "pathID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "currencyID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSpendEntryForPath",
			Type = "Function",

			Arguments =
			{
				{ Name = "pathID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "entryID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetStateForPath",
			Type = "Function",

			Arguments =
			{
				{ Name = "pathID", Type = "number", Nilable = false },
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "state", Type = "ProfessionsSpecPathState", Nilable = false },
			},
		},
		{
			Name = "GetStateForPerk",
			Type = "Function",

			Arguments =
			{
				{ Name = "perkID", Type = "number", Nilable = false },
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "state", Type = "ProfessionsSpecPerkState", Nilable = false },
			},
		},
		{
			Name = "GetStateForTab",
			Type = "Function",

			Arguments =
			{
				{ Name = "tabTreeID", Type = "number", Nilable = false },
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "tabInfo", Type = "ProfessionsSpecTabState", Nilable = false },
			},
		},
		{
			Name = "GetTabInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "tabTreeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "tabInfo", Type = "ProfTabInfo", Nilable = true },
			},
		},
		{
			Name = "GetUnlockEntryForPath",
			Type = "Function",

			Arguments =
			{
				{ Name = "pathID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "entryID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnlockRankForPerk",
			Type = "Function",

			Arguments =
			{
				{ Name = "perkID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "unlockRank", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ShouldShowPointsReminder",
			Type = "Function",

			Returns =
			{
				{ Name = "showReminder", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldShowPointsReminderForSkillLine",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "showReminder", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldShowSpecTab",
			Type = "Function",

			Returns =
			{
				{ Name = "showSpecTab", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SkillLineHasSpecialization",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasSpecialization", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SkillLineSpecsRanksChanged",
			Type = "Event",
			LiteralName = "SKILL_LINE_SPECS_RANKS_CHANGED",
		},
		{
			Name = "SkillLineSpecsUnlocked",
			Type = "Event",
			LiteralName = "SKILL_LINE_SPECS_UNLOCKED",
			Payload =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
				{ Name = "tradeSkillID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ProfessionSpecUI);