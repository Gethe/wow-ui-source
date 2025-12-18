local ParentalControls =
{
	Name = "ParentalControls",
	Type = "System",
	Environment = "All",

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