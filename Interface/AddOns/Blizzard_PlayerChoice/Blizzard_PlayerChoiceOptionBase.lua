local MIN_OPTION_HEIGHT = 439;
local OPTION_HEIGHT_EPSILON = 0.1;
local OPTION_DEFAULT_WIDTH = 240;
local OPTION_DEFAULT_TEXT_WIDTH = 196;

local rarityToItemQuality = {
	[Enum.PlayerChoiceRarity.Common] = Enum.ItemQuality.Common,
    [Enum.PlayerChoiceRarity.Uncommon] = Enum.ItemQuality.Uncommon,
    [Enum.PlayerChoiceRarity.Rare] = Enum.ItemQuality.Rare,
    [Enum.PlayerChoiceRarity.Epic] = Enum.ItemQuality.Epic
};

PlayerChoiceBaseOptionTemplateMixin = {};

function PlayerChoiceBaseOptionTemplateMixin:OnLoad()
	if self.Layout then
		-- If this is a LayoutFrame call Layout to ensure initial anchors are set up
		self:Layout()
	end

	self.OptionButtonsContainer.buttonFrameTemplate = "PlayerChoiceBaseOptionButtonFrameTemplate";
	self.OptionButtonsContainer.listButtonFrameTemplate = "PlayerChoiceSmallerOptionButtonFrameTemplate";
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

function PlayerChoiceBaseOptionTemplateMixin:Setup(optionInfo, frameTextureKit, soloOption, showAsList)
	self.optionInfo = optionInfo;
	self.uiTextureKit = optionInfo.uiTextureKit;
	self.frameTextureKit = frameTextureKit;
	self.soloOption = soloOption;
	self.showAsList = showAsList;

	self:SetupFrame();
	self:SetupHeader();
	self:SetupSubHeader();
	self:SetupTextFonts();
	self:SetupOptionText();
	self:SetupRewards();
	self:SetupWidgets();
	self:SetupButtons();

	self:Layout();

	self:CollectAlignedSectionMaxHeights();
end

function PlayerChoiceBaseOptionTemplateMixin:GetItemQualityForRarity(rarity)
	return rarityToItemQuality[rarity];
end

function PlayerChoiceBaseOptionTemplateMixin:GetAtlasDataForRarity()
	local rarity = self.optionInfo.rarity or Enum.PlayerChoiceRarity.Common;
	local quality = self:GetItemQualityForRarity(rarity);
	return ColorManager.GetAtlasDataForPlayerChoice(quality);
end

function PlayerChoiceBaseOptionTemplateMixin:GetFillerFrame()
	return self.WidgetContainer;
end

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
		-- If filler frame height has changed, we must update layout as other child frames may be anchored below it
		self:Layout();
	end
end

function PlayerChoiceBaseOptionTemplateMixin:SetupFrame()
	self.fixedWidth = OPTION_DEFAULT_WIDTH;
end

function PlayerChoiceBaseOptionTemplateMixin:SetupHeader()
end

function PlayerChoiceBaseOptionTemplateMixin:SetupSubHeader()
end

function PlayerChoiceBaseOptionTemplateMixin:GetOptionFontInfo()
end

function PlayerChoiceBaseOptionTemplateMixin:SetupTextFonts()
end

function PlayerChoiceBaseOptionTemplateMixin:SetupOptionText()
	if self.optionInfo.description == "" then
		self.OptionText:Hide();
	else
		self.OptionText:Show();
		self.OptionText:ClearText();
		self.OptionText:SetWidth(OPTION_DEFAULT_TEXT_WIDTH);
		self.OptionText:SetText(self.optionInfo.description);
	end
end

function PlayerChoiceBaseOptionTemplateMixin:SetupRewards()
end

local function IsTopWidget(widgetFrame, consolidateWidgets)
	if consolidateWidgets then
		return true;
	else
		return widgetFrame.widgetType == Enum.UIWidgetVisualizationType.SpellDisplay;
	end
end

local function ReserveSortWidgets(a, b)
	if a.orderIndex == b.orderIndex then
		return a.widgetID > b.widgetID;
	else
		return a.orderIndex > b.orderIndex;
	end
end

function PlayerChoiceBaseOptionTemplateMixin:WidgetsLayout(widgetContainer, sortedWidgets)
	local topWidgets = {};
	local bottomWidgets = {};

	-- The widget container is the filler frame for player choice options
	-- Some widget types go at the top of the container and others go at the bottom, with any needed filler space added between them

	-- First put the top and bottom widgets into separate tables
	for index, widgetFrame in ipairs(sortedWidgets) do
		if IsTopWidget(widgetFrame, self.optionInfo.consolidateWidgets) then
			table.insert(topWidgets, widgetFrame);
		else
			table.insert(bottomWidgets, widgetFrame);
		end
	end

	local hasTopWidgets = #topWidgets > 0;
	local hasBottomWidgets = #bottomWidgets > 0;
	local skipContainerLayout = true;

	if hasTopWidgets then
		-- Layout all top widgets first from top to bottom and left to right
		widgetContainer.verticalAnchorPoint = "TOP";
		widgetContainer.verticalRelativePoint = "BOTTOM";
		widgetContainer.horizontalAnchorPoint = "LEFT";
		widgetContainer.horizontalRelativePoint = "RIGHT";
		DefaultWidgetLayout(widgetContainer, topWidgets, skipContainerLayout);
	end

	local skipHorizontalRowPoolClear = true;
	if hasBottomWidgets then
		-- We want the bottom widgets to be anchored to the bottom of the container but we still want them to be layed out top to bottom among themselves (by orderIndex)
		-- In order to achieve that, we reserve-sort the bottom widgets and then lay them out bottom to top and right to left

		-- Reverse sort bottom widgets
		table.sort(bottomWidgets, ReserveSortWidgets);

		-- Then lay them out bottom to top and right to left
		widgetContainer.verticalAnchorPoint = "BOTTOM";
		widgetContainer.verticalRelativePoint = "TOP";
		widgetContainer.horizontalAnchorPoint = "RIGHT";
		widgetContainer.horizontalRelativePoint = "LEFT";
		DefaultWidgetLayout(widgetContainer, bottomWidgets, skipContainerLayout, skipHorizontalRowPoolClear);
	end

	-- Add some padding between the top and bottom widgets (more will be added if needed in SetMinHeight)
	if hasTopWidgets and hasBottomWidgets then
		widgetContainer.heightPadding = 20;
	else
		widgetContainer.heightPadding = nil;
	end

	-- Finally call Layout on the widget container itself so it resizes to fit all the widgets and padding
	widgetContainer:Layout();

	if PlayerChoiceFrame:AreOptionsAligned() then
		-- This indicates that a widget has shown/hidden while the player choice frame is up (and the player choice frame itself was not also updated)
		-- In this case, we need to call AlignOptionHeights again. We can skip the AlignSections step though, because the widget container is not a height-aligned section
		local skipAlignSections = true;
		PlayerChoiceFrame:AlignOptionHeights(skipAlignSections);
	end
end

function PlayerChoiceBaseOptionTemplateMixin:WidgetInit(widgetFrame)
	if widgetFrame.SetFontStringColor then
		local fontInfo = self:GetOptionFontInfo();
		if fontInfo then
			widgetFrame:SetFontStringColor(fontInfo.descriptionColor);
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
	self.OptionButtonsContainer:Setup(self.optionInfo, self.showAsList);
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
	self.textObject:SetText("");
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
	if self.useHTML then
		self.textObject:SetFontObject("P", ...);
	else
		self.textObject:SetFontObject(...);
	end
end

function PlayerChoiceBaseOptionTextTemplateMixin:SetTextColor(...)
	if self.useHTML then
		self.textObject:SetTextColor("P", ...);
	else
		self.textObject:SetTextColor(...);
	end
end

function PlayerChoiceBaseOptionTextTemplateMixin:SetJustifyH(...)
	if self.useHTML then
		self.textObject:SetJustifyH("P", ...);
	else
		self.textObject:SetJustifyH(...);
	end
end

function PlayerChoiceBaseOptionTextTemplateMixin:SetStringHeight(height)
	self.String:SetHeight(height);
	self:SetHeight(height);
end

function PlayerChoiceBaseOptionTextTemplateMixin:IsTruncated()
	return not self.useHTML and self.String:IsTruncated();
end

PlayerChoiceBaseOptionButtonFrameTemplateMixin = {};

function PlayerChoiceBaseOptionButtonFrameTemplateMixin:OnLoad()
	self.Button = CreateFrame("Button", nil, self, self.buttonTemplate);
end

local listFontByDisabledState = {
	[false] = WHITE_FONT_COLOR,
	[true] = GRAY_FONT_COLOR,
};

function PlayerChoiceBaseOptionButtonFrameTemplateMixin:Setup(buttonInfo, optionInfo, showAsList)
	if showAsList then
		local fontColor = listFontByDisabledState[buttonInfo.disabled];
		self.ListText:SetTextColor(fontColor:GetRGBA());
		self.ListText:SetText(buttonInfo.listText);
		self.ListText:Show();
		self:SetScript("OnEnter", function() self.Button:OnEnter() end);
		self:SetScript("OnLeave", function() self.Button:OnLeave() end);
	else
		self.ListText:Hide();
		self:SetScript("OnEnter", nil);
		self:SetScript("OnLeave", nil);
	end

	self.Button:Setup(buttonInfo, optionInfo);
	self:Layout();
end

function PlayerChoiceBaseOptionButtonFrameTemplateMixin:OnReset()
	FunctionUtil.SafeInvokeMethod(self.Button, "OnReset");
end

PlayerChoiceBaseOptionButtonTemplateMixin = {};

function PlayerChoiceBaseOptionButtonTemplateMixin:OnLoad()
	self.parentOption = self:GetParent():GetParent():GetParent();
	self.disabledFont = self:GetDisabledFontObject();
end

local COMPLETED_ATLAS_MARKUP = CreateAtlasMarkup("common-icon-checkmark", 16, 16);

function PlayerChoiceBaseOptionButtonTemplateMixin:Setup(buttonInfo, optionInfo)
	local enabledState = not buttonInfo.disabled;
	if self.Text then
		if buttonInfo.showCheckmark then
			self:SetText(COMPLETED_ATLAS_MARKUP);
		else
			self:SetText(buttonInfo.text);
		end

		if buttonInfo.hideButtonShowText then
			self.Text:SetIgnoreParentAlpha(true);
			self:SetAlpha(0);
			enabledState = false;
		else
			self.Text:SetIgnoreParentAlpha(false);
			self:SetAlpha(1);
		end
	end

	self:SetEnabled(enabledState);

	if buttonInfo.selected then
		self:SetPushed(buttonInfo.selected);
	end

	self.confirmation = buttonInfo.confirmation;
	self.tooltip = buttonInfo.tooltip;
	self.rewardQuestID = buttonInfo.rewardQuestID;
	self.buttonID = buttonInfo.id;
	self.optionID = optionInfo.id;
	self.soundKitID = buttonInfo.soundKitID;
	self.keepOpenAfterChoice = buttonInfo.keepOpenAfterChoice;
end

function PlayerChoiceBaseOptionButtonTemplateMixin:OnReset()
	self.pushed = false;
	self:SetDisabledFontObject(self.disabledFont);
	self:SetPushed(false);
end

function PlayerChoiceBaseOptionButtonTemplateMixin:OnConfirm()
	C_PlayerChoice.SendPlayerChoiceResponse(self.buttonID);
	self.parentOption:OnSelected();
end

StaticPopupDialogs["CONFIRM_PLAYER_CHOICE"] = {
	text = "%s",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		data.owner:OnConfirm();
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

	OnAccept = function(dialog, data)
		data.owner:OnConfirm();
	end,
	OnShow = function(dialog, data)
		dialog:GetButton1():Disable();
		dialog:GetButton2():Enable();
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		if dialog:GetButton1():IsEnabled() then
			data.owner:OnConfirm();
			dialog:Hide();
		end
	end,
	EditBoxOnTextChanged = function(editBox, data)
		StaticPopup_StandardConfirmationTextHandler(editBox, data.confirmationString);
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
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

	if self.soundKitID then
		PlaySound(self.soundKitID);
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

function PlayerChoiceBaseOptionButtonTemplateMixin:SetPushed(pushed)
	self.pushed = pushed;
	self:SetEnabled(not pushed);

	self:SetDisabledFontObject(pushed and self:GetNormalFontObject() or self.disabledFont);

	local buttonTextureStateKey = pushed and "Down" or "Up";
	self.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-"..buttonTextureStateKey);
	self.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-"..buttonTextureStateKey);
	self.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-"..buttonTextureStateKey);
end

PlayerChoiceBaseOptionButtonsContainerMixin = {};

function PlayerChoiceBaseOptionButtonsContainerMixin:OnLoad()
	self.buttonFramePool = CreateFramePoolCollection();
	self.initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self, "TOPLEFT", 0, 0);
	self.numColumns = 1;
end

function PlayerChoiceBaseOptionButtonsContainerMixin:OnHide()
	self.topPadding = 5;
end

function PlayerChoiceBaseOptionButtonsContainerMixin:SetPaddedHeight(paddedHeight)
	local paddingHeight = (paddedHeight - self:GetHeight()) + 5;
	self.topPadding = math.max(paddingHeight, 5);
end

function PlayerChoiceBaseOptionButtonsContainerMixin:Setup(optionInfo, showAsList)
	local buttonStride = math.max(math.floor(#optionInfo.buttons / self.numColumns), 1);

	if buttonStride ~= self.lastStride then
		self.layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRightVertical, buttonStride, 20, 5);
		self.lastStride = buttonStride;
	end

	self.buttonFramePool:ReleaseAll();

	local buttonFrameTemplate = showAsList and self.listButtonFrameTemplate or self.buttonFrameTemplate;
	self.buttonFramePool:GetOrCreatePool("Frame", self, buttonFrameTemplate, GenerateClosure(self.OptionButtonResetter, self));

	local buttonFrames = {};
	for buttonIndex, buttonInfo in ipairs(optionInfo.buttons) do
		local buttonFrame = self.buttonFramePool:Acquire(buttonFrameTemplate);
		buttonFrame:Setup(buttonInfo, optionInfo, showAsList);
		buttonFrame:Show();
		table.insert(buttonFrames, buttonFrame);
	end

	AnchorUtil.GridLayout(buttonFrames, self.initialAnchor, self.layout);
end

function PlayerChoiceBaseOptionButtonsContainerMixin:OptionButtonResetter(framePool, optionButton, _new)
	Pool_HideAndClearAnchors(framePool, optionButton);

	FunctionUtil.SafeInvokeMethod(optionButton, "OnReset");
end

function PlayerChoiceBaseOptionButtonsContainerMixin:DisableButtons()
	for buttonFrame in self.buttonFramePool:EnumerateActive() do
		buttonFrame.Button:Disable();
	end
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
	local factionData = C_Reputation.GetFactionDataByID(repRewardInfo.factionId);
	if factionData then
		self.Text:SetText(REWARD_REPUTATION_WITH_AMOUNT:format(repRewardInfo.quantity, factionData.name));
		self.Text:SetTextColor(fontColor:GetRGBA());
	end
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

PlayerChoiceWidgetContainerMixin = {}

function PlayerChoiceWidgetContainerMixin:IsLayoutFrame()
	-- Return false here because the widget container is used as the filler frame for player choice options
	-- This prevents Layout from getting called on the widget container due to the Layout call in SetMinHeight (after padding has been added to it)
	return false;
end
