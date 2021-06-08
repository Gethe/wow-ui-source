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
	["BackgroundGlow"] = "%s-BackgroundGlow",
	["GlowLeft"] = "%s-Glow-BorderLeft",
	["GlowRight"] = "%s-Glow-BorderRight",
	["GlowCenter"] = "%s-Glow-BorderCenter",
}

local backgroundGlowTextureKitString = "%s-BackgroundGlow";
local partitionTextureKitString = "%s-BorderTick";

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

function UIWidgetTemplateStatusBarMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	local frameTextureKit = widgetInfo.frameTextureKit;
	local fillTextureKit = widgetInfo.textureKit;
	if frameTextureKit and fillTextureKit then
		local fillAtlas = fillTextureKitFormatString:format(frameTextureKit, fillTextureKit);
		self.Bar:SetStatusBarAtlas(fillAtlas);
	end

	self.isJailersTowerBar = IsJailersTowerTextureKit(frameTextureKit);

	local overrideHeight = nil;
	local barColor = barColorFromTintValue[widgetInfo.colorTint];
	if(barColor) then 
		self.Bar:SetStatusBarColor(barColor:GetRGB());
		self.Bar.Spark:SetVertexColor(barColor:GetRGB());
	end 

	SetupTextureKitOnRegions(frameTextureKit, self.Bar, textureKitRegionFormatStrings, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	local borderXOffset = self.isJailersTowerBar and 13 or 8;
	self.Bar.BorderLeft:SetPoint("LEFT", self.Bar,  -borderXOffset, 0);
	self.Bar.BorderRight:SetPoint("RIGHT", self.Bar, borderXOffset , 0);

	local barWidth = (widgetInfo.widgetSizeSetting > 0) and widgetInfo.widgetSizeSetting or DEFAULT_BAR_WIDTH;
	self.Bar:SetWidth(barWidth);

	local minVal, maxVal, barVal = widgetInfo.barMin, widgetInfo.barMax, widgetInfo.barValue;
	if minVal > 0 and minVal == maxVal and barVal == maxVal then
		-- If all 3 values are the same and greater than 0, show the bar as full
		minVal, maxVal, barVal = 0, 1, 1;
	end

	self.Bar:Setup(widgetContainer, minVal, maxVal, barVal, widgetInfo.barValueTextType, widgetInfo.tooltip, widgetInfo.overrideBarText, widgetInfo.overrideBarTextShownType);
	self.Bar:SetTooltipLocation(widgetInfo.tooltipLoc);

	local showSpark = widgetInfo.barValue > widgetInfo.barMin and widgetInfo.barValue < widgetInfo.barMax;
	self.Bar.Spark:SetShown(showSpark);
	if showSpark then
		self.Bar.Spark:ClearAllPoints();
		self.Bar.Spark:SetPoint("CENTER", self.Bar:GetStatusBarTexture(), "RIGHT", 0, 0);
	end

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

	self.partitionPool:ReleaseAll();
	local backgroundGlowAtlas = backgroundGlowTextureKitString:format(frameTextureKit);
	local backgroundGlowAtlasInfo = C_Texture.GetAtlasInfo(backgroundGlowAtlas);
	self.Bar.BackgroundGlow:SetShown(backgroundGlowAtlasInfo);

	local hasSoloPartition = (#widgetInfo.partitionValues == 1);
	self.soloPartitionXOffset = nil;

	local paritionAtlas = partitionTextureKitString:format(frameTextureKit);
	local partitionAtlasInfo =  C_Texture.GetAtlasInfo(paritionAtlas);
	for _, partitionValue in ipairs(widgetInfo.partitionValues) do
		if partitionAtlasInfo then
			local partitionTexture = self.partitionPool:Acquire();

			local useAtlasSize = true;
			partitionTexture:SetAtlas(paritionAtlas, useAtlasSize);

			local partitionPercent = ClampedPercentageBetween(partitionValue, minVal, maxVal);
			local xOffset = barWidth * partitionPercent;

			partitionTexture:SetPoint("CENTER", self.Bar:GetStatusBarTexture(), "LEFT", xOffset, 0);
			partitionTexture:Show();

			if hasSoloPartition then
				self.soloPartitionXOffset = xOffset - (barWidth / 2);
			end
		end
	end

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

		if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TORGHAST_DOMINANCE_BAR) and self.soloPartitionXOffset then
			local cutoffHelpTipInfo = {
				text = TORGHAST_DOMINANCE_BAR_CUTOFF_TIP,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_TORGHAST_DOMINANCE_BAR_CUTOFF,
				checkCVars = true,
				targetPoint = HelpTip.Point.BottomEdgeCenter,
				alignment = (self.soloPartitionXOffset > 0) and HelpTip.Alignment.Right or HelpTip.Alignment.Center,
				offsetX = self.soloPartitionXOffset,
			};
		
			HelpTip:Show(self, cutoffHelpTipInfo);
		end
	end
end 

function UIWidgetTemplateStatusBarMixin:OnLoad()
	UIWidgetBaseTemplateMixin.OnLoad(self);
	self.partitionPool = CreateTexturePool(self.Bar, "OVERLAY");
end

function UIWidgetTemplateStatusBarMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.partitionPool:ReleaseAll();
end
