local function GetTextureWithStateVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetTextureWithStateVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.TextureWithState, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateTextureWithState"}, GetTextureWithStateVisInfoData);

UIWidgetTemplateTextureWithStateMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateTextureWithStateMixin:Setup(widgetInfo)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo);
	self.Text:SetText(widgetInfo.name); 
	self:SetTooltip(widgetInfo.tooltip); 

	local backgroundTexture = GetUITextureKitInfo(widgetInfo.backgroundTextureKitID);
	local portraitTexture = GetUITextureKitInfo(widgetInfo.portraitTextureKitID);
	
	self.Portrait:SetAtlas(portraitTexture, false);
	self.Background:SetAtlas(backgroundTexture, false); 
end

function UIWidgetTemplateTextureWithStateMixin:SetTooltipOwner()
	GameTooltip:SetOwner(self.Portrait, "ANCHOR_TOPRIGHT");
end