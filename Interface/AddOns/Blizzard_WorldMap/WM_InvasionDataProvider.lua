WorldMap_InvasionDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function WorldMap_InvasionDataProviderMixin:ShowOverlay()
	self.InvasionOverlay:Show();
end

function WorldMap_InvasionDataProviderMixin:HideOverlay()
	self.InvasionOverlay:Hide();
end

function WorldMap_InvasionDataProviderMixin:RemoveAllData()
	self:HideOverlay();
end

function WorldMap_InvasionDataProviderMixin:RefreshAllData(fromOnShow)
	local map = self:GetMap();
	local mapID = map:GetMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);
	local show = mapInfo and mapInfo.mapType ~= Enum.UIMapType.Continent and C_InvasionInfo.GetInvasionForUiMapID(mapID) ~= nil;
	if (show) then
		self:ShowOverlay();
	else
		self:HideOverlay();
	end
end

function WorldMap_InvasionDataProviderMixin:OnAdded(owningMap)
	MapCanvasDataProviderMixin.OnAdded(self, owningMap);
	if (not self.InvasionOverlay) then
		self.InvasionOverlay = CreateFrame("Frame", nil, nil, "WorldMapInvasionOverlayTemplate");
	end
	self.InvasionOverlay:SetParent(owningMap:GetCanvas());
	self.InvasionOverlay:SetAllPoints(owningMap);
end

function WorldMap_InvasionDataProviderMixin:OnRemoved(owningMap)
	MapCanvasDataProviderMixin.OnRemoved(self, owningMap);
	self.InvasionOverlay:SetParent(nil);
end