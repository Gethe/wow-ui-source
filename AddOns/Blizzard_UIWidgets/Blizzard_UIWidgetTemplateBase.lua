UIWidgetTemplateTooltipFrameMixin = {}

function UIWidgetTemplateTooltipFrameMixin:SetTooltip(tooltip, color)
	self.tooltip = tooltip;
	self.tooltipContainsHyperLink = false;
	self.preString = nil;
	self.hyperLinkString = nil;
	self.postString = nil;
	self.tooltipColor = color;

	if tooltip then
		self.tooltipContainsHyperLink, self.preString, self.hyperLinkString, self.postString = ExtractHyperlinkString(tooltip);
	end
end

function UIWidgetTemplateTooltipFrameMixin:SetTooltipOwner()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
end

function UIWidgetTemplateTooltipFrameMixin:OnEnter()
	if self.tooltip and self.tooltip ~= "" then
		self:SetTooltipOwner();

		if self.tooltipContainsHyperLink then
			-- prestring is thrown out because calling SetHyperlink clears the tooltip
			GameTooltip:SetHyperlink(self.hyperLinkString);
			if self.postString and self.postString:len() > 0 then
				GameTooltip_AddColoredLine(GameTooltip, self.postString, self.tooltipColor or HIGHLIGHT_FONT_COLOR, true);
				GameTooltip:Show();
			end
		else
			local header, nonHeader = SplitTextIntoHeaderAndNonHeader(self.tooltip);
			if header then
				GameTooltip_AddColoredLine(GameTooltip, header, self.tooltipColor or NORMAL_FONT_COLOR, true);
			end
			if nonHeader then
				GameTooltip_AddColoredLine(GameTooltip, nonHeader, self.tooltipColor or NORMAL_FONT_COLOR, true);
			end
			GameTooltip:SetShown(header ~= nil);
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

local function GetTextColorForEnabledState(enabledState, useHighlightForNormal)
	if enabledState == Enum.WidgetEnabledState.Disabled then
		return DISABLED_FONT_COLOR;
	elseif enabledState == Enum.WidgetEnabledState.Red then
		return RED_FONT_COLOR;
	elseif enabledState == Enum.WidgetEnabledState.Highlight then
		return HIGHLIGHT_FONT_COLOR;
	else
		return useHighlightForNormal and HIGHLIGHT_FONT_COLOR or NORMAL_FONT_COLOR;
	end
end

local function SetTextColorForEnabledState(fontString, enabledState, useHighlightForNormal)
	fontString:SetTextColor(GetTextColorForEnabledState(enabledState, useHighlightForNormal):GetRGB());
end

UIWidgetBaseCurrencyTemplateMixin = {}

function UIWidgetBaseCurrencyTemplateMixin:Setup(currencyInfo, enabledState, tooltipEnabledState)
	self.Text:SetText(currencyInfo.text);
	self:SetTooltip(currencyInfo.tooltip, GetTextColorForEnabledState(tooltipEnabledState or enabledState, true));
	self.Icon:SetTexture(currencyInfo.iconFileID);
	self.Icon:SetDesaturated(enabledState == Enum.WidgetEnabledState.Disabled);

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

UIWidgetBaseSpellTemplateMixin = {}

local iconSizes =
{
	[Enum.SpellDisplayIconSizeType.Small]	= 24,
	[Enum.SpellDisplayIconSizeType.Medium]	= 30,
	[Enum.SpellDisplayIconSizeType.Large]	= 36,
}

local function GetIconSize(iconSizeType)
	return iconSizes[iconSizeType] and iconSizes[iconSizeType] or iconSizes[Enum.SpellDisplayIconSizeType.Large];
end

function UIWidgetBaseSpellTemplateMixin:Setup(spellInfo, enabledState, width, iconSizeType)
	local name, _, icon = GetSpellInfo(spellInfo.spellID);
	self.Icon:SetTexture(icon);
	self.Icon:SetDesaturated(enabledState == Enum.WidgetEnabledState.Disabled);

	local iconSize = GetIconSize(iconSizeType);
	self.Icon:SetSize(iconSize, iconSize);

	self.Text:SetText(name);

	local iconWidth = self.Icon:GetWidth() + 5;
	local textWidth;
	if width > 0 then
		textWidth = width - iconWidth;
	else
		textWidth = self.Text:GetStringWidth();
	end

	self.Text:SetWidth(textWidth);
	SetTextColorForEnabledState(self.Text, enabledState);
	self.spellID = spellInfo.spellID;
	self:SetTooltip(spellInfo.tooltip);

	self:SetWidth(iconWidth + textWidth);
	self:SetHeight(self.Icon:GetHeight());
end

function UIWidgetBaseSpellTemplateMixin:OnEnter()
	if not self.tooltip or self.tooltip == "" then
		self:SetTooltipOwner();
		GameTooltip:SetSpellByID(self.spellID);
		GameTooltip:Show();
	else
		UIWidgetTemplateTooltipFrameMixin.OnEnter(self);
	end
end

function UIWidgetBaseSpellTemplateMixin:SetFontColor(color)
	self.Text:SetTextColor(color:GetRGB());
end

UIWidgetBaseColoredTextMixin = {}

function UIWidgetBaseColoredTextMixin:SetEnabledState(enabledState)
	SetTextColorForEnabledState(self, enabledState);
end

UIWidgetBaseStatusBarTemplateMixin = {}

function UIWidgetBaseStatusBarTemplateMixin:Setup(barMin, barMax, barValue, barValueTextType)
	self:SetMinMaxValues(barMin, barMax);
	self:SetValue(barValue);

	self.Label:SetShown(barValueTextType ~= Enum.StatusBarValueTextType.Hidden);

	local maxTimeCount = self:GetMaxTimeCount(barValueTextType);

	if maxTimeCount then
		self.Label:SetText(SecondsToTime(barValue, false, true, maxTimeCount, true));
	elseif barValueTextType == Enum.StatusBarValueTextType.Value then
		self.Label:SetText(barValue);
	elseif barValueTextType == Enum.StatusBarValueTextType.ValueOverMax then
		self.Label:SetText(FormatFraction(barValue, barMax));
	elseif barValueTextType == Enum.StatusBarValueTextType.ValueOverMaxNormalized then
		self.Label:SetText(FormatFraction(barValue - barMin, barMax - barMin));
	elseif barValueTextType == Enum.StatusBarValueTextType.Percentage then
		local barPercent = PercentageBetween(barValue, barMin, barMax);
		local barPercentText = FormatPercentage(barPercent, true);
		self.Label:SetText(barPercentText);
	end
end

function UIWidgetBaseStatusBarTemplateMixin:GetMaxTimeCount(barValueTextType)
	if barValueTextType == Enum.StatusBarValueTextType.Time then
		return 2;
	elseif barValueTextType == Enum.StatusBarValueTextType.TimeShowOneLevelOnly then
		return 1;
	end
end

UIWidgetBaseStateIconTemplateMixin = {}

function UIWidgetBaseStateIconTemplateMixin:Setup(textureKitID, textureKitFormatter, captureIconInfo)
	if captureIconInfo.iconState == Enum.IconState.ShowState1 then
		SetupTextureKitOnFrameByID(textureKitID, self.Icon, "%s-"..textureKitFormatter.."-state1", true, true);
		self:SetTooltip(captureIconInfo.state1Tooltip);
	elseif captureIconInfo.iconState == Enum.IconState.ShowState2 then
		SetupTextureKitOnFrameByID(textureKitID, self.Icon, "%s-"..textureKitFormatter.."-state2", true, true);
		self:SetTooltip(captureIconInfo.state2Tooltip);
	else
		self.Icon:Hide();
	end

	local iconShown = self.Icon:IsShown();

	self:SetWidth(self.Icon:GetWidth());
	self:SetHeight(self.Icon:GetHeight());

	self:SetShown(iconShown);
	return iconShown;
end
