
local MIN_STORY_TOOLTIP_WIDTH = 240;

local tooltipButton;

function QuestMapFrame_OnLoad(self)
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED");
	self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("QUEST_POI_UPDATE");
	self:RegisterEvent("QUEST_WATCH_UPDATE");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");

	QuestPOI_Initialize(QuestScrollFrame.Contents);
	QuestMapQuestOptionsDropDown.questID = 0;		-- for QuestMapQuestOptionsDropDown_Initialize
	UIDropDownMenu_Initialize(QuestMapQuestOptionsDropDown, QuestMapQuestOptionsDropDown_Initialize, "MENU");
end

function QuestMapFrame_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( (event == "QUEST_LOG_UPDATE" or (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player")) and not self.ignoreQuestLogUpdate ) then
		if (not IsTutorialFlagged(55) and TUTORIAL_QUEST_TO_WATCH) then
			local isComplete = select(6, GetQuestLogTitle(GetQuestLogIndexByID(TUTORIAL_QUEST_TO_WATCH)));
			if (isComplete) then
				TriggerTutorial(55);
			end
		end

		if ( tooltipButton ) then
			QuestMapLogTitleButton_OnEnter(tooltipButton);
		end
		
		local updateButtons = false;
		if ( QuestLogPopupDetailFrame.questID ) then
			if ( GetQuestLogIndexByID(QuestLogPopupDetailFrame.questID) == 0 ) then
				HideUIPanel(QuestLogPopupDetailFrame);
			else
				QuestLogPopupDetailFrame_Update();
				updateButtons = true;
			end
		end		
		local questDetailID = QuestMapFrame.DetailsFrame.questID;
		if ( questDetailID ) then
			if ( GetQuestLogIndexByID(questDetailID) == 0 ) then
				-- this will call QuestMapFrame_UpdateAll
				QuestMapFrame_ReturnFromQuestDetails();
				return;
			else
				updateButtons = true;
			end
		end
		if ( updateButtons ) then
			QuestMapFrame_UpdateQuestDetailsButtons();
		end
		QuestMapFrame_UpdateAll();
	elseif ( event == "QUEST_WATCH_UPDATE" ) then
		if (not IsTutorialFlagged(11) and TUTORIAL_QUEST_TO_WATCH) then
			local questID = select(8, GetQuestLogTitle(arg1));
			if (questID == TUTORIAL_QUEST_TO_WATCH) then
				TriggerTutorial(11);
			end
		end
		if ( AUTO_QUEST_WATCH == "1" and 
			GetNumQuestLeaderBoards(arg1) > 0 and 
			GetNumQuestWatches() < MAX_WATCHABLE_QUESTS ) then
			AddQuestWatch(arg1);
		end	
	elseif ( event == "QUEST_WATCH_LIST_CHANGED" ) then
		QuestMapFrame_UpdateQuestDetailsButtons();
		QuestMapFrame_UpdateAll();
	elseif ( event == "SUPER_TRACKED_QUEST_CHANGED" ) then
		local questID = ...;
		QuestPOI_SelectButtonByQuestID(QuestScrollFrame.Contents, questID);
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		if ( QuestMapFrame.DetailsFrame.questID ) then
			QuestMapFrame_UpdateQuestDetailsButtons();
		end

		if ( self:IsVisible() ) then
			QuestMapFrame_UpdateAll();
		end
	elseif ( event == "QUEST_POI_UPDATE" ) then
		QuestMapFrame_UpdateAll();
	elseif ( event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" ) then
		if ( self:IsVisible() ) then
			QuestMapFrame_UpdateAll();
		end	
	elseif ( event == "QUEST_ACCEPTED" ) then
		TUTORIAL_QUEST_ACCEPTED = arg2;
	end
end

-- opening/closing the quest frame is different from showing/hiding because of fullscreen map mode
-- opened indicates the quest frame should show in windowed map mode
-- in fullscreen map mode the quest frame could be opened but hidden
function QuestMapFrame_Open(userAction)
	if ( userAction ) then
		SetCVar("questLogOpen", 1);
	end
	if ( WorldMapFrame_InWindowedMode() ) then
		QuestMapFrame_Show();
	end
end

function QuestMapFrame_Close(userAction)
	if ( userAction ) then
		SetCVar("questLogOpen", 0);
	end
	QuestMapFrame_Hide();
end

function QuestMapFrame_Show()
	if ( not QuestMapFrame:IsShown() ) then
		WorldMapFrame:SetWidth(992);
		WorldMapFrame.BorderFrame:SetWidth(992);
		
		QuestMapFrame_UpdateAll();
		
		QuestMapFrame:Show();
	
		WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:Hide();
		WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:Show();
		
		if ( TutorialFrame.id == 1 or TutorialFrame.id == 55 or TutorialFrame.id == 57 ) then
			TutorialFrame_Hide();
		end
	end
end

function QuestMapFrame_Hide()
	if ( QuestMapFrame:IsShown() ) then
		WorldMapFrame:SetWidth(702);
		WorldMapFrame.BorderFrame:SetWidth(702);
		QuestMapFrame:Hide();
		QuestMapFrame_UpdateAll();

		WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:Show();
		WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:Hide();
		
		QuestMapFrame_CheckTutorials();
	end
end

function QuestMapFrame_CheckTutorials()
	if (TUTORIAL_QUEST_ACCEPTED) then
		if (not IsTutorialFlagged(2)) then
			local _, raceName  = UnitRace("player");
			if ( strupper(raceName) ~= "PANDAREN" ) then
				TriggerTutorial(2);
			end
		end
		if (not IsTutorialFlagged(10) and (TUTORIAL_QUEST_ACCEPTED == TUTORIAL_QUEST_TO_WATCH)) then
			TriggerTutorial(10);
		end
		TUTORIAL_QUEST_ACCEPTED = nil;
	end
end

function QuestMapFrame_UpdateAll()
	local numPOIs = QuestMapUpdateAllQuests();
	QuestPOIUpdateIcons();
	QuestObjectiveTracker_UpdatePOIs();
	if ( WorldMapFrame:IsShown() ) then	
		local poiTable = { };
		if ( numPOIs > 0 and GetCVarBool("questPOI") ) then
			WorldMapBlobFrame:Show();
			WorldMapPOIFrame:Show();
			GetQuestPOIs(poiTable);
		else
			WorldMapBlobFrame:Hide();
			WorldMapPOIFrame:Hide();
		end
		local questDetailID = QuestMapFrame.DetailsFrame.questID;
		if ( questDetailID ) then
			-- update rewards
			SelectQuestLogEntry(GetQuestLogIndexByID(questDetailID));	
			QuestInfo_Display(QUEST_TEMPLATE_MAP_REWARDS, QuestMapFrame.DetailsFrame.RewardsFrame, nil, nil, true);
		else
			QuestLogQuests_Update(poiTable);
		end
		WorldMapPOIFrame_Update(poiTable);
		QuestMapFrameViewAllButton_Update();
	end
end

function QuestMapFrame_ShowQuestDetails(questID)
	local questLogIndex = GetQuestLogIndexByID(questID);
	SelectQuestLogEntry(questLogIndex);
	QuestInfo_Display(QUEST_TEMPLATE_MAP_DETAILS, QuestMapFrame.DetailsFrame.ScrollFrame.Contents);
	QuestInfo_Display(QUEST_TEMPLATE_MAP_REWARDS, QuestMapFrame.DetailsFrame.RewardsFrame, nil, nil, true);
	QuestMapFrame.DetailsFrame.ScrollFrame.ScrollBar:SetValue(0);
		
	local questPortrait, questPortraitText, questPortraitName = GetQuestLogPortraitGiver();
	if (questPortrait and questPortrait ~= 0 and QuestLogShouldShowPortrait() and (UIParent:GetRight() - WorldMapFrame:GetRight() > QuestNPCModel:GetWidth() + 6)) then
		QuestFrame_ShowQuestPortrait(WorldMapFrame, questPortrait, questPortraitText, questPortraitName, -2, -43);
		QuestNPCModel:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 2);
	else
		QuestFrame_HideQuestPortrait();
	end
		
	-- height
	local height = MapQuestInfoRewardsFrame:GetHeight() + 49;
	height = min(height, 275);
	QuestMapFrame.DetailsFrame.RewardsFrame:SetHeight(height);
	QuestMapFrame.DetailsFrame.RewardsFrame.Background:SetTexCoord(0, 1, 0, height / 275);

	QuestMapFrame.QuestsFrame:Hide();
	QuestMapFrame.DetailsFrame:Show();
	QuestMapFrame.DetailsFrame.questID = questID;
	
	-- save current view
	QuestMapFrame.DetailsFrame.continent = GetCurrentMapContinent();
	QuestMapFrame.DetailsFrame.mapID = GetCurrentMapAreaID();
	QuestMapFrame.DetailsFrame.questMapID = nil;	-- doing it now because GetQuestWorldMapAreaID will do a SetMap to current zone
	QuestMapFrame.DetailsFrame.dungeonFloor = GetCurrentMapDungeonLevel();
	
	local mapID, floorNumber = GetQuestWorldMapAreaID(questID);
	if ( mapID ~= 0 ) then
		SetMapByID(mapID);
		if ( floorNumber ~= 0 ) then
			SetDungeonMapLevel(floorNumber);
		end
	end
	
	QuestMapFrame_UpdateQuestDetailsButtons();
	QuestMapFrame.DetailsFrame.questMapID = GetCurrentMapAreaID();

	if ( IsQuestComplete(questID) and GetQuestLogIsAutoComplete(questLogIndex) ) then
		QuestMapFrame.DetailsFrame.CompleteQuestFrame:Show();
		QuestMapFrame.DetailsFrame.RewardsFrame:SetPoint("BOTTOMLEFT", 0, 44);
	else
		QuestMapFrame.DetailsFrame.CompleteQuestFrame:Hide();
		QuestMapFrame.DetailsFrame.RewardsFrame:SetPoint("BOTTOMLEFT", 0, 20);
	end
	
	StaticPopup_Hide("ABANDON_QUEST");
	StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
end

function QuestMapFrame_CloseQuestDetails()
	QuestMapFrame.QuestsFrame:Show();
	QuestMapFrame.DetailsFrame:Hide();
	QuestMapFrame.DetailsFrame.questID = nil;
	QuestMapFrame.DetailsFrame.questMapID = nil;
	QuestMapFrame_UpdateAll();
	QuestFrame_HideQuestPortrait();

	StaticPopup_Hide("ABANDON_QUEST");
	StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");	
end

function QuestMapFrame_UpdateQuestDetailsButtons()
	local questLogSelection = GetQuestLogSelection();
	local _, _, _, _, _, _, _, questID = GetQuestLogTitle(questLogSelection);
	if ( CanAbandonQuest(questID)) then
		QuestMapFrame.DetailsFrame.AbandonButton:Enable();
		QuestLogPopupDetailFrame.AbandonButton:Enable();
	else
		QuestMapFrame.DetailsFrame.AbandonButton:Disable();
		QuestLogPopupDetailFrame.AbandonButton:Disable();
	end

	if ( IsQuestWatched(questLogSelection) ) then
		QuestMapFrame.DetailsFrame.TrackButton:SetText(UNTRACK_QUEST_ABBREV);
		QuestLogPopupDetailFrame.TrackButton:SetText(UNTRACK_QUEST_ABBREV);
	else
		QuestMapFrame.DetailsFrame.TrackButton:SetText(TRACK_QUEST_ABBREV);
		QuestLogPopupDetailFrame.TrackButton:SetText(TRACK_QUEST_ABBREV);
	end

	if ( GetQuestLogPushable() and IsInGroup() ) then
		QuestMapFrame.DetailsFrame.ShareButton:Enable();
		QuestLogPopupDetailFrame.ShareButton:Enable();
	else
		QuestMapFrame.DetailsFrame.ShareButton:Disable();
		QuestLogPopupDetailFrame.ShareButton:Disable();
	end
end

function QuestMapFrame_ReturnFromQuestDetails()
	if ( QuestMapFrame.DetailsFrame.mapID == -1 ) then
		SetMapZoom(QuestMapFrame.DetailsFrame.continent);
	elseif ( QuestMapFrame.DetailsFrame.mapID ) then
		SetMapByID(QuestMapFrame.DetailsFrame.mapID);
		if ( QuestMapFrame.DetailsFrame.dungeonFloor ~= 0 ) then
			SetDungeonMapLevel(QuestMapFrame.DetailsFrame.dungeonFloor);
		end
	end
	QuestMapFrame_CloseQuestDetails();
end

function QuestMapFrame_OpenToQuestDetails(questID)
	ShowQuestLog();
	QuestMapFrame_ShowQuestDetails(questID);
	-- back button should just close details
	QuestMapFrame.DetailsFrame.mapID = nil;
end

function QuestMapFrame_GetDetailQuestID()
	return QuestMapFrame.DetailsFrame.questID;
end

function QuestMapFrameViewAllButton_Update()
	local self = QuestMapFrame.QuestsFrame.ViewAll;
	local _, numQuests = GetNumQuestLogEntries();
	self:SetText(QUEST_MAP_VIEW_ALL_FORMAT:format(numQuests, MAX_QUESTLOG_QUESTS));
end

function QuestMapFrameViewAllButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	SetMapZoom(WORLDMAP_COSMIC_ID);
end

-- *****************************************************************************************************
-- ***** QUEST OPTIONS DROPDOWN
-- *****************************************************************************************************

function QuestMapQuestOptionsDropDown_Initialize(self)
	local questLogIndex = GetQuestLogIndexByID(self.questID);
	local info = UIDropDownMenu_CreateInfo();
	info.isNotRadio = true;
	info.notCheckable = true;

	info.text = TRACK_QUEST;
	if ( IsQuestWatched(questLogIndex) ) then
		info.text = UNTRACK_QUEST;
	end
	info.func =function(_, questID) QuestMapQuestOptions_TrackQuest(questID) end;
	info.arg1 = self.questID;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	info.text = SHARE_QUEST;
	info.func = function(_, questID) QuestMapQuestOptions_ShareQuest(questID) end;
	info.arg1 = self.questID;
	if ( not GetQuestLogPushable(questLogIndex) or not IsInGroup() ) then
		info.disabled = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	info.text = ABANDON_QUEST;
	info.func = function(_, questID) QuestMapQuestOptions_AbandonQuest(questID) end;
	info.arg1 = self.questID;
	info.disabled = nil;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
end

function QuestMapQuestOptions_TrackQuest(questID)
	local questLogIndex = GetQuestLogIndexByID(questID);
	if ( IsQuestWatched(questLogIndex) ) then
		QuestObjectiveTracker_UntrackQuest(nil, questLogIndex);
	else
		AddQuestWatch(questLogIndex, true);
		QuestSuperTracking_OnQuestTracked(questID);
	end
end

function QuestMapQuestOptions_ShareQuest(questID)
	local questLogIndex = GetQuestLogIndexByID(questID);
	QuestLogPushQuest(questLogIndex);
	PlaySound("igQuestLogOpen");
end

function QuestMapQuestOptions_AbandonQuest(questID)
	local lastQuestIndex = GetQuestLogSelection();
	SelectQuestLogEntry(GetQuestLogIndexByID(questID));
	SetAbandonQuest();
	local items = GetAbandonQuestItems();
	if ( items ) then
		StaticPopup_Hide("ABANDON_QUEST");
		StaticPopup_Show("ABANDON_QUEST_WITH_ITEMS", GetAbandonQuestName(), items);
	else
		StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
		StaticPopup_Show("ABANDON_QUEST", GetAbandonQuestName());
	end
	SelectQuestLogEntry(lastQuestIndex);
end

-- *****************************************************************************************************
-- ***** QUEST LIST
-- *****************************************************************************************************

function QuestLogQuests_GetHeaderButton(index)
	local headers = QuestMapFrame.QuestsFrame.Contents.Headers;
	if ( not headers[index] ) then
		local header = CreateFrame("BUTTON", nil, QuestMapFrame.QuestsFrame.Contents, "QuestLogHeaderTemplate");
		headers[index] = header;
	end
	return headers[index];
end

function QuestLogQuests_GetTitleButton(index)
	local titles = QuestMapFrame.QuestsFrame.Contents.Titles;
	if ( not titles[index] ) then
		local title = CreateFrame("BUTTON", nil, QuestMapFrame.QuestsFrame.Contents, "QuestLogTitleTemplate");
		titles[index] = title;
	end
	return titles[index];
end

local OBJECTIVE_FRAMES = { };
function QuestLog_GetObjectiveFrame(index)
	if ( not OBJECTIVE_FRAMES[index] ) then
		local frame = CreateFrame("FRAME", "QLOF"..index, QuestMapFrame.QuestsFrame.Contents, "QuestLogObjectiveTemplate");
		OBJECTIVE_FRAMES[index] = frame;
	end
	return OBJECTIVE_FRAMES[index];
end

function QuestLogQuests_Update(poiTable)
	local playerMoney = GetMoney();
    local numEntries, numQuests = GetNumQuestLogEntries();
	local showPOIs = GetCVarBool("questPOI");

	local mapID, isContinent = GetCurrentMapAreaID();
	local showQuestObjectives = (not isContinent) and (mapID > 0);
	
	local mapHeaderIndex = GetCurrentMapHeaderIndex();
	local button, prevButton;
	
	QuestPOI_ResetUsage(QuestScrollFrame.Contents);

	local poiFrameLevel = QuestLogQuests_GetHeaderButton(1):GetFrameLevel() + 2;

	local storyID, storyMapID = GetZoneStoryID();
	if ( storyID ) then
		QuestScrollFrame.Contents.StoryHeader:Show();
		QuestScrollFrame.Contents.StoryHeader.Text:SetText(GetMapNameByID(storyMapID));
		local numCriteria = GetAchievementNumCriteria(storyID);
		local completedCriteria = 0;
		for i = 1, numCriteria do
			local _, _, completed = GetAchievementCriteriaInfo(storyID, i);
			if ( completed ) then
				completedCriteria = completedCriteria + 1;
			end
		end
		QuestScrollFrame.Contents.StoryHeader.Progress:SetFormattedText(QUEST_STORY_STATUS, completedCriteria, numCriteria);
		if ( mapHeaderIndex > 0 ) then
			-- always expand header for story zone
			local _, _, _, _, isCollapsed = GetQuestLogTitle(mapHeaderIndex);
			if ( isCollapsed ) then
				-- ExpandQuestHeader will signal QUEST_LOG_UPDATE which would otherwise trigger another QuestLogQuests_Update
				QuestMapFrame.ignoreQuestLogUpdate = true;
				ExpandQuestHeader(mapHeaderIndex);
				QuestMapFrame.ignoreQuestLogUpdate = nil;
			end
		end
		prevButton = QuestScrollFrame.Contents.StoryHeader;
	else
		QuestScrollFrame.Contents.StoryHeader:Hide();
	end

	local localQuestsGroup;
	local firstLocalQuestButton;
	local nextQuestsGroup;
	local firstNextQuestButton;

	local headerIndex = 0;
	local titleIndex = 0;
	local objectiveIndex = 0;
	local headerTitle, headerOnMap, headerShown, headerLogIndex, mapHeaderButtonIndex;
	for questLogIndex = 1, numEntries do
		local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(questLogIndex);	
		local difficultyColor = GetQuestDifficultyColor(level);
		if ( isHeader ) then
			headerTitle = title;
			headerOnMap = isOnMap;
			headerShown = false;
			headerLogIndex = questLogIndex;
			difficultyColor = QuestDifficultyColors["header"];
			if ( questLogIndex == mapHeaderIndex ) then
				localQuestsGroup = true;
			elseif ( localQuestsGroup ) then
				localQuestsGroup = false;
				nextQuestsGroup = true;
			end
		elseif ( headerOnMap and isOnMap and not isTask ) then
			-- we have at least one valid entry, show the header for it
			if ( not headerShown and not showQuestObjectives ) then
				headerShown = true;
				headerIndex = headerIndex + 1;
				button = QuestLogQuests_GetHeaderButton(headerIndex);
				if ( headerTitle ) then
					button:SetText(headerTitle);
				else
					button:SetText("");
				end
				button:ClearAllPoints();
				if ( prevButton ) then
					button:SetPoint("TOPLEFT", prevButton, "BOTTOMLEFT", 0, 0);
				else
					button:SetPoint("TOPLEFT", 1, -6);
				end
				button:Show();				
				if ( mapHeaderIndex == headerLogIndex ) then
					mapHeaderButtonIndex = headerIndex;
				end
				button.questLogIndex = headerLogIndex;
				prevButton = button;
			end

			local totalHeight = 8;
			titleIndex = titleIndex + 1;
			button = QuestLogQuests_GetTitleButton(titleIndex);
			button.questID = questID;

			if ( localQuestsGroup and not firstLocalQuestButton ) then
				if ( titleIndex > 1 ) then
					firstLocalQuestButton = button;
				else
					-- no need to move this group of quests, it's already at the top
					localQuestsGroup = nil;
				end
			end
			if ( nextQuestsGroup and not firstNextQuestButton ) then
				firstNextQuestButton = button;
			end

			if ( displayQuestID ) then
				title = questID.." - "..title;
			end
			if ( ENABLE_COLORBLIND_MODE == "1" ) then
				title = "["..level.."] " .. title;
			end
			
			-- If not a header see if any nearby group mates are on this quest
			local partyMembersOnQuest = 0;
			for j=1, GetNumSubgroupMembers() do
				if ( IsUnitOnQuestByQuestID(questID, "party"..j) ) then
					partyMembersOnQuest = partyMembersOnQuest + 1;
				end
			end
			
			if ( partyMembersOnQuest > 0 ) then
				title = "["..partyMembersOnQuest.."] "..title;
			end

			button.Text:SetText(title);
			button.Text:SetTextColor( difficultyColor.r, difficultyColor.g, difficultyColor.b );
			
			totalHeight = totalHeight + button.Text:GetHeight();
			if ( IsQuestHardWatched(questLogIndex) ) then
				button.Check:Show();
				button.Check:SetPoint("LEFT", button.Text, button.Text:GetWrappedWidth() + 2, 0);
			else
				button.Check:Hide();
			end
			
			-- tag. daily icon can be alone or before other icons except for COMPLETED or FAILED
			local tagID;
			local questTagID, tagName = GetQuestTagInfo(questID);
			if ( isComplete and isComplete < 0 ) then
				tagID = "FAILED";
			elseif ( isComplete and isComplete > 0 ) then
				tagID = "COMPLETED";
			elseif( questTagID and questTagID == QUEST_TAG_ACCOUNT ) then
				local factionGroup = GetQuestFactionGroup(questID);
				if( factionGroup ) then
					tagID = "ALLIANCE";
					if ( factionGroup == LE_QUEST_FACTION_HORDE ) then
						tagID = "HORDE";
					end
				else
					tagID = QUEST_TAG_ACCOUNT;
				end
			elseif( frequency == LE_QUEST_FREQUENCY_DAILY and (not isComplete or isComplete == 0) ) then
				tagID = "DAILY";
			elseif( frequency == LE_QUEST_FREQUENCY_WEEKLY and (not isComplete or isComplete == 0) )then
				tagID = "WEEKLY";
			elseif( questTagID ) then
				tagID = questTagID;
			end

			if ( tagID ) then
				local tagCoords = QUEST_TAG_TCOORDS[tagID];
				if( tagCoords ) then
					button.TagTexture:SetTexCoord( unpack(tagCoords) );
					button.TagTexture:Show();
				end
			else
				button.TagTexture:Hide();
			end
			
			-- POI/objectives
			if ( showQuestObjectives ) then			
				local requiredMoney = GetQuestLogRequiredMoney(questLogIndex);
				local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
				-- complete?
				local isBreadcrumb = false;		
				if ( isComplete and isComplete < 0 ) then
					isComplete = false;
				elseif ( numObjectives == 0 and playerMoney >= requiredMoney and not startEvent) then
					isComplete = true;
					if ( requiredMoney == 0 ) then
						isBreadcrumb = true;
					end
				end
				-- objectives
				if ( isComplete ) then
					objectiveIndex = objectiveIndex + 1;
					local objectiveFrame = QuestLog_GetObjectiveFrame(objectiveIndex);
					objectiveFrame.questID = questID;
					objectiveFrame:Show();
					if ( isBreadcrumb ) then
						objectiveFrame.Text:SetText(GetQuestLogCompletionText(questLogIndex));
					else
						objectiveFrame.Text:SetText(QUEST_WATCH_QUEST_READY);
					end
					local height = objectiveFrame.Text:GetStringHeight();
					objectiveFrame:SetHeight(height);
					objectiveFrame:SetPoint("TOPLEFT", button.Text, "BOTTOMLEFT", 0, -3);
					totalHeight = totalHeight + height + 3;						
				else	
					local prevObjective;
					for i = 1, numObjectives do
						local text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogIndex);
						if ( text and not finished ) then
							objectiveIndex = objectiveIndex + 1;
							local objectiveFrame = QuestLog_GetObjectiveFrame(objectiveIndex);
							objectiveFrame.questID = questID;
							objectiveFrame:Show();
							objectiveFrame.Text:SetText(text);
							local height = objectiveFrame.Text:GetStringHeight();
							objectiveFrame:SetHeight(height);
							if ( prevObjective ) then
								objectiveFrame:SetPoint("TOPLEFT", prevObjective, "BOTTOMLEFT", 0, -2);
								height = height + 2;
							else
								objectiveFrame:SetPoint("TOPLEFT", button.Text, "BOTTOMLEFT", 0, -3);
								height = height + 3;
							end
							totalHeight = totalHeight + height;								
							prevObjective = objectiveFrame;
						end
					end
					if ( requiredMoney > playerMoney ) then
						objectiveIndex = objectiveIndex + 1;
						local objectiveFrame = QuestLog_GetObjectiveFrame(objectiveIndex);
						objectiveFrame.questID = questID;
						objectiveFrame:Show();
						objectiveFrame.Text:SetText(GetMoneyString(playerMoney).." / "..GetMoneyString(requiredMoney));
						local height = objectiveFrame.Text:GetStringHeight();
						objectiveFrame:SetHeight(height);
						if ( prevObjective ) then
							objectiveFrame:SetPoint("TOPLEFT", prevObjective, "BOTTOMLEFT", 0, -2);
							height = height + 2;
						else
							objectiveFrame:SetPoint("TOPLEFT", button.Text, "BOTTOMLEFT", 0, -3);
							height = height + 3;
						end
						totalHeight = totalHeight + height;
					end
				end
				-- POI
				if ( hasLocalPOI and showPOIs ) then			
					local poiButton;
					if ( isComplete ) then
						poiButton = QuestPOI_GetButton(QuestScrollFrame.Contents, questID, "normal", nil, isStory);
					else
						for i = 1, #poiTable do
							if ( poiTable[i] == questID ) then
								poiButton = QuestPOI_GetButton(QuestScrollFrame.Contents, questID, "numeric", i, isStory);
								break;
							end
						end
					end
					if ( poiButton ) then
						poiButton:SetPoint("TOPLEFT", button, 6, -4);
						poiButton:SetFrameLevel(poiFrameLevel);
						poiButton.parent = button;
					end
					-- extra room because of POI icon
					totalHeight = totalHeight + 6;
					button.Text:SetPoint("TOPLEFT", 31, -8);
				else
					button.Text:SetPoint("TOPLEFT", 31, -4);
				end
			else
				button.Text:SetPoint("TOPLEFT", 31, -4);
			end
			button:SetHeight(totalHeight);
			button.questLogIndex = questLogIndex;
			button:ClearAllPoints();
			if ( prevButton ) then
				button:SetPoint("TOPLEFT", prevButton, "BOTTOMLEFT", 0, 0);
			else
				button:SetPoint("TOPLEFT", 1, -6);
			end
			button:Show();			
			prevButton = button;
		end
	end

	-- if we have quests for this map, move them up
	if ( firstLocalQuestButton ) then
		local _, origAnchor = firstLocalQuestButton:GetPoint();
		-- if it's the last header, it will be the last quest button
		local lastQuestButton;		
		if ( firstNextQuestButton ) then
			_, lastQuestButton = firstNextQuestButton:GetPoint();		
		else
			lastQuestButton = QuestLogQuests_GetTitleButton(titleIndex);
		end
		-- now rearrange
		if ( storyID ) then
			firstLocalQuestButton:SetPoint("TOPLEFT", QuestScrollFrame.Contents.StoryHeader, "BOTTOMLEFT", 0, 0);
		else
			firstLocalQuestButton:SetPoint("TOPLEFT", 1, -6);
		end
		QuestLogQuests_GetTitleButton(1):SetPoint("TOPLEFT", lastQuestButton, "BOTTOMLEFT", 0, 0);
		if ( firstNextQuestButton ) then
			firstNextQuestButton:SetPoint("TOPLEFT", origAnchor, "BOTTOMLEFT", 0, 0);
		end	
	end

	-- background
	if ( titleIndex > 0 ) then
		QuestScrollFrame.Background:SetAtlas("QuestLogBackground", true);
	else
		QuestScrollFrame.Background:SetAtlas("NoQuestsBackground", true);
	end
	
	QuestPOI_SelectButtonByQuestID(QuestScrollFrame.Contents, GetSuperTrackedQuestID());

	-- clean up
	for i = headerIndex + 1, #QuestMapFrame.QuestsFrame.Contents.Headers do
		QuestMapFrame.QuestsFrame.Contents.Headers[i]:Hide();
	end
	for i = titleIndex + 1, #QuestMapFrame.QuestsFrame.Contents.Titles do
		QuestMapFrame.QuestsFrame.Contents.Titles[i]:Hide();
	end
	for i = objectiveIndex + 1, #OBJECTIVE_FRAMES do
		OBJECTIVE_FRAMES[i]:Hide();
	end
	QuestPOI_HideUnusedButtons(QuestScrollFrame.Contents);
end

function ToggleQuestLog()
	if ( QuestMapFrame:IsShown() and QuestMapFrame:IsVisible() ) then
		HideUIPanel(WorldMapFrame);
	else
		ShowQuestLog();
	end
end

function ShowQuestLog()
	WorldMapFrame.questLogMode = true;
	ShowUIPanel(WorldMapFrame);
	if ( not WorldMapFrame_InWindowedMode() ) then
		WorldMapFrame_ToggleWindowSize();
	end
	QuestMapFrame_Open();
end

function QuestMapLogHeaderButton_OnClick(self, button)
	PlaySound("igMainMenuOptionCheckBoxOn");
	if ( button == "LeftButton" ) then
		-- open to the map for the first quest under the header
		local questLogIndex = self.questLogIndex;
		local numEntries = GetNumQuestLogEntries();
		local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask;
		repeat
			questLogIndex = questLogIndex + 1;
			title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask = GetQuestLogTitle(questLogIndex);
			if ( isOnMap and not isTask ) then
				local mapID, floorNumber = GetQuestWorldMapAreaID(questID);
				if ( mapID ~= 0 ) then
					SetMapByID(mapID);
					return;
				end
			end
		until ( isHeader or questLogIndex >= numEntries )
	else
		WorldMapZoomOutButton_OnClick();
	end
end

function QuestMapLogTitleButton_OnEnter(self)
	-- do block highlight
	local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI = GetQuestLogTitle(self.questLogIndex);
	local _, difficultyHighlightColor = GetQuestDifficultyColor(level);
	if ( isHeader ) then
		_, difficultyHighlightColor = QuestDifficultyColors["header"];
	end
	self.Text:SetTextColor( difficultyHighlightColor.r, difficultyHighlightColor.g, difficultyHighlightColor.b );
	for _, line in pairs(OBJECTIVE_FRAMES) do
		if ( line.questID == self.questID ) then
			line.Text:SetTextColor(1, 1, 1);
		end
	end

	if ( not IsQuestComplete(self.questID) ) then
		WorldMapBlobFrame:DrawBlob(self.questID, true);
	end
	

	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 34, 0);
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:SetText(title);
	local tooltipWidth = 20 + max(231, GameTooltipTextLeft1:GetStringWidth());
	if ( tooltipWidth > UIParent:GetRight() - WorldMapFrame:GetRight() ) then
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0);
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip:SetText(title);
	end
	
	-- quest tag
	local tagID, tagName = GetQuestTagInfo(questID);
	if ( tagName ) then
		local factionGroup = GetQuestFactionGroup(questID);
		-- Faction-specific account quests have additional info in the tooltip
		if ( tagID == QUEST_TAG_ACCOUNT and factionGroup ) then
			local factionString = FACTION_ALLIANCE;
			if ( factionGroup == LE_QUEST_FACTION_HORDE ) then
				factionString = FACTION_HORDE;
			end
			tagName = format("%s (%s)", tagName, factionString);
		end
		GameTooltip:AddLine(tagName, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		if ( QUEST_TAG_TCOORDS[tagID] ) then
			local questTypeIcon;
			if ( tagID == QUEST_TAG_ACCOUNT and factionGroup ) then
				questTypeIcon = QUEST_TAG_TCOORDS["ALLIANCE"];
				if ( factionGroup == LE_QUEST_FACTION_HORDE ) then
					questTypeIcon = QUEST_TAG_TCOORDS["HORDE"];
				end
			else
				questTypeIcon = QUEST_TAG_TCOORDS[tagID];
			end
			GameTooltip:AddTexture("Interface\\QuestFrame\\QuestTypeIcons", unpack(questTypeIcon));
		end
	end
	if ( frequency == LE_QUEST_FREQUENCY_DAILY ) then
		GameTooltip:AddLine(DAILY, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GameTooltip:AddTexture("Interface\\QuestFrame\\QuestTypeIcons", unpack(QUEST_TAG_TCOORDS["DAILY"]));
	elseif ( frequency == LE_QUEST_FREQUENCY_WEEKLY ) then
		GameTooltip:AddLine(WEEKLY, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GameTooltip:AddTexture("Interface\\QuestFrame\\QuestTypeIcons", unpack(QUEST_TAG_TCOORDS["WEEKLY"]));
	end
	if ( isComplete and isComplete < 0 ) then
		GameTooltip:AddLine(FAILED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		GameTooltip:AddTexture("Interface\\QuestFrame\\QuestTypeIcons", unpack(QUEST_TAG_TCOORDS["FAILED"]));	
	end
	GameTooltip:AddLine(" ");

	-- description
	if ( isComplete and isComplete > 0 ) then
		if ( IsBreadcrumbQuest(self.questID) ) then
			GameTooltip:AddLine(GetQuestLogCompletionText(self.questLogIndex), 1, 1, 1, true);
		else
			GameTooltip:AddLine(QUEST_WATCH_QUEST_READY, 1, 1, 1, true);
		end
		GameTooltip:AddLine(" ");
	else
		local needsSeparator = false;
		local _, objectiveText = GetQuestLogQuestText(self.questLogIndex);
		GameTooltip:AddLine(objectiveText, 1, 1, 1, true);
		GameTooltip:AddLine(" ");
		local requiredMoney = GetQuestLogRequiredMoney(self.questLogIndex);
		local numObjectives = GetNumQuestLeaderBoards(self.questLogIndex);
		for i = 1, numObjectives do
			local text, objectiveType, finished = GetQuestLogLeaderBoard(i, self.questLogIndex);
			if ( text ) then
				local color = HIGHLIGHT_FONT_COLOR;
				if ( finished ) then
					color = GRAY_FONT_COLOR;
				end
				GameTooltip:AddLine(QUEST_DASH..text, color.r, color.g, color.b, true);
				needsSeparator = true;
			end
		end
		if ( requiredMoney > 0 ) then
			local playerMoney = GetMoney();
			local color = HIGHLIGHT_FONT_COLOR;
			if ( requiredMoney <= playerMoney ) then
				playerMoney = requiredMoney;
				color = GRAY_FONT_COLOR;
			end
			GameTooltip:AddLine(QUEST_DASH..GetMoneyString(playerMoney).." / "..GetMoneyString(requiredMoney), color.r, color.g, color.b);
			needsSeparator = true;
		end
		
		if ( needsSeparator ) then
			GameTooltip:AddLine(" ");
		end
	end
	
	GameTooltip:AddLine(CLICK_QUEST_DETAILS, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
	
	local partyMembersOnQuest = 0;
	for i=1, GetNumSubgroupMembers() do
		if ( IsUnitOnQuestByQuestID(self.questID, "party"..i) ) then
			--Add the header line if this the first party member found that is on the quest.
			if ( partyMembersOnQuest == 0 ) then
				GameTooltip:AddLine(" ");
				GameTooltip:AddLine("Nearby party members that are on this quest: ");
			end
			partyMembersOnQuest = partyMembersOnQuest + 1;
			GameTooltip:AddLine(LIGHTYELLOW_FONT_COLOR_CODE..GetUnitName("party"..i, true)..FONT_COLOR_CODE_CLOSE);
		end
	end
	
	GameTooltip:Show();
	tooltipButton = self;
end

function QuestMapLogTitleButton_OnLeave(self)
	-- remove block highlight
	local title, level, suggestedGroup, isHeader = GetQuestLogTitle(self.questLogIndex);
	local difficultyColor = GetQuestDifficultyColor(level);
	if ( isHeader ) then
		difficultyColor = QuestDifficultyColors["header"];
	end
	self.Text:SetTextColor( difficultyColor.r, difficultyColor.g, difficultyColor.b );
	for _, line in pairs(OBJECTIVE_FRAMES) do
		if ( line.questID == self.questID ) then
			line.Text:SetTextColor(0.8, 0.8, 0.8);
		end
	end
	
	if ( GetSuperTrackedQuestID() ~= self.questID and not IsQuestComplete(self.questID) ) then
		WorldMapBlobFrame:DrawBlob(self.questID, false);
	end
	GameTooltip:Hide();
	tooltipButton = nil;
end

function QuestMapLogTitleButton_OnClick(self, button)
	PlaySound("igMainMenuOptionCheckBoxOn");
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local questLink = GetQuestLink(GetQuestLogIndexByID(self.questID));
		if ( questLink ) then
			ChatEdit_InsertLink(questLink);
		end
	elseif ( IsShiftKeyDown() ) then
		QuestMapQuestOptions_TrackQuest(self.questID);
	else
		if ( button == "RightButton" ) then
			if ( self.questID ~= QuestMapQuestOptionsDropDown.questID ) then
				CloseDropDownMenus();
			end
			QuestMapQuestOptionsDropDown.questID = self.questID;
			ToggleDropDownMenu(1, nil, QuestMapQuestOptionsDropDown, "cursor", 6, -6);		
		else
			QuestMapFrame_ShowQuestDetails(self.questID);
		end
	end
end

function QuestMapLogTitleButton_OnMouseDown(self)
	local anchor, _, _, x, y = self.Text:GetPoint();
	self.Text:SetPoint(anchor, x + 1, y - 1);
	anchor, _, _, x, y = self.TagTexture:GetPoint(2);
	self.TagTexture:SetPoint(anchor, x + 1, y - 1);
end

function QuestMapLogTitleButton_OnMouseUp(self)
	local anchor, _, _, x, y = self.Text:GetPoint();
	self.Text:SetPoint(anchor, x - 1, y + 1);
	anchor, _, _, x, y = self.TagTexture:GetPoint(2);
	self.TagTexture:SetPoint(anchor, x - 1, y + 1);
end

function QuestMapLog_ShowStoryTooltip(self)
	local tooltip = QuestScrollFrame.StoryTooltip;
	local storyID = GetZoneStoryID();
	local maxWidth = 0;
	local totalHeight = 0;
	
	tooltip.Title:SetText(GetMapNameByID(GetCurrentMapAreaID()));
	totalHeight = totalHeight + tooltip.Title:GetHeight();	
	maxWidth = tooltip.Title:GetWidth();
	
	-- Clear out old quest criteria
	for i = 1, #tooltip.Lines do
		tooltip.Lines[i]:Hide();
	end
	
	local numCriteria = GetAchievementNumCriteria(storyID);
	local completedCriteria = 0;
	for i = 1, numCriteria do
		local title, _, completed = GetAchievementCriteriaInfo(storyID, i);
		if ( completed ) then
			completedCriteria = completedCriteria + 1;
		end
		if ( not tooltip.Lines[i] ) then
			local fontString = tooltip:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			fontString:SetPoint("TOP", tooltip.Lines[i-1], "BOTTOM", 0, -6);
			tooltip.Lines[i] = fontString;
		end
		if ( completed ) then
			tooltip.Lines[i]:SetText(GREEN_FONT_COLOR_CODE..title..FONT_COLOR_CODE_CLOSE);
			tooltip.Lines[i]:SetPoint("LEFT", 30, 0);
			if ( not tooltip.CheckMarks[i] ) then
				local texture = tooltip:CreateTexture(nil, "ARTWORK", "GreenCheckMarkTemplate");
				texture:ClearAllPoints();
				texture:SetPoint("RIGHT", tooltip.Lines[i], "LEFT", -4, -1);
				tooltip.CheckMarks[i] = texture;
			end
			tooltip.CheckMarks[i]:Show();
			maxWidth = max(maxWidth, tooltip.Lines[i]:GetWidth() + 20);		
		else
			tooltip.Lines[i]:SetText(title);
			tooltip.Lines[i]:SetPoint("LEFT", 10, 0);
			if ( tooltip.CheckMarks[i] ) then
				tooltip.CheckMarks[i]:Hide();
			end
			maxWidth = max(maxWidth, tooltip.Lines[i]:GetWidth());			
		end
		tooltip.Lines[i]:Show();
		totalHeight = totalHeight + tooltip.Lines[i]:GetHeight() + 6;
	end
		
	tooltip.ProgressCount:SetFormattedText(STORY_CHAPTERS, completedCriteria, numCriteria);
	maxWidth = max(maxWidth, tooltip.ProgressLabel:GetWidth(), tooltip.ProgressCount:GetWidth());
	totalHeight = totalHeight + tooltip.ProgressLabel:GetHeight() + tooltip.ProgressCount:GetHeight();

	tooltip:ClearAllPoints();
	local tooltipWidth = max(MIN_STORY_TOOLTIP_WIDTH, maxWidth + 20);
	if ( tooltipWidth > UIParent:GetRight() - WorldMapFrame:GetRight() ) then
		tooltip:SetPoint("TOPRIGHT", self:GetParent().StoryHeader, "TOPLEFT", -5, 0);
	else
		tooltip:SetPoint("TOPLEFT", self:GetParent().StoryHeader, "TOPRIGHT", 27, 0);
	end
	tooltip:SetSize(tooltipWidth, totalHeight + 42);
	tooltip:Show();
end

function QuestMapLog_HideStoryTooltip(self)
	QuestScrollFrame.StoryTooltip:Hide();
end

function GetZoneStoryID()
	local areaID = GetCurrentMapAreaID();
	if ( IsMapGarrisonMap(areaID) ) then
		local parentData = GetMapHierarchy();
		if ( parentData ) then
			areaID = parentData[1].id;
		end
	end
	local key = areaID .. "-" .. UnitFactionGroup("player");
	local achievementTable = 
	{
		-- Frostfire Ridge
		["941-Horde"] = {8671, 941},
		-- Tanaan Jungle
		["945-Alliance"] = {8921, 945},
		["945-Horde"] = {8922, 945},
		-- Talador
		["946-Alliance"] = {8920, 946},
		["946-Horde"] = {8919, 946},
		-- Shadowmoon Valley
		["947-Alliance"] = {8845, 947},
		-- Spires of Arak
		["948-Alliance"] = {8925, 948},
		["948-Horde"] = {8926, 948},
		-- Gorgrond
		["949-Alliance"] = {8923, 949},
		["949-Horde"] = {8924, 949},
		-- Nagrand
		["950-Alliance"] = {8927, 950},
		["950-Horde"] = {8928, 950},
		
	};
	if (achievementTable[key] ~= nil) then
		return achievementTable[key][1], achievementTable[key][2];
	end
end

-- *****************************************************************************************************
-- ***** POPUP DETAIL FRAME
-- *****************************************************************************************************

function QuestLogPopupDetailFrame_OnLoad(self)
	self.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", self.ScrollFrame, "TOPRIGHT", 6, -14);
end

function QuestLogPopupDetailFrame_OnHide(self)
	self.questID = nil;
	PlaySound("igQuestLogClose");
end

function QuestLogPopupDetailFrame_Show(questLogIndex)

	local questID = select(8, GetQuestLogTitle(questLogIndex));
	if ( QuestLogPopupDetailFrame.questID == questID and QuestLogPopupDetailFrame:IsShown() ) then
		HideUIPanel(QuestLogPopupDetailFrame);
		return;
	end
	
	QuestLogPopupDetailFrame.questID = questID;

	local questLogIndex = GetQuestLogIndexByID(questID);
	
	SelectQuestLogEntry(questLogIndex);
	StaticPopup_Hide("ABANDON_QUEST");
	StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
	SetAbandonQuest();

	QuestMapFrame_UpdateQuestDetailsButtons();

	QuestLogPopupDetailFrame_Update(true);
	ShowUIPanel(QuestLogPopupDetailFrame);
	PlaySound("igQuestLogOpen");
	
	-- portrait
	local questPortrait, questPortraitText, questPortraitName = GetQuestLogPortraitGiver();
	if (questPortrait and questPortrait ~= 0 and QuestLogShouldShowPortrait()) then
		QuestFrame_ShowQuestPortrait(QuestLogPopupDetailFrame, questPortrait, questPortraitText, questPortraitName, -3, -42);
	else
		QuestFrame_HideQuestPortrait();
	end
end

function QuestLogPopupDetailFrame_Update(resetScrollBar)
	QuestInfo_Display(QUEST_TEMPLATE_LOG, QuestLogPopupDetailFrame.ScrollFrame.ScrollChild)
	if ( resetScrollBar ) then
		QuestLogPopupDetailFrame.ScrollFrame.ScrollBar:SetValue(0);
	end
end