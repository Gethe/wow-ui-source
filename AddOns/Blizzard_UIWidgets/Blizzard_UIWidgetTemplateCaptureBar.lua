local function GetCaptureBarVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetCaptureBarWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.CaptureBar, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateCaptureBar"}, GetCaptureBarVisInfoData);

UIWidgetTemplateCaptureBarMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitRegionInfo = {
	["BarBackground"] = {formatString = "%s-frame-%s", useAtlasSize = true, setVisibility = true},
	["Bar"] = {formatString = "%s-framebar-%s", useAtlasSize = true, setVisibility = true},
	["LeftBar"] = {formatString = "%s-leftfill-%s", setVisibility = true},
	["LeftBarShadow"] = {formatString = "%s-leftfill-shadow-%s", setVisibility = true},
	["RightBar"] = {formatString = "%s-rightfill-%s", setVisibility = true},
	["RightBarShadow"] = {formatString = "%s-rightfill-shadow-%s", setVisibility = true},
	["Divider"] = {formatString = "%s-divider-%s", useAtlasSize = true, setVisibility = true},
	["NeutralBar"] = {formatString = "%s-neutralfill-%s", useAtlasSize = true},
	["Glow1"] = {formatString = "%s-leftglow-%s", useAtlasSize = true, setVisibility = true},
	["Glow2"] = {formatString = "%s-rightglow-%s", useAtlasSize = true, setVisibility = true},
	["Glow3"] = {formatString = "%s-neutralglow-%s", useAtlasSize = true, setVisibility = true},
	["Spark"] = {formatString = "%s-spark-%s", useAtlasSize = true},
	["SparkNeutral"] = {formatString = "%s-spark-neutral-%s", useAtlasSize = true, setVisibility = true},
	["LeftArrow"] = {formatString = "%s-arrow-%s", useAtlasSize = true},
	["RightArrow"] = {formatString = "%s-arrow-%s", useAtlasSize = true},
}

local textureKitBarInfo = 
{
	["bastionarmor"] = {barOffset = 28, barWidth = 139, barHeight = 37},
}

local defaultBarInfo = {barOffset = 36, barWidth = 124, barHeight = 26};

local function ConvertToBarPercentage(percent, widgetInfo)
	return (widgetInfo.fillDirectionType == Enum.CaptureBarWidgetFillDirectionType.RightToLeft) and (1 - percent) or percent;
end

function UIWidgetTemplateCaptureBarMixin:AdjustCaptureBarShadows(inLeftZone, inRightZone)
	if inLeftZone or inRightZone then
		self.LeftBar:SetShown(inLeftZone or not self.hasLeftBarShadow);
		self.LeftBarShadow:SetShown(inRightZone and self.hasLeftBarShadow);

		self.RightBar:SetShown(inRightZone or not self.hasRightBarShadow);
		self.RightBarShadow:SetShown(inLeftZone and self.hasRightBarShadow);
	else
		self.LeftBar:Show();
		self.LeftBarShadow:Hide();
		self.RightBar:Show();
		self.RightBarShadow:Hide();
	end
end

function UIWidgetTemplateCaptureBarMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);

	local frameTextureKit = widgetInfo.frameTextureKit;
	local textureKit = widgetInfo.textureKit;

	local isFactionsTextureKit = (frameTextureKit == "factions");
	if isFactionsTextureKit and IsInLFDBattlefield() then
		frameTextureKit = "lfd";
	end

	local barInfo = textureKitBarInfo[frameTextureKit] or defaultBarInfo;

	self:SetHeight(barInfo.barHeight);

	local barPercent = ClampedPercentageBetween(widgetInfo.barValue, widgetInfo.barMinValue, widgetInfo.barMaxValue);

	local neutralZoneSizePercent = ClampedPercentageBetween(widgetInfo.neutralZoneSize, widgetInfo.barMinValue, widgetInfo.barMaxValue);
	local neutralZoneCenterPercent = ClampedPercentageBetween(widgetInfo.neutralZoneCenter, widgetInfo.barMinValue, widgetInfo.barMaxValue);
	local neutralZoneCenterPercentage = ConvertToBarPercentage(neutralZoneCenterPercent, widgetInfo);
	local neutralZonePosition = barInfo.barOffset + barInfo.barWidth * neutralZoneCenterPercentage;

	local halfNeutralPercent = neutralZoneSizePercent / 2;

	local leftZoneSizePercentage = neutralZoneCenterPercentage - halfNeutralPercent;
	local rightZoneSizePercentage = (1 - neutralZoneCenterPercentage) - halfNeutralPercent;

	if leftZoneSizePercentage > 0 then
		local size = barInfo.barWidth * leftZoneSizePercentage;
		self.LeftBar:SetWidth(size);
		self.LeftBarShadow:SetWidth(size);

		self.LeftBar:SetPoint("LEFT", self, "LEFT", barInfo.barOffset, 0);
		self.LeftBarShadow:SetPoint("LEFT", self, "LEFT", barInfo.barOffset, 0);

		self.LeftBar:Show();
	else
		self.LeftBar:Hide();
	end

	if rightZoneSizePercentage > 0 then
		local size = barInfo.barWidth * rightZoneSizePercentage;
		self.RightBar:SetWidth(size);
		self.RightBarShadow:SetWidth(size);

		self.RightBar:SetPoint("RIGHT", self, "RIGHT", -barInfo.barOffset, 0);
		self.RightBarShadow:SetPoint("RIGHT", self, "RIGHT", -barInfo.barOffset, 0);

		self.RightBar:Show();
	else
		self.RightBar:Hide();
	end
	
	local positionPercentage = ConvertToBarPercentage(barPercent, widgetInfo);
	local position = barInfo.barOffset + barInfo.barWidth * positionPercentage;
	if ( not self.oldValue ) then
		self.oldValue = position;
	end

	local textureKits = {textureKit, frameTextureKit};

	SetupTextureKitsFromRegionInfo(textureKits, self, textureKitRegionInfo);

	local hasLeftGlowTexture = self.Glow1:IsShown();
	local hasRightGlowTexture = self.Glow2:IsShown();
	local hasNeutralGlowTexture = self.Glow3:IsShown();
	local hasNeutralSparkTexture = self.SparkNeutral:IsShown();
	self.hasLeftBarShadow = self.LeftBarShadow:IsShown();
	self.hasRightBarShadow = self.RightBarShadow:IsShown();
	local hasDivider = self.Divider:IsShown();
	local neutralFrameOffsetY = 0; 

	self.LeftArrow:ClearAllPoints(); 
	self.RightArrow:ClearAllPoints(); 

	if frameTextureKit == "bastionarmor" then 
		neutralFrameOffsetY = 2
		self.LeftArrow:SetPoint("TOPRIGHT", self.Spark, "TOPLEFT", 2, -7);
		self.RightArrow:SetPoint("TOPLEFT", self.Spark, "TOPRIGHT", -2, -7);
	elseif frameTextureKit == "boss" then
		self.Glow1:ClearAllPoints();
		self.Glow1:SetPoint("CENTER", self, "CENTER", 0, 0); 
		self.Glow2:ClearAllPoints();
		self.Glow2:SetPoint("CENTER", self, "CENTER", 0, 0); 
		self.LeftArrow:SetPoint("RIGHT", self.Spark, "LEFT", 1, 0);
		self.RightArrow:SetPoint("LEFT", self.Spark, "RIGHT", -1, 0);
	else
		self.Glow1:ClearAllPoints();
		self.Glow1:SetPoint("LEFT", self, "LEFT", 11, 0); 
		self.Glow2:ClearAllPoints();
		self.Glow2:SetPoint("RIGHT", self, "RIGHT", -11, 0); 
		self.Glow3:ClearAllPoints();
		self.Glow3:SetPoint("CENTER", self, "CENTER", 0, 0); 
		self.LeftArrow:SetPoint("RIGHT", self.Spark, "LEFT", 1, 0);
		self.RightArrow:SetPoint("LEFT", self.Spark, "RIGHT", -1, 0);
	end

	local movedLeft = (position < self.oldValue);
	local movedRight = (position > self.oldValue);

	-- Left/Right arrows
	if ( position < self.oldValue ) then
		self.LeftArrowAnim:Play();
		self.RightArrowAnim:Stop();
		self.RightArrow:SetAlpha(0);
	elseif ( position > self.oldValue ) then
		self.LeftArrowAnim:Stop();
		self.LeftArrow:SetAlpha(0);
		self.RightArrowAnim:Play();
	else
		self.LeftArrowAnim:Stop();
		self.LeftArrow:SetAlpha(0);
		self.RightArrowAnim:Stop();
		self.RightArrow:SetAlpha(0);
	end

	-- Figure out if the ticker is in neutral territory or on a faction's side
	-- Favor the neutral zone (if on either line we are in the neutral zone)
	local inLeftZone = positionPercentage < (neutralZoneCenterPercentage - halfNeutralPercent);
	local inRightZone = positionPercentage > (neutralZoneCenterPercentage + halfNeutralPercent);
	local inNeutralZone = not inLeftZone and not inRightZone;

	if inNeutralZone and neutralZoneSizePercent == 0 then
		-- A neutral zone of size 0 is a special case because we never want to be in the neutral zone
		-- Use the direction of movement to try to figure out which zone to go into
		if movedLeft then
			-- If we just moved left, favor the left zone
			inLeftZone = positionPercentage >= neutralZoneCenterPercentage;
			inRightZone = not inLeftZone;
		elseif movedRight then
			-- If we just moved right, favor the right zone
			inRightZone = positionPercentage <= neutralZoneCenterPercentage;
			inLeftZone = not inRightZone;
		else
			-- Otherwise just pick the bigger zone
			if leftZoneSizePercentage ~= rightZoneSizePercentage then
				inLeftZone = leftZoneSizePercentage > rightZoneSizePercentage;
				inRightZone = not inLeftZone;
			else
				-- If they are both the same size then just pick the left side (shrug)
				inLeftZone = true;
			end
		end
	end

	if inLeftZone then
		self.Glow1:SetShown(hasLeftGlowTexture);
		self.Glow2:Hide();
		self.Glow3:Hide();
	elseif inRightZone then
		self.Glow1:Hide();
		self.Glow2:SetShown(hasRightGlowTexture);
		self.Glow3:Hide();
	elseif inNeutralZone then
		self.Glow1:Hide();
		self.Glow2:Hide();
		self.Glow3:SetShown(hasNeutralGlowTexture);
	else
		self.Glow1:Hide();
		self.Glow2:Hide();
		self.Glow3:Hide();
	end
	self:AdjustCaptureBarShadows(inLeftZone, inRightZone)

	if widgetInfo.glowAnimType == Enum.CaptureBarWidgetGlowAnimType.Pulse then
		self.GlowPulseAnim:Play();
	else
		self.GlowPulseAnim:Stop();
		self.Glow1:SetAlpha(1);
		self.Glow2:SetAlpha(1);
		self.Glow3:SetAlpha(1);
	end

	self.NeutralBar:SetPoint("CENTER", self, "LEFT", neutralZonePosition, 0); 

	-- Setup the size of the neutral bar
	if (neutralZoneSizePercent == 0 ) then
		self.NeutralBar:Hide();
		self.LeftLine:Hide();
		self.RightLine:Hide();
		if hasDivider then
			self.Divider:Show();
		end
	else
		self.NeutralBar:Show();
		self.NeutralBar:SetWidth(neutralZoneSizePercent * barInfo.barWidth);
		self.LeftLine:SetShown(frameTextureKit ~= "bastionarmor");
		self.RightLine:SetShown(frameTextureKit ~= "bastionarmor");
		self.Divider:Hide();
	end

	self.oldValue = position;
	self.SparkNeutral:SetPoint("CENTER", self, "LEFT", position, neutralFrameOffsetY);
	self.Spark:SetPoint("CENTER", self, "LEFT", position, neutralFrameOffsetY);
	self.SparkNeutral:SetShown(hasNeutralSparkTexture and inNeutralZone); 
	self.Spark:SetShown(not hasNeutralSparkTexture or not inNeutralZone); 
end

function UIWidgetTemplateCaptureBarMixin:AnimOut()
	self.LeftArrowAnim:Stop();
	self.RightArrowAnim:Stop();
	self.GlowPulseAnim:Stop();
	self.Glow1:Hide();
	self.Glow2:Hide();
	self.Glow3:Hide();
	UIWidgetBaseTemplateMixin.AnimOut(self);
end