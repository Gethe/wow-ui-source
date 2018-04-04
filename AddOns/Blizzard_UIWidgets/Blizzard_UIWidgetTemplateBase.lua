UIWidgetTemplateTooltipFrameMixin = {}

function UIWidgetTemplateTooltipFrameMixin:SetTooltip(tooltip)
	self.tooltip = tooltip;

	if tooltip then
		self.tooltipContainsHyperLink = (tooltip:find("|H", 1, true) ~= nil);
	end
end

function UIWidgetTemplateTooltipFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");

	if self.tooltip then
		if self.tooltipContainsHyperLink then
			GameTooltip:SetHyperlink(self.tooltip);
		else
			GameTooltip:SetText(self.tooltip);
		end
	end
end

function UIWidgetTemplateTooltipFrameMixin:OnLeave()
	GameTooltip:Hide();
end

UIWidgetBaseTemplateMixin = {}

function UIWidgetBaseTemplateMixin:BaseSetup(widgetInfo)
	self.orderIndex = widgetInfo.orderIndex;
	self:Show();
end
