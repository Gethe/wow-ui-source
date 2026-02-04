local FrameAPICooldown =
{
	Name = "FrameAPICooldown",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "Clear",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetCooldownDisplayDuration",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.Cooldown },
			Documentation = { "The returned duration unit is milliseconds, unaffected by modRate." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCooldownDuration",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.Cooldown },
			Documentation = { "The returned duration unit is milliseconds and is multiplied by the modRate." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCooldownTimes",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.Cooldown },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "start", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCountdownFontString",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "countdownString", Type = "SimpleFontString", Nilable = false },
			},
		},
		{
			Name = "GetDrawBling",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "drawBling", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetDrawEdge",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "drawEdge", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetDrawSwipe",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "drawSwipe", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetEdgeScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "edgeScale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHideCountdownNumbers",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hideNumbers", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetMinimumCountdownDuration",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "milliseconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetReverse",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "reverse", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetRotation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "rotationRadians", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUseAuraDisplayTime",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "useAuraDisplayTime", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPaused",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isPaused", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Pause",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "Resume",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetBlingTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "texture", Type = "FileAsset", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "colorA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCooldown",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.Cooldown },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "start", Type = "DurationSeconds", Nilable = false },
				{ Name = "duration", Type = "DurationSeconds", Nilable = false },
				{ Name = "modRate", Type = "number", Nilable = false, Default = 1 },
			},
		},
		{
			Name = "SetCooldownDuration",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.Cooldown },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "duration", Type = "DurationSeconds", Nilable = false },
				{ Name = "modRate", Type = "number", Nilable = false, Default = 1 },
			},
		},
		{
			Name = "SetCooldownFromDurationObject",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "duration", Type = "LuaDurationObject", Nilable = false },
				{ Name = "clearIfZero", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "SetCooldownFromExpirationTime",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.Cooldown },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "expirationTime", Type = "DurationSeconds", Nilable = false },
				{ Name = "duration", Type = "DurationSeconds", Nilable = false },
				{ Name = "modRate", Type = "number", Nilable = false, Default = 1 },
			},
		},
		{
			Name = "SetCooldownUNIX",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.Cooldown },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "start", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "modRate", Type = "number", Nilable = false, Default = 1 },
			},
		},
		{
			Name = "SetCountdownAbbrevThreshold",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "seconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCountdownFont",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "fontName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetDrawBling",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "drawBling", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetDrawEdge",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "drawEdge", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetDrawSwipe",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "drawSwipe", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetEdgeColor",
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
			Name = "SetEdgeScale",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetEdgeTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "texture", Type = "FileAsset", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "colorA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetHideCountdownNumbers",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "hideNumbers", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetMinimumCountdownDuration",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Controls the minimum duration above which countdown text will be shown. This is applied based upon the total duration of the cooldown, not the remaining duration as it ticks down." },

			Arguments =
			{
				{ Name = "milliseconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPaused",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "paused", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetReverse",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetRotation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "rotationRadians", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSwipeColor",
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
			Name = "SetSwipeTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "texture", Type = "FileAsset", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "colorA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTexCoordRange",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "low", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "high", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
			},
		},
		{
			Name = "SetUseAuraDisplayTime",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Aura durations are displayed slightly differently than cooldown durations. Setting this to true will adjust the display logic to stay in sync with aura timers." },

			Arguments =
			{
				{ Name = "useAuraDisplayTime", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetUseCircularEdge",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "useCircularEdge", Type = "bool", Nilable = false, Default = false },
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

APIDocumentation:AddDocumentationTable(FrameAPICooldown);