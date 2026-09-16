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
	SuperTrackablePoiPinMixin.OnAcquired(self, mapLink);
	self.linkedUiMapID = mapLink.linkedUiMapID;
end

function MapLinkPinMixin:GetLinkedUIMapID()
	return self.linkedUiMapID;
end

function MapLinkPinMixin:UseTooltip()
	return true;
end

function MapLinkPinMixin:GetTooltipInstructions()
	return MAP_LINK_POI_TOOLTIP_INSTRUCTION_LINE;
end

function MapLinkPinMixin:OnMouseClickAction(button)
	SuperTrackablePinMixin.OnMouseClickAction(self, button);
	if button == "RightButton" then
		local linkedMap = self:GetLinkedUIMapID();
		if linkedMap then
			self:GetMap():SetMapID(linkedMap);
			PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
		end
	end
end

function MapLinkPinMixin:ShouldMouseButtonBePassthrough(button)
	-- MapLinks allow left click to super track and right click to navigate maps.
	-- Other buttons don't matter at this time.
	return false;
end
