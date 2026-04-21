local SecondsFormatterAPI =
{
	Name = "SecondsFormatterAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "CanApproximate",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if the given number of seconds is within an appropriate range for approximated formatting." },

			Arguments =
			{
				{ Name = "seconds", Type = "DurationSecondsDouble", Nilable = false },
			},

			Returns =
			{
				{ Name = "canApproximate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanRoundUpIntervals",
			Type = "Function",
			Documentation = { "Returns true if the formatter can promote values to higher interval bands." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "canRound", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanRoundUpLastUnit",
			Type = "Function",
			Documentation = { "Returns true if the formatter should round the final unit up rather than down." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "canRound", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EvaluateDesiredUnitCount",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the unit count that a given number of seconds will use for formatting." },

			Arguments =
			{
				{ Name = "seconds", Type = "DurationSecondsDouble", Nilable = false },
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EvaluateMaxInterval",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the maximum interval band that a given number of seconds will use for formatting." },

			Arguments =
			{
				{ Name = "seconds", Type = "DurationSecondsDouble", Nilable = false },
			},

			Returns =
			{
				{ Name = "interval", Type = "SecondsFormatterInterval", Nilable = false },
			},
		},
		{
			Name = "EvaluateMinInterval",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the minimum interval band that a given number of seconds will use for formatting." },

			Arguments =
			{
				{ Name = "seconds", Type = "DurationSecondsDouble", Nilable = false },
			},

			Returns =
			{
				{ Name = "interval", Type = "SecondsFormatterInterval", Nilable = false },
			},
		},
		{
			Name = "Format",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Formats a number of seconds and returns the resulting string." },

			Arguments =
			{
				{ Name = "seconds", Type = "DurationSecondsDouble", Nilable = false },
				{ Name = "abbreviation", Type = "SecondsFormatterAbbrevation", Nilable = true, Documentation = { "Optional abbreviation mode to use in-place of the default." } },
			},

			Returns =
			{
				{ Name = "formattedSeconds", Type = "string", Nilable = false },
			},
		},
		{
			Name = "FormatZero",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns formatted string representing a zero second duration." },

			Arguments =
			{
				{ Name = "abbreviation", Type = "SecondsFormatterAbbrevation", Nilable = true, Documentation = { "Optional abbreviation mode to use in-place of the default." } },
			},

			Returns =
			{
				{ Name = "formattedSeconds", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetApproximationSeconds",
			Type = "Function",
			Documentation = { "Returns the threshold below which numeric values are formatted as approximated strings." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "approximationSeconds", Type = "DurationSecondsDouble", Nilable = false },
			},
		},
		{
			Name = "GetConvertToLower",
			Type = "Function",
			Documentation = { "Returns true if the formatter should lowercase all unit format strings." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "convert", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetDefaultAbbreviation",
			Type = "Function",
			Documentation = { "Returns the default abbreviation mode used for formatting." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "abbreviation", Type = "SecondsFormatterAbbrevation", Nilable = true },
			},
		},
		{
			Name = "GetDesiredUnitCount",
			Type = "Function",
			Documentation = { "Returns the desired unit count for formatting." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = true, Documentation = { "Nil if configured to use a curve." } },
			},
		},
		{
			Name = "GetDesiredUnitCountCurve",
			Type = "Function",
			Documentation = { "Returns the desired unit count curve for formatting." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "curve", Type = "LuaCurveObject", Nilable = true, Documentation = { "Nil if configured to static unit count." } },
			},
		},
		{
			Name = "GetMaxInterval",
			Type = "Function",
			Documentation = { "Returns the maximum interval band permitted for formatting." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "interval", Type = "SecondsFormatterInterval", Nilable = true, Documentation = { "Nil if configured to use a curve." } },
			},
		},
		{
			Name = "GetMaxIntervalCurve",
			Type = "Function",
			Documentation = { "Returns the maximum interval band curve permitted for formatting." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "curve", Type = "LuaCurveObject", Nilable = true, Documentation = { "Nil if configured to static interval band." } },
			},
		},
		{
			Name = "GetMillisecondsThreshold",
			Type = "Function",
			Documentation = { "Returns the threshold below which a value will be formatted as a decimal number of seconds with one place for milliseconds (eg. '3.4')" },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "threshold", Type = "DurationSecondsDouble", Nilable = false },
			},
		},
		{
			Name = "GetMinInterval",
			Type = "Function",
			Documentation = { "Returns the minimum interval band permitted for formatting." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "interval", Type = "SecondsFormatterInterval", Nilable = true, Documentation = { "Nil if configured to use a curve." } },
			},
		},
		{
			Name = "GetMinIntervalCurve",
			Type = "Function",
			Documentation = { "Returns the minimum interval band curve permitted for formatting." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "curve", Type = "LuaCurveObject", Nilable = true, Documentation = { "Nil if configured to static interval band." } },
			},
		},
		{
			Name = "GetStripIntervalWhitespace",
			Type = "Function",
			Documentation = { "Returns the whitespace stripping mode of the formatter." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "strip", Type = "SecondsFormatterIntervalWhitespace", Nilable = false },
			},
		},
		{
			Name = "Reset",
			Type = "Function",
			Documentation = { "Resets all stored configuration of the formatter." },

			Arguments =
			{
			},
		},
		{
			Name = "SetApproximationSeconds",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the formatter to render numeric values between zero and this value as approximated strings (eg. '< 1m')." },

			Arguments =
			{
				{ Name = "seconds", Type = "DurationSecondsDouble", Nilable = false },
			},
		},
		{
			Name = "SetCanRoundUpIntervals",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the formatter to promote intervals if values are large enough (eg. '60m' -> '1h')." },

			Arguments =
			{
				{ Name = "canRound", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCanRoundUpLastUnit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the formatter to round the last formatted unit up, rather than down." },

			Arguments =
			{
				{ Name = "canRound", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetConvertToLower",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the formatter to convert all interval format strings to lowercase." },

			Arguments =
			{
				{ Name = "convert", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDefaultAbbreviation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the default abbreviation mode used for formatting." },

			Arguments =
			{
				{ Name = "abbreviation", Type = "SecondsFormatterAbbrevation", Nilable = false },
			},
		},
		{
			Name = "SetDesiredUnitCount",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the desired unit count used for formatting." },

			Arguments =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetDesiredUnitCountCurve",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the desired unit count used for formatting to a curve that will be evaluated with seconds values to produce a desired unit count." },

			Arguments =
			{
				{ Name = "curve", Type = "LuaCurveObject", Nilable = false },
			},
		},
		{
			Name = "SetMaxInterval",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the maximum interval band used for formatting." },

			Arguments =
			{
				{ Name = "interval", Type = "SecondsFormatterInterval", Nilable = false },
			},
		},
		{
			Name = "SetMaxIntervalCurve",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the maximum interval band used for formatting to a curve that will be evaluated with seconds values to produce a value matching a SecondsFormatterInterval enum member." },

			Arguments =
			{
				{ Name = "curve", Type = "LuaCurveObject", Nilable = false },
			},
		},
		{
			Name = "SetMillisecondsThreshold",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the threshold below which a value will be formatted as a decimal number of seconds with one place for milliseconds (eg. '3.4')" },

			Arguments =
			{
				{ Name = "threshold", Type = "DurationSecondsDouble", Nilable = false },
			},
		},
		{
			Name = "SetMinInterval",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the minimum interval band used for formatting." },

			Arguments =
			{
				{ Name = "interval", Type = "SecondsFormatterInterval", Nilable = false },
			},
		},
		{
			Name = "SetMinIntervalCurve",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the minimum interval band used for formatting to a curve that will be evaluated with seconds values to produce a value matching a SecondsFormatterInterval enum member." },

			Arguments =
			{
				{ Name = "curve", Type = "LuaCurveObject", Nilable = false },
			},
		},
		{
			Name = "SetStripIntervalWhitespace",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the whitespace stripping mode for the formatter." },

			Arguments =
			{
				{ Name = "strip", Type = "SecondsFormatterIntervalWhitespace", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SecondsFormatterAPI);