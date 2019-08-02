
QUEST_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable();
QUEST_TRACKER_MODULE.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST;
QUEST_TRACKER_MODULE.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_QUEST + OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED + OBJECTIVE_TRACKER_UPDATE_SUPER_TRACK_CHANGED;
QUEST_TRACKER_MODULE.usedBlocks = { };

QUEST_TRACKER_MODULE.buttonOffsets = {
	groupFinder = { 7, 4 },
	useItem = { 3, 1 },
};

QUEST_TRACKER_MODULE.paddingBetweenButtons = 2;

-- because this header is shared, on finishing its anim it has to update all the modules that use it
QUEST_TRACKER_MODULE:SetHeader(ObjectiveTrackerFrame.BlocksFrame.QuestHeader, TRACKER_HEADER_QUESTS, OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED);

function QUEST_TRACKER_MODULE:OnFreeBlock(block)
	QuestObjectiveReleaseBlockButton_Item(block);
	QuestObjectiveReleaseBlockButton_FindGroup(block);

	block.timerLine	= nil;
	block.questCompleted = nil;
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

local function GetInlineFactionIcon()
	local faction = UnitFactionGroup("player");
	local coords = faction == "Horde" and QUEST_TAG_TCOORDS.HORDE or QUEST_TAG_TCOORDS.ALLIANCE;
	return CreateTextureMarkup(QUEST_ICONS_FILE, QUEST_ICONS_FILE_WIDTH, QUEST_ICONS_FILE_HEIGHT, 16, 16
	, coords[1]
	, coords[2] - 0.02 -- Offset to stop bleeding from next image
	, coords[3]
	, coords[4], 0, 2);
end
function QUEST_TRACKER_MODULE:SetBlockHeader(block, text, questLogIndex, isQuestComplete, questID)
	QuestObjective_SetupHeader(block);

	local hasGroupFinder = QuestObjectiveSetupBlockButton_FindGroup(block, questID);
	local hasItem = QuestObjectiveSetupBlockButton_Item(block, questLogIndex, isQuestComplete);

	-- Special case for previous behavior...if there are no buttons then use default line width from module
	if not (hasItem or hasGroupFinder) then
		block.lineWidth = nil;
	end

	if ( C_CampaignInfo.IsCampaignQuest(questID) ) then
		text = text..GetInlineFactionIcon();
	end
	-- set the text
	block.HeaderText:SetWidth(block.lineWidth or OBJECTIVE_TRACKER_TEXT_WIDTH);
	local height = QUEST_TRACKER_MODULE:SetStringText(block.HeaderText, text, nil, OBJECTIVE_TRACKER_COLOR["Header"]);
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
			local questLogIndex = GetQuestLogIndexByID(block.id);
			if ( IsQuestComplete(block.id) and GetQuestLogIsAutoComplete(questLogIndex) ) then
				AutoQuestPopupTracker_RemovePopUp(block.id);
				ShowQuestComplete(questLogIndex);
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
	end
end

function QUEST_TRACKER_MODULE:OnBlockHeaderLeave(block)
	DEFAULT_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderLeave(block)
	GameTooltip:Hide();
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
	QUEST_TRACKER_MODULE:FreeLine(block, line);
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
	local questLogIndex = GetQuestLogIndexByID(block.id);

	local info = UIDropDownMenu_CreateInfo();
	info.text = GetQuestLogTitle(questLogIndex);
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

	if ( GetQuestLogPushable(questLogIndex) and IsInGroup() ) then
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
	local questLogIndex = GetQuestLogIndexByID(questID);
	QuestLogPopupDetailFrame_Show(questLogIndex);
end

function QuestObjectiveTracker_UntrackQuest(dropDownButton, questID)
	local superTrackedQuestID = GetSuperTrackedQuestID();
	local questLogIndex = GetQuestLogIndexByID(questID);
	RemoveQuestWatch(questLogIndex);
	if ( questID == superTrackedQuestID ) then
		QuestSuperTracking_OnQuestUntracked();
	end
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
end

function QuestObjectiveTracker_OpenQuestMap(dropDownButton, questID)
	QuestMapFrame_OpenToQuestDetails(questID);
end

function QuestObjectiveTracker_ShareQuest(dropDownButton, questID)
	local questLogIndex = GetQuestLogIndexByID(questID);
	QuestLogPushQuest(questLogIndex);
end

-- *****************************************************************************************************
-- ***** UPDATE FUNCTIONS
-- *****************************************************************************************************

local questTrackerOrderingFlags = {
	{ flagIndex = 18 },		--isWarCampaign flag
	{ flagIndex = 19 },		--hasOverrideSort flag
	{ flagIndex = nil },
};

local function AnyFlagsMatched(questWatchInfoTable)
	for i, flagIndexInfo in ipairs(questTrackerOrderingFlags) do
		local flagIndex = flagIndexInfo.flagIndex;
		if flagIndex then
			if questWatchInfoTable[flagIndex] then
				return true;
			end
		end
	end
	return false;
end

local function EnumQuestWatchDataHelper(func, flagIndex, questWatchInfoTable)
	local questID = questWatchInfoTable[1];
	if questID then
		local pushQuest = false;
		if flagIndex then
			if questWatchInfoTable[flagIndex] then
				pushQuest = true;
			end
		else
			if not AnyFlagsMatched(questWatchInfoTable) then
				pushQuest = true;
			end
		end

		if pushQuest then
			local done = func(questWatchInfoTable);
			if done then
				return true;
			end
		end
	end
	return false;
end

local function EnumQuestWatchData(func)
	local questWatchInfoList = {};

	--cache the questWatchInfo
	for i = 1, GetNumQuestWatches() do
		questWatchInfoList[i] = {GetQuestWatchInfo(i)};
	end

	for _, orderingFlag in ipairs(questTrackerOrderingFlags) do
		for i = 1, GetNumQuestWatches() do
			if EnumQuestWatchDataHelper(func, orderingFlag.flagIndex, questWatchInfoList[i]) then
				return;
			end
		end
	end
end

function QuestObjectiveTracker_UpdatePOIs()
	QuestPOI_ResetUsage(ObjectiveTrackerFrame.BlocksFrame);

	local showPOIs = GetCVarBool("questPOI");
	if ( not showPOIs ) then
		QuestPOI_HideUnusedButtons(ObjectiveTrackerFrame.BlocksFrame);
		return;
	end

	local playerMoney = GetMoney();
	local numPOINumeric = 0;

	EnumQuestWatchData(
		function(questWatchInfoTable)
			-- see if we already have a block for this quest
			local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isBounty, isStory, isOnMap, hasLocalPOI, isHidden, isWarCampaign, hasOverrideSort = unpack(questWatchInfoTable);

			local block = QUEST_TRACKER_MODULE:GetExistingBlock(questID);
			if ( block ) then
				local shouldShowWaypoint = (questID == GetSuperTrackedQuestID()) or (questID == QuestMapFrame_GetFocusedQuestID());
				if ( isComplete and isComplete < 0 ) then
					isComplete = false;
				elseif ( numObjectives == 0 and playerMoney >= requiredMoney and not startEvent ) then
					isComplete = true;
				end
				local poiButton;
				if ( hasLocalPOI or (shouldShowWaypoint and C_QuestLog.GetNextWaypoint(questID) ~= nil) ) then
					if ( isComplete ) then
						poiButton = QuestPOI_GetButton(ObjectiveTrackerFrame.BlocksFrame, questID, "normal", nil);
					else
						numPOINumeric = numPOINumeric + 1;
						poiButton = QuestPOI_GetButton(ObjectiveTrackerFrame.BlocksFrame, questID, "numeric", numPOINumeric);
					end
				elseif ( isComplete ) then
					poiButton = QuestPOI_GetButton(ObjectiveTrackerFrame.BlocksFrame, questID, "remote", nil);
				end
				if ( poiButton ) then
					poiButton:SetPoint("TOPRIGHT", block.HeaderText, "TOPLEFT", -6, 2);
				end
			end
			return false;
		end
	);

	QuestPOI_SelectButtonByQuestID(ObjectiveTrackerFrame.BlocksFrame, GetSuperTrackedQuestID());
	QuestPOI_HideUnusedButtons(ObjectiveTrackerFrame.BlocksFrame);
end

function QuestObjectiveTracker_DoQuestObjectives(block, numObjectives, questCompleted, questSequenced, existingBlock)
	local objectiveCompleting = false;
	local questLogIndex = GetQuestLogIndexByID(block.id);
	for objectiveIndex = 1, numObjectives do
		local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questLogIndex);
		if ( text ) then
			local line = block.lines[objectiveIndex];
			if ( questCompleted ) then
				-- only process existing lines
				if ( line ) then
					line = QUEST_TRACKER_MODULE:AddObjective(block, objectiveIndex, text, LINE_TYPE_ANIM, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
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
						line = QUEST_TRACKER_MODULE:AddObjective(block, objectiveIndex, text, LINE_TYPE_ANIM, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
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
							line = QUEST_TRACKER_MODULE:AddObjective(block, objectiveIndex, text, LINE_TYPE_ANIM, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
							line.Check:Show();
							line.state = "COMPLETED";
						end
					end
				else
					if ( not questSequenced or not objectiveCompleting ) then
						-- new objectives need to animate in
						if ( questSequenced and existingBlock and not line ) then
							line = QUEST_TRACKER_MODULE:AddObjective(block, objectiveIndex, text, LINE_TYPE_ANIM);
							line.Sheen.Anim:Play();
							line.Glow.Anim:Play();
							line.state = "ADDING";
							PlaySound(SOUNDKIT.UI_QUEST_ROLLING_FORWARD_01);
							if ( objectiveType == "progressbar" ) then
								QUEST_TRACKER_MODULE:AddProgressBar(block, line, block.id, finished);
							end
						else
							QUEST_TRACKER_MODULE:AddObjective(block, objectiveIndex, text);
							if ( objectiveType == "progressbar" ) then
								QUEST_TRACKER_MODULE:AddProgressBar(block, block.currentLine, block.id, finished);
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

function QUEST_TRACKER_MODULE:Update()

	QUEST_TRACKER_MODULE:BeginLayout();
	QUEST_TRACKER_MODULE.lastBlock = nil;

	local numPOINumeric = 0;
	QuestPOI_ResetUsage(ObjectiveTrackerFrame.BlocksFrame);

	local _, instanceType = IsInInstance();
	if ( instanceType == "arena" ) then
		-- no quests in arena
		QuestPOI_HideUnusedButtons(ObjectiveTrackerFrame.BlocksFrame);
		QUEST_TRACKER_MODULE:EndLayout();
		return;
	end

	local playerMoney = GetMoney();
	local watchMoney = false;
	local showPOIs = GetCVarBool("questPOI");

	EnumQuestWatchData(
		function(questWatchInfoTable)
			local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isBounty, isStory, isOnMap, hasLocalPOI, isHidden, isWarCampaign, hasOverrideSort = unpack(questWatchInfoTable);
			-- check filters
			local showQuest = true;
			if ( isTask or ( isBounty and not IsQuestComplete(questID) ) ) then
				showQuest = false;
			end

			if ( showQuest ) then
				local shouldShowWaypoint = (questID == GetSuperTrackedQuestID()) or (questID == QuestMapFrame_GetFocusedQuestID());
				local isSequenced = IsQuestSequenced(questID);
				local existingBlock = QUEST_TRACKER_MODULE:GetExistingBlock(questID);
				local block = QUEST_TRACKER_MODULE:GetBlock(questID);
				QUEST_TRACKER_MODULE:SetBlockHeader(block, title, questLogIndex, isComplete, questID);

				-- completion state
				local questFailed = false;
				if ( isComplete and isComplete < 0 ) then
					isComplete = false;
					questFailed = true;
				elseif ( numObjectives == 0 and playerMoney >= requiredMoney and not startEvent ) then
					isComplete = true;
				end

				if ( requiredMoney > 0 ) then
					watchMoney = true;
				end

				if ( isComplete ) then
					-- don't display completion state yet if we're animating an objective completing
					local objectiveCompleting = QuestObjectiveTracker_DoQuestObjectives(block, numObjectives, true, isSequenced, existingBlock);
					if ( not objectiveCompleting ) then
						if ( isAutoComplete ) then
							QUEST_TRACKER_MODULE:AddObjective(block, "QuestComplete", QUEST_WATCH_QUEST_COMPLETE);
							QUEST_TRACKER_MODULE:AddObjective(block, "ClickComplete", QUEST_WATCH_CLICK_TO_COMPLETE);
						else
							local completionText = GetQuestLogCompletionText(questLogIndex);
							if ( completionText ) then
								if ( shouldShowWaypoint ) then
									local waypointText = C_QuestLog.GetNextWaypointText(questID);
									if ( waypointText ~= nil ) then
										QUEST_TRACKER_MODULE:AddObjective(block, "Waypoint", WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText));
									end
								end

								QUEST_TRACKER_MODULE:AddObjective(block, "QuestComplete", completionText, nil, OBJECTIVE_DASH_STYLE_HIDE);
							else
								-- If there isn't completion text, always prefer waypoint to "Ready for turn-in".
								local waypointText = C_QuestLog.GetNextWaypointText(questID);
								if ( waypointText ~= nil ) then
									QUEST_TRACKER_MODULE:AddObjective(block, "Waypoint", waypointText);
								else
									QUEST_TRACKER_MODULE:AddObjective(block, "QuestComplete", QUEST_WATCH_QUEST_READY, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
								end
							end
						end
					end
				elseif ( questFailed ) then
					QUEST_TRACKER_MODULE:AddObjective(block, "Failed", FAILED, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Failed"]);
				else
					if ( shouldShowWaypoint ) then
						local waypointText = C_QuestLog.GetNextWaypointText(questID);
						if ( waypointText ~= nil ) then
							QUEST_TRACKER_MODULE:AddObjective(block, "Waypoint", WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText));
						end
					end

					QuestObjectiveTracker_DoQuestObjectives(block, numObjectives, false, isSequenced, existingBlock);
					if ( requiredMoney > playerMoney ) then
						local text = GetMoneyString(playerMoney).." / "..GetMoneyString(requiredMoney);
						QUEST_TRACKER_MODULE:AddObjective(block, "Money", text);
					end

					-- timer bar
					if ( failureTime and block.currentLine ) then
						local currentLine = block.currentLine;
						if ( timeElapsed and timeElapsed <= failureTime ) then
							-- if a timer was attached to another line, release it
							if ( block.timerLine and block.timerLine ~= currentLine ) then
								QUEST_TRACKER_MODULE:FreeTimerBar(block, block.timerLine);
							end
							QUEST_TRACKER_MODULE:AddTimerBar(block, currentLine, failureTime, GetTime() - timeElapsed);
							block.timerLine = currentLine;
						elseif ( block.timerLine ) then
							QUEST_TRACKER_MODULE:FreeTimerBar(block, block.timerLine);
						end
					end
				end
				block:SetHeight(block.height);

				if ( ObjectiveTracker_AddBlock(block) ) then
					if ( existingBlock and isComplete and not block.questCompleted ) then
						QuestSuperTracking_OnQuestCompleted();
					end
					block.questCompleted = isComplete;
					block:Show();
					QUEST_TRACKER_MODULE:FreeUnusedLines(block);
					-- quest POI icon
					if ( showPOIs ) then
						local poiButton;
						if ( hasLocalPOI or (shouldShowWaypoint and C_QuestLog.GetNextWaypoint(questID) ~= nil) ) then
							if ( isComplete ) then
								poiButton = QuestPOI_GetButton(ObjectiveTrackerFrame.BlocksFrame, questID, "normal", nil);
							else
								numPOINumeric = numPOINumeric + 1;
								poiButton = QuestPOI_GetButton(ObjectiveTrackerFrame.BlocksFrame, questID, "numeric", numPOINumeric);
							end
						elseif ( isComplete ) then
							poiButton = QuestPOI_GetButton(ObjectiveTrackerFrame.BlocksFrame, questID, "remote", nil);
						end
						if ( poiButton ) then
							poiButton:SetParent(block);
							poiButton:SetPoint("TOPRIGHT", block.HeaderText, "TOPLEFT", -6, 2);
						end
					end
				else
					block.used = false;
					return true;
				end
			end
			return false;
		end
	);

	ObjectiveTracker_WatchMoney(watchMoney, OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
	QuestSuperTracking_CheckSelection();
	QuestPOI_SelectButtonByQuestID(ObjectiveTrackerFrame.BlocksFrame, GetSuperTrackedQuestID());
	QuestPOI_HideUnusedButtons(ObjectiveTrackerFrame.BlocksFrame);
	QUEST_TRACKER_MODULE:EndLayout();
end
