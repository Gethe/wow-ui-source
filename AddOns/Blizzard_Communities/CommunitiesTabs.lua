
function CommunitiesFrameTab_OnEnter(self)
	if self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip);
		GameTooltip:Show();
	end
end

function CommunitiesFrameTab_OnLeave(self)
	GameTooltip:Hide();
end