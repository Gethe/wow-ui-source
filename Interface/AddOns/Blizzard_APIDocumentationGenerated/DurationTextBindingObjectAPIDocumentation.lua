local DurationTextBindingObjectAPI =
{
	Name = "DurationTextBindingObjectAPI",
	Type = "ScriptObject",
	ObjectType = "Userdata",
	Environment = "All",

	Functions =
	{
		{
			Name = "CanFormatText",
			Type = "Function",
			Documentation = { "Returns true if this binding has enough configuration to produce formatted text." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "canFormatText", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanUpdateFontString",
			Type = "Function",
			Documentation = { "Returns true if this binding has enough configuration to update its font string with formatted text." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "canUpdateText", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearTextColorCurve",
			Type = "Function",
			Documentation = { "Clears the text color curve used by this binding." },

			Arguments =
			{
			},
		},
		{
			Name = "Disable",
			Type = "Function",
			Documentation = { "Disables automatic updates for this duration text binding." },

			Arguments =
			{
			},
		},
		{
			Name = "Enable",
			Type = "Function",
			Documentation = { "Enables automatic updates for this duration text binding." },

			Arguments =
			{
			},
		},
		{
			Name = "GetDuration",
			Type = "Function",
			Documentation = { "Returns the duration object used by this duration text binding." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "duration", Type = "LuaDurationObject", Nilable = true },
			},
		},
		{
			Name = "GetExpiredText",
			Type = "Function",
			Documentation = { "Returns the text shown when the duration has fully expired." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "text", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetFontString",
			Type = "Function",
			Documentation = { "Returns the font string updated by this duration text binding." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "fontString", Type = "SimpleFontString", Nilable = true },
			},
		},
		{
			Name = "GetFormattedText",
			Type = "Function",
			Documentation = { "Returns the text that would currently be assigned to the configured font string." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "text", Type = "string", Nilable = false, ConditionalSecret = true },
			},
		},
		{
			Name = "GetFormattedTextColor",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns the text color that would currently be assigned to the configured font string." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false, ConditionalSecret = true },
			},
		},
		{
			Name = "GetTextColorCurve",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns the text color curve used by this binding." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "curve", Type = "LuaColorCurveObject", Nilable = false },
				{ Name = "property", Type = "DurationTextBindingProperty", Nilable = false },
			},
		},
		{
			Name = "GetTimeModifier",
			Type = "Function",
			Documentation = { "Returns the time modifier used when sampling duration values for this binding." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false },
			},
		},
		{
			Name = "GetUpdateInterval",
			Type = "Function",
			Documentation = { "Returns the minimum number of seconds between automatic text updates. A value of zero updates every game tick." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "updateInterval", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetZeroDurationText",
			Type = "Function",
			Documentation = { "Returns the text shown when the duration is not configured, or represents a zero-duration time span." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "text", Type = "string", Nilable = true },
			},
		},
		{
			Name = "HasSecretValues",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns true if the duration text binding has been configured with any secret values." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasSecretValues", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEnabled",
			Type = "Function",
			Documentation = { "Returns true if this duration text binding updates its font string automatically." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDuration",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the duration object used by this duration text binding." },

			Arguments =
			{
				{ Name = "duration", Type = "LuaDurationObject", Nilable = false },
			},
		},
		{
			Name = "SetEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures whether this duration text binding updates its font string automatically." },

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetExpiredText",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the text shown when the duration has fully expired." },

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = true },
			},
		},
		{
			Name = "SetFontString",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the font string updated by this duration text binding." },

			Arguments =
			{
				{ Name = "fontString", Type = "SimpleFontString", Nilable = false },
			},
		},
		{
			Name = "SetFormatter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the text format used by this duration text binding to display the remaining duration using the supplied formatter." },

			Arguments =
			{
				{ Name = "formatter", Type = "NumericFormatter", Nilable = false },
			},
		},
		{
			Name = "SetTextColorCurve",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures this duration text binding to adjust fontstring text color by evaluating a duration property through a curve." },

			Arguments =
			{
				{ Name = "curve", Type = "LuaColorCurveObject", Nilable = false },
				{ Name = "property", Type = "DurationTextBindingProperty", Nilable = false },
			},
		},
		{
			Name = "SetTextFormat",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the text format used by this duration text binding. The format string may contain '{}' placeholders, each of which is substituted by the corresponding component in the supplied array." },

			Arguments =
			{
				{ Name = "format", Type = "string", Nilable = false },
				{ Name = "components", Type = "table", InnerType = "DurationTextBindingFormatComponent", Nilable = false },
			},
		},
		{
			Name = "SetTimeModifier",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the time modifier used when sampling duration values for this binding." },

			Arguments =
			{
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false },
			},
		},
		{
			Name = "SetToDefaults",
			Type = "Function",
			Documentation = { "Resets this duration text binding to its default state, clearing the configured font string, duration, format, formatter, and fallback text." },

			Arguments =
			{
			},
		},
		{
			Name = "SetUpdateInterval",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the minimum number of seconds between automatic text updates. A value of zero updates every game tick." },

			Arguments =
			{
				{ Name = "updateInterval", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetZeroDurationText",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the text shown when the duration is not configured, or represents a zero-duration time span." },

			Arguments =
			{
				{ Name = "text", Type = "string", Nilable = true },
			},
		},
		{
			Name = "UpdateFontString",
			Type = "Function",
			Documentation = { "Immediately updates the configured font string from the current duration state." },

			Arguments =
			{
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

APIDocumentation:AddDocumentationTable(DurationTextBindingObjectAPI);