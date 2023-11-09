local FrameAPITabardModelBase =
{
	Name = "FrameAPITabardModelBase",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "CanSaveTabardNow",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "canSave", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CycleVariation",
			Type = "Function",

			Arguments =
			{
				{ Name = "variationIndex", Type = "luaIndex", Nilable = false },
				{ Name = "delta", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLowerEmblemTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
			},
		},
		{
			Name = "GetUpperEmblemTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
			},
		},
		{
			Name = "InitializeTabardColors",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "IsGuildTabard",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isGuildTabard", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Save",
			Type = "Function",

			Arguments =
			{
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

APIDocumentation:AddDocumentationTable(FrameAPITabardModelBase);