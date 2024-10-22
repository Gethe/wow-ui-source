-- *****************************************************************************************************
-- ***** EMBER COURT TUTORIAL
-- *****************************************************************************************************

local showingEmberCourtHelpTip = false;
	
local function AcknowledgeEmberCourtHelpTip()
	if showingEmberCourtHelpTip then
		HelpTip:Acknowledge(UIParent, EMBER_COURT_MAP_HELPTIP);
		EventRegistry:UnregisterCallback("WorldMapOnShow", ScenarioObjectiveTracker);
	end
end

local emberCourtMapHelpTipInfo = {
	text = EMBER_COURT_MAP_HELPTIP,
	buttonStyle = HelpTip.ButtonStyle.Close,
	cvarBitfield = "closedInfoFrames",
	bitfieldFlag = LE_FRAME_TUTORIAL_EMBER_COURT_MAP,
	targetPoint = HelpTip.Point.BottomEdgeCenter,
	offsetX = 0,
	offsetY = 400,
	hideArrow = true,
	checkCVars = true,
};

local EMBER_COURT_TUTORIAL_WIDGET_SET_ID = 461;

local function CheckEmberCourtHelpTip(widgetSetID)
	if widgetSetID == EMBER_COURT_TUTORIAL_WIDGET_SET_ID then
		if HelpTip:Show(UIParent, emberCourtMapHelpTipInfo) then
			showingEmberCourtHelpTip = true;
			EventRegistry:RegisterCallback("WorldMapOnShow", AcknowledgeEmberCourtHelpTip, ScenarioObjectiveTracker);
		end
	else
		AcknowledgeEmberCourtHelpTip();
	end
end

-- *****************************************************************************************************
-- ***** MAIN
-- *****************************************************************************************************

local settings = {
	hasDisplayPriority = true,
	headerText = TRACKER_HEADER_SCENARIO,
	events = { "SCENARIO_UPDATE", "SCENARIO_CRITERIA_UPDATE", "SCENARIO_SPELL_UPDATE", "PLAYER_ENTERING_WORLD", "SCENARIO_COMPLETED", "SCENARIO_CRITERIA_SHOW_STATE_UPDATE", "UNIT_AURA", "SPELL_UPDATE_COOLDOWN" },
	fromHeaderOffsetY = 0,
	blockOffsetX = 20,
	lineSpacing = 12,
	fromBlockOffsetY = -2,
	lineTemplate = "ObjectiveTrackerAnimLineTemplate",
	progressBarTemplate = "ScenarioProgressBarTemplate",
	-- for this module
	progressBarLineSpacing = 2,
	showCriteria = true,
	slideDuration = 0.4,
	leftMargin = -20,
};

ScenarioObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

function ScenarioObjectiveTrackerMixin:InitModule()
	for i, block in ipairs(self.FixedBlocks) do
		block.parentModule = self;
		block:SetParent(self.ContentsFrame);
	end
	self.ObjectivesBlock:Init();
	self.ObjectivesBlock:Reset();
	
	self.spellFramePool = CreateFramePool("FRAME", self.ObjectivesBlock, "ScenarioSpellFrameTemplate");
	
	self.TopWidgetContainerBlock.WidgetContainer:SetScript("OnSizeChanged", GenerateClosure(self.MarkDirty, self));
	self.BottomWidgetContainerBlock.WidgetContainer:SetScript("OnSizeChanged", GenerateClosure(self.MarkDirty, self));

	self.shouldShowCriteria = C_Scenario.ShouldShowCriteria();

	-- StageBlock.FinalBG is outside the bounds, need to make this module wider so it doesn't get cut off during a slide
	self.Header:SetPoint("TOPLEFT", self, "TOPLEFT", self.blockOffsetX, 0);
	self:SetWidth(self:GetWidth() + self.blockOffsetX);
end

local SCENARIO_TRACKER_WIDGET_SET = 252;
local SCENARIO_TRACKER_TOP_WIDGET_SET = 514;

local function WidgetsLayoutWithOffset(widgetContainerFrame, sortedWidgets, containerOffset)
	local containerBlock = widgetContainerFrame:GetParent(); 
	DefaultWidgetLayout(widgetContainerFrame, sortedWidgets);

	if widgetContainerFrame:HasAnyWidgetsShowing() then
		containerBlock:SetWidth(widgetContainerFrame:GetWidth());
	else
		containerBlock:SetWidth(1);
	end

	ScenarioObjectiveTracker:MarkDirty();
end

function ScenarioObjectiveTrackerMixin:OnEvent(event, ...)
	if event == "UNIT_AURA" then
		local isShowingMawBuffs = self:IsShown() and self.MawBuffsBlock:IsShown();
		if ShouldShowMawBuffs() ~= isShowingMawBuffs then
			self:MarkDirty();
		end
	elseif event == "SPELL_UPDATE_COOLDOWN" then
		self:UpdateSpellCooldowns();
	elseif event == "SCENARIO_UPDATE" then
		local newStage = ...;
		self:SetHasNewStage(newStage);
		self:MarkDirty();		
	elseif event == "SCENARIO_CRITERIA_UPDATE" or event == "SCENARIO_SPELL_UPDATE" then
		self:MarkDirty();
	elseif event == "SCENARIO_CRITERIA_SHOW_STATE_UPDATE" then
    	local shouldShow = ...;
    	self:SetShouldShowCriteria(show);
	elseif event == "SCENARIO_COMPLETED" then
		local rewardQuestID, xp, money = ...;
		if (xp and xp > 0 and not IsPlayerAtEffectiveMaxLevel()) or (money and money > 0) then
			ScenarioRewardsFrame:DisplayRewards(xp, money);
		end		
	elseif event == "PLAYER_ENTERING_WORLD" then
		self.BottomWidgetContainerBlock.WidgetContainer:RegisterForWidgetSet(SCENARIO_TRACKER_WIDGET_SET, WidgetsLayoutWithOffset);
		self.TopWidgetContainerBlock.WidgetContainer:RegisterForWidgetSet(SCENARIO_TRACKER_TOP_WIDGET_SET, WidgetsLayoutWithOffset);	
	end
end

function ScenarioObjectiveTrackerMixin:ShouldShowCriteria()
	return self.shouldShowCriteria;
end

function ScenarioObjectiveTrackerMixin:SetShouldShowCriteria(shouldShow)
	if self.shouldShowCriteria ~= shouldShow then
		self.shouldShowCriteria = shouldShow;
		self:MarkDirty();
	end
end

function ScenarioObjectiveTrackerMixin:CanUpdate()
	-- can always update if empty or not sliding
	if not self.hasContents or not self:IsSliding() then
		return true;
	end
	-- if sliding, can update if the stage changed
	local scenarioName, currentStage = C_Scenario.GetInfo();
	return self.currentStage ~= currentStage;
end

function ScenarioObjectiveTrackerMixin:SetHasNewStage(hasNewStage)
	self.hasNewStage = hasNewStage;
end

-- override
function ScenarioObjectiveTrackerMixin:MarkBlocksUnused()
	for i, block in ipairs(self.FixedBlocks) do
		block.used = false;
	end
	-- these are managed directly, no .used
	self.spellFramePool:ReleaseAll();
end

-- override
function ScenarioObjectiveTrackerMixin:FreeUnusedBlocks()
	for i, block in ipairs(self.FixedBlocks) do
		if not block.used then
			block:Hide();
		end
	end
end

function ScenarioObjectiveTrackerMixin:LayoutContents()
	local hasNewStage = self.hasNewStage;
	self:SetHasNewStage(false);

	local scenarioName, currentStage, numStages, flags, _, _, _, xp, money, scenarioType, _, textureKit, scenarioID = C_Scenario.GetInfo();
	textureKit = textureKit or "evergreen-scenario"

	local isInScenario = numStages > 0;
	local shouldShowMawBuffs = ShouldShowMawBuffs();
	if not isInScenario and (not shouldShowMawBuffs or IsOnGroundFloorInJailersTower()) then
		-- clear out data
		self.currentStage = nil;
		self.scenarioID = nil;
		self.slidOutStage = nil;
		self.StageBlock:ClearWidgetSet();
		AcknowledgeEmberCourtHelpTip();
		return;
	end

	if self:IsSliding() then
		self:EndSlide();
	end
	
	local stageName, stageDescription, numCriteria, _, _, _, _, numSpells, allSpellInfo, weightedProgress, _, widgetSetID = C_Scenario.GetStepInfo();

	local inChallengeMode = (scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE);
	local inProvingGrounds = (scenarioType == LE_SCENARIO_TYPE_PROVING_GROUNDS);
	local dungeonDisplay = (scenarioType == LE_SCENARIO_TYPE_USE_DUNGEON_DISPLAY);
	local inWarfront = (scenarioType == LE_SCENARIO_TYPE_WARFRONT);
	local scenarioCompleted = currentStage > numStages;
	local isCollapsed = self:IsCollapsed() or (self.parentContainer and self.parentContainer:IsCollapsed());

	-- determine sliding state
	local slidingState = ObjectiveTrackerSlidingState.None;
	if hasNewStage and not inChallengeMode then
		if not isCollapsed then
			if currentStage == 1 or currentStage == self.slidOutStage then
				slidingState = ObjectiveTrackerSlidingState.SlideIn;
			else
				if not scenarioCompleted then
					slidingState = ObjectiveTrackerSlidingState.SlideOut;
				end
			end
		end
		-- play sound if not the first stage
		if currentStage > 1 and currentStage <= numStages then
			PlaySound(SOUNDKIT.UI_SCENARIO_STAGE_END);
		end
	end
	
	local stageBlock = self.StageBlock;
	local provingGroundsActive = self.ProvingGroundsBlock:IsActive();

	if not isInScenario then
		-- do nothing
	elseif inChallengeMode then
		if self.ChallengeModeBlock:IsActive() then
			self:LayoutBlock(self.ChallengeModeBlock);
		end
	elseif provingGroundsActive then
		self:LayoutBlock(self.ProvingGroundsBlock);
	else
		self:LayoutBlock(stageBlock);
		if self.currentStage ~= currentStage or self.scenarioID ~= scenarioID then
			self.currentStage = currentStage;
			self.scenarioID = scenarioID;
			stageBlock:UpdateStageBlock(scenarioID, scenarioType, widgetSetID, textureKit, flags, currentStage, stageName, numStages);
		end
		stageBlock:UpdateWidgetRegistration();
	end

	-- header
	if inChallengeMode then
		self.Header.Text:SetText(scenarioName);
	elseif inProvingGrounds or provingGroundsActive then
		self.Header.Text:SetText(TRACKER_HEADER_PROVINGGROUNDS);
	elseif dungeonDisplay then
		self.Header.Text:SetText(TRACKER_HEADER_DUNGEON);
	elseif shouldShowMawBuffs and not IsInJailersTower() then
		self.Header.Text:SetText(GetZoneText());
	else
		self.Header.Text:SetText(scenarioName);
	end	
	
	-- On slide out only need the StageBlock
	if slidingState == ObjectiveTrackerSlidingState.SlideOut then
		stageBlock:SetupStageTransition(hasNewStage, scenarioCompleted);
		self:SlideOutContents();
		return;
	end

	if isInScenario then
		if not provingGroundsActive and not scenarioCompleted then
			-- This is the only place the ObjectivesBlock can be added
			local objectivesBlock = self.ObjectivesBlock;
			-- Reset the block
			objectivesBlock:Reset();
			if weightedProgress then
				self:AddWeightedProgressObjective(stageDescription);
			else
				self:UpdateCriteria(numCriteria);
				self:AddSpells(allSpellInfo);
				if objectivesBlock.height > 0 then
					self:LayoutBlock(objectivesBlock);
				end
			end
		end
		self:LayoutWidgetBlock(self.TopWidgetContainerBlock);
	end

	if shouldShowMawBuffs then
		self:LayoutBlock(self.MawBuffsBlock);
		self.MawBuffsBlock.Container:UpdateAlignment();
	end

	if isInScenario then
		self:LayoutWidgetBlock(self.BottomWidgetContainerBlock);
	end

	if slidingState == ObjectiveTrackerSlidingState.SlideIn and self:IsShown() then
		stageBlock:SetupStageTransition(hasNewStage, scenarioCompleted);
		self:SlideInContents();
	end
end

function ScenarioObjectiveTrackerMixin:LayoutWidgetBlock(block)
	local height = block.WidgetContainer:GetHeight();
	if block.WidgetContainer:GetNumWidgetsShowing() > 0 then
		height = height + (block.padding or 0);
	else
		height = 1;
	end
	block.height = height;
	self:LayoutBlock(block);
end

function ScenarioObjectiveTrackerMixin:SlideInContents()
	self.StageBlock:UpdateWidgetRegistration();
	self.StageBlock.CompleteLabel:Hide();
	self.ObjectivesBlock:SetShown(self:ShouldShowCriteria());

	local slideInfo = {
		travel = self.contentsHeight - self.headerHeight,
		adjustModule = true,
		duration = self.slideDuration,
	};
	self:Slide(slideInfo);	
end

function ScenarioObjectiveTrackerMixin:SetStageBlockModelScenesShown(shown)
	if self.StageBlock.WidgetContainer then
		self.StageBlock.WidgetContainer:SetModelScenesShown(shown);
	end
end

function ScenarioObjectiveTrackerMixin:SlideOutContents()
	self:SetStageBlockModelScenesShown(false);

	local slideInfo = {
		travel = -(self.StageBlock.height),
		adjustModule = true,
		duration = self.slideDuration,
		startDelay = 0.8,
		endDelay = 0.6,
	};
	self:Slide(slideInfo);
end

function ScenarioObjectiveTrackerMixin:OnEndSlide(slideOut, finished)
	-- this label should only ever be visible during a slide, specifically the slide out
	self.StageBlock.CompleteLabel:Hide();

	if not finished then
		return;
	end
	
	if slideOut then
		local name, currentStage, numStages = C_Scenario.GetInfo();
		local hasNewStage = currentStage and currentStage <= numStages;
		self.slidOutStage = currentStage;
		self:SetHasNewStage(hasNewStage);
		-- we need to maintain the visual state at the end of the slideout for 1 frame
		self.StageBlock:Hide();
		self:SetHeight(self.headerHeight);
	else
		self:SetStageBlockModelScenesShown(true);
	end

	self:MarkDirty();
end

function ScenarioObjectiveTrackerMixin:UpdateCriteria(numCriteria)
	if not self:ShouldShowCriteria() then
		return;
	end

	local objectivesBlock = self.ObjectivesBlock;
	for criteriaIndex = 1, numCriteria do
		local criteriaInfo = C_ScenarioInfo.GetCriteriaInfo(criteriaIndex);
		if criteriaInfo then
			local criteriaString = criteriaInfo.description;
			if not criteriaInfo.isWeightedProgress and not criteriaInfo.isFormatted then
				criteriaString = string.format("%d/%d %s", criteriaInfo.quantity, criteriaInfo.totalQuantity, criteriaInfo.description);
			end
			local line;
			if criteriaInfo.completed then
				local existingLine = objectivesBlock:GetExistingLine(criteriaIndex);
				line = objectivesBlock:AddObjective(criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
				line.Icon:Show();
				line.Icon:SetAtlas("ui-questtracker-tracker-check", false);
				if existingLine and (not line.state or line.state == ObjectiveTrackerAnimLineState.Present) then	
					line:SetState(ObjectiveTrackerAnimLineState.Completing);
				end
			else
				line = objectivesBlock:AddObjective(criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_HIDE);
				line.Icon:Show();
				line.Icon:SetAtlas("ui-questtracker-objective-nub", false);
			end

			-- progress bar
			if criteriaInfo.isWeightedProgress and not criteriaInfo.completed then
				objectivesBlock:AddProgressBar(criteriaIndex, self.progressBarLineSpacing);
			end
			
			-- timer
			if criteriaInfo.duration > 0 and criteriaInfo.elapsed <= criteriaInfo.duration then
				objectivesBlock:AddTimerBar(criteriaInfo.duration, GetTime() - criteriaInfo.elapsed);
			end		
		end
	end
end

function ScenarioObjectiveTrackerMixin:AddWeightedProgressObjective(stageDescription)
	if not self:ShouldShowCriteria() then
		return;
	end

	local objectivesBlock = self.ObjectivesBlock;
	local line = objectivesBlock:AddObjective(1, stageDescription);
	line.Icon:Hide();
	objectivesBlock:AddProgressBar(1, self.progressBarLineSpacing);
	self:LayoutBlock(objectivesBlock);
end

function ScenarioObjectiveTrackerMixin:AddSpells(allSpellInfo)
	if not allSpellInfo then
		return;
	end
	
	local objectivesBlock = self.ObjectivesBlock;
	
	for index, spellInfo in ipairs(allSpellInfo) do
		local spellFrame = self.spellFramePool:Acquire();
		spellFrame.SpellName:SetText(spellInfo.spellName);
		spellFrame.SpellButton:SetSpell(spellInfo);
		local offsetX = -5;
		local offsetY = (index == 1 and -5) or 0;
		objectivesBlock:AddCustomRegion(spellFrame, offsetX, offsetY);
	end	
end

function ScenarioObjectiveTrackerMixin:UpdateSpellCooldowns()
	for spellFrame in self.spellFramePool:EnumerateActive() do
		spellFrame.SpellButton:UpdateCooldown();
	end
end

-- *****************************************************************************************************
-- ***** STAGE BLOCK
-- *****************************************************************************************************

ScenarioObjectiveTrackerStageMixin = { };

function ScenarioObjectiveTrackerStageMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("RIGHT", self, "LEFT", 0, 0);
	local _, currentStage, numStages, flags, _, _, _, xp, money = C_Scenario.GetInfo();
	local name, description = C_Scenario.GetStepInfo();
	if name and (bit.band(flags, SCENARIO_FLAG_SUPRESS_STAGE_TEXT) == SCENARIO_FLAG_SUPRESS_STAGE_TEXT) then
		GameTooltip_SetTitle(GameTooltip, name);
		GameTooltip_AddNormalLine(GameTooltip, description);

		local blankLineAdded = false;
		if xp > 0 and not IsPlayerAtEffectiveMaxLevel() then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddNormalLine(GameTooltip, BONUS_OBJECTIVE_EXPERIENCE_FORMAT:format(xp));
			blankLineAdded = true;
		end

		if money > 0 then
			if not blankLineAdded then
				GameTooltip_AddBlankLineToTooltip(GameTooltip);
			end
			SetTooltipMoney(GameTooltip, money, nil);
		end

		GameTooltip:Show();
	elseif currentStage <= numStages then
		GameTooltip_SetTitle(GameTooltip, SCENARIO_STAGE_STATUS:format(currentStage, numStages));
		GameTooltip_AddNormalLine(GameTooltip, name);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddNormalLine(GameTooltip, description);
		GameTooltip:Show();
	end
	EventRegistry:TriggerEvent("Scenario.ObjectTracker_OnEnter", GameTooltip);
end

local textureKitOffsets = {
	["evergreen-scenario"] = {normalBGX = 0, normalBGY = 0, finalBGX = -4, finalBGY = 2},
	["thewarwithin-scenario"] = {normalBGX = 0, normalBGY = 0, finalBGX = 3, finalBGY = -2},
	["delves-scenario"] = {normalBGX = -2, normalBGY = 1, finalBGX = -2, finalBGY = 1},
};

local defaultOffsets = {normalBGX = 0, normalBGY = 0, finalBGX = -10, finalBGY = 3};

function ScenarioObjectiveTrackerStageMixin:GetBGAtlases(scenarioType, textureKit)
	local normalBGAtlas, finalBGAtlas;
	if scenarioType == LE_SCENARIO_TYPE_LEGION_INVASION then
		normalBGAtlas = "legioninvasion-ScenarioTrackerToast";
		finalBGAtlas = nil;
	else
		normalBGAtlas = textureKit.."-trackerheader";
		finalBGAtlas = textureKit.."-trackerheader-final-filigree";

		if not C_Texture.GetAtlasInfo(normalBGAtlas) then
			normalBGAtlas = "evergreen-scenario-trackerheader";
			finalBGAtlas = "evergreen-scenario-trackerheader-final-filigree";
		elseif not C_Texture.GetAtlasInfo(finalBGAtlas) then
			finalBGAtlas = nil;
		end
	end

	return normalBGAtlas, finalBGAtlas;
end

function ScenarioObjectiveTrackerStageMixin:UpdateStageBlock(scenarioID, scenarioType, widgetSetID, textureKit, flags, currentStage, stageName, numStages)
	local normalBGAtlas, finalBGAtlas = self:GetBGAtlases(scenarioType, textureKit);

	if bit.band(flags, SCENARIO_FLAG_SUPRESS_STAGE_TEXT) == SCENARIO_FLAG_SUPRESS_STAGE_TEXT then
		self.Stage:SetText(stageName);
		self.Stage:SetSize(172, 36);
		self.Stage:SetPoint("TOPLEFT", 15, -18);
		self.FinalBG:Hide();
		self.Name:SetText("");
	else
		if currentStage == numStages then
			self.Stage:SetText(SCENARIO_STAGE_FINAL);
			self.FinalBG:SetShown(finalBGAtlas ~= nil);
		else
			self.Stage:SetFormattedText(SCENARIO_STAGE, currentStage);
			self.FinalBG:Hide();
		end
		self.Stage:SetSize(172, 18);
		self.Name:SetText(stageName);
		if self.Name:GetStringWidth() > self.Name:GetWrappedWidth() then
			self.Stage:SetPoint("TOPLEFT", 15, -10);
		else
			self.Stage:SetPoint("TOPLEFT", 15, -18);
		end
	end
	if not self.appliedAlready then
		-- Ugly hack to get around :IsTruncated failing if used during load
		C_Timer.After(1, function() self.Stage:ScaleTextToFit(); end);
		self.appliedAlready = true;
	end

	self.widgetSetID = widgetSetID;
	self.Stage:Show();
	self.NormalBG:Show();

	self.NormalBG:SetAtlas(normalBGAtlas, true);
	if finalBGAtlas then
		self.FinalBG:SetAtlas(finalBGAtlas, true);
	end

	if scenarioType == LE_SCENARIO_TYPE_LEGION_INVASION then
		self.Stage:SetTextColor(0.753, 1, 0);
		self.NormalBG:SetPoint("TOPLEFT", 0, 0);
		self.FinalBG:SetPoint("TOPLEFT", -10, 3);
	else
		self.Stage:SetTextColor(1, 0.914, 0.682);
		local offsets = textureKitOffsets[textureKit] or defaultOffsets;
		self.NormalBG:SetPoint("TOPLEFT", offsets.normalBGX, offsets.normalBGY);
		self.FinalBG:SetPoint("TOPLEFT", offsets.finalBGX, offsets.finalBGY);
	end
	
	self:UpdateFindGroupButton(scenarioID);
end

function ScenarioObjectiveTrackerStageMixin:UpdateFindGroupButton(scenarioID)
	local hasButton = C_LFGList.CanCreateScenarioGroup(scenarioID);
	if hasButton then
		if not self.findGroupButton then
			self.findGroupButton = CreateFrame("BUTTON", nil, self, "ScenarioObjectiveTrackerFindGroupButtonTemplate");
			self.findGroupButton:SetPoint("TOPRIGHT", self, -30, 5);
		end
		self.findGroupButton:SetScenarioID(scenarioID);
		self.findGroupButton:Show();
	else
		if self.findGroupButton then
			self.findGroupButton:Hide();
		end
	end
end

function ScenarioObjectiveTrackerStageMixin:ClearWidgetSet()
	self.widgetSetID = nil;
	self:UpdateWidgetRegistration();
end

function ScenarioObjectiveTrackerStageMixin:UpdateWidgetRegistration()
	local widgetSetID = self.widgetSetID;
	self.WidgetContainer:RegisterForWidgetSet(widgetSetID);
	if widgetSetID then
		self.Name:Hide();
		self.Stage:Hide();
		self.NormalBG:Hide();
	else
		self.Name:Show();
		self.Stage:Show();
		self.NormalBG:Show();		
	end
	
	CheckEmberCourtHelpTip(widgetSetID);
end

function ScenarioObjectiveTrackerStageMixin:SetupStageTransition(hasNewStage, scenarioCompleted)
	if not self.WidgetContainer:IsShown() then
		self.Stage:Hide();
		self.Name:Hide();
		self.CompleteLabel:Show();
		if scenarioCompleted then
			local scenarioType = select(10, C_Scenario.GetInfo());
			local dungeonDisplay = (scenarioType == LE_SCENARIO_TYPE_USE_DUNGEON_DISPLAY);
			if dungeonDisplay then
				self.CompleteLabel:SetText(DUNGEON_COMPLETED);
			else
				self.CompleteLabel:SetText(SCENARIO_COMPLETED_GENERIC);
			end
		else
			self.CompleteLabel:SetText(STAGE_COMPLETE);
		end
	end

	if isNewStage then
		self.GlowTexture.AlphaAnim:Play();
	end
end

-- *****************************************************************************************************
-- ***** TIMER
-- *****************************************************************************************************

ScenarioTimerMixin = { };

function ScenarioTimerMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CHALLENGE_MODE_START");
	self:RegisterEvent("WORLD_STATE_TIMER_START");
	self:RegisterEvent("WORLD_STATE_TIMER_STOP");
end

function ScenarioTimerMixin:OnEvent(event, ...)
	if event == "WORLD_STATE_TIMER_START" then
		local timerID = ...;
		self:CheckTimers(timerID);
	elseif event == "WORLD_STATE_TIMER_STOP" then
		local timerID = ...;
		self:StopTimer(timerID);
	elseif event == "CHALLENGE_MODE_START" or event == "PLAYER_ENTERING_WORLD" then
		self:CheckTimers(GetWorldElapsedTimers());
	end
end

local floor = floor;
function ScenarioTimerMixin:OnUpdate(elapsed)
	self.timeSinceBase = self.timeSinceBase + elapsed;
	self.block:UpdateTime(floor(self.baseTime + self.timeSinceBase));
end

function ScenarioTimerMixin:StartTimer(block)
	local _, elapsedTime = GetWorldElapsedTime(block.timerID);
	self.baseTime = elapsedTime;
	self.timeSinceBase = 0;
	self.block = block;
	self:Show();
end

function ScenarioTimerMixin:StopTimer(timerID)
	if self.block and (not timerID or self.block.timerID == timerID) then
		-- remove the block
		self.block.timerID = nil;
		-- remove the timer
		self:Hide();
		self.baseTime = nil;
		self.timeSinceBase = nil;
		self.block = nil;
		-- update
		ScenarioObjectiveTracker:MarkDirty();
	end
end

function ScenarioTimerMixin:CheckTimers(...)
	-- only supporting 1 active timer
	for i = 1, select("#", ...) do
		local timerID = select(i, ...);
		local _, elapsedTime, type = GetWorldElapsedTime(timerID);
		if type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE then
			local mapID = C_ChallengeMode.GetActiveChallengeMapID();
			if mapID then
				local _, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID);
				ScenarioObjectiveTracker.ChallengeModeBlock:Activate(timerID, elapsedTime, timeLimit);
				return;
			end
		elseif type == LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND then
			local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
			if duration > 0 then
				ScenarioObjectiveTracker.ProvingGroundsBlock:Activate(timerID, elapsedTime, duration, diffID, currWave, maxWave);
				return;
			end
		end
	end
	-- we had an update but didn't find a valid timer, kill the timer if it's running
	self:StopTimer();
end

-- *****************************************************************************************************
-- ***** CHALLENGE MODE BLOCK
-- *****************************************************************************************************

ScenarioObjectiveTrackerChallengeModeMixin = { };

function ScenarioObjectiveTrackerChallengeModeMixin:OnLoad()
	self:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED");
	
	self.StartedDepleted:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.StartedDepleted, "ANCHOR_RIGHT");
		GameTooltip:SetText(CHALLENGE_MODE_DEPLETED_KEYSTONE, 1, 1, 1);
		GameTooltip:AddLine(CHALLENGE_MODE_KEYSTONE_DEPLETED_AT_START, nil, nil, nil, true);
		GameTooltip:Show();
	end);
	
	self.TimesUpLootStatus:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.TimesUpLootStatus, "ANCHOR_RIGHT");
		GameTooltip:SetText(CHALLENGE_MODE_TIMES_UP, 1, 1, 1);
		local line;
		if self.wasDepleted then
			if UnitIsGroupLeader("player") then
				line = CHALLENGE_MODE_TIMES_UP_NO_LOOT_LEADER;
			else
				line = CHALLENGE_MODE_TIMES_UP_NO_LOOT;
			end
		else
			line = CHALLENGE_MODE_TIMES_UP_LOOT;
		end
		GameTooltip:AddLine(line, nil, nil, nil, true);
		GameTooltip:Show();	
	end);
	
	self.DeathCount:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.DeathCount, "ANCHOR_LEFT");
		GameTooltip:SetText(CHALLENGE_MODE_DEATH_COUNT_TITLE:format(self.deathCount), 1, 1, 1);
		GameTooltip:AddLine(CHALLENGE_MODE_DEATH_COUNT_DESCRIPTION:format(SecondsToClock(self.timeLost)));
		GameTooltip:Show();	
	end);
	
	self.affixPool = CreateFramePool("FRAME", self, "ScenarioChallengeModeAffixTemplate");
end

function ScenarioObjectiveTrackerChallengeModeMixin:OnEvent(event)
	if event == "CHALLENGE_MODE_DEATH_COUNT_UPDATED" then
		self:UpdateDeathCount();
	end
end

function ScenarioObjectiveTrackerChallengeModeMixin:UpdateTime(elapsedTime)
	local timeLeft = math.max(0, self.timeLimit - elapsedTime);
	local statusBar = self.StatusBar;
	statusBar:SetValue(timeLeft);
	if timeLeft == 0 then
		self.TimeLeft:SetTextColor(RED_FONT_COLOR:GetRGB());
		self.StartedDepleted:Hide();
		self.TimesUpLootStatus:Show();
		self.TimesUpLootStatus.NoLoot:SetShown(self.wasDepleted);
	else
		self.TimeLeft:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end
	self.TimeLeft:SetText(SecondsToClock(timeLeft));
end

function ScenarioObjectiveTrackerChallengeModeMixin:IsActive()
	return not not self.timerID;
end

function ScenarioObjectiveTrackerChallengeModeMixin:Activate(timerID, elapsedTime, timeLimit)
	self.timerID = timerID;
	self.timeLimit = timeLimit;
	self.lastMedalShown = nil;
	local level, affixes, wasEnergized = C_ChallengeMode.GetActiveKeystoneInfo();
	self.Level:SetText(CHALLENGE_MODE_POWER_LEVEL:format(level));
	if not wasEnergized then
		self.wasDepleted = true;
		self.StartedDepleted:Show();
	else
        self.wasDepleted = false;
        self.StartedDepleted:Hide();
    end
	self.TimesUpLootStatus:Hide();
	self:SetUpAffixes(affixes);
	self:UpdateDeathCount();

	local statusBar = self.StatusBar;
	statusBar:SetMinMaxValues(0, self.timeLimit);
	self:UpdateTime(elapsedTime);
	ScenarioTimerFrame:StartTimer(self);
	ScenarioObjectiveTracker:ForceExpand();
end

function ScenarioObjectiveTrackerChallengeModeMixin:UpdateDeathCount()
	local deathCount = self.DeathCount;
	local count, timeLost = C_ChallengeMode.GetDeathCount();
	self.deathCount = count;
	self.timeLost = timeLost;
	if timeLost and timeLost > 0 and count and count > 0 then
		deathCount:Show();
		deathCount.Count:SetText(count);
	else
		deathCount:Hide();
	end
end

function ScenarioObjectiveTrackerChallengeModeMixin:SetUpAffixes(affixes)
	self.affixPool:ReleaseAll();

	local frameWidth, spacing, distance = 22, 4, -18;
	local prevAffixFrame;
	for i, affixID in ipairs(affixes) do
		local affixFrame = self.affixPool:Acquire();
		if prevAffixFrame then
			affixFrame:SetPoint("LEFT", prevAffixFrame, "RIGHT", spacing, 0);
		else
			local num = #affixes;
			local leftPoint = 28 + (spacing * (num - 1)) + (frameWidth * num);		
			affixFrame:SetPoint("TOPLEFT", self, "TOPRIGHT", -leftPoint, distance);
		end
		affixFrame:SetUp(affixID);
		prevAffixFrame = affixFrame;
	end
end

ScenarioChallengeModeAffixMixin = {};

function ScenarioChallengeModeAffixMixin:SetUp(affixID)
	local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID);
	SetPortraitToTexture(self.Portrait, filedataid);

	self.affixID = affixID;

	self:Show();
end

function ScenarioChallengeModeAffixMixin:OnEnter()
	if (self.affixID) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		local name, description = C_ChallengeMode.GetAffixInfo(self.affixID);

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(name, 1, 1, 1, 1, true);
		GameTooltip:AddLine(description, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

-- *****************************************************************************************************
-- ***** PROVING GROUNDS BLOCK
-- *****************************************************************************************************

ScenarioObjectiveTrackerProvingGroundsMixin = { };

function ScenarioObjectiveTrackerProvingGroundsMixin:OnLoad()
	self:RegisterEvent("PROVING_GROUNDS_SCORE_UPDATE");
	
	self.CountdownAnimFrame.Anim:SetScript("OnFinished", GenerateClosure(self.OnAnimFinished, self));
end

function ScenarioObjectiveTrackerProvingGroundsMixin:OnEvent(event, ...)
	local score = ...
	self.Score:SetText(score);
end

function ScenarioObjectiveTrackerProvingGroundsMixin:IsActive()
	return not not self.timerID;
end

local PROVING_GROUNDS_ENDLESS_INDEX = 4;
function ScenarioObjectiveTrackerProvingGroundsMixin:Activate(timerID, elapsedTime, duration, medalIndex, currWave, maxWave)
	local statusBar = self.StatusBar;

	self.timerID = timerID;
	statusBar.duration = duration;
	statusBar:SetMinMaxValues(0, duration);
	if CHALLENGE_MEDAL_TEXTURES[medalIndex] then
		self.MedalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES[medalIndex]);
		self.MedalIcon:Show();
	end

	if medalIndex < PROVING_GROUNDS_ENDLESS_INDEX then
		self.ScoreLabel:Hide();
		self.Score:Hide();
		self.WaveLabel:SetPoint("TOPLEFT", self.MedalIcon, "TOPRIGHT", 1, -4);
		self.Wave:SetFormattedText(GENERIC_FRACTION_STRING, currWave, maxWave);
		statusBar:SetPoint("TOPLEFT", self.WaveLabel, "BOTTOMLEFT", -2, -6);
	else
		self.ScoreLabel:Show();
		self.Score:Show();
		self.WaveLabel:SetPoint("TOPLEFT", self.MedalIcon, "TOPRIGHT", 1, 4);
		self.Wave:SetText(currWave);
		statusBar:SetPoint("TOPLEFT", self.ScoreLabel, "BOTTOMLEFT", -2, -6);
	end

	self:UpdateTime(elapsedTime);
	ScenarioTimerFrame:StartTimer(self);
	ScenarioObjectiveTracker:ForceExpand();
end

function ScenarioObjectiveTrackerProvingGroundsMixin:UpdateTime(elapsedTime)
	local statusBar = self.StatusBar;
	if elapsedTime < statusBar.duration then
		statusBar:SetValue(statusBar.duration - elapsedTime);
		statusBar.TimeLeft:SetText(SecondsToClock(statusBar.duration - elapsedTime, true));

		local timeLeft = statusBar.duration - elapsedTime;
		if timeLeft <= 5 then
			local anim = self.CountdownAnimFrame.Anim;
			if not anim:IsPlaying() and self.cycles == 0 then
				anim:Play();
				self.cycles = 4;
			end
		else
			self.cycles = 0;
		end
	else
		self.cycles = 0;
	end
end

function ScenarioObjectiveTrackerProvingGroundsMixin:OnAnimFinished()
	if self.cycles > 0 then
		self.CountdownAnimFrame.Anim:Play();
		self.cycles = self.cycles - 1;
	else
		self.cycles = 0;
	end
end

-- *****************************************************************************************************
-- ***** REWARDS FRAME
-- *****************************************************************************************************

ScenarioRewardsFrameMixin = { };

function ScenarioRewardsFrameMixin:OnLoad()
	self:SetScale(0.9);
	self.Anim:SetScript("OnFinished", GenerateClosure(self.OnAnimFinished, self));
end

function ScenarioRewardsFrameMixin:AddReward(label, texture, font)
	local frame = self.framePool:Acquire();
	if self.lastFrame then
		frame:SetPoint("TOPLEFT", self.lastFrame, "BOTTOMLEFT", 0, -4);
	else
		frame:SetPoint("TOPLEFT", self.RewardsTop, "BOTTOMLEFT", 25, 0);
	end
	self.lastFrame = frame;
	
	frame.Count:Hide();
	frame.Label:SetFontObject(font);
	frame.Label:SetText(label);
	frame.ItemIcon:SetTexture(texture);
	frame:Show();
	if frame.Anim:IsPlaying() then
		frame.Anim:Stop();
	end
	frame.Anim:Play();	
end

function ScenarioRewardsFrameMixin:DisplayRewards(xp, money)
	if not self.framePool then
		self.framePool = CreateFramePool("FRAME", self, "ObjectiveTrackerRewardFrameTemplate");
	end
	
	self.framePool:ReleaseAll();
	self.lastFrame = nil;

	if xp > 0 and not IsPlayerAtEffectiveMaxLevel() then
		self:AddReward(xp, "Interface\\Icons\\XP_Icon", "NumberFontNormal");
	end	
	if money > 0 then
		self:AddReward(GetMoneyString(money), "Interface\\Icons\\inv_misc_coin_01", "GameFontHighlight");
	end

	self:Show();
	local numRewards = self.framePool:GetNumActive();
	local contentsHeight = 12 + numRewards * 36;
	self.Anim.RewardsBottomAnim:SetOffset(0, -contentsHeight);
	self.Anim.RewardsShadowAnim:SetScaleTo(0.8, contentsHeight / 16);
	self.Anim:Play();
end

function ScenarioRewardsFrameMixin:OnAnimFinished()
	self:Hide();
end

-- *****************************************************************************************************
-- ***** PROGRESS BARS
-- *****************************************************************************************************

ScenarioTrackerProgressBarMixin = { };

function ScenarioTrackerProgressBarMixin:OnGet(isNew, criteriaIndex)
	self.Bar.Icon:Hide();
	self.Bar.IconBG:Hide();
	self.Bar.BarGlow:SetAtlas("bonusobjectives-bar-glow", true);

	if isNew then
		self.Bar.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
	end

	if not criteriaIndex then
		local rewardQuestID = select(11, C_Scenario.GetStepInfo());
		if rewardQuestID ~= 0 then
			-- reward icon; try the first item
			local _, texture = GetQuestLogRewardInfo(1, rewardQuestID);
			-- artifact xp
			local artifactXP, artifactCategory = GetQuestLogRewardArtifactXP(rewardQuestID);
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
			if not texture and GetQuestLogRewardMoney(rewardQuestID) > 0 then
				texture = "Interface\\Icons\\inv_misc_coin_02";
			end
			-- xp
			if not texture and GetQuestLogRewardXP(rewardQuestID) > 0 and not IsPlayerAtEffectiveMaxLevel() then
				texture = "Interface\\Icons\\xp_icon";
			end
			if texture then
				self.Bar.Icon:SetTexture(texture);
				self.Bar.Icon:Show();
				self.Bar.IconBG:Show();
				self.Bar.BarGlow:SetAtlas("bonusobjectives-bar-glow-ring", true);
			end
		end
	end
	
	-- percentage, value 0 - 100
	local percentage;
	if criteriaIndex then
		local criteriaInfo = C_ScenarioInfo.GetCriteriaInfo(criteriaIndex);
		percentage = criteriaInfo and criteriaInfo.quantity or 0;
	else
		percentage = select(10, C_Scenario.GetStepInfo()) or 0;
	end

	local oldPercentage = self.percentage;
	self:SetValue(percentage);
	if not isNew and percentage > oldPercentage then
		self:PlayFlareAnim(oldPercentage);
	end
end

function ScenarioTrackerProgressBarMixin:SetValue(percentage)
	self.Bar:SetValue(percentage);
	self.Bar.Label:SetFormattedText(PERCENTAGE_STRING, percentage);
	self.percentage = percentage;
end

function ScenarioTrackerProgressBarMixin:PlayFlareAnim(oldPercentage)
	local delta = self.percentage - oldPercentage;
	if delta <= 1 then
		return;
	end
	
	local width = self.Bar:GetWidth();
	local offset = width * (oldPercentage/ 100) - 12;
	
	local flare1, flare2;
	if delta < 10 then
		flare1 = self.SmallFlare1;
		flare2 = self.SmallFlare2;
	else
		flare1 = self.Flare1;
		flare2 = self.Flare2;
	end

	if flare1.FlareAnim:IsPlaying() then
		if not flare2.FlareAnim:IsPlaying() then
			flare2:SetPoint("LEFT", self.Bar, "LEFT", offset, 0);
			flare2.FlareAnim:Play();
		end
	end

	local barFlare = self.FullBarFlare1;
	if barFlare.FlareAnim:IsPlaying() then
		barFlare = self.FullBarFlare2;
		if barFlare.FlareAnim:IsPlaying() then
			return;
		end
	end

	barFlare.FlareAnim:Play();
end

-- *****************************************************************************************************
-- ***** SPELLS
-- *****************************************************************************************************

ScenarioSpellButtonMixin = { };

function ScenarioSpellButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetSpellByID(self.spellID);
end

function ScenarioSpellButtonMixin:OnClick()
	CastSpellByID(self.spellID);
end

function ScenarioSpellButtonMixin:SetSpell(spellInfo)
	self.spellID = spellInfo.spellID;
	self.Icon:SetTexture(spellInfo.spellIcon);
	self:UpdateCooldown();
end
		
function ScenarioSpellButtonMixin:UpdateCooldown()
	local cooldownInfo = C_Spell.GetSpellCooldown(self.spellID);
	if cooldownInfo then
		CooldownFrame_Set(self.Cooldown, cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.isEnabled);
		if cooldownInfo.duration > 0 and not cooldownInfo.isEnabled then
			self.Icon:SetVertexColor(0.4, 0.4, 0.4);
		else
			self.Icon:SetVertexColor(1, 1, 1);
		end
	end
end

-- *****************************************************************************************************
-- ***** LFG EYE
-- *****************************************************************************************************

ScenarioObjectiveTrackerFindGroupButtonMixin = { };

function ScenarioObjectiveTrackerFindGroupButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self.Icon:SetPoint("CENTER", self, "CENTER", -2, -1);
		self.Highlight:SetPoint("CENTER", self, "CENTER", -2, -1);
	end
end

function ScenarioObjectiveTrackerFindGroupButtonMixin:OnMouseUp()
	if self:IsEnabled() then
		self.Icon:SetPoint("CENTER", self, "CENTER", -1, 0);
		self.Highlight:SetPoint("CENTER", self, "CENTER", -1, 0);
	end
end

function ScenarioObjectiveTrackerFindGroupButtonMixin:OnEnter()
	GameTooltip:SetOwner(self);
	GameTooltip_AddHighlightLine(GameTooltip, TOOLTIP_TRACKER_FIND_GROUP_BUTTON);

	GameTooltip:Show();
end

function ScenarioObjectiveTrackerFindGroupButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function ScenarioObjectiveTrackerFindGroupButtonMixin:OnClick()
	local shouldShowCreateGroupButton = true;
	LFGListUtil_FindScenarioGroup(self.scenarioID, shouldShowCreateGroupButton);
end

function ScenarioObjectiveTrackerFindGroupButtonMixin:SetScenarioID(scenarioID)
	self.scenarioID = scenarioID;
end
