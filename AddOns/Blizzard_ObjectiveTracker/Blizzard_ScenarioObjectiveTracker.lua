
SCENARIO_CONTENT_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable();
SCENARIO_CONTENT_TRACKER_MODULE.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_SCENARIO;
SCENARIO_CONTENT_TRACKER_MODULE.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_SCENARIO + OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE;
SCENARIO_CONTENT_TRACKER_MODULE:SetHeader(ObjectiveTrackerFrame.BlocksFrame.ScenarioHeader, TRACKER_HEADER_SCENARIO, nil);	-- never anim-in the header
SCENARIO_CONTENT_TRACKER_MODULE.blockOffsetX = -20;
SCENARIO_CONTENT_TRACKER_MODULE.fromHeaderOffsetY = -2;

-- we need to go deeper

SCENARIO_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable();
SCENARIO_TRACKER_MODULE.usedBlocks = { };
SCENARIO_TRACKER_MODULE.freeLines = { };
SCENARIO_TRACKER_MODULE.lineTemplate = "ObjectiveTrackerCheckLineTemplate";
SCENARIO_TRACKER_MODULE.lineSpacing = 12;
SCENARIO_TRACKER_MODULE.blockOffsetY = -1;
SCENARIO_TRACKER_MODULE.fromHeaderOffsetY = -1;

function SCENARIO_TRACKER_MODULE:GetBlock()
	-- just 1 block for scenario objectives
	local block = ScenarioObjectiveBlock;
	block.used = true;
	block.height = 0;
	block.currentLine = nil;
	-- prep lines
	if ( block.lines ) then
		for objectiveKey, line in pairs(block.lines) do
			line.used = nil;
		end
	else
		block.lines = { };
	end
	return block;
end

function SCENARIO_TRACKER_MODULE:OnFreeLine(line)
	if ( line.completed ) then
		line.Glow.Anim:Stop();
		line.Sheen.Anim:Stop();
		line.CheckFlash.Anim:Stop();
		line.completed = nil;
	end
end

-- *****************************************************************************************************
-- ***** SLIDING
-- *****************************************************************************************************

function ScenarioBlocksFrame_OnFinishSlideIn()
	SCENARIO_TRACKER_MODULE.BlocksFrame.slidingAction = nil;
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_SCENARIO);
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_SCENARIO_BONUS_DELAYED);
end

function ScenarioBlocksFrame_OnFinishSlideOut()
	SCENARIO_TRACKER_MODULE.BlocksFrame.slidingAction = nil;
	ScenarioStageBlock.CompleteLabel:Hide();
	local name, currentStage, numStages = C_Scenario.GetInfo();
	if ( currentStage and currentStage <= numStages ) then
		ScenarioBlocksFrame_SlideIn();
	else
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_SCENARIO);
	end	
end

local SLIDE_IN_DATA = { startHeight = 1, endHeight = 0, duration = 0.4, scroll = true, onFinishFunc = ScenarioBlocksFrame_OnFinishSlideIn };
local SLIDE_OUT_DATA = { startHeight = 0, endHeight = 1, duration = 0.4, scroll = true, startDelay =  0.8, endDelay = 0.6, onFinishFunc = ScenarioBlocksFrame_OnFinishSlideOut };

function ScenarioBlocksFrame_SlideIn()
	SCENARIO_TRACKER_MODULE.BlocksFrame.slidingAction = "IN";
	SLIDE_IN_DATA.endHeight = SCENARIO_TRACKER_MODULE.BlocksFrame.height;
	ScenarioStageBlock.Stage:Show();
	ScenarioStageBlock.Name:Show();
	ScenarioStageBlock.CompleteLabel:Hide();	
	ScenarioObjectiveBlock:Show();	
	ObjectiveTracker_SlideBlock(SCENARIO_TRACKER_MODULE.BlocksFrame, SLIDE_IN_DATA);
end

function ScenarioBlocksFrame_SetupStageBlock(scenarioCompleted)
	ScenarioStageBlock.Stage:Hide();
	ScenarioStageBlock.Name:Hide();
	ScenarioStageBlock.CompleteLabel:Show();
	ScenarioObjectiveBlock:Hide();
	if ( scenarioCompleted ) then
		local _, _, _, flags = C_Scenario.GetInfo();
		local dungeonDisplay = bit.band(flags, SCENARIO_FLAG_USE_DUNGEON_DISPLAY) == SCENARIO_FLAG_USE_DUNGEON_DISPLAY;
		if( dungeonDisplay ) then
			ScenarioStageBlock.CompleteLabel:SetText(DUNGEON_COMPLETED);
		else
			ScenarioStageBlock.CompleteLabel:SetText(SCENARIO_COMPLETED_GENERIC);
		end
	else
		ScenarioStageBlock.CompleteLabel:SetText(STAGE_COMPLETE);
	end
	if ( OBJECTIVE_TRACKER_UPDATE_REASON == OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE ) then
		ScenarioStageBlock.GlowTexture.AlphaAnim:Play();
	end
end

function ScenarioBlocksFrame_SlideOut()
	SCENARIO_TRACKER_MODULE.BlocksFrame.slidingAction = "OUT";
	SLIDE_OUT_DATA.startHeight = ScenarioStageBlock.height;
	ObjectiveTracker_SlideBlock(SCENARIO_TRACKER_MODULE.BlocksFrame, SLIDE_OUT_DATA);
end

function ScenarioBlocksFrame_Hide()
	SCENARIO_TRACKER_MODULE.BlocksFrame.currentStage = nil;
	SCENARIO_TRACKER_MODULE.BlocksFrame.scenarioName = nil;	
	SCENARIO_TRACKER_MODULE.BlocksFrame:SetVerticalScroll(0);
	SCENARIO_TRACKER_MODULE.BlocksFrame:Hide();
end

-- *****************************************************************************************************
-- ***** FRAME HANDLERS
-- *****************************************************************************************************

function ScenarioBlocksFrame_OnLoad(self)
	self.module = SCENARIO_CONTENT_TRACKER_MODULE;
	-- scenario uses fixed blocks (stage, objective, challenge mode)
	ScenarioStageBlock.module = SCENARIO_TRACKER_MODULE;
	ScenarioStageBlock.height = ScenarioStageBlock:GetHeight();	
	ScenarioObjectiveBlock.module = SCENARIO_TRACKER_MODULE;
	ScenarioChallengeModeBlock.module = SCENARIO_TRACKER_MODULE;
	ScenarioChallengeModeBlock.height = ScenarioChallengeModeBlock:GetHeight();
	ScenarioProvingGroundsBlock.module = SCENARIO_TRACKER_MODULE;
	ScenarioProvingGroundsBlock.height = ScenarioProvingGroundsBlock:GetHeight();

	SCENARIO_TRACKER_MODULE.BlocksFrame = self;
	
	self:SetWidth(OBJECTIVE_TRACKER_LINE_WIDTH);
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("WORLD_STATE_TIMER_START");
	self:RegisterEvent("WORLD_STATE_TIMER_STOP");
	self:RegisterEvent("PROVING_GROUNDS_SCORE_UPDATE");
	self:RegisterEvent("SCENARIO_COMPLETED");
end

function ScenarioBlocksFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		ScenarioTimer_CheckTimers(GetWorldElapsedTimers());
	elseif ( event == "WORLD_STATE_TIMER_START") then
		local timerID = ...;
		ScenarioTimer_CheckTimers(timerID);
	elseif ( event == "WORLD_STATE_TIMER_STOP" ) then
		local timerID = ...;
		ScenarioTimer_Stop(timerID);
	elseif (event == "PROVING_GROUNDS_SCORE_UPDATE") then
		local score = ...
		ScenarioProvingGroundsBlock.Score:SetText(score);
	elseif (event == "SCENARIO_COMPLETED") then
		local xp, money = ...;
		if( ( xp > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL ) or money > 0 ) then
			ScenarioObjectiveTracker_AnimateReward( xp, money );
		end
	end
end

function ScenarioObjectiveStageBlock_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("RIGHT", self, "LEFT", 0, 0);
	local _, currentStage, numStages, flags, _, _, _, xp, money = C_Scenario.GetInfo();
	local name, description = C_Scenario.GetStepInfo();
	if( name and bit.band(flags, SCENARIO_FLAG_SUPRESS_STAGE_TEXT) == SCENARIO_FLAG_SUPRESS_STAGE_TEXT) then
	  GameTooltip:SetText(name, 1, 0.914, 0.682, 1);
	  GameTooltip:AddLine(description, 1, 1, 1, true);
	  GameTooltip:AddLine(" ");
	  if ( xp > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL ) then
		GameTooltip:AddLine(string.format(BONUS_OBJECTIVE_EXPERIENCE_FORMAT, xp), 1, 1, 1);
	  end
	  if ( money > 0 ) then
		SetTooltipMoney(GameTooltip, money, nil);
	  end
	  GameTooltip:Show();
	elseif( currentStage <= numStages ) then
	  GameTooltip:SetText(string.format(SCENARIO_STAGE_STATUS, currentStage, numStages), 1, 0.914, 0.682, 1);
	  GameTooltip:AddLine(name, 1, 0.831, 0.380, true);
	  GameTooltip:AddLine(" ");
	  GameTooltip:AddLine(description, 1, 1, 1, true);
	  GameTooltip:Show();
	end
end

-- *****************************************************************************************************
-- ***** TIMER
-- *****************************************************************************************************

local floor = floor;
function ScenarioTimer_OnUpdate(self, elapsed)
	self.timeSinceBase = self.timeSinceBase + elapsed;
	self.updateFunc(self.block, floor(self.baseTime + self.timeSinceBase));
end

function ScenarioTimer_Start(block, updateFunc)
	local _, elapsedTime = GetWorldElapsedTime(block.timerID);
	ScenarioTimerFrame.baseTime = elapsedTime;	
	ScenarioTimerFrame.timeSinceBase = 0;	
	ScenarioTimerFrame.block = block;
	ScenarioTimerFrame.updateFunc = updateFunc;
	ScenarioTimerFrame:Show();
end

function ScenarioTimer_Stop(timerID)
	local timerFrame = ScenarioTimerFrame;
	if ( timerFrame.block and (not timerID or timerFrame.block.timerID == timerID) ) then
		-- remove the block
		timerFrame.block.timerID = nil;
		timerFrame.block:Hide();
		-- remove the timer
		timerFrame:Hide();
		timerFrame.baseTime = nil;
		timerFrame.timeSinceBase = nil;
		timerFrame.block = nil;
		timerFrame.updateFunc = nil;
		-- update
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_SCENARIO);
	end
end

function ScenarioTimer_CheckTimers(...)
	-- only supporting 1 active timer
	for i = 1, select("#", ...) do
		local timerID = select(i, ...);
		local _, elapsedTime, type = GetWorldElapsedTime(timerID);
		if ( type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE) then
			local _, _, _, _, _, _, _, mapID = GetInstanceInfo();
			if ( mapID ) then
				Scenario_ChallengeMode_ShowBlock(timerID, elapsedTime, GetChallengeModeMapTimes(mapID));
				return;
			end
		elseif ( type == LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND ) then
			local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
			if (duration > 0) then
				Scenario_ProvingGrounds_ShowBlock(timerID, elapsedTime, duration, diffID, currWave, maxWave);
				return;
			end
		end
	end
	-- we had an update but didn't find a valid timer, kill the timer if it's running
	ScenarioTimer_Stop();
end

-- *****************************************************************************************************
-- ***** REWARD FRAME
-- *****************************************************************************************************

function ScenarioObjectiveTracker_AnimateReward(xp, money)
	local rewardsFrame = ObjectiveTrackerScenarioRewardsFrame;
	rewardsFrame:Show();
	rewardsFrame:SetScale(0.9);
	local rewards = {};
	if( xp > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL ) then
		local t = {};
		t.label = xp;
		t.texture = "Interface\\Icons\\XP_Icon";
		t.count = 0;
		t.font = "NumberFontNormal";
		tinsert(rewards, t);
	end
	if( money > 0 ) then
		local t = {};
		t.label = GetMoneyString(money);
		t.texture = "Interface\\Icons\\inv_misc_coin_01";
		t.count = 0;
		t.font = "GameFontHighlight";
		tinsert(rewards, t);
	end
	local numRewards = #rewards;
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
		local rewardData = rewards[i];
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
		if( rewardItem.Anim:IsPlaying() ) then
			rewardItem.Anim:Stop();
		end
		rewardItem.Anim:Play();
	end
	-- hide unused reward items
	for i = numRewards + 1, #rewardsFrame.Rewards do
		rewardsFrame.Rewards[i]:Hide();
	end
end

function ScenarioObjectiveTracker_OnAnimateRewardDone(self)
	local rewardsFrame = ObjectiveTrackerScenarioRewardsFrame;
	rewardsFrame:Hide();
end

-- *****************************************************************************************************
-- ***** CHALLENGE MODE
-- *****************************************************************************************************

function Scenario_ChallengeMode_ShowBlock(timerID, elapsedTime, ...)
	local block = ScenarioChallengeModeBlock;
	if not ( block.medalTimes ) then
		block.medalTimes = { };
	end
	for i = 1, select("#", ...) do
		block.medalTimes[i] = select(i, ...);
	end
	block.timerID = timerID;
	block.lastMedalShown = nil;
	Scenario_ChallengeMode_UpdateMedal(block, elapsedTime);
	Scenario_ChallengeMode_UpdateTime(block, elapsedTime);
	ScenarioTimer_Start(block, Scenario_ChallengeMode_UpdateTime);
	block:Show();
	ObjectiveTracker_Expand();
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_SCENARIO);
end

function Scenario_ChallengeMode_UpdateMedal(block, elapsedTime)
	-- find best medal for current time
	local prevMedalTime = 0;
	for i = #block.medalTimes, 1, -1 do
		local currentMedalTime = block.medalTimes[i];
		if ( elapsedTime < currentMedalTime ) then
			block.StatusBar:SetMinMaxValues(0, currentMedalTime - prevMedalTime);
			block.StatusBar.medalTime = currentMedalTime;
			if ( CHALLENGE_MEDAL_TEXTURES[i] ) then
				block.MedalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES[i]);
				block.MedalIcon:Show();
				block.GlowFrame.MedalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES[i]);
				block.GlowFrame.MedalGlowAnim:Play();
			end
			block.NoMedal:Hide();
			-- play sound if medal changed
			if ( block.lastMedalShown and block.lastMedalShown ~= i ) then
				if ( block.lastMedalShown == CHALLENGE_MEDAL_GOLD ) then
					PlaySound("UI_Challenges_MedalExpires_GoldtoSilver");
				elseif ( block.lastMedalShown == CHALLENGE_MEDAL_SILVER ) then
					PlaySound("UI_Challenges_MedalExpires_SilvertoBronze");
				else
					PlaySound("UI_Challenges_MedalExpires");
				end
			end
			block.lastMedalShown = i;
			return;
		else
			prevMedalTime = currentMedalTime;
		end
	end
	-- no medal
	block.StatusBar.TimeLeft:SetText(CHALLENGES_TIMER_NO_MEDAL);
	block.StatusBar:SetValue(0);
	block.StatusBar.medalTime = nil;
	block.NoMedal:Show();
	block.MedalIcon:Hide();
	-- play sound if medal changed
	if ( block.lastMedalShown and block.lastMedalShown ~= 0 ) then
		PlaySound("UI_Challenges_MedalExpires");
	end
	block.lastMedalShown = 0;
end

function Scenario_ChallengeMode_UpdateTime(block, elapsedTime)
	local statusBar = block.StatusBar;
	if ( statusBar.medalTime ) then
		local timeLeft = statusBar.medalTime - elapsedTime;
		local anim = block.GlowFrame.MedalPulseAnim;
		if (timeLeft <= 5) then
			if (anim:IsPlaying()) then 
				anim.timeLeft = timeLeft;
			else
				block.GlowFrame.MedalPulseAnim:Play();
			end
		end
		if (timeLeft == 10) then
			if (not block.playedSound) then
				PlaySoundKitID(34154);
				block.playedSound = true;
			end
		else
			block.playedSound = false;
		end
		if ( timeLeft < 0 ) then
			Scenario_ChallengeMode_UpdateMedal(block, elapsedTime);
		else
			statusBar:SetValue(timeLeft);
			statusBar.TimeLeft:SetText(GetTimeStringFromSeconds(timeLeft));
		end
	end
end

function Scenario_ChallengeMode_MedalPulseAnim_OnFinished(self)
	if ( self.timeLeft and self.timeLeft > 0 and self.timeLeft < 5 ) then
		self:Play();
	else
		self.timeLeft = nil;
	end
end

-- *****************************************************************************************************
-- ***** PROVING GROUNDS
-- *****************************************************************************************************

local PROVING_GROUNDS_ENDLESS_INDEX = 4;
function Scenario_ProvingGrounds_ShowBlock(timerID, elapsedTime, duration, medalIndex, currWave, maxWave)
	local block = ScenarioProvingGroundsBlock;
	local statusBar = block.StatusBar;
	
	block.timerID = timerID;
	statusBar.duration = duration;
	statusBar:SetMinMaxValues(0, duration);
	if ( CHALLENGE_MEDAL_TEXTURES[medalIndex] ) then
		block.MedalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES[medalIndex]);
		block.MedalIcon:Show();
	end
	
	if (medalIndex < PROVING_GROUNDS_ENDLESS_INDEX) then
		block.ScoreLabel:Hide();
		block.Score:Hide();
		block.WaveLabel:SetPoint("TOPLEFT", block.MedalIcon, "TOPRIGHT", 1, -4);
		block.Wave:SetFormattedText(GENERIC_FRACTION_STRING, currWave, maxWave);
		statusBar:SetPoint("TOPLEFT", block.WaveLabel, "BOTTOMLEFT", -2, -6);
	else
		block.ScoreLabel:Show();
		block.Score:Show();
		block.WaveLabel:SetPoint("TOPLEFT", block.MedalIcon, "TOPRIGHT", 1, 4);
		block.Wave:SetText(currWave);
		statusBar:SetPoint("TOPLEFT", block.ScoreLabel, "BOTTOMLEFT", -2, -6);
	end

	Scenario_ProvingGrounds_UpdateTime(block, elapsedTime);
	ScenarioProvingGroundsBlockAnim.CountdownAnim.timeLeft = nil;

	ScenarioTimer_Start(block, Scenario_ProvingGrounds_UpdateTime);
	block:Show();
	ObjectiveTracker_Expand();
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_SCENARIO);
end

function Scenario_ProvingGrounds_UpdateTime(block, elapsedTime)
	local statusBar = block.StatusBar;
	local anim = ScenarioProvingGroundsBlockAnim.CountdownAnim;
	if ( elapsedTime < statusBar.duration ) then
		statusBar:SetValue(statusBar.duration - elapsedTime);
		statusBar.TimeLeft:SetText(GetTimeStringFromSeconds(statusBar.duration - elapsedTime));
		
		local timeLeft = statusBar.duration - elapsedTime;
		if (timeLeft <= 5) then
			if (not anim:IsPlaying() and anim.cycles == 0) then 
				anim:Play();
				anim.cycles = 4; 
			end
		else
			anim.cycles = 0;
		end
	else
		anim.cycles = 0;
	end
end

function Scenario_ProvingGrounds_CountdownAnim_OnFinished(self)
	if ( self.cycles > 0 ) then
		self:Play();
		self.cycles = self.cycles - 1;
	else
		self.cycles = 0;
	end
end

-- *****************************************************************************************************
-- ***** UPDATE FUNCTIONS
-- *****************************************************************************************************

function SCENARIO_CONTENT_TRACKER_MODULE:StaticReanchor()
	local scenarioName, currentStage, numStages, flags, _, _, completed, xp, money = C_Scenario.GetInfo();
	local rewardsFrame = ObjectiveTrackerScenarioRewardsFrame;
	if ( numStages == 0 ) then
		ScenarioBlocksFrame_Hide();
		return;
	end
	if ( ScenarioBlocksFrame:IsShown() ) then
		ObjectiveTracker_AddBlock(SCENARIO_TRACKER_MODULE.BlocksFrame);
	end
end

function SCENARIO_CONTENT_TRACKER_MODULE:Update()
	local scenarioName, currentStage, numStages, flags, _, _, _, xp, money = C_Scenario.GetInfo();
	local rewardsFrame = ObjectiveTrackerScenarioRewardsFrame;
	if ( numStages == 0 ) then
		ScenarioBlocksFrame_Hide();
		return;
	end
	local BlocksFrame = SCENARIO_TRACKER_MODULE.BlocksFrame;	
	local objectiveBlock = SCENARIO_TRACKER_MODULE:GetBlock();
	local stageBlock = ScenarioStageBlock;

	-- if sliding, ignore updates unless the stage changed
	if ( BlocksFrame.slidingAction ) then
		if ( BlocksFrame.currentStage == currentStage ) then
			ObjectiveTracker_AddBlock(BlocksFrame);
			BlocksFrame:Show();
			return;
		else
			ObjectiveTracker_EndSlideBlock(BlocksFrame);
		end
	end
	
	BlocksFrame.maxHeight = SCENARIO_CONTENT_TRACKER_MODULE.BlocksFrame.maxHeight;
	BlocksFrame.currentBlock = nil;
	BlocksFrame.contentsHeight = 0;
	SCENARIO_TRACKER_MODULE.contentsHeight = 0;

	local stageName, stageDescription, numCriteria = C_Scenario.GetStepInfo();
	local inChallengeMode = bit.band(flags, SCENARIO_FLAG_CHALLENGE_MODE) == SCENARIO_FLAG_CHALLENGE_MODE;
	local inProvingGrounds = bit.band(flags, SCENARIO_FLAG_PROVING_GROUNDS) == SCENARIO_FLAG_PROVING_GROUNDS;
	local dungeonDisplay = bit.band(flags, SCENARIO_FLAG_USE_DUNGEON_DISPLAY) == SCENARIO_FLAG_USE_DUNGEON_DISPLAY;
	local scenariocompleted = currentStage > numStages;

	if ( scenariocompleted ) then
		ObjectiveTracker_AddBlock(stageBlock);
		ScenarioBlocksFrame_SetupStageBlock(scenariocompleted);
		stageBlock:Show();
	elseif ( inChallengeMode ) then
		if ( ScenarioChallengeModeBlock.timerID ) then
			ObjectiveTracker_AddBlock(ScenarioChallengeModeBlock);
		end
		stageBlock:Hide();
	elseif ( ScenarioProvingGroundsBlock.timerID ) then
		ObjectiveTracker_AddBlock(ScenarioProvingGroundsBlock);
		stageBlock:Hide();
	else
		-- add the stage block
		ObjectiveTracker_AddBlock(stageBlock);
		stageBlock:Show();
		-- update if stage changed
		if ( BlocksFrame.currentStage ~= currentStage or BlocksFrame.scenarioName ~= scenarioName ) then
			SCENARIO_TRACKER_MODULE:FreeUnusedLines(objectiveBlock);
			if ( bit.band(flags, SCENARIO_FLAG_SUPRESS_STAGE_TEXT) == SCENARIO_FLAG_SUPRESS_STAGE_TEXT ) then
				stageBlock.Stage:SetText(stageName);
				stageBlock.Stage:SetSize( 172, 36 );
				stageBlock.Stage:SetPoint("TOPLEFT", 15, -18);				
				stageBlock.FinalBG:Hide();
				stageBlock.Name:SetText("");
			else
				if ( currentStage == numStages ) then
					stageBlock.Stage:SetText(SCENARIO_STAGE_FINAL);
					stageBlock.FinalBG:Show();
				else
					stageBlock.Stage:SetFormattedText(SCENARIO_STAGE, currentStage);
					stageBlock.FinalBG:Hide();
				end
				stageBlock.Stage:SetSize( 172, 18 );
				stageBlock.Name:SetText(stageName);
				if ( stageBlock.Name:GetStringWidth() > stageBlock.Name:GetWrappedWidth() ) then
					stageBlock.Stage:SetPoint("TOPLEFT", 15, -10);
				else
					stageBlock.Stage:SetPoint("TOPLEFT", 15, -18);
				end
			end
		end	
	end
	BlocksFrame.scenarioName = scenarioName;
	BlocksFrame.currentStage = currentStage;
			
	if ( not ScenarioProvingGroundsBlock.timerID and not scenariocompleted ) then
		-- do the criteria
		for criteriaIndex = 1, numCriteria do
			local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed = C_Scenario.GetCriteriaInfo(criteriaIndex);
			criteriaString = string.format("%d/%d %s", quantity, totalQuantity, criteriaString);
			if ( criteriaIndex == 1 and not inChallengeMode ) then
				SCENARIO_TRACKER_MODULE.lineSpacing = 2;
			else
				SCENARIO_TRACKER_MODULE.lineSpacing = 12;
			end
			if ( completed ) then
				local existingLine = objectiveBlock.lines[criteriaIndex];
				SCENARIO_TRACKER_MODULE:AddObjective(objectiveBlock, criteriaIndex, criteriaString, nil, nil, nil, OBJECTIVE_TRACKER_COLOR["Complete"]);
				objectiveBlock.currentLine.Icon:SetAtlas("Tracker-Check", true);
				if ( existingLine and not existingLine.completed ) then
					existingLine.Glow.Anim:Play();
					existingLine.Sheen.Anim:Play();
					existingLine.CheckFlash.Anim:Play();
				end
				objectiveBlock.currentLine.completed = true;			
			else
				SCENARIO_TRACKER_MODULE:AddObjective(objectiveBlock, criteriaIndex, criteriaString);
				objectiveBlock.currentLine.Icon:SetAtlas("Objective-Nub", true);			
			end
			-- timer bar
			local line = objectiveBlock.currentLine;
			if ( duration > 0 and elapsed <= duration ) then
				SCENARIO_TRACKER_MODULE:AddTimerBar(objectiveBlock, objectiveBlock.currentLine, duration, GetTime() - elapsed);
			elseif ( line.TimerBar ) then
				SCENARIO_TRACKER_MODULE:FreeTimerBar(objectiveBlock, objectiveBlock.currentLine);
			end
		end
		-- add the objective block
		objectiveBlock:SetHeight(objectiveBlock.height);
		if ( ObjectiveTracker_AddBlock(objectiveBlock) ) then
			if ( not BlocksFrame.slidingAction ) then
				objectiveBlock:Show();
			end
		else
			objectiveBlock:Hide();
			stageBlock:Hide();
		end
	end

	-- add the scenario block
	if ( BlocksFrame.currentBlock ) then
		BlocksFrame.height = BlocksFrame.contentsHeight + 1;
		BlocksFrame:SetHeight(BlocksFrame.contentsHeight + 1);
		ObjectiveTracker_AddBlock(BlocksFrame);
		BlocksFrame:Show();
		if ( OBJECTIVE_TRACKER_UPDATE_REASON == OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE and not inChallengeMode ) then
			if ( ObjectiveTrackerFrame:IsVisible() ) then
				if ( currentStage == 1 ) then
					ScenarioBlocksFrame_SlideIn();
				else
					ScenarioBlocksFrame_SetupStageBlock(scenariocompleted);
					if ( not scenariocompleted ) then
						ScenarioBlocksFrame_SlideOut();
					end
				end
			end
			LevelUpDisplay_PlayScenario();
			-- play sound if not the first stage
			if ( currentStage > 1 and currentStage <= numStages ) then
				PlaySound("UI_Scenario_Stage_End");
			end		
		end	
		-- header
		if ( inChallengeMode ) then
			SCENARIO_CONTENT_TRACKER_MODULE.Header.Text:SetText(scenarioName);
		elseif ( inProvingGrounds or ScenarioProvingGroundsBlock.timerID ) then
			SCENARIO_CONTENT_TRACKER_MODULE.Header.Text:SetText(TRACKER_HEADER_PROVINGGROUNDS);
		elseif( dungeonDisplay ) then
			SCENARIO_CONTENT_TRACKER_MODULE.Header.Text:SetText(TRACKER_HEADER_DUNGEON);
		else
			SCENARIO_CONTENT_TRACKER_MODULE.Header.Text:SetText(TRACKER_HEADER_SCENARIO);
		end		
	else
		ScenarioBlocksFrame_Hide();
	end
end
