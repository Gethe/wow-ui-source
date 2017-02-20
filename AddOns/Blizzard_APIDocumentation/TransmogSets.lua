local TransmogSets =
{
	Name = "Transmogrify",
	Type = "System",
	Namespace = "C_TransmogSets",

	Functions =
	{
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
			Name = "GetSourcesForInventoryType",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "inventoryType", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "sources", Type = "table", InnerType = "AppearanceSourceInfo", Nilable = false },
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
			Name = "SetIsFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(TransmogSets);