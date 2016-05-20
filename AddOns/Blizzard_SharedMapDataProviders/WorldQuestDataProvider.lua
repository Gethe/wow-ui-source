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
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
end

function WorldQuestDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("WorldQuestPinTemplate");
end

function WorldQuestDataProviderMixin:OnShow()
	assert(self.ticker == nil);
	self.ticker = C_Timer.NewTicker(1, function() self:RefreshAllData() end);
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
	self:RemoveAllData();

	local mapAreaID = self:GetMap():GetMapID();
	for zoneIndex = 1, C_MapCanvas.GetNumZones(mapAreaID) do
		local zoneMapID, zoneName, left, right, top, bottom = C_MapCanvas.GetZoneInfo(mapAreaID, zoneIndex);
		local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(zoneMapID, mapAreaID);

		if taskInfo then
			for i, info in ipairs(taskInfo) do
				if HaveQuestData(info.questId) then
					if QuestMapFrame_IsQuestWorldQuest(info.questId) then
						if self:DoesWorldQuestInfoPassFilters(info) then
							self:AddWorldQuest(info);
						end
					end
				end
			end
		end
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
		
		if rarity == LE_WORLD_QUEST_QUALITY_RARE then
			pin.Background:SetAtlas("worldquest-questmarker-rare");
			pin.Highlight:SetAtlas("worldquest-questmarker-rare");
		elseif rarity == LE_WORLD_QUEST_QUALITY_EPIC then
			pin.Background:SetAtlas("worldquest-questmarker-epic");
			pin.Highlight:SetAtlas("worldquest-questmarker-epic");
		end
	else
		pin.Background:SetSize(75, 75);
		pin.Highlight:SetSize(75, 75);

		pin.Background:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");	
		pin.Highlight:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");

		pin.Background:SetTexCoord(0.875, 1, 0.375, 0.5);
		pin.Highlight:SetTexCoord(0.625, 0.750, 0.875, 1);
	end

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
	elseif worldQuestType == LE_QUEST_TAG_TYPE_WORLD_BOSS then
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
end

--[[ World Quest Pin ]]--
WorldQuestPinMixin = CreateFromMixins(MapCanvasPinMixin);

function WorldQuestPinMixin:OnLoad()
	self:SetAlphaLimits(2.0, 0.0, 1.0);
	self:SetScalingLimits(1, 1.0, 0.50);

	self.UpdateTooltip = self.OnMouseEnter;
end

function WorldQuestPinMixin:OnMouseEnter()
	WorldMapTooltip:SetParent(self:GetMap());
	WorldMapTooltip:SetFrameStrata("TOOLTIP");
	TaskPOI_OnEnter(self);
end

function WorldQuestPinMixin:OnMouseLeave()
	TaskPOI_OnLeave(self);
	WorldMapTooltip:SetParent(WorldMapFrame);
	WorldMapTooltip:SetFrameStrata("TOOLTIP");
end