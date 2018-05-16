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

function UIWidgetBaseTemplateMixin:OnLoad()
end

function UIWidgetBaseTemplateMixin:Setup(widgetInfo)
	self.orderIndex = widgetInfo.orderIndex;
	self.widgetTag = widgetInfo.widgetTag;
	self:Show();
end

-- Override with any custom behaviour that you need to perform when this widget is destroyed (e.g. release pools)
function UIWidgetBaseTemplateMixin:OnReset()
	self:Hide();
	self:ClearAllPoints();
end

UIWidgetBaseResourceTemplateMixin = {}

function UIWidgetBaseResourceTemplateMixin:Setup(resourceInfo)
	self.Text:SetText(resourceInfo.text);
	self:SetTooltip(resourceInfo.tooltip);
	self.Icon:SetTexture(resourceInfo.iconFileID);

	self:SetWidth(self.Icon:GetWidth() + self.Text:GetWidth() + 2);
	self:SetHeight(self.Icon:GetHeight());
end

UIWidgetBaseCurrencyTemplateMixin = {}

function UIWidgetBaseCurrencyTemplateMixin:Setup(currencyInfo, disabled)
	self.Text:SetText(currencyInfo.text);
	self:SetTooltip(currencyInfo.tooltip);
	self.Icon:SetTexture(currencyInfo.iconFileID);
	self.Icon:SetDesaturated(disabled);

	if disabled then
		self.Text:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.LeadingText:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	else
		self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.LeadingText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end

	local totalWidth = self.Icon:GetWidth() + self.Text:GetWidth() + 2;

	self.Icon:ClearAllPoints();
	if currencyInfo.leadingText ~= "" then
		self.LeadingText:SetText(currencyInfo.leadingText);
		self.LeadingText:Show();
		self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", self.LeadingText:GetWidth() + 5, 0);
		totalWidth = totalWidth + self.LeadingText:GetWidth() + 5;
	else
		self.LeadingText:Hide();
		self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
	end

	self:SetWidth(totalWidth);
	self:SetHeight(self.Icon:GetHeight());
end

UIWidgetBaseColoredTextMixin = {}

function UIWidgetBaseColoredTextMixin:SetEnabledState(enabledState)
	if enabledState == Enum.WidgetEnabledState.Disabled then
		self:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	elseif enabledState == Enum.WidgetEnabledState.Red then
		self:SetTextColor(RED_FONT_COLOR:GetRGB());
	elseif enabledState == Enum.WidgetEnabledState.Highlight then
		self:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	else
		self:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end
end

