PlayerChoiceFrameMixin = {};

function PlayerChoiceFrameMixin:OnLoad()
	self.optionPools = CreateFramePoolCollection();
	self.onCloseCallback = GenerateClosure(self.OnCloseUIFromExitButton, self);
end

function PlayerChoiceFrameMixin:OnEvent(event, ...)
	HideUIPanel(self);
end

-- IMPORTANT: useOldNineSlice preserves old functionality and should not be used in the future
local customTextureKitInfo = {
	neutral = {
		useOldNineSlice = true,
	},

	alliance = {
		closeBorderX = 0,
		closeBorderY = 0,
		headerYoffset = -48,
		useOldNineSlice = true,
	},

	horde = {
		headerYoffset = -55,
		useOldNineSlice = true,
	},

	marine = {
		closeButtonX = 3,
		closeButtonY = 3,
		uniqueCorners = true,
		useOldNineSlice = true,
	},

	mechagon = {
		closeButtonX = 3,
		closeButtonY = 3,
		useOldNineSlice = true,
	},

	jailerstower = {
		optionFrameTemplate = "PlayerChoiceTorghastOptionTemplate",
		optionsTopPadding = 30,
		optionsBottomPadding = 55,
		showOptionsOnly = true,
		frameYOffset = 95,
		useOldNineSlice = true,
	},

	cypherchoice = {
		optionFrameTemplate = "PlayerChoiceCypherOptionTemplate",
		optionsTopPadding = 120,
		optionsBottomPadding = 55,
		showOptionsOnly = true,
		frameYOffset = 95,
		toggleXOffset = 0,
		toggleYOffset = -20,
		timerXOffset = 0,
		timerYOffset = -5,
		useOldNineSlice = true,
	},

	Oribos = {
		optionFrameTemplate = "PlayerChoiceCovenantChoiceOptionTemplate",
		exitButtonSoundKit = SOUNDKIT.UI_COVENANT_CHOICE_CLOSE,
		optionsTopPadding = 124,
		optionsBottomPadding = 36,
		optionsSidePadding = 59,
		optionsSpacing = 6,
		uniqueCorners = true,
		useOldNineSlice = true,
	},

	NightFae = {
		uniqueCorners = true,
		useOldNineSlice = true,
		borderTopLeftAnchorX = -12, 
		borderTopLeftAnchorY = 12, 
		borderBottomRightAnchorX = 12, 
		borderBottomRightAnchorY = -12, 
	},

	Venthyr = {
		closeButtonX = 2,
		closeBorderX = -2,
		closeBorderY = 2,
		uniqueCorners = true,
		useOldNineSlice = true,
	},

	Kyrian = {
		uniqueCorners = true,
		useOldNineSlice = true,
	},

	Dragonflight = {
		closeButtonX = -2,
		closeButtonY = -8,
		uniqueCorners = true,
		useOldNineSlice = true,
	},

	genericplayerchoice = {
		optionFrameTemplate = "PlayerChoiceGenericPowerChoiceOptionTemplate",
		optionsTopPadding = 120,
		optionsBottomPadding = 120,
		showOptionsOnly = true,
		frameYOffset = 95,
		timerXOffset = 0,
		timerYOffset = -5,
		useOldNineSlice = true,
	},

	thewarwithin = {
		closeButtonX = -9,
		closeButtonY = -9,
	},
};

local defaultTextureKitInfo = {
	optionFrameTemplate = "PlayerChoiceNormalOptionTemplate",
	closeButtonX = 1,
	closeButtonY = 2,
	closeBorderX = -1,
	closeBorderY = 1,
	optionsTopPadding = 112,
	optionsBottomPadding = 69,
	optionsSidePadding = 65,
	optionsSpacing = 20,
	frameYOffset = 0,
	borderTopLeftAnchorX = -6, 
	borderTopLeftAnchorY = 6, 
	borderBottomRightAnchorX = 6, 
	borderBottomRightAnchorY = -6, 
};

function PlayerChoiceGetTextureKitInfo(textureKit)
	local kitInfo = customTextureKitInfo[textureKit] or {};
	return setmetatable(kitInfo, {__index = defaultTextureKitInfo});
end

function PlayerChoiceFrameMixin:GetTextureKitInfo()
	local kitInfo = customTextureKitInfo[self.uiTextureKit] or {};
	return setmetatable(kitInfo, {__index = defaultTextureKitInfo});
end

function PlayerChoiceFrameMixin:SetupTextureKits(frame, regions)
	SetupTextureKitOnRegions(self.uiTextureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

local DEFAULT_TEXTURE_KIT = "neutral";

function PlayerChoiceFrameMixin:TryShow()
	local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo();
	if not choiceInfo then
		return;
	end

	self.choiceInfo = choiceInfo;

	if choiceInfo.uiTextureKit then
		self.uiTextureKit = choiceInfo.uiTextureKit;
		self.isLegacy = false;
	else
		self.uiTextureKit = DEFAULT_TEXTURE_KIT;
		self.isLegacy = true;
	end

	self.textureKitInfo = self:GetTextureKitInfo();

	self:SetupFrame();
	self:SetupOptions();

	self.Title.Text:SetText(choiceInfo.questionText);

	self:Layout();

	ShowUIPanel(self);
end

function PlayerChoiceFrameMixin:GetObjectGUID()
	return self.choiceInfo and self.choiceInfo.objectGUID;
end

local PLAYER_CHOICE_FRAME_EVENTS = {
	"PLAYER_ENTERING_WORLD",
	"PLAYER_DEAD",
	"PLAYER_CHOICE_CLOSE",
};

local function GetActiveMawBuffContainer()
	if ScenarioBlocksFrame and ScenarioBlocksFrame.MawBuffsBlock:IsShown() then
		return ScenarioBlocksFrame.MawBuffsBlock.Container;
	end
end

function PlayerChoiceFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, PLAYER_CHOICE_FRAME_EVENTS);

	if self.choiceInfo and self.choiceInfo.soundKitID then
		PlaySound(self.choiceInfo.soundKitID);
	else
		PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
	end

	local activeMawBuffContainer = GetActiveMawBuffContainer();
	if activeMawBuffContainer then
		activeMawBuffContainer:UpdateListState(true);
	end

	local toggleButton = PlayerChoiceToggle_GetActiveToggle();
	if toggleButton then
		toggleButton:ClearAllPoints();
		toggleButton:SetPoint("TOP", self, "BOTTOM", self.textureKitInfo.toggleXOffset or 0, self.textureKitInfo.toggleYOffset or 0);
	end
	PlayerChoiceToggle_TryShow();

	PlayerChoiceTimeRemaining:TryShow();
end

function PlayerChoiceFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, PLAYER_CHOICE_FRAME_EVENTS);

	if self.choiceInfo and self.choiceInfo.closeUISoundKitID then
		PlaySound(self.choiceInfo.closeUISoundKitID);
	else
		PlaySound(SOUNDKIT.IG_QUEST_LIST_CLOSE);
	end

	C_PlayerChoice.OnUIClosed();

	if CovenantPreviewFrame and CovenantPreviewFrame:IsShown() then
		CovenantPreviewFrame:Hide();
	end

	local activeMawBuffContainer = GetActiveMawBuffContainer();
	if activeMawBuffContainer then
		activeMawBuffContainer:UpdateListState(false);
	end

	local toggleButton = PlayerChoiceToggle_GetActiveToggle();
	if toggleButton and toggleButton:IsShown() then
		toggleButton:UpdateButtonState();
	end
end

function PlayerChoiceFrameMixin:FadeOutAllOptions()
	for optionFrame in self.optionPools:EnumerateActiveByTemplate(self.optionFrameTemplate) do
		optionFrame:FadeOut();
	end
end

function PlayerChoiceFrameMixin:OnSelectionMade()
	if not self.choiceInfo.keepOpenAfterChoice then
		HideUIPanel(self);
	end
end

function PlayerChoiceFrameMixin:OnCloseUIFromExitButton()
	if self.textureKitInfo.exitButtonSoundKit then
		PlaySound(self.textureKitInfo.exitButtonSoundKit);
	end
	
	HideUIPanel(self);
end

local titleTextureKitRegions = {
	Left = "UI-Frame-%s-TitleLeft",
	Right = "UI-Frame-%s-TitleRight",
	Middle = "_UI-Frame-%s-TitleMiddle",
};

local backgroundTextureKitRegions = {
	BackgroundTile = "UI-Frame-%s-BackgroundTile",
};

local borderFrameTextureKitRegions = {
	Texture = "UI-Frame-%s-Header",
};

local borderFrameTextureKitRegion = "UI-Frame-%s-Border";

function PlayerChoiceFrameMixin:SetupFrame()
	local showExtraFrames = not self.textureKitInfo.showOptionsOnly;
	self.CloseButton:SetShown(showExtraFrames);
	self.Header:SetShown(showExtraFrames);
	self.Title:SetShown(showExtraFrames);
	self.Background:SetShown(showExtraFrames);
	self:EnableMouse(showExtraFrames);

	-- Using the negation here guarantees useOldNineSlice is a bool instead of nil
	local usesNewNineSlice = not self.textureKitInfo.useOldNineSlice;
	self.NineSlice:SetShown(showExtraFrames and not usesNewNineSlice);
	self.BorderOverlay:SetShown(showExtraFrames and usesNewNineSlice);

	if showExtraFrames then
		local function SetBorderPoints(border)
			border:SetPoint("TOPLEFT", self, "TOPLEFT", self.textureKitInfo.borderTopLeftAnchorX, self.textureKitInfo.borderTopLeftAnchorY);
			border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", self.textureKitInfo.borderBottomRightAnchorX, self.textureKitInfo.borderBottomRightAnchorY);
		end

		SetBorderPoints(self.NineSlice);
		SetBorderPoints(self.BorderOverlay);

		if self.textureKitInfo.useOldNineSlice then
			if self.textureKitInfo.uniqueCorners then
				NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, self.uiTextureKit);
			else
				NineSliceUtil.ApplyIdenticalCornersLayout(self.NineSlice, self.uiTextureKit);
			end
		else 
			self.BorderOverlay:SetAtlas(borderFrameTextureKitRegion:format(self.uiTextureKit));
		end

		UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-%s-ExitButtonBorder", self.textureKitInfo.closeBorderX, self.textureKitInfo.closeBorderY, self.uiTextureKit);

		self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", self.textureKitInfo.closeButtonX, self.textureKitInfo.closeButtonY);

		if self.choiceInfo.hideWarboardHeader or not self.textureKitInfo.headerYoffset then
			self.Header:Hide();
		else
			self:SetupTextureKits(self.Header, borderFrameTextureKitRegions);
			self.Header:SetPoint("BOTTOM", self, "TOP", 0, self.textureKitInfo.headerYoffset);
			self.Header:Show();
		end

		self:SetupTextureKits(self.Title, titleTextureKitRegions);
		self:SetupTextureKits(self.Background, backgroundTextureKitRegions);
	end

	self:SetPoint("CENTER", 0, self.textureKitInfo.frameYOffset);
end

local function HideAndAnchorTopLeft(framePool, frame)
	frame:Reset();
	frame:Hide();
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", PlayerChoiceFrame, "TOPLEFT");
end

-- ResetPlayerChoiceOptionHeightData needs to be called when player choice options frames are about to start being processed
function PlayerChoiceFrameMixin:ResetPlayerChoiceOptionHeightData()
	self.alignedSectionMaxHeights = {};
end

function PlayerChoiceFrameMixin:GetPlayerChoiceOptionHeightData()
	return self.alignedSectionMaxHeights;
end

function PlayerChoiceFrameMixin:SetupOptions()
	self.optionsAligned = false;

	self.topPadding = self.textureKitInfo.optionsTopPadding;
	self.bottomPadding = self.textureKitInfo.optionsBottomPadding;
	self.leftPadding = self.textureKitInfo.optionsSidePadding;
	self.rightPadding = self.textureKitInfo.optionsSidePadding;
	self.spacing = self.textureKitInfo.optionsSpacing;

	self.optionPools:ReleaseAll();
	self:ResetPlayerChoiceOptionHeightData();

	self.optionFrameTemplate = self.textureKitInfo.optionFrameTemplate;
	self.optionPools:GetOrCreatePool("FRAME", self, self.optionFrameTemplate, HideAndAnchorTopLeft);

	local soloOption = (#self.choiceInfo.options == 1);

	-- First create and call Setup on all the options.
	-- This needs to be done in a separate loop from the Finalize call (in AlignOptionHeights), because Setup collects the max heights of all the aligned sections, and then Finalize adjusts the heights
	for optionIndex, optionInfo in ipairs(self.choiceInfo.options) do
		local optionFrame = self.optionPools:Acquire(self.optionFrameTemplate);
		optionFrame.layoutIndex = optionIndex;
		optionFrame:Setup(optionInfo, self.uiTextureKit, soloOption);
	end

	self:AlignOptionHeights(soloOption);
end

function PlayerChoiceFrameMixin:AlignOptionHeights(skipAlignSections)
	-- First, loop through all options once, calculating maxOptionHeight
	-- As we loop, we call AlignSections on each, which aligns the heights of all height-aligned sections.
	-- If skipAlignSections is true, we skip the AlignSections call, and just calculate maxOptionHeight
	local maxOptionHeight = 0;
	for optionFrame in self.optionPools:EnumerateActiveByTemplate(self.optionFrameTemplate) do
		if not skipAlignSections then
			optionFrame:AlignSections();
		end
		optionFrame:Layout();
		maxOptionHeight = math.max(maxOptionHeight, optionFrame:GetHeight());
	end

	-- Then call SetMinHeight on each option, using maxOptionHeight. Each option mixin can choose to add padding however it sees fit (or ignore that min height entirely)
	for optionFrame in self.optionPools:EnumerateActiveByTemplate(self.optionFrameTemplate) do
		optionFrame:SetMinHeight(maxOptionHeight);
		optionFrame:Show();
	end

	self.optionsAligned = true;
end

function PlayerChoiceFrameMixin:AreOptionsAligned()
	return self.optionsAligned;
end

function PlayerChoiceFrameMixin:IsLegacy()
	return self.isLegacy;
end