local SpecializationInfo =
{
	Name = "SpecializationInfo",
	Type = "System",
	Namespace = "C_SpecializationInfo",

	Functions =
	{
		{
			Name = "CanPlayerUsePVPTalentUI",
			Type = "Function",

			Returns =
			{
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CanPlayerUseTalentSpecUI",
			Type = "Function",

			Returns =
			{
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CanPlayerUseTalentUI",
			Type = "Function",

			Returns =
			{
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetActiveSpecGroup",
			Type = "Function",

			Arguments =
			{
				{ Name = "isInspect", Type = "bool", Nilable = true },
				{ Name = "isPet", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "groupIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetAllSelectedPvpTalentIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "selectedPvpTalentIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetClassIDFromSpecID",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "classID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetInspectSelectedPvpTalent",
			Type = "Function",

			Arguments =
			{
				{ Name = "inspectedUnit", Type = "UnitToken", Nilable = false },
				{ Name = "talentIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "selectedTalentID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetNumSpecializationsForClassID",
			Type = "Function",

			Arguments =
			{
				{ Name = "classID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "specCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPvpTalentAlertStatus",
			Type = "Function",

			Returns =
			{
				{ Name = "hasUnspentSlot", Type = "bool", Nilable = false },
				{ Name = "hasNewTalent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetPvpTalentInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "talentInfo", Type = "PvpTalentInfo", Nilable = true },
			},
		},
		{
			Name = "GetPvpTalentSlotInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "talentIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slotInfo", Type = "PvpTalentSlotInfo", Nilable = true },
			},
		},
		{
			Name = "GetPvpTalentSlotUnlockLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "talentIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "requiredLevel", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetPvpTalentUnlockLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "requiredLevel", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSpecIDs",
			Type = "Function",

			Arguments =
			{
				{ Name = "specSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "specIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpecialization",
			Type = "Function",

			Arguments =
			{
				{ Name = "isInspect", Type = "bool", Nilable = true },
				{ Name = "isPet", Type = "bool", Nilable = true },
				{ Name = "specGroupIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "specializationIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetSpecializationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "specializationIndex", Type = "luaIndex", Nilable = false },
				{ Name = "isInspect", Type = "bool", Nilable = false, Default = false },
				{ Name = "isPet", Type = "bool", Nilable = false, Default = false },
				{ Name = "inspectTarget", Type = "string", Nilable = true },
				{ Name = "sex", Type = "number", Nilable = true },
				{ Name = "groupIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "specId", Type = "number", Nilable = false, Default = 0 },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "description", Type = "string", Nilable = true },
				{ Name = "icon", Type = "fileID", Nilable = true },
				{ Name = "role", Type = "string", Nilable = true },
				{ Name = "primaryStat", Type = "luaIndex", Nilable = true },
				{ Name = "pointsSpent", Type = "number", Nilable = false, Default = 0 },
				{ Name = "background", Type = "string", Nilable = true },
				{ Name = "previewPointsSpent", Type = "number", Nilable = false, Default = 0 },
				{ Name = "isUnlocked", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "GetSpecializationMasterySpells",
			Type = "Function",

			Arguments =
			{
				{ Name = "specializationIndex", Type = "luaIndex", Nilable = false },
				{ Name = "isInspect", Type = "bool", Nilable = true },
				{ Name = "isPet", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "spellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellsDisplay",
			Type = "Function",

			Arguments =
			{
				{ Name = "specializationID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetTalentInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "query", Type = "TalentInfoQuery", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "TalentInfoResult", Nilable = true },
			},
		},
		{
			Name = "IsInitialized",
			Type = "Function",

			Returns =
			{
				{ Name = "isSpecializationDataInitialized", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPvpTalentLocked",
			Type = "Function",

			Arguments =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "locked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MatchesCurrentSpecSet",
			Type = "Function",

			Arguments =
			{
				{ Name = "specSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "matches", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPetSpecialization",
			Type = "Function",

			Arguments =
			{
				{ Name = "specIndex", Type = "luaIndex", Nilable = false },
				{ Name = "petNumber", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetPvpTalentLocked",
			Type = "Function",

			Arguments =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
				{ Name = "locked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSpecialization",
			Type = "Function",

			Arguments =
			{
				{ Name = "specIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ActiveTalentGroupChanged",
			Type = "Event",
			LiteralName = "ACTIVE_TALENT_GROUP_CHANGED",
			Payload =
			{
				{ Name = "curr", Type = "number", Nilable = false },
				{ Name = "prev", Type = "number", Nilable = false },
			},
		},
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
			Name = "PetSpecializationChanged",
			Type = "Event",
			LiteralName = "PET_SPECIALIZATION_CHANGED",
		},
		{
			Name = "PlayerLearnPvpTalentFailed",
			Type = "Event",
			LiteralName = "PLAYER_LEARN_PVP_TALENT_FAILED",
		},
		{
			Name = "PlayerLearnTalentFailed",
			Type = "Event",
			LiteralName = "PLAYER_LEARN_TALENT_FAILED",
		},
		{
			Name = "PlayerPvpTalentUpdate",
			Type = "Event",
			LiteralName = "PLAYER_PVP_TALENT_UPDATE",
		},
		{
			Name = "PlayerTalentUpdate",
			Type = "Event",
			LiteralName = "PLAYER_TALENT_UPDATE",
		},
		{
			Name = "SpecInvoluntarilyChanged",
			Type = "Event",
			LiteralName = "SPEC_INVOLUNTARILY_CHANGED",
			Payload =
			{
				{ Name = "isPet", Type = "bool", Nilable = false },
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
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "selectedTalentID", Type = "number", Nilable = true },
				{ Name = "availableTalentIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "SpecializationInfoOutput",
			Type = "Structure",
			Fields =
			{
				{ Name = "specId", Type = "number", Nilable = false, Default = 0 },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "description", Type = "string", Nilable = true },
				{ Name = "icon", Type = "fileID", Nilable = true },
				{ Name = "role", Type = "string", Nilable = true },
				{ Name = "primaryStat", Type = "luaIndex", Nilable = true },
				{ Name = "pointsSpent", Type = "number", Nilable = false, Default = 0 },
				{ Name = "background", Type = "string", Nilable = true },
				{ Name = "previewPointsSpent", Type = "number", Nilable = false, Default = 0 },
				{ Name = "isUnlocked", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "SpecializationInfoQuery",
			Type = "Structure",
			Fields =
			{
				{ Name = "specializationIndex", Type = "luaIndex", Nilable = false },
				{ Name = "isInspect", Type = "bool", Nilable = false, Default = false },
				{ Name = "isPet", Type = "bool", Nilable = false, Default = false },
				{ Name = "inspectTarget", Type = "string", Nilable = true },
				{ Name = "sex", Type = "number", Nilable = true },
				{ Name = "groupIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "TalentInfoQuery",
			Type = "Structure",
			Fields =
			{
				{ Name = "groupIndex", Type = "luaIndex", Nilable = true },
				{ Name = "isInspect", Type = "bool", Nilable = false, Default = false },
				{ Name = "tier", Type = "luaIndex", Nilable = true },
				{ Name = "column", Type = "luaIndex", Nilable = true },
				{ Name = "target", Type = "UnitToken", Nilable = true },
				{ Name = "specializationIndex", Type = "luaIndex", Nilable = true },
				{ Name = "talentIndex", Type = "luaIndex", Nilable = true },
				{ Name = "isPet", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TalentInfoResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "talentID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "tier", Type = "luaIndex", Nilable = false },
				{ Name = "column", Type = "luaIndex", Nilable = false },
				{ Name = "selected", Type = "bool", Nilable = false, Default = false },
				{ Name = "available", Type = "bool", Nilable = false, Default = false },
				{ Name = "spellID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "isPVPTalentUnlocked", Type = "bool", Nilable = false, Default = false },
				{ Name = "known", Type = "bool", Nilable = false, Default = false },
				{ Name = "grantedByAura", Type = "bool", Nilable = false, Default = false },
				{ Name = "rank", Type = "luaIndex", Nilable = false },
				{ Name = "maxRank", Type = "luaIndex", Nilable = false },
				{ Name = "meetsPrereq", Type = "bool", Nilable = false, Default = false },
				{ Name = "previewRank", Type = "luaIndex", Nilable = false },
				{ Name = "meetsPreviewPrereq", Type = "bool", Nilable = false, Default = false },
				{ Name = "isExceptional", Type = "bool", Nilable = false, Default = false },
				{ Name = "hasGoldBorder", Type = "bool", Nilable = false, Default = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SpecializationInfo);