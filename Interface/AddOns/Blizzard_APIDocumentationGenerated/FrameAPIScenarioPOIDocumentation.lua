local FrameAPIScenarioPOI =
{
	Name = "FrameAPIScenarioPOI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetScenarioTooltipText",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "tooltipText", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "UpdateMouseOverTooltip",
			Type = "Function",

			Arguments =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasTooltip", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(FrameAPIScenarioPOI);