
local ClickToZoomStyles = {
	[Enum.MapCanvasPosition.BottomLeft] = { point="BOTTOMLEFT", x = 75, y = 65, textPoint="LEFT" };
	[Enum.MapCanvasPosition.BottomRight] = { point="BOTTOMRIGHT", x = -75, y = 65, textPoint="RIGHT" };
	[Enum.MapCanvasPosition.TopLeft] = { point="TOPLEFT", x = 75, y = -65, textPoint="LEFT" };
	[Enum.MapCanvasPosition.TopRight] = { point="TOPRIGHT", x = -75, y = -65, textPoint="RIGHT" };
};

ClickToZoomDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function ClickToZoomDataProviderMixin:FadeIn()
	self.MapLabel.FadeInAnim:Play();
end

function ClickToZoomDataProviderMixin:FadeOut()
	self.MapLabel.FadeOutAnim:Play();
end

function ClickToZoomDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	
	self.fadeInCallback = self.fadeInCallback or function(event, isContinent)
		if isContinent then
			self:FadeIn();
		end
	end
	
	self.fadeOutCallback = self.fadeOutCallback or function(event, isContinent)
		if isContinent then
			self:FadeOut();
		end
	end
	
	self:GetMap():RegisterCallback("ZoneLabelFadeInStart", self.fadeInCallback, self);
	self:GetMap():RegisterCallback("ZoneLabelFadeOutStart", self.fadeOutCallback, self);

	if self.MapLabel then
		self.MapLabel:SetParent(self:GetMap());
		self:ClearAllPoints();
	else
		self.MapLabel = CreateFrame("FRAME", nil, self:GetMap(), "ClickToZoomDataProvider_LabelTemplate");
	end

	self:UpdateStyle();
	self.MapLabel:SetFrameStrata("HIGH");
	self.MapLabel:SetAlpha(1);
end

function ClickToZoomDataProviderMixin:OnRemoved(mapCanvas)
	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);

	self:GetMap():UnregisterCallback("ZoneLabelFadeInStart", self);
	self:GetMap():UnregisterCallback("ZoneLabelFadeOutStart", self);
end

function ClickToZoomDataProviderMixin:RemoveAllData()
	self.MapLabel.FadeInAnim:Stop()
	self.MapLabel.FadeOutAnim:Stop()
	self.MapLabel:SetAlpha(0);
end

function ClickToZoomDataProviderMixin:RefreshAllData(fromOnShow)
	if not self:GetMap():IsAtMaxZoom() then
		if not self.MapLabel.FadeInAnim:IsPlaying() then
			self.MapLabel:SetAlpha(1);
		end
	else
		if not self.MapLabel.FadeOutAnim:IsPlaying() then
			self.MapLabel:SetAlpha(0);
		end
	end
end

function ClickToZoomDataProviderMixin:UpdateStyle()
	local style = ClickToZoomStyles[self:GetClickToZoomStyle()];
	if style then
		self.MapLabel:ClearAllPoints();
		self.MapLabel:SetPoint(style.point, style.x, style.y);
		local text = self.MapLabel.Text;
		text:ClearAllPoints();
		text:SetPoint(style.textPoint);
	end
end

function ClickToZoomDataProviderMixin:OnMapChanged()
	self:UpdateStyle();
end

function ClickToZoomDataProviderMixin:GetClickToZoomStyle()
	local mapID = self:GetMap():GetMapID();
	if mapID then
		return C_Map.GetMapArtHelpTextPosition(mapID);
	end
	
	return Enum.MapCanvasPosition.BottomRight;
end