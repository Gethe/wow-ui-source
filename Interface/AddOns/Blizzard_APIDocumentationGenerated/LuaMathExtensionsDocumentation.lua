local LuaMathExtensions =
{
	Name = "LuaMathExtensions",
	Type = "System",
	Namespace = "math",
	Environment = "All",

	Functions =
	{
		{
			Name = "clamp",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Clamps a value to the inclusive range defined by the minimum and maximum values." },

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false, Documentation = { "The value to clamp." } },
				{ Name = "minimum", Type = "number", Nilable = false, Documentation = { "The inclusive lower bound." } },
				{ Name = "maximum", Type = "number", Nilable = false, Documentation = { "The inclusive upper bound." } },
			},

			Returns =
			{
				{ Name = "clampedValue", Type = "number", Nilable = false, Documentation = { "The clamped value." } },
			},
		},
		{
			Name = "isfinite",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns whether a value is finite." },

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false, Documentation = { "The value to inspect." } },
			},

			Returns =
			{
				{ Name = "finite", Type = "bool", Nilable = false, Documentation = { "True if the value is neither infinite nor NaN; otherwise false." } },
			},
		},
		{
			Name = "isinf",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns whether a value is positive or negative infinity." },

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false, Documentation = { "The value to inspect." } },
			},

			Returns =
			{
				{ Name = "infinite", Type = "bool", Nilable = false, Documentation = { "True if the value is positive or negative infinity; otherwise false." } },
			},
		},
		{
			Name = "isnan",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns whether a value is NaN." },

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false, Documentation = { "The value to inspect." } },
			},

			Returns =
			{
				{ Name = "nan", Type = "bool", Nilable = false, Documentation = { "True if the value is NaN; otherwise false." } },
			},
		},
		{
			Name = "lerp",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Linearly interpolates between two values." },

			Arguments =
			{
				{ Name = "startValue", Type = "number", Nilable = false, Documentation = { "The value returned when the interpolation amount is 0." } },
				{ Name = "endValue", Type = "number", Nilable = false, Documentation = { "The value returned when the interpolation amount is 1." } },
				{ Name = "amount", Type = "number", Nilable = false, Documentation = { "The interpolation amount. Values outside [0, 1] extrapolate beyond the two values." } },
			},

			Returns =
			{
				{ Name = "interpolatedValue", Type = "number", Nilable = false, Documentation = { "The interpolated value." } },
			},
		},
		{
			Name = "normalize",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the relative position of a value within a range, where the minimum maps to 0 and the maximum maps to 1." },

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false, Documentation = { "The value to normalize." } },
				{ Name = "minimum", Type = "number", Nilable = false, Documentation = { "The value that maps to 0." } },
				{ Name = "maximum", Type = "number", Nilable = false, Documentation = { "The value that maps to 1." } },
			},

			Returns =
			{
				{ Name = "normalizedValue", Type = "number", Nilable = false, Documentation = { "The normalized value. Values outside the input range produce results outside [0, 1]." } },
			},
		},
		{
			Name = "remap",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Maps a value from one range to the corresponding position in another range." },

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false, Documentation = { "The value to map." } },
				{ Name = "sourceMinimum", Type = "number", Nilable = false, Documentation = { "The lower endpoint of the source range." } },
				{ Name = "sourceMaximum", Type = "number", Nilable = false, Documentation = { "The upper endpoint of the source range." } },
				{ Name = "destinationMinimum", Type = "number", Nilable = false, Documentation = { "The lower endpoint of the destination range." } },
				{ Name = "destinationMaximum", Type = "number", Nilable = false, Documentation = { "The upper endpoint of the destination range." } },
			},

			Returns =
			{
				{ Name = "remappedValue", Type = "number", Nilable = false, Documentation = { "The mapped value. Values outside the source range are extrapolated beyond the destination range." } },
			},
		},
		{
			Name = "round",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Rounds a value to the specified number of decimal places, with halfway values rounded away from zero." },

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false, Documentation = { "The value to round." } },
				{ Name = "decimalPlaces", Type = "number", Nilable = false, Default = 0, Documentation = { "The number of decimal places to preserve. Negative values round to positions left of the decimal point." } },
			},

			Returns =
			{
				{ Name = "roundedValue", Type = "number", Nilable = false, Documentation = { "The rounded value." } },
			},
		},
		{
			Name = "saturate",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Clamps a value to the inclusive range [0, 1]." },

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false, Documentation = { "The value to clamp." } },
			},

			Returns =
			{
				{ Name = "saturatedValue", Type = "number", Nilable = false, Documentation = { "The value clamped to the inclusive range [0, 1]." } },
			},
		},
		{
			Name = "sign",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns -1 for negative values, 0 for zero, and 1 for positive values." },

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false, Documentation = { "The value whose sign will be returned." } },
			},

			Returns =
			{
				{ Name = "sign", Type = "number", Nilable = false, Documentation = { "The sign of the value." } },
			},
		},
		{
			Name = "wrap",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Wraps a value into the half-open range [minimum, maximum)." },

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false, Documentation = { "The value to wrap." } },
				{ Name = "minimum", Type = "number", Nilable = false, Documentation = { "The inclusive lower bound of the range." } },
				{ Name = "maximum", Type = "number", Nilable = false, Documentation = { "The exclusive upper bound of the range." } },
			},

			Returns =
			{
				{ Name = "wrapped", Type = "number", Nilable = false, Documentation = { "The wrapped value, greater than or equal to minimum and less than maximum. If minimum equals maximum, returns minimum." } },
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

APIDocumentation:AddDocumentationTable(LuaMathExtensions);