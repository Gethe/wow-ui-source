EXPANSION_LEVEL = GetExpansionLevel(); --This doesn't change while logged in, so we just need to do it once.

LFD_MAX_REWARDS = 2;

NUM_LFD_CHOICE_BUTTONS = 15;

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
	--self:RegisterEvent("LFG_PROPOSAL_UPDATE");
	--self:RegisterEvent("LFG_PROPOSAL_SHOW");
	--self:RegisterEvent("LFG_PROPOSAL_FAILED");
	--self:RegisterEvent("LFG_PROPOSAL_SUCCEEDED");
	--self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LFG_ROLE_CHECK_SHOW");
	self:RegisterEvent("LFG_ROLE_CHECK_HIDE");
	self:RegisterEvent("LFG_BOOT_PROPOSAL_UPDATE");
	self:RegisterEvent("VOTE_KICK_REASON_NEEDED");
	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO");
	self:RegisterEvent("LFG_OPEN_FROM_GOSSIP");
	
	ButtonFrameTemplate_HideAttic(self);
	self.Inset:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 2, 284);
	self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 26);
end

function LFDFrame_OnEvent(self, event, ...)
	if ( event == "LFG_ROLE_CHECK_SHOW" ) then
		StaticPopupSpecial_Show(LFDRoleCheckPopup);
		LFDQueueFrameSpecificList_Update();
	elseif ( event == "LFG_ROLE_CHECK_HIDE" ) then
		StaticPopupSpecial_Hide(LFDRoleCheckPopup);
		LFDQueueFrameSpecificList_Update();
	elseif ( event == "LFG_BOOT_PROPOSAL_UPDATE" ) then
		local voteInProgress, didVote, myVote, targetName, totalVotes, bootVotes, timeLeft, reason = GetLFGBootProposal();
		if ( voteInProgress and not didVote and targetName ) then
			StaticPopup_Show("VOTE_BOOT_PLAYER", targetName, reason);
		else
			StaticPopup_Hide("VOTE_BOOT_PLAYER");
		end
	elseif ( event == "VOTE_KICK_REASON_NEEDED" ) then
		local targetName, targetGUID = ...;
		StaticPopup_Show("VOTE_BOOT_REASON_REQUIRED", targetName, nil, targetGUID);
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
	elseif ( event == "LFG_OPEN_FROM_GOSSIP" ) then
		local dungeonID = ...;
		PVEFrame_ShowFrame("GroupFinderFrame", LFDParentFrame);
		LFDQueueFrame_SetType(dungeonID);
	end
end

function LFDFrame_OnShow(self)
	LFDFrame_UpdateBackfill(true);
end

--Backfill option
function LFDFrame_UpdateBackfill(forceUpdate)
	if ( CanPartyLFGBackfill() ) then
		local currentSubtypeID = select(LFG_RETURN_VALUES.subtypeID, GetLFGDungeonInfo(GetPartyLFGID()));
		if ( currentSubtypeID ~= LFG_SUBTYPEID_RAID ) then
			local name, lfgID, typeID = GetPartyLFGBackfillInfo();
			LFDQueueFramePartyBackfillDescription:SetFormattedText(LFG_OFFER_CONTINUE, HIGHLIGHT_FONT_COLOR_CODE..name.."|r");
			local mode, subMode = GetLFGMode();
			if ( (forceUpdate or not LFDQueueFrame:IsVisible()) and mode ~= "queued" and mode ~= "suspended" ) then
				LFDQueueFramePartyBackfill:Show();
			end
		else
			LFDQueueFramePartyBackfill:Hide();
		end
	else
		LFDQueueFramePartyBackfill:Hide();
	end
	LFDQueueFrameRandomCooldownFrame_Update();	--The cooldown frame won't show if the backfill is shown, so we need to update it.
end

--Role-related functions

function LFDQueueFrame_SetRoles()
	SetLFGRoles(LFDQueueFrameRoleButtonLeader.checkButton:GetChecked(), 
		LFDQueueFrameRoleButtonTank.checkButton:GetChecked(),
		LFDQueueFrameRoleButtonHealer.checkButton:GetChecked(),
		LFDQueueFrameRoleButtonDPS.checkButton:GetChecked());
end

function LFDQueueFrame_GetRoles()
	return LFDQueueFrameRoleButtonLeader.checkButton:GetChecked(), 
		LFDQueueFrameRoleButtonTank.checkButton:GetChecked(),
		LFDQueueFrameRoleButtonHealer.checkButton:GetChecked(),
		LFDQueueFrameRoleButtonDPS.checkButton:GetChecked();
end

function LFDFrameRoleCheckButton_OnClick(self)
	LFDQueueFrame_SetRoles();
	LFDQueueFrameRandom_UpdateFrame();	--We may show or hide shortage rewards.
end

function LFDQueueFrame_UpdateRoleIncentives()
	local dungeonID = LFDQueueFrame.type;
	LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonTank, nil);
	LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonHealer, nil);
	LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonDPS, nil);
	
	if ( type(dungeonID) == "number" ) then
		for i=1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount, money, xp = GetLFGRoleShortageRewards(dungeonID, i);
			if ( eligible and (itemCount ~= 0 or money ~= 0 or xp ~= 0) ) then	--Only show the icon if there is actually a reward.
				if ( forTank ) then
					LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonTank, i);
				end
				if ( forHealer ) then
					LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonHealer, i);
				end
				if ( forDamage ) then
					LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonDPS, i);
				end
			end
		end
	end
end

--Role-check popup functions
function LFDRoleCheckPopupAccept_OnClick()
	PlaySound("igCharacterInfoTab");
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
	PlaySound("igCharacterInfoTab");
	StaticPopupSpecial_Hide(LFDRoleCheckPopup);
	CompleteLFGRoleCheck(false);
end

function LFDRoleCheckPopup_Update()
	LFGDungeonList_Setup();
	
	LFG_UpdateRoleCheckboxes();
	
	local inProgress, slots, members = GetLFGRoleUpdate();
	
	local displayName;
	if ( slots == 1 ) then
		local dungeonID, dungeonType, dungeonSubType = GetLFGRoleUpdateSlot(1);
		if ( dungeonSubType == LFG_SUBTYPEID_HEROIC ) then
			displayName = format(HEROIC_PREFIX, select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(dungeonID)));
		else
			displayName = select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(dungeonID));
		end
	else
		displayName = MULTIPLE_DUNGEONS;
	end
	displayName = NORMAL_FONT_COLOR_CODE..displayName.."|r";
	
	LFDRoleCheckPopupDescriptionText:SetFormattedText(QUEUED_FOR, displayName);
	
	LFDRoleCheckPopupDescription:SetWidth(LFDRoleCheckPopupDescriptionText:GetWidth()+10);
	LFDRoleCheckPopupDescription:SetHeight(LFDRoleCheckPopupDescriptionText:GetHeight());
end

function LFDRoleCheckPopupDescription_OnEnter(self)
	local inProgress, slots, members = GetLFGRoleUpdate();
	
	if ( slots <= 1 ) then
		return;
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
	GameTooltip:AddLine(QUEUED_FOR_SHORT);
	
	for i=1, slots do
		local dungeonID, dungeonType, dungeonSubType = GetLFGRoleUpdateSlot(i);
		local displayName;
		if ( dungeonSubType == LFG_SUBTYPEID_HEROIC ) then
			displayName = format(HEROIC_PREFIX, select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(dungeonID)));
		else
			displayName = select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(dungeonID));
		end
		GameTooltip:AddLine("    "..displayName);
	end
	GameTooltip:Show();
end

--List functions
function LFDQueueFrameSpecificListButton_SetDungeon(button, dungeonID, mode, submode)
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
		
		if ( mode == "rolecheck" or mode == "queued" or mode == "listed" or mode == "suspended" or not LFD_IsEmpowered()) then
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
	if ( mode == "queued" or mode == "listed" or mode == "suspended" ) then
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
	
	if ( mode == "rolecheck" or mode == "queued" or mode == "listed" or mode == "suspended" or not LFD_IsEmpowered() ) then
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
		if ( select(LFG_RETURN_VALUES.groupID, GetLFGDungeonInfo(dungeonID)) == headerID ) then
			LFGCollapseList[dungeonID] = isCollapsed;
		end
	end
	for _, dungeonID in pairs(LFDHiddenByCollapseList) do
		if ( select(LFG_RETURN_VALUES.groupID, GetLFGDungeonInfo(dungeonID)) == headerID ) then
			LFGCollapseList[dungeonID] = isCollapsed;
		end
	end
	LFDQueueFrame_Update();
end

function LFDQueueFrame_QueueForInstanceIfEnabled(queueID)
	if ( not LFGIsIDHeader(queueID) and LFGEnabledList[queueID] and not LFGLockList[queueID] ) then
		SetLFGDungeon(queueID);
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
	elseif ( LFDQueueFrame.type ) then
		ClearAllLFGDungeons();
		SetLFGDungeon(LFDQueueFrame.type);
		JoinLFG();
	end
end

function LFDQueueFrameDungeonChoiceEnableButton_OnClick(self, button)
	local parent = self:GetParent();
	local dungeonID = parent.id;
	local isChecked = self:GetChecked();
	
	PlaySound(isChecked and "igMainMenuOptionCheckBoxOff" or "igMainMenuOptionCheckBoxOff");
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
		if ( select(LFG_RETURN_VALUES.groupID, GetLFGDungeonInfo(dungeonID)) == headerID ) then
			LFDList_SetDungeonEnabled(dungeonID, isEnabled);
		end
	end
	for _, dungeonID in pairs(LFDHiddenByCollapseList) do
		if ( select(LFG_RETURN_VALUES.groupID, GetLFGDungeonInfo(dungeonID)) == headerID ) then
			LFDList_SetDungeonEnabled(dungeonID, isEnabled);
		end
	end
	LFGEnabledList[headerID] = not not isEnabled; --Change to true/false.
end

function LFDQueueFrameDungeonListButton_OnEnter(self)
	local dungeonID = self.id;
	if ( self.lockedIndicator:IsShown() ) then
		if ( LFGIsIDHeader(dungeonID) ) then
			--GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			--GameTooltip:AddLine(YOU_MAY_NOT_QUEUE_FOR_CATEGORY, 1.0, 1.0, 1.0);
			--GameTooltip:Show();
		else
			GameTooltip:SetOwner(self, "ANCHOR_TOP");
			GameTooltip:AddLine(YOU_MAY_NOT_QUEUE_FOR_DUNGEON, 1.0, 1.0, 1.0);
			for i=1, GetLFDLockPlayerCount() do
				local playerName, lockedReason, subReason1, subReason2 = GetLFDLockInfo(dungeonID, i);
				if ( lockedReason ~= 0 ) then
					local who;
					if ( i == 1 ) then
						who = "SELF_";
					else
						who = "OTHER_";
					end
					GameTooltip:AddLine(format(_G["INSTANCE_UNAVAILABLE_"..who..(LFG_INSTANCE_INVALID_CODES[lockedReason] or "OTHER")], playerName, subReason1, subReason2));
				end
			end
			GameTooltip:Show();
		end
	end
end

function LFDQueueFrameExpandOrCollapseButton_OnClick(self, button)
	local parent = self:GetParent();
	LFDList_SetHeaderCollapsed(parent.id, not parent.isCollapsed);
end

function LFDQueueFrameTypeDropDown_SetUp(self)
	UIDropDownMenu_SetWidth(self, 180);
	UIDropDownMenu_Initialize(self, LFDQueueFrameTypeDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, LFDQueueFrame.type);
end

local function isRandomDungeonDisplayable(id)
	local name, typeID, subtypeID, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(id);
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
		if ( isRandomDungeonDisplayable(id) ) then
			local isAvailable = IsLFGDungeonJoinable(id);
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
				info.tooltipText = LFGConstructDeclinedMessage(id);
				UIDropDownMenu_AddButton(info);
			end
		end
	end
end

function LFDQueueFrameTypeDropDownButton_OnClick(self)
	LFDQueueFrame_SetType(self.value);
end

function LFDQueueFrame_SetType(value)	--"specific" for the list or the record id for a single dungeon
	LFDQueueFrame.type = value;
	UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, value);
	
	if ( value == "specific" ) then
		LFDQueueFrame_SetTypeSpecificDungeon();
	else
		LFDQueueFrame_SetTypeRandomDungeon();
		LFDQueueFrameRandom_UpdateFrame();
	end
	LFDQueueFrame_UpdateRoleIncentives();
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

function LFDQueueFrameRandom_UpdateFrame()
	local dungeonID = LFDQueueFrame.type;
	
	if ( type(dungeonID) ~= "number" ) then	--We haven't gotten info on available dungeons yet.
		return;
	end
	
	LFGRewardsFrame_UpdateFrame(LFDQueueFrameRandomScrollFrameChildFrame, dungeonID, LFDQueueFrameBackground);
	LFDQueueFrame_UpdateRoleIncentives();
end

function LFDQueueFrameRandomRandomList_OnEnter(self)
	local randomID = LFDQueueFrame.type;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(INCLUDED_DUNGEONS, 1, 1, 1);
	
	local numDungeons = GetNumDungeonForRandomSlot(randomID);
	
	if ( numDungeons == 0 ) then
		GameTooltip:AddLine(INCLUDED_DUNGEONS_EMPTY, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	else
		GameTooltip:AddLine(INCLUDED_DUNGEONS_SUBTEXT, nil, nil, nil, true);
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

function LFDQueueFrameRandomCooldownFrame_OnLoad(self)
	self:SetFrameLevel(LFDQueueFrame:GetFrameLevel() + 9);	--This value also needs to be set when SetParent is called in LFDQueueFrameRandomCooldownFrame_Update.
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD");	--For logging in/reloading ui
	self:RegisterEvent("UNIT_AURA");	--The cooldown is still technically a debuff
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
end

function LFDQueueFrameRandomCooldownFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event ~= "UNIT_AURA" or arg1 == "player" or strsub(arg1, 1, 5) == "party" ) then
		LFDQueueFrameRandomCooldownFrame_Update();
	end
end

function LFDQueueFrameRandomCooldownFrame_Update()
	local cooldownFrame = LFDQueueFrameCooldownFrame;
	local shouldShow = false;
	local hasDeserter = false; --If we have deserter, we want to show this over the specific frame as well as the random frame.
	
	local deserterExpiration = GetLFGDeserterExpiration();
	
	local myExpireTime;
	if ( deserterExpiration ) then
		myExpireTime = deserterExpiration;
		hasDeserter = true;
	else
		myExpireTime = GetLFGRandomCooldownExpiration();
	end
	
	cooldownFrame.myExpirationTime = myExpireTime;
	
	for i = 1, GetNumSubgroupMembers() do
		local nameLabel = _G["LFDQueueFrameCooldownFrameName"..i];
		local statusLabel = _G["LFDQueueFrameCooldownFrameStatus"..i];
		nameLabel:Show();
		statusLabel:Show();
		
		local _, classFilename = UnitClass("party"..i);
		local classColor = classFilename and RAID_CLASS_COLORS[classFilename] or NORMAL_FONT_COLOR;
		nameLabel:SetFormattedText("|cff%.2x%.2x%.2x%s|r", classColor.r * 255, classColor.g * 255, classColor.b * 255, UnitName("party"..i));
		
		local gender = UnitSex("party"..i);
		
		if ( UnitHasLFGDeserter("party"..i) ) then
			statusLabel:SetFormattedText(RED_FONT_COLOR_CODE.."%s|r", GetText("DESERTER", gender));
			shouldShow = true;
			hasDeserter = true;
		elseif ( UnitHasLFGRandomCooldown("party"..i) ) then
			statusLabel:SetFormattedText(RED_FONT_COLOR_CODE.."%s|r", GetText("ON_COOLDOWN", gender));
			shouldShow = true;
		else
			statusLabel:SetFormattedText(GREEN_FONT_COLOR_CODE.."%s|r", GetText("READY", gender));
		end
	end
	for i = GetNumSubgroupMembers() + 1, MAX_PARTY_MEMBERS do
		local nameLabel = _G["LFDQueueFrameCooldownFrameName"..i];
		local statusLabel = _G["LFDQueueFrameCooldownFrameStatus"..i];
		nameLabel:Hide();
		statusLabel:Hide();
	end
	
	if ( GetNumSubgroupMembers() == 0 ) then
		cooldownFrame.description:SetPoint("TOP", 0, -85);
	else
		cooldownFrame.description:SetPoint("TOP", 0, -30);
	end
	
	if ( hasDeserter ) then
		cooldownFrame:SetParent(LFDQueueFrame);
		cooldownFrame:SetFrameLevel(LFDQueueFrame:GetFrameLevel() + 9);	--Setting a new parent changes the frame level, so we need to move it back to what we set in OnLoad.
	else
		cooldownFrame:SetParent(LFDQueueFrameRandom);	--If nobody has deserter, the dungeon cooldown only prevents us from queueing for random.
		cooldownFrame:SetFrameLevel(LFDQueueFrame:GetFrameLevel() + 9);
	end
	
	if ( myExpireTime and GetTime() < myExpireTime ) then
		shouldShow = true;
		if ( deserterExpiration ) then
			cooldownFrame.description:SetText(LFG_DESERTER_YOU);
		else
			cooldownFrame.description:SetText(LFG_RANDOM_COOLDOWN_YOU);
		end
		cooldownFrame.time:SetText(SecondsToTime(ceil(myExpireTime - GetTime())));
		cooldownFrame.time:Show();
		
		cooldownFrame:SetScript("OnUpdate", LFDQueueFrameRandomCooldownFrame_OnUpdate);
	else
		if ( hasDeserter ) then
			cooldownFrame.description:SetText(LFG_DESERTER_OTHER);
		else
			cooldownFrame.description:SetText(LFG_RANDOM_COOLDOWN_OTHER);
		end
		cooldownFrame.time:Hide();
		
		cooldownFrame:SetScript("OnUpdate", nil);
	end
	
	if ( shouldShow and not LFDQueueFramePartyBackfill:IsShown() ) then
		cooldownFrame:Show();
	else
		cooldownFrame:Hide();
	end
end

function LFDQueueFrameRandomCooldownFrame_OnUpdate(self, elapsed)
	local timeRemaining = self.myExpirationTime - GetTime();
	if ( timeRemaining > 0 ) then
		self.time:SetText(SecondsToTime(ceil(timeRemaining)));
	else
		LFDQueueFrameRandomCooldownFrame_Update();
	end
end

function LFDQueueFrameFindGroupButton_Update()
	local mode, subMode = GetLFGMode();
	local queueType = GetLFGModeType();
	if ( queueType == "default" and ( mode == "queued" or mode == "rolecheck" or mode == "proposal" or mode == "suspended" ) ) then
		LFDQueueFrameFindGroupButton:SetText(LEAVE_QUEUE);
	else
		if ( IsInGroup() ) then
			LFDQueueFrameFindGroupButton:SetText(JOIN_AS_PARTY);
		else
			LFDQueueFrameFindGroupButton:SetText(FIND_A_GROUP);
		end
	end
	
	if ( queueType == "raid" and mode ) then	-- if queued for raid finder
		if ( mode == "proposal" or mode == "queued" or mode == "rolecheck" or mode == "suspended" ) then
			LFDQueueFrameFindGroupButton:Disable();
			if ( LFD_IsEmpowered() ) then
				LFRQueueFrameNoLFRWhileLFDLeaveQueueButton:Enable();
			else
				LFRQueueFrameNoLFRWhileLFDLeaveQueueButton:Disable();
			end
		else
			LFDQueueFrameFindGroupButton:Enable();
		end
	elseif ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "listed"  ) then --During the proposal, they must use the proposal buttons to leave the queue.
		if ( (mode == "queued" or mode == "rolecheck" or mode == "suspended")	--The players can dequeue even if one of the two cover panels is up.
			or (not LFDQueueFramePartyBackfill:IsVisible() and not LFDQueueFrameCooldownFrame:IsVisible()) ) then
			LFDQueueFrameFindGroupButton:Enable();
		else
			LFDQueueFrameFindGroupButton:Disable();
		end
		LFRQueueFrameNoLFRWhileLFDLeaveQueueButton:Enable();
	else
		LFDQueueFrameFindGroupButton:Disable();
		LFRQueueFrameNoLFRWhileLFDLeaveQueueButton:Disable();
	end
	
	if ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "queued" and mode ~= "suspended" and mode ~= "rolecheck" ) then
		LFDQueueFramePartyBackfillBackfillButton:Enable();
	else
		LFDQueueFramePartyBackfillBackfillButton:Disable();
	end
end

LFDHiddenByCollapseList = {};
function LFDQueueFrame_Update()
	local enableList;
	
	local mode, submode = GetLFGMode();
	
	if ( LFD_IsEmpowered() and mode ~= "queued" and mode ~= "suspended") then
		enableList = LFGEnabledList;
	else
		enableList = LFGQueuedForList;
	end
	
	LFDDungeonList = GetLFDChoiceOrder(LFDDungeonList);
		
	LFGQueueFrame_UpdateLFGDungeonList(LFDDungeonList, LFDHiddenByCollapseList, LFGLockList, enableList, LFGCollapseList, LFD_CURRENT_FILTER);
	
	LFDQueueFrameSpecificList_Update();
end

function LFDList_DefaultFilterFunction(dungeonID)
	local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday = GetLFGDungeonInfo(dungeonID);
	local hasHeader = groupID ~= 0;
	local sufficientExpansion = EXPANSION_LEVEL >= expansionLevel;
	local level = UnitLevel("player");
	local sufficientLevel = level >= minLevel and level <= maxLevel;
	return (hasHeader and sufficientExpansion and sufficientLevel) and
		( level - LFD_MAX_SHOWN_LEVEL_DIFF <= recLevel or (LFGLockList and not LFGLockList[dungeonID]));	--If the server tells us we can join, who are we to complain?
end

LFD_CURRENT_FILTER = LFDList_DefaultFilterFunction
