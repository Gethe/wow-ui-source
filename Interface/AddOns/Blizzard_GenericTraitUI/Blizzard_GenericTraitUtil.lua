
local TemplatesByEdgeVisualStyle = {
	[Enum.TraitEdgeVisualStyle.Straight] = "TalentEdgeArrowTemplate",
};

local GenericTraitFrameLayoutOptions = {
	-- Note: It might be a good idea to have a more generic style in the future but for
	-- now we're just going to use what we have.
	Default = {
		NineSliceTextureKit = "midnight",
		NineSliceFormatString = "ui-frame-%s-border",
		TitleDividerAtlas = "dragonriding-talents-line",
		TitleDividerShown = true,
		BackgroundAtlas = "ui-frame-midnight-backgroundtile",
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
		HideCurrencyDisplay = false,
	},

	Skyriding = {
		NineSliceLayoutName = "ButtonFrameTemplateNoPortraitLessPadding",
		BackgroundAtlas = "ui-frame-dragonflight-backgroundtile",
		HeaderSize = { Width = 350, Height = 50 },
		PanOffset = { x = 20, y = -50 },
		FrameSize = { Width = 450, Height = 450 },
		CloseButtonOffset = { x = 3, y = 6 },
		UseOldNineSlice = true,
	},

	DRIVE = {
		NineSliceFormatString = "ui-frame-%s-border-small",
		HeaderSize = { Width = 250, Height = 50 },
		PanOffset = { x = 140, y = -35 },
		FrameSize = { Width = 350, Height = 575 },
	},

	Visions = {
		BackgroundAtlas = "talenttree-horrificvision-background",
	},

	TitanConsole = {
		TitleDividerShown = false,
		BackgroundAtlas = "talenttree-titanconsole-background",
		HeaderSize = { Width = 430, Height = 50 },
		FrameSize = { Width = 580, Height = 940 },
		HeaderOffset = { x = 0, y = -37 },
		CurrencyOffset = { x = 40, y = -14 },
		PanOffset = { x = 12, y = -15 },
	},

	ZulAmanLoaBlessing = {
		HideCurrencyDisplay = true,
		SuppressSubTreeConfirmation = true,
	},
};

local GenericTraitFrameLayouts = {
	-- Add custom layouts in here

	-- Skyriding
	[672] = GenericTraitFrameLayoutOptions.Skyriding,

	-- D.R.I.V.E
	[1056] = GenericTraitFrameLayoutOptions.DRIVE,

	-- Visions
	[1057] = GenericTraitFrameLayoutOptions.Visions,

	-- Titan Console (OC Delve)
	[1061] = GenericTraitFrameLayoutOptions.TitanConsole,

	-- Zul'Aman Loa Blessing
	[1166] = GenericTraitFrameLayoutOptions.ZulAmanLoaBlessing,
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

local bgAtlasFormatStr = "ui-frame-%s-backgroundtile";

function GenericTraitUtil.GetFrameLayoutInfo(treeID)
	local layoutInfo = GenericTraitFrameLayouts[treeID] or {};
	local configID = C_Traits.GetConfigIDByTreeID(treeID);
	local treeInfo = configID and C_Traits.GetTreeInfo(configID, treeID);
	if treeInfo then
		layoutInfo.Title = treeInfo.titleText;
		layoutInfo.NineSliceTextureKit = layoutInfo.NineSliceTextureKit or treeInfo.uiTextureKit;
		if not layoutInfo.BackgroundAtlas and treeInfo.uiTextureKit then
			layoutInfo.BackgroundAtlas = bgAtlasFormatStr:format(treeInfo.uiTextureKit);
		end
	end
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
