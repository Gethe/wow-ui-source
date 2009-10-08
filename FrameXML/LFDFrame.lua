LFD_MAX_REWARDS = 2;

NUM_LFD_CHOICE_BUTTONS = 15;
TYPEID_HEROIC_DIFFICULTY = 5;
TYPEID_RANDOM_DUNGEON = 6;

NUM_LFD_MEMBERS = 5;

local hasSetUp = false;
--Variables to store dungeon info in Lua
--local LFDDungeonList, LFDDungeonInfo, LFDCollapseList, LFDEnabledList, LFDHiddenByCollapseList;
LFD_RETURN_VALUES = {
	name = 1,
	typeID = 2,
	minLevel = 3,
	maxLevel = 4,
	expansionLevel = 5,
	groupID = 6,
	texture = 7,
	difficulty = 8,
}

function LFDFrame_OnLoad(self)
	self:RegisterEvent("LFG_PROPOSAL_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_SHOW");
end

function LFDFrame_OnEvent(self, event, ...)
	if ( event == "LFG_PROPOSAL_UPDATE" ) then
		LFDDungeonReadyDialog_Update();
	elseif ( event == "LFG_PROPOSAL_SHOW" ) then
		StaticPopupSpecial_Show(LFDDungeonReadyPopup);
	end
end

function LFDQueueFrame_OnLoad(self)
	self:RegisterEvent("LFG_ROLE_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function LFDQueueFrame_OnEvent(self, event, ...)
	if ( event == "LFG_ROLE_UPDATE" ) then
		LFDQueueFrame_UpdateRoleCheckboxes();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		LFDQueueFrame_UpdateAvailableRoles();
		LFDQueueFrame_UpdateRoleCheckboxes();
	end
end

function LFDQueueFrame_DisableRoleButton(button)
	button:Disable();
	SetDesaturation(button:GetNormalTexture(), true);
	button.cover:Show();
	button.checkButton:Disable();
end

function LFDQueueFrame_EnableRoleButton(button)
	button:Enable();
	SetDesaturation(button:GetNormalTexture(), false);
	button.cover:Hide();
	button.checkButton:Enable();
end

function LFDQueueFrame_UpdateAvailableRoles()
	local canBeTank, canBeHealer, canBeDPS = GetAvailableRoles();
	
	if ( canBeTank ) then
		LFDQueueFrame_EnableRoleButton(LFDQueueFrameRoleButtonTank);
	else
		LFDQueueFrame_DisableRoleButton(LFDQueueFrameRoleButtonTank);
	end
	
	if ( canBeHealer ) then
		LFDQueueFrame_EnableRoleButton(LFDQueueFrameRoleButtonHealer);
	else
		LFDQueueFrame_DisableRoleButton(LFDQueueFrameRoleButtonHealer);
	end
	
	if ( canBeDPS ) then
		LFDQueueFrame_EnableRoleButton(LFDQueueFrameRoleButtonDPS);
	else
		LFDQueueFrame_DisableRoleButton(LFDQueueFrameRoleButtonDPS);
	end
end

function LFDQueueFrame_UpdateRoleCheckboxes()
	local leader, tank, healer, dps = GetLFGRoles();
	
	LFDQueueFrameRoleButtonLeader.checkButton:SetChecked(leader);
	LFDQueueFrameRoleButtonTank.checkButton:SetChecked(tank);
	LFDQueueFrameRoleButtonHealer.checkButton:SetChecked(healer);
	LFDQueueFrameRoleButtonDPS.checkButton:SetChecked(dps);
end

function LFDQueueFrame_SetRoles()
	SetLFGRoles(LFDQueueFrameRoleButtonLeader.checkButton:GetChecked(), 
		LFDQueueFrameRoleButtonTank.checkButton:GetChecked(),
		LFDQueueFrameRoleButtonHealer.checkButton:GetChecked(),
		LFDQueueFrameRoleButtonDPS.checkButton:GetChecked());
end

function LFDFrameRoleCheckButton_OnClick(self)
	LFDQueueFrame_SetRoles();
end

function LFDFrameRoleCheckButton_OnEnter(self)
	if ( self.checkButton:IsEnabled() == 1 ) then
		self.checkButton:LockHighlight();
	end
end

function LFDQueueFrameListButton_SetDungeon(button, dungeonID)
	local info = LFDGetDungeonInfoByID(dungeonID);
	button.id = dungeonID;
	if ( LFDIsIDHeader(dungeonID) ) then
		local name = info[LFD_RETURN_VALUES.name];
		
		button.instanceName:SetText(name);
		button.instanceName:SetFontObject(QuestDifficulty_Header);
		button.instanceName:SetPoint("RIGHT", button, "RIGHT", 0, 0);
		button.level:Hide();
		
		if ( info[LFD_RETURN_VALUES.typeID] == TYPEID_HEROIC_DIFFICULTY ) then
			button.heroicIcon:Show();
			button.instanceName:SetPoint("LEFT", button.heroicIcon, "RIGHT", 0, 0);
		else
			button.heroicIcon:Hide();
			button.instanceName:SetPoint("LEFT", 40, 0);
		end
			
		button.expandOrCollapseButton:Show();
		local isCollapsed = LFDCollapseList[dungeonID];
		button.isCollapsed = isCollapsed;
		if ( isCollapsed ) then
			button.expandOrCollapseButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
		else
			button.expandOrCollapseButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
		end
		
		button.enableButton:SetChecked(false);
	else
		local name, minLevel, maxLevel = info[LFD_RETURN_VALUES.name], info[LFD_RETURN_VALUES.minLevel], info[LFD_RETURN_VALUES.maxLevel];
		
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
		
		local difficultyColor = GetQuestDifficultyColor((minLevel + maxLevel)/2)
		button.instanceName:SetFontObject(difficultyColor.font);
		button.level:SetFontObject(difficultyColor.font);
		
		button.expandOrCollapseButton:Hide();
		button.isCollapsed = false;
	end
	button.enableButton:SetChecked(LFDEnabledList[dungeonID]);
end

function LFDQueueFrameList_Update()
	if ( not hasSetUp ) then
		LFDDungeonList_Setup();
		return;	--Setup will update the list.
	end
	FauxScrollFrame_Update(LFDQueueFrameListScrollFrame, LFDGetNumDungeons(), NUM_LFD_CHOICE_BUTTONS, 16);
	
	local offset = FauxScrollFrame_GetOffset(LFDQueueFrameListScrollFrame);
	
	local areButtonsBig = not LFDQueueFrameListScrollFrame:IsShown();
	
	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		local button = _G["LFDQueueFrameListButton"..i];
		local dungeonID = LFDDungeonList[i+offset];
		if ( dungeonID ) then
			button:Show();
			if ( areButtonsBig ) then
				button:SetWidth(315);
			else
				button:SetWidth(295);
			end
			LFDQueueFrameListButton_SetDungeon(button, dungeonID);
		else
			button:Hide();
		end
	end
end

function LFDList_SetHeaderCollapsed(headerID, isCollapsed)
	SetLFDHeaderCollapsed(headerID, isCollapsed);
	LFDCollapseList[headerID] = isCollapsed;
	for _, dungeonID in pairs(LFDDungeonList) do
		if ( LFDGetDungeonInfoByID(dungeonID)[LFD_RETURN_VALUES.groupID] == headerID ) then
			LFDCollapseList[dungeonID] = isCollapsed;
		end
	end
	for _, dungeonID in pairs(LFDHiddenByCollapseList) do
		if ( LFDGetDungeonInfoByID(dungeonID)[LFD_RETURN_VALUES.groupID] == headerID ) then
			LFDCollapseList[dungeonID] = isCollapsed;
		end
	end
	LFDQueueFrame_UpdateLFDDungeonList();
end

function LFDQueueFrame_QueueForInstanceIfEnabled(queueID)
	if ( not LFDIsIDHeader(queueID) and LFDEnabledList[queueID] ) then
		local info = LFDGetDungeonInfoByID(queueID);
		SetLFGDungeon(info[LFD_RETURN_VALUES.typeID], queueID);
		return true;
	end
	return false;
end

function LFDQueueFrame_Join()
	ClearAllLFGDungeons();
	for _, queueID in pairs(LFDDungeonList) do
		LFDQueueFrame_QueueForInstanceIfEnabled(queueID);
	end
	for _, queueID in pairs(LFDHiddenByCollapseList) do
		LFDQueueFrame_QueueForInstanceIfEnabled(queueID);
	end
	JoinLFG();
end

function LFDQueueFrameDungeonChoiceEnableButton_OnClick(self, button)
	local parent = self:GetParent();
	local dungeonID = parent.id;
	local isChecked = self:GetChecked();
	
	if ( LFDIsIDHeader(dungeonID) ) then
		LFDList_SetHeaderEnabled(dungeonID, isChecked);
	else
		LFDList_SetDungeonEnabled(dungeonID, isChecked);
		LFDListUpdateHeaderEnabledStates(LFDDungeonList, LFDEnabledList, LFDHiddenByCollapseList);
	end
	LFDQueueFrameList_Update();
end

function LFDList_SetDungeonEnabled(dungeonID, isEnabled)
	SetLFDDungeonEnabled(dungeonID, isEnabled);
	LFDEnabledList[dungeonID] = isEnabled;
end

function LFDList_SetHeaderEnabled(headerID, isEnabled)
	for _, dungeonID in pairs(LFDDungeonList) do
		if ( LFDGetDungeonInfoByID(dungeonID)[LFD_RETURN_VALUES.groupID] == headerID ) then
			LFDList_SetDungeonEnabled(dungeonID, isEnabled);
		end
	end
	for _, dungeonID in pairs(LFDHiddenByCollapseList) do
		if ( LFDGetDungeonInfoByID(dungeonID)[LFD_RETURN_VALUES.groupID] == headerID ) then
			LFDList_SetDungeonEnabled(dungeonID, isEnabled);
		end
	end
	LFDEnabledList[headerID] = isEnabled;
end

function GetTexCoordsForRole(role)
	local textureHeight, textureWidth = 256, 256;
	local roleHeight, roleWidth = 67, 67;
	
	if ( role == "LEADER" ) then
		return GetTexCoordsByGrid(1, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "TANK" ) then
		return GetTexCoordsByGrid(1, 2, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "HEALER" ) then
		return GetTexCoordsByGrid(2, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "DAMAGE" ) then
		return GetTexCoordsByGrid(2, 2, textureWidth, textureHeight, roleWidth, roleHeight);
	else
		error("Unknown role: "..tostring(role));
	end
end

function LFDDungeonReadyPopup_Update()	
	local typeID, id, name, texture, role, hasResponded, totalEncounters, completedEncounters, numMembers = GetLFGProposal();

	if ( hasResponded ) then
		LFDDungeonReadyStatus:Show();
		LFDDungeonReadyDialog:Hide();
		
		for i=1, numMembers do
			LFDDungeonReadyStatus_UpdateIcon(_G["LFDDungeonReadyStatusPlayer"..i]);
		end
		for i=numMembers+1, NUM_LFD_MEMBERS do
			_G["LFDDungeonReadyStatusPlayer"..i]:Hide();
		end
		
		if ( not LFDDungeonReadyPopup:IsShown() or StaticPopup_IsLastDisplayedFrame(LFDDungeonReadyPopup) ) then
			LFDDungeonReadyPopup:SetHeight(LFDDungeonReadyStatus:GetHeight());
		end
	else
		LFDDungeonReadyDialog:Show();
		LFDDungeonReadyStatus:Hide();
	
		local LFDDungeonReadyDialog = LFDDungeonReadyDialog; --Make a local copy.
		if ( typeID == TYPEID_RANDOM_DUNGEON ) then
			LFDDungeonReadyPopup:SetHeight(193);
			LFDDungeonReadyDialog.background:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-RANDOMDUNGEON");
			LFDDungeonReadyDialog.background:SetTexCoord(0, 294/512, 0, 118/256);
			LFDDungeonReadyDialog.backgroundFilter:Hide();
			
			LFDDungeonReadyDialog.label:SetText(RANDOM_DUNGEON_IS_READY);
			LFDDungeonReadyDialog.instanceInfo:Hide();
		else
			LFDDungeonReadyPopup:SetHeight(223);
			texture = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-"..texture;
			LFDDungeonReadyDialog.background:SetTexture(texture);
			if ( LFDDungeonReadyDialog.background:GetTexture() ~= texture ) then	--We haven't added this texture yet. Default to the Deadmines.
				LFDDungeonReadyDialog.background:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-Deadmines");	--DEBUG FIXME Default probably shouldn't be Deadmines
			end
			LFDDungeonReadyDialog.background:SetTexCoord(0, 294/512, 0, 148/256);
			LFDDungeonReadyDialog.backgroundFilter:Show();
			
			LFDDungeonReadyDialog.label:SetText(SPECIFIC_DUNGEON_IS_READY);
			LFDDungeonReadyDialog_UpdateInstanceInfo(name, completedEncounters, totalEncounters);
			LFDDungeonReadyDialogInstanceInfoFrame:Show();
		end

		
		LFDDungeonReadyDialogRoleIconTexture:SetTexCoord(GetTexCoordsForRole(role));
		LFDDungeonReadyDialogRoleLabel:SetText(_G[role]);
		
		LFDDungeonReadyDialog_UpdateRewards();
	end
end

function LFDDungeonReadyDialog_UpdateRewards()
	local rewardsOffset = 0;
	--DEBUG FIXME
	if ( true ) then --hasMiscReward ) then
		LFDDungeonReadyDialogReward_SetMisc(LFDDungeonReadyDialogRewardsFrameReward1);
		rewardsOffset = 1;
	end
	
	local numRewards = 1; --DEBUG FIXME
	for i = 1, numRewards do
		LFDDungeonReadyDialogReward_SetReward(_G["LFDDungeonReadyDialogRewardsFrameReward"..(i + rewardsOffset)], i)
	end
	
	local usedButtons = numRewards + rewardsOffset;
	--Hide the unused ones
	for i = usedButtons + 1, LFD_MAX_REWARDS do
		_G["LFDDungeonReadyDialogRewardsFrameReward"..i]:Hide();
	end
	
	if ( usedButtons > 0 ) then
		--Set up positions
		local positionPerIcon = 1/(2 * usedButtons) * LFDDungeonReadyDialogRewardsFrame:GetWidth();
		local iconOffset = 2 * positionPerIcon - LFDDungeonReadyDialogRewardsFrameReward1:GetWidth();
		LFDDungeonReadyDialogRewardsFrameReward1:SetPoint("CENTER", LFDDungeonReadyDialogRewardsFrame, "LEFT", positionPerIcon, 5);
		for i = 2, usedButtons do
			_G["LFDDungeonReadyDialogRewardsFrameReward"..i]:SetPoint("LEFT", "LFDDungeonReadyDialogRewardsFrameReward"..(i - 1), "RIGHT", iconOffset, 0);
		end
	end
end

function LFDDungeonReadyDialogReward_SetMisc(button)
	SetPortraitToTexture(button.texture, "Interface\\Icons\\inv_misc_coin_02");
	button.rewardID = 0;
end

function LFDDungeonReadyDialogReward_SetReward(button, rewardIndex)
	local rewardIcon = "Interface\\Icons\\".."inv_misc_gem_sapphire_02";	--DEBUG FIXME. We need to get this with a funtion...
	SetPortraitToTexture(button.texture, rewardIcon);
	button.rewardID = rewardIndex;
end

function LFDDungeonReadyDialog_UpdateInstanceInfo(name, completedEncounters, totalEncounters)
	local instanceInfoFrame = LFDDungeonReadyDialogInstanceInfoFrame;
	instanceInfoFrame.name:SetFontObject(GameFontNormalLarge);
	instanceInfoFrame.name:SetText(name);
	if ( instanceInfoFrame.name:GetWidth() + 20 > LFDDungeonReadyDialog:GetWidth() ) then
		instanceInfoFrame.name:SetFontObject(GameFontNormal);
	end
	
	instanceInfoFrame.statusText:SetFormattedText(BOSSES_KILLED, completedEncounters, totalEncounters);
end

--DEBUG FIXME
local fakeMiscLoot = {
	"Moneys", "XP", "Lions", "Tigers",  "Bears", "(Oh my!)"};
	
function LFDDungeonReadyDialogReward_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( self.rewardID == 0 ) then
		GameTooltip:AddLine(REWARD_ITEMS_ONLY);
		--DEBUG FIXME
		for i=1, #fakeMiscLoot do
			GameTooltip:AddLine("    "..fakeMiscLoot[i]);
		end
	else
		--DEBUG FIXME
		local itemLink = "item:37711:0:0:0:0:0:0:0"; --GetLFDRewardInfo(self.rewardID);
		GameTooltip:SetHyperlink(itemLink);
	end
	GameTooltip:Show();
end

function LFDDungeonReadyStatus_UpdateIcon(button)
	local isLeader, role, level, responded, accepted, name, class = GetLFGProposalMember(button:GetID());
	
	button.texture:SetTexCoord(GetTexCoordsForRole(role));
	
	if ( not responded ) then
		button.statusIcon:SetTexture(READY_CHECK_WAITING_TEXTURE);
	elseif ( accepted ) then
		button.statusIcon:SetTexture(READY_CHECK_READY_TEXTURE);
	else
		button.statusIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE);
	end
	
	button:Show();
end

-------Utility functions-----------
function LFDGetNumDungeons()
	return #LFDDungeonList;
end

function LFDGetDungeonInfoByID(id)
	return LFDDungeonInfo[id];
end

function LFDGetDungeonInfoByIndex(index)
	return LFDGetDungeonInfoByID(LFDDungeonList[index]);
end

function LFDIsIDHeader(id)
	return id < 0;
end

-------List filtering functions-----------

function LFDDungeonList_Setup()
	hasSetUp = true;
	LFDDungeonInfo = GetLFDChoiceInfo();	--This will never change (without a patch).
	LFDCollapseList = GetLFDChoiceCollapseState();	--We maintain this list in Lua
	LFDEnabledList = GetLFDChoiceEnabledState();	--We maintain this list in Lua
	
	LFDQueueFrame_UpdateLFDDungeonList();
end

function LFDQueueFrame_UpdateLFDDungeonList()
	LFDHiddenByCollapseList = {}
	
	--1. Fill out the table.
	LFDDungeonList = GetLFDChoiceOrder();
	
	--2. Remove all choices that don't match the filter.
	LFDListFilterChoices(LFDDungeonList, LFDDungeonInfo, LFD_CURRENT_FILTER);
	
	--3. Remove all headers that have no entries below them.
	LFDListRemoveHeadersWithoutChildren(LFDDungeonList);
	
	--4. Update the enabled state of headers.
	LFDListUpdateHeaderEnabledStates(LFDDungeonList, LFDEnabledList, LFDHiddenByCollapseList);
	
	--5. Move the children of collapsed headers into the LFDDungeonCollapsedEntries list.
	LFDListRemoveCollapsedChildren(LFDDungeonList, LFDCollapseList, LFDHiddenByCollapseList);
	
	LFDQueueFrameList_Update();
end

function LFDList_DefaultFilterFunction(dungeonID)
	local info = LFDGetDungeonInfoByID(dungeonID)
	local hasHeader = info[LFD_RETURN_VALUES.groupID] ~= 0;
	local avgLevel = (info[LFD_RETURN_VALUES.minLevel] + info[LFD_RETURN_VALUES.maxLevel])/2
	local withinRange = abs(UnitLevel("player") - avgLevel) < 20;
	return hasHeader;
end

LFD_CURRENT_FILTER = LFDList_DefaultFilterFunction

--filterFunc returns true if the object should be shown.
function LFDListFilterChoices(list, infoList, filterFunc)
	local currentPosition = 1;
	while ( currentPosition <= #list ) do
		local id = list[currentPosition];
		local isHeader = LFDIsIDHeader(id);
		if ( isHeader or filterFunc(id) ) then
			currentPosition = currentPosition + 1;
		else
			tremove(list, currentPosition);
		end
	end
end

function LFDListRemoveHeadersWithoutChildren(list)
	--This relies on unparented children coming first.
	local currentPosition = 1;
	--The discrepency between nextObject>IsChild< and >isHeader< is due to the way we want to handle empty values.
	local nextObjectIsChild = not LFDIsIDHeader(list[1] or 0);
	while ( currentPosition <= #list ) do
		local isHeader = not nextObjectIsChild;
		nextObjectIsChild = currentPosition < #list and not LFDIsIDHeader(list[currentPosition+1]);
		if ( isHeader and not nextObjectIsChild ) then
			tremove(list, currentPosition);
		else
			currentPosition = currentPosition + 1;
		end
	end
end

function LFDListUpdateHeaderEnabledStates(dungeonList, enabledList, hiddenByCollapseList)
	for i=1, #dungeonList do
		local id = dungeonList[i];
		if ( LFDIsIDHeader(id) ) then
			enabledList[id] = false;
		elseif ( enabledList[id] ) then
			enabledList[LFDGetDungeonInfoByID(id)[LFD_RETURN_VALUES.groupID]] = true;
		end
	end
	for i=1, #hiddenByCollapseList do
		local id = hiddenByCollapseList[i];
		if ( enabledList[id] ) then
			enabledList[LFDGetDungeonInfoByID(id)[LFD_RETURN_VALUES.groupID]] = true;
		end
	end
end

function LFDListRemoveCollapsedChildren(list, collapseStateList, hiddenByCollapseList)
	local currentPosition = 1;
	while ( currentPosition <= #list ) do
		local id = list[currentPosition];
		if ( not LFDIsIDHeader(id) and collapseStateList[id] ) then
			tinsert(hiddenByCollapseList, tremove(list, currentPosition));
		else
			currentPosition = currentPosition + 1;
		end
	end
end