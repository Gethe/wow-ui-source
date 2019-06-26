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
	["LeftBar"] = {formatString = "%s-leftfill-%s"},
	["RightBar"] = {formatString = "%s-rightfill-%s"},
	["NeutralBar"] = {formatString = "%s-neutralfill-%s"},
	["Glow1"] = {formatString = "%s-leftglow-%s", useAtlasSize = true, setVisibility = true},
	["Glow2"] = {formatString = "%s-rightglow-%s", useAtlasSize = true, setVisibility = true},
	["Spark"] = {formatString = "%s-spark-%s", useAtlasSize = true},
}

local LEFT_BAR_OFFSET = 25;
local FULL_BAR_SIZE = 124;

function UIWidgetTemplateCaptureBarMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);

	local barPercent = ClampedPercentageBetween(widgetInfo.barValue, widgetInfo.barMinValue, widgetInfo.barMaxValue);

	local neutralZoneSizePercent = ClampedPercentageBetween(widgetInfo.neutralZoneSize, widgetInfo.barMinValue, widgetInfo.barMaxValue);
	local neutralZoneCenterPercent = ClampedPercentageBetween(widgetInfo.neutralZoneCenter, widgetInfo.barMinValue, widgetInfo.barMaxValue);
	local neutralZonePosition = LEFT_BAR_OFFSET + FULL_BAR_SIZE * (1 - neutralZoneCenterPercent);

	local halfNeutralPercent = neutralZoneSizePercent / 2;

	local leftZoneSizePercent = (1 - neutralZoneCenterPercent) - halfNeutralPercent;
	local rightZoneSizePercent = neutralZoneCenterPercent - halfNeutralPercent;

	if leftZoneSizePercent > 0 then
		self.LeftBar:SetWidth(FULL_BAR_SIZE * leftZoneSizePercent);
		self.LeftBar:Show();
	else
		self.LeftBar:Hide();
	end

	if rightZoneSizePercent > 0 then
		self.RightBar:SetWidth(FULL_BAR_SIZE * rightZoneSizePercent);
		self.RightBar:Show();
	else
		self.RightBar:Hide();
	end
	
	local position = LEFT_BAR_OFFSET + FULL_BAR_SIZE * (1 - barPercent);
	if ( not self.oldValue ) then
		self.oldValue = position;
	end

	local frameTextureKit = GetUITextureKitInfo(widgetInfo.frameTextureKitID);
	local textureKit = GetUITextureKitInfo(widgetInfo.textureKitID);

	local isFactionsTextureKit = (frameTextureKit == "factions");
	if isFactionsTextureKit and IsInLFDBattlefield() then
		frameTextureKit = "lfd";
	end

	local textureKits = {textureKit, frameTextureKit};

	SetupTextureKitsFromRegionInfo(textureKits, self, textureKitRegionInfo);

	local hasLeftGlow = self.Glow1:IsShown();
	local hasRightGlow = self.Glow2:IsShown();

	if frameTextureKit == "boss" then
		self.Glow1:ClearAllPoints();
		self.Glow1:SetPoint("CENTER", self, "CENTER", 0, 0); 
		self.Glow2:ClearAllPoints();
		self.Glow2:SetPoint("CENTER", self, "CENTER", 0, 0); 
	else
		self.Glow1:ClearAllPoints();
		self.Glow1:SetPoint("LEFT", self, "LEFT", -1, 0); 
		self.Glow2:ClearAllPoints();
		self.Glow2:SetPoint("RIGHT", self, "RIGHT", 1, 0); 
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
	local inLeftZone = barPercent > (neutralZoneCenterPercent + halfNeutralPercent);
	local inRightZone = barPercent < (neutralZoneCenterPercent - halfNeutralPercent);
	local inNeutralZone = not inLeftZone and not inRightZone;

	if inNeutralZone and neutralZoneSizePercent == 0 then
		-- A neutral zone of size 0 is a special case because we never want to be in the neutral zone
		-- Use the direction of movement to try to figure out which zone to go into
		if movedLeft then
			-- If we just moved left, favor the left zone
			inLeftZone = barPercent >= neutralZoneCenterPercent;
			inRightZone = not inLeftZone;
		elseif movedRight then
			-- If we just moved right, favor the right zone
			inRightZone = barPercent <= neutralZoneCenterPercent;
			inLeftZone = not inRightZone;
		else
			-- Otherwise just pick the bigger zone
			if leftZoneSizePercent ~= rightZoneSizePercent then
				inLeftZone = leftZoneSizePercent > rightZoneSizePercent;
				inRightZone = not inLeftZone;
			else
				-- If they are both the same size then just pick the left side (shrug)
				inLeftZone = true;
			end
		end
	end

	if inLeftZone then
		self.Glow1:SetShown(hasLeftGlow);
		self.Glow2:Hide();
	elseif inRightZone then
		self.Glow1:Hide();
		self.Glow2:SetShown(hasRightGlow);
	else
		self.Glow1:Hide();
		self.Glow2:Hide();
	end

	if widgetInfo.glowAnimType == Enum.CaptureBarWidgetGlowAnimType.Pulse then
		self.GlowPulseAnim:Play();
	else
		self.GlowPulseAnim:Stop();
		self.Glow1:SetAlpha(1);
		self.Glow2:SetAlpha(1);
	end

	self.NeutralBar:SetPoint("CENTER", self, "LEFT", neutralZonePosition, 0); 

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
end

function UIWidgetTemplateCaptureBarMixin:AnimOut()
	self.LeftArrowAnim:Stop();
	self.RightArrowAnim:Stop();
	self.GlowPulseAnim:Stop();
	self.Glow1:Hide();
	self.Glow2:Hide();
	UIWidgetBaseTemplateMixin.AnimOut(self);
end