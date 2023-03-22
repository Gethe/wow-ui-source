QuestDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function QuestDataProviderMixin:GetPinTemplate()
	return "QuestPinTemplate";
end

function QuestDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED");
	self:RegisterEvent("QUEST_POI_UPDATE");
	self:RegisterEvent("SUPER_TRACKING_CHANGED");

	if not self.poiQuantizer then
		self.poiQuantizer = CreateFromMixins(WorldMapPOIQuantizerMixin);
		self.poiQuantizer.size = 75;
		self.poiQuantizer:OnLoad(self.poiQuantizer.size, self.poiQuantizer.size);
	end

	self:GetMap():RegisterCallback("SetFocusedQuestID", self.RefreshAllData, self);
	self:GetMap():RegisterCallback("ClearFocusedQuestID", self.RefreshAllData, self);
	self:GetMap():RegisterCallback("SetBounty", self.SetBounty, self);
	self:GetMap():RegisterCallback("PingQuestID", self.OnPingQuestID, self);
	EventRegistry:RegisterCallback("SetHighlightedQuestPOI", self.OnHighlightedQuestPOIChange, self);
	EventRegistry:RegisterCallback("ClearHighlightedQuestPOI", self.OnHighlightedQuestPOIChange, self);
end

function QuestDataProviderMixin:OnRemoved(mapCanvas)
	self:GetMap():UnregisterCallback("SetFocusedQuestID", self);
	self:GetMap():UnregisterCallback("ClearFocusedQuestID", self);
	self:GetMap():UnregisterCallback("SetBounty", self);
	self:GetMap():UnregisterCallback("PingQuestID", self);
	EventRegistry:UnregisterCallback("SetHighlightedQuestPOI", self);
	EventRegistry:UnregisterCallback("ClearHighlightedQuestPOI", self);

	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
end

function QuestDataProviderMixin:OnHighlightedQuestPOIChange(questID)
	for pin in self:GetMap():EnumeratePinsByTemplate(self:GetPinTemplate()) do
		if pin.questID == questID then
			QuestPOIButton_EvaluateManagedHighlight(pin);
			break;
		end
	end	
end

function QuestDataProviderMixin:OnPingQuestID(...)
	self:PingQuestID(...);
end

function QuestDataProviderMixin:PingQuestID(questID)
	if self.pingPin then
		self.pingPin:Stop();
	end

	local questPin;
	for pin in self:GetMap():EnumeratePinsByTemplate(self:GetPinTemplate()) do
		if pin.questID == questID then
			questPin = pin;
			break;
		end
	end

	if not questPin then
		return;
	end

	if not self.pingPin then
		self.pingPin = self:GetMap():AcquirePin("MapPinPingTemplate");
		self.pingPin.dataProvider = self;
		self.pingPin:UseFrameLevelType("PIN_FRAME_LEVEL_QUEST_PING");
		self.pingPin:SetNumLoops(2);
	end

	self.pingPin:SetID(questID);
	local x, y = questPin:GetPosition()
	self.pingPin:PlayAt(x, y);
end

function QuestDataProviderMixin:SetBounty(bountyQuestID, bountyFactionID, bountyFrameType)
	local changed = self.bountyQuestID ~= bountyQuestID;
	if changed then
		self.bountyQuestID = bountyQuestID;
		self.bountyFactionID = bountyFactionID;
		self.bountyFrameType = bountyFrameType;
		if self:GetMap() then
			self:RefreshAllData();
		end
	end
end

function QuestDataProviderMixin:GetBountyInfo()
	return self.bountyQuestID, self.bountyFactionID, self.bountyFrameType;
end

function QuestDataProviderMixin:OnEvent(event, ...)
	if event == "QUEST_LOG_UPDATE" then
		self:RefreshAllData();
	elseif event == "QUEST_WATCH_LIST_CHANGED" then
		self:RefreshAllData();
	elseif event == "QUEST_POI_UPDATE" then
		self:RefreshAllData();
	elseif event == "SUPER_TRACKING_CHANGED" then
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

	local pingQuestID = self.pingPin and self.pingPin:GetID();
	local foundQuestToPing = false;

	local pinsToQuantize = { };

	local mapInfo = C_Map.GetMapInfo(mapID);
	local questsOnMap = C_QuestLog.GetQuestsOnMap(mapID);
	local doesMapShowTaskObjectives = C_TaskQuest.DoesMapShowTaskQuestObjectives(mapID);

	local function CheckAddQuest(questID, x, y, isMapIndicatorQuest, frameLevelOffset, isWaypoint)
		if self:ShouldShowQuest(questID, mapInfo.mapType, doesMapShowTaskObjectives, isMapIndicatorQuest) then
			local pin = self:AddQuest(questID, x, y, frameLevelOffset, isWaypoint);
			table.insert(pinsToQuantize, pin);
			if questID == pingQuestID then
				self.pingPin:SetPosition(x, y);
				foundQuestToPing = true;
			end
		end
	end

	if questsOnMap then
		for i, info in ipairs(questsOnMap) do
			CheckAddQuest(info.questID, info.x, info.y, info.isMapIndicatorQuest, i);
		end
	end

	if pingQuestID and not foundQuestToPing then
		self.pingPin:Stop();
	end

	local waypointQuestID = QuestMapFrame_GetFocusedQuestID() or C_SuperTrack.GetSuperTrackedQuestID();
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
	if mapType == Enum.UIMapType.Continent and questID == C_SuperTrack.GetSuperTrackedQuestID() then
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

function QuestDataProviderMixin:AddQuest(questID, x, y, frameLevelOffset, isWaypoint)
	local pin = self:GetMap():AcquirePin(self:GetPinTemplate());
	pin.questID = questID;
	pin.dataProvider = self;
	QuestPOI_SetPinScale(pin, 2.5);

	local isSuperTracked = questID == C_SuperTrack.GetSuperTrackedQuestID();
	local isComplete = QuestCache:Get(questID):IsComplete();

	pin.isSuperTracked = isSuperTracked;

	if isSuperTracked then
		pin:UseFrameLevelType("PIN_FRAME_LEVEL_SUPER_TRACKED_QUEST");
	else
		pin:UseFrameLevelType("PIN_FRAME_LEVEL_ACTIVE_QUEST", frameLevelOffset);
	end

	pin.Display:ClearAllPoints();
	pin.Display:SetPoint("CENTER");
	pin.moveHighlightOnMouseDown = false;
	pin.selected = isSuperTracked;
	pin.style = QuestPOI_GetStyleFromQuestData(pin, isComplete, isWaypoint);

	if pin.style == "numeric" then
		-- try to match the number with tracker or quest log POI if possible
		local poiButton = QuestPOI_FindButton(ObjectiveTrackerFrame.BlocksFrame, questID) or QuestPOI_FindButton(QuestScrollFrame.Contents, questID);
		if poiButton and poiButton.style == "numeric" then
			local questNumber = poiButton.index;
			self.usedQuestNumbers[questNumber] = true;
			pin:SetQuestNumber(questNumber);
		else
			table.insert(self.pinsMissingNumbers, pin);
		end
	end

	QuestPOI_UpdateButtonStyle(pin);
	QuestPOIButton_EvaluateManagedHighlight(pin);

	MapPinHighlight_CheckHighlightPin(pin:GetHighlightType(), pin, pin.NormalTexture);

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
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
	local title = C_QuestLog.GetTitleForQuestID(questID);
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 5, 2);
	GameTooltip:SetText(title);
	QuestUtils_AddQuestTypeToTooltip(GameTooltip, questID, NORMAL_FONT_COLOR);
	GameTooltip_CheckAddQuestTimeToTooltip(GameTooltip, questID);

	local wouldShowWaypointText = questID == C_SuperTrack.GetSuperTrackedQuestID() or questID == QuestMapFrame_GetFocusedQuestID();
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
	QuestPOIHighlightManager:SetHighlight(questID);
    EventRegistry:TriggerEvent("MapCanvas.QuestPin.OnEnter", self, questID);
end

function QuestPinMixin:OnMouseLeave()
	GameTooltip:Hide();
	QuestPOIHighlightManager:ClearHighlight();
end

function QuestPinMixin:OnMouseClickAction(button)
	QuestPOIButton_OnClick(self, button);
	if not IsModifierKeyDown() then
		EventRegistry:TriggerEvent("MapCanvas.QuestPin.OnClick", self, self.questID);
	end
end

function QuestPinMixin:AssignQuestNumber(questNumber)
	self:SetQuestNumber(questNumber);
	QuestPOI_SetNumber(self);
end

function QuestPinMixin:SetQuestNumber(questNumber)
	self.index = questNumber;
end

function QuestPinMixin:GetHighlightType() -- override
	local bountyQuestID, bountyFactionID, bountyFrameType = self.dataProvider:GetBountyInfo();
	if bountyFrameType == BountyFrameType.ActivityTracker then
		if bountyFactionID and self.questID and C_QuestLog.DoesQuestAwardReputationWithFaction(self.questID, bountyFactionID) then
			return MapPinHighlightType.SupertrackedHighlight;
		end
	end

	return MapPinHighlightType.None;
end

function QuestPinMixin:OnMouseDownAction()
	self.NormalTexture:Hide();
	self.PushedTexture:Show();
	self.Display:UpdatePoint(true);
	if self.moveHighlightOnMouseDown then
		self.HighlightTexture:SetPoint("CENTER", 2, -2);
	end
end

function QuestPinMixin:OnMouseUpAction()
	self.NormalTexture:Show();
	self.PushedTexture:Hide();
	self.Display:UpdatePoint(false);
	if self.moveHighlightOnMouseDown then
		self.HighlightTexture:SetPoint("CENTER", 0, 0);
	end
end

-- This is the misery that results when one POI button is an actual Button and the other is a Frame.  (See: QuestPOI.xml)
function QuestPinMixin:IsEnabled()
	return true;
end