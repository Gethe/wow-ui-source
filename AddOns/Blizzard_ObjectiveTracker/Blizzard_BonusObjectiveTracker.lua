
BONUS_OBJECTIVE_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable();
BONUS_OBJECTIVE_TRACKER_MODULE.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_BONUS_OBJECTIVE;
BONUS_OBJECTIVE_TRACKER_MODULE.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_QUEST + OBJECTIVE_TRACKER_UPDATE_TASK_ADDED + OBJECTIVE_TRACKER_UPDATE_SCENARIO + OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE + OBJECTIVE_TRACKER_UPDATE_SCENARIO_BONUS_DELAYED;
BONUS_OBJECTIVE_TRACKER_MODULE.blockTemplate = "BonusObjectiveTrackerBlockTemplate";
BONUS_OBJECTIVE_TRACKER_MODULE.blockType = "ScrollFrame";
BONUS_OBJECTIVE_TRACKER_MODULE.freeBlocks = { };
BONUS_OBJECTIVE_TRACKER_MODULE.usedBlocks = { };
BONUS_OBJECTIVE_TRACKER_MODULE.freeLines = { };
BONUS_OBJECTIVE_TRACKER_MODULE.lineTemplate = "BonusObjectiveTrackerLineTemplate";
BONUS_OBJECTIVE_TRACKER_MODULE.blockOffsetX = -20;
BONUS_OBJECTIVE_TRACKER_MODULE.blockOffsetY = -6;
BONUS_OBJECTIVE_TRACKER_MODULE.fromHeaderOffsetY = -8;
BONUS_OBJECTIVE_TRACKER_MODULE.blockPadding = 3;	-- need some extra room so scrollframe doesn't cut tails off gjpqy

local COMPLETED_BONUS_DATA = { };

function BONUS_OBJECTIVE_TRACKER_MODULE:OnFreeBlock(block)
	if ( block.state == "LEAVING" ) then
		block.AnimOut:Stop();
	elseif ( block.state == "ENTERING" ) then
		block.AnimIn:Stop();
	end
	if ( COMPLETED_BONUS_DATA[block.id] ) then
		COMPLETED_BONUS_DATA[block.id] = nil;
		local rewardsFrame = ObjectiveTrackerBonusRewardsFrame;
		if ( rewardsFrame.id == block.id ) then
			rewardsFrame:Hide();
			rewardsFrame.Anim:Stop();
			rewardsFrame.id = nil;
			for i = 1, #rewardsFrame.rewards do
				rewardsFrame.rewards[i].Anim:Stop();	
			end
		end
	end
	block:SetAlpha(0);	
	block.state = nil;
	block.finished = nil;
	block.posIndex = nil;
end

function BONUS_OBJECTIVE_TRACKER_MODULE:OnFreeLine(line)
	if ( line.finished ) then
		line.CheckFlash.Anim:Stop();
		line.finished = nil;
	end
end

-- *****************************************************************************************************
-- ***** FRAME HANDLERS
-- *****************************************************************************************************

function BonusObjectiveTracker_OnHeaderLoad(self)
	BONUS_OBJECTIVE_TRACKER_MODULE:SetHeader(self, TRACKER_HEADER_BONUS_OBJECTIVES, 0, OBJECTIVE_TRACKER_UPDATE_MODULE_BONUS_OBJECTIVE);
	self.height = OBJECTIVE_TRACKER_HEADER_HEIGHT;
end

function BonusObjectiveTracker_OnBlockAnimInFinished(self)
	local block = self:GetParent();
	block:SetAlpha(1);
	block.state = "PRESENT";
	-- negative block IDs are for scenario bonus objectives
	if ( block.id > 0 ) then
		local isInArea, isOnMap = GetTaskInfo(block.id);
		if ( not isInArea ) then
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_BONUS_OBJECTIVE);
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
	BONUS_OBJECTIVE_TRACKER_MODULE:FreeBlock(block);
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_BONUS_OBJECTIVE);
end

function BonusObjectiveTracker_OnBlockEnter(block)
	BONUS_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderEnter(block);
	BonusObjectiveTracker_ShowRewardsTooltip(block);
end

function BonusObjectiveTracker_OnBlockLeave(block)
	BONUS_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderLeave(block);
	GameTooltip:Hide();
	BONUS_OBJECTIVE_TRACKER_MODULE.tooltipBlock = nil;
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
		local isInArea, isOnMap, numObjectives = GetTaskInfo(questID);
		for objectiveIndex = 1, numObjectives do
			local text, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex);
			tinsert(data.objectives, text);
		end
	end
	-- save all the rewards
	data.rewards = { };
	-- xp
	if ( not xp ) then
		xp = GetQuestLogRewardXP(questID);
	end
	if ( xp > 0 ) then
		local t = { };
		t.label = xp;
		t.texture = "Interface\\Icons\\XP_Icon";
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
	-- try to play it
	BonusObjectiveTracker_AnimateReward(block);	
end

function BonusObjectiveTracker_AnimateReward(block)
	local rewardsFrame = ObjectiveTrackerBonusRewardsFrame;
	if ( not rewardsFrame.id ) then
		local data = COMPLETED_BONUS_DATA[block.id];
		if ( not data ) then
			return;
		end

		rewardsFrame.id = block.id;
		rewardsFrame:SetParent(block);
		rewardsFrame:ClearAllPoints();
		rewardsFrame:SetPoint("TOPRIGHT", block, "TOPLEFT", 10, -4);
		rewardsFrame:Show();
		local numRewards = #data.rewards;
		local contentsHeight = 12 + numRewards * 36;
		rewardsFrame.Anim.RewardsBottomAnim:SetOffset(0, -contentsHeight);
		rewardsFrame.Anim.RewardsShadowAnim:SetToScale(0.8, contentsHeight / 16);
		rewardsFrame.Anim:Play();
		-- configure reward frames
		for i = 1, numRewards do
			local rewardItem = rewardsFrame.Rewards[i];
			if ( not rewardItem ) then
				rewardItem = CreateFrame("FRAME", nil, rewardsFrame, "BonusObjectiveTrackerRewardTemplate");
				rewardItem:SetPoint("TOPLEFT", rewardsFrame.Rewards[i-1], "BOTTOMLEFT", 0, -4);
			end
			local rewardData = data.rewards[i];
			if ( rewardData.count > 1 ) then
				rewardItem.Count:Show();
				rewardItem.Count:SetText(rewardData.count);				
			else
				rewardItem.Count:Hide();
			end
			rewardItem.Label:SetFontObject(rewardData.font);
			rewardItem.Label:SetText(rewardData.label);
			rewardItem.ItemIcon:SetTexture(rewardData.texture);
			rewardItem:Show();
			rewardItem.Anim:Play();
		end
		-- hide unused reward items
		for i = numRewards + 1, #rewardsFrame.Rewards do
			rewardsFrame.Rewards[i]:Hide();
		end
	end
end

function BonusObjectiveTracker_OnAnimateRewardDone(self)
	local rewardsFrame = ObjectiveTrackerBonusRewardsFrame;
	-- kill the data
	local oldPosIndex = COMPLETED_BONUS_DATA[rewardsFrame.id].posIndex;
	COMPLETED_BONUS_DATA[rewardsFrame.id] = nil;
	rewardsFrame.id = nil;
	-- kill anims
	for i = 1, #rewardsFrame.Rewards do
		rewardsFrame.Rewards[i].Anim:Stop();
	end
	-- look for another reward to animate and fix positions
	local nextAnimBlock;
	for id, data in pairs(COMPLETED_BONUS_DATA) do
		local block = BONUS_OBJECTIVE_TRACKER_MODULE:GetExistingBlock(id);
		-- make sure we're still showing this
		if ( block ) then
			nextAnimBlock = block;
			-- if this block that completed was ahead of this, bring it up
			if ( data.posIndex > oldPosIndex ) then
				data.posIndex = data.posIndex - 1;
			end
		end
	end
	-- update tracker to remove dead bonus objective
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_BONUS_OBJECTIVE);
	-- animate if we have something, otherwise clear it all
	if ( nextAnimBlock ) then
		BonusObjectiveTracker_AnimateReward(nextAnimBlock);
	else
		rewardsFrame:Hide();
		wipe(COMPLETED_BONUS_DATA);
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

	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPRIGHT", block, "TOPLEFT", 0, 0);
	GameTooltip:SetOwner(block, "ANCHOR_PRESERVE");
	GameTooltip:SetText(REWARDS, 1, 0.831, 0.380);

	if ( not HaveQuestData(questID) ) then
		GameTooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	else	
		GameTooltip:AddLine(BONUS_OBJECTIVE_TOOLTIP_DESCRIPTION, 1, 1, 1, 1);
		GameTooltip:AddLine(" ");
		-- xp
		local xp = GetQuestLogRewardXP(questID);
		if ( xp > 0 ) then
			GameTooltip:AddLine(string.format(BONUS_OBJECTIVE_EXPERIENCE_FORMAT, xp), 1, 1, 1);
		end
		-- currency		
		local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID);
		for i = 1, numQuestCurrencies do
			local name, texture, numItems = GetQuestLogRewardCurrencyInfo(i, questID);
			local text = string.format(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT, texture, numItems, name);
			GameTooltip:AddLine(text, 1, 1, 1);			
		end
		-- items
		local numQuestRewards = GetNumQuestLogRewards(questID);
		for i = 1, numQuestRewards do
			local name, texture, numItems, quality, isUsable = GetQuestLogRewardInfo(i, questID);
			local text;
			if ( numItems > 1 ) then
				text = string.format(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT, texture, numItems, name);
			else
				text = string.format(BONUS_OBJECTIVE_REWARD_FORMAT, texture, name);			
			end
			local color = ITEM_QUALITY_COLORS[quality];
			GameTooltip:AddLine(text, color.r, color.g, color.b);
		end
		-- money
		local money = GetQuestLogRewardMoney(questID);
		if ( money > 0 ) then
			SetTooltipMoney(GameTooltip, money, nil);
		end
	end
	GameTooltip:Show();
	BONUS_OBJECTIVE_TRACKER_MODULE.tooltipBlock = block;
end

-- *****************************************************************************************************
-- ***** INTERNAL FUNCTIONS - blending present and past data (future data nyi)
-- *****************************************************************************************************

local function InternalGetTasksTable()
	local tasks = GetTasksTable();
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
		return true, true, #COMPLETED_BONUS_DATA[questID].objectives;
	else
		return GetTaskInfo(questID);
	end
end

local function InternalGetQuestObjectiveInfo(questID, objectiveIndex)
	if ( COMPLETED_BONUS_DATA[questID] ) then
		return COMPLETED_BONUS_DATA[questID].objectives[objectiveIndex], nil, true;
	else
		return GetQuestObjectiveInfo(questID, objectiveIndex);
	end
end

-- *****************************************************************************************************
-- ***** UPDATE FUNCTIONS
-- *****************************************************************************************************

local function UpdateScenarioBonusObjectives(BlocksFrame)
	if ( C_Scenario.IsInScenario() ) then
		BONUS_OBJECTIVE_TRACKER_MODULE.Header.animateReason = OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE + OBJECTIVE_TRACKER_UPDATE_SCENARIO_BONUS_DELAYED;
		local tblBonusSteps = C_Scenario.GetBonusSteps();
		for i = 1, #tblBonusSteps do
			local bonusStepIndex = tblBonusSteps[i];
			local name, description, numCriteria, stepFailed, isBonusStep, isForCurrentStepOnly = C_Scenario.GetStepInfo(bonusStepIndex);
			local blockKey = -bonusStepIndex;	-- so it won't collide with quest IDs
			local existingBlock = BONUS_OBJECTIVE_TRACKER_MODULE:GetExistingBlock(blockKey);
			local block = BONUS_OBJECTIVE_TRACKER_MODULE:GetBlock(blockKey);			
			local stepFinished = true;
			for criteriaIndex = 1, numCriteria do
				local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex);		
				if ( criteriaString ) then
					if ( criteriaCompleted ) then
						local existingLine = block.lines[criteriaIndex];
						BONUS_OBJECTIVE_TRACKER_MODULE:AddObjective(block, criteriaIndex, criteriaString, nil, nil, nil, OBJECTIVE_TRACKER_COLOR["Complete"]);
						local line = block.currentLine;
						if ( existingLine and not line.finished ) then
							line.Glow.Anim:Play();
							line.Sheen.Anim:Play();
						end
						line.finished = true;
					elseif ( criteriaFailed ) then
						stepFinished = false;
						BONUS_OBJECTIVE_TRACKER_MODULE:AddObjective(block, criteriaIndex, criteriaString, nil, nil, nil, OBJECTIVE_TRACKER_COLOR["Failed"]);
					else
						stepFinished = false;
						BONUS_OBJECTIVE_TRACKER_MODULE:AddObjective(block, criteriaIndex, criteriaString);
					end
					-- timer bar
					if ( duration > 0 and elapsed <= duration and not (criteriaFailed or criteriaCompleted) ) then
						BONUS_OBJECTIVE_TRACKER_MODULE:AddTimerBar(block, block.currentLine, duration, GetTime() - elapsed);
					elseif ( block.currentLine.TimerBar ) then
						BONUS_OBJECTIVE_TRACKER_MODULE:FreeTimerBar(block, block.currentLine);
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
						firstLine.CheckFlash.Anim:Play();
						local questID = C_Scenario.GetBonusStepRewardQuestID(bonusStepIndex);
						if ( questID ~= 0 ) then
							BonusObjectiveTracker_AddReward(questID, block);
						end
					end
					block.finished = true;
				else
					firstLine.Icon:SetAtlas("Objective-Nub", true);
				end
				firstLine.Icon:Show();
			end
			block:SetHeight(block.height + BONUS_OBJECTIVE_TRACKER_MODULE.blockPadding);

			if ( not ObjectiveTracker_AddBlock(block, true) ) then
				-- there was no room to show the header and the block, bail
				block.used = false;
				break;
			end

			block:Show();
			BONUS_OBJECTIVE_TRACKER_MODULE:FreeUnusedLines(block);

			if ( not existingBlock and isForCurrentStepOnly ) then
				BonusObjectiveTracker_SetBlockState(block, "ENTERING");
			else
				BonusObjectiveTracker_SetBlockState(block, "PRESENT");
			end	
		end
	end
end

local function UpdateQuestBonusObjectives(BlocksFrame)
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.animateReason = OBJECTIVE_TRACKER_UPDATE_TASK_ADDED;
	local tasksTable = InternalGetTasksTable();
	for i = 1, #tasksTable do
		local questID = tasksTable[i];
		local isInArea, isOnMap, numObjectives = InternalGetTaskInfo(questID);
		-- show task if we're in the area or on the same map and we were displaying it before
		local existingTask = BONUS_OBJECTIVE_TRACKER_MODULE:GetExistingBlock(questID);
		if ( isInArea or ( isOnMap and existingTask ) ) then
			local block = BONUS_OBJECTIVE_TRACKER_MODULE:GetBlock(questID);
			local taskFinished = true;
			for objectiveIndex = 1, numObjectives do
				local text, objectiveType, finished = InternalGetQuestObjectiveInfo(questID, objectiveIndex);
				if ( text ) then
					if ( finished ) then
						local existingLine = block.lines[objectiveIndex];
						BONUS_OBJECTIVE_TRACKER_MODULE:AddObjective(block, objectiveIndex, text, nil, nil, nil, OBJECTIVE_TRACKER_COLOR["Complete"]);
						local line = block.currentLine;
						if ( existingLine and not line.finished ) then
							line.Glow.Anim:Play();
							line.Sheen.Anim:Play();
						end
						line.finished = true;
					else
						taskFinished = false;
						BONUS_OBJECTIVE_TRACKER_MODULE:AddObjective(block, objectiveIndex, text);
					end
					if ( objectiveIndex > 1 ) then
						local line = block.currentLine;
						line.Icon:Hide();
					end
				end
			end
			-- first line is either going to display the nub or the check
			local firstLine = block.lines[1];
			if ( firstLine ) then
				if ( taskFinished ) then
					firstLine.Icon:SetAtlas("Tracker-Check", true);
					-- play anim if needed
					if ( existingTask and not block.finished ) then
						firstLine.CheckFlash.Anim:Play();
					end
					block.finished = true;
				else
					firstLine.Icon:SetAtlas("Objective-Nub", true);
				end
				firstLine.Icon:Show();
			end
			block:SetHeight(block.height + BONUS_OBJECTIVE_TRACKER_MODULE.blockPadding);
			
			if ( not ObjectiveTracker_AddBlock(block, true) ) then
				-- there was no room to show the header and the block, bail
				block.used = false;
				break;
			end

			block.posIndex = i;
			block:Show();
			BONUS_OBJECTIVE_TRACKER_MODULE:FreeUnusedLines(block);
			
			if ( isInArea ) then
				if ( questID == OBJECTIVE_TRACKER_UPDATE_ID ) then
					BonusObjectiveTracker_SetBlockState(block, "ENTERING");
				else
					BonusObjectiveTracker_SetBlockState(block, "PRESENT");
				end
			elseif ( existingTask ) then
				BonusObjectiveTracker_SetBlockState(block, "LEAVING");
			end
		end
	end
	if ( OBJECTIVE_TRACKER_UPDATE_REASON == OBJECTIVE_TRACKER_UPDATE_TASK_ADDED ) then
		PlaySound("UI_Scenario_Stage_End");
	end	
end

function BONUS_OBJECTIVE_TRACKER_MODULE:Update()
	-- ugh, cross-module dependance
	if ( SCENARIO_TRACKER_MODULE.BlocksFrame.slidingAction and BONUS_OBJECTIVE_TRACKER_MODULE.contentsHeight == 0 ) then
		return;
	end
	
	BONUS_OBJECTIVE_TRACKER_MODULE:BeginLayout();

	UpdateScenarioBonusObjectives(BlocksFrame);
	UpdateQuestBonusObjectives(BlocksFrame);
	if ( BONUS_OBJECTIVE_TRACKER_MODULE.tooltipBlock ) then
		BonusObjectiveTracker_ShowRewardsTooltip(BONUS_OBJECTIVE_TRACKER_MODULE.tooltipBlock);
	end
	
	if ( BONUS_OBJECTIVE_TRACKER_MODULE.firstBlock ) then
		local shadowAnim = BONUS_OBJECTIVE_TRACKER_MODULE.Header.ShadowAnim;
		if ( BONUS_OBJECTIVE_TRACKER_MODULE.Header.animating and not shadowAnim:IsPlaying() ) then
			local distance = BONUS_OBJECTIVE_TRACKER_MODULE.contentsAnimHeight - 8;
			shadowAnim.TransAnim:SetOffset(0, -distance);
			shadowAnim.TransAnim:SetDuration(distance * 0.33 / 50);
			shadowAnim:Play();
		end
	end

	BONUS_OBJECTIVE_TRACKER_MODULE:EndLayout();
end

function BonusObjectiveTracker_SetBlockState(block, state, force)
	if ( block.state == state ) then
		return;
	end

	if ( state == "LEAVING" ) then
		-- only apply this state if block is PRESENT - let ENTERING anim finish
		if ( block.state == "PRESENT" ) then
			-- animate out
			block.AnimOut:Play();
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
			anim.TransOut:SetEndDelay((BONUS_OBJECTIVE_TRACKER_MODULE.contentsHeight - OBJECTIVE_TRACKER_HEADER_HEIGHT) * 0.33 / 50);					
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
	end
end