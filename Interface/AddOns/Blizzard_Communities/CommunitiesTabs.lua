
function CommunitiesFrameTab_OnEnter(self)
	if self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip);
		if self.tooltip2 then
			GameTooltip:AddLine(self.tooltip2, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		end
		GameTooltip:Show();
	end
end

function CommunitiesFrameTab_OnLeave(self)
	GameTooltip:Hide();
end