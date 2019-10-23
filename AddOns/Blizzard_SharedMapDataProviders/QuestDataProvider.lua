QuestDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function QuestDataProviderMixin:GetPinTemplate()
	return "QuestPinTemplate";
end

function QuestDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED");
	self:RegisterEvent("QUEST_POI_UPDATE");
	self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED");

	if not self.poiQuantizer then
		self.poiQuantizer = CreateFromMixins(WorldMapPOIQuantizerMixin);
		self.poiQuantizer.size = 75;
		self.poiQuantizer:OnLoad(self.poiQuantizer.size, self.poiQuantizer.size);
	end

	if not self.setFocusedQuestIDCallback then
		self.setFocusedQuestIDCallback = function(event, ...) self:RefreshAllData(...); end;
	end
	if not self.clearFocusedQuestIDCallback then
		self.clearFocusedQuestIDCallback = function(event, ...) self:RefreshAllData(...); end;
	end
	
	self:GetMap():RegisterCallback("SetFocusedQuestID", self.setFocusedQuestIDCallback);
	self:GetMap():RegisterCallback("ClearFocusedQuestID", self.clearFocusedQuestIDCallback);
end

function QuestDataProviderMixin:OnRemoved(mapCanvas)
	self:GetMap():UnregisterCallback("SetFocusedQuestID", self.setFocusedQuestIDCallback);
	self:GetMap():UnregisterCallback("ClearFocusedQuestID", self.clearFocusedQuestIDCallback);

	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
end

function QuestDataProviderMixin:OnEvent(event, ...)
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

function QuestDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function QuestDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	if not mapID then
		return;
	end

	if not GetCVarBool("questPOI") then
		return;
	end
	
	self.usedQuestNumbers = self.usedQuestNumbers or {};
	self.pinsMissingNumbers = self.pinsMissingNumbers or {};

	local pinsToQuantize = { };
	
	local mapInfo = C_Map.GetMapInfo(mapID);
	local questsOnMap = C_QuestLog.GetQuestsOnMap(mapID);
	local doesMapShowTaskObjectives = C_TaskQuest.DoesMapShowTaskQuestObjectives(mapID);
	
	local function CheckAddQuest(questID, x, y, isMapIndicatorQuest, frameLevelOffset, isWaypoint)
		if self:ShouldShowQuest(questID, mapInfo.mapType, doesMapShowTaskObjectives, isMapIndicatorQuest) then
			local pin = self:AddQuest(questID, x, y, frameLevelOffset, isWaypoint);
			table.insert(pinsToQuantize, pin);
		end
	end

	if questsOnMap then
		for i, info in ipairs(questsOnMap) do
			CheckAddQuest(info.questID, info.x, info.y, info.isMapIndicatorQuest, i);
		end
	end
	
	local waypointQuestID = QuestMapFrame_GetFocusedQuestID() or GetSuperTrackedQuestID();
	if waypointQuestID then
		local x, y = C_QuestLog.GetNextWaypointForMap(waypointQuestID, mapID);
		if x and y then
			local isMapIndicatorQuest = false;
			local frameLevelOffset = questsOnMap and (#questsOnMap + 1) or 0;
			local isWaypoint = true;
			CheckAddQuest(waypointQuestID, x, y, isMapIndicatorQuest, frameLevelOffset, isWaypoint);
		end
	end

	self:AssignMissingNumbersToPins();

	self.poiQuantizer:ClearAndQuantize(pinsToQuantize);

	for i, pin in pairs(pinsToQuantize) do
		pin:SetPosition(pin.quantizedX or pin.normalizedX, pin.quantizedY or pin.normalizedY);
	end
end

function QuestDataProviderMixin:ShouldShowQuest(questID, mapType, doesMapShowTaskObjectives, isMapIndicatorQuest)
	local focusedQuestID = QuestMapFrame_GetFocusedQuestID();
	if focusedQuestID and focusedQuestID ~= questID then
		return false;
	end
	if QuestUtils_IsQuestWorldQuest(questID) then
		if not doesMapShowTaskObjectives then
			return false;
		end
	end
	if QuestUtils_IsQuestBonusObjective(questID) then
		return false;
	end
	if isMapIndicatorQuest or not HaveQuestData(questID) then 
		return false; 
	end
	if mapType == Enum.UIMapType.Continent and questID == GetSuperTrackedQuestID() then 
		return true;
	end

	return MapUtil.ShouldMapTypeShowQuests(mapType);
end

function QuestDataProviderMixin:AssignMissingNumbersToPins()
	if #self.pinsMissingNumbers > 0 then
		for questNumber = 1, C_QuestLog.GetMaxNumQuests() do
			if not self.usedQuestNumbers[questNumber] then
				local pin = table.remove(self.pinsMissingNumbers);
				pin:AssignQuestNumber(questNumber);

				if #self.pinsMissingNumbers == 0 then
					break;
				end
			end
		end

		wipe(self.pinsMissingNumbers);
	end
	wipe(self.usedQuestNumbers);
end

function QuestDataProviderMixin:OnCanvasSizeChanged()
	local ratio = self:GetMap():DenormalizeHorizontalSize(1.0) / self:GetMap():DenormalizeVerticalSize(1.0);
	self.poiQuantizer:Resize(math.ceil(self.poiQuantizer.size * ratio), self.poiQuantizer.size);
end

local function GetQuestCompleteIcon(questID)
	local isLegendaryQuest = C_QuestLog.IsLegendaryQuest(questID);
	return isLegendaryQuest and "Interface/WorldMap/UI-WorldMap-QuestIcon-Legendary" or "Interface/WorldMap/UI-WorldMap-QuestIcon";
end

function QuestDataProviderMixin:AddQuest(questID, x, y, frameLevelOffset, isWaypoint)
	local pin = self:GetMap():AcquirePin(self:GetPinTemplate());
	pin.questID = questID;

	local isSuperTracked = questID == GetSuperTrackedQuestID();
	local isComplete = IsQuestComplete(questID);

	pin.isSuperTracked = isSuperTracked;

	if isSuperTracked then
		pin:UseFrameLevelType("PIN_FRAME_LEVEL_SUPER_TRACKED_QUEST");
	else
		pin:UseFrameLevelType("PIN_FRAME_LEVEL_ACTIVE_QUEST", frameLevelOffset);
	end

	pin.Number:ClearAllPoints();
	pin.Number:SetPoint("CENTER");
	pin.moveHighlightOnMouseDown = false;

	if isComplete then
		pin.style = "normal";
		
		-- If the quest is super tracked we want to show the selected circle behind it.
		if ( isSuperTracked ) then
			if isWaypoint then
				pin.Number:SetTexCoord(0, 1.0, 0, 1.0);
				pin.Number:SetAtlas("poi-traveldirections-arrow");

				-- We want the asset to be 13x17, but we need this to work right with scaling. Experimentally determined, (13 * 2.5) x (17 * 2.5)
				pin.Number:SetSize(32.5, 42.5);
			else
				local questCompleteIcon = GetQuestCompleteIcon(questID);
				pin.Number:SetTexCoord(0, 0.5, 0, 0.5);
				pin.Number:SetTexture(questCompleteIcon);
				pin.Number:SetSize(74, 74);
			end

			pin.Texture:SetSize(89, 90);
			pin.PushedTexture:SetSize(89, 90);
			pin.Highlight:SetSize(89, 90);
			pin.Number:ClearAllPoints();
			pin.Number:SetPoint("CENTER", -1, -1);
			pin.Texture:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
			pin.Texture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
			pin.PushedTexture:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
			pin.PushedTexture:SetTexCoord(0.375, 0.500, 0.375, 0.5);
			pin.Highlight:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
			pin.Highlight:SetTexCoord(0.625, 0.750, 0.875, 1);
			pin.Number:Show();
		else
			if isWaypoint then
				pin.Texture:SetTexCoord(0, 1.0, 0, 1.0);
				pin.PushedTexture:SetTexCoord(0, 1.0, 0, 1.0);
				pin.Highlight:SetTexCoord(0, 1.0, 0, 1.0);
				pin.Texture:SetAtlas("poi-traveldirections-arrow");
				pin.PushedTexture:SetAtlas("poi-traveldirections-arrow");
				pin.Highlight:SetAtlas("poi-traveldirections-arrow");

				-- We want the asset to be 13x17, but we need this to work right with scaling. Experimentally determined, (13 * 2.5) x (17 * 2.5)
				pin.Number:SetSize(32.5, 42.5);
				pin.Texture:SetSize(32.5, 42.5);
				pin.PushedTexture:SetSize(32.5, 42.5);
				pin.Highlight:SetSize(32.5, 42.5);
			else
				local questCompleteIcon = GetQuestCompleteIcon(questID);
				pin.Number:SetSize(85, 85);
				pin.Texture:SetSize(95, 95);
				pin.PushedTexture:SetSize(95, 95);
				pin.Highlight:SetSize(95, 95);
				pin.Texture:SetTexCoord(0, 0.5, 0, 0.5);
				pin.PushedTexture:SetTexCoord(0, 0.5, 0.5, 1);
				pin.Highlight:SetTexCoord(0.5, 1, 0, 0.5);
				pin.Texture:SetTexture(questCompleteIcon);
				pin.PushedTexture:SetTexture(questCompleteIcon);
				pin.Highlight:SetTexture(questCompleteIcon);
			end

			pin.moveHighlightOnMouseDown = true;
			pin.Number:Hide();
		end
	else
		pin.style = "numeric";	-- for tooltip
		pin.Texture:SetSize(75, 75);
		pin.PushedTexture:SetSize(75, 75);
		pin.Highlight:SetSize(75, 75);
		pin.Number:SetSize(85, 85);

		pin.Texture:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
		pin.PushedTexture:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
		pin.Highlight:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
		pin.Number:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");

		if isSuperTracked then
			pin.Texture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
			pin.PushedTexture:SetTexCoord(0.375, 0.500, 0.375, 0.5);
		else
			pin.Texture:SetTexCoord(0.875, 1, 0.375, 0.5);
			pin.PushedTexture:SetTexCoord(0.750, 0.875, 0.375, 0.5);
		end

		pin.Highlight:SetTexCoord(0.625, 0.750, 0.375, 0.5);

		-- try to match the number with tracker POI if possible
		local poiButton = QuestPOI_FindButton(ObjectiveTrackerFrame.BlocksFrame, questID);
		if poiButton and poiButton.style == "numeric" then
			local questNumber = poiButton.index;
			self.usedQuestNumbers[questNumber] = true;

			pin:AssignQuestNumber(questNumber);
		else
			table.insert(self.pinsMissingNumbers, pin);
		end

		pin.Number:Show();
	end

	pin:SetPosition(x, y);
	return pin;
end

--[[ Quest Pin ]]--
QuestPinMixin = CreateFromMixins(MapCanvasPinMixin);

function QuestPinMixin:OnLoad()
	self:SetScalingLimits(1, 0.4125, 0.4125);

	self.UpdateTooltip = self.OnMouseEnter;
end

function QuestPinMixin:OnMouseEnter()
	local questID = self.questID;
	local questLogIndex = GetQuestLogIndexByID(questID);
	local title = GetQuestLogTitle(questLogIndex);
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 5, 2);
	GameTooltip:SetText(title);
	QuestUtils_AddQuestTypeToTooltip(GameTooltip, questID, NORMAL_FONT_COLOR);

	local wouldShowWaypointText = questID == GetSuperTrackedQuestID() or questID == QuestMapFrame_GetFocusedQuestID();
	local waypointText = wouldShowWaypointText and C_QuestLog.GetNextWaypointText(questID);
	if waypointText then
		GameTooltip_AddColoredLine(GameTooltip, QUEST_DASH..waypointText, HIGHLIGHT_FONT_COLOR);
	elseif poiButton and poiButton.style ~= "numeric" then
		local completionText = GetQuestLogCompletionText(questLogIndex) or QUEST_WATCH_QUEST_READY;
		GameTooltip:AddLine(QUEST_DASH..completionText, 1, 1, 1, true);
	else
		local numItemDropTooltips = GetNumQuestItemDrops(questLogIndex);
		if numItemDropTooltips > 0 then
			for i = 1, numItemDropTooltips do
				local text, objectiveType, finished = GetQuestLogItemDrop(i, questLogIndex);
				if ( text and not finished ) then
					GameTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
				end
			end
		else
			local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
			for i = 1, numObjectives do
				local text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogIndex);
				if ( text and not finished ) then
					GameTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
				end
			end
		end
	end
	GameTooltip:Show();
	self:GetMap():TriggerEvent("SetHighlightedQuestPOI", questID);
end

function QuestPinMixin:OnMouseLeave()
	GameTooltip:Hide();
	self:GetMap():TriggerEvent("ClearHighlightedQuestPOI");
end

function QuestPinMixin:OnClick(button)
	QuestPOIButton_OnClick(self, button);
end

function QuestPinMixin:AssignQuestNumber(questNumber)
	self.Number:SetTexCoord(QuestPOI_CalculateNumericTexCoords(questNumber, self.isSuperTracked and QUEST_POI_COLOR_BLACK or QUEST_POI_COLOR_YELLOW));
end

function QuestPinMixin:OnMouseDown()
	self.Texture:Hide();
	self.PushedTexture:Show();
	self.Number:SetPoint("CENTER", 2, -2);
	if self.moveHighlightOnMouseDown then
		self.Highlight:SetPoint("CENTER", 2, -2);
	end
end

function QuestPinMixin:OnMouseUp()
	self.Texture:Show();
	self.PushedTexture:Hide();
	self.Number:SetPoint("CENTER", 0, 0);
	if self.moveHighlightOnMouseDown then
		self.Highlight:SetPoint("CENTER", 0, 0);
	end
end