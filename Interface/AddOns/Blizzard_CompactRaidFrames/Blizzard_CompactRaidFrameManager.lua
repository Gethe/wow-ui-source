NUM_WORLD_RAID_MARKERS = 8;
NUM_RAID_ICONS = 8;

WORLD_RAID_MARKER_ORDER = {};
WORLD_RAID_MARKER_ORDER[1] = 8;
WORLD_RAID_MARKER_ORDER[2] = 4;
WORLD_RAID_MARKER_ORDER[3] = 1;
WORLD_RAID_MARKER_ORDER[4] = 7;
WORLD_RAID_MARKER_ORDER[5] = 2;
WORLD_RAID_MARKER_ORDER[6] = 3;
WORLD_RAID_MARKER_ORDER[7] = 6;
WORLD_RAID_MARKER_ORDER[8] = 5;

MINIMUM_RAID_CONTAINER_HEIGHT = 72;

function CompactRaidFrameManager_OnLoad(self)
	self.container = CompactRaidFrameContainer;
	self.container:SetParent(self);

	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UPDATE_ACTIVE_BATTLEFIELD");
	self:RegisterEvent("UNIT_FLAGS");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");

	self.container:SetFlowFilterFunction(CRFFlowFilterFunc)
	self.container:SetGroupFilterFunction(CRFGroupFilterFunc)
	CompactRaidFrameManager_UpdateContainerBounds();

	CompactRaidFrameManager_Collapse();

	--Set up the options flow container
	FlowContainer_Initialize(self.displayFrame.optionsFlowContainer);
end

function CompactRaidFrameManager_OnEvent(self, event, ...)
	if ( event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" ) then
		CompactRaidFrameManager_UpdateContainerBounds();
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "UPDATE_ACTIVE_BATTLEFIELD" ) then
		CompactRaidFrameManager_UpdateShown();
		CompactRaidFrameManager_UpdateDisplayCounts();
		CompactRaidFrameManager_UpdateLabel();
	elseif ( event == "UNIT_FLAGS" or event == "PLAYER_FLAGS_CHANGED" ) then
		CompactRaidFrameManager_UpdateDisplayCounts();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		CompactRaidFrameManager_UpdateShown();
		CompactRaidFrameManager_UpdateDisplayCounts();
		CompactRaidFrameManager_UpdateOptionsFlowContainer();
		CompactRaidFrameManager_UpdateRaidIcons();
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		CompactRaidFrameManager_UpdateOptionsFlowContainer();
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		CompactRaidFrameManager_UpdateRaidIcons();
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		CompactRaidFrameManager_UpdateRaidIcons();
	end
end

function CompactRaidFrameManager_UpdateShown()
	if ShouldShowRaidFrames() or ShouldShowPartyFrames() then
		CompactRaidFrameManager:Show();
	else
		CompactRaidFrameManager:Hide();
	end
	CompactRaidFrameManager_UpdateOptionsFlowContainer();
	CompactRaidFrameManager_UpdateContainerVisibility();
end

function CompactRaidFrameManager_UpdateLabel()
	if ( IsInRaid() ) then
		CompactRaidFrameManager.displayFrame.label:SetText(RAID_MEMBERS);
	else
		CompactRaidFrameManager.displayFrame.label:SetText(PARTY_MEMBERS);
	end
end

function CompactRaidFrameManager_Toggle()
	if ( CompactRaidFrameManager.collapsed ) then
		CompactRaidFrameManager_Expand();
	else
		CompactRaidFrameManager_Collapse();
	end
end

function CompactRaidFrameManager_Expand()
	CompactRaidFrameManager.collapsed = false;
	CompactRaidFrameManager:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -7, -140);
	CompactRaidFrameManager.displayFrame:Show();
	CompactRaidFrameManager.toggleButton:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1);
end

function CompactRaidFrameManager_Collapse()
	CompactRaidFrameManager.collapsed = true;
	CompactRaidFrameManager:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -182, -140);
	CompactRaidFrameManager.displayFrame:Hide();
	CompactRaidFrameManager.toggleButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 1);
end

function CompactRaidFrameManager_UpdateOptionsFlowContainer()
	local container = CompactRaidFrameManager.displayFrame.optionsFlowContainer;

	FlowContainer_RemoveAllObjects(container);
	FlowContainer_PauseUpdates(container);

	if ( IsInRaid() ) then
		FlowContainer_AddObject(container, CompactRaidFrameManager.displayFrame.filterOptions);
		CompactRaidFrameManager.displayFrame.filterOptions:Show();
	else
		CompactRaidFrameManager.displayFrame.filterOptions:Hide();
	end

	if ( not IsInRaid() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") ) then
		FlowContainer_AddObject(container, CompactRaidFrameManager.displayFrame.raidMarkers);
		CompactRaidFrameManager.displayFrame.raidMarkers:Show();
	else
		CompactRaidFrameManager.displayFrame.raidMarkers:Hide();
	end

	if ( not IsInRaid() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") ) then
		FlowContainer_AddObject(container, CompactRaidFrameManager.displayFrame.leaderOptions);
		CompactRaidFrameManager.displayFrame.leaderOptions:Show();
	else
		CompactRaidFrameManager.displayFrame.leaderOptions:Hide();
	end

	if ( not IsInRaid() and UnitIsGroupLeader("player") and not HasLFGRestrictions() ) then
		FlowContainer_AddLineBreak(container);
		FlowContainer_AddSpacer(container, 20);
		FlowContainer_AddObject(container, CompactRaidFrameManager.displayFrame.convertToRaid);
		CompactRaidFrameManager.displayFrame.convertToRaid:Show();
	else
		CompactRaidFrameManager.displayFrame.convertToRaid:Hide();
	end

	if ShouldShowRaidFrames() then
		FlowContainer_AddLineBreak(container);
		FlowContainer_AddSpacer(container, 20);
		FlowContainer_AddObject(container, CompactRaidFrameManager.displayFrame.editMode);
		FlowContainer_AddObject(container, CompactRaidFrameManager.displayFrame.hiddenModeToggle);
		CompactRaidFrameManager.displayFrame.editMode:Show();
		CompactRaidFrameManager.displayFrame.hiddenModeToggle:Show();
	else
		FlowContainer_AddLineBreak(container);
		FlowContainer_AddSpacer(container, 20);
		FlowContainer_AddObject(container, CompactRaidFrameManager.displayFrame.editMode);
		CompactRaidFrameManager.displayFrame.editMode:Show();
		CompactRaidFrameManager.displayFrame.hiddenModeToggle:Hide();
	end

	if ( IsInRaid() and UnitIsGroupLeader("player") ) then
		FlowContainer_AddLineBreak(container);
		FlowContainer_AddSpacer(container, 20);
		FlowContainer_AddObject(container, CompactRaidFrameManager.displayFrame.everyoneIsAssistButton);
		CompactRaidFrameManager.displayFrame.everyoneIsAssistButton:Show();
	else
		CompactRaidFrameManager.displayFrame.everyoneIsAssistButton:Hide();
	end

	FlowContainer_ResumeUpdates(container);

	local usedX, usedY = FlowContainer_GetUsedBounds(container);
	CompactRaidFrameManager:SetHeight(usedY + 40);

	--Then, we update which specific buttons are enabled.

	--Raid leaders and assistants and leaders of non-dungeon finder parties may initiate a role poll.
	if ( IsInGroup() and not HasLFGRestrictions() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) ) then
		CompactRaidFrameManager.displayFrame.leaderOptions.rolePollButton:Enable();
		CompactRaidFrameManager.displayFrame.leaderOptions.rolePollButton:SetAlpha(1);
	else
		CompactRaidFrameManager.displayFrame.leaderOptions.rolePollButton:Disable();
		CompactRaidFrameManager.displayFrame.leaderOptions.rolePollButton:SetAlpha(0.5);
	end

	--Any sort of leader may initiate a ready check.
	if ( IsInGroup() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) ) then
		CompactRaidFrameManager.displayFrame.leaderOptions.readyCheckButton:Enable();
		CompactRaidFrameManager.displayFrame.leaderOptions.readyCheckButton:SetAlpha(1);
		CompactRaidFrameManager.displayFrame.leaderOptions.countdownButton:Enable();
		CompactRaidFrameManager.displayFrame.leaderOptions.countdownButton:SetAlpha(1);
	else
		CompactRaidFrameManager.displayFrame.leaderOptions.readyCheckButton:Disable();
		CompactRaidFrameManager.displayFrame.leaderOptions.readyCheckButton:SetAlpha(0.5);
		CompactRaidFrameManager.displayFrame.leaderOptions.countdownButton:Disable();
		CompactRaidFrameManager.displayFrame.leaderOptions.countdownButton:SetAlpha(0.5);
	end
end

local function RaidWorldMarker_OnClick(self, arg1, arg2, checked)
	if ( checked ) then
		ClearRaidMarker(arg1);
	else
		PlaceRaidMarker(arg1);
	end
end

local function ClearRaidWorldMarker_OnClick(self, arg1, arg2, checked)
	ClearRaidMarker();
end

function CRFManager_RaidWorldMarkerDropDown_Update()
	local info = UIDropDownMenu_CreateInfo();

	info.isNotRadio = true;

	for i=1, NUM_WORLD_RAID_MARKERS do
		local index = WORLD_RAID_MARKER_ORDER[i];
		info.text = _G["WORLD_MARKER"..index];
		info.func = RaidWorldMarker_OnClick;
		info.checked = IsRaidMarkerActive(index);
		info.arg1 = index;
		UIDropDownMenu_AddButton(info);
	end


	info.notCheckable = 1;
	info.text = REMOVE_WORLD_MARKERS;
	info.func = ClearRaidWorldMarker_OnClick;
	info.arg1 = nil;	--Remove everything
	UIDropDownMenu_AddButton(info);
end

function CompactRaidFrameManager_UpdateDisplayCounts()
	CRF_CountStuff();
	CompactRaidFrameManager_UpdateHeaderInfo();
	CompactRaidFrameManager_UpdateFilterInfo()
end

function CompactRaidFrameManager_UpdateHeaderInfo()
	CompactRaidFrameManager.displayFrame.memberCountLabel:SetFormattedText("%d/%d", RaidInfoCounts.totalAlive, RaidInfoCounts.totalCount);
end

local usedGroups = {};
function CompactRaidFrameManager_UpdateFilterInfo()
	CompactRaidFrameManager_UpdateRoleFilterButton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleTank);
	CompactRaidFrameManager_UpdateRoleFilterButton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleHealer);
	CompactRaidFrameManager_UpdateRoleFilterButton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleDamager);

	RaidUtil_GetUsedGroups(usedGroups);
	for i=1, MAX_RAID_GROUPS do
		CompactRaidFrameManager_UpdateGroupFilterButton(CompactRaidFrameManager.displayFrame.filterOptions["filterGroup"..i], usedGroups);
	end
end

function CompactRaidFrameManager_UpdateRoleFilterButton(button)
	local totalAlive, totalCount = RaidInfoCounts["aliveRole"..button.role], RaidInfoCounts["totalRole"..button.role]
	button:SetFormattedText("%s %d/%d", button.roleTexture, totalAlive, totalCount);
	local showSeparateGroups = EditModeManagerFrame:ShouldRaidFrameShowSeparateGroups();
	if ( totalCount == 0 or showSeparateGroups ) then
		button.selectedHighlight:Hide();
		button:Disable();
		button:SetAlpha(0.5);
	else
		button:Enable();
		button:SetAlpha(1);
		local isFiltered = CRF_GetFilterRole(button.role)
		if ( isFiltered ) then
			button.selectedHighlight:Show();
		else
			button.selectedHighlight:Hide();
		end
	end
end

function CompactRaidFrameManager_ToggleRoleFilter(role)
	CRF_SetFilterRole(role, not CRF_GetFilterRole(role));
	CompactRaidFrameManager_UpdateFilterInfo();
	CompactRaidFrameContainer:TryUpdate();
end

function CompactRaidFrameManager_UpdateGroupFilterButton(button, usedGroups)
	local group = button:GetID();
	if ( usedGroups[group] ) then
		button:Enable();
		button:SetAlpha(1);
		local isFiltered = CRF_GetFilterGroup(group);
		if ( isFiltered ) then
			button.selectedHighlight:Show();
		else
			button.selectedHighlight:Hide();
		end
	else
		button.selectedHighlight:Hide();
		button:Disable();
		button:SetAlpha(0.5);
	end
end

function CompactRaidFrameManager_ToggleGroupFilter(group)
	CRF_SetFilterGroup(group, not CRF_GetFilterGroup(group));
	CompactRaidFrameManager_UpdateFilterInfo();
	CompactRaidFrameContainer:TryUpdate();
end

function CompactRaidFrameManager_UpdateRaidIcons()
	local unit = "target";
	local disableAll = not CanBeRaidTarget(unit);
	for i=1, NUM_RAID_ICONS do
		local button = _G["CompactRaidFrameManagerDisplayFrameRaidMarkersRaidMarker"..i];	--.... /cry
		if ( disableAll or button:GetID() == GetRaidTargetIndex(unit) ) then
			button:GetNormalTexture():SetDesaturated(true);
			button:SetAlpha(0.7);
			button:Disable();
		else
			button:GetNormalTexture():SetDesaturated(false);
			button:SetAlpha(1);
			button:Enable();
		end
	end

	local removeButton = CompactRaidFrameManagerDisplayFrameRaidMarkersRaidMarkerRemove;
	if ( not GetRaidTargetIndex(unit) ) then
		removeButton:GetNormalTexture():SetDesaturated(true);
		removeButton:Disable();
	else
		removeButton:GetNormalTexture():SetDesaturated(false);
		removeButton:Enable();
	end
end


--Settings stuff
local cachedSettings = {};
local isSettingCached = {};
function CompactRaidFrameManager_GetSetting(settingName)
	if ( not isSettingCached[settingName] ) then
		cachedSettings[settingName] = CompactRaidFrameManager_GetSettingBeforeLoad(settingName);
		isSettingCached[settingName] = true;
	end
	return cachedSettings[settingName];
end

function CompactRaidFrameManager_GetSettingBeforeLoad(settingName)
	if ( settingName == "Managed" ) then
		return true;
	elseif ( settingName == "Locked" ) then
		return true;
	elseif ( settingName == "DisplayPets" ) then
		return false;
	elseif ( settingName == "DisplayMainTankAndAssist" ) then
		return true;
	elseif ( settingName == "IsShown" ) then
		return true;
	else
		GMError("Unknown setting "..tostring(settingName));
	end
end

do	--Enclosure to make sure people go through SetSetting
	local function CompactRaidFrameManager_SetManaged(value)
		local container = CompactRaidFrameManager.container;
	end

	local function CompactRaidFrameManager_SetDisplayPets(value)
		local container = CompactRaidFrameManager.container;
		local displayPets;
		if ( value and value ~= "0" ) then
			displayPets = true;
		end

		container:SetDisplayPets(displayPets);
	end

	local function CompactRaidFrameManager_SetDisplayMainTankAndAssist(value)
		local container = CompactRaidFrameManager.container;
		local displayFlaggedMembers;
		if value and value ~= "0" then
			displayFlaggedMembers = true;
		end

		container:SetDisplayMainTankAndAssist(displayFlaggedMembers);
	end

	local function CompactRaidFrameManager_SetIsShown(value)
		if value and value ~= "0" then
			CompactRaidFrameManager.container.enabled = true;
			CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetText(HIDE);
			CompactRaidFrameManagerDisplayFrameHiddenModeToggle.shownMode = false;
		else
			CompactRaidFrameManager.container.enabled = false;
			CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetText(SHOW);
			CompactRaidFrameManagerDisplayFrameHiddenModeToggle.shownMode = true;
		end
		CompactRaidFrameManager_UpdateContainerVisibility();
	end

	function CompactRaidFrameManager_SetSetting(settingName, value)
		cachedSettings[settingName] = value;
		isSettingCached[settingName] = true;

		--Perform the actual functions
		if ( settingName == "Managed" ) then
			CompactRaidFrameManager_SetManaged(value);
		elseif ( settingName == "DisplayPets" ) then
			CompactRaidFrameManager_SetDisplayPets(value);
		elseif ( settingName == "DisplayMainTankAndAssist" ) then
			CompactRaidFrameManager_SetDisplayMainTankAndAssist(value);
		elseif ( settingName == "IsShown" ) then
			CompactRaidFrameManager_SetIsShown(value);
		else
			GMError("Unknown setting "..tostring(settingName));
		end
	end
end

function CompactRaidFrameManager_UpdateContainerVisibility()
	if ShouldShowRaidFrames() and CompactRaidFrameManager.container.enabled then
		CompactRaidFrameManager.container:Show();
	else
		CompactRaidFrameManager.container:Hide();
	end

	CompactPartyFrame_UpdateVisibility();
end

function CompactRaidFrameManager_UpdateContainerBounds()
	CompactRaidFrameManager.container:Layout();
end

-------------Utility functions-------------
--Functions used for sorting and such
function CRFSort_Group(token1, token2)
	if ( IsInRaid() ) then
		local id1 = tonumber(string.sub(token1, 5));
		local id2 = tonumber(string.sub(token2, 5));

		if ( not id1 or not id2 ) then
			return id1;
		end

		local _, _, subgroup1 = GetRaidRosterInfo(id1);
		local _, _, subgroup2 = GetRaidRosterInfo(id2);

		if ( subgroup1 and subgroup2 and subgroup1 ~= subgroup2 ) then
			return subgroup1 < subgroup2;
		end

		--Fallthrough: Sort by order in Raid window.
		return id1 < id2;
	else
		if ( token1 == "player" ) then
			return true;
		elseif ( token2 == "player" ) then
			return false;
		else
			return token1 < token2;	--String compare is OK since we don't go above 1 digit for party.
		end
	end
end

local roleValues = { MAINTANK = 1, MAINASSIST = 2, TANK = 3, HEALER = 4, DAMAGER = 5, NONE = 6 };
function CRFSort_Role(token1, token2)
	local id1, id2 = UnitInRaid(token1), UnitInRaid(token2);
	local role1, role2;
	if ( id1 ) then
		role1 = select(10, GetRaidRosterInfo(id1));
	end
	if ( id2 ) then
		role2 = select(10, GetRaidRosterInfo(id2));
	end

	role1 = role1 or UnitGroupRolesAssigned(token1);
	role2 = role2 or UnitGroupRolesAssigned(token2);

	local value1, value2 = roleValues[role1], roleValues[role2];
	if ( value1 ~= value2 ) then
		return value1 < value2;
	end

	--Fallthrough: Sort alphabetically.
	return CRFSort_Alphabetical(token1, token2);
end

function CRFSort_Alphabetical(token1, token2)
	local name1, name2 = UnitName(token1), UnitName(token2);
	if ( name1 and name2 ) then
		return name1 < name2;
	elseif ( name1 or name2 ) then
		return name1;
	end

	--Fallthrough: Alphabetic order of tokens (just here to make comparisons well-ordered)
	return token1 < token2;
end

--Functions used for filtering
local filterOptions = {
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
	[7] = true,
	[8] = true,
	displayRoleNONE = true;
	displayRoleTANK = true;
	displayRoleHEALER = true;
	displayRoleDAMAGER = true;

}
function CRF_SetFilterRole(role, show)
	filterOptions["displayRole"..role] = show;
end

function CRF_GetFilterRole(role)
	return filterOptions["displayRole"..role];
end

function CRF_SetFilterGroup(group, show)
	assert(type(group) == "number");
	filterOptions[group] = show;
end

function CRF_GetFilterGroup(group)
	assert(type(group) == "number");
	return filterOptions[group];
end

function CRFFlowFilterFunc(token)
	if ( not UnitExists(token) ) then
		return false;
	end

	if ( not IsInRaid() ) then	--We don't filter unless we're in a raid.
		return true;
	end

	local role = UnitGroupRolesAssigned(token);
	if ( not filterOptions["displayRole"..role] ) then
		return false;
	end

	local raidID = UnitInRaid(token);
	if ( raidID ) then
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, raidRole, isML = GetRaidRosterInfo(raidID);
		if ( not filterOptions[subgroup] ) then
			return false;
		end

		local showingMTandMA = CompactRaidFrameManager_GetSetting("DisplayMainTankAndAssist");
		if ( raidRole and (showingMTandMA and showingMTandMA ~= "0") ) then	--If this character is already displayed as a Main Tank/Main Assist, we don't want to show them a second time
			return false;
		end
	end

	return true;
end

function CRFGroupFilterFunc(groupNum)
	return filterOptions[groupNum];
end

--Counting functions
RaidInfoCounts = {
	aliveRoleTANK 			= 0,
	totalRoleTANK			= 0,
	aliveRoleHEALER		= 0,
	totalRoleHEALER		= 0,
	aliveRoleDAMAGER	= 0,
	totalRoleDAMAGER		= 0,
	aliveRoleNONE			= 0,
	totalRoleNONE			= 0,
	totalCount					= 0,
	totalAlive					= 0,
}

local function CRF_ResetCountedStuff()
	for key, val in pairs(RaidInfoCounts) do
		RaidInfoCounts[key] = 0;
	end
end

function CRF_CountStuff()
	CRF_ResetCountedStuff();
	if ( IsInRaid() ) then
		for i=1, GetNumGroupMembers() do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, assignedRole = GetRaidRosterInfo(i);	--Weird that we have 2 role return values, but... oh well
			if ( rank ) then
				CRF_AddToCount(isDead, assignedRole);
			end
		end
	else
		CRF_AddToCount(UnitIsDeadOrGhost("player") , UnitGroupRolesAssigned("player"));
		for i=1, GetNumSubgroupMembers() do
			local unit = "party"..i;
			CRF_AddToCount(UnitIsDeadOrGhost(unit), UnitGroupRolesAssigned(unit));
		end
	end
end

function CRF_AddToCount(isDead, assignedRole)
	RaidInfoCounts.totalCount = RaidInfoCounts.totalCount + 1;
	RaidInfoCounts["totalRole"..assignedRole] = RaidInfoCounts["totalRole"..assignedRole] + 1;
	if ( not isDead ) then
		RaidInfoCounts.totalAlive = RaidInfoCounts.totalAlive + 1;
		RaidInfoCounts["aliveRole"..assignedRole] = RaidInfoCounts["aliveRole"..assignedRole] + 1;
	end
end
