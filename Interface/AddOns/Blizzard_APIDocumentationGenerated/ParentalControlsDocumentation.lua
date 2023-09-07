local ParentalControls =
{
	Name = "ParentalControls",
	Type = "System",

	Functions =
	{
		{
			Name = "GetSecondsUntilParentalControlsKick",
			Type = "Function",

			Returns =
			{
				{ Name = "remaining", Type = "number", Nilable = true },
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

APIDocumentation:AddDocumentationTable(ParentalControls);