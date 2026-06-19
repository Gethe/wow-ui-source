SocialUITabMixin = CreateFromMixins(SidePanelTabButtonMixin);

function SocialUITabMixin:Initialize(tabData)
	if not tabData then
		return;
	end

	self.tabData = tabData;
	self.tooltipText = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(tabData.tabName);
	self.activeAtlas = tabData.iconAtlas;
	self.inactiveAtlas = tabData.iconInactiveAtlas or tabData.iconAtlas;
	self:RefreshCounter();
end

function SocialUITabMixin:Reset()
	self.tabData = nil;
	self.tooltipText = nil;
	self.activeAtlas = nil;
	self.inactiveAtlas = nil;
	self.activeHelpTipSystem = nil;
	self:SetChecked(false);
	self:SetTabGlowAnimationPlaying(false);
	self:SetCount(nil);
end

function SocialUITabMixin:OnMouseDown(button)
	if button == "LeftButton" then
		local yOffset = self.iconBaseYOffset or 0;
		self.Icon:SetPoint("CENTER", -1, yOffset - 1);
	end
end

function SocialUITabMixin:OnMouseUp(button, upInside)
	if button == "LeftButton" then
		self.Icon:SetPoint("CENTER", -2, self.iconBaseYOffset or 0);
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	end

	if self.customMouseUpHandler then
		self.customMouseUpHandler(self, button, upInside);
	end
end

function SocialUITabMixin:RefreshCounter()
	local countGenerator = self.tabData and self.tabData.countGenerator;
	if not countGenerator then
		self:SetCount(nil);
		return;
	end

	local count = countGenerator();
	self:SetCount(count);
end

function SocialUITabMixin:SetCount(count)
	local hasCount = count and count > 0;
	self.Count:SetShown(hasCount);
	self.Count:SetText(hasCount and AbbreviateNumbers(count) or "");

	self:RefreshIconAnchoring();
end

function SocialUITabMixin:RefreshIconAnchoring()
	local isCountVisible = self.Count:IsShown();
	self.iconBaseYOffset = isCountVisible and 5 or 0;
	self.Icon:SetPoint("CENTER", -2, self.iconBaseYOffset);
end

SocialUIOnlineStatusDropdownMixin = {};

local SocialUIOnlineStatusDropdownEvents =
{
	"BN_INFO_CHANGED",
};

function SocialUIOnlineStatusDropdownMixin:OnLoad()
	WowStyle1DropdownMixin.OnLoad(self);
	self:SetWidth(54);
end

function SocialUIOnlineStatusDropdownMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SocialUIOnlineStatusDropdownEvents);
	self:RefreshPresenceTypeSelf();
	self:InitializeMenu();
end

function SocialUIOnlineStatusDropdownMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SocialUIOnlineStatusDropdownEvents);
end

function SocialUIOnlineStatusDropdownMixin:OnEvent(_event, ...)
	self:RefreshPresenceTypeSelf();
	self:GenerateMenu();
end

function SocialUIOnlineStatusDropdownMixin:RefreshPresenceTypeSelf()
	self.presenceTypeSelf = SocialUIUtil.GetPresenceTypeSelf();
end

function SocialUIOnlineStatusDropdownMixin:InitializeMenu()
	local function IsSelected(presenceType)
		return self.presenceTypeSelf == presenceType;
	end

	local function SetSelected(presenceType)
		local presenceTypeAlreadySet = presenceType == self.presenceTypeSelf;
		if presenceTypeAlreadySet then
			return;
		end

		self.presenceTypeSelf = presenceType;
		SocialUIUtil.SetBattleNetPresenceFromSocialUIPresence(presenceType);
	end

	local function CreateRadio(rootDescription, text, presenceType)
		local radio = rootDescription:CreateButton(text, nop, presenceType);
		radio:SetIsSelected(IsSelected);
		radio:SetResponder(SetSelected);
		return radio;
	end

	self:SetSelectionTranslator(function(selection)
		local presenceIcon = SocialUIUtil.GetIconForPresenceType(selection.data);
		local iconSize = self.presenceIconSizeForDropdown;
		return CreateAtlasMarkup(presenceIcon, iconSize, iconSize);
	end);

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_SOCIAL_UI_BATTLE_NET_PRESENCE");

		local function CreatePresenceRadio(presenceType, label)
			local presenceIcon = SocialUIUtil.GetIconForPresenceType(presenceType);
			local iconSize = self.presenceIconSizeForDropdown;
			local iconMarkup = CreateAtlasMarkup(presenceIcon, iconSize, iconSize);

			local radio = CreateRadio(rootDescription, SOCIAL_UI_PRESENCE_TYPE_DROPDOWN_FORMAT:format(iconMarkup, label), presenceType);
			radio:AddInitializer(SocialUIUtil.InitializeUserScaledDropdownButton);
		end

		CreatePresenceRadio(Enum.SocialUIPresenceType.Online, SOCIAL_UI_PRESENCE_TYPE_LABEL_ONLINE);
		CreatePresenceRadio(Enum.SocialUIPresenceType.Away, SOCIAL_UI_PRESENCE_TYPE_LABEL_AWAY);
		CreatePresenceRadio(Enum.SocialUIPresenceType.Busy, SOCIAL_UI_PRESENCE_TYPE_LABEL_BUSY);
		CreatePresenceRadio(Enum.SocialUIPresenceType.Offline, SOCIAL_UI_PRESENCE_TYPE_LABEL_APPEAR_OFFLINE);
	end);

	self:SetScript("OnEnter", function()
		local presenceLabel = SocialUIUtil.GetLabelForPresenceType(self.presenceTypeSelf);
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT", -18, 0);
		GameTooltip_AddNormalLine(tooltip, SOCIAL_UI_PRESENCE_TYPE_DROPDOWN_TOOLTIP_FORMAT:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(presenceLabel)));
		tooltip:Show();
	end);
	self:SetScript("OnLeave", function() GetAppropriateTooltip():Hide() end);
end

SocialUIBattleNetMenuButtonMixin = CreateFromMixins(SocialUISystemMixin);

function SocialUIBattleNetMenuButtonMixin:OnShow()
	self:Refresh();
end

function SocialUIBattleNetMenuButtonMixin:Refresh()
	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_SOCIAL_UI_BATTLE_NET_BAR");

		local function CreateBattleNetMenuButton(buttonLabel, onClickFunction)
			local button = rootDescription:CreateButton(buttonLabel, onClickFunction);
			button:AddInitializer(SocialUIUtil.InitializeUserScaledDropdownButton);
			return button;
		end

		if self:ShouldShowBroadcastMenuOption() then
			CreateBattleNetMenuButton(SOCIAL_UI_MENU_BROADCAST_BUTTON_LABEL, function()
				self:SocialUIRequestToggleSideWindow(SocialUISideWindowType.BattleNetBroadcastFrame);
			end);
		end

		if self:ShouldShowIgnoreListMenuOption() then
			CreateBattleNetMenuButton(SOCIAL_UI_MENU_IGNORE_LIST_BUTTON_LABEL, function()
				self:SocialUIRequestToggleSideWindow(SocialUISideWindowType.IgnoreListFrame);
			end);
		end
	end);
end

function SocialUIBattleNetMenuButtonMixin:OnMouseDown()
	self.Icon:AdjustPointsOffset(1, -1);
end

function SocialUIBattleNetMenuButtonMixin:OnMouseUp()
	self.Icon:AdjustPointsOffset(-1, 1);
end

function SocialUIBattleNetMenuButtonMixin:OnEnter()
	self:ShowTooltip();
end

function SocialUIBattleNetMenuButtonMixin:ShowTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(tooltip, SOCIAL_UI_BATTLE_NET_BAR_MENU_BUTTON_LABEL);
	tooltip:Show();
end

function SocialUIBattleNetMenuButtonMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

function SocialUIBattleNetMenuButtonMixin:ShouldShowBroadcastMenuOption()
	return BNFeaturesEnabled() and BNConnected();
end

function SocialUIBattleNetMenuButtonMixin:ShouldShowIgnoreListMenuOption()
	return not C_Glue.IsOnGlueScreen();
end

function SocialUIBattleNetMenuButtonMixin:HasAnyAvailableMenuOptions()
	return self:ShouldShowBroadcastMenuOption() or self:ShouldShowIgnoreListMenuOption();
end

SocialUIPersonalBattleTagDisplayMixin = {};

function SocialUIPersonalBattleTagDisplayMixin:ShowBestDisplayTextAndButton()
	if not BNFeaturesEnabled() then
		return;
	end

	local isConnectedToBattleNet = BNConnected();
	if isConnectedToBattleNet then
		self:ShowBattleTag();
	else
		self:ShowBattleNetUnavailableNotice();
	end
	self.BattleNetUnavailableNoticeButton:SetShown(not isConnectedToBattleNet);
	self.CopyBattleTagToClipboardButton:SetShown(isConnectedToBattleNet);
end

function SocialUIPersonalBattleTagDisplayMixin:ShowBattleNetUnavailableNotice()
	self.DisplayText:SetText(NORMAL_FONT_COLOR:WrapTextInColorCode(SOCIAL_UI_BATTLE_NET_UNAVAILABLE_NOTICE));
end

function SocialUIPersonalBattleTagDisplayMixin:ShowBattleTag()
	self.battleTag = BNet_GetBattleTagSelf();
	local battleTagComponents = BNet_GetBattleTagComponents(self.battleTag);
	local coloredBattleTag = BATTLE_TAG_FONT_COLOR:WrapTextInColorCode(battleTagComponents.prefix or "") .. BATTLE_TAG_SUFFIX_FONT_COLOR:WrapTextInColorCode(battleTagComponents.tagSplitSymbol or "") .. BATTLE_TAG_SUFFIX_FONT_COLOR:WrapTextInColorCode(battleTagComponents.suffix or "");
	self.DisplayText:SetText(coloredBattleTag);
end

function SocialUIPersonalBattleTagDisplayMixin:OnEnter()
	self:ShowTooltipIfTruncated();
end

function SocialUIPersonalBattleTagDisplayMixin:ShowTooltipIfTruncated()
	if not self.DisplayText or not self.DisplayText:IsTruncated() then
		return;
	end

	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");

	local wrapText = false;
	GameTooltip_AddNormalLine(tooltip, self.DisplayText:GetText(), wrapText);
	tooltip:Show();
end

function SocialUIPersonalBattleTagDisplayMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

SocialUICopyBattleTagToClipboardButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function SocialUICopyBattleTagToClipboardButtonMixin:OnLoad()
	self:SetDisplacedRegions(1, -1, self.Icon, self.HighlightTexture);
end

function SocialUICopyBattleTagToClipboardButtonMixin:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);
	self:AddTooltip();
end

function SocialUICopyBattleTagToClipboardButtonMixin:AddTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(tooltip, SOCIAL_UI_BATTLE_TAG_COPY_BUTTON_LABEL, HIGHLIGHT_FONT_COLOR);
	tooltip:Show();
end

function SocialUICopyBattleTagToClipboardButtonMixin:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);
	GetAppropriateTooltip():Hide();
end

function SocialUICopyBattleTagToClipboardButtonMixin:OnClick()
	self:CopyBattleTagToClipboard();
	self:DisplayCopiedNotice();

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function SocialUICopyBattleTagToClipboardButtonMixin:CopyBattleTagToClipboard()
	local battleTag = BNet_GetBattleTagSelf();
	CopyToClipboard(battleTag);
end

function SocialUICopyBattleTagToClipboardButtonMixin:DisplayCopiedNotice()
	ChatFrameUtil.AddSystemMessage(SOCIAL_UI_PERSONAL_BATTLE_TAG_COPIED_NOTICE);
end

SocialUIBattleNetUnavailableNoticeButtonMixin = CreateFromMixins(SocialUISystemMixin);

function SocialUIBattleNetUnavailableNoticeButtonMixin:OnClick()
	self:SocialUIRequestToggleSideWindow(SocialUISideWindowType.BattleNetUnavailableNoticeFrame);
end

SocialUIBattleNetControlsContainerMixin = {};

local SocialUIBattleNetControlsContainerEvents =
{
	"BN_CONNECTED",
	"BN_DISCONNECTED",
	"BN_INFO_CHANGED",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_FLAGS_CHANGED",
	"FRAMES_LOADED",
};

function SocialUIBattleNetControlsContainerMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SocialUIBattleNetControlsContainerEvents);
	EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", self.LayoutPersonalBattleTagDisplayText, self);

	self:FullRefresh();
end

function SocialUIBattleNetControlsContainerMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SocialUIBattleNetControlsContainerEvents);
	EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self);
end

function SocialUIBattleNetControlsContainerMixin:RefreshElementVisibility()
	local battleNetFeaturesEnabled = BNFeaturesEnabled();
	local battleNetConnected = BNConnected();
	self.OnlineStatusDropdown:SetShown(battleNetFeaturesEnabled);
	self.PersonalBattleTagDisplay:SetShown(battleNetFeaturesEnabled);
	self.BattleNetBackground:SetShown(battleNetFeaturesEnabled);

	local shouldShowBattleNetMenuButton = self.BattleNetMenuButton:HasAnyAvailableMenuOptions();
	self.BattleNetMenuButton:SetShown(shouldShowBattleNetMenuButton);

	if not battleNetConnected then
		self.BattleNetMenuButton:SocialUIRequestHideSideWindow(SocialUISideWindowType.BattleNetBroadcastFrame);
	end
end

function SocialUIBattleNetControlsContainerMixin:FullRefresh()
	self:RefreshElementVisibility();
	self:RefreshPersonalBattleTagDisplay();
end

function SocialUIBattleNetControlsContainerMixin:OnEvent(event, ...)
	self:FullRefresh();
end

function SocialUIBattleNetControlsContainerMixin:RefreshPersonalBattleTagDisplay()
	self.PersonalBattleTagDisplay:ShowBestDisplayTextAndButton();
	self:LayoutPersonalBattleTagDisplayText();
end

-- The text we display in the BattleTag display can significantly vary in length (we either show the BattleTag or the "Battle.net unavailable" notice)
-- We generally want the text to be centered within the our background.
-- However, we have the OnlineStatusDropdown on the left side of the background, which means long text will grow and hit a limit on the left side first.
-- This means we need to dynamically adjust the text position between two modes: centered if it fits without overlapping OnlineStatusDropdown, or left-aligned if it will overlap.
function SocialUIBattleNetControlsContainerMixin:LayoutPersonalBattleTagDisplayText()
	local battleTagDisplay = self.PersonalBattleTagDisplay;
	local displayText = battleTagDisplay.DisplayText;

	-- The battleTagDisplay's left side is directly anchored to OnlineStatusDropdown's right side. That is our limit for text growth.
	-- Let's measure the center of the background to that left side to figure out how much space the text has to grow to the left before overlapping
	local backgroundCenterX = (self.BattleNetBackground:GetCenter());
	local availableHalfWidth = backgroundCenterX - battleTagDisplay:GetLeft();

	local textWidth = displayText:GetUnboundedStringWidth();
	local textFitsCentered = (textWidth / 2) <= availableHalfWidth;

	displayText:ClearAllPoints();
	if textFitsCentered then
		displayText:SetPoint("CENTER", self.BattleNetBackground, "CENTER");
		displayText:SetJustifyH("CENTER");
		displayText:SetWidth(textWidth);
	else
		displayText:SetPoint("LEFT", battleTagDisplay, "LEFT", 4, 0);
		displayText:SetJustifyH("LEFT");

		-- We have a button anchored to the right side of the text, so we need to account for its width to make sure the text + button both fit within the background.
		local buttonPadding = 16;
		local visibleButton = battleTagDisplay.CopyBattleTagToClipboardButton:IsShown() and battleTagDisplay.CopyBattleTagToClipboardButton or battleTagDisplay.BattleNetUnavailableNoticeButton;
		local buttonSpace = visibleButton:GetWidth() + buttonPadding;
		displayText:SetWidth(math.min(textWidth, battleTagDisplay:GetWidth() - buttonSpace));
	end
end

SocialUIBattleNetUnavailableNoticeFrameMixin = {};

function SocialUIBattleNetUnavailableNoticeFrameMixin:OnShow()
	EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", self.Refresh, self);
	self:Refresh();

	PlaySound(SOUNDKIT.IG_CHAT_EMOTE_BUTTON);
end

function SocialUIBattleNetUnavailableNoticeFrameMixin:OnHide()
	EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self);

	PlaySound(SOUNDKIT.IG_CHAT_EMOTE_BUTTON);
end

function SocialUIBattleNetUnavailableNoticeFrameMixin:Refresh()
	self:Layout();
end

SocialUIBattleNetBroadcastFrameMixin = {};

function SocialUIBattleNetBroadcastFrameMixin:OnLoad()
	self:InitializeBroadcastFrameElements();
end

function SocialUIBattleNetBroadcastFrameMixin:InitializeBroadcastFrameElements()
	self.EditBox:SetScript("OnEnterPressed", function()
		self:SetBroadcast();
	end);

	self.UpdateButton:SetScript("OnClick", function()
		self:SetBroadcast();
	end);

	self.CancelButton:SetScript("OnClick", function()
		self:SocialUIRequestHideSideWindow(SocialUISideWindowType.BattleNetBroadcastFrame);
	end);
end

local SocialUIBattleNetBroadcastFrameEvents =
{
	"BN_CUSTOM_MESSAGE_CHANGED",
	"BN_CUSTOM_MESSAGE_LOADED",
};

function SocialUIBattleNetBroadcastFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SocialUIBattleNetBroadcastFrameEvents);
	EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", self.Layout, self);

	self:FullRefresh();

	PlaySound(SOUNDKIT.IG_CHAT_EMOTE_BUTTON);
end

function SocialUIBattleNetBroadcastFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SocialUIBattleNetBroadcastFrameEvents);
	EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self);

	self.EditBox:ClearFocus();

	PlaySound(SOUNDKIT.IG_CHAT_EMOTE_BUTTON);
end

function SocialUIBattleNetBroadcastFrameMixin:OnEvent(event, ...)
	if event == "BN_CUSTOM_MESSAGE_CHANGED" then
		local bnetIDAccount = ...;
		local messageChangedSelf = not bnetIDAccount;
		if messageChangedSelf then
			self:RefreshBroadcastText();
		end
	elseif event == "BN_CUSTOM_MESSAGE_LOADED" then
		self:RefreshBroadcastText();
	end
end

function SocialUIBattleNetBroadcastFrameMixin:OnMouseDown()
	self.EditBox:SetFocus();
end

function SocialUIBattleNetBroadcastFrameMixin:FullRefresh()
	self:RefreshBroadcastText();
	self.EditBox:SetFocus();
	self:Layout();
end

function SocialUIBattleNetBroadcastFrameMixin:RefreshBroadcastText()
	local currentBroadcastText = BNet_GetBroadcastTextSelf();
	self.EditBox:SetText(currentBroadcastText);
end

function SocialUIBattleNetBroadcastFrameMixin:SetBroadcast()
	local pendingBroadcastText = self.EditBox:GetText();
	local currentBroadcastText = BNet_GetBroadcastTextSelf();
	if pendingBroadcastText ~= currentBroadcastText then
		C_BattleNet.SetCustomMessage(pendingBroadcastText);
	end

	self:SocialUIRequestHideSideWindow(SocialUISideWindowType.BattleNetBroadcastFrame);
end

SocialUIBattleNetBroadcastEditBoxMixin = {};

function SocialUIBattleNetBroadcastEditBoxMixin:OnTextChanged()
	self:RefreshPromptTextVisibility();
end

function SocialUIBattleNetBroadcastEditBoxMixin:RefreshPromptTextVisibility()
	local shouldShowPromptText = self:GetText() == "";
	self.PromptText:SetShown(shouldShowPromptText);
end

function SocialUIBattleNetBroadcastEditBoxMixin:OnEscapePressed()
	self:ClearFocus();
end

SocialUIIgnoreListMixin = CreateFromMixins(SocialUIScrollableElementExtentPreviewerMixin);

local SocialUIIgnoreListEvents =
{
	"IGNORELIST_UPDATE",
	"BN_BLOCK_LIST_UPDATED",
};

function SocialUIIgnoreListMixin:OnLoad()
	self:InitializeUserScaledSizing();
	self:InitializeFrameVisuals();
	self:InitializeScrollBox();
	self:InitializeButtons();
end

function SocialUIIgnoreListMixin:InitializeUserScaledSizing()
	UserScaledElementMixin.OnLoad_UserScaledElement(self);
	SocialUIScrollableElementExtentPreviewerMixin.OnLoad(self);
end

function SocialUIIgnoreListMixin:InitializeFrameVisuals()
	ButtonFrameTemplate_HidePortrait(self);

	self:SetTitle(SOCIAL_UI_IGNORE_LIST_TITLE);

	self.TopTileStreaks:Hide();
	self.Inset:ClearAllPoints();
	self.Inset:SetPoint("TOPLEFT", self, "TOPLEFT", 11, -28);
	self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -6, 0);
	self.Inset:SetPoint("BOTTOM", self.BlockButton, "TOP", 0, 6);

	self.ScrollBox:ClearAllPoints();
	self.ScrollBox:SetPoint("TOPLEFT", self.Inset, 5, -5);
	self.ScrollBox:SetPoint("BOTTOMRIGHT", self.Inset, -22, 2);
end

function SocialUIIgnoreListMixin:InitializeScrollBox()
	self:RegisterScrollableTemplatesForExtentPreview({"SocialUIIgnoreListHeaderTemplate", "SocialUIIgnoreListEntryTemplate"});

	local function IgnoreListHeaderInitializer(button, elementData)
		button:Initialize(elementData);
	end

	local function IgnoreListEntryInitializer(button, elementData)
		button:SetScript("OnClick", function()
			self.selectionBehavior:SelectElementData(elementData);
		end);

		button:Initialize(elementData);
	end

	local function GetBestTemplateForElementData(elementData)
		local isHeader = elementData.headerText ~= nil;
		return isHeader and "SocialUIIgnoreListHeaderTemplate" or "SocialUIIgnoreListEntryTemplate";
	end

	local topPadding, bottomPadding, leftPadding, rightPadding = 0, 0, 0, 0;
	local elementSpacing = 1;
	local view = CreateScrollBoxListLinearView(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);
	view:SetElementFactory(function(factory, elementData)
		local isHeader = elementData.headerText ~= nil;
		if isHeader then
			factory("SocialUIIgnoreListHeaderTemplate", IgnoreListHeaderInitializer);
		else
			factory("SocialUIIgnoreListEntryTemplate", IgnoreListEntryInitializer);
		end
	end);

	view:SetElementExtentCalculator(function(dataIndex, elementData)
		local templateName = GetBestTemplateForElementData(elementData);
		return templateName and self:GetTemplateExtent(templateName) or 0;
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox, SelectionBehaviorFlags.Intrusive);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, self.OnSelectionChanged, self);
end

function SocialUIIgnoreListMixin:InitializeButtons()
	self:InitializeBlockButton();
	self:InitializeUnblockButton();
	self:InitializeCloseButton();
end

function SocialUIIgnoreListMixin:InitializeBlockButton()
	self.BlockButton:SetScript("OnClick", function()
		self:BlockPlayer();
	end);
end

function SocialUIIgnoreListMixin:InitializeUnblockButton()
	self.UnblockButton:SetScript("OnClick", function()
		self:UnblockSelected();
	end);
end

function SocialUIIgnoreListMixin:InitializeCloseButton()
	self.onCloseCallback = GenerateClosure(self.SocialUIRequestHideSideWindow, self);
end

function SocialUIIgnoreListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SocialUIIgnoreListEvents);

	EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", self.OnIgnoreListTextScaleUpdated, self);
	self:ClearTemplateExtentCache();

	self:FullRefresh();

	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function SocialUIIgnoreListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SocialUIIgnoreListEvents);
	EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self);

	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function SocialUIIgnoreListMixin:OnEvent(_event, ...)
	self:FullRefresh();
end

function SocialUIIgnoreListMixin:OnIgnoreListTextScaleUpdated()
	if self:IsShown() then
		self:FullRefresh();
	end
end

function SocialUIIgnoreListMixin:FullRefresh()
	self:ClearTemplateExtentCache();
	self:RefreshDataProvider();
	self:SelectFirstEntryIfNoneSelected();
	self:RefreshButtons();
end

function SocialUIIgnoreListMixin:RefreshDataProvider()
	local dataProvider = CreateDataProvider();

	local numIgnores = C_FriendList.GetNumIgnores();
	local shouldAddIgnores = numIgnores > 0;
	if shouldAddIgnores then
		dataProvider:Insert({ headerText = SOCIAL_UI_IGNORE_LIST_IGNORE_HEADER });
		for index = 1, numIgnores do
			dataProvider:Insert({ blockType = Enum.SocialUIBlockType.Ignore, blockIndex = index });
		end
	end

	local numBattleNetBlocks = BNGetNumBlocked();
	local shouldAddBattleNetBlocks = numBattleNetBlocks > 0;
	if shouldAddBattleNetBlocks then
		dataProvider:Insert({ headerText = SOCIAL_UI_IGNORE_LIST_BATTLE_NET_BLOCK_HEADER });
		for index = 1, numBattleNetBlocks do
			dataProvider:Insert({ blockType = Enum.SocialUIBlockType.BattleNetInviteBlock, blockIndex = index });
		end
	end

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function SocialUIIgnoreListMixin:RefreshButtons()
	self.UnblockButton:SetEnabled(self.selectionBehavior:HasSelection());
end

function SocialUIIgnoreListMixin:SelectFirstEntryIfNoneSelected()
	if self.selectionBehavior:HasSelection() then
		return;
	end

	local isValidEntry = function(elementData)
		return elementData.blockType ~= nil;
	end;
	self.selectionBehavior:SelectFirstElementData(isValidEntry);
end

function SocialUIIgnoreListMixin:OnSelectionChanged(elementData, isSelected)
	if not elementData or not elementData.blockType then
		return;
	end

	if isSelected then
		if elementData.blockType == Enum.SocialUIBlockType.Ignore then
			C_FriendList.SetSelectedIgnore(elementData.blockIndex);
		elseif elementData.blockType == Enum.SocialUIBlockType.BattleNetInviteBlock then
			BNSetSelectedBlock(elementData.blockIndex);
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end

	local entry = self.ScrollBox:FindFrame(elementData);
	if entry then
		entry:SetSelected(isSelected);
	end

	self:RefreshButtons();
end

function SocialUIIgnoreListMixin:BlockPlayer()
	if not UnitCanCooperate("player", "target") or not UnitIsHumanPlayer("target") then
		StaticPopup_Show("ADD_IGNORE");
		return;
	end

	local name, server = UnitName("target");
	local finalName = name;
	local isDifferentRealm = server and UnitRealmRelationship("target") ~= LE_REALM_RELATION_SAME;
	if isDifferentRealm then
		finalName = name .. "-" .. server;
	end
	C_FriendList.AddIgnore(finalName);

	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function SocialUIIgnoreListMixin:UnblockSelected()
	local selectedElementData = self.selectionBehavior:GetFirstSelectedElementData();
	if not selectedElementData then
		return;
	end

	if selectedElementData.blockType == Enum.SocialUIBlockType.Ignore then
		C_FriendList.DelIgnoreByIndex(C_FriendList.GetSelectedIgnore());
	elseif selectedElementData.blockType == Enum.SocialUIBlockType.BattleNetInviteBlock then
		local blockID, _blockedName = BNGetBlockedInfo(BNGetSelectedBlock());
		BNSetBlocked(blockID, false);
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

SocialUIIgnoreListHeaderMixin = {};

function SocialUIIgnoreListHeaderMixin:Initialize(elementData)
	self.elementData = elementData;
	self:RefreshText();
end

function SocialUIIgnoreListHeaderMixin:RefreshText()
	local headerText = self.elementData.headerText or "";
	self.Text:SetText(headerText);
end

SocialUIIgnoreListEntryMixin = {};

function SocialUIIgnoreListEntryMixin:Initialize(elementData)
	self.elementData = elementData;

	self:FullRefresh();
end

function SocialUIIgnoreListEntryMixin:GetBlockType()
	return self.elementData and self.elementData.blockType;
end

function SocialUIIgnoreListEntryMixin:GetBlockIndex()
	return self.elementData and self.elementData.blockIndex;
end

function SocialUIIgnoreListEntryMixin:FullRefresh()
	self:RefreshName();
	self:RefreshSelected();
end

function SocialUIIgnoreListEntryMixin:RefreshName()
	if not self.elementData then
		return;
	end

	local name = SocialUIUtil.GetBlockedName(self.elementData.blockType, self.elementData.blockIndex);
	self.Name:SetText(name);
end

function SocialUIIgnoreListEntryMixin:RefreshSelected()
	local selected = SelectionBehaviorMixin.IsElementDataIntrusiveSelected(self.elementData);
	self:SetSelected(selected);
end

function SocialUIIgnoreListEntryMixin:SetSelected(selected)
	self:SetHighlightLocked(selected);
end

SocialUIRaidInfoFrameMixin = {}

local RAID_INFO_FRAME_EVENTS =
{
	"PLAYER_ENTERING_WORLD",
	"UPDATE_INSTANCE_INFO",
};

function SocialUIRaidInfoFrameMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("SocialUIRaidInfoContentFrameTemplate", GenerateClosure(self.InitButton, self));

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	NineSliceUtil.ApplyLayoutByName(self.Border, "Dialog");

	self.CloseButton:SetScript("OnClick", function()
		self:SocialUIRequestHideSideWindow(SocialUISideWindowType.RaidInfo);
	end)
end

function SocialUIRaidInfoFrameMixin:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		RequestRaidInfo();
	elseif event == "UPDATE_INSTANCE_INFO" then
		self:UpdateScrollAndButtons();
	end
end

function SocialUIRaidInfoFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RAID_INFO_FRAME_EVENTS);
	RequestRaidInfo();
	self:UpdateScrollAndButtons();
end

function SocialUIRaidInfoFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RAID_INFO_FRAME_EVENTS);
end

function SocialUIRaidInfoFrameMixin:UpdateButtons()
	local function Lock()
		self.ExtendButton:SetText(EXTEND_RAID_LOCK);
		self.ExtendButton:Disable();
	end
	if self.selectedIndex then
		if self.selectedIsInstance then
			local _, _, _, _, locked, extended, _, _, _, _, _, _, extendDisabled, _ = GetSavedInstanceInfo(self.selectedIndex);
			self.ExtendButton:SetEnabled(not extendDisabled);
			self.ExtendButton.doExtend = not extended;
			if extended then
				self.ExtendButton:SetText(UNEXTEND_RAID_LOCK);
			else
				self.ExtendButton:SetText(locked and EXTEND_RAID_LOCK or REACTIVATE_RAID_LOCK);
			end
		else
			Lock();
		end
	else
		Lock();
	end
end

function SocialUIRaidInfoFrameMixin:UpdateScrollAndButtons()
	local dataProvider = CreateDataProvider();
	for index = 1, GetNumSavedInstances() do
		dataProvider:Insert({index=index, isInstance=true});
	end

	for index = 1, GetNumSavedWorldBosses() do
		dataProvider:Insert({index=index});
	end

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	self:UpdateButtons();
end

function SocialUIRaidInfoFrameMixin:InitButton(button, elementData)
	local function Init(extended, locked, reset, name, difficulty)
		if extended or locked then
			button.reset:SetText(SecondsToTime(reset, true, nil, 3));
			button.name:SetText(name);
		else
			button.reset:SetText(RAID_INSTANCE_EXPIRES_EXPIRED);
			button.name:SetText(name);
			button.reset:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
			button.name:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		end
		button.difficulty:SetText(difficulty);
		button.extended:SetShown(extended);
		button.parent = self;
	end

	local index = elementData.index;
	if elementData.isInstance then
		local name, instanceID, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName = GetSavedInstanceInfo(index);
		Init(extended, locked, reset, name, difficultyName);
		button.instanceID = instanceID;
	else
		local name, _, reset = GetSavedWorldBossInfo(index);
		local locked = true;
		local extended = false;
		Init(extended, locked, reset, name, RAID_INFO_WORLD_BOSS);

		button.instanceID = nil;
	end

	local selected = self.selectedIndex == index and self.selectedIsInstance == elementData.isInstance;
	self:SetButtonSelected(button, selected);
end

function SocialUIRaidInfoFrameMixin:SetButtonSelected(button, selected)
	button:SetHighlightLocked(selected);
end

SocialUIRaidInfoExtendMixin = {}

function SocialUIRaidInfoExtendMixin:OnClick()
	local parent = self:GetParent();
	if parent.selectedIndex and parent.selectedIndex <= GetNumSavedInstances() then
		SetSavedInstanceExtend(parent.selectedIndex, self.doExtend);
		RequestRaidInfo();
		parent:UpdateScrollAndButtons();
	end
end

SocialUIRaidInfoContentFrameMixin = {}

function SocialUIRaidInfoContentFrameMixin:OnMouseUp()
	self.name:SetPoint("TOPLEFT", 3, -10);
	self.reset:SetPoint("TOPRIGHT", 0, -11);
end

function SocialUIRaidInfoContentFrameMixin:OnMouseDown()
	self.name:SetPoint("TOPLEFT", 5, -12);
	self.reset:SetPoint("TOPRIGHT", 2, -13);
end

function SocialUIRaidInfoContentFrameMixin:OnClick()
	if self.instanceID and IsModifiedClick("CHATLINK") then
		ChatFrameUtil.InsertLink(GetSavedInstanceChatLink(self:GetElementData().index));
	else
		local oldSelectedIndex = self.parent.selectedIndex;
		local oldSelectedIsInstance = self.parent.selectedIsInstance;
		local elementData = self:GetElementData();
		self.parent.selectedIndex = elementData.index;
		self.parent.selectedIsInstance = elementData.isInstance;

		local function UpdateButtonSelected(index, isInstance, selected)
			if index then
				local button = self.parent.ScrollBox:FindFrameByPredicate(function(button, elementData)
					return elementData.index == index and elementData.isInstance == isInstance;
				end);
				if button then
					self.parent:SetButtonSelected(button, selected);
				end
			end
		end

		UpdateButtonSelected(oldSelectedIndex, oldSelectedIsInstance, false);
		UpdateButtonSelected(self.parent.selectedIndex, self.parent.selectedIsInstance, true);

		self.parent:UpdateButtons();
	end
end

function SocialUIRaidInfoContentFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.instanceID then
		GameTooltip:SetInstanceLockEncountersComplete(self:GetElementData().index);
	else
		local instanceName, _, _ = GetSavedWorldBossInfo(self:GetElementData().index);
		GameTooltip:SetText(instanceName);
	end
	GameTooltip:Show();
end

function SocialUIRaidInfoContentFrameMixin:OnLeave()
	GameTooltip:Hide();
end
