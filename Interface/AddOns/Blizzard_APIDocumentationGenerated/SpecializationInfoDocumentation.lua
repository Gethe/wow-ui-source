local SpecializationInfo =
{
	Name = "SpecializationInfo",
	Type = "System",
	Namespace = "C_SpecializationInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ConfirmPetUnlearn",
			Type = "Event",
			LiteralName = "CONFIRM_PET_UNLEARN",
			Payload =
			{
				{ Name = "cost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ConfirmTalentWipe",
			Type = "Event",
			LiteralName = "CONFIRM_TALENT_WIPE",
			Payload =
			{
				{ Name = "cost", Type = "number", Nilable = false },
				{ Name = "respecType", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TalentsInvoluntarilyReset",
			Type = "Event",
			LiteralName = "TALENTS_INVOLUNTARILY_RESET",
			Payload =
			{
				{ Name = "isPetTalents", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "PvpTalentInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "selected", Type = "bool", Nilable = false },
				{ Name = "available", Type = "bool", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "unlocked", Type = "bool", Nilable = false },
				{ Name = "known", Type = "bool", Nilable = false },
				{ Name = "grantedByAura", Type = "bool", Nilable = false },
				{ Name = "dependenciesUnmet", Type = "bool", Nilable = false },
				{ Name = "dependenciesUnmetReason", Type = "string", Nilable = true },
			},
		},
		{
			Name = "PvpTalentSlotInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
				{ Name = "selectedTalentID", Type = "number", Nilable = true },
				{ Name = "availableTalentIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SpecializationInfo);