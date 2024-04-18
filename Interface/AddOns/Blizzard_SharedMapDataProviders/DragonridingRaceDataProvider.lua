DragonridingRaceDataProviderMixin = CreateAndInitFromMixin (CVarMapCanvasDataProviderMixin, "dragonRidingRacesFilter");

function DragonridingRaceDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("DragonridingRacePinTemplate");
end

function DragonridingRaceDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	if not self:IsCVarSet() then
		return;
	end

	local mapID = self:GetMap():GetMapID();
	local areaPOIs = C_AreaPoiInfo.GetDragonridingRacesForMap(mapID);
	for i, areaPoiID in ipairs(areaPOIs) do
		local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID);
		if poiInfo then
			poiInfo.dataProvider = self;
			self:GetMap():AcquirePin("DragonridingRacePinTemplate", poiInfo);
		end
	end
end

--[[ Pin ]]--
DragonridingRacePinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DRAGONRIDING_RACE");
