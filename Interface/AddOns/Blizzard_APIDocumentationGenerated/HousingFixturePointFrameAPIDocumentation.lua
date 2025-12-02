local HousingFixturePointFrameAPI =
{
	Name = "HousingFixturePointFrameAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "HasAttachedFixture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasAttachedFixture", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSelected",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isSelected", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValid",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Select",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetUpdateCallback",
			Type = "Function",

			Arguments =
			{
				{ Name = "cb", Type = "FixturePointUpdatedCallback", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "FixturePointUpdatedCallback",
			Type = "CallbackType",
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingFixturePointFrameAPI);