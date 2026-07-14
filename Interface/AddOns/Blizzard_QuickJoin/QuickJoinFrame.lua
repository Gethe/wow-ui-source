QuickJoinSocialViewJoinButtonMixin = CreateFromMixins(SocialUIActionButtonMixin);

function QuickJoinSocialViewJoinButtonMixin:ShowDisabledTooltip()
	if not self.tooltip then
		return;
	end

	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	local wrapText = true;
	GameTooltip_AddErrorLine(tooltip, self.tooltip, wrapText);
	tooltip:Show();
end

QuickJoinSocialViewMixin = CreateFromMixins(QuickJoinMixin, SocialUISystemMixin);

function QuickJoinSocialViewMixin:OnLoad()
	QuickJoinMixin.OnLoad(self);

	-- Keep listening even while hidden so we can tell the Social UI to refresh our tab's availability
	self:RegisterEvent("SOCIAL_UI_SOCIAL_QUEUE_SYSTEM_STATUS_UPDATED");

	self:InitializeActionButton();
	self:InitializeFilterBar();
end

function QuickJoinSocialViewMixin:GetScrollBoxPadding()
	local topPadding, bottomPadding, leftPadding, rightPadding = 10, 10, 5, 5;
	local elementSpacing = 0;
	return topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing;
end

function QuickJoinSocialViewMixin:InitializeActionButton()
	Mixin(self.ActionButton, QuickJoinSocialViewJoinButtonMixin);
	self.ActionButton.PerformClickAction = function() self:JoinQueue(); end

	self.ActionButton:SetText(JOIN_QUEUE);
end

function QuickJoinSocialViewMixin:InitializeFilterBar()
	self:SetFilterBarShown(false);
end

function QuickJoinSocialViewMixin:GetJoinButton()
	return self.ActionButton;
end

function QuickJoinSocialViewMixin:OnEvent(event, ...)
	QuickJoinMixin.OnEvent(self, event, ...);

	if event == "SOCIAL_QUEUE_UPDATE" then
		self:RefreshCounter();
	elseif event == "SOCIAL_UI_SOCIAL_QUEUE_SYSTEM_STATUS_UPDATED" then
		self:TriggerSocialUIEvent(SocialUIFrameMixin.Event.FeatureAvailabilityChanged);
	end
end

function QuickJoinSocialViewMixin:RefreshCounter()
	self:TriggerSocialUIEvent(SocialUIFrameMixin.Event.TabCounterRefreshRequested, SocialUITabType.QuickJoin);
end
