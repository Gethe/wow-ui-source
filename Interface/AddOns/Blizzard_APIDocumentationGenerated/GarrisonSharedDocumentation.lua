local GarrisonShared =
{
	Tables =
	{
		{
			Name = "GarrisonAbilityEffect",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "factor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonFollowerAbilityInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "isTrait", Type = "bool", Nilable = false },
				{ Name = "isSpecialization", Type = "bool", Nilable = false },
				{ Name = "temporary", Type = "bool", Nilable = false },
				{ Name = "category", Type = "cstring", Nilable = true },
				{ Name = "counters", Type = "table", InnerType = "GarrisonAbilityEffect", Nilable = false },
				{ Name = "isEmptySlot", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GarrisonTalentCurrencyCostInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "currencyType", Type = "number", Nilable = false },
				{ Name = "currencyQuantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonTalentInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "ability", Type = "GarrisonFollowerAbilityInfo", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "tier", Type = "number", Nilable = false },
				{ Name = "uiOrder", Type = "number", Nilable = false },
				{ Name = "type", Type = "number", Nilable = false },
				{ Name = "prerequisiteTalentID", Type = "number", Nilable = true },
				{ Name = "selected", Type = "bool", Nilable = false },
				{ Name = "researched", Type = "bool", Nilable = false },
				{ Name = "ignoreTalent", Type = "bool", Nilable = false },
				{ Name = "researchDuration", Type = "time_t", Nilable = false },
				{ Name = "startTime", Type = "time_t", Nilable = false },
				{ Name = "timeRemaining", Type = "time_t", Nilable = false },
				{ Name = "researchGoldCost", Type = "number", Nilable = false },
				{ Name = "researchCurrencyCosts", Type = "table", InnerType = "GarrisonTalentCurrencyCostInfo", Nilable = false },
				{ Name = "talentAvailability", Type = "GarrisonTalentAvailability", Nilable = false },
				{ Name = "talentRank", Type = "number", Nilable = false },
				{ Name = "talentMaxRank", Type = "number", Nilable = false },
				{ Name = "isBeingResearched", Type = "bool", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "perkSpellID", Type = "number", Nilable = false },
				{ Name = "researchDescription", Type = "string", Nilable = true },
				{ Name = "playerConditionReason", Type = "string", Nilable = true },
				{ Name = "socketInfo", Type = "GarrisonTalentSocketInfo", Nilable = false },
				{ Name = "treeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonTalentSocketInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "socketType", Type = "number", Nilable = false },
				{ Name = "socketSubtype", Type = "number", Nilable = false },
				{ Name = "misc0", Type = "number", Nilable = false },
				{ Name = "misc1", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GarrisonTalentTreeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
				{ Name = "title", Type = "cstring", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "talents", Type = "table", InnerType = "GarrisonTalentInfo", Nilable = false },
				{ Name = "isClassAgnostic", Type = "bool", Nilable = false },
				{ Name = "isThemed", Type = "bool", Nilable = false },
				{ Name = "featureType", Type = "number", Nilable = false },
				{ Name = "featureSubtype", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GarrisonShared);