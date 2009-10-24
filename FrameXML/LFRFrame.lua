--Extra lines added because looking upward was too much work.







LFR_MAX_SHOWN_LEVEL_DIFF = 15;

NUM_LFR_CHOICE_BUTTONS = 14;

function LFR_CanQueueForLockedInstances()
	return GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0;
end

function LFRQueueFrame_SetRoles()
	local leader, tank, healer, damage = GetLFGRoles();
	
	SetLFGRoles(leader, 
		LFRQueueFrameRoleButtonTank.checkButton:GetChecked(),
		LFRQueueFrameRoleButtonHealer.checkButton:GetChecked(),
		LFRQueueFrameRoleButtonDPS.checkButton:GetChecked());
end

function LFRFrameRoleCheckButton_OnClick(self)
	LFRQueueFrame_SetRoles();
end

function LFRQueueFrameDungeonChoiceEnableButton_OnClick(self, button)
	local parent = self:GetParent();
	local dungeonID = parent.id;
	local isChecked = self:GetChecked();
	
	if ( LFGIsIDHeader(dungeonID) ) then
		LFRList_SetHeaderEnabled(dungeonID, isChecked);
	else
		LFRList_SetRaidEnabled(dungeonID, isChecked);
		LFGListUpdateHeaderEnabledAndLockedStates(LFRRaidList, LFGEnabledList, LFGLockList, LFRHiddenByCollapseList);
	end
	LFRQueueFrameSpecificList_Update();
end

function LFRQueueFrameExpandOrCollapseButton_OnClick(self, button)
	local parent = self:GetParent();
	LFRList_SetHeaderCollapsed(parent.id, not parent.isCollapsed);
end

function LFRList_SetRaidEnabled(dungeonID, isEnabled)
	local typeID = LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.typeID];
	LFGEnabledList[dungeonID] = isEnabled;
end

function LFRList_SetHeaderEnabled(headerID, isEnabled)
	for _, dungeonID in pairs(LFRRaidList) do
		if ( LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.groupID] == headerID ) then
			LFRList_SetRaidEnabled(dungeonID, isEnabled);
		end
	end
	for _, dungeonID in pairs(LFRHiddenByCollapseList) do
		if ( LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.groupID] == headerID ) then
			LFRList_SetRaidEnabled(dungeonID, isEnabled);
		end
	end
	LFGEnabledList[headerID] = isEnabled;
end


function LFRList_SetHeaderCollapsed(headerID, isCollapsed)
	SetLFGHeaderCollapsed(headerID, isCollapsed);
	LFGCollapseList[headerID] = isCollapsed;
	for _, dungeonID in pairs(LFRRaidList) do
		if ( LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.groupID] == headerID ) then
			LFGCollapseList[dungeonID] = isCollapsed;
		end
	end
	for _, dungeonID in pairs(LFRHiddenByCollapseList) do
		if ( LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.groupID] == headerID ) then
			LFGCollapseList[dungeonID] = isCollapsed;
		end
	end
	LFRQueueFrame_Update();
end

--List functions
function LFRQueueFrameSpecificListButton_SetDungeon(button, dungeonID, mode, submode)
	local info = LFGGetDungeonInfoByID(dungeonID);
	button.id = dungeonID;
	if ( LFGIsIDHeader(dungeonID) ) then
		local name = info[LFG_RETURN_VALUES.name];
		
		button.instanceName:SetText(name);
		button.instanceName:SetFontObject(QuestDifficulty_Header);
		button.instanceName:SetPoint("RIGHT", button, "RIGHT", 0, 0);
		button.level:Hide();
		
		if ( info[LFG_RETURN_VALUES.typeID] == TYPEID_HEROIC_DIFFICULTY ) then
			button.heroicIcon:Show();
			button.instanceName:SetPoint("LEFT", button.heroicIcon, "RIGHT", 0, 0);
		else
			button.heroicIcon:Hide();
			button.instanceName:SetPoint("LEFT", 40, 0);
		end
			
		button.expandOrCollapseButton:Show();
		local isCollapsed = LFGCollapseList[dungeonID];
		button.isCollapsed = isCollapsed;
		if ( isCollapsed ) then
			button.expandOrCollapseButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
		else
			button.expandOrCollapseButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
		end
	else
		local name, minRecLevel, maxRecLevel = info[LFG_RETURN_VALUES.name], info[LFG_RETURN_VALUES.minRecLevel], info[LFG_RETURN_VALUES.maxRecLevel];
		
		button.instanceName:SetText(name);
		button.instanceName:SetPoint("RIGHT", button.level, "LEFT", -10, 0);
		
		button.heroicIcon:Hide();
		button.instanceName:SetPoint("LEFT", 40, 0);
			
		if ( minRecLevel == maxRecLevel ) then
			button.level:SetText(format(LFD_LEVEL_FORMAT_SINGLE, minRecLevel));
		else
			button.level:SetText(format(LFD_LEVEL_FORMAT_RANGE, minRecLevel, maxRecLevel));
		end
		button.level:Show();
		
		if ( mode == "rolecheck" or mode == "queued" or not LFG_IsEmpowered()) then
			button.instanceName:SetFontObject(QuestDifficulty_Header);
			button.level:SetFontObject(QuestDifficulty_Header);
		else
			local difficultyColor = GetQuestDifficultyColor((minRecLevel + maxRecLevel)/2)
			button.instanceName:SetFontObject(difficultyColor.font);
			button.level:SetFontObject(difficultyColor.font);
		end
		
		
		button.expandOrCollapseButton:Hide();
		
		button.isCollapsed = false;
	end
	
	if ( not LFR_CanQueueForLockedInstances() and LFGLockList[dungeonID] ) then
		button.enableButton:Hide();
		button.lockedIndicator:Show();
	else
		button.enableButton:Show();
		button.lockedIndicator:Hide();
	end
	
	if ( mode == "queued" ) then
		button.enableButton:SetChecked(LFGQueuedForList[dungeonID]);
	else
		button.enableButton:SetChecked(LFGEnabledList[dungeonID]);
	end
	
	if ( mode == "rolecheck" or mode == "queued" or not LFG_IsEmpowered() ) then
		button.enableButton:Disable();
	else
		button.enableButton:Enable();
	end
end


function LFRQueueFrameSpecificList_Update()
	if ( LFGDungeonList_Setup() ) then
		return;	--Setup will update the list.
	end
	FauxScrollFrame_Update(LFRQueueFrameSpecificListScrollFrame, LFRGetNumDungeons(), NUM_LFR_CHOICE_BUTTONS, 16);
	
	local offset = FauxScrollFrame_GetOffset(LFRQueueFrameSpecificListScrollFrame);
	
	local areButtonsBig = not LFRQueueFrameSpecificListScrollFrame:IsShown();
	
	local mode, subMode = GetLFDMode();
	
	for i = 1, NUM_LFR_CHOICE_BUTTONS do
		local button = _G["LFRQueueFrameSpecificListButton"..i];
		local dungeonID = LFRRaidList[i+offset];
		if ( dungeonID ) then
			button:Show();
			if ( areButtonsBig ) then
				button:SetWidth(315);
			else
				button:SetWidth(295);
			end
			LFRQueueFrameSpecificListButton_SetDungeon(button, dungeonID, mode, subMode);
		else
			button:Hide();
		end
	end
end

function LFRQueueFrameComment_OnUpdate(self, elapsed)
	ScrollingEdit_OnUpdate(self, elapsed, self:GetParent());
	if ( self.setTime ) then
		self.setTime = self.setTime - elapsed;
		if ( self.setTime < 0 ) then
			self.setTime = nil;
			SetLFGComment(self:GetText());
		end
	end
end

function LFRQueueFrame_QueueForInstanceIfEnabled(queueID)
	if ( not LFGIsIDHeader(queueID) and LFGEnabledList[queueID] and (LFR_CanQueueForLockedInstances() or not LFGLockList[queueID]) ) then
		local info = LFGGetDungeonInfoByID(queueID);
		SetLFGDungeon(info[LFG_RETURN_VALUES.typeID], queueID);
		return true;
	end
	return false;
end

function LFRQueueFrame_Join()
	ClearAllLFGDungeons();
	for _, queueID in pairs(LFRRaidList) do
		LFRQueueFrame_QueueForInstanceIfEnabled(queueID);
	end
	for _, queueID in pairs(LFRHiddenByCollapseList) do
		LFRQueueFrame_QueueForInstanceIfEnabled(queueID);
	end
	JoinLFG();
end

LFRHiddenByCollapseList = {};
function LFRQueueFrame_Update()	
	local enableList;
	
	if ( LFG_IsEmpowered() and not queued) then
		enableList = LFGEnabledList;
	else
		enableList = LFGQueuedForList;
	end
	
	LFRRaidList = GetLFRChoiceOrder(LFRRaidList);
		
	LFGQueueFrame_UpdateLFGDungeonList(LFRRaidList, LFRHiddenByCollapseList, LFGLockList, LFGDungeonInfo, enableList, LFGCollapseList, LFR_CURRENT_FILTER);
	
	LFRQueueFrameSpecificList_Update();
end

function LFRList_DefaultFilterFunction(dungeonID)
	local info = LFGGetDungeonInfoByID(dungeonID)
	local hasHeader = info[LFG_RETURN_VALUES.groupID] ~= 0;
	local sufficientExpansion = EXPANSION_LEVEL >= info[LFG_RETURN_VALUES.expansionLevel];
	local level = UnitLevel("player");
	local sufficientLevel = level >= info[LFG_RETURN_VALUES.minLevel] and level <= info[LFG_RETURN_VALUES.maxLevel];
	return (hasHeader and sufficientExpansion and sufficientLevel) and
		( level - LFR_MAX_SHOWN_LEVEL_DIFF <= info[LFG_RETURN_VALUES.maxRecLevel] or (LFGLockList and not LFGLockList[dungeonID]));	--If the server tells us we can join, who are we to complain?
end

LFR_CURRENT_FILTER = LFRList_DefaultFilterFunction;
