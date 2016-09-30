ActiveQuestDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function ActiveQuestDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED");
	self:RegisterEvent("QUEST_POI_UPDATE");
	self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED");
end

function ActiveQuestDataProviderMixin:OnEvent(event, ...)
	if event == "QUEST_LOG_UPDATE" then
		self:RefreshAllData();
	elseif event == "QUEST_WATCH_LIST_CHANGED" then
		self:RefreshAllData();
	elseif event == "QUEST_POI_UPDATE" then
		self:RefreshAllData();
	elseif event == "SUPER_TRACKED_QUEST_CHANGED" then
		self:RefreshAllData();
	end
end

function ActiveQuestDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("ActiveQuestPinTemplate");
end

function ActiveQuestDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapAreaID = self:GetMap():GetMapID();
	for zoneIndex = 1, C_MapCanvas.GetNumZones(mapAreaID) do
		local zoneMapID, zoneName, zoneDepth, left, right, top, bottom = C_MapCanvas.GetZoneInfo(mapAreaID, zoneIndex);
		if zoneDepth <= 1 then -- Exclude subzones
			local activeQuestInfo = GetQuestsForPlayerByMapID(zoneMapID, mapAreaID);

			if activeQuestInfo then
				local superTrackedQuestID = GetSuperTrackedQuestID();
				for i, info in ipairs(activeQuestInfo) do
					if (IsQuestComplete(info.questID) or info.questID == superTrackedQuestID) and not QuestUtils_IsQuestWorldQuest(info.questID) then
						self:AddActiveQuest(info.questID, info.x, info.y);
					end
				end
			end
		end
	end
end

function ActiveQuestDataProviderMixin:AddActiveQuest(questID, x, y)
	local pin = self:GetMap():AcquirePin("ActiveQuestPinTemplate");
	pin.questID = questID;

	local isSuperTracked = questID == GetSuperTrackedQuestID();
	if ( isSuperTracked ) then
		pin:SetFrameLevel(100);
	else
		pin:SetFrameLevel(50);
	end

	pin.Number:ClearAllPoints();
	pin.Number:SetPoint("CENTER");

	if IsQuestComplete(questID) then
		-- If the quest is super tracked we want to show the selected circle behind it.
		if ( isSuperTracked ) then
			pin.Texture:SetSize(89, 90);
			pin.Highlight:SetSize(89, 90);
			pin.Number:SetSize(74, 74);
			pin.Number:ClearAllPoints();
			pin.Number:SetPoint("CENTER", -1, -1);
			pin.Texture:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
			pin.Texture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
			pin.Highlight:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
			pin.Highlight:SetTexCoord(0.625, 0.750, 0.875, 1);
			pin.Number:SetTexture("Interface/WorldMap/UI-WorldMap-QuestIcon");
			pin.Number:SetTexCoord(0, 0.5, 0, 0.5);
			pin.Number:Show();
		else
			pin.Texture:SetSize(95, 95);
			pin.Highlight:SetSize(95, 95);
			pin.Number:SetSize(85, 85);
			pin.Texture:SetTexture("Interface/WorldMap/UI-WorldMap-QuestIcon");
			pin.Highlight:SetTexture("Interface/WorldMap/UI-WorldMap-QuestIcon");
			pin.Texture:SetTexCoord(0, 0.5, 0, 0.5);
			pin.Highlight:SetTexCoord(0.5, 1, 0, 0.5);
			pin.Number:Hide();
		end
	elseif ( isSuperTracked ) then
		pin.style = "numeric";	-- for tooltip
		pin.Texture:SetSize(75, 75);
		pin.Highlight:SetSize(75, 75);
		pin.Number:SetSize(85, 85);

		pin.Texture:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
		pin.Highlight:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");

		pin.Texture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
		pin.Highlight:SetTexCoord(0.625, 0.750, 0.375, 0.5);

		-- try to match the number with tracker POI if possible
		local questNumber = 1;
		local poiButton = QuestPOI_FindButton(ObjectiveTrackerFrame.BlocksFrame, questID);
		if ( poiButton and poiButton.style == "numeric" ) then
			questNumber = poiButton.index;
		end
		pin.Number:SetTexCoord(QuestPOI_CalculateNumericTexCoords(questNumber, QUEST_POI_COLOR_BLACK));
		pin.Number:Show();
	end

	pin:SetPosition(x, y);
	pin:Show();
end

--[[ Active Quest Pin ]]--
ActiveQuestPinMixin = CreateFromMixins(MapCanvasPinMixin);

function ActiveQuestPinMixin:OnLoad()
	self:SetAlphaLimits(1.0, 1.0, 1.0);
	self:SetScalingLimits(1, 1.5, 0.50);

	self.UpdateTooltip = self.OnMouseEnter;

	-- Flight points can nudge quest pins.
	self:SetNudgeTargetFactor(0.015);
	self:SetNudgeZoomedOutFactor(1.0);
	self:SetNudgeZoomedInFactor(0.25);
end

function ActiveQuestPinMixin:OnMouseEnter()
	WorldMap_HijackTooltip(self:GetMap());

	WorldMapQuestPOI_SetTooltip(self, GetQuestLogIndexByID(self.questID));
end

function ActiveQuestPinMixin:OnMouseLeave()
	WorldMapPOIButton_OnLeave(self);

	WorldMap_RestoreTooltip();
end