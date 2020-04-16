local MAX_PLAYER_CHOICE_OPTIONS = 4;
local REWARDS_WIDTH = 200;
local INIT_OPTION_HEIGHT = 370;

local GORGROND_GARRISON_ALLIANCE_CHOICE = 55;
local GORGROND_GARRISON_HORDE_CHOICE = 56;

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
local ANIMA_GLOW_FILE_ID = 3164512; 

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
		SendPlayerChoiceResponse(self.data.response);
		HideUIPanel(self.data.owner);
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
}

local contentTextureKitRegions = {
	["Header"] = "warboard-header-%s",
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
};

local borderLayout = {
	["alliance"] = {
		closeButtonX = 1,
		closeButtonY = 2,
		closeBorderX = 0,
		closeBorderY = 0,
		header = -55,
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
		showTitle = true,
		frameOffsetY = 0, 
	},
	["mechagon"] = { 
		closeButtonX = 3,
		closeButtonY = 3,
		closeBorderX = -1,
		closeBorderY = 1,
		header = 0,
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
		frameOffsetY = 90, 
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
}

local choiceLayout = {
	["default"] = { 
		atlasBackgroundWidthPadding = 0, 
		optionHeightOffset = 0, 
		extraPaddingOnArtworkBorder = 0,
		backgroundYOffset = 0, 
		optionButtonOverrideWidth = 175, 
		optionTextJustifyH = "LEFT",
		offsetBetweenOptions = 0,
	},
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
	},
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
}

local hideButtonOverrideInfo = {
	["jailerstower"] = { playerChoiceShowingText = HIDE, playerChoiceHiddenText = JAILERS_TOWER_PENDING_POWER_SELECTION},
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

PlayerChoiceFrameMixin = { };
function PlayerChoiceFrameMixin:OnLoad()
	BaseLayoutMixin.OnLoad(self);
	self.QuestionText = self.Title.Text;
	self.optionInitHeight = INIT_OPTION_HEIGHT;
end

function PlayerChoiceFrameMixin:OnEvent(event)
	if (event == "PLAYER_DEAD" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_CHOICE_CLOSE") then
		self:TryHide(); 
	end
end

function PlayerChoiceFrameMixin:OnShow()
	BaseLayoutMixin.OnLoad(self);
	FrameUtil.RegisterFrameForEvents(self, PLAYER_CHOICE_FRAME_EVENTS);

	local choiceInfo = C_PlayerChoice.GetPlayerChoiceInfo();

	if(choiceInfo and choiceInfo.soundKitID) then 
		PlaySound(choiceInfo.soundKitID);
	else 
		PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
	end 

	--TODO: AChurchill Change this section when you work on the maw buffs.
	if IsInJailersTower() then
		if MawBuffsContainer then
			MawBuffsContainer.List:Show()
			MawBuffsContainer:Disable()
			MawBuffsContainer.Icon:SetDesaturated(true)
		end
	end
end

function PlayerChoiceFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_QUEST_LIST_CLOSE);
	ClosePlayerChoice();
	StaticPopup_Hide("CONFIRM_GORGROND_GARRISON_CHOICE");

	FrameUtil.UnregisterFrameForEvents(self, PLAYER_CHOICE_FRAME_EVENTS);

	for i = 1, #self.Options do
		local option = self.Options[i];
		self:UpdateOptionWidgetRegistration(option, nil);
	end

	if IsInJailersTower() then
		if MawBuffsContainer then
			MawBuffsContainer.List:Hide()
			MawBuffsContainer:Enable()
			MawBuffsContainer.Icon:SetDesaturated(false)
		end
	end

	if(PlayerChoiceToggleButton:IsShown()) then
		PlayerChoiceToggleButton:UpdateButtonState(); 
	end 
end

function PlayerChoiceFrameMixin:SetupTextureKits(frame, regions, overrideTextureKit)
	SetupTextureKitOnRegions(overrideTextureKit or self.uiTextureKit, frame, regions, self.setAtlasVisibility, TextureKitConstants.UseAtlasSize);
end

function PlayerChoiceFrameMixin:OnFadeOutFinished()
	HideUIPanel(self); 
end 

function PlayerChoiceFrameMixin:TryHide()
	if(self.optionLayout.animateFrameInAndOut) then 
		self.FadeOut:Play(); 
	else 
		HideUIPanel(self);
	end 
end 

function PlayerChoiceFrameMixin:TryShow()
	local choiceInfo = C_PlayerChoice.GetPlayerChoiceInfo();

	self.uiTextureKit = choiceInfo.uiTextureKit or DEFAULT_TEXTURE_KIT;
	local layout = borderLayout[self.uiTextureKit] or borderLayout["neutral"];
	self.optionLayout = choiceLayout[self.uiTextureKit] or choiceLayout["default"];
	self.optionInitHeight = INIT_OPTION_HEIGHT - self.optionLayout.optionHeightOffset;

	self:SetPoint("CENTER", 0, layout.frameOffsetY); 
	self:AdjustFramePaddingForCustomChoicePadding();

	self.setAtlasVisibility = layout.setAtlasVisibility;

	self:SetupTextureKits(self.Title, titleTextureKitRegions);
	self:SetupTextureKits(self.Background, backgroundTextureKitRegions);

	self.optionDescriptionColor = WARBOARD_OPTION_TEXT_COLOR;
	self.optionHeaderTitleColor = BLACK_FONT_COLOR;
	
	local textureKitFontProperties = textureFontProperties[self.uiTextureKit];
	if textureKitFontProperties then
		self.optionDescriptionColor = textureKitFontProperties.description;
		self.optionHeaderTitleColor = textureKitFontProperties.title;
		if(textureKitFontProperties.titleFont) then 
			self.optionTitleFont = textureKitFontProperties.titleFont;
		else 
			self.optionTitleFont = SystemFont_Large;
		end
		if(textureKitFontProperties.descriptionFont) then 
			self.optionDescriptionFont = textureKitFontProperties.descriptionFont;
		else 
			self.optionDescriptionFont = GameFontBlack;
		end 
	end

	SetupBorder(self, layout, self.uiTextureKit);

	if(choiceInfo.hideWarboardHeader) then 
		self.BorderFrame.Header:Hide(); 
	end 

	for _, option in pairs(self.Options) do
		option.Header.Text:SetFontObject(self.optionTitleFont)
		option.Header.Text:SetTextColor(self.optionHeaderTitleColor:GetRGBA()); 
		option.OptionText:SetFontObject(self.optionDescriptionFont); 
		option.OptionText:SetTextColor(self.optionDescriptionColor:GetRGBA());
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

local function IsTopWidget(widgetFrame)
	return widgetFrame.widgetType == Enum.UIWidgetVisualizationType.SpellDisplay;
end

local function WidgetsLayout(widgetContainer, sortedWidgets)
	local widgetsHeight = 0;
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

		widgetsHeight = widgetsHeight + widgetFrame:GetWidgetHeight();

		local widgetWidth = widgetFrame:GetWidgetWidth();
		if widgetWidth > maxWidgetWidth then
			maxWidgetWidth = widgetWidth;
		end
	end

	if lastTopWidget and lastBottomWidget then
		widgetsHeight = widgetsHeight + 20;
	end

	widgetsHeight = math.max(widgetsHeight, 1);
	maxWidgetWidth = math.max(maxWidgetWidth, 1);
	widgetContainer:SetHeight(widgetsHeight);
	widgetContainer:SetWidth(maxWidgetWidth);
end

function PlayerChoiceFrameMixin:WidgetLayout(widgetContainer, sortedWidgets)
	WidgetsLayout(widgetContainer, sortedWidgets);
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

	option.WidgetContainer:RegisterForWidgetSet(widgetSetID,  function(...) self:WidgetLayout(...) end, function(...) self:WidgetInit(...) end);
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
	local shouldShowTitle = layout.showTitle; 
	for i, option in ipairs(self.Options) do
		if i > self.numActiveOptions then
			self:UpdateOptionWidgetRegistration(option, nil);
			option:Hide();
		else
			option:ResetOption(); 

			local optionInfo = self.optionData[i];
			option.rarity = optionInfo.rarity;

			option.hasDesaturatedArt = optionInfo.desaturatedArt;
			option.Artwork:SetDesaturated(option.hasDesaturatedArt);
			option.ArtworkBorder:SetShown(not option.hasDesaturatedArt and optionInfo.choiceArtID > 0 );
			option.ArtworkBorderDisabled:SetShown(option.hasDesaturatedArt);
			option.uiTextureKit = optionInfo.uiTextureKit; 
			
			option:ConfigureHeader(optionInfo.header, optionInfo.headerIconAtlasElement);
			option:UpdateOptionSize();
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
			option.OptionButtonsContainer:ClearAllPoints(); 
			option.OptionButtonsContainer:SetPoint("TOP", option:GetPaddingFrame(), "BOTTOM", 0, -5);
			option.OptionButtonsContainer:ConfigureButtons(optionInfo, self.uiTextureKit);

			-- We want to override the texture text color if this is jailers tower.
			if(self.uiTextureKit == "jailerstower") then 
				option.Header.Text:SetTextColor(BAG_ITEM_QUALITY_COLORS[option.rarity + RARITY_OFFSET]:GetRGBA()); 
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

			option:Show();

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
 
	-- title needs to reach across
	if lastActiveOption and shouldShowTitle then
		self.Title:SetPoint("RIGHT", lastActiveOption, "RIGHT", 15, -50);
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
		local optionFrameRewards = self["Option"..i].Rewards;
		local rewardInfo = C_PlayerChoice.GetPlayerChoiceRewardInfo(i);

		if rewardInfo then 
			optionFrameRewards.ItemRewardsPool:ReleaseAll(); 
			optionFrameRewards.CurrencyRewardsPool:ReleaseAll(); 
			optionFrameRewards.ReputationRewardsPool:ReleaseAll(); 
			optionFrameRewards.lastReward = nil;
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

			optionFrameRewards:MarkDirty(); 
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
	local modifiedClick = IsModifiedClick();
	if ( modifiedClick ) then
		HandleModifiedItemClick(self.itemLink);
	end
end

PlayerChoiceOptionFrameMixin = {};

function PlayerChoiceOptionFrameMixin:ResetOption()
	self.Background:SetScale(1); 
	self.Background:SetAlpha(1);

	self.ArtworkBorder:SetRotation(0);	
	self.ArtworkBorder:SetAlpha(1); 
	self.ArtworkBorder:SetAtlas("UI-Frame-Horde-Portrait", true);
	self.ArtworkBorder:ClearAllPoints(); 
	self.ArtworkBorder:SetPoint("TOP");

	self.ArtworkBorderAdditionalGlow:SetRotation(0); 
	self.ArtworkBorderAdditionalGlow:SetAlpha(1);

	self.BackgroundGlow:Hide();
	self.ArtworkBorder2:Hide(); 
	self.BackgroundShadowSmall:Hide(); 
	self.BackgroundShadowLarge:Hide(); 
	self.RotateArtworkBorderAnimation:Stop(); 
	self.ArtworkBorderGlowAnimation:Stop();  
	local layoutInfo = self:GetOptionLayoutInfo(); 
	local optionButtonLayout = choiceButtonLayout[self:GetParent().uiTextureKit] or choiceButtonLayout["default"];
	self.OptionButtonsContainer:SetShown(not optionButtonLayout.hideOptionButtonsUntilMouseOver); 
	self:GetPaddingFrame():SetHeight(1); 
	self:UpdatePadding(1);
end 

function PlayerChoiceOptionFrameMixin:UpdateMouseOverStateOnOption()
	local mouseOver = RegionUtil.IsDescendantOfOrSame(GetMouseFocus(), self);
	self:SetDrawLayerEnabled("HIGHLIGHT", mouseOver);

	-- OnLeave logic
	if not mouseOver then
		self:SetScript("OnUpdate", nil);
		self:OnLeaveOverride(); 
	end
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

	if(self:GetOptionLayoutInfo().enlargeBackgroundOnMouseOver) then 
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

	if(optionButtonLayout.hideOptionButtonsUntilMouseOver) then 
		self.Background:Show(); 
		self.BlackBackground:Hide(); 
		self.ScrollingBG:SetAlpha(0);
		self.ScrollingBackgroundScroll:Stop(); 
		self.OptionButtonsContainer:Hide(); 
		self.BackgroundShadowSmall:Show(); 
		self.BackgroundShadowLarge:Hide(); 
		self:SetFrameLevel(200); 
		self:Layout();
	end 

	
	if(self:GetOptionLayoutInfo().enlargeBackgroundOnMouseOver) then 		 
		self.Background:SetScale(1); 
	end

	self.BackgroundGlowAnimationOut:Play(); 

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
	local artworkBorder;

	local extraPaddingOnArtworkBorder = optionLayout.extraPaddingOnArtworkBorder;
	local width, height = self.ArtworkBorder:GetSize();
	height = height - (extraPaddingOnArtworkBorder);
	width = width - (extraPaddingOnArtworkBorder);

	if(self.ArtworkBorder:IsShown()) then 
		artworkBorder = self.ArtworkBorder; 
	elseif(self.ArtworkBorderDisabled:IsShown()) then 
		artworkBorder = self.ArtworkBorderDisabled; 
	end 

	if(not artworkBorder) then 
		return; 
	end 

	artworkBorder:ClearAllPoints(); 
	self.Artwork:ClearAllPoints();
	self.ArtworkBorderAdditionalGlow:ClearAllPoints(); 

	if (optionLayout.combineHeaderWithOption) then 
		if(self.hasHeader) then 
			artworkBorder:SetPoint("BOTTOM", self.Header, 0, -(height + 15));
		else 
			artworkBorder:SetPoint("TOP", 0, -(height + 15));
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
	if (self.hasRewards) then 
		return self.Rewards; 
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
			self.Header:SetPoint("TOP", self, "TOP", 0, -60);
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

function PlayerChoiceOptionFrameMixin:ConfigureSubHeader(subHeader)
	if subHeader then
		self.SubHeader.Text:SetText(subHeader);
		self.SubHeader:Show();
		self.OptionText:SetPoint("TOP", self.SubHeader, "BOTTOM", 0, -12);
	else
		self.SubHeader:Hide();
		local optionLayout = self:GetOptionLayoutInfo(); 
		local paddingY = -20 + optionLayout.extraPaddingOnArtworkBorder; 
		self.OptionText:SetPoint("TOP", self.ArtworkBorder, "BOTTOM", 0, paddingY);
	end
end

function PlayerChoiceOptionFrameMixin:OnButtonClick(button)
	if(button.soundKitID) then 
		PlaySound(button.soundKitID);
	else 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end

	if ( button.optID ) then
		if ( IsInGroup() and (self.choiceID == GORGROND_GARRISON_ALLIANCE_CHOICE or self.choiceID == GORGROND_GARRISON_HORDE_CHOICE) ) then
			StaticPopup_Show("CONFIRM_GORGROND_GARRISON_CHOICE", nil, nil, { response = button.optID, owner = self:GetParent() });
		elseif ( button.confirmation ) then
			StaticPopup_Show("CONFIRM_PLAYER_CHOICE", button.confirmation, nil, { response = button.optID, owner = self:GetParent() });
		else
			SendPlayerChoiceResponse(button.optID);
			local choiceInfo = C_PlayerChoice.GetPlayerChoiceInfo();
			local optionLayout = self:GetParent().optionLayout;
			local isSecondButton = button.buttonIndex == 2; 

			if (not choiceInfo.keepOpenAfterChoice and (not isSecondButton or not optionLayout.secondButtonClickDoesntCloseUI)) then
				self:GetParent():TryHide(); 
			end
		end
	end
end

PlayerChoiceOptionButtonContainerMixin = {};

function PlayerChoiceOptionButtonContainerMixin:OnLoad()
	ResizeLayoutMixin.OnLoad(self);
	self.buttonPool = CreateFramePoolCollection();
	self.buttonPool:CreatePool("Button", self, "PlayerChoiceOptionButtonTemplate");
	self.buttonPool:CreatePool("Button", self, "PlayerChoiceOptionMagnifyingGlass");
end

function PlayerChoiceOptionButtonContainerMixin:ConfigureButtons(optionInfo, textureKit)
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

	local buttonContainerOffset = 5;
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
			buttonContainerOffset = 35;
		end
	end
	self:SetPoint("TOP", parent:GetPaddingFrame(), "BOTTOM", 0, -buttonContainerOffset);
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
	ResizeLayoutMixin.OnLoad(self);

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
	local IsInJailersTower = IsInJailersTower();
	PlayerChoiceToggleButton:SetShown(IsInJailersTower);
end 

function PlayerChoiceToggleButtonMixin:OnShow() 
	self:UpdateButtonState(); 
end 

function PlayerChoiceToggleButtonMixin:UpdateModelScene(scene, sceneID, fileID, forceUpdate)
	if (not scene) then
		return;
	end

	scene:Show();
	scene:SetFromModelSceneID(sceneID, forceUpdate);
	local effect = scene:GetActorByTag("effect");
	if (effect) then
		effect:SetModelByFileID(fileID);
	end
end


function PlayerChoiceToggleButtonMixin:UpdateButtonState()
	if (not C_PlayerChoice.IsWaitingForPlayerChoiceResponse()) then 
		self:Hide();
	end 

	local choiceInfo = C_PlayerChoice.GetPlayerChoiceInfo();
	if(not choiceInfo or not choiceInfo.uiTextureKit) then 
		return;
	end

	self:ClearAllPoints(); 
	if(self.isPlayerChoiceFrameSetup) then 
		self:SetPoint("TOP", PlayerChoiceFrame, "BOTTOM", 0, -70);
	else 
		self:SetPoint("CENTER", self:GetParent(), 0, -300);
	end 

	local textureKit = choiceInfo.uiTextureKit;
	local overrideTextInfo = hideButtonOverrideInfo[textureKit]; 
	local isPlayerChoiceShowing = PlayerChoiceFrame:IsShown(); 
	local normalTextureKitInfo = isPlayerChoiceShowing and hideButtonAtlasOptions.SmallButton or hideButtonAtlasOptions.LargeButton;
	local highlightTextureKitInfo = isPlayerChoiceShowing and hideButtonAtlasOptions.SmallButtonHighlight or hideButtonAtlasOptions.LargeButtonHighlight;

	if(not isPlayerChoiceShowing) then 
		self:UpdateModelScene(self.GlowySphereModelScene, ANIMA_GLOW_MODEL_SCENE_ID, ANIMA_GLOW_FILE_ID, true);
	else
		self.GlowySphereModelScene:Hide(); 
	end
	local normalTextureAtlas = GetFinalNameFromTextureKit(normalTextureKitInfo, textureKit); 
	local highlightTextureAtlas = GetFinalNameFromTextureKit(highlightTextureKitInfo, textureKit); 

	self:SetNormalAtlas(normalTextureAtlas);
	self:SetHighlightAtlas(highlightTextureAtlas);

	if(overrideTextInfo) then
		self.Text:SetText(isPlayerChoiceShowing and overrideTextInfo.playerChoiceShowingText or overrideTextInfo.playerChoiceHiddenText);
		self.Text:Show(); 
	else 
		self.Text:Hide();
	end 

	local normalAtlasInfo = C_Texture.GetAtlasInfo(normalTextureAtlas); 
	if(normalAtlasInfo) then 
		self:SetSize(normalAtlasInfo.width, normalAtlasInfo.height);
	end
end 

function PlayerChoiceToggleButtonMixin:OnClick()
	if(not PlayerChoiceFrame:IsShown()) then 
		PlayerChoiceFrame:TryShow();
		self.FadeIn:Play(); 
	else 
		PlayerChoiceFrame:TryHide(); 
		self.FadeOutAndIn:Play(); 
	end
end 