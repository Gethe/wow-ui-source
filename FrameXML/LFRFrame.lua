--Extra lines added because looking upward was too much work.







LFR_MAX_SHOWN_LEVEL_DIFF = 15;

NUM_LFR_CHOICE_BUTTONS = 14;

NUM_LFR_LIST_BUTTONS = 19;

LFR_BROWSE_AUTO_REFRESH_TIME = 20;

local heroicIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-HEROIC:16:13:-5:-3:32:32:0:16:0:20|t";

function LFRFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_LFG_LIST");
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	
	PanelTemplates_SetNumTabs(self, 2);
	LFRFrame_SetActiveTab(1);
	
	self.lastInGroup = GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0;
end

function LFRFrame_OnEvent(self, event, ...)
	if ( event == "UPDATE_LFG_LIST" ) then
		if ( LFRBrowseFrame:IsVisible() ) then
			LFRBrowseFrameList_Update();
		end
	elseif ( event == "LFG_UPDATE" or event == "PARTY_MEMBERS_CHANGED" ) then
		local inParty, joined, queued, noPartialClear, achievements, lfgComment, slotCount = GetLFGInfoServer();
		local inGroup = GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0;
		if ( inGroup ~= self.lastInGroup ) then
			self.lastInGroup = inGroup;
			LFRQueueFrameComment:SetText("");
			LFRQueueFrameCommentExplanation:Show();
			LFRQueueFrameComment:ClearFocus();
			SetLFGComment("");
		end
		if ( not LFR_IsEmpowered() or (not LFRQueueFrameComment:HasFocus() and LFRQueueFrameComment:GetText() == "") ) then
			if ( joined ) then
				LFRQueueFrameComment:SetText(lfgComment);
				if ( strtrim(lfgComment) == "" ) then
					LFRQueueFrameCommentExplanation:Show();
				else
					LFRQueueFrameCommentExplanation:Hide();
				end
			end
			LFRQueueFrameComment:ClearFocus();
		end
	end
end

function LFRQueueFrameFindGroupButton_Update()
	local mode, subMode = GetLFGMode();
	if ( mode == "listed" ) then
		if ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 ) then
			LFRQueueFrameFindGroupButton:SetText(UNLIST_MY_GROUP);
			LFDQueueFrameNoLFDWhileLFRLeaveQueueButton:SetText(UNLIST_MY_GROUP);
		else
			LFRQueueFrameFindGroupButton:SetText(UNLIST_ME);
			LFDQueueFrameNoLFDWhileLFRLeaveQueueButton:SetText(UNLIST_ME);
		end
	else
		if ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 ) then
			LFRQueueFrameFindGroupButton:SetText(LIST_MY_GROUP);
		else
			LFRQueueFrameFindGroupButton:SetText(LIST_ME);
		end
	end
	
	if ( LFR_IsEmpowered() and mode ~= "proposal" and mode ~= "queued" and mode ~= "rolecheck" and (not LFRRaidList or LFRRaidList[1])) then --During the proposal, they must use the proposal buttons to leave the queue.
		LFRQueueFrameFindGroupButton:Enable();
		LFRQueueFrameAcceptCommentButton:Enable();
		LFDQueueFrameNoLFDWhileLFRLeaveQueueButton:Enable();
	else
		LFRQueueFrameFindGroupButton:Disable();
		LFRQueueFrameAcceptCommentButton:Disable();
		LFDQueueFrameNoLFDWhileLFRLeaveQueueButton:Disable();
	end
end

function LFR_CanQueueForLockedInstances()
	return GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0;
end

function LFR_CanQueueForMultiple()
	return (GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0);
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
	
	PlaySound(isChecked and "igMainMenuOptionCheckBoxOff" or "igMainMenuOptionCheckBoxOff");
	if ( LFGIsIDHeader(dungeonID) ) then
		LFRList_SetHeaderEnabled(dungeonID, isChecked);
	elseif ( LFR_CanQueueForMultiple() ) then
		LFRList_SetRaidEnabled(dungeonID, isChecked);
		LFGListUpdateHeaderEnabledAndLockedStates(LFRRaidList, LFGEnabledList, LFGLockList, LFRHiddenByCollapseList);
	else
		LFRQueueFrame.selectedLFM = dungeonID;
	end
	
	LFRQueueFrameSpecificList_Update();
end

function LFRQueueFrameExpandOrCollapseButton_OnClick(self, button)
	local parent = self:GetParent();
	LFRList_SetHeaderCollapsed(parent.id, not parent.isCollapsed);
end

function LFRList_SetRaidEnabled(dungeonID, isEnabled)
	SetLFGDungeonEnabled(dungeonID, isEnabled);
	LFGEnabledList[dungeonID] = not not isEnabled;	--Change to true/false
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
	LFGEnabledList[headerID] = not not isEnabled; --Change to true/false
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
			button.instanceName:SetPoint("LEFT", button.heroicIcon, "RIGHT", 0, 1);
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
		local name =  info[LFG_RETURN_VALUES.name];
		local minLevel, maxLevel = info[LFG_RETURN_VALUES.minLevel], info[LFG_RETURN_VALUES.maxLevel];
		local minRecLevel, maxRecLevel = info[LFG_RETURN_VALUES.minRecLevel], info[LFG_RETURN_VALUES.maxRecLevel];
		local recLevel = info[LFG_RETURN_VALUES.recLevel];
		
		button.instanceName:SetText(name);
		button.instanceName:SetPoint("RIGHT", button.level, "LEFT", -10, 0);
		
		button.heroicIcon:Hide();
		button.instanceName:SetPoint("LEFT", 40, 0);
			
		if ( minLevel == maxLevel ) then
			button.level:SetText(format(LFD_LEVEL_FORMAT_SINGLE, minLevel));
		else
			button.level:SetText(format(LFD_LEVEL_FORMAT_RANGE, minLevel, maxLevel));
		end
		button.level:Show();
		local difficultyColor = GetQuestDifficultyColor(recLevel);
		button.level:SetFontObject(difficultyColor.font);
		
		if ( mode == "rolecheck" or mode == "queued" or mode == "listed" or not LFR_IsEmpowered()) then
			button.instanceName:SetFontObject(QuestDifficulty_Header);
		else
			button.instanceName:SetFontObject(difficultyColor.font);
		end
		
		
		button.expandOrCollapseButton:Hide();
		
		button.isCollapsed = false;
	end
	
	--Could probably use being refactored.
	if ( not LFR_CanQueueForLockedInstances() and LFGLockList[dungeonID] ) then
		button.enableButton:Hide();
		button.lockedIndicator:Show();
	else
		if ( LFR_CanQueueForMultiple() ) then
			button.enableButton:Show();
			LFGSpecificChoiceEnableButton_SetIsRadio(button.enableButton, false);
		else
			if ( LFGIsIDHeader(dungeonID) ) then
				button.enableButton:Hide();
			else
				button.enableButton:Show();
				LFGSpecificChoiceEnableButton_SetIsRadio(button.enableButton, true);
			end
		end
		button.lockedIndicator:Hide();
	end
	
	local enableState;
	if ( mode == "queued" or mode == "listed" ) then
		enableState = LFGQueuedForList[dungeonID];
	elseif ( not LFR_CanQueueForMultiple() ) then
		enableState = dungeonID == LFRQueueFrame.selectedLFM;
	else
		enableState = LFGEnabledList[dungeonID];
	end
	
	if ( LFR_CanQueueForMultiple() ) then
		if ( enableState == 1 ) then	--Some are checked, some aren't.
			button.enableButton:SetCheckedTexture("Interface\\Buttons\\UI-MultiCheck-Up");
			button.enableButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-MultiCheck-Disabled");
		else
			button.enableButton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
			button.enableButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
		end
		button.enableButton:SetChecked(enableState and enableState ~= 0);
	else
		button.enableButton:SetChecked(enableState);
	end
	
	if ( mode == "rolecheck" or mode == "queued" or mode == "listed" or not LFR_IsEmpowered() ) then
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
	
	local mode, subMode = GetLFGMode();
	
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
	
	if ( LFRRaidList[1] ) then
		LFRQueueFrameSpecificNoRaidsAvailable:Hide();
	else
		LFRQueueFrameSpecificNoRaidsAvailable:Show();
	end
end

function LFRQueueFrame_QueueForInstanceIfEnabled(queueID)
	if ( not LFGIsIDHeader(queueID) and LFGEnabledList[queueID] and (LFR_CanQueueForLockedInstances() or not LFGLockList[queueID]) ) then
		local info = LFGGetDungeonInfoByID(queueID);
		SetLFGDungeon(queueID);
		return true;
	end
	return false;
end

function LFRQueueFrame_Join()
	ClearAllLFGDungeons();
	
	if ( LFR_CanQueueForMultiple() ) then
		for _, queueID in pairs(LFRRaidList) do
			LFRQueueFrame_QueueForInstanceIfEnabled(queueID);
		end
		for _, queueID in pairs(LFRHiddenByCollapseList) do
			LFRQueueFrame_QueueForInstanceIfEnabled(queueID);
		end
	else
		if ( LFRQueueFrame.selectedLFM ) then
			SetLFGDungeon(LFRQueueFrame.selectedLFM);
		end
	end
	
	if ( LFRQueueFrameComment:HasFocus() ) then
		LFRQueueFrameComment:ClearFocus();
	else
		SetLFGComment(LFRQueueFrameComment:GetText());
	end
	JoinLFG();
end

LFRHiddenByCollapseList = {};
function LFRQueueFrame_Update()
	local enableList;
	
	local mode, submode = GetLFGMode();
	if ( LFR_IsEmpowered() and mode ~= "listed") then
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
		( level - LFR_MAX_SHOWN_LEVEL_DIFF <= info[LFG_RETURN_VALUES.recLevel] or (LFGLockList and not LFGLockList[dungeonID]));	--If the server tells us we can join, who are we to complain?
end

LFR_CURRENT_FILTER = LFRList_DefaultFilterFunction;

-----------------------------------------------------------------------
-----------------------LFR Browsing--------------------------------
-----------------------------------------------------------------------
local browseFrameLocal;
function LFRBrowseFrame_OnLoad(self)
	browseFrameLocal = self;
end

function LFRBrowseFrame_OnUpdateAlways(elapsed)	--Actually called in UIParent_OnUpdate so that it can run while LFRBrowseFrame is hidden.
	local timeToClear = browseFrameLocal.timeToClear;
	if ( timeToClear ) then
		if ( timeToClear < 0 ) then
			SearchLFGLeave();
			--We don't really have to do any of the other work done by SetSelectedValue, so why do it?
			LFRBrowseFrameRaidDropDownText:SetText(NONE);
			browseFrameLocal.timeToClear = nil;
		else
			browseFrameLocal.timeToClear = timeToClear - elapsed;
		end
	end
end

--We construct the list. This should only need to be called once (since we don't filter or change it), so we don't much worry about 1 garbage table.
function GetFullRaidList()
	LFGDungeonList_Setup();
	
	local headerOrder = {};
	local list = {};
	
	local tempList = GetLFRChoiceOrder();
	LFGListRemoveHeadersWithoutChildren(tempList);
	
	for i=1, #tempList do
		local id = tempList[i];
		if ( LFGIsIDHeader(tempList[i]) ) then
			tinsert(headerOrder, id);
			list[tempList[i]] = {};
		else
			local parentID = LFGGetDungeonInfoByID(id)[LFG_RETURN_VALUES.groupID];
			if ( parentID ~= 0 ) then
				local parentTable = list[parentID];
				tinsert(parentTable, id);
			end
		end
	end
	return headerOrder, list;
end

function LFRBrowseFrameRaidDropDown_SetUp(self)
	UIDropDownMenu_SetWidth(self, 140);
	UIDropDownMenu_Initialize(self, LFRBrowseFrameRaidDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(LFRBrowseFrameRaidDropDown, SearchLFGGetJoinedID() or "none");
end

function LFRBrowseFrameRaidDropDown_Initialize(self, level)
	LFGDungeonList_Setup();
	if ( not LFR_FULL_RAID_LIST_HEADER_ORDER ) then
		LFR_FULL_RAID_LIST_HEADER_ORDER, LFR_FULL_RAID_LIST = GetFullRaidList();
	end
	
	local activeSearching = SearchLFGGetJoinedID() or "none";
	
	local info = UIDropDownMenu_CreateInfo();
	
	if ( not level or level == 1 ) then
		info.text = NONE;
		info.value = "none";
		info.func = LFRBrowseFrameRaidDropDownButton_OnClick;
		info.checked = activeSearching == info.value;
		UIDropDownMenu_AddButton(info);
		
		for _, groupID in ipairs(LFR_FULL_RAID_LIST_HEADER_ORDER) do
			info.text = LFGGetDungeonInfoByID(groupID)[LFG_RETURN_VALUES.name];
			info.value = groupID;
			info.func = nil;
			info.hasArrow = true;
			info.checked = false;
			UIDropDownMenu_AddButton(info, 1);
		end
	elseif ( level == 2 ) then
		for _, dungeonID in ipairs(LFR_FULL_RAID_LIST[UIDROPDOWNMENU_MENU_VALUE]) do
			local info = LFGGetDungeonInfoByID(dungeonID);
			local maxPlayers = format(LFD_LEVEL_FORMAT_SINGLE, info[LFG_RETURN_VALUES.maxPlayers]);
			info.text = maxPlayers.." "..info[LFG_RETURN_VALUES.name];
			info.value = dungeonID;
			info.func = LFRBrowseFrameRaidDropDownButton_OnClick;
			info.checked = activeSearching == info.value;
			UIDropDownMenu_AddButton(info, level);
		end
	end
end

function LFRBrowseFrameRaidDropDownButton_OnClick(self)
	LFRBrowseFrameRaidDropDown.activeValue = self.value;
	UIDropDownMenu_SetSelectedValue(LFRBrowseFrameRaidDropDown, self.value);
	HideDropDownMenu(1);	--Hide the category menu. It gets annoying.
	if ( self.value == "none" ) then
		SearchLFGLeave();
	else
		SearchLFGJoin(LFGGetDungeonInfoByID(self.value)[LFG_RETURN_VALUES.typeID], self.value);
	end
end

function LFRFrame_SetActiveTab(tab)
	if ( tab == 1 ) then
		LFRParentFrame.activeTab = 1;
		LFRQueueFrame:Show();
		LFRBrowseFrame:Hide();
	elseif ( tab == 2 ) then
		LFRParentFrame.activeTab = 2;
		LFRBrowseFrame:Show();
		LFRQueueFrame:Hide();
	end
	PanelTemplates_SetTab(LFRParentFrame, tab);
end

function LFRBrowseFrameRefreshButton_OnUpdate(self, elapsed)
	local timeLeft = self.timeUntilNextRefresh;
	if ( timeLeft ) then
		self.timeUntilNextRefresh = timeLeft - elapsed;
		if ( self.timeUntilNextRefresh <= 0 ) then
			RefreshLFGList();
		end
	end
end

function LFRBrowseFrameList_Update()
	LFRBrowseFrameRefreshButton.timeUntilNextRefresh = LFR_BROWSE_AUTO_REFRESH_TIME;
	
	local numResults, totalResults = SearchLFGGetNumResults();
	FauxScrollFrame_Update(LFRBrowseFrameListScrollFrame, numResults, NUM_LFR_LIST_BUTTONS, 16);
	
	local offset = FauxScrollFrame_GetOffset(LFRBrowseFrameListScrollFrame);
	
	for i=1, NUM_LFR_LIST_BUTTONS do
		local button = _G["LFRBrowseFrameListButton"..i];
		if ( i <= numResults ) then
			LFRBrowseFrameListButton_SetData(button, i + offset);
			button:Show();
		else
			button:Hide();
		end
	end

	if ( LFRBrowseFrame.selectedName ) then
		local nameStillThere = false;
		for i=1, numResults do
			local name = SearchLFGGetResults(i);
			if ( LFRBrowseFrame.selectedName == name ) then
				nameStillThere = true;
				break;
			end
		end
		if ( not nameStillThere ) then
			LFRBrowseFrame.selectedName = nil;
		end
	end
	
	LFRBrowse_UpdateButtonStates();
end

function LFRBrowseFrameListButton_SetData(button, index)
	local name, level, areaName, className, comment, partyMembers, status, class, encountersTotal, encountersComplete, isLeader, isTank, isHealer, isDamage = SearchLFGGetResults(index);
	
	button.index = index;
	button.unitName = name;
	if ( LFRBrowseFrame.selectedName == name ) then
		button:LockHighlight();
	else
		button:UnlockHighlight();
	end
	button.name:SetText(name);
	
	button.level:SetText(level);
	
	local classTextColor;
	if ( class ) then
		classTextColor = RAID_CLASS_COLORS[class];
	else
		classTextColor = NORMAL_FONT_COLOR;
	end
	button.class:SetText(className);
	button.class:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
	
	
	if ( partyMembers > 0 ) then
		button.type = "party";
		button.partyIcon:Show();
		button.tankIcon:Hide();
		button.healerIcon:Hide();
		button.damageIcon:Hide();
	else
		button.type = "individual";
		button.partyIcon:Hide();
		
		if ( isTank ) then
			button.tankIcon:Show()
		else
			button.tankIcon:Hide();
		end
		
		if ( isHealer ) then
			button.healerIcon:Show();
		else
			button.healerIcon:Hide();
		end
		
		if ( isDamage ) then
			button.damageIcon:Show();
		else
			button.damageIcon:Hide();
		end
	end
	
	if ( name == UnitName("player") ) then
		button:Disable();
		button.name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		button.level:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		button.class:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		button.tankIcon:SetTexture("Interface\\LFGFrame\\LFGRole_BW");
		button.healerIcon:SetTexture("Interface\\LFGFrame\\LFGRole_BW");
		button.damageIcon:SetTexture("Interface\\LFGFrame\\LFGRole_BW");
		button.partyIcon:SetTexture("Interface\\LFGFrame\\LFGRole_BW");
	else
		button:Enable();
		button.name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		button.level:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		button.tankIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
		button.healerIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
		button.damageIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
		button.partyIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
	end
end

function LFRBrowseButton_OnEnter(self)
	local name, level, areaName, className, comment, partyMembers, status, class, encountersTotal, encountersComplete, isLeader, isTank, isHealer, isDamage = SearchLFGGetResults(self.index);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 27, -37);
	
	if ( partyMembers > 0 ) then
		GameTooltip:AddLine(LOOKING_FOR_RAID);
		
		GameTooltip:AddLine(name);
		GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0, 0.25, 0, 1);
		
		GameTooltip:AddLine(format(LFM_NUM_RAID_MEMBER_TEMPLATE, partyMembers));
		-- Bogus texture to fix spacing
		GameTooltip:AddTexture("");
		
		--Display ignored party members and friend party members. (You probably won't care about the rest. Though guildys would be nice at some point...)
		local displayedMembersLabel = false;
		for i=1, partyMembers do
			local name, level, relationship, className, areaName, comment = SearchLFGGetPartyResults(self.index, i);
			if ( relationship ) then
				if ( not displayedMembersLabel ) then
					displayedMembersLabel = true;
					GameTooltip:AddLine("\n"..IMPORTANT_PEOPLE_IN_GROUP);
				end
				if ( relationship == "ignored" ) then
					GameTooltip:AddDoubleLine(name, IGNORED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				elseif ( relationship == "friend" ) then
					GameTooltip:AddDoubleLine(name, FRIEND, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				end
			end
		end
	else
		GameTooltip:AddLine(name);
		GameTooltip:AddLine(format(FRIENDS_LEVEL_TEMPLATE, level, className));
	end
	
	if ( comment and comment ~= "" ) then
		GameTooltip:AddLine("\n"..comment, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
	end
	
	if ( partyMembers == 0 ) then
		GameTooltip:AddLine("\n"..LFG_TOOLTIP_ROLES);
		if ( isTank ) then
			GameTooltip:AddLine(TANK);
			GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0.5, 0.75, 0, 1);
		end
		if ( isHealer ) then
			GameTooltip:AddLine(HEALER);
			GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0.75, 1, 0, 1);
		end
		if ( isDamage ) then
			GameTooltip:AddLine(DAMAGER);
			GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0.25, 0.5, 0, 1);
		end
	end
	
	if ( encountersComplete > 0 ) then
		GameTooltip:AddLine("\n"..BOSSES);
		for i=1, encountersTotal do
			local bossName, texture, isKilled = SearchLFGGetEncounterResults(self.index, i);
			if ( isKilled ) then
				GameTooltip:AddDoubleLine(bossName, BOSS_DEAD, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			else
				GameTooltip:AddDoubleLine(bossName, BOSS_ALIVE, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
			end
		end
	elseif ( partyMembers > 0 and encountersTotal > 0) then
		GameTooltip:AddLine("\n"..ALL_BOSSES_ALIVE);
	end
	
	GameTooltip:Show();
end

--this is used by the static popup for INSTANCE_LOCK_TIMER
function InstanceLock_OnEnter(self)
	GameTooltip:SetOwner(self:GetParent(), "ANCHOR_BOTTOM");
	if ( self.encountersComplete > 0 ) then
		GameTooltip:SetText(BOSSES);
		for i=1, self.encountersTotal do
			local bossName, texture, isKilled = GetInstanceLockTimeRemainingEncounter(i);
			if ( isKilled ) then
				GameTooltip:AddDoubleLine(bossName, BOSS_DEAD, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			else
				GameTooltip:AddDoubleLine(bossName, BOSS_ALIVE, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
			end
		end
	else
		GameTooltip:SetText(ALL_BOSSES_ALIVE);
	end
	GameTooltip:Show();
end

function LFRBrowseButton_OnClick(self)
	if ( LFRBrowseFrame.selectedName == self.unitName ) then
		PlaySound("igMainMenuOptionCheckBoxOff");
		LFRBrowseFrame.selectedName = nil;
		LFRBrowseFrame.selectedType = nil;
		self:UnlockHighlight();
	else
		PlaySound("igMainMenuOptionCheckBoxOn");
		LFRBrowseFrame.selectedName = self.unitName;
		LFRBrowseFrame.selectedType = self.type;
		--Unlock all other highlights
		for i=1, NUM_LFR_LIST_BUTTONS do
			_G["LFRBrowseFrameListButton"..i]:UnlockHighlight();
		end
		self:LockHighlight();
	end
	LFRBrowse_UpdateButtonStates();
end

function LFRBrowse_UpdateButtonStates()
	local playerName = UnitName("player");
	local selectedName = LFRBrowseFrame.selectedName;
	
	if ( selectedName and selectedName ~= playerName ) then
		LFRBrowseFrameSendMessageButton:Enable();
	else
		LFRBrowseFrameSendMessageButton:Disable();
	end
	
	if ( selectedName and selectedName ~= playerName and LFRBrowseFrame.selectedType ~= "party" and CanGroupInvite() ) then
		LFRBrowseFrameInviteButton:Enable();
	else
		LFRBrowseFrameInviteButton:Disable();
	end
end