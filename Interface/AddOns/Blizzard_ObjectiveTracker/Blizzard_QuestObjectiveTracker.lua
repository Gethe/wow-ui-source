QUEST_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable("QUEST_TRACKER_MODULE");
QUEST_TRACKER_MODULE.updateReasonModule = 	OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST +
											OBJECTIVE_TRACKER_UPDATE_MODULE_AUTO_QUEST_POPUP;

QUEST_TRACKER_MODULE.updateReasonEvents = 	OBJECTIVE_TRACKER_UPDATE_QUEST +
											OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED +
											OBJECTIVE_TRACKER_UPDATE_SUPER_TRACK_CHANGED;

local QUEST_TRACKER_MODULE_BLOCK_TEMPLATE = "ObjectiveTrackerBlockTemplate";

QUEST_TRACKER_MODULE:AddButtonOffsets(QUEST_TRACKER_MODULE_BLOCK_TEMPLATE, {
	groupFinder = { 7, 4 },
	useItem = { 3, 1 },
});

QUEST_TRACKER_MODULE:AddPaddingBetweenButtons(QUEST_TRACKER_MODULE_BLOCK_TEMPLATE, 2);

-- because this header is shared, on finishing its anim it has to update all the modules that use it
QUEST_TRACKER_MODULE:SetHeader(ObjectiveTrackerFrame.BlocksFrame.QuestHeader, TRACKER_HEADER_QUESTS, OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED);

function QUEST_TRACKER_MODULE:OnFreeBlock(block)
	if block.blockTemplate == QUEST_TRACKER_MODULE_BLOCK_TEMPLATE then
		QuestObjectiveReleaseBlockButton_Item(block);
		QuestObjectiveReleaseBlockButton_FindGroup(block);

		block.timerLine	= nil;
	else
		AutoQuestPopupTracker_OnFreeBlock(block);
	end
end

function QUEST_TRACKER_MODULE:OnFreeTypedLine(line)
	line.block = nil;
	if ( line.state ) then
		line.Check:Hide();
		line.state = nil;
		line.Glow.Anim:Stop();
		line.Glow:SetAlpha(0);
		line.Sheen.Anim:Stop();
		line.Sheen:SetAlpha(0);
		line.CheckFlash.Anim:Stop();
		line.CheckFlash:SetAlpha(0);
		line.FadeOutAnim:Stop();
	end
end

function QUEST_TRACKER_MODULE:SetBlockHeader(block, text, questLogIndex, isQuestComplete, questID)
	QuestObjective_SetupHeader(block);

	local hasGroupFinder = QuestObjectiveSetupBlockButton_FindGroup(block, questID);
	local hasItem = QuestObjectiveSetupBlockButton_Item(block, questLogIndex, isQuestComplete);

	-- Special case for previous behavior...if there are no buttons then use default line width from module
	if not (hasItem or hasGroupFinder) then
		block.lineWidth = nil;
	end

	-- set the text
	block.HeaderText:SetWidth(block.lineWidth or OBJECTIVE_TRACKER_TEXT_WIDTH);
	local height = self:SetStringText(block.HeaderText, text, nil, OBJECTIVE_TRACKER_COLOR["Header"]);
	block.height = height;
end

function QUEST_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
	if ( ChatEdit_TryInsertQuestLinkForQuestID(block.id) ) then
		return;
	end

	if ( mouseButton ~= "RightButton" ) then
		CloseDropDownMenus();
		if ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
			QuestObjectiveTracker_UntrackQuest(nil, block.id);
		else
			local quest = QuestCache:Get(block.id);
			if quest.isAutoComplete and quest:IsComplete() then
				AutoQuestPopupTracker_RemovePopUp(block.id);
				ShowQuestComplete(block.id);
			else
				QuestMapFrame_OpenToQuestDetails(block.id);
			end
		end
		return;
	else
		ObjectiveTracker_ToggleDropDown(block, QuestObjectiveTracker_OnOpenDropDown);
	end
end

function QUEST_TRACKER_MODULE:OnBlockHeaderEnter(block)
	DEFAULT_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderEnter(block)

	if IsInGroup() then
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("TOPRIGHT", block, "TOPLEFT", 0, 0);
		GameTooltip:SetOwner(block, "ANCHOR_PRESERVE");
		GameTooltip:SetQuestPartyProgress(block.id);
        EventRegistry:TriggerEvent("OnQuestBlockHeader.OnEnter", block, block.id, true);
    else
        EventRegistry:TriggerEvent("OnQuestBlockHeader.OnEnter", block, block.id, false);
	end
end

function QUEST_TRACKER_MODULE:OnBlockHeaderLeave(block)
	DEFAULT_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderLeave(block)
	GameTooltip:Hide();
end

function QUEST_TRACKER_MODULE:GetDebugReportInfo(block)
	return { debugType = "TrackedQuest", questID = block.id, };
end

local LINE_TYPE_ANIM = { template = "QuestObjectiveAnimLineTemplate", freeLines = { } };

-- *****************************************************************************************************
-- ***** ANIMATIONS
-- *****************************************************************************************************

function QuestObjectiveTracker_FinishGlowAnim(line)
	if ( line.state == "ADDING" ) then
		line.state = "PRESENT";
	else
		local questID = line.block.id;
		if ( IsQuestSequenced(questID) ) then
			line.FadeOutAnim:Play();
			line.state = "FADING";
		else
			line.state = "COMPLETED";
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
		end
	end
end

function QuestObjectiveTracker_FinishFadeOutAnim(line)
	local block = line.block;
	block.module:FreeLine(block, line);
	for _, otherLine in pairs(block.lines) do
		if ( otherLine.state == "FADING" ) then
			-- some other line is still fading
			return;
		end
	end
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
end

-- *****************************************************************************************************
-- ***** BLOCK DROPDOWN FUNCTIONS
-- *****************************************************************************************************

function QuestObjectiveTracker_OnOpenDropDown(self)
	local block = self.activeFrame;

	local info = UIDropDownMenu_CreateInfo();
	info.text = C_QuestLog.GetTitleForQuestID(block.id);
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;

	info.text = OBJECTIVES_VIEW_IN_QUESTLOG;
	info.func = QuestObjectiveTracker_OpenQuestDetails;
	info.arg1 = block.id;
	info.noClickSound = 1;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info.text = OBJECTIVES_STOP_TRACKING;
	info.func = QuestObjectiveTracker_UntrackQuest;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	if ( C_QuestLog.IsPushableQuest(block.id) and IsInGroup() ) then
		info.text = SHARE_QUEST;
		info.func = QuestObjectiveTracker_ShareQuest;
		info.arg1 = block.id;
		info.checked = false;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end

	info.text = OBJECTIVES_SHOW_QUEST_MAP;
	info.func = QuestObjectiveTracker_OpenQuestMap;
	info.arg1 = block.id;
	info.checked = false;
	info.noClickSound = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
end

function QuestObjectiveTracker_OpenQuestDetails(dropDownButton, questID)
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
	QuestLogPopupDetailFrame_Show(questLogIndex);
end

function QuestObjectiveTracker_UntrackQuest(dropDownButton, questID)
	local superTrackedQuestID = C_SuperTrack.GetSuperTrackedQuestID();
	C_QuestLog.RemoveQuestWatch(questID);
	if questID == superTrackedQuestID then
		QuestSuperTracking_OnQuestUntracked();
	end
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
end

function QuestObjectiveTracker_OpenQuestMap(dropDownButton, questID)
	QuestMapFrame_OpenToQuestDetails(questID);
end

function QuestObjectiveTracker_ShareQuest(dropDownButton, questID)
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
	QuestLogPushQuest(questLogIndex);
end

-- *****************************************************************************************************
-- ***** UPDATE FUNCTIONS
-- *****************************************************************************************************

local function CompareQuestWatchInfos(info1, info2)
	local quest1, quest2 = info1.quest, info2.quest;

	if quest1:IsCalling() ~= quest2:IsCalling() then
		return quest1:IsCalling();
	end

	if quest1.overridesSortOrder ~= quest2.overridesSortOrder then
		return quest1.overridesSortOrder;
	end

	return info1.index < info2.index;
end

function QUEST_TRACKER_MODULE:BuildQuestWatchInfos()
	local infos = {};

	for i = 1, C_QuestLog.GetNumQuestWatches() do
		local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i);
		if questID then
			local quest = QuestCache:Get(questID);
			if self:ShouldDisplayQuest(quest) then
				table.insert(infos, { quest = quest, index = i });
			end
		end
	end

	table.sort(infos, CompareQuestWatchInfos);
	return infos;
end

function QUEST_TRACKER_MODULE:EnumQuestWatchData(func)
	local infos = self:BuildQuestWatchInfos();
	for index, questWatchInfo in ipairs(infos) do
		if func(self, questWatchInfo.quest) then
			return;
		end
	end
end

function QUEST_TRACKER_MODULE:UpdatePOISingle(quest)
	local questID = quest:GetID();
	local isComplete = quest:IsComplete();
	local isOnMap, hasLocalPOI = quest:IsOnMap();

	local block = self:GetExistingBlock(questID);
	if block then
		local shouldShowWaypoint = (questID == C_SuperTrack.GetSuperTrackedQuestID()) or (questID == QuestMapFrame_GetFocusedQuestID());
		local poiButton;

		if isComplete then
			poiButton = ObjectiveTrackerFrame.BlocksFrame:GetButtonForQuest(questID, POIButtonUtil.Style.QuestComplete, nil);
		elseif  hasLocalPOI or (shouldShowWaypoint and C_QuestLog.GetNextWaypoint(questID) ~= nil) then
			self.numPOINumeric = self.numPOINumeric + 1;
			poiButton = ObjectiveTrackerFrame.BlocksFrame:GetButtonForQuest(questID, POIButtonUtil.Style.Numeric, self.numPOINumeric);
		end

		if poiButton then
			poiButton:SetPoint("TOPRIGHT", block.HeaderText, "TOPLEFT", -6, 2);
		end
	end
end

function QUEST_TRACKER_MODULE:UpdatePOIs(numPOINumeric)
	self.numPOINumeric = numPOINumeric;
	self:EnumQuestWatchData(self.UpdatePOISingle);
	return self.numPOINumeric;
end

function QuestObjectiveTracker_DoQuestObjectives(self, block, questCompleted, questSequenced, existingBlock, useFullHeight)
	local objectiveCompleting = false;
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(block.id);
	local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
	local suppressProgressPercentageInObjectiveText = true;
	for objectiveIndex = 1, numObjectives do

		local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questLogIndex, suppressProgressPercentageInObjectiveText);
		if ( text ) then
			local line = block.lines[objectiveIndex];
			if ( questCompleted ) then
				-- only process existing lines
				if ( line ) then
					line = self:AddObjective(block, objectiveIndex, text, LINE_TYPE_ANIM, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
					-- don't do anything else if a line is either COMPLETING or FADING, the anims' OnFinished will continue the process
					if ( not line.state or line.state == "PRESENT" ) then
						-- this objective wasn't marked finished
						line.block = block;
						line.Check:Show();
						line.Sheen.Anim:Play();
						line.Glow.Anim:Play();
						line.CheckFlash.Anim:Play();
						line.state = "COMPLETING";
					end
				end
			else
				if ( finished ) then
					if ( line ) then
						line = self:AddObjective(block, objectiveIndex, text, LINE_TYPE_ANIM, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
						if ( not line.state or line.state == "PRESENT" ) then
							-- complete this
							line.block = block;
							line.Check:Show();
							line.Sheen.Anim:Play();
							line.Glow.Anim:Play();
							line.CheckFlash.Anim:Play();
							line.state = "COMPLETING";
						end
					else
						-- didn't have a line, just show completed if not sequenced
						if ( not questSequenced ) then
							line = self:AddObjective(block, objectiveIndex, text, LINE_TYPE_ANIM, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
							line.Check:Show();
							line.state = "COMPLETED";
						end
					end
				else
					if ( not questSequenced or not objectiveCompleting ) then
						-- new objectives need to animate in
						if ( questSequenced and existingBlock and not line ) then
							line = self:AddObjective(block, objectiveIndex, text, LINE_TYPE_ANIM, useFullHeight);
							line.Sheen.Anim:Play();
							line.Glow.Anim:Play();
							line.state = "ADDING";
							PlaySound(SOUNDKIT.UI_QUEST_ROLLING_FORWARD_01);
							if ( objectiveType == "progressbar" ) then
								self:AddProgressBar(block, line, block.id, finished);
							end
						else
							self:AddObjective(block, objectiveIndex, text, nil, useFullHeight);
							if ( objectiveType == "progressbar" ) then
								self:AddProgressBar(block, block.currentLine, block.id, finished);
							end
						end
					end
				end
			end
			if ( line ) then
				line.block = block;
				if ( line.state == "COMPLETING" ) then
					objectiveCompleting = true;
				end
			end

		end
	end
	if ( questCompleted and not objectiveCompleting ) then
		for _, line in pairs(block.lines) do
			if ( line.state == "COMPLETED" ) then
				line.FadeOutAnim:Play();
				line.state = "FADING";
			end
		end
	end
	return objectiveCompleting;
end

function QUEST_TRACKER_MODULE:UpdateSingle(quest)
	local questID = quest:GetID();
	local isComplete = quest:IsComplete();
	local isSuperTracked = (questID == C_SuperTrack.GetSuperTrackedQuestID());
	local useFullHeight = true; -- Always use full height of the block for the quest tracker.
	local shouldShowWaypoint = isSuperTracked or (questID == QuestMapFrame_GetFocusedQuestID());
	local isSequenced = IsQuestSequenced(questID);
	local existingBlock = self:GetExistingBlock(questID);
	local block = self:GetBlock(questID);
	self:SetBlockHeader(block, quest.title, quest:GetQuestLogIndex(), isComplete, questID);

	-- completion state
	local questFailed = C_QuestLog.IsFailed(questID);

	if quest.requiredMoney > 0 then
		self.watchMoney = true;
	end

	if ( isComplete ) then
		-- don't display completion state yet if we're animating an objective completing
		local objectiveCompleting = QuestObjectiveTracker_DoQuestObjectives(self, block, isComplete, isSequenced, existingBlock, useFullHeight);
		if ( not objectiveCompleting ) then
			if ( quest.isAutoComplete ) then
				self:AddObjective(block, "QuestComplete", QUEST_WATCH_QUEST_COMPLETE);
				self:AddObjective(block, "ClickComplete", QUEST_WATCH_CLICK_TO_COMPLETE);
			else
				local completionText = GetQuestLogCompletionText(quest:GetQuestLogIndex());
				if ( completionText ) then
					if ( shouldShowWaypoint ) then
						local waypointText = C_QuestLog.GetNextWaypointText(questID);
						if ( waypointText ~= nil ) then
							self:AddObjective(block, "Waypoint", WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText), nil, useFullHeight);
						end
					end

					local forceCompletedToUseFullHeight = true;
					self:AddObjective(block, "QuestComplete", completionText, nil, forceCompletedToUseFullHeight, OBJECTIVE_DASH_STYLE_HIDE);
				else
					-- If there isn't completion text, always prefer waypoint to "Ready for turn-in".
					local waypointText = C_QuestLog.GetNextWaypointText(questID);
					if ( waypointText ~= nil ) then
						self:AddObjective(block, "Waypoint", waypointText, nil, useFullHeight);
					else
						self:AddObjective(block, "QuestComplete", QUEST_WATCH_QUEST_READY, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
					end
				end
			end
		end
	elseif ( questFailed ) then
		self:AddObjective(block, "Failed", FAILED, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Failed"]);
	else
		if ( shouldShowWaypoint ) then
			local waypointText = C_QuestLog.GetNextWaypointText(questID);
			if ( waypointText ~= nil ) then
				self:AddObjective(block, "Waypoint", WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText), nil, useFullHeight);
			end
		end

		QuestObjectiveTracker_DoQuestObjectives(self, block, isComplete, isSequenced, existingBlock, useFullHeight);
		if ( quest.requiredMoney > self.playerMoney ) then
			local text = GetMoneyString(self.playerMoney).." / "..GetMoneyString(quest.requiredMoney);
			self:AddObjective(block, "Money", text, nil, useFullHeight);
		end

		-- timer bar
		local timeTotal, timeElapsed = C_QuestLog.GetTimeAllowed(questID);
		if timeTotal and block.currentLine then
			local currentLine = block.currentLine;
			if timeElapsed and timeElapsed <= timeTotal then
				-- if a timer was attached to another line, release it
				if block.timerLine and block.timerLine ~= currentLine then
					self:FreeTimerBar(block, block.timerLine);
				end
				self:AddTimerBar(block, currentLine, timeTotal, GetTime() - timeElapsed);
				block.timerLine = currentLine;
			elseif block.timerLine then
				self:FreeTimerBar(block, block.timerLine);
			end
		end
	end
	block:SetHeight(block.height);

	if ObjectiveTracker_AddBlock(block) then
		block:Show();
		self:FreeUnusedLines(block);
	else
		block.used = false;
		return true; -- Can't add the block, we're done enumerating quests
	end
end

function QUEST_TRACKER_MODULE:Update()
	self:BeginLayout();

	AutoQuestPopupTracker_Update(self);

	local _, instanceType = IsInInstance();
	if ( instanceType == "arena" ) then
		-- no quests in arena
		self:EndLayout();
		return;
	end

	self.playerMoney = GetMoney();
	self.watchMoney = false;

	self:EnumQuestWatchData(self.UpdateSingle);

	ObjectiveTracker_WatchMoney(self.watchMoney, OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
	QuestSuperTracking_CheckSelection();
	self:EndLayout();
end

function QUEST_TRACKER_MODULE:ShouldDisplayQuest(quest)
	if quest.isTask or (quest.isBounty and not isComplete) or quest:IsDisabledForSession() then
		return false;
	end

	return quest:GetSortType() ~= QuestSortType.Campaign;
end
