EXPANSION_LEVEL = GetExpansionLevel(); --This doesn't change while logged in, so we just need to do it once.

LFD_MAX_REWARDS = 2;

NUM_LFD_CHOICE_BUTTONS = 15;
TYPEID_HEROIC_DIFFICULTY = 5;
TYPEID_RANDOM_DUNGEON = 6;

NUM_LFD_MEMBERS = 5;

LFD_STATISTIC_CHANGE_TIME = 10; --In secs.

LFD_PROPOSAL_FAILED_CLOSE_TIME = 5;

LFD_NUM_ROLES = 3;

LFD_MAX_SHOWN_LEVEL_DIFF = 15;

local NUM_STATISTIC_TYPES = 1;


-------------------------------------
-----------LFD Frame--------------
-------------------------------------

--General functions
function LFDFrame_OnLoad(self)
	self:RegisterEvent("LFG_PROPOSAL_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_SHOW");
	self:RegisterEvent("LFG_PROPOSAL_FAILED");
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LFG_ROLE_CHECK_SHOW");
	self:RegisterEvent("LFG_ROLE_CHECK_HIDE");
	self:RegisterEvent("LFG_BOOT_PROPOSAL_UPDATE");
	self:RegisterEvent("LFG_ROLE_UPDATE");
	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO");
end

function LFDFrame_OnEvent(self, event, ...)
	if ( event == "LFG_PROPOSAL_UPDATE" ) then
		LFDDungeonReadyPopup_Update();
	elseif ( event == "LFG_PROPOSAL_SHOW" ) then
		LFDDungeonReadyPopup.closeIn = nil;
		LFDDungeonReadyPopup:SetScript("OnUpdate", nil);
		StaticPopupSpecial_Show(LFDDungeonReadyPopup);
	elseif ( event == "LFG_PROPOSAL_FAILED" ) then
		LFDDungeonReadyPopup_OnFail();
	elseif ( event == "LFG_UPDATE" or event == "PLAYER_ENTERING_WORLD") then
		local inParty, joined, queued, noPartialClear, achievements, lfgComment, slotCount = GetLFGInfoServer();
		
		if ( not joined ) then
			StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
		end
	elseif ( event == "LFG_ROLE_CHECK_SHOW" ) then
		StaticPopupSpecial_Show(LFDRoleCheckPopup);
		LFDQueueFrameSpecificList_Update();
	elseif ( event == "LFG_ROLE_CHECK_HIDE" ) then
		StaticPopupSpecial_Hide(LFDRoleCheckPopup);
		LFDQueueFrameSpecificList_Update();
	elseif ( event == "LFG_BOOT_PROPOSAL_UPDATE" ) then
		local voteInProgress, didVote, myVote, targetName, totalVotes, bootVotes, timeLeft = GetLFGBootProposal();
		if ( voteInProgress and not didVote and targetName ) then
			StaticPopup_Show("VOTE_BOOT_PLAYER", targetName);
		else
			StaticPopup_Hide("VOTE_BOOT_PLAYER");
		end
	elseif ( event == "LFG_ROLE_UPDATE" ) then
		LFG_UpdateRoleCheckboxes();
	elseif ( event == "LFG_UPDATE_RANDOM_INFO" ) then
		if ( not LFDQueueFrame.type or (type(LFDQueueFrame.type) == "number" and not IsLFGDungeonJoinable(LFDQueueFrame.type)) ) then
			LFDQueueFrame.type = GetRandomDungeonBestChoice();
			UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, LFDQueueFrame.type);
		end
		--If we still don't have a value, we should go to specific.
		if ( not LFDQueueFrame.type ) then
			LFDQueueFrame.type = "specific";
			UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, LFDQueueFrame.type);
			LFDQueueFrame_SetTypeSpecificDungeon();
		elseif ( LFDQueueFrameRandom:IsShown() ) then
			LFDQueueFrameRandom_UpdateFrame();
		end
	end
end

--Role-related functions

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
	local oldLeader = GetLFGRoles();
	SetLFGRoles(oldLeader, 
		LFDRoleCheckPopupRoleButtonTank.checkButton:GetChecked(),
		LFDRoleCheckPopupRoleButtonHealer.checkButton:GetChecked(),
		LFDRoleCheckPopupRoleButtonDPS.checkButton:GetChecked());
	if ( CompleteLFGRoleCheck(true) ) then
		StaticPopupSpecial_Hide(LFDRoleCheckPopup);
	end
end

function LFDRoleCheckPopupDecline_OnClick()
	StaticPopupSpecial_Hide(LFDRoleCheckPopup);
	CompleteLFGRoleCheck(false);
end

function LFDRoleCheckPopup_Update()
	LFGDungeonList_Setup();
	
	LFG_UpdateRoleCheckboxes();
	
	local inProgress, slots, members = GetLFGRoleUpdate();
	
	local displayName;
	if ( slots == 1 ) then
		local dungeonType, dungeonID = GetLFGRoleUpdateSlot(1);
		if ( dungeonType == TYPEID_RANDOM_DUNGEON ) then
			displayName = A_RANDOM_DUNGEON;
		elseif ( dungeonType == TYPEID_HEROIC_DIFFICULTY ) then
			displayName = format(HEROIC_PREFIX, LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.name]);
		else
			displayName = LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.name];
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
			displayName = format(HEROIC_PREFIX, LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.name]);
		else
			displayName = LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.name];
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
function LFDQueueFrameSpecificListButton_SetDungeon(button, dungeonID, mode, submode)
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
		
		if ( mode == "rolecheck" or mode == "queued" or mode == "listed" or not LFG_IsEmpowered()) then
			button.instanceName:SetFontObject(QuestDifficulty_Header);
		else
			button.instanceName:SetFontObject(difficultyColor.font);
		end
		
		
		button.expandOrCollapseButton:Hide();
		
		button.isCollapsed = false;
	end
	
	if ( LFGLockList[dungeonID] ) then
		button.enableButton:Hide();
		button.lockedIndicator:Show();
	else
		button.enableButton:Show();
		button.lockedIndicator:Hide();
	end
	
	local enableState= LFGEnabledList;
	if ( mode == "queued" or mode == "listed" ) then
		enableState = LFGQueuedForList[dungeonID];
	else
		enableState = LFGEnabledList[dungeonID];
	end
	
	if ( enableState == 1 ) then	--Some are checked, some aren't.
		button.enableButton:SetCheckedTexture("Interface\\Buttons\\UI-MultiCheck-Up");
		button.enableButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-MultiCheck-Disabled");
	else
		button.enableButton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
		button.enableButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
	end
	button.enableButton:SetChecked(enableState and enableState ~= 0);
	
	if ( mode == "rolecheck" or mode == "queued" or mode == "listed" or not LFG_IsEmpowered() ) then
		button.enableButton:Disable();
	else
		button.enableButton:Enable();
	end
end

function LFDQueueFrameSpecificList_Update()
	if ( LFGDungeonList_Setup() ) then
		return;	--Setup will update the list.
	end
	FauxScrollFrame_Update(LFDQueueFrameSpecificListScrollFrame, LFDGetNumDungeons(), NUM_LFD_CHOICE_BUTTONS, 16);
	
	local offset = FauxScrollFrame_GetOffset(LFDQueueFrameSpecificListScrollFrame);
	
	local areButtonsBig = not LFDQueueFrameSpecificListScrollFrame:IsShown();
	
	local mode, subMode = GetLFGMode();
	
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
			LFDQueueFrameSpecificListButton_SetDungeon(button, dungeonID, mode, subMode);
		else
			button:Hide();
		end
	end
end

function LFDList_SetHeaderCollapsed(headerID, isCollapsed)
	SetLFGHeaderCollapsed(headerID, isCollapsed);
	LFGCollapseList[headerID] = isCollapsed;
	for _, dungeonID in pairs(LFDDungeonList) do
		if ( LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.groupID] == headerID ) then
			LFGCollapseList[dungeonID] = isCollapsed;
		end
	end
	for _, dungeonID in pairs(LFDHiddenByCollapseList) do
		if ( LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.groupID] == headerID ) then
			LFGCollapseList[dungeonID] = isCollapsed;
		end
	end
	LFDQueueFrame_Update();
end

function LFDQueueFrame_QueueForInstanceIfEnabled(queueID)
	if ( not LFGIsIDHeader(queueID) and LFGEnabledList[queueID] and not LFGLockList[queueID] ) then
		local info = LFGGetDungeonInfoByID(queueID);
		SetLFGDungeon(info[LFG_RETURN_VALUES.typeID], queueID);
		return true;
	end
	return false;
end

function LFDQueueFrame_Join()
	if ( LFDQueueFrame.type == "specific" ) then	--Random queue
		ClearAllLFGDungeons();
		for _, queueID in pairs(LFDDungeonList) do
			LFDQueueFrame_QueueForInstanceIfEnabled(queueID);
		end
		for _, queueID in pairs(LFDHiddenByCollapseList) do
			LFDQueueFrame_QueueForInstanceIfEnabled(queueID);
		end
		JoinLFG();
	else
		ClearAllLFGDungeons();
		SetLFGDungeon(TYPEID_RANDOM_DUNGEON, LFDQueueFrame.type);
		JoinLFG();
	end
end

function LFDQueueFrameDungeonChoiceEnableButton_OnClick(self, button)
	local parent = self:GetParent();
	local dungeonID = parent.id;
	local isChecked = self:GetChecked();
	
	if ( LFGIsIDHeader(dungeonID) ) then
		LFDList_SetHeaderEnabled(dungeonID, isChecked);
	else
		LFDList_SetDungeonEnabled(dungeonID, isChecked);
		LFGListUpdateHeaderEnabledAndLockedStates(LFDDungeonList, LFGEnabledList, LFGLockList, LFDHiddenByCollapseList);
	end
	LFDQueueFrameSpecificList_Update();
end

function LFDList_SetDungeonEnabled(dungeonID, isEnabled)
	SetLFGDungeonEnabled(dungeonID, isEnabled);
	LFGEnabledList[dungeonID] = not not isEnabled; --Change to true/false.
end

function LFDList_SetHeaderEnabled(headerID, isEnabled)
	for _, dungeonID in pairs(LFDDungeonList) do
		if ( LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.groupID] == headerID ) then
			LFDList_SetDungeonEnabled(dungeonID, isEnabled);
		end
	end
	for _, dungeonID in pairs(LFDHiddenByCollapseList) do
		if ( LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.groupID] == headerID ) then
			LFDList_SetDungeonEnabled(dungeonID, isEnabled);
		end
	end
	LFGEnabledList[headerID] = not not isEnabled; --Change to true/false.
end

function LFDQueueFrameDungeonLockedIndicator_OnEnter(self)
	local dungeonID = self:GetParent().id;
	if ( LFGIsIDHeader(dungeonID) ) then
		--GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		--GameTooltip:AddLine(YOU_MAY_NOT_QUEUE_FOR_CATEGORY, 1.0, 1.0, 1.0);
		--GameTooltip:Show();
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:AddLine(YOU_MAY_NOT_QUEUE_FOR_DUNGEON, 1.0, 1.0, 1.0);
		for i=1, GetLFDLockPlayerCount() do
			local playerName, lockedReason = GetLFDLockInfo(dungeonID, i);
			if ( lockedReason ~= 0 ) then
				local who;
				if ( i == 1 ) then
					who = "SELF_";
				else
					who = "OTHER_";
				end
				GameTooltip:AddLine(format(_G["INSTANCE_UNAVAILABLE_"..who..(LFG_INSTANCE_INVALID_CODES[lockedReason] or "OTHER")], playerName));
			end
		end
		GameTooltip:Show();
	end
end

function LFDQueueFrameExpandOrCollapseButton_OnClick(self, button)
	local parent = self:GetParent();
	LFDList_SetHeaderCollapsed(parent.id, not parent.isCollapsed);
end

--Ready popup functions

function LFDDungeonReadyPopup_OnFail()
	if ( LFDDungeonReadyDialog:IsShown() ) then
		StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
	elseif ( LFDDungeonReadyPopup:IsShown() ) then
		LFDDungeonReadyPopup.closeIn = LFD_PROPOSAL_FAILED_CLOSE_TIME;
		LFDDungeonReadyPopup:SetScript("OnUpdate", LFDDungeonReadyPopup_OnUpdate);
	end
end

function LFDDungeonReadyPopup_OnUpdate(self, elapsed)
	self.closeIn = self.closeIn - elapsed;
	if ( self.closeIn < 0 ) then	--We remove the OnUpdate and closeIn OnHide
		StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
	end
end

function LFDDungeonReadyPopup_Update()	
	local proposalExists, typeID, id, name, texture, role, hasResponded, totalEncounters, completedEncounters, numMembers = GetLFGProposal();

	if ( not proposalExists ) then
		StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
		return;
	end
	
	LFDDungeonReadyPopup.dungeonID = id;
	
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
			LFDDungeonReadyDialog.background:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-RANDOMDUNGEON");
			
			LFDDungeonReadyDialog.label:SetText(RANDOM_DUNGEON_IS_READY);
			
			LFDDungeonReadyDialog.instanceInfo:Hide();
			
			if ( completedEncounters > 0 ) then
				LFDDungeonReadyDialog.randomInProgress:Show();
				LFDDungeonReadyPopup:SetHeight(223);
				LFDDungeonReadyDialog.background:SetTexCoord(0, 1, 0, 1);
			else
				LFDDungeonReadyDialog.randomInProgress:Hide();
				LFDDungeonReadyPopup:SetHeight(193);
				LFDDungeonReadyDialog.background:SetTexCoord(0, 1, 0, 118/128);
			end
		else
			LFDDungeonReadyDialog.randomInProgress:Hide();
			LFDDungeonReadyPopup:SetHeight(223);
			LFDDungeonReadyDialog.background:SetTexCoord(0, 1, 0, 1);
			texture = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-"..texture;
			LFDDungeonReadyDialog.background:SetTexture(texture);
			if ( LFDDungeonReadyDialog.background:GetTexture() ~= texture ) then	--We haven't added this texture yet. Default to the Deadmines.
				LFDDungeonReadyDialog.background:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-Deadmines");	--DEBUG FIXME Default probably shouldn't be Deadmines
			end
			
			LFDDungeonReadyDialog.label:SetText(SPECIFIC_DUNGEON_IS_READY);
			LFDDungeonReadyDialog_UpdateInstanceInfo(name, completedEncounters, totalEncounters);
			LFDDungeonReadyDialog.instanceInfo:Show();
		end

		
		LFDDungeonReadyDialogRoleIconTexture:SetTexCoord(GetTexCoordsForRole(role));
		LFDDungeonReadyDialogRoleLabel:SetText(_G[role]);
		
		LFDDungeonReadyDialog_UpdateRewards(id);
	end
end

function LFDDungeonReadyDialog_UpdateRewards(dungeonID)
	local doneToday, moneyBase, moneyVar, experienceBase, experienceVar, numRewards = GetLFGDungeonRewards(dungeonID);
	
	local numRandoms = 4 - GetNumPartyMembers();
	local moneyAmount = moneyBase + moneyVar * numRandoms;
	local experienceGained = experienceBase + experienceVar * numRandoms;
	
	local rewardsOffset = 0;

	if ( moneyAmount > 0 or experienceGained > 0 ) then --hasMiscReward ) then
		LFDDungeonReadyDialogReward_SetMisc(LFDDungeonReadyDialogRewardsFrameReward1);
		rewardsOffset = 1;
	end
	
	if ( moneyAmount == 0 and experienceGained == 0 and numRewards == 0 ) then
		LFDDungeonReadyDialogRewardsFrameLabel:Hide();
	else
		LFDDungeonReadyDialogRewardsFrameLabel:Show();
	end

	
	for i = 1, numRewards do
		local frameID = (i + rewardsOffset);
		local frame = _G["LFDDungeonReadyDialogRewardsFrameReward"..frameID];
		if ( not frame ) then
			frame = CreateFrame("FRAME", "LFDDungeonReadyDialogRewardsFrameReward"..frameID, LFDDungeonReadyDialogRewardsFrame, LFDDungeonReadyRewardTemplate);
			frame:SetID(frameID);
			LFD_MAX_REWARDS = frameID;
		end
		LFDDungeonReadyDialogReward_SetReward(frame, dungeonID, i)
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
	button:Show();
end

function LFDDungeonReadyDialogReward_SetReward(button, dungeonID, rewardIndex)
	local name, texturePath, quantity = GetLFGDungeonRewardInfo(dungeonID, rewardIndex);
	if ( texturePath ) then	--Otherwise, we may be waiting on the item data to come from the server.
		SetPortraitToTexture(button.texture, texturePath);
	end
	button.rewardID = rewardIndex;
	button:Show();
end
	
function LFDDungeonReadyDialogReward_OnEnter(self, dungeonID)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( self.rewardID == 0 ) then
		GameTooltip:AddLine(REWARD_ITEMS_ONLY);
		local doneToday, moneyBase, moneyVar, experienceBase, experienceVar, numRewards = GetLFGDungeonRewards(LFDDungeonReadyPopup.dungeonID);
		local numRandoms = 4 - GetNumPartyMembers();
		local moneyAmount = moneyBase + moneyVar * numRandoms;
		local experienceGained = experienceBase + experienceVar * numRandoms;
		
		if ( experienceGained > 0 ) then
			GameTooltip:AddLine(string.format(GAIN_EXPERIENCE, experienceGained));
		end
		if ( moneyAmount > 0 ) then
			SetTooltipMoney(GameTooltip, moneyAmount, nil);
		end
	else
		GameTooltip:SetLFGDungeonReward(LFDDungeonReadyPopup.dungeonID, self.rewardID);
	end
	GameTooltip:Show();
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
			GameTooltip:AddDoubleLine(bossName, BOSS_DEAD, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			GameTooltip:AddDoubleLine(bossName, BOSS_ALIVE, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
		end
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

function LFDQueueFrameTypeDropDown_SetUp(self)
	UIDropDownMenu_SetWidth(self, 180);
	UIDropDownMenu_Initialize(self, LFDQueueFrameTypeDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, LFDQueueFrame.type);
end

local function isRandomDungeonDisplayable(id)
	local name, typeID, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(id);
	local myLevel = UnitLevel("player");
	return myLevel >= minLevel and myLevel <= maxLevel and EXPANSION_LEVEL >= expansionLevel;
end

function LFDQueueFrameTypeDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = SPECIFIC_DUNGEONS;
	info.value = "specific";
	info.func = LFDQueueFrameTypeDropDownButton_OnClick;
	info.checked = LFDQueueFrame.type == info.value;
	UIDropDownMenu_AddButton(info);
	
	for i=1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i);
		local isAvailable = IsLFGDungeonJoinable(id);
		if ( isRandomDungeonDisplayable(id) ) then
			if ( isAvailable ) then		
				info.text = name;
				info.value = id;
				info.isTitle = nil;
				info.func = LFDQueueFrameTypeDropDownButton_OnClick;
				info.disabled = nil;
				info.checked = (LFDQueueFrame.type == info.value);
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
				info.tooltipText = LFDConstructDeclinedMessage(id);
				UIDropDownMenu_AddButton(info);
			end
		end
	end
end

function LFDQueueFrameTypeDropDownButton_OnClick(self)
	LFDQueueFrame.type = self.value;
	UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, self.value);
	
	if ( self.value == "specific" ) then
		LFDQueueFrame_SetTypeSpecificDungeon();
	else
		LFDQueueFrame_SetTypeRandomDungeon();
		LFDQueueFrameRandom_UpdateFrame();
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

function LFDConstructDeclinedMessage(dungeonID)
	local returnVal;
	for i=1, GetLFDLockPlayerCount() do
		local playerName, lockedReason = GetLFDLockInfo(dungeonID, i);
		if ( lockedReason ~= 0 ) then
			local who;
			if ( i == 1 ) then
				who = "SELF_";
			else
				who = "OTHER_";
			end
			if ( returnVal ) then
				returnVal = returnVal.."\n"..format(_G["INSTANCE_UNAVAILABLE_"..who..(LFG_INSTANCE_INVALID_CODES[lockedReason] or "OTHER")], playerName);
			else
				returnVal = format(_G["INSTANCE_UNAVAILABLE_"..who..(LFG_INSTANCE_INVALID_CODES[lockedReason] or "OTHER")], playerName);
			end
		end
	end
	return returnVal;
end

NUM_LFD_RANDOM_REWARD_FRAMES = 1;
function LFDQueueFrameRandom_UpdateFrame()
	local parentName = "LFDQueueFrameRandomScrollFrameChildFrame"
	local parentFrame = _G[parentName];
	
	local dungeonID = LFDQueueFrame.type;
	
	if ( not dungeonID ) then	--We haven't gotten info on available dungeons yet.
		return;
	end
	
	local isHeroic = select(11, GetLFGDungeonInfo(dungeonID)) > 0;
	local doneToday, moneyBase, moneyVar, experienceBase, experienceVar, numRewards = GetLFGDungeonRewards(dungeonID);
	local numRandoms = 4 - GetNumPartyMembers();
	local moneyAmount = moneyBase + moneyVar * numRandoms;
	local experienceGained = experienceBase + experienceVar * numRandoms;
	
		
	if ( isHeroic ) then
		LFDQueueFrameBackground:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-HEROIC");
	else
		LFDQueueFrameBackground:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-QUESTPAPER");
	end
	
	local lastFrame = parentFrame.rewardsLabel;
	if ( doneToday ) then
		parentFrame.rewardsDescription:SetText(LFD_RANDOM_REWARD_EXPLANATION2);
	else
		parentFrame.rewardsDescription:SetText(LFD_RANDOM_REWARD_EXPLANATION1);
	end
		
	for i=1, numRewards do
		local frame = _G[parentName.."Item"..i];
		if ( not frame ) then
			frame = CreateFrame("Button", parentName.."Item"..i, _G[parentName], "LFDRandomDungeonLootTemplate");
			frame:SetID(i);
			NUM_LFD_RANDOM_REWARD_FRAMES = i;
			if ( mod(i, 2) == 0 ) then
				frame:SetPoint("LEFT", parentName.."Item"..(i-1), "RIGHT", 0, 0);
			else
				frame:SetPoint("TOPLEFT", parentName.."Item"..(i-2), "BOTTOMLEFT", 0, -5);
			end
		end

		local name, texture, numItems = GetLFGDungeonRewardInfo(dungeonID, i);
		
		_G[parentName.."Item"..i.."Name"]:SetText(name);
		SetItemButtonTexture(frame, texture);
		SetItemButtonCount(frame, numItems);
		frame:Show();
		lastFrame = frame;
	end
	for i=numRewards+1, NUM_LFD_RANDOM_REWARD_FRAMES do
		_G[parentName.."Item"..i]:Hide();
	end
	
	if ( numRewards > 0 or ((moneyVar == 0 and experienceVar == 0) and (moneyAmount > 0 or experienceGained > 0)) ) then
		parentFrame.rewardsDescription:Show();
		lastFrame = parentFrame.rewardsDescription;
	else
		parentFrame.rewardsDescription:Hide();
	end
	
	if ( numRewards > 0 ) then
		lastFrame = _G[parentName.."Item"..(numRewards - mod(numRewards+1, 2))];
	end
	
	if ( moneyVar > 0 or experienceVar > 0 ) then
		parentFrame.pugDescription:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -5);
		parentFrame.pugDescription:Show();
		lastFrame = parentFrame.pugDescription;
	else
		parentFrame.pugDescription:Hide();
	end
	
	if ( moneyAmount > 0 ) then
		MoneyFrame_Update(parentFrame.moneyFrame, moneyAmount);
		parentFrame.moneyLabel:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 20, -10);
		parentFrame.moneyLabel:Show();
		parentFrame.moneyFrame:Show()
		
		parentFrame.xpLabel:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -5);
		
		lastFrame = parentFrame.moneyLabel;
	else
		parentFrame.moneyLabel:Hide();
		parentFrame.moneyFrame:Hide();
		
	end
	
	if ( experienceGained > 0 ) then
		parentFrame.xpAmount:SetText(experienceGained);
		
		if ( lastFrame == parentFrame.moneyLabel ) then
			parentFrame.xpLabel:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -5);
		else
			parentFrame.xpLabel:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 20, -10);
		end
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
		icon:SetTexCoord(GetTexCoordsForRole("DAMAGER"));
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
	local hasData,  leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, instanceType, instanceName, averageWait = GetLFGQueueStats();
	
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
		if ( instanceType == TYPEID_RANDOM_DUNGEON ) then
			LFDSearchStatus:SetHeight(120);
		else
			LFDSearchStatus:SetHeight(153);
		end
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
			LFDSearchStatus.displayedStatistic = math.random(1, NUM_STATISTIC_TYPES);
			LFDSearchStatus.lastStatisticTime = now;
		end
		
		local statistic = LFDSearchStatus.displayedStatistic;
		if ( statistic == 1 ) then --If the average wait is 0, we have no data for this instance, so showing it is useless.
			if ( averageWait ~= 0 ) then
				LFDSearchStatus.statistic:SetFormattedText(LFG_STATISTIC_AVERAGE_WAIT, instanceName, SecondsToTime(averageWait, false, false, 1));
			else
				LFDSearchStatus.statistic:SetFormattedText(LFG_STATISTIC_AVERAGE_WAIT_UNKNOWN, instanceName);
			end
		end
	end
end

function LFDQueueFrameFindGroupButton_Update()
	local mode, subMode = GetLFGMode();
	if ( mode == "queued" or mode == "rolecheck" or mode == "proposal") then
		LFDQueueFrameFindGroupButton:SetText(LEAVE_QUEUE);
	else
		if ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 ) then
			LFDQueueFrameFindGroupButton:SetText(JOIN_AS_PARTY);
		else
			LFDQueueFrameFindGroupButton:SetText(FIND_A_GROUP);
		end
	end
	
	if ( LFG_IsEmpowered() and mode ~= "proposal" and mode ~= "listed" ) then --During the proposal, they must use the proposal buttons to leave the queue.
		LFDQueueFrameFindGroupButton:Enable();
		LFRQueueFrameNoLFRWhileLFDLeaveQueueButton:Enable();
	else
		LFDQueueFrameFindGroupButton:Disable();
		LFRQueueFrameNoLFRWhileLFDLeaveQueueButton:Disable();
	end
end

LFDHiddenByCollapseList = {};
function LFDQueueFrame_Update()
	local enableList;
	
	local mode, submode = GetLFGMode();
	
	if ( LFG_IsEmpowered() and mode ~= "queued") then
		enableList = LFGEnabledList;
	else
		enableList = LFGQueuedForList;
	end
	
	LFDDungeonList = GetLFDChoiceOrder(LFDDungeonList);
		
	LFGQueueFrame_UpdateLFGDungeonList(LFDDungeonList, LFDHiddenByCollapseList, LFGLockList, LFGDungeonInfo, enableList, LFGCollapseList, LFD_CURRENT_FILTER);
	
	LFDQueueFrameSpecificList_Update();
end

function LFDList_DefaultFilterFunction(dungeonID)
	local info = LFGGetDungeonInfoByID(dungeonID)
	local hasHeader = info[LFG_RETURN_VALUES.groupID] ~= 0;
	local sufficientExpansion = EXPANSION_LEVEL >= info[LFG_RETURN_VALUES.expansionLevel];
	local level = UnitLevel("player");
	local sufficientLevel = level >= info[LFG_RETURN_VALUES.minLevel] and level <= info[LFG_RETURN_VALUES.maxLevel];
	return (hasHeader and sufficientExpansion and sufficientLevel) and
		( level - LFD_MAX_SHOWN_LEVEL_DIFF <= info[LFG_RETURN_VALUES.recLevel] or (LFGLockList and not LFGLockList[dungeonID]));	--If the server tells us we can join, who are we to complain?
end

LFD_CURRENT_FILTER = LFDList_DefaultFilterFunction
