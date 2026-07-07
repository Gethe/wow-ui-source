local NumericRuleFormatterShared =
{
	Tables =
	{
		{
			Name = "NumericRuleFormatRounding",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Nearest", Type = "NumericRuleFormatRounding", EnumValue = 0 },
				{ Name = "Up", Type = "NumericRuleFormatRounding", EnumValue = 1 },
				{ Name = "Down", Type = "NumericRuleFormatRounding", EnumValue = 2 },
			},
		},
		{
			Name = "NumericRuleFormatBreakpoint",
			Type = "Structure",
			Fields =
			{
				{ Name = "threshold", Type = "number", Nilable = false, Documentation = { "Minimum input value that this rule applies to." } },
				{ Name = "step", Type = "number", Nilable = true, Documentation = { "If specified, the input value is rounded to multiples of this step before processing." } },
				{ Name = "rounding", Type = "NumericRuleFormatRounding", Nilable = false, Default = "Nearest", Documentation = { "If specified, the rounding mode to apply to the step." } },
				{ Name = "min", Type = "number", Nilable = true, Documentation = { "If specified, clamps the input value to this value if lesser after rounding." } },
				{ Name = "max", Type = "number", Nilable = true, Documentation = { "If specified, clamps the input value to this value if greater after rounding." } },
				{ Name = "format", Type = "string", Nilable = false, Documentation = { "The format string to apply at this threshold. If no components are specified, this can include at-most one numeric format specifier - else, should contain an equal number of format specifiers to elements in the components array." } },
				{ Name = "components", Type = "table", InnerType = "NumericRuleFormatComponent", Nilable = true, Documentation = { "Vector of component descriptions for this rule." } },
			},
		},
		{
			Name = "NumericRuleFormatComponent",
			Type = "Structure",
			Fields =
			{
				{ Name = "div", Type = "number", Nilable = true, Documentation = { "If specified, divide the value by this amount and use the resulting quotient. This is applied before modulo division." } },
				{ Name = "mod", Type = "number", Nilable = true, Documentation = { "If specified, divide the value by this amount and use the resulting remainder. This is applied after quotient division." } },
				{ Name = "step", Type = "number", Nilable = true, Documentation = { "If specified, round the value to multiples of this step. This is applied after all division." } },
				{ Name = "rounding", Type = "NumericRuleFormatRounding", Nilable = false, Default = "Nearest", Documentation = { "If specified, rounding mode to apply to the step." } },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(NumericRuleFormatterShared);