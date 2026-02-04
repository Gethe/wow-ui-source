
local OWNER_TYPE_TO_TEMPLATE = {
	[Enum.HousingPlotOwnerType.None] = "UnoccupiedPlotPinTemplate",
	[Enum.HousingPlotOwnerType.Friend] = "FriendsPlotPinTemplate",
	[Enum.HousingPlotOwnerType.Stranger] = "OccupiedPlotPinTemplate",
	[Enum.HousingPlotOwnerType.Self] = "PlayersPlotPinTemplate",
};

NeighborhoodMapDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function NeighborhoodMapDataProviderMixin:OnShow()
	self:RegisterEvent("NEIGHBORHOOD_MAP_DATA_UPDATED");
end

function NeighborhoodMapDataProviderMixin:OnHide()
	self:UnregisterEvent("NEIGHBORHOOD_MAP_DATA_UPDATED");

end

function NeighborhoodMapDataProviderMixin:OnEvent(event, ...)
	self:RefreshAllData();
end

function NeighborhoodMapDataProviderMixin:RemoveAllData()
	for _ownerType, template in pairs(OWNER_TYPE_TO_TEMPLATE) do
		self:GetMap():RemoveAllPinsByTemplate(template);
	end
end

function NeighborhoodMapDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	if C_Housing.IsOnNeighborhoodMap() and self:GetMap():GetMapID() == C_Map.GetBestMapForUnit("player") then
		local houseMapData = C_HousingNeighborhood.GetNeighborhoodMapData();
		for _index, plotInfo in ipairs(houseMapData) do
			local template = OWNER_TYPE_TO_TEMPLATE[plotInfo.ownerType];
			if template then
				local pin = self:GetMap():AcquirePin(template, plotInfo);
				pin:SetPosition(plotInfo.mapPosition.x, plotInfo.mapPosition.y);
			end
		end
	end

end
--///////////////////Base Map Pin//////////////////////////////
NeighborhoodMapBasePinMixin = CreateFromMixins(MapCanvasPinMixin);

function NeighborhoodMapBasePinMixin:OnLoad()
	self:SetScalingLimits(1, 0.7, 1.3);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_NEIGHBORHOOD_MAP_OBJECTS");
end

function NeighborhoodMapBasePinMixin:OnAcquired(mapPlotInfo)
	SuperTrackablePinMixin.OnAcquired(self);

	self.plotInfo = mapPlotInfo;
	self:Refresh();
end

function NeighborhoodMapBasePinMixin:GetPlotInfo()
	return self.plotInfo;
end

function NeighborhoodMapBasePinMixin:GetSuperTrackData()
	-- Overrides SuperTrackablePoiPinMixin.
	local plotInfo = self:GetPlotInfo();
	return Enum.SuperTrackingMapPinType.HousingPlot, plotInfo and plotInfo.plotDataID or nil;
end

function NeighborhoodMapBasePinMixin:GetSuperTrackMarkerOffset()
	-- Overrides SuperTrackablePoiPinMixin.
	return 1, 0;
end

function NeighborhoodMapBasePinMixin:Refresh()

end

function NeighborhoodMapBasePinMixin:OnMouseEnter()
	local plotInfo = self:GetPlotInfo();

	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip_SetTitle(GameTooltip, C_HousingNeighborhood.GetNeighborhoodPlotName(plotInfo.plotID));

	if plotInfo.ownerName then
		GameTooltip_AddNormalLine(GameTooltip, string.format(NEIGHBORHOODMAP_OWNED_BY, plotInfo.ownerName));
	end

	GameTooltip:Show();
end

function NeighborhoodMapBasePinMixin:OnMouseLeave()
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end
--///////////////////Unoccupied Pin////////////////////////////
UnoccupiedPlotPinMixin = CreateFromMixins(NeighborhoodMapBasePinMixin);

--///////////////////Occupied Pin////////////////////////////
OccupiedPlotPinMixin = CreateFromMixins(NeighborhoodMapBasePinMixin);

--///////////////////Friend Plot Pin////////////////////////////
FriendsPlotPinMixin = CreateFromMixins(NeighborhoodMapBasePinMixin);

--///////////////////Player Plot Pin////////////////////////////
PlayersPlotPinMixin = CreateFromMixins(NeighborhoodMapBasePinMixin);

function PlayersPlotPinMixin:OnMouseEnter()
	-- Overrides NeighborhoodMapBasePinMixin.

	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip_SetTitle(GameTooltip, C_HousingNeighborhood.GetNeighborhoodPlotName(self:GetPlotInfo().plotID));
	GameTooltip_AddNormalLine(GameTooltip, NEIGHBORHOODMAP_YOUR_HOUSE);
	GameTooltip:Show();
end


