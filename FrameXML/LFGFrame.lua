-----
--A note on nomenclature:
--LFD is used for Dungeon-specific functions and values
--LFR is used for Raid-specific functions and values
--LFG is used for for generic functions/values that may be used for LFD, LFR, and any other LF_ system we may implement in the future.
------


LFG_RETURN_VALUES = {
	name = 1,
	typeID = 2,
	minLevel = 3,
	maxLevel = 4,
	minRecLevel = 5,	--Minimum recommended level
	maxRecLevel = 6,	--Maximum recommended level
	expansionLevel = 7,
	groupID = 8,
	texture = 9,
	difficulty = 10,
}

LFG_INSTANCE_INVALID_CODES = { --Any other codes are unspecified conditions (e.g. attunements)
	"EXPANSION_TOO_LOW",
	"LEVEL_TOO_LOW",
	"LEVEL_TOO_HIGH",
	"GEAR_TOO_LOW",
	"GEAR_TOO_HIGH",
	"RAID_LOCKED",
}

--Variables to store dungeon info in Lua
--local LFDDungeonList, LFRRaidList, LFGDungeonInfo, LFGCollapseList, LFGEnabledList, LFDHiddenByCollapseList, LFGLockList;

function LFGEventFrame_OnLoad(self)
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LFG_LOCK_INFO_RECEIVED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
end

function LFGEventFrame_OnEvent(self, event, ...)
	if ( event == "LFG_UPDATE" ) then
		LFGQueuedForList = GetLFGQueuedList();
		LFG_UpdateFramesIfShown();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		LFGQueuedForList = GetLFGQueuedList();
		LFG_UpdateFramesIfShown();
		LFG_UpdateRoleCheckboxes();
	elseif ( event == "LFG_LOCK_INFO_RECEIVED" ) then
		LFGLockList = GetLFDChoiceLockedState();
		LFG_UpdateFramesIfShown();
	elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
		LFG_UpdateFramesIfShown();
	end
end

function LFG_UpdateFramesIfShown()
	if ( LFDParentFrame:IsShown() ) then
		LFDQueueFrame_Update();
	end
	if ( LFRParentFrame:IsShown() ) then
		LFRQueueFrame_Update();
	end
end

function LFG_PermanentlyDisableRoleButton(button)
	button.permDisabled = true;
	button:Disable();
	SetDesaturation(button:GetNormalTexture(), true);
	button.cover:Show();
	button.cover:SetAlpha(0.7);
	button.checkButton:Hide();
	button.checkButton:Disable();
	if ( button.background ) then
		button.background:Hide();
	end
end

function LFG_DisableRoleButton(button)
	button:Disable();
	button.cover:Show();
	if ( not button.permDisabled ) then
		button.cover:SetAlpha(0.5);
	end
	button.checkButton:Disable();
	if ( button.background ) then
		button.background:Hide();
	end
end

function LFG_EnableRoleButton(button)
	button.permDisabled = false;
	button:Enable();
	SetDesaturation(button:GetNormalTexture(), false);
	button.cover:Hide();
	button.checkButton:Show();
	button.checkButton:Enable();
	if ( button.background ) then
		button.background:Show();
	end
end

function LFG_UpdateAvailableRoles()
	local canBeTank, canBeHealer, canBeDPS = GetAvailableRoles();
	
	if ( canBeTank ) then
		LFG_EnableRoleButton(LFDQueueFrameRoleButtonTank);
		LFG_EnableRoleButton(LFRQueueFrameRoleButtonTank);
		LFG_EnableRoleButton(LFDRoleCheckPopupRoleButtonTank);
	else
		LFG_PermanentlyDisableRoleButton(LFDQueueFrameRoleButtonTank);
		LFG_PermanentlyDisableRoleButton(LFRQueueFrameRoleButtonTank);
		LFG_PermanentlyDisableRoleButton(LFDRoleCheckPopupRoleButtonTank);
	end
	
	if ( canBeHealer ) then
		LFG_EnableRoleButton(LFDQueueFrameRoleButtonHealer);
		LFG_EnableRoleButton(LFRQueueFrameRoleButtonHealer);
		LFG_EnableRoleButton(LFDRoleCheckPopupRoleButtonHealer);
	else
		LFG_PermanentlyDisableRoleButton(LFDQueueFrameRoleButtonHealer);
		LFG_PermanentlyDisableRoleButton(LFRQueueFrameRoleButtonHealer);
		LFG_PermanentlyDisableRoleButton(LFDRoleCheckPopupRoleButtonHealer);
	end
	
	if ( canBeDPS ) then
		LFG_EnableRoleButton(LFDQueueFrameRoleButtonDPS);
		LFG_EnableRoleButton(LFRQueueFrameRoleButtonDPS);
		LFG_EnableRoleButton(LFDRoleCheckPopupRoleButtonDPS);
	else
		LFG_PermanentlyDisableRoleButton(LFDQueueFrameRoleButtonDPS);
		LFG_PermanentlyDisableRoleButton(LFRQueueFrameRoleButtonDPS);
		LFG_PermanentlyDisableRoleButton(LFDRoleCheckPopupRoleButtonDPS);
	end
	
	local canChangeLeader = GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0;
	if ( canChangeLeader ) then
		LFG_EnableRoleButton(LFDQueueFrameRoleButtonLeader);
	else
		LFG_PermanentlyDisableRoleButton(LFDQueueFrameRoleButtonLeader);
	end
end

function LFG_UpdateRoleCheckboxes()
	local leader, tank, healer, dps = GetLFGRoles();
	
	LFDQueueFrameRoleButtonLeader.checkButton:SetChecked(leader);
	
	LFDQueueFrameRoleButtonTank.checkButton:SetChecked(tank);
	LFRQueueFrameRoleButtonTank.checkButton:SetChecked(tank);
	LFDRoleCheckPopupRoleButtonTank.checkButton:SetChecked(tank);
	
	LFDQueueFrameRoleButtonHealer.checkButton:SetChecked(healer);
	LFRQueueFrameRoleButtonHealer.checkButton:SetChecked(healer);
	LFDRoleCheckPopupRoleButtonHealer.checkButton:SetChecked(healer);
	
	LFDQueueFrameRoleButtonDPS.checkButton:SetChecked(dps);
	LFRQueueFrameRoleButtonDPS.checkButton:SetChecked(dps);
	LFDRoleCheckPopupRoleButtonDPS.checkButton:SetChecked(dps);
end

function LFG_UpdateRolesChangeable()
	local mode, subMode = GetLFDMode();
	if ( mode == "queued" or mode == "rolecheck" ) then
		LFG_DisableRoleButton(LFDQueueFrameRoleButtonTank, true);
		LFG_DisableRoleButton(LFRQueueFrameRoleButtonTank, true);
		
		LFG_DisableRoleButton(LFDQueueFrameRoleButtonHealer, true);
		LFG_DisableRoleButton(LFRQueueFrameRoleButtonHealer, true);
		
		LFG_DisableRoleButton(LFDQueueFrameRoleButtonDPS, true);
		LFG_DisableRoleButton(LFRQueueFrameRoleButtonDPS, true);
		
		LFG_DisableRoleButton(LFDQueueFrameRoleButtonLeader, true);
	else
		LFG_UpdateAvailableRoles();
	end
end

--More functions

function LFG_IsEmpowered()
	return not ( ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) and
		not (IsPartyLeader() or IsRaidLeader() or IsRaidOfficer()) );
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

function GetBackgroundTexCoordsForRole(role)
	local textureHeight, textureWidth = 128, 256;
	local roleHeight, roleWidth = 75, 75;
	
	if ( role == "TANK" ) then
		return GetTexCoordsByGrid(2, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "HEALER" ) then
		return GetTexCoordsByGrid(1, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "DAMAGE" ) then
		return GetTexCoordsByGrid(3, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	else
		error("Role does not have background: "..tostring(role));
	end
end

-------Utility functions-----------
function LFDGetNumDungeons()
	return #LFDDungeonList;
end

function LFRGetNumDungeons()
	return #LFRRaidList;
end

function LFGGetDungeonInfoByID(id)
	return LFGDungeonInfo[id];
end

function LFGIsIDHeader(id)
	return id < 0;
end

-------List filtering functions-----------
local hasSetUp = false;
function LFGDungeonList_Setup()
	if ( not hasSetUp ) then
		hasSetUp = true;
		LFGDungeonInfo = GetLFDChoiceInfo(LFGDungeonInfo);	--This will never change (without a patch).
		LFGCollapseList = GetLFDChoiceCollapseState(LFGCollapseList);	--We maintain this list in Lua
		LFGEnabledList = GetLFDChoiceEnabledState(LFGEnabledList);	--We maintain this list in Lua
		LFGLockList = GetLFDChoiceLockedState(LFGLockList);
		
		LFDQueueFrame_Update();
		return true;
	end
	return false;
end

function LFGQueueFrame_UpdateLFGDungeonList(dungeonList, hiddenByCollapseList, lockList, dungeonInfo, enableList, collapseList, filter)
	if ( LFGDungeonList_Setup() ) then
		return;
	end
	
	table.wipe(hiddenByCollapseList);
	
	--1. Remove all choices that don't match the filter.
	LFGListFilterChoices(dungeonList, dungeonInfo, filter);
	
	--2. Remove all headers that have no entries below them.
	LFGListRemoveHeadersWithoutChildren(dungeonList);
	
	--3. Update the enabled state of headers.
	LFGListUpdateHeaderEnabledAndLockedStates(dungeonList, enableList, lockList, hiddenByCollapseList);
	
	--4. Move the children of collapsed headers into the hiddenByCollapse list.
	LFGListRemoveCollapsedChildren(dungeonList, collapseList, hiddenByCollapseList);
end

--filterFunc returns true if the object should be shown.
function LFGListFilterChoices(list, infoList, filterFunc)
	local currentPosition = 1;
	while ( currentPosition <= #list ) do
		local id = list[currentPosition];
		local isHeader = LFGIsIDHeader(id);
		if ( isHeader or filterFunc(id) ) then
			currentPosition = currentPosition + 1;
		else
			tremove(list, currentPosition);
		end
	end
end

function LFGListRemoveHeadersWithoutChildren(list)
	--This relies on unparented children coming first.
	local currentPosition = 1;
	--The discrepency between nextObject>IsChild< and >isHeader< is due to the way we want to handle empty values.
	local nextObjectIsChild = not LFGIsIDHeader(list[1] or 0);
	while ( currentPosition <= #list ) do
		local isHeader = not nextObjectIsChild;
		nextObjectIsChild = currentPosition < #list and not LFGIsIDHeader(list[currentPosition+1]);
		if ( isHeader and not nextObjectIsChild ) then
			tremove(list, currentPosition);
		else
			currentPosition = currentPosition + 1;
		end
	end
end

function LFGListUpdateHeaderEnabledAndLockedStates(dungeonList, enabledList, lockList, hiddenByCollapseList)
	for i=1, #dungeonList do
		local id = dungeonList[i];
		if ( LFGIsIDHeader(id) ) then
			enabledList[id] = false;
			lockList[id] = true;
		elseif ( not lockList[id] ) then
			local groupID = LFGGetDungeonInfoByID(id)[LFG_RETURN_VALUES.groupID];
			lockList[groupID] = false;
			if ( enabledList[id] ) then
				enabledList[groupID] = true;
			end
		end
	end
	for i=1, #hiddenByCollapseList do
		local id = hiddenByCollapseList[i];
		if ( LFGIsIDHeader(id) ) then
			enabledList[id] = false;
			lockList[id] = true;
		elseif ( not lockList[id] ) then
			local groupID = LFGGetDungeonInfoByID(id)[LFG_RETURN_VALUES.groupID];
			lockList[groupID] = false;
			if ( enabledList[id] ) then
				enabledList[groupID] = true;
			end
		end
	end
end

function LFGListRemoveCollapsedChildren(list, collapseStateList, hiddenByCollapseList)
	local currentPosition = 1;
	while ( currentPosition <= #list ) do
		local id = list[currentPosition];
		if ( not LFGIsIDHeader(id) and collapseStateList[id] ) then
			tinsert(hiddenByCollapseList, tremove(list, currentPosition));
		else
			currentPosition = currentPosition + 1;
		end
	end
end