SCENARIO_MAX_SHOWN_LEVEL_DIFF = 5;
NUM_SCENARIO_CHOICE_BUTTONS = 19;
SCENARIOS_CURRENT_FILTER = LFGList_DefaultFilterFunction;

function ScenarioFinderFrame_OnLoad(self)
	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO");
end

function ScenarioFinderFrame_OnEvent(self, event, ...)
	if ( event == "LFG_UPDATE_RANDOM_INFO" ) then
		local queueFrame = ScenarioQueueFrame;
		if ( not queueFrame.type or (type(queueFrame.type) == "number" and not IsLFGDungeonJoinable(queueFrame.type)) ) then
			local bestChoice = GetRandomScenarioBestChoice();
			if ( bestChoice ) then
				ScenarioQueueFrame_SetType(bestChoice);
			end
		end
		--If we still don't have a value, we should go to specific.
		if ( not queueFrame.type ) then
			ScenarioQueueFrame_SetType("specific");
		end
		ScenarioFinderFrame_UpdateAvailability();
	end
end

function ScenarioFinderFrame_OnShow(self)
	LFGBackfillCover_Update(ScenarioQueueFrame.PartyBackfill, true);
	ScenarioFinderFrame_UpdateAvailability();
end

local allScenarios = GetScenariosChoiceOrder();
function ScenarioFinderFrame_UpdateAvailability()
	local available = false;
	local nextLevel = nil;
	local level = UnitLevel("player");

	--We have to look through both random scenarios and specific scenarios.
	for i=1, GetNumRandomScenarios() do
		local id, name, typeID, subtype, minLevel, maxLevel = GetRandomScenarioInfo(i);
		if ( level >= minLevel and level <= maxLevel ) then
			available = true;
			nextLevel = nil;
			break;
		elseif ( level < minLevel and (not nextLevel or minLevel < nextLevel ) ) then
			nextLevel = minLevel;
		end
	end
	if ( not available ) then
		for i=1, #allScenarios do
			local id = allScenarios[i];
			if ( id > 0 ) then
				local name, typeID, subtype, minLevel, maxLevel = GetLFGDungeonInfo(id);
				if ( level >= minLevel and level <= maxLevel ) then
					available = true;
					nextLevel = nil;
					break;
				elseif ( level < minLevel and (not nextLevel or minLevel < nextLevel ) ) then
					nextLevel = minLevel;
				end
			end
		end
	end
	if ( available ) then
		ScenarioFinderFrame.NoScenariosCover:Hide();
	else
		ScenarioFinderFrame.NoScenariosCover:Show();
		if ( nextLevel ) then
			ScenarioFinderFrame.NoScenariosCover.Label:SetFormattedText(NO_SCENARIO_AVAILABLE_WITH_NEXT_LEVEL, nextLevel);
		else
			ScenarioFinderFrame.NoScenariosCover.Label:SetText(NO_SCENARIO_AVAILABLE); 
		end
	end
end

-- Specific
ScenariosHiddenByCollapseList = { };
function ScenarioQueueFrame_Update()
	local mode, submode = GetLFGMode(LE_LFG_CATEGORY_SCENARIO);

	local checkedList;
	if ( LFD_IsEmpowered() and mode ~= "queued" and mode ~= "suspended") then
		checkedList = LFGEnabledList;
	else
		checkedList = LFGQueuedForList[LE_LFG_CATEGORY_SCENARIO];
	end

	ScenariosList = GetScenariosChoiceOrder(ScenariosList);

	LFGQueueFrame_UpdateLFGDungeonList(ScenariosList, ScenariosHiddenByCollapseList, checkedList, SCENARIOS_CURRENT_FILTER, SCENARIO_MAX_SHOWN_LEVEL_DIFF);

	ScenarioQueueFrameSpecific_Update();
end

function ScenarioQueueFrameSpecific_Update()
	if ( LFGDungeonList_Setup() ) then
		return;	--Setup will update the list.
	end
	local scrollFrame = ScenarioQueueFrame.Specific.ScrollFrame;
	FauxScrollFrame_Update(scrollFrame, ScenariosGetNumDungeons(), NUM_SCENARIO_CHOICE_BUTTONS, 16);

	local offset = FauxScrollFrame_GetOffset(scrollFrame);

	local areButtonsBig = not scrollFrame:IsShown();

	local enabled, queued = LFGDungeonList_EvaluateListState(LE_LFG_CATEGORY_SCENARIO);
	
	local checkedList;
	if ( queued ) then
		checkedList = LFGQueuedForList[LE_LFG_CATEGORY_SCENARIO];
	else
		checkedList = LFGEnabledList;
	end

	local buttonsFrame = ScenarioQueueFrame.Specific;
	for i = 1, NUM_SCENARIO_CHOICE_BUTTONS do
		local button = buttonsFrame["Button"..i];
		local dungeonID = ScenariosList[i+offset];
		if ( dungeonID ) then
			if ( not button ) then
				button = CreateFrame("FRAME", buttonsFrame:GetName().."Button"..i, buttonsFrame, "ScenarioSpecificChoiceTemplate");
				button:SetPoint("TOPLEFT", buttonsFrame["Button"..(i - 1)], "BOTTOMLEFT");
				buttonsFrame["Button"..i] = button;
			end
			button:Show();
			if ( areButtonsBig ) then
				button:SetWidth(315);
			else
				button:SetWidth(295);
			end
			LFGDungeonListButton_SetDungeon(button, dungeonID, enabled, checkedList);
		elseif ( button ) then
			button:Hide();
		end
	end
end

-- Random
function ScenarioQueueFrameRandom_UpdateFrame()
	local dungeonID = ScenarioQueueFrame.type;

	if ( type(dungeonID) ~= "number" ) then	--We haven't gotten info on available dungeons yet.
		return;
	end
	LFGRewardsFrame_UpdateFrame(ScenarioQueueFrame.Random.ScrollFrame.Child, dungeonID, nil);
end

function ScenarioQueueFrameRandomRandomList_OnEnter(self)
	local randomID = ScenarioQueueFrame.type;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(INCLUDED_SCENARIOS, 1, 1, 1);

	local numDungeons = GetNumDungeonForRandomSlot(randomID);

	if ( numDungeons == 0 ) then
		GameTooltip:AddLine(INCLUDED_SCENARIOS_EMPTY, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	else
		GameTooltip:AddLine(INCLUDED_SCENARIOS_SUBTEXT, nil, nil, nil, true);
		GameTooltip:AddLine(" ");
		for i=1, numDungeons do
			local dungeonID = GetDungeonForRandomSlot(randomID, i);
			local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday = GetLFGDungeonInfo(dungeonID);
			local rangeText;
			if ( minLevel == maxLevel ) then
				rangeText = format(LFD_LEVEL_FORMAT_SINGLE, minLevel);
			else
				rangeText = format(LFD_LEVEL_FORMAT_RANGE, minLevel, maxLevel);
			end
			local difficultyColor = GetQuestDifficultyColor(recLevel);
			
			local displayName = name;
			if ( LFGLockList[dungeonID] ) then
				displayName = "|TInterface\\LFGFrame\\UI-LFG-ICON-LOCK:14:14:0:0:32:32:0:28:0:28|t"..displayName;
			end
			GameTooltip:AddDoubleLine(displayName, rangeText, difficultyColor.r, difficultyColor.g, difficultyColor.b, difficultyColor.r, difficultyColor.g, difficultyColor.b);
		end
	end

	GameTooltip:Show();
end

-- Join button
function ScenarioQueueFrame_Join()
	LFG_JoinDungeon(LE_LFG_CATEGORY_SCENARIO, ScenarioQueueFrame.type, ScenariosList, ScenariosHiddenByCollapseList);
end

function ScenarioQueueFrameFindGroupButton_Update()
	local mode, subMode = GetLFGMode(LE_LFG_CATEGORY_SCENARIO);
	if ( mode == "queued" or mode == "rolecheck" or mode == "proposal" or mode == "suspended" ) then
		ScenarioQueueFrameFindGroupButton:SetText(LEAVE_QUEUE);
	else
		if ( IsInGroup() and GetNumGroupMembers() > 1 ) then
			ScenarioQueueFrameFindGroupButton:SetText(JOIN_AS_PARTY);
		else
			ScenarioQueueFrameFindGroupButton:SetText(FIND_A_GROUP);
		end
	end

	if ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "listed"  ) then --During the proposal, they must use the proposal buttons to leave the queue.
		if ( (mode == "queued" or mode == "rolecheck" or mode == "suspended")	--The players can dequeue even if one of the two cover panels is up.
			or (not ScenarioQueueFramePartyBackfill:IsVisible() and not ScenarioQueueFrameCooldownFrame:IsVisible()) ) then
			ScenarioQueueFrameFindGroupButton:Enable();
		else
			ScenarioQueueFrameFindGroupButton:Disable();
		end
	else
		ScenarioQueueFrameFindGroupButton:Disable();
	end

	if ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "queued" and mode ~= "suspended" and mode ~= "rolecheck" ) then
		ScenarioQueueFramePartyBackfillBackfillButton:Enable();
	else
		ScenarioQueueFramePartyBackfillBackfillButton:Disable();
	end
end

-- List buttons
function ScenarioQueueFrameChoiceEnableButton_OnClick(self)
	LFGDungeonListCheckButton_OnClick(self, LE_LFG_CATEGORY_SCENARIO, ScenariosList, ScenariosHiddenByCollapseList);
	ScenarioQueueFrameSpecific_Update();
end

function ScenarioQueueFrameExpandOrCollapseButton_OnClick(self)
	LFGDungeonList_SetHeaderCollapsed(self:GetParent(), ScenariosList, ScenariosHiddenByCollapseList)
	ScenarioQueueFrame_Update();
end

function ScenarioQueueFrameChoiceButton_OnEnter(self)
	LFGDungeonListButton_OnEnter(self, YOU_MAY_NOT_QUEUE_FOR_SCENARIO);
end

-- Dropdown
function ScenarioQueueFrameTypeDropDown_SetUp(self)
	UIDropDownMenu_SetWidth(self, 180);
	UIDropDownMenu_Initialize(self, ScenarioQueueFrameTypeDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(ScenarioQueueFrame.Dropdown, ScenarioQueueFrame.type);
end

function ScenarioQueueFrameTypeDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = SPECIFIC_SCENARIOS;
	info.value = "specific";
	info.func = ScenarioQueueFrameTypeDropDown_OnClick;
	info.checked = ScenarioQueueFrame.type == info.value;
	UIDropDownMenu_AddButton(info);

	for i=1, GetNumRandomScenarios() do
		local id, name = GetRandomScenarioInfo(i);
		if ( LFG_IsRandomDungeonDisplayable(id) ) then
			local isAvailable = IsLFGDungeonJoinable(id);
			if ( isAvailable ) then
				info.text = name;
				info.value = id;
				info.isTitle = nil;
				info.func = ScenarioQueueFrameTypeDropDown_OnClick;
				info.disabled = nil;
				info.checked = (ScenarioQueueFrame.type == info.value);
				info.tooltipWhileDisabled = nil;
				info.tooltipOnButton = nil;
				info.tooltipTitle = nil;
				info.tooltipText = nil;
				UIDropDownMenu_AddButton(info);
			else
				info.text = name;
				info.value = id;
				info.isTitle = nil;
				info.func = nil;
				info.disabled = 1;
				info.checked = nil;
				info.tooltipWhileDisabled = 1;
				info.tooltipOnButton = 1;
				info.tooltipTitle = YOU_MAY_NOT_QUEUE_FOR_THIS;
				info.tooltipText = LFGConstructDeclinedMessage(id);
				UIDropDownMenu_AddButton(info);
			end
		end
	end
end

function ScenarioQueueFrameTypeDropDown_OnClick(self)
	ScenarioQueueFrame_SetType(self.value);
end

function ScenarioQueueFrame_SetType(value)	--"specific" for the list or the record id for a single dungeon
	ScenarioQueueFrame.type = value;
	UIDropDownMenu_SetSelectedValue(ScenarioQueueFrame.Dropdown, value);
	
	if ( value == "specific" ) then
		ScenarioQueueFrame_SetTypeSpecific();
	else
		ScenarioQueueFrame_SetTypeRandom();
		ScenarioQueueFrameRandom_UpdateFrame();
	end
end

function ScenarioQueueFrame_SetTypeRandom()
	local queueFrame = ScenarioQueueFrame;
	queueFrame.Bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SCENARIO-Random");
	queueFrame.Bg:SetHeight(512);
	queueFrame.Specific:Hide();
	queueFrame.Random:Show();
	LFGCooldownCover_ChangeSettings(ScenarioQueueFrame.CooldownFrame, true, true);
end

function ScenarioQueueFrame_SetTypeSpecific()
	local queueFrame = ScenarioQueueFrame;
	queueFrame.Bg:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-DUNGEONWALL");
	queueFrame.Bg:SetHeight(326);
	queueFrame.Random:Hide();
	queueFrame.Specific:Show();
	LFGCooldownCover_ChangeSettings(ScenarioQueueFrame.CooldownFrame, true, false);
end
