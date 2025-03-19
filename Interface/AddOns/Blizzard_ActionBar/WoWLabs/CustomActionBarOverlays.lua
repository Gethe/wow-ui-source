
PlunderstormBarCapTooltipMixin = {};

function PlunderstormBarCapTooltipMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, self.tooltip);
	GameTooltip:Show();
end

function PlunderstormBarCapTooltipMixin:OnLeave()
	GameTooltip_Hide()
end