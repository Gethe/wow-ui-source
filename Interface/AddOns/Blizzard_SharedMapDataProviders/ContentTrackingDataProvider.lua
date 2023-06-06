ContentTrackingDataProviderMixin = CreateAndInitFromMixin (CVarMapCanvasDataProviderMixin, "contentTrackingFilter");

function ContentTrackingDataProviderMixin:GetPinTemplate()
	return "ContentTrackingPinTemplate";
end

function ContentTrackingDataProviderMixin:OnAdded(mapCanvas)
	CVarMapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	mapCanvas:SetPinTemplateType(self:GetPinTemplate(), "BUTTON");

	if not self.poiQuantizer then
		self.poiQuantizer = CreateFromMixins(WorldMapPOIQuantizerMixin);
		self.poiQuantizer.size = 75;
		self.poiQuantizer:OnLoad(self.poiQuantizer.size, self.poiQuantizer.size);
	end

	self:RegisterEvent("CONTENT_TRACKING_UPDATE");
	self:RegisterEvent("TRACKING_TARGET_INFO_UPDATE");
	self:RegisterEvent("SUPER_TRACKING_CHANGED");
end

function ContentTrackingDataProviderMixin:OnEvent(event, ...)
	if (event == "CONTENT_TRACKING_UPDATE") or (event == "TRACKING_TARGET_INFO_UPDATE") then
		self:RefreshAllData();
	elseif event == "SUPER_TRACKING_CHANGED" then
		self:RefreshAllData();
	end
end

function ContentTrackingDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function ContentTrackingDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	if not mapID then
		return;
	end

	if not self:IsCVarSet() then
		return;
	end

	local pinsToQuantize = { };

	local function AddTrackableToMap(trackableMapInfo, isWaypoint)
		local pin = self:AddTrackable(trackableMapInfo, isWaypoint);
		pin:Show();
		table.insert(pinsToQuantize, pin);
	end

	for i, trackableType in ipairs(C_ContentTracking.GetCollectableSourceTypes()) do
		local unusued_trackingResult, trackableMapInfos = C_ContentTracking.GetTrackablesOnMap(trackableType, mapID);

		-- Note: regardless of whether data is pending, let's add what we can.
		for j, trackableMapInfo in ipairs(trackableMapInfos) do
			AddTrackableToMap(trackableMapInfo, false --[[ isWaypoint ]]);
		end
	end

	local trackableType, trackableID = C_SuperTrack.GetSuperTrackedContent();
	if trackableType then
		local trackingResult, mapInfo = C_ContentTracking.GetNextWaypointForTrackable(trackableType, trackableID, mapID);
		if trackingResult == Enum.ContentTrackingResult.Success then
			local isWaypoint = true;
			AddTrackableToMap(mapInfo, isWaypoint);
		end
	end

	self.poiQuantizer:ClearAndQuantize(pinsToQuantize);

	for i, pin in pairs(pinsToQuantize) do
		pin:SetPosition(pin.quantizedX or pin.normalizedX, pin.quantizedY or pin.normalizedY);
	end
end

function ContentTrackingDataProviderMixin:OnCanvasSizeChanged()
	local ratio = self:GetMap():DenormalizeHorizontalSize(1.0) / self:GetMap():DenormalizeVerticalSize(1.0);
	self.poiQuantizer:Resize(math.ceil(self.poiQuantizer.size * ratio), self.poiQuantizer.size);
end

function ContentTrackingDataProviderMixin:AddTrackable(trackableMapInfo, isWaypoint)
	local pin = self:GetMap():AcquirePin(self:GetPinTemplate());
	pin:SetPinScale(2.5);
	pin:Init(self, trackableMapInfo, isWaypoint);

	local trackableType, trackableID = C_SuperTrack.GetSuperTrackedContent();
	local isSuperTracked = (trackableType == trackableMapInfo.trackableType) and (trackableID == trackableMapInfo.trackableID);
	pin.isSuperTracked = isSuperTracked;

	if isSuperTracked then
		pin:UseFrameLevelType("PIN_FRAME_LEVEL_SUPER_TRACKED_CONTENT");
	else
		pin:UseFrameLevelType("PIN_FRAME_LEVEL_TRACKED_CONTENT");
	end

	pin.selected = isSuperTracked;
	pin:SetStyle(isWaypoint and POIButtonUtil.Style.Waypoint or POIButtonUtil.Style.ContentTracking);
	pin:SetTrackable(trackableMapInfo.trackableType, trackableMapInfo.trackableID);

	pin:UpdateButtonStyle();

	pin:SetPosition(trackableMapInfo.x, trackableMapInfo.y);
	return pin;
end

--[[ Content Tracking Pin ]]--
ContentTrackingPinMixin = CreateFromMixins(MapCanvasPinMixin);

function ContentTrackingPinMixin:OnLoad()
	self:SetScalingLimits(1, 0.4125, 0.4125);

	self:SetNudgeTargetFactor(0.01);
	self:SetNudgeZoomedOutFactor(1.0);
	self:SetNudgeZoomedInFactor(0.75);

	self.UpdateTooltip = self.OnMouseEnter;
end

function ContentTrackingPinMixin:DisableInheritedMotionScriptsWarning()
	return true;
end

function ContentTrackingPinMixin:Init(dataProvider, trackableMapInfo, isWaypoint)
	self.dataProvider = dataProvider;
	self.trackableMapInfo = trackableMapInfo;
	self.isWaypoint = isWaypoint;
end

function ContentTrackingPinMixin:OnMouseEnter()
	POIButtonMixin.OnEnter(self);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local trackableMapInfo = self.trackableMapInfo;
	local title = C_ContentTracking.GetTitle(trackableMapInfo.trackableType, trackableMapInfo.trackableID)
	GameTooltip_SetTitle(GameTooltip, title);

	local objectiveText = C_ContentTracking.GetObjectiveText(trackableMapInfo.targetType, trackableMapInfo.targetID);
	GameTooltip_AddNormalLine(GameTooltip, CONTENT_TRACKING_OBJECTIVE_FORMAT:format(objectiveText));

	if self.isWaypoint then
		GameTooltip_AddNormalLine(GameTooltip, CONTENT_TRACKING_OBJECTIVE_FORMAT:format(self.trackableMapInfo.waypointText));
	end

	GameTooltip:Show();
end

function ContentTrackingPinMixin:OnMouseLeave()
	POIButtonMixin.OnLeave(self);

	GameTooltip_Hide();
end

function ContentTrackingPinMixin:OnMouseClickAction(...)
	POIButtonMixin.OnClick(self, ...);
end

function ContentTrackingPinMixin:OnMouseDownAction()
	self.NormalTexture:Hide();
	self.PushedTexture:Show();
end

function ContentTrackingPinMixin:OnMouseUpAction()
	self.NormalTexture:Show();
	self.PushedTexture:Hide();
end
