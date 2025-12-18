local FrameAPIQuestPOI =
{
	Name = "FrameAPIQuestPOI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetNumTooltips",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "numObjectives", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTooltipIndex",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "objectiveIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UpdateMouseOverTooltip",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "numObjectives", Type = "number", Nilable = true },
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

APIDocumentation:AddDocumentationTable(FrameAPIQuestPOI);