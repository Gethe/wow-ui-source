
local TemplatesByEdgeVisualStyle = {
	[Enum.TraitEdgeVisualStyle.Straight] = "TalentEdgeArrowTemplate",
};

local GenericTraitFrameLayoutOptions = {
	-- Note: It might be a good idea to have a more generic style in the future but for
	-- now we're just going to use what we have.
	Default = {
		NineSliceTextureKit = "thewarwithin",
		NineSliceFormatString = "ui-frame-%s-border",
		TitleDividerAtlas = "dragonriding-talents-line",
		TitleDividerShown = true,
		BackgroundAtlas = "ui-frame-thewarwithin-backgroundtile",
		HeaderSize = { Width = 500, Height = 50 },
		FrameSize = { Width = 650, Height = 750 },
		ShowInset = false,
		HeaderOffset = { x = 0, y = -30 },
		CurrencyOffset = { x = 0, y = -20 },
		CurrencyBackgroundAtlas = "dragonriding-talents-currencybg",
		PanOffset = { x = 0, y = 0 },
		ButtonPurchaseFXIDs = { 150, 142, 143 },
		CloseButtonOffset = { x = -9, y = -9 },
		PanelArea = "left",
	},

	Dragonflight = {
		NineSliceTextureKit = "Dragonflight",
		DetailTopAtlas = "dragonflight-golddetailtop",
		BackgroundAtlas = "dragonriding-talents-background",
		HeaderSize = { Width = 500, Height = 130 },
		PanOffset = { x = -80, y = -35 },
		CloseButtonOffset = { x = -3, y = -10 },
		UseOldNineSlice = true,
	},

	Skyriding = {
		NineSliceLayoutName = "ButtonFrameTemplateNoPortraitLessPadding",
		BackgroundAtlas = "ui-frame-dragonflight-backgroundtile",
		Title = GENERIC_TRAIT_FRAME_DRAGONRIDING_TITLE,
		HeaderSize = { Width = 350, Height = 50 },
		PanOffset = { x = 20, y = -50 },
		FrameSize = { Width = 450, Height = 450 },
		CloseButtonOffset = { x = 3, y = 6 },
		UseOldNineSlice = true,
	},

	TheWeaver = {
		Title = GENERIC_TRAIT_FRAME_THE_WEAVER_TITLE,
	},

	TheGeneral = {
		Title = GENERIC_TRAIT_FRAME_THE_GENERAL_TITLE,
	},

	TheVizier = {
		Title = GENERIC_TRAIT_FRAME_THE_VIZIER_TITLE,
	},

	DRIVE = {
		NineSliceFormatString = "ui-frame-%s-border-small",
		Title = GENERIC_TRAIT_FRAME_DRIVE_TITLE,
		HeaderSize = { Width = 250, Height = 50 },
		PanOffset = { x = 140, y = -35 },
		FrameSize = { Width = 350, Height = 575 },
	},

	Visions = {
		Title = GENERIC_TRAIT_FRAME_VISIONS_TITLE,
		BackgroundAtlas = "talenttree-horrificvision-background",
	},

	TitanConsole = {
		Title = GENERIC_TRAIT_FRAME_TITAN_CONSOLE_TITLE,
		TitleDividerShown = false,
		BackgroundAtlas = "talenttree-titanconsole-background",
		HeaderSize = { Width = 430, Height = 50 },
		FrameSize = { Width = 580, Height = 940 },
		HeaderOffset = { x = 0, y = -37 },
		CurrencyOffset = { x = 40, y = -14 },
		PanOffset = { x = 12, y = -15 },
	},

	ReshiiWraps = {
		Title = GENERIC_TRAIT_FRAME_RESHII_WRAPS_TITLE,
	},
};

local GenericTraitFrameLayouts = {
	-- Add custom layouts in here

	-- Skyriding
	[672] = GenericTraitFrameLayoutOptions.Skyriding,

	-- Pact: The Weaver
	[1042] = GenericTraitFrameLayoutOptions.TheWeaver,

	-- Pact: The General
	[1045] = GenericTraitFrameLayoutOptions.TheGeneral,

	-- Pact: The Vizier
	[1046] = GenericTraitFrameLayoutOptions.TheVizier,

	-- D.R.I.V.E
	[1056] = GenericTraitFrameLayoutOptions.DRIVE,

	-- Visions
	[1057] = GenericTraitFrameLayoutOptions.Visions,

	-- Titan Console (OC Delve)
	[1061] = GenericTraitFrameLayoutOptions.TitanConsole,

	-- Reshii Wraps (11.2.0 Cloak)
	[1115] = GenericTraitFrameLayoutOptions.ReshiiWraps,
};

local GenericTraitFrameTutorials = {
	-- Dragonriding TreeID
	--[[ This tutorial is no longer needed or correct but keeping it here as an example of usage.
	[672] = {
		tutorial = {
			text = DRAGON_RIDING_SKILLS_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_DRAGON_RIDING_SKILLS,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			useParentStrata = false,
		},
	},
	]]
};

local GenericTraitCurrencyTutorials = {
	-- Dragonriding
	[2563] = {
		tutorial = {
			text = DRAGON_RIDING_CURRENCY_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_DRAGON_RIDING_GLYPHS,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			useParentStrata = true,
		},
	},
};

GenericTraitUtil = {};

function GenericTraitUtil.GetEdgeTemplateType(edgeVisualStyle)
	return TemplatesByEdgeVisualStyle[edgeVisualStyle];
end

function GenericTraitUtil.GetFrameLayoutInfo(treeID)
	local layoutInfo = GenericTraitFrameLayouts[treeID] or {};
	return setmetatable(layoutInfo, {__index = GenericTraitFrameLayoutOptions.Default});
end

function GenericTraitUtil.AddFrameLayoutInfo(treeID, frameLayoutInfo)
	GenericTraitFrameLayouts[treeID] = frameLayoutInfo;
end

function GenericTraitUtil.GetFrameTutorialInfo(treeID)
	return GenericTraitFrameTutorials[treeID];
end

function GenericTraitUtil.GetCurrencyTutorialInfo(treeID)
	return GenericTraitCurrencyTutorials[treeID];
end
