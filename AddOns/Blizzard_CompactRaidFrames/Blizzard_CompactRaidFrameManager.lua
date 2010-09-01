NUM_WORLD_RAID_MARKERS = 5;
NUM_RAID_ICONS = 8;

MINIMUM_RAID_CONTAINER_HEIGHT = 80;

function CompactRaidFrameManager_OnLoad(self)
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	self.container = CompactRaidFrameContainer;
	
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterEvent("UNIT_FLAGS");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	
	self.containerResizeFrame:SetMinResize(self.container:GetWidth(), MINIMUM_RAID_CONTAINER_HEIGHT + 2);
	self.dynamicContainerPosition = true;
	
	CompactRaidFrameContainer_SetFlowFilterFunction(self.container, CRFFlowFilterFunc)
	CompactRaidFrameContainer_SetGroupFilterFunction(self.container, CRFGroupFilterFunc)
	CompactRaidFrameManager_UpdateContainerBounds(self);
	
	CompactRaidFrameManager_Collapse(self);
end

local settings = { --[["Managed",]] "Locked", "SortMode", "KeepGroupsTogether", "DisplayPets", "DisplayMainTankAndAssist", "IsShown" };
function CompactRaidFrameManager_OnEvent(self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		for _, setting in pairs(settings) do
			CompactRaidFrameManager_SetSetting(setting, GetCVar("raidOption"..setting));
		end
		CompactRaidFrameManager_ResizeFrame_LoadPosition(self);
	elseif ( event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" ) then
		CompactRaidFrameManager_UpdateContainerBounds(self);
	elseif ( event == "RAID_ROSTER_UPDATE" ) then
		if ( GetNumRaidMembers() > 0 ) then
			self:Show();
		else
			self:Hide();
		end
		CompactRaidFrameManager_UpdateDisplayCounts(self);
	elseif ( event == "UNIT_FLAGS" ) then
		CompactRaidFrameManager_UpdateDisplayCounts(self);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		CompactRaidFrameManager_UpdateDisplayCounts(self);
		CompactRaidFrameManager_UpdateLeaderButtonsShown(self);
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		CompactRaidFrameManager_UpdateLeaderButtonsShown(self);
	end
end

function CompactRaidFrameManager_Toggle(self)
	if ( self.collapsed ) then
		CompactRaidFrameManager_Expand(self);
	else
		CompactRaidFrameManager_Collapse(self);
	end
end

function CompactRaidFrameManager_Expand(self)
	self.collapsed = false;
	self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -7, -140);
	self.displayFrame:Show();
	self.toggleButton:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1);
end

function CompactRaidFrameManager_Collapse(self)
	self.collapsed = true;
	self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -182, -140);
	self.displayFrame:Hide();
	self.toggleButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 1);
end

function CompactRaidFrameManager_UpdateLeaderButtonsShown(self)
	if ( IsPartyLeader() or IsRaidLeader() or IsRaidOfficer() ) then
		if ( not self.hasLeader ) then
			self.hasLeader = true
			self:SetHeight(180);
			self.displayFrame.leaderOptions:Show();
		end
	else
		if ( self.hasLeader ) then
			self.hasLeader = false;
			self:SetHeight(140);
			self.displayFrame.leaderOptions:Hide();
		end
	end
end

local function RaidWorldMarker_OnClick(self, arg1, arg2, checked)
	PlaceRaidMarker(arg1, arg2);
end

local function ClearRaidWorldMarker_OnClick(self, arg1, arg2, checked)
	ClearRaidMarker(arg1);
end

function CRFManager_RaidWorldMarkerDropDown_Update()
	local info = UIDropDownMenu_CreateInfo();
	
	for i=1, NUM_WORLD_RAID_MARKERS do
		info.text = format(WORLD_MARKER, i);
		info.func = RaidWorldMarker_OnClick;
		info.arg1 = i;
		UIDropDownMenu_AddButton(info);
	end

	info.text = REMOVE_WORLD_MARKERS;
	info.func = ClearRaidWorldMarker_OnClick;
	info.arg1 = nil;	--Remove everything
	UIDropDownMenu_AddButton(info);
end

local function RaidTargetIcon_OnClick(self, arg1, arg2, checked)
	SetRaidTarget(arg1, arg2);
end

function CRFManager_RaidIconDropDown_Update()
	local targetUnit = "target";
	local info = UIDropDownMenu_CreateInfo();
	
	info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons";
	for i=1, NUM_RAID_ICONS do
		info.text = _G["RAID_TARGET_"..i];
		info.tCoordLeft = mod((i-1)/4, 1);
		info.tCoordRight = info.tCoordLeft + 0.25;
		info.tCoordTop = floor((i-1)/4) * 0.25;
		info.tCoordBottom = info.tCoordTop + 0.25;
		info.checked = (GetRaidTargetIndex(targetUnit) == i);
		info.func = RaidTargetIcon_OnClick;
		info.arg1 = targetUnit;
		info.arg2 = i;
		UIDropDownMenu_AddButton(info);
	end
		
	local info = UIDropDownMenu_CreateInfo();
	info.text = RAID_TARGET_NONE;
	info.func = RaidTargetIcon_OnClick;
	info.arg1 = targetUnit;
	info.arg2 = 0;
	UIDropDownMenu_AddButton(info);
end

function CompactRaidFrameManager_UpdateDisplayCounts(self)
	CRF_CountStuff();
	CompactRaidFrameManager_UpdateHeaderInfo(self);
	CompactRaidFrameManager_UpdateFilterInfo(self)
end

function CompactRaidFrameManager_UpdateHeaderInfo(self)
	self.displayFrame.memberCountLabel:SetFormattedText("%d/%d", RaidInfoCounts.totalAlive, RaidInfoCounts.totalCount);
end

local usedGroups = {};
function CompactRaidFrameManager_UpdateFilterInfo(self)
	CompactRaidFrameManager_UpdateRoleFilterButton(self.displayFrame.filterRoleTank);
	CompactRaidFrameManager_UpdateRoleFilterButton(self.displayFrame.filterRoleHealer);
	CompactRaidFrameManager_UpdateRoleFilterButton(self.displayFrame.filterRoleDamager);
	
	RaidUtil_GetUsedGroups(usedGroups);
	for i=1, MAX_RAID_GROUPS do
		CompactRaidFrameManager_UpdateGroupFilterButton(self.displayFrame["filterGroup"..i], usedGroups);
	end
end

function CompactRaidFrameManager_UpdateRoleFilterButton(button)
	local totalAlive, totalCount = RaidInfoCounts["aliveRole"..button.role], RaidInfoCounts["totalRole"..button.role]
	button:SetFormattedText("%s%d/%d", button.roleTexture, totalAlive, totalCount);
	local keepGroupsTogether = CompactRaidFrameManager_GetSetting("KeepGroupsTogether");
	keepGroupsTogether = keepGroupsTogether and keepGroupsTogether ~= "0";
	if ( totalCount == 0 or keepGroupsTogether ) then
		button:UnlockHighlight();
		button:Disable();
	else
		button:Enable();
		local isFiltered = CRF_GetFilterRole(button.role)
		if ( isFiltered ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
	end
end

function CompactRaidFrameManager_ToggleRoleFilter(role)
	CRF_SetFilterRole(role, not CRF_GetFilterRole(role));
	CompactRaidFrameManager_UpdateFilterInfo(CompactRaidFrameManager);
	CompactRaidFrameContainer_TryUpdate(CompactRaidFrameContainer);
end

function CompactRaidFrameManager_UpdateGroupFilterButton(button, usedGroups)
	local group = button:GetID();
	if ( usedGroups[group] ) then
		button:Enable();
		local isFiltered = CRF_GetFilterGroup(group);
		if ( isFiltered ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
	else
		button:UnlockHighlight();
		button:Disable();
	end
end

function CompactRaidFrameManager_ToggleGroupFilter(group)
	CRF_SetFilterGroup(group, not CRF_GetFilterGroup(group));
	CompactRaidFrameManager_UpdateFilterInfo(CompactRaidFrameManager);
	CompactRaidFrameContainer_TryUpdate(CompactRaidFrameContainer);
end

--Settings stuff
local cachedSettings = {};
local isSettingCached = {};
function CompactRaidFrameManager_GetSetting(settingName)
	if ( not isSettingCached[settingName] ) then
		cachedSettings[settingName] = GetCVar("raidOption"..settingName);
		isSettingCached[settingName] = true;
	end
	return cachedSettings[settingName];
end

function CompactRaidFrameManager_GetSettingDefault(settingName)
	return GetCVarDefault("raidOption"..settingName);
end

do	--Enclosure to make sure people go through SetSetting
	local function CompactRaidFrameManager_SetManaged(value)
		local container = CompactRaidFrameManager.container;
	end

	local function CompactRaidFrameManager_SetLocked(value)
		local manager = CompactRaidFrameManager;
		if ( value == "lock" ) then
			CompactRaidFrameManager_LockContainer(manager);
			CompactRaidFrameManagerDisplayFrameLockedModeToggle:SetText(UNLOCK);
			CompactRaidFrameManagerDisplayFrameLockedModeToggle.lockMode = "unlock";
		elseif ( value == "unlock" ) then
			CompactRaidFrameManager_UnlockContainer(manager);
			CompactRaidFrameManagerDisplayFrameLockedModeToggle:SetText(LOCK);
			CompactRaidFrameManagerDisplayFrameLockedModeToggle.lockMode = "lock";
		else
			CompactRaidFrameManager_SetSetting("Locked", CompactRaidFrameManager_GetSettingDefault("Locked"));
			GMError("Unknown lock value: "..tostring(value));
		end
	end

	local function CompactRaidFrameManager_SetSortMode(value)
		local manager = CompactRaidFrameManager;
		if ( value == "group" ) then
			CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_Group);
		elseif ( value == "role" ) then
			CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_Role);
		elseif ( value == "alphabetical" ) then
			CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_Alphabetical);
		else
			CompactRaidFrameManager_SetSetting("SortMode", CompactRaidFrameManager_GetSettingDefault("SortMode"));
			GMError("Unknown sort mode: "..tostring(value));
		end
	end

	local function CompactRaidFrameManager_SetKeepGroupsTogether(value)
		local manager = CompactRaidFrameManager;
		local groupMode;
		if ( not value or value == "0" ) then
			groupMode = "flush";
		else
			groupMode = "discrete";
		end
		
		CompactRaidFrameContainer_SetGroupMode(manager.container, groupMode);
		if ( groupMode == "discrete" ) then		
			InterfaceOptionsRaidFramePanelSortBy:Hide();
		elseif ( groupMode == "flush" ) then
			InterfaceOptionsRaidFramePanelSortBy:Show();
		end
		CompactRaidFrameManager_UpdateFilterInfo(manager);
	end

	local function CompactRaidFrameManager_SetDisplayPets(value)
		local container = CompactRaidFrameManager.container;
		local displayPets;
		if ( value and value ~= "0" ) then
			displayPets = true;
		end
		
		CompactRaidFrameContainer_SetDisplayPets(container, displayPets);
	end

	local function CompactRaidFrameManager_SetDisplayMainTankAndAssist(value)
		local container = CompactRaidFrameManager.container;
		local displayFlaggedMembers;
		if ( value and value ~= "0" ) then
			displayFlaggedMembers = true;
		end
		
		CompactRaidFrameContainer_SetDisplayMainTankAndAssist(container, displayFlaggedMembers);
	end

	local function CompactRaidFrameManager_SetIsShown(value)
		local manager = CompactRaidFrameManager;
		if ( value and value ~= "0" ) then
			manager.container:Show();
			CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetText(HIDE);
			CompactRaidFrameManagerDisplayFrameHiddenModeToggle.shownMode = "0";
		else
			manager.container:Hide();
			CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetText(SHOW);
			CompactRaidFrameManagerDisplayFrameHiddenModeToggle.shownMode = "1";
		end
	end
	
	function CompactRaidFrameManager_SetSetting(settingName, value)
		SetCVar("raidOption"..settingName, value);
		cachedSettings[settingName] = value;
		isSettingCached[settingName] = true;
		
		--Perform the actual functions
		if ( settingName == "Managed" ) then
			CompactRaidFrameManager_SetManaged(value);
		elseif ( settingName == "Locked" ) then
			CompactRaidFrameManager_SetLocked(value);
		elseif ( settingName == "SortMode" ) then
			CompactRaidFrameManager_SetSortMode(value);
		elseif ( settingName == "KeepGroupsTogether" ) then
			CompactRaidFrameManager_SetKeepGroupsTogether(value);
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

function CompactRaidFrameManager_ResetContainerPosition()
	local manager = CompactRaidFrameManager;
	manager.dynamicContainerPosition = true;
	CompactRaidFrameManager_UpdateContainerBounds(manager);
	CompactRaidFrameManager_ResizeFrame_SavePosition(manager);
end

function CompactRaidFrameManager_UpdateContainerBounds(self) --Hah, "Bounds" instead of "SizeAndPosition". WHO NEEDS A THESAURUS NOW?!
	if ( self.dynamicContainerPosition ) then
		--Should be below the TargetFrameSpellBar at its lowest height..
		local top = GetScreenHeight() - 135;
		--Should be just above the FriendsFrameMicroButton.
		local bottom = 330;
		
		local managerTop = self:GetTop();
		
		self.container:ClearAllPoints();
		self.container:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, top - managerTop);
		self.container:SetHeight(top - bottom);
	end
end

function CompactRaidFrameManager_LockContainer(self)
	self.containerResizeFrame:Hide();
end

function CompactRaidFrameManager_UnlockContainer(self)
	--Anchor the resizer to the current position.
	CompactRaidFrameManager_ResizeFrame_Reanchor(self);
	
	self.containerResizeFrame:Show();
end

--ResizeFrame related functions
local RESIZE_OUTSETS = 5;
function CompactRaidFrameManager_ResizeFrame_Reanchor(manager)
	manager.containerResizeFrame:ClearAllPoints();
	manager.containerResizeFrame:SetPoint("TOPLEFT", manager.container, "TOPLEFT", -RESIZE_OUTSETS, RESIZE_OUTSETS);
	manager.containerResizeFrame:SetPoint("BOTTOMLEFT", manager.container, "BOTTOMLEFT", -RESIZE_OUTSETS, -RESIZE_OUTSETS);
end

function CompactRaidFrameManager_ResizeFrame_OnDragStart(manager)
	manager.dynamicContainerPosition = false;
	
	manager.container:StartMoving();
end

function CompactRaidFrameManager_ResizeFrame_OnDragStop(manager)
	manager.container:StopMovingOrSizing();
	CompactRaidFrameManager_ResizeFrame_CheckMagnetism(manager);
	CompactRaidFrameManager_ResizeFrame_SavePosition(manager);
end

function CompactRaidFrameManager_ResizeFrame_OnResizeStart(manager)
	manager.dynamicContainerPosition = false;
	
	manager.containerResizeFrame:StartSizing("BOTTOM")
	manager.containerResizeFrame:SetScript("OnUpdate", CompactRaidFrameManager_ResizeFrame_OnUpdate);
end

function CompactRaidFrameManager_ResizeFrame_OnResizeStop(manager)
	manager.containerResizeFrame:StopMovingOrSizing();
	manager.containerResizeFrame:SetScript("OnUpdate", nil);
	CompactRaidFrameManager_ResizeFrame_UpdateContainerSize(manager);
end

local RESIZE_UPDATE_INTERVAL = 0.5;
function CompactRaidFrameManager_ResizeFrame_OnUpdate(self, elapsed)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed;
	if ( self.timeSinceUpdate >= RESIZE_UPDATE_INTERVAL ) then
		CompactRaidFrameManager_ResizeFrame_UpdateContainerSize(self:GetParent());
	end
end

function CompactRaidFrameManager_ResizeFrame_UpdateContainerSize(manager)
	--Re-anchor the frame by the topleft
	local top, left = manager.container:GetTop(), manager.container:GetLeft();
	manager.container:ClearAllPoints();
	manager.container:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top);
	
	manager.container:SetHeight(manager.containerResizeFrame:GetHeight() - RESIZE_OUTSETS * 2);
	CompactRaidFrameManager_ResizeFrame_Reanchor(manager);
	CompactRaidFrameManager_ResizeFrame_CheckMagnetism(manager);
	CompactRaidFrameManager_ResizeFrame_SavePosition(manager);
end

local MAGNETIC_FIELD_RANGE = 10;
function CompactRaidFrameManager_ResizeFrame_CheckMagnetism(manager)
	if ( abs(manager.container:GetLeft() - manager:GetRight()) < MAGNETIC_FIELD_RANGE and
		manager.container:GetTop() > manager:GetBottom() and manager.container:GetBottom() < manager:GetTop() ) then
		manager.container:ClearAllPoints();
		manager.container:SetPoint("TOPLEFT", manager, "TOPRIGHT", 0, manager.container:GetTop() - manager:GetTop());
	end
end

local POSITION_CVAR_VERSION = 1;	--In case we ever change the format of this save.
function CompactRaidFrameManager_ResizeFrame_SavePosition(manager)
	local cvar = "raidFramesPosition";
	if ( manager.dynamicContainerPosition ) then
		SetCVar(cvar, "");
		return;
	end
	
	--The stuff we're actually saving
	local topPoint, topOffset;
	local bottomPoint, bottomOffset;
	local leftPoint, leftOffset;
	
	local screenHeight = GetScreenHeight();
	local top = manager.container:GetTop();
	if ( top > screenHeight / 2 ) then
		topPoint = "TOP";
		topOffset = screenHeight - top;
	else
		topPoint = "BOTTOM";
		topOffset = top;
	end
	
	local bottom = manager.container:GetBottom();
	if ( bottom > screenHeight / 2 ) then
		bottomPoint = "TOP";
		bottomOffset = screenHeight - bottom;
	else
		bottomPoint = "BOTTOM";
		bottomOffset = bottom;
	end
	
	local isAttached = select(2, manager.container:GetPoint(1)) == manager;
	if ( isAttached ) then
		leftPoint = "ATTACHED";
		leftOffset = 0;
	else
		local screenWidth = GetScreenWidth();
		local left = manager.container:GetLeft();
		if ( left > screenWidth / 2 ) then
			leftPoint = "RIGHT";
			leftOffset = screenWidth - left;
		else
			leftPoint = "LEFT";
			leftOffset = left;
		end
	end
	
	SetCVar(cvar, strjoin(",", POSITION_CVAR_VERSION, topPoint, topOffset, bottomPoint, bottomOffset, leftPoint, leftOffset));
end

function CompactRaidFrameManager_ResizeFrame_LoadPosition(manager)
	local cvar = "raidFramesPosition";
	
	local version, topPoint, topOffset, bottomPoint, bottomOffset, leftPoint, leftOffset = strsplit(",", GetCVar(cvar));
	
	if ( version == "" ) then	--We are automatically placed.
		manager.dynamicContainerPosition = true;
		CompactRaidFrameManager_UpdateContainerBounds(manager);
		return;
	else
		manager.dynamicContainerPosition = false;
	end
	
	--First, let's clear the container's current anchors.
	manager.container:ClearAllPoints();
	
	local top;
	if ( topPoint == "TOP" ) then
		top = GetScreenHeight() - topOffset;
	else
		top = topOffset;
	end
	
	local bottom;
	if ( bottomPoint == "TOP" ) then
		bottom = GetScreenHeight() - bottomOffset;
	else
		bottom = bottomOffset
	end
	
	local height = top - bottom;
	height = max(height, MINIMUM_RAID_CONTAINER_HEIGHT);
	top = max(top, height);
	
	manager.container:SetHeight(height);
	
	if ( leftPoint == "ATTACHED" ) then
		manager.container:SetPoint("TOPLEFT", manager, "TOPRIGHT", 0, top - manager:GetTop());
	else
		local left;
		if ( leftPoint == "RIGHT" ) then
			left = GetScreenWidth() - leftOffset;
		else
			left = leftOffset;
		end
		
		manager.container:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", left, top);
	end
end

-------------Utility functions-------------
--Functions used for sorting and such
function CRFSort_Group(token1, token2)
	local id1 = tonumber(string.sub(token1, 5));
	local id2 = tonumber(string.sub(token2, 5));
	
	local _, _, subgroup1 = GetRaidRosterInfo(id1);
	local _, _, subgroup2 = GetRaidRosterInfo(id2);
	
	if ( subgroup1 and subgroup2 and subgroup1 ~= subgroup2 ) then
		return subgroup1 < subgroup2;
	end
	
	--Fallthrough: Sort by order in Raid window.
	return id1 < id2;
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
	for i=1, GetNumRaidMembers() do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, assignedRole = GetRaidRosterInfo(i);	--Weird that we have 2 role return values, but... oh well
		if ( name ) then
			RaidInfoCounts.totalCount = RaidInfoCounts.totalCount + 1;
			if ( not isDead ) then
				RaidInfoCounts.totalAlive = RaidInfoCounts.totalAlive + 1;
			end
			
			RaidInfoCounts["totalRole"..assignedRole] = RaidInfoCounts["totalRole"..assignedRole] + 1;
			if ( not isDead ) then
				RaidInfoCounts["aliveRole"..assignedRole] = RaidInfoCounts["aliveRole"..assignedRole] + 1;
			end
		end
	end
end