PlayerChoiceBaseOptionTemplateMixin = {};

function PlayerChoiceBaseOptionTemplateMixin:OnLoad()
end

function PlayerChoiceBaseOptionTemplateMixin:OnShow()
end

function PlayerChoiceBaseOptionTemplateMixin:OnHide()
	self.WidgetContainer:UnregisterForWidgetSet();
end

function PlayerChoiceBaseOptionTemplateMixin:Reset()
	self:SetHeight(1);

	local fillerFrame = self:GetFillerFrame();
	if fillerFrame then
		fillerFrame:SetHeight(1);
	end
end

function PlayerChoiceBaseOptionTemplateMixin:FadeOut()
	self:Hide();
end

function PlayerChoiceBaseOptionTemplateMixin:OnSelected()
	PlayerChoiceFrame:OnSelectionMade();
end

function PlayerChoiceBaseOptionTemplateMixin:Setup(optionInfo, frameTextureKit, soloOption)
	self.optionInfo = optionInfo;
	self.uiTextureKit = optionInfo.uiTextureKit;
	self.frameTextureKit = frameTextureKit;
	self.soloOption = soloOption;

	self:SetupFrame();
	self:SetupHeader();
	self:SetupSubHeader();
	self:SetupTextColors();
	self:SetupOptionText();
	self:SetupRewards();
	self:SetupWidgets();
	self:SetupButtons();

	self:Layout();

	self:CollectAlignedSectionMaxHeights();
end

function PlayerChoiceBaseOptionTemplateMixin:GetFillerFrame()
	return self.WidgetContainer;
end

local MIN_OPTION_HEIGHT = 439;

function PlayerChoiceBaseOptionTemplateMixin:GetMinOptionHeight()
	return MIN_OPTION_HEIGHT;
end

function PlayerChoiceBaseOptionTemplateMixin:GetTextureKit()
	return self.uiTextureKit or self.frameTextureKit;
end

function PlayerChoiceBaseOptionTemplateMixin:SetupTextureKitOnRegions(frame, textureKitRegions, setVisibilityOfRegions, useAtlasSize)
	setVisibilityOfRegions = (setVisibilityOfRegions == nil) and TextureKitConstants.SetVisibility or setVisibilityOfRegions;
	useAtlasSize = (useAtlasSize == nil) and TextureKitConstants.UseAtlasSize or useAtlasSize;

	SetupTextureKitOnRegions(self:GetTextureKit(), frame, textureKitRegions, setVisibilityOfRegions, useAtlasSize);
end

function PlayerChoiceBaseOptionTemplateMixin:CollectAlignedSectionMaxHeights()
	local alignedSectionMaxHeights = PlayerChoiceFrame:GetPlayerChoiceOptionHeightData();

	for _, sectionFrame in ipairs(self.AlignedSections) do
		local sectionHeight = sectionFrame:GetHeight();

		if not alignedSectionMaxHeights[sectionFrame.alignedSectionKey] then
			alignedSectionMaxHeights[sectionFrame.alignedSectionKey] = sectionHeight;
		else
			alignedSectionMaxHeights[sectionFrame.alignedSectionKey] = math.max(alignedSectionMaxHeights[sectionFrame.alignedSectionKey], sectionHeight);
		end

		-- Set a key-value pair from alignedSectionKey to the frame, for easy access during AdjustAlignedSectionHeights
		self[sectionFrame.alignedSectionKey] = sectionFrame;
	end
end

function PlayerChoiceBaseOptionTemplateMixin:AlignSections()
	local alignedSectionMaxHeights = PlayerChoiceFrame:GetPlayerChoiceOptionHeightData();

	for alignedSectionKey, alignedSectionHeight in pairs(alignedSectionMaxHeights) do
		local sectionFrame = self[alignedSectionKey];
		sectionFrame:SetPaddedHeight(alignedSectionHeight);
	end

	-- Have to call Layout here, not MarkDirty, the player choice frame counts on everything being layed out after this call (so it can adjust the heights of the options to all be the same)
	self:Layout();
end

local OPTION_HEIGHT_EPSILON = 0.1;

function PlayerChoiceBaseOptionTemplateMixin:SetMinHeight(minHeight)
	local fillerFrame = self:GetFillerFrame();
	if not fillerFrame then
		return;
	end

	local desiredOptionHeight = math.max(self:GetMinOptionHeight(), minHeight);
	local currentOptionHeight = self:GetHeight();

	if not ApproximatelyEqual(desiredOptionHeight, currentOptionHeight, OPTION_HEIGHT_EPSILON) then
		local fillerHeight = desiredOptionHeight - currentOptionHeight;
		fillerFrame:SetHeight(fillerFrame:GetHeight() + fillerHeight);
	end
end

local OPTION_DEFAULT_WIDTH = 240;

function PlayerChoiceBaseOptionTemplateMixin:SetupFrame()
	self.fixedWidth = OPTION_DEFAULT_WIDTH;
end

function PlayerChoiceBaseOptionTemplateMixin:SetupHeader()
end

function PlayerChoiceBaseOptionTemplateMixin:SetupSubHeader()
end

function PlayerChoiceBaseOptionTemplateMixin:GetOptionFontColors()
end

function PlayerChoiceBaseOptionTemplateMixin:SetupTextColors()
end

local OPTION_DEFAULT_TEXT_WIDTH = 196;

function PlayerChoiceBaseOptionTemplateMixin:SetupOptionText()
	self.OptionText:ClearText()
	self.OptionText:SetWidth(OPTION_DEFAULT_TEXT_WIDTH);
	self.OptionText:SetText(self.optionInfo.description);
end

function PlayerChoiceBaseOptionTemplateMixin:SetupRewards()
end

local function IsTopWidget(widgetFrame)
	return widgetFrame.widgetType == Enum.UIWidgetVisualizationType.SpellDisplay;
end

function PlayerChoiceBaseOptionTemplateMixin:WidgetsLayout(widgetContainer, sortedWidgets)
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

	if PlayerChoiceFrame:AreOptionsAligned() then
		-- This indicates that a widget has shown/hidden while the player choice frame is up (and the player choice frame itself was not also updated)
		-- In this case, we need to call AlignOptionHeights again. We can skip the AlignSections step though, because the widget container is not a height-aligned section
		local skipAlignSections = true;
		PlayerChoiceFrame:AlignOptionHeights(skipAlignSections);
	end
end

function PlayerChoiceBaseOptionTemplateMixin:WidgetInit(widgetFrame)
	if widgetFrame.SetFontStringColor then
		local fontColors = self:GetOptionFontColors();
		if fontColors then
			widgetFrame:SetFontStringColor(fontColors.description);
		end
	end
end

function PlayerChoiceBaseOptionTemplateMixin:SetupWidgets()
	if self.optionInfo.widgetSetID ~= self.WidgetContainer.widgetSetID then
		local attachedUnitInfo = {unit = PlayerChoiceFrame:GetObjectGUID(), isGuid = true};
		self.WidgetContainer:RegisterForWidgetSet(self.optionInfo.widgetSetID, GenerateClosure(self.WidgetsLayout, self), GenerateClosure(self.WidgetInit, self), attachedUnitInfo);
	elseif self.WidgetContainer:GetNumWidgetsShowing() > 0 then
		-- WidgetContainer is also used as the filler frame, so the height may have been adjusted the last time this option was set up.
		-- If the widget set ID is the same as it was before, and there are widgets showing, then we need to call UpdateWidgetLayout
		self.WidgetContainer:UpdateWidgetLayout();
	end
end

function PlayerChoiceBaseOptionTemplateMixin:SetupButtons()
	self.OptionButtonsContainer:Setup(self.optionInfo);
end

PlayerChoiceBaseOptionAlignedSectionMixin = {};

function PlayerChoiceBaseOptionAlignedSectionMixin:SetPaddedHeight(paddedHeight)
	self:SetHeight(paddedHeight);
end

PlayerChoiceBaseOptionTextTemplateMixin = { }

function PlayerChoiceBaseOptionTextTemplateMixin:OnLoad()
	self:SetUseHTML(true);

	local setWidth = self.SetWidth;
	self.SetWidth = function(self, ...)
		self.textObject:SetWidth(...);
		setWidth(self, ...);
	end
end

function PlayerChoiceBaseOptionTextTemplateMixin:SetUseHTML(useHTML)
	self.useHTML = useHTML;
	self.HTML:SetShown(useHTML);
	self.String:SetShown(not useHTML);

	self.textObject = useHTML and self.HTML or self.String;
end

function PlayerChoiceBaseOptionTextTemplateMixin:ClearText()
	self.textObject:SetText(nil);
	self.textObject:SetHeight(0);
	self:SetHeight(10);
end

function PlayerChoiceBaseOptionTextTemplateMixin:SetText(...)
	self.textObject:SetText(...);

	if self.useHTML then
		self:SetHeight(self.HTML:GetHeight());
	end
end

function PlayerChoiceBaseOptionTextTemplateMixin:SetFontObject(...)
	self.textObject:SetFontObject(...);
end

function PlayerChoiceBaseOptionTextTemplateMixin:SetTextColor(...)
	self.textObject:SetTextColor(...);
end

function PlayerChoiceBaseOptionTextTemplateMixin:SetJustifyH(...)
	self.textObject:SetJustifyH(...);
end

function PlayerChoiceBaseOptionTextTemplateMixin:SetStringHeight(height)
	self.String:SetHeight(height);
	self:SetHeight(height);
end

function PlayerChoiceBaseOptionTextTemplateMixin:IsTruncated()
	return not self.useHTML and self.String:IsTruncated();
end

PlayerChoiceBaseOptionButtonTemplateMixin = {};

function PlayerChoiceBaseOptionButtonTemplateMixin:OnLoad()
	self.parentOption = self:GetParent():GetParent();
end

function PlayerChoiceBaseOptionButtonTemplateMixin:Setup(buttonInfo, optionInfo)
	self.confirmation = buttonInfo.confirmation;
	self.tooltip = buttonInfo.tooltip;
	self.rewardQuestID = buttonInfo.rewardQuestID;
	self:SetText(buttonInfo.text);
	self.buttonID = buttonInfo.id;
	self.optionID = optionInfo.id;
	self.soundKitID = buttonInfo.soundKitID;
	self:SetEnabled(not buttonInfo.disabled);
	self.keepOpenAfterChoice = buttonInfo.keepOpenAfterChoice;
end

function PlayerChoiceBaseOptionButtonTemplateMixin:OnConfirm()
	C_PlayerChoice.SendPlayerChoiceResponse(self.buttonID);
	self.parentOption:OnSelected();
end

StaticPopupDialogs["CONFIRM_PLAYER_CHOICE"] = {
	text = "%s",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		self.data.owner:OnConfirm();
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};

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
		self.data.owner:OnConfirm();
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
		if parent.button1:IsEnabled() then
			parent.data.owner:OnConfirm();
			parent:Hide();
		end
	end,
	EditBoxOnTextChanged = function (self)
		local parent = self:GetParent();
		StaticPopup_StandardConfirmationTextHandler(self, parent.data.confirmationString);
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
		ClearCursor();
	end
};

local THREADS_OF_FATE_OPTION_ID = 3272;

function PlayerChoiceBaseOptionButtonTemplateMixin:OnClick()
	if self.confirmation then
		if self.optionID == THREADS_OF_FATE_OPTION_ID then
			StaticPopup_Show("CONFIRM_PLAYER_CHOICE_WITH_CONFIRMATION_STRING", self.confirmation, nil, { owner = self, confirmationString = SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING });
		else
			StaticPopup_Show("CONFIRM_PLAYER_CHOICE", self.confirmation, nil, { owner = self });
		end
	else
		self:OnConfirm();
	end
end

function PlayerChoiceBaseOptionButtonTemplateMixin:OnEnter()
	if self.tooltip or self.rewardQuestID or self.Text:IsTruncated() then
		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");

		if self.rewardQuestID and not HaveQuestRewardData(self.rewardQuestID) then
			GameTooltip_SetTitle(EmbeddedItemTooltip, RETRIEVING_DATA, RED_FONT_COLOR);
			GameTooltip_SetTooltipWaitingForData(EmbeddedItemTooltip, true);
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

			GameTooltip_SetTooltipWaitingForData(EmbeddedItemTooltip, false);
		end

		EmbeddedItemTooltip:Show();
	else
		EmbeddedItemTooltip:Hide();
	end

	self.UpdateTooltip = self.OnEnter;
end

function PlayerChoiceBaseOptionButtonTemplateMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
	self.UpdateTooltip = nil;
end

PlayerChoiceBaseOptionButtonsContainerMixin = {};

local DEFAULT_BUTTON_TEMPLATE = "PlayerChoiceBaseOptionButtonTemplate";

function PlayerChoiceBaseOptionButtonsContainerMixin:OnLoad()
	self.buttonPool = CreateFramePoolCollection();
	self.initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self, "TOPLEFT", 0, 0);
	self.buttonTemplate = DEFAULT_BUTTON_TEMPLATE;
end

function PlayerChoiceBaseOptionButtonsContainerMixin:OnHide()
	self.topPadding = 5;
end

function PlayerChoiceBaseOptionButtonsContainerMixin:SetPaddedHeight(paddedHeight)
	local paddingHeight = (paddedHeight - self:GetHeight()) + 5;
	self.topPadding = math.max(paddingHeight, 5);
end

function PlayerChoiceBaseOptionButtonsContainerMixin:Setup(optionInfo, numColumns)
	numColumns = numColumns or 1;
	local buttonStride = math.max(math.floor(#optionInfo.buttons / numColumns), 1);

	if buttonStride ~= self.lastStride then
		self.layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRightVertical, buttonStride, 20, 5);
		self.lastStride = buttonStride;
	end

	self.buttonPool:ReleaseAll();
	self.buttonPool:CreatePoolIfNeeded("Button", self, self.buttonTemplate);

	local buttons = {};
	for buttonIndex, buttonInfo in ipairs(optionInfo.buttons) do
		local button = self.buttonPool:Acquire(self.buttonTemplate);
		button:Setup(buttonInfo, optionInfo);
		button:Show();
		table.insert(buttons, button);
	end

	AnchorUtil.GridLayout(buttons, self.initialAnchor, self.layout);
end

PlayerChoiceBaseOptionCurrencyRewardMixin = {};

function PlayerChoiceBaseOptionCurrencyRewardMixin:Setup(currencyRewardInfo, fontColor)
	self.currencyID = currencyRewardInfo.currencyId;
	self.Icon:SetTexture(currencyRewardInfo.currencyTexture);
	self.Count:SetText(AbbreviateNumbers(currencyRewardInfo.quantity));
	self.Name:SetText(currencyRewardInfo.name);
	self.Name:SetTextColor(fontColor:GetRGBA());
end

function PlayerChoiceBaseOptionCurrencyRewardMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetCurrencyByID(self.currencyID);
end

function PlayerChoiceBaseOptionCurrencyRewardMixin:OnLeave()
	GameTooltip_Hide();
end

PlayerChoiceBaseOptionItemRewardMixin = {};

function PlayerChoiceBaseOptionItemRewardMixin:OnLoad()
	self.itemButton:EnableMouse(false);
end

function PlayerChoiceBaseOptionItemRewardMixin:IsDressupReward(itemRewardInfo)
	if C_Item.IsDressableItemByID(self.itemButton.itemLink) then
		return true;
	end

	if C_MountJournal.GetMountFromItem(itemRewardInfo.itemId) then
		return true;
	end

	if C_PetJournal.GetPetInfoByItemID(itemRewardInfo.itemId) then
		return true;
	end

	return false;
end

function PlayerChoiceBaseOptionItemRewardMixin:Setup(itemRewardInfo, fontColor)
	self.itemButton:SetItem(itemRewardInfo.itemId);
	self.itemButton:SetItemButtonCount(itemRewardInfo.quantity);

	self.Name:SetText(itemRewardInfo.name);
	self.Name:SetTextColor(fontColor:GetRGBA());

	self.dressupReward = self:IsDressupReward(itemRewardInfo);
end

function PlayerChoiceBaseOptionItemRewardMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetItemByID(self.itemButton.item);
		
	if IsModifiedClick("DRESSUP") and self.dressupReward then
		ShowInspectCursor();
	else
		ResetCursor();
	end

	self.UpdateTooltip = self.OnEnter;
end

function PlayerChoiceBaseOptionItemRewardMixin:OnLeave()
	self.UpdateTooltip = nil;
	ResetCursor();
	GameTooltip_Hide();
end

function PlayerChoiceBaseOptionItemRewardMixin:OnClick(button)
	if IsModifiedClick() then
		HandleModifiedItemClick(self.itemButton.itemLink);
	end
end

PlayerChoiceBaseOptionCurrencyContainerRewardMixin = {};

function PlayerChoiceBaseOptionCurrencyContainerRewardMixin:OnLoad()
	self.itemButton:EnableMouse(false);
end

function PlayerChoiceBaseOptionCurrencyContainerRewardMixin:Setup(currencyRewardInfo, fontColor)
	local currencyContainerInfo = C_CurrencyInfo.GetCurrencyContainerInfo(currencyRewardInfo.currencyId, currencyRewardInfo.quantity); 
	SetItemButtonTexture(self.itemButton, currencyContainerInfo.icon);
	SetItemButtonQuality(self.itemButton, currencyContainerInfo.quality);
	SetItemButtonCount(self.itemButton, currencyContainerInfo.displayAmount);

	self.currencyID = currencyRewardInfo.currencyId;
	self.quantity = currencyRewardInfo.quantity;

	self.Name:SetText(currencyContainerInfo.name);
	self.Name:SetTextColor(fontColor:GetRGBA());
end

function PlayerChoiceBaseOptionCurrencyContainerRewardMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetCurrencyByID(self.currencyID, self.quantity);
end

function PlayerChoiceBaseOptionCurrencyContainerRewardMixin:OnLeave()
	GameTooltip_Hide();
end

PlayerChoiceBaseOptionReputationRewardMixin = {};

function PlayerChoiceBaseOptionReputationRewardMixin:Setup(repRewardInfo, fontColor)
	local factionName = GetFactionInfoByID(repRewardInfo.factionId);
	self.Text:SetText(REWARD_REPUTATION_WITH_AMOUNT:format(repRewardInfo.quantity, factionName));
	self.Text:SetTextColor(fontColor:GetRGBA());
end

PlayerChoiceBaseOptionRewardsMixin = {}

function PlayerChoiceBaseOptionRewardsMixin:OnLoad()
	self.rewardsPool = CreateFramePoolCollection();
	self.rewardsPool:CreatePool("Button", self, "PlayerChoiceBaseOptionItemRewardTemplate");
	self.rewardsPool:CreatePool("Frame", self, "PlayerChoiceBaseOptionCurrencyContainerRewardTemplate");
	self.rewardsPool:CreatePool("Frame", self, "PlayerChoiceBaseOptionCurrencyRewardTemplate");
	self.rewardsPool:CreatePool("Frame", self, "PlayerChoiceBaseOptionReputationRewardTemplate");
end

function PlayerChoiceBaseOptionRewardsMixin:Setup(optionInfo, fontColor)
	self.rewardsPool:ReleaseAll();

	if not optionInfo.hasRewards then
		self:Hide();
		return;
	end

	local rewardIndex = 1;

	for _, itemRewardInfo in ipairs(optionInfo.rewardInfo.itemRewards) do
		local rewardFrame = self.rewardsPool:Acquire("PlayerChoiceBaseOptionItemRewardTemplate");
		rewardFrame:Setup(itemRewardInfo, fontColor);
		rewardFrame.layoutIndex = rewardIndex;
		rewardIndex = rewardIndex + 1;
		rewardFrame:Show();
	end

	for _, currencyRewardInfo in ipairs(optionInfo.rewardInfo.currencyRewards) do
		local rewardFrame;
		if currencyRewardInfo.isCurrencyContainer then
			rewardFrame = self.rewardsPool:Acquire("PlayerChoiceBaseOptionCurrencyContainerRewardTemplate");
		else
			rewardFrame = self.rewardsPool:Acquire("PlayerChoiceBaseOptionCurrencyRewardTemplate");
		end

		rewardFrame:Setup(currencyRewardInfo, fontColor);
		rewardFrame.layoutIndex = rewardIndex;
		rewardIndex = rewardIndex + 1;
		rewardFrame:Show();
	end

	for _, repRewardInfo in ipairs(optionInfo.rewardInfo.repRewards) do
		local rewardFrame = self.rewardsPool:Acquire("PlayerChoiceBaseOptionReputationRewardTemplate");
		rewardFrame:Setup(repRewardInfo, fontColor);
		rewardFrame.layoutIndex = rewardIndex;
		rewardIndex = rewardIndex + 1;
		rewardFrame:Show();
	end

	self:Show();
end
