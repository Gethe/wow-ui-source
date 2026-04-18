local NumericRuleFormatterAPI =
{
	Name = "NumericRuleFormatterAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "AddBreakpoint",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Adds a new breakpoint to the formatter." },

			Arguments =
			{
				{ Name = "breakpoint", Type = "NumericRuleFormatBreakpoint", Nilable = false },
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
				{ Name = "copy", Type = "NumericRuleFormatter", Nilable = false },
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
				{ Name = "breakpoints", Type = "table", InnerType = "NumericRuleFormatBreakpoint", Nilable = false },
			},
		},
		{
			Name = "SetBreakpoints",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Replaces all breakpoints on the formatter." },

			Arguments =
			{
				{ Name = "breakpoints", Type = "table", InnerType = "NumericRuleFormatBreakpoint", Nilable = false },
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

APIDocumentation:AddDocumentationTable(NumericRuleFormatterAPI);