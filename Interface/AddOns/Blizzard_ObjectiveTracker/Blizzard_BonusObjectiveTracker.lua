BonusObjectiveTrackerModuleMixin = {};

function CreateBonusObjectiveTrackerModule(friendlyName)
	local module = Mixin(ObjectiveTracker_GetModuleInfoTable(friendlyName), BonusObjectiveTrackerModuleMixin);

	module.blockTemplate = "BonusObjectiveTrackerBlockTemplate";
	module.blockType = "ScrollFrame";
	module.freeLines = { };
	module.lineTemplate = "BonusObjectiveTrackerLineTemplate";
	module.usedProgressBars = { };
	module.freeProgressBars = { };
	module.fromHeaderOffsetY = -8;
	module.blockPadding = 3;	-- need some extra room so scrollframe doesn't cut tails off gjpqy

	module:AddPaddingBetweenButtons("BonusObjectiveTrackerBlockTemplate", 2);
	module:AddBlockOffset("BonusObjectiveTrackerBlockTemplate", -20, -6);
	module:AddButtonOffsets("BonusObjectiveTrackerBlockTemplate", {
		groupFinder = { 11, 4 },
		useItem = { 7, 1 },
	});

	return module;
end

local BONUS_OBJECTIVE_LINE_DASH_OFFSET = 20;  -- the X offset of the dash fontstring in the line

local COMPLETED_BONUS_DATA = { };
local COMPLETED_SUPERSEDED_BONUS_OBJECTIVES = { };
-- this is to track which bonus objective is playing in the banner and shouldn't be in the tracker yet
-- if multiple bonus objectives are added at the same time, only one will be in the banner
local BANNER_BONUS_OBJECTIVE_ID;

function BonusObjectiveTrackerModuleMixin:OnFreeBlock(block)
	if ( block.state == "LEAVING" ) then
		block.AnimOut:Stop();
	elseif ( block.state == "ENTERING" ) then
		block.AnimIn:Stop();
	end
	if ( COMPLETED_BONUS_DATA[block.id] ) then
		COMPLETED_BONUS_DATA[block.id] = nil;
		local rewardsFrame = block.module.rewardsFrame;
		if ( rewardsFrame.id == block.id ) then
			rewardsFrame:Hide();
			rewardsFrame.Anim:Stop();
			rewardsFrame.id = nil;
			for i = 1, #rewardsFrame.Rewards do
				rewardsFrame.Rewards[i].Anim:Stop();
			end
		end
	end

	QuestObjectiveReleaseBlockButton_Item(block);
	QuestObjectiveReleaseBlockButton_FindGroup(block);

	if (block.id < 0) then
		local blockKey = -block.id;
		if (BonusObjectiveTracker_GetSupersedingStep(blockKey)) then
			tinsert(COMPLETED_SUPERSEDED_BONUS_OBJECTIVES, blockKey);
		end
	end
	block:SetAlpha(0);
	block.state = nil;
	block.finished = nil;
	block.posIndex = nil;
	block.isThreatQuest = nil;
end

function BonusObjectiveTrackerModuleMixin:OnFreeLine(line)
	if ( line.finished ) then
		line.CheckFlash.Anim:Stop();
		line.CheckFlash:Hide();
		line.finished = nil;
	end
	if line.state == "FADING" then
		line.FadeOutAnim:Stop();
		line.state = nil;
		line.block = nil;
	end
end

-- *****************************************************************************************************
-- ***** FRAME HANDLERS
-- *****************************************************************************************************

function BonusObjectiveTracker_OnHeaderLoad(self)
	local module = CreateBonusObjectiveTrackerModule(self.ModuleName);

	module.rewardsFrame = self.RewardsFrame;
	module.ShowWorldQuests = self.ShowWorldQuests;
	module.DefaultHeaderText = self.DefaultHeaderText;

	if ( module.ShowWorldQuests ) then
		module.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_WORLD_QUEST;
		module.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_QUEST + OBJECTIVE_TRACKER_UPDATE_WORLD_QUEST_ADDED + OBJECTIVE_TRACKER_UPDATE_SUPER_TRACK_CHANGED + OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED;
	else
		module.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_BONUS_OBJECTIVE;
		module.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_QUEST + OBJECTIVE_TRACKER_UPDATE_TASK_ADDED + OBJECTIVE_TRACKER_UPDATE_SCENARIO + OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE + OBJECTIVE_TRACKER_UPDATE_SCENARIO_BONUS_DELAYED;
		module.UpdatePOIs = BonusObjectiveTracker_UpdatePOIs;
	end

	self.module = module;
	_G[self.ModuleName] = module;
	self.RewardsFrame.module = module;


	self.module:SetHeader(self, module.DefaultHeaderText, 0);
	self.height = OBJECTIVE_TRACKER_HEADER_HEIGHT;

	self:RegisterEvent("CRITERIA_COMPLETE");
end

function BonusObjectiveTracker_OnBlockAnimInFinished(self)
	local block = self:GetParent();
	block:SetAlpha(1);
	block.state = "PRESENT";
	-- negative block IDs are for scenario bonus objectives
	if ( block.id > 0 ) then
		local isInArea, isOnMap = GetTaskInfo(block.id);
		if ( not isInArea ) then
			ObjectiveTracker_Update(block.module.updateReasonModule);
			return;
		end
	end
	for _, line in pairs(block.lines) do
		line.Glow.Anim:Play();
	end
end

function BonusObjectiveTracker_OnBlockAnimOutFinished(self)
	local block = self:GetParent();
	block:SetAlpha(0);
	block.used = nil;
	block.module:FreeBlock(block);
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_ALL);
end

function BonusObjectiveTracker_OnBlockEnter(block)
	block.module:OnBlockHeaderEnter(block);
	BonusObjectiveTracker_ShowRewardsTooltip(block);
end

function BonusObjectiveTracker_OnBlockLeave(block)
	block.module:OnBlockHeaderLeave(block);
	GameTooltip:Hide();
	block.module.tooltipBlock = nil;
end

function BonusObjectiveTracker_UpdatePOIs(self, numPOINumeric)
	local usedBlocks = self:GetActiveBlocks();
	for questID, block in pairs(usedBlocks) do
		if block.isThreatQuest then
			local poiButton = ObjectiveTrackerFrame.BlocksFrame:GetButtonForQuest(questID, POIButtonUtil.Style.QuestThreat, nil);
			if poiButton then
				local topLine = block.lines[0] or block.lines[1];
				poiButton:SetPoint("TOPRIGHT", topLine, "TOPLEFT", 18, 0);
				poiButton:SetFrameLevel(block:GetFrameLevel() + 1);
				poiButton.pingWorldMap = true;
			end
		end
	end

	return numPOINumeric;
end

local lastTrackedQuestID = nil;
function BonusObjectiveTracker_TrackWorldQuest(questID, watchType)
	if C_QuestLog.AddWorldQuestWatch(questID, watchType) then
		if lastTrackedQuestID and lastTrackedQuestID ~= questID then
			if C_QuestLog.GetQuestWatchType(lastTrackedQuestID) ~= Enum.QuestWatchType.Manual and watchType == Enum.QuestWatchType.Manual then
				C_QuestLog.AddWorldQuestWatch(lastTrackedQuestID, Enum.QuestWatchType.Manual); -- Promote to manual watch
			end
		end
		lastTrackedQuestID = questID;
	end

	if watchType == Enum.QuestWatchType.Automatic or not C_SuperTrack.GetSuperTrackedQuestID() then
		C_SuperTrack.SetSuperTrackedQuestID(questID);
	end
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_QUEST);
end

function BonusObjectiveTracker_UntrackWorldQuest(questID)
	if C_QuestLog.RemoveWorldQuestWatch(questID) then
		if lastTrackedQuestID == questID then
			lastTrackedQuestID = nil;
		end
		if questID == C_SuperTrack.GetSuperTrackedQuestID() then
			QuestSuperTracking_ChooseClosestQuest();
		end
	end
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_QUEST);
end

function BonusObjectiveTracker_OnBlockClick(self, button)
	local questID = self.TrackedQuest and self.TrackedQuest.questID or self.id;
	local isThreatQuest = C_QuestLog.IsThreatQuest(questID);
	if self.module.ShowWorldQuests or isThreatQuest then
		if button == "LeftButton" then
			if ( not ChatEdit_TryInsertQuestLinkForQuestID(questID) ) then
				if IsShiftKeyDown() then
					if QuestUtils_IsQuestWatched(questID) and not isThreatQuest then
						BonusObjectiveTracker_UntrackWorldQuest(questID);
					end
				else
					local mapID = C_TaskQuest.GetQuestZoneID(questID);
					if mapID then
						OpenQuestLog(mapID);
						WorldMapPing_StartPingQuest(questID);
					end
				end
			end
		elseif button == "RightButton" and not isThreatQuest then
			ObjectiveTracker_ToggleDropDown(self, BonusObjectiveTracker_OnOpenDropDown);
		end
	end
end

function BonusObjectiveTracker_OnOpenDropDown(self)
	local block = self.activeFrame;
	local questID = block.TrackedQuest.questID;
	local addStopTracking = QuestUtils_IsQuestWatched(questID);

	-- Ensure at least one option will appear before showing the dropdown.
	if not addStopTracking then
		return;
	end

	-- Add title
	local info = UIDropDownMenu_CreateInfo();
	info.text = C_TaskQuest.GetQuestInfoByQuestID(questID);
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	-- Add "stop tracking"
	if QuestUtils_IsQuestWatched(questID) then
		info = UIDropDownMenu_CreateInfo();
		info.notCheckable = true;
		info.text = OBJECTIVES_STOP_TRACKING;
		info.func = function()
			BonusObjectiveTracker_UntrackWorldQuest(questID);
		end
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
end

function BonusObjectiveTracker_OnEvent(self, event, ...)
	if ( event == "CRITERIA_COMPLETE" and not ObjectiveTrackerFrame.collapsed ) then
		local tblBonusSteps = C_Scenario.GetBonusSteps();
		for i = 1, #tblBonusSteps do
			local bonusStepIndex = tblBonusSteps[i];
			local _, _, numCriteria = C_Scenario.GetStepInfo(bonusStepIndex);
			local blockKey = -bonusStepIndex;	-- so it won't collide with quest IDs
			local block = self.module:GetBlock(blockKey);
			if( block ) then
				for criteriaIndex = 1, numCriteria do
					local _, _, _, _, _, _, _, _, criteriaID = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex);
					if( id == criteriaID ) then
						local questID = C_Scenario.GetBonusStepRewardQuestID(bonusStepIndex);
						if ( questID ~= 0 ) then
							BonusObjectiveTracker_AddReward(questID, block);
							return;
						end
					end
				end
			end
		end
	end
end

-- *****************************************************************************************************
-- ***** REWARD FUNCTIONS
-- *****************************************************************************************************

function BonusObjectiveTracker_OnTaskCompleted(questID, xp, money)
	-- make sure we're already displaying this
	local block = BONUS_OBJECTIVE_TRACKER_MODULE:GetExistingBlock(questID);
	if ( block ) then
		BonusObjectiveTracker_AddReward(questID, block, xp, money);
	end
end

function BonusObjectiveTracker_AddReward(questID, block, xp, money)
	-- cancel any entering/leaving animations
	BonusObjectiveTracker_SetBlockState(block, "PRESENT", true);

	local data = { };
	-- save data for a quest
	if ( block.id > 0 ) then
		data.posIndex = block.posIndex;
		data.objectives = { };
		local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(questID);
		for objectiveIndex = 1, numObjectives do
			local text, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, true);
			tinsert(data.objectives, text);
			data.objectiveType = objectiveType;
		end
		data.taskName = taskName;
		data.displayAsObjective = displayAsObjective;
	end
	-- save all the rewards
	data.rewards = { };
	-- xp
	if ( not xp ) then
		xp = GetQuestLogRewardXP(questID);
	end
	if ( xp > 0 and not IsPlayerAtEffectiveMaxLevel() ) then
		local t = { };
		t.label = xp;
		t.texture = "Interface\\Icons\\XP_Icon";
		t.count = 0;
		t.font = "NumberFontNormal";
		tinsert(data.rewards, t);
	end

	local artifactXP, artifactCategory = GetQuestLogRewardArtifactXP(questID);
	if ( artifactXP > 0 ) then
		local name, icon = C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory);
		local t = { };
		t.label = artifactXP;
		t.texture = icon or "Interface\\Icons\\INV_Misc_QuestionMark";
		t.overlay = "Interface\\Artifacts\\ArtifactPower-QuestBorder";
		t.count = 0;
		t.font = "NumberFontNormal";
		tinsert(data.rewards, t);
	end
	-- currencies
	local numCurrencies = GetNumQuestLogRewardCurrencies(questID);
	for i = 1, numCurrencies do
		local name, texture, count = GetQuestLogRewardCurrencyInfo(i, questID);
		local t = { };
		t.label = name;
		t.texture = texture;
		t.count = count;
		t.font = "GameFontHighlightSmall";
		tinsert(data.rewards, t);
	end
	-- items
	local numItems = GetNumQuestLogRewards(questID);
	for i = 1, numItems do
		local name, texture, count, quality, isUsable = GetQuestLogRewardInfo(i, questID);
		local t = { };
		t.label = name;
		t.texture = texture;
		t.count = count;
		t.font = "GameFontHighlightSmall";
		tinsert(data.rewards, t);
	end
	-- money
	if ( not money ) then
		money = GetQuestLogRewardMoney(questID);
	end
	if ( money > 0 ) then
		local t = { };
		t.label = GetMoneyString(money);
		t.texture = "Interface\\Icons\\inv_misc_coin_01";
		t.count = 0;
		t.font = "GameFontHighlight";
		tinsert(data.rewards, t);
	end
	COMPLETED_BONUS_DATA[block.id] = data;
	block.module.rewardsFrame:SetRewardData(COMPLETED_BONUS_DATA);
	-- try to play it
	if( #data.rewards > 0 ) then
		block.module.rewardsFrame:AnimateReward(block, data);
	else
		local oldPosIndex = COMPLETED_BONUS_DATA[block.id].posIndex;
		COMPLETED_BONUS_DATA[block.id] = nil;
		block.module.rewardsFrame:SetRewardData(COMPLETED_BONUS_DATA);
		block.module.rewardsFrame:OnAnimateNextReward(block.module, oldPosIndex);
	end
end

function BonusObjectiveTracker_ShowRewardsTooltip(block)
	local questID;
	if ( block.id < 0 ) then
		-- this is a scenario bonus objective
		questID = C_Scenario.GetBonusStepRewardQuestID(-block.id);
		if ( questID == 0 ) then
			-- huh, no reward
			return;
		end
	else
		questID = block.id;
		if ( COMPLETED_BONUS_DATA[questID] ) then
			-- no tooltip for completed objectives
			return;
		end
	end

	if ( HaveQuestRewardData(questID) and GetQuestLogRewardXP(questID) == 0 and GetNumQuestLogRewardCurrencies(questID) == 0
								and GetNumQuestLogRewards(questID) == 0 and GetQuestLogRewardMoney(questID) == 0 and GetQuestLogRewardArtifactXP(questID) == 0 ) then
		GameTooltip:Hide();
		return;
	end

	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPRIGHT", block, "TOPLEFT", 0, 0);
	GameTooltip:SetOwner(block, "ANCHOR_PRESERVE");

	if ( not HaveQuestRewardData(questID) ) then
		GameTooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		GameTooltip_SetTooltipWaitingForData(GameTooltip, true);
	else
		local isWorldQuest = block.module.ShowWorldQuests;
		if ( isWorldQuest ) then
			QuestUtils_AddQuestTypeToTooltip(GameTooltip, questID, NORMAL_FONT_COLOR);
			GameTooltip:AddLine(REWARDS, NORMAL_FONT_COLOR:GetRGB());
		else
			GameTooltip:SetText(REWARDS, NORMAL_FONT_COLOR:GetRGB());
		end
		GameTooltip:AddLine(isWorldQuest and WORLD_QUEST_TOOLTIP_DESCRIPTION or BONUS_OBJECTIVE_TOOLTIP_DESCRIPTION, 1, 1, 1, 1);
		GameTooltip:AddLine(" ");
		GameTooltip_AddQuestRewardsToTooltip(GameTooltip, questID, TOOLTIP_QUEST_REWARDS_STYLE_NONE);
		GameTooltip_SetTooltipWaitingForData(GameTooltip, false);
	end

	GameTooltip:Show();
	block.module.tooltipBlock = block;
end

-- *****************************************************************************************************
-- ***** INTERNAL FUNCTIONS - blending present and past data (future data nyi)
-- *****************************************************************************************************

local function InternalGetTasksTable()
	local tasks = GetTasksTable();
	for i = 1, #tasks do
		if ( tasks[i] == BANNER_BONUS_OBJECTIVE_ID ) then
			tremove(tasks, i);
			break;
		end
	end
	for questID, data in pairs(COMPLETED_BONUS_DATA) do
		if ( questID > 0 ) then
			local found = false;
			for i = 1, #tasks do
				if ( tasks[i] == questID ) then
					found = true;
					break;
				end
			end
			if ( not found ) then
				if ( data.posIndex <= #tasks ) then
					tinsert(tasks, data.posIndex, questID);
				else
					tinsert(tasks, questID);
				end
			end
		end
	end
	return tasks;
end

local function InternalGetTaskInfo(questID)
	if ( COMPLETED_BONUS_DATA[questID] ) then
		return true, true, #COMPLETED_BONUS_DATA[questID].objectives, COMPLETED_BONUS_DATA[questID].taskName, COMPLETED_BONUS_DATA[questID].displayAsObjective;
	else
		return GetTaskInfo(questID);
	end
end

local function InternalGetQuestObjectiveInfo(questID, objectiveIndex)
	if ( COMPLETED_BONUS_DATA[questID] ) then
		return COMPLETED_BONUS_DATA[questID].objectives[objectiveIndex], COMPLETED_BONUS_DATA[questID].objectiveType, true;
	else
		return GetQuestObjectiveInfo(questID, objectiveIndex, false);
	end
end

local function InternalIsQuestComplete(questID)
	if ( COMPLETED_BONUS_DATA[questID] ) then
		return true;
	else
		return C_QuestLog.IsComplete(questID);
	end
end

-- *****************************************************************************************************
-- ***** UPDATE FUNCTIONS
-- *****************************************************************************************************

function BonusObjectiveTracker_GetSupersedingStep(index)
	local supersededObjectives = C_Scenario.GetSupersededObjectives();
	for i = 1, #supersededObjectives do
		local pairs = supersededObjectives[i];
		local k,v = unpack(pairs);

		if (v == index) then
			return k;
		end
	end
end

local function UpdateScenarioBonusObjectives(module)
	if ( C_Scenario.IsInScenario() ) then
		module.Header.animateReason = OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE + OBJECTIVE_TRACKER_UPDATE_SCENARIO_BONUS_DELAYED;
		local tblBonusSteps = C_Scenario.GetBonusSteps();
		-- two steps
		local supersededToRemove = {};
		for i = 1, #tblBonusSteps do
			local bonusStepIndex = tblBonusSteps[i];
			local supersededIndex = BonusObjectiveTracker_GetSupersedingStep(bonusStepIndex);
			if (supersededIndex) then
				local name, description, numCriteria, stepFailed, isBonusStep, isForCurrentStepOnly, shouldShowBonusObjective = C_Scenario.GetStepInfo(bonusStepIndex);
				local completed = true;
				for criteriaIndex = 1, numCriteria do
					local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex);
					if ( criteriaString ) then
						if ( not criteriaCompleted ) then
							completed = false;
							break;
						end
					end
				end
				if (not completed) then
					-- B supercedes A, A is not completed, show A but not B
					tinsert(supersededToRemove, supersededIndex);
				else
					if (tContains(COMPLETED_SUPERSEDED_BONUS_OBJECTIVES, bonusStepIndex)) then
						tinsert(supersededToRemove, bonusStepIndex);
					end
				end
			end
		end
		for i = 1, #supersededToRemove do
			tDeleteItem(tblBonusSteps, supersededToRemove[i]);
		end

		for i = 1, #tblBonusSteps do
			local bonusStepIndex = tblBonusSteps[i];
			local name, description, numCriteria, stepFailed, isBonusStep, isForCurrentStepOnly, shouldShowBonusObjective = C_Scenario.GetStepInfo(bonusStepIndex);
			if shouldShowBonusObjective then
				local blockKey = -bonusStepIndex;	-- so it won't collide with quest IDs
				local existingBlock = module:GetExistingBlock(blockKey);
				local block = module:GetBlock(blockKey);
				local stepFinished = true;
				for criteriaIndex = 1, numCriteria do
					local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed, isWeightedProgress = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex);
					if ( criteriaString ) then
						if (not isWeightedProgress) then
							criteriaString = string.format("%d/%d %s", quantity, totalQuantity, criteriaString);
						end
						if ( criteriaCompleted ) then
							local existingLine = block.lines[criteriaIndex];
							module:AddObjective(block, criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE, OBJECTIVE_TRACKER_COLOR["Complete"]);
							local line = block.currentLine;
							if ( existingLine and not line.finished ) then
								line.Glow.Anim:Play();
								line.Sheen.Anim:Play();
							end
							line.finished = true;
						elseif ( criteriaFailed ) then
							stepFinished = false;
							module:AddObjective(block, criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE, OBJECTIVE_TRACKER_COLOR["Failed"]);
						else
							stepFinished = false;
							module:AddObjective(block, criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE);
						end
						-- timer bar
						if ( duration > 0 and elapsed <= duration and not (criteriaFailed or criteriaCompleted) ) then
							module:AddTimerBar(block, block.currentLine, duration, GetTime() - elapsed);
						elseif ( block.currentLine.TimerBar ) then
							module:FreeTimerBar(block, block.currentLine);
						end
						if ( criteriaIndex > 1 ) then
							local line = block.currentLine;
							line.Icon:Hide();
						end
					end
				end
				-- first line is going to display an icon
				local firstLine = block.lines[1];
				if ( firstLine ) then
					if ( stepFailed ) then
						firstLine.Icon:SetAtlas("Objective-Fail", true);
					elseif ( stepFinished ) then
						firstLine.Icon:SetAtlas("Tracker-Check", true);
						-- play anim if needed
						if ( existingBlock and not block.finished ) then
							firstLine.CheckFlash:Show();
							firstLine.CheckFlash.Anim:Play();
							if (BonusObjectiveTracker_GetSupersedingStep(bonusStepIndex)) then
								BonusObjectiveTracker_SetBlockState(block, "FINISHED");
							end
						end
						block.finished = true;
					else
						firstLine.Icon:SetAtlas("Objective-Nub", true);
					end
					firstLine.Icon:ClearAllPoints();
					firstLine.Icon:SetPoint("CENTER", firstLine.IconAnchor, "CENTER", 0, 0);
					firstLine.Icon:Show();
				end
				block:SetHeight(block.height + module.blockPadding);

				if ( not ObjectiveTracker_AddBlock(block) ) then
					-- there was no room to show the header and the block, bail
					block.used = false;
					break;
				end

				block:Show();
				module:FreeUnusedLines(block);

				if ( block.state ~= "FINISHED" ) then
					if ( not existingBlock and isForCurrentStepOnly ) then
						BonusObjectiveTracker_SetBlockState(block, "ENTERING");
					else
						BonusObjectiveTracker_SetBlockState(block, "PRESENT");
					end
				end
			end
		end
	else
		wipe(COMPLETED_SUPERSEDED_BONUS_OBJECTIVES);
	end
end

local function TryAddingExpirationWarningLine(module, block, questID)
	if ( QuestUtils_ShouldDisplayExpirationWarning(questID) ) then
		local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(questID);
		local text = "";
		if ( timeLeftMinutes and module.tickerSeconds ) then
			if ( timeLeftMinutes > 0 ) then
				if ( timeLeftMinutes < WORLD_QUESTS_TIME_CRITICAL_MINUTES ) then
					local timeString = SecondsToTime(timeLeftMinutes * 60);
					text = BONUS_OBJECTIVE_TIME_LEFT:format(timeString);
					-- want to update the time every 10 seconds
					module.tickerSeconds = 10;
				else
					-- want to update 10 seconds before the difference becomes 0 minutes
					-- once at 0 minutes we want a 10 second update to catch the transition below WORLD_QUESTS_TIME_CRITICAL_MINUTES
					local timeToAlert = min((timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) * 60 - 10, 10);
					if ( module.tickerSeconds == 0 or timeToAlert < module.tickerSeconds ) then
						module.tickerSeconds = timeToAlert;
					end
				end
			end
		end
		module:AddObjective(block, "TimeLeft", text, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["TimeLeft"], true);
		block.currentLine.Icon:Hide();
	end
end

local function AddBonusObjectiveQuest(module, questID, posIndex, isTrackedWorldQuest)
	local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = InternalGetTaskInfo(questID);
	local treatAsInArea = isTrackedWorldQuest or isInArea;
	local isSuperTracked = questID == C_SuperTrack.GetSuperTrackedQuestID();
	local playEnterAnim = treatAsInArea and not isTrackedWorldQuest and questID == OBJECTIVE_TRACKER_UPDATE_ID and not isSuperTracked;
	-- show task if we're in the area or on the same map and we were displaying it before
	local existingTask = module:GetExistingBlock(questID);
	if ( numObjectives and ( treatAsInArea or ( isOnMap and existingTask ) ) ) then
		local block = module:GetBlock(questID);
		-- module header?
		if ( displayAsObjective and not module.ShowWorldQuests ) then
			module.headerText = TRACKER_HEADER_OBJECTIVE;
		end

		local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
		QuestObjective_SetupHeader(block, OBJECTIVE_TRACKER_LINE_WIDTH - OBJECTIVE_TRACKER_DASH_WIDTH - BONUS_OBJECTIVE_LINE_DASH_OFFSET);
		QuestObjectiveSetupBlockButton_FindGroup(block, questID);
		QuestObjectiveSetupBlockButton_Item(block, questLogIndex);

		-- block header? add it as objectiveIndex 0
		if ( taskName ) then
			module:AddObjective(block, 0, taskName, nil, nil, OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE, OBJECTIVE_TRACKER_COLOR["Header"]);
			block.currentLine.Icon:Hide();
		end

		if ( QuestUtils_IsQuestWorldQuest(questID) ) then
			local info = C_QuestLog.GetQuestTagInfo(questID);
			-- Always have the WQ icon show ! instead of ?
			local inProgress = false;
			QuestUtil.SetupWorldQuestButton(block.TrackedQuest, info, inProgress, isSuperTracked, nil, nil, isTrackedWorldQuest);

			if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.QuestSuperTracking) then
				block.TrackedQuest:SetScale(.9);
				block.TrackedQuest:SetPoint("TOPRIGHT", block.currentLine, "TOPLEFT", 18, 0);
				block.TrackedQuest:Show();

				block.TrackedQuest.questID = questID;
			end
		elseif C_QuestLog.IsThreatQuest(questID) then
			block.isThreatQuest = true;
		else
			block.TrackedQuest:Hide();
		end

		local showAsCompleted = block.isThreatQuest and InternalIsQuestComplete(questID);
		local hasAddedTimeLeft = false;
		for objectiveIndex = 1, numObjectives do
			local text, objectiveType, finished = InternalGetQuestObjectiveInfo(questID, objectiveIndex);
			if ( text ) then
				if ( finished ) then
					local existingLine = block.lines[objectiveIndex];
					if not showAsCompleted or existingLine then
						module:AddObjective(block, objectiveIndex, text, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
						local line = block.currentLine;
						line.Icon:SetAtlas("Tracker-Check", true);
						if ( existingLine and not line.finished ) then
							BonusObjectiveTracker_TryPlayLineAnim(block, line.Glow.Anim);
							BonusObjectiveTracker_TryPlayLineAnim(block, line.Sheen.Anim);	
							if ( existingTask ) then
								line.CheckFlash:Show();
								BonusObjectiveTracker_TryPlayLineAnim(block, line.CheckFlash.Anim);	
							end
						end
						line.finished = true;
						line.Icon:ClearAllPoints();
						line.Icon:SetPoint("TOPLEFT", line, "TOPLEFT", 10, 0);
						line.Icon:Show();
					end
				else
					module:AddObjective(block, objectiveIndex, text, nil, nil, OBJECTIVE_DASH_STYLE_SHOW);
					block.currentLine.Icon:Hide();
				end
			end
			if ( objectiveType == "progressbar") then
				if not finished then
					if ( module.ShowWorldQuests and not hasAddedTimeLeft ) then
						-- Add time left (if any) right before the progress bar
						TryAddingExpirationWarningLine(module, block, questID);
						hasAddedTimeLeft = true;
					end

					local progressBar = module:AddProgressBar(block, block.currentLine, questID, finished);
					if ( playEnterAnim and (OBJECTIVE_TRACKER_UPDATE_REASON == OBJECTIVE_TRACKER_UPDATE_TASK_ADDED or OBJECTIVE_TRACKER_UPDATE_REASON == OBJECTIVE_TRACKER_UPDATE_WORLD_QUEST_ADDED) ) then
						BonusObjectiveTracker_TryPlayLineAnim(block, progressBar.Bar.AnimIn);
					elseif not progressBar.Bar.AnimIn:IsPlaying() then
						-- Bug ID: 495448, setToFinal doesn't always work properly with sibling animations, hackily fix up the state here
						progressBar.Bar.BarGlow:SetAlpha(0);
						progressBar.Bar.Starburst:SetAlpha(0);
						progressBar.Bar.BarFrame2:SetAlpha(0);
						progressBar.Bar.BarFrame3:SetAlpha(0);
						progressBar.Bar.Sheen:SetAlpha(0);
					end
				else
					module:FreeProgressBar(block, block.currentLine);
				end
			end
		end
		if showAsCompleted then
			local completionText;
			if block.isThreatQuest then
				local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
				completionText = GetQuestLogCompletionText(questLogIndex);
			end
			module:AddObjective(block, "QuestComplete", completionText or QUEST_WATCH_QUEST_READY, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
		end
		if ( module.ShowWorldQuests and not hasAddedTimeLeft ) then
			-- No progress bar, try adding it at the end
			TryAddingExpirationWarningLine(module, block, questID);
		end
		block:SetHeight(block.height + module.blockPadding);

		if ( not ObjectiveTracker_AddBlock(block) ) then
			-- there was no room to show the header and the block, bail
			block.used = false;
			return false;
		end

		if ( showAsCompleted ) then
			for _, line in pairs(block.lines) do
				if ( line.finished and line.state ~= "FADING" ) then
					if BonusObjectiveTracker_TryPlayLineAnim(block, line.FadeOutAnim) then
						line.state = "FADING";
						line.block = block;
					end
				end
			end
		end

		block.posIndex = posIndex;
		block:Show();
		module:FreeUnusedLines(block);

		if ( treatAsInArea ) then
			if ( playEnterAnim ) then
				BonusObjectiveTracker_SetBlockState(block, "ENTERING");
			else
				BonusObjectiveTracker_SetBlockState(block, "PRESENT");
			end
		elseif ( existingTask ) then
			BonusObjectiveTracker_SetBlockState(block, "LEAVING");
		end
	end
	return true;
end

local function SortWorldQuestsHelper(questID1, questID2)
	local inArea1, onMap1 = GetTaskInfo(questID1);
	local inArea2, onMap2 = GetTaskInfo(questID2);

	if (inArea1 ~= inArea2) then
		return inArea1;
	elseif (onMap1 ~= onMap2) then
		return onMap1;
	else
		return questID1 < questID2;
	end
end

function BonusObjectiveTracker_SortWorldQuests()
	local sortedQuests = {};
	for i = 1, C_QuestLog.GetNumWorldQuestWatches() do
		tinsert(sortedQuests, C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i));
	end

	table.sort(sortedQuests, SortWorldQuestsHelper);

	return sortedQuests;
end

local function UpdateTrackedWorldQuests(module)
	if ( module.ticker ) then
		module.ticker:Cancel();
		module.ticker = nil;
	end
	module.tickerSeconds = 0;

	local sortedQuests = BonusObjectiveTracker_SortWorldQuests();
	for i, questID in ipairs(sortedQuests) do
		if not AddBonusObjectiveQuest(module, questID, i, true) then
			break; -- No more room
		end
	end

	if ( module.tickerSeconds > 0 ) then
		module.ticker = C_Timer.NewTicker(module.tickerSeconds, function()
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_WORLD_QUEST);
		end);
	end
end

local function UpdateQuestBonusObjectives(module)
	module.Header.animateReason = OBJECTIVE_TRACKER_UPDATE_TASK_ADDED;
	local tasksTable = InternalGetTasksTable();
	for i = 1, #tasksTable do
		local questID = tasksTable[i];
		if module.ShowWorldQuests == QuestUtils_IsQuestWorldQuest(questID) and not QuestUtils_IsQuestWatched(questID) then
			if not AddBonusObjectiveQuest(module, questID, i + C_QuestLog.GetNumWorldQuestWatches()) then
				break; -- No more room
			end
		end
	end
	if ( OBJECTIVE_TRACKER_UPDATE_REASON == OBJECTIVE_TRACKER_UPDATE_TASK_ADDED ) then
		PlaySound(SOUNDKIT.UI_SCENARIO_STAGE_END);
	end
end

function BonusObjectiveTrackerModuleMixin:Update()
	-- ugh, cross-module dependance
	if ( SCENARIO_TRACKER_MODULE.BlocksFrame.slidingAction and self.contentsHeight == 0 ) then
		return;
	end

	if ( OBJECTIVE_TRACKER_UPDATE_REASON == OBJECTIVE_TRACKER_UPDATE_TASK_ADDED or OBJECTIVE_TRACKER_UPDATE_REASON == OBJECTIVE_TRACKER_UPDATE_WORLD_QUEST_ADDED ) then
		if ( BANNER_BONUS_OBJECTIVE_ID == OBJECTIVE_TRACKER_UPDATE_ID ) then
			-- we just finished the banner for this, clear the data so the block displays
			BANNER_BONUS_OBJECTIVE_ID = nil;
		elseif( TopBannerManager_IsIdle() ) then
			-- if there's no other banner showing we should show the banner, unless it would show for a WQ that shouldn't be in the tracker
			if not QuestUtils_IsQuestWorldQuest(OBJECTIVE_TRACKER_UPDATE_ID) or GetTaskInfo(OBJECTIVE_TRACKER_UPDATE_ID) ~= nil then
				TopBannerManager_Show(ObjectiveTrackerBonusBannerFrame, OBJECTIVE_TRACKER_UPDATE_ID);
			end
		end
	end

	self:BeginLayout();
	self.headerText = self.DefaultHeaderText;

	if ( not self.ShowWorldQuests ) then
		UpdateScenarioBonusObjectives(self);
	end

	UpdateQuestBonusObjectives(self);

	if ( self.ShowWorldQuests ) then
		UpdateTrackedWorldQuests(self);
	end

	if ( self.tooltipBlock ) then
		BonusObjectiveTracker_ShowRewardsTooltip(self.tooltipBlock);
	end

	if ( self.firstBlock ) then
		-- update module header text (certain bonus objectives can force this to change)
		self.Header.Text:SetText(self.headerText);
		-- shadow anim
		local shadowAnim = self.Header.ShadowAnim;
		if ( self.Header.animating and not shadowAnim:IsPlaying() and C_QuestLog.GetNumWorldQuestWatches() == 0 ) then
			local distance = self.contentsAnimHeight - 8;
			shadowAnim.TransAnim:SetOffset(0, -distance);
			shadowAnim.TransAnim:SetDuration(distance * 0.33 / 50);
			shadowAnim:Play();
		end
	end

	self:EndLayout();
end

function BonusObjectiveTracker_TryPlayLineAnim(block, anim)
	-- When entering or leaving we're animating the whole block, don't allow line anims to play
	if block.state == "ENTERING" or block.state == "LEAVING" then
		return false;
	end
	anim:Play();
	return true;
end

function BonusObjectiveTracker_SetBlockState(block, state, force)
	if ( block.state == state ) then
		return;
	end

	local doAnimOut = false;
	if ( state == "LEAVING" ) then
		-- only apply this state if block is PRESENT - let ENTERING anim finish
		if ( block.state == "PRESENT" ) then
			-- animate out
			doAnimOut = true;
			block.state = "LEAVING";
		end
	elseif ( state == "ENTERING" ) then
		if ( block.state == "LEAVING" ) then
			-- was leaving, just cancel the animation
			block.AnimOut:Stop();
			block:SetAlpha(1);
			block.state = "PRESENT";
		elseif ( not block.state or block.state == "PRESENT" ) then
			-- animate in
			local maxStringWidth = 0;
			for _, line in pairs(block.lines) do
				maxStringWidth = max(maxStringWidth, line.Text:GetStringWidth());
			end
			block:SetAlpha(0);
			local anim = block.AnimIn;
			anim.TransOut:SetOffset((maxStringWidth + 17) * -1, 0);
			anim.TransOut:SetEndDelay((block.module.contentsHeight - OBJECTIVE_TRACKER_HEADER_HEIGHT) * 0.33 / 50);
			anim.TransIn:SetDuration(0.33 * (maxStringWidth + 17)/ 192);
			anim.TransIn:SetOffset((maxStringWidth + 17), 0);
			anim:Play();
			block.state = "ENTERING";
		end
	elseif ( state == "PRESENT" ) then
		-- let ENTERING anim finish
		if ( block.state == "LEAVING" ) then
			-- was leaving, just cancel the animation
			block.AnimOut:Stop();
			block:SetAlpha(1);
			block.state = "PRESENT";
		elseif ( block.state == "ENTERING" and force ) then
			block.AnimIn:Stop();
			block:SetAlpha(1);
			block.state = "PRESENT";
		elseif ( not block.state ) then
			block:SetAlpha(1);
			block.state = "PRESENT";
		end
	elseif ( state == "FINISHED" ) then
		-- only apply this state if block is PRESENT
		if ( block.state == "PRESENT" ) then
			doAnimOut = true;
			block.state = "FINISHED";
		end
	end

	if doAnimOut then
		-- First kill any anims in progress
		-- Can't do it on block release, that doesn't happen until this anim ends
		-- And can't have nested anims playing at the same time, bug WOW9-19015
		for _, line in pairs(block.lines) do
			line.Glow.Anim:Stop();
			line.Sheen.Anim:Stop();
		end
		local progressBars = block.module.usedProgressBars[block];
		if progressBars then
			for line, bar in pairs(progressBars) do
				BonusObjectiveTrackerProgressBar_ResetAnimations(bar);
			end
		end
		block.AnimOut:Play();
	end
end

function BonusObjectiveTracker_FinishFadeOutAnim(line)
	local block = line.block;
	BONUS_OBJECTIVE_TRACKER_MODULE:FreeLine(block, line);
	for _, otherLine in pairs(block.lines) do
		if ( otherLine.state == "FADING" ) then
			-- some other line is still fading
			return;
		end
	end
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_BONUS_OBJECTIVE);
end

-- *****************************************************************************************************
-- ***** PROGRESS BAR
-- *****************************************************************************************************
function BonusObjectiveTrackerModuleMixin:AddProgressBar(block, line, questID, finished)
	local progressBar = self.usedProgressBars[block] and self.usedProgressBars[block][line];
	if ( not progressBar ) then
		local numFreeProgressBars = #self.freeProgressBars;
		local parent = block.ScrollContents or block;
		if ( numFreeProgressBars > 0 ) then
			progressBar = self.freeProgressBars[numFreeProgressBars];
			tremove(self.freeProgressBars, numFreeProgressBars);
			progressBar:SetParent(parent);
			progressBar:Show();
		else
			progressBar = CreateFrame("Frame", nil, parent, "BonusTrackerProgressBarTemplate");
			progressBar.height = progressBar:GetHeight();
		end
		if ( not self.usedProgressBars[block] ) then
			self.usedProgressBars[block] = { };
		end
		self.usedProgressBars[block][line] = progressBar;
		progressBar:RegisterEvent("QUEST_LOG_UPDATE");
		progressBar:Show();
		-- initialize to the right values
		progressBar.questID = questID;
		if( not finished ) then
			BonusObjectiveTrackerProgressBar_SetValue( progressBar, GetQuestProgressBarPercent(questID) );
		end
		BonusObjectiveTrackerProgressBar_UpdateReward(progressBar);
	end
	-- anchor the status bar
	local anchor = block.currentLine or block.HeaderText;
	if ( anchor ) then
		progressBar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -block.module.lineSpacing);
	else
		progressBar:SetPoint("TOPLEFT", 0, -block.module.lineSpacing);
	end

	if( finished ) then
		progressBar.finished = true;
		BonusObjectiveTrackerProgressBar_SetValue( progressBar, 100 );
	end

	progressBar.block = block;
	progressBar.questID = questID;

	line.ProgressBar = progressBar;
	block.height = block.height + progressBar.height + block.module.lineSpacing;
	block.currentLine = progressBar;
	return progressBar;
end

function BonusObjectiveTrackerModuleMixin:FreeProgressBar(block, line)
	local progressBar = line.ProgressBar;
	if ( progressBar ) then
		self.usedProgressBars[block][line] = nil;
		tinsert(self.freeProgressBars, progressBar);
		progressBar:Hide();
		line.ProgressBar = nil;
		progressBar.finished = nil;
		progressBar.AnimValue = nil;
		progressBar:UnregisterEvent("QUEST_LOG_UPDATE");
		progressBar.Bar.AnimIn:Stop();
	end
end

function BonusObjectiveTrackerProgressBar_SetValue(self, percent)
	self.Bar:SetValue(percent);
	self.Bar.Label:SetFormattedText(PERCENTAGE_STRING, percent);
	self.AnimValue = percent;
end

function BonusObjectiveTrackerProgressBar_OnEvent(self)
	BonusObjectiveTrackerProgressBar_PlayAnimation(self);
	if ( self.needsReward ) then
		BonusObjectiveTrackerProgressBar_UpdateReward(self);
	end
end

function BonusObjectiveTrackerProgressBar_UpdateReward(progressBar)
	local _, texture;
	if ( HaveQuestRewardData(progressBar.questID) ) then
		-- reward icon; try the first item
		_, texture = GetQuestLogRewardInfo(1, progressBar.questID);
		-- artifact xp
		local artifactXP, artifactCategory = GetQuestLogRewardArtifactXP(progressBar.questID);
		if ( not texture and artifactXP > 0 ) then
			local name, icon = C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory);
			texture = icon or "Interface\\Icons\\INV_Misc_QuestionMark";
		end
		-- currency
		if ( not texture and GetNumQuestLogRewardCurrencies(progressBar.questID) > 0 ) then
			_, texture = GetQuestLogRewardCurrencyInfo(1, progressBar.questID);
		end
		-- money?
		if ( not texture and GetQuestLogRewardMoney(progressBar.questID) > 0 ) then
			texture = "Interface\\Icons\\inv_misc_coin_02";
		end
		-- xp
		if ( not texture and GetQuestLogRewardXP(progressBar.questID) > 0 and not IsPlayerAtEffectiveMaxLevel() ) then
			texture = "Interface\\Icons\\xp_icon";
		end
		progressBar.needsReward = nil;
	else
		progressBar.needsReward = true;
	end
	if ( not texture ) then
		progressBar.Bar.Icon:Hide();
		progressBar.Bar.IconBG:Hide();
		progressBar.Bar.BarGlow:SetAtlas("bonusobjectives-bar-glow", true);
	else
		progressBar.Bar.Icon:SetTexture(texture);
		progressBar.Bar.Icon:Show();
		progressBar.Bar.IconBG:Show();
		progressBar.Bar.BarGlow:SetAtlas("bonusobjectives-bar-glow-ring", true);
	end
end

function BonusObjectiveTrackerProgressBar_ResetAnimations(self)
	for i, frame in ipairs(self.AnimatableFrames) do
		-- a progressbar animatable frame will have one of these two parentkey anims
		local anim = frame.AnimIn or frame.FlareAnim;
		anim:Stop();
		for i, texture in ipairs(frame.AlphaTextures) do
			texture:SetAlpha(0);
		end
	end
end

function BonusObjectiveTrackerProgressBar_PlayAnimation(self, overridePercent, overrideDelta)
	local percent = overridePercent or self.finished and 100 or GetQuestProgressBarPercent(self.questID);
	local delta = overrideDelta or percent - self.AnimValue;
	BonusObjectiveTrackerProgressBar_PlayFlareAnim(self, delta);
	BonusObjectiveTrackerProgressBar_SetValue(self, percent);
end

function BonusObjectiveTrackerProgressBar_PlayFlareAnim(progressBar, delta)
	if( progressBar.AnimValue >= 100 or delta == 0 ) then
		return;
	end

	animOffset = animOffset or 12;
	local offset = progressBar.Bar:GetWidth() * (progressBar.AnimValue / 100) - animOffset;

	local prefix = "";
	if delta < 10 then
		prefix = "Small";
	end

	local flare = progressBar[prefix.."Flare1"];
	if( flare.FlareAnim:IsPlaying() ) then
		flare = progressBar[prefix.."Flare2"];
		if( flare.FlareAnim:IsPlaying() ) then
			flare = nil;
		end
	end

	if ( flare ) then
		flare:SetPoint("LEFT", progressBar.Bar, "LEFT", offset, 0);
		BonusObjectiveTracker_TryPlayLineAnim(progressBar.block, flare.FlareAnim);
	end

	local barFlare = progressBar["FullBarFlare1"];
	if( barFlare.FlareAnim:IsPlaying() ) then
		barFlare = progressBar["FullBarFlare2"];
		if( barFlare.FlareAnim:IsPlaying() ) then
			barFlare = nil;
		end
	end

	if ( barFlare ) then
		BonusObjectiveTracker_TryPlayLineAnim(progressBar.block, barFlare.FlareAnim);
	end
end

-- *****************************************************************************************************
-- ***** BONUS OBJECTIVE BANNER
-- *****************************************************************************************************

function ObjectiveTrackerBonusBannerFrame_OnLoad(self)
	self.PlayBanner = ObjectiveTrackerBonusBannerFrame_PlayBanner;
	self.StopBanner = ObjectiveTrackerBonusBannerFrame_StopBanner;
end

function ObjectiveTrackerBonusBannerFrame_PlayBanner(self, questID)
	-- quest title
	local questTitle = C_QuestLog.GetTitleForQuestID(questID);
	if ( not questTitle ) then
		return;
	end
	self.Title:SetText(questTitle);
	self.TitleFlash:SetText(questTitle);
	local isWorldQuest = QuestUtils_IsQuestWorldQuest(questID);
	self.BonusLabel:SetText(isWorldQuest and WORLD_QUEST_BANNER or BONUS_OBJECTIVE_BANNER);
	if isWorldQuest then
		PlaySound(SOUNDKIT.UI_WORLDQUEST_START);
	end
	-- offsets for anims
	local trackerFrame = ObjectiveTrackerFrame;
	local xOffset = trackerFrame:GetLeft() - self:GetRight();
	local height = 0;
	for i = 1, #trackerFrame.MODULES_UI_ORDER do
		if ( trackerFrame.MODULES_UI_ORDER[i] == BONUS_OBJECTIVE_TRACKER_MODULE ) then
			break;
		end
		height = height + (trackerFrame.MODULES_UI_ORDER[i].oldContentsHeight or trackerFrame.MODULES_UI_ORDER[i].contentsHeight or 0);
	end
	local yOffset = trackerFrame:GetTop() - height - self:GetTop() + 64;
	self.Anim.BG1Translation:SetOffset(xOffset, yOffset);
	self.Anim.TitleTranslation:SetOffset(xOffset, yOffset);
	self.Anim.BonusLabelTranslation:SetOffset(xOffset, yOffset);
	self.Anim.IconTranslation:SetOffset(xOffset, yOffset);
	-- hide zone text as it's very likely to be up
	ZoneText_Clear();
	-- show and play
	self:Show();
	self.Anim:Stop();
	self.Anim:Play();
	BANNER_BONUS_OBJECTIVE_ID = questID;
	-- timer to put the bonus objective in the tracker
	C_Timer.After(2.66, function() if BANNER_BONUS_OBJECTIVE_ID == questID then ObjectiveTracker_Update(isWorldQuest and OBJECTIVE_TRACKER_UPDATE_WORLD_QUEST_ADDED or OBJECTIVE_TRACKER_UPDATE_TASK_ADDED, BANNER_BONUS_OBJECTIVE_ID); end end);
end

function ObjectiveTrackerBonusBannerFrame_StopBanner(self)
	self.Anim:Stop();
	self:Hide();
end

function ObjectiveTrackerBonusBannerFrame_OnAnimFinished()
	TopBannerManager_BannerFinished();
end
