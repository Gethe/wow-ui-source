local Build =
{
	Name = "Build",
	Type = "System",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetBuildOption",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSet", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "IsBetaBuild",
			Type = "Function",

			Returns =
			{
				{ Name = "isBetaBuild", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsDebugBuild",
			Type = "Function",

			Returns =
			{
				{ Name = "isDebugBuild", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPublicTestClient",
			Type = "Function",
			Documentation = { "Reflects the state of the OnlyBetaAndPTR TOC directive" },

			Returns =
			{
				{ Name = "isPublicTestClient", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(Build);