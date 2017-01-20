local ArtifactUILua =
{
	Name = "ArtifactUI",
	Namespace = "C_ArtifactUI",

	Functions =
	{
		{
			Name = "AddPower",

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ApplyCursorRelicToSlot",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CanApplyArtifactRelic",

			Arguments =
			{
				{ Name = "relicItemID", Type = "number", Nilable = false },
				{ Name = "onlyUnlocked", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "canApply", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanApplyCursorRelicToSlot",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canApply", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanApplyRelicItemIDToEquippedArtifactSlot",

			Arguments =
			{
				{ Name = "relicItemID", Type = "number", Nilable = false },
				{ Name = "relicSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canApply", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanApplyRelicItemIDToSlot",

			Arguments =
			{
				{ Name = "relicItemID", Type = "number", Nilable = false },
				{ Name = "relicSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canApply", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CheckRespecNPC",

			Returns =
			{
				{ Name = "canRespec", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Clear",
		},
		{
			Name = "ClearForgeCamera",
		},
		{
			Name = "ConfirmRespec",
		},
		{
			Name = "DoesEquippedArtifactHaveAnyRelicsSlotted",

			Returns =
			{
				{ Name = "hasAnyRelicsSlotted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceInfo",

			Arguments =
			{
				{ Name = "appearanceSetIndex", Type = "number", Nilable = false },
				{ Name = "appearanceIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceName", Type = "string", Nilable = false },
				{ Name = "displayIndex", Type = "number", Nilable = false },
				{ Name = "unlocked", Type = "bool", Nilable = false },
				{ Name = "failureDescription", Type = "string", Nilable = true },
				{ Name = "uiCameraID", Type = "number", Nilable = false },
				{ Name = "altHandCameraID", Type = "number", Nilable = true },
				{ Name = "swatchColorR", Type = "number", Nilable = false },
				{ Name = "swatchColorG", Type = "number", Nilable = false },
				{ Name = "swatchColorB", Type = "number", Nilable = false },
				{ Name = "modelOpacity", Type = "number", Nilable = false },
				{ Name = "modelSaturation", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceInfoByID",

			Arguments =
			{
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "artifactAppearanceSetID", Type = "number", Nilable = false },
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceName", Type = "string", Nilable = false },
				{ Name = "displayIndex", Type = "number", Nilable = false },
				{ Name = "unlocked", Type = "bool", Nilable = false },
				{ Name = "failureDescription", Type = "string", Nilable = true },
				{ Name = "uiCameraID", Type = "number", Nilable = false },
				{ Name = "altHandCameraID", Type = "number", Nilable = true },
				{ Name = "swatchColorR", Type = "number", Nilable = false },
				{ Name = "swatchColorG", Type = "number", Nilable = false },
				{ Name = "swatchColorB", Type = "number", Nilable = false },
				{ Name = "modelOpacity", Type = "number", Nilable = false },
				{ Name = "modelSaturation", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceSetInfo",

			Arguments =
			{
				{ Name = "appearanceSetIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "artifactAppearanceSetID", Type = "number", Nilable = false },
				{ Name = "appearanceSetName", Type = "string", Nilable = false },
				{ Name = "appearanceSetDescription", Type = "string", Nilable = false },
				{ Name = "numAppearances", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetArtifactArtInfo",

			Returns =
			{
				{ Name = "artifactArtInfo", Type = "ArtifactArtInfo", Nilable = false },
			},
		},
		{
			Name = "GetArtifactInfo",

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "altItemID", Type = "number", Nilable = true },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "xp", Type = "number", Nilable = false },
				{ Name = "pointsSpent", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceModID", Type = "number", Nilable = false },
				{ Name = "itemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altItemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altOnTop", Type = "bool", Nilable = false },
				{ Name = "artifactMaxed", Type = "bool", Nilable = false },
				{ Name = "tier", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetArtifactKnowledgeLevel",

			Returns =
			{
				{ Name = "knowledgeLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetArtifactKnowledgeMultiplier",

			Returns =
			{
				{ Name = "knowledgeMultiplier", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetArtifactTier",

			Returns =
			{
				{ Name = "tier", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetArtifactXPRewardTargetInfo",

			Arguments =
			{
				{ Name = "artifactCategoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCostForPointAtRank",

			Arguments =
			{
				{ Name = "rank", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "cost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquippedArtifactArtInfo",

			Returns =
			{
				{ Name = "artifactArtInfo", Type = "ArtifactArtInfo", Nilable = false },
			},
		},
		{
			Name = "GetEquippedArtifactInfo",

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "altItemID", Type = "number", Nilable = true },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "xp", Type = "number", Nilable = false },
				{ Name = "pointsSpent", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceModID", Type = "number", Nilable = false },
				{ Name = "itemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altItemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altOnTop", Type = "bool", Nilable = false },
				{ Name = "artifactMaxed", Type = "bool", Nilable = false },
				{ Name = "tier", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquippedArtifactNumRelicSlots",

			Arguments =
			{
				{ Name = "onlyUnlocked", Type = "bool", Nilable = false, Default = false, Documentation = { "If true then only the relic slots that are unlocked will be considered." } },
			},

			Returns =
			{
				{ Name = "numRelicSlots", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquippedArtifactRelicInfo",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "slotTypeName", Type = "string", Nilable = false, Documentation = { "Matches the socket identifiers used in the socketing system." } },
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetEquippedRelicLockedReason",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "lockedReason", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetForgeRotation",

			Returns =
			{
				{ Name = "forgeRotationX", Type = "number", Nilable = false },
				{ Name = "forgeRotationY", Type = "number", Nilable = false },
				{ Name = "forgeRotationZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemLevelIncreaseProvidedByRelic",

			Arguments =
			{
				{ Name = "itemLinkOrID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemIevelIncrease", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMetaPowerInfo",

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false, StrideIndex = 1 },
				{ Name = "powerCost", Type = "number", Nilable = false, StrideIndex = 2 },
				{ Name = "currentRank", Type = "number", Nilable = false, StrideIndex = 3 },
			},
		},
		{
			Name = "GetNumAppearanceSets",

			Returns =
			{
				{ Name = "numAppearanceSets", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumObtainedArtifacts",

			Returns =
			{
				{ Name = "numObtainedArtifacts", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumRelicSlots",

			Arguments =
			{
				{ Name = "onlyUnlocked", Type = "bool", Nilable = false, Default = false, Documentation = { "If true then only the relic slots that are unlocked will be considered." } },
			},

			Returns =
			{
				{ Name = "numRelicSlots", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPointsRemaining",

			Returns =
			{
				{ Name = "pointsRemaining", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPowerHyperlink",

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetPowerInfo",

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerInfo", Type = "ArtifactPowerInfo", Nilable = false },
			},
		},
		{
			Name = "GetPowerLinks",

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "linkingPowerID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetPowers",

			Returns =
			{
				{ Name = "powerID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetPowersAffectedByRelic",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerIDs", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetPowersAffectedByRelicItemID",

			Arguments =
			{
				{ Name = "relicItemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerIDs", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetPreviewAppearance",

			Returns =
			{
				{ Name = "artifactAppearanceID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetRelicInfo",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "slotTypeName", Type = "string", Nilable = false, Documentation = { "Matches the socket identifiers used in the socketing system." } },
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRelicInfoByItemID",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "slotTypeName", Type = "string", Nilable = false, Documentation = { "Matches the socket identifiers used in the socketing system." } },
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRelicLockedReason",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "lockedReason", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetRelicSlotType",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slotTypeName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRespecArtifactArtInfo",

			Returns =
			{
				{ Name = "artifactArtInfo", Type = "ArtifactArtInfo", Nilable = false },
			},
		},
		{
			Name = "GetRespecArtifactInfo",

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "altItemID", Type = "number", Nilable = true },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "xp", Type = "number", Nilable = false },
				{ Name = "pointsSpent", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceModID", Type = "number", Nilable = false },
				{ Name = "itemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altItemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altOnTop", Type = "bool", Nilable = false },
				{ Name = "artifactMaxed", Type = "bool", Nilable = false },
				{ Name = "tier", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRespecCost",

			Returns =
			{
				{ Name = "cost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTotalPurchasedRanks",

			Returns =
			{
				{ Name = "totalPurchasedRanks", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsAtForge",

			Returns =
			{
				{ Name = "isAtForge", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPowerKnown",

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "known", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsViewedArtifactEquipped",

			Returns =
			{
				{ Name = "isViewedArtifactEquipped", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAppearance",

			Arguments =
			{
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetForgeCamera",
		},
		{
			Name = "SetForgeRotation",

			Arguments =
			{
				{ Name = "forgeRotationX", Type = "number", Nilable = false },
				{ Name = "forgeRotationY", Type = "number", Nilable = false },
				{ Name = "forgeRotationZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPreviewAppearance",
			Documentation = { "Call without an argument to clear the preview." },

			Arguments =
			{
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "ShouldSuppressForgeRotation",

			Returns =
			{
				{ Name = "shouldSuppressForgeRotation", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "ArtifactArtInfo",
			Fields =
			{
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "titleName", Type = "string", Nilable = false },
				{ Name = "titleColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "barConnectedColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "barDisconnectedColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "uiModelSceneID", Type = "number", Nilable = false },
				{ Name = "spellVisualKitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ArtifactPowerInfo",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "cost", Type = "number", Nilable = false },
				{ Name = "currentRank", Type = "number", Nilable = false },
				{ Name = "maxRank", Type = "number", Nilable = false },
				{ Name = "bonusRanks", Type = "number", Nilable = false },
				{ Name = "numMaxRankBonusFromTier", Type = "number", Nilable = false },
				{ Name = "prereqsMet", Type = "bool", Nilable = false },
				{ Name = "isStart", Type = "bool", Nilable = false },
				{ Name = "isGoldMedal", Type = "bool", Nilable = false },
				{ Name = "isFinal", Type = "bool", Nilable = false },
				{ Name = "tier", Type = "number", Nilable = false },
				{ Name = "position", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "offset", Type = "vector2", Mixin = "Vector2DMixin", Nilable = true },
				{ Name = "linearIndex", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ArtifactUILua);