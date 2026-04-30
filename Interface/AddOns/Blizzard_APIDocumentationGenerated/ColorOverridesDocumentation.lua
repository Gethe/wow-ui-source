local ColorOverrides =
{
	Name = "ColorOverrides",
	Type = "System",
	Namespace = "C_ColorOverrides",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ColorOverrideUpdated",
			Type = "Event",
			LiteralName = "COLOR_OVERRIDE_UPDATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "overrideType", Type = "ColorOverride", Nilable = false },
			},
		},
		{
			Name = "ColorOverridesReset",
			Type = "Event",
			LiteralName = "COLOR_OVERRIDES_RESET",
			SynchronousEvent = true,
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
				{ Name = "overrideColor", Type = "colorRGB", Nilable = false },
				{ Name = "overrideColorString", Type = "string", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(ColorOverrides);