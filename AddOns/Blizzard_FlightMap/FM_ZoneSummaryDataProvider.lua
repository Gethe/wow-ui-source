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

	self:GatherWorldQuests();

	self:CheckMouse();
end

function FlightMap_ZoneSummaryDataProvider:GatherWorldQuests()
	self.worldQuestsByZone = {};

	local mapAreaID = self:GetMap():GetMapID();
	for zoneIndex = 1, C_MapCanvas.GetNumZones(mapAreaID) do
		local zoneMapID, zoneName, left, right, top, bottom = C_MapCanvas.GetZoneInfo(mapAreaID, zoneIndex);
		local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(zoneMapID, mapAreaID);

		if taskInfo then
			for i, info in ipairs(taskInfo) do
				if HaveQuestData(info.questId) then
					if QuestMapFrame_IsQuestWorldQuest(info.questId) and WorldMap_DoesWorldQuestInfoPassFilters(info) then
						if not self.worldQuestsByZone[zoneMapID] then
							self.worldQuestsByZone[zoneMapID] = {};
						end
						table.insert(self.worldQuestsByZone[zoneMapID], info);
					end
				end
			end
		end
	end
end

function FlightMap_ZoneSummaryDataProvider:CheckMouse()
	if self:GetMap():IsZoomedOut() and self:GetMap():GetMapID() and self:GetMap():IsCanvasMouseFocus() then
		local mapAreaID = self:GetMap():GetMapID();
		local mouseX, mouseY = self:GetMap():GetNormalizedCursorPosition();
		local zoneMapID = C_MapCanvas.FindZoneAtPosition(mapAreaID, mouseX, mouseY);

		if zoneMapID then
			local zoneName, left, right, top, bottom = C_MapCanvas.GetZoneInfoByID(mapAreaID, zoneMapID);

			GameTooltip:SetOwner(self:GetMap(), "ANCHOR_CURSOR_RIGHT", 30);

			GameTooltip:SetText(zoneName);

			local worldQuests = self.worldQuestsByZone[zoneMapID];
			if worldQuests then
				GameTooltip:AddLine(FLIGHT_MAP_WORLD_QUESTS:format(#worldQuests), HIGHLIGHT_FONT_COLOR:GetRGB());
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