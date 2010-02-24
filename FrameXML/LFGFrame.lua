-----
--A note on nomenclature:
--LFD is used for Dungeon-specific functions and values
--LFR is used for Raid-specific functions and values
--LFG is used for for generic functions/values that may be used for LFD, LFR, and any other LF_ system we may implement in the future.
------

--DEBUG FIXME:
function LFGDebug(text, ...)
	if ( GetCVarBool("lfgDebug") ) then
		ConsolePrint("LFGLua: "..format(text, ...));
	end
end

LFG_RETURN_VALUES = {
	name = 1,
	typeID = 2,
	minLevel = 3,
	maxLevel = 4,
	recLevel = 5,	--Recommended level
	minRecLevel = 6,	--Minimum recommended level
	maxRecLevel = 7,	--Maximum recommended level
	expansionLevel = 8,
	groupID = 9,
	texture = 10,
	difficulty = 11,
	maxPlayers = 12,
}

LFG_INSTANCE_INVALID_CODES = { --Any other codes are unspecified conditions (e.g. attunements)
	"EXPANSION_TOO_LOW",
	"LEVEL_TOO_LOW",
	"LEVEL_TOO_HIGH",
	"GEAR_TOO_LOW",
	"GEAR_TOO_HIGH",
	"RAID_LOCKED",
	[1001] = "LEVEL_TOO_LOW",
	[1002] = "LEVEL_TOO_HIGH",
	[1022] = "QUEST_NOT_COMPLETED",
	[1025] = "MISSING_ITEM",
	
}

local tankIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:%d:64:64:0:19:22:41|t";
local healerIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:%d:64:64:20:39:1:20|t";
local damageIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:%d:64:64:20:39:22:41|t";

--Variables to store dungeon info in Lua
--local LFDDungeonList, LFRRaidList, LFGDungeonInfo, LFGCollapseList, LFGEnabledList, LFDHiddenByCollapseList, LFGLockList;

function LFGEventFrame_OnLoad(self)
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LFG_LOCK_INFO_RECEIVED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	
	self:RegisterEvent("LFG_OFFER_CONTINUE");
	self:RegisterEvent("LFG_ROLE_CHECK_ROLE_CHOSEN");
	
	--These just update states (roles changeable, buttons clickable, etc.)
	self:RegisterEvent("LFG_PROPOSAL_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_SHOW");
	self:RegisterEvent("LFG_ROLE_CHECK_SHOW");
	self:RegisterEvent("LFG_ROLE_CHECK_HIDE");
	self:RegisterEvent("LFG_BOOT_PROPOSAL_UPDATE");
	self:RegisterEvent("LFG_ROLE_UPDATE");
	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO");
	self:RegisterEvent("LFG_PROPOSAL_FAILED");
end

LFGQueuedForList = {};
function LFGEventFrame_OnEvent(self, event, ...)
	if ( event == "LFG_UPDATE" ) then
		LFG_UpdateQueuedList();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		LFG_UpdateQueuedList();
		LFG_UpdateRoleCheckboxes();
	elseif ( event == "LFG_LOCK_INFO_RECEIVED" ) then
		LFGLockList = GetLFDChoiceLockedState();
		LFG_UpdateFramesIfShown();
	elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
		LFG_UpdateQueuedList();
		LFG_UpdateFramesIfShown();
		if ( not CanPartyLFGBackfill() ) then
			StaticPopup_Hide("LFG_OFFER_CONTINUE");
		end
	elseif ( event == "LFG_OFFER_CONTINUE" ) then
		local displayName, lfgID, typeID = ...;
		local dialog = StaticPopup_Show("LFG_OFFER_CONTINUE", NORMAL_FONT_COLOR_CODE..displayName.."|r");
		if ( dialog ) then
			dialog.data = lfgID;
			dialog.data2 = typeID;
		end
	elseif ( event == "LFG_ROLE_CHECK_ROLE_CHOSEN" ) then
		local player, isTank, isHealer, isDamage = ...;

		--Yes, consecutive string concatenation == bad for garbage collection. But the alternative is either extremely unslightly or localization unfriendly. (Also, this happens fairly rarely)
		local roleList;
		
		--Horrible hack to deal with a bug in embedded font strings. FIXME
		--The more icons with absolute sizes in a certain fontstring, the higher up the text goes. This offsets it to make the icons be in line with the text.
		local numRoles = (isTank and 1 or 0) + (isHealer and 1 or 0) + (isDamage and 1 or 0);
		local yOffset = 2*(numRoles-1)-2;	--Formula derived through testing.
		
		local tankIcon = format(tankIcon, yOffset);
		local healerIcon = format(healerIcon, yOffset);
		local damageIcon = format(damageIcon, yOffset);
		
		if ( isTank ) then
			roleList = tankIcon.." "..TANK;
		end
		if ( isHealer ) then
			if ( roleList ) then
				roleList = roleList..PLAYER_LIST_DELIMITER.." "..healerIcon.." "..HEALER;
			else
				roleList = healerIcon.." "..HEALER;
			end
		end
		if ( isDamage ) then
			if ( roleList ) then
				roleList = roleList..PLAYER_LIST_DELIMITER.." "..damageIcon.." "..DAMAGER;
			else
				roleList = damageIcon.." "..DAMAGER;
			end
		end
		assert(roleList);
		ChatFrame_DisplayUsageError(string.format(LFG_ROLE_CHECK_ROLE_CHOSEN, player, roleList));
	end
	
	LFG_UpdateRolesChangeable();
	LFG_UpdateFindGroupButtons();
	LFG_UpdateLockedOutPanels();
	LFDFrame_UpdateBackfill();
end

function LFG_UpdateLockedOutPanels()
	local mode, submode = GetLFGMode();
	
	if ( mode == "listed" ) then
		LFDQueueFrameNoLFDWhileLFR:Show();
	else
		LFDQueueFrameNoLFDWhileLFR:Hide();
	end
	
	if ( mode == "queued" or mode == "proposal" or mode == "rolecheck" ) then
		LFRQueueFrameNoLFRWhileLFD:Show();
	else
		LFRQueueFrameNoLFRWhileLFD:Hide();
	end
end

function LFG_UpdateFindGroupButtons()
	LFDQueueFrameFindGroupButton_Update();
	LFRQueueFrameFindGroupButton_Update();
end

function LFG_UpdateQueuedList()
	GetLFGQueuedList(LFGQueuedForList);
	LFG_UpdateFramesIfShown();
	MiniMapLFG_UpdateIsShown();
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
	
	local canChangeLeader = (GetNumPartyMembers() == 0 or IsPartyLeader()) and (GetNumRaidMembers() == 0 or IsRaidLeader());
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
	local mode, subMode = GetLFGMode();
	if ( mode == "queued" or mode == "listed" or mode == "rolecheck" or mode == "proposal" ) then
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

function LFGSpecificChoiceEnableButton_SetIsRadio(button, isRadio)
	if ( isRadio ) then
		button:SetSize(17, 17)
		button:SetNormalTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetNormalTexture():SetTexCoord(0, 0.25, 0, 1);
		
		button:SetHighlightTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetHighlightTexture():SetTexCoord(0.5, 0.75, 0, 1);
		
		button:SetCheckedTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetCheckedTexture():SetTexCoord(0.25, 0.5, 0, 1);
		
		button:SetPushedTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetPushedTexture():SetTexCoord(0, 0.25, 0, 1);
		
		button:SetDisabledCheckedTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetDisabledCheckedTexture():SetTexCoord(0.75, 1, 0, 1);
	else
		button:SetSize(20, 20);
		button:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up");
		button:GetNormalTexture():SetTexCoord(0, 1, 0, 1);
		
		button:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight");
		button:GetHighlightTexture():SetTexCoord(0, 1, 0, 1);
		
		button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
		button:GetCheckedTexture():SetTexCoord(0, 1, 0, 1);
		
		button:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down");
		button:GetPushedTexture():SetTexCoord(0, 1, 0, 1);
		
		button:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
		button:GetDisabledCheckedTexture():SetTexCoord(0, 1, 0, 1);
	end	
end

--More functions

function GetTexCoordsForRole(role)
	local textureHeight, textureWidth = 256, 256;
	local roleHeight, roleWidth = 67, 67;
	
	if ( role == "GUIDE" ) then
		return GetTexCoordsByGrid(1, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "TANK" ) then
		return GetTexCoordsByGrid(1, 2, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "HEALER" ) then
		return GetTexCoordsByGrid(2, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "DAMAGER" ) then
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
	elseif ( role == "DAMAGER" ) then
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
		LFRQueueFrame_Update();
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

--false = no children so far
--0 = all children unchecked
--1 = some children checked, some unchecked
--2 = all children checked
function LFGListUpdateHeaderEnabledAndLockedStates(dungeonList, enabledList, lockList, hiddenByCollapseList)
	for i=1, #dungeonList do
		local id = dungeonList[i];
		if ( LFGIsIDHeader(id) ) then
			enabledList[id] = false;
			lockList[id] = true;
		elseif ( not lockList[id] ) then
			local groupID = LFGGetDungeonInfoByID(id)[LFG_RETURN_VALUES.groupID];
			lockList[groupID] = false;
			local idState = enabledList[id];
			local groupState = enabledList[groupID];
			if ( idState ) then
				if ( not groupState or groupState == 2 ) then
					enabledList[groupID] = 2;
				elseif ( groupState == 0 or groupState == 1 ) then
					enabledList[groupID] = 1;
				end
			else
				if ( not groupState or groupState == 0 ) then
					enabledList[groupID] = 0;
				elseif ( groupState == 1 or groupState == 2 ) then
					enabledList[groupID]  = 1;
				end
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
			local idState = enabledList[id];
			local groupState = enabledList[groupID];
			if ( idState ) then
				if ( not groupState or groupState == 2 ) then
					enabledList[groupID] = 2;
				elseif ( groupState == 0 or groupState == 1 ) then
					enabledList[groupID] = 1;
				end
			else
				if ( not groupState or groupState == 0 ) then
					enabledList[groupID] = 0;
				elseif ( groupState == 1 or groupState == 2 ) then
					enabledList[groupID]  = 1;
				end
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