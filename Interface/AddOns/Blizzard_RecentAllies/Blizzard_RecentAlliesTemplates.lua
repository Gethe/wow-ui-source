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

local function AddCharacterFactionToTooltip(tooltip, characterData)
	local factionInfo = C_CreatureInfo.GetFactionInfo(characterData.raceID);
	GameTooltip_AddHighlightLine(tooltip, factionInfo and factionInfo.name or "");
end

function RecentAlliesEntryMixin:AddCharacterDataToTooltip(tooltip)
	local characterData = self.elementData.characterData;
	AddCharacterNameToTooltip(tooltip, characterData);
	AddCharacterLevelAndRaceToTooltip(tooltip, characterData);
	AddCharacterClassToTooltip(tooltip, characterData);
	AddCharacterFactionToTooltip(tooltip, characterData);
end

local function TryAddCurrentLocationToTooltip(tooltip, stateData)
	if stateData.currentLocation then
		GameTooltip_AddHighlightLine(tooltip, stateData.currentLocation);
	end
end

function RecentAlliesEntryMixin:AddStateDataToTooltip(tooltip)
	TryAddCurrentLocationToTooltip(tooltip, self.elementData.stateData);
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

local function TryAddNoteToTooltip(tooltip, interactionData)
	local note = interactionData.note;
	if note and note ~= "" then
		GameTooltip_AddNormalLine(tooltip, RECENT_ALLY_NOTE_FORMAT:format(note));
	end
end

function RecentAlliesEntryMixin:AddInteractionDataToTooltip(tooltip)
	TryAddNoteToTooltip(tooltip, self.elementData.interactionData);
	
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
	self.StateIconContainer.FriendRequestPendingDisplay:SetShown(stateData.hasFriendRequestPending);
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
