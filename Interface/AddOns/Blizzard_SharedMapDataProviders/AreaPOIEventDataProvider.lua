AreaPOIEventDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AreaPOIEventDataProviderMixin:GetPinTemplate()
	return "AreaPOIEventPinTemplate";
end

function AreaPOIEventDataProviderMixin:OnShow()
	self:RegisterEvent("AREA_POIS_UPDATED");
	EventRegistry:RegisterCallback("PingAreaPOIEvent", self.OnPingAreaPOIEvent, self);
end

function AreaPOIEventDataProviderMixin:OnHide()
	self:UnregisterEvent("AREA_POIS_UPDATED");
	EventRegistry:UnregisterCallback("PingAreaPOIEvent", self);
end

function AreaPOIEventDataProviderMixin:OnEvent(event, ...)
	if event == "AREA_POIS_UPDATED" then
		self:RefreshAllData();
	end
end

function AreaPOIEventDataProviderMixin:OnPingAreaPOIEvent(areaPOIID)
	local numLoops = 2;
	if self:PingPin("areaPOIID", areaPOIID, "PIN_FRAME_LEVEL_QUEST_PING", numLoops) then
		PlaySound(SOUNDKIT.MAP_PING);
	end
end

function AreaPOIEventDataProviderMixin:GetBountyInfo()
	-- Not currently related to bounties, but might be someday.
	-- This primarily exists because these event pins are AreaPOI pins
	-- and require that this API exists on the data provider.
end

function AreaPOIEventDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function AreaPOIEventDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local map = self:GetMap();
	local mapID = map:GetMapID();
	local events = C_AreaPoiInfo.GetEventsForMap(mapID);
	for i, eventID in ipairs(events) do
		local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, eventID);
		if poiInfo then
			poiInfo.dataProvider = self;
			map:AcquirePin(self:GetPinTemplate(), poiInfo);
		end
	end

	self:UpdatePing();
end

AreaPOIEventPinMixin = AreaPOIPinMixin:CreateSubPin("PIN_FRAME_LEVEL_AREA_POI_EVENT");

function AreaPOIEventPinMixin:OnAcquired(poiInfo) -- override
	AreaPOIPinMixin.OnAcquired(self, poiInfo);
	self:AddTag(MapPinTags.Event);

	self:SetMapPinScale(1.3, 1, 1.3, 1.3);
	self:SetStyle(POIButtonUtil.Style.AreaPOI);
	self:SetAreaPOIInfo(poiInfo);
	self:UpdateButtonStyle();
	self:UpdateSelected();
end

function AreaPOIEventPinMixin:OnMouseClickAction(button)
	POIButtonMixin.OnClick(self, button);
end

function AreaPOIEventPinMixin:OnMouseEnter()
	POIButtonMixin.OnEnter(self);
	AreaPOIPinMixin.OnMouseEnter(self);
end

function AreaPOIEventPinMixin:OnMouseLeave()
	POIButtonMixin.OnLeave(self);
	AreaPOIPinMixin.OnMouseLeave(self);
end

function AreaPOIEventPinMixin:DisableInheritedMotionScriptsWarning()
	return true;
end

function AreaPOIEventPinMixin:SetTexture()
	-- This is handled via POIButton, overridden to prevent base mixin behavior.
end

function AreaPOIEventPinMixin:IsSuperTrackingExternallyHandled()
	return true;
end