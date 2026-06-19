local function OnlyAvailableInGame()
	return not C_Glue.IsOnGlueScreen();
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
	contentFrame:SetPoint("BOTTOMRIGHT", socialUIFrame.Bg);
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
	sideWindow:SetPoint("TOPLEFT", socialUIFrame, "TOPRIGHT", 45, 0);
	sideWindow:Hide();
	socialUIFrame[parentKey] = sideWindow;
	return sideWindow;
end

local function IsTabSupported(tabData)
	return tabData.IsSupported == nil or tabData.IsSupported();
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
			contentFrameTemplate = "QuickJoinFrameSocialTemplate",
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
			--contentFrameSetupCallback = SocialUIContactsFrameInitializeAADC,
		},
		[SocialUITabType.RecruitAFriend] =
		{
			tabOrder = 5,
			tabType = SocialUITabType.RecruitAFriend,
			socialSystem = Enum.SocialSystemType.RecruitAFriend,
			tabName = SOCIAL_UI_RECRUIT_A_FRIEND_TAB_NAME,
			iconAtlas = "friends-icon-tab-recruitFriends",
			iconInactiveAtlas = "friends-icon-tab-recruitFriends-inactive",
			contentFrame = self.RecruitAFriendFrame,
			IsSupported = C_RecruitAFriend.IsSystemSupported,
			IsAvailable = C_RecruitAFriend.IsSystemEnabled,
			contentFrameSetupCallback = RecruitAFriendFrameSocialInitializeAADC,
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
				{ sideWindowType = SocialUISideWindowType.RaidInfo, template = "SocialUIRaidInfoFrameTemplate", key = "RaidInfoFrame" },
			},
			contentFrameTemplate = "RaidFrameSocialTemplate",
			contentFrameParentKey = "RaidFrame",
			IsAvailable = OnlyAvailableInGame,
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

	local deferredOpenTabType = self:ConsumeDeferredOpenTab();
	if deferredOpenTabType then
		self:SelectTab(deferredOpenTabType);
	else
		self:SelectFirstAvailableTab();
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

	local previousTab;
	for _index, tabData in ipairs(self.availableTabData) do
		local newTab, isFirstAcquire = self.socialTabPool:Acquire();
		SetUpNewTab(self, newTab, tabData, isFirstAcquire, previousTab);
		previousTab = newTab;
	end
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

function SocialUIFrameMixin:SelectFirstAvailableTab()
	local firstAvailableTabType = #self.availableTabData > 0 and self.availableTabData[1].tabType or nil;
	self:SelectTab(firstAvailableTabType);
end

function SocialUIFrameMixin:SelectTab(tabType)
	local alreadySelected = self.selectedTab == tabType;
	if alreadySelected then
		return;
	end

	self.selectedTab = tabType;
	self:OnNewTabSelected();
end

function SocialUIFrameMixin:OnNewTabSelected()
	self:RefreshContentFrame();
	self:RefreshVisuals();
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
		[SocialUISideWindowType.RaidInfo] = self.RaidInfoFrame,
	};

	-- Create and register side windows defined by supported tabs
	for _tabType, tabData in pairs(self.tabDefinitions) do
		local hasSideWindows = IsTabSupported(tabData) and tabData.sideWindows ~= nil;
		if hasSideWindows then
			for _index, sideWindowDefinition in ipairs(tabData.sideWindows) do
				local sideWindowFrame = CreateSideWindowFrame(self, sideWindowDefinition.template, sideWindowDefinition.key);
				self.sideWindowFrames[sideWindowDefinition.sideWindowType] = sideWindowFrame;
			end
		end
	end
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

	local sideWindowFrameToShow = self:GetSideWindowFrame(sideWindowTypeToShow);
	if not sideWindowFrameToShow then
		return;
	end

	self:HideActiveSideWindow();

	self.activeSideWindowType = sideWindowTypeToShow;
	sideWindowFrameToShow:Show();
	self:TryRefreshUIPanelWidth();
end

function SocialUIFrameMixin:HideActiveSideWindow()
	local noSideWindowActive = not self.activeSideWindowType;
	if noSideWindowActive then
		return;
	end

	local sideWindowFrame = self:GetSideWindowFrame(self.activeSideWindowType);
	if sideWindowFrame then
		sideWindowFrame:Hide();
	end

	self.activeSideWindowType = nil;
	self:TryRefreshUIPanelWidth();
end

function SocialUIFrameMixin:GetActiveSideWindowType()
	return self.activeSideWindowType;
end

function SocialUIFrameMixin:TryRefreshUIPanelWidth()
	local uiPanelManagerIsUsed = not C_Glue.IsOnGlueScreen();
	if not uiPanelManagerIsUsed then
		return;
	end

	local bestWidth = self:GetBestUIPanelWidth();
	SetUIPanelAttribute(self, "width", bestWidth);
	UpdateUIPanelPositions(self);
end

-- The Social UI has various side windows that may affect its overall width, such as the Ignore List
-- We need to dynamically adjust the width of the Social UI depending on which side windows are currently visible
function SocialUIFrameMixin:GetBestUIPanelWidth()
	local activeSideWindowType = self:GetActiveSideWindowType();
	if not activeSideWindowType then
		return self.baseUIPanelWidth;
	end

	local sideWindowFrame = self:GetSideWindowFrame(activeSideWindowType);
	if not sideWindowFrame then
		return self.baseUIPanelWidth;
	end

	return self.baseUIPanelWidth + sideWindowFrame:GetWidth();
end
