EXPANSION_LEVEL = GetExpansionLevel(); --This doesn't change while logged in, so we just need to do it once.

LFD_MAX_REWARDS = 2;

NUM_LFD_CHOICE_BUTTONS = 15;
TYPEID_DUNGEON = 1;
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
	self:RegisterEvent("LFG_PROPOSAL_SUCCEEDED");
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LFG_ROLE_CHECK_SHOW");
	self:RegisterEvent("LFG_ROLE_CHECK_HIDE");
	self:RegisterEvent("LFG_BOOT_PROPOSAL_UPDATE");
	self:RegisterEvent("VOTE_KICK_REASON_NEEDED");
	self:RegisterEvent("LFG_ROLE_UPDATE");
	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO");
	self:RegisterEvent("LFG_OPEN_FROM_GOSSIP");
	self:RegisterEvent("GOSSIP_CLOSED");
	
	ButtonFrameTemplate_HideAttic(self);
	self.Inset:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 2, 284);
	self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 26);
end

function LFDFrame_OnEvent(self, event, ...)
	if ( event == "LFG_PROPOSAL_UPDATE" ) then
		LFDDungeonReadyPopup_Update();
	elseif ( event == "LFG_PROPOSAL_SHOW" ) then
		LFDDungeonReadyPopup.closeIn = nil;
		LFDDungeonReadyPopup:SetScript("OnUpdate", nil);
		LFDDungeonReadyStatus_ResetReadyStates();
		StaticPopupSpecial_Show(LFDDungeonReadyPopup);
		LFDSearchStatus:Hide();
		PlaySound("ReadyCheck");
	elseif ( event == "LFG_PROPOSAL_FAILED" ) then
		LFDDungeonReadyPopup_OnFail();
	elseif ( event == "LFG_PROPOSAL_SUCCEEDED" ) then
		LFGDebug("Proposal Hidden: Proposal succeeded.");
		StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
	elseif ( event == "LFG_ROLE_CHECK_SHOW" ) then
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
	elseif ( event == "LFG_OPEN_FROM_GOSSIP" ) then
		local dungeonID = ...;
		LFDParentFrame.fromGossip = true;
		ShowUIPanel(LFDParentFrame);
		LFDQueueFrame_SetType(dungeonID);
	elseif ( event == "GOSSIP_CLOSED" ) then
		if ( LFDParentFrame.fromGossip ) then
			HideUIPanel(LFDParentFrame);
		end
	end
	LFDQueueFrame_UpdatePortrait();
end

function LFDFrame_OnShow(self)
	LFDFrame_UpdateBackfill(true);
	LFDFrame_UpdateCapBar();
end

function LFDFrame_OnHide(self)
	if ( self.fromGossip ) then
		CloseGossip();
		self.fromGossip = false;
	end
end

function LFDQueueFrame_UpdatePortrait()
	local mode, submode = GetLFGMode();
	if ( mode == "queued" or mode == "rolecheck" ) then
		EyeTemplate_StartAnimating(LFDParentFrameEyeFrame);
	else
		EyeTemplate_StopAnimating(LFDParentFrameEyeFrame);
	end
end

--If we want to change the bar based on the current selection, just replace instances of VALOR_TIER1_LFG_ID with LFDQueueFrame.type
local VALOR_TIER1_LFG_ID = 301;
function LFDFrame_UpdateCapBar()
	local capBar = LFDQueueFrameCapBar;
	
	local currencyID, tier1DungeonID, tier1Quantity, tier1Limit, overallQuantity, overallLimit, periodPurseQuantity, periodPurseLimit = GetLFGDungeonRewardCapBarInfo(VALOR_TIER1_LFG_ID);
	if ( not currencyID ) then
		return;	--We may not have any info yet. (If the player has 5 seconds of lag and opens the window right after login)
	end
	
	local currencyName, currencyQuantity, currencyIcon, currencyEarnedThisWeek, currencyEarnablePerWeek, currencyCap, currencyIsDiscovered = GetCurrencyInfo(currencyID);
	if ( currencyIsDiscovered ) then
		capBar:Show();
		LFDParentFrame:SetHeight(470);
	else
		capBar:Hide();
		LFDParentFrame:SetHeight(428);
		return;
	end
	
	local hasNoSharedStats = false;
	if ( periodPurseQuantity == 0 and periodPurseLimit == 0 ) then
		--This is the case for reward counts not directly associated with currencies (e.g. non-heroics)
		periodPurseQuantity, periodPurseLimit = overallQuantity, overallLimit;
		hasNoSharedStats = true;
	end
	
	CapProgressBar_Update(capBar, tier1Quantity, tier1Limit, overallQuantity, overallLimit, periodPurseQuantity, periodPurseLimit, hasNoSharedStats);
	
	if ( currencyID == 0 ) then
		currencyName = REWARDS;
	end
	
	capBar.label:SetFormattedText(CURRENCY_THIS_WEEK, currencyName);
end

function LFDQueueFrameCapBar_OnEnter(self)
	local currencyID, tier1DungeonID, tier1Quantity, tier1Limit, overallQuantity, overallLimit, periodPurseQuantity, periodPurseLimit = GetLFGDungeonRewardCapBarInfo(VALOR_TIER1_LFG_ID);
	local currencyName;
	if ( currencyID == 0 ) then
		currencyName = REWARDS;
	else
		currencyName = GetCurrencyInfo(currencyID);
	end
	local tier1Name = GetLFGDungeonInfo(tier1DungeonID);
	local hasNoSharedStats = (periodPurseLimit == 0);
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(MAXIMUM_REWARD);
	GameTooltip:AddLine(format(CURRENCY_RECEIVED_THIS_WEEK, currencyName), 1, 1, 1, true);
	GameTooltip:AddLine(" ");
	
	local r, g, b = 1, 1, 1;
	if ( hasNoSharedStats ) then
		if ( tier1Quantity >= tier1Limit ) then
			r, g, b = 0.5, 0.5, 0.5;
		end
		GameTooltip:AddDoubleLine(format(FROM_A_DUNGEON, tier1Name), format(CURRENCY_WEEKLY_CAP_FRACTION, tier1Quantity, tier1Limit), r, g, b, r, g, b);
	else
		if ( periodPurseQuantity >= periodPurseLimit ) then
			r, g, b = 0.5, 0.5, 0.5;
		end
		GameTooltip:AddDoubleLine(FROM_ALL_SOURCES, format(CURRENCY_WEEKLY_CAP_FRACTION, periodPurseQuantity, periodPurseLimit), r, g, b, r, g, b);
		GameTooltip:AddDoubleLine(" -"..FROM_RAID, format(CURRENCY_WEEKLY_CAP_FRACTION, periodPurseQuantity - overallQuantity, periodPurseLimit), r, g, b, r, g, b);
		
		if ( overallQuantity >= overallLimit ) then
			r, g, b = 0.5, 0.5, 0.5;
		end
		GameTooltip:AddDoubleLine(" -"..FROM_DUNGEON_FINDER_SOURCES, format(CURRENCY_WEEKLY_CAP_FRACTION, overallQuantity, overallLimit), r, g, b, r, g, b);
		GameTooltip:AddDoubleLine("   -"..FROM_TROLLPOCALYPSE, format(CURRENCY_WEEKLY_CAP_FRACTION, overallQuantity - tier1Quantity, overallLimit), r, g, b, r, g, b);
		
		if ( tier1Quantity >= tier1Limit ) then
			r, g, b = 0.5, 0.5, 0.5;
		end
		GameTooltip:AddDoubleLine("   -"..format(FROM_A_DUNGEON, tier1Name), format(CURRENCY_WEEKLY_CAP_FRACTION, tier1Quantity, tier1Limit), r, g, b, r, g, b);
	end
	GameTooltip:Show();
end

function LFDQueueFrameCapBarCapMarker_OnEnter(self)
	local isTier1 = self:GetID() == 1;
	
	local currencyID, tier1DungeonID, tier1Quantity, tier1Limit, overallQuantity, overallLimit, periodPurseQuantity, periodPurseLimit = GetLFGDungeonRewardCapBarInfo(VALOR_TIER1_LFG_ID);
	if(not currencyID) then
		return;
	end

	local currencyName;
	if ( currencyID == 0 ) then
		currencyName = REWARDS;
	else
		currencyName = GetCurrencyInfo(currencyID);
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( isTier1 ) then
		local tier1Name = GetLFGDungeonInfo(tier1DungeonID);
		GameTooltip:SetText(MAXIMUM_REWARD);
		GameTooltip:AddLine(format(LFD_CURRENCY_CAP_SPECIFIC, currencyName, tier1Name), 1, 1, 1, true);
		GameTooltip:AddLine(format(CURRENCY_THIS_WEEK_WITH_AMOUNT, currencyName, tier1Quantity, tier1Limit));
	else
		GameTooltip:SetText(MAXIMUM_REWARD);
		GameTooltip:AddLine(format(LFD_CURRENCY_CAP_ALL, currencyName), 1, 1, 1, true);
		GameTooltip:AddLine(format(CURRENCY_THIS_WEEK_WITH_AMOUNT, currencyName, overallQuantity, overallLimit));
	end
	GameTooltip:Show();
end

--Backfill option
function LFDFrame_UpdateBackfill(forceUpdate)
	if ( CanPartyLFGBackfill() ) then
		local name, lfgID, typeID = GetPartyLFGBackfillInfo();
		LFDQueueFramePartyBackfillDescription:SetFormattedText(LFG_OFFER_CONTINUE, HIGHLIGHT_FONT_COLOR_CODE..name.."|r");
		local mode, subMode = GetLFGMode();
		if ( (forceUpdate or not LFDQueueFrame:IsVisible()) and mode ~= "queued" ) then
			LFDQueueFramePartyBackfill:Show();
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
		local dungeonType, dungeonID = GetLFGRoleUpdateSlot(1);
		if ( dungeonType == TYPEID_HEROIC_DIFFICULTY ) then
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
		
		if ( mode == "rolecheck" or mode == "queued" or mode == "listed" or not LFD_IsEmpowered()) then
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
	
	if ( mode == "rolecheck" or mode == "queued" or mode == "listed" or not LFD_IsEmpowered() ) then
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

--Ready popup functions

function LFDDungeonReadyPopup_OnFail()
	PlaySound("LFG_Denied");
	if ( LFDDungeonReadyDialog:IsShown() ) then
		LFGDebug("Proposal Hidden: Proposal failed.");
		StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
	elseif ( LFDDungeonReadyPopup:IsShown() ) then
		LFDDungeonReadyPopup.closeIn = LFD_PROPOSAL_FAILED_CLOSE_TIME;
		LFDDungeonReadyPopup:SetScript("OnUpdate", LFDDungeonReadyPopup_OnUpdate);
	end
end

function LFDDungeonReadyPopup_OnUpdate(self, elapsed)
	self.closeIn = self.closeIn - elapsed;
	if ( self.closeIn < 0 ) then	--We remove the OnUpdate and closeIn OnHide
		LFGDebug("Proposal Hidden: Failure close timer expired.");
		StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
	end
end

function LFDDungeonReadyPopup_Update()	
	local proposalExists, typeID, id, name, texture, role, hasResponded, totalEncounters, completedEncounters, numMembers, isLeader = GetLFGProposal();

	if ( not proposalExists ) then
		LFGDebug("Proposal Hidden: No proposal exists.");
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
			if ( not LFDDungeonReadyDialog.background:SetTexture(texture) ) then	--We haven't added this texture yet. Default to the Deadmines.
				LFDDungeonReadyDialog.background:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-Deadmines");	--DEBUG FIXME Default probably shouldn't be Deadmines
			end
			
			LFDDungeonReadyDialog.label:SetText(SPECIFIC_DUNGEON_IS_READY);
			LFDDungeonReadyDialog_UpdateInstanceInfo(name, completedEncounters, totalEncounters);
			LFDDungeonReadyDialog.instanceInfo:Show();
		end

		
		LFDDungeonReadyDialogRoleIconTexture:SetTexCoord(GetTexCoordsForRole(role));
		LFDDungeonReadyDialogRoleLabel:SetText(_G[role]);
		if ( isLeader ) then
			LFDDungeonReadyDialogRoleIconLeaderIcon:Show();
		else
			LFDDungeonReadyDialogRoleIconLeaderIcon:Hide();
		end
		
		LFDDungeonReadyDialog_UpdateRewards(id, role);
	end
end

function LFDDungeonReadyDialog_UpdateRewards(dungeonID, role)
	local doneToday, moneyBase, moneyVar, experienceBase, experienceVar, numRewards = GetLFGDungeonRewards(dungeonID);
	
	local numRandoms = 4 - GetNumPartyMembers();
	local moneyAmount = moneyBase + moneyVar * numRandoms;
	local experienceGained = experienceBase + experienceVar * numRandoms;
	
	local frameID = 1;

	if ( moneyAmount > 0 or experienceGained > 0 ) then --hasMiscReward ) then
		LFDDungeonReadyDialogReward_SetMisc(LFDDungeonReadyDialogRewardsFrameReward1);
		frameID = 2;
	end
	
	if ( moneyAmount == 0 and experienceGained == 0 and numRewards == 0 ) then
		LFDDungeonReadyDialogRewardsFrameLabel:Hide();
	else
		LFDDungeonReadyDialogRewardsFrameLabel:Show();
	end
	
	for i = 1, numRewards do
		local frame = _G["LFDDungeonReadyDialogRewardsFrameReward"..frameID];
		if ( not frame ) then
			frame = CreateFrame("FRAME", "LFDDungeonReadyDialogRewardsFrameReward"..frameID, LFDDungeonReadyDialogRewardsFrame, "LFDDungeonReadyRewardTemplate");
			frame:SetID(frameID);
			LFD_MAX_REWARDS = frameID;
		end
		LFDDungeonReadyDialogReward_SetReward(frame, dungeonID, i, "reward")
		frameID = frameID + 1;
	end
	
	for shortageIndex = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
		local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(dungeonID, shortageIndex);
		if ( eligible and ((role == "TANK" and forTank) or (role == "HEALER" and forHealer) or (role == "DAMAGER" and forDamage)) ) then
			for rewardIndex=1, itemCount do
				local frame = _G["LFDDungeonReadyDialogRewardsFrameReward"..frameID];
				if ( not frame ) then
					frame = CreateFrame("FRAME", "LFDDungeonReadyDialogRewardsFrameReward"..frameID, LFDDungeonReadyDialogRewardsFrame, "LFDDungeonReadyRewardTemplate");
					frame:SetID(frameID);
					LFD_MAX_REWARDS = frameID;
				end
				LFDDungeonReadyDialogReward_SetReward(frame, dungeonID, rewardIndex, "shortage", shortageIndex);
				frameID = frameID + 1;
			end
		end
	end
	
	--Hide the unused ones
	for i = frameID, LFD_MAX_REWARDS do
		_G["LFDDungeonReadyDialogRewardsFrameReward"..i]:Hide();
	end
	
	local usedButtons= frameID - 1;
	
	if ( usedButtons > 0 ) then
		--Set up positions
		local iconOffset;
		if ( usedButtons > 2 ) then
			iconOffset = -5;
		else
			iconOffset = 0;
		end
		local area = usedButtons * LFDDungeonReadyDialogRewardsFrameReward1:GetWidth() + (usedButtons - 1) * iconOffset;
		
		LFDDungeonReadyDialogRewardsFrameReward1:SetPoint("LEFT", LFDDungeonReadyDialogRewardsFrame, "CENTER", -area/2, 5);
		for i = 2, usedButtons do
			_G["LFDDungeonReadyDialogRewardsFrameReward"..i]:SetPoint("LEFT", "LFDDungeonReadyDialogRewardsFrameReward"..(i - 1), "RIGHT", iconOffset, 0);
		end
	end
end

function LFDDungeonReadyDialogReward_SetMisc(button)
	SetPortraitToTexture(button.texture, "Interface\\Icons\\inv_misc_coin_02");
	button.rewardType = "misc";
	button:Show();
end

function LFDDungeonReadyDialogReward_SetReward(button, dungeonID, rewardIndex, rewardType, rewardArg)
	local name, texturePath, quantity;
	if ( rewardType == "reward" ) then
		name, texturePath, quantity = GetLFGDungeonRewardInfo(dungeonID, rewardIndex);
	elseif ( rewardType == "shortage" ) then
		name, texturePath, quantity = GetLFGDungeonShortageRewardInfo(dungeonID, rewardArg, rewardIndex);
	end
	if ( texturePath ) then	--Otherwise, we may be waiting on the item data to come from the server.
		SetPortraitToTexture(button.texture, texturePath);
	end
	button.rewardType = rewardType;
	button.rewardID = rewardIndex;
	button.rewardArg = rewardArg;
	button:Show();
end
	
function LFDDungeonReadyDialogReward_OnEnter(self, dungeonID)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( self.rewardType == "misc" ) then
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
	elseif ( self.rewardType == "reward" ) then
		GameTooltip:SetLFGDungeonReward(LFDDungeonReadyPopup.dungeonID, self.rewardID);
	elseif ( self.rewardType == "shortage" ) then
		GameTooltip:SetLFGDungeonShortageReward(LFDDungeonReadyPopup.dungeonID, self.rewardArg, self.rewardID);
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
	local isHoliday = select(12, GetLFGProposal());
	
	if ( numBosses == 0 or isHoliday) then
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

function LFDDungeonReadyStatus_ResetReadyStates()
	for i=1, NUM_LFD_MEMBERS do
		local button = _G["LFDDungeonReadyStatusPlayer"..i];
		button.readyStatus = "unknown";
	end
end

function LFDDungeonReadyStatus_UpdateIcon(button)
	local isLeader, role, level, responded, accepted, name, class = GetLFGProposalMember(button:GetID());
	
	button.texture:SetTexCoord(GetTexCoordsForRole(role));
	
	if ( not responded ) then
		button.statusIcon:SetTexture(READY_CHECK_WAITING_TEXTURE);
	elseif ( accepted ) then
		if ( button.readyStatus ~= "accepted" ) then
			button.readyStatus = "accepted";
			PlaySound("LFG_RoleCheck");
		end
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
				info.tooltipText = LFDConstructDeclinedMessage(id);
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

function LFDConstructDeclinedMessage(dungeonID)
	local returnVal;
	for i=1, GetLFDLockPlayerCount() do
		local playerName, lockedReason, subReason1, subReason2 = GetLFDLockInfo(dungeonID, i);
		if ( lockedReason ~= 0 ) then
			local who;
			if ( i == 1 ) then
				who = "SELF_";
			else
				who = "OTHER_";
			end
			if ( returnVal ) then
				returnVal = returnVal.."\n"..format(_G["INSTANCE_UNAVAILABLE_"..who..(LFG_INSTANCE_INVALID_CODES[lockedReason] or "OTHER")], playerName, subReason1, subReason2);
			else
				returnVal = format(_G["INSTANCE_UNAVAILABLE_"..who..(LFG_INSTANCE_INVALID_CODES[lockedReason] or "OTHER")], playerName, subReason1, subReason2);
			end
		end
	end
	return returnVal;
end

--Random frame functions
NUM_LFD_RANDOM_REWARD_FRAMES = 1;
function LFDQueueFrameRandom_UpdateFrame()
	local parentName = "LFDQueueFrameRandomScrollFrameChildFrame"
	local parentFrame = _G[parentName];
	
	local dungeonID = LFDQueueFrame.type;
	
	if ( type(dungeonID) ~= "number" ) then	--We haven't gotten info on available dungeons yet.
		return;
	end
	
	parentFrame:Show();
	
	local holiday;
	local difficulty;
	local dungeonDescription;
	local textureFilename;
	local dungeonName, _,_,_,_,_,_,_,_,textureFilename,difficulty,_,dungeonDescription, isHoliday = GetLFGDungeonInfo(dungeonID);
	local isHeroic = difficulty > 0;
	local doneToday, moneyBase, moneyVar, experienceBase, experienceVar, numRewards = GetLFGDungeonRewards(dungeonID);
	local numRandoms = 4 - GetNumPartyMembers();
	local moneyAmount = moneyBase + moneyVar * numRandoms;
	local experienceGained = experienceBase + experienceVar * numRandoms;

	
	local backgroundTexture;
	
	local leaderChecked, tankChecked, healerChecked, damageChecked = LFDQueueFrame_GetRoles();
	
	--HACK
	if ( dungeonID == 341 ) then	--Trollpocalypse Heroic
		backgroundTexture = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-TROLLPOCALYPSE";
	elseif ( textureFilename ~= "" ) then
		backgroundTexture = "Interface\\LFGFrame\\UI-LFG-HOLIDAY-BACKGROUND-"..textureFilename;
	elseif ( isHeroic ) then
		backgroundTexture = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-HEROIC";
	else
		backgroundTexture = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-QUESTPAPER";
	end
	LFDQueueFrameBackground:SetTexture(backgroundTexture);
	
	local lastFrame = parentFrame.rewardsLabel;
	if ( isHoliday ) then
		if ( doneToday ) then
			parentFrame.rewardsDescription:SetText(LFD_HOLIDAY_REWARD_EXPLANATION2);
		else
			parentFrame.rewardsDescription:SetText(LFD_HOLIDAY_REWARD_EXPLANATION1);
		end
		parentFrame.title:SetText(dungeonName);
		parentFrame.description:SetText(dungeonDescription);
	else
		local numCompletions, isWeekly = LFDQueueFrameRandom_EstimateRemainingCompletions(dungeonID);
		if ( numCompletions <= 0 ) then
			parentFrame.rewardsDescription:SetText(LFD_RANDOM_REWARD_EXPLANATION2);
		elseif ( isWeekly ) then
			parentFrame.rewardsDescription:SetText(format(LFD_REWARD_DESCRIPTION_WEEKLY, numCompletions));
		else
			parentFrame.rewardsDescription:SetText(format(LFD_REWARD_DESCRIPTION_DAILY, numCompletions));
		end
		parentFrame.title:SetText(LFG_TYPE_RANDOM_DUNGEON);
		parentFrame.description:SetText(LFD_RANDOM_EXPLANATION);
	end
		
	local itemButtonIndex = 1;
	for i=1, numRewards do
		local name, texture, numItems = GetLFGDungeonRewardInfo(dungeonID, i);
		lastFrame = LFDQueueFrameRandom_SetItemButton(itemButtonIndex, i, name, texture, numItems, nil);
		itemButtonIndex = itemButtonIndex + 1;
	end
	
	for shortageIndex=1, LFG_ROLE_NUM_SHORTAGE_TYPES do
		local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(dungeonID, shortageIndex);
		if ( eligible and ((tankChecked and forTank) or (healerChecked and forHealer) or (damageChecked and forDamage)) ) then
			for rewardIndex=1, itemCount do
				local name, texture, numItems = GetLFGDungeonShortageRewardInfo(dungeonID, shortageIndex, rewardIndex);
				lastFrame = LFDQueueFrameRandom_SetItemButton(itemButtonIndex, rewardIndex, name, texture, numItems, shortageIndex, forTank, forHealer, forDamage);
				itemButtonIndex = itemButtonIndex + 1;
			end
		end
	end
	
	for i=itemButtonIndex, NUM_LFD_RANDOM_REWARD_FRAMES do
		_G[parentName.."Item"..i]:Hide();
	end
	
	local totalRewards = itemButtonIndex - 1;
		
	if ( totalRewards > 0 or ((moneyVar == 0 and experienceVar == 0) and (moneyAmount > 0 or experienceGained > 0)) ) then
		parentFrame.rewardsLabel:Show();
		parentFrame.rewardsDescription:Show();
		lastFrame = parentFrame.rewardsDescription;
	else
		parentFrame.rewardsLabel:Hide();
		parentFrame.rewardsDescription:Hide();
	end
	
	if ( totalRewards > 0 ) then
		lastFrame = _G[parentName.."Item"..(totalRewards - mod(totalRewards+1, 2))];
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
	
	if ( not isHoliday ) then
		parentFrame.randomList:Show();
	else
		parentFrame.randomList:Hide();
	end
	
	parentFrame.spacer:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10);
	LFDQueueFrame_UpdateRoleIncentives();
end

function LFDQueueFrameRandom_SetItemButton(index, id, name, texture, numItems, shortageIndex, showTankIcon, showHealerIcon, showDamageIcon)
	local parentName = "LFDQueueFrameRandomScrollFrameChildFrame";
	local frame = _G[parentName.."Item"..index];
	if ( not frame ) then
		frame = CreateFrame("Button", parentName.."Item"..index, _G[parentName], "LFDRandomDungeonLootTemplate");
		NUM_LFD_RANDOM_REWARD_FRAMES = index;
		if ( mod(index, 2) == 0 ) then
			frame:SetPoint("LEFT", parentName.."Item"..(index-1), "RIGHT", 0, 0);
		else
			frame:SetPoint("TOPLEFT", parentName.."Item"..(index-2), "BOTTOMLEFT", 0, -5);
		end
	end
	frame:SetID(id);
	
	_G[parentName.."Item"..index.."Name"]:SetText(name);
	SetItemButtonTexture(frame, texture);
	SetItemButtonCount(frame, numItems);
	frame.shortageIndex = shortageIndex;
	
	if ( shortageIndex ) then
		frame.shortageBorder:Show();
	else
		frame.shortageBorder:Hide();
	end
	
	local numRoles = (showTankIcon and 1 or 0) + (showHealerIcon and 1 or 0) + (showDamageIcon and 1 or 0);
	
	--Show role icons if this reward is specific to a role:
	frame.roleIcon1:Hide();
	frame.roleIcon2:Hide();
	
	if ( numRoles > 0 and numRoles < 3 ) then	--If we give it to all 3 roles, no reason to show icons.
		local roleIcon = frame.roleIcon1;
		if ( showTankIcon ) then
			roleIcon.texture:SetTexCoord(GetTexCoordsForRoleSmallCircle("TANK"));
			roleIcon.role = "TANK";
			roleIcon:Show();
			roleIcon = frame.roleIcon2;
		end
		if ( showHealerIcon ) then
			roleIcon.texture:SetTexCoord(GetTexCoordsForRoleSmallCircle("HEALER"));
			roleIcon.role = "HEALER";
			roleIcon:Show();
			roleIcon = frame.roleIcon2;
		end
		if ( showDamageIcon ) then
			roleIcon.texture:SetTexCoord(GetTexCoordsForRoleSmallCircle("DAMAGER"));
			roleIcon.role = "DAMAGER";
			roleIcon:Show();
			roleIcon = frame.roleIcon2;
		end
		
		if ( numRoles == 2 ) then
			frame.roleIcon1:SetPoint("LEFT", frame, "TOPLEFT", 1, -2);
		else
			frame.roleIcon1:SetPoint("LEFT", frame, "TOPLEFT", 10, -2);
		end
	end
	
	frame:Show();
	return frame;
end

function LFDQueueFrameRandom_EstimateRemainingCompletions(dungeonID)
	local currencyID, currencyQuantity, specificQuantity, specificLimit, overallQuantity, overallLimit, periodPurseQuantity, periodPurseLimit, isWeekly = GetLFGDungeonRewardCapInfo(LFDQueueFrame.type);
	if(not currencyID) then
		return 0, false;
	end

	local remainingAllotment = min(specificLimit - specificQuantity, overallLimit - overallQuantity);
	if ( periodPurseLimit ~= 0 ) then
		remainingAllotment = min(remainingAllotment, periodPurseLimit - periodPurseQuantity);
	end

	return ceil(remainingAllotment / currencyQuantity), isWeekly;
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
			local info = LFGGetDungeonInfoByID(dungeonID);
			local name, minLevel, maxLevel, recLevel = info[LFG_RETURN_VALUES.name], info[LFG_RETURN_VALUES.minLevel], info[LFG_RETURN_VALUES.maxLevel], info[LFG_RETURN_VALUES.recLevel];
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
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
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
	
	for i = 1, GetNumPartyMembers() do
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
	for i = GetNumPartyMembers() + 1, MAX_PARTY_MEMBERS do
		local nameLabel = _G["LFDQueueFrameCooldownFrameName"..i];
		local statusLabel = _G["LFDQueueFrameCooldownFrameStatus"..i];
		nameLabel:Hide();
		statusLabel:Hide();
	end
	
	if ( GetNumPartyMembers() == 0 ) then
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

local embeddedTankIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:20:20:0:5:64:64:0:19:22:41|t";
local embeddedHealerIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:20:20:0:5:64:64:20:39:1:20|t";
local embeddedDamageIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:20:20:0:5:64:64:20:39:22:41|t";

function LFDSearchStatus_Update()
	local LFDSearchStatus = LFDSearchStatus;
	local hasData,  leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, instanceType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats();
	
	LFDSearchStatus_UpdateRoles();
	
	if ( not hasData ) then
		LFDSearchStatus:SetHeight(145);
		LFDSearchStatusPlayer_SetFound(LFDSearchStatusTank1, false)
		LFDSearchStatusPlayer_SetFound(LFDSearchStatusHealer1, false);
		for i=1, NUM_DAMAGERS do
			LFDSearchStatusPlayer_SetFound(_G["LFDSearchStatusDamage"..i], false);
		end
		LFDSearchStatus.statistic:Hide();
		LFDSearchStatus.elapsedWait:SetFormattedText(TIME_IN_QUEUE, LESS_THAN_ONE_MINUTE);
		
		LFDSearchStatus:SetScript("OnUpdate", nil);
		return;
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
	
	LFDSearchStatus.queuedTime = queuedTime;
	local elapsedTime = GetTime() - queuedTime;
	LFDSearchStatus.elapsedWait:SetFormattedText(TIME_IN_QUEUE, (elapsedTime >= 60) and SecondsToTime(elapsedTime) or LESS_THAN_ONE_MINUTE);
	LFDSearchStatus.elapsedWait:Show();
	
	if ( myWait == -1 ) then
		LFDSearchStatus.statistic:Hide();
		LFDSearchStatus:SetHeight(145);
	else
		LFDSearchStatus.statistic:Show();
		LFDSearchStatus:SetHeight(170);
		LFDSearchStatus.statistic:SetFormattedText(LFG_STATISTIC_AVERAGE_WAIT, myWait == -1 and TIME_UNKNOWN or SecondsToTime(myWait, false, false, 1));
	end
	LFDSearchStatus:SetScript("OnUpdate", LFDSearchStatus_OnUpdate);
end

function LFDSearchStatus_OnUpdate(self, elapsed)
	local elapsedTime = GetTime() - self.queuedTime;
	self.elapsedWait:SetFormattedText(TIME_IN_QUEUE, (elapsedTime >= 60) and SecondsToTime(elapsedTime) or LESS_THAN_ONE_MINUTE);
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
	
	if ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "listed"  ) then --During the proposal, they must use the proposal buttons to leave the queue.
		if ( mode == "queued" or mode =="proposal" or mode == "rolecheck" or not LFDQueueFramePartyBackfill:IsVisible() ) then
			LFDQueueFrameFindGroupButton:Enable();
		else
			LFDQueueFrameFindGroupButton:Disable();
		end
		LFRQueueFrameNoLFRWhileLFDLeaveQueueButton:Enable();
	else
		LFDQueueFrameFindGroupButton:Disable();
		LFRQueueFrameNoLFRWhileLFDLeaveQueueButton:Disable();
	end
	
	if ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "queued" ) then
		LFDQueueFramePartyBackfillBackfillButton:Enable();
	else
		LFDQueueFramePartyBackfillBackfillButton:Disable();
	end
end

LFDHiddenByCollapseList = {};
function LFDQueueFrame_Update()
	local enableList;
	
	local mode, submode = GetLFGMode();
	
	if ( LFD_IsEmpowered() and mode ~= "queued") then
		enableList = LFGEnabledList;
	else
		enableList = LFGQueuedForList;
	end
	
	LFDDungeonList = GetLFDChoiceOrder(LFDDungeonList);
		
	LFGQueueFrame_UpdateLFGDungeonList(LFDDungeonList, LFDHiddenByCollapseList, LFGLockList, LFGDungeonInfo, enableList, LFGCollapseList, LFD_CURRENT_FILTER);
	
	LFDQueueFrameSpecificList_Update();
	LFDFrame_UpdateCapBar();
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