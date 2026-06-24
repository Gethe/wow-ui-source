RecentAlliesListMixin = {};

local RecentAlliesListEvents = {
	"RECENT_ALLIES_CACHE_UPDATE",
};

function RecentAlliesListMixin:OnLoad()
	self:InitializeScrollBox();
end

function RecentAlliesListMixin:InitializeScrollBox()
	local elementSpacing = 1;
	local topPadding, bottomPadding, leftPadding, rightPadding = 0, 0, 0, 0;
	local view = CreateScrollBoxListLinearView(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);
	view:SetElementFactory(function(factory, elementData)
		if elementData.isDivider then
			factory("RecentAlliesDividerTemplate");
		else
			factory("RecentAlliesEntryTemplate", function(button, elementData)
				button:Initialize(elementData);
				button:SetScript("OnClick", function(button, mouseButtonName)
					if mouseButtonName == "LeftButton" then
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
						self.selectionBehavior:ToggleSelect(button);
					elseif mouseButtonName == "RightButton" then
						button:OpenMenu();
					end
				end);
			end);
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox, SelectionBehaviorFlags.Intrusive);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, function(o, elementData, selected)
		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end
	end, self);
end

function RecentAlliesListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RecentAlliesListEvents);

	C_RecentAllies.TryRequestRecentAlliesData();
	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
end

function RecentAlliesListMixin:SelectFirstRecentAlly()
	self.selectionBehavior:SelectFirstElementData();
end

function RecentAlliesListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RecentAlliesListEvents);
end

function RecentAlliesListMixin:OnEvent(event, ...)
	if event == "RECENT_ALLIES_CACHE_UPDATE" then
		self:Refresh(ScrollBoxConstants.RetainScrollPosition);
	end
end

function RecentAlliesListMixin:Refresh(retainScrollPosition)
	local dataReady = C_RecentAllies.IsRecentAllyDataReady();
	self:SetLoadingSpinnerShown(not dataReady);
	if not dataReady then
		return;
	end

	self.ScrollBox:SetDataProvider(self:BuildRecentAlliesDataProvider(), retainScrollPosition);
	if not retainScrollPosition then
		self:SelectFirstRecentAlly();
	end
end

-- Assumes the data provider has pinned recent allies presorted to the front
local function GetBestIndexForPinStateDivider(dataProvider)
	local firstUnpinnedAllyIndex = dataProvider:FindIndexByPredicate(function(elementData) return not elementData.stateData.pinExpirationDate end);

	-- If there are no unpinned allies, no divider is needed
	if not firstUnpinnedAllyIndex then
		return nil;
	end

	-- If the first unpinned ally is at the start, there are no pinned allies
	if firstUnpinnedAllyIndex == 1 then
		return nil;
	end

	-- Otherwise, insert the divider before the first unpinned ally
	return firstUnpinnedAllyIndex;
end

local function TryInsertPinStateDividerIntoDataProvider(dataProvider)
	local indexForPinStateDivider = GetBestIndexForPinStateDivider(dataProvider);
	if indexForPinStateDivider then
		dataProvider:InsertAtIndex({ isDivider = true }, indexForPinStateDivider);
	end
end

function RecentAlliesListMixin:BuildRecentAlliesDataProvider()
	-- Recent Allies are presorted by pin state, online status, most recently interacted, and then alphabetically
	local dataProvider = CreateDataProvider(C_RecentAllies.GetRecentAllies());

	TryInsertPinStateDividerIntoDataProvider(dataProvider);

	return dataProvider;
end

function RecentAlliesListMixin:SetLoadingSpinnerShown(shown)
	-- We shouldn't show the spinner and the scrolling list at the same time
	self.LoadingSpinner:SetShown(shown);
	self.ScrollBox:SetShown(not shown);
	self.ScrollBar:SetShown(not shown);
end

RecentAlliesEntryMixin = {};

function RecentAlliesEntryMixin:OnLoad()
	self.PartyButton:SetScript("OnClick", function()
		local characterData = self.elementData and self.elementData.characterData or nil;
		if characterData and characterData.fullName then
			C_PartyInfo.InviteUnit(characterData.fullName);
		end
	end);
end

function RecentAlliesEntryMixin:Initialize(elementData)
	self.elementData = elementData;
	self:InitializeCharacterData();
	self:InitializeStateDisplay();
	self:SetMostRecentInteraction();

	self:SetSelected(SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData));
end

function RecentAlliesEntryMixin:OnEnter()
	self:ShowTooltip();
end

function RecentAlliesEntryMixin:OnLeave()
	GameTooltip:Hide();
end

function RecentAlliesEntryMixin:ShowTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:BuildRecentAllyTooltip(GameTooltip);
	GameTooltip:Show();
end

function RecentAlliesEntryMixin:BuildRecentAllyTooltip(tooltip)
	self:AddCharacterDataToTooltip(tooltip);
	self:AddStateDataToTooltip(tooltip);
	self:AddInteractionDataToTooltip(tooltip);
end

local function AddCharacterNameToTooltip(tooltip, characterData)
	GameTooltip_AddNormalLine(tooltip, characterData.fullName);
end

local function AddCharacterLevelAndRaceToTooltip(tooltip, characterData)
	local raceInfo = C_CreatureInfo.GetRaceInfo(characterData.raceID);
	local dividerAtlasMarkup = CreateAtlasMarkup("charactercreate-customize-dropdown-linemouseover-middle", 1, 10);
	GameTooltip_AddHighlightLine(tooltip, RECENT_ALLY_TOOLTIP_LEVEL_RACE_FORMAT:format(characterData.level, dividerAtlasMarkup, raceInfo and raceInfo.raceName or ""));
end

local function AddCharacterClassToTooltip(tooltip, characterData)
	local classInfo = C_CreatureInfo.GetClassInfo(characterData.classID);
	GameTooltip_AddHighlightLine(tooltip, RECENT_ALLY_TOOLTIP_CLASS_FORMAT:format(classInfo and classInfo.className or ""));
end

local function AddCharacterFactionInfoToTooltip(tooltip, characterData)
	local factionInfo = C_CreatureInfo.GetFactionInfo(characterData.raceID);
	GameTooltip_AddHighlightLine(tooltip, factionInfo and factionInfo.name or "");
end

function RecentAlliesEntryMixin:AddCharacterDataToTooltip(tooltip)
	local characterData = self.elementData.characterData;
	AddCharacterNameToTooltip(tooltip, characterData);
	AddCharacterLevelAndRaceToTooltip(tooltip, characterData);
	AddCharacterClassToTooltip(tooltip, characterData);
	AddCharacterFactionInfoToTooltip(tooltip, characterData);
end

local function TryAddCurrentLocationInfoToTooltip(tooltip, stateData)
	if stateData.currentLocation then
		GameTooltip_AddHighlightLine(tooltip, stateData.currentLocation);
	end
end

function RecentAlliesEntryMixin:AddStateDataToTooltip(tooltip)
	TryAddCurrentLocationInfoToTooltip(tooltip, self.elementData.stateData);
end

function RecentAlliesEntryMixin:AddInteractionsToTooltip(tooltip)
	local mostRecentInteraction = self:GetMostRecentInteraction();
	if not mostRecentInteraction then
		return;
	end
	
	local leftTooltipText = RECENT_ALLY_RECENT_ACTIVITIES_LABEL;
	local timeSinceInteraction = GetServerTime() - mostRecentInteraction.timestamp;
	local rightTooltipText = RECENT_ALLY_INTERACTION_TIME_FORMAT:format(RecentAlliesUtil.GetFormattedTime(timeSinceInteraction));
	tooltip:AddDoubleLine(leftTooltipText, rightTooltipText, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);

	GameTooltip_AddHighlightLine(tooltip, self:ConvertInteractionToTooltipString(mostRecentInteraction));
end

local function TryAddNoteInfoToTooltip(tooltip, interactionData)
	local note = interactionData.note;
	if note and note ~= "" then
		GameTooltip_AddNormalLine(tooltip, RECENT_ALLY_NOTE_FORMAT:format(note));
	end
end

function RecentAlliesEntryMixin:AddInteractionDataToTooltip(tooltip)
	TryAddNoteInfoToTooltip(tooltip, self.elementData.interactionData);
	
	if self:HasInteractions() then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		self:AddInteractionsToTooltip(tooltip);
	end
end

function RecentAlliesEntryMixin:GetMostRecentInteraction()
	if self:HasInteractions() then
		-- Assuming the list of interactions is presorted from most recent to least recent
		return self.elementData.interactionData.interactions[1];
	end
end

function RecentAlliesEntryMixin:InitializeStateDisplay()
	local stateData = self.elementData.stateData;
	self:UpdateOnlineStatusIcon();
	self:UpdateBackgroundForOnlineStatus(stateData.isOnline);

	self.StateIconContainer.PinDisplay:Init(stateData);
	self.StateIconContainer.FriendRequestPendingDisplay:SetShown(stateData.friendRequestSentThisSession);
	self.StateIconContainer.PinDisplay:SetShown(stateData.pinExpirationDate ~= nil);

	self.PartyButton:SetEnabled(stateData.isOnline);
	
	self:SetCharacterLocation(stateData.currentLocation);
end

function RecentAlliesEntryMixin:GetBestIconForOnlineStatus()
	local stateData = self.elementData.stateData;
	if not stateData.isOnline then
		return "Interface\\FriendsFrame\\StatusIcon-Offline";
	elseif stateData.isAFK then
		return "Interface\\FriendsFrame\\StatusIcon-Away";
	elseif stateData.isDND then
		return "Interface\\FriendsFrame\\StatusIcon-DnD";
	else
		return "Interface\\FriendsFrame\\StatusIcon-Online";
	end
end

function RecentAlliesEntryMixin:UpdateOnlineStatusIcon()
	self.OnlineStatusIcon:SetTexture(self:GetBestIconForOnlineStatus());
end

function RecentAlliesEntryMixin:SetMostRecentInteraction()
	local mostRecentInteraction = self:GetMostRecentInteraction();
	self.CharacterData.MostRecentInteraction:SetText(mostRecentInteraction and mostRecentInteraction.description or "");
end

function RecentAlliesEntryMixin:ConvertInteractionToTooltipString(interactionData)
	if not interactionData then
		return "";
	end

	local contextData = interactionData.contextData;
	-- If we need item data, ensure it is loaded here before moving on
	if contextData and contextData.itemID then
		local item = Item:CreateFromItemID(contextData.itemID);
		if item and not item:IsItemDataCached() then
			item:ContinueOnItemLoad(function()
				self:ShowTooltip();
			end);
			return;
		end
	end

	return RecentAlliesUtil.GenerateContextStringForInteraction(interactionData);
end

function RecentAlliesEntryMixin:HasInteractions()
	return #self.elementData.interactionData.interactions > 0;
end

function RecentAlliesEntryMixin:UpdateBackgroundForOnlineStatus(online)
	local bestBackgroundColor = online and FRIENDS_WOW_BACKGROUND_COLOR or FRIENDS_OFFLINE_BACKGROUND_COLOR;
	self.NormalTexture:SetColorTexture(bestBackgroundColor:GetRGBA());
end

function RecentAlliesEntryMixin:InitializeCharacterData()
	self:SetCharacterName();
	self:SetCharacterLevel();
	self:SetCharacterClass();
	self:RefreshCharacterDataDividerColor();
end

local function GetBestCharacterDataDisplayColor(stateData)
	return stateData and stateData.isOnline and NORMAL_FONT_COLOR or FRIENDS_GRAY_COLOR;
end

function RecentAlliesEntryMixin:SetCharacterName()
	self.CharacterData.Name:SetText(GetBestCharacterDataDisplayColor(self.elementData.stateData):WrapTextInColorCode(self.elementData.characterData.name));
	self.CharacterData.Name:SetWidth(math.min(self.CharacterData.Name:GetUnboundedStringWidth(), self.CharacterData.Name.maxWidth));
end

function RecentAlliesEntryMixin:SetCharacterLevel()
	self.CharacterData.Level:SetText(GetBestCharacterDataDisplayColor(self.elementData.stateData):WrapTextInColorCode(self.elementData.characterData.level));
	self.CharacterData.Level:SetWidth(self.CharacterData.Level:GetUnboundedStringWidth());
end

function RecentAlliesEntryMixin:SetCharacterClass()
	local classInfo = C_CreatureInfo.GetClassInfo(self.elementData.characterData.classID);
	if not classInfo then
		self.CharacterData.Class:SetText("");
		return;
	end

	local bestFontColor = self.elementData.stateData.isOnline and GetClassColorObj(classInfo.classFile) or FRIENDS_GRAY_COLOR;
	self.CharacterData.Class:SetText(bestFontColor:WrapTextInColorCode(classInfo.className));
end

function RecentAlliesEntryMixin:SetCharacterLocation(location)
	self.CharacterData.Location:SetText(location or "");
end

function RecentAlliesEntryMixin:RefreshCharacterDataDividerColor()
	local bestDividerColor = GetBestCharacterDataDisplayColor(self.elementData.stateData)
	for index, divider in ipairs(self.CharacterData.Dividers) do
		divider:SetVertexColor(bestDividerColor:GetRGB());
	end
end

function RecentAlliesEntryMixin:SetSelected(selected)
	self:SetHighlightLocked(selected);
end

function RecentAlliesEntryMixin:OpenMenu()
	local recentAllyData = self.elementData;
	local contextData = {
		recentAllyData = recentAllyData,
		-- The generic unit popup code expects data in the format  below, so we duplicate a couple things for compatibility
		name = recentAllyData.characterData.name,
		server = recentAllyData.characterData.realmName,
		guid = recentAllyData.characterData.guid,
		isOffline = not recentAllyData.stateData.isOnline,
	};

	local bestMenu = recentAllyData.stateData.isOnline and "RECENT_ALLY" or "RECENT_ALLY_OFFLINE";
	UnitPopup_OpenMenu(bestMenu, contextData);
end

RecentAlliesEntryPartyButtonMixin = {};

function RecentAlliesEntryPartyButtonMixin:OnEnter()
	self:ShowTooltip();
end

function RecentAlliesEntryPartyButtonMixin:ShowTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, RECENT_ALLIES_PARTY_BUTTON_TOOLTIP);

	if not self:IsEnabled() then
		GameTooltip_AddErrorLine(GameTooltip, self:GetBestDisabledTooltip());
	end

	GameTooltip:Show();
end

function RecentAlliesEntryPartyButtonMixin:GetBestDisabledTooltip()
	return RECENT_ALLIES_PARTY_BUTTON_OFFLINE_TOOLTIP;
end

function RecentAlliesEntryPartyButtonMixin:OnLeave()
	GameTooltip:Hide();
end

RecentAlliesEntryPinDisplayMixin = {};

function RecentAlliesEntryPinDisplayMixin:Init(stateData)
	self.pinExpirationDate = stateData.pinExpirationDate;
	self:RefreshPinExpirationIcon();
end

local function IsPinNearingExpiration(pinExpirationDate)
	if not pinExpirationDate then
		return false;
	end

	local remainingDays = (pinExpirationDate - GetServerTime()) / SECONDS_PER_DAY;
	return remainingDays <= Constants.RecentAlliesConsts.PIN_EXPIRATION_WARNING_DAYS;
end

function RecentAlliesEntryPinDisplayMixin:RefreshPinExpirationIcon()
	self.Icon:SetAtlas(IsPinNearingExpiration(self.pinExpirationDate) and "friendslist-recentallies-pin" or "friendslist-recentallies-pin-yellow", TextureKitConstants.IgnoreAtlasSize);
end

function RecentAlliesEntryPinDisplayMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local wrapText = false;
	if IsPinNearingExpiration(self.pinExpirationDate) then
		-- Set to a minimum of 1 second (lowest we should show is "< 1 Hour")
		local timeUntilExpiration = math.max(self.pinExpirationDate - GetServerTime(), 1);
		GameTooltip_AddHighlightLine(GameTooltip, RECENT_ALLY_PIN_EXPIRING_TOOLTIP:format(RecentAlliesUtil.GetFormattedTime(timeUntilExpiration), wrapText));
	else
		GameTooltip_AddHighlightLine(GameTooltip, RECENT_ALLY_PIN_TOOLTIP, wrapText);
	end

	GameTooltip:Show();
end

function RecentAlliesEntryPinDisplayMixin:OnLeave()
	GameTooltip:Hide();
end

RecentAlliesSocialViewMixin = CreateFromMixins(SocialUISystemMixin, SocialUIScrollableElementExtentPreviewerMixin);

local RecentAlliesSocialViewEvents =
{
	"RECENT_ALLIES_CACHE_UPDATE",
};

function RecentAlliesSocialViewMixin:OnLoad()
	-- Keep track of this even when hidden so we can tell the Social UI to refresh our tab if it is visible
	self:RegisterEvent("RECENT_ALLIES_SYSTEM_STATUS_UPDATED");

	SocialUIScrollableElementExtentPreviewerMixin.OnLoad(self);
	self:InitializeActionButton();
	self:InitializeScrollBox();
end

function RecentAlliesSocialViewMixin:InitializeActionButton()
	Mixin(self.ActionButton, SocialUIAddFriendButtonMixin);
	self.ActionButton:SetText(SOCIAL_UI_RECENT_ALLIES_ADD_FRIEND_BUTTON_LABEL);
end

function RecentAlliesSocialViewMixin:InitializeScrollBox()
	self:RegisterScrollableTemplatesForExtentPreview({
		"SocialUIScrollableHeaderTemplate",
		{ template = "RecentAlliesSocialCardTemplate", baseHeightCalculator = RecentAlliesSocialCardMixin.GetActiveBaseHeight },
		"SocialUIScrollableSpacerTemplate",
	});

	local topPadding, bottomPadding, leftPadding, rightPadding = 10, 10, 10, 7;
	local childElementIndent, elementSpacing = 0, 3;
	local view = CreateScrollBoxListTreeListView(childElementIndent, topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);

	local function InitializeHeaderButton(button, node)
		button:Initialize(node);
		button:SetScript("OnClick", function(clickedButton, _buttonName)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
			node:ToggleCollapsed();
			clickedButton:UpdateCollapsedState(node:IsCollapsed());
		end);
	end

	local function InitializeCardButton(button, node)
		button:Initialize(node);
		button:SetScript("OnClick", function(clickedButton, mouseButtonName)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
			if mouseButtonName == "LeftButton" then
				self.selectionBehavior:ToggleSelect(clickedButton);
			elseif mouseButtonName == "RightButton" then
				clickedButton:OpenMenu();
			end
		end);
	end

	local function IsSpacerNode(node)
		return node:GetData().isSpacer;
	end

	local function IsHeaderNode(node)
		return node:GetData().headerText ~= nil;
	end

	local function GetBestTemplateForNode(node)
		if IsSpacerNode(node) then
			return "SocialUIScrollableSpacerTemplate";
		elseif IsHeaderNode(node) then
			return "SocialUIScrollableHeaderTemplate";
		else
			return "RecentAlliesSocialCardTemplate";
		end
	end

	local function GetBestInitializerForNode(node)
		if IsSpacerNode(node) then
			return nil;
		elseif IsHeaderNode(node) then
			return InitializeHeaderButton;
		else
			return InitializeCardButton;
		end
	end

	view:SetElementFactory(function(factory, node)
		local template = GetBestTemplateForNode(node);
		local initializer = GetBestInitializerForNode(node);
		factory(template, initializer);
	end);

	view:SetElementExtentCalculator(function(_dataIndex, node)
		local elementTemplate = GetBestTemplateForNode(node);
		return self:GetTemplateExtent(elementTemplate);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox, SelectionBehaviorFlags.Deselectable, SelectionBehaviorFlags.Intrusive);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, function(_o, elementData, selected)
		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end
	end, self);
end

function RecentAlliesSocialViewMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RecentAlliesSocialViewEvents);

	EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", self.OnRecentAlliesTextScaleUpdated, self);
	self:ClearTemplateExtentCache();

	C_RecentAllies.TryRequestRecentAlliesData();
	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
end

function RecentAlliesSocialViewMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RecentAlliesSocialViewEvents);

	EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self);
end

function RecentAlliesSocialViewMixin:OnEvent(event, ...)
	if event == "RECENT_ALLIES_SYSTEM_STATUS_UPDATED" then
		self:TriggerSocialUIEvent(SocialUIFrameMixin.Event.FeatureAvailabilityChanged);
	elseif event == "RECENT_ALLIES_CACHE_UPDATE" then
		self:Refresh(ScrollBoxConstants.RetainScrollPosition);
	end
end

function RecentAlliesSocialViewMixin:OnRecentAlliesTextScaleUpdated()
	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function RecentAlliesSocialViewMixin:Refresh(retainScrollPosition)
	self:RefreshActionButtonEnabledState();

	local dataReady = C_RecentAllies.IsRecentAllyDataReady();
	self:SetLoadingSpinnerShown(not dataReady);
	if not dataReady then
		return;
	end

	self:ClearTemplateExtentCache();
	self.ScrollBox:SetDataProvider(self:GenerateDataProvider(), retainScrollPosition);
end

local function PartitionRecentAlliesByPinState(allies)
	local pinnedAllies = {};
	local unpinnedAllies = {};
	for _index, ally in ipairs(allies) do
		local isPinned = ally.stateData.pinExpirationDate ~= nil;
		if isPinned then
			table.insert(pinnedAllies, ally);
		else
			table.insert(unpinnedAllies, ally);
		end
	end

	return pinnedAllies, unpinnedAllies;
end

local function TryInsertRecentAlliesSubTree(dataProvider, headerFormatString, allies)
	local treeHasEntries = allies and #allies > 0;
	if not treeHasEntries then
		return;
	end

	local newSubTree = dataProvider:Insert({});
	newSubTree:Insert({ isSpacer = true });

	local onlineCount = 0;
	for _index, ally in ipairs(allies) do
		if ally.stateData.isOnline then
			onlineCount = onlineCount + 1;
		end
		newSubTree:Insert(ally);
	end

	newSubTree:GetData().headerText = headerFormatString:format(onlineCount, #allies);
end

function RecentAlliesSocialViewMixin:GenerateDataProvider()
	local dataProvider = CreateTreeDataProvider();

	local pinnedAllies, unpinnedAllies = PartitionRecentAlliesByPinState(C_RecentAllies.GetRecentAllies());
	TryInsertRecentAlliesSubTree(dataProvider, SOCIAL_UI_RECENT_ALLIES_VIEW_HEADER_PINNED, pinnedAllies);

	local listWillShowBothTrees = (#pinnedAllies > 0) and (#unpinnedAllies > 0);
	if listWillShowBothTrees then
		dataProvider:Insert({ isSpacer = true });
	end

	TryInsertRecentAlliesSubTree(dataProvider, SOCIAL_UI_RECENT_ALLIES_VIEW_HEADER_UNPINNED, unpinnedAllies);

	return dataProvider;
end

RecentAlliesSocialCardMixin = {};

function RecentAlliesSocialCardMixin:OnLoad()
	self.PartyButton:SetScript("OnClick", function()
		local characterData = self.elementData and self.elementData.characterData or nil;
		if characterData and characterData.fullName then
			C_PartyInfo.InviteUnit(characterData.fullName);
		end
	end);
end

function RecentAlliesSocialCardMixin:Initialize(node)
	self.elementData = node:GetData();

	self:InitializeDisplay();

	local selected = SelectionBehaviorMixin.IsElementDataIntrusiveSelected(node);
	self:SetSelected(selected);
end

function RecentAlliesSocialCardMixin:SetSelected(selected)
	self:SetHighlightLocked(selected);
end

function RecentAlliesSocialCardMixin:InitializeDisplay()
	self:InitializeBackground();
	self:InitializePresenceDisplay();
	self:InitializePartyButton();
	self:InitializeCardDisplayText();
end

function RecentAlliesSocialCardMixin:InitializeBackground()
	local bestBackgroundAtlas = self.elementData.stateData.isOnline and "friends-card-default" or "friends-card-disabled";
	self.Background:SetAtlas(bestBackgroundAtlas);
end

function RecentAlliesSocialCardMixin:InitializePresenceDisplay()
	local presenceType = RecentAlliesUtil.GetBestSocialUIPresenceTypeForStateData(self.elementData.stateData);
	self.PresenceHolder:SetPresence(presenceType);
end

function RecentAlliesSocialCardMixin:InitializePartyButton()
	self.PartyButton:SetEnabledState(self.elementData.stateData.isOnline);
end

function RecentAlliesSocialCardMixin:InitializeCardDisplayText()
	self:RefreshCharacterDataDisplayText();
	self:RefreshMostRecentInteractionDisplayText();
	self:RefreshLocationDisplayText();

	-- The state display is holds icons that are anchored to the side of the character data display text 
	-- We need to initialize it here before we layout/anchor the strings
	self:InitializeStateDisplay();

	self:LayoutScaledContent();
end

local function BuildCharacterNameDisplayText(characterData, stateData)
	local displayColor = stateData and stateData.isOnline and NORMAL_FONT_COLOR or DARKGRAY_COLOR;
	return displayColor:WrapTextInColorCode(characterData.name);
end

local function BuildCharacterLevelDisplayText(characterData, stateData)
	local levelText = string.format(SOCIAL_UI_RECENT_ALLIES_CARD_LEVEL_DISPLAY_FORMAT, characterData.level);
	local displayColor = stateData and stateData.isOnline and HIGHLIGHT_FONT_COLOR or DARKGRAY_COLOR;
	return displayColor:WrapTextInColorCode(levelText);
end

local function BuildCharacterClassDisplayText(characterData, stateData)
	local classInfo = C_CreatureInfo.GetClassInfo(characterData.classID);
	if not classInfo then
		return "";
	end

	local displayColor = stateData and stateData.isOnline and GetClassColorObj(classInfo.classFile) or DARKGRAY_COLOR;
	return displayColor:WrapTextInColorCode(classInfo.className);
end

function RecentAlliesSocialCardMixin:RefreshCharacterDataDisplayText()
	local characterData = self.elementData.characterData;
	local stateData = self.elementData.stateData;

	local nameText = BuildCharacterNameDisplayText(characterData, stateData);
	self.Name:SetText(nameText);

	local levelText = BuildCharacterLevelDisplayText(characterData, stateData);
	self.Level:SetText(levelText);

	local classText = BuildCharacterClassDisplayText(characterData, stateData);
	self.Class:SetText(classText);
end

local function BuildMostRecentInteractionDisplayText(interactionData, stateData)
	if #interactionData.interactions == 0 then
		return "";
	end

	-- Assuming the list of interactions is presorted from most recent to least recent
	local interactionText = interactionData.interactions[1].description;
	local displayColor = stateData and stateData.isOnline and FRIENDS_GRAY_COLOR or DARKGRAY_COLOR;
	return displayColor:WrapTextInColorCode(interactionText);
end

function RecentAlliesSocialCardMixin:RefreshMostRecentInteractionDisplayText()
	local interactionText = BuildMostRecentInteractionDisplayText(self.elementData.interactionData, self.elementData.stateData);
	self.MostRecentInteraction:SetText(interactionText);
end

local function BuildCurrentLocationDisplayText(stateData)
	local locationText = stateData.currentLocation or "";
	local displayColor = stateData and stateData.isOnline and FRIENDS_GRAY_COLOR or DARKGRAY_COLOR;
	return displayColor:WrapTextInColorCode(locationText);
end

function RecentAlliesSocialCardMixin:RefreshLocationDisplayText()
	local locationText = BuildCurrentLocationDisplayText(self.elementData.stateData);
	self.Location:SetText(locationText);
end

function RecentAlliesSocialCardMixin:InitializeStateDisplay()
	self.StateDisplay:Initialize(self.elementData.stateData);
end

-- We attempt to keep the anchoring of elements visually consistent as they get bigger due to font scaling
-- Ex. Icons and buttons get larger as the font scales up, so we need to adjust their anchoring offsets to keep them in the same relative position
function RecentAlliesSocialCardMixin:LayoutScaledContent()
	self:LayoutScaledPresenceHolderAnchors();
	self:LayoutScaledTextHolderAnchors();

	if self:ShouldUseExpandedLayout() then
		self:LayoutCardDisplayTextExpanded();
	else
		self:LayoutCardDisplayTextCompact();
	end
end

function RecentAlliesSocialCardMixin:LayoutScaledPresenceHolderAnchors()
	local presenceHolder = self.PresenceHolder;

	local scaleWeightSource = presenceHolder;
	local scaledPresenceHolderXOffset = TextSizeManager:GetScaledValueWeighted(self.presenceHolderXOffset, scaleWeightSource);
	local scaledPresenceHolderYOffset = TextSizeManager:GetScaledValueWeighted(self.presenceHolderYOffset, scaleWeightSource);

	presenceHolder:ClearAllPoints();
	presenceHolder:SetPoint("CENTER", self, "TOPLEFT", scaledPresenceHolderXOffset, scaledPresenceHolderYOffset);
end

function RecentAlliesSocialCardMixin:LayoutScaledTextHolderAnchors()
	local textHolder = self.TextHolder;
	local presenceHolder = self.PresenceHolder;

	local scaleWeightSource = presenceHolder;
	local scaledTextHolderTopLeftXOffset = TextSizeManager:GetScaledValueWeighted(self.textHolderTopLeftXOffset, scaleWeightSource);
	local scaledTextHolderTopLeftYOffset = TextSizeManager:GetScaledValueWeighted(self.textHolderTopLeftYOffset, scaleWeightSource);

	textHolder:ClearAllPoints();
	textHolder:SetPoint("TOPLEFT", presenceHolder, "BOTTOMRIGHT", scaledTextHolderTopLeftXOffset, scaledTextHolderTopLeftYOffset);
	textHolder:SetPoint("RIGHT", self.PartyButton, "LEFT", self.textHolderRightXOffset, 0);
	textHolder:SetPoint("BOTTOM", self, "BOTTOM", 0, self.textHolderBottomYOffset);
end

function RecentAlliesSocialCardMixin:LayoutSecondaryTextLines(textToAnchorTo)
	local lineSpacing = TextSizeManager:GetScaledValue(self.lineSpacing);

	self.MostRecentInteraction:ClearAllPoints();
	self.MostRecentInteraction:SetPoint("TOPLEFT", textToAnchorTo, "BOTTOMLEFT", self.secondaryTextIndent, -lineSpacing);
	self.MostRecentInteraction:SetPoint("RIGHT", self.TextHolder);

	self.Location:ClearAllPoints();
	self.Location:SetPoint("TOPLEFT", self.MostRecentInteraction, "BOTTOMLEFT", 0, -lineSpacing);
	self.Location:SetPoint("RIGHT", self.TextHolder);
end

-- Compact layout: Character Name, Level, Class, and StateDisplay all on one row
function RecentAlliesSocialCardMixin:LayoutCardDisplayTextCompact()
	-- We start with the entire width of the text holder available to us
	local totalAvailableRowWidth = self.TextHolder:GetWidth();
	local remainingUsableRowWidth = totalAvailableRowWidth;

	-- We know we have 3 strings (name, level, class) which means we need to reserve the space for the two spaces between them
	remainingUsableRowWidth = remainingUsableRowWidth - (self.interStringTextSpacing * 2);

	-- We may also have state display icons to fit on this row, so we need to reserve space for them as well
	local stateDisplay = self.StateDisplay;
	local stateDisplayWidth = stateDisplay:GetWidth();
	local scaleWeightSource = stateDisplay;
	local scaledStateDisplayXOffset = (stateDisplayWidth > 0) and TextSizeManager:GetScaledValueWeighted(self.stateDisplayXOffset, scaleWeightSource) or 0;
	remainingUsableRowWidth = remainingUsableRowWidth - stateDisplayWidth - scaledStateDisplayXOffset;

	-- Now that we know how much space exists for text on this row we can calculate the width of each string
	-- We start with the level text because it's never truncated
	local levelWidth = self.Level:GetUnboundedStringWidth();
	self.Level:SetWidth(levelWidth);
	remainingUsableRowWidth = remainingUsableRowWidth - levelWidth;

	-- Next we look at the name.
	-- The name can get up to 50% of the row...
	local maxNameWidthByRatio = totalAvailableRowWidth * 0.5;
	-- ... but we need to show at least part of the class name so it might get less than 50% if the level text is very long.
	local minClassWidth = 30;
	local maxNameWidthByRemainingSpace = remainingUsableRowWidth - minClassWidth;
	-- We pick whichever limit is smaller...
	local bestMaxNameWidth = math.min(maxNameWidthByRatio, maxNameWidthByRemainingSpace);
	-- ... and clamp it to 0 in case the untruncated level text ate all the space (shouldn't happen, but just to be safe)
	bestMaxNameWidth = math.max(bestMaxNameWidth, 0);

	local finalNameWidth = math.min(self.Name:GetUnboundedStringWidth(), bestMaxNameWidth);
	self.Name:SetWidth(finalNameWidth);
	remainingUsableRowWidth = remainingUsableRowWidth - finalNameWidth;

	-- Then finally, the class name gets whatever text space remains after Name and Level (we already reserved at least minClassWidth for it assuming the level text isn't huge)
	local classWidth = math.min(self.Class:GetUnboundedStringWidth(), math.max(remainingUsableRowWidth, 0));
	self.Class:SetWidth(classWidth);

	-- With all the calculations done we can now anchor the text elements on this row (name is always anchored to the text holder)
	self.Level:ClearAllPoints();
	self.Level:SetPoint("LEFT", self.Name, "RIGHT", self.interStringTextSpacing, 0);
	self.Level:SetPoint("TOP", self.Name);

	self.Class:ClearAllPoints();
	self.Class:SetPoint("LEFT", self.Level, "RIGHT", self.interStringTextSpacing, 0);
	self.Class:SetPoint("TOP", self.Level);

	stateDisplay:ClearAllPoints();
	stateDisplay:SetPoint("LEFT", self.Class, "RIGHT", scaledStateDisplayXOffset, 0);

	-- And then anchor the secondary text lines (Interaction and Location) below the Name row
	local textToAnchorTo = self.Name;
	self:LayoutSecondaryTextLines(textToAnchorTo);
end

-- Expanded layout: Character Name + StateDisplay on row 1, Level + Class on row 2
function RecentAlliesSocialCardMixin:LayoutCardDisplayTextExpanded()
	local availableWidth = self.TextHolder:GetWidth();

	-- Row 1:
	-- We start with the entire width of the text holder available to us
	local remainingRow1UsableWidth = availableWidth;

	-- We may have state display icons to fit on this row, so we need to reserve space for them
	local stateDisplay = self.StateDisplay;
	local stateDisplayWidth = stateDisplay:GetWidth();
	local scaleWeightSource = stateDisplay;
	local scaledStateDisplayXOffset = (stateDisplayWidth > 0) and TextSizeManager:GetScaledValueWeighted(self.stateDisplayXOffset, scaleWeightSource) or 0;
	remainingRow1UsableWidth = remainingRow1UsableWidth - stateDisplayWidth - scaledStateDisplayXOffset;

	-- Then the name gets whatever width remains on this row after the state display
	local nameWidth = math.min(self.Name:GetUnboundedStringWidth(), remainingRow1UsableWidth);
	self.Name:SetWidth(nameWidth);

	-- Row 2: 
	-- We start with the entire width of the text holder available to us
	local remainingRow2UsableWidth = availableWidth;

	-- We know we're displaying the level and class name, so we need to reserve space for the one space between the two strings
	remainingRow2UsableWidth = remainingRow2UsableWidth - self.interStringTextSpacing;

	-- We need to show at least part of the class name, so we reserve some space for that before giving level its width
	local minClassWidth = 30;
	local levelWidth = math.min(self.Level:GetUnboundedStringWidth(), remainingRow2UsableWidth - minClassWidth);
	self.Level:SetWidth(levelWidth);

	-- With all the calculations done we can now anchor the state display to the name on Row 1...
	stateDisplay:ClearAllPoints();
	stateDisplay:SetPoint("LEFT", self.Name, "RIGHT", scaledStateDisplayXOffset, 0);

	--...anchor the text elements for Row 2 under Row 1...
	local lineSpacing = TextSizeManager:GetScaledValue(self.lineSpacing);
	self.Level:ClearAllPoints();
	self.Level:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, -lineSpacing);

	-- Class fills whatever space remains between Level and the TextHolder's right edge
	self.Class:ClearAllPoints();
	self.Class:SetPoint("LEFT", self.Level, "RIGHT", self.interStringTextSpacing, 0);
	self.Class:SetPoint("TOP", self.Level);
	self.Class:SetPoint("RIGHT", self.TextHolder);

	-- ...and anchor the secondary text lines (Interaction and Location) under Row 2
	local textToAnchorTo = self.Level;
	self:LayoutSecondaryTextLines(textToAnchorTo);
end

-- Normally we display cards in a compact layout with 3 rows of text (Row 1: Character data, Row 2: Interaction data, Row 3: Current location)
-- With larger text sizes we switch to an expanded 4 line layout so the character data has more room (Row 1: Character Name, Row 2: Level and Class, Row 3: Interaction, Row 4: Location)
function RecentAlliesSocialCardMixin.ShouldUseExpandedLayout()
	local hasLargerTextSizeThanDefault = TextSizeManager:GetSettingValue() > TextSizeManager:GetSettingDefaultValue();
	return hasLargerTextSizeThanDefault;
end

function RecentAlliesSocialCardMixin.GetActiveBaseHeight()
	return RecentAlliesSocialCardMixin.ShouldUseExpandedLayout() and 87 or 70;
end

function RecentAlliesSocialCardMixin:OpenMenu()
	local recentAllyData = self.elementData;
	local contextData =
	{
		recentAllyData = recentAllyData,
		-- The generic unit popup code expects data in the format  below, so we duplicate a couple things for compatibility
		name = recentAllyData.characterData.name,
		server = recentAllyData.characterData.realmName,
		guid = recentAllyData.characterData.guid,
		isOffline = not recentAllyData.stateData.isOnline,
		menuElementPreInitializer = SocialUIUtil.InitializeUserScaledDropdownButton,
		menuTitlePreInitializer = SocialUIUtil.InitializeUserScaledDropdownTitle,
	};

	local bestMenu = recentAllyData.stateData.isOnline and "RECENT_ALLY" or "RECENT_ALLY_OFFLINE";
	UnitPopup_OpenMenu(bestMenu, contextData);
end

function RecentAlliesSocialCardMixin:OnEnter()
	self:ShowTooltip();
end

function RecentAlliesSocialCardMixin:ShowTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	tooltip:SetMinimumWidth(250);
	self:BuildTooltip(tooltip);
	tooltip:Show();
end

function RecentAlliesSocialCardMixin:BuildTooltip(tooltip)
	self:AddCharacterDataToTooltip(tooltip);
	self:AddStateDataToTooltip(tooltip);
	self:AddInteractionDataToTooltip(tooltip);
end

local function AddCharacterNameHeaderToTooltip(tooltip, elementData)
	local isOnline = elementData.stateData.isOnline;
	local displayColor = isOnline and NORMAL_FONT_COLOR or FRIENDS_GRAY_COLOR;
	local wrap = false;
	if elementData.stateData.pinExpirationDate then
		local atlasMarkup = CreateAtlasMarkup(isOnline and "friends-icon-pinned" or "friends-icon-pinned-dis", 18, 18);
		GameTooltip_AddColoredDoubleLine(tooltip, elementData.characterData.fullName, atlasMarkup, displayColor, HIGHLIGHT_FONT_COLOR, wrap);
	else
		GameTooltip_AddColoredLine(tooltip, elementData.characterData.fullName, displayColor, wrap);
	end
end

local function AddCharacterLevelAndClassToTooltip(tooltip, elementData)
	local characterData = elementData.characterData;
	local classInfo = C_CreatureInfo.GetClassInfo(characterData.classID);
	local displayColor = elementData.stateData.isOnline and HIGHLIGHT_FONT_COLOR or FRIENDS_GRAY_COLOR;
	GameTooltip_AddColoredLine(tooltip, SOCIAL_UI_RECENT_ALLIES_TOOLTIP_LEVEL_CLASS_FORMAT:format(characterData.level, classInfo and classInfo.className or ""), displayColor);
end

local function AddCharacterRaceToTooltip(tooltip, elementData)
	local raceInfo = C_CreatureInfo.GetRaceInfo(elementData.characterData.raceID);
	local displayColor = elementData.stateData.isOnline and HIGHLIGHT_FONT_COLOR or FRIENDS_GRAY_COLOR;
	GameTooltip_AddColoredLine(tooltip, raceInfo and raceInfo.raceName or "", displayColor);
end

local function AddCharacterFactionToTooltip(tooltip, elementData)
	local factionInfo = C_CreatureInfo.GetFactionInfo(elementData.characterData.raceID);
	local displayColor = elementData.stateData.isOnline and HIGHLIGHT_FONT_COLOR or FRIENDS_GRAY_COLOR;
	GameTooltip_AddColoredLine(tooltip, factionInfo and factionInfo.name or "", displayColor);
end

function RecentAlliesSocialCardMixin:AddCharacterDataToTooltip(tooltip)
	AddCharacterNameHeaderToTooltip(tooltip, self.elementData);
	SocialUIUtil.AddSeparatorToTooltip(tooltip);
	AddCharacterLevelAndClassToTooltip(tooltip, self.elementData);
	AddCharacterRaceToTooltip(tooltip, self.elementData);
	AddCharacterFactionToTooltip(tooltip, self.elementData);
end

local function TryAddCurrentLocationToTooltip(tooltip, stateData)
	if not stateData.currentLocation then
		return;
	end

	local displayColor = stateData.isOnline and HIGHLIGHT_FONT_COLOR or FRIENDS_GRAY_COLOR;
	GameTooltip_AddColoredLine(tooltip, stateData.currentLocation, displayColor);
end

function RecentAlliesSocialCardMixin:AddStateDataToTooltip(tooltip)
	TryAddCurrentLocationToTooltip(tooltip, self.elementData.stateData);
end

local function TryAddNoteToTooltip(tooltip, elementData)
	local note = elementData.interactionData.note;
	if not note or note == "" then
		return;
	end

	local isOnline = elementData.stateData.isOnline;
	local displayColor = isOnline and NORMAL_FONT_COLOR or FRIENDS_GRAY_COLOR;
	local noteFormat = isOnline and SOCIAL_UI_RECENT_ALLIES_NOTE_FORMAT or SOCIAL_UI_RECENT_ALLIES_NOTE_OFFLINE_FORMAT;
	GameTooltip_AddColoredLine(tooltip, noteFormat:format(note), displayColor);
end

function RecentAlliesSocialCardMixin:AddInteractionDataToTooltip(tooltip)
	TryAddNoteToTooltip(tooltip, self.elementData);

	if self:HasInteractions() then
		SocialUIUtil.AddSeparatorToTooltip(tooltip);
		self:AddInteractionsToTooltip(tooltip);
	end
end

function RecentAlliesSocialCardMixin:HasInteractions()
	return #self.elementData.interactionData.interactions > 0;
end

function RecentAlliesSocialCardMixin:AddInteractionsToTooltip(tooltip)
	local mostRecentInteraction = self:GetMostRecentInteraction();
	if not mostRecentInteraction then
		return;
	end

	local isOnline = self.elementData.stateData.isOnline;
	local leftTooltipColor = isOnline and NORMAL_FONT_COLOR or FRIENDS_GRAY_COLOR;
	local leftTooltipText = RECENT_ALLY_RECENT_ACTIVITIES_LABEL;

	local rightTooltipColor = isOnline and DISABLED_FONT_COLOR or FRIENDS_GRAY_COLOR;
	local timeSinceInteraction = GetServerTime() - mostRecentInteraction.timestamp;
	local rightTooltipText = RECENT_ALLY_INTERACTION_TIME_FORMAT:format(RecentAlliesUtil.GetFormattedTime(timeSinceInteraction));

	tooltip:AddDoubleLine(leftTooltipText, rightTooltipText, leftTooltipColor.r, leftTooltipColor.g, leftTooltipColor.b, rightTooltipColor.r, rightTooltipColor.g, rightTooltipColor.b);

	local interactionDisplayColor = isOnline and HIGHLIGHT_FONT_COLOR or FRIENDS_GRAY_COLOR;
	GameTooltip_AddColoredLine(tooltip, self:ConvertInteractionToTooltipString(mostRecentInteraction), interactionDisplayColor);
end

function RecentAlliesSocialCardMixin:GetMostRecentInteraction()
	if self:HasInteractions() then
		-- Assuming the list of interactions is presorted from most recent to least recent
		return self.elementData.interactionData.interactions[1];
	end
end

function RecentAlliesSocialCardMixin:ConvertInteractionToTooltipString(interactionData)
	local contextData = interactionData.contextData;
	-- If we need item data, ensure it is loaded here before moving on
	if contextData.itemID then
		local item = Item:CreateFromItemID(contextData.itemID);
		if item and not item:IsItemDataCached() then
			item:ContinueOnItemLoad(function()
				self:ShowTooltip();
			end);
			return "";
		end
	end

	return RecentAlliesUtil.GenerateContextStringForInteraction(interactionData);
end

function RecentAlliesSocialCardMixin:OnLeave()
	self:HideTooltip();
end

function RecentAlliesSocialCardMixin:HideTooltip()
	GetAppropriateTooltip():Hide();
end

RecentAlliesCardStateDisplayMixin = {};

function RecentAlliesCardStateDisplayMixin:Initialize(stateData)
	self.PinDisplay:Initialize(stateData);
	self.FriendRequestSentDisplay:Initialize(stateData);
	self:LayoutContent();
end

function RecentAlliesCardStateDisplayMixin:LayoutContent()
	local pinShown = self.PinDisplay:IsShown();
	local friendRequestShown = self.FriendRequestSentDisplay:IsShown();
	self:SetShown(pinShown or friendRequestShown);

	if not pinShown and not friendRequestShown then
		self:SetDesiredWidth(0);
		return;
	end

	self.PinDisplay:ClearAllPoints();
	self.FriendRequestSentDisplay:ClearAllPoints();

	local finalDesiredWidth = 0;
	if pinShown then
		self.PinDisplay:SetPoint("LEFT");
		finalDesiredWidth = finalDesiredWidth + self.PinDisplay.baseWidth;
	end

	if friendRequestShown then
		if pinShown then
			local iconSpacing = 3;
			self.FriendRequestSentDisplay:SetPoint("LEFT", self.PinDisplay, "RIGHT", iconSpacing, 0);
			finalDesiredWidth = finalDesiredWidth + iconSpacing;
		else
			self.FriendRequestSentDisplay:SetPoint("LEFT");
		end

		finalDesiredWidth = finalDesiredWidth + self.FriendRequestSentDisplay.baseWidth;
	end

	self:SetDesiredWidth(finalDesiredWidth);
end

RecentAlliesSocialCardPartyButtonMixin = {};

function RecentAlliesSocialCardPartyButtonMixin:RefreshIcon()
	local icon = self:IsEnabled() and "friends-icon-friendsAvailable" or "friends-icon-friendsAvailable-dis";
	self.ActionIcon:SetAtlas(icon, TextureKitConstants.UseAtlasSize);
end

function RecentAlliesSocialCardPartyButtonMixin:ShowTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(tooltip, RECENT_ALLIES_PARTY_BUTTON_TOOLTIP);

	if not self:IsEnabled() then
		GameTooltip_AddErrorLine(tooltip, self:GetBestDisabledTooltip());
	end

	tooltip:Show();
end

function RecentAlliesSocialCardPartyButtonMixin:GetBestDisabledTooltip()
	return RECENT_ALLIES_PARTY_BUTTON_OFFLINE_TOOLTIP;
end

RecentAlliesSocialCardPinDisplayMixin = {};

function RecentAlliesSocialCardPinDisplayMixin:Initialize(stateData)
	self.pinExpirationDate = stateData.pinExpirationDate;
	self.isOnline = stateData.isOnline;
	self:RefreshIconAndVisibility();
end

function RecentAlliesSocialCardPinDisplayMixin:RefreshIconAndVisibility()
	local icon = self.isOnline and (IsPinNearingExpiration(self.pinExpirationDate) and "friendslist-recentallies-pin" or "friends-icon-pinned") or "friends-icon-pinned-dis";
	self.Icon:SetAtlas(icon, TextureKitConstants.IgnoreAtlasSize);

	local isPinned = self.pinExpirationDate ~= nil;
	self:SetShown(isPinned);
end

function RecentAlliesSocialCardPinDisplayMixin:OnEnter()
	self:ShowTooltip();
end

function RecentAlliesSocialCardPinDisplayMixin:ShowTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");

	local wrapText = false;
	if IsPinNearingExpiration(self.pinExpirationDate) then
		local timeUntilExpiration = math.max(self.pinExpirationDate - GetServerTime(), 1);
		GameTooltip_AddHighlightLine(tooltip, RECENT_ALLY_PIN_EXPIRING_TOOLTIP:format(RecentAlliesUtil.GetFormattedTime(timeUntilExpiration)), wrapText);
	else
		GameTooltip_AddHighlightLine(tooltip, RECENT_ALLY_PIN_TOOLTIP, wrapText);
	end

	tooltip:Show();
end

function RecentAlliesSocialCardPinDisplayMixin:OnLeave()
	self:HideTooltip();
end

function RecentAlliesSocialCardPinDisplayMixin:HideTooltip()
	GetAppropriateTooltip():Hide();
end

RecentAlliesSocialCardFriendRequestSentDisplayMixin = {};

function RecentAlliesSocialCardFriendRequestSentDisplayMixin:Initialize(stateData)
	self:SetShown(stateData.friendRequestSentThisSession);
end

function RecentAlliesSocialCardFriendRequestSentDisplayMixin:OnEnter()
	self:ShowTooltip();
end

function RecentAlliesSocialCardFriendRequestSentDisplayMixin:ShowTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(tooltip, SOCIAL_UI_RECENT_ALLIES_FRIEND_REQUEST_SENT_TOOLTIP);
	tooltip:Show();
end

function RecentAlliesSocialCardFriendRequestSentDisplayMixin:OnLeave()
	self:HideTooltip();
end

function RecentAlliesSocialCardFriendRequestSentDisplayMixin:HideTooltip()
	GetAppropriateTooltip():Hide();
end
