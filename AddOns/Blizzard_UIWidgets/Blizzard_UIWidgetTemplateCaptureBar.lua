local function GetCaptureBarVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetCaptureBarWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.CaptureBar, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateCaptureBar"}, GetCaptureBarVisInfoData);

UIWidgetTemplateCaptureBarMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local PVPTextureKitRegions = {
	["BarBackground"] = "%s-frame-factions",
	["LeftBar"] = "%s-blue",
	["RightBar"] = "%s-red",
	["Middle"] = "%s-spark-yellow",
}

local LFDTextureKitRegions = {
	["BarBackground"] = "%s-frame",
	["LeftBar"] = "%s-yellow",
	["RightBar"] = "%s-purple",
	["Middle"] = "%s-spark-green",
}

local LEFT_BAR_OFFSET = 25;
local FULL_BAR_SIZE = 124;
local MIDDLE_BAR_SIZE = 121;

function UIWidgetTemplateCaptureBarMixin:Setup(widgetInfo)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo);
	local halfNeutralPercent = widgetInfo.neutralPercent / 2;

	local position = LEFT_BAR_OFFSET + FULL_BAR_SIZE * (1 - widgetInfo.barPercent);
	if ( not self.oldValue ) then
		self.oldValue = position;
	end

	local useLFDBattlefieldTextures = IsInLFDBattlefield();
	if ( self.useLFDBattlefieldTextures ~= useLFDBattlefieldTextures ) then
		self.useLFDBattlefieldTextures = useLFDBattlefieldTextures;

		local regions = useLFDBattlefieldTextures and LFDTextureKitRegions or PVPTextureKitRegions;

		local textureKit = GetUITextureKitInfo(widgetInfo.textureKitID);

		SetupTextureKitOnRegions(textureKit, self, regions);
		SetupTextureKitOnRegions(textureKit, self.Indicator, regions);
	end

	-- Left/Right indicators
	if ( position < self.oldValue and widgetInfo.barPercent < 1 ) then
		self.Indicator.Left:Show();
		self.Indicator.Right:Hide();
	elseif ( position > self.oldValue and widgetInfo.barPercent > 0 ) then
		self.Indicator.Left:Hide();
		self.Indicator.Right:Show();
	else
		self.Indicator.Left:Hide();
		self.Indicator.Right:Hide();
	end

	-- Figure out if the ticker is in neutral territory or on a faction's side
	if ( widgetInfo.barPercent > (0.5 + halfNeutralPercent) ) then
		self.LeftIconHighlight:Show();
		self.RightIconHighlight:Hide();
	elseif ( widgetInfo.barPercent < (0.5 - halfNeutralPercent) ) then
		self.LeftIconHighlight:Hide();
		self.RightIconHighlight:Show();
	else
		self.LeftIconHighlight:Hide();
		self.RightIconHighlight:Hide();
	end

	-- Setup the size of the neutral bar
	if ( widgetInfo.neutralPercent == 0 ) then
		self.MiddleBar:SetWidth(1);
		self.LeftLine:Hide();
	else
		self.MiddleBar:SetWidth(widgetInfo.neutralPercent * MIDDLE_BAR_SIZE);
		self.LeftLine:Show();
	end

	self.oldValue = position;
	self.Indicator:SetPoint("CENTER", self, "LEFT", position, 0);
end
