local settings = {
	hasDisplayPriority = true,
	headerText = TRACKER_HEADER_BONUS_OBJECTIVES,
	events = { "CRITERIA_COMPLETE", "QUEST_TURNED_IN", "QUEST_LOG_UPDATE", "QUEST_WATCH_LIST_CHANGED", "SCENARIO_BONUS_VISIBILITY_UPDATE", "SCENARIO_CRITERIA_UPDATE", "SCENARIO_UPDATE", "QUEST_ACCEPTED", "QUEST_REMOVED" },
	progressBarTemplate = "BonusTrackerProgressBarTemplate",
	lineTemplate = "ObjectiveTrackerAnimLineTemplate",
	blockTemplate = "BonusObjectiveTrackerBlockTemplate",
	-- for this module and those that inherit from it
	showWorldQuests = false,
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
	completedSupersededObjectives = { },
};

BonusObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

local function GetScenarioSupersedingStep(index)
	local supersededObjectives = C_Scenario.GetSupersededObjectives();
	for i, tbl in ipairs(supersededObjectives) do
		-- these tables have 2 values
		local scenarioBonusStepID, supersededBonusStepID = unpack(tbl);
		if supersededBonusStepID == index then
			return scenarioBonusStepID;
		end
	end
end

function BonusObjectiveTrackerMixin:OnFreeBlock(block)
	if block.id < 0 then
		local blockKey = -block.id;
		if GetScenarioSupersedingStep(blockKey) then
			tinsert(self.completedSupersededObjectives, blockKey);
		end
	end
	block:SetAlpha(1);
	block.taskName = nil;
	block.numObjectives = nil;
	block:EnableMouse(false);
end

function BonusObjectiveTrackerMixin:OnBlockHeaderEnter(block)
	block:TryShowRewardsTooltip();
end

function BonusObjectiveTrackerMixin:OnBlockHeaderLeave(block)
	GameTooltip:Hide();
	block.hasRewardsTooltip = nil;
end

function BonusObjectiveTrackerMixin:OnBlockHeaderClick(block, button)
	local questID = block.id;
	local isThreatQuest = C_QuestLog.IsThreatQuest(questID);
	if self.showWorldQuests or isThreatQuest then
		if button == "LeftButton" then
			if ( not ChatEdit_TryInsertQuestLinkForQuestID(questID) ) then
				if IsShiftKeyDown() then
					if QuestUtils_IsQuestWatched(questID) and not isThreatQuest then
						QuestUtil.UntrackWorldQuest(questID);
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
			-- Ensure at least one option will appear before showing the dropdown.
			if not QuestUtils_IsQuestWatched(questID) then
				return;
			end

			MenuUtil.CreateContextMenu(self:GetContextMenuParent(), function(owner, rootDescription)
				rootDescription:SetTag("MENU_BONUS_OBJECTIVE_TRACKER", block);

				local questTitle = C_TaskQuest.GetQuestInfoByQuestID(questID);
				rootDescription:CreateTitle(questTitle);
				rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function()
					QuestUtil.UntrackWorldQuest(questID);
				end);
			end);
		end
	end
end

function BonusObjectiveTrackerMixin:OnEvent(event, ...)
	if event == "CRITERIA_COMPLETE" then
		local tblBonusSteps = C_Scenario.GetBonusSteps();
		for i = 1, #tblBonusSteps do
			local bonusStepIndex = tblBonusSteps[i];
			local _, _, numCriteria = C_Scenario.GetStepInfo(bonusStepIndex);
			local blockKey = -bonusStepIndex;	-- so it won't collide with quest IDs
			local block = self:GetExistingBlock(blockKey);
			if block then
				local id = ...;
				for criteriaIndex = 1, numCriteria do
					local criteriaInfo = C_ScenarioInfo.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex);
					local criteriaID = criteriaInfo and criteriaInfo.criteriaID;
					if id == criteriaID then
						local questID = C_Scenario.GetBonusStepRewardQuestID(bonusStepIndex);
						if questID ~= 0 then
							self:ShowRewardsToast(block, questID);
							return;
						end
					end
				end
			end
		end
	elseif event == "QUEST_TURNED_IN" then
		self:OnQuestTurnedIn(...);
	elseif event == "QUEST_REMOVED" then
		self:OnQuestRemoved(...);
	elseif event == "QUEST_ACCEPTED" then
		local questID = ...;
		if QuestUtil.IsQuestTrackableTask(questID) and not QuestUtils_IsQuestWorldQuest(questID) then
			self:OnQuestAccepted(questID);
		end
	else
		self:MarkDirty();
	end
end

function BonusObjectiveTrackerMixin:OnQuestAccepted(questID)
	if ObjectiveTrackerTopBannerFrame:DisplayForQuest(questID, self) then
		-- banner is gonna play, no need to update yet
		return;
	end
	self:MarkDirty();
end

function BonusObjectiveTrackerMixin:OnQuestTurnedIn(questID)
	local block = self:GetExistingBlock(questID);
	if block then
		block:Reset();
		local forceShowCompleted = true;
		self:SetUpQuestBlock(block, forceShowCompleted);
		if self.showWorldQuests then
			block:TryPlayAnim(block.RemoveAnim, 1);
		else
			self:ShowRewardsToast(block, questID);
		end
	end
end

function BonusObjectiveTrackerMixin:OnQuestRemoved(questID)
	local block = self:GetExistingBlock(questID);
	if block then
		-- if the quest is not completed then the player left the area
		if not C_QuestLog.IsQuestFlaggedCompleted(questID) then
			block:TryPlayAnim(block.RemoveAnim);
		end
	end
end

function BonusObjectiveTrackerMixin:ShowRewardsToast(block, questID)
	local rewards = { };
	-- xp
	local xp = GetQuestLogRewardXP(questID);
	if xp > 0 and not IsPlayerAtEffectiveMaxLevel() then
		local t = { };
		t.label = xp;
		t.texture = "Interface\\Icons\\XP_Icon";
		t.count = 0;
		t.font = "NumberFontNormal";
		tinsert(rewards, t);
	end

	local artifactXP, artifactCategory = GetQuestLogRewardArtifactXP(questID);
	if artifactXP > 0 then
		local name, icon = C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory);
		local t = { };
		t.label = artifactXP;
		t.texture = icon or "Interface\\Icons\\INV_Misc_QuestionMark";
		t.overlay = "Interface\\Artifacts\\ArtifactPower-QuestBorder";
		t.count = 0;
		t.font = "NumberFontNormal";
		tinsert(rewards, t);
	end
	-- currencies
	for index, currencyReward in ipairs(C_QuestLog.GetQuestRewardCurrencies(questID)) do
		local t = { };
		t.label = currencyReward.name;
		t.texture = currencyReward.texture;
		t.count = currencyReward.totalRewardAmount;
		t.font = "GameFontHighlightSmall";
		tinsert(rewards, t);
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
		tinsert(rewards, t);
	end
	-- money
	local money = GetQuestLogRewardMoney(questID);
	if money > 0 then
		local t = { };
		t.label = GetMoneyString(money);
		t.texture = "Interface\\Icons\\inv_misc_coin_01";
		t.count = 0;
		t.font = "GameFontHighlight";
		tinsert(rewards, t);
	end

	local headerText = nil;  -- use default
	local callback = nil;
	if block then
		self:AddBlockToCache(block);
		callback = GenerateClosure(self.OnShowRewardsToastDone, self, block);
	end
	if #rewards > 0 then
		ObjectiveTrackerManager:ShowRewardsToast(rewards, self, block, headerText, callback);
	else
		self:RemoveBlockFromCache(block);
	end
end

function BonusObjectiveTrackerMixin:OnShowRewardsToastDone(block)
	self:RemoveBlockFromCache(block);
end

function BonusObjectiveTrackerMixin:ProcessScenarioBonusObjectives()
	if C_Scenario.IsInScenario() then
		local tblBonusSteps = C_Scenario.GetBonusSteps();
		-- two steps
		local supersededToRemove = {};
		for i = 1, #tblBonusSteps do
			local bonusStepIndex = tblBonusSteps[i];
			local supersededIndex = GetScenarioSupersedingStep(bonusStepIndex);
			if supersededIndex then
				local name, description, numCriteria, stepFailed, isBonusStep, isForCurrentStepOnly, shouldShowBonusObjective = C_Scenario.GetStepInfo(bonusStepIndex);
				local completed = true;
				for criteriaIndex = 1, numCriteria do
					local criteriaInfo = C_ScenarioInfo.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex);
					if criteriaInfo then
						if not criteriaInfo.completed then
							completed = false;
							break;
						end
					end
				end
				if not completed then
					-- B supercedes A, A is not completed, show A but not B
					tinsert(supersededToRemove, supersededIndex);
				else
					if tContains(self.completedSupersededObjectives, bonusStepIndex) then
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
				local block, isExistingBlock = self:GetBlock(blockKey);
				local stepFinished = true;
				local firstLine = nil;
				for criteriaIndex = 1, numCriteria do
					local criteriaInfo = C_ScenarioInfo.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex);
					if criteriaInfo then
						local line;
						local criteriaString = criteriaInfo.description;
						if not criteriaInfo.isWeightedProgress and not criteriaInfo.isFormatted then
							criteriaString = string.format("%d/%d %s", criteriaInfo.quantity, criteriaInfo.totalQuantity, criteriaString);
						end
						if criteriaInfo.completed then
							local existingLine = block:GetExistingLine(criteriaIndex);
							line = block:AddObjective(criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
							if existingLine and not line.finished then
								line:SetState(ObjectiveTrackerAnimLineState.Completing);
							end
							line.finished = true;
						elseif criteriaInfo.failed then
							stepFinished = false;
							line = block:AddObjective(criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Failed"]);
						else
							stepFinished = false;
							line = block:AddObjective(criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_HIDE);
						end
						-- timer bar
						if criteriaInfo.duration > 0 and criteriaInfo.elapsed <= criteriaInfo.duration and not (criteriaInfo.failed or criteriaInfo.completed) then
							block:AddTimerBar(criteriaInfo.duration, GetTime() - criteriaInfo.elapsed);
						end
						if criteriaIndex > 1 then
							line:SetNoIcon(true);
						end
						if not firstLine then
							firstLine = line;
						end
					end
				end

				if not self:LayoutBlock(block) then
					return;
				end

				-- these have no header, enable mouse on block for rewards tooltip
				block:EnableMouse(true);

				-- first line is going to display an icon
				if firstLine then
					if stepFailed then
						firstLine.Icon:SetAtlas("ui-questtracker-objective-fail", false);
					elseif stepFinished then
						firstLine.Icon:SetAtlas("ui-questtracker-tracker-check", false);
					else
						firstLine.Icon:SetAtlas("ui-questtracker-objective-nub", false);
					end
					firstLine.Icon:Show();
				end
			end
		end
	else
		wipe(self.completedSupersededObjectives);
	end
end

function BonusObjectiveTrackerMixin:SetUpQuestBlock(block, forceShowCompleted)
	local questID = block.id;
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
	local isQuestComplete = C_QuestLog.IsComplete(questID);

	if QuestUtil.CanCreateQuestGroup(questID) then
		block:AddRightEdgeFrame(self.findGroupButtonSettings, questID);
	end
	if questLogIndex and QuestUtil.QuestShowsItemByIndex(questLogIndex, isQuestComplete) then
		block:AddRightEdgeFrame(self.questItemButtonSettings, questLogIndex);
	end

	block:SetHeader(block.taskName);
	block:EnableMouse(not block.taskName);

	local isWorldQuest = self.showWorldQuests;
	local isThreatQuest = false;
	if QuestUtils_IsQuestWorldQuest(questID) then
		local isComplete = false;
		local isSuperTracked = questID == C_SuperTrack.GetSuperTrackedQuestID();
		block:SetPOIInfo(questID, isComplete, isSuperTracked, isWorldQuest);
	elseif C_QuestLog.IsThreatQuest(questID) then
		isThreatQuest = true;
	end

	local showAsCompleted = isThreatQuest and isQuestComplete;
	local hasAddedTimeLeft = false;
	for objectiveIndex = 1, block.numObjectives do
		local text, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, forceShowCompleted);
		if text then
			if finished then
				local existingLine = block:GetExistingLine(objectiveIndex);
				if not showAsCompleted or existingLine then
					local line = block:AddObjective(objectiveIndex, text, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
					line.Icon:SetAtlas("ui-questtracker-tracker-check", false);
					line.Icon:Show();
					if existingLine and (not line.state or line.state == ObjectiveTrackerAnimLineState.Present) then
						line:SetState(ObjectiveTrackerAnimLineState.Completing);
					else
						line:SetState(ObjectiveTrackerAnimLineState.Completed);
					end
				end
			else
				local line = block:AddObjective(objectiveIndex, text, nil, nil, OBJECTIVE_DASH_STYLE_SHOW);
				line.Icon:Hide();
			end
		end
		if objectiveType == "progressbar" then
			if not finished then
				if isWorldQuest and not hasAddedTimeLeft then
					-- Add time left (if any) right before the progress bar
					self:TryAddingExpirationWarningLine(block, questID);
					hasAddedTimeLeft = true;
				end

				local progressBar = block:AddProgressBar(questID, finished);
				if self:NeedsFanfare(questID) then
					progressBar.Bar.AnimIn:Play();
				elseif not progressBar.Bar.AnimIn:IsPlaying() then
					-- Bug ID: 495448, setToFinal doesn't always work properly with sibling animations, hackily fix up the state here
					progressBar.Bar.BarGlow:SetAlpha(0);
					progressBar.Bar.Starburst:SetAlpha(0);
					progressBar.Bar.BarFrame2:SetAlpha(0);
					progressBar.Bar.BarFrame3:SetAlpha(0);
					progressBar.Bar.Sheen:SetAlpha(0);
				end
			end
		end
	end
	if showAsCompleted then
		local completionText = isThreatQuest and questLogIndex and GetQuestLogCompletionText(questLogIndex) or QUEST_WATCH_QUEST_READY;
		block:AddObjective("QuestComplete", completionText, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
	end
	if isWorldQuest and not hasAddedTimeLeft then
		-- No progress bar, try adding it at the end
		self:TryAddingExpirationWarningLine(block, questID);
	end

	if showAsCompleted then
		block:ForEachUsedLine(function(line, objectiveKey)
			if line.state == ObjectiveTrackerAnimLineState.Completed then
				line:SetState(ObjectiveTrackerAnimLineState.Fading);
			end
		end);
	end
end

function BonusObjectiveTrackerMixin:AddQuest(questID, isTrackedWorldQuest)
	local isWorldQuest = self.showWorldQuests;
	local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(questID);
	local treatAsInArea = isTrackedWorldQuest or isInArea;
	-- show task if we're in the area and it's not being toasted
	if numObjectives and treatAsInArea and questID ~= ObjectiveTrackerTopBannerFrame:GetQuestID() then
		if displayAsObjective and not self.showWorldQuests then
			self.headerText = TRACKER_HEADER_OBJECTIVE;
		end

		local block = self:GetBlock(questID);
		block.taskName = taskName;
		block.numObjectives = numObjectives;

		local forceShowCompleted = false;
		self:SetUpQuestBlock(block, forceShowCompleted);

		if not self:LayoutBlock(block) then
			return false;
		end

		if self:NeedsFanfare(questID) then
			block:TryPlayAnim(block.AddAnim);
		end

		if block.hasRewardsTooltip then
			block:TryShowRewardsTooltip();
		end
	end
	return true;
end

function BonusObjectiveTrackerMixin:LayoutContents()
	-- reset header text, could be overriden
	self.headerText = TRACKER_HEADER_BONUS_OBJECTIVES;

	self:ProcessScenarioBonusObjectives();

	local tasksTable = GetTasksTable();
	for i = 1, #tasksTable do
		local questID = tasksTable[i];
		if not QuestUtils_IsQuestWorldQuest(questID) and not QuestUtils_IsQuestWatched(questID) then
			if not self:AddQuest(questID) then
				break; -- No more room
			end
		end
	end

	if self:HasContents() then
		self:SetHeader(self.headerText);
	end
end

-- *****************************************************************************************************
-- ***** PROGRESS BAR
-- *****************************************************************************************************

BonusObjectiveTrackerProgressBarMixin = { };

function BonusObjectiveTrackerProgressBarMixin:OnLoad()
	self.Bar.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
end

function BonusObjectiveTrackerProgressBarMixin:SetValue(percent)
	self.Bar:SetValue(percent);
	self.Bar.Label:SetFormattedText(PERCENTAGE_STRING, percent);
	local oldPercent = self.oldPercent;
	self.oldPercent = percent;
	if oldPercent and oldPercent < 100 then
		local delta = percent - oldPercent;
		if delta > 0 then
			self:PlayFlareAnim(delta);
		end
	end
end

function BonusObjectiveTrackerProgressBarMixin:OnGet(isNew, questID, finished)
	local percent = finished and 100 or GetQuestProgressBarPercent(questID);
	self.finished = finished;
	self.questID = questID;
	if isNew then
		self.oldValue = nil;
	end
	if isNew or self.needsReward then
		self:UpdateReward();
	end
	self:SetValue(percent);
end

function BonusObjectiveTrackerProgressBarMixin:UpdateReward()
	local _, texture;
	local questID = self.questID;
	if HaveQuestRewardData(questID) then
		-- reward icon; try the first item
		_, texture = GetQuestLogRewardInfo(1, questID);
		-- artifact xp
		local artifactXP, artifactCategory = GetQuestLogRewardArtifactXP(questID);
		if not texture and artifactXP > 0 then
			local name, icon = C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory);
			texture = icon or "Interface\\Icons\\INV_Misc_QuestionMark";
		end
		-- currency
		local questRewardCurrencies = C_QuestInfoSystem.GetQuestRewardCurrencies(questID);
		if not texture and #questRewardCurrencies > 0 then
			texture = questRewardCurrencies[1].texture;
		end
		-- money?
		if not texture and GetQuestLogRewardMoney(questID) > 0 then
			texture = "Interface\\Icons\\inv_misc_coin_02";
		end
		-- xp
		if not texture and GetQuestLogRewardXP(questID) > 0 and not IsPlayerAtEffectiveMaxLevel() then
			texture = "Interface\\Icons\\xp_icon";
		end
		self.needsReward = nil;
	else
		self.needsReward = true;
	end
	if not texture then
		self.Bar.Icon:Hide();
		self.Bar.IconBG:Hide();
		self.Bar.BarGlow:SetAtlas("bonusobjectives-bar-glow", true);
	else
		self.Bar.Icon:SetTexture(texture);
		self.Bar.Icon:Show();
		self.Bar.IconBG:Show();
		self.Bar.BarGlow:SetAtlas("bonusobjectives-bar-glow-ring", true);
	end
end

function BonusObjectiveTrackerProgressBarMixin:PlayFlareAnim(delta)
	local animOffset = animOffset or 12;
	local offset = self.Bar:GetWidth() * (self.oldPercent / 100) - animOffset;

	local prefix = "";
	if delta < 10 then
		prefix = "Small";
	end

	local flare = self[prefix.."Flare1"];
	if flare.FlareAnim:IsPlaying() then
		flare = self[prefix.."Flare2"];
		if flare.FlareAnim:IsPlaying() then
			flare = nil;
		end
	end

	local block = self.parentLine.parentBlock;
	local canPlayAnim = not block:HasActiveAnim();

	if canPlayAnim and flare then
		flare:SetPoint("LEFT", self.Bar, "LEFT", offset, 0);
		flare.FlareAnim:Play();
	end

	local barFlare = self["FullBarFlare1"];
	if barFlare.FlareAnim:IsPlaying() then
		barFlare = self["FullBarFlare2"];
		if barFlare.FlareAnim:IsPlaying() then
			barFlare = nil;
		end
	end

	if canPlayAnim and barFlare then
		barFlare.FlareAnim:Play();
	end
end

function BonusObjectiveTrackerProgressBarMixin:OnFree()
	self:ResetAnimations();
end

function BonusObjectiveTrackerProgressBarMixin:ResetAnimations()
	for _, frame in ipairs(self.AnimatableFrames) do
		-- a progressbar animatable frame will have one of these two parentkey anims
		local anim = frame.AnimIn or frame.FlareAnim;
		anim:Stop();
		for _, texture in ipairs(frame.AlphaTextures) do
			texture:SetAlpha(0);
		end
	end
end

-- *****************************************************************************************************
-- ***** BLOCK
-- *****************************************************************************************************

BonusObjectiveBlockMixin = CreateFromMixins(ObjectiveTrackerQuestPOIBlockMixin);

function BonusObjectiveBlockMixin:OnEnter()
	self:OnHeaderEnter();
end

function BonusObjectiveBlockMixin:OnLeave()
	self:OnHeaderLeave();
end

function BonusObjectiveBlockMixin:OnMouseUp(mouseButton)
	self:OnHeaderClick(mouseButton);
end

function BonusObjectiveBlockMixin:OnRemoveAnimFinished()
	self.parentModule:ForceRemoveBlock(self);
end

function BonusObjectiveBlockMixin:TryShowRewardsTooltip()
	local questID;
	if self.id < 0 then
		-- this is a scenario bonus objective
		questID = C_Scenario.GetBonusStepRewardQuestID(-self.id);
		if questID == 0 then
			-- huh, no reward
			return;
		end
	else
		questID = self.id;
		if C_QuestLog.IsQuestFlaggedCompleted(questID) then
			-- no tooltip for completed objectives
			return;
		end
	end

	if HaveQuestRewardData(questID) and GetQuestLogRewardXP(questID) == 0 and (not C_QuestInfoSystem.HasQuestRewardCurrencies(questID))
								and GetNumQuestLogRewards(questID) == 0 and GetQuestLogRewardMoney(questID) == 0 and GetQuestLogRewardArtifactXP(questID) == 0 then
		GameTooltip:Hide();
		return;
	end

	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0);
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");

	if not HaveQuestRewardData(questID) then
		GameTooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		GameTooltip_SetTooltipWaitingForData(GameTooltip, true);
	else
		local isWorldQuest = self.parentModule.showWorldQuests;
		if isWorldQuest then
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
	self.hasRewardsTooltip = true;
end

-- *****************************************************************************************************
-- ***** TOP BANNER
-- *****************************************************************************************************

ObjectiveTrackerTopBannerMixin = { };

function ObjectiveTrackerTopBannerMixin:OnLoad()
	self.PopAnim:SetScript("OnFinished", GenerateClosure(self.OnPopAnimFinished, self));
	self.SlideAnim:SetScript("OnFinished", GenerateClosure(self.OnSlideAnimFinished, self));
end

function ObjectiveTrackerTopBannerMixin:OnHide()
	TopBannerManager_BannerFinished();
end

function ObjectiveTrackerTopBannerMixin:GetQuestID()
	return self.questID;
end

function ObjectiveTrackerTopBannerMixin:DisplayForQuest(questID, module)
	if not TopBannerManager_IsIdle() then
		return false;
	end

	local questTitle = C_QuestLog.GetTitleForQuestID(questID);
	if not questTitle then
		return false;
	end

	self.questID = questID;
	self.module = module;
	self.questTitle = questTitle;
	TopBannerManager_Show(ObjectiveTrackerTopBannerFrame);
	return true;
end

-- called by TopBannerManager
function ObjectiveTrackerTopBannerMixin:PlayBanner()
	self.Title:SetText(self.questTitle);
	if self.showWorldQuests then
		self.Subtitle:SetText(WORLD_QUEST_BANNER);
		PlaySound(SOUNDKIT.UI_WORLDQUEST_START);
	else
		self.Subtitle:SetText(BONUS_OBJECTIVE_BANNER);
		PlaySound(SOUNDKIT.UI_SCENARIO_STAGE_END);
	end
	-- hide zone text as it's very likely to be up
	ZoneText_Clear();
	-- reset alphas for those with start delays
	self.UpLine:SetAlpha(0);
	self.DownLine:SetAlpha(0);
	self.UpLineGlow:SetAlpha(1);
	self.DownLineGlow:SetAlpha(1);
	self.Spark:SetAlpha(0);
	self.Title:SetAlpha(0);
	self.Subtitle:SetAlpha(0);
	-- show and play
	self:Show();
	self:SetAlpha(1);
	self.SlideAnim:Stop();
	self.PopAnim:Restart();
end

-- called by TopBannerManager
function ObjectiveTrackerTopBannerMixin:StopBanner()
	self.PopAnim:Stop();
	self.SlideAnim:Stop();
	self:Hide();
	self:Finish();
end

function ObjectiveTrackerTopBannerMixin:OnPopAnimFinished()
	-- offsets for anims
	local container = ObjectiveTrackerManager:GetContainerForModule(self.module);
	if container:IsRectValid() then
		local height = container:GetHeightToModule(self.module);
		local xOffset = container:GetLeft() - self:GetRight();
		local yOffset = container:GetTop() - height - self:GetTop() + (self:GetHeight() / 2);
		self.SlideAnim.Translation:SetOffset(xOffset, yOffset);
	else
		self.SlideAnim.Translation:SetOffset(0, 0);
	end
	self.SlideAnim:Play();
end

function ObjectiveTrackerTopBannerMixin:OnSlideAnimFinished()
	self:Hide();
	self:Finish();
end

function ObjectiveTrackerTopBannerMixin:Finish()
	-- TODO: figure out why sometimes there is no .module
	if self.module then
		self.module:SetNeedsFanfare(self.questID);
		self.module:MarkDirty();
		self.module = nil;
		self.questID = nil;
	end
end