AreaPOIDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AreaPOIDataProviderMixin:GetPinTemplate()
	return "AreaPOIPinTemplate";
end

function AreaPOIDataProviderMixin:OnShow()
	self:RegisterEvent("WORLD_MAP_UPDATE");
end

function AreaPOIDataProviderMixin:OnHide()
	self:UnregisterEvent("WORLD_MAP_UPDATE");
end

function AreaPOIDataProviderMixin:OnEvent(event, ...)
	if event == "WORLD_MAP_UPDATE" then
		self:RefreshAllData();
	end
end

function AreaPOIDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function AreaPOIDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapAreaID = self:GetMap():GetMapID();
	local areaPOIs = C_WorldMap.GetAreaPOIForMap(mapAreaID);
	if areaPOIs then
		for i, areaPoiID in ipairs(areaPOIs) do
			local poiInfo = C_WorldMap.GetAreaPOIInfo(mapAreaID, areaPoiID);
			if poiInfo then
				self:AddAreaPOI(poiInfo);
			end
		end
	end
end

function AreaPOIDataProviderMixin:AddAreaPOI(poiInfo)
	local pin = self:GetMap():AcquirePin(self:GetPinTemplate());
	pin.poiID = poiInfo.poiID;
	if poiInfo.atlasName then
		local atlasName = poiInfo.textureKitPrefix and ("%s-%s"):format(poiInfo.textureKitPrefix, poiInfo.atlasName) or poiInfo.atlasName;
		local _, width, height = GetAtlasInfo(atlasName);
		pin.Texture:SetAtlas(atlasName);
		pin.Texture:SetSize(width * 2, height * 2);
		pin.Highlight:SetAtlas(atlasName);
		pin.Highlight:SetSize(width * 2, height * 2);
	else
		local x1, x2, y1, y2 = GetPOITextureCoords(poiInfo.textureIndex);
		pin.Texture:SetTexture("Interface/Minimap/POIIcons");
		pin.Texture:SetSize(40, 40);
		pin.Texture:SetTexCoord(x1, x2, y1, y2);
		pin.Highlight:SetTexture("Interface/Minimap/POIIcons");
		pin.Highlight:SetTexCoord(x1, x2, y1, y2);
		pin.Highlight:SetSize(40, 40);
	end
	pin:SetPosition(poiInfo.x, poiInfo.y);
end

--[[ Area POI Pin ]]--
AreaPOIPinMixin = CreateFromMixins(MapCanvasPinMixin);

function AreaPOIPinMixin:OnLoad()	
	self:SetScalingLimits(1, 0.4125, 0.425);

	self.UpdateTooltip = self.OnMouseEnter;

	self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI");
end

function AreaPOIPinMixin:OnMouseEnter()
	local poiInfo = C_WorldMap.GetAreaPOIInfo(self:GetMap():GetMapID(), self.poiID);
	if poiInfo then
		WorldMap_HijackTooltip(self:GetMap());

		WorldMapPOI_AddPOITimeLeftText(self, self.poiID, poiInfo.name, poiInfo.description)
	end
end

function AreaPOIPinMixin:OnMouseLeave()
	WorldMap_RestoreTooltip();
end