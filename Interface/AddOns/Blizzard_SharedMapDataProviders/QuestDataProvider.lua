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
		self.setFocusedQuestIDCallback = function(event, ...) self:SetFocusedQuestID(...); end;
	end
	if not self.clearFocusedQuestIDCallback then
		self.clearFocusedQuestIDCallback = function(event, ...) self:ClearFocusedQuestID(...); end;
	end
	
	self:GetMap():RegisterCallback("SetFocusedQuestID", self.setFocusedQuestIDCallback, self);
	self:GetMap():RegisterCallback("ClearFocusedQuestID", self.clearFocusedQuestIDCallback, self);
end

function QuestDataProviderMixin:OnRemoved(mapCanvas)
	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);

	self:GetMap():UnregisterCallback("SetFocusedQuestID", self);
	self:GetMap():UnregisterCallback("ClearFocusedQuestID", self);
end

function QuestDataProviderMixin:SetFocusedQuestID(questID)
	self.focusedQuestID = questID;
	self:RefreshAllData();
end

function QuestDataProviderMixin:ClearFocusedQuestID(questID)
	self.focusedQuestID = nil;
	self:RefreshAllData();
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
	if questsOnMap then
		for i, info in ipairs(questsOnMap) do
			if self:ShouldShowQuest(info.questID, mapInfo.mapType, doesMapShowTaskObjectives) then
				local pin = self:AddQuest(info.questID, info.x, info.y, i);
				table.insert(pinsToQuantize, pin);
			end
		end
	end

	self:AssignMissingNumbersToPins();

	self.poiQuantizer:ClearAndQuantize(pinsToQuantize);

	for i, pin in pairs(pinsToQuantize) do
		pin:SetPosition(pin.quantizedX or pin.normalizedX, pin.quantizedY or pin.normalizedY);
	end
end

function QuestDataProviderMixin:ShouldShowQuest(questID, mapType, doesMapShowTaskObjectives)
	if self.focusedQuestID and self.focusedQuestID ~= questID then
		return false;
	end
	if QuestUtils_IsQuestWorldQuest(questID) then
		if not doesMapShowTaskObjectives then
			return false;
		end
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

function QuestDataProviderMixin:AddQuest(questID, x, y, frameLevelOffset)
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
			pin.Texture:SetSize(89, 90);
			pin.PushedTexture:SetSize(89, 90);
			pin.Highlight:SetSize(89, 90);
			pin.Number:SetSize(74, 74);
			pin.Number:ClearAllPoints();
			pin.Number:SetPoint("CENTER", -1, -1);
			pin.Texture:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
			pin.Texture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
			pin.PushedTexture:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
			pin.PushedTexture:SetTexCoord(0.375, 0.500, 0.375, 0.5);
			pin.Highlight:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
			pin.Highlight:SetTexCoord(0.625, 0.750, 0.875, 1);
			pin.Number:SetTexture("Interface/WorldMap/UI-WorldMap-QuestIcon");
			pin.Number:SetTexCoord(0, 0.5, 0, 0.5);
			pin.Number:Show();
		else
			pin.Texture:SetSize(95, 95);
			pin.PushedTexture:SetSize(95, 95);
			pin.Highlight:SetSize(95, 95);
			pin.Number:SetSize(85, 85);
			pin.Texture:SetTexture("Interface/WorldMap/UI-WorldMap-QuestIcon");
			pin.PushedTexture:SetTexture("Interface/WorldMap/UI-WorldMap-QuestIcon");
			pin.Highlight:SetTexture("Interface/WorldMap/UI-WorldMap-QuestIcon");
			pin.Texture:SetTexCoord(0, 0.5, 0, 0.5);
			pin.PushedTexture:SetTexCoord(0, 0.5, 0.5, 1);
			pin.Highlight:SetTexCoord(0.5, 1, 0, 0.5);
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
	local questLogIndex = GetQuestLogIndexByID(self.questID);
	local title = GetQuestLogTitle(questLogIndex);
	WorldMapTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 5, 2);
	WorldMapTooltip:SetText(title);
	QuestUtils_AddQuestTypeToTooltip(WorldMapTooltip, self.questID, NORMAL_FONT_COLOR);

	if poiButton and poiButton.style ~= "numeric" then
		local completionText = GetQuestLogCompletionText(questLogIndex) or QUEST_WATCH_QUEST_READY;
		WorldMapTooltip:AddLine(QUEST_DASH..completionText, 1, 1, 1, true);
	else
		local numItemDropTooltips = GetNumQuestItemDrops(questLogIndex);
		if numItemDropTooltips > 0 then
			for i = 1, numItemDropTooltips do
				local text, objectiveType, finished = GetQuestLogItemDrop(i, questLogIndex);
				if ( text and not finished ) then
					WorldMapTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
				end
			end
		else
			local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
			for i = 1, numObjectives do
				local text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogIndex);
				if ( text and not finished ) then
					WorldMapTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
				end
			end
		end
	end
	WorldMapTooltip:Show();
	self:GetMap():TriggerEvent("SetHighlightedQuestPOI", self.questID);
end

function QuestPinMixin:OnMouseLeave()
	WorldMapTooltip:Hide();
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