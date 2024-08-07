AreaPOIEventDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AreaPOIEventDataProviderMixin:GetPinTemplate()
	return "AreaPOIEventPinTemplate";
end

function AreaPOIEventDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	mapCanvas:SetPinTemplateType(self:GetPinTemplate(), "Button");
end

function AreaPOIEventDataProviderMixin:OnShow()
	self:RegisterEvent("AREA_POIS_UPDATED");
end

function AreaPOIEventDataProviderMixin:OnHide()
	self:UnregisterEvent("AREA_POIS_UPDATED");
end

function AreaPOIEventDataProviderMixin:OnEvent(event, ...)
	if event == "AREA_POIS_UPDATED" then
		self:RefreshAllData();
	end
end

function AreaPOIEventDataProviderMixin:GetBountyInfo()
	-- Not currently related to bounties, but might be someday.
	-- This primarily exists because these event pins are AreaPOI pins
	-- and require that this API exists on the data provider.
end

function AreaPOIEventDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function AreaPOIEventDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local map = self:GetMap();
	local mapID = map:GetMapID();
	local events = C_AreaPoiInfo.GetEventsForMap(mapID);
	for i, eventID in ipairs(events) do
		local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, eventID);
		if poiInfo then
			poiInfo.dataProvider = self;
			map:AcquirePin(self:GetPinTemplate(), poiInfo);
		end
	end
end

AreaPOIEventPinMixin = CreateFromMixins(AreaPOIPinMixin);

function AreaPOIEventPinMixin:OnAcquired(poiInfo) -- override
	AreaPOIPinMixin.OnAcquired(self, poiInfo);

	self:SetMapPinScale(1.3, 1, 1.3, 1.3);
	self:SetStyle(POIButtonUtil.Style.AreaPOI);
	self:SetAreaPOIInfo(poiInfo);
	self:UpdateButtonStyle();
	self:UpdateSelected();
end

function AreaPOIEventPinMixin:OnMouseClickAction(button)
	POIButtonMixin.OnClick(self, button);
end

function AreaPOIEventPinMixin:DisableInheritedMotionScriptsWarning()
	-- The area pin will override these anyway, we don't need to handle
	-- onEnter/Leave for the POIButton
	return true;
end

function AreaPOIEventPinMixin:SetTexture()
	-- This is handled via POIButton, overridden to prevent base mixin behavior.
end

function AreaPOIEventPinMixin:IsSuperTrackingExternallyHandled()
	return true;
end