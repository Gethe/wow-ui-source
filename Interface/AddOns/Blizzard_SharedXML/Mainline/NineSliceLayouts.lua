
NineSliceLayouts =
{
	SimplePanelTemplate =
	{
		mirrorLayout = true,
		TopLeftCorner =	{ atlas = "UI-Frame-SimpleMetal-CornerTopLeft", x = -5, y = 0, },
		TopRightCorner = { atlas = "UI-Frame-SimpleMetal-CornerTopLeft", x = 2, y = 0, },
		BottomLeftCorner = { atlas = "UI-Frame-SimpleMetal-CornerTopLeft", x = -5, y = -3, },
		BottomRightCorner =	{ atlas = "UI-Frame-SimpleMetal-CornerTopLeft", x = 2, y = -3, },
		TopEdge = { atlas = "_UI-Frame-SimpleMetal-EdgeTop", },
		BottomEdge = { atlas = "_UI-Frame-SimpleMetal-EdgeTop", },
		LeftEdge = { atlas = "!UI-Frame-SimpleMetal-EdgeLeft", },
		RightEdge = { atlas = "!UI-Frame-SimpleMetal-EdgeLeft", },
	},

	PortraitFrameTemplate =
	{
		disableSharpening = true,
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-PortraitMetal-CornerTopLeft", x = -13, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopRight", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomLeft", x = -13, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer="OVERLAY", atlas = "_UI-Frame-Metal-EdgeTop", x = 0, y = 0, x1 = 0, y1 = 0, },
		BottomEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeBottom", x = 0, y = 0, x1 = 0, y1 = 0, },
		LeftEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeLeft", x = 0, y = 0, x1 = 0, y1 = 0 },
		RightEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeRight", x = 0, y = 0, x1 = 0, y1 = 0, },
	},

	PortraitFrameTemplateMinimizable =
	{
		disableSharpening = true,
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-PortraitMetal-CornerTopLeft", x = -13, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopRightDouble", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomLeft", x = -13, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer="OVERLAY", atlas = "_UI-Frame-Metal-EdgeTop", x = 0, y = 0, x1 = 0, y1 = 0, },
		BottomEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeBottom", x = 0, y = 0, x1 = 0, y1 = 0, },
		LeftEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeLeft", x = 0, y = 0, x1 = 0, y1 = 0 },
		RightEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeRight", x = 0, y = 0, x1 = 0, y1 = 0, },
	},

	ButtonFrameTemplateNoPortrait =
	{
		disableSharpening = true,
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopLeft", x = -8, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopRight", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomLeft", x = -8, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeTop", },
		BottomEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeBottom", },
		LeftEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeLeft", },
		RightEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeRight", },
	},

	ButtonFrameTemplateNoPortraitMinimizable =
	{
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopLeft", x = -12, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopRightDouble", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomLeft", x = -12, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeTop", },
		BottomEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeBottom", },
		LeftEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeLeft", },
		RightEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeRight", },
	},

	InsetFrameTemplate =
	{
		TopLeftCorner = { layer = "BORDER", subLevel = -5, atlas = "UI-Frame-InnerTopLeft", },
		TopRightCorner = { layer = "BORDER", subLevel = -5, atlas = "UI-Frame-InnerTopRight", },
		BottomLeftCorner = { layer = "BORDER", subLevel = -5, atlas = "UI-Frame-InnerBotLeftCorner", x = 0, y = -1, },
		BottomRightCorner = { layer = "BORDER", subLevel = -5, atlas = "UI-Frame-InnerBotRight", x = 0, y = -1, },
		TopEdge = { layer = "BORDER", subLevel = -5, atlas = "_UI-Frame-InnerTopTile", },
		BottomEdge = { layer = "BORDER", subLevel = -5, atlas = "_UI-Frame-InnerBotTile", },
		LeftEdge = { layer = "BORDER", subLevel = -5, atlas = "!UI-Frame-InnerLeftTile", },
		RightEdge = { layer = "BORDER", subLevel = -5, atlas = "!UI-Frame-InnerRightTile", },
	},

	BFAMissionHorde =
	{
		mirrorLayout = true,
		TopLeftCorner =	{ atlas = "HordeFrame-Corner-TopLeft", x = -6, y = 6, },
		TopRightCorner =	{ atlas = "HordeFrame-Corner-TopLeft", x = 6, y = 6, },
		BottomLeftCorner =	{ atlas = "HordeFrame-Corner-TopLeft", x = -6, y = -6, },
		BottomRightCorner =	{ atlas = "HordeFrame-Corner-TopLeft", x = 6, y = -6, },
		TopEdge = { atlas = "_HordeFrameTile-Top", },
		BottomEdge = { atlas = "_HordeFrameTile-Top", },
		LeftEdge = { atlas = "!HordeFrameTile-Left", },
		RightEdge = { atlas = "!HordeFrameTile-Left", },
	},

	BFAMissionAlliance =
	{
		mirrorLayout = true,
		TopLeftCorner =	{ atlas = "AllianceFrameCorner-TopLeft", x = -6, y = 6, },
		TopRightCorner =	{ atlas = "AllianceFrameCorner-TopLeft", x = 6, y = 6, },
		BottomLeftCorner =	{ atlas = "AllianceFrameCorner-TopLeft", x = -6, y = -6, },
		BottomRightCorner =	{ atlas = "AllianceFrameCorner-TopLeft", x = 6, y = -6, },
		TopEdge = { atlas = "_AllianceFrameTile-Top", },
		BottomEdge = { atlas = "_AllianceFrameTile-Top", },
		LeftEdge = { atlas = "!AllianceFrameTile-Left", },
		RightEdge = { atlas = "!AllianceFrameTile-Left", },
	},

	CovenantMissionFrame =
	{
		mirrorLayout = true,
		TopLeftCorner =	{ atlas = "Oribos-NineSlice-CornerTopLeft", x = -6, y = 6, },
		TopRightCorner =	{ atlas = "Oribos-NineSlice-CornerTopLeft", x = 6, y = 6, },
		BottomLeftCorner =	{ atlas = "Oribos-NineSlice-CornerTopLeft", x = -6, y = -6, },
		BottomRightCorner =	{ atlas = "Oribos-NineSlice-CornerTopLeft", x = 6, y = -6, },
		TopEdge = { atlas = "_Oribos-NineSlice-EdgeTop", },
		BottomEdge = { atlas = "_Oribos-NineSlice-EdgeTop", },
		LeftEdge = { atlas = "!Oribos-NineSlice-EdgeLeft", },
		RightEdge = { atlas = "!Oribos-NineSlice-EdgeLeft", },
	},

	DragonflightMissionFrame =
	{
		mirrorLayout = false,
		TopLeftCorner =		{ atlas = "Dragonflight-NineSlice-CornerTopLeft", x = -6, y = 6, },
		TopRightCorner =	{ atlas = "Dragonflight-NineSlice-CornerTopRight", x = 6, y = 6, },
		BottomLeftCorner =	{ atlas = "Dragonflight-NineSlice-CornerBottomLeft", x = -6, y = -6, },
		BottomRightCorner =	{ atlas = "Dragonflight-NineSlice-CornerBottomRight", x = 6, y = -6, },
		TopEdge = { atlas = "_dragonflight-nineslice-edgetop", },
		BottomEdge = { atlas = "_dragonflight-nineslice-edgebottom", },
		LeftEdge = { atlas = "!Dragonflight-NineSlice-EdgeLeft", },
		RightEdge = { atlas = "!Dragonflight-NineSlice-EdgeRight", },
	},

	GenericMetal =
	{
		TopLeftCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = -6, y = 6, mirrorLayout = true, },
		TopRightCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = 6, y = 6, mirrorLayout = true, },
		BottomLeftCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = -6, y = -6, mirrorLayout = true, },
		BottomRightCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = 6, y = -6, mirrorLayout = true, },
		TopEdge = { atlas = "_UI-Frame-GenericMetal-EdgeTop", },
		BottomEdge = { atlas = "_UI-Frame-GenericMetal-EdgeBottom", },
		LeftEdge = { atlas = "!UI-Frame-GenericMetal-EdgeLeft", },
		RightEdge = { atlas = "!UI-Frame-GenericMetal-EdgeRight", },
	},

	Dialog =
	{
		TopLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopLeft", },
		TopRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopRight", },
		BottomLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomLeft", },
		BottomRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomRight", },
		TopEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeTop", },
		BottomEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeBottom", },
		LeftEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeLeft", },
		RightEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeRight", },
	},

	WoodenNeutralFrameTemplate =
	{
		mirrorLayout = true,
		TopLeftCorner =	{ atlas = "Neutral-NineSlice-Corner", x = -6, y = 6, },
		TopRightCorner =	{ atlas = "Neutral-NineSlice-Corner", x = 6, y = 6, },
		BottomLeftCorner =	{ atlas = "Neutral-NineSlice-Corner", x = -6, y = -6, },
		BottomRightCorner =	{ atlas = "Neutral-NineSlice-Corner", x = 6, y = -6, },
		TopEdge = { atlas = "_Neutral-NineSlice-EdgeTop", },
		BottomEdge = { atlas = "_Neutral-NineSlice-EdgeBottom", mirrorLayout = false, },
		LeftEdge = { atlas = "!Neutral-NineSlice-EdgeLeft", },
		RightEdge = { atlas = "!Neutral-NineSlice-EdgeRight", mirrorLayout = false, },
	},

	Runeforge =
	{
		TopLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopLeft", },
		TopRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopRight", },
		BottomLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomLeft", },
		BottomRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomRight", },
		TopEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeTop", },
		BottomEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeBottom", },
		LeftEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeLeft", },
		RightEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeRight", },
	},

	AdventuresMissionComplete =
	{
		TopLeftCorner =	{ atlas = "AdventuresFrame-Corner-Small-TopLeft", mirrorLayout = true, },
		TopRightCorner =	{ atlas = "AdventuresFrame-Corner-Small-TopLeft", mirrorLayout = true, },
		BottomLeftCorner =	{ atlas = "AdventuresFrame-Corner-Small-TopLeft", mirrorLayout = true, },
		BottomRightCorner =	{ atlas = "AdventuresFrame-Corner-Small-TopLeft", mirrorLayout = true, },
		TopEdge = { layer = "BACKGROUND", atlas = "_AdventuresFrame-Small-Top", x = -10, y = 3, x1 = 10, y1 = 3, },
		BottomEdge = { layer = "BACKGROUND", atlas = "_AdventuresFrame-Small-Top", x = -10, y = -3, x1 = 10, y1 = -3, mirrorLayout = true, },
		LeftEdge = { layer = "BACKGROUND", atlas = "!AdventuresFrame-Right", x = -3, y = 10, x1 = -3, y1 = -10,},
		RightEdge = { layer = "BACKGROUND", atlas = "!AdventuresFrame-Left", x = 3, y = 10, x1 = 3, y1 = -10,},
	},

	CharacterCreateDropdown =
	{
		TopLeftCorner =	{ atlas = "CharacterCreateDropdown-NineSlice-CornerTopLeft", x=-30, y=20 },
		TopRightCorner =	{ atlas = "CharacterCreateDropdown-NineSlice-CornerTopRight", x=30, y=20 },
		BottomLeftCorner =	{ atlas = "CharacterCreateDropdown-NineSlice-CornerBottomLeft", x=-30, y=-20 },
		BottomRightCorner =	{ atlas = "CharacterCreateDropdown-NineSlice-CornerBottomRight", x=30, y=-20 },
		TopEdge = { atlas = "_CharacterCreateDropdown-NineSlice-EdgeTop", },
		BottomEdge = { atlas = "_CharacterCreateDropdown-NineSlice-EdgeBottom", },
		LeftEdge = { atlas = "!CharacterCreateDropdown-NineSlice-EdgeLeft", },
		RightEdge = { atlas = "!CharacterCreateDropdown-NineSlice-EdgeRight", },
		Center = { atlas = "CharacterCreateDropdown-NineSlice-Center", },
	},

	ChatBubble =
	{
		TopLeftCorner =	{ atlas = "ChatBubble-NineSlice-CornerTopLeft", },
		TopRightCorner =	{ atlas = "ChatBubble-NineSlice-CornerTopRight", },
		BottomLeftCorner =	{ atlas = "ChatBubble-NineSlice-CornerBottomLeft", },
		BottomRightCorner =	{ atlas = "ChatBubble-NineSlice-CornerBottomRight", },
		TopEdge = { atlas = "_ChatBubble-NineSlice-EdgeTop", },
		BottomEdge = { atlas = "_ChatBubble-NineSlice-EdgeBottom", },
		LeftEdge = { atlas = "!ChatBubble-NineSlice-EdgeLeft", },
		RightEdge = { atlas = "!ChatBubble-NineSlice-EdgeRight", },
		Center = { atlas = "ChatBubble-NineSlice-Center", },
	},

	SelectionFrameTemplate =
	{
		TopLeftCorner =	{ atlas = "macropopup-topleft", },
		TopRightCorner =	{ atlas = "macropopup-topright", },
		BottomLeftCorner =	{ atlas = "macropopup-bottomleft", },
		BottomRightCorner =	{ atlas = "macropopup-bottomright", },
		TopEdge = { atlas = "_macropopup-top", },
		BottomEdge = { atlas = "_macropopup-bottom", },
		LeftEdge = { atlas = "!macropopup-left", },
		RightEdge = { atlas = "!macropopup-right", },
	},

	GMChatRequest =
	{
		["TopRightCorner"] = { atlas = "GMChat-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "GMChat-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "GMChat-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "GMChat-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_GMChat-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_GMChat-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!GMChat-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!GMChat-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-NineSlice-Center", x = -4, y = 4, x1 = 4, y1 = -4 },
	};

	TooltipDefaultLayout =
	{
		["TopRightCorner"] = { atlas = "Tooltip-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "Tooltip-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "Tooltip-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "Tooltip-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_Tooltip-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_Tooltip-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!Tooltip-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!Tooltip-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-NineSlice-Center", x = -4, y = 4, x1 = 4, y1 = -4 },
	};

	TooltipDefaultDarkLayout =
	{
		["TopRightCorner"] = { atlas = "Tooltip-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "Tooltip-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "Tooltip-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "Tooltip-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_Tooltip-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_Tooltip-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!Tooltip-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!Tooltip-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-Azerite-NineSlice-Center", x = -4, y = 4, x1 = 4, y1 = -4 },
	};

	TooltipAzeriteLayout =
	{
		["TopRightCorner"] = { atlas = "Tooltip-Azerite-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "Tooltip-Azerite-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "Tooltip-Azerite-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "Tooltip-Azerite-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_Tooltip-Azerite-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_Tooltip-Azerite-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!Tooltip-Azerite-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!Tooltip-Azerite-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-Azerite-NineSlice-Center", x = -18, y = 18, x1 = 18, y1 = -18, },
	};

	TooltipCorruptedLayout =
	{
		["TopRightCorner"] = { atlas = "Tooltip-Corrupted-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "Tooltip-Corrupted-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "Tooltip-Corrupted-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "Tooltip-Corrupted-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_Tooltip-Corrupted-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_Tooltip-Corrupted-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!Tooltip-Corrupted-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!Tooltip-Corrupted-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-Corrupted-NineSlice-Center", x = -18, y = 18, x1 = 18, y1 = -18, },
	};

	TooltipMawLayout =
	{
		["TopRightCorner"] = { atlas = "Tooltip-Maw-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "Tooltip-Maw-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "Tooltip-Maw-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "Tooltip-Maw-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_Tooltip-Maw-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_Tooltip-Maw-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!Tooltip-Maw-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!Tooltip-Maw-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-Maw-NineSlice-Center", x = -24, y = 24, x1 = 24, y1 = -24, },
	};

	TooltipGluesLayout =
	{
		["TopRightCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_Tooltip-Glues-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_Tooltip-Glues-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!Tooltip-Glues-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!Tooltip-Glues-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-Glues-NineSlice-Center", x = -8, y = 10, x1 = 8, y1 = -7, },
	};

	DarkmoonBasicSmallContainerLayout =
	{
		["TopRightCorner"] = { atlas = "DarkmoonBasicSmallContainer-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "DarkmoonBasicSmallContainer-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "DarkmoonBasicSmallContainer-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "DarkmoonBasicSmallContainer-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_DarkmoonBasicSmallContainer-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_DarkmoonBasicSmallContainer-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!DarkmoonBasicSmallContainer-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!DarkmoonBasicSmallContainer-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "DarkmoonBasicSmallContainer-NineSlice-Center", x = -56, y = 59, x1 = 56, y1 = -59, },
	};

	TooltipMixedLayout =
	{
		["TopRightCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "Tooltip-Glues-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_Tooltip-Glues-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_Tooltip-Glues-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!Tooltip-Glues-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!Tooltip-Glues-NineSlice-EdgeRight" },
		["Center"] = { layer = "BACKGROUND", atlas = "Tooltip-NineSlice-Center", x = -8, y = 10, x1 = 8, y1 = -7, },
	};

	HeldBagLayout =
	{
		disableSharpening = true,
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "ui-frame-portraitmetal-cornertopleftsmall", x = -13, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopRight", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomLeft", x = -13, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer="OVERLAY", atlas = "_UI-Frame-Metal-EdgeTop", x = 0, y = 0, x1 = 0, y1 = 0, },
		BottomEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeBottom", x = 0, y = 0, x1 = 0, y1 = 0, },
		LeftEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeLeft", x = 0, y = 0, x1 = 0, y1 = 0 },
		RightEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeRight", x = 0, y = 0, x1 = 0, y1 = 0, },
	};

	IdenticalCornersLayoutNoCenter =
	{
		["TopRightCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, },
		["TopLeftCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true,},
		["BottomLeftCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, },
		["BottomRightCorner"] = { atlas = "%s-NineSlice-Corner",  mirrorLayout = true,},
		["TopEdge"] = { atlas = "_%s-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_%s-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!%s-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!%s-NineSlice-EdgeRight" },
	};

	IdenticalCornersLayout =
	{
		["TopRightCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, },
		["TopLeftCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true,},
		["BottomLeftCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, },
		["BottomRightCorner"] = { atlas = "%s-NineSlice-Corner",  mirrorLayout = true,},
		["TopEdge"] = { atlas = "_%s-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_%s-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!%s-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!%s-NineSlice-EdgeRight" },
		["Center"] = { atlas = "%s-NineSlice-Center" },
	};

	UniqueCornersLayout =
	{
		["TopRightCorner"] = { atlas = "%s-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "%s-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "%s-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "%s-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_%s-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_%s-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!%s-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!%s-NineSlice-EdgeRight" },
		["Center"] = { atlas = "%s-NineSlice-Center" },
	};

	PerksProgramProductsPanelTemplate =
	{
		TopLeftCorner =	{ atlas = "Perks-List-NineSlice-CornerTopLeft", x=-31, y=31},
		TopRightCorner = { atlas = "Perks-List-NineSlice-CornerTopLeft", mirrorLayout = true, x=31, y=31 },
		BottomLeftCorner = { atlas = "Perks-List-NineSlice-CornerTopLeft", mirrorLayout = true, x=-31, y=-31 },
		BottomRightCorner =	{ atlas = "Perks-List-NineSlice-CornerTopLeft", mirrorLayout = true, x=31, y=-31 },
		TopEdge = { atlas = "_Perks-List-NineSlice-EdgeTop" },
		BottomEdge = { atlas = "_Perks-List-NineSlice-EdgeTop", mirrorLayout = true},
		LeftEdge = { atlas = "!Perks-List-NineSlice-EdgeLeft" },
		RightEdge = { atlas = "!Perks-List-NineSlice-EdgeLeft", mirrorLayout = true},
		Center = { atlas = "Perks-List-NineSlice-Center" },
	},

	PerksProgramHoldPanelTemplate =
	{
		TopLeftCorner =	{ atlas = "Perks-Hold-NineSlice-CornerTopLeft" },
		TopRightCorner = { atlas = "Perks-Hold-NineSlice-CornerTopLeft", mirrorLayout = true },
		BottomLeftCorner = { atlas = "Perks-Hold-NineSlice-CornerBottomLeft" },
		BottomRightCorner =	{ atlas = "Perks-Hold-NineSlice-CornerBottomRight"},
		TopEdge = { atlas = "_Perks-Hold-NineSlice-EdgeTop", },
		BottomEdge = { atlas = "_Perks-Hold-NineSlice-EdgeTop", mirrorLayout = true,},
		LeftEdge = { atlas = "!Perks-Hold-NineSlice-EdgeLeft", },
		RightEdge = { atlas = "!Perks-Hold-NineSlice-EdgeLeft", mirrorLayout = true,},
		Center = { atlas = "Perks-Hold-NineSlice-Center", },
	},

	BankTabSettingsMenuLayout =
	{
		TopLeftCorner =	{ atlas = "macropopup-topleft2", },
		TopRightCorner =	{ atlas = "macropopup-topright2", },
		BottomLeftCorner =	{ atlas = "macropopup-bottomleft", },
		BottomRightCorner =	{ atlas = "macropopup-bottomright", },
		TopEdge = { atlas = "_macropopup-top2", },
		BottomEdge = { atlas = "_macropopup-bottom", },
		LeftEdge = { atlas = "!macropopup-left2", },
		RightEdge = { atlas = "!macropopup-right2", },
	},

	ThreeSliceVerticalLayout =
	{
		threeSliceVertical = true,
		["TopEdge"] = { atlas = "%s-ThreeSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "%s-ThreeSlice-EdgeBottom" },
		["Center"] = { atlas = "!%s-ThreeSlice-Center" },
	};

	ThreeSliceHorizontalLayout =
	{
		threeSliceHorizontal = true,
		["LeftEdge"] = { atlas = "%s-ThreeSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "%s-ThreeSlice-EdgeRight" },
		["Center"] = { atlas = "_%s-ThreeSlice-Center" },
	};
};