local function GetCaptureBarVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetCaptureBarWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.CaptureBar, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateCaptureBar"}, GetCaptureBarVisInfoData);

UIWidgetTemplateCaptureBarMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitRegionInfo = {
	["BarBackground"] = {formatString = "%s-frame-%s", useAtlasSize = true},
	["Bar"] = {formatString = "%s-framebar-%s", useAtlasSize = true},
	["LeftBar"] = {formatString = "%s-leftfill-%s"},
	["RightBar"] = {formatString = "%s-rightfill-%s"},
	["NeutralBar"] = {formatString = "%s-neutralfill-%s", useAtlasSize = true},
	["Glow1"] = {formatString = "%s-leftglow-%s", useAtlasSize = true, setVisibility = true},
	["Glow2"] = {formatString = "%s-rightglow-%s", useAtlasSize = true, setVisibility = true},
	["Glow3"] = {formatString = "%s-neutralglow-%s", useAtlasSize = true, setVisibility = true},
	["Spark"] = {formatString = "%s-spark-%s", useAtlasSize = true},
	["SparkNeutral"] = {formatString = "%s-spark-neutral-%s", setVisibility = true},
	["LeftArrow"] = {formatString = "%s-arrow-%s", useAtlasSize = true},
	["RightArrow"] = {formatString = "%s-arrow-%s", useAtlasSize = true},
}

local LEFT_BAR_OFFSET = 25;
local FULL_BAR_SIZE = 124;

local function ConvertToBarPercentage(percent, widgetInfo)
	return (widgetInfo.fillDirectionType == Enum.CaptureBarWidgetFillDirectionType.RightToLeft) and (1 - percent) or percent;
end

function UIWidgetTemplateCaptureBarMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);

	local barPercent = ClampedPercentageBetween(widgetInfo.barValue, widgetInfo.barMinValue, widgetInfo.barMaxValue);

	local neutralZoneSizePercent = ClampedPercentageBetween(widgetInfo.neutralZoneSize, widgetInfo.barMinValue, widgetInfo.barMaxValue);
	local neutralZoneCenterPercent = ClampedPercentageBetween(widgetInfo.neutralZoneCenter, widgetInfo.barMinValue, widgetInfo.barMaxValue);
	local neutralZoneCenterPercentage = ConvertToBarPercentage(neutralZoneCenterPercent, widgetInfo);
	local neutralZonePosition = LEFT_BAR_OFFSET + FULL_BAR_SIZE * neutralZoneCenterPercentage;

	local halfNeutralPercent = neutralZoneSizePercent / 2;

	local leftZoneSizePercentage = neutralZoneCenterPercentage - halfNeutralPercent;
	local rightZoneSizePercentage = (1 - neutralZoneCenterPercentage) - halfNeutralPercent;

	if leftZoneSizePercentage > 0 then
		self.LeftBar:SetWidth(FULL_BAR_SIZE * leftZoneSizePercentage);
		self.LeftBar:Show();
	else
		self.LeftBar:Hide();
	end

	if rightZoneSizePercentage > 0 then
		self.RightBar:SetWidth(FULL_BAR_SIZE * rightZoneSizePercentage);
		self.RightBar:Show();
	else
		self.RightBar:Hide();
	end
	
	local positionPercentage = ConvertToBarPercentage(barPercent, widgetInfo);
	local position = LEFT_BAR_OFFSET + FULL_BAR_SIZE * positionPercentage;
	if ( not self.oldValue ) then
		self.oldValue = position;
	end

	local frameTextureKit = widgetInfo.frameTextureKit;
	local textureKit = widgetInfo.textureKit;

	local isFactionsTextureKit = (frameTextureKit == "factions");
	if isFactionsTextureKit and IsInLFDBattlefield() then
		frameTextureKit = "lfd";
	end

	local textureKits = {textureKit, frameTextureKit};

	SetupTextureKitsFromRegionInfo(textureKits, self, textureKitRegionInfo);

	local hasLeftGlowTexture = self.Glow1:IsShown();
	local hasRightGlowTexture = self.Glow2:IsShown();
	local hasNeutralGlowTexture = self.Glow3:IsShown();
	local hasNeutralSparkTexture = self.SparkNeutral:IsShown(); 
	local neutralFrameOffsetY = 0; 

	if frameTextureKit == "bastionarmor" then 
		neutralFrameOffsetY = -5
		self.Glow3:ClearAllPoints();
		self.Glow3:SetPoint("CENTER", self, "CENTER", 0, neutralFrameOffsetY); 
		self.LeftArrow:ClearAllPoints(); 
		self.RightArrow:ClearAllPoints(); 
		self.LeftArrow:SetPoint("TOPRIGHT", self.Spark, "TOPLEFT", 0, neutralFrameOffsetY);
		self.RightArrow:SetPoint("TOPLEFT", self.Spark, "TOPRIGHT", 0, neutralFrameOffsetY);
	elseif frameTextureKit == "boss" then
		self.Glow1:ClearAllPoints();
		self.Glow1:SetPoint("CENTER", self, "CENTER", 0, 0); 
		self.Glow2:ClearAllPoints();
		self.Glow2:SetPoint("CENTER", self, "CENTER", 0, 0); 
	else
		self.Glow1:ClearAllPoints();
		self.Glow1:SetPoint("LEFT", self, "LEFT", -1, 0); 
		self.Glow2:ClearAllPoints();
		self.Glow2:SetPoint("RIGHT", self, "RIGHT", 1, 0); 
		self.Glow3:ClearAllPoints();
		self.Glow3:SetPoint("CENTER", self, "CENTER", 0, 0); 
		self.LeftArrow:ClearAllPoints(); 
		self.RightArrow:ClearAllPoints(); 
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

	if widgetInfo.glowAnimType == Enum.CaptureBarWidgetGlowAnimType.Pulse then
		self.GlowPulseAnim:Play();
	else
		self.GlowPulseAnim:Stop();
		self.Glow1:SetAlpha(1);
		self.Glow2:SetAlpha(1);
		self.Glow3:SetAlpha(1);
	end

	self.NeutralBar:SetPoint("CENTER", self, "LEFT", neutralZonePosition, neutralFrameOffsetY); 

	-- Setup the size of the neutral bar
	if (neutralZoneSizePercent == 0 ) then
		self.NeutralBar:Hide();
		self.LeftLine:Hide();
		self.RightLine:Hide();
	else
		self.NeutralBar:Show();
		self.NeutralBar:SetWidth(neutralZoneSizePercent * FULL_BAR_SIZE);
		self.LeftLine:Show();
		self.RightLine:Show();
	end

	self.oldValue = position;
	self.Spark:SetPoint("CENTER", self, "LEFT", position, 0);
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