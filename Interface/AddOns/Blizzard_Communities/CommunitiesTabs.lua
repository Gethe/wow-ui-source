CommunitiesFrameTabMixin = {};

function CommunitiesFrameTabMixin:OnLoad()
	self.Icon:SetTexture(self.iconTexture);
end

function CommunitiesFrameTabMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:SetChecked(true);

	self:GetParent():SetDisplayMode(self.displayMode);
end

function CommunitiesFrameTabMixin:OnEnter()
	if self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip);
		if self.tooltip2 then
			GameTooltip:AddLine(self.tooltip2, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		end
		GameTooltip:Show();
	end
end

function CommunitiesFrameTabMixin:OnLeave()
	GameTooltip:Hide();
end

CommunitiesChatTabMixin = CreateFromMixins(CommunitiesFrameTabMixin);

function CommunitiesChatTabMixin:OnClick(buttonName, down)
	if IsShiftKeyDown() then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		ShowUIPanel(ChatConfigFrame);
	elseif self:GetParent():IsChatAccessible() then
		CommunitiesFrameTabMixin.OnClick(self, buttonName, down);
	else
		self:SetChecked(false);
	end
end