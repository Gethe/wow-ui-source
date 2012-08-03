--Extra lines added because looking upward was too much work.







LFR_MAX_SHOWN_LEVEL_DIFF = 15;

NUM_LFR_CHOICE_BUTTONS = 14;

NUM_LFR_LIST_BUTTONS = 19;

LFR_BROWSE_AUTO_REFRESH_TIME = 20;

local heroicIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-HEROIC:16:13:-5:-3:32:32:0:16:0:20|t";

function LFRFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_LFG_LIST");
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	
	
	LFRFrame_SetActiveTab(1);
	
	self.lastInGroup = IsInGroup();
	
	for i = 2, 19 do
		local button = CreateFrame("Button", "LFRBrowseFrameListButton"..i, LFRBrowseFrame, "LFRBrowseButtonTemplate");
		button:SetPoint("TOPLEFT", _G["LFRBrowseFrameListButton"..(i-1)], "BOTTOMLEFT");
	end
	for i = 2, 14 do
		local button = CreateFrame("Button", "LFRQueueFrameSpecificListButton"..i, LFRQueueFrameSpecific, "LFRFrameDungeonChoiceTemplate");
		button:SetID(i);
		button:SetPoint("TOPLEFT", _G["LFRQueueFrameSpecificListButton"..(i-1)], "BOTTOMLEFT");
	end
end

function LFRFrame_OnEvent(self, event, ...)
	if ( event == "UPDATE_LFG_LIST" ) then
		if ( LFRBrowseFrame:IsVisible() ) then
			LFRBrowseFrameList_Update();
		end
	elseif ( event == "LFG_UPDATE" or event == "GROUP_ROSTER_UPDATE" ) then
		local inParty, joined, queued, noPartialClear, achievements, lfgComment, slotCount = GetLFGInfoServer(LE_LFG_CATEGORY_LFR);
		local inGroup = IsInGroup();
		if ( inGroup ~= self.lastInGroup ) then
			self.lastInGroup = inGroup;
			LFRQueueFrameComment:SetText("");
			LFRQueueFrameCommentExplanation:Show();
			LFRQueueFrameComment:ClearFocus();
			SetLFGComment("");
		end
		if ( not RaidBrowser_IsEmpowered() or (not LFRQueueFrameComment:HasFocus() and LFRQueueFrameComment:GetText() == "") ) then
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
	local mode, subMode = GetLFGMode(LE_LFG_CATEGORY_LFR);
	if ( mode == "listed" ) then
		if ( IsInGroup() ) then
			LFRQueueFrameFindGroupButton:SetText(UNLIST_MY_GROUP);
			LFDQueueFrameNoLFDWhileLFRLeaveQueueButton:SetText(UNLIST_MY_GROUP);
		else
			LFRQueueFrameFindGroupButton:SetText(UNLIST_ME);
			LFDQueueFrameNoLFDWhileLFRLeaveQueueButton:SetText(UNLIST_ME);
		end
	else
		if ( IsInGroup() ) then
			LFRQueueFrameFindGroupButton:SetText(LIST_MY_GROUP);
		else
			LFRQueueFrameFindGroupButton:SetText(LIST_ME);
		end
	end
	
	if ( not RaidBrowser_IsEmpowered() or (LFRRaidList and not LFRRaidList[1]) ) then --Not group leader or no eligible raids
		LFRQueueFrameFindGroupButton:Disable();
		LFRQueueFrameAcceptCommentButton:Disable();
	else
		LFRQueueFrameFindGroupButton:Enable();
		LFRQueueFrameAcceptCommentButton:Enable();
	end
end

function LFR_CanQueueForLockedInstances()
	return IsInGroup();
end

function LFR_CanQueueForRaidLockedInstances()
	return true;	--For now, everyone can queue for raid locked instances.
end

function LFR_CanQueueForMultiple()
	return (not IsInGroup());
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
	if ( LFR_CanQueueForMultiple() ) then
		LFGDungeonListCheckButton_OnClick(self, LE_LFG_CATEGORY_LFR, LFRRaidList, LFRHiddenByCollapseList);
	else
		LFRQueueFrame.selectedLFM = self:GetParent().id;
	end
	LFRQueueFrameSpecificList_Update();
end

function LFRQueueFrameExpandOrCollapseButton_OnClick(self, button)
	local parent = self:GetParent();
	LFGDungeonList_SetHeaderCollapsed(self:GetParent(), LFRRaidList, LFRHiddenByCollapseList);
	LFRQueueFrame_Update();
end

--List functions
function LFRQueueFrameSpecificListButton_SetDungeon(button, dungeonID, mode, submode)
	local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday = GetLFGDungeonInfo(dungeonID);
	button.id = dungeonID;
	if ( LFGIsIDHeader(dungeonID) ) then
		button.instanceName:SetText(name);
		button.instanceName:SetFontObject(QuestDifficulty_Header);
		button.instanceName:SetPoint("RIGHT", button, "RIGHT", 0, 0);
		button.level:Hide();
		
		if ( subtypeID == LFG_SUBTYPEID_HEROIC ) then
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
		
		if ( mode == "rolecheck" or mode == "queued" or mode == "listed" or mode == "suspended" or not RaidBrowser_IsEmpowered()) then
			button.instanceName:SetFontObject(QuestDifficulty_Header);
		else
			button.instanceName:SetFontObject(difficultyColor.font);
		end
		
		
		button.expandOrCollapseButton:Hide();
		
		button.isCollapsed = false;
	end
	
	if ( not LFGLockList[dungeonID] or LFR_CanQueueForLockedInstances() or (LFR_CanQueueForRaidLockedInstances() and LFGLockList[dungeonID] == LFG_INSTANCE_INVALID_RAID_LOCKED) ) then
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
	else
		button.enableButton:Hide();
		button.lockedIndicator:Show();
	end
	
	local enableState;
	if ( mode == "queued" or mode == "listed" or mode == "suspended" ) then
		enableState = LFGQueuedForList[LE_LFG_CATEGORY_LFR][dungeonID];
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
	
	if ( mode == "rolecheck" or mode == "queued" or mode == "listed" or mode == "suspended" or not RaidBrowser_IsEmpowered() ) then
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
	
	local mode, subMode = GetLFGMode(LE_LFG_CATEGORY_LFR);
	
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
	if ( not LFGIsIDHeader(queueID) and LFGEnabledList[queueID] and
		(not LFGLockList[dungeonID] or LFR_CanQueueForLockedInstances() or (LFR_CanQueueForRaidLockedInstances() and LFGLockList[dungeonID] == LFG_INSTANCE_INVALID_RAID_LOCKED)) ) then
		SetLFGDungeon(LE_LFG_CATEGORY_LFR, queueID);
		return true;
	end
	return false;
end

function LFRQueueFrame_Join()
	ClearAllLFGDungeons(LE_LFG_CATEGORY_LFR);
	
	if ( LFR_CanQueueForMultiple() ) then
		for _, queueID in pairs(LFRRaidList) do
			LFRQueueFrame_QueueForInstanceIfEnabled(queueID);
		end
		for _, queueID in pairs(LFRHiddenByCollapseList) do
			LFRQueueFrame_QueueForInstanceIfEnabled(queueID);
		end
	else
		if ( LFRQueueFrame.selectedLFM ) then
			SetLFGDungeon(LE_LFG_CATEGORY_LFR, LFRQueueFrame.selectedLFM);
		end
	end
	
	if ( LFRQueueFrameComment:HasFocus() ) then
		LFRQueueFrameComment:ClearFocus();
	else
		SetLFGComment(LFRQueueFrameComment:GetText());
	end
	JoinLFG(LE_LFG_CATEGORY_LFR);
end

LFRHiddenByCollapseList = {};
function LFRQueueFrame_Update()
	local mode, submode = GetLFGMode(LE_LFG_CATEGORY_LFR);

	local checkedList;
	if ( RaidBrowser_IsEmpowered() and mode ~= "listed") then
		checkedList = LFGEnabledList;
	else
		checkedList = LFGQueuedForList[LE_LFG_CATEGORY_LFR];
	end
	
	LFRRaidList = GetLFRChoiceOrder(LFRRaidList);
		
	LFGQueueFrame_UpdateLFGDungeonList(LFRRaidList, LFRHiddenByCollapseList, checkedList, LFR_CURRENT_FILTER, LFR_MAX_SHOWN_LEVEL_DIFF);
	
	LFRQueueFrameSpecificList_Update();
end

LFR_CURRENT_FILTER = LFGList_DefaultFilterFunction;

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
			local parentID = select(LFG_RETURN_VALUES.groupID, GetLFGDungeonInfo(id));
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
			info.text = select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(groupID));
			info.value = groupID;
			info.func = nil;
			info.hasArrow = true;
			info.checked = false;
			UIDropDownMenu_AddButton(info, 1);
		end
	elseif ( level == 2 ) then
		for _, dungeonID in ipairs(LFR_FULL_RAID_LIST[UIDROPDOWNMENU_MENU_VALUE]) do
			local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday = GetLFGDungeonInfo(dungeonID);
			if ( maxPlayers > 0 ) then
				local maxPlayers = format(LFD_LEVEL_FORMAT_SINGLE, maxPlayers);
				info.text = maxPlayers.." "..name;
			else
				info.text = name;
			end
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
		SearchLFGJoin(select(LFG_RETURN_VALUES.typeID, GetLFGDungeonInfo(self.value)), self.value);
	end
end

function LFRFrame_SetActiveTab(tab)
	if ( tab == 1 ) then
		LFRParentFrame.activeTab = 1;
		LFRQueueFrame:Show();
		ButtonFrameTemplate_HideAttic(RaidParentFrame);
		LFRBrowseFrame:Hide();
		LFRParentFrameSideTab1:SetChecked(true);
		LFRParentFrameSideTab2:SetChecked(false);
	elseif ( tab == 2 ) then
		LFRParentFrame.activeTab = 2;
		LFRBrowseFrame:Show();
		RaidParentFrameInset:SetPoint("TOPLEFT", 4, -83);
		LFRQueueFrame:Hide();
		LFRParentFrameSideTab1:SetChecked(false);
		LFRParentFrameSideTab2:SetChecked(true);
	end
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
	local name, level, areaName, className, comment, partyMembers, status, class, encountersTotal, encountersComplete, isIneligible, isLeader, isTank, isHealer, isDamage = SearchLFGGetResults(index);
	
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
		if ( isIneligible ) then
			button.name:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			button.name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		end
		button.level:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		button.tankIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
		button.healerIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
		button.damageIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
		button.partyIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
	end
end

function LFRBrowseButton_OnEnter(self)
	local name, level, areaName, className, comment, partyMembers, status, class, encountersTotal, encountersComplete, isIneligible, isLeader, isTank, isHealer, isDamage = SearchLFGGetResults(self.index);
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
	
	if ( encountersComplete > 0 or isIneligible ) then
		GameTooltip:AddLine("\n"..BOSSES);
		for i=1, encountersTotal do
			local bossName, texture, isKilled, isIneligible = SearchLFGGetEncounterResults(self.index, i);
			if ( isKilled ) then
				GameTooltip:AddDoubleLine(bossName, BOSS_DEAD, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			elseif ( isIneligible ) then
				GameTooltip:AddDoubleLine(bossName, BOSS_ALIVE_INELIGIBLE, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
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
