local settings = {
	headerText = TRACKER_HEADER_QUESTS,
	events = { "QUEST_LOG_UPDATE", "QUEST_WATCH_LIST_CHANGED", "QUEST_AUTOCOMPLETE", "SUPER_TRACKING_CHANGED", "QUEST_TURNED_IN" },
	lineTemplate = "QuestObjectiveLineTemplate",
	blockTemplate = "ObjectiveTrackerQuestPOIBlockTemplate",
	rightEdgeFrameSpacing = 2,
	-- for this module
	questItemButtonSettings = {
		template = "QuestObjectiveItemButtonTemplate",
		offsetX = 0,
		offsetY = 0,
	},
	findGroupButtonSettings = {
		template = "QuestObjectiveFindGroupButtonTemplate",
		offsetX = 5,
		offsetY = 2,
	},
};

QuestObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings, AutoQuestPopupTrackerMixin);

function QuestObjectiveTrackerMixin:InitModule()
	self:WatchMoney(false);
end

function QuestObjectiveTrackerMixin:OnEvent(event, ...)
	if event == "QUEST_AUTOCOMPLETE" then
		local questID = ...;
		self:AddAutoQuestPopUp(questID, "COMPLETE");
	elseif event == "QUEST_WATCH_LIST_CHANGED" then
		local questID, added = ...;
		if added then
			local block = self:GetExistingBlock(questID);
			if not block then
				self:SetNeedsFanfare(questID);
			end
		end
		self:MarkDirty();
	elseif event == "QUEST_TURNED_IN" then
		local questID = ...;
		local block = self:GetExistingBlock(questID);
		if block then
			block:PlayTurnInAnimation();
		end
	else
		self:MarkDirty();
	end
end

function QuestObjectiveTrackerMixin:OnBlockHeaderClick(block, mouseButton)
	if ChatEdit_TryInsertQuestLinkForQuestID(block.id) then
		return;
	end

	if mouseButton ~= "RightButton" then
		local questID = block.id;
		if IsModifiedClick("QUESTWATCHTOGGLE") then
			C_QuestLog.RemoveQuestWatch(questID);
		else
			local quest = QuestCache:Get(questID);
			if quest.isAutoComplete and quest:IsComplete() then
				self:RemoveAutoQuestPopUp(questID);
				ShowQuestComplete(questID);
			else
				QuestMapFrame_OpenToQuestDetails(questID);
			end
		end
	else
		MenuUtil.CreateContextMenu(self:GetContextMenuParent(), function(owner, rootDescription)
			rootDescription:SetTag("MENU_QUEST_OBJECTIVE_TRACKER");

			local questID = block.id;
			rootDescription:CreateTitle(C_QuestLog.GetTitleForQuestID(questID));

			if C_SuperTrack.GetSuperTrackedQuestID() ~= questID then
				rootDescription:CreateButton(SUPER_TRACK_QUEST, function()
					C_SuperTrack.SetSuperTrackedQuestID(questID);
				end);
			else
				rootDescription:CreateButton(STOP_SUPER_TRACK_QUEST, function()
					C_SuperTrack.SetSuperTrackedQuestID(0);
				end);
			end

			local toggleDetailsText = QuestUtil.IsShowingQuestDetails(questID) and OBJECTIVES_HIDE_VIEW_IN_QUESTLOG or OBJECTIVES_VIEW_IN_QUESTLOG;

			rootDescription:CreateButton(toggleDetailsText, function()
				QuestUtil.OpenQuestDetails(questID);
			end);

			rootDescription:CreateButton(OBJECTIVES_SHOW_QUEST_MAP, function()
				QuestMapFrame_OpenToQuestDetails(questID);
			end);

			rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function()
				C_QuestLog.RemoveQuestWatch(questID);
			end);

			if C_QuestLog.IsPushableQuest(questID) and IsInGroup() then
				rootDescription:CreateButton(SHARE_QUEST, function()
					QuestUtil.ShareQuest(questID);
				end);
			end
			rootDescription:CreateButton(ABANDON_QUEST_ABBREV, function()
				QuestMapQuestOptions_AbandonQuest(questID);
			end);
		end);
	end
end

function QuestObjectiveTrackerMixin:OnBlockHeaderEnter(block)
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

function QuestObjectiveTrackerMixin:OnBlockHeaderLeave(block)
	GameTooltip:Hide();
end

function QuestObjectiveTrackerMixin:OnFreeBlock(block)
	block.ItemButton = nil;
end

function QuestObjectiveTrackerMixin:GetDebugReportInfo(block)
	return { debugType = "TrackedQuest", questID = block.id, };
end

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

function QuestObjectiveTrackerMixin:BuildQuestWatchInfos()
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

function QuestObjectiveTrackerMixin:EnumQuestWatchData(func)
	local infos = self:BuildQuestWatchInfos();
	for index, questWatchInfo in ipairs(infos) do
		if not func(self, questWatchInfo.quest) then
			return;
		end
	end
end

function QuestObjectiveTrackerMixin:DoQuestObjectives(block, questCompleted, questSequenced, isExistingBlock, useFullHeight)
	local questID = block.id;
	local objectiveCompleting = false;
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
	local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
	local suppressProgressPercentageInObjectiveText = true;

	for objectiveIndex = 1, numObjectives do
		local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questLogIndex, suppressProgressPercentageInObjectiveText);
		if text then
			local line = block:GetExistingLine(objectiveIndex);
			if questCompleted then
				-- only process existing lines that have not faded
				if line and line.state ~= ObjectiveTrackerAnimLineState.Faded then
					line = block:AddObjective(objectiveIndex, text, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
					-- don't do anything else if a line is either COMPLETING or FADING, the anims' OnFinished will continue the process
					if not line.state or line.state == ObjectiveTrackerAnimLineState.Present then
						-- this objective wasn't marked finished
						line:SetState(ObjectiveTrackerAnimLineState.Completing);
					end
				end
			else
				if finished then
					if line and line.state == ObjectiveTrackerAnimLineState.Faded then
						-- don't show this anymore
					elseif line then
						line = block:AddObjective(objectiveIndex, text, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
						if not line.state or line.state == ObjectiveTrackerAnimLineState.Present then
							-- complete this
							line:SetState(ObjectiveTrackerAnimLineState.Completing);
						end
					else
						-- didn't have a line, just show completed if not sequenced
						if not questSequenced then
							line = block:AddObjective(objectiveIndex, text, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
							line:SetState(ObjectiveTrackerAnimLineState.Completed);
						end
					end
				else
					if not questSequenced or not objectiveCompleting then
						-- new objectives need to animate in
						if questSequenced and isExistingBlock and not line then
							line = block:AddObjective(objectiveIndex, text, nil, useFullHeight);
							line:SetState(ObjectiveTrackerAnimLineState.Adding);
							PlaySound(SOUNDKIT.UI_QUEST_ROLLING_FORWARD_01);
							if objectiveType == "progressbar" then
								local progressBar = block:AddProgressBar(questID);
								progressBar:SetPercent(GetQuestProgressBarPercent(questID));
							end
						else
							line = block:AddObjective(objectiveIndex, text, nil, useFullHeight);
							-- some quest objectives can be undone
							if line.state == ObjectiveTrackerAnimLineState.Completed then
								line:SetState(ObjectiveTrackerAnimLineState.Present);
							end
							if objectiveType == "progressbar" then
								local progressBar = block:AddProgressBar(questID);
								progressBar:SetPercent(GetQuestProgressBarPercent(questID));
							end
						end
					end
				end
			end
			if line then
				if line.state == ObjectiveTrackerAnimLineState.Completing then
					objectiveCompleting = true;
				end
			end

		end
	end
	if questCompleted and not objectiveCompleting then
		block:ForEachUsedLine(function(line, objectiveKey)
			if line.state == ObjectiveTrackerAnimLineState.Completed then
				line:SetState(ObjectiveTrackerAnimLineState.Fading);
			end
		end);
	end
	return objectiveCompleting;
end

function QuestObjectiveTrackerMixin:UpdateSingle(quest)
	local questID = quest:GetID();
	local isComplete = quest:IsComplete();
	local isSuperTracked = (questID == C_SuperTrack.GetSuperTrackedQuestID());
	local useFullHeight = true; -- Always use full height of the block for the quest tracker.
	local shouldShowWaypoint = isSuperTracked or (questID == QuestMapFrame_GetFocusedQuestID());
	local isSequenced = IsQuestSequenced(questID);
	local questLogIndex = quest:GetQuestLogIndex();
	local block, isExistingBlock = self:GetBlock(questID);

	if QuestUtil.CanCreateQuestGroup(questID) then
		block:AddRightEdgeFrame(self.findGroupButtonSettings, questID);
	end
	if QuestUtil.QuestShowsItemByIndex(questLogIndex, isComplete) then
		block.ItemButton = block:AddRightEdgeFrame(self.questItemButtonSettings, questLogIndex);
	end

	block:SetHeader(quest.title);

	-- completion state
	local questFailed = C_QuestLog.IsFailed(questID);

	if quest.requiredMoney > 0 then
		self:WatchMoney(true);
	end

	if isComplete then
		-- don't display completion state yet if we're animating an objective completing
		local objectiveCompleting = self:DoQuestObjectives(block, isComplete, isSequenced, isExistingBlock, useFullHeight);
		if not objectiveCompleting then
			if quest.isAutoComplete then
				block:AddObjective("QuestComplete", QUEST_WATCH_QUEST_COMPLETE);
				block:AddObjective("ClickComplete", QUEST_WATCH_CLICK_TO_COMPLETE);
			else
				local completionText = GetQuestLogCompletionText(quest:GetQuestLogIndex());
				if completionText then
					if shouldShowWaypoint then
						local waypointText = C_QuestLog.GetNextWaypointText(questID);
						if waypointText ~= nil then
							block:AddObjective("Waypoint", WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText), nil, useFullHeight);
						end
					end

					local forceCompletedToUseFullHeight = true;
					block:AddObjective("QuestComplete", completionText, nil, forceCompletedToUseFullHeight, OBJECTIVE_DASH_STYLE_HIDE);
				else
					-- If there isn't completion text, always prefer waypoint to "Ready for turn-in".
					local waypointText = C_QuestLog.GetNextWaypointText(questID);
					if waypointText ~= nil then
						block:AddObjective("Waypoint", waypointText, nil, useFullHeight);
					else
						block:AddObjective("QuestComplete", QUEST_WATCH_QUEST_READY, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
					end
				end
			end
		end
	elseif questFailed then
		block:AddObjective("Failed", FAILED, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Failed"]);
	else
		if shouldShowWaypoint then
			local waypointText = C_QuestLog.GetNextWaypointText(questID);
			if waypointText ~= nil then
				block:AddObjective("Waypoint", WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText), nil, useFullHeight);
			end
		end

		self:DoQuestObjectives(block, isComplete, isSequenced, isExistingBlock, useFullHeight);

		if quest.requiredMoney > self.playerMoney then
			local text = GetMoneyString(self.playerMoney).." / "..GetMoneyString(quest.requiredMoney);
			block:AddObjective("Money", text, nil, useFullHeight);
		end

		-- timer bar
		local timeTotal, timeElapsed = C_QuestLog.GetTimeAllowed(questID);
		if timeTotal and timeElapsed and timeElapsed < timeTotal then
			block:AddTimerBar(timeTotal, GetTime() - timeElapsed);
		end
	end

	block:SetPOIInfo(questID, isComplete, isSuperTracked);
	return self:LayoutBlock(block);
end

function QuestObjectiveTrackerMixin:WatchMoney(watch)
	if self.watchMoney ~= watch then
		self.watchMoney = watch;
		self.playerMoney = GetMoney();
	end
end

function QuestObjectiveTrackerMixin:LayoutContents()
	local _, instanceType = IsInInstance();
	if instanceType == "arena" then
		-- no quests in arena
		return;
	end

	self:AddAutoQuestObjectives();
	-- if autoquests ran out of space, we're done
	if self:HasSkippedBlocks() then
		return;
	end

	self:WatchMoney(false);
	self:EnumQuestWatchData(self.UpdateSingle);
end

function QuestObjectiveTrackerMixin:ShouldDisplayQuest(quest)
	if quest.isTask or (quest.isBounty and not isComplete) or quest:IsDisabledForSession() then
		return false;
	end

	return quest:GetQuestClassification() ~= Enum.QuestClassification.Campaign;
end

-- *****************************************************************************************************
-- ***** QUEST LINE
-- *****************************************************************************************************

QuestObjectiveLineMixin = CreateFromMixins(ObjectiveTrackerAnimLineMixin);

-- overrides base
function QuestObjectiveLineMixin:OnGlowAnimFinished()
	if self.state == ObjectiveTrackerAnimLineState.Completing then
		local questID = self.parentBlock.id;
		if IsQuestSequenced(questID) then
			self:SetState(ObjectiveTrackerAnimLineState.Fading);
		else
			self.state = ObjectiveTrackerAnimLineState.Completed;
			self:UpdateModule();
		end
	else
		ObjectiveTrackerAnimLineMixin.OnGlowAnimFinished(self);
	end
end

