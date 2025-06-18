local ColorOverrides =
{
	Name = "ColorOverrides",
	Type = "System",
	Namespace = "C_ColorOverrides",

	Functions =
	{
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