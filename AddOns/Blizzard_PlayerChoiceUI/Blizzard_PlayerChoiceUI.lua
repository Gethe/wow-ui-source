local MAX_PLAYER_CHOICE_OPTIONS = 4;
local REWARDS_WIDTH = 200;
local INIT_OPTION_HEIGHT = 370;

local GORGROND_GARRISON_ALLIANCE_CHOICE = 55;
local GORGROND_GARRISON_HORDE_CHOICE = 56;
local THREADS_OF_FATE_RESPONSE = 3272;

local STANDARD_SIZE_TEXT_WIDTH = 196;
local STANDARD_SIZE_WIDTH = 240;

local WIDE_SIZE_TEXT_WIDTH = 356;
local WIDE_SIZE_WIDTH = 501;

local HEADERS_SHOWN_TOP_PADDING = 185;
local TITLE_HIDDEN_TOP_PADDING = -200;
local HEADERS_HIDDEN_TOP_PADDING = 150;
local HEADERS_COMBINED_WITH_OPTION_TOP_PADDING = 160;
local HEADERS_COMBINED_AND_TITLE_HIDDEN_TOP_PADDING = 30;

local DEFAULT_LEFT_PADDING = 65;
local DEFAULT_RIGHT_PADDING = 65;
local DEFAULT_SPACING = 20;
local DEFAULT_TEXTURE_KIT = "neutral";

local MAXIMUM_VARIED_BACKGROUND_OPTION_TEXTURES = 3;
local RARITY_OFFSET = 1;

local ANIMA_GLOW_MODEL_SCENE_ID = 342;

local PLAYER_CHOICE_FRAME_EVENTS = {
	"PLAYER_ENTERING_WORLD",
	"PLAYER_DEAD",
	"PLAYER_CHOICE_CLOSE",
};

StaticPopupDialogs["CONFIRM_GORGROND_GARRISON_CHOICE"] = {
	text = CONFIRM_GORGROND_GARRISON_CHOICE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		SendPlayerChoiceResponse(self.data.response);
		HideUIPanel(self.data.owner);
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
}

StaticPopupDialogs["CONFIRM_PLAYER_CHOICE"] = {
	text = "%s",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		if (self.data.confirmationSoundkit) then 
			PlaySound(self.data.confirmationSoundkit);
		end 
		SendPlayerChoiceResponse(self.data.response);
		HideUIPanel(self.data.owner);
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
}

StaticPopupDialogs["CONFIRM_PLAYER_CHOICE_WITH_CONFIRMATION_STRING"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = DECLINE,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hasEditBox = 1,
	maxLetters = 32,

	OnAccept = function(self)
		SendPlayerChoiceResponse(self.data.response);
		HideUIPanel(PlayerChoiceFrame);
	end,
	OnShow = function(self)
		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		if (parent.button1:IsEnabled()) then
			SendPlayerChoiceResponse(parent.data.response);
			parent:Hide(); 
			HideUIPanel(PlayerChoiceFrame);
		end
	end,
	EditBoxOnTextChanged = function (self)
		local parent = self:GetParent();
		if (strupper(parent.editBox:GetText()) == parent.data.confirmationString ) then
			parent.button1:Enable();
		else
			parent.button1:Disable();
		end
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide(); 
		ClearCursor();
	end
}

local borderFrameTextureKitRegions = {
	["Header"] = "UI-Frame-%s-Header",
}

local titleTextureKitRegions = {
	["Left"] = "UI-Frame-%s-TitleLeft",
	["Right"] = "UI-Frame-%s-TitleRight",
	["Middle"] = "_UI-Frame-%s-TitleMiddle",
}

local standardSizeTextureKitRegions = {
	["ArtworkBorder"] = "UI-Frame-%s-Portrait",
	["ArtworkBorderAdditionalGlow"] = "UI-Frame-%s-Portrait",
	["ArtworkBorderDisabled"] = "UI-Frame-%s-PortraitDisable",
	["BackgroundGlow"] = "UI-Frame-%s-CardParchment-Normal",
	["ArtworkBorder2"] = "UI-Frame-%s-Portrait-border",
	["BackgroundShadowSmall"] = "UI-Frame-%s-CardShadowSmall",
	["BackgroundShadowLarge"] = "UI-Frame-%s-CardShadowLarge",
	["ShadowMask"] = "UI-Frame-%s-CardShadowMask",
};

local optionBackgroundTextureKitRegions = {
	["Background"] = "UI-Frame-%s-CardParchment",
	["ScrollingBG"] = "UI-Frame-%s-ScrollingBG",
};

local variedBackgroundTextureKits = {
	[1] = "UI-Frame-%s-CardParchment-Style1",
	[2] = "UI-Frame-%s-CardParchment-Style2",
	[3] = "UI-Frame-%s-CardParchment-Style3",
}

local wideSizeTextureKitRegions = {
	["ArtworkBorder"] = "UI-Frame-%s-PortraitWider",
	["ArtworkBorderAdditionalGlow"] = "UI-Frame-%s-PortraitWider",
	["ArtworkBorderDisabled"] = "UI-Frame-%s-PortraitWiderDisable",
	["Background"] = "UI-Frame-%s-CardParchmentWider",
};

local hideButtonAtlasOptions = {
	SmallButton = "UI-Frame-%s-HideButton",
	LargeButton = "UI-Frame-%s-PendingButton",
	SmallButtonHighlight = "UI-Frame-%s-HideButtonHighlight",
	LargeButtonHighlight = "UI-Frame-%s-PendingButtonHighlight",
};

local backgroundTextureKitRegions = {
	["BackgroundTile"] = "UI-Frame-%s-BackgroundTile",
};

local contentHeaderTextureKitRegions = {
	["Ribbon"] = "UI-Frame-%s-Ribbon",
};

local contentSubHeaderTextureKitRegions = {
	["BG"] = "UI-Frame-%s-Subtitle",
};

local contentSubHeaderTextureKitRegionsDisabled = {
	["BG"] = "UI-Frame-%s-DisableSubtitle",
};

local textureFontProperties = {
	["alliance"] = {
		title = CreateColor(0.008, 0.051, 0.192),
		description = CreateColor(0.082, 0.165, 0.373),
	},
	["horde"] = {
		title = CreateColor(0.192, 0.051, 0.008),
		description = CreateColor(0.412, 0.020, 0.020),
	},
	["marine"] = {
		title = CreateColor(0.192, 0.051, 0.008),
		description = CreateColor(0.192, 0.051, 0.008),
	},
	["mechagon"] = {
		title = CreateColor(0.969, 0.855, 0.667),
		description = CreateColor(0.969, 0.855, 0.667),
	},
	["jailerstower"] = {
		title = HIGHLIGHT_FONT_COLOR,
		description = NORMAL_FONT_COLOR,
		titleFont = QuestFont_Huge;
	},
	["Oribos"] = {
		title = HIGHLIGHT_FONT_COLOR,
		description = HIGHLIGHT_FONT_COLOR,
		descriptionFont = QuestFont_Super_Huge;
	},
	["Kyrian"] = {
		title = CreateColor(0.008, 0.051, 0.192),
		description = CreateColor(0.082, 0.165, 0.373),
	},
};

local borderLayout = {
	["alliance"] = {
		closeButtonX = 1,
		closeButtonY = 2,
		closeBorderX = 0,
		closeBorderY = 0,
		header = -55,
		setAtlasVisibility = true,
		showHeader = true,
		showTitle = true,
		frameOffsetY = 0,
	},
	["horde"] = {
		closeButtonX = 1,
		closeButtonY = 2,
		closeBorderX = -1,
		closeBorderY = 1,
		header = -61,
		setAtlasVisibility = true,
		showHeader = true,
		showTitle = true,
		frameOffsetY = 0,
	},
	["marine"] = {
		closeButtonX = 3,
		closeButtonY = 3,
		closeBorderX = -1,
		closeBorderY = 1,
		header = 0,
		setAtlasVisibility = true,
		showTitle = true,
		frameOffsetY = 0,
		useFourCornersBorderNineSlice = true,
	},
	["neutral"] = {
		closeButtonX = 1,
		closeButtonY = 2,
		closeBorderX = -1,
		closeBorderY = 1,
		header = 0,
		setAtlasVisibility = true,
		showTitle = true,
		frameOffsetY = 0,
	},
	["mechagon"] = {
		closeButtonX = 3,
		closeButtonY = 3,
		closeBorderX = -1,
		closeBorderY = 1,
		header = 0,
		setAtlasVisibility = true,
		showTitle = true,
		frameOffsetY = 0,
	},
	["jailerstower"] = {
		closeButtonX = 1,
		closeButtonY = 2,
		hideCloseButton = true,
		closeBorderX = -1,
		closeBorderY = 1,
		header = 0,
		setAtlasVisibility = true,
		frameOffsetY = 130,
		hideBorder = true,
	},
	["Oribos"] = {
		closeButtonX = 1,
		closeButtonY = 2,
		closeBorderX = -1,
		closeBorderY = 1,
		header = 0,
		showTitle = true,
		setAtlasVisibility = true,
		frameOffsetY = 0,
		useFourCornersBorderNineSlice = true,
	},
	["Venthyr"] = {
		closeButtonX = 2,
		closeBorderX = -2,
		closeButtonY = 2,
		closeBorderY = 2,
		showTitle = true,
		setAtlasVisibility = true,
		useFourCornersBorderNineSlice = true,
	},
	["Kyrian"] = {
		closeButtonX = 1,
		closeBorderX = 0,
		closeButtonY = 2,
		closeBorderY = 1,
		showTitle = true,
		setAtlasVisibility = true,
		useFourCornersBorderNineSlice = true,
		noTitleOffset = true, 
	},
}

local PLAYER_CHOICE_QUALITY_TEXT = {
	[Enum.PlayerChoiceRarity.Common] = ITEM_QUALITY1_DESC,
	[Enum.PlayerChoiceRarity.Uncommon] = ITEM_QUALITY2_DESC,
	[Enum.PlayerChoiceRarity.Rare] = ITEM_QUALITY3_DESC,
	[Enum.PlayerChoiceRarity.Epic] = ITEM_QUALITY4_DESC,
};

local defaultChoiceLayout = {
	atlasBackgroundWidthPadding = 0,
	optionHeightOffset = 0,
	extraPaddingOnArtworkBorder = 0,
	backgroundYOffset = 0,
	optionButtonOverrideWidth = 175,
	optionTextJustifyH = "LEFT",
	offsetBetweenOptions = 0,
};

local choiceLayout = {
	["default"] = defaultChoiceLayout,

	["jailerstower"] = {
		atlasBackgroundWidthPadding = 50,
		optionHeightOffset = 90,
		extraPaddingOnArtworkBorder = 56,
		backgroundYOffset = -160,
		combineHeaderWithOption = true,
		usesVariedBackgrounds = true,
		showCircleMaskOnArtwork = true,
		optionButtonOverrideWidth = 120,
		forceStandardSize = true,
		optionTextJustifyH = "CENTER",
		standardSizeTextWidthOverride = 160,
		animateArtworkBorder = true,
		animateFrameInAndOut = true,
		offsetBetweenOptions = -50,
		highlightChoiceBeforeHide = true, 
		useArtworkGlowOnSelection = true,
		artworkAboveBorder = true;
		optionFixedHeight = 115,
		optionYOffset = -35,
		optionsButtonContainerYOffset = 10,
		headerYOffset = -50;
		artworkBorderYOffset = 25;
		tooltipOnArtworkAndOptionText = true,
		fadeOutSoundKitID = SOUNDKIT.UI_PLAYER_CHOICE_JAILERS_TOWER_FADEOUT_POWERS_NOT_PICKED,
		setupTooltip = function(frame, tooltip, choiceInfo)
			tooltip:SetOwner(frame, "ANCHOR_RIGHT");
			if(choiceInfo.rarityColor) then 
				GameTooltip_AddColoredLine(tooltip, choiceInfo.header, choiceInfo.rarityColor);
			else 
				GameTooltip_AddHighlightLine(tooltip, choiceInfo.header);
			end
			if (choiceInfo.rarity and choiceInfo.rarityColor) then
				local rarityText = PLAYER_CHOICE_QUALITY_TEXT[choiceInfo.rarity];
				GameTooltip_AddColoredLine(tooltip, rarityText,  choiceInfo.rarityColor);
			end
			GameTooltip_AddNormalLine(tooltip, choiceInfo.description, true);
			tooltip:Show();
		end;
	},
	["Oribos"] = {
		atlasBackgroundWidthPadding = -2,
		optionHeightOffset = 0,
		extraPaddingOnArtworkBorder = 0,
		backgroundYOffset = 0,
		combineHeaderWithOption = true,
		optionTextJustifyH = "CENTER",
		anchorOptionTextToButton = true;
		optionButtonOverrideWidth = 120,
		offsetBetweenOptions = 0,
		covenantPreviewId = 1,
		secondButtonClickDoesntCloseUI = true,
		enlargeBackgroundOnMouseOver = true,
		mouseOverSoundKit = SOUNDKIT.UI_COVENANT_CHOICE_MOUSE_OVER_COVENANT, 
		confirmationOkSoundKit = SOUNDKIT.UI_COVENANT_CHOICE_CONFIRM_COVENANT,
		exitButtonSoundKit = SOUNDKIT.UI_COVENANT_CHOICE_CLOSE,
	},
	["Venthyr"] = setmetatable(
		{
			restrictByID = {636, 652, 653,},
			optionFixedHeight = 125,
			widgetFixedHeight = 135,
		},
		{ 
			__index = defaultChoiceLayout
		}
	),
}

local choiceButtonLayout = {
	["default"] = {
		firstButtonOffsetX = 0,
		firstButtonOffsetY = 0,
		secondButtonOffsetX = 0,
		secondButtonOffsetY = 0,
		firstButtonTemplate="PlayerChoiceOptionButtonTemplate",
		secondButtonTemplate="PlayerChoiceOptionButtonTemplate",
	},
	["Oribos"] = {
		firstButtonOffsetX = 20,
		firstButtonOffsetY = 0,
		secondButtonOffsetX = -30,
		secondButtonOffsetY = 0,
		firstButtonTemplate = "PlayerChoiceOptionButtonTemplate",
		secondButtonTemplate = "PlayerChoiceOptionMagnifyingGlass",
		firstButtonUseAtlasSize = false,
		secondButtonUseAtlasSize = true,
		hideOptionButtonsUntilMouseOver = true,
		forceSideBySideLayout = true,
	},
	["jailerstower"] = {
		firstButtonOffsetX = 0,
		firstButtonOffsetY = -30,
		secondButtonOffsetX = 0,
		secondButtonOffsetY = 0,
		firstButtonTemplate="PlayerChoiceOptionButtonTemplate",
		secondButtonTemplate="PlayerChoiceOptionButtonTemplate",
	}
}

local choiceModelSceneLayout = {
	["jailerstower"] = {
		effectID = 89, 
		modelSceneYOffest = -120, 
		modelSceneXOffest = 0, 
		artworkEffectID = 95, 
		makeChoiceEffectID = 97, 
		extraButtonEffectID = 98, 
	},
}

local hideButtonOverrideInfo = {
	["jailerstower"] = { 
		playerChoiceShowingText = HIDE, 
		playerChoiceHiddenText = JAILERS_TOWER_PENDING_POWER_SELECTION, 
		playerChoiceShowingTextXOffset = 3,
		playerChoiceHiddenTextXOffset = 8,
		playerChoiceShowingTextYOffset = -3,
		playerChoiceHiddenTextYOffset = -3,
		playerChoiceShowingSoundKit = SOUNDKIT.UI_PLAYER_CHOICE_JAILERS_TOWER_HIDE_POWERS,
		playerChoiceHiddenSoundKit = SOUNDKIT.UI_PLAYER_CHOICE_JAILERS_TOWER_SHOW_POWERS,
	},
}

local function SetupBorder(self, layout, textureKit)
	if (layout.useFourCornersBorderNineSlice) then
		if(not layout.hideBorder) then
			NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, textureKit);
		end
	else
		if(not layout.hideBorder) then
			NineSliceUtil.ApplyIdenticalCornersLayout(self.NineSlice, textureKit);
		end
	end

	self.NineSlice:SetShown(not layout.hideBorder);

	self.BorderFrame.Header:SetPoint("BOTTOM", self.BorderFrame, "TOP", 0, layout.header);
	self.BorderFrame.Header:SetShown(layout.showHeader);

	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-%s-ExitButtonBorder", layout.closeBorderX, layout.closeBorderY, textureKit);

	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", layout.closeButtonX, layout.closeButtonY);
	self.CloseButton:SetFrameLevel(510);
	self.NineSlice:SetFrameLevel(500);
	self.CloseButton:SetShown(not layout.hideCloseButton);
end

local function JailersTowerBuffsContainerActive()
	return IsInJailersTower() and ScenarioBlocksFrame and ScenarioBlocksFrame.MawBuffsBlock:IsShown();
end 

PlayerChoiceFrameMixin = { };
function PlayerChoiceFrameMixin:OnLoad()
	self.QuestionText = self.Title.Text;
	self.optionInitHeight = INIT_OPTION_HEIGHT;
end

function PlayerChoiceFrameMixin:OnEvent(event)
	if (event == "PLAYER_DEAD" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_CHOICE_CLOSE") then
		self:TryHide();
	end
end

function PlayerChoiceFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, PLAYER_CHOICE_FRAME_EVENTS);

	local choiceInfo = C_PlayerChoice.GetPlayerChoiceInfo();

	if(choiceInfo and choiceInfo.soundKitID) then
		PlaySound(choiceInfo.soundKitID, nil, SOUNDKIT_ALLOW_DUPLICATES);
	else
		PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
	end

	if JailersTowerBuffsContainerActive() then
		ScenarioBlocksFrame.MawBuffsBlock.Container:UpdateListState(true);
	end
	self:EnableMouse(true);
end

function PlayerChoiceFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_QUEST_LIST_CLOSE);
	StaticPopup_Hide("CONFIRM_GORGROND_GARRISON_CHOICE");

	FrameUtil.UnregisterFrameForEvents(self, PLAYER_CHOICE_FRAME_EVENTS);
	ClosePlayerChoice();

	for i = 1, #self.Options do
		local option = self.Options[i];
		self:UpdateOptionWidgetRegistration(option, nil);
	end

	if JailersTowerBuffsContainerActive() then
		ScenarioBlocksFrame.MawBuffsBlock.Container:UpdateListState(false);
	end

	if(PlayerChoiceToggleButton:IsShown()) then
		PlayerChoiceToggleButton:UpdateButtonState();
	end
	GameTooltip:Hide(); 
end

function PlayerChoiceFrameMixin:SetupTextureKits(frame, regions, overrideTextureKit)
	SetupTextureKitOnRegions(overrideTextureKit or self.uiTextureKit, frame, regions, self.setAtlasVisibility, TextureKitConstants.UseAtlasSize);
end

function PlayerChoiceFrameMixin:OnFadeOutFinished()
	HideUIPanel(self);
end

function PlayerChoiceFrameMixin:OnFadeInFinished()
	local modelSceneLayout = choiceModelSceneLayout[self.uiTextureKit]; 

	self.HighStrataModelScene:SetShown(modelSceneLayout);
end

function PlayerChoiceFrameMixin:TryHide()
	if(self.optionLayout.animateFrameInAndOut) then
		for i, option in ipairs(self.Options) do
			if (i > self.numActiveOptions) then
				break;
			end
			option:CancelEffects();
		end
		self.FadeOut:Play();
	else
		HideUIPanel(self);
	end
end

function PlayerChoiceFrameMixin:HideOptions(option)
	for i, optionToHide in ipairs(self.Options) do
		optionToHide.OptionButtonsContainer:DisableButtons();
		if(option ~= optionToHide) then
			self.HighStrataModelScene:Hide(); 
			optionToHide:CancelEffects(); 
			optionToHide.MouseOverOverride:Hide();
			optionToHide.FadeoutUnselected:Restart(); 
		end 
	end
end 

local function GetChoiceLayout(choiceInfo)
	local overrideLayout = choiceLayout[choiceInfo.uiTextureKit or DEFAULT_TEXTURE_KIT];
	if overrideLayout then
		if not overrideLayout.restrictByID or tContains(overrideLayout.restrictByID, choiceInfo.choiceID) then
			return overrideLayout;
		end
	end

	return choiceLayout.default;
end

function PlayerChoiceFrameMixin:TryShow()
	local choiceInfo = C_PlayerChoice.GetPlayerChoiceInfo();
	if(not choiceInfo) then
		return; 
	end 
	self.uiTextureKit = choiceInfo.uiTextureKit or DEFAULT_TEXTURE_KIT;
	local layout = borderLayout[self.uiTextureKit] or borderLayout["neutral"];
	self.optionLayout = GetChoiceLayout(choiceInfo);
	self.optionInitHeight = INIT_OPTION_HEIGHT - self.optionLayout.optionHeightOffset;

	self:SetPoint("CENTER", 0, layout.frameOffsetY);
	self:AdjustFramePaddingForCustomChoicePadding();

	self.setAtlasVisibility = layout.setAtlasVisibility;

	self:SetupTextureKits(self.BorderFrame, borderFrameTextureKitRegions);
	self:SetupTextureKits(self.Title, titleTextureKitRegions);
	self:SetupTextureKits(self.Background, backgroundTextureKitRegions);

	self.optionDescriptionColor = WARBOARD_OPTION_TEXT_COLOR;
	self.optionHeaderTitleColor = BLACK_FONT_COLOR;
	self.optionTitleFont = SystemFont_Large;
	self.optionDescriptionFont = GameFontBlack;

	local textureKitFontProperties = textureFontProperties[self.uiTextureKit];
	if textureKitFontProperties then
		self.optionDescriptionColor = textureKitFontProperties.description;
		self.optionHeaderTitleColor = textureKitFontProperties.title;
		if(textureKitFontProperties.titleFont) then
			self.optionTitleFont = textureKitFontProperties.titleFont;
		end
		if(textureKitFontProperties.descriptionFont) then
			self.optionDescriptionFont = textureKitFontProperties.descriptionFont;
		end
	end

	self.BlackBackground:Hide(); 
	SetupBorder(self, layout, self.uiTextureKit);

	if(choiceInfo.hideWarboardHeader) then
		self.BorderFrame.Header:Hide();
	end

	for _, option in pairs(self.Options) do
		option.Header.Text:SetFontObject(self.optionTitleFont)
		option.Header.Text:SetTextColor(self.optionHeaderTitleColor:GetRGBA());
		option.OptionText:ClearText()
		if (self.optionLayout.optionFixedHeight) then
			option.OptionText:SetUseHTML(false);
			option.OptionText:SetStringHeight(self.optionLayout.optionFixedHeight);
		else
			option.OptionText:SetUseHTML(true);
		end
		option.OptionText:SetFontObject(self.optionDescriptionFont);
		option.OptionText:SetTextColor(self.optionDescriptionColor:GetRGBA());

		if(option.FadeoutSelected:IsPlaying()) then 
			option.FadeoutSelected:Stop(); 
		end 
		option.FadeoutUnselected:Stop();
		option:SetAlpha(1);

		if (self.optionLayout.artworkAboveBorder) then
			option.Artwork:SetDrawLayer("ARTWORK", 2);
		else
			option.Artwork:SetDrawLayer("ARTWORK", -2);
		end

		option.SpinningGlows2:SetAlpha(0);
		option.RingGlow:SetAlpha(0);
		option.PointBurstLeft:SetAlpha(0);
		option.PointBurstRight:SetAlpha(0);
	end

	if (not self:IsShown()) then
		if (self.optionLayout.animateFrameInAndOut) then
			self.FadeIn:Play();
		end
		ShowUIPanel(self)
	end

	if(PlayerChoiceToggleButton:IsShown()) then
		PlayerChoiceToggleButton.isPlayerChoiceFrameSetup = true;
		PlayerChoiceToggleButton:UpdateButtonState();
	end

	self:SetAlpha(1);
	self:Update();
end

function PlayerChoiceFrameMixin:CloseUIFromExitButton()
	if(self.optionLayout.exitButtonSoundKit) then
		PlaySound(self.optionLayout.exitButtonSoundKit);
	end
	HideUIPanel(self);
end 

local function IsTopWidget(widgetFrame)
	return widgetFrame.widgetType == Enum.UIWidgetVisualizationType.SpellDisplay;
end

local function WidgetsLayout(widgetContainer, sortedWidgets, fixedHeight)
	local widgetsHeight = fixedHeight or 0;
	local maxWidgetWidth = 0;

	local lastTopWidget, lastBottomWidget;

	for index, widgetFrame in ipairs(sortedWidgets) do
		if IsTopWidget(widgetFrame) then
			if lastTopWidget then
				widgetFrame:SetPoint("TOP", lastTopWidget, "BOTTOM", 0, 0);
			else
				widgetFrame:SetPoint("TOP", widgetContainer, "TOP", 0, 0);
			end

			lastTopWidget = widgetFrame;
		else
			if lastBottomWidget then
				lastBottomWidget:SetPoint("BOTTOM", widgetFrame, "TOP", 0, 0);
			end

			widgetFrame:SetPoint("BOTTOM", widgetContainer, "BOTTOM", 0, 0);

			lastBottomWidget = widgetFrame;
		end

		if not fixedHeight then
			widgetsHeight = widgetsHeight + widgetFrame:GetWidgetHeight();
		end

		local widgetWidth = widgetFrame:GetWidgetWidth();
		if widgetWidth > maxWidgetWidth then
			maxWidgetWidth = widgetWidth;
		end
	end

	if not fixedHeight and lastTopWidget and lastBottomWidget then
		widgetsHeight = widgetsHeight + 20;
	end

	widgetsHeight = math.max(widgetsHeight, 1);
	maxWidgetWidth = math.max(maxWidgetWidth, 1);
	widgetContainer:SetHeight(widgetsHeight);
	widgetContainer:SetWidth(maxWidgetWidth);
end

function PlayerChoiceFrameMixin:WidgetLayout(widgetContainer, sortedWidgets)
	WidgetsLayout(widgetContainer, sortedWidgets, self.optionLayout.widgetFixedHeight);
	self.optionsAligned = false;
	self:MarkDirty();
end

function PlayerChoiceFrameMixin:WidgetInit(widgetFrame)
	if self.optionDescriptionColor and widgetFrame.SetFontStringColor then
		widgetFrame:SetFontStringColor(self.optionDescriptionColor);
	end
end

function PlayerChoiceFrameMixin:UpdateOptionWidgetRegistration(option, widgetSetID)
	if not option.WidgetContainer then
		return;
	end

	option.WidgetContainer:RegisterForWidgetSet(widgetSetID, function(...) self:WidgetLayout(...); end, function(...) self:WidgetInit(...); end);
	if not option:HasWidgets() then
		if self.optionLayout.widgetFixedHeight then
			option.WidgetContainer:SetHeight(self.optionLayout.widgetFixedHeight);
		else
			option.WidgetContainer:SetHeight(1);
		end
	end
end

function PlayerChoiceFrameMixin:OnCleaned()
	if not self.optionsAligned then
		self:AlignOptionHeights();
	end
end

function PlayerChoiceFrameMixin:AlignOptionHeights()
	if not self.numActiveOptions then
		return;
	end

	-- Get the max height option
	local maxOptionHeight = 0;
	local maxHeightOption;
	for i=1, self.numActiveOptions do
		local option = self.Options[i];
		local optionHeight = option:GetHeight();
		if optionHeight > maxOptionHeight then
			maxHeightOption = option;
			maxOptionHeight = optionHeight;
		end
	end
	-- If the max height option is smaller than the initHeight, add height to its padding container
	if self.optionInitHeight > maxOptionHeight then
		maxHeightOption:AddPaddingHeight(self.optionInitHeight - maxOptionHeight);
	end

	-- Now get the max padding frame height
	local maxPaddingHeight = 0;
	for i=1, self.numActiveOptions do
		local option = self.Options[i];
		maxPaddingHeight = math.max(maxPaddingHeight, option:GetPaddingHeight());
	end

	-- And set all padding frame heights to the max padding frame height (so top and bottom widgets align)
	maxOptionHeight = 0;
	for i=1, self.numActiveOptions do
		local option = self.Options[i];
		local optionPaddingHeight = option:GetPaddingHeight();

		-- If optionPaddingHeight is 1 or less there is nothing in it, so don't bother (we don't want an empty padding container to make a large option even larger)
		if optionPaddingHeight > 1 then
			local heightDiff = maxPaddingHeight - optionPaddingHeight;
			option:AddPaddingHeight(heightDiff);
		end

		maxOptionHeight = math.max(maxOptionHeight, option:GetHeight());	-- Might as well calculate the new maxOptionHeight while we are in here
	end

	-- Then loop through again and adjust the padding offset and heights to make all the options the same height
	for i=1, self.numActiveOptions do
		local option = self.Options[i];
		option:UpdatePadding(maxOptionHeight);
	end

	if not self.fixedPaddingAndSpacing then
		if self.numActiveOptions == 1 then
			self.leftPadding = 0;
			self.rightPadding = 0;
			self.spacing = 0;
		elseif self.numActiveOptions == 4 then
			self.leftPadding = 50;
			self.rightPadding = 50;
			self.spacing = 20;
		else
			self.leftPadding = DEFAULT_LEFT_PADDING;
			self.rightPadding = DEFAULT_RIGHT_PADDING;
			self.spacing = DEFAULT_SPACING;
		end
	end

	-- NOTE: It is very important that you set optionsAligned to true here, otherwise the Layout call will cause AlignOptionHeights to get called again
	self.optionsAligned = true;

	self:Layout(); -- Note that we call Layout here and not MarkDirty. Otherwise the Layout won't happen until the next frame and you will see a pop as things get adjsuted
	UpdateScaleForFit(self);
end

function PlayerChoiceFrameMixin:GetNumOptions()
	return self.numActiveOptions;
end

function PlayerChoiceFrameMixin:ThrowTooManyOptionsError(playerChoiceID, badOptID)
	local showingOptionIDs = {};
	for _, option in ipairs(self.Options) do
		table.insert(showingOptionIDs, option.id);
	end

	table.insert(showingOptionIDs, badOptID);
	local errorMessage = "|n|nPLAYERCHOICE DATA ERROR: Too many visible options! Max allowed is "..MAX_PLAYER_CHOICE_OPTIONS..".|n|nCurrently showing PlayerChoice ID "..playerChoiceID.."|nCurrently showing OptionIDs: "..table.concat(showingOptionIDs, ", ").."|n";
	error(errorMessage);
end

function PlayerChoiceFrameMixin:UpdateNumActiveOptions(choiceInfo)
	self.numActiveOptions = 0;
	self.anOptionHasMultipleButtons = false;
	self.optionData = {};

	local groupOptionMap = {};
	for i=1, choiceInfo.numOptions do
		local optionInfo = C_PlayerChoice.GetPlayerChoiceOptionInfo(i);
		if not optionInfo then
			return;	-- End of the valid options
		end

		if not optionInfo.groupID or not groupOptionMap[optionInfo.groupID] then
			-- This option is either not part of a group or is part of a NEW group
			if self.numActiveOptions == MAX_PLAYER_CHOICE_OPTIONS then
				self:ThrowTooManyOptionsError(choiceInfo.choiceID, optionInfo.id);	-- This will cause a lua error and execution will stop
			end

			self.numActiveOptions = self.numActiveOptions + 1;
			table.insert(self.optionData, optionInfo);
			if optionInfo.groupID then
				groupOptionMap[optionInfo.groupID] = #self.optionData;
			end
		else
			-- This option is part of a group that already exists...add its info to that option
			local existingGroupOptionIndex = groupOptionMap[optionInfo.groupID];
			local existingGroupOptionInfo = self.optionData[existingGroupOptionIndex];
			existingGroupOptionInfo.secondOptionInfo = optionInfo;

			-- for grouped options the option is only disabled if all of them are
			if not optionInfo.disabledOption then
				existingGroupOptionInfo.disabledOption = false;
			end

			-- for grouped options the art is only desaturated if all of them are
			if not optionInfo.desaturatedArt then
				existingGroupOptionInfo.desaturatedArt = false;
			end

			self.anOptionHasMultipleButtons = true;
		end
	end
end

function PlayerChoiceFrameMixin:AdjustFramePaddingForCustomChoicePadding()
	self.spacing = (DEFAULT_SPACING - self.optionLayout.atlasBackgroundWidthPadding) + self.optionLayout.offsetBetweenOptions;
	self.leftPadding = DEFAULT_LEFT_PADDING - self.optionLayout.atlasBackgroundWidthPadding;
	self.rightPadding = DEFAULT_RIGHT_PADDING - self.optionLayout.atlasBackgroundWidthPadding;
end

function PlayerChoiceFrameMixin:Update()
	self.hasPendingUpdate = false;

	local choiceInfo = C_PlayerChoice.GetPlayerChoiceInfo();
	if (not choiceInfo or choiceInfo.choiceID == 0 or choiceInfo.numOptions == 0) then
		self:Hide();
		return;
	end

	self.choiceID = choiceInfo.choiceID;
	self.QuestionText:SetText(choiceInfo.questionText);

	self:UpdateNumActiveOptions(choiceInfo);

	self.optionsAligned = false;
	local hasHeaders = false;
	local lastActiveOption;

	local layout = borderLayout[self.uiTextureKit] or borderLayout[DEFAULT_TEXTURE_KIT];
	local modelSceneLayout = choiceModelSceneLayout[self.uiTextureKit]; 
	local shouldShowTitle = layout.showTitle;
	local noTitleOffset = layout.noTitleOffset;

	for i, option in ipairs(self.Options) do
		self:UpdateOptionWidgetRegistration(option, nil);
		if i > self.numActiveOptions then
			option:Hide();
		else
			option:ResetOption();

			local optionInfo = self.optionData[i];
			option.rarity = optionInfo.rarity;
			if(optionInfo.rarityColor) then
				option.rarityColor = optionInfo.rarityColor;
			end
			if(option.rarity and self.uiTextureKit and self.uiTextureKit == "jailerstower") then 
				optionInfo.description = option:SetupRarityDescription(optionInfo.description); 
			end 

			option.showOptionDisabled = optionInfo.disabledOption;
			option.hasDesaturatedArt = not option.showOptionDisabled and optionInfo.desaturatedArt;

			option.Artwork:SetDesaturated(option.showOptionDisabled or option.hasDesaturatedArt);
			option.ArtworkBorder:SetDesaturated(option.showOptionDisabled);
			option.Header.Ribbon:SetDesaturated(option.showOptionDisabled);
			option.SubHeader.BG:SetDesaturated(option.showOptionDisabled);
			option.Background:SetDesaturated(option.showOptionDisabled);

			option.uiTextureKit = optionInfo.uiTextureKit;
		
			option.maxStacks = optionInfo.maxStacks;
			option.spellID = optionInfo.spellID; 

			option:ConfigureHeader(optionInfo.header, optionInfo.headerIconAtlasElement);
			option:UpdateOptionSize();

			local hasArtworkBorderArt = option.ArtworkBorder:IsShown();
			option.ArtworkBorder:SetShown(hasArtworkBorderArt and not option.hasDesaturatedArt and optionInfo.choiceArtID > 0);

			local hasArtworkBorderDisabledArt = option.ArtworkBorderDisabled:IsShown();
			option.ArtworkBorderDisabled:SetShown(hasArtworkBorderDisabledArt and option.hasDesaturatedArt);

			option:SetupArtworkForOption();
			option:UpdatePadding();
			option.optID = optionInfo.responseIdentifier;
			option.id = optionInfo.id;
			option.OptionText:SetJustifyH(self.optionLayout.optionTextJustifyH);
			option.OptionText:SetText(optionInfo.description);
			option:ConfigureType(optionInfo.typeArtID);
			option:ConfigureSubHeader(optionInfo.subHeader);
			option.Artwork:SetTexture(optionInfo.choiceArtID);
			option.soundKitID = optionInfo.soundKitID;
			option.hasRewards = optionInfo.hasRewards;
			self:UpdateOptionWidgetRegistration(option, optionInfo.widgetSetID);
			option.OptionButtonsContainer:ConfigureButtons(optionInfo, self.uiTextureKit);

			-- We want to override the texture text color if this is jailers tower.
			if(self.uiTextureKit == "jailerstower" and option.rarityColor) then
				option.Header.Text:SetTextColor(option.rarityColor:GetRGBA());
			end

			option.Background:ClearAllPoints();
			option.Background:SetPoint("TOPLEFT", -8, 38);
			option.Background:SetPoint("BOTTOMRIGHT", 8, -30 + self.optionLayout.backgroundYOffset);


			if(self.optionLayout.animateArtworkBorder) then
				option.ArtworkBorderAdditionalGlow:Show();
				option.RotateArtworkBorderAnimation:Play();
				option.ArtworkBorderGlowAnimation:Play();
			else
				option.ArtworkBorderAdditionalGlow:Hide();
			end

			option:CancelEffects(); 

			option:Show();

			option:BeginEffects(modelSceneLayout, self.HighStrataModelScene, GlobalFXBackgroundModelScene);

			if not hasHeaders then
				hasHeaders = option.Header:IsShown();
			end

			option:SetupTextureKits(option.Header, contentHeaderTextureKitRegions);
			if option.hasDesaturatedArt then
				option:SetupTextureKits(option.SubHeader, contentSubHeaderTextureKitRegionsDisabled);
			else
				option:SetupTextureKits(option.SubHeader, contentSubHeaderTextureKitRegions);
			end
			lastActiveOption = option;
		end
	end

	self:SetupRewards();

	if (modelSceneLayout) then 
		self.HighStrataModelScene:ClearAllPoints(); 
		self.HighStrataModelScene:SetPoint("TOPLEFT"); 
		self.HighStrataModelScene:SetPoint("BOTTOMRIGHT", modelSceneLayout.modelSceneXOffest, modelSceneLayout.modelSceneYOffest)
		self.HighStrataModelScene:Show();
	else
		self.HighStrataModelScene:Hide();
	end 

	-- title needs to reach across
	if lastActiveOption and shouldShowTitle then
		self.Title:SetPoint("RIGHT", lastActiveOption, "RIGHT", 15, -50);
	end

	self.Title.Middle:ClearAllPoints();

	if(noTitleOffset) then 
		self.Title.Middle:SetPoint("LEFT", self.Title.Left, "RIGHT");
		self.Title.Middle:SetPoint("RIGHT", self.Title.Right, "LEFT");
	else 
		self.Title.Middle:SetPoint("LEFT", self.Title.Left, "RIGHT", -60, 0);
		self.Title.Middle:SetPoint("RIGHT", self.Title.Right, "LEFT", 60, 0);
	end 

	self.Title:SetShown(shouldShowTitle);
	if self.optionLayout.combineHeaderWithOption and shouldShowTitle then
		self.topPadding = HEADERS_COMBINED_WITH_OPTION_TOP_PADDING;
	elseif self.optionLayout.combineHeaderWithOption and not shouldShowTitle then
		self.topPadding = HEADERS_COMBINED_AND_TITLE_HIDDEN_TOP_PADDING;
	elseif hasHeaders then
		self.topPadding = HEADERS_SHOWN_TOP_PADDING;
	else
		self.topPadding = HEADERS_HIDDEN_TOP_PADDING;
	end

	if C_Scenario.IsInScenario() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WARFRONT_CONSTRUCTION) and select(10, C_Scenario.GetInfo()) == LE_SCENARIO_TYPE_WARFRONT then
		local helpTipInfo = {
			text = WARFRONT_TUTORIAL_CONSTRUCTION,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_WARFRONT_CONSTRUCTION,
			targetPoint = HelpTip.Point.RightEdgeCenter,
		};
		HelpTip:Show(self, helpTipInfo, self.Option1.OptionButtonsContainer);
	end

	self:MarkDirty();
end

function PlayerChoiceFrameMixin:SetupRewards()
	for i=1, self.numActiveOptions do
		local optionFrameRewards = self.Options[i].RewardsFrame.Rewards;
		local rewardInfo = C_PlayerChoice.GetPlayerChoiceRewardInfo(i);

		optionFrameRewards.ItemRewardsPool:ReleaseAll();
		optionFrameRewards.CurrencyRewardsPool:ReleaseAll();
		optionFrameRewards.ReputationRewardsPool:ReleaseAll();
		optionFrameRewards.lastReward = nil;

		if rewardInfo then
			for _, itemReward in ipairs(rewardInfo.itemRewards) do
				optionFrameRewards.lastReward = optionFrameRewards:GetItemRewardsFrame(itemReward);
			end

			for _, currencyReward in ipairs(rewardInfo.currencyRewards) do
				if C_CurrencyInfo.IsCurrencyContainer(currencyReward.currencyId, currencyReward.quantity) then
					optionFrameRewards.lastReward = optionFrameRewards:GetCurrencyContainerRewardsFrame(currencyReward);
				else
					optionFrameRewards.lastReward = optionFrameRewards:GetCurrencyRewardsFrame(currencyReward);
				end
			end

			for _, reputationReward in ipairs(rewardInfo.repRewards) do
				optionFrameRewards.lastReward = optionFrameRewards:GetReputationRewardsFrame(reputationReward);
			end

			optionFrameRewards:Layout();

			self.Options[i].RewardsFrame:SetHeight(optionFrameRewards:GetHeight());
		else
			self.Options[i].RewardsFrame:SetHeight(1);
		end
	end
end

PlayerChoiceItemButtonMixin = {};

function PlayerChoiceItemButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
	if (self.isCurrencyContainer) then
		GameTooltip:SetCurrencyByID(self.itemID, self.quantity);
		self.UpdateTooltip = self.OnEnter;
	elseif GameTooltip:SetItemByID(self.itemID) then
		self.UpdateTooltip = self.OnEnter;
	else
		self.UpdateTooltip = nil;
	end
end

function PlayerChoiceItemButtonMixin:OnUpdate()
	if GameTooltip:IsOwned(self) then
		if IsModifiedClick("DRESSUP") then
			ShowInspectCursor();
		else
			ResetCursor();
		end
	end
end

function PlayerChoiceItemButtonMixin:OnModifiedClick(button)
	if IsModifiedClick() then
		HandleModifiedItemClick(self.itemLink);
	end
end

PlayerChoiceOptionFrameMixin = {};

function PlayerChoiceOptionFrameMixin:ResetOption()
	self.Background:SetScale(1);
	self.Background:SetAlpha(1);
	self.Background:Show();

	self:CancelEffects()

	self.ChoiceSelectedAnimation:Stop(); 
	self.ArtworkBorder:SetRotation(0);
	self.ArtworkBorder:SetAlpha(1);
	self:UpdateCircleGlowVisibility(false); 

	self.ArtworkBorder:SetAtlas("UI-Frame-Horde-Portrait", true);
	self.ArtworkBorder:ClearAllPoints();
	self.ArtworkBorder:SetPoint("TOP");
	self.Artwork:ClearAllPoints();
	self.Artwork:SetPoint("TOPLEFT", self.ArtworkBorder, 10, -9);
	self.Artwork:SetPoint("BOTTOMRIGHT", self.ArtworkBorder, -10, 9);

	self.ArtworkBorderAdditionalGlow:SetRotation(0);
	self.ArtworkBorderAdditionalGlow:SetAlpha(1);

	self.BlackBackground:Hide();
	self.BackgroundGlow:Hide();
	self.ArtworkBorder2:Hide();
	self.ScrollingBG:SetAlpha(0);
	self.BackgroundShadowSmall:Hide();
	self.BackgroundShadowLarge:Hide();
	self.RotateArtworkBorderAnimation:Stop();
	self.ArtworkBorderGlowAnimation:Stop();
	local layoutInfo = self:GetOptionLayoutInfo();
	local optionButtonLayout = choiceButtonLayout[self:GetParent().uiTextureKit] or choiceButtonLayout["default"];
	self.OptionButtonsContainer:SetShown(not optionButtonLayout.hideOptionButtonsUntilMouseOver);
	self.MouseOverOverride:Show();
	self.WidgetContainer:SetHeight(1);
	self.RewardsFrame:SetHeight(1);
	self:SetHeight(332);
	self:SetAlpha(1);
end

function PlayerChoiceOptionFrameMixin:UpdateMouseOverStateOnOption()
	local mouseOver = RegionUtil.IsDescendantOfOrSame(GetMouseFocus(), self);
	self:SetDrawLayerEnabled("HIGHLIGHT", mouseOver);

	-- OnLeave logic
	if not mouseOver then
		self:SetScript("OnUpdate", nil);
		self:OnLeaveOverride();
		return;
	end

	local tooltipShown = false;
	local layoutInfo = self:GetOptionLayoutInfo();
	local choiceInfo = C_PlayerChoice.GetPlayerChoiceOptionInfo(self.layoutIndex);

	if (layoutInfo.setupTooltip and choiceInfo) then
		local mouseOverFrame = nil;

		if (layoutInfo.tooltipOnArtworkAndOptionText) then
			if (MouseIsOver(self.Artwork) or MouseIsOver(self.OptionText)) then 
				mouseOverFrame = self.OptionText;
			end
		elseif (MouseIsOver(self.MouseOverOverride)) then
			mouseOverFrame = self.MouseOverOverride;
		end

		if (mouseOverFrame) then
			layoutInfo.setupTooltip(mouseOverFrame, GameTooltip, choiceInfo);
			tooltipShown = true;
		end
	end
	if (not tooltipShown) then
		GameTooltip:Hide();
	end
end

function PlayerChoiceOptionFrameMixin:OnHide()
	self:CancelEffects(); 
end 

function PlayerChoiceOptionFrameMixin:OnEnterOverride()
	self.BackgroundGlow:Show();
	self.BackgroundGlowAnimationOut:Stop();
	self.BackgroundGlowAnimation:Stop();
	self.BackgroundGlowAnimationIn:Stop();

	local textureKit = self:GetParent().uiTextureKit;
	local optionButtonLayout = choiceButtonLayout[textureKit] or choiceButtonLayout["default"];
	local needsLayout = false;
	if(optionButtonLayout.hideOptionButtonsUntilMouseOver) then
		self.OptionButtonsContainer:Show();
		needsLayout = true;
	end
	local optionLayout = self:GetOptionLayoutInfo(); 

	if(optionLayout.mouseOverSoundKit) then 
		PlaySound(optionLayout.mouseOverSoundKit);
	end 
	if(optionLayout.enlargeBackgroundOnMouseOver) then
		self.BlackBackground:Show();
		self.Background:Hide();
		self.ScrollingBackgroundAnimIn:Play();
		self.BackgroundShadowSmall:Hide();
		self.BackgroundShadowLarge:Show();
		self:SetFrameLevel(550);
		needsLayout = true;
	end

	if(needsLayout) then
		self:Layout();
	end

	self.BackgroundGlowAnimationIn:Play();

	self:SetScript("OnUpdate", self.UpdateMouseOverStateOnOption);
end

function PlayerChoiceOptionFrameMixin:OnLeaveOverride()
	self.BackgroundGlowAnimationIn:Stop();
	self.BackgroundGlowAnimation:Stop();
	self.ScrollingBackgroundAnimIn:Stop();

	local textureKit = self:GetParent().uiTextureKit;
	local optionButtonLayout = choiceButtonLayout[textureKit] or choiceButtonLayout["default"]

	local needsLayout = false;
	if(optionButtonLayout.hideOptionButtonsUntilMouseOver) then
		self.OptionButtonsContainer:Hide();
		needsLayout = true;
	end

	if(self:GetOptionLayoutInfo().enlargeBackgroundOnMouseOver) then
		self.Background:SetScale(1);
		self.Background:Show();
		self.BlackBackground:Hide();
		self.ScrollingBG:SetAlpha(0);
		self.ScrollingBackgroundScroll:Stop();
		self.BackgroundShadowSmall:Show();
		self.BackgroundShadowLarge:Hide();
		self:SetFrameLevel(200);
		needsLayout = true;
	end

	if(needsLayout) then
		self:Layout();
	end

	self.BackgroundGlowAnimationOut:Play();
	if JailersTowerBuffsContainerActive() then
		if(self.maxStacks and self.spellID) then 
			ScenarioBlocksFrame.MawBuffsBlock.Container:HideBuffHighlight(self.spellID);
		end
	end
	GameTooltip:Hide(); 
end

function PlayerChoiceOptionFrameMixin:UpdateOptionSize()
	if self:GetParent():GetNumOptions() == 1 and not self:GetOptionLayoutInfo().forceStandardSize then
		self:SetToWideSize();
	else
		self:SetToStandardSize();
	end
end

function PlayerChoiceOptionFrameMixin:GetOptionLayoutInfo()
	return self:GetParent().optionLayout;
end

function PlayerChoiceOptionFrameMixin:UpdateOptionBorderAtlasBasedOnRarity()
	if (self.rarity == Enum.PlayerChoiceRarity.Common) then
		standardSizeTextureKitRegions.ArtworkBorder = "UI-Frame-%s-Portrait";
		standardSizeTextureKitRegions.ArtworkBorderAdditionalGlow = "UI-Frame-%s-Portrait";
		standardSizeTextureKitRegions.ArtworkBorder2 = "UI-Frame-%s-Portrait-border";
	elseif (self.rarity == Enum.PlayerChoiceRarity.Uncommon) then
		standardSizeTextureKitRegions.ArtworkBorder = "UI-Frame-%s-Portrait-QualityUncommon";
		standardSizeTextureKitRegions.ArtworkBorderAdditionalGlow = "UI-Frame-%s-Portrait-QualityUncommon";
		standardSizeTextureKitRegions.ArtworkBorder2 = "UI-Frame-%s-Portrait-QualityUncommon-border";
	elseif (self.rarity == Enum.PlayerChoiceRarity.Rare) then
		standardSizeTextureKitRegions.ArtworkBorder = "UI-Frame-%s-Portrait-QualityRare";
		standardSizeTextureKitRegions.ArtworkBorderAdditionalGlow = "UI-Frame-%s-Portrait-QualityRare";
		standardSizeTextureKitRegions.ArtworkBorder2 = "UI-Frame-%s-Portrait-QualityRare-border";
	elseif (self.rarity == Enum.PlayerChoiceRarity.Epic) then
		standardSizeTextureKitRegions.ArtworkBorder = "UI-Frame-%s-Portrait-QualityEpic";
		standardSizeTextureKitRegions.ArtworkBorderAdditionalGlow = "UI-Frame-%s-Portrait-QualityEpic";
		standardSizeTextureKitRegions.ArtworkBorder2 = "UI-Frame-%s-Portrait-QualityEpic-border";
	end
end

function PlayerChoiceOptionFrameMixin:UpdateBackgroundGlowAtlasBasedOnRarity()
	if (self.rarity == Enum.PlayerChoiceRarity.Common) then
		standardSizeTextureKitRegions.BackgroundGlow = "UI-Frame-%s-CardParchment-Normal";
	elseif (self.rarity == Enum.PlayerChoiceRarity.Uncommon) then
		standardSizeTextureKitRegions.BackgroundGlow = "UI-Frame-%s-CardParchment-Uncommon";
	elseif (self.rarity == Enum.PlayerChoiceRarity.Rare) then
		standardSizeTextureKitRegions.BackgroundGlow = "UI-Frame-%s-CardParchment-Rare";
	elseif (self.rarity == Enum.PlayerChoiceRarity.Epic) then
		standardSizeTextureKitRegions.BackgroundGlow = "UI-Frame-%s-CardParchment-Epic";
	end
end

function PlayerChoiceOptionFrameMixin:OverrideBackgroundTextureForVariedTextures()
	if(self.layoutIndex > MAXIMUM_VARIED_BACKGROUND_OPTION_TEXTURES) then
		local optionIndex = mod(self.layoutIndex, MAXIMUM_VARIED_BACKGROUND_OPTION_TEXTURES);
		optionBackgroundTextureKitRegions.Background = variedBackgroundTextureKits[optionIndex];
	else
		optionBackgroundTextureKitRegions.Background = variedBackgroundTextureKits[self.layoutIndex];
	end
end

function PlayerChoiceOptionFrameMixin:SetupArtworkForOption()
	local optionLayout = self:GetOptionLayoutInfo();

	local extraPaddingOnArtworkBorder = optionLayout.extraPaddingOnArtworkBorder;
	local width = self.ArtworkBorder:GetWidth() - extraPaddingOnArtworkBorder;
	local height = self.ArtworkBorder:GetHeight() - extraPaddingOnArtworkBorder;

	local artworkBorder = self.ArtworkBorder;
	if (not self.ArtworkBorder:IsShown() and not self.ArtworkBorderDisabled:IsShown()) then
		return;
	end

	artworkBorder:ClearAllPoints();
	self.Artwork:ClearAllPoints();
	self.ArtworkBorderAdditionalGlow:ClearAllPoints();

	if (optionLayout.combineHeaderWithOption) then
		local y = -(height + (optionLayout.artworkBorderYOffset or 15));
		if(self.hasHeader) then
			artworkBorder:SetPoint("BOTTOM", self.Header, 0, y);
		else
			artworkBorder:SetPoint("TOP", 0, y);
		end

		self.Artwork:SetPoint("TOPLEFT", artworkBorder, "TOPLEFT", (width), -(height));
		self.Artwork:SetPoint("BOTTOMRIGHT", artworkBorder, "BOTTOMRIGHT", -(width), (height));
	else
		if(self.hasHeader) then
			artworkBorder:SetPoint("TOP", self.Header, "BOTTOM", 0, -10);
		else
			artworkBorder:SetPoint("TOP", 0, -10);
		end

		self.Artwork:SetPoint("TOPLEFT", artworkBorder, "TOPLEFT", 10, -9);
		self.Artwork:SetPoint("BOTTOMRIGHT", artworkBorder, "BOTTOMRIGHT", -10, 9);
	end
	self.ArtworkBorderAdditionalGlow:SetPoint("CENTER", artworkBorder);


	self.CircleMask:SetShown(optionLayout.showCircleMaskOnArtwork);
end

function PlayerChoiceOptionFrameMixin:SetToStandardSize()
	self:UpdateOptionBorderAtlasBasedOnRarity();
	self:UpdateBackgroundGlowAtlasBasedOnRarity();

	local optionLayout = self:GetOptionLayoutInfo();
	if (optionLayout.usesVariedBackgrounds) then
		self:OverrideBackgroundTextureForVariedTextures();
	else
		optionBackgroundTextureKitRegions.Background = "UI-Frame-%s-CardParchment";
	end

	self:SetupTextureKits(self, standardSizeTextureKitRegions);
	self:SetupTextureKits(self, optionBackgroundTextureKitRegions, self.uiTextureKit);

	self.BackgroundShadowLarge:Hide();

	local textureKit = self.uiTextureKit or self:GetParent().uiTextureKit;
	local backgroundInfo = C_Texture.GetAtlasInfo(GetFinalNameFromTextureKit(optionBackgroundTextureKitRegions.Background, textureKit));

	if (not backgroundInfo) then
		self.Background:SetAtlas("UI-Frame-neutral-CardParchment");
	end

	self.fixedWidth = STANDARD_SIZE_WIDTH + (optionLayout.atlasBackgroundWidthPadding * 2);

	if(optionLayout.standardSizeTextWidthOverride) then
		self.OptionText:SetWidth(optionLayout.standardSizeTextWidthOverride);
	else
		self.OptionText:SetWidth(STANDARD_SIZE_TEXT_WIDTH);
	end

	self.Background:Show();
end

function PlayerChoiceOptionFrameMixin:SetToWideSize()
	local optionLayout = self:GetOptionLayoutInfo();

	self:SetupTextureKits(self, wideSizeTextureKitRegions);
	self.fixedWidth = WIDE_SIZE_WIDTH + (optionLayout.atlasBackgroundWidthPadding * 2);
	self.OptionText:SetWidth(WIDE_SIZE_TEXT_WIDTH);
end

function PlayerChoiceOptionFrameMixin:SetupTextureKits(frame, regions, textureKit)
	self:GetParent():SetupTextureKits(frame, regions, textureKit);
end

function PlayerChoiceOptionFrameMixin:GetPaddingFrame()
	if self.hasRewards then
		return self.RewardsFrame;
	else
		return self.WidgetContainer;
	end
end

-- If we need to make up extra space in this option, adjust the padding frame offset to push it down further and create space
function PlayerChoiceOptionFrameMixin:UpdatePadding(maxOptionHeight)
	local yOffset = 5;

	if maxOptionHeight then
		local optionHeight = self:GetHeight();
		if maxOptionHeight > optionHeight then
			local heightDiff = maxOptionHeight - optionHeight;
			yOffset = heightDiff + 5;
			self:SetHeight(maxOptionHeight);
		end
	end
	self:GetPaddingFrame():SetPoint("TOP", self.OptionText, "BOTTOM", 0, -yOffset);
end

function PlayerChoiceOptionFrameMixin:AddPaddingHeight(addedHeight)
	local paddingFrame = self:GetPaddingFrame();
	paddingFrame:SetHeight(paddingFrame:GetHeight() + addedHeight);
	self:SetHeight(self:GetHeight() + addedHeight);
end

function PlayerChoiceOptionFrameMixin:GetPaddingHeight()
	return self:GetPaddingFrame():GetHeight();
end

function PlayerChoiceOptionFrameMixin:HasWidgets()
	return self.WidgetContainer and self.WidgetContainer:GetNumWidgetsShowing() > 0;
end

local HEADER_TEXT_AREA_WIDTH = 195;

function PlayerChoiceOptionFrameMixin:ConfigureType(typeIconFileId)
	if (typeIconFileId) then
		self.Type:SetTexture(typeIconFileId);
	else
		self.Type:Hide();
	end
end

function PlayerChoiceOptionFrameMixin:ConfigureHeader(header, headerIconAtlasElement)
	if header and #header > 0 then
		if headerIconAtlasElement then
			self.Header.Icon:SetAtlas(headerIconAtlasElement, true);
			self.Header.Icon:Show();
			self.Header.Text:SetWidth(HEADER_TEXT_AREA_WIDTH - (self.Header.Icon:GetWidth() + self.Header.spacing));
		else
			self.Header.Icon:Hide();
			self.Header.Text:SetWidth(HEADER_TEXT_AREA_WIDTH);
		end

		self.Header.Text:SetText(header);

		if self.Header.Text:GetNumLines() > 1 then
			self.Header.Text:SetWidth(self.Header.Text:GetWrappedWidth());
		else
			self.Header.Text:SetWidth(self.Header.Text:GetStringWidth());
		end
		local optionLayout = self:GetOptionLayoutInfo();

		self.Header:ClearAllPoints();
		if (optionLayout and optionLayout.combineHeaderWithOption) then
			self.Header.ignoreInLayout = false;
			self.Header:SetPoint("TOP", self, "TOP", 0, optionLayout.headerYOffset or -60);
		else
			self.Header.ignoreInLayout = true;
			self.Header:SetPoint("BOTTOM", self, "TOP", 0, 15);
		end

		self.Header:Show();
		self.Header:Layout();	-- Force a layout in case it was already shown
		self.hasHeader = true;
	else
		self.Header:Hide();
		self.hasHeader = false;
	end
end

function PlayerChoiceOptionFrameMixin:BeginEffects(modelSceneLayout, highStrataModelScene, backgroundModelScene)
	if (modelSceneLayout) then 
		if (modelSceneLayout.artworkEffectID and not self.artworkEffectController) then 
			self.artworkEffectController = highStrataModelScene:AddEffect(modelSceneLayout.artworkEffectID, self.Artwork);
		end

		if (modelSceneLayout.effectID and not self.backgroundEffectController) then
			self.backgroundEffectController = backgroundModelScene:AddEffect(modelSceneLayout.effectID, self.Background);
		end
	end 
end

function PlayerChoiceOptionFrameMixin:CancelEffects()
	if (self.backgroundEffectController) then 
		self.backgroundEffectController:CancelEffect(); 
		self.backgroundEffectController = nil; 
	end 

	if(self.artworkEffectController) then 
		self.artworkEffectController:CancelEffect(); 
		self.artworkEffectController = nil; 
	end 

	if (self.dialogEffectController) then 
		self.dialogEffectController:CancelEffect(); 
		self.dialogEffectController = nil;
	end 
end 

function PlayerChoiceOptionFrameMixin:UpdateCircleGlowVisibility(shouldShow)
	self.SpinningGlows2:SetShown(shouldShow);
	self.RingGlow:SetShown(shouldShow);
	self.PointBurstLeft:SetShown(shouldShow);
	self.PointBurstRight:SetShown(shouldShow);
end 

function PlayerChoiceOptionFrameMixin:ConfigureSubHeader(subHeader)
	if subHeader then
		self.SubHeader.Text:SetText(subHeader);
		self.SubHeader:Show();
		self.OptionText:SetPoint("TOP", self.SubHeader, "BOTTOM", 0, -12);
	else
		self.SubHeader:Hide();
		local optionLayout = self:GetOptionLayoutInfo();
		local paddingY = (optionLayout.optionYOffset or -20) + optionLayout.extraPaddingOnArtworkBorder;
		self.OptionText:SetPoint("TOP", self.ArtworkBorder, "BOTTOM", 0, paddingY);
	end
end

function PlayerChoiceOptionFrameMixin:OnButtonClick(button)
	if(button.soundKitID) then
		PlaySound(button.soundKitID);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end

	local optionLayout = self:GetParent().optionLayout;
	if ( button.optID ) then
		if ( IsInGroup() and (self.choiceID == GORGROND_GARRISON_ALLIANCE_CHOICE or self.choiceID == GORGROND_GARRISON_HORDE_CHOICE) ) then
			StaticPopup_Show("CONFIRM_GORGROND_GARRISON_CHOICE", nil, nil, { response = button.optID, owner = self:GetParent() });
		elseif (button.confirmation and self.id == THREADS_OF_FATE_RESPONSE) then 
			StaticPopup_Show("CONFIRM_PLAYER_CHOICE_WITH_CONFIRMATION_STRING", button.confirmation, nil, { response = button.optID, owner = self:GetParent(), confirmationString = SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING});
		elseif ( button.confirmation ) then
			local confirmationSoundKit = optionLayout.confirmationOkSoundKit;
			StaticPopup_Show("CONFIRM_PLAYER_CHOICE", button.confirmation, nil, { response = button.optID, owner = self:GetParent(), confirmationSoundkit = confirmationSoundKit});
		else
			SendPlayerChoiceResponse(button.optID);
			local choiceInfo = C_PlayerChoice.GetPlayerChoiceInfo();
			local isSecondButton = button.buttonIndex == 2;

			if (optionLayout.useArtworkGlowOnSelection) then 
				self:UpdateCircleGlowVisibility(true); 
				self.ChoiceSelectedAnimation:Restart(); 
			end 

			local textureKit = self.uiTextureKit or self:GetParent().uiTextureKit;
			if(textureKit) then 
				local modelSceneLayout = choiceModelSceneLayout[textureKit];
				if (modelSceneLayout and modelSceneLayout.makeChoiceEffectID) then 
					self.dialogEffectController = GlobalFXDialogModelScene:AddEffect(modelSceneLayout.makeChoiceEffectID, self.Artwork);
				end 
			end 

			local shouldFadeOutOtherOptions = optionLayout.highlightChoiceBeforeHide; 
			if(shouldFadeOutOtherOptions) then
				self:GetParent():EnableMouse(false);
				self:GetParent():HideOptions(self);
				PlayerChoiceToggleButton:Hide(); 
				C_Timer.After(1.25, function() if(self.FadeoutSelected:IsPlaying()) then self:CancelEffects() end end);
				self.FadeoutSelected:Restart();
				if (optionLayout.fadeOutSoundKitID) then 
					PlaySound(optionLayout.fadeOutSoundKitID)
				end
			elseif (not choiceInfo.keepOpenAfterChoice and (not isSecondButton or not optionLayout.secondButtonClickDoesntCloseUI)) then
				self:GetParent():TryHide();
			end
		end
	end
end

function PlayerChoiceOptionFrameMixin:GetRarityDescriptionString()
	if (self.rarity == Enum.PlayerChoiceRarity.Common) then
		return PLAYER_CHOICE_QUALITY_STRING_COMMON;
	elseif (self.rarity == Enum.PlayerChoiceRarity.Uncommon) then
		return PLAYER_CHOICE_QUALITY_STRING_UNCOMMON;
	elseif (self.rarity == Enum.PlayerChoiceRarity.Rare) then
		return PLAYER_CHOICE_QUALITY_STRING_RARE;
	elseif (self.rarity == Enum.PlayerChoiceRarity.Epic) then
		return PLAYER_CHOICE_QUALITY_STRING_EPIC;
	end
end 

function PlayerChoiceOptionFrameMixin:SetupRarityDescription(description)
	if(not description) then 
		return self:GetRarityDescriptionString();
	else	
		return (self:GetRarityDescriptionString() .. description);
	end 
end 

PlayerChoiceOptionButtonContainerMixin = {};

function PlayerChoiceOptionButtonContainerMixin:OnLoad()
	self.buttonPool = CreateFramePoolCollection();
	self.buttonPool:CreatePool("Button", self, "PlayerChoiceOptionButtonTemplate");
	self.buttonPool:CreatePool("Button", self, "PlayerChoiceOptionMagnifyingGlass");
end

function PlayerChoiceOptionButtonContainerMixin:ConfigureButtons(optionInfo, textureKit)
	if(not self.buttonPool) then 
		return;
	end 
	self.buttonPool:ReleaseAll();

	local parent = self:GetParent();
	local optionLayout = parent:GetOptionLayoutInfo();
	local optionButtonLayout = choiceButtonLayout[textureKit] or choiceButtonLayout["default"];

	self.button1 = self.buttonPool:Acquire(optionButtonLayout.firstButtonTemplate);
	self.button1.buttonIndex = 1;

	if(not optionButtonLayout.firstButtonUseAtlasSize) then
		self.button1:SetWidth(optionLayout.optionButtonOverrideWidth);
	end

	self.button1:ConfigureButton(optionInfo);
	self.button1:SetPoint("TOPLEFT", self, optionButtonLayout.firstButtonOffsetX, optionButtonLayout.firstButtonOffsetY);
	self.button1:Show();

	local buttonContainerOffset = optionInfo.optionsButtonContainerYOffset or 5;
	if optionInfo.secondOptionInfo then
		 self.button2 = self.buttonPool:Acquire(optionButtonLayout.secondButtonTemplate);
		 self.button2.buttonIndex = 2;
		if(not optionButtonLayout.secondButtonUseAtlasSize) then
			self.button2:SetWidth(optionLayout.optionButtonOverrideWidth);
		end

		self.button2:ConfigureButton(optionInfo.secondOptionInfo);
		if PlayerChoiceFrame:GetNumOptions() == 1 or optionButtonLayout.forceSideBySideLayout then
			local xOffset = 40 + optionButtonLayout.secondButtonOffsetX;
			self.button2:SetPoint("LEFT", self.button1, "RIGHT", xOffset, optionButtonLayout.secondButtonOffsetY);
		else
			local yOffset = optionButtonLayout.secondButtonOffsetY - 8;
			self.button2:SetPoint("TOP", self.button1, "BOTTOM", optionButtonLayout.secondButtonOffsetX, yOffset);
		end

		self.button2:Show();
		self.button2:SetAlpha(optionButtonLayout.hideSecondButtonUntilMouseOver and 0 or 1);
	else
		if parent:GetParent().anOptionHasMultipleButtons and not optionButtonLayout.forceSideBySideLayout then
			-- If another option has multiple Buttons and we don't, offset the container more
			buttonContainerOffset = buttonContainerOffset + 30;
		end
	end
	self:ClearAllPoints();
	self:SetPoint("TOP", parent:GetPaddingFrame(), "BOTTOM", 0, -buttonContainerOffset);
end

function PlayerChoiceOptionButtonContainerMixin:DisableButtons()
	for button in self.buttonPool:EnumerateActive() do
		button:Disable();
	end
end

PlayerChoiceOptionButtonMixin = {};

function PlayerChoiceOptionButtonMixin:ConfigureButton(optionInfo)
	self.confirmation = optionInfo.confirmation;
	self.tooltip = optionInfo.buttonTooltip;
	self.rewardQuestID = optionInfo.rewardQuestID;
	self:SetText(optionInfo.buttonText);
	self.optID = optionInfo.responseIdentifier;
	self.soundKitID = optionInfo.soundKitID;
	self:SetEnabled(not optionInfo.disabledButton);
end

function PlayerChoiceOptionButtonMixin:OnEnter()
	if self.tooltip or self.rewardQuestID or self.Text:IsTruncated() then
		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");

		if self.rewardQuestID and not HaveQuestRewardData(self.rewardQuestID) then
			GameTooltip_SetTitle(EmbeddedItemTooltip, RETRIEVING_DATA, RED_FONT_COLOR);
		else
			if self.Text:IsTruncated() then
				GameTooltip_SetTitle(EmbeddedItemTooltip, self.Text:GetText(), nil, true);
			end

			if self.tooltip then
				GameTooltip_AddNormalLine(EmbeddedItemTooltip, self.tooltip, true);
			end

			if self.rewardQuestID then
				GameTooltip_AddQuestRewardsToTooltip(EmbeddedItemTooltip, self.rewardQuestID, TOOLTIP_QUEST_REWARDS_STYLE_QUEST_CHOICE);
			end
		end

		EmbeddedItemTooltip:Show();
	else
		EmbeddedItemTooltip:Hide();
	end

	self.UpdateTooltip = self.OnEnter;
end

function PlayerChoiceOptionButtonMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
	self.UpdateTooltip = nil;
end

PlayerChoiceRewardsMixin = {};

function PlayerChoiceRewardsMixin:OnLoad()
	self.CurrencyRewardsPool = CreateFramePool("FRAME", self, "PlayerChoiceCurrencyTemplate");
	self.ReputationRewardsPool = CreateFramePool("FRAME", self, "PlayerChoiceReputationTemplate");
	self.ItemRewardsPool = CreateFramePool("BUTTON", self, "PlayerChoiceItemTemplate");
end

function PlayerChoiceRewardsMixin:GetItemRewardsFrame(itemReward)
	local itemRewardButton = self.ItemRewardsPool:Acquire();

	if(not self.lastReward) then
		itemRewardButton:SetPoint("TOPLEFT", self, 0, 0);
	else
		itemRewardButton:SetPoint("TOP", self.lastReward, "BOTTOM", 0, -10);
	end

	itemRewardButton.itemID = itemReward.itemId;
	itemRewardButton.Name:SetText(itemReward.name);
	SetItemButtonCount(itemRewardButton, itemReward.quantity);
	SetItemButtonTexture(itemRewardButton, itemReward.textureFileId);
	SetItemButtonQuality(itemRewardButton, itemReward.quality, itemReward.itemId);
	itemRewardButton.itemLink = itemReward.itemLink;
	itemRewardButton.isCurrencyContainer = false;
	itemRewardButton.quantity = nil;
	itemRewardButton:Show();
	return itemRewardButton;
end

function PlayerChoiceRewardsMixin:GetCurrencyContainerRewardsFrame(currencyReward)
	local itemRewardButton = self.ItemRewardsPool:Acquire();

	if(not self.lastReward) then
		itemRewardButton:SetPoint("TOPLEFT", self, 0, 0);
	else
		itemRewardButton:SetPoint("TOPLEFT", self.lastReward, "BOTTOMLEFT", 0, -10);
	end

	local name, texture, displayQuantity, quality;
	name, texture, displayQuantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyReward.currencyId, currencyReward.quantity, name, texture, quality);

	itemRewardButton.itemID = currencyReward.currencyId;
	itemRewardButton.Name:SetText(name);
	SetItemButtonCount(itemRewardButton, displayQuantity);
	SetItemButtonTexture(itemRewardButton, texture);
	SetItemButtonQuality(itemRewardButton, quality);
	itemRewardButton.itemLink = nil;
	itemRewardButton.isCurrencyContainer = true;
	itemRewardButton.quantity = currencyReward.quantity;
	itemRewardButton:Show();
	return itemRewardButton;
end

function PlayerChoiceRewardsMixin:GetCurrencyRewardsFrame(currencyReward)
	local currencyRewardButton = self.CurrencyRewardsPool:Acquire();

	if(not self.lastReward) then
		currencyRewardButton:SetPoint("TOPLEFT", self, 0, 0);
	else
		currencyRewardButton:SetPoint("TOPLEFT", self.lastReward, "BOTTOMLEFT", 0, -10);
	end

	currencyRewardButton.currencyID = currencyReward.currencyId;
	currencyRewardButton.Icon:SetTexture(currencyReward.currencyTexture);
	currencyRewardButton.Quantity:SetText(currencyReward.quantity);
	currencyRewardButton:Show();
	return currencyRewardButton;
end

function PlayerChoiceRewardsMixin:GetReputationRewardsFrame(reputationReward)
	local reputationRewardButton = self.ReputationRewardsPool:Acquire();

	if(not self.lastReward) then
		reputationRewardButton:SetPoint("TOPLEFT", self,  0, 0);
	else
		reputationRewardButton:SetPoint("TOPLEFT", self.lastReward, "BOTTOMLEFT", 0, -10);
	end

	local factionFrame = reputationRewardButton.Faction;
	local amountFrame = reputationRewardButton.Amount;
	local factionName = format(REWARD_REPUTATION, GetFactionInfoByID(reputationReward.factionId));
	factionFrame:SetText(factionName);
	amountFrame:SetText(reputationReward.quantity);
	local amountWidth = amountFrame:GetWidth();
	local factionWidth = factionFrame:GetWidth();
	if ((amountWidth + factionWidth) > REWARDS_WIDTH) then
		factionFrame:SetWidth(REWARDS_WIDTH - amountWidth - 5);
		reputationRewardButton.tooltip = factionName;
	else
		reputationRewardButton.tooltip = nil
	end

	reputationRewardButton:Show();
	return reputationRewardButton;
end

PlayerChoiceToggleButtonMixin = { };
function PlayerChoiceToggleButtonMixin:TryShow()
	PlayerChoiceToggleButton:SetShown(IsInJailersTower() and C_PlayerChoice.IsWaitingForPlayerChoiceResponse());
end

function PlayerChoiceToggleButtonMixin:OnShow()
	self:UpdateButtonState();
end

function PlayerChoiceToggleButtonMixin:OnHide()
	if (self.dialogEffectController) then 
		self.dialogEffectController:CancelEffect();
		self.dialogEffectController = nil; 
	end 
end

function PlayerChoiceToggleButtonMixin:UpdateButtonState()
	if (not C_PlayerChoice.IsWaitingForPlayerChoiceResponse()) then
		self:Hide();
	end

	local choiceInfo = C_PlayerChoice.GetPlayerChoiceInfo();
	if (not choiceInfo or not choiceInfo.uiTextureKit) then
		return;
	end

	self:ClearAllPoints();
	if (self.isPlayerChoiceFrameSetup) then
		self:SetPoint("TOP", PlayerChoiceFrame, "BOTTOM", 0, -70);
	else
		self:SetPoint("CENTER", self:GetParent(), 0, -200);
	end
	self.hasSetPoint = true;

	self.textureKit = choiceInfo.uiTextureKit;
	local overrideTextInfo = hideButtonOverrideInfo[self.textureKit];
	local modelSceneLayout = choiceModelSceneLayout[self.textureKit]; 
	local isPlayerChoiceShowing = PlayerChoiceFrame:IsShown();
	local normalTextureKitInfo = isPlayerChoiceShowing and hideButtonAtlasOptions.SmallButton or hideButtonAtlasOptions.LargeButton;
	local highlightTextureKitInfo = isPlayerChoiceShowing and hideButtonAtlasOptions.SmallButtonHighlight or hideButtonAtlasOptions.LargeButtonHighlight;

	if(self.dialogEffectController) then 
		self.dialogEffectController:CancelEffect();
		self.dialogEffectController = nil; 
	end 

	if(not isPlayerChoiceShowing and modelSceneLayout and modelSceneLayout.extraButtonEffectID) then 
		self.dialogEffectController = GlobalFXMediumModelScene:AddEffect(modelSceneLayout.extraButtonEffectID, self);
	end 
	local normalTextureAtlas = GetFinalNameFromTextureKit(normalTextureKitInfo, self.textureKit);
	local highlightTextureAtlas = GetFinalNameFromTextureKit(highlightTextureKitInfo, self.textureKit);

	self:SetNormalAtlas(normalTextureAtlas);
	self:SetHighlightAtlas(highlightTextureAtlas);

	if (overrideTextInfo) then
		local xOffset = 0;
		if (isPlayerChoiceShowing and overrideTextInfo.playerChoiceShowingTextXOffset) then
			xOffset = overrideTextInfo.playerChoiceShowingTextXOffset;
		elseif (not isPlayerChoiceShowing and overrideTextInfo.playerChoiceHiddenTextXOffset) then
			xOffset = overrideTextInfo.playerChoiceHiddenTextXOffset;
		end
		local yOffset = 0;
		if (isPlayerChoiceShowing and overrideTextInfo.playerChoiceShowingTextYOffset) then
			yOffset = overrideTextInfo.playerChoiceShowingTextYOffset;
		elseif (not isPlayerChoiceShowing and overrideTextInfo.playerChoiceHiddenTextYOffset) then
			yOffset = overrideTextInfo.playerChoiceHiddenTextYOffset;
		end

		self.Text:ClearAllPoints();
		self.Text:SetPoint("CENTER", self, "CENTER", xOffset, yOffset); 
		self.Text:SetText(isPlayerChoiceShowing and overrideTextInfo.playerChoiceShowingText or overrideTextInfo.playerChoiceHiddenText);
		self.Text:Show();
	else
		self.Text:Hide();
	end

	local normalAtlasInfo = C_Texture.GetAtlasInfo(normalTextureAtlas);
	if (normalAtlasInfo) then
		self:SetSize(normalAtlasInfo.width, normalAtlasInfo.height);
	end
end

function PlayerChoiceToggleButtonMixin:OnClick()
	local overrideButtonInfo = hideButtonOverrideInfo[self.textureKit];
	if (PlayerChoiceFrame:IsShown()) then
		if(overrideButtonInfo and overrideButtonInfo.playerChoiceShowingSoundKit) then 
			PlaySound(overrideButtonInfo.playerChoiceShowingSoundKit);
		end 
		PlayerChoiceFrame:TryHide();
	else
		if(overrideButtonInfo and overrideButtonInfo.playerChoiceHiddenSoundKit) then 
			PlaySound(overrideButtonInfo.playerChoiceHiddenSoundKit);
		end 
		PlayerChoiceFrame:TryShow();
	end
	self.FadeIn:Restart();
end

PlayerChoiceOptionTextWrapperMixin = { }

function PlayerChoiceOptionTextWrapperMixin:OnLoad()
	local setWidth = self.SetWidth;
	self.SetWidth = function(self, ...)
		if self.useHTML then
			self.HTML:SetWidth(...);
		else
			self.String:SetWidth(...);
		end
		setWidth(self, ...);
	end
	self:SetUseHTML(true);
end

function PlayerChoiceOptionTextWrapperMixin:SetUseHTML(useHTML)
	self.useHTML = useHTML;
	self.HTML:SetShown(useHTML);
	self.String:SetShown(not useHTML);

	self.textObject = useHTML and self.HTML or self.String;
end

function PlayerChoiceOptionTextWrapperMixin:ClearText()
	self.HTML:SetText(nil);
	self.HTML:SetHeight(0);
	self.String:SetText(nil);
	self.String:SetHeight(0);
	self:SetHeight(10);
end

function PlayerChoiceOptionTextWrapperMixin:SetText(...)
	self.textObject:SetText(...);

	if self.useHTML then
		self:SetHeight(self.HTML:GetHeight());
	end
end

function PlayerChoiceOptionTextWrapperMixin:SetFontObject(...)
	self.textObject:SetFontObject(...);
end

function PlayerChoiceOptionTextWrapperMixin:SetTextColor(...)
	self.textObject:SetTextColor(...);
end

function PlayerChoiceOptionTextWrapperMixin:SetJustifyH(...)
	self.textObject:SetJustifyH(...);
end

function PlayerChoiceOptionTextWrapperMixin:SetStringHeight(height)
	self.String:SetHeight(height);
	self:SetHeight(height);
end
