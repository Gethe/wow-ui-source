UIWidgetTemplateTooltipFrameMixin = {}

function UIWidgetTemplateTooltipFrameMixin:OnLoad()
	self:EnableMouse(true);
	self:SetMouseClickEnabled(false);
end

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
	UIWidgetTemplateTooltipFrameMixin.OnLoad(self);
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

function UIWidgetBaseSpellTemplateMixin:Setup(spellInfo, enabledState, width)
	local name, _, icon = GetSpellInfo(spellInfo.spellID);
	self.Icon:SetTexture(icon);
	self.Icon:SetDesaturated(enabledState == Enum.WidgetEnabledState.Disabled);

	local iconSize = GetIconSize(spellInfo.iconSizeType);
	self.Icon:SetSize(iconSize, iconSize);

	if spellInfo.text ~= "" then
		self.Text:SetText(spellInfo.text);
	else
		self.Text:SetText(name);
	end

	if spellInfo.stackDisplay > 0 then
		self.StackCount:Show();
		self.StackCount:SetText(spellInfo.stackDisplay);
	else
		self.StackCount:Hide();
	end

	self.Border:SetShown(spellInfo.iconDisplayType == Enum.SpellDisplayIconDisplayType.Buff);
	self.DebuffBorder:SetShown(spellInfo.iconDisplayType == Enum.SpellDisplayIconDisplayType.Debuff);

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

UIWidgetBaseControlZoneTemplateMixin = {}

function UIWidgetBaseControlZoneTemplateMixin:OnLoad()
	UIWidgetBaseTemplateMixin.OnLoad(self);
	ResizeLayoutMixin.OnLoad(self);
end

local zoneFormatString = "%s-%s-%s";
local cappedFormatString = "%s-%s-%s-cap";
local swipeTextureFormatString = "Interface\\Widgets\\%s-%s-fill"

local textureKitRegionInfo = {
	["Zone"] = {useAtlasSize = true, setVisibility = true},	-- formatString is filled on before passing to SetupTextureKitsFromRegionInfo (based on whether the zone is capped or not)
	["FallingGlowBackground"] = {formatString = "%s-fallingglow-bg", useAtlasSize = true},
	["FallingGlowOverlay"] = {formatString = "%s-fallingglow", useAtlasSize = true},
	["FullGlow"] = {formatString = "%s-fullglow", useAtlasSize = true},
	["FullGlowStar"] = {formatString = "%s-starglow", useAtlasSize = true},
}

function UIWidgetBaseControlZoneTemplateMixin:UpdateAnimations(zoneInfo, zoneMode, lastVals)
	local isActive = (zoneInfo.activeState == Enum.ZoneControlActiveState.Active);
	local isMaxed = (zoneInfo.current == zoneInfo.max);
	local wasMaxed = lastVals and (lastVals.current == lastVals.max) or false;

	if not lastVals or not isActive then
		-- This is either the first update on this zone/state or the zone is inactive...turn off all animations
		self.FallingGlowAnim:Stop();
		self.FallingGlowBackground:Hide();
		self.FallingGlowOverlay:Hide();
		self.FullGlowAnim:Stop();
		self.FullGlow:Hide();
		self.FullGlowStar:Hide();
	else
		if isMaxed then
			if not wasMaxed then
				-- This zone just got maxed...play the full glow
				self.FullGlowStar:Show();
				self.FullGlow:Show();
				self.FullGlowAnim:Play();
			end

			-- The zone is maxed...turn off the falling glow
			self.FallingGlowAnim:Stop();
			self.FallingGlowBackground:Hide();
			self.FallingGlowOverlay:Hide();
		else
			local reverseAnims;
			if zoneMode == Enum.ZoneControlMode.BothStatesAreGood then
				reverseAnims = false;
			elseif zoneMode == Enum.ZoneControlMode.State1IsGood then
				reverseAnims = (zoneInfo.state == Enum.ZoneControlState.State2);
			elseif zoneMode == Enum.ZoneControlMode.State2IsGood then
				reverseAnims = (zoneInfo.state == Enum.ZoneControlState.State1);
			else
				reverseAnims = true;
			end

			local playFallingAnim, stopFallingAnim;
			if reverseAnims then
				playFallingAnim = zoneInfo.current > lastVals.current;
				stopFallingAnim = zoneInfo.current < lastVals.current;
			else
				playFallingAnim = zoneInfo.current < lastVals.current;
				stopFallingAnim = zoneInfo.current > lastVals.current;
			end

			if playFallingAnim then
				self.FallingGlowBackground:Show();
				self.FallingGlowOverlay:Show();
				self.FallingGlowAnim:Play();
			elseif stopFallingAnim then
				self.FallingGlowAnim:Stop();
				self.FallingGlowBackground:Hide();
				self.FallingGlowOverlay:Hide();
			end

			-- The zone is not maxed...turn off the full glow
			self.FullGlowAnim:Stop();
			self.FullGlow:Hide();
			self.FullGlowStar:Hide();
		end
	end
end

function UIWidgetBaseControlZoneTemplateMixin:Setup(zoneIndex, zoneMode, zoneInfo, lastVals, textureKitID)
	local textureKit = GetUITextureKitInfo(textureKitID);
	if not textureKit then
		self:Hide();
		return;
	end

	local currentVal = Clamp(zoneInfo.current, zoneInfo.min, zoneInfo.max);

	local stateString = "state"..(zoneInfo.state + 1);
	local zoneString = "zone"..zoneIndex;

	local isActive = (zoneInfo.activeState == Enum.ZoneControlActiveState.Active);
	if isActive then
		self.Zone:SetDesaturated(false);
	else
		currentVal = 0;
		self.Zone:SetDesaturated(true);
	end

	if currentVal >= zoneInfo.capturePoint then
		textureKitRegionInfo.Zone.formatString = cappedFormatString;
	else
		textureKitRegionInfo.Zone.formatString = zoneFormatString;
	end

	SetupTextureKitsFromRegionInfo({textureKit, stateString, zoneString}, self, textureKitRegionInfo);

	local swipeTextureName = swipeTextureFormatString:format(unpack({textureKit, stateString}));
	self.Progress:SetSwipeTexture(swipeTextureName);

	local percentageFull;
	local reverse;
	if zoneInfo.fillType == Enum.ZoneControlFillType.SingleFillClockwise then
		percentageFull = ClampedPercentageBetween(currentVal, zoneInfo.min, zoneInfo.max);
		reverse = true;
	elseif zoneInfo.fillType == Enum.ZoneControlFillType.SingleFillCounterClockwise then
		percentageFull = 1 - ClampedPercentageBetween(currentVal, zoneInfo.min, zoneInfo.max);
		reverse = false;
	elseif zoneInfo.fillType == Enum.ZoneControlFillType.DoubleFillClockwise then
		if currentVal >= zoneInfo.capturePoint then
			percentageFull = ClampedPercentageBetween(currentVal, zoneInfo.capturePoint, zoneInfo.max);
		else
			percentageFull = ClampedPercentageBetween(currentVal, zoneInfo.min, zoneInfo.capturePoint);
		end
		reverse = true;
	elseif zoneInfo.fillType == Enum.ZoneControlFillType.DoubleFillCounterClockwise then
		if currentVal >= zoneInfo.capturePoint then
			percentageFull = 1 - ClampedPercentageBetween(currentVal, zoneInfo.capturePoint, zoneInfo.max);
		else
			percentageFull = 1 - ClampedPercentageBetween(currentVal, zoneInfo.min, zoneInfo.capturePoint);
		end
		reverse = false;
	end

	if percentageFull == 1 then
		-- A cooldown at full duration actually draws nothing when what we want is a full bar...to achieve that, flip reverse and set the percentage to 0
		percentageFull = 0;
		reverse = not reverse;
	end

	self.Progress:SetReverse(reverse);
	CooldownFrame_SetDisplayAsPercentage(self.Progress, percentageFull);

	-- Set current to the clamped value
	zoneInfo.current = currentVal;

	-- And update the animations
	self:UpdateAnimations(zoneInfo, zoneMode, lastVals);

	self:SetTooltip(zoneInfo.tooltip);

	self:MarkDirty(); -- The widget needs to resize based on whether the textures are shown or hidden
end
