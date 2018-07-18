FogOfWarDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function FogOfWarDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self:GetMap():SetPinTemplateType("FogOfWarPinTemplate", "FogOfWarFrame");

	local pin = self:GetMap():AcquirePin("FogOfWarPinTemplate");
	pin.dataProvider = self;
	pin:SetPosition(0.5, 0.5);
	self.pin = pin;
end

function FogOfWarDataProviderMixin:OnRemoved(mapCanvas)
	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);

	self:GetMap():RemoveAllPinsByTemplate("FogOfWarPinTemplate");
end

function FogOfWarDataProviderMixin:RefreshAllData(fromOnShow)
	self.pin:OnMapChanged();
end

FogOfWarPinMixin = CreateFromMixins(MapCanvasPinMixin);

function FogOfWarPinMixin:OnLoad()
	FogOfWarFrameMixin.OnLoad(self);
	self:SetAlphaLimits(1.0, 1.0, 1.0);
	self:SetIgnoreGlobalPinScale(true);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_FOG_OF_WAR");
end

function FogOfWarPinMixin:OnCanvasScaleChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
end

function FogOfWarPinMixin:OnMapChanged()
	local mapID = self:GetMap():GetMapID();
	self:SetUiMapID(mapID)
end