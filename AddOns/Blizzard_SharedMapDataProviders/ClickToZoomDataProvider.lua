
local ClickToZoomStyles = {
	[Enum.MapCanvasPosition.BottomLeft] = { point="BOTTOMLEFT", x = 75, y = 65, textPoint="LEFT" };
	[Enum.MapCanvasPosition.BottomRight] = { point="BOTTOMRIGHT", x = -75, y = 65, textPoint="RIGHT" };
	[Enum.MapCanvasPosition.TopLeft] = { point="TOPLEFT", x = 75, y = -65, textPoint="LEFT" };
	[Enum.MapCanvasPosition.TopRight] = { point="TOPRIGHT", x = -75, y = -65, textPoint="RIGHT" };
};

ClickToZoomDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function ClickToZoomDataProviderMixin:OnZoneLabelFadeIn(isContinent)
	if isContinent then
		self.MapLabel:FadeIn();

		if self:ShouldShowZoomOut() then
			self.ZoomOutMapLabel:FadeOut();
		end
	end
end

function ClickToZoomDataProviderMixin:OnZoneLabelFadeOut(isContinent)
	if isContinent then
		self.MapLabel:FadeOut();

		if self:ShouldShowZoomOut() then
			self.ZoomOutMapLabel:FadeIn();
		end
	end
end

function ClickToZoomDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	mapCanvas:RegisterCallback("ZoneLabelFadeInStart", self.OnZoneLabelFadeIn, self);
	mapCanvas:RegisterCallback("ZoneLabelFadeOutStart", self.OnZoneLabelFadeOut, self);

	self:UpdateZoomStyle();

	if self.MapLabel then
		self.MapLabel:SetParent(mapCanvas);
	else
		self.MapLabel = CreateFrame("FRAME", nil, mapCanvas, "ClickToZoomDataProvider_LabelTemplate");

		local showAtMaxZoom = false;
		self.MapLabel:Init(FLIGHT_MAP_CLICK_TO_ZOOM_HINT, showAtMaxZoom);
	end

	if self.ZoomOutMapLabel then
		self.ZoomOutMapLabel:SetParent(mapCanvas);
	else
		self.ZoomOutMapLabel = CreateFrame("FRAME", nil, mapCanvas, "ClickToZoomDataProvider_LabelTemplate");

		local showAtMaxZoom = true;
		self.ZoomOutMapLabel:Init(FLIGHT_MAP_CLICK_TO_ZOOM_OUT_HINT, showAtMaxZoom);
	end

	self:UpdateStyle();
end

function ClickToZoomDataProviderMixin:OnRemoved(mapCanvas)
	mapCanvas:UnregisterCallback("ZoneLabelFadeInStart", self);
	mapCanvas:UnregisterCallback("ZoneLabelFadeOutStart", self);	

	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
end

function ClickToZoomDataProviderMixin:RemoveAllData()
	self.MapLabel:Reset();
	self.ZoomOutMapLabel:Reset();
end

function ClickToZoomDataProviderMixin:RefreshAllData(fromOnShow)
	self.MapLabel:Refresh();

	if self:ShouldShowZoomOut() then
		self.ZoomOutMapLabel:Refresh();
	else
		self.ZoomOutMapLabel:Reset();
	end
end

function ClickToZoomDataProviderMixin:UpdateStyle()
	local style = ClickToZoomStyles[self:GetClickToZoomStyle()];
	if style then
		self.MapLabel:SetStyle(style);
		self.ZoomOutMapLabel:SetStyle(style);
	end
end

function ClickToZoomDataProviderMixin:UpdateZoomStyle()
	local mapID = self:GetMap():GetMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);
	self.shouldShowZoomOut = FlagsUtil.IsSet(mapInfo.flags, Enum.UIMapFlag.FlightMapShowZoomOut);
end

function ClickToZoomDataProviderMixin:OnMapChanged()
	self:UpdateStyle();
	self:UpdateZoomStyle();
end

function ClickToZoomDataProviderMixin:OnCanvasScaleChanged()
	MapCanvasDataProviderMixin.OnCanvasScaleChanged(self);

	if self:GetMap():IsAtMaxZoom() or self:GetMap():IsAtMinZoom() then
		self:RefreshAllData();
	end
end

function ClickToZoomDataProviderMixin:GetClickToZoomStyle()
	local mapID = self:GetMap():GetMapID();
	if mapID then
		return C_Map.GetMapArtHelpTextPosition(mapID);
	end
	
	return Enum.MapCanvasPosition.BottomRight;
end

function ClickToZoomDataProviderMixin:ShouldShowZoomOut()
	return self.shouldShowZoomOut;
end

ClickToZoomDataProvider_LabelMixin = {};

function ClickToZoomDataProvider_LabelMixin:Init(text, showAtMaxZoom)
	self.Text:SetText(text);
	self.showAtMaxZoom = showAtMaxZoom;
	self:SetFrameStrata("HIGH");
	self:SetAlpha(0);
end

function ClickToZoomDataProvider_LabelMixin:SetStyle(style)
	self:ClearAllPoints();
	self:SetPoint(style.point, style.x, style.y);
	local text = self.Text;
	text:ClearAllPoints();
	text:SetPoint(style.textPoint);
end

function ClickToZoomDataProvider_LabelMixin:FadeIn()
	self.FadeInAnim:Play();
end

function ClickToZoomDataProvider_LabelMixin:FadeOut()
	self.FadeOutAnim:Play();
end

function ClickToZoomDataProvider_LabelMixin:Refresh()
	if self.showAtMaxZoom == self:GetMap():IsAtMaxZoom() then
		if not self.FadeInAnim:IsPlaying() then
			self:SetAlpha(1);
		end
	else
		if not self.FadeOutAnim:IsPlaying() then
			self:SetAlpha(0);
		end
	end
end

function ClickToZoomDataProvider_LabelMixin:Reset()
	self.FadeInAnim:Stop()
	self.FadeOutAnim:Stop()
	self:SetAlpha(0);
end

function ClickToZoomDataProvider_LabelMixin:GetMap()
	return self:GetParent();
end