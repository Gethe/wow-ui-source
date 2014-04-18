
BONUS_OBJECTIVE_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable();
BONUS_OBJECTIVE_TRACKER_MODULE.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_BONUS_OBJECTIVE;
BONUS_OBJECTIVE_TRACKER_MODULE.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_QUEST + OBJECTIVE_TRACKER_UPDATE_TASK_ADDED + OBJECTIVE_TRACKER_UPDATE_SCENARIO + OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE;
BONUS_OBJECTIVE_TRACKER_MODULE.blockTemplate = "BonusObjectiveTrackerBlockTemplate";
BONUS_OBJECTIVE_TRACKER_MODULE.blockType = "ScrollFrame";
BONUS_OBJECTIVE_TRACKER_MODULE.freeBlocks = { };
BONUS_OBJECTIVE_TRACKER_MODULE.usedBlocks = { };
BONUS_OBJECTIVE_TRACKER_MODULE.freeLines = { };
BONUS_OBJECTIVE_TRACKER_MODULE.lineTemplate = "BonusObjectiveTrackerLineTemplate";
BONUS_OBJECTIVE_TRACKER_MODULE.blockOffsetX = -20;
BONUS_OBJECTIVE_TRACKER_MODULE.lineSpacing = 6;
BONUS_OBJECTIVE_TRACKER_MODULE.fromHeaderOffsetY = -4;

function BONUS_OBJECTIVE_TRACKER_MODULE:OnFreeBlock(block)
	if ( block.state == "LEAVING" ) then
		block.AnimOut:Stop();
	elseif ( block.state == "ENTERING" ) then
		block.AnimIn:Stop();
	end
	block:SetAlpha(0);	
	block.state = nil;
	block.finished = nil;
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
	BONUS_OBJECTIVE_TRACKER_MODULE:SetHeader(self, "Bonus Objectives", 0, OBJECTIVE_TRACKER_UPDATE_MODULE_BONUS_OBJECTIVE);
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
-- ***** UPDATE FUNCTIONS
-- *****************************************************************************************************

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
	end

	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPRIGHT", block, "TOPLEFT", 0, 0);
	GameTooltip:SetOwner(block, "ANCHOR_PRESERVE");
	GameTooltip:SetText(QUEST_REWARDS, 1, 0.831, 0.380);

	if ( not RequestQuestData(questID) ) then
		GameTooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	else	
		GameTooltip:AddLine(BONUS_OBJECTIVE_TOOLTIP_DESCRIPTION, 1, 1, 1, 1);
		GameTooltip:AddLine(" ");
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
		-- currency		
		local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID);
		for i = 1, numQuestCurrencies do
			local name, texture, numItems = GetQuestLogRewardCurrencyInfo(i, questID);
			local text = string.format(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT, texture, numItems, name);
			GameTooltip:AddLine(text, 1, 1, 1);			
		end
		-- xp
		local xp = GetQuestLogRewardXP(questID);
		if ( xp > 0 ) then
			GameTooltip:AddLine(string.format(BONUS_OBJECTIVE_EXPERIENCE_FORMAT, xp), 1, 1, 1);
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

local function UpdateScenarioBonusObjectives(BlocksFrame)
	if ( C_Scenario.IsInScenario() ) then
		BONUS_OBJECTIVE_TRACKER_MODULE.Header.animateReason = OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE;
		local tblBonusSteps = C_Scenario.GetBonusSteps();
		for i = 1, #tblBonusSteps do
			local bonusStepIndex = tblBonusSteps[i];
			local name, description, numCriteria, stepFailed, isBonusStep, isForCurrentStepOnly = C_Scenario.GetStepInfo(bonusStepIndex);
			local blockKey = -bonusStepIndex;	-- so it won't collide with quest IDs			
			local existingBlock = BONUS_OBJECTIVE_TRACKER_MODULE.usedBlocks[blockKey];		
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
					if ( duration > 0 and elapsed <= duration and not criteriaFailed ) then
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
					end
					block.finished = true;
				else
					firstLine.Icon:SetAtlas("Objective-Nub", true);
				end
				firstLine.Icon:Show();
			end
			block:SetHeight(block.height);

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
	local tasksTable = GetTasksTable();
	for _, questID in pairs(tasksTable) do
		local isInArea, isOnMap, numObjectives = GetTaskInfo(questID);
		-- show task if we're in the area or on the same map and we were displaying it before
		local existingTask = BONUS_OBJECTIVE_TRACKER_MODULE.usedBlocks[questID];
		if ( isInArea or ( isOnMap and existingTask ) ) then
			local block = BONUS_OBJECTIVE_TRACKER_MODULE:GetBlock(questID);
			local taskFinished = true;
			for objectiveIndex = 1, numObjectives do
				local text, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex);
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
			block:SetHeight(block.height);
			
			if ( not ObjectiveTracker_AddBlock(block, true) ) then
				-- there was no room to show the header and the block, bail
				block.used = false;
				break;
			end

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

	BONUS_OBJECTIVE_TRACKER_MODULE:BeginLayout();

	UpdateScenarioBonusObjectives(BlocksFrame);
	UpdateQuestBonusObjectives(BlocksFrame);
	if ( BONUS_OBJECTIVE_TRACKER_MODULE.tooltipBlock ) then
		BonusObjectiveTracker_ShowRewardsTooltip(BONUS_OBJECTIVE_TRACKER_MODULE.tooltipBlock);
	end
	
	if ( BONUS_OBJECTIVE_TRACKER_MODULE.firstBlock ) then
		local shadowAnim = BONUS_OBJECTIVE_TRACKER_MODULE.Header.ShadowAnim;
		if ( BONUS_OBJECTIVE_TRACKER_MODULE.Header.animating and not shadowAnim:IsPlaying() ) then
			local distance = BONUS_OBJECTIVE_TRACKER_MODULE.contentsHeight - OBJECTIVE_TRACKER_HEADER_HEIGHT;
			shadowAnim.TransAnim:SetOffset(0, -distance);
			shadowAnim.TransAnim:SetDuration(distance * 0.33 / 50);
			shadowAnim:Play();
		end
	end

	BONUS_OBJECTIVE_TRACKER_MODULE:EndLayout();
end

function BonusObjectiveTracker_SetBlockState(block, state)
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
		elseif ( not block.state ) then
			block:SetAlpha(1);
			block.state = "PRESENT";
		end
	end
end