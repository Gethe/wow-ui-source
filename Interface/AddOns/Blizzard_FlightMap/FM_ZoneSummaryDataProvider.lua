FlightMap_ZoneSummaryDataProvider = CreateFromMixins(MapCanvasDataProviderMixin);

function FlightMap_ZoneSummaryDataProvider:OnShow()
	self.ticker = C_Timer.NewTicker(0, function() self:CheckMouse() end);
end

function FlightMap_ZoneSummaryDataProvider:OnHide()
	self.ticker:Cancel();
	self.ticker = nil;

	self:HideGameTooltip();
end

function FlightMap_ZoneSummaryDataProvider:RemoveAllData()
	self:HideGameTooltip();
end

function FlightMap_ZoneSummaryDataProvider:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	self:CheckMouse();
end

function FlightMap_ZoneSummaryDataProvider:GetNumWorldQuestsForMap(mapID)
	local numWorldQuests = 0;

	local taskInfo = GetQuestsForPlayerByMapIDCached(mapID);
	if taskInfo then
		for i, info in ipairs(taskInfo) do
			if info.childDepth and HaveQuestData(info.questId) and QuestUtils_IsQuestWorldQuest(info.questId) and WorldMap_DoesWorldQuestInfoPassFilters(info) then
				numWorldQuests = numWorldQuests + 1;
			end
		end
	end

	return numWorldQuests;
end

function FlightMap_ZoneSummaryDataProvider:CheckMouse()
	if self:GetMap():IsAtMinZoom() and self:GetMap():GetMapID() and self:GetMap():IsCanvasMouseFocus() and (not GameTooltip:GetOwner() or GameTooltip:GetOwner() == self:GetMap()) then
		local mapID = self:GetMap():GetMapID();
		local mouseX, mouseY = self:GetMap():GetNormalizedCursorPosition();
		local mapInfo = C_Map.GetMapInfoAtPosition(mapID, mouseX, mouseY);

		if mapInfo and mapInfo.mapID ~= mapID then
			GameTooltip:SetOwner(self:GetMap(), "ANCHOR_CURSOR_RIGHT", 30);
			GameTooltip:SetText(mapInfo.name);

			local numWorldQuests = self:GetNumWorldQuestsForMap(mapInfo.mapID);
			if numWorldQuests > 0 then
				GameTooltip:AddLine(FLIGHT_MAP_WORLD_QUESTS:format(numWorldQuests), HIGHLIGHT_FONT_COLOR:GetRGB());
				GameTooltip:AddLine(" ");
			end

			GameTooltip:AddLine(FLIGHT_MAP_CLICK_TO_ZOOM_IN, GREEN_FONT_COLOR:GetRGB());


			GameTooltip:Show();

			self.hasGameTooltip = true;
		else
			self:HideGameTooltip();
		end
	else
		self:HideGameTooltip();
	end
end

function FlightMap_ZoneSummaryDataProvider:HideGameTooltip()
	if self.hasGameTooltip and GameTooltip:GetOwner() == self:GetMap() then
		GameTooltip_Hide();
	end
	self.hasGameTooltip = nil;
end