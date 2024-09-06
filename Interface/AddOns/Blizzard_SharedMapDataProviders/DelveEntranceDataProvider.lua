DelveEntranceDataProviderMixin = CreateFromMixins(CVarMapCanvasDataProviderMixin, AreaPOIDataProviderMixin);
DelveEntranceDataProviderMixin:Init("showDelveEntrancesOnMap");

function DelveEntranceDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("DelveEntrancePinTemplate");
end

function DelveEntranceDataProviderMixin:OnShow()
	CVarMapCanvasDataProviderMixin.OnShow(self);
	AreaPOIDataProviderMixin.OnShow(self);
end

function DelveEntranceDataProviderMixin:OnHide()
	CVarMapCanvasDataProviderMixin.OnHide(self);
	AreaPOIDataProviderMixin.OnHide(self);
end

function DelveEntranceDataProviderMixin:OnEvent(event, ...)
	CVarMapCanvasDataProviderMixin.OnEvent(self, event, ...);
	AreaPOIDataProviderMixin.OnEvent(self, event, ...);
end

function DelveEntranceDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	if not self:IsCVarSet() then
		return;
	end

	local mapID = self:GetMap():GetMapID();
	local areaPOIs = C_AreaPoiInfo.GetDelvesForMap(mapID);
	for i, areaPoiID in ipairs(areaPOIs) do
		local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID);
		if poiInfo then
			poiInfo.dataProvider = self;
			self:GetMap():AcquirePin("DelveEntrancePinTemplate", poiInfo);
		end
	end
end

--[[ Pin ]]--
DelveEntrancePinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DELVE_ENTRANCE", AreaPOIPinMixin);