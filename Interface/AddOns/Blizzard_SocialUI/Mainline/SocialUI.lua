local function IsInGame()
	return not C_Glue.IsOnGlueScreen();
end

local function GameStateUsesUIPanelManager()
	return IsInGame();
end

local function TabSort(tab1, tab2)
	if tab1.tabOrder ~= tab2.tabOrder then
		return tab1.tabOrder < tab2.tabOrder;
	end

	return strcmputf8i(tab1.tabName, tab2.tabName) < 0;
end

SocialUIFrameMixin = CreateFromMixins(CallbackRegistryMixin);

SocialUIFrameMixin:GenerateCallbackEvents(
{
	"FeatureAvailabilityChanged",
	"OpenToTabAndSideWindowRequested",
	"OpenToTabRequested",
	"SideWindowHideRequested",
	"SideWindowShowRequested",
	"TabCounterRefreshRequested",
	"TabGlowRequested",
});

local SOCIAL_UI_FRAME_EVENTS =
{
	"SOCIAL_UI_SYSTEM_STATUS_UPDATED",
};

function SocialUIFrameMixin:OnLoad()
	self:InitializeCallbackEventSystem();
	self:InitializeAnchoringForGameContext();
	self:InitializeFrameVisuals();
	self:InitializeTabSystem();
	self:InitializeSideWindows();

	self:TryInitializeUIPanelRegistration();
	self:RegisterForTransitions();
end

function SocialUIFrameMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);
	FrameUtil.RegisterFrameForEvents(self, SOCIAL_UI_FRAME_EVENTS);
	self:Reset();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function SocialUIFrameMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, SOCIAL_UI_FRAME_EVENTS);
	self:CleanUp();

	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function SocialUIFrameMixin:OnEvent(event, ...)
	if event == "SOCIAL_UI_SYSTEM_STATUS_UPDATED" then
		self:Reset();
	end
end

function SocialUIFrameMixin:SetBestTopLevelParent()
	local bestParent = GetAppropriateTopLevelParent();
	self:SetParent(bestParent);
end

function SocialUIFrameMixin:InitializeCallbackEventSystem()
	CallbackRegistryMixin.OnLoad(self);

	self:AddStaticEventMethod(self, SocialUIFrameMixin.Event.OpenToTabAndSideWindowRequested, self.OnOpenToTabAndSideWindowRequested);
	self:AddStaticEventMethod(self, SocialUIFrameMixin.Event.OpenToTabRequested, self.OnOpenToTabRequested);
	self:AddStaticEventMethod(self, SocialUIFrameMixin.Event.TabGlowRequested, self.OnTabGlowRequested);

	self:AddDynamicEventMethod(self, SocialUIFrameMixin.Event.FeatureAvailabilityChanged, self.OnFeatureAvailabilityChanged);
	self:AddDynamicEventMethod(self, SocialUIFrameMixin.Event.SideWindowHideRequested, self.OnSideWindowHideRequested);
	self:AddDynamicEventMethod(self, SocialUIFrameMixin.Event.SideWindowShowRequested, self.OnSideWindowShowRequested);
	self:AddDynamicEventMethod(self, SocialUIFrameMixin.Event.TabCounterRefreshRequested, self.OnTabCounterRefreshRequested);
end

-- The Social UI is accessible both in-game and at glues
-- We need to make adjustments depending on the game context
function SocialUIFrameMixin:InitializeAnchoringForGameContext()
	self:SetBestTopLevelParent();

	if C_Glue.IsOnGlueScreen() then
		self:ClearAllPoints();
		self:SetPoint("TOPLEFT", 50, -50);
	end
end

function SocialUIFrameMixin:InitializeFrameVisuals()
	self.TopTileStreaks:Hide();
	self.Bg:SetColorTexture(BLACK_FONT_COLOR:GetRGBA());
	self:SetPortraitToAsset(self.portraitIcon);
end

function SocialUIFrameMixin:InitializeTabSystem()
	local function SocialTabResetter(framePool, tab)
		tab:Reset();
		Pool_HideAndClearAnchors(framePool, tab);
	end
	self.socialTabPool = CreateFramePool("BUTTON", self, "SocialUITabTemplate", SocialTabResetter);

	self:InitializeTabDefinitions();
	self.availableTabData = {};
	self.selectedTab = nil;
	self.lastSelectedTabType = nil;
	self.deferredOpenTabType = nil;
	self.deferredSideWindowType = nil;
	self.glowingTabTypes = {};
end

local function CreateTabContentFrame(socialUIFrame, template, parentKey)
	local frameAlreadyExists = socialUIFrame[parentKey] ~= nil;
	if frameAlreadyExists then
		return socialUIFrame[parentKey];
	end

	local contentFrame = CreateFrame("Frame", nil, socialUIFrame, template);
	contentFrame:SetPoint("TOPLEFT", socialUIFrame.BattleNetBar, "BOTTOMLEFT", 0, 5);
	contentFrame:SetPoint("BOTTOMRIGHT", socialUIFrame, "BOTTOMRIGHT", -2, 2);
	contentFrame:Hide();
	socialUIFrame[parentKey] = contentFrame;
	return contentFrame;
end

local function CreateSideWindowFrame(socialUIFrame, template, parentKey)
	local frameAlreadyExists = socialUIFrame[parentKey] ~= nil;
	if frameAlreadyExists then
		return socialUIFrame[parentKey];
	end

	local sideWindow = CreateFrame("Frame", nil, socialUIFrame, template);
	sideWindow:Hide();
	socialUIFrame[parentKey] = sideWindow;
	return sideWindow;
end

local function IsTabSupported(tabData)
	return tabData.IsSupported == nil or tabData.IsSupported();
end

local function IsTabEnabled(tabData)
	return tabData.GetEnabledState == nil or tabData.GetEnabledState();
end

function SocialUIFrameMixin:InitializeTabDefinitions()
	-- Example tab definition:
	-- [SocialUITabType.MyFeature] =							-- Add a new SocialUITabType in SocialUISharedConstants.lua
	-- {
	--     tabOrder = 1,										-- Tab sort order (ascending)
	--     tabType = SocialUITabType.MyFeature,					-- The SocialUITabType you created for this tab
	--     socialSystem = Enum.SocialSystemType.MyFeature,		-- Backend system enum for this feature
	--     tabName = SOCIAL_UI_MY_FEATURE_TAB_NAME,				-- Global string for the tab tooltip and Social UI window title
	--     iconAtlas = "friends-icon-tab-myfeature",			-- Atlas for the tab button icon
	--     iconInactiveAtlas = "friends-icon-tab-myfeature-inactive", -- (Optional) Atlas for the tab button icon when not selected; if omitted, iconAtlas will be used for both states
	--     contentFrameTemplate = "MyFeatureViewTemplate",		-- XML template to create as the tab's content frame; omit if the frame is defined in XML (but generally they should exist in the feature addon)
	--     contentFrameParentKey = "MyFeatureList",				-- parentKey name on SocialUIFrame; required if using contentFrameTemplate
	--     sideWindows =										-- (Optional) Side windows to create alongside this tab; add new entries to SocialUISideWindowType in SocialUISharedConstants.lua
	--     {
	--			{ sideWindowType = SocialUISideWindowType.MyFeatureSideWindow, template = "MyFeatureSideWindowTemplate", key = "MyFeatureSideWindow" },
	--     },
	--     countGenerator = custom function						-- (Optional) Returns a number to display under the tab button's icon
	--     helpTipGenerator = custom function					-- (Optional) Returns a helpTipInfo table (or nil) to show on the tab button when the Social UI opens
	--     IsSupported = SomeNamespace.IsSystemSupported,		-- (Optional static check) Can this feature EVER work in the current game state? (Ex. Glues versus in-game)
	--     IsAvailable = SomeNamespace.IsSystemEnabled,			-- Dynamic check: If supported in this game state, is the feature actually turned on?
	--     GetEnabledState = custom function					-- (Optional dynamic check) The feature is turned on, but can you use it right now? This can also return a disabled reason for the tab tooltip
	-- },

	self.tabDefinitions =
	{
		[SocialUITabType.Friends] =
		{
			tabOrder = 1,
			tabType = SocialUITabType.Friends,
			socialSystem = Enum.SocialSystemType.Friends,
			tabName = SOCIAL_UI_FRIENDS_TAB_NAME,
			iconAtlas = "friends-icon-tab-friends",
			iconInactiveAtlas = "friends-icon-tab-friends-inactive",
			contentFrameTemplate = "FriendsListSocialViewTemplate",
			contentFrameParentKey = "FriendsList",
			IsSupported = C_BattleNet.IsBattleNetFriendsListSupported,
			IsAvailable = C_BattleNet.IsBattleNetFriendsListEnabled,
			contentFrameSetupCallback = SocialUIContactsFrameInitializeAADC,
		},
		[SocialUITabType.RecentAllies] =
		{
			tabOrder = 2,
			tabType = SocialUITabType.RecentAllies,
			socialSystem = Enum.SocialSystemType.RecentAllies,
			tabName = SOCIAL_UI_RECENT_ALLIES_TAB_NAME,
			iconAtlas = "friends-icon-tab-recentallies",
			iconInactiveAtlas = "friends-icon-tab-recentallies-inactive",
			contentFrameTemplate = "RecentAlliesSocialViewTemplate",
			contentFrameParentKey = "RecentAlliesList",
			IsSupported = C_RecentAllies.IsSystemSupported,
			IsAvailable = C_RecentAllies.IsSystemEnabled,
			contentFrameSetupCallback = SocialUIContactsFrameInitializeAADC,
		},
		[SocialUITabType.QuickJoin] =
		{
			tabOrder = 3,
			tabType = SocialUITabType.QuickJoin,
			socialSystem = Enum.SocialSystemType.QuickJoin,
			tabName = SOCIAL_UI_QUICK_JOIN_TAB_NAME,
			iconAtlas = "friends-icon-tab-quickjoin",
			iconInactiveAtlas = "friends-icon-tab-quickjoin-inactive",
			contentFrameTemplate = "QuickJoinSocialViewTemplate",
			contentFrameParentKey = "QuickJoinFrame",
			countGenerator = function() return #C_SocialQueue.GetAllGroups(); end,
			helpTipGenerator = function()
				-- We want at least two groups to show the tutorial.  This avoids more cases where all groups delist.
				local allowNonJoinable, allowNonQueuedGroups = false, false;
				local hasEnoughGroupsToTriggerHelpTip = #C_SocialQueue.GetAllGroups(allowNonJoinable, allowNonQueuedGroups) > 1;
				local hasSeenTutorial = GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FRIENDS_LIST_QUICK_JOIN);
				if hasSeenTutorial or not hasEnoughGroupsToTriggerHelpTip then
					return nil;
				end

				return
				{
					text = SOCIAL_QUICK_JOIN_TAB_HELP_TIP,
					buttonStyle = HelpTip.ButtonStyle.Close,
					cvarBitfield = "closedInfoFrames",
					bitfieldFlag = LE_FRAME_TUTORIAL_FRIENDS_LIST_QUICK_JOIN,
					targetPoint = HelpTip.Point.RightEdgeCenter,
					system = "quickJoinIntroduction",
				};
			end,
			IsSupported = C_SocialQueue.IsSystemSupported,
			IsAvailable = C_SocialQueue.IsSystemEnabled,
			contentFrameSetupCallback = SocialUIContactsFrameInitializeAADC,
		},
		[SocialUITabType.FriendRequests] =
		{
			tabOrder = 4,
			tabType = SocialUITabType.FriendRequests,
			socialSystem = Enum.SocialSystemType.Friends,
			tabName = SOCIAL_UI_FRIEND_REQUESTS_TAB_NAME,
			iconAtlas = "friends-icon-tab-friendRequest",
			iconInactiveAtlas = "friends-icon-tab-friendRequest-inactive",
			contentFrameTemplate = "FriendRequestsListSocialViewTemplate",
			contentFrameParentKey = "FriendRequestsList",
			IsSupported = C_BattleNet.IsBattleNetFriendsListSupported,
			IsAvailable = C_BattleNet.IsBattleNetFriendsListEnabled,
			contentFrameSetupCallback = SocialUIContactsFrameInitializeAADC,
		},
		[SocialUITabType.RecruitAFriend] =
		{
			tabOrder = 5,
			tabType = SocialUITabType.RecruitAFriend,
			socialSystem = Enum.SocialSystemType.RecruitAFriend,
			tabName = SOCIAL_UI_RECRUIT_A_FRIEND_TAB_NAME,
			iconAtlas = "friends-icon-tab-recruitFriends",
			iconInactiveAtlas = "friends-icon-tab-recruitFriends-inactive",
			contentFrameTemplate = "RecruitAFriendFrameSocialViewTemplate",
			contentFrameParentKey = "RecruitAFriendFrame",
			IsSupported = C_RecruitAFriend.IsSystemSupported,
			IsAvailable = C_RecruitAFriend.IsSystemEnabled,
		},
		[SocialUITabType.RaidList] =
		{
			tabOrder = 6,
			tabType = SocialUITabType.RaidList,
			socialSystem = Enum.SocialSystemType.RaidList,
			tabName = SOCIAL_UI_RAID_TAB_NAME,
			iconAtlas = "friends-icon-tab-raid",
			iconInactiveAtlas = "friends-icon-tab-raid-inactive",
			sideWindows =
			{
				{ sideWindowType = SocialUISideWindowType.RaidInfoFrame, template = "SocialUIRaidInfoFrameTemplate", key = "RaidInfoFrame" },
			},
			contentFrameTemplate = "RaidFrameSocialTemplate",
			contentFrameParentKey = "RaidFrame",
			IsSupported = C_PartyInfo.IsRaidListSupported,
			IsAvailable = C_PartyInfo.IsRaidListEnabled,
			GetEnabledState = function()
				if DifficultyUtil.InStoryRaid() then
					return false, DIFFICULTY_LOCKED_REASON_STORY_RAID;
				end

				return true, nil;
			end,
		},
	};

	self:CreateContentFramesForSupportedTabs();
end

function SocialUIFrameMixin:CreateContentFramesForSupportedTabs()
	for _tabType, tabData in pairs(self.tabDefinitions) do
		local hasDynamicContentFrame = IsTabSupported(tabData) and tabData.contentFrameTemplate ~= nil and tabData.contentFrameParentKey ~= nil;
		if hasDynamicContentFrame then
			tabData.contentFrame = CreateTabContentFrame(self, tabData.contentFrameTemplate, tabData.contentFrameParentKey);
		end
	end
end

function SocialUIFrameMixin:Reset()
	if not C_SocialUI.IsSystemEnabled() then
		HideUIPanel(self);
		return;
	end

	self:ResetTabs();
	self:TryHideActiveSideWindowForUnavailableTab();

	local deferredOpenTabType = self:ConsumeDeferredOpenTab();
	local canOpenDeferredTab = self:GetDataForAvailableTab(deferredOpenTabType) ~= nil;
	if canOpenDeferredTab then
		self:SelectTab(deferredOpenTabType);
	else
		self:SelectBestDefaultTab();
	end

	local deferredSideWindowType = self:ConsumeDeferredSideWindow();
	if deferredSideWindowType then
		self:ShowSideWindow(deferredSideWindowType);
	end

	self:TryShowTabHelpTips();
end

function SocialUIFrameMixin:CleanUp()
	self:HideActiveSideWindow();
	self:ClearAllTabs();
end

function SocialUIFrameMixin:ResetTabs()
	self:ClearAllTabs();
	self:RefreshTabs();
end

function SocialUIFrameMixin:ClearSelectedTab()
	self:SelectTab(nil);
end

function SocialUIFrameMixin:FilterAvailableTabData(sourceTabData)
	local availableTabs = {};
	for _tabType, tabData in pairs(sourceTabData) do
		if IsTabSupported(tabData) and tabData.IsAvailable() then
			table.insert(availableTabs, tabData);
		end
	end
	return availableTabs;
end

function SocialUIFrameMixin:SortTabData(sourceTabData)
	table.sort(sourceTabData, TabSort);
end

function SocialUIFrameMixin:GenerateAvailableTabData()
	local availableTabData = self:FilterAvailableTabData(self.tabDefinitions);
	self:SortTabData(availableTabData);
	return availableTabData;
end

local function SetUpNewTab(socialUIFrame, newTab, tabData, isFirstAcquire, previousTab)
	newTab:Initialize(tabData);
	newTab:SetID(tabData.tabType);
	if isFirstAcquire then
		newTab:SetScript("OnClick", function(tab)
			socialUIFrame:SelectTab(tab.tabData.tabType);
		end);
	end

	local isFirstTab = previousTab == nil;
	if isFirstTab then
		newTab:SetPoint("TOPLEFT", socialUIFrame, "TOPRIGHT", 0, -122);
	else
		newTab:SetPoint("TOPLEFT", previousTab, "BOTTOMLEFT", 0, -3);
	end
	newTab:Show();
end

function SocialUIFrameMixin:RefreshAvailableTabData()
	self.availableTabData = self:GenerateAvailableTabData();
end

function SocialUIFrameMixin:RefreshTabs()
	self:RefreshAvailableTabData();

	self.socialTabPool:ReleaseAll();

	local tabs = {};
	local previousTab;
	for _index, tabData in ipairs(self.availableTabData) do
		local newTab, isFirstAcquire = self.socialTabPool:Acquire();
		SetUpNewTab(self, newTab, tabData, isFirstAcquire, previousTab);
		table.insert(tabs, newTab);
		previousTab = newTab;
	end

	self.TabIndicators:SetUpTabs(tabs);
end

function SocialUIFrameMixin:ClearAllTabs()
	self:HideActiveTabHelpTips();
	self:ClearSelectedTab();
	self.socialTabPool:ReleaseAll();
	table.wipe(self.availableTabData);
end

function SocialUIFrameMixin:TryShowTabHelpTips()
	for tab in self:EnumerateTabs() do
		local helpTipInfo = tab.tabData.helpTipGenerator and tab.tabData.helpTipGenerator() or nil;
		if helpTipInfo then
			HelpTip:Show(self, helpTipInfo, tab);
			tab.activeHelpTipSystem = helpTipInfo.system;
		end
	end
end

function SocialUIFrameMixin:HideActiveTabHelpTips()
	for tab in self:EnumerateTabs() do
		if tab.activeHelpTipSystem then
			HelpTip:HideAllSystem(tab.activeHelpTipSystem);
			tab.activeHelpTipSystem = nil;
		end
	end
end

function SocialUIFrameMixin:EnumerateTabs()
	return self.socialTabPool:EnumerateActive();
end

function SocialUIFrameMixin:SetDeferredOpenTab(tabType)
	self.deferredOpenTabType = tabType;
end

function SocialUIFrameMixin:ConsumeDeferredOpenTab()
	local deferredOpenTabType = self.deferredOpenTabType;
	self.deferredOpenTabType = nil;
	return deferredOpenTabType;
end

function SocialUIFrameMixin:SetDeferredSideWindow(sideWindowType)
	self.deferredSideWindowType = sideWindowType;
end

function SocialUIFrameMixin:ConsumeDeferredSideWindow()
	local deferredSideWindowType = self.deferredSideWindowType;
	self.deferredSideWindowType = nil;
	return deferredSideWindowType;
end

function SocialUIFrameMixin:OnOpenToTabAndSideWindowRequested(tabType, sideWindowType)
	if self:IsShown() then
		self:SelectTab(tabType);
		self:ShowSideWindow(sideWindowType);
		return;
	end

	-- The deferred tab and side window will be consumed during the Reset() when showing the SocialUI
	self:SetDeferredOpenTab(tabType);
	self:SetDeferredSideWindow(sideWindowType);
	ToggleSocialUI();
end

function SocialUIFrameMixin:OnFeatureAvailabilityChanged()
	self:Reset();
end

function SocialUIFrameMixin:OnOpenToTabRequested(tabType)
	if self:IsShown() then
		self:SelectTab(tabType);
		return;
	end

	-- The deferred tab will be consumed during the Reset() when showing the SocialUI
	self:SetDeferredOpenTab(tabType);
	ToggleSocialUI();
end

function SocialUIFrameMixin:SelectBestDefaultTab()
	local bestDefaultTabType = self:GetBestDefaultTabType();
	self:SelectTab(bestDefaultTabType);
end

function SocialUIFrameMixin:GetBestDefaultTabType()
	local lastSelectedTabData = self:GetDataForAvailableTab(self.lastSelectedTabType);
	local canReturnToLastSelectedTab = (lastSelectedTabData ~= nil) and IsTabEnabled(lastSelectedTabData);
	if canReturnToLastSelectedTab then
		return self.lastSelectedTabType;
	end

	return self:GetFirstEnabledTabType();
end

function SocialUIFrameMixin:GetFirstEnabledTabType()
	for _index, tabData in ipairs(self.availableTabData) do
		if IsTabEnabled(tabData) then
			return tabData.tabType;
		end
	end

	return nil;
end

function SocialUIFrameMixin:ClearLastSelectedTab()
	self.lastSelectedTabType = nil;
end

function SocialUIFrameMixin:SelectTab(tabType)
	local isClearingSelectedTab = tabType == nil;
	local isRequestedTabAvailable = isClearingSelectedTab or (self:GetDataForAvailableTab(tabType) ~= nil);
	if not isRequestedTabAvailable then
		return;
	end

	local alreadySelected = self.selectedTab == tabType;
	if alreadySelected then
		return;
	end

	self.selectedTab = tabType;

	-- Our list of tabs is rebuilt pretty often (ex. when showing the UI, when a feature is enabled/disabled, etc.)
	-- Rebuilding (and closing the UI) clears out your selected tab, so we remember it here to auto select it afterwards
	local shouldRememberTabSelection = tabType ~= nil;
	if shouldRememberTabSelection then
		self.lastSelectedTabType = tabType;
	end

	self:OnNewTabSelected();
end

function SocialUIFrameMixin:OnNewTabSelected()
	self:RefreshContentFrame();
	self:RefreshVisuals();
	if InputUtil.IsGamepadUIEnabled() then
		self.footer:Refresh();
		self:RefreshSmartNavJumps();
		self:UpdateSmartNavFocus();
		self.TabIndicators:UpdateTabVisibility();
		if self.hasGamepadFocus then
			self:UpdateGamepadScrollTarget();
		end
	end
end

function SocialUIFrameMixin:RefreshContentFrame()
	local selectedTabData = self:GetSelectedTabData();

	local contentFrameSetupCallback = selectedTabData and selectedTabData.contentFrameSetupCallback;
	if contentFrameSetupCallback then
		contentFrameSetupCallback(selectedTabData);
	end

	local selectedContentFrame = selectedTabData and selectedTabData.contentFrame or nil;
	self:SetActiveContentFrame(selectedContentFrame);
end

function SocialUIFrameMixin:SetActiveContentFrame(targetContentFrame)
	for _tabType, tabData in pairs(self.tabDefinitions) do
		local entryContentFrame = tabData.contentFrame;
		if entryContentFrame then
			entryContentFrame:SetShown(entryContentFrame == targetContentFrame);
		end
	end
	self.activeContentFrame = targetContentFrame;
end

function SocialUIFrameMixin:RefreshTabStates()
	for tab in self:EnumerateTabs() do
		local tabType = tab.tabData and tab.tabData.tabType;
		local isSelected = tabType == self.selectedTab;
		tab:SetChecked(isSelected);

		if isSelected then
			self:ClearTabTypeGlowing(tabType);
		end

		local shouldTabGlow = self:IsTabTypeGlowing(tabType);
		tab:SetTabGlowAnimationPlaying(shouldTabGlow);
	end
end

function SocialUIFrameMixin:GetTabByType(tabType)
	for tab in self:EnumerateTabs() do
		if tab.tabData and tab.tabData.tabType == tabType then
			return tab;
		end
	end

	return nil;
end

function SocialUIFrameMixin:OnTabGlowRequested(tabType)
	local tabIsCurrentlySelected = tabType == self:GetSelectedTab();
	if tabIsCurrentlySelected then
		return;
	end

	self:SetTabTypeGlowing(tabType);

	local tab = self:GetTabByType(tabType);
	if not tab then
		return;
	end

	tab:SetTabGlowAnimationPlaying(true);
end

function SocialUIFrameMixin:SetTabTypeGlowing(tabType)
	self.glowingTabTypes[tabType] = true;
end

function SocialUIFrameMixin:ClearTabTypeGlowing(tabType)
	self.glowingTabTypes[tabType] = nil;
end

function SocialUIFrameMixin:ClearAllTabTypeGlowing()
	table.wipe(self.glowingTabTypes);
end

function SocialUIFrameMixin:IsTabTypeGlowing(tabType)
	return tabType and self.glowingTabTypes[tabType] or false;
end

function SocialUIFrameMixin:OnTabCounterRefreshRequested(tabType)
	local tab = self:GetTabByType(tabType);
	if not tab then
		return;
	end

	tab:RefreshCounter();
end

function SocialUIFrameMixin:RefreshVisuals()
	self:RefreshTabStates();
	self:RefreshTitle();
end

function SocialUIFrameMixin:RefreshTitle()
	local title = self:GetTitleForSelectedTab() or "";
	self:SetTitle(title);
end

function SocialUIFrameMixin:GetTitleForSelectedTab()
	local selectedTabData = self:GetSelectedTabData();
	return selectedTabData and selectedTabData.tabName or nil;
end

function SocialUIFrameMixin:GetSelectedTabData()
	local selectedTab = self:GetSelectedTab();
	return self:GetDataForAvailableTab(selectedTab);
end

function SocialUIFrameMixin:GetSelectedTab()
	return self.selectedTab;
end

function SocialUIFrameMixin:GetDataForAvailableTab(tabType)
	if not tabType or not self.availableTabData then
		return nil;
	end

	for _index, tabData in ipairs(self.availableTabData) do
		if tabData.tabType == tabType then
			return tabData;
		end
	end

	return nil;
end

function SocialUIFrameMixin:GetTabDefinition(tabType)
	return self.tabDefinitions[tabType];
end

-- Side windows are child frames that are anchored to and displayed on the side of the Social UI frame
-- To prevent these windows overlapping with other UIs, we need to dynamically adjust the width of the Social UI depending on which side window is currently visible
function SocialUIFrameMixin:InitializeSideWindows()
	self.activeSideWindowType = nil;
	-- These side windows live in XML because they exist independently of any tabs
	self.sideWindowFrames =
	{
		[SocialUISideWindowType.BattleNetBroadcastFrame] = self.BattleNetBroadcastFrame,
		[SocialUISideWindowType.BattleNetUnavailableNoticeFrame] = self.BattleNetUnavailableNoticeFrame,
		[SocialUISideWindowType.IgnoreListFrame] = self.IgnoreListFrame,
	};

	-- Remembers which tab a side window comes from, so we can close the side window if that tab goes away
	-- Some side windows aren't linked to a specific tab and will not appear here (Ex. IgnoreListFrame, BattleNetBroadcastFrame, etc.)
	self.sideWindowToLinkedTabType = {};

	-- Create and register side windows defined by supported tabs
	for _tabType, tabData in pairs(self.tabDefinitions) do
		local hasSideWindows = IsTabSupported(tabData) and tabData.sideWindows ~= nil;
		if hasSideWindows then
			for _index, sideWindowDefinition in ipairs(tabData.sideWindows) do
				local sideWindowFrame = CreateSideWindowFrame(self, sideWindowDefinition.template, sideWindowDefinition.key);
				self.sideWindowFrames[sideWindowDefinition.sideWindowType] = sideWindowFrame;
				self.sideWindowToLinkedTabType[sideWindowDefinition.sideWindowType] = tabData.tabType;
			end
		end
	end

	self:InitializeSideWindowAnchoring();
end

function SocialUIFrameMixin:InitializeSideWindowAnchoring()
	local tabColumnWidth = SocialUIFrameMixin:GetTabColumnWidth();
	for _sideWindowType, sideWindowFrame in pairs(self.sideWindowFrames) do
		sideWindowFrame:ClearAllPoints();
		sideWindowFrame:SetPoint("TOPLEFT", self, "TOPRIGHT", tabColumnWidth, 0);
	end
end

function SocialUIFrameMixin:TryInitializeUIPanelRegistration()
	if not GameStateUsesUIPanelManager() then
		return;
	end

	local attributes =
	{
		area = "left",
		pushable = 1,
		whileDead = 1,
		extraWidthFunc = SocialUIFrameMixin.GetPanelExtraWidth,
	};
	RegisterUIPanel(self, attributes);
end

function SocialUIFrameMixin:GetSideWindowFrame(sideWindowType)
	return self.sideWindowFrames[sideWindowType];
end

function SocialUIFrameMixin:OnSideWindowShowRequested(sideWindowType)
	self:ShowSideWindow(sideWindowType);
end

function SocialUIFrameMixin:OnSideWindowHideRequested(_sideWindowType)
	-- We currently only support one active side window at a time
	self:HideActiveSideWindow();
end

function SocialUIFrameMixin:ShowSideWindow(sideWindowTypeToShow)
	local sideWindowAlreadyShown = self.activeSideWindowType == sideWindowTypeToShow;
	if sideWindowAlreadyShown then
		return;
	end

	if not self:IsSideWindowAllowedByLinkedTab(sideWindowTypeToShow) then
		return;
	end

	local sideWindowFrameToShow = self:GetSideWindowFrame(sideWindowTypeToShow);
	if not sideWindowFrameToShow then
		return;
	end

	self:HideActiveSideWindow();

	self.activeSideWindowType = sideWindowTypeToShow;
	sideWindowFrameToShow:Show();
	self:TryRefreshUIPanelPositions();
end

function SocialUIFrameMixin:IsSideWindowAllowedByLinkedTab(sideWindowType)
	local linkedTabType = self.sideWindowToLinkedTabType[sideWindowType];
	local sideWindowLinkedToATab = linkedTabType ~= nil;
	-- Some side windows aren't linked to a specific tab so they will always be allowed (Ex. IgnoreListFrame, BattleNetBroadcastFrame, etc.)
	if not sideWindowLinkedToATab then
		return true;
	end

	local linkedTabIsAvailableInSocialUI = self:GetDataForAvailableTab(linkedTabType) ~= nil;
	return linkedTabIsAvailableInSocialUI;
end

-- A tab's side window shouldn't stick around if the linked tab disappears, ex. the feature is shut off by its kill switch
function SocialUIFrameMixin:TryHideActiveSideWindowForUnavailableTab()
	local activeSideWindowType = self:GetActiveSideWindowType();
	if not self:IsSideWindowAllowedByLinkedTab(activeSideWindowType) then
		self:HideActiveSideWindow();
	end
end

function SocialUIFrameMixin:HideActiveSideWindow()
	local noSideWindowActive = not self.activeSideWindowType;
	if noSideWindowActive then
		return;
	end

	local activeSideWindowFrame = self:GetSideWindowFrame(self.activeSideWindowType);
	if activeSideWindowFrame then
		activeSideWindowFrame:Hide();
	end

	self.activeSideWindowType = nil;
	self:TryRefreshUIPanelPositions();
end

function SocialUIFrameMixin:GetActiveSideWindowType()
	return self.activeSideWindowType;
end

-- The Social UI has various side windows that may affect its overall width, such as the Ignore List
-- We need to dynamically adjust the width of the Social UI depending on which side windows are currently visible
function SocialUIFrameMixin:TryRefreshUIPanelPositions()
	if not GameStateUsesUIPanelManager() then
		return;
	end

	UpdateUIPanelPositions(self);
end

function SocialUIFrameMixin:GetPanelExtraWidth()
	return self:GetTabColumnWidth() + self:GetActiveSideWindowWidth();
end

function SocialUIFrameMixin:GetTabColumnWidth()
	local tabWidth, _tabHeight = SocialUITabMixin.CalculateTabSizeBasedOnTabArt();
	local padding = 7;
	return tabWidth + padding;
end

function SocialUIFrameMixin:GetActiveSideWindowWidth()
	local activeSideWindowType = self:GetActiveSideWindowType();
	if not activeSideWindowType then
		return 0;
	end

	local activeSideWindowFrame = self:GetSideWindowFrame(activeSideWindowType);
	if not activeSideWindowFrame then
		return 0;
	end

	return activeSideWindowFrame:GetWidth();
end

function SocialUIFrameMixin:FocusGamepad()
	self.hasGamepadFocus = true;
	self.TabIndicators:Show();
	self.footer:ShowAndActivateBindings();
	if self.gamepadFocusTab ~= self:GetSelectedTab() then
		self:UpdateSmartNavFocus();
	end
	self:UpdateGamepadScrollTarget();
end

function SocialUIFrameMixin:UnfocusGamepad()
	self.hasGamepadFocus = false;
	self.pendingSmartNavFocusScrollBox = nil;
	self.footer:HideAndDeactivateBindings();
	self.TabIndicators:Hide();
	self:UpdateGamepadScrollTarget();
end

function SocialUIFrameMixin:UpdateGamepadScrollTarget()
	local tabData = self.hasGamepadFocus and self:GetSelectedTabData() or nil;
	local contentFrame = tabData and tabData.contentFrame;
	local scrollBox = contentFrame and contentFrame.ScrollBox;
	SmartNavigation:SetScrollFrameForFrame(self, scrollBox);

	local scrollBar = scrollBox and contentFrame.ScrollBar;
	if scrollBar then
		GamepadScrollBarHint:SetOwner(scrollBar.Track.Thumb, "CENTER");
		GamepadScrollBarHint:Show();
	else
		GamepadScrollBarHint:Hide();
	end
end

function SocialUIFrameMixin:FindFirstSocialScrollBoxButton(scrollBox, includeHeader)
	if not scrollBox then
		return nil;
	end

	return scrollBox:FindFrameByPredicate(function(button, elementData)
		if not elementData or not button:IsVisible() or not button:IsObjectType("Button") then
			return false;
		end

		local data = elementData.GetData and elementData:GetData() or elementData;
		return data and not data.isSpacer and (includeHeader or not data.headerText);
	end);
end

function SocialUIFrameMixin:UpdateSmartNavFocus()
	self.gamepadFocusTab = nil;
	self.pendingSmartNavFocusScrollBox = nil;
	if not self.hasGamepadFocus or not self:IsShown() then
		return;
	end

	local tabData = self:GetSelectedTabData();
	local contentFrame = tabData and tabData.contentFrame;
	local scrollBox = contentFrame and contentFrame.ScrollBox;
	local firstButton = self:FindFirstSocialScrollBoxButton(scrollBox, false);

	if firstButton then
		SmartNavigation:SelectButton(firstButton);
		self.gamepadFocusTab = self:GetSelectedTab();
		return;
	end

	local statusDropdown = self.BattleNetBar.ControlsContainer.OnlineStatusDropdown;
	SmartNavigation:SelectButton(statusDropdown);
	self.pendingSmartNavFocusScrollBox = scrollBox;
	if not scrollBox then
		self.gamepadFocusTab = self:GetSelectedTab();
	end
end

function SocialUIFrameMixin:OnGamepadScrollBoxDataRangeChanged(scrollBox)
	self:RefreshSmartNavJumps();
	if self.pendingSmartNavFocusScrollBox ~= scrollBox then
		return;
	end

	local tabData = self:GetSelectedTabData();
	local contentFrame = tabData and tabData.contentFrame;
	local statusDropdown = self.BattleNetBar.ControlsContainer.OnlineStatusDropdown;
	if not contentFrame or contentFrame.ScrollBox ~= scrollBox or SmartNavigation:GetCurrentButton() ~= statusDropdown then
		self.pendingSmartNavFocusScrollBox = nil;
		return;
	end

	self:UpdateSmartNavFocus();
end

function SocialUIFrameMixin:AdjustFilterBarForContentFrame(frame)
	local filterBar = frame.FilterBar;
	local searchBar = filterBar.SearchBar;
	searchBar.GetScaledDesiredHeight = function()
		return 27;
	end;
	TextSizeManager:UpdateObject(searchBar);
	searchBar:ClearAllPoints();
	searchBar:SetPoint("LEFT", filterBar, "LEFT", 40, 0);
	searchBar:SetPoint("RIGHT", filterBar.SearchFilterDropdown, "LEFT", -40, 0);
	filterBar.SearchFilterDropdown:SetWidth(120);
end

function SocialUIFrameMixin:RefreshSmartNavJumpsForContentFrame(frame)
	if not frame then
		return;
	end

	local scrollBox = frame.ScrollBox;
	local onlineStatusDropdown = self.BattleNetBar.ControlsContainer.OnlineStatusDropdown;

	-- Clear previous overrides
	for _, button in ipairs(scrollBox:GetFrames()) do
		SmartNavigation_ClearJumpNavigationOverrides(button);
	end

	local selectedTabData = self:GetSelectedTabData();
	if not selectedTabData or selectedTabData.contentFrame ~= frame or not scrollBox:IsVisible() then
		return;
	end

	local firstFrame = self:FindFirstSocialScrollBoxButton(scrollBox, true);
	if firstFrame then
		SmartNavigation_AddBidirectionalJumpNavigationOverride(firstFrame, SMART_NAV_INPUT_DIRECTION.UP, onlineStatusDropdown);
	end
end

function SocialUIFrameMixin:RefreshSmartNavJumps()
	local onlineStatusDropdown = self.BattleNetBar.ControlsContainer.OnlineStatusDropdown;
	SmartNavigation_ClearJumpNavigationOverridesInDirection(onlineStatusDropdown, SMART_NAV_INPUT_DIRECTION.DOWN);

	self:RefreshSmartNavJumpsForContentFrame(self.FriendsList);
	self:RefreshSmartNavJumpsForContentFrame(self.RecentAlliesList);
	self:RefreshSmartNavJumpsForContentFrame(self.FriendRequestsList);
end

function SocialUIFrameMixin:SetUpActionButtonPrompts(selectPrompt)
	local actionTabTypes = { SocialUITabType.Friends, SocialUITabType.RecentAllies, SocialUITabType.FriendRequests };
	local actionButtonsByTab = {};
	for _, tabType in ipairs(actionTabTypes) do
		local tabData = self.tabDefinitions[tabType];
		local contentFrame = tabData and tabData.contentFrame;
		actionButtonsByTab[tabType] = contentFrame and contentFrame.ActionButton;
	end

	local function GetCurrentActionButton()
		return actionButtonsByTab[self:GetSelectedTab()];
	end

	local function CanUseActionButton()
		local actionButton = GetCurrentActionButton();
		return actionButton and actionButton:IsShown() and actionButton:IsEnabled();
	end

	local function ClickActionButton()
		local actionButton = GetCurrentActionButton();
		if actionButton then
			actionButton:Click();
		end
	end

	local function ActivateCurrentButton()
		local button = SmartNavigation:GetCurrentButton();
		if not button then
			return;
		end

		if button.buttonContext == "ButtonContext_FriendRequestsListCard"  then
			button.AcceptButton:Click();
		elseif button.OpenMenu then
			button:OpenMenu();
		elseif button.Click then
			button:Click();
		end
	end
	local holdTime = 0.5;
	local actionInputFrame = CreateFrame("Frame", nil, self);
	actionInputFrame:Hide();
	local actionInputPrompt = selectPrompt:AddCustomPromptBinding({
		frame = actionInputFrame,
		visibilityType = PromptedBindingMixin.VISIBILITY_TYPE.NEVER,
	});
	selectPrompt:AddCustomPromptHoldFunction(actionInputPrompt, {
		holdTime = holdTime,
		onTap = ActivateCurrentButton,
		onHeld = ClickActionButton,
	});

	for _, tabType in ipairs(actionTabTypes) do
		local actionButton = actionButtonsByTab[tabType];
		if actionButton then
			local actionIcon = GamepadMode.AddGamepadIconToButton(actionButton, GAMEPAD_FACE_BOTTOM, { isHoldAction = true });
			local actionHoldPrompt = selectPrompt:AddCustomPromptBinding({
				frame = actionIcon,
				visibilityType = function()
					if GetCurrentActionButton() == actionButton and CanUseActionButton() then
						return PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE;
					end

					return PromptedBindingMixin.VISIBILITY_TYPE.NEVER;
				end,
			});

			GamepadMode.UpdateGamepadIconAnchor(actionIcon, { anchorIconToButton = true, });

			selectPrompt:AddCustomPromptHoldFunction(actionHoldPrompt, {
				holdTime = holdTime,
			});

			SmartNavigation_MarkFrameIgnored(actionButton);
		end
	end
end

function SocialUIFrameMixin:SetUpFilterPrompts()
	local function GetActiveFilterBar()
		local tabData = self:GetSelectedTabData();
		local contentFrame = tabData and tabData.contentFrame;
		return contentFrame and contentFrame.FilterBar;
	end

	local function OpenFilter()
		local filterBar = GetActiveFilterBar();
		if filterBar and filterBar:IsVisible() then
			filterBar.SearchFilterDropdown:OpenMenu();
		end
	end

	local function SetSearchFocus()
		local filterBar = GetActiveFilterBar();

		if filterBar and filterBar:IsVisible() then
			filterBar.SearchBar:SetFocus();
		end
	end

	local openFilter = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_RIGHT, OpenFilter, nil);
	openFilter:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.NEVER);

	local focusSearch = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_LEFT, SetSearchFocus, nil);
	focusSearch:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.NEVER);

	for _, contentFrame in ipairs({ self.FriendsList, self.RecentAlliesList }) do
		local filterBar = contentFrame.FilterBar;

		openFilter:AddCustomPromptBinding({
			frame = filterBar.DropdownIcon,
			conditions = function()
				return filterBar:IsVisible();
			end,
			visibilityType = PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE,
		});

		focusSearch:AddCustomPromptBinding({
			frame = filterBar.SearchBoxIcon,
			conditions = function()
				return filterBar:IsVisible();
			end,
			visibilityType = PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE,
		});

		SmartNavigation_MarkFrameIgnored(filterBar.SearchBar);
		SmartNavigation_MarkFrameIgnored(filterBar.SearchFilterDropdown);
	end

	return openFilter, focusSearch;
end

function SocialUIFrameMixin:SetUpSearchForContentFrame(frame)
	if not frame then
		return;
	end

	local searchBox = frame.FilterBar.SearchBar;

	local function ClearText()
		searchBox:SetText("");
		searchBox:SetFocus();
	end

	local function HasText()
		return searchBox:GetText() ~= "";
	end

	local function ClearSearchFocus()
		searchBox:ClearFocus();
	end

	local clear = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, ClearText, NARRATION_OBJECT_CLEAR_BUTTON);
	clear:AddCondition(HasText);

	local back = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, ClearSearchFocus, BACK);

	local unfocusSearch = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_LEFT, ClearSearchFocus, nil);
	unfocusSearch:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.NEVER);

	local search = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, ClearSearchFocus, SEARCH);
	search:AddCondition(HasText);

	local searchBoxFooter = GamepadSharedUtility.CreatePromptedBindingFooter(searchBox, "SocialUISearchBoxFooter");
	searchBoxFooter:AddPromptedBinding(search);
	searchBoxFooter:AddPromptedBinding(clear);
	searchBoxFooter:AddPromptedBinding(back);
	searchBoxFooter:AddPromptedBinding(unfocusSearch);
	searchBoxFooter:Finalize();
	searchBoxFooter.inputLegend:SetFrameStrata("HIGH");

	local function OnSearchBoxFocusGained()
		GamepadMode.FrameControlsManager:SuspendFrame();
		GamepadMode.FrameControlsManager:FrameShown(searchBox);
		searchBoxFooter:ShowAndActivateBindings();
	end

	local function OnSearchBoxFocusLost()
		searchBoxFooter:HideAndDeactivateBindings();
		GamepadMode.FrameControlsManager:FrameHidden(searchBox);
		GamepadMode.FrameControlsManager:UnsuspendFrame();
	end

	local function OnTextChanged()
		searchBoxFooter:Refresh();
	end

	SmartNavigation_MarkFrameIgnored(searchBox.clearButton);
	searchBox:HookScript("OnEditFocusGained", OnSearchBoxFocusGained);
	searchBox:HookScript("OnEditFocusLost", OnSearchBoxFocusLost);
	searchBox:HookScript("OnTextChanged", OnTextChanged);
end

function SocialUIFrameMixin:SetUpSearch()
	self:SetUpSearchForContentFrame(self.FriendsList);
	self:SetUpSearchForContentFrame(self.RecentAlliesList);
end

function SocialUIFrameMixin:SetUpFooter()
	local function GetCurrentPartyButton()
		local button = SmartNavigation:GetCurrentButton();
		return button and button.PartyButton;
	end

	local function CanInviteFriend()
		local partyButton = GetCurrentPartyButton();
		return partyButton and partyButton:IsShown() and partyButton:IsEnabled();
	end

	local function InviteFriend()
		local partyButton = GetCurrentPartyButton();
		if partyButton then
			partyButton:Click();
		end
	end

	local function IgnoreInvite()
		local button = SmartNavigation:GetCurrentButton();
		if button and button.DeclineButton then
			button.DeclineButton:OpenMenu();
		end
	end

	self.footer = GamepadSharedUtility.CreatePromptedBindingFooter(self, "SocialUIFooter");
	local selectPrompt = self.footer:AddStandardSelectPrompt();
	selectPrompt:SetLabelFunction(function()
		if SmartNavigation:GetCurrentButtonContext() == "ButtonContext_FriendRequestsListCard" then
			return ACCEPT;
		elseif SmartNavigation:GetCurrentButtonContext() == "ButtonContext_FriendsListCard" then
			return CONTEXT_ACTION_LABEL_MORE_ACTIONS;
		end

		return ACTION_LABEL_SELECT;
	end);
	self:SetUpActionButtonPrompts(selectPrompt);

	local inviteFriend = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, InviteFriend, PARTY_INVITE);
	inviteFriend:AddCondition(CanInviteFriend);
	inviteFriend:AddButtonContext("ButtonContext_FriendsListCard");

	local ignoreInvite = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, "IgnoreInvitePromptedBinding");
	ignoreInvite:AddFooterBinding({
		label = DECLINE,
		buttonContexts = "ButtonContext_FriendRequestsListCard",
		visibilityType = PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE,
	});
	ignoreInvite:AddFooterFunction({
		bindingFunctions = IgnoreInvite,
	})

	local openFilter, focusSearch = self:SetUpFilterPrompts();
	self.footer:AddStandardBackPrompt(FRAME_ACTION_CLOSE);
	self.footer:AddPromptedBinding(inviteFriend);
	self.footer:AddPromptedBinding(ignoreInvite);
	self.footer:AddPromptedBinding(openFilter);
	self.footer:AddPromptedBinding(focusSearch);
	self.footer:Finalize();
end

function SocialUIFrameMixin:SetUpScrollBoxCallbacks()
	for _, tabData in pairs(self.tabDefinitions) do
		local contentFrame = tabData.contentFrame;
		local scrollBox = contentFrame and contentFrame.ScrollBox;
		if scrollBox then
			scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnAcquiredFrame, function(_, frame)
				SmartNavigation_ClearJumpNavigationOverrides(frame);
			end, self);
			scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, function()
				self:OnGamepadScrollBoxDataRangeChanged(scrollBox);
			end, self);
		end
	end
end

function SocialUIFrameMixin:SetUpGamepad()
	self:SetUpFooter();
	self:SetUpSearch();
	self:SetUpScrollBoxCallbacks();
end

function SocialUIFrameMixin:InitializeGamepad()
	-- Hide unnecessary SocialUIFrame elements for gamepad.
	SocialUIFrameCloseButton:Hide();
	
	local bnetControls = self.BattleNetBar.ControlsContainer;
	bnetControls.BattleNetBackground:ClearAllPoints();
	bnetControls.BattleNetBackground:SetPoint("LEFT", bnetControls.OnlineStatusDropdown, "LEFT", 0, 0);
	bnetControls.BattleNetBackground:SetPoint("RIGHT", bnetControls.BattleNetMenuButton, "LEFT", 26, 0);

	bnetControls.OnlineStatusDropdown:SetSize(54, 28);
	bnetControls.OnlineStatusDropdown.Arrow:SetSize(28, 28);

	self:AdjustFilterBarForContentFrame(self.FriendsList);
	self:AdjustFilterBarForContentFrame(self.RecentAlliesList);
end

function SocialUIFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetUpGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
end
