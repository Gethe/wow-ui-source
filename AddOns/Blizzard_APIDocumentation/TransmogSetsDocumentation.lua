local TransmogSets =
{
	Name = "TransmogrifySets",
	Type = "System",
	Namespace = "C_TransmogSets",

	Functions =
	{
		{
			Name = "ClearLatestSource",
			Type = "Function",
		},
		{
			Name = "ClearNewSource",
			Type = "Function",

			Arguments =
			{
				{ Name = "sourceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClearSetNewSourcesForSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAllSets",
			Type = "Function",

			Returns =
			{
				{ Name = "sets", Type = "table", InnerType = "TransmogSetInfo", Nilable = false },
			},
		},
		{
			Name = "GetAllSourceIDs",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sources", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetBaseSetID",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "baseTransmogSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetBaseSets",
			Type = "Function",

			Returns =
			{
				{ Name = "sets", Type = "table", InnerType = "TransmogSetInfo", Nilable = false },
			},
		},
		{
			Name = "GetBaseSetsCounts",
			Type = "Function",

			Returns =
			{
				{ Name = "numCollected", Type = "number", Nilable = false },
				{ Name = "numTotal", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetBaseSetsFilter",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetCameraIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "detailsCameraID", Type = "number", Nilable = true },
				{ Name = "vendorCameraID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetIsFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "isGroupFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetLatestSource",
			Type = "Function",

			Returns =
			{
				{ Name = "sourceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSetInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "set", Type = "TransmogSetInfo", Nilable = false },
			},
		},
		{
			Name = "GetSetNewSources",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sourceIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetSetPrimaryAppearances",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "apppearances", Type = "table", InnerType = "TransmogSetPrimaryAppearanceInfo", Nilable = false },
			},
		},
		{
			Name = "GetSetsContainingSourceID",
			Type = "Function",

			Arguments =
			{
				{ Name = "sourceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "setIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetSourceIDsForSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sources", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetSourcesForSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sources", Type = "table", InnerType = "AppearanceSourceInfo", Nilable = false },
			},
		},
		{
			Name = "GetUsableSets",
			Type = "Function",

			Returns =
			{
				{ Name = "sets", Type = "table", InnerType = "TransmogSetInfo", Nilable = false },
			},
		},
		{
			Name = "GetVariantSets",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sets", Type = "table", InnerType = "TransmogSetInfo", Nilable = false },
			},
		},
		{
			Name = "HasUsableSets",
			Type = "Function",

			Returns =
			{
				{ Name = "hasUsableSets", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsBaseSetCollected",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCollected", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsNewSource",
			Type = "Function",

			Arguments =
			{
				{ Name = "sourceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isNew", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetBaseSetsFilter",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetHasNewSources",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasNewSources", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetHasNewSourcesForSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasNewSources", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetIsFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "TransmogSetInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "setID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "baseSetID", Type = "number", Nilable = true },
				{ Name = "description", Type = "string", Nilable = true },
				{ Name = "label", Type = "string", Nilable = true },
				{ Name = "expansionID", Type = "number", Nilable = false },
				{ Name = "patchID", Type = "number", Nilable = false },
				{ Name = "uiOrder", Type = "number", Nilable = false },
				{ Name = "classMask", Type = "number", Nilable = false },
				{ Name = "hiddenUntilCollected", Type = "bool", Nilable = false },
				{ Name = "requiredFaction", Type = "string", Nilable = true },
				{ Name = "collected", Type = "bool", Nilable = false },
				{ Name = "favorite", Type = "bool", Nilable = false },
				{ Name = "limitedTimeSet", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TransmogSetPrimaryAppearanceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "appearanceID", Type = "number", Nilable = false },
				{ Name = "collected", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TransmogSets);