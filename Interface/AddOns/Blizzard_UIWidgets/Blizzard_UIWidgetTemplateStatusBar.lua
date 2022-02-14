local function GetStatusBarVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.StatusBar, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateStatusBar"}, GetStatusBarVisInfoData);

UIWidgetTemplateStatusBarMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitRegionFormatStrings = {
	["BorderLeft"] = "%s-BorderLeft",
	["BorderRight"] = "%s-BorderRight",
	["BorderCenter"] = "%s-BorderCenter",
	["BGLeft"] = "%s-BGLeft",
	["BGRight"] = "%s-BGRight",
	["BGCenter"] = "%s-BGCenter",
	["Spark"] = "%s-Spark",
	["SparkMask"] = "%s-spark-mask",
	["BackgroundGlow"] = "%s-BackgroundGlow",
	["GlowLeft"] = "%s-Glow-BorderLeft",
	["GlowRight"] = "%s-Glow-BorderRight",
	["GlowCenter"] = "%s-Glow-BorderCenter",
}

local backgroundGlowTextureKitString = "%s-BackgroundGlow";

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

local fillTextureKitFormatString = "%s-Fill-%s";
local DEFAULT_BAR_WIDTH = 215;

local function IsJailersTowerTextureKit(textureKit)
	return string.sub(textureKit, 1, 21) == "jailerstower-scorebar";
end

function UIWidgetTemplateStatusBarMixin:SanitizeTextureKits(widgetInfo)
	widgetInfo.frameTextureKit = widgetInfo.frameTextureKit or "widgetstatusbar";
	widgetInfo.fillTextureKit = widgetInfo.textureKit or "white";
end

function UIWidgetTemplateStatusBarMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	self:SanitizeTextureKits(widgetInfo);

	local fillAtlas = fillTextureKitFormatString:format(widgetInfo.frameTextureKit, widgetInfo.fillTextureKit);
	local fillAtlasInfo = C_Texture.GetAtlasInfo(fillAtlas);
	if fillAtlasInfo then
		self.Bar:SetStatusBarAtlas(fillAtlas);
		self.Bar:SetHeight(fillAtlasInfo.height);
		self.Bar:GetStatusBarTexture():SetHorizTile(fillAtlasInfo.tilesHorizontally);
	end

	self.isJailersTowerBar = IsJailersTowerTextureKit(widgetInfo.frameTextureKit);

	local overrideHeight = nil;
	local barColor = barColorFromTintValue[widgetInfo.colorTint];
	if(barColor) then 
		self.Bar:SetStatusBarColor(barColor:GetRGB());
		self.Bar.Spark:SetVertexColor(barColor:GetRGB());
	end 

	SetupTextureKitOnRegions(widgetInfo.frameTextureKit, self.Bar, textureKitRegionFormatStrings, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	local borderXOffset = self.isJailersTowerBar and 13 or 8;
	self.Bar.BorderLeft:SetPoint("LEFT", self.Bar,  -borderXOffset, 0);
	self.Bar.BorderRight:SetPoint("RIGHT", self.Bar, borderXOffset , 0);
	self.Bar.Spark:SetPoint("CENTER", self.Bar:GetStatusBarTexture(), "RIGHT", 0, 0);

	local barWidth = (widgetInfo.widgetSizeSetting > 0) and widgetInfo.widgetSizeSetting or DEFAULT_BAR_WIDTH;
	self.Bar:SetWidth(barWidth);

	self.Bar:Setup(widgetContainer, widgetInfo);
	self.Bar:SetTooltipLocation(widgetInfo.tooltipLoc);

	self.Label:SetText(widgetInfo.text);

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

	local backgroundGlowAtlas = backgroundGlowTextureKitString:format(widgetInfo.frameTextureKit);
	local backgroundGlowAtlasInfo = C_Texture.GetAtlasInfo(backgroundGlowAtlas);
	self.Bar.BackgroundGlow:SetShown(backgroundGlowAtlasInfo);

	local totalWidth = math.max(self.Bar:GetWidth() + 16, labelWidth);
	self:SetWidth(totalWidth);

	local barHeight = overrideHeight ~= nil and overrideHeight or (self.Bar:GetHeight() + 16);

	local totalHeight = barHeight + labelHeight;
	self:SetHeight(totalHeight);

	self:EvaluateTutorials();
end

function UIWidgetTemplateStatusBarMixin:EvaluateTutorials()
	if self.isJailersTowerBar then
		local evaluateTutorialsClosure = GenerateClosure(self.EvaluateTutorials, self);

		local barHelpTipInfo = {
			text = TORGHAST_DOMINANCE_BAR_TIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_TORGHAST_DOMINANCE_BAR,
			checkCVars = true,
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
					alignment = HelpTip.Alignment.Right,
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
