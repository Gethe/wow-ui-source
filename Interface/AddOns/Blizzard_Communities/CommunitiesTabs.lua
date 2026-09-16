CommunitiesFrameTabMixin = {};

function CommunitiesFrameTabMixin:OnClick()
	RightSideTabMixin.OnClick(self);

	self:GetParent():SetDisplayMode(self.displayMode);
end

CommunitiesChatTabMixin = CreateFromMixins(CommunitiesFrameTabMixin);

function CommunitiesChatTabMixin:OnClick(buttonName, down)
	if IsShiftKeyDown() then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID);
	elseif self:GetParent():IsChatAccessible() then
		CommunitiesFrameTabMixin.OnClick(self, buttonName, down);
	else
		self:SetChecked(false);
	end
end
