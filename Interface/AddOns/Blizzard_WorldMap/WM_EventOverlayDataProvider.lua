WorldMap_EventOverlayDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function WorldMap_EventOverlayDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("WorldMapInvasionOverlayPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("WorldMapThreatOverlayPinTemplate");
end

function WorldMap_EventOverlayDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local map = self:GetMap();
	local mapID = map:GetMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);
	if mapInfo and mapInfo.mapType == Enum.UIMapType.Zone then
		-- no overlaps 
		if not self:CheckShowInvasionOverlay(mapID) then
			self:CheckShowThreatOverlay(mapID);
		end
	end
end

function WorldMap_EventOverlayDataProviderMixin:CheckShowInvasionOverlay(mapID)
	if C_InvasionInfo.GetInvasionForUiMapID(mapID) then
		local pin = self:GetMap():AcquirePin("WorldMapInvasionOverlayPinTemplate");
		pin:SetPosition(0.5, 0.5);
		return true;
	end
	return false;
end

function WorldMap_EventOverlayDataProviderMixin:CheckShowThreatOverlay(mapID)
	local threatMaps = C_QuestLog.GetActiveThreatMaps();
	if threatMaps then
		for i, threatMapID in ipairs(threatMaps) do
			if mapID == threatMapID then
				local pin = self:GetMap():AcquirePin("WorldMapThreatOverlayPinTemplate");
				pin:SetPosition(0.5, 0.5);
				return true;
			end
		end
	end
	return false;
end

--[[ EventOverlay Blob Pin ]]--
WorldMap_EventOverlayPinMixin = CreateFromMixins(MapCanvasPinMixin);

function WorldMap_EventOverlayPinMixin:OnLoad()
	self:SetIgnoreGlobalPinScale(true);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_EVENT_OVERLAY");
end

function WorldMap_EventOverlayPinMixin:OnAcquired()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
end

function WorldMap_EventOverlayPinMixin:OnCanvasSizeChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
end