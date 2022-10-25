local SimpleAnimAlphaAPI =
{
	Name = "SimpleAnimAlphaAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetFromAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "normalizedAlpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetToAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "normalizedAlpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFromAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "normalizedAlpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetToAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "normalizedAlpha", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleAnimAlphaAPI);