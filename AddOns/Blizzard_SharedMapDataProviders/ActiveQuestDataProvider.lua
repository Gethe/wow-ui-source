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

	self.usedQuestNumbers = self.usedQuestNumbers or {};
	self.pinsMissingNumbers = self.pinsMissingNumbers or {};

	local mapAreaID = self:GetMap():GetMapID();
	for zoneIndex = 1, C_MapCanvas.GetNumZones(mapAreaID) do
		local zoneMapID, zoneName, zoneDepth, left, right, top, bottom = C_MapCanvas.GetZoneInfo(mapAreaID, zoneIndex);
		if zoneDepth <= 1 then -- Exclude subzones
			local activeQuestInfo = GetQuestsForPlayerByMapID(zoneMapID, mapAreaID, self:GetTransformFlags());

			if activeQuestInfo then
				for i, info in ipairs(activeQuestInfo) do
					if not QuestUtils_IsQuestWorldQuest(info.questID) then
						self:AddActiveQuest(info.questID, info.x, info.y);
					end
				end
			end
		end
	end

	self:AssignMissingNumbersToPins();
end

function ActiveQuestDataProviderMixin:AssignMissingNumbersToPins()
	if #self.pinsMissingNumbers > 0 then
		for questNumber = 1, MAX_NUM_QUESTS do
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

function ActiveQuestDataProviderMixin:AddActiveQuest(questID, x, y)
	local pin = self:GetMap():AcquirePin("ActiveQuestPinTemplate");
	pin.questID = questID;

	local isSuperTracked = questID == GetSuperTrackedQuestID();
	local isComplete = IsQuestComplete(questID);

	pin.isSuperTracked = isSuperTracked;

	if ( isSuperTracked ) then
		pin:SetFrameLevel(100);
	else
		pin:SetFrameLevel(50);
	end

	pin.Number:ClearAllPoints();
	pin.Number:SetPoint("CENTER");

	if isSuperTracked or isComplete then
		pin:SetAlphaLimits(nil, 0.0, 1.0);
		pin:SetAlpha(1);
	else
		pin:SetAlphaLimits(2.0, 0.0, 1.0);
	end

	if isComplete then
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
	else
		pin.style = "numeric";	-- for tooltip
		pin.Texture:SetSize(75, 75);
		pin.Highlight:SetSize(75, 75);
		pin.Number:SetSize(85, 85);

		pin.Texture:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
		pin.Highlight:SetTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");

		if isSuperTracked then
			pin.Texture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
		else
			pin.Texture:SetTexCoord(0.875, 1, 0.375, 0.5);
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
end

--[[ Active Quest Pin ]]--
ActiveQuestPinMixin = CreateFromMixins(MapCanvasPinMixin);

function ActiveQuestPinMixin:OnLoad()
	self:SetAlphaLimits(2.0, 0.0, 1.0);
	self:SetScalingLimits(1, 0.4125, 0.425);

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

function ActiveQuestPinMixin:OnClick(button)
	QuestPOIButton_OnClick(self, button);
end

function ActiveQuestPinMixin:AssignQuestNumber(questNumber)
	self.Number:SetTexCoord(QuestPOI_CalculateNumericTexCoords(questNumber, self.isSuperTracked and QUEST_POI_COLOR_BLACK or QUEST_POI_COLOR_YELLOW));
end