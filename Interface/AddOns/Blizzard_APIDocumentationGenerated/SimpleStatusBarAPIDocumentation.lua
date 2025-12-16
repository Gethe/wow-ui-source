local SimpleStatusBarAPI =
{
	Name = "SimpleStatusBarAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetFillStyle",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "fillStyle", Type = "StatusBarFillStyle", Nilable = false },
			},
		},
		{
			Name = "GetInterpolatedValue",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.BarValue },
			Documentation = { "Returns the current interpolated value displayed by the bar." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMinMaxValues",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.BarValue },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "minValue", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOrientation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "orientation", Type = "Orientation", Nilable = false },
			},
		},
		{
			Name = "GetReverseFill",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isReverseFill", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetRotatesTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "rotatesTexture", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetStatusBarColor",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "colorA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetStatusBarDesaturation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "desaturation", Type = "normalizedValue", Nilable = false },
			},
		},
		{
			Name = "GetStatusBarTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
			},
		},
		{
			Name = "GetTimerDuration",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "duration", Type = "LuaDurationObject", Nilable = false },
			},
		},
		{
			Name = "GetValue",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.BarValue },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsInterpolating",
			Type = "Function",
			Documentation = { "Returns true if the status bar is currently interpolating toward a target value." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isInterpolating", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsStatusBarDesaturated",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "desaturated", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetColorFill",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
			},
		},
		{
			Name = "SetFillStyle",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "fillStyle", Type = "StatusBarFillStyle", Nilable = false },
			},
		},
		{
			Name = "SetMinMaxValues",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.BarValue },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "minValue", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
				{ Name = "interpolation", Type = "StatusBarInterpolation", Nilable = false, Default = "Immediate" },
			},
		},
		{
			Name = "SetOrientation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "orientation", Type = "Orientation", Nilable = false },
			},
		},
		{
			Name = "SetReverseFill",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isReverseFill", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetRotatesTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "rotatesTexture", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetStatusBarColor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
			},
		},
		{
			Name = "SetStatusBarDesaturated",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "desaturated", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetStatusBarDesaturation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "desaturation", Type = "normalizedValue", Nilable = false },
			},
		},
		{
			Name = "SetStatusBarTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetTimerDuration",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "duration", Type = "LuaDurationObject", Nilable = false },
				{ Name = "interpolation", Type = "StatusBarInterpolation", Nilable = false, Default = "Immediate" },
				{ Name = "direction", Type = "StatusBarTimerDirection", Nilable = false, Default = "ElapsedTime" },
			},
		},
		{
			Name = "SetToTargetValue",
			Type = "Function",
			Documentation = { "Immediately finishes any interpolation of the bar and snaps it to the target value." },

			Arguments =
			{
			},
		},
		{
			Name = "SetValue",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.BarValue },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false },
				{ Name = "interpolation", Type = "StatusBarInterpolation", Nilable = false, Default = "Immediate" },
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

APIDocumentation:AddDocumentationTable(SimpleStatusBarAPI);