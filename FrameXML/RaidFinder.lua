MAX_RAID_FINDER_COOLDOWN_NAMES = 8;

local function isRaidFinderDungeonDisplayable(id)
	local name, typeID, subtypeID, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(id);
	local myLevel = UnitLevel("player");
	return myLevel >= minLevel and myLevel <= maxLevel and EXPANSION_LEVEL >= expansionLevel;
end

function RaidFinderFrame_OnLoad(self)
	self:RegisterEvent("LFG_LOCK_INFO_RECEIVED");
end

function RaidFinderFrame_OnEvent(self, event, ...)
	if ( event == "LFG_LOCK_INFO_RECEIVED" ) then
		if ( not RaidFinderQueueFrame.raid or not IsLFGDungeonJoinable(RaidFinderQueueFrame.raid) ) then
			RaidFinderQueueFrame_SetRaid(GetBestRFChoice());
			--RaidFinderQueueFrame.raid = GetBestRFChoice();
			--UIDropDownMenu_SetSelectedValue(RaidFinderQueueFrameSelectionDropDown, RaidFinderQueueFrame.raid);
		end
		RaidFinderFrame_UpdateAvailability();
	end
end

function RaidFinderFrame_OnShow(self)
	RequestLFDPlayerLockInfo();
	RequestLFDPartyLockInfo();
	RaidFinderFrameFindRaidButton_Update();
	LFGBackfillCover_Update(RaidFinderQueueFrame.PartyBackfill, true);
	RaidFinderFrame_UpdateAvailability();
	PlaySound("igCharacterInfoOpen");
end

-- unused now, might need this logic for Group Finder
function RaidFinderFrame_UpdateAvailability()
	--Update the cover panel (specifically for when you hit level 86 and can no longer queue
	--for any RF raids until you hit level 90).
	local available = false;
	local nextLevel = nil;
	local level = UnitLevel("player");
	for i=1, GetNumRFDungeons() do
		local id, name, typeID, subtype, minLevel, maxLevel = GetRFDungeonInfo(i);
		if ( level >= minLevel and level <= maxLevel ) then
			available = true;
			nextLevel = nil;
			break;
		elseif ( level < minLevel and (not nextLevel or minLevel < nextLevel ) ) then
			nextLevel = minLevel;
		end
	end
	if ( available ) then
		RaidFinderFrame.NoRaidsCover:Hide();
	else
		RaidFinderFrame.NoRaidsCover:Show();
		if ( nextLevel ) then
			RaidFinderFrame.NoRaidsCover.Label:SetFormattedText(NO_RF_AVAILABLE_WITH_NEXT_LEVEL, nextLevel);
		else
			RaidFinderFrame.NoRaidsCover.Label:SetText(NO_RF_AVAILABLE);
		end
	end
	--[[
	local enableTab = false;
	local isPlayerEligible = false;
	for i = 1, GetNumRFDungeons() do
		local id, name = GetRFDungeonInfo(i);
		local isAvailable, isAvailableToPlayer = IsLFGDungeonJoinable(id);
		if ( isAvailable ) then
			-- there is at least one raid that can be selected, make it so
			RaidFinderQueueFrameIneligibleFrame_SetIneligibility(false, false);
			PanelTemplates_EnableTab(RaidParentFrame, 1);
			return;
		elseif ( isAvailableToPlayer ) then
			enableTab = true;
			isPlayerEligible = true;
		elseif ( isRaidFinderDungeonDisplayable(id) ) then
			enableTab = true;
		end
	end
	if ( enableTab ) then
		-- at least one raid is visible, but none can be selected
		PanelTemplates_EnableTab(RaidParentFrame, 1);
		if ( isPlayerEligible ) then
			RaidFinderQueueFrameIneligibleFrame_SetIneligibility(true, false);
		else
			RaidFinderQueueFrameIneligibleFrame_SetIneligibility(false, true);
		end
	else
		-- nothing in the dropdown, just block the tab
		RaidFinderFrame:Hide();
		PanelTemplates_DisableTab(RaidParentFrame, 1);
		if ( RaidParentFrame.selectectTab == 1 ) then
			RaidParentFrame_SetView(2);
		end
	end
	]]--
end

-- returns true if the inelibile frame is shown
function RaidFinderQueueFrameIneligibleFrame_SetIneligibility(onGroup, onPlayer)
	local frame = RaidFinderQueueFrameIneligibleFrame;
	if ( onGroup ) then
		frame.ineligibleGroup = true;
		frame.ineligiblePlayer = false;
	elseif ( onPlayer ) then
		frame.ineligibleGroup = false;
		frame.ineligiblePlayer = true;
	else
		frame.ineligibleGroup = false;
		frame.ineligiblePlayer = false;
	end
	RaidFinderQueueFrameIneligibleFrame_UpdateFrame(frame);
end

-- returns true if the inelibile frame is shown
function RaidFinderQueueFrameIneligibleFrame_SetQueueRestriction(otherQueue)
	local frame = RaidFinderQueueFrameIneligibleFrame;
	frame.queueRestriction = otherQueue;
	return RaidFinderQueueFrameIneligibleFrame_UpdateFrame(frame);
end

function RaidFinderQueueFrameIneligibleFrame_UpdateFrame(self)
	if ( self.queueRestriction ) then
		self.leaveQueueButton:Show();
		if ( self.queueRestriction == "lfd" ) then
			self.description:SetText(NO_RF_WHILE_LFD);
			self.leaveQueueButton:SetText(LEAVE_QUEUE);
			if ( LFD_IsEmpowered() ) then
				self.leaveQueueButton:Enable();
			else
				self.leaveQueueButton:Disable();
			end
		else
			self.description:SetText(NO_RF_WHILE_LFR);
			if ( IsInGroup() ) then
				self.leaveQueueButton:SetText(UNLIST_MY_GROUP);
			else
				self.leaveQueueButton:SetText(UNLIST_ME);
			end
			if ( RaidBrowser_IsEmpowered() ) then
				self.leaveQueueButton:Enable();
			else
				self.leaveQueueButton:Disable();
			end
		end
		self:Show();
		return true;
	elseif ( self.ineligibleGroup ) then
		self.description:SetText(LFR_QUEUE_GROUP_INELIGIBLE);
		self.leaveQueueButton:Hide();
		self:Show();
		return true;
	elseif ( self.ineligiblePlayer ) then
		self.description:SetText(LFR_QUEUE_PLAYER_INELIGIBLE);
		self.leaveQueueButton:Hide();
		self:Show();
		return true;
	else
		self:Hide();
	end
end

function RaidFinderQueueFrameSelectionDropDown_SetUp(self)
	UIDropDownMenu_SetWidth(self, 180);
	UIDropDownMenu_Initialize(self, RaidFinderQueueFrameSelectionDropDown_Initialize);
	if ( RaidFinderQueueFrame.raid ) then
		UIDropDownMenu_SetSelectedValue(RaidFinderQueueFrameSelectionDropDown, RaidFinderQueueFrame.raid);
	else
		UIDropDownMenu_SetText(self, "")
	end
end

function RaidFinderQueueFrameSelectionDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	
	-- If we ever change this logic, we also need to change the logic in RaidFinderFrame_UpdateAvailability
	for i=1, GetNumRFDungeons() do
		local id, name = GetRFDungeonInfo(i);
		local isAvailable, isAvailableToPlayer = IsLFGDungeonJoinable(id);
		if ( isAvailable or isAvailableToPlayer or isRaidFinderDungeonDisplayable(id) ) then
			if ( isAvailable ) then
				info.text = name; --Note that the dropdown text may be manually changed in RaidFinderQueueFrame_SetRaid
				info.value = id;
				info.isTitle = nil;
				info.func = RaidFinderQueueFrameSelectionDropDownButton_OnClick;
				info.disabled = nil;
				info.checked = (RaidFinderQueueFrame.raid == info.value);
				info.tooltipWhileDisabled = nil;
				info.tooltipOnButton = nil;
				info.tooltipTitle = nil;
				info.tooltipText = nil;
				UIDropDownMenu_AddButton(info);
			else
				info.text = name; --Note that the dropdown text may be manually changed in RaidFinderQueueFrame_SetRaid
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

function RaidFinderQueueFrameSelectionDropDownButton_OnClick(self)
	RaidFinderQueueFrame_SetRaid(self.value);
end

function RaidFinderQueueFrame_SetRaid(value)
	RaidFinderQueueFrame.raid = value;
	UIDropDownMenu_SetSelectedValue(RaidFinderQueueFrameSelectionDropDown, value);
	if ( value ) then
		local name = GetLFGDungeonInfo(value);
		UIDropDownMenu_SetText(RaidFinderQueueFrameSelectionDropDown, name);
	else
		UIDropDownMenu_SetText(RaidFinderQueueFrameSelectionDropDown, "");
	end
	RaidFinderQueueFrameRewards_UpdateFrame();
end

function RaidFinderQueueFrame_Join()
	if ( RaidFinderQueueFrame.raid ) then
		ClearAllLFGDungeons(LE_LFG_CATEGORY_RF);
		SetLFGDungeon(LE_LFG_CATEGORY_RF, RaidFinderQueueFrame.raid);
		JoinLFG(LE_LFG_CATEGORY_RF);
	end
end

function RaidFinderFrameRoleCheckButton_OnClick(self)
	RaidFinderQueueFrame_SetRoles();
end

function RaidFinderQueueFrame_SetRoles()
	SetLFGRoles(RaidFinderQueueFrameRoleButtonLeader.checkButton:GetChecked(), 
		RaidFinderQueueFrameRoleButtonTank.checkButton:GetChecked(),
		RaidFinderQueueFrameRoleButtonHealer.checkButton:GetChecked(),
		RaidFinderQueueFrameRoleButtonDPS.checkButton:GetChecked());
end

function RaidFinderQueueFrameRewards_UpdateFrame()
	LFGRewardsFrame_UpdateFrame(RaidFinderQueueFrameScrollFrameChildFrame, RaidFinderQueueFrame.raid, RaidFinderQueueFrameBackground);
end

function RaidFinderFrameFindRaidButton_Update()
	local mode, subMode = GetLFGMode(LE_LFG_CATEGORY_RF);
	if ( mode == "queued" or mode == "rolecheck" or mode == "proposal" or mode == "suspended" ) then
		RaidFinderFrameFindRaidButton:SetText(LEAVE_QUEUE);
	else
		if ( IsInGroup() and GetNumGroupMembers() > 1 ) then
			RaidFinderFrameFindRaidButton:SetText(JOIN_AS_PARTY);
		else
			RaidFinderFrameFindRaidButton:SetText(FIND_A_GROUP);
		end
	end
	
	if ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "listed"  ) then --During the proposal, they must use the proposal buttons to leave the queue.
		if ( (mode == "queued" or mode == "rolecheck" or mode == "suspended")	--The players can dequeue even if one of the two cover panels is up.
			or (not RaidFinderQueueFramePartyBackfill:IsVisible() and not RaidFinderQueueFrameCooldownFrame:IsVisible()) ) then
			RaidFinderFrameFindRaidButton:Enable();
		else
			RaidFinderFrameFindRaidButton:Disable();
		end
	else
		RaidFinderFrameFindRaidButton:Disable();
	end

	if ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "queued" and mode ~= "suspended" and mode ~= "rolecheck" ) then
		RaidFinderQueueFramePartyBackfillBackfillButton:Enable();
	else
		RaidFinderQueueFramePartyBackfillBackfillButton:Disable();
	end
end

--Cooldown panel
function RaidFinderQueueFrameCooldownFrame_OnLoad(self)
	self:SetFrameLevel(RaidFinderQueueFrame:GetFrameLevel() + 9);	--This value also needs to be set when SetParent is called in LFDQueueFrameRandomCooldownFrame_Update.
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD");	--For logging in/reloading ui
	self:RegisterEvent("UNIT_AURA");	--The cooldown is still technically a debuff
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
end

function RaidFinderQueueFrameCooldownFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event ~= "UNIT_AURA" or arg1 == "player" or strsub(arg1, 1, 5) == "party" or strsub(arg1, 1, 5) == "raid" ) then
		RaidFinderQueueFrameCooldownFrame_Update();
	end
end

function RaidFinderQueueFrameCooldownFrame_OnUpdate(self, elapsed)
	local timeRemaining = self.myExpirationTime - GetTime();
	if ( timeRemaining > 0 ) then
		self.time:SetText(SecondsToTime(ceil(timeRemaining)));
	else
		RaidFinderQueueFrameCooldownFrame_Update();
	end
end

function RaidFinderQueueFrameCooldownFrame_Update()
	local cooldownFrame = RaidFinderQueueFrameCooldownFrame;
	local shouldShow = false;
	
	local cooldownExpiration = GetLFGDeserterExpiration();
	
	cooldownFrame.myExpirationTime = cooldownExpiration;

	local tokenPrefix;
	local numMembers;
	if ( IsInRaid() ) then
		tokenPrefix = "raid";
		numMembers = GetNumGroupMembers();
	else
		tokenPrefix = "party";
		numMembers = GetNumSubgroupMembers();
	end
	
	local numCooldowns = 0;
	for i = 1, numMembers do
		if ( UnitHasLFGDeserter(tokenPrefix..i) and not UnitIsUnit(tokenPrefix..i, "player") ) then
			numCooldowns = numCooldowns + 1;

			if ( numCooldowns <= MAX_RAID_FINDER_COOLDOWN_NAMES ) then
				local nameLabel = _G["RaidFinderQueueFrameCooldownFrameName"..numCooldowns];
				nameLabel:Show();

				local _, classFilename = UnitClass(tokenPrefix..i);
				local classColor = classFilename and RAID_CLASS_COLORS[classFilename] or NORMAL_FONT_COLOR;
				nameLabel:SetFormattedText("|cff%.2x%.2x%.2x%s|r", classColor.r * 255, classColor.g * 255, classColor.b * 255, UnitName(tokenPrefix..i));
			end
		
			shouldShow = true;
		end
	end
	for i = numCooldowns + 1, MAX_RAID_FINDER_COOLDOWN_NAMES do
		local nameLabel = _G["RaidFinderQueueFrameCooldownFrameName"..i];
		nameLabel:Hide();
	end
	
	local anchorSide = "LEFT";	--Used to center text when we have 4 or fewer players.
	local anchorOffset = 25;
	if ( numCooldowns == 0 ) then
		cooldownFrame.description:SetPoint("TOP", 0, -85);
		cooldownFrame.additionalPlayersFrame:Hide();
	elseif ( numCooldowns <= MAX_RAID_FINDER_COOLDOWN_NAMES / 2 ) then
		cooldownFrame.description:SetPoint("TOP", 0, -30);
		for i=2, MAX_RAID_FINDER_COOLDOWN_NAMES do
			local nameLabel = _G["RaidFinderQueueFrameCooldownFrameName"..i];
			nameLabel:ClearAllPoints();
			nameLabel:SetPoint("TOP", _G["RaidFinderQueueFrameCooldownFrameName"..(i-1)], "BOTTOM", 0, -5);
		end
		cooldownFrame.additionalPlayersFrame:Hide();
		anchorSide = "";
		anchorOffset = 0;
	else
		if ( numCooldowns > MAX_RAID_FINDER_COOLDOWN_NAMES ) then
			cooldownFrame.additionalPlayersFrame.text:SetFormattedText(RF_COOLDOWN_ADDITIONAL_PEOPLE, numCooldowns - MAX_RAID_FINDER_COOLDOWN_NAMES);
			cooldownFrame.additionalPlayersFrame:Show();
		else
			cooldownFrame.additionalPlayersFrame:Hide();
		end
		cooldownFrame.description:SetPoint("TOP", 0, -30);
		for i=2, MAX_RAID_FINDER_COOLDOWN_NAMES do
			local nameLabel = _G["RaidFinderQueueFrameCooldownFrameName"..i];
			nameLabel:ClearAllPoints();
			if ( i % 2 == 0 ) then
				nameLabel:SetPoint("LEFT", _G["RaidFinderQueueFrameCooldownFrameName"..(i-1)], "RIGHT", 15, 0);
			else
				nameLabel:SetPoint("TOP", _G["RaidFinderQueueFrameCooldownFrameName"..(i-2)], "BOTTOM", 0, -5);
			end
		end
	end

	RaidFinderQueueFrameCooldownFrameName1:ClearAllPoints();
	if ( cooldownExpiration and GetTime() < cooldownExpiration ) then
		shouldShow = true;
		cooldownFrame.description:SetText(RF_DESERTER_YOU);
		cooldownFrame.time:SetText(SecondsToTime(ceil(cooldownExpiration - GetTime())));
		cooldownFrame.time:Show();
		
		cooldownFrame:SetScript("OnUpdate", RaidFinderQueueFrameCooldownFrame_OnUpdate);

		if ( numCooldowns > 0 ) then
			cooldownFrame.secondaryDescription:Show();
			RaidFinderQueueFrameCooldownFrameName1:SetPoint("TOP"..anchorSide, cooldownFrame.secondaryDescription, "BOTTOM"..anchorSide, anchorOffset, -20);
		else
			cooldownFrame.secondaryDescription:Hide();
			RaidFinderQueueFrameCooldownFrameName1:SetPoint("TOP"..anchorSide, cooldownFrame.description, "BOTTOM"..anchorSide, anchorOffset, -20);
		end
	else
		cooldownFrame.description:SetText(RF_DESERTER_OTHER);
		cooldownFrame.time:Hide();
		
		cooldownFrame:SetScript("OnUpdate", nil);
		cooldownFrame.secondaryDescription:Hide();
		RaidFinderQueueFrameCooldownFrameName1:SetPoint("TOP"..anchorSide, cooldownFrame.description, "BOTTOM"..anchorSide, anchorOffset, -20);
	end
	
	if ( shouldShow and not RaidFinderQueueFramePartyBackfill:IsShown() ) then
		cooldownFrame:Show();
	else
		cooldownFrame:Hide();
	end
end

function RaidFinderQueueFrameCooldownAdditionalPlayers_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(DESERTER);
	if ( IsInRaid() ) then
		for i=1, GetNumGroupMembers() do
			if ( UnitHasLFGDeserter("raid"..i) ) then
				GameTooltip:AddLine(UnitName("raid"..i), 1, 1, 1);
			end
		end
	end
	GameTooltip:Show();
end
