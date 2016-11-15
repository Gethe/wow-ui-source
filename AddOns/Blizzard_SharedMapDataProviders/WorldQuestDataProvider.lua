WorldQuestDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function WorldQuestDataProviderMixin:SetMatchWorldMapFilters(matchWorldMapFilters)
	local wasMatchingWorldMapFilters = self:IsMatchingWorldMapFilters();
	self.matchWorldMapFilters = matchWorldMapFilters;
	if wasMatchingWorldMapFilters ~= self:IsMatchingWorldMapFilters() and self:GetMap() and self:GetMap():GetMapID() then
		self:RefreshAllData();
	end
end

function WorldQuestDataProviderMixin:IsMatchingWorldMapFilters()
	return not not self.matchWorldMapFilters;
end

function WorldQuestDataProviderMixin:OnAdded(mapCanvas)
	self.activePins = {};
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED");
end

function WorldQuestDataProviderMixin:OnEvent(event, ...)
	if event == "SUPER_TRACKED_QUEST_CHANGED" then
		self:RefreshAllData();
	end
end

function WorldQuestDataProviderMixin:RemoveAllData()
	wipe(self.activePins);
	self:GetMap():RemoveAllPinsByTemplate("WorldQuestPinTemplate");
end

function WorldQuestDataProviderMixin:OnShow()
	assert(self.ticker == nil);
	self.ticker = C_Timer.NewTicker(10, function() self:RefreshAllData() end);
end

function WorldQuestDataProviderMixin:OnHide()
	self.ticker:Cancel();
	self.ticker = nil;
end

function WorldQuestDataProviderMixin:DoesWorldQuestInfoPassFilters(info)
	local ignoreTypeRequirements = not self:IsMatchingWorldMapFilters();
	local ignoreTimeRequirements = false;
	return WorldMap_DoesWorldQuestInfoPassFilters(info, ignoreTypeRequirements, ignoreTimeRequirements);
end

function WorldQuestDataProviderMixin:RefreshAllData(fromOnShow)
	local pinsToRemove = {};
	for questId in pairs(self.activePins) do
		pinsToRemove[questId] = true;
	end

	local mapAreaID = self:GetMap():GetMapID();
	for zoneIndex = 1, C_MapCanvas.GetNumZones(mapAreaID) do
		local zoneMapID, zoneName, zoneDepth, left, right, top, bottom = C_MapCanvas.GetZoneInfo(mapAreaID, zoneIndex);
		if zoneDepth <= 1 then -- Exclude subzones
			local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(zoneMapID, mapAreaID);

			if taskInfo then
				for i, info in ipairs(taskInfo) do
					if HaveQuestData(info.questId) then
						if QuestUtils_IsQuestWorldQuest(info.questId) then
							if self:DoesWorldQuestInfoPassFilters(info) then
								pinsToRemove[info.questId] = nil;
								local pin = self.activePins[info.questId];
								if pin then
									pin:RefreshVisuals();
								else
									self.activePins[info.questId] = self:AddWorldQuest(info);
								end
							end
						end
					end
				end
			end
		end
	end

	for questId in pairs(pinsToRemove) do
		self:GetMap():RemovePin(self.activePins[questId]);
		self.activePins[questId] = nil;
	end
end

function WorldQuestDataProviderMixin:AddWorldQuest(info)
	local pin = self:GetMap():AcquirePin("WorldQuestPinTemplate");
	pin.questID = info.questId;

	pin.worldQuest = true;
	pin.numObjectives = info.numObjectives;
	pin:SetFrameLevel(1000 + self:GetMap():GetNumActivePinsByTemplate("WorldQuestPinTemplate"));

	local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(info.questId);
	local tradeskillLineID = tradeskillLineIndex and select(7, GetProfessionInfo(tradeskillLineIndex));

	if rarity ~= LE_WORLD_QUEST_QUALITY_COMMON then
		pin.Background:SetTexCoord(0, 1, 0, 1);
		pin.Highlight:SetTexCoord(0, 1, 0, 1);

		pin.Background:SetSize(45, 45);
		pin.Highlight:SetSize(45, 45);
		pin.SelectedGlow:SetSize(45, 45);

		if rarity == LE_WORLD_QUEST_QUALITY_RARE then
			pin.Background:SetAtlas("worldquest-questmarker-rare");
			pin.Highlight:SetAtlas("worldquest-questmarker-rare");
			pin.SelectedGlow:SetAtlas("worldquest-questmarker-rare");
		elseif rarity == LE_WORLD_QUEST_QUALITY_EPIC then
			pin.Background:SetAtlas("worldquest-questmarker-epic");
			pin.Highlight:SetAtlas("worldquest-questmarker-epic");
			pin.SelectedGlow:SetAtlas("worldquest-questmarker-epic");
		end
	else
		pin.Background:SetSize(75, 75);
		pin.Highlight:SetSize(75, 75);

		-- We are setting the texture without updating the tex coords.  Refresh visuals will handle
		-- updating the tex coords based on whether this pin is selected or not.
		pin.Background:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
		pin.Highlight:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");

		pin.Highlight:SetTexCoord(0.625, 0.750, 0.875, 1);
	end
	
	pin:RefreshVisuals();

	if isElite then
		pin.Underlay:SetAtlas("worldquest-questmarker-dragon");
		pin.Underlay:Show();
	else
		pin.Underlay:Hide();
	end

	if worldQuestType == LE_QUEST_TAG_TYPE_PVP then
		local _, width, height = GetAtlasInfo("worldquest-icon-pvp-ffa");
		pin.Texture:SetAtlas("worldquest-icon-pvp-ffa");
		pin.Texture:SetSize(width * 2, height * 2);
	elseif worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE then
		pin.Texture:SetAtlas("worldquest-icon-petbattle");
		pin.Texture:SetSize(26, 22);
	elseif worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION and WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID] then
		local _, width, height = GetAtlasInfo(WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID]);
		pin.Texture:SetAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID]);
		pin.Texture:SetSize(width * 2, height * 2);
	elseif worldQuestType == LE_QUEST_TAG_TYPE_DUNGEON then
		local _, width, height = GetAtlasInfo("worldquest-icon-dungeon");
		pin.Texture:SetAtlas("worldquest-icon-dungeon");
		pin.Texture:SetSize(width * 2, height * 2);
	else
		pin.Texture:SetAtlas("worldquest-questmarker-questbang");
		pin.Texture:SetSize(12, 30);
	end

	local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(info.questId);
	if timeLeftMinutes and timeLeftMinutes <= WORLD_QUESTS_TIME_LOW_MINUTES then
		pin.TimeLowFrame:Show();
	else
		pin.TimeLowFrame:Hide();
	end

	pin:SetPosition(info.x, info.y);
	pin:Show();

	C_TaskQuest.RequestPreloadRewardData(info.questId);

	return pin;
end

--[[ World Quest Pin ]]--
WorldQuestPinMixin = CreateFromMixins(MapCanvasPinMixin);

function WorldQuestPinMixin:OnLoad()
	self:SetAlphaLimits(2.0, 0.0, 1.0);
	self:SetScalingLimits(1, 1.5, 0.50);

	self.UpdateTooltip = self.OnMouseEnter;

	-- Flight points can nudge world quests.
	self:SetNudgeTargetFactor(0.015);
	self:SetNudgeZoomedOutFactor(1.0);
	self:SetNudgeZoomedInFactor(0.25);
end

function WorldQuestPinMixin:RefreshVisuals()
	local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(self.questID);
	local selected = self.questID == GetSuperTrackedQuestID();
	self.Glow:SetShown(selected);
	self.SelectedGlow:SetShown(rarity ~= LE_WORLD_QUEST_QUALITY_COMMON and selected);
	
	if rarity == LE_WORLD_QUEST_QUALITY_COMMON then
		if selected then
			self.Background:SetTexCoord(0.500, 0.625, 0.375, 0.5);
		else
			self.Background:SetTexCoord(0.875, 1, 0.375, 0.5);
		end
	end
	
	if IsWorldQuestWatched(self.questID) then
		self:SetAlphaLimits(nil, 0.0, 1.0);
		self:SetAlpha(1);
	else
		self:SetAlphaLimits(2.0, 0.0, 1.0);
	end
	
	self:Show();
end

function WorldQuestPinMixin:OnMouseEnter()
	WorldMap_HijackTooltip(self:GetMap());

	TaskPOI_OnEnter(self);
end

function WorldQuestPinMixin:OnMouseLeave()
	TaskPOI_OnLeave(self);

	WorldMap_RestoreTooltip();
end