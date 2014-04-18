
QUEST_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable();
QUEST_TRACKER_MODULE.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST;
QUEST_TRACKER_MODULE.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_QUEST + OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED;
QUEST_TRACKER_MODULE.usedBlocks = { };
QUEST_TRACKER_MODULE.freeItemButtons = { };
-- because this header is shared, on finishing its anim it has to update all the modules that use it
QUEST_TRACKER_MODULE:SetHeader(ObjectiveTrackerFrame.BlocksFrame.QuestHeader, "Quests", OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED, OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST + OBJECTIVE_TRACKER_UPDATE_MODULE_AUTO_QUEST_POPUP);

function QUEST_TRACKER_MODULE:OnFreeBlock(block)
	local itemButton = block.itemButton;
	if ( itemButton ) then
		tinsert(self.freeItemButtons, itemButton);
		block.itemButton = nil;
		itemButton:Hide();
	end
	block.numShownObjectives = nil;
	block.timerLine	= nil;
end

function QUEST_TRACKER_MODULE:OnReleaseTypedLine(line)
	line.block = nil;
	line.Check:Hide();
	if ( line.activeAnim ) then
		line.activeAnim = nil;
		line.Glow.Anim:Stop();
		line.Sheen.Anim:Stop();
		line.CheckFlash.Anim:Stop();
		line.FadeOutAnim:Stop();
	end	
end

function QUEST_TRACKER_MODULE:SetBlockHeader(block, text, questLogIndex, isQuestComplete)
	block.questLogIndex = questLogIndex;
	-- check if there's an item
	local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex);
	local itemButton = block.itemButton;	
	if ( item and ( not isQuestComplete or showItemWhenComplete ) ) then
		-- if the block doesn't already have an item, get one
		if ( not itemButton ) then
			local numFreeButtons = #QUEST_TRACKER_MODULE.freeItemButtons;
			if ( numFreeButtons > 0 ) then
				itemButton = QUEST_TRACKER_MODULE.freeItemButtons[numFreeButtons];
				tremove(QUEST_TRACKER_MODULE.freeItemButtons, numFreeButtons);
				itemButton:SetParent(block);				
			else
				itemButton = CreateFrame("BUTTON", nil, ObjectiveTrackerFrame.BlocksFrame, "QuestObjectiveItemButtonTemplate");
			end
			block.itemButton = itemButton;
			itemButton:SetPoint("TOPRIGHT", block, -2, 1);
			itemButton:Show();
		end
		itemButton.questLogIndex = questLogIndex;
		itemButton.charges = charges;
		itemButton.rangeTimer = -1;
		SetItemButtonTexture(itemButton, item);
		SetItemButtonCount(itemButton, charges);
		QuestObjectiveItem_UpdateCooldown(itemButton);
		block.lineWidth = OBJECTIVE_TRACKER_TEXT_WIDTH - OBJECTIVE_TRACKER_ITEM_WIDTH;
		block.HeaderText:SetWidth(block.lineWidth);		
	else
		if ( itemButton ) then
			tinsert(QUEST_TRACKER_MODULE.freeItemButtons, itemButton);
			block.itemButton = nil;
			itemButton:Hide();
		end
		block.lineWidth = nil;
		block.HeaderText:SetWidth(OBJECTIVE_TRACKER_TEXT_WIDTH);
	end
	-- set the text
	local height = QUEST_TRACKER_MODULE:SetStringText(block.HeaderText, text, nil, OBJECTIVE_TRACKER_COLOR["Header"]);
	block.height = height;
end

function QUEST_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local questLink = GetQuestLink(block.questLogIndex);
		if ( questLink ) then
			ChatEdit_InsertLink(questLink);
		end
	elseif ( mouseButton ~= "RightButton" ) then
		CloseDropDownMenus();
		if ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
			QuestObjectiveTracker_UntrackQuest(_, block.questLogIndex);
		else
			--[[
			ExpandQuestHeader( GetQuestSortIndex( GetQuestIndexForWatch(self.index) ) );
			 you have to call GetQuestIndexForWatch again because ExpandQuestHeader will sort the indices
			local questIndex = GetQuestIndexForWatch(self.index);
			if (self.isComplete and GetQuestLogIsAutoComplete(questIndex)) then
				--ShowQuestComplete(questIndex);
				--WatchFrameAutoQuest_ClearPopUpByLogIndex(questIndex);
			else
				--QuestLog_OpenToQuest( questIndex );
			end
			]]--
			if ( GetQuestLogIsAutoComplete(block.questLogIndex) ) then
				-- TODO: Handle with ShowQuestComplete
			else
				QuestLog_OpenToQuest(block.questLogIndex);
			end
		end
		return;
	else
		ObjectiveTracker_ToggleDropDown(block, QuestObjectiveTracker_OnOpenDropDown);
	end
end

local LINE_TYPE_ANIM = { template = "QuestObjectiveAnimLineTemplate", freeLines = { } };

-- *****************************************************************************************************
-- ***** ANIMATIONS
-- *****************************************************************************************************

function QuestObjectiveTracker_FinishGlowAnim(line)
	line.activeAnim = "FADEOUT";
	line.FadeOutAnim:Play();
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
end

function QuestObjectiveTracker_FinishFadeOutAnim(line)
	QUEST_TRACKER_MODULE:FreeLine(line.block, line);
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
end

-- *****************************************************************************************************
-- ***** ITEM FUNCTIONS
-- *****************************************************************************************************

function QuestObjectiveItem_OnClick(self, button, down)
end

function QuestObjectiveItem_OnLoad(self)
	self:RegisterForClicks("AnyUp");
end

function QuestObjectiveItem_OnEvent(self, event, ...)
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		self.rangeTimer = -1;
	elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
		QuestObjectiveItem_UpdateCooldown(self);
	end
end

function QuestObjectiveItem_OnUpdate(self, elapsed)
	-- Handle range indicator
	local rangeTimer = self.rangeTimer;
	if ( rangeTimer ) then	
		rangeTimer = rangeTimer - elapsed;		
		if ( rangeTimer <= 0 ) then
			local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(self.questLogIndex);
			if ( not charges or charges ~= self.charges ) then
				ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
				return;
			end
			local count = self.HotKey;
			local valid = IsQuestLogSpecialItemInRange(self.questLogIndex);
			if ( valid == 0 ) then
				count:Show();
				count:SetVertexColor(1.0, 0.1, 0.1);
			elseif ( valid == 1 ) then
				count:Show();
				count:SetVertexColor(0.6, 0.6, 0.6);
			else
				count:Hide();
			end
			rangeTimer = TOOLTIP_UPDATE_TIME;
		end
		
		self.rangeTimer = rangeTimer;
	end
end

function QuestObjectiveItem_OnShow(self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
end

function QuestObjectiveItem_OnHide(self)
	self:UnregisterEvent("PLAYER_TARGET_CHANGED");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
end

function QuestObjectiveItem_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetQuestLogSpecialItem(self.questLogIndex);
end
		
function QuestObjectiveItem_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(self.questLogIndex);
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	else
		UseQuestLogSpecialItem(self.questLogIndex);
	end
end

function QuestObjectiveItem_UpdateCooldown(itemButton)
	local start, duration, enable = GetQuestLogSpecialItemCooldown(itemButton.questLogIndex);
	if ( start ) then
		CooldownFrame_SetTimer(itemButton.Cooldown, start, duration, enable);
		if ( duration > 0 and enable == 0 ) then
			SetItemButtonTextureVertexColor(itemButton, 0.4, 0.4, 0.4);
		else
			SetItemButtonTextureVertexColor(itemButton, 1, 1, 1);
		end
	end
end

-- *****************************************************************************************************
-- ***** BLOCK DROPDOWN FUNCTIONS
-- *****************************************************************************************************

function QuestObjectiveTracker_OnOpenDropDown(self)
	local block = self.activeFrame;
	local questLogIndex = block.questLogIndex;

	local info = UIDropDownMenu_CreateInfo();
	info.text = GetQuestLogTitle(questLogIndex);
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;

	info.text = OBJECTIVES_VIEW_IN_QUESTLOG;
	info.func = QuestObjectiveTracker_OpenQuestDetails;
	info.arg1 = questLogIndex;
	info.noClickSound = 1;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info.text = OBJECTIVES_STOP_TRACKING;
	info.func = QuestObjectiveTracker_UntrackQuest;
	info.arg1 = questLogIndex;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	if ( GetQuestLogPushable(questLogIndex) and IsInGroup() ) then
		info.text = SHARE_QUEST;
		info.func = QuestObjectiveTracker_ShareQuest;
		info.arg1 = questLogIndex;
		info.checked = false;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end

	info.text = OBJECTIVES_SHOW_QUEST_MAP;
	info.func = QuestObjectiveTracker_OpenQuestMap;
	info.arg1 = questLogIndex;
	info.checked = false;
	info.noClickSound = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
end

function QuestObjectiveTracker_OpenQuestDetails(dropDownButton, questLogIndex)
	QuestLog_OpenToQuest(questLogIndex);
end

function QuestObjectiveTracker_UntrackQuest(dropDownButton, questLogIndex)
	RemoveQuestWatch(questLogIndex);
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
end

function QuestObjectiveTracker_OpenQuestMap(dropDownButton, questLogIndex)
	local questID = select(8, GetQuestLogTitle(questLogIndex));
	QuestMapFrame_OpenToQuestDetails(questID);
end

function QuestObjectiveTracker_ShareQuest(dropDownButton, questLogIndex)
	QuestLogPushQuest(questLogIndex);
end

-- *****************************************************************************************************
-- ***** UPDATE FUNCTIONS
-- *****************************************************************************************************

function QuestObjectiveTracker_SelectSuperTrackedQuest()
	local trackedQuestID = GetSuperTrackedQuestID();
	-- if supertracked quest is not in the quest log anymore, stop supertracking it
	if ( trackedQuestID == 0 or GetQuestLogIndexByID(trackedQuestID) == 0 ) then
		-- pick the first tracked quest to supertrack		
		local questIndex = GetQuestIndexForWatch(1);
		if ( questIndex ) then
			local questID = select(8, GetQuestLogTitle(questIndex));
			SetSuperTrackedQuestID(questID);
			QuestPOIUpdateIcons();
		end
	else
		QuestPOI_SelectButtonByQuestID(ObjectiveTrackerFrame.BlocksFrame, trackedQuestID);
		QuestPOIUpdateIcons();
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
	for i = 1, GetNumQuestWatches() do
		local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(i);
		if ( questID ) then
			-- see if we already have a block for this quest
			local block = QUEST_TRACKER_MODULE.usedBlocks[questID];
			if ( block ) then
				if ( isComplete and isComplete < 0 ) then
					isComplete = false;
				elseif ( numObjectives == 0 and playerMoney >= requiredMoney and not startEvent ) then
					isComplete = true;
				end
				local poiButton;			
				if ( hasLocalPOI ) then
					if ( isComplete ) then
						poiButton = QuestPOI_GetButton(ObjectiveTrackerFrame.BlocksFrame, questID, "normal", nil, isStory);
					else
						numPOINumeric = numPOINumeric + 1;
						poiButton = QuestPOI_GetButton(ObjectiveTrackerFrame.BlocksFrame, questID, "numeric", numPOINumeric, isStory);
					end
				elseif ( isComplete ) then
					poiButton = QuestPOI_GetButton(ObjectiveTrackerFrame.BlocksFrame, questID, "remote", nil, isStory);
				end
				if ( poiButton ) then
					poiButton:SetPoint("TOPRIGHT", block.HeaderText, "TOPLEFT", -6, 2);
				end
			end
		end
	end
	QuestObjectiveTracker_SelectSuperTrackedQuest();
	QuestPOI_HideUnusedButtons(ObjectiveTrackerFrame.BlocksFrame);
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
	local inScenario = C_Scenario.IsInScenario();
	local showPOIs = GetCVarBool("questPOI");

	for i = 1, GetNumQuestWatches() do
		local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(i);
		if ( not questID ) then
			break;
		end

		-- check filters
		local showQuest = true;
		if ( inScenario and questType ~= QUEST_TYPE_SCENARIO ) then
			showQuest = false;
		elseif ( isTask ) then
			showQuest = false;
		end

		if ( showQuest ) then
			local block = QUEST_TRACKER_MODULE:GetBlock(questID);
			QUEST_TRACKER_MODULE:SetBlockHeader(block, title, questLogIndex, isComplete);

			-- completion state
			local questFailed = false;
			if ( isComplete and isComplete < 0 ) then
				isComplete = false;
				questFailed = true;
			elseif ( numObjectives == 0 and playerMoney >= requiredMoney and not startEvent ) then
				isComplete = true;
			end

			if ( isComplete ) then
				if ( isAutoComplete ) then
					QUEST_TRACKER_MODULE:AddObjective(block, "QuestComplete", QUEST_WATCH_QUEST_COMPLETE);
					QUEST_TRACKER_MODULE:AddObjective(block, "ClickComplete", QUEST_WATCH_CLICK_TO_COMPLETE);
				else
					QUEST_TRACKER_MODULE:AddObjective(block, "QuestComplete", GetQuestLogCompletionText(questLogIndex), nil, true);
				end
			elseif ( questFailed ) then
				QUEST_TRACKER_MODULE:AddObjective(block, "Failed", FAILED, nil, nil, true, OBJECTIVE_TRACKER_COLOR["Failed"]);
			else
				local numShownObjectives = 0;
				local objectiveCompleting = false;
				for objectiveIndex = 1, numObjectives do
					local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questLogIndex);
					if ( text ) then
						if ( not finished ) then
							if ( not ( objectiveCompleting and block.numShownObjectives and objectiveIndex > block.numShownObjectives ) ) then
								numShownObjectives = numShownObjectives + 1;
								if ( block.numShownObjectives and objectiveIndex > block.numShownObjectives ) then
									QUEST_TRACKER_MODULE:AddObjective(block, objectiveIndex, text, LINE_TYPE_ANIM);
									local line = block.currentLine;
									if ( not line.activeAnim ) then
										line.block = block;
										line.activeAnim = "ADD";
										line.Sheen.Anim:Play();
										line.Glow.Anim:Play();									
									end
								else
									QUEST_TRACKER_MODULE:AddObjective(block, objectiveIndex, text);
								end
							end
						else
							-- this objective is complete, but if we already have a line for it either animate it out or maintain it until it's done animating out
							if ( block.lines[objectiveIndex] ) then
								QUEST_TRACKER_MODULE:AddObjective(block, objectiveIndex, text, LINE_TYPE_ANIM, nil, true, OBJECTIVE_TRACKER_COLOR["Complete"]);
								local line = block.currentLine;
								if ( not line.activeAnim ) then
									line.block = block;
									line.activeAnim = "COMPLETE";
									line.Check:Show();
									line.Sheen.Anim:Play();								
									line.Glow.Anim:Play();
									line.CheckFlash.Anim:Play();
								end
								if ( line.activeAnim == "COMPLETE" ) then
									objectiveCompleting = true;
								end
							end
							numShownObjectives = numShownObjectives + 1;
						end
					end
				end
				block.numShownObjectives = numShownObjectives;
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
				block:Show();
				QUEST_TRACKER_MODULE:FreeUnusedLines(block);
				-- quest POI icon
				if ( showPOIs ) then
					local poiButton;
					if ( hasLocalPOI ) then
						if ( isComplete ) then
							poiButton = QuestPOI_GetButton(ObjectiveTrackerFrame.BlocksFrame, questID, "normal", nil, isStory);
						else
							numPOINumeric = numPOINumeric + 1;
							poiButton = QuestPOI_GetButton(ObjectiveTrackerFrame.BlocksFrame, questID, "numeric", numPOINumeric, isStory);
						end
					elseif ( isComplete ) then
						poiButton = QuestPOI_GetButton(ObjectiveTrackerFrame.BlocksFrame, questID, "remote", nil, isStory);
					end
					if ( poiButton ) then
						poiButton:SetPoint("TOPRIGHT", block.HeaderText, "TOPLEFT", -6, 2);
					end				
				end
			else
				block.used = false;
				break;
			end
		end
	end

	QuestObjectiveTracker_SelectSuperTrackedQuest();
	
	QuestPOI_HideUnusedButtons(ObjectiveTrackerFrame.BlocksFrame);
	QUEST_TRACKER_MODULE:EndLayout();
end