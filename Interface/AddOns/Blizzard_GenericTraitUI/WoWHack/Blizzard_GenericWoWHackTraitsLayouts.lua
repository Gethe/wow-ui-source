
-----------------------------------------------------------------------------------

-- Sets up all of the Generic Trait Frame layouts for WoWHack
-- This uses a custom default table for the base of the vendors
-- since there's a lot of boiler plate.

local WoWHackDefaultLayout = {
	FrameSize = { Width = 650, Height = 750 },
	HeaderSize = { Width = 1, Height = 1 },
	HeaderOffset = { x = 0, y = -30 },
	TitleDividerAtlas = "dragonriding-talents-line",
	ShowInset = false,
	PanelArea = "center",
	NineSliceTextureKit = "midnight",
	NineSliceFormatString = "ui-frame-%s-border",
	NineSliceLayoutName = "ButtonFrameTemplateNoPortraitLessPadding",
	UseOldNineSlice = true,
	TitleDividerShown = false,
	CurrencyOffset = { x = -55, y = -17 },
	CurrencyTextOffset = { x = -11, y = -2 },
	CurrencyTextOverrides = {
		Font = GameFontNormalHuge2,
		Color = SCRIBE_POINTS_COLOR,
		IconWidth = 14,
		IconHeight = 14,
	},
	CurrencyBackgroundAtlas = "Talebound-Vendor-Talent-Point-Frame",
	UseCurrencyTooltip = true,
	PanOffset = { x = 0, y = 0 },
	ButtonPurchaseFXIDs = { 150, 142, 143 },
	HideCurrencyDisplay = false,
	CloseButtonOffset = { x = 3, y = 5 },
};

GenericTraitUtil.SetDefaultLayout(WoWHackDefaultLayout);

-----------------------------------------------------------------------------------

-- Arcanist
GenericTraitUtil.AddFrameLayoutInfo(1160, {
	HeaderSize = { Width = 873, Height = 1 },
	FrameTitle = GENERIC_TRAIT_FRAME_WOWHACK_ALCHEMIST_TITLE,
	FrameSize = { Width = 873, Height = 910 },
	BackgroundAtlas = "talebound-vendor-arcanist-background"
});

-- Antiquarian
GenericTraitUtil.AddFrameLayoutInfo(1165, {
	FrameTitle = GENERIC_TRAIT_FRAME_WOWHACK_ANTIQUARIAN_TITLE,
	HeaderSize = { Width = 988, Height = 1 },
	FrameSize = { Width = 988, Height = 507 },
	BackgroundAtlas = "talebound-vendor-antiquarian-background",
});

-- Outfitter 
GenericTraitUtil.AddFrameLayoutInfo(1261, {
	HeaderSize = { Width = 873, Height = 1 },
	FrameTitle = GENERIC_TRAIT_FRAME_WOWHACK_OUTFITTER_TITLE,
	FrameSize = { Width = 873, Height = 910 },
	BackgroundAtlas = "talebound-vendor-outfitter-background",
	HideUndiscoveredNodes = true,
	OnEnterDisplayCallback = function(display)
		local spellID = display:GetSpellID();
		if spellID then
			EventRegistry:TriggerEvent("PlayerChoiceOption.OnOptionEnter", spellID);
		else
			EventRegistry:TriggerEvent("PlayerChoiceOption.OnOptionLeave");
		end
	end,
	OnLeaveDisplayCallback = function()
		EventRegistry:TriggerEvent("PlayerChoiceOption.OnOptionLeave");
	end,
	OnShowCallback = function()
		EventRegistry:TriggerEvent("OutfitterFrame.Opened");
	end,
	OnHideCallback = function()
		EventRegistry:TriggerEvent("PlayerChoiceOption.OnOptionLeave");
		EventRegistry:TriggerEvent("OutfitterFrame.Closed");
	end,
});
