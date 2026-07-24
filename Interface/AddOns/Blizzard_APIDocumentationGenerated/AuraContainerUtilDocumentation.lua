local AuraContainerUtil =
{
	Name = "AuraContainerUtil",
	Type = "System",
	Namespace = "C_AuraContainerUtil",
	Environment = "All",

	Functions =
	{
		{
			Name = "ProcessAuraTooltipBackdropOptions",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "options", Type = "AuraContainerTooltipBackdropOptions", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "AuraContainerTooltipBackdropOptions", Nilable = false },
			},
		},
		{
			Name = "ProcessAuraTooltipNineSliceOptions",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "options", Type = "AuraContainerTooltipNineSliceOptions", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "AuraContainerTooltipNineSliceOptions", Nilable = false },
			},
		},
		{
			Name = "ProcessAuraTooltipTextureSliceOptions",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "options", Type = "AuraContainerTooltipTextureSliceOptions", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "AuraContainerTooltipTextureSliceOptions", Nilable = false },
			},
		},
		{
			Name = "ProcessCustomAuraButtonApplicationBarOptions",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "options", Type = "CustomAuraButtonApplicationBarOptions", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "CustomAuraButtonApplicationBarOptions", Nilable = false },
			},
		},
		{
			Name = "ProcessCustomAuraButtonApplicationCountOptions",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "options", Type = "CustomAuraButtonApplicationCountOptions", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "CustomAuraButtonApplicationCountOptions", Nilable = false },
			},
		},
		{
			Name = "ProcessCustomAuraButtonDispelTypeTextOptions",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "options", Type = "CustomAuraButtonDispelTypeTextOptions", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "CustomAuraButtonDispelTypeTextOptions", Nilable = false },
			},
		},
		{
			Name = "ProcessCustomAuraButtonDispelTypeTextureOptions",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "options", Type = "CustomAuraButtonDispelTypeTextureOptions", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "CustomAuraButtonDispelTypeTextureOptions", Nilable = false },
			},
		},
		{
			Name = "ProcessCustomAuraButtonDurationBarOptions",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "options", Type = "CustomAuraButtonDurationBarOptions", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "CustomAuraButtonDurationBarOptions", Nilable = false },
			},
		},
		{
			Name = "ProcessCustomAuraButtonDurationTextOptions",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "options", Type = "CustomAuraButtonDurationTextOptions", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "CustomAuraButtonDurationTextOptions", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "AuraContainerTooltipAnchorOffsets",
			Type = "Structure",
			Fields =
			{
				{ Name = "left", Type = "number", Nilable = false, Default = 0 },
				{ Name = "right", Type = "number", Nilable = false, Default = 0 },
				{ Name = "top", Type = "number", Nilable = false, Default = 0 },
				{ Name = "bottom", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "AuraContainerTooltipBackdropInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "bgFile", Type = "TextureAssetDisk", Nilable = true, Documentation = { "Optional background texture asset." } },
				{ Name = "edgeFile", Type = "TextureAssetDisk", Nilable = true, Documentation = { "Optional edge texture asset." } },
				{ Name = "edgeSize", Type = "number", Nilable = true, Documentation = { "Optional edge size." } },
				{ Name = "insets", Type = "AuraContainerTooltipBackdropInsets", Nilable = true, Documentation = { "Optional backdrop insets." } },
				{ Name = "tile", Type = "bool", Nilable = true, Documentation = { "If true, tiles the background texture." } },
				{ Name = "tileEdge", Type = "bool", Nilable = true, Documentation = { "If true, tiles the edge texture." } },
				{ Name = "tileSize", Type = "number", Nilable = true, Documentation = { "Optional tile size used when tiling the background texture." } },
			},
		},
		{
			Name = "AuraContainerTooltipBackdropInsets",
			Type = "Structure",
			Fields =
			{
				{ Name = "left", Type = "number", Nilable = false, Default = 0 },
				{ Name = "right", Type = "number", Nilable = false, Default = 0 },
				{ Name = "top", Type = "number", Nilable = false, Default = 0 },
				{ Name = "bottom", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "AuraContainerTooltipBackdropOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "backdropInfo", Type = "AuraContainerTooltipBackdropInfo", Nilable = false, Documentation = { "Backdrop information used to construct the tooltip backdrop." } },
				{ Name = "borderColor", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = true, Documentation = { "Optional color applied to the backdrop border." } },
				{ Name = "centerColor", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = true, Documentation = { "Optional color applied to the backdrop background." } },
				{ Name = "anchorOffsets", Type = "AuraContainerTooltipAnchorOffsets", Nilable = true, Documentation = { "Optional offsets applied to the backdrop's TOPLEFT and BOTTOMRIGHT anchor points." } },
			},
		},
		{
			Name = "AuraContainerTooltipNineSliceOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "layoutName", Type = "cstring", Nilable = false, Documentation = { "Name of the NineSlice layout template to apply, such as 'TooltipDefaultLayout'." } },
				{ Name = "borderColor", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = true, Documentation = { "Optional color applied to the NineSlice border." } },
				{ Name = "centerColor", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = true, Documentation = { "Optional color applied to the NineSlice center region." } },
				{ Name = "anchorOffsets", Type = "AuraContainerTooltipAnchorOffsets", Nilable = true, Documentation = { "Optional offsets applied to the NineSlice's TOPLEFT and BOTTOMRIGHT anchor points." } },
			},
		},
		{
			Name = "AuraContainerTooltipTextureSliceOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "asset", Type = "TextureAssetDisk", Nilable = false, Documentation = { "Texture asset (file path or atlas name) displayed by the slice." } },
				{ Name = "sliceMargins", Type = "UITextureSliceMargins", Nilable = true, Documentation = { "Optional texture slice margins. See Texture:SetTextureSliceMargins." } },
				{ Name = "sliceMode", Type = "UITextureSliceMode", Nilable = true, Documentation = { "Optional texture slice mode. See Texture:SetTextureSliceMode." } },
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = true, Documentation = { "Optional vertex color applied to the texture." } },
				{ Name = "anchorOffsets", Type = "AuraContainerTooltipAnchorOffsets", Nilable = true, Documentation = { "Optional offsets applied to the slice's TOPLEFT and BOTTOMRIGHT anchor points." } },
				{ Name = "drawLayer", Type = "DrawLayer", Nilable = true, Documentation = { "Draw layer used when displaying the texture." } },
				{ Name = "drawLayerSublevel", Type = "number", Nilable = false, Default = 0, Documentation = { "Draw layer sublevel used when displaying the texture." } },
			},
		},
		{
			Name = "CustomAuraButtonApplicationBarOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "maxApplications", Type = "number", Nilable = false, Documentation = { "The maximum number of aura applications represented by the bar." } },
				{ Name = "interpolation", Type = "StatusBarInterpolation", Nilable = true, Documentation = { "Optional interpolation method used when updating the bar value." } },
			},
		},
		{
			Name = "CustomAuraButtonApplicationCountOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "formatter", Type = "NumericFormatter", Nilable = true, Documentation = { "Optional formatter used to display aura application counts." } },
			},
		},
		{
			Name = "CustomAuraButtonDispelTypeTextOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "showWhenHarmful", Type = "bool", Nilable = false, Default = true, Documentation = { "Shows the dispel type text for harmful auras." } },
				{ Name = "showWhenHelpful", Type = "bool", Nilable = false, Default = false, Documentation = { "Shows the dispel type text for helpful auras." } },
				{ Name = "showWithoutDispelType", Type = "bool", Nilable = false, Default = false, Documentation = { "Shows the dispel type text for auras that do not have a dispel type." } },
				{ Name = "customDispelTextMap", Type = "table", InnerType = "stringView", KeyType = "string", Nilable = true, Documentation = { "Optional map of dispel type names to custom texts. An empty key can be used for auras without a dispel type." } },
			},
		},
		{
			Name = "CustomAuraButtonDispelTypeTextureAsset",
			Type = "Structure",
			Fields =
			{
				{ Name = "asset", Type = "TextureAssetDisk", Nilable = false, Documentation = { "The texture file or atlas to use." } },
				{ Name = "useAtlasSize", Type = "bool", Nilable = false, Default = false, Documentation = { "Resizes the texture to the atlas dimensions. Ignored when asset does not name an atlas." } },
				{ Name = "texCoords", Type = "CustomAuraButtonDispelTypeTextureTexCoords", Nilable = true, Documentation = { "Optional texture coordinates used when asset does not name an atlas." } },
			},
		},
		{
			Name = "CustomAuraButtonDispelTypeTextureOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "showWhenHarmful", Type = "bool", Nilable = false, Default = true, Documentation = { "Shows the dispel type texture for harmful auras." } },
				{ Name = "showWhenHelpful", Type = "bool", Nilable = false, Default = false, Documentation = { "Shows the dispel type texture for helpful auras." } },
				{ Name = "showWithoutDispelType", Type = "bool", Nilable = false, Default = false, Documentation = { "Shows the dispel type texture for auras that do not have a dispel type." } },
				{ Name = "style", Type = "CustomAuraButtonDispelTypeTextureStyle", Nilable = false, Default = "BorderWithIcon", Documentation = { "The texture style to use." } },
				{ Name = "customDispelAssetMap", Type = "table", InnerType = "CustomAuraButtonDispelTypeTextureAsset", KeyType = "string", Nilable = true, Documentation = { "Optional map of dispel type names to custom texture assets. The \"None\" key represents auras without a dispel type. Only applies when using the CustomAsset style." } },
				{ Name = "customDispelColorMap", Type = "table", InnerType = "colorRGB", KeyType = "string", Nilable = true, Documentation = { "Optional map of dispel type names to custom vertex colors. The \"None\" key represents auras without a dispel type." } },
				{ Name = "customDispelColorCurve", Type = "LuaColorCurveObject", Nilable = true, Documentation = { "Optional curve used to determine vertex colors from the aura's dispel type." } },
			},
		},
		{
			Name = "CustomAuraButtonDispelTypeTextureTexCoords",
			Type = "Structure",
			Fields =
			{
				{ Name = "left", Type = "number", Nilable = false, Default = 0 },
				{ Name = "right", Type = "number", Nilable = false, Default = 1 },
				{ Name = "top", Type = "number", Nilable = false, Default = 0 },
				{ Name = "bottom", Type = "number", Nilable = false, Default = 1 },
			},
		},
		{
			Name = "CustomAuraButtonDurationBarOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "interpolation", Type = "StatusBarInterpolation", Nilable = true, Documentation = { "The interpolation method used when updating the duration bar." } },
				{ Name = "direction", Type = "StatusBarTimerDirection", Nilable = true, Documentation = { "The direction in which the duration bar progresses." } },
			},
		},
		{
			Name = "CustomAuraButtonDurationTextOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "binding", Type = "DurationTextBinding", Nilable = true, Documentation = { "Optional duration text binding to use. The binding is copied before being associated with the aura button." } },
				{ Name = "textFormatter", Type = "NumericFormatter", Nilable = true, Documentation = { "Optional formatter used to display remaining duration values. Ignored if textFormat is specified." } },
				{ Name = "textFormat", Type = "DurationTextBindingFormatOptions", Nilable = true, Documentation = { "Optional text format configuration applied to the duration text binding. Overrides textFormatter when specified." } },
				{ Name = "textColor", Type = "DurationTextBindingColorOptions", Nilable = true, Documentation = { "Optional text color configuration applied to the duration text binding." } },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(AuraContainerUtil);