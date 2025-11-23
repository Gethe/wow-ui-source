MapLinkDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function MapLinkDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("MapLinkPinTemplate");
end

function MapLinkDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	local mapLinks = C_Map.GetMapLinksForMap(mapID);
	for i, mapLink in ipairs(mapLinks) do
		self:GetMap():AcquirePin("MapLinkPinTemplate", mapLink);
	end
end

--[[ Pin ]]--
MapLinkPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_MAP_LINK");

function MapLinkPinMixin:OnAcquired(mapLink) -- override
	BaseMapPoiPinMixin.OnAcquired(self, mapLink);

	self.linkedUiMapID = mapLink.linkedUiMapID;
end

function MapLinkPinMixin:OnClick()
	self:GetMap():SetMapID(self.linkedUiMapID);
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
end