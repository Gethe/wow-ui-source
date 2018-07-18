GossipDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function GossipDataProviderMixin:OnShow()
	self:RegisterEvent("DYNAMIC_GOSSIP_POI_UPDATED");
end

function GossipDataProviderMixin:OnHide()
	self:UnregisterEvent("DYNAMIC_GOSSIP_POI_UPDATED");
end

function GossipDataProviderMixin:OnEvent(event, ...)
	if event == "DYNAMIC_GOSSIP_POI_UPDATED" then
		self:RefreshAllData();
	end
end

function GossipDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("GossipPinTemplate");
end

function GossipDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	local gossipPoiID = C_GossipInfo.GetGossipPoiForUiMapID(mapID);

	if gossipPoiID then
		local gossipInfo = C_GossipInfo.GetGossipPoiInfo(mapID, gossipPoiID);
		if gossipInfo then
			self:GetMap():AcquirePin("GossipPinTemplate", gossipInfo);
		end
	end
end

--[[ Pin ]]--
GossipPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_GOSSIP");