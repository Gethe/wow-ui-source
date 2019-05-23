local STANDARD_SIZE_TEXT_WIDTH = 196;
local STANDARD_SIZE_WIDTH = 240;

local WIDE_SIZE_TEXT_WIDTH = 356;
local WIDE_SIZE_WIDTH = 501;

local HEADERS_SHOWN_TOP_PADDING = 185;
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
	["marine"] = {
		title = CreateColor(0.192, 0.051, 0.008),
		description = CreateColor(0.192, 0.051, 0.008),
	},
	["mechagon"] = {
		title = CreateColor(0.969, 0.855, 0.667),
		description = CreateColor(0.969, 0.855, 0.667),
	},
};

local borderFrameTextureKitRegions = {
	["Header"] = "UI-Frame-%s-Header",
	["Corner"] = "UI-Frame-%s-Corner",
	["TopRightCorner"] = "UI-Frame-%s-CornerTopRight",
	["TopLeftCorner"] = "UI-Frame-%s-Corner",
	["BottomLeftCorner"] = "UI-Frame-%s-CornerBottomLeft",
	["BottomRightCorner"] = "UI-Frame-%s-CornerBottomRight",
	["TopEdge"] = "_UI-Frame-%s-TileTop",
	["BottomEdge"] = "_UI-Frame-%s-TileBottom",
	["LeftEdge"] = "!UI-Frame-%s-TileLeft",
	["RightEdge"] = "!UI-Frame-%s-TileRight",
	["CloseButtonBorder"] = "UI-Frame-%s-ExitButtonBorder",
};

-- NOTE: Because the nineSlice is themed, the offsets may not be able to remain the same, ideally the artwork will be set up so that this isn't a problem
NineSliceUtil.AddLayout("WarboardTextureKit", {
	mirrorLayout = true,
	TopLeftCorner =	{ atlas = borderFrameTextureKitRegions["Corner"], x = -6, y = 6, },
	TopRightCorner =	{ atlas = borderFrameTextureKitRegions["Corner"], x = 6, y = 6, },
	BottomLeftCorner =	{ atlas = borderFrameTextureKitRegions["Corner"], x = -6, y = -6, },
	BottomRightCorner =	{ atlas = borderFrameTextureKitRegions["Corner"], x = 6, y = -6, },
	TopEdge = { atlas = borderFrameTextureKitRegions["TopEdge"], },
	BottomEdge = { atlas = borderFrameTextureKitRegions["BottomEdge"], mirrorLayout = false, },
	LeftEdge = { atlas = borderFrameTextureKitRegions["LeftEdge"], },
	RightEdge = { atlas = borderFrameTextureKitRegions["RightEdge"], mirrorLayout = false, },
});

NineSliceUtil.AddLayout("WarboardTextureKit_FourCorners", {
	mirrorLayout = true,
	TopLeftCorner =	{ atlas = borderFrameTextureKitRegions["TopLeftCorner"], x = -6, y = 6, },
	TopRightCorner =	{ atlas = borderFrameTextureKitRegions["TopRightCorner"], x = 6, y = 6, mirrorLayout = false},
	BottomLeftCorner =	{ atlas = borderFrameTextureKitRegions["BottomLeftCorner"], x = -6, y = -6, mirrorLayout = false},
	BottomRightCorner =	{ atlas = borderFrameTextureKitRegions["BottomRightCorner"], x = 6, y = -6, mirrorLayout = false},
	TopEdge = { atlas = borderFrameTextureKitRegions["TopEdge"], },
	BottomEdge = { atlas = borderFrameTextureKitRegions["BottomEdge"], mirrorLayout = false, },
	LeftEdge = { atlas = borderFrameTextureKitRegions["LeftEdge"], },
	RightEdge = { atlas = borderFrameTextureKitRegions["RightEdge"], mirrorLayout = false, },
});

local nineSliceLayout = {
	["marine"] = "WarboardTextureKit_FourCorners",
}

local borderLayout = {
	["alliance"] = { closeButtonX = 1, closeButtonY = 2, closeBorderX = 0, closeBorderY = 0, header = -55, showHeader = true, },
	["horde"] = { closeButtonX = 1, closeButtonY = 2, closeBorderX = -1, closeBorderY = 1, header = -61, showHeader = true, },
	["marine"] = { closeButtonX = 3, closeButtonY = 3, closeBorderX = -1, closeBorderY = 1, header = 0, showHeader = false, },
	["neutral"] = { closeButtonX = 1, closeButtonY = 2, closeBorderX = -1, closeBorderY = 1, header = 0, showHeader = false, },
	["mechagon"] = { closeButtonX = 3, closeButtonY = 3, closeBorderX = -1, closeBorderY = 1, header = 0, showHeader = false, },
}

local function SetupBorder(self, layout, textureKit, nineSliceLayout)
	NineSliceUtil.ApplyLayoutByName(self.NineSlice, nineSliceLayout, textureKit);

	self.BorderFrame.Header:SetPoint("BOTTOM", self.BorderFrame, "TOP", 0, layout.header);
	self.BorderFrame.Header:SetShown(layout.showHeader);

	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, borderFrameTextureKitRegions.CloseButtonBorder, layout.closeBorderX, layout.closeBorderY, textureKit);

	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", layout.closeButtonX, layout.closeButtonY);
	self.CloseButton:SetFrameLevel(510);
end

function WarboardQuestChoiceFrameMixin:OnLoad()
	self.QuestionText = self.Title.Text;
	self.initOptionHeight = 370;

	QuestChoiceFrameMixin.OnLoad(self);
end

-- Adding this as this frame does not show rewards, so disabling the function to avoid lua errors from missing elements.
function WarboardQuestChoiceFrameMixin:ShowRewards(numChoices)
end

function WarboardQuestChoiceFrameMixin:SetupTextureKits(frame, regions)
	SetupTextureKits(self.uiTextureKitID, frame, regions, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
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
	local nineSliceLayout = nineSliceLayout[textureKit] or "WarboardTextureKit";
	SetupBorder(self, layout, textureKit, nineSliceLayout);

	for _, option in pairs(self.Options) do
		option.OptionText:SetTextColor(self.optionDescriptionColor:GetRGBA());
		option.Header.Text:SetTextColor(self.optionHeaderTitleColor:GetRGBA());
	end

	QuestChoiceFrameMixin.TryShow(self);
end

function WarboardQuestChoiceFrameMixin:Update()
	QuestChoiceFrameMixin.Update(self);

	local hasHeaders = false;
	local lastActiveOption;
	for i = 1, self.numActiveOptions do
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
		lastActiveOption = option;
	end

	-- title needs to reach across
	if lastActiveOption then
		self.Title:SetPoint("RIGHT", lastActiveOption, "RIGHT", 15, 0);
	end

	if hasHeaders then
		self.topPadding = HEADERS_SHOWN_TOP_PADDING;
	else
		self.topPadding = HEADERS_HIDDEN_TOP_PADDING;
	end

	self:MarkDirty();

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

-- If there is only 1 option use a wider size
function WarboardQuestChoiceOptionFrameMixin:UpdateOptionSize()
	if self:GetParent():GetNumOptions() == 1 then
		self:SetToWideSize();
	else
		self:SetToStandardSize();
	end
end

function WarboardQuestChoiceOptionFrameMixin:SetToStandardSize()
	self:SetupTextureKits(self, standardSizeTextureKitRegions);
	self.OptionText:SetWidth(STANDARD_SIZE_TEXT_WIDTH);
	self.fixedWidth = STANDARD_SIZE_WIDTH;
end

function WarboardQuestChoiceOptionFrameMixin:SetToWideSize()
	self:SetupTextureKits(self, wideSizeTextureKitRegions);
	self.OptionText:SetWidth(WIDE_SIZE_TEXT_WIDTH);
	self.fixedWidth = WIDE_SIZE_WIDTH;
end

-- If there is only 1 option align the buttons horizontally. Otherwise align vertically
function WarboardQuestChoiceOptionFrameMixin:UpdateSecondButtonAnchors()
	local button = self.OptionButtonsContainer.OptionButton2;
	button:ClearAllPoints();
	if self:GetParent():GetNumOptions() == 1 then
		button:SetPoint("LEFT", self.OptionButtonsContainer.OptionButton1, "RIGHT", 40, 0);
	else
		button:SetPoint("TOP", self.OptionButtonsContainer.OptionButton1, "BOTTOM", 0, -8);
	end
end

function WarboardQuestChoiceOptionFrameMixin:SetupTextureKits(frame, regions)
	self:GetParent():SetupTextureKits(frame, regions);
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

function WarboardQuestChoiceOptionFrameMixin:GetPaddingFrame()
	return self.WidgetContainer;
end
