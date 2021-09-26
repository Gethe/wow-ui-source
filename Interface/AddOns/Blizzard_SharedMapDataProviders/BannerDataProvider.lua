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
	local timeLeftMinutes = C_AreaPoiInfo.GetAreaPOITimeLeft(mapBannerInfo.areaPoiID);
	local descriptionLabel = nil;
	if timeLeftMinutes then
		local hoursLeft = math.floor(timeLeftMinutes / 60);
		local minutesLeft = timeLeftMinutes % 60;
		descriptionLabel = INVASION_TIME_FORMAT:format(hoursLeft, minutesLeft)
	end

	local atlas, width, height = GetAtlasInfo(mapBannerInfo.atlasName);
	local bannerLabelTextureInfo = {};
	bannerLabelTextureInfo.atlas = mapBannerInfo.atlasName;
	bannerLabelTextureInfo.width = width;
	bannerLabelTextureInfo.height = height;
	self:GetMap():TriggerEvent("SetAreaLabel", MAP_AREA_LABEL_TYPE.AREA_POI_BANNER, mapBannerInfo.name, descriptionLabel, INVASION_FONT_COLOR, INVASION_DESCRIPTION_FONT_COLOR, bannerLabelTextureInfo);
end