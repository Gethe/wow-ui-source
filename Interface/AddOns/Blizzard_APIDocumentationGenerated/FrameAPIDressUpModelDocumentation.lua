local FrameAPIDressUpModel =
{
	Name = "FrameAPIDressUpModel",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "Dress",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetAutoDress",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSheathed",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "sheathed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAutoDress",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetSheathed",
			Type = "Function",

			Arguments =
			{
				{ Name = "sheathed", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TryOn",
			Type = "Function",

			Arguments =
			{
				{ Name = "linkOrItemModifiedAppearanceID", Type = "IDOrLink", Nilable = false },
				{ Name = "handSlotName", Type = "cstring", Nilable = true },
				{ Name = "spellEnchantID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "Undress",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "UndressSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "inventorySlot", Type = "luaIndex", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(FrameAPIDressUpModel);