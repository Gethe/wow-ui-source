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

	local backgroundTexture = GetUITextureKitInfo(widgetInfo.backgroundTextureKitID);
	local portraitTexture = GetUITextureKitInfo(widgetInfo.portraitTextureKitID);
	
	local shouldBeAtlasSize = true;
	self.Portrait:SetAtlas(portraitTexture, shouldBeAtlasSize);
	self.Background:SetAtlas(backgroundTexture, shouldBeAtlasSize); 
end

function UIWidgetTemplateTextureWithStateMixin:SetTooltipOwner()
	GameTooltip:SetOwner(self.Portrait, "ANCHOR_TOPLEFT");
end