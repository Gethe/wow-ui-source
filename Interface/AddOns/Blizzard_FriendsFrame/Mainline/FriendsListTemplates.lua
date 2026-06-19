FriendsListSocialViewMixin = CreateFromMixins(SocialUISystemMixin, SocialUIScrollableElementExtentPreviewerMixin);

local FriendsListSocialViewDynamicEvents =
{
	"BATTLE_NET_FRIEND_TAG_ENABLED_STATUS_UPDATED",
	"BN_FRIEND_LIST_SIZE_CHANGED",
	"BN_FRIEND_INFO_CHANGED",
};

function FriendsListSocialViewMixin:OnLoad()
	-- Keep track of this even when hidden so we can tell the Social UI to refresh our tab if it is visible
	self:RegisterEvent("SOCIAL_UI_FRIENDS_LIST_SYSTEM_STATUS_UPDATED");

	SocialUIScrollableElementExtentPreviewerMixin.OnLoad(self);

	self:InitializeActionButton();
	self:InitializeScrollBox();
end

function FriendsListSocialViewMixin:InitializeActionButton()
	self.ActionButton:SetText(SOCIAL_UI_FRIENDS_LIST_ADD_FRIEND_BUTTON_LABEL);
end

function FriendsListSocialViewMixin:InitializeScrollBox()
	self:RegisterScrollableTemplatesForExtentPreview({
		"SocialUIScrollableHeaderTemplate",
		{ template = "FriendsListSocialCardTemplate", baseHeightCalculator = FriendsListSocialCardMixin.GetActiveBaseHeight },
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
				self:TrySwitchFriendsFriendsTarget(node);
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
			return "FriendsListSocialCardTemplate";
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

local function HasAcknowledgedCrossFactionInviteTutorial()
	return GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE);
end

local function IsCrossFactionFriend(accountInfo)
	if not accountInfo or not FriendsListUtil.GameStateUsesFactions() then
		return false;
	end

	local friendFaction = accountInfo.gameAccountInfo.factionName;
	if not friendFaction then
		return false;
	end

	local ourFaction = UnitFactionGroup("player");
	local isCrossFactionFriend = friendFaction ~= ourFaction;
	return isCrossFactionFriend;
end

function FriendsListSocialViewMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, FriendsListSocialViewDynamicEvents);

	EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", self.OnFriendsListTextScaleUpdated, self);
	self:ClearTemplateExtentCache();

	self:TryRegisterScrollBoxForCrossFactionInviteTutorial();

	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
end

function FriendsListSocialViewMixin:TryRegisterScrollBoxForCrossFactionInviteTutorial()
	if HasAcknowledgedCrossFactionInviteTutorial() or not FriendsListUtil.GameStateUsesFactions() then
		return;
	end

	self.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, self.RefreshCrossFactionInviteTutorial, self);
end

function FriendsListSocialViewMixin:RefreshCrossFactionInviteTutorial()
	HelpTip:Hide(self, CROSS_FACTION_INVITE_HELPTIP);

	if HasAcknowledgedCrossFactionInviteTutorial() then
		self:UnregisterScrollBoxForCrossFactionInviteTutorial();
		return;
	end

	local firstFoundCrossFactionFriend = self.ScrollBox:FindFrameByPredicate(function(_button, node)
		local data = node:GetData();
		local isHeader = data.headerText ~= nil;
		if isHeader then
			return false;
		end

		return IsCrossFactionFriend(data.accountInfo);
	end);
	if not firstFoundCrossFactionFriend then
		return;
	end

	local helpTipInfo =
	{
		text = CROSS_FACTION_INVITE_HELPTIP,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		alignment = HelpTip.Alignment.Center,
		acknowledgeOnHide = false,
		system = "friendsList",
	};

	HelpTip:Show(self, helpTipInfo, firstFoundCrossFactionFriend.PartyButton);
end

function FriendsListSocialViewMixin:UnregisterScrollBoxForCrossFactionInviteTutorial()
	self.ScrollBox:UnregisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, self);
end

function FriendsListSocialViewMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, FriendsListSocialViewDynamicEvents);

	EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self);

	self:UnregisterScrollBoxForCrossFactionInviteTutorial();

	self:HideFriendsFriendsFrame();
end

function FriendsListSocialViewMixin:OnEvent(event, ...)
	if event == "SOCIAL_UI_FRIENDS_LIST_SYSTEM_STATUS_UPDATED" then
		self:TriggerSocialUIEvent(SocialUIFrameMixin.Event.FeatureAvailabilityChanged);
	elseif event == "BN_FRIEND_LIST_SIZE_CHANGED" then
		self:Refresh(ScrollBoxConstants.RetainScrollPosition);

		local bnetIDAccount = ...;
		if bnetIDAccount then
			self:NotifyFriendsFriendsOfFriendListChange(bnetIDAccount);
		end
	elseif event == "BN_FRIEND_INFO_CHANGED" or event == "BATTLE_NET_FRIEND_TAG_ENABLED_STATUS_UPDATED" then
		self:Refresh(ScrollBoxConstants.RetainScrollPosition);
	end
end

function FriendsListSocialViewMixin:OnFriendsListTextScaleUpdated()
	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function FriendsListSocialViewMixin:HideFriendsFriendsFrame()
	FriendsFriendsFrame:Close();
end

function FriendsListSocialViewMixin:NotifyFriendsFriendsOfFriendListChange(bnetIDAccount)
	FriendsFriendsFrame.requested[bnetIDAccount] = nil;
	if FriendsFriendsFrame:IsShown() then
		FriendsFriendsFrame:Update();
	end
end

function FriendsListSocialViewMixin:TrySwitchFriendsFriendsTarget(node)
	if not FriendsFriendsFrame:IsShown() then
		return;
	end

	local data = node:GetData();
	local accountInfo = data.accountInfo;
	if accountInfo and accountInfo.bnetAccountID ~= FriendsFriendsFrame.bnetIDAccount then
		FriendsFriendsFrame:Open(accountInfo.bnetAccountID);
	end
end

function FriendsListSocialViewMixin:Refresh(retainScrollPosition)
	self:ClearTemplateExtentCache();
	self.ScrollBox:SetDataProvider(self:GenerateDataProvider(), retainScrollPosition);
end

local function TryInsertFriendsSubTree(dataProvider, headerString, numEntriesOnline, numEntriesTotal)
	if numEntriesTotal <= 0 then
		return nil;
	end

	local newSubTree = dataProvider:Insert({ headerText = headerString:format(numEntriesOnline, numEntriesTotal) });
	newSubTree:Insert({ isSpacer = true });
	return newSubTree;
end

local function InsertFriendsIntoDataProvider(dataProvider)
	local numFriends, numFriendsOnline, numFavorites, numFavoritesOnline = BNGetNumFriends();
	if numFriends == 0 then
		return;
	end

	local favoritesSubTree = TryInsertFriendsSubTree(dataProvider, SOCIAL_UI_FAVORITE_FRIENDS_LIST_HEADER, numFavoritesOnline, numFavorites);

	local numNonFavoritesOnline = numFriendsOnline - numFavoritesOnline;
	local numNonFavorites = numFriends - numFavorites;

	local listWillShowBothTrees = favoritesSubTree and (numNonFavorites > 0);
	if listWillShowBothTrees then
		dataProvider:Insert({ isSpacer = true });
	end

	local nonFavoriteSubTree = TryInsertFriendsSubTree(dataProvider, SOCIAL_UI_FRIENDS_LIST_HEADER, numNonFavoritesOnline, numNonFavorites);

	for index = 1, numFriends do
		local accountInfo = C_BattleNet.GetFriendAccountInfo(index);
		if accountInfo then
			local bestSubTree = accountInfo.isFavorite and favoritesSubTree or nonFavoriteSubTree;
			if bestSubTree then
				bestSubTree:Insert({ friendIndex = index, accountInfo = accountInfo });
			end
		end
	end
end

function FriendsListSocialViewMixin:GenerateDataProvider()
	local dataProvider = CreateTreeDataProvider();
	InsertFriendsIntoDataProvider(dataProvider);
	return dataProvider;
end

FriendsListSocialCardMixin = {};

function FriendsListSocialCardMixin:OnLoad()
	self:TrySetUpSummonButton();
end

function FriendsListSocialCardMixin:TrySetUpSummonButton()
	local summonButtonAlreadyExists = self.RAFSummonButton ~= nil;
	if summonButtonAlreadyExists or not C_RecruitAFriend.IsSystemSupported() then
		return;
	end

	self.RAFSummonButton = CreateFrame("Button", nil, self, "FriendsListSocialCardRAFSummonButtonTemplate");
	self.RAFSummonButton:SetPoint("RIGHT", self.PartyButton, "LEFT");
end

function FriendsListSocialCardMixin:Initialize(node)
	self.elementData = node:GetData();

	self:InitializeDisplay();

	local selected = SelectionBehaviorMixin.IsElementDataIntrusiveSelected(node);
	self:SetSelected(selected);
end

function FriendsListSocialCardMixin:SetSelected(selected)
	self:SetHighlightLocked(selected);
end

function FriendsListSocialCardMixin:InitializeDisplay()
	self:InitializeBackground();
	self:InitializePresenceDisplay();
	self:InitializePartyButton();
	self:InitializeRAFSummonButton();
	self:InitializeGameIcon();
	self:InitializeCardDisplayText();
end

function FriendsListSocialCardMixin:IsWowAccountFriend()
	return false;
end

function FriendsListSocialCardMixin:IsOnline()
	return self.elementData.accountInfo.gameAccountInfo.isOnline;
end

function FriendsListSocialCardMixin:HasCharacterDataToDisplay()
	return self.elementData.accountInfo.gameAccountInfo.characterName ~= nil;
end

function FriendsListSocialCardMixin:HasNote()
	local note = self.elementData.accountInfo.note;
	return note and note ~= "";
end

function FriendsListSocialCardMixin:HasTags()
	return #self.elementData.accountInfo.friendTags > 0;
end

function FriendsListSocialCardMixin:InitializeBackground()
	local backgroundAtlas = self:GetBestBackgroundAtlas();
	self.Background:SetAtlas(backgroundAtlas, TextureKitConstants.IgnoreAtlasSize);
end

function FriendsListSocialCardMixin:GetBestBackgroundAtlas()
	if not self:IsOnline() then
		return "friends-card-disabled";
	end

	return self:IsWowAccountFriend() and "friends-card-default" or "friends-card-battleNet";
end

function FriendsListSocialCardMixin:InitializePresenceDisplay()
	local presenceType = SocialUIUtil.GetPresenceTypeForBattleNetAccountInfo(self.elementData.accountInfo);
	self.PresenceHolder:SetPresence(presenceType);
end

function FriendsListSocialCardMixin:InitializePartyButton()
	self.PartyButton:Initialize(self.elementData);
end

function FriendsListSocialCardMixin:InitializeRAFSummonButton()
	if not self.RAFSummonButton then
		return;
	end

	self.RAFSummonButton:Initialize(self.elementData);
end

function FriendsListSocialCardMixin:InitializeGameIcon()
	local gameIconHolder = self.GameIconHolder;

	if not self:ShouldShowGameIcon() then
		gameIconHolder:Hide();
		return;
	end

	local gameAccountInfo = self.elementData.accountInfo.gameAccountInfo;
	C_Texture.SetTitleIconTexture(gameIconHolder.Icon, gameAccountInfo.clientProgram, Enum.TitleIconVersion.Medium);

	local friendIsPlayingDifferentWowProject = FriendsListUtil.IsPlayingDifferentWoWProject(gameAccountInfo);
	gameIconHolder.Icon:SetAlpha(friendIsPlayingDifferentWowProject and 0.6 or 1);

	gameIconHolder:Show();
end

function FriendsListSocialCardMixin:ShouldShowGameIcon()
	-- The game icon and RAFSummonButton occupy the same space on the card
	-- We let the RAFSummonButton take priority if it needs to be shown
	if self:IsRAFSummonButtonShown() then
		return false;
	end

	local hasValidClientProgram = self:IsOnline() and self.elementData.accountInfo.gameAccountInfo.clientProgram ~= "";
	return hasValidClientProgram;
end

function FriendsListSocialCardMixin:IsRAFSummonButtonShown()
	return self.RAFSummonButton and self.RAFSummonButton:IsShown();
end

function FriendsListSocialCardMixin:InitializeCardDisplayText()
	self:RefreshFriendNameDisplayText();
	self:RefreshFriendCharacterDataDisplayText();
	self:RefreshLocationDisplayText();

	-- The state display holds icons that are anchored to the side of the friend name display text
	-- We need to initialize it here before we layout/anchor the strings
	self:InitializeStateDisplay();

	self:LayoutScaledContent();
end

function FriendsListSocialCardMixin:RefreshFriendNameDisplayText()
	local displayText = FriendsListUtil.BuildFriendNameDisplayText(self.elementData.accountInfo);
	self.FriendName:SetText(displayText);
end

function FriendsListSocialCardMixin:RefreshFriendCharacterDataDisplayText()
	local accountInfo = self.elementData.accountInfo;

	local nameText = FriendsListUtil.BuildCharacterNameDisplayText(accountInfo);
	self.Name:SetText(nameText);

	local levelText = FriendsListUtil.BuildCharacterLevelDisplayText(accountInfo);
	self.Level:SetText(levelText);

	local classText = FriendsListUtil.BuildCharacterClassDisplayText(accountInfo);
	self.Class:SetText(classText);
end

function FriendsListSocialCardMixin:RefreshLocationDisplayText()
	local displayText = FriendsListUtil.BuildLocationDisplayText(self.elementData.accountInfo);
	self.Location:SetText(displayText);
end

function FriendsListSocialCardMixin:InitializeStateDisplay()
	self.StateDisplay:Initialize(self.elementData.accountInfo);
end

-- We attempt to keep the anchoring of elements visually consistent as they get bigger due to font scaling
-- Ex. Icons and buttons get larger as the font scales up, so we need to adjust their anchoring offsets to keep them in the same relative position
function FriendsListSocialCardMixin:LayoutScaledContent()
	self:LayoutScaledPresenceHolderAnchors();
	self:LayoutScaledTextHolderAnchors();

	if self:ShouldUseExpandedLayout() then
		self:LayoutCardDisplayTextExpanded();
	else
		self:LayoutCardDisplayTextCompact();
	end
end

function FriendsListSocialCardMixin:LayoutScaledPresenceHolderAnchors()
	local presenceHolder = self.PresenceHolder;

	local scaleWeightSource = presenceHolder;
	local scaledPresenceHolderXOffset = TextSizeManager:GetScaledValueWeighted(self.presenceHolderXOffset, scaleWeightSource);
	local scaledPresenceHolderYOffset = TextSizeManager:GetScaledValueWeighted(self.presenceHolderYOffset, scaleWeightSource);

	presenceHolder:ClearAllPoints();
	presenceHolder:SetPoint("CENTER", self, "TOPLEFT", scaledPresenceHolderXOffset, scaledPresenceHolderYOffset);
end

function FriendsListSocialCardMixin:LayoutScaledTextHolderAnchors()
	local textHolder = self.TextHolder;
	local presenceHolder = self.PresenceHolder;

	local scaleWeightSource = presenceHolder;
	local scaledTextHolderTopLeftXOffset = TextSizeManager:GetScaledValueWeighted(self.textHolderTopLeftXOffset, scaleWeightSource);
	local scaledTextHolderTopLeftYOffset = TextSizeManager:GetScaledValueWeighted(self.textHolderTopLeftYOffset, scaleWeightSource);

	textHolder:ClearAllPoints();
	textHolder:SetPoint("TOPLEFT", presenceHolder, "BOTTOMRIGHT", scaledTextHolderTopLeftXOffset, scaledTextHolderTopLeftYOffset);
	textHolder:SetPoint("RIGHT", self:GetBestRightAnchorForTextHolder(), "LEFT", self.textHolderRightXOffset, 0);
	textHolder:SetPoint("BOTTOM", self, "BOTTOM", 0, self.textHolderBottomYOffset);
end

-- Various buttons and icons exist on the right side of the card
-- The text needs to be anchored to the left of the innermost element so the text can be properly truncated
function FriendsListSocialCardMixin:GetBestRightAnchorForTextHolder()
	local rafSummonButton = self.RAFSummonButton;
	if rafSummonButton and rafSummonButton:IsShown() then
		return rafSummonButton;
	end

	local gameIconHolder = self.GameIconHolder;
	return gameIconHolder:IsShown() and gameIconHolder or self.PartyButton;
end

function FriendsListSocialCardMixin:LayoutFriendNameTextLine()
	-- We know the FriendName and the state display need to fit on the same line
	-- We prioritize showing the entire state display, and the remaining space can go to the friend name
	local totalAvailableRowWidth = self.TextHolder:GetWidth();

	local stateDisplay = self.StateDisplay;
	local stateDisplayWidth = stateDisplay:GetWidth();
	local scaleWeightSource = stateDisplay;
	local scaledStateDisplayXOffset = (stateDisplayWidth > 0) and TextSizeManager:GetScaledValueWeighted(self.stateDisplayXOffset, scaleWeightSource) or 0;
	local maxNameWidth = totalAvailableRowWidth - stateDisplayWidth - scaledStateDisplayXOffset;

	-- FriendName is a kstring so using GetStringWidth and GetUnboundedStringWidth won't work
	-- We reset the width so it resize to hold the text and then we clamp it to the max available width for this line
	self.FriendName:SetWidth(0);
	local nameWidth = math.min(self.FriendName:GetWidth(), maxNameWidth);
	self.FriendName:SetWidth(nameWidth);

	stateDisplay:ClearAllPoints();
	stateDisplay:SetPoint("LEFT", self.FriendName, "RIGHT", scaledStateDisplayXOffset, 0);
end

function FriendsListSocialCardMixin:LayoutSecondaryTextLines(textToAnchorTo)
	local lineSpacing = TextSizeManager:GetScaledValue(self.lineSpacing);

	self.Location:ClearAllPoints();
	self.Location:SetPoint("TOPLEFT", textToAnchorTo, "BOTTOMLEFT", 0, -lineSpacing);
	self.Location:SetPoint("RIGHT", self.TextHolder);
end

-- Compact layout: Character Name, Level, and Class all on one row
function FriendsListSocialCardMixin:LayoutCardDisplayTextCompact()
	self:LayoutFriendNameTextLine();

	local hasCharacterDataToDisplay = self:HasCharacterDataToDisplay();
	self.Name:SetShown(hasCharacterDataToDisplay);
	self.Level:SetShown(hasCharacterDataToDisplay);
	self.Class:SetShown(hasCharacterDataToDisplay);
	if not hasCharacterDataToDisplay then
		self:LayoutSecondaryTextLines(self.FriendName);
		return;
	end

	-- We start with the entire width of the text holder available to us
	local totalAvailableRowWidth = self.TextHolder:GetWidth();
	local remainingUsableRowWidth = totalAvailableRowWidth;

	-- We know we have 3 strings (name, level, class) which means we need to reserve the space for the two spaces between them
	remainingUsableRowWidth = remainingUsableRowWidth - (self.interStringTextSpacing * 2);

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

	-- With all the calculations done we can now anchor the text elements on this row (Name is anchored below FriendName)
	self.Name:ClearAllPoints();
	local lineSpacing = TextSizeManager:GetScaledValue(self.lineSpacing);
	self.Name:SetPoint("TOPLEFT", self.FriendName, "BOTTOMLEFT", self.secondaryTextIndent, -lineSpacing);

	self.Level:ClearAllPoints();
	self.Level:SetPoint("LEFT", self.Name, "RIGHT", self.interStringTextSpacing, 0);
	self.Level:SetPoint("TOP", self.Name);

	-- Class fills whatever space remains between Level and the TextHolder's right edge
	self.Class:ClearAllPoints();
	self.Class:SetPoint("LEFT", self.Level, "RIGHT", self.interStringTextSpacing, 0);
	self.Class:SetPoint("TOP", self.Level);
	self.Class:SetPoint("RIGHT", self.TextHolder);

	-- And then anchor the secondary text line (Location) below the character data row
	local textToAnchorTo = self.Name;
	self:LayoutSecondaryTextLines(textToAnchorTo);
end

-- Expanded layout: Character Name on its own row, Level and Class on the row below
function FriendsListSocialCardMixin:LayoutCardDisplayTextExpanded()
	self:LayoutFriendNameTextLine();

	local hasCharacterDataToDisplay = self:HasCharacterDataToDisplay();
	self.Name:SetShown(hasCharacterDataToDisplay);
	self.Level:SetShown(hasCharacterDataToDisplay);
	self.Class:SetShown(hasCharacterDataToDisplay);
	if not hasCharacterDataToDisplay then
		self:LayoutSecondaryTextLines(self.FriendName);
		return;
	end

	local availableWidth = self.TextHolder:GetWidth();
	local lineSpacing = TextSizeManager:GetScaledValue(self.lineSpacing);

	-- Row 2: Character Name gets the full width of the text holder
	self.Name:ClearAllPoints();
	self.Name:SetPoint("TOPLEFT", self.FriendName, "BOTTOMLEFT", self.secondaryTextIndent, -lineSpacing);
	self.Name:SetPoint("RIGHT", self.TextHolder);

	-- Row 3: Level and Class share the row
	-- We start with the entire width of the text holder available to us
	local remainingRowUsableWidth = availableWidth;

	-- We know we're displaying the level and class name, so we need to reserve space for the one space between the two strings
	remainingRowUsableWidth = remainingRowUsableWidth - self.interStringTextSpacing;

	-- We need to show at least part of the class name, so we reserve some space for that before giving level its width
	local minClassWidth = 30;
	local levelWidth = math.min(self.Level:GetUnboundedStringWidth(), remainingRowUsableWidth - minClassWidth);
	self.Level:SetWidth(levelWidth);

	-- With all the calculations done we can now anchor the Level/Class row below the Name row
	self.Level:ClearAllPoints();
	self.Level:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, -lineSpacing);

	-- Class fills whatever space remains between Level and the TextHolder's right edge
	self.Class:ClearAllPoints();
	self.Class:SetPoint("LEFT", self.Level, "RIGHT", self.interStringTextSpacing, 0);
	self.Class:SetPoint("TOP", self.Level);
	self.Class:SetPoint("RIGHT", self.TextHolder);

	-- And then anchor the secondary text lines (Location) below the Level/Class row
	local textToAnchorTo = self.Level;
	self:LayoutSecondaryTextLines(textToAnchorTo);
end

-- Normally we display cards in a compact layout with 3 rows of text (Row 1: FriendName + StateDisplay, Row 2: Name/Level/Class, Row 3: Location)
-- With larger text sizes we switch to an expanded 4 row layout so the character data has more room (Row 1: FriendName + StateDisplay, Row 2: Name, Row 3: Level/Class, Row 4: Location)
function FriendsListSocialCardMixin.ShouldUseExpandedLayout()
	local hasLargerTextSizeThanDefault = TextSizeManager:GetSettingValue() > TextSizeManager:GetSettingDefaultValue();
	return hasLargerTextSizeThanDefault;
end

function FriendsListSocialCardMixin.GetActiveBaseHeight()
	return FriendsListSocialCardMixin.ShouldUseExpandedLayout() and 85 or 70;
end

function FriendsListSocialCardMixin:OpenMenu()
	local accountInfo = self.elementData.accountInfo;

	local contextData =
	{
		battleTag = accountInfo.battleTag,
		bnetIDAccount = accountInfo.bnetAccountID,
		friendsList = true,
		name = accountInfo.accountName,
		titleColor = FRIENDS_BNET_NAME_COLOR,
		menuElementPreInitializer = SocialUIUtil.InitializeUserScaledDropdownButton,
		menuTitlePreInitializer = SocialUIUtil.InitializeUserScaledDropdownTitle,
	};

	if self:IsOnline() then
		local bestMenu = C_Glue.IsOnGlueScreen() and "GLUE_FRIEND" or "BN_FRIEND";
		UnitPopup_OpenMenu(bestMenu, contextData);
	else
		UnitPopup_OpenMenu("BN_FRIEND_OFFLINE", contextData);
	end
end

local function AddFriendNameHeaderToTooltip(tooltip, accountInfo)
	if not accountInfo then
		return;
	end

	local isOnline = accountInfo.gameAccountInfo.isOnline;
	local nameText = FriendsListUtil.GetFriendAccountNameText(accountInfo);
	local displayColor = isOnline and FRIENDS_BNET_NAME_COLOR or FRIENDS_GRAY_COLOR;
	local wrap = false;
	if accountInfo.isFavorite then
		local atlasMarkup = CreateAtlasMarkup(isOnline and "friends-icon-favorites" or "friends-icon-favorites-dis", 16, 16);
		GameTooltip_AddColoredDoubleLine(tooltip, nameText, atlasMarkup, displayColor, HIGHLIGHT_FONT_COLOR, wrap);
	else
		GameTooltip_AddColoredLine(tooltip, nameText, displayColor, wrap);
	end
end

local function AddRichPresenceToTooltip(tooltip, accountInfo)
	local characterName = FriendsListUtil.GetFormattedCharacterName(accountInfo);
	if characterName ~= "" then
		GameTooltip_AddNormalLine(tooltip, characterName);
	end

	local richPresence = accountInfo.gameAccountInfo.richPresence or "";
	if richPresence ~= "" then
		GameTooltip_AddHighlightLine(tooltip, richPresence);
	end
end

local function TryAddWowCharacterGroupDetailsToTooltip(tooltip, accountInfo)
	if not accountInfo or not C_SocialQueue.IsSystemSupported() then
		return;
	end

	local playerGuid = accountInfo.gameAccountInfo.playerGuid;
	local isInGroup = playerGuid and (C_SocialQueue.GetGroupForPlayer(playerGuid) ~= nil) or false;
	if isInGroup then
		local inGroupIcon = CreateAtlasMarkup("friends-icon-friendsInGroup", 16, 16);
		GameTooltip_AddNormalLine(tooltip, SOCIAL_UI_FRIENDS_LIST_FRIEND_IN_GROUP_TOOLTIP:format(inGroupIcon));
	end
end

local function AddWowCharacterDetailsToTooltip(tooltip, accountInfo)
	if not accountInfo then
		return;
	end

	local gameAccountInfo = accountInfo.gameAccountInfo;
	local characterName = FULL_PLAYER_NAME:format(gameAccountInfo.characterName or "", gameAccountInfo.realmName or "");
	if gameAccountInfo.timerunningSeasonID then
		characterName = TimerunningUtil.AddSmallIcon(characterName);
	end
	local finalNameText = characterName;
	if not gameAccountInfo.isInCurrentRegion then
		finalNameText = SOCIAL_UI_FRIENDS_LIST_CHARACTER_TOOLTIP_FORMAT:format(characterName, FriendsListUtil.GetRegionName(accountInfo));
	end
	GameTooltip_AddNormalLine(tooltip, finalNameText);

	local levelClassText = FRIENDS_LEVEL_TEMPLATE:format(gameAccountInfo.characterLevel or 0, gameAccountInfo.className or UNKNOWN);
	GameTooltip_AddHighlightLine(tooltip, levelClassText);

	GameTooltip_AddHighlightLine(tooltip, gameAccountInfo.raceName or UNKNOWN);

	GameTooltip_AddHighlightLine(tooltip, gameAccountInfo.areaName or UNKNOWN);

	GameTooltip_AddHighlightLine(tooltip, gameAccountInfo.factionName or UNKNOWN);

	TryAddWowCharacterGroupDetailsToTooltip(tooltip, accountInfo);
end

local function AddFriendDetailsToTooltip(tooltip, accountInfo)
	local addedFriendDetails = false;
	if not accountInfo or not accountInfo.gameAccountInfo.isOnline or not accountInfo.gameAccountInfo.gameAccountID then
		return addedFriendDetails;
	end

	SocialUIUtil.AddSeparatorToTooltip(tooltip);

	if FriendsListUtil.ShouldShowRichPresenceOnly(accountInfo) then
		AddRichPresenceToTooltip(tooltip, accountInfo);
	else
		AddWowCharacterDetailsToTooltip(tooltip, accountInfo);
	end

	addedFriendDetails = true;
	return addedFriendDetails;
end

local function TryAddNoteToTooltip(tooltip, accountInfo)
	local friendHasNote = (accountInfo and accountInfo.note ~= "") or false;
	if not friendHasNote then
		return;
	end

	local isOnline = accountInfo.gameAccountInfo.isOnline;
	local noteFormat = isOnline and SOCIAL_UI_FRIENDS_LIST_BATTLE_NET_FRIEND_NOTE_FORMAT or SOCIAL_UI_FRIENDS_LIST_BATTLE_NET_FRIEND_NOTE_OFFLINE_FORMAT;
	local displayColor = isOnline and NORMAL_FONT_COLOR or FRIENDS_GRAY_COLOR;
	GameTooltip_AddColoredLine(tooltip, noteFormat:format(accountInfo.note), displayColor);
end

local function TryAddFriendTagsToTooltip(tooltip, accountInfo)
	local friendHasTags = accountInfo and accountInfo.friendTags and #accountInfo.friendTags > 0;
	if not friendHasTags then
		return;
	end

	local tagLabels = {};
	for _index, tag in ipairs(accountInfo.friendTags) do
		local label = SocialUIUtil.GetLabelForBattleNetFriendTag(tag);
		if label ~= "" then
			table.insert(tagLabels, label);
		end
	end

	local hasValidTagsToDisplay = #tagLabels > 0;
	if not hasValidTagsToDisplay then
		return;
	end

	local tagsFormat = accountInfo.gameAccountInfo.isOnline and SOCIAL_UI_FRIENDS_LIST_BATTLE_NET_FRIEND_TAGS_FORMAT or SOCIAL_UI_FRIENDS_LIST_BATTLE_NET_FRIEND_TAGS_OFFLINE_FORMAT;
	local concatenatedTags = table.concat(tagLabels, LIST_DELIMITER);
	GameTooltip_AddHighlightLine(tooltip, tagsFormat:format(concatenatedTags));
end

local function TryAddBroadcastToTooltip(tooltip, accountInfo)
	local broadcastText = FriendsListUtil.BuildTooltipBroadcastText(accountInfo);
	if not broadcastText then
		return;
	end

	SocialUIUtil.AddSeparatorToTooltip(tooltip);
	GameTooltip_AddColoredLine(tooltip, broadcastText, BATTLENET_FONT_COLOR);
end

local function TryAddLastOnlineToTooltip(tooltip, accountInfo)
	if not accountInfo or accountInfo.gameAccountInfo.isOnline then
		return;
	end

	SocialUIUtil.AddSeparatorToTooltip(tooltip);
	local lastOnlineText = FriendsListUtil.GetLastOnlineText(accountInfo);
	GameTooltip_AddColoredLine(tooltip, lastOnlineText, FRIENDS_GRAY_COLOR);
end

local function IsSecondaryGameAccountFilteredFromTooltip(gameAccountInfo)
	local isPrimaryAccountForTooltip = gameAccountInfo.hasFocus;
	local isInApp = (gameAccountInfo.clientProgram == BNET_CLIENT_APP) or (gameAccountInfo.clientProgram == BNET_CLIENT_CLNT);
	return isPrimaryAccountForTooltip or isInApp;
end

local function GetGameAccountIconPrefix(gameAccountInfo)
	local iconPrefix = "";
	if C_Texture.IsTitleIconTextureReady(gameAccountInfo.clientProgram, Enum.TitleIconVersion.Small) then
		C_Texture.GetTitleIconTexture(gameAccountInfo.clientProgram, Enum.TitleIconVersion.Small, function(success, texture)
			if success then
				local fileWidth, fileHeight, width, height, xOffset, yOffset = 32, 32, 0, 0, 0, 0;
				iconPrefix = BNet_GetClientEmbeddedTexture(texture, fileWidth, fileHeight, width, height, xOffset, yOffset) .. " ";
			end
		end);
	end
	return iconPrefix;
end

local function BuildSameProjectGameAccountText(accountInfo, gameAccountInfo)
	if not accountInfo or not gameAccountInfo then
		return "", "";
	end

	local characterName = gameAccountInfo.characterName or "";
	local characterLevel = gameAccountInfo.characterLevel or 0;
	local raceName = gameAccountInfo.raceName or UNKNOWN;
	local className = gameAccountInfo.className or UNKNOWN;

	local nameText = GetGameAccountIconPrefix(gameAccountInfo) .. string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, characterName, characterLevel, raceName, className);
	local infoText = gameAccountInfo.areaName or UNKNOWN;
	return nameText, infoText;
end

local function BuildOtherGameAccountText(accountInfo, gameAccountInfo)
	if not accountInfo or not gameAccountInfo then
		return "", "";
	end

	local characterName = "";
	if gameAccountInfo.isOnline then
		characterName = BNet_GetValidatedCharacterName(gameAccountInfo.characterName, accountInfo.battleTag, gameAccountInfo.clientProgram) or "";
		if gameAccountInfo.timerunningSeasonID then
			characterName = TimerunningUtil.AddSmallIcon(characterName);
		end
	end

	local nameText = GetGameAccountIconPrefix(gameAccountInfo) .. characterName;
	local infoText = gameAccountInfo.richPresence or "";
	return nameText, infoText;
end

local function AddSecondaryGameAccountToTooltip(tooltip, accountInfo, gameAccountInfo)
	local isWowSameProject = FriendsListUtil.IsPlayingSameWoWProject(gameAccountInfo);
	local displayTextBuilder = isWowSameProject and BuildSameProjectGameAccountText or BuildOtherGameAccountText;
	local nameText, infoText = displayTextBuilder(accountInfo, gameAccountInfo);

	if nameText ~= "" then
		GameTooltip_AddNormalLine(tooltip, nameText);
	end

	if infoText ~= "" then
		GameTooltip_AddHighlightLine(tooltip, infoText);
	end
end

local MAX_ADDITIONAL_GAME_ACCOUNTS_TO_DISPLAY = 5;
local function TryAddGameAccountsToTooltip(tooltip, friendIndex, accountInfo)
	if not accountInfo or not accountInfo.gameAccountInfo.isOnline or not friendIndex then
		return;
	end

	local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(friendIndex);
	local hasMultipleGameAccounts = numGameAccounts > 1;
	if not hasMultipleGameAccounts then
		return;
	end

	-- We're already showing the main game account in the tooltip, so we subtract 1
	local maxSecondaryAccountsToDisplay = MAX_ADDITIONAL_GAME_ACCOUNTS_TO_DISPLAY - 1;

	local numDisplayed = 0;
	local hasAddedSeparator = false;
	for index = 1, numGameAccounts do
		local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(friendIndex, index);

		if not IsSecondaryGameAccountFilteredFromTooltip(gameAccountInfo) then
			numDisplayed = numDisplayed + 1;
			if numDisplayed > maxSecondaryAccountsToDisplay then
				break;
			end

			if not hasAddedSeparator then
				SocialUIUtil.AddSeparatorToTooltip(tooltip);
				hasAddedSeparator = true;
			end

			AddSecondaryGameAccountToTooltip(tooltip, accountInfo, gameAccountInfo);
		end
	end

	local numOverflowAccounts = numGameAccounts - MAX_ADDITIONAL_GAME_ACCOUNTS_TO_DISPLAY;
	if numOverflowAccounts > 0 then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		local overflowText = string.format(FRIENDS_TOOLTIP_TOO_MANY_CHARACTERS, numOverflowAccounts);
		GameTooltip_AddHighlightLine(tooltip, overflowText);
	end
end

function FriendsListSocialCardMixin:OnEnter()
	self:ShowTooltip();
end

function FriendsListSocialCardMixin:ShowTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:BuildTooltip(tooltip);
	tooltip:Show();
end

function FriendsListSocialCardMixin:BuildTooltip(tooltip)
	local accountInfo = self.elementData.accountInfo;
	if not accountInfo then
		return;
	end

	tooltip:SetMinimumWidth(250);

	AddFriendNameHeaderToTooltip(tooltip, accountInfo);

	local addedFriendDetails = AddFriendDetailsToTooltip(tooltip, accountInfo);

	local needsSeparatorForNoteOrTags = not addedFriendDetails and (self:HasNote() or self:HasTags());
	if needsSeparatorForNoteOrTags then
		SocialUIUtil.AddSeparatorToTooltip(tooltip);
	end

	TryAddNoteToTooltip(tooltip, accountInfo);
	TryAddFriendTagsToTooltip(tooltip, accountInfo);

	TryAddBroadcastToTooltip(tooltip, accountInfo);
	TryAddLastOnlineToTooltip(tooltip, accountInfo);
	TryAddGameAccountsToTooltip(tooltip, self.elementData.friendIndex, accountInfo);
end

function FriendsListSocialCardMixin:OnLeave()
	self:HideTooltip();
end

function FriendsListSocialCardMixin:HideTooltip()
	local tooltip = GetAppropriateTooltip();
	if tooltip:IsOwned(self) then
		tooltip:Hide();
	end
end

FriendsListSocialCardStateDisplayMixin = {};

function FriendsListSocialCardStateDisplayMixin:Initialize(accountInfo)
	self.FavoriteDisplay:Initialize(accountInfo);
	self:LayoutContent();
end

function FriendsListSocialCardStateDisplayMixin:LayoutContent()
	local favoriteDisplayShown = self.FavoriteDisplay:IsShown();
	self:SetShown(favoriteDisplayShown);
	self:SetDesiredWidth(favoriteDisplayShown and self.FavoriteDisplay.baseWidth or 0);
end

FriendsListSocialCardFavoriteDisplayMixin = {};

function FriendsListSocialCardFavoriteDisplayMixin:Initialize(accountInfo)
	self.isFavorite = accountInfo.isFavorite;
	self.isOnline = accountInfo.gameAccountInfo.isOnline;

	self:RefreshIconAndVisibility();
end

function FriendsListSocialCardFavoriteDisplayMixin:RefreshIconAndVisibility()
	local icon = self.isOnline and "friends-icon-favorites" or "friends-icon-favorites-dis";
	self.Icon:SetAtlas(icon, TextureKitConstants.IgnoreAtlasSize);

	self:SetShown(self.isFavorite);
end

function FriendsListSocialCardFavoriteDisplayMixin:OnEnter()
	self:ShowTooltip();
end

function FriendsListSocialCardFavoriteDisplayMixin:ShowTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(tooltip, SOCIAL_UI_FRIENDS_LIST_FAVORITE_TOOLTIP);
	tooltip:Show();
end

function FriendsListSocialCardFavoriteDisplayMixin:OnLeave()
	self:HideTooltip();
end

function FriendsListSocialCardFavoriteDisplayMixin:HideTooltip()
	GetAppropriateTooltip():Hide();
end

FriendsListSocialCardRAFSummonButtonMixin = {};

local FriendsListSocialCardRAFSummonButtonDynamicEvents =
{
	"SPELL_UPDATE_COOLDOWN",
	"GROUP_ROSTER_UPDATE",
};

function FriendsListSocialCardRAFSummonButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, FriendsListSocialCardRAFSummonButtonDynamicEvents);
end

function FriendsListSocialCardRAFSummonButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, FriendsListSocialCardRAFSummonButtonDynamicEvents);
end

function FriendsListSocialCardRAFSummonButtonMixin:OnEvent(_event, ...)
	self:Refresh();
end

function FriendsListSocialCardRAFSummonButtonMixin:Initialize(elementData)
	self.friendIndex = elementData.friendIndex;
	self.friendGUID = elementData.accountInfo.gameAccountInfo.playerGuid;
	self.rafLinkType = elementData.accountInfo.rafLinkType;

	self:Refresh();
end

function FriendsListSocialCardRAFSummonButtonMixin:Refresh()
	self:RefreshVisibility();
	self:RefreshEnabledState();
	self:RefreshCooldown();
end

function FriendsListSocialCardRAFSummonButtonMixin:RefreshVisibility()
	local shown = self:HasSummonableFriend();
	self:SetShown(shown);
end

function FriendsListSocialCardRAFSummonButtonMixin:HasSummonableFriend()
	local isRAFFriend = self.rafLinkType ~= Enum.RafLinkType.None;
	if not isRAFFriend then
		return false;
	end

	local partyInviteRestriction = FriendsListUtil.GetBattleNetFriendPartyInviteRestriction(self.friendIndex);
	local canInviteToParty = partyInviteRestriction == BattleNetFriendPartyInviteRestrictionType.None;
	return canInviteToParty;
end

function FriendsListSocialCardRAFSummonButtonMixin:RefreshEnabledState()
	if not self.friendGUID then
		local enabled = false;
		self:SetEnabledState(enabled);
		return;
	end

	local canSummon, reason = C_RecruitAFriend.CanSummonFriend(self.friendGUID);
	local isValidFriendButSummonOnCooldown = reason == Enum.RecruitAFriendFailure.SummonCooldown;
	self:SetEnabledState(canSummon or isValidFriendButSummonOnCooldown);
end

-- This button is never actually disabled because all error messages come from the server when you attempt to summon
-- We still want to provide visual feedback that summoning won't work so we desaturate the icon
function FriendsListSocialCardRAFSummonButtonMixin:SetEnabledState(enabled)
	self.ActionIcon:SetDesaturated(not enabled);
end

function FriendsListSocialCardRAFSummonButtonMixin:RefreshCooldown()
	local cooldownStartTimeSeconds, cooldownDurationSeconds, enableCooldownTimer = C_RecruitAFriend.GetSummonFriendCooldown();
	self.cooldownDurationSeconds = cooldownDurationSeconds;
	self.cooldownStartTime = cooldownStartTimeSeconds;
	CooldownFrame_Set(self.Cooldown, self.cooldownStartTime, self.cooldownDurationSeconds, enableCooldownTimer);
end

function FriendsListSocialCardRAFSummonButtonMixin:OnClick()
	if not self.friendIndex then
		return;
	end

	BNSummonFriendByIndex(self.friendIndex);
end

function FriendsListSocialCardRAFSummonButtonMixin:OnEnter()
	self:ShowTooltip();
end

function FriendsListSocialCardRAFSummonButtonMixin:ShowTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");

	GameTooltip_AddHighlightLine(tooltip, RAF_SUMMON_LINKED);
	if self.cooldownDurationSeconds > 0 then
		local cooldownRemainingString = SOCIAL_UI_RAF_SUMMON_BUTTON_COOLDOWN_FORMAT:format(SecondsToTime(self.cooldownDurationSeconds - (GetTime() - self.cooldownStartTime)));
		GameTooltip_AddHighlightLine(tooltip, cooldownRemainingString);
	end

	tooltip:Show();
end

function FriendsListSocialCardRAFSummonButtonMixin:OnLeave()
	self:HideTooltip();
end

function FriendsListSocialCardRAFSummonButtonMixin:HideTooltip()
	GetAppropriateTooltip():Hide();
end

FriendsListSocialCardPartyButtonMixin = {};

function FriendsListSocialCardPartyButtonMixin:Initialize(elementData)
	local accountInfo = elementData.accountInfo;
	if not accountInfo then
		return;
	end

	self.friendIndex = elementData.friendIndex;
	self.playerGUID = accountInfo.gameAccountInfo.playerGuid;
	self.isOnline = accountInfo.gameAccountInfo.isOnline;
	self.isCrossFactionFriend = IsCrossFactionFriend(accountInfo);

	self:Refresh();
end

function FriendsListSocialCardPartyButtonMixin:Refresh()
	self:RefreshDynamicData();
	self:RefreshEnabledState();
	self:RefreshIcon();
end

function FriendsListSocialCardPartyButtonMixin:RefreshDynamicData()
	local hasValidPlayerGUID = self.playerGUID ~= nil;
	self.isInGroup = hasValidPlayerGUID and C_SocialQueue.IsSystemSupported() and (C_SocialQueue.GetGroupForPlayer(self.playerGUID) ~= nil);

	self.inviteRestriction = FriendsListUtil.GetBattleNetFriendPartyInviteRestriction(self.friendIndex);
end

function FriendsListSocialCardPartyButtonMixin:HasInviteRestriction()
	return (self.inviteRestriction ~= nil) and self.inviteRestriction ~= BattleNetFriendPartyInviteRestrictionType.None;
end

function FriendsListSocialCardPartyButtonMixin:RefreshEnabledState()
	self:SetEnabledState(self.isOnline and not self:HasInviteRestriction());
end

function FriendsListSocialCardPartyButtonMixin:GetBestIconAtlas()
	if self.isInGroup then
		return self:IsEnabled() and "friends-icon-friendsInGroup" or "friends-icon-friendsInGroup-dis";
	else
		return self:IsEnabled() and "friends-icon-friendsAvailable" or "friends-icon-friendsAvailable-dis";
	end
end

function FriendsListSocialCardPartyButtonMixin:RefreshIcon()
	local icon = self:GetBestIconAtlas();
	self.ActionIcon:SetAtlas(icon, TextureKitConstants.UseAtlasSize);
end

function FriendsListSocialCardPartyButtonMixin:TryShowTooltip()
	if not self:ShouldShowTooltip() then
		return;
	end

	self:ShowTooltip();
end

function FriendsListSocialCardPartyButtonMixin:ShouldShowTooltip()
	return not C_Glue.IsOnGlueScreen();
end

function FriendsListSocialCardPartyButtonMixin:ShowTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:BuildTooltip(tooltip);
	tooltip:Show();
end

local function AddOfflineErrorToTooltip(tooltip)
	local wrapText = true;
	GameTooltip_AddErrorLine(tooltip, SOCIAL_UI_FRIENDS_LIST_PARTY_BUTTON_OFFLINE_TOOLTIP, wrapText);
end

local function AddInviteRestrictionToTooltip(tooltip, inviteRestriction)
	local wrapText = true;
	local restrictionText = FriendsListUtil.GetBattleNetFriendPartyInviteRestrictionText(inviteRestriction);
	GameTooltip_AddErrorLine(tooltip, restrictionText, wrapText);
end

local CrossFactionInviteAtlases =
{
	["Horde"] = "communities-create-button-wow-horde",
	["Alliance"] = "communities-create-button-wow-alliance",
};

local function TryAddCrossFactionInviteDetailsToTooltip(tooltip, inviteInfo)
	local isCrossFactionInvite = inviteInfo.isCrossFaction and inviteInfo.factionName;
	local addedCrossFactionDetails = false;
	if not isCrossFactionInvite then
		return addedCrossFactionDetails;
	end

	GameTooltip_AddBlankLineToTooltip(tooltip);

	local wrapText = true;
	local factionAtlas = CrossFactionInviteAtlases[inviteInfo.factionName];
	local factionLabel = FACTION_LABELS_FROM_STRING[inviteInfo.factionName] or FACTION_NEUTRAL;
	if factionAtlas then
		local factionColor = GetFactionColor(inviteInfo.factionName) or NORMAL_FONT_COLOR;
		local factionAtlasMarkup = CreateAtlasMarkup(factionAtlas, 22, 27);
		GameTooltip_AddColoredLine(tooltip, SOCIAL_UI_FRIENDS_LIST_FACTION_LABEL_FORMAT:format(factionAtlasMarkup, factionLabel), factionColor, wrapText);
	end

	GameTooltip_AddNormalLine(tooltip, CROSS_FACTION_INVITE_TOOLTIP:format(factionLabel), wrapText);
	addedCrossFactionDetails = true;
	return addedCrossFactionDetails;
end

local function BuildRequestInviteGroupMemberTooltipText(groupMemberInfo)
	local missingNameFallback = nil;
	local memberName, memberColor = SocialQueueUtil_GetRelationshipInfo(groupMemberInfo.guid, missingNameFallback, groupMemberInfo.clubId);

	local finalMemberName = memberColor and (memberColor .. memberName .. FONT_COLOR_CODE_CLOSE) or memberName;
	return finalMemberName;
end

local MAX_ADDITIONAL_GROUP_MEMBERS_IN_PARTY_BUTTON_TOOLTIP = 7;
local function TryAddRequestInviteGroupMembersToTooltip(tooltip, inviteInfo, groupGUID, queues)
	-- SocialQueueUtil_SetTooltip already lists group members via LFGListUtil_SetSearchEntryTooltip
	-- No point in duplicating the information here
	local isLFGListQueue = queues[1].queueData.queueType == "lfglist";
	if isLFGListQueue then
		return;
	end

	local groupMembers = C_SocialQueue.GetGroupMembers(groupGUID);
	if not groupMembers then
		return;
	end

	local inviteTargetGUID = inviteInfo.playerGUID;
	local numDisplayedGroupMembers = 0;
	for _index, groupMemberInfo in ipairs(groupMembers) do
		local isInviteTarget = groupMemberInfo.guid == inviteTargetGUID;
		if not isInviteTarget then
			local hasDisplayedAnyGroupMembers = numDisplayedGroupMembers > 0;
			local reachedTooltipMemberLimit = numDisplayedGroupMembers >= MAX_ADDITIONAL_GROUP_MEMBERS_IN_PARTY_BUTTON_TOOLTIP;

			if not hasDisplayedAnyGroupMembers then
				GameTooltip_AddBlankLineToTooltip(tooltip);
				GameTooltip_AddHighlightLine(tooltip, SOCIAL_QUEUE_ALSO_IN_GROUP);
			elseif reachedTooltipMemberLimit then
				GameTooltip_AddColoredLine(tooltip, SOCIAL_QUEUE_AND_MORE, GRAY_FONT_COLOR);
				break;
			end

			local formattedGroupMemberName = BuildRequestInviteGroupMemberTooltipText(groupMemberInfo);
			GameTooltip_AddNormalLine(tooltip, formattedGroupMemberName);

			numDisplayedGroupMembers = numDisplayedGroupMembers + 1;
		end
	end
end

local function TryAddSocialQueueDataToTooltip(tooltip, inviteInfo, shouldAddSeparator)
	if not inviteInfo or not inviteInfo.playerGUID or not FriendsListUtil.IsRequestInviteType(inviteInfo.inviteType) then
		return;
	end

	if not C_SocialQueue.IsSystemSupported() then
		return;
	end

	local groupGUID = C_SocialQueue.GetGroupForPlayer(inviteInfo.playerGUID);
	if not groupGUID then
		return;
	end

	local queues = C_SocialQueue.GetGroupQueues(groupGUID);
	if not queues or #queues == 0 then
		return;
	end

	if shouldAddSeparator then
		SocialUIUtil.AddSeparatorToTooltip(tooltip);
	end

	local tooltipTitle = nil;
	local canJoin = true;
	local hasRelationshipWithLeader = SocialQueueUtil_HasRelationshipWithLeader(groupGUID);
	SocialQueueUtil_SetTooltip(tooltip, tooltipTitle, queues, canJoin, hasRelationshipWithLeader);

	TryAddRequestInviteGroupMembersToTooltip(tooltip, inviteInfo, groupGUID, queues);
end

function FriendsListSocialCardPartyButtonMixin:BuildTooltip(tooltip)
	local inviteInfo = FriendsListUtil.GetBattleNetFriendInviteInfo(self.friendIndex);

	local inviteTypeLabel = FriendsListUtil.GetBattleNetFriendInviteTypeLabel(inviteInfo.inviteType);
	GameTooltip_AddHighlightLine(tooltip, inviteTypeLabel);

	if not self.isOnline then
		AddOfflineErrorToTooltip(tooltip);
		return;
	end

	local addedCrossFactionDetails = TryAddCrossFactionInviteDetailsToTooltip(tooltip, inviteInfo);

	if self:HasInviteRestriction() then
		AddInviteRestrictionToTooltip(tooltip, self.inviteRestriction);
		return;
	end

	local shouldAddSeparatorBeforeSocialQueueData = addedCrossFactionDetails;
	TryAddSocialQueueDataToTooltip(tooltip, inviteInfo, shouldAddSeparatorBeforeSocialQueueData);
end

function FriendsListSocialCardPartyButtonMixin:OnClick()
	self:TryInviteFriend();
end

local function BuildWoWGameAccountDropdownText(gameAccountInfo, hasInviteRestriction)
	local characterName = gameAccountInfo.characterName or "";
	if hasInviteRestriction then
		characterName = characterName .. CANNOT_COOPERATE_LABEL;
	end

	local characterLevel = gameAccountInfo.characterLevel or 0;
	local raceName = gameAccountInfo.raceName or UNKNOWN;
	local className = gameAccountInfo.className or UNKNOWN;
	return string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, characterName, characterLevel, raceName, className);
end

local function BuildNonWoWGameAccountDropdownText(gameAccountInfo, battleTag)
	local iconPrefix = "";
	if C_Texture.IsTitleIconTextureReady(gameAccountInfo.clientProgram, Enum.TitleIconVersion.Small) then
		C_Texture.GetTitleIconTexture(gameAccountInfo.clientProgram, Enum.TitleIconVersion.Small, function(success, texture)
			if success then
				local fileWidth, fileHeight, width, height, xOffset, yOffset = 32, 32, 14, 14, 0, 0;
				iconPrefix = BNet_GetClientEmbeddedTexture(texture, fileWidth, fileHeight, width);
			end
		end);
	end

	local characterName = BNet_GetValidatedCharacterName(gameAccountInfo.characterName, battleTag, gameAccountInfo.clientProgram) or "";
	if iconPrefix ~= "" then
		return SOCIAL_UI_FRIENDS_LIST_PARTY_DROPDOWN_ICON_NAME_FORMAT:format(iconPrefix, characterName);
	end
	return characterName;
end

local function GetGameAccountDropdownText(gameAccountInfo, battleTag)
	local isPlayingWoW = FriendsListUtil.IsPlayingWoW(gameAccountInfo);
	if not isPlayingWoW then
		return BuildNonWoWGameAccountDropdownText(gameAccountInfo, battleTag);
	end

	local restriction = FriendsListUtil.GetGameAccountPartyInviteRestriction(gameAccountInfo);
	local hasInviteRestriction = restriction ~= BattleNetFriendPartyInviteRestrictionType.None;
	return BuildWoWGameAccountDropdownText(gameAccountInfo, hasInviteRestriction);
end

local function IsGameAccountInvitable(gameAccountInfo)
	if not FriendsListUtil.IsPlayingWoW(gameAccountInfo) then
		return false;
	end

	local restriction = FriendsListUtil.GetGameAccountPartyInviteRestriction(gameAccountInfo);
	return restriction == BattleNetFriendPartyInviteRestrictionType.None;
end

local function AddGameAccountDropdownButton(rootDescription, gameAccountInfo, battleTag)
	local text = GetGameAccountDropdownText(gameAccountInfo, battleTag);

	if not IsGameAccountInvitable(gameAccountInfo) then
		local button = rootDescription:CreateButton(text);
		button:SetEnabled(false);
		button:AddInitializer(SocialUIUtil.InitializeUserScaledDropdownButton);
		return;
	end

	local button = rootDescription:CreateButton(text, function()
		local refreshedGameAccountInfo = C_BattleNet.GetGameAccountInfoByID(gameAccountInfo.gameAccountID);
		local playerGuid = refreshedGameAccountInfo and refreshedGameAccountInfo.playerGuid;
		if playerGuid then
			FriendsListUtil.InviteOrRequestToJoin(playerGuid, gameAccountInfo.gameAccountID);
		end
	end);
	button:AddInitializer(SocialUIUtil.InitializeUserScaledDropdownButton);
end

local function ShowPartyInviteTargetSelectionDropdown(friendIndex, attachedTo)
	local accountInfo = C_BattleNet.GetFriendAccountInfo(friendIndex);
	local battleTag = accountInfo and accountInfo.battleTag;

	MenuUtil.CreateContextMenu(attachedTo, function(_owner, rootDescription)
		rootDescription:SetTag("MENU_FRIENDS_TRAVEL_PASS");

		local title = rootDescription:CreateTitle(TRAVEL_PASS_INVITE);
		title:AddInitializer(SocialUIUtil.InitializeUserScaledDropdownTitle);

		local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(friendIndex);
		for accountIndex = 1, numGameAccounts do
			local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(friendIndex, accountIndex);
			AddGameAccountDropdownButton(rootDescription, gameAccountInfo, battleTag);
		end
	end);
end

function FriendsListSocialCardPartyButtonMixin:TryInviteFriend()
	local friendIndex = self.friendIndex;
	if not friendIndex then
		return;
	end

	if self.isCrossFactionFriend and not HasAcknowledgedCrossFactionInviteTutorial() then
		HelpTip:AcknowledgeSystem("friendsList", CROSS_FACTION_INVITE_HELPTIP);
	end

	local directInviteGameAccountInfo = FriendsListUtil.GetBattleNetFriendGameAccountInfoIfExactlyOneDirectInviteTargetExists(friendIndex);
	if directInviteGameAccountInfo then
		FriendsListUtil.InviteOrRequestToJoin(directInviteGameAccountInfo.playerGuid, directInviteGameAccountInfo.gameAccountID);
		return;
	end

	if FriendsListUtil.HasMultipleGameAccounts(friendIndex) then
		local attachTo = self;
		ShowPartyInviteTargetSelectionDropdown(friendIndex, attachTo);
	end
end
