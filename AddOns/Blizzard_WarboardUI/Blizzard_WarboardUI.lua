
local STANDARD_SIZE_TEXT_WIDTH = 196;
local STANDARD_SIZE_WIDTH = 240;

local WIDE_SIZE_TEXT_WIDTH = 356;
local WIDE_SIZE_WIDTH = 501;

local SOLO_OPTION_WIDTH = 500;

local HEADER_SHOWN_ARTWORK_OFFSET_Y = -38;
local HEADER_SHOWN_STATIC_HEIGHT = 220;

local HEADER_HIDDEN_ARTWORK_OFFSET_Y = -19;
local HEADER_HIDDEN_STATIC_HEIGHT = 299;

local HEADERS_SHOWN_TOP_PADDING = 123;
local HEADERS_HIDDEN_TOP_PADDING = 150;

WarboardQuestChoiceFrameMixin = CreateFromMixins(QuestChoiceFrameMixin);

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
	["ArtworkBorderDisabled"] = "UI-Frame-%s-PortraitDisable",
	["Background"] = "UI-Frame-%s-CardParchment",
};

local wideSizeTextureKitRegions = {
	["ArtworkBorder"] = "UI-Frame-%s-PortraitWider",
	["ArtworkBorderDisabled"] = "UI-Frame-%s-PortraitWiderDisable",
	["Background"] = "UI-Frame-%s-CardParchmentWider",
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

local textureKitColors = {
	["alliance"] = {
		title = CreateColor(0.008, 0.051, 0.192),
		description = CreateColor(0.082, 0.165, 0.373),
	},
	["horde"] = {
		title = CreateColor(0.192, 0.051, 0.008),
		description = CreateColor(0.412, 0.020, 0.020),
	},
};

local borderFrameTextureKitRegions = {
	["Header"] = "UI-Frame-%s-Header",
	["TopRightCorner"] = "UI-Frame-%s-Corner",
	["TopLeftCorner"] = "UI-Frame-%s-Corner",
	["BottomLeftCorner"] = "UI-Frame-%s-Corner",
	["BottomRightCorner"] = "UI-Frame-%s-Corner",
	["TopEdge"] = "_UI-Frame-%s-TileTop",
	["BottomEdge"] = "_UI-Frame-%s-TileBottom",
	["LeftEdge"] = "!UI-Frame-%s-TileLeft",
	["RightEdge"] = "!UI-Frame-%s-TileRight",
	["CloseButtonBorder"] = "UI-Frame-%s-ExitButtonBorder",
};

-- NOTE: Because the nineSlice is themed, the offsets may not be able to remain the same, ideally the artwork will be set up so that this isn't a problem
AnchorUtil.AddNineSliceLayout("WarboardTextureKit", {
	mirrorLayout = true,
	TopLeftCorner =	{ atlas = borderFrameTextureKitRegions["TopLeftCorner"], x = -6, y = 6, },
	TopRightCorner =	{ atlas = borderFrameTextureKitRegions["TopRightCorner"], x = 6, y = 6, },
	BottomLeftCorner =	{ atlas = borderFrameTextureKitRegions["BottomLeftCorner"], x = -6, y = -6, },
	BottomRightCorner =	{ atlas = borderFrameTextureKitRegions["BottomRightCorner"], x = 6, y = -6, },
	TopEdge = { atlas = borderFrameTextureKitRegions["TopEdge"], },
	BottomEdge = { atlas = borderFrameTextureKitRegions["BottomEdge"], mirrorLayout = false, },
	LeftEdge = { atlas = borderFrameTextureKitRegions["LeftEdge"], },
	RightEdge = { atlas = borderFrameTextureKitRegions["RightEdge"], mirrorLayout = false, },
});

local borderLayout = {
	["alliance"] = { closeX = 0, closeY = 0, header = -55, showHeader = true, },
	["horde"] = { closeX = -1, closeY = 1, header = -61, showHeader = true, },
	["neutral"] = { closeX = -1, closeY = 1, header = 0, showHeader = false, },
}

local function SetupBorder(self, layout, textureKit)
	AnchorUtil.ApplyNineSliceLayoutByName(self.NineSlice, "WarboardTextureKit", textureKit);

	self.BorderFrame.Header:SetPoint("BOTTOM", self.BorderFrame, "TOP", 0, layout.header);
	self.BorderFrame.Header:SetShown(layout.showHeader);

	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, borderFrameTextureKitRegions.CloseButtonBorder, layout.closeX, layout.closeY, textureKit);
	self.CloseButton:SetFrameLevel(510);
end

function WarboardQuestChoiceFrameMixin:OnLoad()
	self.QuestionText = self.Title.Text;
	self.initOptionHeight = 439;
	self.initWindowHeight = 549;
	self.initOptionBackgroundHeight = 439;
	self.initOptionHeaderTextHeight = 0;

	QuestChoiceFrameMixin.OnLoad(self);
end

-- Adding this as this frame does not show rewards, so disabling the function to avoid lua errors from missing elements.
function WarboardQuestChoiceFrameMixin:ShowRewards(numChoices)
end

function WarboardQuestChoiceFrameMixin:SetupTextureKits(frame, regions)
	local setVisibilityOfRegions = nil;
	local useAtlasSize = true;
	SetupTextureKits(self.uiTextureKitID, frame, regions, setVisibilityOfRegions, useAtlasSize);
end

function WarboardQuestChoiceFrameMixin:TryShow()
	local choiceInfo = C_QuestChoice.GetQuestChoiceInfo();
	self.uiTextureKitID = choiceInfo.uiTextureKitID;

	self:SetupTextureKits(self.BorderFrame, borderFrameTextureKitRegions);
	self:SetupTextureKits(self.Title, titleTextureKitRegions);
	self:SetupTextureKits(self.Background, backgroundTextureKitRegions);

	self.BorderFrame.Header:SetShown(not choiceInfo.hideWarboardHeader);
	self.optionDescriptionColor = WARBOARD_OPTION_TEXT_COLOR;
	self.optionHeaderTitleColor = BLACK_FONT_COLOR;
	local textureKit = GetUITextureKitInfo(choiceInfo.uiTextureKitID);
	local textureKitColor = textureKitColors[textureKit];
	if textureKitColor then
		self.optionDescriptionColor = textureKitColor.description;
		self.optionHeaderTitleColor = textureKitColor.title;
	end

	local layout = borderLayout[textureKit] or borderLayout["neutral"];
	SetupBorder(self, layout, textureKit);

	for _, option in pairs(self.Options) do
		option.OptionText:SetTextColor(self.optionDescriptionColor:GetRGBA());
		option.Header.Text:SetTextColor(self.optionHeaderTitleColor:GetRGBA());
	end

	QuestChoiceFrameMixin.TryShow(self);
end

function WarboardQuestChoiceFrameMixin:OnHeightChanged(heightDiff)
	for _, option in pairs(self.Options) do
		option.Background:SetHeight(self.initOptionBackgroundHeight + heightDiff);
	end
end

function WarboardQuestChoiceFrameMixin:Update()
	QuestChoiceFrameMixin.Update(self);

	local hasHeaders = false;
	local numOptions = self:GetNumOptions();
	for i = 1, numOptions do
		local option = self.Options[i];
		option.Artwork:SetDesaturated(option.hasDesaturatedArt);
		option.ArtworkBorder:SetShown(not option.hasDesaturatedArt);
		option.ArtworkBorderDisabled:SetShown(option.hasDesaturatedArt);
		if not hasHeaders then
			hasHeaders = option.Header:IsShown();
		end
		option:SetupTextureKits(option.Header, contentHeaderTextureKitRegions);
		if option.hasDesaturatedArt then
			option:SetupTextureKits(option.SubHeader, contentSubHeaderTextureKitRegionsDisabled);
		else
			option:SetupTextureKits(option.SubHeader, contentSubHeaderTextureKitRegions);
		end
	end

	-- resize solo options of standard size
	local lastOption = self.Options[numOptions];
	if numOptions == 1 and not lastOption.isWide then
		lastOption:SetWidth(SOLO_OPTION_WIDTH);
	end
	-- title needs to reach across
	self.Title:SetPoint("RIGHT", lastOption, "RIGHT", 3, 0);

	if hasHeaders then
		self.topPadding = HEADERS_HIDDEN_TOP_PADDING;
	else
		self.topPadding = HEADERS_SHOWN_TOP_PADDING;
	end

	self:Layout();

	local showWarfrontHelpbox = false;
	if C_Scenario.IsInScenario() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WARFRONT_CONSTRUCTION) then
		local scenarioType = select(10, C_Scenario.GetInfo());
		showWarfrontHelpbox = scenarioType == LE_SCENARIO_TYPE_WARFRONT;
	end
	if showWarfrontHelpbox then
		self.WarfrontHelpBox:SetHeight(25 + self.WarfrontHelpBox.BigText:GetHeight());
		self.WarfrontHelpBox:Show();
	else
		self.WarfrontHelpBox:Hide();
	end
end

WarboardQuestChoiceOptionFrameMixin = CreateFromMixins(QuestChoiceOptionFrameMixin);

function WarboardQuestChoiceOptionFrameMixin:ConfigureButtons()
	local parent = self:GetParent();
	local secondButton = self.OptionButtonsContainer.OptionButton2;
	if self.hasMultipleButtons then
		secondButton:Show();
		secondButton:ClearAllPoints();
		local firstButton = self.OptionButtonsContainer.OptionButton1;
		if self:GetParent():GetNumOptions() == 1 then
			self.OptionButtonsContainer:SetSize(parent.optionButtonWidth * 2 + parent.optionButtonHorizontalSpacing, parent.optionButtonHeight);
			secondButton:SetPoint("LEFT", firstButton, "RIGHT", parent.optionButtonHorizontalSpacing, 0);
			self:SetToWideSize();
		else
			self.OptionButtonsContainer:SetSize(parent.optionButtonWidth, parent.optionButtonHeight * 2 + parent.optionButtonVerticalSpacing);
			secondButton:SetPoint("TOP", firstButton, "BOTTOM", 0, -parent.optionButtonVerticalSpacing);
			self:SetToStandardSize();
		end
	else
		if self:GetParent():GetNumOptions() == 1 then
			self:SetToWideSize();
		else
			self:SetToStandardSize();
		end
		secondButton:Hide();
		self.OptionButtonsContainer:SetSize(parent.optionButtonWidth, parent.optionButtonHeight);
	end
end

function WarboardQuestChoiceOptionFrameMixin:SetupTextureKits(frame, regions)
	self:GetParent():SetupTextureKits(frame, regions);
end

function WarboardQuestChoiceOptionFrameMixin:SetToStandardSize()
	self:SetupTextureKits(self, standardSizeTextureKitRegions);
	self.OptionText:SetWidth(STANDARD_SIZE_TEXT_WIDTH);
	self:SetWidth(STANDARD_SIZE_WIDTH);
	self.isWide = false;
end

function WarboardQuestChoiceOptionFrameMixin:SetToWideSize()
	self:SetupTextureKits(self, wideSizeTextureKitRegions);
	self.OptionText:SetWidth(WIDE_SIZE_TEXT_WIDTH);
	self:SetWidth(WIDE_SIZE_WIDTH);
	self.isWide = true;
end

function WarboardQuestChoiceOptionFrameMixin:ConfigureHeader(header, headerIconAtlasElement)
	QuestChoiceOptionFrameMixin.ConfigureHeader(self, header, headerIconAtlasElement);

	if self.Header:IsShown() then
		self.ArtworkBorder:SetPoint("TOP", 0, HEADER_SHOWN_ARTWORK_OFFSET_Y);
		self:GetParent().optionStaticHeight = HEADER_SHOWN_STATIC_HEIGHT;
	else
		self.ArtworkBorder:SetPoint("TOP", 0, HEADER_HIDDEN_ARTWORK_OFFSET_Y);
		self:GetParent().optionStaticHeight = HEADER_HIDDEN_STATIC_HEIGHT;
	end
end

function WarboardQuestChoiceOptionFrameMixin:ConfigureSubHeader(subHeader)
	if subHeader then
		self.SubHeader.Text:SetText(subHeader);
		self.SubHeader:Show();
		self.OptionText:SetPoint("TOP", self.SubHeader, "BOTTOM", 0, -12);
	else
		self.SubHeader:Hide();
		self.OptionText:SetPoint("TOP", self.ArtworkBorder, "BOTTOM", 0, -12);
	end
end
