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
	local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(mapBannerInfo.areaPoiID);
	local descriptionLabel = nil;
	if secondsLeft and secondsLeft > 0 then
		local timeString = SecondsToTime(secondsLeft);
		descriptionLabel = INVASION_TIME_FORMAT:format(timeString);
	end

	local atlas, width, height = GetAtlasInfo(mapBannerInfo.atlasName);
	local bannerLabelTextureInfo = {};
	bannerLabelTextureInfo.atlas = mapBannerInfo.atlasName;
	bannerLabelTextureInfo.width = width;
	bannerLabelTextureInfo.height = height;
	local fontColor = mapBannerInfo.uiTextureKit == "LegionInvasion" and INVASION_FONT_COLOR or AREA_NAME_FONT_COLOR;
	local descriptionFontColor = mapBannerInfo.uiTextureKit == "LegionInvasion" and INVASION_DESCRIPTION_FONT_COLOR or AREA_DESCRIPTION_FONT_COLOR;
	self:GetMap():TriggerEvent("SetAreaLabel", MAP_AREA_LABEL_TYPE.AREA_POI_BANNER, mapBannerInfo.name, descriptionLabel, fontColor, descriptionFontColor, bannerLabelTextureInfo);
end