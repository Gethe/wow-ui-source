local FrameAPICooldown =
{
	Name = "FrameAPICooldown",
	Type = "ScriptObject",

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

			Arguments =
			{
				{ Name = "start", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "modRate", Type = "number", Nilable = false, Default = 1 },
			},
		},
		{
			Name = "SetCooldownDuration",
			Type = "Function",

			Arguments =
			{
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "modRate", Type = "number", Nilable = false, Default = 1 },
			},
		},
		{
			Name = "SetCooldownUNIX",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "seconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCountdownFont",
			Type = "Function",

			Arguments =
			{
				{ Name = "fontName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetDrawBling",
			Type = "Function",

			Arguments =
			{
				{ Name = "drawBling", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetDrawEdge",
			Type = "Function",

			Arguments =
			{
				{ Name = "drawEdge", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetDrawSwipe",
			Type = "Function",

			Arguments =
			{
				{ Name = "drawSwipe", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetEdgeScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetEdgeTexture",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "hideNumbers", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetReverse",
			Type = "Function",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetRotation",
			Type = "Function",

			Arguments =
			{
				{ Name = "rotationRadians", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSwipeColor",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "low", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "high", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
			},
		},
		{
			Name = "SetUseCircularEdge",
			Type = "Function",

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