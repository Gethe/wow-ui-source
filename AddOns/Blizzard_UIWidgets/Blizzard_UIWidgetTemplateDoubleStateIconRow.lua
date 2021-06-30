local function GetDoubleStateIconRowVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetDoubleStateIconRowVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.DoubleStateIconRow, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateDoubleStateIconRow"}, GetDoubleStateIconRowVisInfoData);

UIWidgetTemplateDoubleStateIconRowMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateDoubleStateIconRowMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self.iconPool:ReleaseAll();

	local leftAligned = true;
	local biggestLeftHeight, totalLeftWidth = self:SetupIcons(widgetContainer, widgetInfo.leftIcons, widgetInfo.textureKit, leftAligned, widgetInfo.tooltipLoc);

	local rightAligned = false;
	local biggestRightHeight, totalRightWidth = self:SetupIcons(widgetContainer, widgetInfo.rightIcons, widgetInfo.textureKit, rightAligned, widgetInfo.tooltipLoc);

	local biggestHeight = math.max(biggestLeftHeight, biggestRightHeight);
	biggestHeight = math.max(biggestHeight, 1);

	local maxWidth = math.max(totalLeftWidth, totalRightWidth);
	local totalWidth = maxWidth * 2;
	totalWidth = math.max(totalWidth, 1);

	self:SetWidth(totalWidth);
	self:SetHeight(biggestHeight);
end

function UIWidgetTemplateDoubleStateIconRowMixin:SetupIcons(widgetContainer, icons, textureKit, leftAlign, tooltipLoc)
	local previousIconFrame;
	local biggestHeight = 0;
	local totalWidth = 0;

	local anchorPt;
	local relAnchorPt;
	local textureKitFormatter;

	if leftAlign then
		anchorPt = "TOPRIGHT";
		relAnchorPt = "TOPLEFT";
		textureKitFormatter = "leftIcon";
	else
		anchorPt = "TOPLEFT";
		relAnchorPt = "TOPRIGHT";
		textureKitFormatter = "rightIcon";
	end

	for index, iconInfo in ipairs(icons) do
		local iconFrame = self.iconPool:Acquire();
		local iconShowing = iconFrame:Setup(widgetContainer, textureKit, textureKitFormatter..index, iconInfo);

		if iconShowing then
			if previousIconFrame then
				iconFrame:SetPoint(anchorPt, previousIconFrame, relAnchorPt, NegateIf(1, leftAlign), 0);
				totalWidth = totalWidth + iconFrame:GetWidth() + 1;
			else
				iconFrame:SetPoint(anchorPt, self, "TOP", NegateIf(7, leftAlign), 0);
				totalWidth = totalWidth + iconFrame:GetWidth() + 7;
			end

			previousIconFrame = iconFrame;

			biggestHeight = math.max(biggestHeight, iconFrame:GetHeight());

			iconFrame:SetTooltipLocation(tooltipLoc);
		end
	end

	return biggestHeight, totalWidth;
end

function UIWidgetTemplateDoubleStateIconRowMixin:OnLoad()
	self.iconPool = CreateFramePool("FRAME", self, "UIWidgetBaseStateIconTemplate");
end

function UIWidgetTemplateDoubleStateIconRowMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.iconPool:ReleaseAll();
end
