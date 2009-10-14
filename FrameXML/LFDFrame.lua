LFD_MAX_REWARDS = 2;

NUM_LFD_CHOICE_BUTTONS = 15;
TYPEID_HEROIC_DIFFICULTY = 5;
TYPEID_RANDOM_DUNGEON = 6;

NUM_LFD_MEMBERS = 5;

LFD_STATISTIC_CHANGE_TIME = 10; --In secs.

LFD_NUM_ROLES = 3;

local NUM_STATISTIC_TYPES = 4;

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

--General functions
function LFDFrame_OnLoad(self)
	self:RegisterEvent("LFG_PROPOSAL_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_SHOW");
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LFG_ROLE_CHECK_SHOW");
	self:RegisterEvent("LFG_ROLE_CHECK_HIDE");
	self:RegisterEvent("LFG_BOOT_PROPOSAL_UPDATE");
end

function LFDFrame_OnEvent(self, event, ...)
	if ( event == "LFG_PROPOSAL_UPDATE" ) then
		LFDDungeonReadyPopup_Update();
	elseif ( event == "LFG_PROPOSAL_SHOW" ) then
		StaticPopupSpecial_Show(LFDDungeonReadyPopup);
	elseif ( event == "LFG_UPDATE" or event == "PLAYER_ENTERING_WORLD") then
		local inParty, joined, queued, noPartialClear, achievements, lfgComment, slotCount = GetLFGInfoServer();
		if ( queued ) then
			LFDQueueFrameFindGroupButton:SetText(LEAVE_QUEUE);
		else
			LFDQueueFrameFindGroupButton:SetText(FIND_GROUP);
		end
		
		if ( not joined ) then
			StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
		end
	elseif ( event == "LFG_ROLE_CHECK_SHOW" ) then
		StaticPopupSpecial_Show(LFDRoleCheckPopup);
	elseif ( event == "LFG_ROLE_CHECK_HIDE" ) then
		StaticPopupSpecial_Hide(LFDRoleCheckPopup);
	elseif ( event == "LFG_BOOT_PROPOSAL_UPDATE" ) then
		local voteInProgress, didVote, myVote, targetName, totalVotes, bootVotes, timeLeft = GetLFGBootProposal();
		if ( voteInProgress and not didVote and targetName ) then
			StaticPopup_Show("VOTE_BOOT_PLAYER", targetName);
		else
			StaticPopup_Hide("VOTE_BOOT_PLAYER");
		end
	end
end

--Queue-frame functions
function LFDQueueFrame_OnLoad(self)
	self:RegisterEvent("LFG_ROLE_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	self.type = 1;	--Default to random dungeon.
end

function LFDQueueFrame_OnEvent(self, event, ...)
	if ( event == "LFG_ROLE_UPDATE" ) then
		LFDQueueFrame_UpdateRoleCheckboxes();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		LFDQueueFrame_UpdateAvailableRoles();
		LFDQueueFrame_UpdateRoleCheckboxes();
	end
end

--Role-related functions
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
		LFDQueueFrame_EnableRoleButton(LFDRoleCheckPopupRoleButtonTank);
	else
		LFDQueueFrame_DisableRoleButton(LFDQueueFrameRoleButtonTank);
		LFDQueueFrame_DisableRoleButton(LFDRoleCheckPopupRoleButtonTank);
	end
	
	if ( canBeHealer ) then
		LFDQueueFrame_EnableRoleButton(LFDQueueFrameRoleButtonHealer);
		LFDQueueFrame_EnableRoleButton(LFDRoleCheckPopupRoleButtonHealer);
	else
		LFDQueueFrame_DisableRoleButton(LFDQueueFrameRoleButtonHealer);
		LFDQueueFrame_DisableRoleButton(LFDRoleCheckPopupRoleButtonHealer);
	end
	
	if ( canBeDPS ) then
		LFDQueueFrame_EnableRoleButton(LFDQueueFrameRoleButtonDPS);
		LFDQueueFrame_EnableRoleButton(LFDRoleCheckPopupRoleButtonDPS);
	else
		LFDQueueFrame_DisableRoleButton(LFDQueueFrameRoleButtonDPS);
		LFDQueueFrame_DisableRoleButton(LFDRoleCheckPopupRoleButtonDPS);
	end
end

function LFDQueueFrame_UpdateRoleCheckboxes()
	local leader, tank, healer, dps = GetLFGRoles();
	
	LFDQueueFrameRoleButtonLeader.checkButton:SetChecked(leader);
	
	LFDQueueFrameRoleButtonTank.checkButton:SetChecked(tank);
	LFDRoleCheckPopupRoleButtonTank.checkButton:SetChecked(tank);
	
	LFDQueueFrameRoleButtonHealer.checkButton:SetChecked(healer);
	LFDRoleCheckPopupRoleButtonHealer.checkButton:SetChecked(healer);
	
	LFDQueueFrameRoleButtonDPS.checkButton:SetChecked(dps);
	LFDRoleCheckPopupRoleButtonDPS.checkButton:SetChecked(dps);
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

--Role-check popup functions
function LFDRoleCheckPopupAccept_OnClick()
	StaticPopupSpecial_Hide(LFDRoleCheckPopup);
	local oldLeader = GetLFGRoles();
	SetLFGRoles(oldLeader, 
		LFDRoleCheckPopupRoleButtonTank.checkButton:GetChecked(),
		LFDRoleCheckPopupRoleButtonHealer.checkButton:GetChecked(),
		LFDRoleCheckPopupRoleButtonDPS.checkButton:GetChecked());
end

function LFDRoleCheckPopup_Update()
	if ( not hasSetUp ) then
		LFDDungeonList_Setup();
	end
	
	LFDQueueFrame_UpdateRoleCheckboxes();
	
	local inProgress, slots, members = GetLFGRoleUpdate();
	
	local displayName;
	if ( slots == 1 ) then
		local dungeonType, dungeonID = GetLFGRoleUpdateSlot(1);
		if ( dungeonType == TYPEID_RANDOM_DUNGEON ) then
			displayName = A_RANDOM_DUNGEON;
		elseif ( dungeonType == TYPEID_HEROIC_DIFFICULTY ) then
			displayName = format(HEROIC_PREFIX, LFDGetDungeonInfoByID(dungeonID)[LFD_RETURN_VALUES.name]);
		else
			displayName = LFDGetDungeonInfoByID(dungeonID)[LFD_RETURN_VALUES.name];
		end
	else
		displayName = MULTIPLE_DUNGEONS;
	end
	displayName = NORMAL_FONT_COLOR_CODE..displayName.."|r";
	
	LFDRoleCheckPopupDescriptionText:SetFormattedText(QUEUED_FOR, displayName);
	
	LFDRoleCheckPopupDescription:SetWidth(LFDRoleCheckPopupDescriptionText:GetWidth()+10);
end

function LFDRoleCheckPopupDescription_OnEnter(self)
	local inProgress, slots, members = GetLFGRoleUpdate();
	
	if ( slots <= 1 ) then
		return;
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
	GameTooltip:AddLine(QUEUED_FOR_SHORT);
	
	for i=1, slots do
		local dungeonType, dungeonID = GetLFGRoleUpdateSlot(i);
		local displayName;
		if ( dungeonType == TYPEID_HEROIC_DIFFICULTY ) then
			displayName = format(HEROIC_PREFIX, LFDGetDungeonInfoByID(dungeonID)[LFD_RETURN_VALUES.name]);
		else
			displayName = LFDGetDungeonInfoByID(dungeonID)[LFD_RETURN_VALUES.name];
		end
		GameTooltip:AddLine("    "..displayName);
	end
	GameTooltip:Show();
end

function LFDFrameRoleCheckButton_OnEnter(self)
	if ( self.checkButton:IsEnabled() == 1 ) then
		self.checkButton:LockHighlight();
	end
end

--List functions
function LFDQueueFrameSpecificListButton_SetDungeon(button, dungeonID)
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

function LFDQueueFrameSpecificList_Update()
	if ( not hasSetUp ) then
		LFDDungeonList_Setup();
		return;	--Setup will update the list.
	end
	FauxScrollFrame_Update(LFDQueueFrameSpecificListScrollFrame, LFDGetNumDungeons(), NUM_LFD_CHOICE_BUTTONS, 16);
	
	local offset = FauxScrollFrame_GetOffset(LFDQueueFrameSpecificListScrollFrame);
	
	local areButtonsBig = not LFDQueueFrameSpecificListScrollFrame:IsShown();
	
	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		local button = _G["LFDQueueFrameSpecificListButton"..i];
		local dungeonID = LFDDungeonList[i+offset];
		if ( dungeonID ) then
			button:Show();
			if ( areButtonsBig ) then
				button:SetWidth(315);
			else
				button:SetWidth(295);
			end
			LFDQueueFrameSpecificListButton_SetDungeon(button, dungeonID);
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
	if ( LFDQueueFrame.type == 1 ) then	--Random queue
		JoinRandomDungeon();
	elseif ( LFDQueueFrame.type == 2 ) then
		ClearAllLFGDungeons();
		for _, queueID in pairs(LFDDungeonList) do
			LFDQueueFrame_QueueForInstanceIfEnabled(queueID);
		end
		for _, queueID in pairs(LFDHiddenByCollapseList) do
			LFDQueueFrame_QueueForInstanceIfEnabled(queueID);
		end
		JoinLFG();
	end
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
	LFDQueueFrameSpecificList_Update();
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

--Ready popup functions
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
	local proposalExists, typeID, id, name, texture, role, hasResponded, totalEncounters, completedEncounters, numMembers = GetLFGProposal();

	if ( not proposalExists ) then
		StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
		return;
	end
	
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

function LFDDungeonReadyDialogInstanceInfo_OnEnter(self)
	local numBosses = select(8, GetLFGProposal());
	
	if ( numBosses == 0 ) then
		return;
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
	GameTooltip:AddLine(BOSSES)
	for i=1, numBosses do
		local bossName, texture, isKilled = GetLFGProposalEncounter(i);
		if ( isKilled ) then
			GameTooltip:AddDoubleLine(bossName, BOSS_DEAD, 1, 0, 0, 1, 0, 0);
		else
			GameTooltip:AddDoubleLine(bossName, BOSS_ALIVE, 0, 1, 0, 0, 1, 0);
		end
	end
	GameTooltip:Show();
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

function LFDQueueFrameTypeDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, LFDQueueFrameTypeDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, LFDQueueFrame.type);
end

function LFDQueueFrameTypeDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = LFG_TYPE_RANDOM_DUNGEON;
	info.value = 1;
	info.func = LFDQueueFrameTypeDropDownButton_OnClick;
	info.checked = LFDQueueFrame.type == info.value;
	UIDropDownMenu_AddButton(info);
	
	
	info.text = SPECIFIC_DUNGEONS;
	info.value = 2;
	info.func = LFDQueueFrameTypeDropDownButton_OnClick;
	info.checked = LFDQueueFrame.type == info.value;
	UIDropDownMenu_AddButton(info);
end

function LFDQueueFrameTypeDropDownButton_OnClick(self)
	LFDQueueFrame.type = self.value;
	UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, self.value);
	
	if ( self.value == 1 ) then
		LFDQueueFrame_SetTypeRandomDungeon();
	elseif ( self.value == 2 ) then
		LFDQueueFrame_SetTypeSpecificDungeon();
	end
end

function LFDQueueFrame_SetTypeRandomDungeon()
	LFDQueueFrameBackground:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-QUESTPAPER")
	LFDQueueFrameSpecific:Hide();
	LFDQueueFrameRandom:Show();
end

function LFDQueueFrame_SetTypeSpecificDungeon()
	LFDQueueFrameBackground:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-DUNGEONWALL");
	LFDQueueFrameRandom:Hide();
	LFDQueueFrameSpecific:Show();
end

--DEBUG FIXME
local fakeRandomLoot = {
	37711,
	37742,
	38644,
	37711,
	37742,
	38644,
	37711,
	37742,
	38644,
}

NUM_LFD_RANDOM_REWARD_FRAMES = 1;
function LFDQueueFrameRandom_UpdateFrame()
	local parentName = "LFDQueueFrameRandomScrollFrameChildFrame"
	local parentFrame = _G[parentName];
	
	local lastFrame;
	
	--DEBUG FIXME
	local numRewards = 1;
	
	for i=1, numRewards do
		local frame = _G[parentName.."Item"..i];
		if ( not frame ) then
			frame = CreateFrame("Button", parentName.."Item"..i, _G[parentName], "LargeItemButtonTemplate");
			NUM_LFD_RANDOM_REWARD_FRAMES = i;
			if ( mod(i, 2) == 0 ) then
				frame:SetPoint("LEFT", parentName.."Item"..(i-1), "RIGHT", 0, 0);
			else
				frame:SetPoint("TOPLEFT", parentName.."Item"..(i-2), "BOTTOMLEFT", 0, -5);
			end
		end
		--DEBUG FIXME
		local name, texture, numItems = GetItemInfo(fakeRandomLoot[i]), select(10, GetItemInfo(fakeRandomLoot[i])), i;
		
		_G[parentName.."Item"..i.."Name"]:SetText(name);
		SetItemButtonTexture(frame, texture);
		SetItemButtonCount(frame, numItems);
		frame:Show();
		lastFrame = frame;
	end
	for i=numRewards+1, NUM_LFD_RANDOM_REWARD_FRAMES do
		_G[parentName.."Item"..i]:Hide();
	end
	
	if ( numRewards >= 1 ) then
		parentFrame.rewardsDescription:Show();
		local relativeFrameNum = numRewards - mod(numRewards+1, 2);
		parentFrame.pugDescription:SetPoint("TOPLEFT", parentName.."Item"..relativeFrameNum, "BOTTOMLEFT", 0, -5);
	else
		parentFrame.rewardsDescription:Hide();
		parentFrame.pugDescription:SetPoint("TOPLEFT", parentFrame.rewardsLabel, "BOTTOMLEFT", 0, -5);
	end
	
	
	--DEBUG FIXME
	local moneyAmount = 7777777;
	local experienceGained = 1337;
	
	if ( moneyAmount > 0 or experienceGained > 0 ) then
		parentFrame.pugDescription:Show();
	else
		parentFrame.pugDescription:Hide();
	end
	
	if ( moneyAmount > 0 ) then
		MoneyFrame_Update(parentFrame.moneyFrame, moneyAmount);
		parentFrame.moneyLabel:Show();
		parentFrame.moneyFrame:Show()
		
		parentFrame.xpLabel:SetPoint("TOPLEFT", parentFrame.moneyLabel, "BOTTOMLEFT", 0, -5);
		
		lastFrame = parentFrame.moneyLabel;
	else
		parentFrame.moneyLabel:Hide();
		parentFrame.moneyFrame:Hide();
		
		parentFrame.xpLabel:SetPoint("TOPLEFT", parentFrame.pugDescription, "BOTTOMLEFT", 20, -10);
	end
	
	if ( experienceGained > 0 ) then
		parentFrame.xpAmount:SetText(experienceGained);
		
		parentFrame.xpLabel:Show();
		parentFrame.xpAmount:Show();
		
		lastFrame = parentFrame.xpLabel;
	else
		parentFrame.xpLabel:Hide();
		parentFrame.xpAmount:Hide();
	end
	
	parentFrame.spacer:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10);
end

--Queued status functions

local NUM_TANKS = 1;
local NUM_HEALERS = 1;
local NUM_DAMAGERS = 3;

function LFDSearchStatus_OnEvent(self, event, ...)
	if ( event == "LFG_QUEUE_STATUS_UPDATE" ) then
		LFDSearchStatus_Update();
	end
end

function LFDSearchStatusPlayer_SetFound(button, isFound)
	if ( isFound ) then
		SetDesaturation(button.texture, false);
		button.cover:Hide();
	else
		SetDesaturation(button.texture, true);
		button.cover:Show();
	end
end

function LFDSearchStatus_UpdateRoles()
	local leader, tank, healer, damage = GetLFGRoles();
	local currentIcon = 1;
	if ( tank ) then
		local icon = _G["LFDSearchStatusRoleIcon"..currentIcon]
		icon:SetTexCoord(GetTexCoordsForRole("TANK"));
		icon:Show();
		currentIcon = currentIcon + 1;
	end
	if ( healer ) then
		local icon = _G["LFDSearchStatusRoleIcon"..currentIcon]
		icon:SetTexCoord(GetTexCoordsForRole("HEALER"));
		icon:Show();
		currentIcon = currentIcon + 1;
	end
	if ( damage ) then
		local icon = _G["LFDSearchStatusRoleIcon"..currentIcon]
		icon:SetTexCoord(GetTexCoordsForRole("DAMAGE"));
		icon:Show();
		currentIcon = currentIcon + 1;
	end
	for i=currentIcon, LFD_NUM_ROLES do
		_G["LFDSearchStatusRoleIcon"..i]:Hide();
	end
	local extraWidth = 27*(currentIcon-1);
	LFDSearchStatusLookingFor:SetPoint("BOTTOM", -extraWidth/2, 14);
end

function LFDSearchStatus_Update()
	local LFDSearchStatus = LFDSearchStatus;
	local hasData,  leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, instanceType, instanceName, playersInQueue, partiesInQueue, averageWait, matchesMade, someTimeValue= GetLFGQueueStats();
	
	LFDSearchStatus_UpdateRoles();
	
	if ( not hasData ) then
		LFDSearchStatus:SetHeight(120);
		LFDSearchStatusPlayer_SetFound(LFDSearchStatusTank1, false)
		LFDSearchStatusPlayer_SetFound(LFDSearchStatusHealer1, false);
		for i=1, NUM_DAMAGERS do
			LFDSearchStatusPlayer_SetFound(_G["LFDSearchStatusDamage"..i], false);
		end
		LFDSearchStatus.statistic:Hide();
		return;
	else
		LFDSearchStatus:SetHeight(153);
	end
	
	if ( instancetype == TYPEID_HEROIC_DIFFICULTY ) then
		instanceName = format(HEROIC_PREFIX, instanceName);
	end
	
	--This won't work if we decide the makeup is, say, 3 healers, 1 damage, 1 tank.
	LFDSearchStatusPlayer_SetFound(LFDSearchStatusTank1, (tankNeeds == 0))
	LFDSearchStatusPlayer_SetFound(LFDSearchStatusHealer1, (healerNeeds == 0));
	for i=1, NUM_DAMAGERS do
		LFDSearchStatusPlayer_SetFound(_G["LFDSearchStatusDamage"..i], i <= (NUM_DAMAGERS - dpsNeeds));
	end
	
	if ( instanceType == TYPEID_RANDOM_DUNGEON ) then
		LFDSearchStatus.statistic:Hide();
	else
		LFDSearchStatus.statistic:Show();
		--Display a random statistic if the last displayed time was long enough ago
		local now = time();
		if ( not LFDSearchStatus.lastStatisticTime or (LFDSearchStatus.lastStatisticTime + LFD_STATISTIC_CHANGE_TIME < now) ) then
			LFDSearchStatus.displayedStatistic = math.random(1, 4)
			LFDSearchStatus.lastStatisticTime = now;
		end
		
		local statistic = LFDSearchStatus.displayedStatistic;
		if ( statistic == 2 ) then
			LFDSearchStatus.statistic:SetFormattedText(LFG_STATISTIC_PARTIES_IN_QUEUE, instanceName, partiesInQueue);
		elseif ( statistic == 3 and averageWait ~= 0 ) then --If the average wait is 0, we have no data for this instance, so showing it is useless.
			LFDSearchStatus.statistic:SetFormattedText(LFG_STATISTIC_AVERAGE_WAIT, instanceName, averageWait);
		elseif ( statistic == 4 ) then
			LFDSearchStatus.statistic:SetFormattedText(LFG_STATISTIC_MATCHES_MADE, instanceName, matchesMade);
		else
			LFDSearchStatus.statistic:SetFormattedText(LFG_STATISTIC_PLAYERS_IN_QUEUE, instanceName, playersInQueue);
		end
	end
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
	
	LFDQueueFrameSpecificList_Update();
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