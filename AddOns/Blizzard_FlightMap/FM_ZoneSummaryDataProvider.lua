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

	local mapID = self:GetMap():GetMapID();
	local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(mapID);
	if taskInfo then
		for i, info in ipairs(taskInfo) do
			if HaveQuestData(info.questId) then
				if QuestUtils_IsQuestWorldQuest(info.questId) and WorldMap_DoesWorldQuestInfoPassFilters(info) then
					if not self.worldQuestsByZone[info.mapID] then
						self.worldQuestsByZone[info.mapID] = {};
					end
					table.insert(self.worldQuestsByZone[info.mapID], info);

					C_TaskQuest.RequestPreloadRewardData(info.questId);
				end
			end
		end
	end
end

function FlightMap_ZoneSummaryDataProvider:CheckMouse()
	if not self:GetMap():IsAtMaxZoom() and self:GetMap():GetMapID() and self:GetMap():IsCanvasMouseFocus() and (not GameTooltip:GetOwner() or GameTooltip:GetOwner() == self:GetMap()) then
		local mapID = self:GetMap():GetMapID();
		local mouseX, mouseY = self:GetMap():GetNormalizedCursorPosition();
		local mapInfo = C_Map.GetMapInfoAtPosition(mapID, mouseX, mouseY);

		if mapInfo and mapInfo.mapID ~= mapID then
			GameTooltip:SetOwner(self:GetMap(), "ANCHOR_CURSOR_RIGHT", 30);
			GameTooltip:SetText(mapInfo.name);

			local worldQuests = self.worldQuestsByZone[mapInfo.mapID];
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