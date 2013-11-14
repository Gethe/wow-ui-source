
----------------------------------------------
---------QueueStatusMinimapButton-------------
----------------------------------------------

function QueueStatusMinimapButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:SetFrameLevel(self:GetFrameLevel() + 1);
end

function QueueStatusMinimapButton_OnEnter(self)
	QueueStatusFrame:Show();
end

function QueueStatusMinimapButton_OnLeave(self)
	QueueStatusFrame:Hide();
end

function QueueStatusMinimapButton_OnClick(self, button)
	if ( button == "RightButton" ) then
		QueueStatusDropDown_Show(self.DropDown, self:GetName());
	else
		local inBattlefield, showScoreboard = QueueStatus_InActiveBattlefield();
		if ( inBattlefield ) then
			if ( showScoreboard ) then
				ToggleWorldStateScoreFrame();
			end
		else
			QueueStatusDropDown_Show(self.DropDown, self:GetName());
		end
	end
end

function QueueStatusMinimapButton_OnShow(self)
	self.Eye:SetFrameLevel(self:GetFrameLevel() - 1);
end

----------------------------------------------
------------QueueStatusFrame------------------
----------------------------------------------
function QueueStatusFrame_OnLoad(self)
	--For everything
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");

	--For LFG
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("LFG_ROLE_CHECK_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_FAILED");
	self:RegisterEvent("LFG_PROPOSAL_SUCCEEDED");
	self:RegisterEvent("LFG_PROPOSAL_SHOW");
	self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE");

	--For PvP Role Checks
	self:RegisterEvent("PVP_ROLE_CHECK_UPDATED");

	--For PvP
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");

	--For World PvP stuff
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_REQUEST_RESPONSE");
	self:RegisterEvent("BATTLEFIELD_MGR_EJECT_PENDING");
	self:RegisterEvent("BATTLEFIELD_MGR_EJECTED");
	self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_INVITE");
	self:RegisterEvent("BATTLEFIELD_MGR_ENTRY_INVITE");
	self:RegisterEvent("BATTLEFIELD_MGR_ENTERED");

	--For Pet Battles
	self:RegisterEvent("PET_BATTLE_QUEUE_STATUS");

	self.StatusEntries = {};
end

function QueueStatusFrame_OnEvent(self)
	QueueStatusFrame_Update(self);
end

function QueueStatusFrame_GetEntry(self, entryIndex)
	local entry = self.StatusEntries[entryIndex];
	if ( not entry ) then
		self.StatusEntries[entryIndex] = CreateFrame("FRAME", nil, self, "QueueStatusEntryTemplate");
		entry = self.StatusEntries[entryIndex];
		if ( entryIndex == 1 ) then
			entry:SetPoint("TOP", self, "TOP", 0, 0);
			entry.EntrySeparator:Hide();
		else
			entry:SetPoint("TOP", self.StatusEntries[entryIndex - 1], "BOTTOM", 0, 0);
		end
	end
	return entry;
end

function QueueStatusFrame_Update(self)
	local showMinimapButton, animateEye;

	local nextEntry = 1;

	local totalHeight = 4; --Add some buffer height

	--Try each LFG type
	for i=1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(i);
		if ( mode ) then
			local entry = QueueStatusFrame_GetEntry(self, nextEntry);
			QueueStatusEntry_SetUpLFG(entry, i);
			entry:Show();
			totalHeight = totalHeight + entry:GetHeight();
			nextEntry = nextEntry + 1;

			showMinimapButton = true;
			if ( mode == "queued" ) then
				animateEye = true;
			end
		end
	end

	local inProgress, _, _, _, _, isBattleground = GetLFGRoleUpdate();
	--Try PvP Role Check
	if ( inProgress and isBattleground ) then
		local entry = QueueStatusFrame_GetEntry(self, nextEntry);
		QueueStatusEntry_SetUpPVPRoleCheck(entry);
		entry:Show();
		totalHeight = totalHeight + entry:GetHeight();
		nextEntry = nextEntry + 1;
		showMinimapButton = true;
	end

	--Try all PvP queues
	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch, suspend = GetBattlefieldStatus(i);
		if ( status and status ~= "none" ) then
			local entry = QueueStatusFrame_GetEntry(self, nextEntry);
			QueueStatusEntry_SetUpBattlefield(entry, i);
			entry:Show();
			totalHeight = totalHeight + entry:GetHeight();
			nextEntry = nextEntry + 1;

			showMinimapButton = true;
			if ( status == "queued" and not suspend ) then
				animateEye = true;
			end
		end
	end

	--Try all World PvP queues
	for i=1, MAX_WORLD_PVP_QUEUES do
		local status, mapName, queueID = GetWorldPVPQueueStatus(i);
		if ( status and status ~= "none" ) then
			local entry = QueueStatusFrame_GetEntry(self, nextEntry);
			QueueStatusEntry_SetUpWorldPvP(entry, i);
			entry:Show();
			totalHeight = totalHeight + entry:GetHeight();
			nextEntry = nextEntry + 1;

			showMinimapButton = true;
			if ( status == "queued" ) then
				animateEye = true;
			end
		end
	end

	--World PvP areas we're currently in
	if ( CanHearthAndResurrectFromArea() ) then
		local entry = QueueStatusFrame_GetEntry(self, nextEntry);
		QueueStatusEntry_SetUpActiveWorldPVP(entry);
		entry:Show();
		totalHeight = totalHeight + entry:GetHeight();
		nextEntry = nextEntry + 1;

		showMinimapButton = true;
	end

	--Pet Battle PvP Queue
	local pbStatus = C_PetBattles.GetPVPMatchmakingInfo();
	if ( pbStatus ) then
		local entry = QueueStatusFrame_GetEntry(self, nextEntry);
		QueueStatusEntry_SetUpPetBattlePvP(entry);
		entry:Show();
		totalHeight = totalHeight + entry:GetHeight();
		nextEntry = nextEntry + 1;

		showMinimapButton = true;
		if ( pbStatus == "queued" ) then
			animateEye = true;
		end
	end

	--Hide all remaining entries.
	for i=nextEntry, #self.StatusEntries do
		self.StatusEntries[i]:Hide();
	end

	--Update the size of this frame to fit everything
	self:SetHeight(totalHeight);

	--Update the minimap icon
	if ( showMinimapButton ) then
		QueueStatusMinimapButton:Show();
	else
		QueueStatusMinimapButton:Hide();
	end
	if ( animateEye ) then
		EyeTemplate_StartAnimating(QueueStatusMinimapButton.Eye);
	else
		EyeTemplate_StopAnimating(QueueStatusMinimapButton.Eye);
	end
end

----------------------------------------------
------------QueueStatusEntry------------------
----------------------------------------------
local queuedList = {};
local function QueueStatus_GetAllRelevantLFG(category, queuedList)
	--Get the list of everything we're queued for
	queuedList = GetLFGQueuedList(category, queuedList);

	--Add queues currently in the proposal stage to the list
	local proposalExists, id, typeID, subtypeID, name, texture, role, hasResponded, totalEncounters, completedEncounters, numMembers, isLeader, isHoliday, proposalCategory = GetLFGProposal();
	if ( proposalCategory == category ) then
		queuedList[id] = true;
	end

	--Add queues currently in the role update stage to the list
	local roleCheckInProgress, slots, members, roleUpdateCategory, roleUpdateID = GetLFGRoleUpdate();
	if ( roleUpdateCategory == category ) then
		queuedList[roleUpdateID] = true;
	end

	--Add instances you are currently in a party for
	local partySlot = GetPartyLFGID();
	if ( partySlot and GetLFGCategoryForID(partySlot) == category ) then
		queuedList[partySlot] = true;
	end

	return queuedList;
end

function QueueStatusEntry_SetUpLFG(entry, category)
	--Figure out which one we're going to have as primary
	local activeIndex = nil;
	local allNames = {};

	QueueStatus_GetAllRelevantLFG(category, queuedList);

	
	local activeID = select(18, GetLFGQueueStats(category));
	for queueID in pairs(queuedList) do
		local mode, submode = GetLFGMode(category, queueID);
		if ( mode ) then
			--Save off the name (we'll remove the active one later)
			allNames[#allNames + 1] = select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(queueID));
			if ( mode ~= "queued" and mode ~= "listed" and mode ~= "suspended" ) then
				activeID = queueID;
				activeIndex = #allNames;
			elseif ( not activeID ) then
				activeID = queueID;
				activeIndex = #allNames;
			end
			
		end
	end

	if ( not activeID ) then
		GMError(format("Thought we had an active queue, but we don't.: activeIdx - %d", activeID));
	end
	
	local mode, submode = GetLFGMode(category, activeID);

	local subTitle;
	local extraText;

	if ( category == LE_LFG_CATEGORY_RF and #allNames > 1 ) then --HACK - For now, RF works differently.
		--We're queued for more than one thing
		subTitle = table.remove(allNames, activeIndex);
		extraText = string.format(ALSO_QUEUED_FOR, table.concat(allNames, PLAYER_LIST_DELIMITER));
	elseif ( mode == "suspended" ) then 
		local suspendedPlayers = GetLFGSuspendedPlayers(category);
		if ( #suspendedPlayers > 0 ) then
			extraText = "";
			for i = 1, 3 do
				if (suspendedPlayers[i]) then
					if ( i > 1 ) then
						extraText = extraText .. "\n";
					end
					extraText = extraText .. string.format(RAID_MEMBER_NOT_READY, suspendedPlayers[i]);
				end
			end
		end
	end

	--Set up the actual display
	if ( mode == "queued" ) then
		local inParty, joined, queued, noPartialClear, achievements, lfgComment, slotCount, _, leader, tank, healer, dps = GetLFGInfoServer(category, activeID);
		local hasData,  leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(category, activeID);
		if ( category == LE_LFG_CATEGORY_SCENARIO ) then --Hide roles for scenarios
			tank, healer, dps = nil, nil, nil;
			totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds = nil, nil, nil, nil, nil, nil;
		end
		QueueStatusEntry_SetFullDisplay(entry, LFG_CATEGORY_NAMES[category], queuedTime, myWait, tank, healer, dps, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText);
	elseif ( mode == "proposal" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, LFG_CATEGORY_NAMES[category], QUEUED_STATUS_PROPOSAL, subTitle, extraText);
	elseif ( mode == "listed" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, LFG_CATEGORY_NAMES[category], QUEUED_STATUS_LISTED, subTitle, extraText);
	elseif ( mode == "suspended" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, LFG_CATEGORY_NAMES[category], QUEUED_STATUS_SUSPENDED, subTitle, extraText);
	elseif ( mode == "rolecheck" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, LFG_CATEGORY_NAMES[category], QUEUED_STATUS_ROLE_CHECK_IN_PROGRESS, subTitle, extraText);
	elseif ( mode == "lfgparty" or mode == "abandonedInDungeon" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, LFG_CATEGORY_NAMES[category], QUEUED_STATUS_IN_PROGRESS, subTitle, extraText);
	else
		QueueStatusEntry_SetMinimalDisplay(entry, LFG_CATEGORY_NAMES[category], QUEUED_STATUS_UNKNOWN, subTitle, extraText);
	end
end

function QueueStatusEntry_SetUpBattlefield(entry, idx)
	local status, mapName, teamSize, registeredMatch, suspend = GetBattlefieldStatus(idx);
	if ( status == "queued" ) then
		if ( suspend ) then
			QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_SUSPENDED);
		else
			local queuedTime = GetTime() - GetBattlefieldTimeWaited(idx) / 1000;
			local estimatedTime = GetBattlefieldEstimatedWaitTime(idx) / 1000;
			QueueStatusEntry_SetFullDisplay(entry, mapName, queuedTime, estimatedTime);
		end
	elseif ( status == "confirm" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_PROPOSAL);
	elseif ( status == "active" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_IN_PROGRESS);
	elseif ( status == "locked" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_LOCKED, QUEUED_STATUS_LOCKED_EXPLANATION);
	else
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_UNKNOWN);
	end
end

function QueueStatusEntry_SetUpPVPRoleCheck(entry)
	local queueName = GetLFGRoleUpdateBattlegroundInfo();
	QueueStatusEntry_SetMinimalDisplay(entry, queueName, QUEUED_STATUS_ROLE_CHECK_IN_PROGRESS);
end

function QueueStatusEntry_SetUpWorldPvP(entry, idx)
	local status, mapName, queueID = GetWorldPVPQueueStatus(idx);
	if ( status == "queued" ) then
		--We have no wait time (or any related information) for world PvP queues
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_QUEUED);
	elseif ( status == "confirm" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_PROPOSAL);
	elseif ( status == "active" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_IN_PROGRESS);
	else
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_UNKNOWN);
	end
end

function QueueStatusEntry_SetUpActiveWorldPVP(entry)
	QueueStatusEntry_SetMinimalDisplay(entry, GetRealZoneText(), QUEUED_STATUS_IN_PROGRESS);
end

function QueueStatusEntry_SetUpPetBattlePvP(entry)
	local status, estimatedTime, queuedTime = C_PetBattles.GetPVPMatchmakingInfo();
	if ( status == "queued" ) then
		QueueStatusEntry_SetFullDisplay(entry, PET_BATTLE_PVP_QUEUE, queuedTime, estimatedTime);
	elseif ( status == "proposal" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, PET_BATTLE_PVP_QUEUE, QUEUED_STATUS_PROPOSAL);
	elseif ( status == "suspended" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, PET_BATTLE_PVP_QUEUE, QUEUED_STATUS_SUSPENDED);
	elseif ( status == "entry" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, PET_BATTLE_PVP_QUEUE, QUEUED_STATUS_WAITING);
	else
		QueueStatusEntry_SetMinimalDisplay(entry, PET_BATTLE_PVP_QUEUE, QUEUED_STATUS_UNKNOWN);
	end
end

function QueueStatusEntry_SetMinimalDisplay(entry, title, description, subTitle, extraText)
	local height = 10;

	entry.Title:SetWidth(168);
	entry.Title:SetText(title);
	height = height + entry.Title:GetHeight();

	entry.Status:SetText(description);
	entry.Status:Show();

	if ( subTitle ) then
		entry.SubTitle:SetText(subTitle);
		entry.SubTitle:Show();
		height = height + entry.SubTitle:GetHeight() + 5;
	else
		entry.SubTitle:Hide();
	end

	if ( extraText ) then
		entry.ExtraText:SetText(extraText);
		entry.ExtraText:Show();
		entry.ExtraText:SetPoint("TOPLEFT", entry, "TOPLEFT", 10, -(height + 5));
		height = height + entry.ExtraText:GetHeight() + 5;
	else
		entry.ExtraText:Hide();
	end

	entry.TimeInQueue:Hide();
	entry.AverageWait:Hide();

	for i=1, LFD_NUM_ROLES do
		entry["RoleIcon"..i]:Hide();
	end

	entry.TanksFound:Hide();
	entry.HealersFound:Hide();
	entry.DamagersFound:Hide();

	entry:SetScript("OnUpdate", nil);

	entry:SetHeight(height + 6);
end

function QueueStatusEntry_SetFullDisplay(entry, title, queuedTime, myWait, isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText)
	local height = 14;
	
	entry.Title:SetWidth(0);
	entry.Title:SetText(title);
	height = height + entry.Title:GetHeight();

	entry.Status:Hide();

	if ( subTitle ) then
		entry.SubTitle:SetText(subTitle);
		entry.SubTitle:Show();
		height = height + entry.SubTitle:GetHeight() + 5;
	else
		entry.SubTitle:Hide();
	end

	--Update your role icons
	local nextRoleIcon = 1;
	if ( isDPS ) then
		local icon = entry["RoleIcon"..nextRoleIcon];
		icon:SetTexCoord(GetTexCoordsForRole("DAMAGER"));
		icon:Show();
		nextRoleIcon = nextRoleIcon + 1;
	end
	if ( isHealer ) then
		local icon = entry["RoleIcon"..nextRoleIcon];
		icon:SetTexCoord(GetTexCoordsForRole("HEALER"));
		icon:Show();
		nextRoleIcon = nextRoleIcon + 1;
	end
	if ( isTank ) then
		local icon = entry["RoleIcon"..nextRoleIcon];
		icon:SetTexCoord(GetTexCoordsForRole("TANK"));
		icon:Show();
		nextRoleIcon = nextRoleIcon + 1;
	end

	for i=nextRoleIcon, LFD_NUM_ROLES do
		entry["RoleIcon"..i]:Hide();
	end

	--Update the role needs
	if ( totalTanks and totalHealers and totalDPS ) then
		entry.HealersFound:SetPoint("TOP", entry, "TOP", 0, -(height + 5));
		entry.TanksFound.Count:SetFormattedText(PLAYERS_FOUND_OUT_OF_MAX, totalTanks - tankNeeds, totalTanks);
		entry.HealersFound.Count:SetFormattedText(PLAYERS_FOUND_OUT_OF_MAX, totalHealers - healerNeeds, totalHealers);
		entry.DamagersFound.Count:SetFormattedText(PLAYERS_FOUND_OUT_OF_MAX, totalDPS - dpsNeeds, totalDPS);

		entry.TanksFound.Texture:SetDesaturated(tankNeeds ~= 0);
		entry.TanksFound.Cover:SetShown(tankNeeds ~= 0);
		entry.HealersFound.Texture:SetDesaturated(healerNeeds ~= 0);
		entry.HealersFound.Cover:SetShown(healerNeeds ~= 0);
		entry.DamagersFound.Texture:SetDesaturated(dpsNeeds ~= 0);
		entry.DamagersFound.Cover:SetShown(dpsNeeds ~= 0);

		entry.TanksFound:Show();
		entry.HealersFound:Show();
		entry.DamagersFound:Show();
		height = height + 68;
	else
		entry.TanksFound:Hide();
		entry.HealersFound:Hide();
		entry.DamagersFound:Hide();
	end

	if ( not myWait or myWait <= 0 ) then
		entry.AverageWait:Hide();
	else
		entry.AverageWait:SetPoint("TOPLEFT", entry, "TOPLEFT", 10, -(height + 5));
		entry.AverageWait:SetFormattedText(LFG_STATISTIC_AVERAGE_WAIT, SecondsToTime(myWait, false, false, 1));
		entry.AverageWait:Show();
		height = height + entry.AverageWait:GetHeight();
	end

	if ( queuedTime ) then
		entry.queuedTime = queuedTime;
		local elapsed = GetTime() - queuedTime;
		entry.TimeInQueue:SetFormattedText(TIME_IN_QUEUE, (elapsed >= 60) and SecondsToTime(elapsed) or LESS_THAN_ONE_MINUTE);
		entry:SetScript("OnUpdate", QueueStatusEntry_OnUpdate);
	else
		entry.TimeInQueue:SetFormattedText(TIME_IN_QUEUE, LESS_THAN_ONE_MINUTE);
		entry:SetScript("OnUpdate", nil);
	end
	entry.TimeInQueue:SetPoint("TOPLEFT", entry, "TOPLEFT", 10, -(height + 5));
	entry.TimeInQueue:Show();
	height = height + entry.TimeInQueue:GetHeight();

	if ( extraText ) then
		entry.ExtraText:SetText(extraText);
		entry.ExtraText:Show();
		entry.ExtraText:SetPoint("TOPLEFT", entry, "TOPLEFT", 10, -(height + 10));
		height = height + entry.ExtraText:GetHeight() + 10;
	else
		entry.ExtraText:Hide();
	end

	entry:SetHeight(height + 14);
end

function QueueStatusEntry_OnUpdate(self, elapsed)
	--Don't update every tick (can't do 1 second beause it might be 1.01 seconds and we'll miss a tick.
	--Also can't do slightly less than 1 second (0.9) because we'll end up with some lingering numbers
	self.updateThrottle = (self.updateThrottle or 0.1) - elapsed;
	if ( self.updateThrottle <= 0 ) then
		local elapsed = GetTime() - self.queuedTime;
		self.TimeInQueue:SetFormattedText(TIME_IN_QUEUE, (elapsed >= 60) and SecondsToTime(elapsed) or LESS_THAN_ONE_MINUTE);
		self.updateThrottle = 0.1;
	end
end

----------------------------------------------
------------QueueStatusDropDown---------------
----------------------------------------------
function QueueStatusDropDown_Show(self, relativeTo)
	PlaySound("igMainMenuOpen");
	ToggleDropDownMenu(1, nil, self, relativeTo, 0, 0);
end

local wrappedFuncs = {};
local function wrapFunc(func) --Lets us directly set .func = on dropdown entries.
	if ( not wrappedFuncs[func] ) then
		wrappedFuncs[func] = function(button, ...) func(...) end;
	end
	return wrappedFuncs[func];
end

function QueueStatusDropDown_Update()
	local info = UIDropDownMenu_CreateInfo();

	--All LFG types
	for i=1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(i);
		if ( mode ) then
			QueueStatusDropDown_AddLFGButtons(info, i);
		end
	end

	local inProgress, _, _, _, _, isBattleground = GetLFGRoleUpdate();
	if ( inProgress and isBattleground ) then
		QueueStatusDropDown_AddPVPRoleCheckButtons(info);
	end

	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch = GetBattlefieldStatus(i);
		if ( status and status ~= "none" ) then
			QueueStatusDropDown_AddBattlefieldButtons(info, i);
		end
	end

	for i=1, MAX_WORLD_PVP_QUEUES do
		local status, mapName, queueID = GetWorldPVPQueueStatus(i);
		if ( status and status ~= "none" ) then
			QueueStatusDropDown_AddWorldPvPButtons(info, i);
		end
	end

	if ( CanHearthAndResurrectFromArea() ) then
		wipe(info);
		local name = GetRealZoneText();
		info.text = "|cff19ff19"..name.."|r";
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);

		info.text = format(LEAVE_ZONE, name);
		info.isTitle = false;
		info.disabled = false;
		info.func = wrapFunc(HearthAndResurrectFromArea);
		UIDropDownMenu_AddButton(info);
	end

	if ( C_PetBattles.GetPVPMatchmakingInfo() ) then
		QueueStatusDropDown_AddPetBattleButtons(info);
	end
end

function QueueStatusDropDown_AddWorldPvPButtons(info, idx)
	wipe(info);
	local status, mapName, queueID = GetWorldPVPQueueStatus(idx);

	local name = mapName;

	info.text = name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.disabled = false;
	info.isTitle = nil;
	info.leftPadding = 10;

	if ( status == "queued" ) then
		info.text = LEAVE_QUEUE;
		info.func = wrapFunc(BattlefieldMgrExitRequest);
		info.arg1 = queueID;
		UIDropDownMenu_AddButton(info);
	elseif ( status == "confirm" ) then
		info.text = ENTER_BATTLE;
		info.func = wrapFunc(BattlefieldMgrEntryInviteResponse);
		info.arg1 = queueID;
		info.arg2 = 1;
		UIDropDownMenu_AddButton(info);

		info.text = LEAVE_QUEUE;
		info.func = wrapFunc(BattlefieldMgrExitRequest);
		info.arg1 = queueID;
		info.arg2 = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function QueueStatusDropDown_AddPVPRoleCheckButtons(info)
	wipe(info);
	local inProgress, _, _, _, _, isBattleground = GetLFGRoleUpdate();
	
	if ( inProgress and isBattleground ) then
		local name = GetLFGRoleUpdateBattlegroundInfo();
		info.text = name;
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);

		info.text = QUEUED_STATUS_ROLE_CHECK_IN_PROGRESS;
		info.isTitle = nil;
		info.leftPadding = 10;
		info.func = nil;
		info.disabled = true;
		UIDropDownMenu_AddButton(info);
	end
end

function QueueStatusDropDown_AddBattlefieldButtons(info, idx)
	wipe(info);
	local status, mapName, teamSize, registeredMatch = GetBattlefieldStatus(idx);

	local name = mapName;
	if ( status == "active" ) then
		name = "|cff19ff19"..name.."|r";
	end
	info.text = name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.disabled = false;
	info.isTitle = nil;
	info.leftPadding = 10;

	if ( status == "queued" ) then
		info.text = LEAVE_QUEUE;
		info.func = wrapFunc(AcceptBattlefieldPort);
		info.arg1 = idx;
		info.arg2 = false;
		info.disabled = registeredMatch and IsInGroup() and not UnitIsGroupLeader("player");
		UIDropDownMenu_AddButton(info);
	elseif ( status == "locked" ) then
		info.text = LEAVE_BATTLEGROUND;
		info.disabled = true;
		UIDropDownMenu_AddButton(info);
	elseif ( status == "confirm" ) then
		info.text = ENTER_BATTLE;
		info.func = wrapFunc(AcceptBattlefieldPort);
		info.arg1 = idx;
		info.arg2 = 1;
		UIDropDownMenu_AddButton(info);

		if ( teamSize == 0 ) then
			info.text = LEAVE_QUEUE;
			info.func = wrapFunc(AcceptBattlefieldPort);
			info.arg1 = idx;
			info.arg2 = false;
			UIDropDownMenu_AddButton(info);
		end
	elseif ( status == "active" ) then
		local inArena = IsActiveBattlefieldArena();

		if ( not inArena or GetBattlefieldWinner() ) then
			info.text = TOGGLE_SCOREBOARD;
			info.func = wrapFunc(ToggleWorldStateScoreFrame);
			info.arg1 = nil;
			info.arg2 = nil;
			UIDropDownMenu_AddButton(info);
		end
		
		if ( not inArena ) then
			info.text = TOGGLE_BATTLEFIELD_MAP;
			info.func = wrapFunc(ToggleBattlefieldMinimap);
			info.arg1 = nil;
			info.arg2 = nil;
			UIDropDownMenu_AddButton(info);
		end

		if ( inArena ) then
			info.text = LEAVE_ARENA;
		else
			info.text = LEAVE_BATTLEGROUND;
		end
		info.func = wrapFunc(ConfirmOrLeaveBattlefield);
		info.arg1 = nil;
		info.arg2 = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function QueueStatusDropDown_AddLFGButtons(info, category)
	wipe(info);

	QueueStatus_GetAllRelevantLFG(category, queuedList);
	local statuses = {};
	for queueID in pairs(queuedList) do
		local mode, submode = GetLFGMode(category, queueID);
		if ( mode ) then
			statuses[mode] = (statuses[mode] or 0) + 1;
			local hack = mode.."."..(submode or ""); --eww
			statuses[hack] = (statuses[hack] or 0) + 1;
		end
	end

	local name = LFG_CATEGORY_NAMES[category];
	if ( IsLFGModeActive(category) ) then
		name = "|cff19ff19"..name.."|r";
	end
	info.text = name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.disabled = false;
	info.isTitle = nil;
	info.leftPadding = 10;

	if ( IsLFGModeActive(category) and IsPartyLFG() ) then
		if ( IsAllowedToUserTeleport() ) then
			if ( IsInLFGDungeon() ) then
				info.text = TELEPORT_OUT_OF_DUNGEON;
				info.func = wrapFunc(LFGTeleport);
				info.arg1 = true;
				info.disabled = false;
				UIDropDownMenu_AddButton(info);
			else
				info.text = TELEPORT_TO_DUNGEON;
				info.func = wrapFunc(LFGTeleport);
				info.arg1 = false;
				info.disabled = false;
				UIDropDownMenu_AddButton(info);
			end
		end
		info.text = INSTANCE_PARTY_LEAVE;
		info.func = wrapFunc(ConfirmOrLeaveLFGParty);
		info.arg1 = nil;
		info.disabled = false;
		UIDropDownMenu_AddButton(info);
	end

	if ( statuses.rolecheck ) then
		info.text = QUEUED_STATUS_ROLE_CHECK_IN_PROGRESS;
		info.func = nil;
		info.disabled = true;
		UIDropDownMenu_AddButton(info);
	end
	if ( statuses.queued or statuses.suspended ) then
		local manyQueues = (category == LE_LFG_CATEGORY_RF) and (statuses.queued or 0) + (statuses.suspended or 0) > 1;
		info.text = manyQueues and LEAVE_ALL_QUEUES or LEAVE_QUEUE;
		info.func = wrapFunc(LeaveLFG);
		info.arg1 = category;
		info.disabled = not (statuses["queued.empowered"] or statuses["suspended.empowered"]);
		UIDropDownMenu_AddButton(info);
	end
	if ( statuses.listed ) then
		if ( IsInGroup() ) then
			info.text = UNLIST_MY_GROUP;
		else
			info.text = UNLIST_ME;
		end
		info.func = wrapFunc(LeaveLFG);
		info.arg1 = category;
		info.disabled = not statuses["listed.empowered"];
		UIDropDownMenu_AddButton(info);
	end
	if ( statuses.proposal ) then
		if ( statuses["proposal.accepted"] ) then
			info.text = QUEUED_STATUS_PROPOSAL;
			info.func = nil;
			info.disabled = true;
			UIDropDownMenu_AddButton(info);
		elseif ( statuses["proposal.unaccepted"] ) then
			info.text = ENTER_DUNGEON;
			info.func = wrapFunc(AcceptProposal);
			info.arg1 = nil;
			info.disabled = false;
			UIDropDownMenu_AddButton(info);

			info.text = LEAVE_QUEUE;
			info.func = wrapFunc(RejectProposal);
			info.arg1 = category;
			info.disabled = (submode == "unempowered");
			UIDropDownMenu_AddButton(info);
		end
	end
end

function QueueStatusDropDown_AcceptQueuedPVPMatch()
	if ( IsFalling() ) then
		UIErrorsFrame:AddMessage(ERR_NOT_WHILE_FALLING, 1.0, 0.1, 0.1, 1.0);
	elseif ( UnitAffectingCombat("player") ) then
		UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT, 1.0, 0.1, 0.1, 1.0);
	else
		C_PetBattles.AcceptQueuedPVPMatch()
	end
end

function QueueStatusDropDown_AddPetBattleButtons(info)
	wipe(info);

	local status = C_PetBattles.GetPVPMatchmakingInfo();

	info.text = PET_BATTLE_PVP_QUEUE;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.disabled = false;
	info.isTitle = nil;
	info.leftPadding = 10;

	if ( status == "queued" or status == "suspended" ) then
		info.text = LEAVE_QUEUE;
		info.func = wrapFunc(C_PetBattles.StopPVPMatchmaking);
		UIDropDownMenu_AddButton(info);
	elseif ( status == "proposal" ) then
		info.text = ENTER_PET_BATTLE;
		info.func = wrapFunc(QueueStatusDropDown_AcceptQueuedPVPMatch);
		UIDropDownMenu_AddButton(info);

		info.text = LEAVE_QUEUE;
		info.func = wrapFunc(C_PetBattles.DeclineQueuedPVPMatch);
		UIDropDownMenu_AddButton(info);
	elseif ( status == "entry" ) then
		info.text = ENTER_PET_BATTLE;
		info.func = nil;
		info.disabled = true;
		UIDropDownMenu_AddButton(info);
	end
end

----------------------------------------------
-------QueueStatus Utility Functions----------
----------------------------------------------
function QueueStatus_InActiveBattlefield()
	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch = GetBattlefieldStatus(i);
		if ( status == "active" ) then
			local canShowScoreboard = false;
			local inArena = IsActiveBattlefieldArena();
			if ( not inArena or GetBattlefieldWinner() ) then
				canShowScoreboard = true;
			end
			return true, canShowScoreboard;
		end
	end
end

