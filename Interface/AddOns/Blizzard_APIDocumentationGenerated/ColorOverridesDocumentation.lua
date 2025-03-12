local ColorOverrides =
{
	Name = "ColorOverrides",
	Type = "System",
	Namespace = "C_ColorOverrides",

	Functions =
	{
		{
			Name = "ClearColorOverrides",
			Type = "Function",
		},
		{
			Name = "GetColorForQuality",
			Type = "Function",

			Arguments =
			{
				{ Name = "quality", Type = "ItemQuality", Nilable = false },
			},

			Returns =
			{
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "GetColorOverrideInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "overrideType", Type = "ColorOverride", Nilable = false },
			},

			Returns =
			{
				{ Name = "overrideInfo", Type = "ColorOverrideInfo", Nilable = true },
			},
		},
		{
			Name = "GetDefaultColorForQuality",
			Type = "Function",

			Arguments =
			{
				{ Name = "quality", Type = "ItemQuality", Nilable = false },
			},

			Returns =
			{
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "RemoveColorOverride",
			Type = "Function",

			Arguments =
			{
				{ Name = "overrideType", Type = "ColorOverride", Nilable = false },
			},
		},
		{
			Name = "SetColorOverride",
			Type = "Function",

			Arguments =
			{
				{ Name = "overrideType", Type = "ColorOverride", Nilable = false },
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ColorOverrideUpdated",
			Type = "Event",
			LiteralName = "COLOR_OVERRIDE_UPDATED",
			Payload =
			{
				{ Name = "overrideType", Type = "ColorOverride", Nilable = false },
			},
		},
		{
			Name = "ColorOverridesReset",
			Type = "Event",
			LiteralName = "COLOR_OVERRIDES_RESET",
		},
	},

	Tables =
	{
		{
			Name = "ColorOverrideInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "overrideType", Type = "ColorOverride", Nilable = false },
				{ Name = "overrideColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "overrideColorString", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ColorOverrides);