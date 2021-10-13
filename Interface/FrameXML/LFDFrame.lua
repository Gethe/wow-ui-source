EXPANSION_LEVEL = GetExpansionLevel(); --This can change while logged in, when an expansion releases

LFD_MAX_REWARDS = 2;

NUM_LFD_CHOICE_BUTTONS = 15;

NUM_LFD_MEMBERS = 5;

LFD_STATISTIC_CHANGE_TIME = 10; --In secs.

LFD_PROPOSAL_FAILED_CLOSE_TIME = 5;

LFD_NUM_ROLES = 3;

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
	self:RegisterEvent("LFG_READY_CHECK_SHOW");
	self:RegisterEvent("LFG_READY_CHECK_HIDE");
	self:RegisterEvent("LFG_BOOT_PROPOSAL_UPDATE");
	self:RegisterEvent("VOTE_KICK_REASON_NEEDED");
	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO");
	self:RegisterEvent("LFG_OPEN_FROM_GOSSIP");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	self:RegisterEvent("AJ_DUNGEON_ACTION");

	ButtonFrameTemplate_HideAttic(self);
	self.Inset:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 2, 284);
	self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 26);
end

function LFDFrame_OnEvent(self, event, ...)
	if ( event == "LFG_ROLE_CHECK_SHOW" ) then
		local requeue = ...;
		LFDRoleCheckPopup.Text:SetText(requeue and REQUEUE_CONFIRM_YOUR_ROLE or CONFIRM_YOUR_ROLE);
		LFDRoleCheckPopup_Update();

		StaticPopupSpecial_Show(LFDRoleCheckPopup);
		LFDQueueFrameSpecificList_Update();
	elseif ( event == "LFG_ROLE_CHECK_HIDE" ) then
		StaticPopupSpecial_Hide(LFDRoleCheckPopup);
		LFDQueueFrameSpecificList_Update();
	elseif ( event == "LFG_READY_CHECK_SHOW" ) then
		local _, readyCheckBgQueue = GetLFGReadyCheckUpdate();
		local displayName;
		if ( readyCheckBgQueue ) then
			displayName = GetLFGReadyCheckUpdateBattlegroundInfo();
		else
			displayName = UNKNOWN;
		end
		LFDReadyCheckPopup.Text:SetFormattedText(CONFIRM_YOU_ARE_READY, displayName);
		StaticPopupSpecial_Show(LFDReadyCheckPopup);
	elseif ( event == "LFG_READY_CHECK_HIDE" ) then
		StaticPopupSpecial_Hide(LFDReadyCheckPopup);
	elseif ( event == "LFG_BOOT_PROPOSAL_UPDATE" ) then
		local voteInProgress, didVote, myVote, targetName, totalVotes, bootVotes, timeLeft, reason = GetLFGBootProposal();
		if ( voteInProgress and not didVote and targetName ) then
			if (reason and reason ~= "") then
				StaticPopupDialogs["VOTE_BOOT_PLAYER"].text = VOTE_BOOT_PLAYER;
			else
				StaticPopupDialogs["VOTE_BOOT_PLAYER"].text = VOTE_BOOT_PLAYER_NO_REASON;
			end
			-- Person who started the vote voted yes, the person being voted against voted no, so weve seen this before if we have more than 2 votes.
			StaticPopup_Show("VOTE_BOOT_PLAYER", targetName, reason, totalVotes > 2 );
		else
			StaticPopup_Hide("VOTE_BOOT_PLAYER");
		end
	elseif ( event == "VOTE_KICK_REASON_NEEDED" ) then
		local targetName, targetGUID = ...;
		StaticPopup_Show("VOTE_BOOT_REASON_REQUIRED", targetName, nil, targetGUID);
	elseif ( event == "LFG_UPDATE_RANDOM_INFO" ) then
		if C_PlayerInfo.IsPlayerNPERestricted() then
		-- if the player is NPE restricted, we need to default to specific dungeons
		-- for a cleaner tutorial experience
			LFDQueueFrame_SetType("specific");
		else
			if ( not LFDQueueFrame.type or (type(LFDQueueFrame.type) == "number" and not IsLFGDungeonJoinable(LFDQueueFrame.type)) ) then
				local bestChoice = GetRandomDungeonBestChoice();
				if ( bestChoice ) then
					UIDropDownMenu_Initialize(LFDQueueFrameTypeDropDown, LFDQueueFrameTypeDropDown_Initialize);
					LFDQueueFrame_SetType(bestChoice);
				end
			end
			--If we still don't have a value, we should go to specific.
			if ( not LFDQueueFrame.type ) then
				LFDQueueFrame_SetType("specific");
			end
		end
	elseif ( event == "LFG_OPEN_FROM_GOSSIP" ) then
		local dungeonID = ...;
		LFDFrame_DisplayDungeonByID(dungeonID);
		PVEFrame_ShowFrame("GroupFinderFrame", LFDParentFrame);
	elseif ( event == "UPDATE_EXPANSION_LEVEL" ) then
		EXPANSION_LEVEL = GetExpansionLevel();
	elseif ( event == "AJ_DUNGEON_ACTION" ) then
		local id = ...;
		if ( id ) then
			LFDFrame_DisplayDungeonByID(id);
			local categoryID = DungeonAppearsInRandomLFD(id);
			if ( categoryID ~= LE_LFG_CATEGORY_LFD ) then
				LFGDungeonList_DisableEntries();
				LFGDungeonList_SetDungeonEnabled(id, true);
				LFGListUpdateHeaderEnabledAndLockedStates(LFDDungeonList, LFGEnabledList, LFDHiddenByCollapseList);
			end
		end
		PVEFrame_ShowFrame("GroupFinderFrame", LFDParentFrame);
	end
end

function LFDFrame_OnShow(self)
	LFGBackfillCover_Update(LFDQueueFrame.PartyBackfill, true);
end

function LFDFrame_DisplayDungeonByID(dungeonID)
	if ( DungeonAppearsInRandomLFD(dungeonID) ) then
		LFDQueueFrame_SetType(dungeonID);
	else
		LFDQueueFrame_SetType("specific");
	end
end

--Role-related functions

function LFDQueueFrame_SetRoles()
	SetLFGRoles(LFGRole_GetChecked(LFDQueueFrameRoleButtonLeader),
		LFGRole_GetChecked(LFDQueueFrameRoleButtonTank),
		LFGRole_GetChecked(LFDQueueFrameRoleButtonHealer),
		LFGRole_GetChecked(LFDQueueFrameRoleButtonDPS));
end

function LFDQueueFrame_GetRoles()
	return LFGRole_GetChecked(LFDQueueFrameRoleButtonLeader),
		LFGRole_GetChecked(LFDQueueFrameRoleButtonTank),
		LFGRole_GetChecked(LFDQueueFrameRoleButtonHealer),
		LFGRole_GetChecked(LFDQueueFrameRoleButtonDPS);
end

function LFDFrameRoleCheckButton_OnClick(self)
	LFDQueueFrame_SetRoles();
	LFDQueueFrameFindGroupButton_Update();
	LFDQueueFrameRandom_UpdateFrame();	--We may show or hide shortage rewards.
end

function LFDQueueFrame_UpdateRoleButtons()
	local dungeonID = LFDQueueFrame.type;
	LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonTank, nil);
	LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonHealer, nil);
	LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonDPS, nil);

	local tankLocked, healerLocked, dpsLocked;
	local restrictedRoles = {[1]={count=0, alert=false}, -- tank
							 [2]={count=0, alert=false}, -- healer
							 [3]={count=0, alert=false}} -- dps
	if ( type(dungeonID) == "number" ) then
		tankLocked, healerLocked, dpsLocked = GetLFDRoleRestrictions(dungeonID);
		if ( not IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
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
	elseif( dungeonID == "specific" and LFDDungeonList and LFGEnabledList )then
		-- count the number of dungeons a role is locked
		local dungeonCount = 0;
		for _, id in ipairs(LFDDungeonList) do
			local isChecked = LFGEnabledList[id];
			if isChecked and not LFGIsIDHeader(id) then
				tankLocked, healerLocked, dpsLocked = GetLFDRoleRestrictions(id);
				restrictedRoles[1].count = restrictedRoles[1].count + ((tankLocked and 1) or 0);
				restrictedRoles[2].count = restrictedRoles[2].count + ((healerLocked and 1) or 0);
				restrictedRoles[3].count = restrictedRoles[3].count + ((dpsLocked and 1) or 0);
				dungeonCount = dungeonCount + 1;
			end
		end
		if( dungeonCount > 0 ) then
			tankLocked = restrictedRoles[1].count == dungeonCount;
			healerLocked = restrictedRoles[2].count == dungeonCount;
			dpsLocked = restrictedRoles[3].count == dungeonCount;
		end
		restrictedRoles[1].alert = not tankLocked and restrictedRoles[1].count > 0;
		restrictedRoles[2].alert = not healerLocked and restrictedRoles[2].count > 0;
		restrictedRoles[3].alert = not dpsLocked and restrictedRoles[3].count > 0;
	end

	LFDQueueFrame_UpdateRoleButton(LFDQueueFrameRoleButtonTank, tankLocked, restrictedRoles[1].alert);
	LFDQueueFrame_UpdateRoleButton(LFDQueueFrameRoleButtonHealer, healerLocked, restrictedRoles[2].alert);
	LFDQueueFrame_UpdateRoleButton(LFDQueueFrameRoleButtonDPS, dpsLocked, restrictedRoles[3].alert);

	LFDQueueFrameFindGroupButton_Update();
end

function LFDQueueFrame_UpdateRoleButton(button, locked, alert)
	if( button.permDisabled )then
		return;
	end

	if( locked ) then
		button.lockedIndicator:Show();
		button.checkButton:Hide();
		button.checkButton:Disable();
		button.alert:Hide();
	else
		button.lockedIndicator:Hide();
		button.checkButton:Show();
		button.checkButton:Enable();

		if( alert ) then
			button.alert:Show();
		else
			button.alert:Hide();
		end
	end
end

--Role-check functions
function LFDQueueCheckRoleSelectionValid(tank, healer, dps)
	if not tank and not healer and not dps then
		return false;
	end

	if not LFDDungeonList or not LFGEnabledList then
		return true;
	end

	if LFDQueueFrame.type == "specific" then
		for _, id in ipairs(LFDDungeonList) do
			local isChecked = LFGEnabledList[id];
			if isChecked and not LFGIsIDHeader(id) then
				if LFDCheckRolesRestricted( id, tank, healer, dps ) then
					return false;
				end
			end
		end
	end

	return true;
end

function LFDCheckRolesRestricted(dungeonID, tank, healer, dps)
	local tankSelected, healerSelected, dpsSelected = tank, healer, dps;
	local tankLocked, healerLocked, dpsLocked = GetLFDRoleRestrictions(dungeonID);
	if ( tankLocked ) then
		tankSelected = false;
	end
	if ( healerLocked ) then
		healerSelected = false;
	end
	if ( dpsLocked ) then
		dpsSelected = false;
	end

	return not tankSelected and not healerSelected and not dpsSelected;
end

function LFDPopupRoleCheckButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(_G["ROLE_DESCRIPTION_"..self.role], nil, nil, nil, nil, true);
	if ( self.permDisabled ) then
		if(self.permDisabledTip)then
			GameTooltip:AddLine(self.permDisabledTip, 1, 0, 0, true);
		end
	elseif ( self.disabledTooltip and not self:IsEnabled() ) then
		GameTooltip:AddLine(self.disabledTooltip, 1, 0, 0, true);
	elseif ( not self:IsEnabled() ) then
		local dungeonID = LFDQueueFrame.type;
		local roleID = self:GetID();
		GameTooltip:SetText(ERR_ROLE_UNAVAILABLE, 1.0, 1.0, 1.0);
		local reasons = GetLFGInviteRoleRestrictions(roleID);
		for i = 1, #reasons do
			local text = _G["INSTANCE_UNAVAILABLE_SELF_"..(LFG_INSTANCE_INVALID_CODES[reasons[i]] or "OTHER")];
			if( text ) then
				GameTooltip:AddLine(text);
			end
		end
		GameTooltip:Show();
		return;
	elseif( self.alert:IsShown() ) then
		GameTooltip:SetText(INSTANCE_ROLE_WARNING_TITLE, 1.0, 1.0, 1.0, true);
		GameTooltip:AddLine(INSTANCE_ROLE_WARNING_TEXT, nil, nil, nil, true);
	end
	GameTooltip:Show();
	LFGFrameRoleCheckButton_OnEnter(self);
end

--List functions
function LFDQueueFrameSpecificList_Update()
	if ( LFGDungeonList_Setup() ) then
		return;	--Setup will update the list.
	end

	if C_PlayerInfo.IsPlayerNPERestricted() then
		if #LFDDungeonList == 0 then
			-- no eligible dungeons
			EventRegistry:TriggerEvent("LFDQueueFrameSpecificList_Update.EmptyDungeonList");
		else
			EventRegistry:TriggerEvent("LFDQueueFrameSpecificList_Update.DungeonListReady");
		end
	end

	FauxScrollFrame_Update(LFDQueueFrameSpecificListScrollFrame, #LFDDungeonList, NUM_LFD_CHOICE_BUTTONS, 16);

	local offset = FauxScrollFrame_GetOffset(LFDQueueFrameSpecificListScrollFrame);

	local areButtonsBig = not LFDQueueFrameSpecificListScrollFrame:IsShown();

	local enabled, queued = LFGDungeonList_EvaluateListState(LE_LFG_CATEGORY_LFD);

	local checkedList;
	if ( queued ) then
		checkedList = LFGQueuedForList[LE_LFG_CATEGORY_LFD];
	else
		checkedList = LFGEnabledList;
	end

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
			LFGDungeonListButton_SetDungeon(button, dungeonID, enabled, checkedList);
		else
			button:Hide();
		end
	end
end

function LFDQueueFrame_Join()
	LFG_JoinDungeon(LE_LFG_CATEGORY_LFD, LFDQueueFrame.type, LFDDungeonList, LFDHiddenByCollapseList);
end

function LFDQueueFrameDungeonChoiceEnableButton_OnClick(self, button)
	LFGDungeonListCheckButton_OnClick(self, LE_LFG_CATEGORY_LFD, LFDDungeonList, LFDHiddenByCollapseList);
	LFDQueueFrameSpecificList_Update();
	LFDQueueFrame_UpdateRoleButtons();
end

function LFDQueueFrameDungeonListButton_OnEnter(self)
	LFGDungeonListButton_OnEnter(self, YOU_MAY_NOT_QUEUE_FOR_DUNGEON);
end

function LFDQueueFrameExpandOrCollapseButton_OnClick(self, button)
	LFGDungeonList_SetHeaderCollapsed(self:GetParent(), LFDDungeonList, LFDHiddenByCollapseList);
	LFDQueueFrame_Update();
end

function LFDQueueFrameTypeDropDown_SetUp(self)
	UIDropDownMenu_SetWidth(self, 180);
	UIDropDownMenu_Initialize(self, LFDQueueFrameTypeDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, LFDQueueFrame.type);
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
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);
		if isAvailableForPlayer or not hideIfNotJoinable then
			if isAvailableForAll then
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
		local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday, _, _, isTimeWalker = GetLFGDungeonInfo(value);
		LFDQueueFrame_SetTypeRandomDungeon(isHoliday and not isTimeWalker);
		LFDQueueFrameRandom_UpdateFrame();
	end
	LFDQueueFrame_UpdateRoleButtons();
end

function LFDQueueFrame_SetTypeRandomDungeon(hideCooldown)
	LFDQueueFrameBackground:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-QUESTPAPER")
	LFDQueueFrameSpecific:Hide();
	LFDQueueFrameRandom:Show();
	LFGCooldownCover_ChangeSettings(LFDQueueFrame.CooldownFrame, true, not hideCooldown);
end

function LFDQueueFrame_SetTypeSpecificDungeon()
	LFDQueueFrameBackground:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-DUNGEONWALL");
	LFDQueueFrameRandom:Hide();
	LFDQueueFrameSpecific:Show();
	LFGCooldownCover_ChangeSettings(LFDQueueFrame.CooldownFrame, true, false);
end

function LFDQueueFrameRandom_UpdateFrame()
	local dungeonID = LFDQueueFrame.type;

	if ( type(dungeonID) ~= "number" ) then	--We haven't gotten info on available dungeons yet.
		return;
	end

	LFGRewardsFrame_UpdateFrame(LFDQueueFrameRandomScrollFrameChildFrame, dungeonID, LFDQueueFrameBackground);
	LFDQueueFrame_UpdateRoleButtons();
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
		nameLabel:SetFormattedText("|cff%.2x%.2x%.2x%s|r", classColor.r * 255, classColor.g * 255, classColor.b * 255, GetUnitName("party"..i, true));

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
	local mode, subMode = GetLFGMode(LE_LFG_CATEGORY_LFD);
	--Update the text on the button
	if ( mode == "queued" or mode == "rolecheck" or mode == "proposal" or mode == "suspended" ) then
		LFDQueueFrameFindGroupButton:SetText(LEAVE_QUEUE);
	else
		if ( IsInGroup() and GetNumGroupMembers() > 1 ) then
			LFDQueueFrameFindGroupButton:SetText(JOIN_AS_PARTY);
		else
			LFDQueueFrameFindGroupButton:SetText(FIND_A_GROUP);
		end
	end

	if C_PlayerInfo.IsPlayerNPERestricted() then
		if not LFDQueueCheckRoleSelectionValid(LFGRole_GetChecked(LFDQueueFrameRoleButtonTank), LFGRole_GetChecked(LFDQueueFrameRoleButtonHealer), LFGRole_GetChecked(LFDQueueFrameRoleButtonDPS)) then
			-- the NPE restricted player needs to at least be a DPS role if nothing is selected
			LFDQueueFrameRoleButtonDPS.checkButton:SetChecked(true);
			LFDFrameRoleCheckButton_OnClick(LFDQueueFrameRoleButtonDPS.checkButton);
		end
	end

	if ( not LFDQueueCheckRoleSelectionValid( LFGRole_GetChecked(LFDQueueFrameRoleButtonTank),
												LFGRole_GetChecked(LFDQueueFrameRoleButtonHealer),
												LFGRole_GetChecked(LFDQueueFrameRoleButtonDPS)) ) then
		LFDQueueFrameFindGroupButton:Disable();
		LFDQueueFrameFindGroupButton.tooltip = INSTANCE_ROLE_WARNING_TITLE;
		return;
	end

	--Disable the button if we're not in a state where we can make a change
	if ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "listed"  ) then --During the proposal, they must use the proposal buttons to leave the queue.
		if ( (mode == "queued" or mode == "rolecheck" or mode == "suspended")	--The players can dequeue even if one of the two cover panels is up.
			or (not LFDQueueFramePartyBackfill:IsVisible() and not LFDQueueFrameCooldownFrame:IsVisible()) ) then
			LFDQueueFrameFindGroupButton:Enable();
			LFDQueueFrameFindGroupButton.tooltip = nil;
		else
			LFDQueueFrameFindGroupButton:Disable();
		end
		LFRQueueFrameNoLFRWhileLFDLeaveQueueButton:Enable();
	else
		LFDQueueFrameFindGroupButton:Disable();
		if ( IsInGroup(LE_PARTY_CATEGORY_HOME) and not UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
			LFDQueueFrameFindGroupButton.tooltip = ERR_NOT_LEADER;
		end
	end

	--Disable the button if the person is active in LFGList
	local lfgListDisabled;
	if ( C_LFGList.HasActiveEntryInfo() ) then
		lfgListDisabled = CANNOT_DO_THIS_WHILE_LFGLIST_LISTED;
	end

	if ( lfgListDisabled ) then
		LFDQueueFrameFindGroupButton:Disable();
		LFDQueueFrameFindGroupButton.tooltip = lfgListDisabled;
	end

	--Update the backfill enable state
	if ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "queued" and mode ~= "suspended" and mode ~= "rolecheck" ) then
		LFDQueueFramePartyBackfillBackfillButton:Enable();
	else
		LFDQueueFramePartyBackfillBackfillButton:Disable();
	end
end

LFDHiddenByCollapseList = {};

local function UpdateLFDDungeonList()
	LFDDungeonList = {};

	-- Get the list of dungeons, then pull out dungeons that are hidden (due to current Timewalking Campaign, etc) and add the rest to LFDDungeonList
	local dungeonList = GetLFDChoiceOrder();
	for _, dungeonID in ipairs(dungeonList) do
		if not LFGLockList[dungeonID] or not LFGLockList[dungeonID].hideEntry then
			table.insert(LFDDungeonList, dungeonID);
		end
	end
end

function LFDQueueFrame_Update()
	local mode, submode = GetLFGMode(LE_LFG_CATEGORY_LFD);

	local checkedList;
	if ( LFD_IsEmpowered() and mode ~= "queued" and mode ~= "suspended") then
		checkedList = LFGEnabledList;
	else
		checkedList = LFGQueuedForList[LE_LFG_CATEGORY_LFD];
	end

	UpdateLFDDungeonList();
	
	LFGQueueFrame_UpdateLFGDungeonList(LFDDungeonList, LFDHiddenByCollapseList, checkedList, LFD_CURRENT_FILTER);

	LFDQueueFrameSpecificList_Update();
end

LFD_CURRENT_FILTER = LFGList_DefaultFilterFunction;

---------------------------------------------------
-----------LFD Role Check Popup Frame--------------
---------------------------------------------------
function LFDFramePopupRoleCheckButton_OnClick(self)
	LFGRoleCheckPopup_UpdatePvPRoles();
	LFDRoleCheckPopup_UpdateAcceptButton();
end

function LFGRoleCheckPopup_UpdatePvPRoles()
	local isBGRoleCheck = select(6, GetLFGRoleUpdate());
	if ( isBGRoleCheck ) then
		local tankChecked, healerChecked, dpsChecked = LFDRoleCheckPopup_GetRolesChecked();
		SetPVPRoles(tankChecked, healerChecked, dpsChecked);
	end
end

function LFGRoleCheckPopup_UpdateRoleButton(button)
	if( button:IsEnabled() )then
		local unlocked, alert = GetLFGInviteRoleAvailability(button:GetID());
		if(unlocked)then
			LFG_EnableRoleButton(button);
			button.lockedIndicator:Hide();
			button.checkButton:Show();
			if(alert) then
				button.alert:Show();
			else
				button.alert:Hide();
			end
		else
			button.lockedIndicator:Show();
			LFG_DisableRoleButton(button);
			button.checkButton:Hide();
			button.alert:Hide();
		end
	end
end

function LFDPopupRoleCheckButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(_G["ROLE_DESCRIPTION_"..self.role], nil, nil, nil, nil, true);
	if ( self.permDisabled ) then
		if(self.permDisabledTip)then
			GameTooltip:AddLine(self.permDisabledTip, 1, 0, 0, true);
		end
	elseif ( self.disabledTooltip and not self:IsEnabled() ) then
		GameTooltip:AddLine(self.disabledTooltip, 1, 0, 0, true);
	elseif ( not self:IsEnabled() ) then
		local dungeonID = LFDQueueFrame.type;
		local roleID = self:GetID();
		GameTooltip:SetText(ERR_ROLE_UNAVAILABLE, 1.0, 1.0, 1.0);
		local reasons = GetLFGInviteRoleRestrictions(roleID);
		for i = 1, #reasons do
			local text = _G["INSTANCE_UNAVAILABLE_SELF_"..(LFG_INSTANCE_INVALID_CODES[reasons[i]] or "OTHER")];
			if( text ) then
				GameTooltip:AddLine(text);
			end
		end
		GameTooltip:Show();
		return;
	elseif( self.alert:IsShown() ) then
		GameTooltip:SetText(INSTANCE_ROLE_WARNING_TITLE, 1.0, 1.0, 1.0, true);
		GameTooltip:AddLine(INSTANCE_ROLE_WARNING_TEXT, nil, nil, nil, true);
	end
	GameTooltip:Show();
	LFGFrameRoleCheckButton_OnEnter(self);
end

function LFDRoleCheckPopup_OnShow(self)
	PlaySound(SOUNDKIT.READY_CHECK);
	FlashClientIcon();
	LFDRoleCheckPopup_Update();
	self:RegisterEvent("PVP_BRAWL_INFO_UPDATED");
end

function LFDRoleCheckPopup_OnHide(self)
	self:UnregisterEvent("PVP_BRAWL_INFO_UPDATED");
end

function LFDRoleCheckPopup_OnEvent(self, event)
	if (event == "PVP_BRAWL_INFO_UPDATED") then
		LFDRoleCheckPopup_Update();
	end
end

function LFDRoleCheckPopup_Update()
	LFGDungeonList_Setup();

	LFG_UpdateAllRoleCheckboxes();

	local inProgress, slots, members, category, lfgID, bgQueue = GetLFGRoleUpdate();
	local isLFGList, activityID = C_LFGList.GetRoleCheckInfo();

	local displayName;
	if( isLFGList ) then
		displayName = C_LFGList.GetActivityInfo(activityID);
	elseif ( bgQueue ) then
		displayName = GetLFGRoleUpdateBattlegroundInfo();
	elseif ( slots == 1 ) then
		local dungeonID, dungeonType, dungeonSubType = GetLFGRoleUpdateSlot(1);
		if ( dungeonSubType == LFG_SUBTYPEID_HEROIC ) then
			displayName = format(HEROIC_PREFIX, select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(dungeonID)));
		else
			displayName = select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(dungeonID));
		end
	else
		displayName = MULTIPLE_DUNGEONS;
	end
	displayName = displayName and NORMAL_FONT_COLOR:WrapTextInColorCode(displayName) or "";

	if ( isLFGList ) then
		LFDRoleCheckPopupDescriptionText:SetFormattedText(LFG_LIST_APPLYING_TO, displayName);
	else
		LFDRoleCheckPopupDescriptionText:SetFormattedText(QUEUED_FOR, displayName);
	end

	local descSubTextWidth = 0;
	local descSubTextHeight = 0;
	local maxLevel, isLevelReduced = C_LFGInfo.GetRoleCheckDifficultyDetails();
	if isLevelReduced then
		local canDisplayLevel = maxLevel and maxLevel < UnitEffectiveLevel("player");
		if canDisplayLevel then
			local formattedString = string.format(bgQueue and LFG_PVP_LEVEL_REDUCED or LFG_LEVEL_REDUCED, maxLevel);
			LFDRoleCheckPopupDescription.SubText:SetText(formattedString);
		else
			LFDRoleCheckPopupDescription.SubText:SetText(LFG_LEVEL_REDUCED_GENERIC);
		end
		descSubTextWidth = LFDRoleCheckPopupDescription.SubText:GetWidth();
		descSubTextHeight = LFDRoleCheckPopupDescription.SubText:GetHeight();
	end
	LFDRoleCheckPopupDescription.SubText:SetShown(isLevelReduced);

	local descTextWidth = LFDRoleCheckPopupDescriptionText:GetWidth();
	local maxTextWidth = math.max(descSubTextWidth, descTextWidth) + 10;
	LFDRoleCheckPopupDescription:SetWidth(maxTextWidth);

	local descTextHeight = LFDRoleCheckPopupDescriptionText:GetHeight();
	local totalDescriptionTextHeight = descSubTextHeight + descTextHeight;
	LFDRoleCheckPopupDescription:SetHeight(totalDescriptionTextHeight);

	local descriptionTextMargin = isLevelReduced and 35 or 46;
	local descriptionOffsetY = LFDRoleCheckPopupDescription:GetHeight() + descriptionTextMargin;
	LFDRoleCheckPopupDescription:SetPoint("CENTER", LFDRoleCheckPopup, "BOTTOM", 0, descriptionOffsetY);

	local headerTextHeight = LFDRoleCheckPopup.Text:GetHeight();
	local roleHeight = LFDRoleCheckPopupRoleButtonTank:GetHeight();
	local popupHeight = headerTextHeight + roleHeight + totalDescriptionTextHeight + 85;
	LFDRoleCheckPopup:SetHeight(popupHeight);

	LFGRoleCheckPopup_UpdateRoleButton(LFDRoleCheckPopupRoleButtonTank);
	LFGRoleCheckPopup_UpdateRoleButton(LFDRoleCheckPopupRoleButtonHealer);
	LFGRoleCheckPopup_UpdateRoleButton(LFDRoleCheckPopupRoleButtonDPS);

	LFDRoleCheckPopup_UpdateAcceptButton();
end

function LFDRoleCheckPopup_GetRolesChecked()
	local tankChecked = LFGRole_GetChecked(LFDRoleCheckPopupRoleButtonTank);
	local healerChecked = LFGRole_GetChecked(LFDRoleCheckPopupRoleButtonHealer);
	local dpsChecked = LFGRole_GetChecked(LFDRoleCheckPopupRoleButtonDPS);
	return tankChecked, healerChecked, dpsChecked;
end

function LFDRoleCheckPopupAccept_OnClick()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);

	--Check if the role check is for a BG or not.
	local _, _, _, _, _, isBGRoleCheck = GetLFGRoleUpdate();
	local tankChecked, healerChecked, dpsChecked = LFDRoleCheckPopup_GetRolesChecked();
	if ( isBGRoleCheck ) then
		SetPVPRoles(tankChecked, healerChecked, dpsChecked);
	else
		local oldLeader = GetLFGRoles();
		SetLFGRoles(oldLeader, tankChecked, healerChecked, dpsChecked);
	end

	if ( CompleteLFGRoleCheck(true) ) then
		StaticPopupSpecial_Hide(LFDRoleCheckPopup);
	end
end

function LFDRoleCheckPopupDecline_OnClick()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	StaticPopupSpecial_Hide(LFDRoleCheckPopup);
	CompleteLFGRoleCheck(false);
end


function LFDPopupCheckRoleSelectionValid(tank, healer, dps)
	if ( not tank and not healer and not dps ) then
		return false;
	end

	local inProgress, slots, members = GetLFGRoleUpdate();
	for i=1, slots do
		local dungeonID = GetLFGRoleUpdateSlot(i);
		if ( LFDCheckRolesRestricted(dungeonID, tank, healer, dps) ) then
			return false;
		end
	end
	return true;
end

function LFDRoleCheckPopup_UpdateAcceptButton()
	local button = LFDRoleCheckPopupAcceptButton;
	if ( LFDPopupCheckRoleSelectionValid( LFGRole_GetChecked(LFDRoleCheckPopupRoleButtonTank),
										LFGRole_GetChecked(LFDRoleCheckPopupRoleButtonHealer),
										LFGRole_GetChecked(LFDRoleCheckPopupRoleButtonDPS)) ) then
		button:Enable();
		button.tooltipText = nil;
	else
		button:Disable();
		button.tooltipText = INSTANCE_ROLE_WARNING_TITLE;
	end
end

