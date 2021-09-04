
----------------------------------------------
---------QueueStatusMinimapButton-------------
----------------------------------------------

function QueueStatusMinimapButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:SetFrameLevel(self:GetFrameLevel() + 1);
	self.glowLocks = {};
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
		if IsInLFDBattlefield() then
			inBattlefield = true;
			showScoreboard = true;
		end
		local lfgListActiveEntry = C_LFGList.HasActiveEntryInfo();
		if ( inBattlefield ) then
			if ( showScoreboard ) then
				TogglePVPScoreboardOrResults();
			end
		elseif ( lfgListActiveEntry ) then
			LFGListUtil_OpenBestWindow(true);
		else
			--See if we have any active LFGList applications
			local apps = C_LFGList.GetApplications();
			for i=1, #apps do
				local _, appStatus = C_LFGList.GetApplicationInfo(apps[i]);
				if ( appStatus == "applied" or appStatus == "invited" ) then
					--We want to open to the LFGList screen
					LFGListUtil_OpenBestWindow(true);
					return;
				end
			end

			--Just show the dropdown
			QueueStatusDropDown_Show(self.DropDown, self:GetName());
		end
	end
end

function QueueStatusMinimapButton_OnShow(self)
	self.Eye:SetFrameLevel(self:GetFrameLevel() - 1);
end

function QueueStatusMinimapButton_OnHide(self)
	QueueStatusFrame:Hide();
end

--Will play the sound numPingSounds times (or forever if nil)
function QueueStatusMinimapButton_SetGlowLock(self, lock, enabled, numPingSounds)
	self.glowLocks[lock] = enabled and (numPingSounds or -1);
	QueueStatusMinimapButton_UpdateGlow(self);
end

function QueueStatusMinimapButton_UpdateGlow(self)
	local enabled = false;
	for k, v in pairs(self.glowLocks) do
		if ( v ) then
			enabled = true;
			break;
		end
	end

	self.Highlight:SetShown(enabled);
	if ( enabled ) then
		self.EyeHighlightAnim:Play();
	else
		self.EyeHighlightAnim:Stop();
	end
end

function QueueStatusMinimapButton_OnGlowPulse(self)
	local playSounds = false;
	for k, v in pairs(self.glowLocks) do
		if ( type(v) == "number" ) then
			-- < 0 means play sounds forever
			-- > 0 means play sounds n times
			-- == 0 means no longer playing sounds
			if ( v < 0 ) then
				playSounds = true;
			elseif ( v > 0 ) then
				self.glowLocks[k] = v - 1;
				playSounds = true;
			end
		end
	end

	return playSounds;
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
	self:RegisterEvent("LFG_READY_CHECK_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_FAILED");
	self:RegisterEvent("LFG_PROPOSAL_SUCCEEDED");
	self:RegisterEvent("LFG_PROPOSAL_SHOW");
	self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE");

	--For LFGList
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");
	self:RegisterEvent("LFG_LIST_APPLICANT_UPDATED");

	--For PvP
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PVP_BRAWL_INFO_UPDATED");

	--For World PvP stuff
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("ZONE_CHANGED");

	--For Pet Battles
	self:RegisterEvent("PET_BATTLE_QUEUE_STATUS");

	QueueStatusFrame_CreateEntriesPool(self);
end

function QueueStatusFrame_OnEvent(self)
	QueueStatusFrame_Update(self);
end

function QueueStatusFrame_GetEntry(self, entryIndex)
	local entry = self.statusEntriesPool:Acquire();
	entry.orderIndex = entryIndex;
	return entry;
end

do
	local function EntryComparator(left, right)
		if (left.active ~= right.active) then
			return left.active;
		end

		return left.orderIndex < right.orderIndex;
	end

	function QueueStatusFrame_SortAndAnchorEntries(self)
		local entries = {};
		for entry in self.statusEntriesPool:EnumerateActive() do
			entries[#entries + 1] = entry;
		end
		table.sort(entries, EntryComparator);

		local prevEntry;
		for i, entry in ipairs(entries) do
			if ( not prevEntry ) then
				entry:SetPoint("TOP", self, "TOP", 0, 0);
				entry.EntrySeparator:Hide();
			else
				entry:SetPoint("TOP", prevEntry, "BOTTOM", 0, 0);
			end
			prevEntry = entry;
		end
	end
end

do
    local function QueueStatusEntryResetter(pool, frame)
	    frame:Hide();
	    frame:ClearAllPoints();
    
	    frame.EntrySeparator:Show();
	    frame.active = nil;
	    frame.orderIndex = nil;
    end

	function QueueStatusFrame_CreateEntriesPool(self)
		self.statusEntriesPool = CreateFramePool("FRAME", self, "QueueStatusEntryTemplate", QueueStatusEntryResetter);
	end
end

function QueueStatusFrame_Update(self)
	local animateEye;

	local nextEntry = 1;

	local totalHeight = 4; --Add some buffer height

	self.statusEntriesPool:ReleaseAll();

	--Try each LFG type
	for i=1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(i);
		if ( mode and submode ~= "noteleport" ) then
			local entry = QueueStatusFrame_GetEntry(self, nextEntry);
			QueueStatusEntry_SetUpLFG(entry, i);
			entry:Show();
			totalHeight = totalHeight + entry:GetHeight();
			nextEntry = nextEntry + 1;

			if ( mode == "queued" ) then
				animateEye = true;
			end
		end
	end

	--Try LFGList entries
	local isActive = C_LFGList.HasActiveEntryInfo();
	if ( isActive ) then
		local entry = QueueStatusFrame_GetEntry(self, nextEntry);
		QueueStatusEntry_SetUpLFGListActiveEntry(entry);
		entry:Show();
		totalHeight = totalHeight + entry:GetHeight();
		nextEntry = nextEntry + 1;
		animateEye = true;
	end

	--Try LFGList applications
	local apps = C_LFGList.GetApplications();
	for i=1, #apps do
		local _, appStatus = C_LFGList.GetApplicationInfo(apps[i]);
		if ( appStatus == "applied" or appStatus == "invited" ) then
			local entry = QueueStatusFrame_GetEntry(self, nextEntry);
			QueueStatusEntry_SetUpLFGListApplication(entry, apps[i]);
			entry:Show();
			totalHeight = totalHeight + entry:GetHeight();
			nextEntry = nextEntry + 1;

			if ( appStatus == "applied" ) then
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
	end

	local readyCheckInProgress, readyCheckIsBattleground = GetLFGReadyCheckUpdate();

	-- Try PvP Ready Check
	if ( readyCheckInProgress and readyCheckIsBattleground ) then
		local entry = QueueStatusFrame_GetEntry(self, nextEntry);
		QueueStatusEntry_SetUpPvPReadyCheck(entry);
		entry:Show();
		totalHeight = totalHeight + entry:GetHeight();
		nextEntry = nextEntry + 1;
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
	end

	--Pet Battle PvP Queue
	local pbStatus = C_PetBattles.GetPVPMatchmakingInfo();
	if ( pbStatus ) then
		local entry = QueueStatusFrame_GetEntry(self, nextEntry);
		QueueStatusEntry_SetUpPetBattlePvP(entry);
		entry:Show();
		totalHeight = totalHeight + entry:GetHeight();
		nextEntry = nextEntry + 1;

		if ( pbStatus == "queued" ) then
			animateEye = true;
		end
	end

	QueueStatusFrame_SortAndAnchorEntries(self);

	--Update the size of this frame to fit everything
	self:SetHeight(totalHeight);

	--Update the minimap icon
	if ( nextEntry > 1 ) then
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

local function GetDisplayNameFromCategory(category)
	if (category == LE_LFG_CATEGORY_BATTLEFIELD) then
		local brawlInfo;
		if (C_PvP.IsInBrawl()) then
			brawlInfo = C_PvP.GetActiveBrawlInfo();
		else
			brawlInfo = C_PvP.GetAvailableBrawlInfo();
		end
		if (brawlInfo and brawlInfo.canQueue and brawlInfo.name) then
			return brawlInfo.name;
		end
	end

	if (category == LE_LFG_CATEGORY_SCENARIO) then
		local scenarioIDs = C_LFGInfo.GetAllEntriesForCategory(category)
		for i, scenID in ipairs(scenarioIDs) do
			if (not C_LFGInfo.HideNameFromUI(scenID)) then
				local instanceName = GetLFGDungeonInfo(scenID);
				if(instanceName) then
					return instanceName;
				end
			end
		end
	end

	return LFG_CATEGORY_NAMES[category];
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
		
		if ( category == LE_LFG_CATEGORY_WORLDPVP ) then
			QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_IN_PROGRESS, subTitle, extraText);
		else
			QueueStatusEntry_SetFullDisplay(entry, GetDisplayNameFromCategory(category), queuedTime, myWait, tank, healer, dps, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText);
		end
	elseif ( mode == "proposal" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_PROPOSAL, subTitle, extraText);
	elseif ( mode == "listed" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_LISTED, subTitle, extraText);
	elseif ( mode == "suspended" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_SUSPENDED, subTitle, extraText);
	elseif ( mode == "rolecheck" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_ROLE_CHECK_IN_PROGRESS, subTitle, extraText);
	elseif ( mode == "lfgparty" or mode == "abandonedInDungeon" ) then
		local title;
		if (C_PvP.IsInBrawl()) then
			local brawlInfo = C_PvP.GetActiveBrawlInfo();
			if (brawlInfo and brawlInfo.canQueue and brawlInfo.longDescription) then
				title = brawlInfo.name;
				if (subtitle) then
					subtitle = QUEUED_STATUS_BRAWL_RULES_SUBTITLE:format(brawlInfo.longDescription, subtitle);
				else
					subtitle = brawlInfo.longDescription;
				end
			end
		else
			title = GetDisplayNameFromCategory(category);
		end
		QueueStatusEntry_SetMinimalDisplay(entry, title, QUEUED_STATUS_IN_PROGRESS, subTitle, extraText);
	else
		QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_UNKNOWN, subTitle, extraText);
	end
end

function QueueStatusEntry_SetUpLFGListActiveEntry(entry)
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	local numApplicants, numActiveApplicants = C_LFGList.GetNumApplicants();
	QueueStatusEntry_SetMinimalDisplay(entry, activeEntryInfo.name, QUEUED_STATUS_LISTED, string.format(LFG_LIST_PENDING_APPLICANTS, numActiveApplicants));
end

function QueueStatusEntry_SetUpLFGListApplication(entry, resultID)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	local activityName = C_LFGList.GetActivityInfo(searchResultInfo.activityID, nil, searchResultInfo.isWarMode);
	QueueStatusEntry_SetMinimalDisplay(entry, searchResultInfo.name, QUEUED_STATUS_SIGNED_UP, activityName);
end

function QueueStatusEntry_SetUpBattlefield(entry, idx)
	local status, mapName, teamSize, registeredMatch, suspend, _, _, _, _, _, longDescription = GetBattlefieldStatus(idx);
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
		if (mapName) then
			local hasLongDescription = longDescription and longDescription ~= "";
			local text = hasLongDescription and longDescription or nil;
			QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_IN_PROGRESS, text);
		else
			QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_IN_PROGRESS);
		end
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

function QueueStatusEntry_SetUpPvPReadyCheck(entry)
	local queueName = GetLFGReadyCheckUpdateBattlegroundInfo();
	QueueStatusEntry_SetMinimalDisplay(entry, queueName, QUEUED_STATUS_READY_CHECK_IN_PROGRESS);
end

function QueueStatusEntry_SetUpWorldPvP(entry, idx)
	local status, mapName, queueID, expireTime, averageWaitTime, queuedTime, suspended = GetWorldPVPQueueStatus(idx);
	if ( status == "queued" ) then
		if ( suspended ) then
			QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_SUSPENDED);
		else
			QueueStatusEntry_SetFullDisplay(entry, mapName, queuedTime / 1000, averageWaitTime / 1000);
		end
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

function QueueStatusEntry_SetMinimalDisplay(entry, title, status, subTitle, extraText)
	local height = 10;

	entry.Title:SetText(title);
	entry.Status:SetText(status);
	entry.Status:Show();
	entry.SubTitle:ClearAllPoints();
	entry.SubTitle:SetPoint("TOPLEFT", entry.Status, "BOTTOMLEFT", 0, -5);
	entry.active = (status == QUEUED_STATUS_IN_PROGRESS);

	height = height + entry.Status:GetHeight() + entry.Title:GetHeight();

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
	
	entry.Title:SetText(title);
	height = height + entry.Title:GetHeight();

	entry.Status:Hide();
	entry.SubTitle:ClearAllPoints();
	entry.SubTitle:SetPoint("TOPLEFT", entry.Title, "BOTTOMLEFT", 0, -5);

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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
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
	--All LFG types
	for i=1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(i);
		if ( mode and submode ~= "noteleport" ) then
			QueueStatusDropDown_AddLFGButtons(i);
		end
	end

	--LFGList
	local isActive = C_LFGList.HasActiveEntryInfo();
	if ( isActive ) then
		QueueStatusDropDown_AddLFGListButtons();
	end

	local apps = C_LFGList.GetApplications();
	for i=1, #apps do
		local _, appStatus = C_LFGList.GetApplicationInfo(apps[i]);
		if ( appStatus == "applied" ) then
			QueueStatusDropDown_AddLFGListApplicationButtons(apps[i]);
		end
	end

	--PvP
	local inProgress, _, _, _, _, isBattleground = GetLFGRoleUpdate();
	if ( inProgress and isBattleground ) then
		QueueStatusDropDown_AddPVPRoleCheckButtons();
	end

	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch = GetBattlefieldStatus(i);
		if ( status and status ~= "none" ) then
			QueueStatusDropDown_AddBattlefieldButtons(i);
		end
	end

	--World PvP
	for i=1, MAX_WORLD_PVP_QUEUES do
		local status, mapName, queueID = GetWorldPVPQueueStatus(i);
		if ( status and status ~= "none" ) then
			QueueStatusDropDown_AddWorldPvPButtons(i);
		end
	end

	if ( CanHearthAndResurrectFromArea() ) then
		local info = UIDropDownMenu_CreateInfo();
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

	--Pet Battles
	if ( C_PetBattles.GetPVPMatchmakingInfo() ) then
		QueueStatusDropDown_AddPetBattleButtons();
	end
end

function QueueStatusDropDown_AddWorldPvPButtons(idx)
	local info = UIDropDownMenu_CreateInfo();
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
		info.text = ENTER_LFG;
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

function QueueStatusDropDown_AddPVPRoleCheckButtons()
	local info = UIDropDownMenu_CreateInfo();
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

local function LeaveQueueWithMatchReadyCheck(idx)
	local status, mapName, teamSize, registeredMatch, suspendedQueue, queueType = GetBattlefieldStatus(idx);
	if status == "confirm" and (queueType == "ARENA" or queueType == "ARENASKIRMISH" or (queueType == "BATTLEGROUND" and registeredMatch)) then
		UIErrorsFrame:AddExternalErrorMessage(PVP_MATCH_READY_ERROR);
	else
		local acceptPort = false;
		AcceptBattlefieldPort(idx, acceptPort);
	end
end

function QueueStatusDropDown_AddBattlefieldButtons(idx)
	local info = UIDropDownMenu_CreateInfo();
	local status, mapName, teamSize, registeredMatch,_,_,_,_, asGroup = GetBattlefieldStatus(idx);

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
		info.func = wrapFunc(LeaveQueueWithMatchReadyCheck);
		info.arg1 = idx;
		info.arg2 = nil;
		info.disabled = IsInGroup() and not UnitIsGroupLeader("player");
		UIDropDownMenu_AddButton(info);
	elseif ( status == "locked" ) then
		info.text = LEAVE_BATTLEGROUND;
		info.disabled = true;
		UIDropDownMenu_AddButton(info);
	elseif ( status == "confirm" ) then
		info.text = ENTER_LFG;
		info.func = wrapFunc(AcceptBattlefieldPort);
		info.arg1 = idx;
		info.arg2 = 1;
		UIDropDownMenu_AddButton(info);

		if ( teamSize == 0 ) then
			info.text = LEAVE_QUEUE;
			info.func = wrapFunc(LeaveQueueWithMatchReadyCheck);
			info.arg1 = idx;
			info.arg2 = nil;
			UIDropDownMenu_AddButton(info);
		end
	elseif ( status == "active" ) then
		local inArena = IsActiveBattlefieldArena();

		if ( not inArena or GetBattlefieldWinner() or C_Commentator.GetMode() > 0 or C_PvP.IsInBrawl() ) then
			info.text = TOGGLE_SCOREBOARD;
			info.func = wrapFunc(TogglePVPScoreboardOrResults);
			info.arg1 = nil;
			info.arg2 = nil;
			UIDropDownMenu_AddButton(info);
		end
		
		if ( not inArena ) then
			info.text = TOGGLE_BATTLEFIELD_MAP;
			info.func = wrapFunc(ToggleBattlefieldMap);
			info.arg1 = nil;
			info.arg2 = nil;
			UIDropDownMenu_AddButton(info);
		end

		if ( inArena and not C_PvP.IsInBrawl() ) then
			info.text = SURRENDER_ARENA;
			info.func = wrapFunc(ConfirmSurrenderArena);
			info.arg1 = nil;
			info.arg2 = nil;
			if (not CanSurrenderArena()) then
				info.disabled = true;
			end
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			info.disabled = false;
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

function QueueStatusDropDown_AddLFGButtons(category)
	local info = UIDropDownMenu_CreateInfo();

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

	local name = GetDisplayNameFromCategory(category);
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
		local addExitOption = true;
		if ( IsAllowedToUserTeleport() ) then
			if ( IsInLFDBattlefield() ) then
				local _, instanceType = IsInInstance();
				if ( instanceType ~= "arena" and instanceType ~= "pvp" ) then
					info.text = ENTER_LFG;
					info.func = wrapFunc(LFGTeleport);
					info.arg1 = false;
					info.disabled = false;
					UIDropDownMenu_AddButton(info);
					addExitOption = false;
				else
					info.text = TOGGLE_SCOREBOARD;
					info.func = wrapFunc(TogglePVPScoreboardOrResults);
					info.arg1 = nil;
					info.arg2 = nil;
					UIDropDownMenu_AddButton(info);
				end
			elseif ( IsInLFGDungeon() ) then
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
		if ( addExitOption ) then
			info.text = (category == LE_LFG_CATEGORY_WORLDPVP) and LEAVE_BATTLEGROUND or INSTANCE_PARTY_LEAVE;
			info.func = wrapFunc(ConfirmOrLeaveLFGParty);
			info.arg1 = nil;
			info.disabled = false;
			UIDropDownMenu_AddButton(info);
		end
	end

	if ( statuses.rolecheck ) then
		info.text = QUEUED_STATUS_ROLE_CHECK_IN_PROGRESS;
		info.func = nil;
		info.disabled = true;
		UIDropDownMenu_AddButton(info);
	end
	local preventLeaveQueue = IsLFGModeActive(category) and IsServerControlledBackfill();
	if ( ( statuses.queued or statuses.suspended ) and not preventLeaveQueue ) then
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
			info.text = ENTER_LFG;
			info.func = wrapFunc(AcceptProposal);
			info.arg1 = nil;
			info.disabled = false;
			UIDropDownMenu_AddButton(info);

			info.text = LEAVE_QUEUE;
			info.func = wrapFunc(RejectProposal);
			info.arg1 = category;
			info.disabled = false;
			UIDropDownMenu_AddButton(info);
		end
	end
end

function QueueStatusDropDown_AddLFGListButtons()
	local info = UIDropDownMenu_CreateInfo();
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	info.text = activeEntryInfo.name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.text = LFG_LIST_VIEW_GROUP;
	info.isTitle = nil;
	info.leftPadding = 10;
	info.func = LFGListUtil_OpenBestWindow;
	info.disabled = false;
	UIDropDownMenu_AddButton(info);

	info.text = UNLIST_MY_GROUP;
	info.isTitle = nil;
	info.leftPadding = 10;
	info.func = wrapFunc(C_LFGList.RemoveListing);
	info.disabled = not UnitIsGroupLeader("player");
	UIDropDownMenu_AddButton(info);
end

function QueueStatusDropDown_AddLFGListApplicationButtons(resultID)
	local info = UIDropDownMenu_CreateInfo();
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	info.text = searchResultInfo.name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.text = CANCEL_SIGN_UP;
	info.isTitle = nil;
	info.leftPadding = 10;
	info.func = wrapFunc(C_LFGList.CancelApplication);
	info.arg1 = resultID;
	info.disabled = IsInGroup() and not UnitIsGroupLeader("player");
	UIDropDownMenu_AddButton(info);
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

function QueueStatusDropDown_AddPetBattleButtons()
	local info = UIDropDownMenu_CreateInfo();

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
			if not inArena or GetBattlefieldWinner() or C_PvP.IsInBrawl() then
				canShowScoreboard = true;
			end
			return true, canShowScoreboard;
		end
	end
end

function TogglePVPScoreboardOrResults()
	if IsAddOnLoaded("Blizzard_PVPMatch") then
		local matchState = C_PvP.GetActiveMatchState();
		local isComplete = matchState == Enum.PvPMatchState.Complete;
		if isComplete then
			if PVPMatchResults:IsShown() then
				HideUIPanel(PVPMatchResults);
			else
				PVPMatchResults:BeginShow();
			end
		else
			if PVPMatchScoreboard:IsShown() then
				HideUIPanel(PVPMatchScoreboard);
			else
				local isActive = matchState == Enum.PvPMatchState.Active;
				if isActive and not C_PvP.IsMatchConsideredArena() then
					PVPMatchScoreboard:BeginShow();
				end
			end
		end
	end
end