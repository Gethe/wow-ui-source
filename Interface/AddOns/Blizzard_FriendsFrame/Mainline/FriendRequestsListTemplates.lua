FriendRequestsListSocialViewMixin = CreateFromMixins(SocialUISystemMixin, SocialUIScrollableElementExtentPreviewerMixin);

local FriendRequestsListSocialViewDynamicEvents =
{
	"BN_CONNECTED",
	"BN_DISCONNECTED",
	"BN_FRIEND_INVITE_LIST_INITIALIZED",
	"BN_FRIEND_INVITE_ADDED",
	"BN_FRIEND_INVITE_REMOVED",
	"BN_INFO_CHANGED",
};

local function ModeSupportsStaticPopups()
	return not C_Glue.IsOnGlueScreen();
end

local function ClosePendingFriendRequestDialogs()
	if not ModeSupportsStaticPopups() then
		return;
	end

	StaticPopup_Hide("CONFIRM_BLOCK_INVITES");
end

function FriendRequestsListSocialViewMixin:OnLoad()
	SocialUIScrollableElementExtentPreviewerMixin.OnLoad(self);
	self:InitializeActionButton();
	self:InitializeScrollBox();
	self:InitializeRealIDWarning();
end

function FriendRequestsListSocialViewMixin:InitializeActionButton()
	Mixin(self.ActionButton, SocialUIAddFriendButtonMixin);
	self.ActionButton:SetText(SOCIAL_UI_FRIEND_REQUESTS_ADD_FRIEND_BUTTON_LABEL);
end

function FriendRequestsListSocialViewMixin:InitializeScrollBox()
	self:RegisterScrollableTemplatesForExtentPreview({"SocialUIScrollableHeaderTemplate", "FriendRequestsListSocialCardTemplate", "SocialUIScrollableSpacerTemplate",});

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
			return "FriendRequestsListSocialCardTemplate";
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

function FriendRequestsListSocialViewMixin:InitializeRealIDWarning()
	self.RealIDWarning.ContinueButton:SetScript("OnClick", function(button)
		SocialUIActionButtonMixin.OnClick(button);

		SetCVar("pendingInviteInfoShown", 1);
		self:RefreshRealIDWarningVisibility();
	end);
end

function FriendRequestsListSocialViewMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, FriendRequestsListSocialViewDynamicEvents);

	EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", self.OnFriendRequestsListTextScaleUpdated, self);
	self:ClearTemplateExtentCache();

	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
end

function FriendRequestsListSocialViewMixin:OnFriendRequestsListTextScaleUpdated()
	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function FriendRequestsListSocialViewMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, FriendRequestsListSocialViewDynamicEvents);

	EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self.OnFriendRequestsListTextScaleUpdated, self);

	ClosePendingFriendRequestDialogs();
end

function FriendRequestsListSocialViewMixin:OnEvent(_event, ...)
	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

local function InsertFriendRequestsIntoDataProvider(dataProvider)
	local numFriendRequests = BNGetNumFriendInvites();
	local friendRequestsSubTree = dataProvider:Insert({ headerText = SOCIAL_UI_FRIEND_REQUESTS_RECEIVED_HEADER:format(numFriendRequests) });
	friendRequestsSubTree:Insert({ isSpacer = true });

	for inviteIndex = 1, numFriendRequests do
		friendRequestsSubTree:Insert({ inviteIndex = inviteIndex });
	end
end

function FriendRequestsListSocialViewMixin:Refresh(retainScrollPosition)
	self:RefreshActionButtonEnabledState();

	self:ClearTemplateExtentCache();
	self.ScrollBox:SetDataProvider(self:GenerateDataProvider(), retainScrollPosition);

	self:RefreshRealIDWarningVisibility();
end

function FriendRequestsListSocialViewMixin:GenerateDataProvider()
	local dataProvider = CreateTreeDataProvider();
	InsertFriendRequestsIntoDataProvider(dataProvider);
	return dataProvider;
end

function FriendRequestsListSocialViewMixin:RefreshRealIDWarningVisibility()
	local shouldShowRealIDWarning = self:ShouldShowRealIDWarning();
	self.RealIDWarning:SetShown(shouldShowRealIDWarning);
end

local function HasAnyRealIDInvites()
	for inviteIndex = 1, BNGetNumFriendInvites() do
		local inviteInfo = C_BattleNet.GetFriendInviteInfo(inviteIndex);
		local isRealIDInvite = inviteInfo and (inviteInfo.friendLevel == Enum.BattleNetFriendLevel.RealID) or false;
		if isRealIDInvite then
			return true;
		end
	end

	return false;
end

function FriendRequestsListSocialViewMixin:ShouldShowRealIDWarning()
	local alreadySeenWarning = GetCVarBool("pendingInviteInfoShown");
	if alreadySeenWarning then
		return false;
	end

	local isRealIDEnabled = select(7, BNGetInfo());
	if not isRealIDEnabled then
		return false;
	end

	return HasAnyRealIDInvites();
end

FriendRequestsListSocialCardAcceptButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function FriendRequestsListSocialCardAcceptButtonMixin:OnLoad()
	self:OnLoad_UserScaledElement();

	ButtonStateBehaviorMixin.OnLoad(self);
	self:SetUpDisplacedRegions();
end

function FriendRequestsListSocialCardAcceptButtonMixin:SetUpDisplacedRegions()
	local displaceX, displaceY = 1, -1;
	self:SetDisplacedRegions(displaceX, displaceY, self.Text);
end

function FriendRequestsListSocialCardAcceptButtonMixin:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);

	self:ShowTooltipIfTruncated();
end

function FriendRequestsListSocialCardAcceptButtonMixin:ShowTooltipIfTruncated()
	if not self.Text:IsTruncated() then
		return;
	end

	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(tooltip, self.Text:GetText());
	tooltip:Show();
end

function FriendRequestsListSocialCardAcceptButtonMixin:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);

	self:HideTooltip();
end

function FriendRequestsListSocialCardAcceptButtonMixin:HideTooltip()
	local tooltip = GetAppropriateTooltip();
	if tooltip:IsOwned(self) then
		tooltip:Hide();
	end
end

function FriendRequestsListSocialCardAcceptButtonMixin:OnMouseDown()
	ButtonStateBehaviorMixin.OnMouseDown(self);
end

function FriendRequestsListSocialCardAcceptButtonMixin:OnMouseUp()
	ButtonStateBehaviorMixin.OnMouseUp(self);
end

function FriendRequestsListSocialCardAcceptButtonMixin:OnClick()
	ClosePendingFriendRequestDialogs();
	self:AcceptFriendInvite();

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function FriendRequestsListSocialCardAcceptButtonMixin:AcceptFriendInvite()
	if not self.inviteID then
		return;
	end

	BNAcceptFriendInvite(self.inviteID);
end

function FriendRequestsListSocialCardAcceptButtonMixin:Initialize(elementData)
	self.inviteID = elementData.inviteID;
end

FriendRequestsListSocialCardMixin = {};

function FriendRequestsListSocialCardMixin:Initialize(node)
	self:RefreshInviteData(node);
	self:InitializeDisplay();
	self:LayoutScaledContent();

	local selected = SelectionBehaviorMixin.IsElementDataIntrusiveSelected(node);
	self:SetSelected(selected);
end

function FriendRequestsListSocialCardMixin:SetSelected(selected)
	self:SetHighlightLocked(selected);
end

function FriendRequestsListSocialCardMixin:RefreshInviteData(node)
	local inviteIndex = node:GetData().inviteIndex;
	local inviteInfo = C_BattleNet.GetFriendInviteInfo(inviteIndex);
	if not inviteInfo then
		self.elementData = { inviteIndex = inviteIndex, };
		return;
	end

	self.elementData =
	{
		inviteIndex = inviteIndex,
		inviteID = inviteInfo.inviteID,
		accountName = inviteInfo.accountName,
		friendLevel = inviteInfo.friendLevel,
		creationTimestamp = inviteInfo.creationTimestamp,
	};
end

function FriendRequestsListSocialCardMixin:InitializeDisplay()
	self:InitializeBackground();
	self:InitializeAcceptButton();
	self:InitializeDeclineButton();
	self:InitializeCardDisplayText();
end

function FriendRequestsListSocialCardMixin:InitializeBackground()
	local backgroundAtlas = self:GetBestBackgroundAtlas();
	self.Background:SetAtlas(backgroundAtlas, TextureKitConstants.IgnoreAtlasSize);
end

function FriendRequestsListSocialCardMixin:GetBestBackgroundAtlas()
	return self:IsWowAccountFriendRequest() and "friends-card-default" or "friends-card-battleNet";
end

function FriendRequestsListSocialCardMixin:InitializeAcceptButton()
	self.AcceptButton:Initialize(self.elementData);
end

function FriendRequestsListSocialCardMixin:InitializeDeclineButton()
	self.DeclineButton:Initialize(self.elementData);
end

function FriendRequestsListSocialCardMixin:InitializeCardDisplayText()
	self:InitializeRequestTimestampText();
	self:InitializeRequesterNameText();
	self:InitializeFriendTypeText();
end

local FRIEND_LEVEL_TO_DISPLAY_TEXT =
{
	[Enum.BattleNetFriendLevel.RealID] = SOCIAL_UI_FRIEND_REQUESTS_CARD_REAL_ID_LABEL,
	[Enum.BattleNetFriendLevel.BattleTag] = SOCIAL_UI_FRIEND_REQUESTS_CARD_BATTLE_NET_LABEL,
	[Enum.BattleNetFriendLevel.Title] = SOCIAL_UI_FRIEND_REQUESTS_CARD_TITLE_LABEL,
};

local function GetFriendTypeText(elementData)
	return FRIEND_LEVEL_TO_DISPLAY_TEXT[elementData.friendLevel] or "";
end

local function BuildTimestampDisplayText(elementData)
	local creationTimestamp = elementData.creationTimestamp;
	local hasValidCreationTimestamp = creationTimestamp and creationTimestamp > 0;
	if not hasValidCreationTimestamp then
		return "";
	end

	local relativeTimeText = FriendsListUtil.GetRelativeTimeText(creationTimestamp);
	local timestampText = format(SOCIAL_UI_FRIEND_REQUESTS_CARD_TIMESTAMP_FORMAT, relativeTimeText);
	return HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(timestampText);
end

function FriendRequestsListSocialCardMixin:InitializeRequestTimestampText()
	local displayText = BuildTimestampDisplayText(self.elementData);
	self.RequestTimestamp:SetText(displayText);
end

local function GetRequesterNameColor(elementData)
	local isWowAccountFriendRequest = elementData.friendLevel == Enum.BattleNetFriendLevel.Title;
	return isWowAccountFriendRequest and NORMAL_FONT_COLOR or BATTLENET_FONT_COLOR;
end

local function BuildRequesterNameDisplayText(elementData)
	local accountName = elementData.accountName or "";
	local nameColor = GetRequesterNameColor(elementData);
	return nameColor:WrapTextInColorCode(accountName);
end

function FriendRequestsListSocialCardMixin:InitializeRequesterNameText()
	local displayText = BuildRequesterNameDisplayText(self.elementData);
	self.Name:SetText(displayText);
end

local function BuildFriendTypeDisplayText(elementData)
	local displayText = GetFriendTypeText(elementData);
	return FRIENDS_GRAY_COLOR:WrapTextInColorCode(displayText);
end

function FriendRequestsListSocialCardMixin:InitializeFriendTypeText()
	local displayText = BuildFriendTypeDisplayText(self.elementData);
	self.FriendType:SetText(displayText);
end

-- We attempt to keep the anchoring of elements visually consistent as they get bigger due to font scaling
function FriendRequestsListSocialCardMixin:LayoutScaledContent()
	self:LayoutScaledAcceptButtonAnchors();
	self:LayoutScaledDeclineButtonAnchors();
	self:LayoutScaledTextHolderAnchors();
	self:LayoutCardDisplayText();
end

function FriendRequestsListSocialCardMixin:LayoutScaledAcceptButtonAnchors()
	local scaledXOffset = TextSizeManager:GetScaledValue(self.acceptButtonXOffset);
	local scaledYOffset = TextSizeManager:GetScaledValue(self.acceptButtonYOffset);

	self.AcceptButton:ClearAllPoints();
	self.AcceptButton:SetPoint("RIGHT", self, "RIGHT", scaledXOffset, scaledYOffset);
end

function FriendRequestsListSocialCardMixin:LayoutScaledDeclineButtonAnchors()
	local scaledXOffset = TextSizeManager:GetScaledValue(self.declineButtonXOffset);
	local scaledYOffset = TextSizeManager:GetScaledValue(self.declineButtonYOffset);

	self.DeclineButton:ClearAllPoints();
	self.DeclineButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", scaledXOffset, scaledYOffset);
end

function FriendRequestsListSocialCardMixin:LayoutScaledTextHolderAnchors()
	local textHolder = self.TextHolder;

	local scaledTopLeftYOffset = TextSizeManager:GetScaledValue(self.textHolderTopLeftYOffset);

	textHolder:ClearAllPoints();
	textHolder:SetPoint("TOPLEFT", self, "TOPLEFT", self.textHolderTopLeftXOffset, scaledTopLeftYOffset);
	textHolder:SetPoint("RIGHT", self.AcceptButton, "LEFT", self.textHolderRightXOffset, 0);
	textHolder:SetPoint("BOTTOM", self, "BOTTOM", 0, self.textHolderBottomYOffset);
end

function FriendRequestsListSocialCardMixin:LayoutCardDisplayText()
	self.RequestTimestamp:ClearAllPoints();
	self.RequestTimestamp:SetPoint("TOPLEFT", self.TextHolder);
	self.RequestTimestamp:SetPoint("RIGHT", self.TextHolder);

	local scaledLineSpacing = TextSizeManager:GetScaledValue(self.lineSpacing);

	self.Name:ClearAllPoints();
	self.Name:SetPoint("TOPLEFT", self.RequestTimestamp, "BOTTOMLEFT", 0, -scaledLineSpacing);
	self.Name:SetPoint("RIGHT", self.TextHolder);

	self.FriendType:ClearAllPoints();
	self.FriendType:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, -scaledLineSpacing);
	self.FriendType:SetPoint("RIGHT", self.TextHolder);
end

function FriendRequestsListSocialCardMixin:OnEnter()
	self:ShowTooltip();
end

function FriendRequestsListSocialCardMixin:ShowTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:BuildTooltip(tooltip);
	tooltip:Show();
end

local function AddFriendRequestDataToTooltip(tooltip, elementData)
	local timestampText = BuildTimestampDisplayText(elementData);
	GameTooltip_AddNormalLine(tooltip, timestampText);

	local nameText = BuildRequesterNameDisplayText(elementData);
	GameTooltip_AddNormalLine(tooltip, nameText);

	local friendTypeText = BuildFriendTypeDisplayText(elementData);
	GameTooltip_AddNormalLine(tooltip, friendTypeText);
end

function FriendRequestsListSocialCardMixin:BuildTooltip(tooltip)
	AddFriendRequestDataToTooltip(tooltip, self.elementData);
end

function FriendRequestsListSocialCardMixin:OnLeave()
	self:HideTooltip();
end

function FriendRequestsListSocialCardMixin:HideTooltip()
	local tooltip = GetAppropriateTooltip();
	if tooltip:IsOwned(self) then
		tooltip:Hide();
	end
end

function FriendRequestsListSocialCardMixin:GetInviteID()
	return self.elementData.inviteID;
end

function FriendRequestsListSocialCardMixin:IsWowAccountFriendRequest()
	return self.elementData.friendLevel == Enum.BattleNetFriendLevel.Title;
end

function FriendRequestsListSocialCardMixin:IsBattleTagAccountFriendRequest()
	return self.elementData.friendLevel == Enum.BattleNetFriendLevel.BattleTag;
end

function FriendRequestsListSocialCardMixin:IsRealIDFriendRequest()
	return self.elementData.friendLevel == Enum.BattleNetFriendLevel.RealID;
end

FriendRequestsListSocialCardDeclineButtonMixin = {};

function FriendRequestsListSocialCardDeclineButtonMixin:OnLoad()
	UserScaledElementMixin.OnLoad_UserScaledElement(self);

	self:SetupMenu(function(_dropdown, rootDescription)
		rootDescription:SetTag("MENU_FRIEND_REQUESTS_DECLINE");

		local declineButton = rootDescription:CreateButton(DECLINE, function()
			ClosePendingFriendRequestDialogs();
			BNDeclineFriendInvite(self.inviteID);
		end);
		declineButton:AddInitializer(SocialUIUtil.InitializeUserScaledDropdownButton);

		local reportButton = rootDescription:CreateButton(REPORT_PLAYER, function()
			local inviteInfo = C_BattleNet.GetFriendInviteInfo(self.inviteIndex);
			local bnetIDAccount = inviteInfo and inviteInfo.inviteID or nil;
			local name = inviteInfo and inviteInfo.accountName or nil;
			local playerLocation = PlayerLocation:CreateFromBattleNetID(bnetIDAccount);
			local reportInfo = ReportInfo:CreateReportInfoFromType(Enum.ReportType.Friend);
			ReportFrame:InitiateReport(reportInfo, name, playerLocation, bnetIDAccount ~= nil);
		end);
		reportButton:AddInitializer(SocialUIUtil.InitializeUserScaledDropdownButton);

		if ModeSupportsStaticPopups() then
			local blockButton = rootDescription:CreateButton(BLOCK_INVITES, function()
				local inviteInfo = C_BattleNet.GetFriendInviteInfo(self.inviteIndex);
				local inviteID = inviteInfo and inviteInfo.inviteID or nil;
				local accountName = inviteInfo and inviteInfo.accountName or nil;
				StaticPopup_Show("CONFIRM_BLOCK_INVITES", accountName, nil, inviteID);
			end);
			blockButton:AddInitializer(SocialUIUtil.InitializeUserScaledDropdownButton);
		end
	end);
end

function FriendRequestsListSocialCardDeclineButtonMixin:Initialize(elementData)
	self.inviteID = elementData.inviteID;
	self.inviteIndex = elementData.inviteIndex;
end

FriendRequestsListRealIDWarningMixin = {};

function FriendRequestsListRealIDWarningMixin:OnLoad()
	self:InitializeScrollBox();
end

function FriendRequestsListRealIDWarningMixin:InitializeScrollBox()
	local scrollBox = self.ScrollableWarningText:GetScrollBox();
	ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, self.ScrollBar);
	scrollBox:SetEdgeFadeLength(10);

	self.ScrollableWarningText:SetText(SOCIAL_UI_FRIEND_REQUESTS_REAL_ID_WARNING);
	self.ScrollableWarningText:GetFontString():SetJustifyH("CENTER");
end
