SocialUIActionButtonMixin = {};

function SocialUIActionButtonMixin:OnEnter()
	self:TryShowTooltip();
end

function SocialUIActionButtonMixin:TryShowTooltip()
	if not self:IsEnabled() then
		self:ShowDisabledTooltip();
		return;
	end

	self:ShowTooltip();
end

function SocialUIActionButtonMixin:ShowDisabledTooltip()
	-- Optionally override in your mixin
end

function SocialUIActionButtonMixin:ShowTooltip()
	-- Optionally override in your mixin
end

function SocialUIActionButtonMixin:OnLeave()
	self:TryHideTooltip();
end

function SocialUIActionButtonMixin:OnClick(...)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:PerformClickAction(...);
end

function SocialUIActionButtonMixin:PerformClickAction(...)
	-- Optionally override in your mixin
end

function SocialUIActionButtonMixin:TryHideTooltip()
	local tooltip = GetAppropriateTooltip();
	if tooltip:IsOwned(self) then
		tooltip:Hide();
	end
end

function SocialUIActionButtonMixin:RefreshEnabledState()
	local isEnabled = self:IsActionEnabled();
	self:SetEnabled(isEnabled);
end

function SocialUIActionButtonMixin:IsActionEnabled()
	-- Optionally override in your mixin
	return true;
end

SocialUIAddFriendButtonMixin = CreateFromMixins(SocialUIActionButtonMixin);

function SocialUIAddFriendButtonMixin:IsActionEnabled()
	local isFriendsEnabled = not C_SocialRestrictions.IsFriendsDisabled();
	return isFriendsEnabled;
end

function SocialUIAddFriendButtonMixin:ShowDisabledTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddErrorLine(tooltip, ADDING_FRIENDS_DISABLED);
	tooltip:Show();
end

function SocialUIAddFriendButtonMixin:PerformClickAction(...)
	AddFriendFrame_Show();
end

SocialUISearchBoxMixin = {};

local function GetOwningSocialViewForSearchBox(searchBox)
	local filterBar = searchBox:GetParent();
	return filterBar and filterBar:GetParent() or nil;
end

local function GetFilterInfoForSearchBox(searchBox)
	local filterBar = searchBox:GetParent();
	local filterDropdown = filterBar and filterBar.SearchFilterDropdown;
	return filterDropdown and filterDropdown:GetSelectionData() or nil;
end

function SocialUISearchBoxMixin:OnLoad()
	SearchBoxTemplate_OnLoad(self);
	self:InitializeUserScaledFontSystem();
end

function SocialUISearchBoxMixin:OnEnterPressed()
	local socialView = GetOwningSocialViewForSearchBox(self);
	if socialView and socialView.OnSearchEnterPressed then
		socialView:OnSearchEnterPressed(self:GetText());
		return;
	end

	EditBox_ClearFocus(self);
end

function SocialUISearchBoxMixin:InitializeUserScaledFontSystem()
	UserScaledElementMixin.OnLoad_UserScaledElement(self);

	self:SetFontObject("UserScaledFontGameHighlight");
	self:SetJustifyH("LEFT");

	self.Instructions:SetFontObject("UserScaledFontGameDisable");
	self.Instructions:SetMaxLines(1);
end

SocialUIOnlineSearchFilterDropdownMixin = {};

function SocialUIOnlineSearchFilterDropdownMixin:OnLoad()
	WowStyle1FilterDropdownMixin.OnLoad(self);
	self:InitializeUserScaledFontSystem();

	self:SetupMenu(function(dropdown, rootDescription)
		local socialView = self:GetSocialView();
		if socialView then
			if socialView.SetupStatusFilterDropdown then
				local statusDescription = rootDescription:CreateButton(SOCIAL_FILTER_DROPDOWN_STATUS);
				socialView:SetupStatusFilterDropdown(dropdown, statusDescription);
			end

			if socialView.SetupTagsFilterDropdown then
				local tagsDescription = rootDescription:CreateButton(SOCIAL_FILTER_DROPDOWN_TAGS);
				socialView:SetupTagsFilterDropdown(dropdown, tagsDescription);
			end
		end
	end);
end

function SocialUIOnlineSearchFilterDropdownMixin:SetSocialView(view)
	self.socialView = view;
end

function SocialUIOnlineSearchFilterDropdownMixin:GetSocialView()
	return self.socialView;
end

function SocialUIOnlineSearchFilterDropdownMixin:InitializeUserScaledFontSystem()
	UserScaledElementMixin.OnLoad_UserScaledElement(self);

	self.Text:ClearAllPoints();
	self.Text:SetPoint("CENTER", self, "CENTER", 0, 0);
end

SocialUIContactsFrameMixin = {};

function SocialUIContactsFrameMixin:SetFilterBarShown(shown)
	self.FilterBar:SetShown(shown);
	self.TopDivider:ClearAllPoints();
	if shown then
		self.TopDivider:SetPoint("TOPLEFT", self.FilterBar, "BOTTOMLEFT", 5, -3);
		self.TopDivider:SetPoint("TOPRIGHT", self.FilterBar, "BOTTOMRIGHT", -5, -3);
	else
		self.TopDivider:SetPoint("TOPLEFT", self, "TOPLEFT", 5, -14);
		self.TopDivider:SetPoint("TOPRIGHT", self, "TOPRIGHT", -5, -14);
	end
end

function SocialUIContactsFrameMixin:RefreshActionButtonEnabledState()
	self.ActionButton:RefreshEnabledState();
end

function SocialUIContactsFrameMixin:SetLoadingSpinnerShown(shown)
	if not self.FriendsDisabledText:IsShown() then
		self.LoadingSpinner:SetShown(shown);

		self.ScrollBox:SetShown(not shown);
		self.ScrollBar:SetShown(not shown);
	end
end

function SocialUIContactsFrameInitializeAADC(tabData)
	local frame = tabData.contentFrame;
	if C_SocialRestrictions.IsFriendsDisabled() then
		frame.ScrollBox:Hide();
		frame.ScrollBar:Hide();
		frame.FriendsDisabledText:SetText(SOCIAL_TAB_UNAVAILABLE:format(tabData.tabName));
		frame.FriendsDisabledText:Show();
	else
		frame.ScrollBox:Show();
		frame.ScrollBar:Show();
		frame.FriendsDisabledText:Hide();
	end
end

SocialUIScrollableHeaderMixin = {};

function SocialUIScrollableHeaderMixin:OnLoad()
	UserScaledElementMixin.OnLoad_UserScaledElement(self);
	ListHeaderMixin.OnLoad(self);
end

function SocialUIScrollableHeaderMixin:Initialize(node)
	local nodeData = node:GetData();
	self:SetText(nodeData and nodeData.headerText or "");
	self:UpdateCollapsedState(node:IsCollapsed());
end

function SocialUIScrollableHeaderMixin:SetText(text)
	self.ButtonText:SetText(text);
end

SocialCardPresenceHolderMixin = {};

function SocialCardPresenceHolderMixin:SetPresence(presenceType)
	local icon = SocialUIUtil.GetIconForPresenceType(presenceType);
	self.PresenceIcon:SetAtlas(icon);
end

SocialCardActionButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function SocialCardActionButtonMixin:OnLoad()
	self:SetUpDisplacedRegions();
end

function SocialCardActionButtonMixin:SetUpDisplacedRegions()
	local displaceX, displaceY = 1, -1;
	self:SetDisplacedRegions(displaceX, displaceY, self.ActionIcon);
end

function SocialCardActionButtonMixin:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);
	self:TryShowTooltip();
end

function SocialCardActionButtonMixin:TryShowTooltip()
	self:ShowTooltip();
end

function SocialCardActionButtonMixin:ShowTooltip()
	-- Optionally override in your mixin
end

function SocialCardActionButtonMixin:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);
	self:TryHideTooltip();
end

function SocialCardActionButtonMixin:OnMouseDown()
	ButtonStateBehaviorMixin.OnMouseDown(self);
end

function SocialCardActionButtonMixin:OnMouseUp()
	ButtonStateBehaviorMixin.OnMouseUp(self);
end

function SocialCardActionButtonMixin:OnEnable()
	ButtonStateBehaviorMixin.OnEnable(self);
end

function SocialCardActionButtonMixin:OnDisable()
	ButtonStateBehaviorMixin.OnDisable(self);
end

function SocialCardActionButtonMixin:TryHideTooltip()
	local tooltip = GetAppropriateTooltip();
	if tooltip:IsOwned(self) then
		tooltip:Hide();
	end
end

function SocialCardActionButtonMixin:SetEnabledState(enabled)
	self:SetEnabled(enabled);
	self:RefreshIcon();
end

function SocialCardActionButtonMixin:RefreshIcon()
	-- Optionally override in your mixin
end
