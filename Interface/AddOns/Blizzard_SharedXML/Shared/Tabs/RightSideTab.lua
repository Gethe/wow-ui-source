RightSideTabMixin = {};

function RightSideTabMixin:OnLoad()
	self.Icon:SetTexture(self.iconTexture);
end

function RightSideTabMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:SetChecked(true);
end

function RightSideTabMixin:OnEnter()
	if self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip);
		if self.tooltip2 then
			GameTooltip:AddLine(self.tooltip2, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		end
		GameTooltip:Show();
	end
end

function RightSideTabMixin:OnLeave()
	GameTooltip:Hide();
end
