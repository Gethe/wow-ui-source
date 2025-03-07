local function GetStatusBarVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.StatusBar, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateStatusBar"}, GetStatusBarVisInfoData);

UIWidgetTemplateStatusBarMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local singleTexKitStrings = {
	["BorderLeft"] = "%s-borderleft",
	["BorderRight"] = "%s-borderright",
	["BorderCenter"] = "%s-bordercenter",
	["SparkMask"] = "%s-spark-mask",
	["GlowLeft"] = "%s-glowleft",
	["GlowRight"] = "%s-glowright",
	["GlowCenter"] = "%s-glowcenter",
};

local doubleTexKitStrings = {
	["BGLeft"] = "%s-bgleft-%s",
	["BGRight"] = "%s-bgright-%s",
	["BGCenter"] = "%s-bgcenter-%s",
	["Spark"] = "%s-spark-%s",
	["BackgroundGlow"] = "%s-backgroundglow-%s",
};

function UIWidgetTemplateStatusBarMixin:SetupTextures()
	-- First set textures that only require frameTextureKit
	SetupTextureKitOnRegions(self.frameTextureKit, self.Bar, singleTexKitStrings, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	-- Then attempt to set textures that have textureKit-specific variants: (frameTextureKit)-x-(textureKit)
	SetupTextureKitOnRegions({self.frameTextureKit, self.textureKit}, self.Bar, doubleTexKitStrings, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	-- Loop through each of these and check if the texture was actually found
	for parentKey, fmt in pairs(doubleTexKitStrings) do
		local childFrame = self.Bar[parentKey];
		if not childFrame:IsShown() then
			-- The (frameTextureKit)-x-(textureKit) texture was not found, fall back to (frameTextureKit)-x
			local singleParamFmt = string.sub(fmt, 1, -4);
			SetupTextureKitOnFrame(self.frameTextureKit, childFrame, singleParamFmt, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize)
		end
	end
end

local barColorFromTintValue = {
	[Enum.StatusBarColorTintValue.Black] = BLACK_FONT_COLOR,
	[Enum.StatusBarColorTintValue.White] = WHITE_FONT_COLOR,
	[Enum.StatusBarColorTintValue.Red] = RED_FONT_COLOR,
	[Enum.StatusBarColorTintValue.Yellow] = YELLOW_FONT_COLOR,
	[Enum.StatusBarColorTintValue.Orange] = ORANGE_FONT_COLOR,
	[Enum.StatusBarColorTintValue.Purple] = EPIC_PURPLE_COLOR,
	[Enum.StatusBarColorTintValue.Green] = GREEN_FONT_COLOR,
	[Enum.StatusBarColorTintValue.Blue] = RARE_BLUE_COLOR,
}

local DEFAULT_BAR_WIDTH = 215;

local textureKitOptions =
{
	["jailerstower-scorebar"] = { borderXOffset = 25 },
	["plunderstorm-stormbar"] = { borderXOffset = 2 },
	["junkyard-scorebar"] = { borderXOffset = 14 },
}

local defaultTextureKitOptions = { borderXOffset = 8 };

function UIWidgetTemplateStatusBarMixin:SanitizeTextureKits(widgetInfo)
	widgetInfo.frameTextureKit = widgetInfo.frameTextureKit or "widgetstatusbar";
	self.frameTextureKit = widgetInfo.frameTextureKit;
	self.textureKit = widgetInfo.textureKit or "white";
end

function UIWidgetTemplateStatusBarMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	self:SanitizeTextureKits(widgetInfo);

	local barColor = barColorFromTintValue[widgetInfo.colorTint];
	if barColor then 
		self.Bar:SetStatusBarColor(barColor:GetRGB());
		self.Bar.Spark:SetVertexColor(barColor:GetRGB());
	else
		self.Bar:SetStatusBarColor(WHITE_FONT_COLOR:GetRGB());
		self.Bar.Spark:SetVertexColor(WHITE_FONT_COLOR:GetRGB());
	end 

	self:SetupTextures(widgetInfo);

	local texKitOptions = textureKitOptions[self.frameTextureKit] or defaultTextureKitOptions;

	self.Bar.BorderLeft:SetPoint("LEFT", self.Bar, -texKitOptions.borderXOffset, 0);
	self.Bar.BorderRight:SetPoint("RIGHT", self.Bar, texKitOptions.borderXOffset , 0);
	self.Bar.Spark:SetPoint("CENTER", self.Bar:GetStatusBarTexture(), "RIGHT", 0, 0);

	local barWidth = (widgetInfo.widgetSizeSetting > 0) and widgetInfo.widgetSizeSetting or DEFAULT_BAR_WIDTH;
	self.Bar:SetWidth(barWidth);

	self.Bar:Setup(widgetContainer, widgetInfo, widgetInfo.tooltipLoc);

	self.Label:Setup(widgetInfo.text, widgetInfo.textFontType, widgetInfo.textSizeType, widgetInfo.textEnabledState);

	local labelWidth = 0;
	local labelHeight = 0;
	self.Bar:ClearAllPoints();
	if widgetInfo.text ~= "" then
		labelWidth = self.Label:GetWidth();
		labelHeight = self.Label:GetHeight() + 3;
		self.Bar:SetPoint("TOP", self.Label, "BOTTOM", 0, -8);
	else
		self.Bar:SetPoint("TOP", self, "TOP", 0, -8);
	end

	local hasGlows = self.Bar.GlowLeft:IsShown() and self.Bar.GlowRight:IsShown() and self.Bar.GlowCenter:IsShown();
	if hasGlows and (widgetInfo.showGlowState == Enum.WidgetShowGlowState.ShowGlow) then
		self.Bar.GlowLeft:Show();
		self.Bar.GlowRight:Show();
		self.Bar.GlowCenter:Show();

		if widgetInfo.glowAnimType == Enum.WidgetGlowAnimType.Pulse then
			self.Bar.GlowPulseAnim:Play();
		else
			self.Bar.GlowPulseAnim:Stop();
			self.Bar.GlowLeft:SetAlpha(1);
			self.Bar.GlowRight:SetAlpha(1);
			self.Bar.GlowCenter:SetAlpha(1);
		end
	else
		self.Bar.GlowPulseAnim:Stop();
		self.Bar.GlowLeft:Hide();
		self.Bar.GlowRight:Hide();
		self.Bar.GlowCenter:Hide();
		self.Bar.GlowLeft:SetAlpha(1);
		self.Bar.GlowRight:SetAlpha(1);
		self.Bar.GlowCenter:SetAlpha(1);
	end

	local totalWidth = math.max(self.Bar:GetWidth() + 16, labelWidth);
	self:SetWidth(totalWidth);

	local barHeight = self.Bar:GetHeight() + 16;

	local totalHeight = barHeight + labelHeight;
	self:SetHeight(totalHeight);

	self:EvaluateTutorials();
end

function UIWidgetTemplateStatusBarMixin:EvaluateTutorials()
	if self.frameTextureKit == "jailerstower-scorebar" then
		local evaluateTutorialsClosure = GenerateClosure(self.EvaluateTutorials, self);

		local barHelpTipInfo = {
			text = TORGHAST_DOMINANCE_BAR_TIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_TORGHAST_DOMINANCE_BAR,
			checkCVars = true,
			autoEdgeFlipping = true;
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			onAcknowledgeCallback = evaluateTutorialsClosure,
		};

		HelpTip:Show(self, barHelpTipInfo);

		if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TORGHAST_DOMINANCE_BAR) and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TORGHAST_DOMINANCE_BAR_CUTOFF) then
			local firstPartition = self.Bar.partitionPool and self.Bar.partitionPool:GetNextActive();
			if firstPartition then
				local cutoffHelpTipInfo = {
					text = TORGHAST_DOMINANCE_BAR_CUTOFF_TIP,
					buttonStyle = HelpTip.ButtonStyle.Close,
					cvarBitfield = "closedInfoFrames",
					bitfieldFlag = LE_FRAME_TUTORIAL_TORGHAST_DOMINANCE_BAR_CUTOFF,
					checkCVars = true,
					targetPoint = HelpTip.Point.BottomEdgeCenter,
					alignment = (ObjectiveTrackerFrame and ObjectiveTrackerFrame.isOnLeftSideOfScreen) and HelpTip.Alignment.Left or HelpTip.Alignment.Right,
				};

				HelpTip:Show(firstPartition, cutoffHelpTipInfo);
			end
		end
	end
end 

function UIWidgetTemplateStatusBarMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.Bar:OnReset();
end
