FlightPointDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function FlightPointDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("FlightPointPinTemplate");
end

function FlightPointDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	local taxiNodes = C_TaxiMap.GetTaxiNodesForMap(mapID);

	local factionGroup = UnitFactionGroup("player");
	for i, taxiNodeInfo in ipairs(taxiNodes) do
		if self:ShouldShowTaxiNode(factionGroup, taxiNodeInfo) then
			self:GetMap():AcquirePin("FlightPointPinTemplate", taxiNodeInfo);
		end
	end
end

function FlightPointDataProviderMixin:ShouldShowTaxiNode(factionGroup, taxiNodeInfo)
	if taxiNodeInfo.faction == Enum.FlightPathFaction.Horde then
		return factionGroup == "Horde";
	end

	if taxiNodeInfo.faction == Enum.FlightPathFaction.Alliance then
		return factionGroup == "Alliance";
	end
	
	return true;
end

--[[ Pin ]]--
FlightPointPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_FLIGHT_POINT");

function FlightPointPinMixin:SetTexture(poiInfo)
	BaseMapPoiPinMixin.SetTexture(self, poiInfo);
	if poiInfo.textureKitPrefix == "FlightMaster_Argus" then
		self:SetSize(21, 18);
		self.Texture:SetSize(21, 18);
	end
end