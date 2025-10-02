AreaPOIDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AreaPOIDataProviderMixin:GetPinTemplate()
	return "AreaPOIPinTemplate";
end

function AreaPOIDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self:GetMap():RegisterCallback("SetBounty", self.SetBounty, self);
end

function AreaPOIDataProviderMixin:OnRemoved(mapCanvas)
	self:GetMap():UnregisterCallback("SetBounty", self);

	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
end

function AreaPOIDataProviderMixin:SetBounty(bountyQuestID, bountyFactionID, bountyFrameType)
	local changed = self.bountyQuestID ~= bountyQuestID;
	if changed then
		self.bountyQuestID = bountyQuestID;
		self.bountyFactionID = bountyFactionID;
		self.bountyFrameType = bountyFrameType;
		if self:GetMap() then
			self:RefreshAllData();
		end
	end
end

function AreaPOIDataProviderMixin:GetBountyInfo()
	return self.bountyQuestID, self.bountyFactionID, self.bountyFrameType;
end

function AreaPOIDataProviderMixin:OnShow()
	self:RegisterEvent("AREA_POIS_UPDATED");
end

function AreaPOIDataProviderMixin:OnHide()
	self:UnregisterEvent("AREA_POIS_UPDATED");
end

function AreaPOIDataProviderMixin:OnEvent(event, ...)
	if event == "AREA_POIS_UPDATED" then
		self:RefreshAllData();
	end
end

function AreaPOIDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function AreaPOIDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	local areaPOIs = GetAreaPOIsForPlayerByMapIDCached(mapID);
	for i, areaPoiID in ipairs(areaPOIs) do
		local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID);
		if poiInfo then
			poiInfo.dataProvider = self;
			self:GetMap():AcquirePin(self:GetPinTemplate(), poiInfo);
		end
	end
end

--[[ Area POI Pin ]]--
AreaPOIPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_AREA_POI");

local AREAPOI_HIGHLIGHT_PARAMS = { backgroundPadding = 20 };

local GreatVaultMouseHandler = {};

function GreatVaultMouseHandler:OnMouseClickAction(button)
	if self:IsClickAction(button) then
		WeeklyRewards_ShowUI();
		return true;
	end
end

function GreatVaultMouseHandler:IsClickAction(button, action)
	return button == "RightButton";
end

local customOnClickHandlers =
{
	OribosGreatVault = GreatVaultMouseHandler,
}

function AreaPOIPinMixin:GetCustomMouseHandler()
	return self.textureKit and customOnClickHandlers[self.textureKit];
end

function AreaPOIPinMixin:UpdateCustomMouseHandlers()
	self.customOnClickHandler = self:GetCustomMouseHandler();
end

function AreaPOIPinMixin:ShouldMouseButtonBePassthrough(button)
	-- GreatVault allows right click to open it, everything else defers to the base mixin.
	local onClickHandler = self:GetCustomMouseHandler();
	if onClickHandler then
		if onClickHandler:IsClickAction(button) then
			return false;
		end
	end

	return MapCanvasPinMixin.ShouldMouseButtonBePassthrough(self, button);
end

function AreaPOIPinMixin:OnAcquired(poiInfo) -- override
	SuperTrackablePoiPinMixin.OnAcquired(self, poiInfo);

	self.poiInfo = poiInfo;
	self:SetupHoverInfo(poiInfo);
	MapPinHighlight_CheckHighlightPin(self:GetHighlightType(), self, self.Texture, AREAPOI_HIGHLIGHT_PARAMS);

	self:AddIconWidgets();
	self:UpdateCustomMouseHandlers();

	if poiInfo.isAlwaysOnFlightmap then
		self:SetAlphaLimits(1.0, 1.0, 1.0);
	end
end

function AreaPOIPinMixin:OnMouseClickAction(button)
	if not SuperTrackablePinMixin.OnMouseClickAction(self, button) then
		if self.customOnClickHandler then
			return self.customOnClickHandler:OnMouseClickAction(button);
		end
	end
end

function AreaPOIPinMixin:SetupHoverInfo(poiInfo)
	self.highlightWorldQuestsOnHover = poiInfo.highlightWorldQuestsOnHover;
	self.highlightVignettesOnHover = poiInfo.highlightVignettesOnHover;

	if poiInfo.atlasName == "dreamsurge_hub-icon" then
		self.pinHoverHighlightType = MapPinHighlightType.DreamsurgeHighlight;
	else
		self.pinHoverHighlightType = MapPinHighlightType.SupertrackedHighlight;
	end
end

function AreaPOIPinMixin:GetHighlightType() -- override
	if self.poiInfo.shouldGlow then
		return MapPinHighlightType.SupertrackedHighlight;
	end

	local bountyQuestID, bountyFactionID, bountyFrameType = self:GetDataProvider():GetBountyInfo();
	if bountyFrameType == BountyFrameType.ActivityTracker then
		if bountyFactionID and self.poiInfo.factionID == bountyFactionID then
			return MapPinHighlightType.SupertrackedHighlight;
		end
	end

	return MapPinHighlightType.None;
end

function AreaPOIPinMixin:OnMouseEnter()
	if not self:HasDisplayName() then
		return;
	end

	self.UpdateTooltip = function() self:OnMouseEnter(); end;

	local tooltipShown = self:TryShowTooltip();
	if not tooltipShown then
		self:GetMap():TriggerEvent("SetAreaLabel", MAP_AREA_LABEL_TYPE.POI, self:GetDisplayName(), self.description);
	end

	EventRegistry:TriggerEvent("AreaPOIPin.MouseOver", self, tooltipShown, self.poiInfo.areaPoiID, self:GetDisplayName());
	self:OnLegendPinMouseEnter();

	if self.highlightWorldQuestsOnHover then
		self:GetMap():TriggerEvent("HighlightMapPins.WorldQuests", self.pinHoverHighlightType);
	end

	if self.highlightVignettesOnHover then
		self:GetMap():TriggerEvent("HighlightMapPins.Vignettes", self.pinHoverHighlightType);
	end
end

function AreaPOIPinMixin:AddCustomTooltipData(tooltip)
	-- override if needed
end

function AreaPOIPinMixin:TryShowTooltip()
	local function customFn(tooltip)
		self:AddCustomTooltipData(tooltip);
	end
	return AreaPoiUtil.TryShowTooltip(self, "ANCHOR_RIGHT", self.poiInfo, customFn);
end

function AreaPOIPinMixin:OnMouseLeave()
	local map = self:GetMap();
	if map then
		map:TriggerEvent("ClearAreaLabel", MAP_AREA_LABEL_TYPE.POI);

		if self.highlightWorldQuestsOnHover then
			map:TriggerEvent("HighlightMapPins.WorldQuests", nil);
		end

		if self.highlightVignettesOnHover then
			map:TriggerEvent("HighlightMapPins.Vignettes", nil);
		end
	else
		self:ReportPinError("Invalid map for areaPOI pin[%s] where last map used was [%s]", tostring(self:GetAreaPOIID()), tostring(self:GetLastDisplayMap()));
	end

	self:OnLegendPinMouseLeave();

	GetAppropriateTooltip():Hide();
end

function AreaPOIPinMixin:GetDisplayName()
	return self.poiInfo.name or "";
end

function AreaPOIPinMixin:HasDisplayName()
	return self.poiInfo.name and self.poiInfo.name ~= "";
end

function AreaPOIPinMixin:GetAreaPOIID()
	return self.poiInfo and self.poiInfo.areaPoiID;
end
