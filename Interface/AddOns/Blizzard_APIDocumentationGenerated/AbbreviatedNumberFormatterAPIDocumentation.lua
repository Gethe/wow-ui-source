local AbbreviatedNumberFormatterAPI =
{
	Name = "AbbreviatedNumberFormatterAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "AddBreakpoint",
			Type = "Function",
			RequiresValidAbbreviationBreakpoints = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Adds a new breakpoint to the formatter." },

			Arguments =
			{
				{ Name = "breakpoint", Type = "NumberAbbreviationBreakpoint", Nilable = false },
			},
		},
		{
			Name = "ClearBreakpoints",
			Type = "Function",
			Documentation = { "Removes all configured breakpoints from the formatter." },

			Arguments =
			{
			},
		},
		{
			Name = "Copy",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns a new copy of this formatter." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "copy", Type = "AbbreviatedNumberFormatter", Nilable = false },
			},
		},
		{
			Name = "GetBreakpoints",
			Type = "Function",
			Documentation = { "Returns a list of all configured breakpoints on this formatter." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "breakpoints", Type = "table", InnerType = "NumberAbbreviationBreakpoint", Nilable = false },
			},
		},
		{
			Name = "ResetBreakpoints",
			Type = "Function",
			Documentation = { "Removes all configured breakpoints from the formatter and replaces them with appropriate defaults for the client locale." },

			Arguments =
			{
			},
		},
		{
			Name = "SetBreakpoints",
			Type = "Function",
			RequiresValidAbbreviationBreakpoints = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Replaces all breakpoints on the formatter." },

			Arguments =
			{
				{ Name = "breakpoints", Type = "table", InnerType = "NumberAbbreviationBreakpoint", Nilable = false },
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

APIDocumentation:AddDocumentationTable(AbbreviatedNumberFormatterAPI);