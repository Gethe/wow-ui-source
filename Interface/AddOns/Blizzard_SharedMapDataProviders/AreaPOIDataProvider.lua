AreaPOIDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AreaPOIDataProviderMixin:GetPinTemplate()
	return "AreaPOIPinTemplate";
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
	local areaPOIs = C_AreaPoiInfo.GetAreaPOIForMap(mapID);
	for i, areaPoiID in ipairs(areaPOIs) do
		local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID);
		if poiInfo then
			self:GetMap():AcquirePin(self:GetPinTemplate(), poiInfo);
		end
	end
end

--[[ Area POI Pin ]]--
AreaPOIPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_AREA_POI");

local AREAPOI_HIGHLIGHT_PARAMS = { backgroundPadding = 20 };

function AreaPOIPinMixin:OnAcquired(poiInfo) -- override
	BaseMapPoiPinMixin.OnAcquired(self, poiInfo);

	self.areaPoiID = poiInfo.areaPoiID;
	MapPinHighlight_CheckHighlightPin(poiInfo.shouldGlow, self, self.Texture, AREAPOI_HIGHLIGHT_PARAMS);

	if self.textureKit == "OribosGreatVault" then
		local function OribosGreatVaultPOIOnMouseUp(self, button, upInside)
			if upInside and (button == "LeftButton") then
				WeeklyRewards_ShowUI();
			end
		end

		self:SetScript("OnMouseUp", OribosGreatVaultPOIOnMouseUp);
	else
		self:SetScript("OnMouseUp", nil);
	end
end

function AreaPOIPinMixin:OnMouseEnter()
	if not self.name or #self.name == 0 then
		return;
	end

	self.UpdateTooltip = function() self:OnMouseEnter(); end;

	local tooltipShown = self:TryShowTooltip();
	if not tooltipShown then
		self:GetMap():TriggerEvent("SetAreaLabel", MAP_AREA_LABEL_TYPE.POI, self.name, self.description);
	end

	EventRegistry:TriggerEvent("AreaPOIPin.MouseOver", self, tooltipShown, self.areaPoiID, self.name);
end

function AreaPOIPinMixin:TryShowTooltip()
	local description = self.description;
	local hasDescription = description and #description > 0;
	local isTimed = C_AreaPoiInfo.IsAreaPOITimed(self.areaPoiID);
	local hasWidgetSet = self.widgetSetID ~= nil;

	local hasTooltip = hasDescription or isTimed or hasWidgetSet;

	if hasTooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, self.name, HIGHLIGHT_FONT_COLOR);

		if hasDescription then
			GameTooltip_AddNormalLine(GameTooltip, description);
		end

		if isTimed then
			local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(self.areaPoiID);
			if secondsLeft and secondsLeft > 0 then
				local timeString = SecondsToTime(secondsLeft);
				GameTooltip_AddNormalLine(GameTooltip, BONUS_OBJECTIVE_TIME_LEFT:format(timeString));
			end
		end

		if self.textureKit == "OribosGreatVault" then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddInstructionLine(GameTooltip, ORIBOS_GREAT_VAULT_POI_TOOLTIP_INSTRUCTIONS);
		end

		if hasWidgetSet then
			GameTooltip_AddWidgetSet(GameTooltip, self.widgetSetID, 10);
		end

		if self.textureKit then
			local backdropStyle = GAME_TOOLTIP_TEXTUREKIT_BACKDROP_STYLES[self.textureKit];
			if (backdropStyle) then
				SharedTooltip_SetBackdropStyle(GameTooltip, backdropStyle);
			end
		end
		GameTooltip:Show();
		return true;
	end

	return false;
end

function AreaPOIPinMixin:OnMouseLeave()
	self:GetMap():TriggerEvent("ClearAreaLabel", MAP_AREA_LABEL_TYPE.POI);

	GameTooltip:Hide();
end