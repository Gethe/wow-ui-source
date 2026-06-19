SocialUIActionButtonMixin = {}

function SocialUIActionButtonMixin:OnEnter()
	if self.disableTooltip then
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddErrorLine(tooltip, self.disableTooltip);
		tooltip:Show();
	end
end

function SocialUIActionButtonMixin:OnLeave()
	GetAppropriateTooltip():Hide()
end


SocialUISearchBoxMixin = {};

function SocialUISearchBoxMixin:OnLoad()
	SearchBoxTemplate_OnLoad(self);
	self:InitializeUserScaledFontSystem();
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
end

function SocialUIOnlineSearchFilterDropdownMixin:InitializeUserScaledFontSystem()
	UserScaledElementMixin.OnLoad_UserScaledElement(self);

	self.Text:ClearAllPoints();
	self.Text:SetPoint("CENTER", self, "CENTER", 0, 0);
end

SocialUIContactsFrameMixin = {};

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

		if frame.ActionButton then
			frame.ActionButton:SetEnabled(false);
			frame.ActionButton.disableTooltip = ADDING_FRIENDS_DISABLED;
		end
	else
		frame.ScrollBox:Show();
		frame.ScrollBar:Show();
		frame.FriendsDisabledText:Hide();
		
		if frame.ActionButton then
			frame.ActionButton:SetEnabled(true);
			frame.ActionButton.disableTooltip = nil;
		end
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

SocialUIScrollableSpacerMixin = {};

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
