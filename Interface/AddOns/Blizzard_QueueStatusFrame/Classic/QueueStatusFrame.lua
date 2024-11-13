----------------------------------------------
------------QueueStatusFrame------------------
----------------------------------------------

QueueStatusFrameMixin = {}
function QueueStatusFrameMixin:OnLoad()
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

	QueueStatusFrame_CreateEntriesPool(self);
end

function QueueStatusFrameMixin:OnEvent(event, ...)
	self:Update();
end

function QueueStatusFrameMixin:OnShow()
	self:SetPoint("TOPRIGHT", MiniMapLFGFrame, "BOTTOMLEFT", 0, 6);
end

function QueueStatusFrameMixin:GetEntry(entryIndex)
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

function QueueStatusFrameMixin:Update()
	local nextEntry = 1;

	local totalHeight = 4; --Add some buffer height

	self.statusEntriesPool:ReleaseAll();

	--Try each LFG type
	for i=1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(i);

		if ( mode and submode ~= "noteleport" ) then
			local entry = self:GetEntry(nextEntry);
			QueueStatusEntry_SetUpLFG(entry, i);
			entry:Show();
			totalHeight = totalHeight + entry:GetHeight();
			nextEntry = nextEntry + 1;
		end
	end

	--Try LFGList entries
	local isActive = C_LFGList.HasActiveEntryInfo();
	if ( isActive ) then
		local entry = self:GetEntry(nextEntry);
		QueueStatusEntry_SetUpLFGListActiveEntry(entry);
		entry:Show();
		totalHeight = totalHeight + entry:GetHeight();
		nextEntry = nextEntry + 1;
	end

	--Try LFGList applications
	local apps = C_LFGList.GetApplications();
	for i=1, #apps do
		local _, appStatus = C_LFGList.GetApplicationInfo(apps[i]);
		if ( appStatus == "applied" or appStatus == "invited" ) then
			local entry = self:GetEntry(nextEntry);
			QueueStatusEntry_SetUpLFGListApplication(entry, apps[i]);
			entry:Show();
			totalHeight = totalHeight + entry:GetHeight();
			nextEntry = nextEntry + 1;
		end
	end

	local inProgress, _, _, _, _, isBattleground = GetLFGRoleUpdate();

	--Try PvP Role Check
	if ( inProgress and isBattleground ) then
		local entry = self:GetEntry(nextEntry);
		QueueStatusEntry_SetUpPVPRoleCheck(entry);
		entry:Show();
		totalHeight = totalHeight + entry:GetHeight();
		nextEntry = nextEntry + 1;
	end

	local readyCheckInProgress, readyCheckIsBattleground = GetLFGReadyCheckUpdate();

	-- Try PvP Ready Check
	if ( readyCheckInProgress and readyCheckIsBattleground ) then
		local entry = self:GetEntry(nextEntry);
		QueueStatusEntry_SetUpPvPReadyCheck(entry);
		entry:Show();
		totalHeight = totalHeight + entry:GetHeight();
		nextEntry = nextEntry + 1;
	end

	--Try all PvP queues
	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch, suspend = GetBattlefieldStatus(i);
		if ( status and status ~= "none" ) then
			local entry = self:GetEntry(nextEntry);
			QueueStatusEntry_SetUpBattlefield(entry, i);
			entry:Show();
			totalHeight = totalHeight + entry:GetHeight();
			nextEntry = nextEntry + 1;
		end
	end

	-- NOTICE: Keep this as the last possible entry
	-- If you're in edit mode and there are no other entries then add one for edit mode so the eye shows
	if ( nextEntry <= 1 and EditModeManagerFrame:IsEditModeActive() ) then
		local entry = self:GetEntry(nextEntry);
		QueueStatusEntry_SetMinimalDisplay(entry, HUD_EDIT_MODE_TITLE, QUEUED_STATUS_IN_PROGRESS);
		entry:Show();
		totalHeight = totalHeight + entry:GetHeight();
		nextEntry = nextEntry + 1;
	end

	QueueStatusFrame_SortAndAnchorEntries(self);

	--Update the size of this frame to fit everything
	self:SetHeight(totalHeight);
end

function QueueStatusFrameMixin:UpdatePosition(microMenuPosition, isMenuHorizontal)
	-- Position frame so that it is facing towards the center of the screen to avoid it going offscreen
	local point, relativePoint, offsetX, offsetY;
	if isMenuHorizontal then
		if microMenuPosition == MicroMenuPositionEnum.BottomLeft then
			point, relativePoint, offsetX, offsetY = "BOTTOMLEFT", "BOTTOMRIGHT", 0, 25;
		elseif microMenuPosition == MicroMenuPositionEnum.BottomRight then
			point, relativePoint, offsetX, offsetY = "BOTTOMRIGHT", "BOTTOMLEFT", 0, 25;
		elseif microMenuPosition == MicroMenuPositionEnum.TopLeft then
			point, relativePoint, offsetX, offsetY = "TOPLEFT", "TOPRIGHT", 0, -25;
		elseif microMenuPosition == MicroMenuPositionEnum.TopRight then
			point, relativePoint, offsetX, offsetY = "TOPRIGHT", "TOPLEFT", 0, -25;
		end
	else
		if microMenuPosition == MicroMenuPositionEnum.BottomLeft then
			point, relativePoint, offsetX, offsetY = "BOTTOMLEFT", "TOPLEFT", 25, 0;
		elseif microMenuPosition == MicroMenuPositionEnum.BottomRight then
			point, relativePoint, offsetX, offsetY = "BOTTOMRIGHT", "TOPRIGHT", -25, 0;
		elseif microMenuPosition == MicroMenuPositionEnum.TopLeft then
			point, relativePoint, offsetX, offsetY = "TOPLEFT", "BOTTOMLEFT", 25, 0;
		elseif microMenuPosition == MicroMenuPositionEnum.TopRight then
			point, relativePoint, offsetX, offsetY = "TOPRIGHT", "BOTTOMRIGHT", -25, 0;
		end
	end

	self:ClearAllPoints();
	self:SetPoint(point, MiniMapLFGFrame, relativePoint, offsetX, offsetY);
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
				if (subTitle) then
					subTitle = QUEUED_STATUS_BRAWL_RULES_SUBTITLE:format(brawlInfo.longDescription, subTitle);
				else
					subTitle = brawlInfo.longDescription;
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
	local activityName = C_LFGList.GetActivityFullName(searchResultInfo.activityIDs[1], nil, searchResultInfo.isWarMode);
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
			local isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
			local assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(idx);
			QueueStatusEntry_SetFullDisplay(entry, mapName, queuedTime, estimatedTime, isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText, assignedSpec);
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
	entry.AssignedSpec:Hide();

	entry.TanksFound:Hide();
	entry.HealersFound:Hide();
	entry.DamagersFound:Hide();

	entry:SetScript("OnUpdate", nil);

	entry:SetHeight(height + 6);
end

function QueueStatusEntry_SetFullDisplay(entry, title, queuedTime, myWait, isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText, assignedSpec)
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

	local nextRoleIcon = 1;
	if assignedSpec then
		local id, name, description, icon, role, classFile, className = GetSpecializationInfoByID(assignedSpec);
		SetPortraitToTexture(entry.AssignedSpec.Icon, icon or QUESTION_MARK_ICON);
	else
		--Update your role icons
		if ( isDPS ) then
			local icon = entry["RoleIcon"..nextRoleIcon];
			local showDisabled = false;
			icon:SetAtlas(GetIconForRole("DAMAGER", showDisabled), TextureKitConstants.IgnoreAtlasSize);
			icon:Show();
			nextRoleIcon = nextRoleIcon + 1;
		end
		if ( isHealer ) then
			local icon = entry["RoleIcon"..nextRoleIcon];
			local showDisabled = false;
			icon:SetAtlas(GetIconForRole("HEALER", showDisabled), TextureKitConstants.IgnoreAtlasSize);
			icon:Show();
			nextRoleIcon = nextRoleIcon + 1;
		end
		if ( isTank ) then
			local icon = entry["RoleIcon"..nextRoleIcon];
			local showDisabled = false;
			icon:SetAtlas(GetIconForRole("TANK", showDisabled), TextureKitConstants.IgnoreAtlasSize);
			icon:Show();
			nextRoleIcon = nextRoleIcon + 1;
		end
	end

	-- Hide unused role and spec icons
	for i=nextRoleIcon, LFD_NUM_ROLES do
		entry["RoleIcon"..i]:Hide();
	end
	entry.AssignedSpec:SetShown(assignedSpec ~= nil);

	--Update the role needs
	if ( totalTanks and totalHealers and totalDPS ) then
		entry.HealersFound:SetPoint("TOP", entry, "TOP", 0, -(height + 5));
		entry.TanksFound.Count:SetFormattedText(PLAYERS_FOUND_OUT_OF_MAX, totalTanks - tankNeeds, totalTanks);
		entry.HealersFound.Count:SetFormattedText(PLAYERS_FOUND_OUT_OF_MAX, totalHealers - healerNeeds, totalHealers);
		entry.DamagersFound.Count:SetFormattedText(PLAYERS_FOUND_OUT_OF_MAX, totalDPS - dpsNeeds, totalDPS);

		local needMoreTanks, needMoreHealers, needMoreDPS = tankNeeds ~= 0, healerNeeds ~= 0, dpsNeeds ~= 0; 
		entry.TanksFound.RoleIcon:SetAtlas(GetIconForRole("TANK", needMoreTanks), TextureKitConstants.IgnoreAtlasSize);
		entry.HealersFound.RoleIcon:SetAtlas(GetIconForRole("HEALER", needMoreHealers), TextureKitConstants.IgnoreAtlasSize);
		entry.DamagersFound.RoleIcon:SetAtlas(GetIconForRole("DAMAGER", needMoreDPS), TextureKitConstants.IgnoreAtlasSize);

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
		local queuedElapsed = GetTime() - self.queuedTime;
		self.TimeInQueue:SetFormattedText(TIME_IN_QUEUE, (queuedElapsed >= 60) and SecondsToTime(queuedElapsed) or LESS_THAN_ONE_MINUTE);
		self.updateThrottle = 0.1;
	end
end

----------------------------------------------
------------QueueStatusDropdown---------------
----------------------------------------------
function QueueStatusDropdown_Show(source)
	MenuUtil.CreateContextMenu(source, function(owner, rootDescription)
	rootDescription:SetTag("MENU_QUEUE_STATUS_FRAME");

	--All LFG types
	for i=1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(i);
		if ( mode and submode ~= "noteleport" ) then
				QueueStatusDropdown_AddLFGButtons(rootDescription, i);
		end
	end

	--LFGList
	local isActive = C_LFGList.HasActiveEntryInfo();
	if ( isActive ) then
			QueueStatusDropdown_AddLFGListButtons(rootDescription);
	end

	local apps = C_LFGList.GetApplications();
	for i=1, #apps do
		local _, appStatus = C_LFGList.GetApplicationInfo(apps[i]);
		if ( appStatus == "applied" ) then
				QueueStatusDropdown_AddLFGListApplicationButtons(rootDescription, apps[i]);
		end
	end

	--PvP
	local inProgress, _, _, _, _, isBattleground = GetLFGRoleUpdate();
	if ( inProgress and isBattleground ) then
			QueueStatusDropdown_AddPVPRoleCheckButtons(rootDescription);
	end

	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch = GetBattlefieldStatus(i);
		if ( status and status ~= "none" ) then
				QueueStatusDropdown_AddBattlefieldButtons(rootDescription, i);
		end
	end

	if ( CanHearthAndResurrectFromArea() ) then
		local name = GetRealZoneText();
			rootDescription:CreateTitle("|cff19ff19"..name.."|r");

			rootDescription:CreateButton(format(LEAVE_ZONE, name), function()
				HearthAndResurrectFromArea();
			end);
	end
	end);
end

function QueueStatusDropdown_AddPVPRoleCheckButtons(description)
	local inProgress, _, _, _, _, isBattleground = GetLFGRoleUpdate();

	if ( inProgress and isBattleground ) then
		local name = GetLFGRoleUpdateBattlegroundInfo();
		description:CreateTitle(name);

		local button = description:CreateButton(QUEUED_STATUS_ROLE_CHECK_IN_PROGRESS);
		button:SetEnabled(false);
	end
end

local function LeaveQueueWithMatchReadyCheck(idx)
	local status, mapName, teamSize, registeredMatch, suspendedQueue, queueType = GetBattlefieldStatus(idx);
	if status == "confirm" and not PVPHelper_QueueAllowsLeaveQueueWithMatchReady(queueType) then
		UIErrorsFrame:AddExternalErrorMessage(PVP_MATCH_READY_ERROR);
	else
		local acceptPort = false;
		AcceptBattlefieldPort(idx, acceptPort);
	end
end

function QueueStatusDropdown_AddBattlefieldButtons(description, idx)
	local status, mapName, teamSize, registeredMatch, _, _, _, _, asGroup, _, _, isSoloQueue  = GetBattlefieldStatus(idx);

	local name = mapName;
	if ( name and status == "active" ) then
		name = "|cff19ff19"..name.."|r";
	end
	description:CreateTitle(name);

	if ( status == "queued" ) then
		local button = description:CreateButton(LEAVE_QUEUE, function()
			LeaveQueueWithMatchReadyCheck(idx);
		end);

		if IsInGroup() and not UnitIsGroupLeader("player") and not isSoloQueue then
			button:SetEnabled(false);
		end
	elseif ( status == "locked" ) then
		local button = description:CreateButton(LEAVE_BATTLEGROUND);
		button:SetEnabled(false);
	elseif ( status == "confirm" ) then
		description:CreateButton(ENTER_LFG, function()
			AcceptBattlefieldPort(idx, 1);
		end);

		if ( teamSize == 0 and queueType ~= "RATEDSHUFFLE") then
			description:CreateButton(LEAVE_QUEUE, function()
				LeaveQueueWithMatchReadyCheck(idx);
			end);
		end
	elseif ( status == "active" ) then
		local inArena = IsActiveBattlefieldArena();

		if ( not inArena or GetBattlefieldWinner() or C_Commentator.GetMode() > 0 or C_PvP.IsInBrawl() ) then
			description:CreateButton(TOGGLE_SCOREBOARD, function()
				TogglePVPScoreboardOrResults();
			end);
		end

		if ( not inArena ) then
			description:CreateButton(TOGGLE_BATTLEFIELD_MAP, function()
				ToggleBattlefieldMap();
			end);
		end

		local text;
		local disabled = false;
		if ( inArena and not C_PvP.IsInBrawl() ) then
			local button = description:CreateButton(SURRENDER_ARENA, function()
				ConfirmSurrenderArena();
			end);
			if not CanSurrenderArena() or C_PvP.IsSoloShuffle() then
				button:SetEnabled(false);
			end
			disabled = false;
			text = LEAVE_ARENA;
		else
			if ( C_PvP.IsSoloShuffle() ) then
				disabled = true;
			end
			if ( C_PvP.IsInBrawl() ) then
				text = LEAVE_LFD_BATTLEFIELD;
			else
				text = LEAVE_BATTLEGROUND;
			end
		end

		local leaveButton = description:CreateButton(text, function()
			ConfirmOrLeaveBattlefield();
		end);
		
		if disabled then
			leaveButton:SetEnabled(false);
		end
	end
end

function QueueStatusDropdown_AddLFGButtons(description, category)
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

	description:CreateTitle(name);

	if ( IsLFGModeActive(category) and IsPartyLFG() ) then
		local addExitOption = true;
		if ( IsAllowedToUserTeleport() ) then
			if ( IsInLFDBattlefield() ) then
				local _, instanceType = IsInInstance();
				if ( instanceType ~= "arena" and instanceType ~= "pvp" ) then
					description:CreateButton(ENTER_LFG, function()
						LFGTeleport(false);
					end);
					addExitOption = false;
				else
					description:CreateButton(TOGGLE_SCOREBOARD, function()
						TogglePVPScoreboardOrResults();
					end);
				end
			elseif ( IsInLFGDungeon() ) then
				description:CreateButton(TELEPORT_OUT_OF_DUNGEON, function()
					LFGTeleport(true);
				end);
			else
				description:CreateButton(TELEPORT_TO_DUNGEON, function()
					LFGTeleport(false);
				end);
			end
		end
		if ( addExitOption ) then
			local text = (category == LE_LFG_CATEGORY_WORLDPVP) and LEAVE_BATTLEGROUND or INSTANCE_PARTY_LEAVE;
			description:CreateButton(text, function()
				ConfirmOrLeaveLFGParty();
			end);
		end
	end

	if ( statuses.rolecheck ) then
		local button = description:CreateButton(QUEUED_STATUS_ROLE_CHECK_IN_PROGRESS);
		button:SetEnabled(false);
	end
	local preventLeaveQueue = IsLFGModeActive(category) and IsServerControlledBackfill();
	if ( ( statuses.queued or statuses.suspended ) and not preventLeaveQueue ) then
		local manyQueues = (category == LE_LFG_CATEGORY_RF) and (statuses.queued or 0) + (statuses.suspended or 0) > 1;
		local text = manyQueues and LEAVE_ALL_QUEUES or LEAVE_QUEUE;
		local button = description:CreateButton(text, function()
			LeaveLFG(category);
		end);

		if not (statuses["queued.empowered"] or statuses["suspended.empowered"]) then
			button:SetEnabled(false);
		end
	end
	if ( statuses.listed ) then
		local text = IsInGroup() and UNLIST_MY_GROUP or UNLIST_ME;
		local button = description:CreateButton(text, function()
			LeaveLFG(category);
		end);

		if not statuses["listed.empowered"] then
			button:SetEnabled(false);
		end
	end
	if ( statuses.proposal ) then
		if ( statuses["proposal.accepted"] ) then
			local button = description:CreateButton(QUEUED_STATUS_PROPOSAL);
			button:SetEnabled(false);
		elseif ( statuses["proposal.unaccepted"] ) then
			description:CreateButton(ENTER_LFG, function()
				AcceptProposal();
			end);

			description:CreateButton(LEAVE_QUEUE, function()
				RejectProposal(category);
			end);
		end
	end
end

function QueueStatusDropdown_AddLFGListButtons(description)
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	description:CreateTitle(activeEntryInfo.name);

	description:CreateButton(LFG_LIST_VIEW_GROUP, function()
		LFGListUtil_OpenBestWindow();
	end);

	local button = description:CreateButton(UNLIST_MY_GROUP, function()
		C_LFGList.RemoveListing();
	end);

	if not UnitIsGroupLeader("player") then
		button:SetEnabled(false);
	end
end

function QueueStatusDropdown_AddLFGListApplicationButtons(description, resultID)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	description:CreateTitle(searchResultInfo.name);

	local button = description:CreateButton(CANCEL_SIGN_UP, function()
		C_LFGList.CancelApplication(resultID);
	end);

	if IsInGroup() and not UnitIsGroupLeader("player") then
		button:SetEnabled(false);
	end
end

function QueueStatusDropdown_AcceptQueuedPVPMatch()
	if ( IsFalling() ) then
		UIErrorsFrame:AddMessage(ERR_NOT_WHILE_FALLING, 1.0, 0.1, 0.1, 1.0);
	elseif ( UnitAffectingCombat("player") ) then
		UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT, 1.0, 0.1, 0.1, 1.0);
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
			if not IsActiveBattlefieldArena() or GetBattlefieldWinner() or C_PvP.IsInBrawl() or C_PvP.IsSoloShuffle() then
				canShowScoreboard = true;
			end
			return true, canShowScoreboard;
		end
	end
end

function TogglePVPScoreboardOrResults()
	if IsAddOnLoaded("Blizzard_PVPMatch") then
		local isComplete = C_PvP.IsMatchComplete();
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
				local isActive = C_PvP.IsMatchActive();
				if isActive and (not C_PvP.IsMatchConsideredArena() or C_PvP.IsSoloShuffle()) then
					PVPMatchScoreboard:BeginShow();
				end
			end
		end
	end
end