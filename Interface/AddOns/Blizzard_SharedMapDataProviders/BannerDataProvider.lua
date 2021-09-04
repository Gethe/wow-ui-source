BannerDataProvider = CreateFromMixins(MapCanvasDataProviderMixin);

function BannerDataProvider:RemoveAllData()
	self:GetMap():TriggerEvent("ClearAreaLabel", MAP_AREA_LABEL_TYPE.AREA_POI_BANNER);
end

function BannerDataProvider:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	local mapBanners = C_Map.GetMapBannersForMap(mapID);
	for i, mapBannerInfo in ipairs(mapBanners) do
		self:AddBanner(mapBannerInfo);
		-- We don't really support more than one
	end
end

function BannerDataProvider:AddBanner(mapBannerInfo)
	local function CalculateAndFormatPOITimeRemaining()
		local seconds = C_AreaPoiInfo.GetAreaPOISecondsLeft(mapBannerInfo.areaPoiID);
		if seconds and seconds > 0 then
			local omitSeconds = true;
			return SecondsToTime(math.max(seconds, 60), omitSeconds);
		end
 	end

	local info = C_Texture.GetAtlasInfo(mapBannerInfo.atlasName);
	local bannerLabelTextureInfo = {};
	bannerLabelTextureInfo.atlas = mapBannerInfo.atlasName;
	bannerLabelTextureInfo.width = info and info.width or 0;
	bannerLabelTextureInfo.height = info and info.height or 0;
	local descriptionCallback = CalculateAndFormatPOITimeRemaining;
	local fontColor = mapBannerInfo.uiTextureKit == "LegionInvasion" and INVASION_FONT_COLOR or AREA_NAME_FONT_COLOR;
	local descriptionFontColor = mapBannerInfo.uiTextureKit == "LegionInvasion" and INVASION_DESCRIPTION_FONT_COLOR or AREA_DESCRIPTION_FONT_COLOR;
	self:GetMap():TriggerEvent("SetAreaLabel", MAP_AREA_LABEL_TYPE.AREA_POI_BANNER, mapBannerInfo.name, descriptionCallback, fontColor, descriptionFontColor, bannerLabelTextureInfo);
end