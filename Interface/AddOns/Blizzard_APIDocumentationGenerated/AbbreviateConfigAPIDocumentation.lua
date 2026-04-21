local AbbreviateConfigAPI =
{
	Name = "AbbreviateConfigAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetAbbreviateNumberData",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "data", Type = "table", InnerType = "NumberAbbreviationBreakpoint", Nilable = false },
			},
		},
		{
			Name = "SetAbbreviateNumberData",
			Type = "Function",
			RequiresRestrictedAbbreviationBreakpoints = true,
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "data", Type = "table", InnerType = "NumberAbbreviationBreakpoint", Nilable = false },
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

APIDocumentation:AddDocumentationTable(AbbreviateConfigAPI);