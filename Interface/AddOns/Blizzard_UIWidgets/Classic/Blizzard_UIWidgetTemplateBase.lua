UIWidgetTemplateTooltipFrameMixin = {}

function UIWidgetTemplateTooltipFrameMixin:SetTooltip(tooltip)
	self.tooltip = tooltip;
	self.tooltipContainsHyperLink = false;
	self.preString = nil;
	self.hyperLinkString = nil;
	self.postString = nil;

	if tooltip then
		self.tooltipContainsHyperLink, self.preString, self.hyperLinkString, self.postString = ExtractHyperlinkString(tooltip);
	end
end

function UIWidgetTemplateTooltipFrameMixin:SetTooltipOwner()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
end

function UIWidgetTemplateTooltipFrameMixin:OnEnter()
	self:SetTooltipOwner();

	if self.tooltip then
		if self.tooltipContainsHyperLink then
			-- prestring is thrown out because calling SetHyperlink clears the tooltip
			GameTooltip:SetHyperlink(self.hyperLinkString);
			if self.postString and self.postString:len() > 0 then
				GameTooltip_AddColoredLine(GameTooltip, self.postString, HIGHLIGHT_FONT_COLOR, true);
				GameTooltip:Show();
			end
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
	self.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	self.Text:SetText(resourceInfo.text);

	self:SetTooltip(resourceInfo.tooltip);
	self.Icon:SetTexture(resourceInfo.iconFileID);

	self:SetWidth(self.Icon:GetWidth() + self.Text:GetWidth() + 2);
	self:SetHeight(self.Icon:GetHeight());
end

function UIWidgetBaseResourceTemplateMixin:SetFontColor(color)
	self.Text:SetTextColor(color:GetRGB());
end

local function SetTextColorForEnabledState(fontString, enabledState)
	if enabledState == Enum.WidgetEnabledState.Disabled then
		fontString:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	elseif enabledState == Enum.WidgetEnabledState.Red then
		fontString:SetTextColor(RED_FONT_COLOR:GetRGB());
	elseif enabledState == Enum.WidgetEnabledState.Highlight then
		fontString:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	else
		fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end
end

UIWidgetBaseCurrencyTemplateMixin = {}

function UIWidgetBaseCurrencyTemplateMixin:Setup(currencyInfo, enabledState)
	self.Text:SetText(currencyInfo.text);
	self:SetTooltip(currencyInfo.tooltip);
	self.Icon:SetTexture(currencyInfo.iconFileID);
	self.Icon:SetDesaturated(disabled);

	SetTextColorForEnabledState(self.Text, enabledState);
	SetTextColorForEnabledState(self.LeadingText, enabledState);

	local totalWidth = self.Icon:GetWidth() + self.Text:GetWidth() + 5;

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

function UIWidgetBaseCurrencyTemplateMixin:SetFontColor(color)
	self.Text:SetTextColor(color:GetRGB());
	self.LeadingText:SetTextColor(color:GetRGB());
end

UIWidgetBaseColoredTextMixin = {}

function UIWidgetBaseColoredTextMixin:SetEnabledState(enabledState)
	SetTextColorForEnabledState(self, enabledState);
end
