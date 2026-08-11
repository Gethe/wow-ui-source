local function GetButtonHeaderVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetButtonHeaderWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.ButtonHeader, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateButtonHeader"}, GetButtonHeaderVisInfoData);

UIWidgetTemplateButtonHeaderMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

local textureKitRegions = {
	["Frame"] = "%s-frame",
}

local textureKitAnchorInfo = {
	["evergreen-scenario-widget-short"] = {
		buttonContainer = { point = "RIGHT", xOffset = -13, yOffset = 0 },
		headerText = { point = "LEFT", xOffset = 12, yOffset = 0 },
	},
};

local defaultAnchorInfo = {
	buttonContainer = { point = "BOTTOMRIGHT", xOffset = -13, yOffset = 9 },
	headerText = { point = "LEFT", xOffset = 21, yOffset = 0 },
};

function UIWidgetTemplateButtonHeaderMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	self:SetTooltip(widgetInfo.tooltip);
	self.HeaderText:SetText(widgetInfo.headerText);

	SetupTextureKitOnRegions(widgetInfo.frameTextureKit, self, textureKitRegions, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);

	local anchorInfo = textureKitAnchorInfo[widgetInfo.frameTextureKit] or defaultAnchorInfo;

	self.ButtonContainer:ClearAllPoints();
	self.ButtonContainer:SetPoint(anchorInfo.buttonContainer.point, self, anchorInfo.buttonContainer.point, anchorInfo.buttonContainer.xOffset, anchorInfo.buttonContainer.yOffset);

	self.HeaderText:SetPoint(anchorInfo.headerText.point, self, anchorInfo.headerText.point, anchorInfo.headerText.xOffset, anchorInfo.headerText.yOffset);

	self.buttonPool:ReleaseAll();

	for index, buttonInfo in ipairs(widgetInfo.buttons) do
		local buttonFrame = self.buttonPool:Acquire();
		buttonFrame:Setup(widgetContainer, buttonInfo);
		buttonFrame.layoutIndex = index;
		buttonFrame:Show();
	end
	self.ButtonContainer:Layout();

	self:EvaluateTutorials(widgetInfo.frameTextureKit);

	self:Layout();
	self:Show();
end

function UIWidgetTemplateButtonHeaderMixin:OnLoad()
	self.buttonPool = CreateFramePool("BUTTON", self.ButtonContainer, "UIWidgetBaseButtonTemplate");
end

function UIWidgetTemplateButtonHeaderMixin:EvaluateTutorials(textureKit)
	if textureKit == "lorewalking-scenario" then
		local helpTipInfo = {
			text = LOREWALKING_QUESTS_HIDDEN_HELP_TIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_LOREWALKING_QUESTS_HIDDEN,
			checkCVars = true,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
		};
		HelpTip:Show(self, helpTipInfo);
	end
end
