UIWidgetTemplateTooltipFrameMixin = {}

function UIWidgetTemplateTooltipFrameMixin:SetMouse(disableMouse)
	local useMouse = self.tooltip and self.tooltip ~= "" and not disableMouse;
	self:EnableMouse(useMouse)
	self:SetMouseClickEnabled(false);
end

function UIWidgetTemplateTooltipFrameMixin:OnLoad()
end

function UIWidgetTemplateTooltipFrameMixin:UpdateMouseEnabled()
	self:SetMouse(self.disableTooltip);
end

function UIWidgetTemplateTooltipFrameMixin:Setup(widgetContainer)
	self.disableTooltip = widgetContainer.disableWidgetTooltips;
	self:UpdateMouseEnabled();
	self:SetMouseClickEnabled(false);
	self:SetTooltipLocation(nil);
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
	self:UpdateMouseEnabled();
end

local tooltipLocToAnchor = {
	[Enum.UIWidgetTooltipLocation.BottomLeft]	= "ANCHOR_BOTTOMLEFT",
	[Enum.UIWidgetTooltipLocation.Left]			= "ANCHOR_NONE",
	[Enum.UIWidgetTooltipLocation.TopLeft]		= "ANCHOR_LEFT",
	[Enum.UIWidgetTooltipLocation.Top]			= "ANCHOR_TOP",
	[Enum.UIWidgetTooltipLocation.TopRight]		= "ANCHOR_RIGHT",
	[Enum.UIWidgetTooltipLocation.Right]		= "ANCHOR_NONE",
	[Enum.UIWidgetTooltipLocation.BottomRight]	= "ANCHOR_BOTTOMRIGHT",
	[Enum.UIWidgetTooltipLocation.Bottom]		= "ANCHOR_BOTTOM",
};

function UIWidgetTemplateTooltipFrameMixin:SetTooltipLocation(tooltipLoc)
	self.tooltipLoc = tooltipLoc;
	self.tooltipAnchor = tooltipLocToAnchor[tooltipLoc] or self.defaultTooltipAnchor;
end

function UIWidgetTemplateTooltipFrameMixin:SetTooltipOwner()
	if self.tooltipAnchor == "ANCHOR_NONE" then
		EmbeddedItemTooltip:SetOwner(self, self.tooltipAnchor);
		EmbeddedItemTooltip:ClearAllPoints();
		if self.tooltipLoc == Enum.UIWidgetTooltipLocation.Left then
			EmbeddedItemTooltip:SetPoint("RIGHT", self, "LEFT", self.tooltipXOffset, self.tooltipYOffset);
		elseif self.tooltipLoc == Enum.UIWidgetTooltipLocation.Right then
			EmbeddedItemTooltip:SetPoint("LEFT", self, "RIGHT", self.tooltipXOffset, self.tooltipYOffset);
		end
	else
		EmbeddedItemTooltip:SetOwner(self, self.tooltipAnchor, self.tooltipXOffset, self.tooltipYOffset);
	end
end

function UIWidgetTemplateTooltipFrameMixin:OnEnter()
	if self.tooltip and self.tooltip ~= "" then
		self:SetTooltipOwner();

		if self.tooltipBackdropStyle then
			SharedTooltip_SetBackdropStyle(EmbeddedItemTooltip, self.tooltipBackdropStyle);
		end

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

			self.UpdateTooltip = self.OnEnter;

			EmbeddedItemTooltip:Show();
		else
			local header, nonHeader = SplitTextIntoHeaderAndNonHeader(self.tooltip);
			if header then
				GameTooltip_AddColoredLine(EmbeddedItemTooltip, header, self.tooltipColor or NORMAL_FONT_COLOR, true);
			end
			if nonHeader then
				GameTooltip_AddColoredLine(EmbeddedItemTooltip, nonHeader, self.tooltipColor or NORMAL_FONT_COLOR, true);
			end

			self.UpdateTooltip = nil;

			EmbeddedItemTooltip:SetShown(header ~= nil);
		end
	end
	self.mouseOver = true;
end

function UIWidgetTemplateTooltipFrameMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
	self.mouseOver = false;
	self.UpdateTooltip = nil;
end

local function GetTextColorForEnabledState(enabledState, overrideNormalFontColor)
	if enabledState == Enum.WidgetEnabledState.Disabled then
		return DISABLED_FONT_COLOR;
	elseif enabledState == Enum.WidgetEnabledState.Red then
		return RED_FONT_COLOR;
	elseif enabledState == Enum.WidgetEnabledState.White then
		return HIGHLIGHT_FONT_COLOR;
	elseif enabledState == Enum.WidgetEnabledState.Green then
		return GREEN_FONT_COLOR;
	elseif enabledState == Enum.WidgetEnabledState.Gold then
		return CHALLENGE_MODE_TOAST_TITLE_COLOR;
	else
		return overrideNormalFontColor or NORMAL_FONT_COLOR;
	end
end

UIWidgetBaseEnabledFrameMixin = {}

function UIWidgetBaseEnabledFrameMixin:SetOverrideNormalFontColor(overrideNormalFontColor)
	self.overrideNormalFontColor = overrideNormalFontColor;
	self:UpdateFontColors();
end

function UIWidgetBaseEnabledFrameMixin:ClearOverrideNormalFontColor()
	self.overrideNormalFontColor = nil;
	self:UpdateFontColors();
end

function UIWidgetBaseEnabledFrameMixin:UpdateFontColors()
	if self.SetTextColor then
		self:SetTextColor(GetTextColorForEnabledState(self.enabledState, self.overrideNormalFontColor):GetRGB());
	end

	if self.ColoredStrings then
		for _, fontString in ipairs(self.ColoredStrings) do
			fontString:SetTextColor(GetTextColorForEnabledState(self.enabledState, self.overrideNormalFontColor):GetRGB());
		end
	end
end

function UIWidgetBaseEnabledFrameMixin:SetEnabledState(enabledState)
	self.enabledState = enabledState;
	self:UpdateFontColors();
end

UIWidgetBaseTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

function UIWidgetBaseTemplateMixin:ShouldApplyEffectsToSubFrames()
	return false;
end

function UIWidgetBaseTemplateMixin:ClearEffects()
	local frames = {self:GetChildren()};
	table.insert(frames, self);
	for _, frame in ipairs(frames) do
		if frame.effectController then 
			frame.effectController:CancelEffect();
			frame.effectController = nil;
		end	
	end
end 

function UIWidgetBaseTemplateMixin:ApplyEffectToFrame(widgetInfo, widgetContainer, frame) 
	if frame.effectController then 
		frame.effectController:CancelEffect();
		frame.effectController = nil;
	end
	if widgetInfo.scriptedAnimationEffectID and widgetInfo.modelSceneLayer ~= Enum.UIWidgetModelSceneLayer.None then
		if widgetInfo.modelSceneLayer == Enum.UIWidgetModelSceneLayer.Front then 
			frame.effectController = widgetContainer.FrontModelScene:AddEffect(widgetInfo.scriptedAnimationEffectID, frame, frame);
		elseif widgetInfo.modelSceneLayer == Enum.UIWidgetModelSceneLayer.Back then 
			frame.effectController = widgetContainer.BackModelScene:AddEffect(widgetInfo.scriptedAnimationEffectID, frame, frame);
		end 
	end
end	

function UIWidgetBaseTemplateMixin:ApplyEffects(widgetInfo)
	local applyFrames = self:ShouldApplyEffectsToSubFrames() and {self:GetChildren()} or {self};
	for _, frame in ipairs(applyFrames) do
		self:ApplyEffectToFrame(widgetInfo, self.widgetContainer, frame);
	end
end

function UIWidgetBaseTemplateMixin:OnLoad()
	UIWidgetTemplateTooltipFrameMixin.OnLoad(self);
end

function UIWidgetBaseTemplateMixin:GetWidgetWidth()
	return self:GetWidth() * self:GetScale();
end

function UIWidgetBaseTemplateMixin:GetWidgetHeight()
	return self:GetHeight() * self:GetScale();
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

local widgetScales =
{
	[Enum.UIWidgetScale.OneHundred]	= 1,
	[Enum.UIWidgetScale.Ninty]	 = 0.9,
	[Enum.UIWidgetScale.Eighty]	 = 0.8,
	[Enum.UIWidgetScale.Seventy] = 0.7,
	[Enum.UIWidgetScale.Sixty]	= 0.6,
	[Enum.UIWidgetScale.Fifty]	= 0.5,
}

local function GetWidgetScale(widgetScale)
	return widgetScales[widgetScale] and widgetScales[widgetScale] or widgetScales[Enum.UIWidgetScale.OneHundred];
end

-- Override with any custom behaviour that you need to perform when this widget is updated. Make sure you still call the base though because it handles animations
function UIWidgetBaseTemplateMixin:Setup(widgetInfo, widgetContainer)
	self:SetScale(GetWidgetScale(widgetInfo.widgetScale));
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	self:SetTooltipLocation(widgetInfo.tooltipLoc);
	self.widgetContainer = widgetContainer;
	self.orderIndex = widgetInfo.orderIndex;
	self.layoutDirection = widgetInfo.layoutDirection; 
	self:AnimIn();
end

-- Override with any custom behaviour that you need to perform when this widget is destroyed (e.g. release pools)
function UIWidgetBaseTemplateMixin:OnReset()
	self:Hide();
	self:ClearAllPoints();
	self:ClearEffects();
end

UIWidgetBaseResourceTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin, UIWidgetBaseEnabledFrameMixin);

function UIWidgetBaseResourceTemplateMixin:Setup(widgetContainer, resourceInfo)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	self.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	self.Text:SetText(resourceInfo.text);

	self:SetTooltip(resourceInfo.tooltip);
	self.Icon:SetTexture(resourceInfo.iconFileID);

	self:SetWidth(self.Icon:GetWidth() + self.Text:GetWidth() + 2);
	self:SetHeight(self.Icon:GetHeight());
end

UIWidgetBaseCurrencyTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin, UIWidgetBaseEnabledFrameMixin);

function UIWidgetBaseCurrencyTemplateMixin:Setup(widgetContainer, currencyInfo, enabledState, tooltipEnabledState)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	self.Text:SetText(currencyInfo.text);
	self:SetTooltip(currencyInfo.tooltip, GetTextColorForEnabledState(tooltipEnabledState or enabledState));
	self.Icon:SetTexture(currencyInfo.iconFileID);
	self.Icon:SetDesaturated(enabledState == Enum.WidgetEnabledState.Disabled);

	self:SetEnabledState(enabledState);

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

UIWidgetBaseSpellTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin, UIWidgetBaseEnabledFrameMixin);

local iconSizes =
{
	[Enum.SpellDisplayIconSizeType.Small]	= 24,
	[Enum.SpellDisplayIconSizeType.Medium]	= 30,
	[Enum.SpellDisplayIconSizeType.Large]	= 36,
}

local function GetIconSize(iconSizeType)
	return iconSizes[iconSizeType] and iconSizes[iconSizeType] or iconSizes[Enum.SpellDisplayIconSizeType.Large];
end

local spellTextureKitRegionInfo = {
	["Border"] = {formatString = "%s-frame", setVisibility = true, useAtlasSize = true},
	["AmountBorder"] = {formatString = "%s-amount", setVisibility = true, useAtlasSize = true},
}

function UIWidgetBaseSpellTemplateMixin:Setup(widgetContainer, spellInfo, enabledState, width, textureKit)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	SetupTextureKitsFromRegionInfo(textureKit, self, spellTextureKitRegionInfo);

	local hasAmountBorderTexture = self.AmountBorder:IsShown();
	local hasBorderTexture = self.Border:IsShown(); 

	self.StackCount:ClearAllPoints();
	if (hasAmountBorderTexture) then  
		self.StackCount:SetPoint("CENTER", self.AmountBorder);
	else 
		self.StackCount:SetPoint("BOTTOMRIGHT", self.Icon, -2, 2);
	end 

	local name, _, icon = GetSpellInfo(spellInfo.spellID);
	self.Icon:SetTexture(icon);
	self.Icon:SetDesaturated(enabledState == Enum.WidgetEnabledState.Disabled);

	local iconSize = GetIconSize(spellInfo.iconSizeType);
	self.Icon:SetSize(iconSize, iconSize);

	if (not hasBorderTexture) then 
		self.Border:SetAtlas("UI-Frame-IconBorder", false); 
	end 

	local iconWidth = self.Icon:GetWidth();
	local textWidth = 0;
	if width > iconWidth then
		textWidth = width - iconWidth;
	end

	self.Text:SetWidth(textWidth);
	self.Text:SetHeight(0);

	local textShown = spellInfo.textShownState == Enum.SpellDisplayTextShownStateType.Shown;
	self.Text:SetShown(textShown);

	if textShown then
		if spellInfo.text ~= "" then
			self.Text:SetText(spellInfo.text);
		else
			self.Text:SetText(name);
		end
		if textWidth == 0 then
			textWidth = self.Text:GetWidth();
		end
		if self.Text:GetHeight() < self.Icon:GetHeight() then
			self.Text:SetHeight(self.Icon:GetHeight());
		end
		iconWidth = iconWidth + 5;
	end

	if spellInfo.stackDisplay > 0 then
		self.StackCount:Show();
		self.StackCount:SetText(spellInfo.stackDisplay);
	else
		self.StackCount:Hide();
		self.AmountBorder:Hide();
	end

	self.Border:SetShown(spellInfo.iconDisplayType == Enum.SpellDisplayIconDisplayType.Buff or spellInfo.iconDisplayType == Enum.SpellDisplayIconDisplayType.Circular);
	self.DebuffBorder:SetShown(spellInfo.iconDisplayType == Enum.SpellDisplayIconDisplayType.Debuff);
	self.IconMask:SetShown(spellInfo.iconDisplayType ~= Enum.SpellDisplayIconDisplayType.Circular);
	self.CircleMask:SetShown(spellInfo.iconDisplayType == Enum.SpellDisplayIconDisplayType.Circular);

	local widgetHeight = math.max(self.Icon:GetHeight(), self.Text:GetHeight());
	self:SetEnabledState(enabledState);
	self.spellID = spellInfo.spellID;
	self:SetTooltip(spellInfo.tooltip);

	self:SetWidth(math.max(iconWidth + textWidth, 1));
	self:SetHeight(math.max(widgetHeight, 1));
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

function UIWidgetBaseSpellTemplateMixin:SetMouse(disableMouse)
	local useMouse = ((self.tooltip and self.tooltip ~= "") or self.spellID) and not disableMouse;
	self:EnableMouse(useMouse)
	self:SetMouseClickEnabled(false);
end

UIWidgetBaseStatusBarTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

function UIWidgetBaseStatusBarTemplateMixin:Setup(widgetContainer, barMin, barMax, barValue, barValueTextType, tooltip, overrideBarText, overrideBarTextShownType)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
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

function UIWidgetBaseStatusBarTemplateMixin:SetMouse(disableMouse)
	local useMouse = ((self.tooltip and self.tooltip ~= "") or (self.overrideBarText and self.overrideBarText ~= "") or (self.barText and self.barText ~= "")) and not disableMouse;
	self:EnableMouse(useMouse)
	self:SetMouseClickEnabled(false);
end

UIWidgetBaseStateIconTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

function UIWidgetBaseStateIconTemplateMixin:Setup(widgetContainer, textureKit, textureKitFormatter, captureIconInfo)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	if captureIconInfo.iconState == Enum.IconState.ShowState1 then
		SetupTextureKitOnFrame(textureKit, self.Icon, "%s-"..textureKitFormatter.."-state1", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
		self:SetTooltip(captureIconInfo.state1Tooltip);
	elseif captureIconInfo.iconState == Enum.IconState.ShowState2 then
		SetupTextureKitOnFrame(textureKit, self.Icon, "%s-"..textureKitFormatter.."-state2", TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
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

UIWidgetBaseTextureAndTextTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

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
	UIWidgetTemplateTooltipFrameMixin.OnLoad(self);
	self.Text:SetFontObjectsToTry();
end

function UIWidgetBaseTextureAndTextTemplateMixin:Setup(widgetContainer, text, tooltip, frameTextureKit, textureKit, textSizeType, layoutIndex)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
	self.layoutIndex = layoutIndex;

	local bgTextureKitFmt = "%s";
	local fgTextureKitFmt = "%s";

	if layoutIndex then
		if frameTextureKit and C_Texture.GetAtlasInfo(GetFinalNameFromTextureKit("%s_"..layoutIndex, frameTextureKit)) then 
			bgTextureKitFmt = "%s_"..layoutIndex;
		end

		if textureKit and C_Texture.GetAtlasInfo(GetFinalNameFromTextureKit("%s_"..layoutIndex, textureKit)) then 
			fgTextureKitFmt = "%s_"..layoutIndex;
		end
	end

	self.Text:SetFontObject(GetTextSizeFont(textSizeType));

	self.Text:SetText(text);
	self:SetTooltip(tooltip);
	SetupTextureKitOnFrame(frameTextureKit, self.Background, bgTextureKitFmt, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	SetupTextureKitOnFrame(textureKit, self.Foreground, fgTextureKitFmt, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	self:MarkDirty(); -- The widget needs to resize based on whether the textures are shown or hidden
end

UIWidgetBaseControlZoneTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

function UIWidgetBaseControlZoneTemplateMixin:OnLoad()
	UIWidgetTemplateTooltipFrameMixin.OnLoad(self);
	self.Progress:SetFrameLevel(self.UncapturedSection:GetFrameLevel() + 1);
end

local zoneFormatString = "%s-%s-%s";
local cappedFormatString = "%s-%s-%s-cap";
local swipeTextureFormatString = "Interface\\Widgets\\%s-%s-fill";
local edgeTextureFormatString = "Interface\\UnitPowerBarAlt\\%s-spark%s";

local textureKitRegionInfo = {
	["Zone"] = {useAtlasSize = true, setVisibility = true},	-- formatString is filled on before passing to SetupTextureKitsFromRegionInfo (based on whether the zone is capped or not)
	["DangerGlowBackground"] = {formatString = "%s-fallingglow-bg", useAtlasSize = true},
	["DangerGlowOverlay"] = {formatString = "%s-fallingglow", useAtlasSize = true},
	["CapturedGlow"] = {formatString = "%s-fullglow", useAtlasSize = true},
	["CapturedGlowStar"] = {formatString = "%s-starglow", useAtlasSize = true},
}

local PLAY_ANIM = true;
local STOP_ANIM = false;

function UIWidgetBaseControlZoneTemplateMixin:PlayOrStopCapturedAnimation(play)
	if play then
		self.CapturedGlowStar:Show();
		self.CapturedGlow:Show();
		self.CapturedGlowAnim:Play();
	else
		self.CapturedGlowAnim:Stop();
		self.CapturedGlow:Hide();
		self.CapturedGlowStar:Hide();
	end
end

function UIWidgetBaseControlZoneTemplateMixin:PlayOrStopDangerAnimation(play)
	if play then
		self.DangerGlowBackground:Show();
		self.DangerGlowOverlay:Show();
		self.DangerGlowAnim:Play();
	else
		self.DangerGlowAnim:Stop();
		self.DangerGlowBackground:Hide();
		self.DangerGlowOverlay:Hide();
	end
end

function UIWidgetBaseControlZoneTemplateMixin:UpdateAnimations(zoneInfo, zoneIsGood, lastVals, dangerFlashType)
	local isActive = (zoneInfo.activeState == Enum.ZoneControlActiveState.Active);
	local isCaptured = (zoneInfo.current >= zoneInfo.capturePoint);
	local wasCaptured = not lastVals or (lastVals.current >= lastVals.capturePoint);

	if not isActive then
		-- The zone is inactive...turn off all animations
		self:PlayOrStopCapturedAnimation(STOP_ANIM);
		self:PlayOrStopDangerAnimation(STOP_ANIM);
	else
		if zoneIsGood and isCaptured and not wasCaptured then
			-- This is a good zone that just got captured...play the captured animation
			self:PlayOrStopCapturedAnimation(PLAY_ANIM);
		end

		local zoneStateUsesDangerAnim;
		if zoneIsGood then
			zoneStateUsesDangerAnim = (dangerFlashType == Enum.ZoneControlDangerFlashType.ShowOnGoodStates) or (dangerFlashType == Enum.ZoneControlDangerFlashType.ShowOnBoth);
		else
			zoneStateUsesDangerAnim = (dangerFlashType == Enum.ZoneControlDangerFlashType.ShowOnBadStates) or (dangerFlashType == Enum.ZoneControlDangerFlashType.ShowOnBoth);
		end

		if not zoneStateUsesDangerAnim then
			-- This zone doesn't use the danger animation...kill it and return
			self:PlayOrStopDangerAnimation(STOP_ANIM);
			return;
		end

		local playDangerAnim, stopDangerAnim;
		if zoneIsGood then
			playDangerAnim = lastVals and zoneInfo.current < lastVals.current;
			stopDangerAnim = not lastVals or zoneInfo.current > lastVals.current;
		else
			playDangerAnim = lastVals and zoneInfo.current > lastVals.current;
			stopDangerAnim = not lastVals or zoneInfo.current < lastVals.current;
		end

		if playDangerAnim then
			self:PlayOrStopDangerAnimation(PLAY_ANIM);
		elseif stopDangerAnim then
			self:PlayOrStopDangerAnimation(STOP_ANIM);
		end
	end
end

function UIWidgetBaseControlZoneTemplateMixin:Setup(widgetContainer, zoneIndex, zoneMode, leadingEdgeType, dangerFlashType, zoneInfo, lastVals, textureKit)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);
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
	local capturePercentage;
	local reverse;
	if zoneInfo.fillType == Enum.ZoneControlFillType.SingleFillClockwise then
		percentageFull = ClampedPercentageBetween(currentVal, zoneInfo.min, zoneInfo.max);
		capturePercentage = ClampedPercentageBetween(zoneInfo.capturePoint, zoneInfo.min, zoneInfo.max);
		reverse = true;
	elseif zoneInfo.fillType == Enum.ZoneControlFillType.SingleFillCounterClockwise then
		percentageFull = 1 - ClampedPercentageBetween(currentVal, zoneInfo.min, zoneInfo.max);
		capturePercentage = 1 - ClampedPercentageBetween(zoneInfo.capturePoint, zoneInfo.min, zoneInfo.max);
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

	local reverseUncapturedSection = reverse;

	if percentageFull == 1 then
		-- A cooldown at full duration actually draws nothing when what we want is a full bar...to achieve that, flip reverse and set the percentage to 0
		percentageFull = 0;
		reverse = not reverse;
	end

	local edgeColorString = zoneInfo.state == Enum.ZoneControlState.State1 and "blue" or "yellow";
	local edgeTextureName = edgeTextureFormatString:format(unpack({textureKit, edgeColorString}));

	if percentageFull == 0  or leadingEdgeType == Enum.ZoneControlLeadingEdgeType.NoLeadingEdge then
		self.Progress:SetEdgeTexture("", 1, 1, 1, 0);
	else
		self.Progress:SetEdgeTexture(edgeTextureName);
	end

	local zoneIsGood;
	if zoneMode == Enum.ZoneControlMode.BothStatesAreGood then
		zoneIsGood = true;
	elseif zoneMode == Enum.ZoneControlMode.State1IsGood then
		zoneIsGood = (zoneInfo.state == Enum.ZoneControlState.State1);
	elseif zoneMode == Enum.ZoneControlMode.State2IsGood then
		zoneIsGood = (zoneInfo.state == Enum.ZoneControlState.State2);
	else
		zoneIsGood = false;
	end

	local showUncapturedSection = isActive and zoneIsGood and capturePercentage and (zoneInfo.capturePoint > 1);
	self.UncapturedSection:SetShown(showUncapturedSection);
	if showUncapturedSection then
		self.UncapturedSection:SetReverse(reverseUncapturedSection);
		CooldownFrame_SetDisplayAsPercentage(self.UncapturedSection, capturePercentage);
	end

	self.Progress:SetReverse(reverse);
	CooldownFrame_SetDisplayAsPercentage(self.Progress, percentageFull);

	-- Set current to the clamped value
	zoneInfo.current = currentVal;

	-- And update the animations
	self:UpdateAnimations(zoneInfo, zoneIsGood, lastVals, dangerFlashType);

	self:SetTooltip(zoneInfo.tooltip);

	self:MarkDirty(); -- The widget needs to resize based on whether the textures are shown or hidden
end

UIWidgetBaseScenarioHeaderTemplateMixin = {};

local scenarioHeaderTextureKitRegions = {
	["Frame"] = "%s-frame",
}

local scenarioHeaderTextureKitInfo =
{
	["jailerstower-scenario"] = {fontObjects = {GameFontNormalLarge, GameFontNormalHuge}, fontColor = WHITE_FONT_COLOR, textAnchorOffsets = {xOffset = 33, yOffset = -8}},
	["jailerstower-scenario-nodeaths"] = {fontObjects = {GameFontNormalLarge, GameFontNormalHuge}, fontColor = WHITE_FONT_COLOR, textAnchorOffsets = {xOffset = 33, yOffset = -8}},
	["EmberCourtScenario-Tracker"] = {fontObjects = {GameFontNormalMed3, GameFontNormal, GameFontNormalSmall}, headerTextHeight = 20},
}

local scenarioHeaderDefaultFontObjects = {QuestTitleFont, Fancy16Font, SystemFont_Med1};
local scenarioHeaderDefaultFontColor = SCENARIO_STAGE_COLOR;
local scenarioHeaderDefaultTextAnchorOffsets = {xOffset = 15, yOffset = -8};
local scenarioHeaderDefaultHeaderTextHeight = 36;
local scenarioHeaderStageChangeWaitTime = 1.5;

-- This returns true if we are waiting for the stage header to slide out
function UIWidgetBaseScenarioHeaderTemplateMixin:Setup(widgetInfo, widgetContainer)
	self:EnableMouse(false);

	if self.WaitTimer then
		self.latestWidgetInfo = widgetInfo;
		return true;
	end

	local _, currentScenarioStage = C_Scenario.GetInfo();
	if self.lastScenarioStage and self.lastScenarioStage ~= currentScenarioStage then
		-- This widget was already showing and the scenario stage changed since the last time Setup was called
		-- If we update everything now we will be showing the next stage's info
		-- So instead we want to set a timer to give the current stage's header time to slide out

		if self.WaitTimer then
			self.WaitTimer:Cancel();
		end

		self.latestWidgetInfo = widgetInfo;
		self.WaitTimer = C_Timer.NewTimer(scenarioHeaderStageChangeWaitTime, GenerateClosure(self.OnWaitTimerDone, self));
		return true;
	end

	self.lastScenarioStage = currentScenarioStage;

	local textureKitInfo = scenarioHeaderTextureKitInfo[widgetInfo.frameTextureKit];

	local fontObjectsToTry = textureKitInfo and textureKitInfo.fontObjects or scenarioHeaderDefaultFontObjects;
	self.HeaderText:SetFontObjectsToTry(unpack(fontObjectsToTry));

	local fontColor = textureKitInfo and textureKitInfo.fontColor or scenarioHeaderDefaultFontColor;
	self.HeaderText:SetTextColor(fontColor:GetRGB());

	local headerTextHeight = textureKitInfo and textureKitInfo.headerTextHeight or scenarioHeaderDefaultHeaderTextHeight;
	self.HeaderText:SetHeight(headerTextHeight);

	self.HeaderText:SetText(widgetInfo.headerText);

	local textAnchorOffsets = textureKitInfo and textureKitInfo.textAnchorOffsets or scenarioHeaderDefaultTextAnchorOffsets;
	self.HeaderText:SetPoint("TOPLEFT", self, "TOPLEFT", textAnchorOffsets.xOffset, textAnchorOffsets.yOffset);

	SetupTextureKitOnRegions(widgetInfo.frameTextureKit, self, scenarioHeaderTextureKitRegions, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);

	self:SetWidth(self.Frame:GetWidth());
	self:SetHeight(self.Frame:GetHeight());
end

function UIWidgetBaseScenarioHeaderTemplateMixin:OnWaitTimerDone()
	self.WaitTimer = nil;
	
	local _, currentScenarioStage = C_Scenario.GetInfo();
	self.lastScenarioStage = currentScenarioStage;

	self:Setup(self.latestWidgetInfo, self.widgetContainer);
	self.latestWidgetInfo = nil;
end

function UIWidgetBaseScenarioHeaderTemplateMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);

	if self.WaitTimer then
		self.WaitTimer:Cancel();
		self.WaitTimer = nil;
	end

	self.lastScenarioStage = nil;
	self.latestWidgetInfo = nil;
end

UIWidgetBaseCircularStatusBarTemplateMixin = CreateFromMixins(UIWidgetTemplateTooltipFrameMixin);

local circularBarSwipeTextureFormatString = "Interface\\UnitPowerBarAlt\\%s-fill";

function UIWidgetBaseCircularStatusBarTemplateMixin:Setup(widgetContainer, barMin, barMax, barValue, deadZonePercentage, textureKit)
	UIWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);

	barValue = Clamp(barValue, barMin, barMax);

	local currentPercent = ClampedPercentageBetween(barValue, barMin, barMax);

	if deadZonePercentage then
		deadZonePercentage = deadZonePercentage / 2;

		local range = barMax - barMin;
		local newMin = range * deadZonePercentage;
		local newMax = range * (1 - deadZonePercentage);
		local newRange = newMax - newMin;
		local newValue = newMin + newRange * currentPercent;

		currentPercent = newValue / range;
	end

	local swipeTextureName = circularBarSwipeTextureFormatString:format(textureKit);
	self.Progress:SetSwipeTexture(swipeTextureName);

	CooldownFrame_SetDisplayAsPercentage(self.Progress, 1 - currentPercent);
end

UIWidgetBaseTextMixin = CreateFromMixins(UIWidgetBaseEnabledFrameMixin);

local normalFonts =
{
	[Enum.UIWidgetTextSizeType.Small]	= "SystemFont_Med1",
	[Enum.UIWidgetTextSizeType.Medium]	= "SystemFont_Large",
	[Enum.UIWidgetTextSizeType.Large]	= "SystemFont_Huge2",
	[Enum.UIWidgetTextSizeType.Huge]	= "SystemFont_Huge4",
}

local shadowFonts =
{
	[Enum.UIWidgetTextSizeType.Small]	= "SystemFont_Shadow_Med1",
	[Enum.UIWidgetTextSizeType.Medium]	= "SystemFont_Shadow_Large",
	[Enum.UIWidgetTextSizeType.Large]	= "SystemFont_Shadow_Huge2",
	[Enum.UIWidgetTextSizeType.Huge]	= "SystemFont_Shadow_Huge4",
}

local outlineFonts =
{
	[Enum.UIWidgetTextSizeType.Small]	= "SystemFont_Shadow_Med1_Outline",
	[Enum.UIWidgetTextSizeType.Medium]	= "SystemFont_Shadow_Large_Outline",
	[Enum.UIWidgetTextSizeType.Large]	= "SystemFont_Shadow_Huge2_Outline",
	[Enum.UIWidgetTextSizeType.Huge]	= "SystemFont_Shadow_Huge4_Outline",
}

local fontTypes = 
{
	[Enum.UIWidgetFontType.Normal]	= normalFonts,
	[Enum.UIWidgetFontType.Shadow]	= shadowFonts,
	[Enum.UIWidgetFontType.Outline]	= outlineFonts,
}

local function GetTextFont(fontType, textSizeType)
	return fontTypes[fontType][textSizeType];
end

local function GetJustifyH(hAlignType)
	if hAlignType == Enum.WidgetTextHorizontalAlignmentType.Left then
		return "LEFT";
	elseif hAlignType == Enum.WidgetTextHorizontalAlignmentType.Right then
		return "RIGHT";
	else
		return "CENTER";
	end
end

function UIWidgetBaseTextMixin:Setup(text, fontType, textSizeType, enabledState, hAlignType)
	self:SetFontObject(GetTextFont(fontType, textSizeType));
	self:SetJustifyH(GetJustifyH(hAlignType))
	self:SetText(text);
	self:SetEnabledState(enabledState);
end
