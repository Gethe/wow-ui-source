local AuraContainerUtil =
{
	Name = "AuraContainerUtil",
	Type = "System",
	Namespace = "C_AuraContainerUtil",
	Environment = "All",

	Functions =
	{
		{
			Name = "ProcessCustomAuraButtonBorderOptions",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "options", Type = "CustomAuraButtonBorderOptions", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "CustomAuraButtonBorderOptions", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "CustomAuraButtonBorderOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "showWhenHarmful", Type = "bool", Nilable = false, Default = true, Documentation = { "Shows the border texture for harmful auras." } },
				{ Name = "showWhenHelpful", Type = "bool", Nilable = false, Default = false, Documentation = { "Shows the border texture for helpful auras." } },
				{ Name = "showWithoutDispelType", Type = "bool", Nilable = false, Default = false, Documentation = { "Shows the border texture for auras that do not have a dispel type." } },
				{ Name = "showIcon", Type = "bool", Nilable = false, Default = true, Documentation = { "Shows a dispel type icon in the corner of the border. Only applies when using the Atlas border style." } },
				{ Name = "style", Type = "CustomAuraButtonBorderStyle", Nilable = false, Default = "Atlas", Documentation = { "The border style to use." } },
				{ Name = "customDispelColorMap", Type = "table", InnerType = "colorRGB", KeyType = "string", Nilable = true, Documentation = { "Optional map of dispel type names to custom border colors. Only applies when using the Color border style." } },
				{ Name = "customDispelColorCurve", Type = "LuaColorCurveObject", Nilable = true, Documentation = { "Optional curve used to determine border colors from the aura's dispel type. Only applies when using the Color border style." } },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(AuraContainerUtil);