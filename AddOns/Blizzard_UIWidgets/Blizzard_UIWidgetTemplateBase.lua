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
	EmbeddedItemTooltip:SetOwner(self, self.tooltipAnchor);
end

function UIWidgetTemplateTooltipFrameMixin:OnEnter()
	if self.tooltip and self.tooltip ~= "" then
		self:SetTooltipOwner();

		if self.tooltipContainsHyperLink then
			local clearTooltip = true;
			if self.preString and self.preString:len() > 0 then
				GameTooltip_AddNormalLine(EmbeddedItemTooltip, self.preString, true);
				clearTooltip = false;
			end

			GameTooltip_ShowHyperlink(EmbeddedItemTooltip, self.hyperLinkString, 0, 0, clearTooltip);

			if self.postString and self.postString:len() > 0 then
				GameTooltip_AddColoredLine(EmbeddedItemTooltip, self.postString, self.tooltipColor or HIGHLIGHT_FONT_COLOR, true);
			end
			
			EmbeddedItemTooltip:Show();
		else
			local header, nonHeader = SplitTextIntoHeaderAndNonHeader(self.tooltip);
			if header then
				GameTooltip_AddColoredLine(EmbeddedItemTooltip, header, self.tooltipColor or NORMAL_FONT_COLOR, true);
			end
			if nonHeader then
				GameTooltip_AddColoredLine(EmbeddedItemTooltip, nonHeader, self.tooltipColor or NORMAL_FONT_COLOR, true);
			end
			EmbeddedItemTooltip:SetShown(header ~= nil);
		end
	end
	self.mouseOver = true;
end

function UIWidgetTemplateTooltipFrameMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
	self.mouseOver = false;
end

UIWidgetBaseTemplateMixin = {}

function UIWidgetBaseTemplateMixin:OnLoad()
end

function UIWidgetBaseTemplateMixin:InAnimFinished()
end

function UIWidgetBaseTemplateMixin:OutAnimFinished()
	self.widgetContainer:RemoveWidget(self.widgetID);
end

function UIWidgetBaseTemplateMixin:GetInAnim()
	if self.inAnimType == Enum.WidgetAnimationType.Fade then
		return self.FadeInAnim;
	end
end

function UIWidgetBaseTemplateMixin:GetOutAnim()
	if self.outAnimType == Enum.WidgetAnimationType.Fade then
		return self.FadeOutAnim;
	end
end

function UIWidgetBaseTemplateMixin:ResetAnimState()
	self.FadeInAnim:Stop();
	self.FadeOutAnim:Stop();
	self:SetAlpha(100);
end

function UIWidgetBaseTemplateMixin:AnimIn()
	if not self:IsShown() then
		self:ResetAnimState();

		self:Show();

		local inAnim = self:GetInAnim();
		if inAnim then
			inAnim:Play();
		else
			self:InAnimFinished();
		end
	end
end

-- Animates the widget out. Once that is done the widget is removed from the widget container and actually released
function UIWidgetBaseTemplateMixin:AnimOut()
	if self:IsShown() then
		self:ResetAnimState();

		local outAnim = self:GetOutAnim();
		if outAnim then
			outAnim:Play();
		else
			self:OutAnimFinished();
		end
	end
end

-- Override with any custom behaviour that you need to perform when this widget is updated. Make sure you still call the base though because it handles animations
function UIWidgetBaseTemplateMixin:Setup(widgetInfo, widgetContainer)
	self.widgetContainer = widgetContainer;
	self:AnimIn();
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
		EmbeddedItemTooltip:SetSpellByID(self.spellID);
		EmbeddedItemTooltip:Show();
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

function UIWidgetBaseStatusBarTemplateMixin:Setup(barMin, barMax, barValue, barValueTextType, tooltip, overrideBarText, overrideBarTextShownType)
	barValue = Clamp(barValue, barMin, barMax);

	self:SetMinMaxValues(barMin, barMax);
	self:SetValue(barValue);

	self:SetTooltip(tooltip);

	self.Label:SetShown(barValueTextType ~= Enum.StatusBarValueTextType.Hidden);

	self.overrideBarText = overrideBarText;
	self.overrideBarTextShownType = overrideBarTextShownType;

	local maxTimeCount = self:GetMaxTimeCount(barValueTextType);

	if maxTimeCount then
		self.barText = SecondsToTime(barValue, false, true, maxTimeCount, true);
	elseif barValueTextType == Enum.StatusBarValueTextType.Value then
		self.barText = barValue;
	elseif barValueTextType == Enum.StatusBarValueTextType.ValueOverMax then
		self.barText = FormatFraction(barValue, barMax);
	elseif barValueTextType == Enum.StatusBarValueTextType.ValueOverMaxNormalized then
		self.barText = FormatFraction(barValue - barMin, barMax - barMin);
	elseif barValueTextType == Enum.StatusBarValueTextType.Percentage then
		local barPercent = PercentageBetween(barValue, barMin, barMax);
		self.barText = FormatPercentage(barPercent, true);
	else
		self.barText = "";
	end

	self:UpdateBarText();
end

function UIWidgetBaseStatusBarTemplateMixin:GetMaxTimeCount(barValueTextType)
	if barValueTextType == Enum.StatusBarValueTextType.Time then
		return 2;
	elseif barValueTextType == Enum.StatusBarValueTextType.TimeShowOneLevelOnly then
		return 1;
	end
end

function UIWidgetBaseStatusBarTemplateMixin:OnEnter()
	UIWidgetTemplateTooltipFrameMixin.OnEnter(self);
	self:UpdateBarText();
end

function UIWidgetBaseStatusBarTemplateMixin:OnLeave()
	UIWidgetTemplateTooltipFrameMixin.OnLeave(self);
	self:UpdateBarText();
end

function UIWidgetBaseStatusBarTemplateMixin:UpdateBarText()
	if self.overrideBarText then
		local showOverrideBarText = (self.overrideBarTextShownType == Enum.StatusBarOverrideBarTextShownType.Always);
		if not showOverrideBarText then
			if self.mouseOver then
				showOverrideBarText = (self.overrideBarTextShownType == Enum.StatusBarOverrideBarTextShownType.OnlyOnMouseover);
			else
				showOverrideBarText = (self.overrideBarTextShownType == Enum.StatusBarOverrideBarTextShownType.OnlyNotOnMouseover);
			end
		end

		if showOverrideBarText then
			self.Label:SetText(self.overrideBarText);
		else
			self.Label:SetText(self.barText);
		end
	else
		self.Label:SetText(self.barText);
	end
end

UIWidgetBaseStateIconTemplateMixin = {}

function UIWidgetBaseStateIconTemplateMixin:Setup(textureKitID, textureKitFormatter, captureIconInfo)
	if captureIconInfo.iconState == Enum.IconState.ShowState1 then
		SetupTextureKitOnFrameByID(textureKitID, self.Icon, "%s-"..textureKitFormatter.."-state1", TextureKitConstants.SetVisiblity, TextureKitConstants.UseAtlasSize);
		self:SetTooltip(captureIconInfo.state1Tooltip);
	elseif captureIconInfo.iconState == Enum.IconState.ShowState2 then
		SetupTextureKitOnFrameByID(textureKitID, self.Icon, "%s-"..textureKitFormatter.."-state2", TextureKitConstants.SetVisiblity, TextureKitConstants.UseAtlasSize);
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

UIWidgetBaseTextureAndTextTemplateMixin = {}

local textFontSizes =
{
	[Enum.UIWidgetTextSizeType.Small]	= "GameFontNormal",
	[Enum.UIWidgetTextSizeType.Medium]	= "GameFontNormalLarge",
	[Enum.UIWidgetTextSizeType.Large]	= "GameFontNormalHuge2",
	[Enum.UIWidgetTextSizeType.Huge]	= "GameFontNormalHuge4",
}

local function GetTextSizeFont(textSizeType)
	return textFontSizes[textSizeType] and textFontSizes[textSizeType] or textFontSizes[Enum.UIWidgetTextSizeType.Medium];
end

function UIWidgetBaseTextureAndTextTemplateMixin:OnLoad()
	ResizeLayoutMixin.OnLoad(self); 
	self.Text:SetFontObjectsToTry(); 
end 

function UIWidgetBaseTextureAndTextTemplateMixin:Setup(text, tooltip, frameTextureKitID, textureKitID, textSizeType, layoutIndex)
	self.layoutIndex = layoutIndex;

	local textureKitAppend = "";

	if layoutIndex then
		textureKitAppend = "_"..layoutIndex;
	end

	self.Text:SetFontObject(GetTextSizeFont(textSizeType));

	self.Text:SetText(text); 
	self:SetTooltip(tooltip);

	SetupTextureKitOnFrameByID(frameTextureKitID, self.Background, "%s"..textureKitAppend, TextureKitConstants.SetVisiblity, TextureKitConstants.UseAtlasSize);
	SetupTextureKitOnFrameByID(textureKitID, self.Foreground, "%s"..textureKitAppend, TextureKitConstants.SetVisiblity, TextureKitConstants.UseAtlasSize);

	self:MarkDirty(); -- The widget needs to resize based on whether the textures are shown or hidden
end
