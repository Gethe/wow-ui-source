local TransmogItems =
{
	Name = "TransmogrifyCollection",
	Type = "System",
	Namespace = "C_TransmogCollection",

	Functions =
	{
		{
			Name = "AccountCanCollectSource",
			Type = "Function",

			Arguments =
			{
				{ Name = "sourceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasItemData", Type = "bool", Nilable = false },
				{ Name = "canCollect", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AreAllCollectionTypeFiltersChecked",
			Type = "Function",

			Returns =
			{
				{ Name = "areAllCollectionTypeFiltersChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AreAllSourceTypeFiltersChecked",
			Type = "Function",

			Returns =
			{
				{ Name = "areAllSourceTypeFiltersChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearNewAppearance",
			Type = "Function",

			Arguments =
			{
				{ Name = "visualID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClearSearch",
			Type = "Function",

			Arguments =
			{
				{ Name = "searchType", Type = "TransmogSearchType", Nilable = false },
			},

			Returns =
			{
				{ Name = "completed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DeleteOutfit",
			Type = "Function",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EndSearch",
			Type = "Function",
		},
		{
			Name = "GetAllAppearanceSources",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemModifiedAppearanceIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceCameraID",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemAppearanceID", Type = "number", Nilable = false },
				{ Name = "variation", Type = "TransmogCameraVariation", Nilable = true },
			},

			Returns =
			{
				{ Name = "cameraID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceCameraIDBySource",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
				{ Name = "variation", Type = "TransmogCameraVariation", Nilable = true },
			},

			Returns =
			{
				{ Name = "cameraID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceInfoBySource",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "TransmogAppearanceInfoBySourceData", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceSourceDrops",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "encounterInfo", Type = "table", InnerType = "TransmogAppearanceJournalEncounterInfo", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceSourceInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "category", Type = "TransmogCollectionType", Nilable = false },
				{ Name = "itemAppearanceID", Type = "number", Nilable = false },
				{ Name = "canHaveIllusion", Type = "bool", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "isCollected", Type = "bool", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = false },
				{ Name = "transmoglink", Type = "string", Nilable = false },
				{ Name = "sourceType", Type = "luaIndex", Nilable = true },
				{ Name = "itemSubClass", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceSources",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "appearanceID", Type = "number", Nilable = false },
				{ Name = "categoryType", Type = "TransmogCollectionType", Nilable = true },
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = true },
			},

			Returns =
			{
				{ Name = "sources", Type = "table", InnerType = "AppearanceSourceInfo", Nilable = false },
			},
		},
		{
			Name = "GetCategoryAppearances",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "category", Type = "TransmogCollectionType", Nilable = false },
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = true },
			},

			Returns =
			{
				{ Name = "appearances", Type = "table", InnerType = "TransmogCategoryAppearanceInfo", Nilable = false },
			},
		},
		{
			Name = "GetCategoryCollectedCount",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "TransmogCollectionType", Nilable = false },
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCategoryForItem",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "collectionCategory", Type = "TransmogCollectionType", Nilable = false },
			},
		},
		{
			Name = "GetCategoryInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "category", Type = "TransmogCollectionType", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "isWeapon", Type = "bool", Nilable = false, Default = false },
				{ Name = "canHaveIllusions", Type = "bool", Nilable = false, Default = false },
				{ Name = "canMainHand", Type = "bool", Nilable = false, Default = false },
				{ Name = "canOffHand", Type = "bool", Nilable = false, Default = false },
				{ Name = "canRanged", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "GetCategoryTotal",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "TransmogCollectionType", Nilable = false },
			},

			Returns =
			{
				{ Name = "total", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCollectedShown",
			Type = "Function",

			Returns =
			{
				{ Name = "shown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetIsAppearanceFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetItemInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemAppearanceID", Type = "number", Nilable = false },
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemTransmogInfoListFromOutfitHyperlink",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "hyperlink", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "list", Type = "table", InnerType = "ItemTransmogInfo", Nilable = false },
			},
		},
		{
			Name = "GetLatestAppearance",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "visualID", Type = "number", Nilable = false },
				{ Name = "category", Type = "TransmogCollectionType", Nilable = false },
			},
		},
		{
			Name = "GetNumMaxOutfits",
			Type = "Function",

			Returns =
			{
				{ Name = "maxOutfits", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumTransmogSources",
			Type = "Function",

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOutfitInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "GetOutfitItemTransmogInfoList",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "list", Type = "table", InnerType = "ItemTransmogInfo", Nilable = false },
			},
		},
		{
			Name = "GetOutfits",
			Type = "Function",

			Returns =
			{
				{ Name = "outfitID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetPairedArtifactAppearance",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "pairedItemModifiedAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSourceIcon",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "icon", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "GetSourceInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "sourceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sourceInfo", Type = "AppearanceSourceInfo", Nilable = false },
			},
		},
		{
			Name = "GetSourceItemID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSourceRequiredHoliday",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "holidayName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetUncollectedShown",
			Type = "Function",

			Returns =
			{
				{ Name = "shown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasFavorites",
			Type = "Function",

			Returns =
			{
				{ Name = "hasFavorites", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAppearanceHiddenVisual",
			Type = "Function",

			Arguments =
			{
				{ Name = "appearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isHiddenVisual", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsCategoryValidForItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "TransmogCollectionType", Nilable = false },
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsNewAppearance",
			Type = "Function",

			Arguments =
			{
				{ Name = "visualID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isNew", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSearchDBLoading",
			Type = "Function",

			Returns =
			{
				{ Name = "isLoading", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSearchInProgress",
			Type = "Function",

			Arguments =
			{
				{ Name = "searchType", Type = "TransmogSearchType", Nilable = false },
			},

			Returns =
			{
				{ Name = "inProgress", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSourceTypeFilterChecked",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "checked", Type = "bool", Nilable = false },
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
			Name = "ModifyOutfit",
			Type = "Function",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
				{ Name = "itemTransmogInfoList", Type = "table", InnerType = "ItemTransmogInfo", Nilable = false },
			},
		},
		{
			Name = "NewOutfit",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "itemTransmogInfoList", Type = "table", InnerType = "ItemTransmogInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "outfitID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "PlayerCanCollectSource",
			Type = "Function",

			Arguments =
			{
				{ Name = "sourceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasItemData", Type = "bool", Nilable = false },
				{ Name = "canCollect", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerHasTransmog",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemAppearanceModID", Type = "number", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "hasTransmog", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerHasTransmogItemModifiedAppearance",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasTransmog", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerKnowsSource",
			Type = "Function",

			Arguments =
			{
				{ Name = "sourceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isKnown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RenameOutfit",
			Type = "Function",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SearchProgress",
			Type = "Function",

			Arguments =
			{
				{ Name = "searchType", Type = "TransmogSearchType", Nilable = false },
			},

			Returns =
			{
				{ Name = "progress", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SearchSize",
			Type = "Function",

			Arguments =
			{
				{ Name = "searchType", Type = "TransmogSearchType", Nilable = false },
			},

			Returns =
			{
				{ Name = "size", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetAllCollectionTypeFilters",
			Type = "Function",

			Arguments =
			{
				{ Name = "checked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAllSourceTypeFilters",
			Type = "Function",

			Arguments =
			{
				{ Name = "checked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCollectedShown",
			Type = "Function",

			Arguments =
			{
				{ Name = "shown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDefaultFilters",
			Type = "Function",
		},
		{
			Name = "SetIsAppearanceFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemAppearanceID", Type = "number", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSearch",
			Type = "Function",

			Arguments =
			{
				{ Name = "searchType", Type = "TransmogSearchType", Nilable = false },
				{ Name = "searchText", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "completed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSearchAndFilterCategory",
			Type = "Function",

			Arguments =
			{
				{ Name = "category", Type = "TransmogCollectionType", Nilable = false },
			},
		},
		{
			Name = "SetSourceTypeFilter",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "checked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetUncollectedShown",
			Type = "Function",

			Arguments =
			{
				{ Name = "shown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UpdateUsableAppearances",
			Type = "Function",
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "TransmogCameraVariation",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "TransmogCameraVariation", EnumValue = 0 },
				{ Name = "RightShoulder", Type = "TransmogCameraVariation", EnumValue = 1 },
				{ Name = "CloakBackpack", Type = "TransmogCameraVariation", EnumValue = 1 },
			},
		},
		{
			Name = "TransmogAppearanceInfoBySourceData",
			Type = "Structure",
			Fields =
			{
				{ Name = "appearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceIsCollected", Type = "bool", Nilable = false },
				{ Name = "sourceIsCollected", Type = "bool", Nilable = false },
				{ Name = "sourceIsCollectedPermanent", Type = "bool", Nilable = false },
				{ Name = "sourceIsCollectedConditional", Type = "bool", Nilable = false },
				{ Name = "meetsTransmogPlayerCondition", Type = "bool", Nilable = false },
				{ Name = "appearanceHasAnyNonLevelRequirements", Type = "bool", Nilable = false },
				{ Name = "appearanceMeetsNonLevelRequirements", Type = "bool", Nilable = false },
				{ Name = "appearanceIsUsable", Type = "bool", Nilable = false },
				{ Name = "appearanceNumSources", Type = "number", Nilable = false },
				{ Name = "sourceIsKnown", Type = "bool", Nilable = false },
				{ Name = "canDisplayOnPlayer", Type = "bool", Nilable = false },
				{ Name = "isAnySourceValidForPlayer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TransmogAppearanceJournalEncounterInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "instance", Type = "string", Nilable = false },
				{ Name = "instanceType", Type = "number", Nilable = false },
				{ Name = "tiers", Type = "table", InnerType = "string", Nilable = false },
				{ Name = "encounter", Type = "string", Nilable = false },
				{ Name = "difficulties", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "TransmogAppearanceSourceInfoData",
			Type = "Structure",
			Fields =
			{
				{ Name = "category", Type = "TransmogCollectionType", Nilable = false },
				{ Name = "itemAppearanceID", Type = "number", Nilable = false },
				{ Name = "canHaveIllusion", Type = "bool", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "isCollected", Type = "bool", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = false },
				{ Name = "transmoglink", Type = "string", Nilable = false },
				{ Name = "sourceType", Type = "luaIndex", Nilable = true },
				{ Name = "itemSubClass", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TransmogCategoryAppearanceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "visualID", Type = "number", Nilable = false },
				{ Name = "isCollected", Type = "bool", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "isHideVisual", Type = "bool", Nilable = false },
				{ Name = "canDisplayOnPlayer", Type = "bool", Nilable = false },
				{ Name = "uiOrder", Type = "number", Nilable = false },
				{ Name = "exclusions", Type = "number", Nilable = false },
				{ Name = "restrictedSlotID", Type = "luaIndex", Nilable = true },
				{ Name = "isUsable", Type = "bool", Nilable = false },
				{ Name = "hasRequiredHoliday", Type = "bool", Nilable = false },
				{ Name = "hasActiveRequiredHoliday", Type = "bool", Nilable = false },
				{ Name = "alwaysShowItem", Type = "bool", Nilable = true, Documentation = { "For internal testing only" } },
			},
		},
		{
			Name = "TransmogCategoryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "isWeapon", Type = "bool", Nilable = false, Default = false },
				{ Name = "canHaveIllusions", Type = "bool", Nilable = false, Default = false },
				{ Name = "canMainHand", Type = "bool", Nilable = false, Default = false },
				{ Name = "canOffHand", Type = "bool", Nilable = false, Default = false },
				{ Name = "canRanged", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TransmogIllusionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "visualID", Type = "number", Nilable = false },
				{ Name = "sourceID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "isCollected", Type = "bool", Nilable = false },
				{ Name = "isUsable", Type = "bool", Nilable = false },
				{ Name = "isHideVisual", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TransmogOutfitInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TransmogItems);