local function GetBulletTextListVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetBulletTextListWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.BulletTextList, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateBulletTextList"}, GetBulletTextListVisInfoData);

UIWidgetTemplateBulletTextListMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateBulletTextListMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self.linePool:ReleaseAll();

	local previousLineFrame;
	local totalHeight = 0;
	for i, line in ipairs(widgetInfo.lines) do
		local lineFrame = self.linePool:Acquire();
		lineFrame:Show();

		lineFrame.Text:SetText(line);
		lineFrame:SetEnabledState(widgetInfo.enabledState)
		lineFrame:SetHeight(lineFrame.Text:GetStringHeight());

		lineFrame:ClearAllPoints();
		if previousLineFrame then
			lineFrame:SetPoint("TOPLEFT", previousLineFrame, "BOTTOMLEFT", 0, -3);
			totalHeight = totalHeight + lineFrame:GetHeight() + 3;
		else
			lineFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
			totalHeight = lineFrame:GetHeight();
		end

		previousLineFrame = lineFrame;
	end

	self:SetHeight(totalHeight);
end

function UIWidgetTemplateBulletTextListMixin:OnLoad()
	self.linePool = CreateFramePool("FRAME", self, "UIWidgetTemplateBulletTextListLine");
end

function UIWidgetTemplateBulletTextListMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.linePool:ReleaseAll();
end

function UIWidgetTemplateBulletTextListMixin:CustomDebugSetup(color)
	for line in self.linePool:EnumerateActive() do
		if not line._debugBGTex then
			line._debugBGTex = line:CreateTexture()
			line._debugBGTex:SetColorTexture(color:GetRGBA());
			line._debugBGTex:SetAllPoints(line);
		end
	end
end

UIWidgetTemplateBulletTextListLineMixin = {};

function UIWidgetTemplateBulletTextListLineMixin:SetEnabledState(enabledState)
	self.Bullet:SetEnabledState(enabledState);
	self.Text:SetEnabledState(enabledState);
end
