-------------------------------------------------------
----------Constants
-------------------------------------------------------
MAX_LFG_LIST_APPLICATIONS = 5;
MAX_LFG_LIST_SEARCH_AUTOCOMPLETE_ENTRIES = 6;
MAX_LFG_LIST_GROUP_DROPDOWN_ENTRIES = 17;
LFG_LIST_DELISTED_FONT_COLOR = {r=0.3, g=0.3, b=0.3};
LFG_LIST_COMMENT_FONT_COLOR = {r=0.6, g=0.6, b=0.6};
GROUP_FINDER_CATEGORY_ID_DUNGEONS = 2;
GROUP_FINDER_CUSTOM_CATEGORY = 6;
GROUP_FINDER_ACTIVITY_CUSTOM_PVE = 16;

ACTIVITY_RETURN_VALUES = {
	fullName = 1,
	shortName = 2,
	categoryID = 3,
	groupID = 4,
	itemLevel = 5,
	filters = 6,
	minLevel = 7,
	maxPlayers = 8,
	displayType = 9,
	orderIndex = 10,
	useHonorLevel = 11,
};

--Hard-coded values. Should probably make these part of the DB, but it gets a little more complicated with the per-expansion textures
LFG_LIST_CATEGORY_TEXTURES = {
	[1] = "questing",
	[2] = "dungeons",
	[3] = "raids", --Prefix for expansion
	[4] = "arenas",
	[5] = "scenarios",
	[6] = "custom", -- Prefix for "-pve" or "-pvp"
	[7] = "skirmishes",
	[8] = "battlegrounds",
	[9] = "ratedbgs",
	[10] = "ashran",
	[111] = "islands",
	[113] = "torghast",
	[121] = "delves",
};

LFG_LIST_PER_EXPANSION_TEXTURES = {
	[0] = "classic",
	[1] = "bc",
	[2] = "wrath",
	[3] = "cataclysm",
	[4] = "mists",
	[5] = "warlords",
	[6] = "legion",
	[7] = "battleforazeroth",
	[8] = "shadowlands",
	[9] = "dragonflight",
	[10] = "war-within",
}

LFG_LIST_GROUP_DATA_ATLASES = {
	--Roles
	TANK = GetMicroIconForRole("TANK"),
	HEALER = GetMicroIconForRole("HEALER"),
	DAMAGER = GetMicroIconForRole("DAMAGER"),
};

local LFG_LIST_GROUP_DATA_ATLASES_BORDERLESS = {
	TANK = "groupfinder-icon-role-micro-tank",
	HEALER = "groupfinder-icon-role-micro-heal",
	DAMAGER = "groupfinder-icon-role-micro-dps",
}

local LFG_STRING_FROM_ENUM = {
	[Enum.LFGRole.Tank] = "TANK",
	[Enum.LFGRole.Healer] = "HEALER",
	[Enum.LFGRole.Damage] = "DAMAGER",
};

function GetLFGStringFromEnum(role)
	local stringName = LFG_STRING_FROM_ENUM[role];
	
	if not stringName then
		assertsafe("Bad role enum: " .. tostring(role));
		return "";
	end

	return _G[stringName];
end
	

--Fill out classes
for i=1, #CLASS_SORT_ORDER do
	LFG_LIST_GROUP_DATA_ATLASES[CLASS_SORT_ORDER[i]] = "groupfinder-icon-class-"..string.lower(CLASS_SORT_ORDER[i]);
end

LFG_LIST_GROUP_DATA_ROLE_ORDER = { "TANK", "HEALER", "DAMAGER" };
LFG_LIST_GROUP_DATA_CLASS_ORDER = CLASS_SORT_ORDER;

local FACTION_STRINGS = { [0] = FACTION_HORDE, [1] = FACTION_ALLIANCE};

StaticPopupDialogs["LFG_LIST_INVITING_CONVERT_TO_RAID"] = {
	text = LFG_LIST_CONVERT_TO_RAID_WARNING,
	button1 = INVITE,
	button2 = CANCEL,
	OnAccept = function(self, applicantID) C_PartyInfo.ConfirmConvertToRaid(); C_LFGList.InviteApplicant(applicantID) end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

local function ResolveCategoryFilters(categoryID, filters)
	-- Dungeons ONLY display recommended groups.
	if categoryID == GROUP_FINDER_CATEGORY_ID_DUNGEONS then
		return bit.band(bit.bnot(Enum.LFGListFilter.NotRecommended), bit.bor(filters, Enum.LFGListFilter.Recommended));
	end

	return filters;
end

local function GetFindGroupRestriction()
	if ( C_SocialRestrictions.IsSilenced() ) then
		return "SILENCED", RED_FONT_COLOR:WrapTextInColorCode(ERR_ACCOUNT_SILENCED);
	elseif ( C_SocialRestrictions.IsSquelched() ) then
		return "SQUELCHED", RED_FONT_COLOR:WrapTextInColorCode(ERR_USER_SQUELCHED);
	end

	return nil, nil;
end

local function GetStartGroupRestriction()
	return GetFindGroupRestriction();
end

-------------------------------------------------------
----------Base Frame
-------------------------------------------------------
LFG_LIST_EDIT_BOX_TAB_CATEGORIES = {};
function LFGListFrame_OnLoad(self)
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	self:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE");
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterEvent("LFG_LIST_ENTRY_CREATION_FAILED");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");
	self:RegisterEvent("LFG_LIST_SEARCH_FAILED");
	self:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED");
	self:RegisterEvent("LFG_LIST_APPLICANT_UPDATED");
	self:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS");
	self:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TIMEOUT");
	self:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED");
	self:RegisterEvent("UNIT_CONNECTION");
	self:RegisterEvent("LFG_GROUP_DELISTED_LEADERSHIP_CHANGE");

	for i=1, #LFG_LIST_ACTIVE_QUEUE_MESSAGE_EVENTS do
		self:RegisterEvent(LFG_LIST_ACTIVE_QUEUE_MESSAGE_EVENTS[i]);
	end
	LFGListFrame_SetBaseFilters(self, Enum.LFGListFilter.PvE);
	LFGListFrame_SetActivePanel(self, self.NothingAvailable);

	self.EventsInBackground = {
		LFG_LIST_SEARCH_FAILED = { self.SearchPanel };
	};
end

local function IsDeclined(appStatus)
	return appStatus == "declined" or appStatus == "declined_delisted" or appStatus =="declined_full";
end

function LFGListFrame_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_AVAILABILITY_UPDATE" or event == "TRIAL_STATUS_UPDATE") then
		LFGListFrame_FixPanelValid(self);
	elseif ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		local createdNew = ...;
		LFGListFrame_FixPanelValid(self);	--If our current panel isn't valid, change it.

		if ( C_LFGList.HasActiveEntryInfo() ) then
			self.EntryCreation.WorkingCover:Hide();
		else
			LFGListFrame_CheckPendingQuestIDSearch(self);
			LFGListFrame_CheckPendingScenarioIDSearch(self);
		end

		if ( createdNew ) then
			PlaySound(SOUNDKIT.PVP_ENTER_QUEUE);
		end
	elseif ( event == "LFG_LIST_ENTRY_CREATION_FAILED" ) then
		self.EntryCreation.WorkingCover:Hide();
	elseif ( event == "LFG_LIST_APPLICANT_LIST_UPDATED" ) then
		local hasNewPending, hasNewPendingWithData = ...;
		if ( hasNewPending and hasNewPendingWithData and LFGListUtil_IsEntryEmpowered() ) then
			local isLeader = UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME);
			local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
			local numPings = nil;
			if ( not isLeader ) then
				numPings = 6;
			end
			--Non-leaders don't get another ping until they open the panel or we reset the count to 0
			if ( isLeader or not self.stopAssistPings ) then
				if ( activeEntryInfo.autoAccept ) then
					--Check if we would be auto-inviting more people if we were in a raid
					if ( not IsInRaid(LE_PARTY_CATEGORY_HOME) and
					GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) + C_LFGList.GetNumInvitedApplicantMembers() + C_LFGList.GetNumPendingApplicantMembers() > (MAX_PARTY_MEMBERS+1) ) then
						if ( self.displayedAutoAcceptConvert ) then
							QueueStatusButton:SetGlowLock("lfglist-applicant", true, numPings);
							self.stopAssistPings = true;
						else
							self.displayedAutoAcceptConvert = true;
							StaticPopup_Show("LFG_LIST_AUTO_ACCEPT_CONVERT_TO_RAID");
						end
					end
				elseif ( not self:IsVisible() ) then
					QueueStatusButton:SetGlowLock("lfglist-applicant", true, numPings);
					self.stopAssistPings = true;
				end
			end
		end
	elseif ( event == "LFG_LIST_APPLICANT_UPDATED" ) then
		local numApps, numActiveApps = C_LFGList.GetNumApplicants();
		if ( numActiveApps == 0 ) then
			QueueStatusButton:SetGlowLock("lfglist-applicant", false);
			self.stopAssistPings = false;
		end
	elseif ( event == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS" ) then
		if ( UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
			StaticPopup_Show("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS");
		end
	elseif ( event == "LFG_LIST_ENTRY_EXPIRED_TIMEOUT" ) then
		if ( UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
			StaticPopup_Show("LFG_LIST_ENTRY_EXPIRED_TIMEOUT");
		end
	elseif ( event == "LFG_LIST_APPLICATION_STATUS_UPDATED" ) then
		local searchResultID, newStatus, oldStatus, kstringGroupName = ...;
		local chatMessage = LFGListFrame_GetChatMessageForSearchStatusChange(newStatus);
		if ( chatMessage ) then
			ChatFrame_DisplaySystemMessageInPrimary(chatMessage:format(kstringGroupName));
		end

		if IsDeclined(newStatus) then
			local searchResultInfo = C_LFGList.GetSearchResultInfo(searchResultID);
			self.declines = self.declines or {};
			self.declines[searchResultInfo.partyGUID] = newStatus;
			LFGListSearchPanel_UpdateResults(LFGListFrame.SearchPanel) --don't sort
		else
			LFGListSearchPanel_UpdateResultList(LFGListFrame.SearchPanel)
		end

		
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		if ( not IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
			self.displayedAutoAcceptConvert = false;
		end
	elseif ( event == "LFG_GROUP_DELISTED_LEADERSHIP_CHANGE") then
		local listingTitle, delistTime = ...;
		StaticPopup_Show("PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING", nil, nil, { listingTitle = listingTitle, delistTime = delistTime, });
	end

	--Dispatch the event to our currently active panel
	local onEvent = self.activePanel and self.activePanel:GetScript("OnEvent");
	if ( onEvent ) then
		onEvent(self.activePanel, event, ...);
	end

	--Dispatch the event to any panels that want the event in the background
	local bg = self.EventsInBackground[event];
	if ( bg ) then
		for i=1, #bg do
			if ( bg[i] ~= self.activePanel ) then
				bg[i]:GetScript("OnEvent")(bg[i], event, ...);
			end
		end
	end
end

function LFGListFrame_OnShow(self)
	LFGListFrame_FixPanelValid(self);
	C_LFGList.RequestAvailableActivities();
	self.stopAssistPings = false;
	QueueStatusButton:SetGlowLock("lfglist-applicant", false);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function LFGListFrame_OnHide(self)
	LFGListFrame_SetPendingQuestIDSearch(self, nil);
	LFGListFrame_SetPendingScenarioIDSearch(self, nil);
	LFGListEntryCreation_ClearAutoCreateMode(self.EntryCreation);
	self.SearchPanel.shouldAlwaysShowCreateGroupButton = nil;
end

function LFGListFrame_GetChatMessageForSearchStatusChange(newStatus)
	if ( newStatus == "declined" ) then
		return LFG_LIST_APP_DECLINED_MESSAGE;
	elseif ( newStatus == "declined_full" ) then
		return LFG_LIST_APP_DECLINED_FULL_MESSAGE;
	elseif ( newStatus == "declined_delisted" ) then
		return LFG_LIST_APP_DECLINED_DELISTED_MESSAGE;
	elseif ( newStatus == "timedout" ) then
		return LFG_LIST_APP_TIMED_OUT_MESSAGE;
	end
end

function LFGListFrame_SetActivePanel(self, panel)
	if ( self.activePanel ) then
		self.activePanel:Hide();
	end
	self.activePanel = panel;
	self.activePanel:Show();
end

function LFGListFrame_IsPanelValid(self, panel)
	local listed = C_LFGList.HasActiveEntryInfo();

	--If we're listed, make sure we're either viewing applicants or editing our group
	if ( listed and panel ~= self.ApplicationViewer and not (panel == self.EntryCreation and LFGListEntryCreation_IsEditMode(self.EntryCreation)) ) then
		return false;
	end

	--If we're not listed, we can't be viewing applicants or editing our group
	if ( not listed and (panel == self.ApplicationViewer or
			(panel == self.EntryCreation and LFGListEntryCreation_IsEditMode(self.EntryCreation)) ) ) then
		return false;
	end

	--Make sure we aren't creating a new entry with different baseFilters
	if ( panel == self.EntryCreation ) then
		if ( not LFGListEntryCreation_IsEditMode(self.EntryCreation) and self.baseFilters ~= self.EntryCreation.baseFilters ) then
			return false;
		end
	end

	--Make sure we aren't searching with different baseFilters
	if ( panel == self.SearchPanel ) then
		if ( self.baseFilters ~= self.SearchPanel.preferredFilters ) then
			return false;
		end
	end

	--If we're a trial account, we can only see the NothingAvailable and ApplicationViewer
	if ( IsRestrictedAccount() ) then
		if ( panel ~= self.NothingAvailable and panel ~= self.ApplicationViewer ) then
			return false;
		end
	end

	--If we don't have any available activities, say so
	if ( #C_LFGList.GetAvailableCategories(self.baseFilters) == 0 ) then
		if ( panel == self.CategorySelection ) then
			return false;
		end
	else
		if ( panel == self.NothingAvailable and not IsRestrictedAccount() ) then
			return false;
		end
	end

	return true;
end

function LFGListFrame_GetBestPanel(self)
	local listed = C_LFGList.HasActiveEntryInfo();

	if ( listed ) then
		return self.ApplicationViewer;
	elseif ( IsRestrictedAccount() ) then
		return self.NothingAvailable;
	elseif ( #C_LFGList.GetAvailableCategories(self.baseFilters) == 0 ) then
		return self.NothingAvailable;
	else
		return self.CategorySelection;
	end
end

function LFGListFrame_FixPanelValid(self)
	if ( not LFGListFrame_IsPanelValid(self, self.activePanel) ) then
		LFGListFrame_SetActivePanel(self, LFGListFrame_GetBestPanel(self));
	end
end

function LFGListFrame_SetBaseFilters(self, filters)
	self.baseFilters = filters;

	--If we need to change panels, do so
	LFGListFrame_FixPanelValid(self);

	--Update the current panel
	if ( self.activePanel and self.activePanel.updateAll ) then
		self.activePanel.updateAll(self.activePanel);
	end
end

function LFGListFrame_CheckPendingQuestIDSearch(self)
	local questID = LFGListFrame_GetPendingQuestIDSearch(self);
	if questID and not C_LFGList.HasActiveEntryInfo() then
		LFGListFrame_SetPendingQuestIDSearch(self, nil);

		if issecure() then
			LFGListFrame_BeginFindQuestGroup(self, questID);
		else
			StaticPopup_Show("PREMADE_GROUP_INSECURE_SEARCH", QuestUtils_GetQuestName(questID), nil, questID);
		end
	end
end

function LFGListFrame_CheckPendingScenarioIDSearch(self)
	local scenarioID = LFGListFrame_GetPendingScenarioIDSearch(self);
	if scenarioID and not C_LFGList.HasActiveEntryInfo() then
		LFGListFrame_SetPendingScenarioIDSearch(self, nil);

		if issecure() then
			LFGListFrame_BeginFindScenarioGroup(self, scenarioID);
		else
			StaticPopup_Show("PREMADE_SCENARIO_GROUP_INSECURE_SEARCH", select(1, C_Scenario.GetInfo()), nil, scenarioID);
		end
	end
end

function LFGListFrame_GetPendingScenarioIDSearch(self)
	return self.pendingScenarioIDSearch;
end

function LFGListFrame_SetPendingScenarioIDSearch(self, scenarioID)
	self.pendingScenarioIDSearch = scenarioID;
end

function LFGListFrame_GetPendingQuestIDSearch(self)
	return self.pendingQuestIDSearch;
end

function LFGListFrame_SetPendingQuestIDSearch(self, questID)
	self.pendingQuestIDSearch = questID;
end

function LFGListFrame_BeginFindQuestGroup(self, questID, shouldShowCreateGroupButton)
	local activityID, categoryID, filters, questName = LFGListUtil_GetQuestCategoryData(questID);

	if not activityID then
		return;
	end

	if C_LFGList.HasActiveEntryInfo() then
		if LFGListUtil_CanListGroup() then
			C_LFGList.RemoveListing();
			LFGListFrame_SetPendingQuestIDSearch(self, questID);
		end
		return;
	end

	self.SearchPanel.shouldAlwaysShowCreateGroupButton = shouldShowCreateGroupButton;

	PVEFrame_ShowFrame("GroupFinderFrame", LFGListPVEStub);

	local panel = self.CategorySelection;
	LFGListCategorySelection_SelectCategory(panel, categoryID, filters);
	LFGListCategorySelection_StartFindGroup(panel, questID);
	LFGListEntryCreation_SetAutoCreateMode(panel:GetParent().EntryCreation, "quest", activityID, questID);
end

function LFGListFrame_BeginFindScenarioGroup(self, scenarioID, shouldShowCreateGroupButton)

	if C_LFGList.HasActiveEntryInfo() then
		if LFGListUtil_CanListGroup() then
			C_LFGList.RemoveListing();
			LFGListFrame_SetPendingScenarioIDSearch(self, scenarioID);
		end
		return;
	end

	self.SearchPanel.shouldAlwaysShowCreateGroupButton = shouldShowCreateGroupButton;

	PVEFrame_ShowFrame("GroupFinderFrame", LFGListPVEStub);

	local panel = self.CategorySelection;
	LFGListCategorySelection_SelectCategory(panel, GROUP_FINDER_CUSTOM_CATEGORY, nil);
	LFGListCategorySelection_StartFindScenarioGroup(panel, scenarioID);
	LFGListEntryCreation_SetAutoCreateMode(panel:GetParent().EntryCreation, "scenario", GROUP_FINDER_ACTIVITY_CUSTOM_PVE, scenarioID);
end

function LFGListCategorySelection_StartFindScenarioGroup(self, scenarioID)
	local baseFilters = self:GetParent().baseFilters;
	local searchPanel = self:GetParent().SearchPanel;
	LFGListSearchPanel_Clear(searchPanel);
	if scenarioID then
		C_LFGList.SetSearchToScenarioID(scenarioID);
	end
	LFGListSearchPanel_SetCategory(searchPanel, GROUP_FINDER_CUSTOM_CATEGORY, self.selectedFilters, baseFilters);
	LFGListSearchPanel_DoSearch(searchPanel);
	LFGListFrame_SetActivePanel(self:GetParent(), searchPanel);
end

-------------------------------------------------------
----------Nothing available frame
-------------------------------------------------------
function LFGListNothingAvailable_OnEvent(self, event, ...)
	--Note: events are dispatched from the base frame. Add RegisterEvent there.
	if ( event == "LFG_LIST_AVAILABILITY_UPDATE" ) then
		LFGListNothingAvailable_Update(self);
	end
end

function LFGListNothingAvailable_Update(self)
	if ( IsRestrictedAccount() ) then
		self.Label:SetText(ERR_RESTRICTED_ACCOUNT_LFG_LIST_TRIAL);
	elseif ( C_LFGList.HasActivityList() ) then
		self.Label:SetText(NO_LFG_LIST_AVAILABLE);
	else
		self.Label:SetText(LFG_LIST_LOADING);
	end
end

-------------------------------------------------------
----------Category selection
-------------------------------------------------------
function LFGListCategorySelection_OnLoad(self)
	LFGListCategorySelection_UpdateNavButtons(self);
end

function LFGListCategorySelection_OnEvent(self, event, ...)
	--Note: events are dispatched from the base frame. Add RegisterEvent there.
	if ( event == "LFG_LIST_AVAILABILITY_UPDATE" ) then
		LFGListCategorySelection_UpdateCategoryButtons(self);
	end

	if ( tContains(LFG_LIST_ACTIVE_QUEUE_MESSAGE_EVENTS, event) ) then
		LFGListCategorySelection_UpdateNavButtons(self);
	end
end

function LFGListCategorySelection_OnShow(self)
	LFGListCategorySelection_UpdateCategoryButtons(self);
	LFGListCategorySelection_UpdateNavButtons(self);
end

function LFGListCategorySelection_UpdateCategoryButtons(self)
	local baseFilters = self:GetParent().baseFilters;
	local categories = C_LFGList.GetAvailableCategories(baseFilters);

	local nextBtn = 1;
	local hasSelected = false;

	--Update category buttons
	for i=1, #categories do
		local isSelected = false;
		local categoryID = categories[i];
		local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID);

		if categoryInfo.separateRecommended then
			nextBtn, isSelected = LFGListCategorySelection_AddButton(self, nextBtn, categoryID, Enum.LFGListFilter.Recommended);
			hasSelected = hasSelected or isSelected;
			nextBtn, isSelected = LFGListCategorySelection_AddButton(self, nextBtn, categoryID, Enum.LFGListFilter.NotRecommended);
		else
			nextBtn, isSelected = LFGListCategorySelection_AddButton(self, nextBtn, categoryID, 0);
		end

		hasSelected = hasSelected or isSelected;
	end

	--Hide any extra buttons
	for i=nextBtn, #self.CategoryButtons do
		self.CategoryButtons[i]:Hide();
	end

	--If the selected item isn't in the list, deselect it
	if ( self.selectedCategory and not hasSelected ) then
		LFGListCategorySelection_SelectCategory(self, nil, nil);
	end
end

function LFGListCategorySelection_AddButton(self, btnIndex, categoryID, filters)
	--Check that we have activities with this filter
	local baseFilters = self:GetParent().baseFilters;
	local allFilters = bit.bor(baseFilters, filters);

	if ( filters ~= 0 and #C_LFGList.GetAvailableActivities(categoryID, nil, allFilters) == 0) then
		return btnIndex, false;
	end

	local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID);

	local button = self.CategoryButtons[btnIndex];
	if ( not button ) then
		self.CategoryButtons[btnIndex] = CreateFrame("BUTTON", nil, self, "LFGListCategoryTemplate");
		self.CategoryButtons[btnIndex]:SetPoint("TOP", self.CategoryButtons[btnIndex - 1], "BOTTOM", 0, -3);
		button = self.CategoryButtons[btnIndex];
	end

	button:SetText(LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, filters, true));
	button.categoryID = categoryID;
	button.filters = filters;

	local atlasName = nil;
	if ( bit.band(allFilters, Enum.LFGListFilter.Recommended) ~= 0 ) then
		atlasName = "groupfinder-button-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "raids").."-"..(LFG_LIST_PER_EXPANSION_TEXTURES[LFGListUtil_GetCurrentExpansion()] or "classic");
	elseif ( bit.band(allFilters, Enum.LFGListFilter.NotRecommended) ~= 0 ) then
		atlasName = "groupfinder-button-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "raids").."-"..(LFG_LIST_PER_EXPANSION_TEXTURES[math.max(0,LFGListUtil_GetCurrentExpansion() - 1)] or "classic");
	else
		atlasName = "groupfinder-button-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "questing");
	end

	local suffix = "";
	if ( bit.band(allFilters, Enum.LFGListFilter.PvE) ~= 0 ) then
		suffix = "-pve";
	elseif ( bit.band(allFilters, Enum.LFGListFilter.PvP) ~= 0 ) then
		suffix = "-pvp";
	end

	--Try with the suffix and then without it
	if not CheckSetAtlas(button.Icon, atlasName..suffix) then
		CheckSetAtlas(button.Icon, atlasName);
	end

	local selected = self.selectedCategory == categoryID and self.selectedFilters == filters;
	button.SelectedTexture:SetShown(selected);
	button:Show();

	return btnIndex + 1, selected;
end

function LFGListCategorySelection_SelectCategory(self, categoryID, filters)
	self.selectedCategory = categoryID;
	self.selectedFilters = filters;
	LFGListCategorySelection_UpdateCategoryButtons(self);
	LFGListCategorySelection_UpdateNavButtons(self);
end

function LFGListCategorySelection_UpdateNavButtons(self)
	local findEnabled, startEnabled = true, true;
	self.FindGroupButton.tooltip = nil;
	self.StartGroupButton.tooltip = nil;

	--Check if the user needs to select a category
	if ( not self.selectedCategory ) then
		findEnabled = false;
		self.FindGroupButton.tooltip = LFG_LIST_SELECT_A_CATEGORY;
		startEnabled = false;
		self.StartGroupButton.tooltip = LFG_LIST_SELECT_A_CATEGORY;
	end

	--Check if the user can't start a group due to not being a leader
	if ( IsInGroup(LE_PARTY_CATEGORY_HOME) and not UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
		startEnabled = false;
		self.StartGroupButton.tooltip = LFG_LIST_NOT_LEADER;
	end

	--Check if the player is currently in some incompatible queue
	local messageStart = LFGListUtil_GetActiveQueueMessage(false);
	if ( messageStart ) then
		startEnabled = false;
		self.StartGroupButton.tooltip = messageStart;
	end

	local findError, findErrorText = GetFindGroupRestriction();
	if ( findError ~= nil ) then
		findEnabled = false;
		self.FindGroupButton.tooltip = findErrorText;
	end

	local startError, startErrorText = GetStartGroupRestriction();
	if ( startError ~= nil ) then
		startEnabled = false;
		self.StartGroupButton.tooltip = startErrorText;
	end

	self.FindGroupButton:SetEnabled(findEnabled);
	self.StartGroupButton:SetEnabled(startEnabled);
end

function LFGListCategorySelectionStartGroupButton_OnClick(self)
	local panel = self:GetParent();
	if ( not panel.selectedCategory ) then
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local baseFilters = panel:GetParent().baseFilters;

	local entryCreation = panel:GetParent().EntryCreation;

	LFGListEntryCreation_Show(entryCreation, baseFilters, panel.selectedCategory, panel.selectedFilters);
end

function LFGListCategorySelectionFindGroupButton_OnClick(self)
	local panel = self:GetParent();
	if ( not panel.selectedCategory ) then
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	LFGListCategorySelection_StartFindGroup(panel);
end

function LFGListCategorySelection_StartFindGroup(self, questID)
	local baseFilters = self:GetParent().baseFilters;
	local searchPanel = self:GetParent().SearchPanel;
	LFGListSearchPanel_Clear(searchPanel);
	if questID then
		C_LFGList.SetSearchToQuestID(questID);
	end
	LFGListSearchPanel_SetCategory(searchPanel, self.selectedCategory, self.selectedFilters, baseFilters);
	LFGListSearchPanel_DoSearch(searchPanel);
	LFGListFrame_SetActivePanel(self:GetParent(), searchPanel);
end

--The individual category buttons
function LFGListCategorySelectionButton_OnClick(self)
	local panel = self:GetParent();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	LFGListCategorySelection_SelectCategory(panel, self.categoryID, self.filters);
	LFGListEntryCreation_ClearAutoCreateMode(panel:GetParent().EntryCreation);
end

-------------------------------------------------------
----------List Entry Creation
-------------------------------------------------------
function LFGListEntryCreation_OnLoad(self)
	self.Name.Instructions:SetText(LFG_LIST_ENTER_NAME);
	self.Description.EditBox:SetScript("OnEnterPressed", nop);

	self.GroupDropdown:SetWidth(141);

	-- Group dropdown has a "More" option that requires us to set the text
	-- manually if the option is not in the selected list.
	self.GroupDropdown:SetSelectionText(function(currentSelections)
		-- overrideName assigned when an option is picked from the dialog.
		if self.GroupDropdown.overrideName then
			return self.GroupDropdown.overrideName;
		end

		local currentSelection = currentSelections[1];
		if currentSelection then
			return MenuUtil.GetElementText(currentSelection);
		end

		return nil;
	end);

	-- ActivityDropdown dropdown has a "More" option that requires us to set the text
	-- manually if the option is not in the selected list.
	self.ActivityDropdown:SetSelectionText(function(currentSelections)
		-- overrideName assigned when an option is picked from the dialog.
		if self.ActivityDropdown.overrideName then
			return self.ActivityDropdown.overrideName;
		end

		local currentSelection = currentSelections[1];
		if currentSelection then
			return MenuUtil.GetElementText(currentSelection);
		end

		return nil;
	end);

	self.ActivityDropdown:SetWidth(138);
	self.PlayStyleDropdown:SetWidth(144);

	LFGListEntryCreation_SetBaseFilters(self, 0);
end

function LFGListEntryCreation_SetupGroupDropdown(self)
	self.GroupDropdown.overrideName = nil;
	self.GroupDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_LFG_FRAME_GROUP");

		if ( not self.selectedCategory ) then
			--We don't have a category, so we can't fill out groups.
			return;
		end

		local useMore = false;

		--Start out displaying everything
		local groups = C_LFGList.GetAvailableActivityGroups(self.selectedCategory, bit.bor(self.baseFilters, self.selectedFilters));
		local activities = C_LFGList.GetAvailableActivities(self.selectedCategory, 0, bit.bor(self.baseFilters, self.selectedFilters));
		if ( self.selectedFilters == 0 ) then
			--We don't bother filtering if we have less than 5 items anyway
			if ( #groups + #activities > 5 ) then
				--Try just displaying the recommended
				local filters = bit.bor(self.selectedFilters, self.baseFilters, Enum.LFGListFilter.Recommended);
				local recGroups = C_LFGList.GetAvailableActivityGroups(self.selectedCategory, filters);
				local recActivities = C_LFGList.GetAvailableActivities(self.selectedCategory, 0, filters);

				--If we have some recommended, just display those
				if ( #recGroups + #recActivities > 0 ) then
					--If we still have just as many, we don't need to display more
					useMore = #recGroups ~= #groups or #recActivities ~= #activities;
					groups = recGroups;
					activities = recActivities;
				end
			end
		end

		local groupOrder = groups[1] and select(2, C_LFGList.GetActivityGroupInfo(groups[1]));
		local firstActivityInfo = activities[1] and C_LFGList.GetActivityInfoTable(activities[1]);
		local activityOrder = firstActivityInfo and firstActivityInfo.orderIndex;
		local groupIndex, activityIndex = 1, 1;

		local function IsActivitySelected(activityID)
			return self.selectedActivity == activityID;
		end
		
		local function SetActivitySelected(activityID)
			LFGListEntryCreation_Select(self, nil, nil, nil, activityID);
		end

		local function IsGroupSelected(groupID)
			return self.selectedGroup == groupID;
		end
		
		local function SetGroupSelected(groupID)
			LFGListEntryCreation_Select(self, self.selectedFilters, self.selectedCategory, groupID);
		end

		--Start merging
		for i=1, MAX_LFG_LIST_GROUP_DROPDOWN_ENTRIES do
			if ( not groupOrder and not activityOrder ) then
				break;
			end

			if ( activityOrder and (not groupOrder or activityOrder < groupOrder) ) then
				local activityID = activities[activityIndex];
				local activityInfo = activityID and C_LFGList.GetActivityInfoTable(activityID);
				local name = activityInfo and activityInfo.shortName;
				rootDescription:CreateRadio(name, IsActivitySelected, SetActivitySelected, activityID);

				activityIndex = activityIndex + 1;
				local nextActivityInfo =  activities[activityIndex] and C_LFGList.GetActivityInfoTable(activities[activityIndex]);
				activityOrder = nextActivityInfo and nextActivityInfo.orderIndex;
			else
				local groupID = groups[groupIndex];
				local name = C_LFGList.GetActivityGroupInfo(groupID);
				rootDescription:CreateRadio(name, IsGroupSelected, SetGroupSelected, groupID);

				groupIndex = groupIndex + 1;
				groupOrder = groups[groupIndex] and select(2, C_LFGList.GetActivityGroupInfo(groups[groupIndex]));
			end
		end

		if ( #activities + #groups > MAX_LFG_LIST_GROUP_DROPDOWN_ENTRIES ) then
			useMore = true;
		end

		if useMore then
			rootDescription:CreateButton(LFG_LIST_MORE, function()
				LFGListEntryCreationActivityFinder_Show(self.ActivityFinder, self.selectedCategory, nil, bit.bor(self.baseFilters, self.selectedFilters));
			end);
		end
	end);
end

function LFGListEntryCreation_SetupActivityDropdown(self)
	self.ActivityDropdown.overrideName = nil;
	self.ActivityDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_LFG_FRAME_GROUP_ACTIVITY");

		local useMore = self.selectedFilters == 0;

		local filters = bit.bor(self.baseFilters, self.selectedFilters);

		--Start out displaying everything
		local activities = C_LFGList.GetAvailableActivities(self.selectedCategory, self.selectedGroup, filters);

		--If we're displaying more than 5, see if we can just display recommended
		if ( useMore ) then
			if ( #activities > 5 ) then
				filters = bit.bor(filters, Enum.LFGListFilter.Recommended);
				local recActivities = C_LFGList.GetAvailableActivities(self.selectedCategory, self.selectedGroup, filters);

				useMore = #recActivities ~= #activities;
				if ( #recActivities > 0 ) then
					activities = recActivities;
				else
					--Just display up to 5 non-recommended activities
					for i=#activities, 5, -1 do
						activities[i] = nil;
					end
				end
			else
				useMore = false;
			end
		end
		
		local function IsActivitySelected(activityID)
			return self.selectedActivity == activityID;
		end
		
		local function SetActivitySelected(activityID)
			LFGListEntryCreation_Select(self, nil, nil, nil, activityID);
		end

		for i=1, #activities do
			local activityID = activities[i];
			local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
			local shortName = activityInfo and activityInfo.shortName;
			rootDescription:CreateRadio(shortName, IsActivitySelected, SetActivitySelected, activityID);
		end

		if useMore then
			rootDescription:CreateButton(LFG_LIST_MORE, function()
				LFGListEntryCreationActivityFinder_Show(self.ActivityFinder, self.selectedCategory, self.selectedGroup, bit.bor(self.baseFilters, self.selectedFilters));
			end);
		end
	end);
end

function LFGListEntryCreation_SetupPlayStyleDropdown(self)
	local activityInfo = C_LFGList.GetActivityInfoTable(self.selectedActivity);
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(self.selectedCategory);
	local shouldShowPlayStyleDropdown = categoryInfo.showPlaystyleDropdown and (activityInfo.isMythicPlusActivity or activityInfo.isRatedPvpActivity or activityInfo.isCurrentRaidActivity or activityInfo.isMythicActivity);
	self.PlayStyleDropdown:SetShown(shouldShowPlayStyleDropdown);
	self.PlayStyleLabel:SetShown(shouldShowPlayStyleDropdown);
	
	local function IsSelected(playstyle)
		return self.selectedPlaystyle == playstyle;
	end
	
	local function SetSelected(playstyle)
		LFGListEntryCreation_OnPlayStyleSelectedInternal(self, playstyle);
	end

	local function CreateRadio(rootDescription, activityInfo, playstyle)
		local text = C_LFGList.GetPlaystyleString(playstyle, activityInfo);
		rootDescription:CreateRadio(text, IsSelected, SetSelected, playstyle);
	end

	LFGListEntryCreation_SetPlaystyleLabelTextFromActivityInfo(self, activityInfo);
	self.PlayStyleDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_LFG_FRAME_GROUP_PLAYSTYLE");

		if(not self.selectedActivity or not self.selectedCategory) then
			return;
		end
		local activityInfo = C_LFGList.GetActivityInfoTable(self.selectedActivity);
		CreateRadio(rootDescription, activityInfo, Enum.LFGEntryPlaystyle.Standard);
		CreateRadio(rootDescription, activityInfo, Enum.LFGEntryPlaystyle.Casual);
		CreateRadio(rootDescription, activityInfo, Enum.LFGEntryPlaystyle.Hardcore);
	end);
end

function LFGListEntryCreation_OnEvent(self, event, ...)
	if ( event == "GROUP_ROSTER_UPDATE" ) then
		LFGListEntryCreation_UpdateValidState(self);
	elseif ( tContains(LFG_LIST_ACTIVE_QUEUE_MESSAGE_EVENTS, event) ) then
		LFGListEntryCreation_UpdateValidState(self);
	end
end

function LFGListEntryCreation_OnShow(self)
	LFGListEntryCreation_UpdateValidState(self);
	LFGListEntryCreation_SetupGroupDropdown(self);
	LFGListEntryCreation_SetupActivityDropdown(self);
	LFGListEntryCreation_SetupPlayStyleDropdown(self);
end

function LFGListEntryCreation_Show(self, baseFilters, selectedCategory, selectedFilters)
	--If this was what the player selected last time, just leave it filled out with the same info.
	--Also don't save it for categories that try to set it to the current area.
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(selectedCategory);
	local keepOldData = not categoryInfo.preferCurrentArea and self.selectedCategory == selectedCategory and baseFilters == self.baseFilters and self.selectedFilters == selectedFilters;
	LFGListEntryCreation_SetBaseFilters(self, baseFilters);
	if ( not keepOldData ) then
		LFGListEntryCreation_Clear(self);
		LFGListEntryCreation_Select(self, selectedFilters, selectedCategory);
	end
	LFGListEntryCreation_OnPlayStyleSelected(self, Enum.LFGEntryPlaystyle.Standard);
	LFGListEntryCreation_SetEditMode(self, false);

	LFGListEntryCreation_UpdateValidState(self);

	LFGListFrame_SetActivePanel(self:GetParent(), self);
	self.Name:SetFocus();
	self.Label:SetText(categoryInfo.name);

	LFGListEntryCreation_CheckAutoCreate(self);
end

function LFGListEntryCreation_Clear(self)
	--Clear selections
	self.selectedGroup = nil;
	self.selectedActivity = nil;
	self.selectedFilters = nil;
	self.selectedCategory = nil;
	self.selectedPlaystyle = nil;

	--Reset widgets
	C_LFGList.ClearCreationTextFields();
	self.ItemLevel.CheckButton:SetChecked(false);
	self.ItemLevel.EditBox:SetText("");
	self.PvpItemLevel.CheckButton:SetChecked(false);
	self.PvpItemLevel.EditBox:SetText("");
	self.PVPRating.CheckButton:SetChecked(false);
	self.PVPRating.EditBox:SetText("");
	self.MythicPlusRating.CheckButton:SetChecked(false);
	self.MythicPlusRating.EditBox:SetText("");
	self.VoiceChat.CheckButton:SetChecked(false);
	--self.VoiceChat.EditBox:SetText(""); --Cleared in ClearCreationTextFields
	self.PrivateGroup.CheckButton:SetChecked(false);
	self.CrossFactionGroup.CheckButton:SetChecked(false);

	self.ActivityFinder:Hide();
end

function LFGListEntryCreation_ClearFocus(self)
	self.Name:ClearFocus();
	self.ItemLevel.EditBox:ClearFocus();
	self.PvpItemLevel.EditBox:ClearFocus();
	self.MythicPlusRating.EditBox:ClearFocus();
	self.PVPRating.EditBox:ClearFocus();
	self.VoiceChat.EditBox:ClearFocus();
	self.Description.EditBox:ClearFocus();
end

--This function accepts any or all of categoryID, groupId, and activityID
function LFGListEntryCreation_Select(self, filters, categoryID, groupID, activityID)
	filters, categoryID, groupID, activityID = LFGListUtil_AugmentWithBest(bit.bor(self.baseFilters or 0, filters or 0), categoryID, groupID, activityID);
	self.selectedCategory = categoryID;
	self.selectedGroup = groupID;
	self.selectedActivity = activityID;
	self.selectedFilters = filters;
	
	--Update the category dropdown
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID);

	--Update the activity dropdown
	local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
	if(not activityInfo) then
		return;
	end

	--Update the group dropdown. If the group dropdown is showing an activity, hide the activity dropdown
	local groupName = C_LFGList.GetActivityGroupInfo(groupID);
	self.ActivityDropdown.overrideName = activityInfo and activityInfo.shortName;
	self.GroupDropdown.overrideName = groupName or activityInfo.shortName;

	self.ActivityDropdown:SetShown(groupName and not categoryInfo.autoChooseActivity);
	self.ActivityDropdown:GenerateMenu();

	self.GroupDropdown:SetShown(not categoryInfo.autoChooseActivity);
	self.GroupDropdown:GenerateMenu();

	local shouldShowPlayStyleDropdown = (categoryInfo.showPlaystyleDropdown) and (activityInfo.isMythicPlusActivity or activityInfo.isRatedPvpActivity or activityInfo.isCurrentRaidActivity or activityInfo.isMythicActivity);
	local shouldShowCrossFactionToggle = (categoryInfo.allowCrossFaction);
	local shouldDisableCrossFactionToggle = (categoryInfo.allowCrossFaction) and not (activityInfo.allowCrossFaction);
	if(shouldShowPlayStyleDropdown) then
		LFGListEntryCreation_OnPlayStyleSelected(self, self.selectedPlaystyle or Enum.LFGEntryPlaystyle.Standard);
	end

	self.PlayStyleDropdown:SetShown(shouldShowPlayStyleDropdown);
	self.PlayStyleLabel:SetShown(shouldShowPlayStyleDropdown);

	if(not shouldShowPlayStyleDropdown)  then
		self.selectedPlaystyle = nil
	end
	local _, localizedFaction = UnitFactionGroup("player");
	self.CrossFactionGroup.Label:SetText(LFG_LIST_CROSS_FACTION:format(localizedFaction));
	self.CrossFactionGroup.tooltip = LFG_LIST_CROSS_FACTION_TOOLTIP:format(localizedFaction);
	self.CrossFactionGroup.disableTooltip = LFG_LIST_CROSS_FACTION_DISABLE_TOOLTIP:format(localizedFaction);
	self.CrossFactionGroup:SetShown(shouldShowCrossFactionToggle);
	self.CrossFactionGroup.CheckButton:SetEnabled(not shouldDisableCrossFactionToggle);
	self.CrossFactionGroup.CheckButton:SetChecked(shouldDisableCrossFactionToggle);
	if(shouldDisableCrossFactionToggle) then
		self.CrossFactionGroup.Label:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	else
		self.CrossFactionGroup.Label:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end

	self.MythicPlusRating:SetShown(activityInfo.isMythicPlusActivity);
	self.PVPRating:SetShown(activityInfo.isRatedPvpActivity);

	--Update the recommended item level box
	if ( activityInfo.ilvlSuggestion ~= 0 ) then
		self.ItemLevel.EditBox.Instructions:SetFormattedText(LFG_LIST_RECOMMENDED_ILVL, activityInfo.ilvlSuggestion);
	else
		self.ItemLevel.EditBox.Instructions:SetText(LFG_LIST_ITEM_LEVEL_INSTR_SHORT);
	end

	self.NameLabel:ClearAllPoints();
	if (not self.ActivityDropdown:IsShown() and not self.GroupDropdown:IsShown()) then
		self.NameLabel:SetPoint("TOPLEFT", 20, -82);
	else
		self.NameLabel:SetPoint("TOPLEFT", 20, -120);
	end

	self.ItemLevel:ClearAllPoints();
	self.PvpItemLevel:ClearAllPoints();

	self.ItemLevel:SetShown(not activityInfo.isPvpActivity);
	self.PvpItemLevel:SetShown(activityInfo.isPvpActivity);

	if (self.MythicPlusRating:IsShown()) then
		self.ItemLevel:SetPoint("TOPLEFT", self.MythicPlusRating, "BOTTOMLEFT", 0, -3);
		self.PvpItemLevel:SetPoint("TOPLEFT", self.MythicPlusRating, "BOTTOMLEFT", 0, -3);
	elseif (self.PVPRating:IsShown()) then
		self.ItemLevel:SetPoint("TOPLEFT", self.PVPRating, "BOTTOMLEFT", 0, -3);
		self.PvpItemLevel:SetPoint("TOPLEFT", self.PVPRating, "BOTTOMLEFT", 0, -3);
	elseif(self.PlayStyleDropdown:IsShown()) then
		self.ItemLevel:SetPoint("TOPLEFT", self.PlayStyleLabel, "BOTTOMLEFT", -1, -15);
		self.PvpItemLevel:SetPoint("TOPLEFT", self.PlayStyleLabel, "BOTTOMLEFT", -1, -15);
	else
		self.ItemLevel:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", -6, -19);
		self.PvpItemLevel:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", -6, -19);
	end
	if(self.ItemLevel:IsShown()) then
		LFGListRequirement_Validate(self.ItemLevel, self.ItemLevel.EditBox:GetText());
	else
		LFGListRequirement_Validate(self.PvpItemLevel, self.PvpItemLevel.EditBox:GetText());
	end

	LFGListEntryCreation_SetPlaystyleLabelTextFromActivityInfo(self, activityInfo);
	LFGListEntryCreation_UpdateValidState(self);
	LFGListEntryCreation_SetTitleFromActivityInfo(self);
end

function LFGListEntryCreation_SetPlaystyleLabelTextFromActivityInfo(self, activityInfo)
	if(not activityInfo) then
		return;
	end
	local labelText;
	if(activityInfo.isRatedPvpActivity) then
		labelText = LFG_PLAYSTYLE_LABEL_PVP
	elseif (activityInfo.isMythicPlusActivity) then
		labelText = LFG_PLAYSTYLE_LABEL_PVE;
	else
		labelText = LFG_PLAYSTYLE_LABEL_PVE_MYTHICZERO;
	end
	self.PlayStyleLabel:SetText(labelText);
end

function LFGListEntryCreation_OnPlayStyleSelectedInternal(self, playstyle)
	local previousPlaystyle = self.selectedPlaystyle;
	self.selectedPlaystyle = playstyle;
	if(C_LFGList.DoesEntryTitleMatchPrebuiltTitle(self.selectedActivity, self.selectedGroup, previousPlaystyle)) then
		LFGListEntryCreation_SetTitleFromActivityInfo(self);
	end
end

function LFGListEntryCreation_OnPlayStyleSelected(self, playstyle)
	LFGListEntryCreation_OnPlayStyleSelectedInternal(self, playstyle);
	self.PlayStyleDropdown:GenerateMenu();
end

function LFGListEntryCreation_GetSanitizedName(self)
	return string.match(self.Name:GetText(), "^%s*(.-)%s*$");
end

function LFGListEntryCreation_ListGroupInternal(self, activityID, itemLevel, autoAccept, privateGroup, questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction)
	local honorLevel = 0;
	if ( LFGListEntryCreation_IsEditMode(self) ) then
		local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
		if activeEntryInfo.isCrossFactionListing == isCrossFaction then
			C_LFGList.UpdateListing(activityID, itemLevel, honorLevel, activeEntryInfo.autoAccept, privateGroup, activeEntryInfo.questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);
		else
			-- Changing cross faction setting requires re-listing the group due to how listings are bucketed server side.
			C_LFGList.RemoveListing();
			C_LFGList.CreateListing(activityID, itemLevel, honorLevel, activeEntryInfo.autoAccept, privateGroup, activeEntryInfo.questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);
		end
		LFGListFrame_SetActivePanel(self:GetParent(), self:GetParent().ApplicationViewer);
	else
		if(C_LFGList.CreateListing(activityID, itemLevel, honorLevel, autoAccept, privateGroup, questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction)) then
			self.WorkingCover:Show();
			LFGListEntryCreation_ClearFocus(self);
		end
	end
end

function LFGListEntryCreation_ListScenarioGroupInternal(self, activityID, itemLevel, autoAccept, privateGroup, scenarioID)
	if(C_LFGList.CreateScenarioListing(activityID, itemLevel, autoAccept, privateGroup, scenarioID)) then
		self.WorkingCover:Show();
		LFGListEntryCreation_ClearFocus(self);
	end
end

function LFGListEntryCreation_ListGroup(self)

	local itemLevel;
	if(self.ItemLevel:IsShown()) then
		itemLevel = tonumber(self.ItemLevel.EditBox:GetText()) or 0;
	else
		itemLevel = tonumber(self.PvpItemLevel.EditBox:GetText()) or 0;
	end
	local pvpRating =  tonumber(self.PVPRating.EditBox:GetText()) or 0;
	local mythicPlusRating =  tonumber(self.MythicPlusRating.EditBox:GetText()) or 0;
	local autoAccept = false;
	local privateGroup = self.PrivateGroup.CheckButton:GetChecked();
	local isCrossFaction =  self.CrossFactionGroup:IsShown() and not self.CrossFactionGroup.CheckButton:GetChecked();
	local selectedPlaystyle = self.PlayStyleDropdown:IsShown() and self.selectedPlaystyle or nil;

	LFGListEntryCreation_ListGroupInternal(self, self.selectedActivity, itemLevel, autoAccept, privateGroup, 0, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);
end

function LFGListEntryCreation_SetAutoCreateDataInternal(self, activityType, activityID, contextID)
	self.autoCreateActivityType = activityType;
	self.autoCreateActivityID = activityID;
	self.autoCreateContextID = contextID;
end

function LFGListEntryCreation_SetAutoCreateMode(self, activityType, activityID, contextID)
	LFGListEntryCreation_SetAutoCreateDataInternal(self, activityType, activityID, contextID);
end

function LFGListEntryCreation_ClearAutoCreateMode(self)
	LFGListEntryCreation_SetAutoCreateDataInternal(self, nil, nil, nil);
end

function LFGListEntryCreation_IsAutoCreateMode(self)
	return self.autoCreateActivityType ~= nil;
end

function LFGListEntryCreation_GetAutoCreateDataQuest(self)
	local questID, activityID = self.autoCreateContextID, self.autoCreateActivityID;

	local itemLevel = 0;
	local autoAccept = true;
	local privateGroup = false;

	return activityID, itemLevel, autoAccept, privateGroup, questID;
end

function LFGListEntryCreation_GetAutoCreateDataScenario(self)
	local scenarioID, activityID = self.autoCreateContextID, self.autoCreateActivityID;

	local itemLevel = 0;
	local autoAccept = true;
	local privateGroup = false;

	return activityID, itemLevel, autoAccept, privateGroup, scenarioID;
end

function LFGListEntryCreation_GetAutoCreateData(self)
	if self.autoCreateActivityType == "quest" then
		return LFGListEntryCreation_GetAutoCreateDataQuest(self);
	elseif self.autoCreateActivityType == "scenario" then
		return LFGListEntryCreation_GetAutoCreateDataScenario(self);
	end
end

function LFGListEntryCreation_CheckAutoCreate(self)
	if LFGListEntryCreation_IsAutoCreateMode(self) then
		C_LFGList.ClearCreationTextFields();
		if self.autoCreateActivityType == "scenario" then
			LFGListEntryCreation_ListScenarioGroupInternal(self, LFGListEntryCreation_GetAutoCreateData(self));
		else
			LFGListEntryCreation_ListGroupInternal(self, LFGListEntryCreation_GetAutoCreateData(self));
		end
		LFGListEntryCreation_ClearAutoCreateMode(self);
	end
end

function LFGListEntryCreation_UpdateValidState(self)
	local errorText;
	local activityInfo = C_LFGList.GetActivityInfoTable(self.selectedActivity)
	local maxNumPlayers = activityInfo and  activityInfo.maxNumPlayers or 0;
	local mythicPlusDisableActivity = not C_LFGList.IsPlayerAuthenticatedForLFG(self.selectedActivity) and (activityInfo.isMythicPlusActivity and not C_LFGList.GetKeystoneForActivity(self.selectedActivity));
	if ( maxNumPlayers > 0 and GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) >= maxNumPlayers ) then
		errorText = string.format(LFG_LIST_TOO_MANY_FOR_ACTIVITY, maxNumPlayers);
	elseif (mythicPlusDisableActivity) then
		errorText = LFG_AUTHENTICATOR_BUTTON_MYTHIC_PLUS_TOOLTIP;
	elseif ( LFGListEntryCreation_GetSanitizedName(self) == "" ) then
		errorText = LFG_LIST_MUST_HAVE_NAME;
	elseif ( self.ItemLevel.warningText ) then
		errorText = self.ItemLevel.warningText;
	elseif (self.PvpItemLevel.warningText) then
		errorText = self.PvpItemLevel.warningText;
	elseif (self.MythicPlusRating.warningText) then
		errorText = self.MythicPlusRating.warningText;
	elseif (self.PVPRating.warningText) then
		errorText = self.PVPRating.warningText;
	else
		errorText = LFGListUtil_GetActiveQueueMessage(false);
	end

	LFGListEntryCreation_UpdateAuthenticatedState(self);

	self.ListGroupButton.DisableStateClickButton:SetShown(mythicPlusDisableActivity);
	self.ListGroupButton:SetEnabled(not errorText and not mythicPlusDisableActivity);
	self.ListGroupButton.errorText = errorText;
end

function LFGListEntryCreation_UpdateAuthenticatedState(self)
	local isAuthenticated = C_LFGList.IsPlayerAuthenticatedForLFG(self.selectedActivity);
	self.Description.EditBox:SetEnabled(isAuthenticated);
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	local isQuestListing = activeEntryInfo and activeEntryInfo.questID or nil;
	self.Name:SetEnabled(isAuthenticated and not isQuestListing);
	self.VoiceChat.EditBox:SetEnabled(isAuthenticated)
end

function LFGListEntryCreation_SetBaseFilters(self, baseFilters)
	self.baseFilters = baseFilters;
end

function LFGListEntryCreation_SetTitleFromActivityInfo(self)
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	if(not self.selectedActivity or not self.selectedGroup or not self.selectedCategory) then
		return;
	end
	local activityID = activeEntryInfo and activeEntryInfo.activityID or (self.selectedActivity or 0);
	local activityInfo =  C_LFGList.GetActivityInfoTable(activityID);
	if((activityInfo and activityInfo.isMythicPlusActivity) or not C_LFGList.IsPlayerAuthenticatedForLFG(self.selectedActivity)) then
		C_LFGList.SetEntryTitle(self.selectedActivity, self.selectedGroup, self.selectedPlaystyle);
	end
end

function LFGListEntryCreation_SetEditMode(self, editMode)
	self.editMode = editMode;

	local descInstructions = nil;
	local isAccountSecured = C_LFGList.IsPlayerAuthenticatedForLFG(self:GetParent().selectedActivity);
	if (not isAccountSecured) then
		descInstructions = LFG_AUTHENTICATOR_DESCRIPTION_BOX;
	end

	if ( editMode ) then
		local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
		assert(activeEntryInfo);

		--Update the dropdowns
		LFGListEntryCreation_Select(self, nil, nil, nil, activeEntryInfo.activityID);

		self.GroupDropdown:Disable();
		self.ActivityDropdown:Disable();

		--Update edit boxes
		C_LFGList.CopyActiveEntryInfoToCreationFields();
		self.Name:SetEnabled(activeEntryInfo.questID == nil and isAccountSecured);
		if ( activeEntryInfo.questID ) then
			self.Description.EditBox.Instructions:SetText(LFGListUtil_GetQuestDescription(activeEntryInfo.questID));
		else
			self.Description.EditBox.Instructions:SetText(descInstructions or DESCRIPTION_OF_YOUR_GROUP);
		end

		if (self.ItemLevel:IsShown()) then
			self.ItemLevel.EditBox:SetText(activeEntryInfo.requiredItemLevel ~= 0 and activeEntryInfo.requiredItemLevel or "");
		else
			self.PvpItemLevel.EditBox:SetText(activeEntryInfo.requiredItemLevel ~= 0 and activeEntryInfo.requiredItemLevel or "");
		end
		self.MythicPlusRating.EditBox:SetText(activeEntryInfo.requiredDungeonScore or "" );
		self.PVPRating.EditBox:SetText(activeEntryInfo.requiredPvpRating or "" )
		self.PrivateGroup.CheckButton:SetChecked(activeEntryInfo.privateGroup);
		self.CrossFactionGroup.CheckButton:SetChecked(not activeEntryInfo.isCrossFactionListing);
		if(self.PlayStyleDropdown:IsShown()) then
			LFGListEntryCreation_OnPlayStyleSelected(self, activeEntryInfo.playstyle);
		end

		self.ListGroupButton:SetText(DONE_EDITING);
	else
		self.GroupDropdown:Enable();
		self.ActivityDropdown:Enable();
		self.ListGroupButton:SetText(LIST_GROUP);
		self.Name:SetEnabled(isAccountSecured);
		self.Description.EditBox.Instructions:SetText(descInstructions or DESCRIPTION_OF_YOUR_GROUP);
		local activityInfo = C_LFGList.GetActivityInfoTable(self.selectedActivity);

		if(activityInfo and self.selectedCategory == GROUP_FINDER_CATEGORY_ID_DUNGEONS) then
			local activityID, groupID = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(); --Prioritize regular keystones
			if(activityID) then
				LFGListEntryCreation_Select(self, self.selectedFilters, self.selectedCategory, groupID, activityID);
			else
				activityID, groupID = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(true);  -- Check for a timewalking keystone.
				if(activityID) then
					LFGListEntryCreation_Select(self, self.selectedFilters, self.selectedCategory, groupID, activityID);
				end
			end
		end
	end
end

function LFGListEntryCreation_IsEditMode(self)
	return self.editMode;
end

function LFGListEntryCreationCancelButton_OnClick(self)
	local panel = self:GetParent();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if ( LFGListEntryCreation_IsEditMode(panel) ) then
		LFGListFrame_SetActivePanel(panel:GetParent(), panel:GetParent().ApplicationViewer);
	else
		LFGListFrame_SetActivePanel(panel:GetParent(), panel:GetParent().CategorySelection);
	end
end

function LFGListEntryCreationListGroupButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	LFGListEntryCreation_ListGroup(self:GetParent());
end

function LFGListEntryCreationActivityFinder_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("LFGListEntryCreationActivityListTemplate", function(button, elementData)
		LFGListEntryCreationActivityFinder_InitButton(button, elementData);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.Dialog.ScrollBox, self.Dialog.ScrollBar, view);

	self.matchingActivities = {};
end

function LFGListEntryCreationActivityFinder_Show(self, categoryID, groupID, filters)
	self.Dialog.EntryBox:SetText("");
	self.categoryID = categoryID;
	self.groupID = groupID;
	self.filters = filters;
	self.selectedActivity = nil;
	LFGListEntryCreationActivityFinder_UpdateMatching(self);
	self:Show();
	self.Dialog.EntryBox:SetFocus();
end

function LFGListEntryCreationActivityFinder_UpdateMatching(self)
	local filters = ResolveCategoryFilters(self.categoryID, self.filters);
	self.matchingActivities = C_LFGList.GetAvailableActivities(self.categoryID, self.groupID, filters, self.Dialog.EntryBox:GetText());
	LFGListUtil_SortActivitiesByRelevancy(self.matchingActivities);
	if ( not self.selectedActivity or not tContains(self.matchingActivities, self.selectedActivity) ) then
		self.selectedActivity = self.matchingActivities[1];
	end

	local dataProvider = CreateDataProviderWithAssignedKey(self.matchingActivities, "id");
	self.Dialog.ScrollBox:SetDataProvider(dataProvider);
end

function LFGListEntryCreationActivityFinder_InitButton(button, elementData)
	local id = elementData.id;
	button.activityID = id;
	local activityInfo = C_LFGList.GetActivityInfoTable(id);
	if(activityInfo) then
		button:SetText(activityInfo.fullName);
		LFGListEntryCreationActivityFinder_SetButtonSelected(button, LFGListFrame.EntryCreation.ActivityFinder.selectedActivity == id);
	end
end

function LFGListEntryCreationActivityFinder_SetButtonSelected(button, selected)
	button.Selected:SetShown(selected);
	if ( selected ) then
		button:LockHighlight();
	else
		button:UnlockHighlight();
	end
end

function LFGListEntryCreationActivityFinder_Accept(self)
	if ( self.selectedActivity ) then
		LFGListEntryCreation_Select(self:GetParent(), nil, nil, nil, self.selectedActivity);
	end
	self:Hide();
end

function LFGListEntryCreationActivityFinder_Cancel(self)
	self:Hide();
end

function LFGListEntryCreationActivityFinder_Select(self, activityID)
	local oldSelectedActivityID = self.selectedActivity;
	self.selectedActivity = activityID;

	local function UpdateButtonSelection(id, selected)
		if id then
			local button = self.Dialog.ScrollBox:FindFrameByPredicate(function(button, elementData)
				return elementData.id == id;
			end);
			if button then
				LFGListEntryCreationActivityFinder_SetButtonSelected(button, selected);
			end
		end
	end;

	UpdateButtonSelection(oldSelectedActivityID,  false);
	UpdateButtonSelection(activityID, true);
end

-------------------------------------------------------
----------Application Viewing
-------------------------------------------------------
function LFGListApplicationViewer_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementExtentCalculator(function(dataIndex, elementData)
		return LFGListApplicationViewerUtil_GetButtonHeight(elementData.numMembers);
	end);
	view:SetElementInitializer("LFGListApplicantTemplate", function(button, elementData)
		LFGListApplicationViewer_InitButton(button, elementData);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

end

function LFGListApplicationViewer_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		LFGListApplicationViewer_UpdateInfo(self);
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		LFGListApplicationViewer_UpdateAvailability(self);
		LFGListApplicationViewer_UpdateInfo(self);
		LFGListApplicationViewer_UpdateResultList(self);
		LFGListApplicationViewer_UpdateResults(self);
	elseif ( event == "LFG_LIST_APPLICANT_LIST_UPDATED" ) then
		LFGListApplicationViewer_UpdateResultList(self);
		LFGListApplicationViewer_UpdateResults(self);
	elseif ( event == "LFG_LIST_APPLICANT_UPDATED" ) then
		--If we can't make changes, we just remove people immediately
		local id = ...;
		if ( not LFGListUtil_IsEntryEmpowered() ) then
			C_LFGList.RemoveApplicant(id);
			LFGListApplicationViewer_UpdateResultList(self);
			LFGListApplicationViewer_UpdateResults(self);
		else
			local frame = self.ScrollBox:FindFrameByPredicate(function(frame, elementData)
				return elementData.id == id;
			end);
			if frame then
				LFGListApplicationViewer_UpdateApplicant(frame, id);
			end
		end

		--Update whether we can invite people
		LFGListApplicationViewer_UpdateInviteState(self);
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		LFGListApplicationViewer_UpdateAvailability(self);
		LFGListApplicationViewer_UpdateGroupData(self);
		LFGListApplicationViewer_UpdateInviteState(self);
		LFGListApplicationViewer_UpdateInfo(self);
	elseif ( event == "PLAYER_ROLES_ASSIGNED") then
		LFGListApplicationViewer_UpdateGroupData(self);
	end
end

function LFGListApplicationViewer_OnShow(self)
	C_LFGList.RefreshApplicants();
	LFGListApplicationViewer_UpdateResultList(self);
	LFGListApplicationViewer_UpdateResults(self);
	LFGListApplicationViewer_UpdateInfo(self);
	LFGListApplicationViewer_UpdateAvailability(self);
	LFGListApplicationViewer_UpdateGroupData(self);
end

function LFGListApplicationViewer_UpdateGroupData(self)
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	if ( not activeEntryInfo ) then
		return;
	end

	local data = GetGroupMemberCountsForDisplay();
	local disabled, showClassesByRole = false, false;
	LFGListGroupDataDisplay_Update(self.DataDisplay, activeEntryInfo.activityID, data, disabled, showClassesByRole);
end

function LFGListApplicationViewer_UpdateInfo(self)
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	assert(activeEntryInfo);
	local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID);
	if(not activityInfo) then
		return;
	end
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID);

	if (not categoryInfo) then
		return;
	end

	self.RatingColumnHeader:SetShown(activityInfo.isMythicPlusActivity or activityInfo.isRatedPvpActivity);
	self.EntryName:SetWidth(0);
	self.EntryName:SetText(activeEntryInfo.name);
	self.DescriptionFrame.activityName = activityInfo.fullName;
	if ( activeEntryInfo.comment == "" and activeEntryInfo.questID ) then
		activeEntryInfo.comment = LFGListUtil_GetQuestDescription(activeEntryInfo.questID);
	end
	self.DescriptionFrame.comment = activeEntryInfo.comment;
	if ( activeEntryInfo.comment == "" ) then
		self.DescriptionFrame.Text:SetText(self.DescriptionFrame.activityName);
	else
		self.DescriptionFrame.Text:SetFormattedText("%s |cff888888- %s|r", self.DescriptionFrame.activityName, self.DescriptionFrame.comment);
	end

	local hasRestrictions = false;
	if (activityInfo.isPvpActivity) then
		if ( activeEntryInfo.requiredItemLevel == 0 ) then
			self.ItemLevel:SetText("");
		else
			self.ItemLevel:SetFormattedText(LFG_LIST_ITEM_LEVEL_CURRENT_PVP, activeEntryInfo.requiredItemLevel);
		end
	else
		if ( activeEntryInfo.requiredItemLevel == 0 ) then
			self.ItemLevel:SetText("");
		else
			self.ItemLevel:SetFormattedText(LFG_LIST_ITEM_LEVEL_CURRENT, activeEntryInfo.requiredItemLevel);
		end
	end

	if ( activeEntryInfo.privateGroup ) then
		self.PrivateGroup:SetText(LFG_LIST_PRIVATE);
		self.ItemLevel:ClearAllPoints();
		self.ItemLevel:SetPoint("LEFT", self.PrivateGroup, "RIGHT", 3, 0);
	else
		self.PrivateGroup:SetText("");
		self.ItemLevel:ClearAllPoints();
		self.ItemLevel:SetPoint("TOPLEFT", self.InfoBackground, "TOPLEFT", 12, -52);
	end

	if ( activeEntryInfo.voiceChat == "" ) then
		self.VoiceChatFrame.tooltip = nil;
		self.VoiceChatFrame:Hide();
	else
		self.VoiceChatFrame.tooltip = activeEntryInfo.voiceChat;
		self.VoiceChatFrame:Show();
	end

	if ( self.EntryName:GetWidth() > 290 ) then
		self.EntryName:SetWidth(290);
	end

	local filters = activityInfo.filters;
	local categoryID = activityInfo.categoryID;

	--Set the background
	local atlasName = nil;
	if ( categoryInfo.separateRecommended and bit.band(filters, Enum.LFGListFilter.Recommended) ~= 0 ) then
		atlasName = "groupfinder-background-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "raids").."-"..(LFG_LIST_PER_EXPANSION_TEXTURES[LFGListUtil_GetCurrentExpansion()] or "classic");
	elseif ( categoryInfo.separateRecommended and bit.band(filters, Enum.LFGListFilter.NotRecommended) ~= 0 ) then
		atlasName = "groupfinder-background-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "raids").."-"..(LFG_LIST_PER_EXPANSION_TEXTURES[math.max(0,LFGListUtil_GetCurrentExpansion() - 1)] or "classic");
	else
		atlasName = "groupfinder-background-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "questing");
	end

	local suffix = "";
	if ( bit.band(filters, Enum.LFGListFilter.PvE) ~= 0 ) then
		suffix = "-pve";
	elseif ( bit.band(filters, Enum.LFGListFilter.PvP) ~= 0 ) then
		suffix = "-pvp";
	end

	--Try with the suffix and then without it
	if ( not self.InfoBackground:SetAtlas(atlasName..suffix) ) then
		self.InfoBackground:SetAtlas(atlasName);
	end

	local isPartyLeader = UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME);
	--Update the AutoAccept button
	self.AutoAcceptButton:SetChecked(activeEntryInfo.autoAccept);

	self.RemoveEntryButton:ClearAllPoints()
	self.BrowseGroupsButton:SetShown(isPartyLeader);

	if (isPartyLeader) then
		self.RemoveEntryButton:SetPoint("LEFT", self.BrowseGroupsButton, "RIGHT", 15, 0);
	else
		self.RemoveEntryButton:SetPoint("BOTTOMLEFT", -3, 4);
	end

	if ( not C_LFGList.CanActiveEntryUseAutoAccept() ) then
		self.AutoAcceptButton:Hide();
	elseif ( isPartyLeader ) then
		self.AutoAcceptButton:Show();
		self.AutoAcceptButton:Enable();
		self.AutoAcceptButton.Label:SetFontObject(GameFontHighlightSmall);
	elseif ( UnitIsGroupAssistant("player", LE_PARTY_CATEGORY_HOME) ) then
		self.AutoAcceptButton:Show();
		self.AutoAcceptButton:Disable();
		self.AutoAcceptButton.Label:SetFontObject(GameFontDisableSmall);
	else
		self.AutoAcceptButton:SetShown(activeEntryInfo.autoAccept);
		self.AutoAcceptButton:Disable();
		self.AutoAcceptButton.Label:SetFontObject(GameFontDisableSmall);
	end
end

function LFGListApplicationViewer_UpdateAvailability(self)
	if ( UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
		self.RemoveEntryButton:Show();
		self.EditButton:Show();
	else
		self.RemoveEntryButton:Hide();
		self.EditButton:Hide();
	end

	if ( IsRestrictedAccount() ) then
		self.EditButton:Disable();
		self.EditButton.tooltip = ERR_RESTRICTED_ACCOUNT_LFG_LIST_TRIAL;
	else
		self.EditButton:Enable();
		self.EditButton.tooltip = nil;
	end

	local empowered = LFGListUtil_IsEntryEmpowered();
	self.UnempoweredCover:SetShown(not empowered);
	self.ScrollBox.NoApplicants:SetShown(empowered and (not self.applicants or #self.applicants == 0));
end

function LFGListApplicationViewer_UpdateResultList(self)
	self.applicants = C_LFGList.GetApplicants();

	--Sort applicants
	LFGListUtil_SortApplicants(self.applicants);

	LFGListApplicationViewer_UpdateAvailability(self);
end

function LFGListApplicationViewer_UpdateInviteState(self)
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	if ( not activeEntryInfo ) then
		return;
	end

	local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID, activeEntryInfo.questID);
	local numAllowed = activityInfo and activityInfo.maxNumPlayers or 0;
	if ( numAllowed == 0 ) then
		numAllowed = MAX_RAID_MEMBERS;
	end

	local currentCount = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
	local numInvited = C_LFGList.GetNumInvitedApplicantMembers();

	self.ScrollBox:ForEachFrame(function(button)
		if ( button.numMembers + currentCount > numAllowed ) then
			button.InviteButton:Disable();
			button.InviteButton.tooltip = LFG_LIST_GROUP_TOO_FULL;
		elseif ( button.numMembers + currentCount + numInvited > numAllowed ) then
			button.InviteButton:Disable();
			button.InviteButton.tooltip = LFG_LIST_INVITED_APP_FILLS_GROUP;
		else
			button.InviteButton:Enable();
			button.InviteButton.tooltip = nil;
		end

		--If our mouse is already over the button, update the tooltip
		if ( button.InviteButton:IsMouseOver() ) then
			if ( button.InviteButton.tooltip ) then
				button.InviteButton:GetScript("OnEnter")(button.InviteButton);
			else
				GameTooltip:Hide();
			end
		end
	end);
end

function LFGListApplicationViewer_InitButton(button, elementData)
	local id = elementData.id;
	local index = elementData.index;

	button.applicantID = id;
	LFGListApplicationViewer_UpdateApplicant(button, id);
	button.Background:SetAlpha(index % 2 == 0 and 0.1 or 0.05);
end

function LFGListApplicationViewer_UpdateResults(self)
	--If the mouse is over something in this frame, update it
	local mouseovers = GetMouseFoci();
	for _, mouseover in ipairs(mouseovers) do
		local mouseoverParent = mouseover and mouseover:GetParent();
		local parentParent = mouseoverParent and mouseoverParent:GetParent();
		if ( mouseoverParent == self.ScrollFrame or parentParent == self.ScrollFrame ) then
			--Just hide the tooltip. We should show it again inside the update function.
			GameTooltip:Hide();
			break;
		end
	end

	local dataProvider = CreateDataProvider();
	for index = 1, #self.applicants do
		local id = self.applicants[index];
		local info = C_LFGList.GetApplicantInfo(id);
		local numMembers = info.numMembers;
		dataProvider:Insert({index=index, id=id, numMembers=numMembers});
	end
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	LFGListApplicationViewer_UpdateInviteState(self);
end

function LFGListApplicationViewer_UpdateApplicant(button, id)
	local applicantInfo = C_LFGList.GetApplicantInfo(id);
	button:SetHeight(LFGListApplicationViewerUtil_GetButtonHeight(applicantInfo.numMembers));

	--Update individual members
	for i=1, applicantInfo.numMembers do
		local member = button.Members[i];
		if ( not member ) then
			member = CreateFrame("BUTTON", nil, button, "LFGListApplicantMemberTemplate");
			member:SetPoint("TOPLEFT", button.Members[i-1], "BOTTOMLEFT", 0, 0);
			button.Members[i] = member;
		end
		LFGListApplicationViewer_UpdateApplicantMember(member, id, i, applicantInfo.applicationStatus, applicantInfo.pendingApplicationStatus);
		member:Show();
	end

	--Hide extra member buttons
	for i=applicantInfo.numMembers+1, #button.Members do
		button.Members[i]:Hide();
	end

	--Update the Invite and Decline buttons based on group size
	if ( applicantInfo.numMembers > 1 ) then
		button.DeclineButton:SetHeight(36);
		button.InviteButton:SetHeight(36);
	else
		button.DeclineButton:SetHeight(22);
		button.InviteButton:SetHeight(22);
	end

	if ( applicantInfo.applicantInfo or applicantInfo.applicationStatus == "applied" ) then
		button.Status:Hide();
	elseif ( applicantInfo.applicationStatus == "invited" ) then
		button.Status:Show();
		button.Status:SetText(LFG_LIST_APP_INVITED);
		button.Status:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
	elseif ( applicantInfo.applicationStatus == "failed" or applicantInfo.applicationStatus == "cancelled" ) then
		button.Status:Show();
		button.Status:SetText(LFG_LIST_APP_CANCELLED);
		button.Status:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	elseif ( applicantInfo.applicationStatus == "declined" or applicantInfo.applicationStatus == "declined_full" or applicantInfo.applicationStatus == "declined_delisted" ) then
		button.Status:Show();
		button.Status:SetText(LFG_LIST_APP_DECLINED);
		button.Status:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	elseif ( applicantInfo.applicationStatus == "timedout" ) then
		button.Status:Show();
		button.Status:SetText(LFG_LIST_APP_TIMED_OUT);
		button.Status:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	elseif ( applicantInfo.applicationStatus == "inviteaccepted" ) then
		button.Status:Show();
		button.Status:SetText(LFG_LIST_APP_INVITE_ACCEPTED);
		button.Status:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
	elseif ( applicantInfo.applicationStatus == "invitedeclined" ) then
		button.Status:Show();
		button.Status:SetText(LFG_LIST_APP_INVITE_DECLINED);
		button.Status:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end

	button.numMembers = applicantInfo.numMembers;
	local useSmallInviteButton = LFGApplicationViewerRatingColumnHeader:IsShown();
	button.Status:ClearAllPoints();

	button.InviteButtonSmall:SetShown(useSmallInviteButton and not applicantInfo.applicantInfo and applicantInfo.applicationStatus == "applied" and LFGListUtil_IsEntryEmpowered());
	button.InviteButton:SetShown(not useSmallInviteButton and not applicantInfo.applicantInfo and applicantInfo.applicationStatus == "applied" and LFGListUtil_IsEntryEmpowered());
	button.DeclineButton:SetShown(not applicantInfo.applicantInfo and applicantInfo.applicationStatus ~= "invited" and LFGListUtil_IsEntryEmpowered());
	button.DeclineButton.isAck = (applicantInfo.applicationStatus ~= "applied" and applicantInfo.applicationStatus ~= "invited");
	if(button.DeclineButton:IsShown()) then
		button.Status:SetPoint("RIGHT", button.DeclineButton, "LEFT", -14, 0);
	else
		button.Status:SetPoint("CENTER", button, "RIGHT", -37, 0);
	end
	button.Spinner:SetShown(applicantInfo.applicantInfo);
end

function LFGListApplicationViewer_UpdateRoleIcons(member, grayedOut, tank, healer, damage, noTouchy, assignedRole)
	--Update the roles.
	if ( grayedOut ) then
		member.RoleIcon1:Hide();
		member.RoleIcon2:Hide();
		member.RoleIcon3:Hide();
	else
		local role1 = tank and "TANK" or (healer and "HEALER" or (damage and "DAMAGER"));
		local role2 = (tank and healer and "HEALER") or ((tank or healer) and damage and "DAMAGER");
		local role3 = (tank and healer and damage and "DAMAGER");
		member.RoleIcon1:GetNormalTexture():SetAtlas(LFG_LIST_GROUP_DATA_ATLASES[role1]);
		member.RoleIcon1:GetHighlightTexture():SetAtlas(LFG_LIST_GROUP_DATA_ATLASES[role1]);
		if ( role2 ) then
			member.RoleIcon2:GetNormalTexture():SetAtlas(LFG_LIST_GROUP_DATA_ATLASES[role2]);
			member.RoleIcon2:GetHighlightTexture():SetAtlas(LFG_LIST_GROUP_DATA_ATLASES[role2]);
		end
		if ( role3 ) then
			member.RoleIcon3:GetNormalTexture():SetAtlas(LFG_LIST_GROUP_DATA_ATLASES[role3]);
			member.RoleIcon3:GetHighlightTexture():SetAtlas(LFG_LIST_GROUP_DATA_ATLASES[role3]);
		end

		member.RoleIcon1:SetEnabled(not noTouchy and role1 ~= assignedRole);
		member.RoleIcon1:SetAlpha(role1 == assignedRole and 1 or 0.3);
		member.RoleIcon1:Show();
		member.RoleIcon2:SetEnabled(not noTouchy and role2 ~= assignedRole);
		member.RoleIcon2:SetAlpha(role2 == assignedRole and 1 or 0.3);
		member.RoleIcon2:SetShown(role2);
		member.RoleIcon3:SetEnabled(not noTouchy and role3 ~= assignedRole);
		member.RoleIcon3:SetAlpha(role3 == assignedRole and 1 or 0.3);
		member.RoleIcon3:SetShown(role3);
		member.RoleIcon1.role = role1;
		member.RoleIcon2.role = role2;
		member.RoleIcon3.role = role3;
	end
end

function LFGListApplicationViewer_UpdateApplicantMember(member, appID, memberIdx, status, pendingStatus)
	local grayedOut = not pendingStatus and (status == "failed" or status == "cancelled" or status == "declined" or status == "declined_full" or status == "declined_delisted" or status == "invitedeclined" or status == "timedout" or status == "inviteaccepted" or status == "invitedeclined");
	local noTouchy = (status == "invited");

	local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damage, assignedRole, relationship, dungeonScore, pvpItemLevel = C_LFGList.GetApplicantMemberInfo(appID, memberIdx);

	member.memberIdx = memberIdx;

	member.Name:SetWidth(0);
	if ( name ) then
		local displayName = Ambiguate(name, "short");
		if ( memberIdx > 1 ) then
			member.Name:SetText("  "..displayName);
		else
			member.Name:SetText(displayName);
		end

		local classTextColor = grayedOut and GRAY_FONT_COLOR or RAID_CLASS_COLORS[class];
		member.Name:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
	else
		--We might still be requesting the name and class from the server.
		member.Name:SetText("");
	end

	member.FriendIcon:SetShown(relationship);
	member.FriendIcon.relationship = relationship;
	member.FriendIcon.Icon:SetDesaturated(grayedOut);
	member.FriendIcon:SetAlpha(grayedOut and 0.5 or 1.0);

	--Adjust name width depending on whether we have the friend icon
	local nameLength = 100;
	if ( relationship ) then
		nameLength = nameLength - 22;
	end
	if ( member.Name:GetWidth() > nameLength ) then
		member.Name:SetWidth(nameLength);
	end

	LFGListApplicationViewer_UpdateRoleIcons(member, grayedOut, tank, healer, damage, noTouchy, assignedRole);
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID);

	member.ItemLevel:SetShown(not grayedOut);
	if(activityInfo and activityInfo.isPvpActivity) then
		member.ItemLevel:SetText(math.floor(pvpItemLevel));
	else
		member.ItemLevel:SetText(math.floor(itemLevel));
	end

	local pvpRatingForEntry = C_LFGList.GetApplicantPvpRatingInfoForListing(appID, memberIdx, activeEntryInfo.activityID);

	if not grayedOut and LFGApplicationViewerRatingColumnHeader:IsShown() and pvpRatingForEntry then
		member.Rating:SetText(pvpRatingForEntry.rating);
		member.Rating:Show();
		member:SetWidth(256);
	elseif not grayedOut and LFGApplicationViewerRatingColumnHeader:IsShown() and dungeonScore then
		local color = C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore) or HIGHLIGHT_FONT_COLOR;
		member.Rating:SetText(color:WrapTextInColorCode(dungeonScore));
		member.Rating:Show();
		member:SetWidth(256);
	else
		member.Rating:Hide();
		member:SetWidth(200);
	end

	local mouseFoci = GetMouseFoci();
	for _, mouseFocus in ipairs(mouseFoci) do 
		if ( mouseFocus == member ) then
			LFGListApplicantMember_OnEnter(member);
			break;
		elseif ( mouseFocus == member.FriendIcon ) then
			member.FriendIcon:GetScript("OnEnter")(member.FriendIcon);
			break;
		end
	end
end

function LFGListApplicationViewerUtil_GetButtonHeight(numApplicants)
	return 20 * numApplicants + 6;
end

function LFGListApplicationViewerEditButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local panel = self:GetParent();
	local entryCreation = panel:GetParent().EntryCreation;
	LFGListEntryCreation_SetEditMode(entryCreation, true);
	LFGListFrame_SetActivePanel(panel:GetParent(), entryCreation);
end

LFGApplicationBrowseGroupsButtonMixin = { };
function LFGApplicationBrowseGroupsButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local panel = self:GetParent();
	local baseFilters = panel:GetParent().baseFilters;
	local searchPanel = panel:GetParent().SearchPanel;
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	if(activeEntryInfo) then
		local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID);
		if(activityInfo) then
			LFGListSearchPanel_SetCategory(searchPanel, activityInfo.categoryID, activityInfo.filters, baseFilters);
			LFGListFrame_SetActivePanel(panel:GetParent(), searchPanel);
			LFGListSearchPanel_DoSearch(searchPanel);
		end
	end
end

local function MakeRunLevelWithIncrement(dungeonScoreStruct)
	local pluses = "";
	for i = 1, dungeonScoreStruct.bestLevelIncrement do
		pluses = pluses..GROUPFINDER_PLUS;
	end
	return pluses..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(dungeonScoreStruct.bestRunLevel);
end

--Applicant members

function LFGListApplicantMember_OnMouseDown(self)
	MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
		rootDescription:SetTag("MENU_LFG_FRAME_MEMBER_APPLY");

		local applicantID = self:GetParent().applicantID;
		local memberIdx = self.memberIdx;
		local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damage, assignedRole = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx);
		local applicantInfo = C_LFGList.GetApplicantInfo(applicantID);
		
		rootDescription:CreateTitle(name or "");

		local whisperButton = rootDescription:CreateButton(WHISPER, function()
			ChatFrame_SendTell(name);
		end);

		rootDescription:CreateButton(LFG_LIST_REPORT_PLAYER, function()
			LFGList_ReportApplicant(applicantID, name or "");
		end);

		local ignoreButton = rootDescription:CreateButton(IGNORE_PLAYER, function()
			C_FriendList.AddIgnore(name); 
			C_LFGList.DeclineApplicant(applicantID);
		end);

		if not name then
			whisperButton:SetEnabled(false);
			ignoreButton:SetEnabled(false);
		end
	end);
end

function LFGListApplicantMember_OnEnter(self)
	local applicantID = self:GetParent().applicantID;
	local memberIdx = self.memberIdx;

	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	if ( not activeEntryInfo ) then
		return;
	end

	local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID);
	if(not activityInfo) then
		return;
	end
	local applicantInfo = C_LFGList.GetApplicantInfo(applicantID);
	local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damage, assignedRole, relationship, dungeonScore, pvpItemLevel, factionGroup, raceID, specID = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx);
	local bestDungeonScoreForEntry = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, memberIdx, activeEntryInfo.activityID);
	local bestOverallScore = C_LFGList.GetApplicantBestDungeonScore(applicantID, memberIdx);
	local pvpRatingForEntry = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, memberIdx, activeEntryInfo.activityID);

	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 105, 0);

	if ( name ) then
		local classTextColor = RAID_CLASS_COLORS[class];
		GameTooltip:SetText(name, classTextColor.r, classTextColor.g, classTextColor.b);
		local classSpecializationName = localizedClass;
		if(specID) then
			local specName = PlayerUtil.GetSpecNameBySpecID(specID);
			if(specName) then
				classSpecializationName = CLUB_FINDER_LOOKING_FOR_CLASS_SPEC:format(specName, classSpecializationName);
			end
		end
		if(UnitFactionGroup("player") ~= PLAYER_FACTION_GROUP[factionGroup]) then
			GameTooltip_AddHighlightLine(GameTooltip, UNIT_TYPE_LEVEL_FACTION_TEMPLATE:format(level, classSpecializationName, FACTION_STRINGS[factionGroup]));
		else
			GameTooltip_AddHighlightLine(GameTooltip, UNIT_TYPE_LEVEL_TEMPLATE:format(level, classSpecializationName));
		end
	else
		GameTooltip:SetText(" ");	--Just make it empty until we get the name update
	end

	if (activityInfo.isPvpActivity) then
		GameTooltip_AddColoredLine(GameTooltip, LFG_LIST_ITEM_LEVEL_CURRENT_PVP:format(pvpItemLevel), HIGHLIGHT_FONT_COLOR);
	else
		GameTooltip_AddNormalLine(GameTooltip, LFG_LIST_ITEM_LEVEL_CURRENT:format(itemLevel));
	end

	if ( activityInfo.useHonorLevel ) then
		GameTooltip:AddLine(string.format(LFG_LIST_HONOR_LEVEL_CURRENT_PVP, honorLevel), 1, 1, 1);
	end
	if ( applicantInfo.comment and applicantInfo.comment ~= "" ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(string.format(LFG_LIST_COMMENT_FORMAT, applicantInfo.comment), LFG_LIST_COMMENT_FONT_COLOR.r, LFG_LIST_COMMENT_FONT_COLOR.g, LFG_LIST_COMMENT_FONT_COLOR.b, true);
	end
	if(LFGApplicationViewerRatingColumnHeader:IsShown()) then
		if(pvpRatingForEntry) then
			GameTooltip_AddNormalLine(GameTooltip, PVP_RATING_GROUP_FINDER:format(pvpRatingForEntry.activityName, pvpRatingForEntry.rating, PVPUtil.GetTierName(pvpRatingForEntry.tier)));
		else
			if(not dungeonScore) then
				dungeonScore = 0;
			end
			GameTooltip_AddBlankLineToTooltip(GameTooltip);

			local color = C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore);
			if(not color) then
				color = HIGHLIGHT_FONT_COLOR;
			end
			
			GameTooltip:AddDoubleLine(DUNGEON_SCORE, color:WrapTextInColorCode(dungeonScore));

			local function AddDungeonScore(leftText, dungeonScoreStruct)
				if not dungeonScoreStruct or dungeonScoreStruct.mapScore == 0 or not dungeonScoreStruct.finishedSuccess then
					GameTooltip:AddDoubleLine(leftText, GRAY_FONT_COLOR:WrapTextInColorCode(DUNGEON_SCORE_LINK_NO_SCORE));
				else
					local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(dungeonScoreStruct.mapScore);
					if not color then
						color = HIGHLIGHT_FONT_COLOR;
					end

					GameTooltip:AddDoubleLine(leftText, MakeRunLevelWithIncrement(dungeonScoreStruct).." "..color:WrapTextInColorCode(dungeonScoreStruct.mapName));
				end
			end

			AddDungeonScore(LFG_LIST_BEST_FOR_DUNGEON, bestDungeonScoreForEntry);
			AddDungeonScore(LFG_LIST_BEST_RUN, bestOverallScore);
		end
	end

	--Add statistics
	local stats = C_LFGList.GetApplicantMemberStats(applicantID, memberIdx);
	local lastTitle = nil;

	--Tank proving ground
	if ( stats[23690] and stats[23690] > 0 ) then
		LFGListUtil_AppendStatistic(LFG_LIST_PROVING_TANK_GOLD, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle);
		lastTitle = LFG_LIST_PROVING_GROUND_TITLE;
	elseif ( stats[23687] and stats[23687] > 0 ) then
		LFGListUtil_AppendStatistic(LFG_LIST_PROVING_TANK_SILVER, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle);
		lastTitle = LFG_LIST_PROVING_GROUND_TITLE;
	elseif ( stats[23684] and stats[23684] > 0 ) then
		LFGListUtil_AppendStatistic(LFG_LIST_PROVING_TANK_BRONZE, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle);
		lastTitle = LFG_LIST_PROVING_GROUND_TITLE;
	end

	--Healer proving ground
	if ( stats[23691] and stats[23691] > 0 ) then
		LFGListUtil_AppendStatistic(LFG_LIST_PROVING_HEALER_GOLD, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle);
		lastTitle = LFG_LIST_PROVING_GROUND_TITLE;
	elseif ( stats[23688] and stats[23688] > 0 ) then
		LFGListUtil_AppendStatistic(LFG_LIST_PROVING_HEALER_SILVER, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle);
		lastTitle = LFG_LIST_PROVING_GROUND_TITLE;
	elseif ( stats[23685] and stats[23685] > 0 ) then
		LFGListUtil_AppendStatistic(LFG_LIST_PROVING_HEALER_BRONZE, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle);
		lastTitle = LFG_LIST_PROVING_GROUND_TITLE;
	end

	--Damage proving ground
	if ( stats[23689] and stats[23689] > 0 ) then
		LFGListUtil_AppendStatistic(LFG_LIST_PROVING_DAMAGER_GOLD, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle);
		lastTitle = LFG_LIST_PROVING_GROUND_TITLE;
	elseif ( stats[23686] and stats[23686] > 0 ) then
		LFGListUtil_AppendStatistic(LFG_LIST_PROVING_DAMAGER_SILVER, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle);
		lastTitle = LFG_LIST_PROVING_GROUND_TITLE;
	elseif ( stats[23683] and stats[23683] > 0 ) then
		LFGListUtil_AppendStatistic(LFG_LIST_PROVING_DAMAGER_BRONZE, nil, LFG_LIST_PROVING_GROUND_TITLE, lastTitle);
		lastTitle = LFG_LIST_PROVING_GROUND_TITLE;
	end

	GameTooltip:Show();
end

-------------------------------------------------------
----------Searching
-------------------------------------------------------
function LFGListSearchPanel_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementFactory(function(factory, elementData)
		if elementData.startGroup then
			factory("LFGStartGroupButtonListTemplate");
		else
			factory("LFGListSearchEntryTemplate", LFGListSearchPanel_InitButton);
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.SearchBox.clearButton:SetScript("OnClick", function(btn)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local editBox = btn:GetParent();
		C_LFGList.ClearSearchTextFields();
		editBox:ClearFocus();

		LFGListSearchPanel_DoSearch(self);
	end);

	self.FilterButton:SetWidth(93);
end

function LFGListSearchPanel_OnEvent(self, event, ...)
	--Note: events are dispatched from the base frame. Add RegisterEvent there.
	if ( event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" ) then
		StaticPopupSpecial_Hide(LFGListApplicationDialog);
		self.searching = false;
		self.searchFailed = false;
		LFGListSearchPanel_UpdateResultList(self);
	elseif ( event == "LFG_LIST_SEARCH_FAILED" ) then
		self.searching = false;
		self.searchFailed = true;
		LFGListSearchPanel_UpdateResultList(self);
	elseif ( event == "LFG_LIST_SEARCH_RESULT_UPDATED" ) then
		local id = ...;
		if ( self.selectedResult == id ) then
			LFGListSearchPanel_ValidateSelected(self);
			if ( self.selectedResult ~= id ) then
				LFGListSearchPanel_UpdateResults(self);
			end
		else
			local updatedEntryFrame = self.ScrollBox:FindFrameByPredicate(function(frame)
				local elementData = frame:GetElementData();
				return elementData and elementData.resultID == id;
			end);
			if updatedEntryFrame then
				LFGListSearchEntry_Update(updatedEntryFrame);
			end
		end
		LFGListSearchPanel_UpdateButtonStatus(self);
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		LFGListSearchPanel_UpdateButtonStatus(self);
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		LFGListSearchPanel_UpdateButtonStatus(self);
	elseif ( event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		local unit = ...;
		if ( unit == "player" ) then
			LFGListSearchPanel_UpdateButtonStatus(self);
		end
	elseif ( event == "UNIT_CONNECTION" ) then
		LFGListSearchPanel_UpdateButtonStatus(self);
	elseif ( event == "LFG_ROLE_CHECK_UPDATE" ) then
		LFGListSearchPanel_UpdateResultList(self);
	end

	if ( tContains(LFG_LIST_ACTIVE_QUEUE_MESSAGE_EVENTS, event) ) then
		LFGListSearchPanel_UpdateButtonStatus(self);
	end
end

function LFGListCanChangeLanguages()
	if GetCurrentRegionName() == "US" then
		return false;
	end

	local availableLanguages = C_LFGList.GetAvailableLanguageSearchFilter();
	local defaultLanguages = C_LFGList.GetDefaultLanguageSearchFilter();

	local canChangeLanguages = false;
	for i=1, #availableLanguages do
		if ( not defaultLanguages[availableLanguages[i]] ) then
			canChangeLanguages = true; 
			break;
		end
	end
	return canChangeLanguages;
end

local function LFGListAdvancedFiltersActivitiesNoneChecked(enabled)
	return #enabled.activities == 0;
end

local function LFGListAdvancedFiltersActivitiesAllChecked(enabled)
	local seasonGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));
	local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE));
	
	return #enabled.activities == (#seasonGroups + #expansionGroups);
end

local function LFGListAdvancedFiltersDifficultyNoneChecked(enabled)
	return not (enabled.difficultyNormal or enabled.difficultyHeroic or enabled.difficultyMythic or enabled.difficultyMythicPlus);
end

local function LFGListAdvancedFiltersDifficultyAllChecked(enabled)
	return enabled.difficultyNormal and enabled.difficultyHeroic and enabled.difficultyMythic and enabled.difficultyMythicPlus;
end

--for activities and difficulties, none checked and all checked are equivalent. Although visually we want to show all checked as the default.
local function LFGListAdvancedFiltersIsDefault(enabled)
	return (LFGListAdvancedFiltersActivitiesNoneChecked(enabled) or LFGListAdvancedFiltersActivitiesAllChecked(enabled))
		and (LFGListAdvancedFiltersDifficultyNoneChecked(enabled) or LFGListAdvancedFiltersDifficultyAllChecked(enabled))
		and not (enabled.needsTank or enabled.needsHealer or enabled.needsDamage or enabled.needsMyClass or enabled.hasTank or enabled.hasHealer 
				or (enabled.minimumRating ~= 0));
end

local function LFGListAdvancedFiltersCheckAllDifficulties(enabled)
	enabled.difficultyNormal = true;
	enabled.difficultyHeroic = true;
	enabled.difficultyMythic = true;
	enabled.difficultyMythicPlus = true;
end

local function LFGListAdvancedFiltersCheckAllDungeons(enabled)
	local seasonGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));
	local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE));
	
	local allDungeons = {};

	tAppendAll(allDungeons, seasonGroups);
	tAppendAll(allDungeons, expansionGroups);

	enabled.activities = allDungeons;
end

local function LFGListSearchPanel_SetupAdvancedFilter(dropdown, rootDescription)
	if IsPlayerAtEffectiveMaxLevel() then
		local enabled = C_LFGList.GetAdvancedFilter();

		--use a set in Lua and convert to a list for communicating with the server.
		local activitySet = {};
		local function ActivitiesListToSet()
			activitySet = {};
			for _, activityId in ipairs(enabled.activities) do
				activitySet[activityId] = true;
			end
		end
		local function ActivitiesSetToList()
			enabled.activities = {};
			for activityId, checked in pairs(activitySet) do
				if checked then
					table.insert(enabled.activities, activityId);
				end
			end
		end

		ActivitiesListToSet();

		local function IsSelected(key)
			return enabled[key];
		end

		local function SetSelected(key)
			enabled[key] = not IsSelected(key);

			C_LFGList.SaveAdvancedFilter(enabled); 
			LFGListFrame.SearchPanel.ScrollBox:ForEachFrame(LFGListSearchEntry_Update);
		end

		local function AddEntry(name, key, overrideCheck)
			enabled[key] = overrideCheck or enabled[key];
			rootDescription:CreateCheckbox(name, IsSelected, SetSelected, key);
		end

		rootDescription:CreateTitle(LFG_LIST_REQUIRE);
		local availTank, availHealer, availDPS = C_LFGList.GetAvailableRoles();
		if availTank then
			AddEntry(LFG_LIST_NEEDS_TANK, "needsTank");
		end
		if availHealer then
			AddEntry(LFG_LIST_NEEDS_HEALER, "needsHealer");
		end
		if availDPS then
			AddEntry(LFG_LIST_NEEDS_DAMAGE, "needsDamage");
		end
		AddEntry(string.format(LFG_LIST_CLASS_AVAILABLE, PlayerUtil.GetClassName()), "needsMyClass");
		AddEntry(LFG_LIST_HAS_TANK, "hasTank");
		AddEntry(LFG_LIST_HAS_HEALER, "hasHealer");

		rootDescription:CreateSpacer();
		rootDescription:CreateTitle(DUNGEONS);

		do
			local function IsGroupSelected(activityId)
				return activitySet[activityId];
			end

			local function SetGroupSelected(activityId)
				ActivitiesListToSet();
				activitySet[activityId] = not IsGroupSelected(activityId); 
				ActivitiesSetToList();

				C_LFGList.SaveAdvancedFilter(enabled); 
				LFGListFrame.SearchPanel.ScrollBox:ForEachFrame(LFGListSearchEntry_Update);
			end

			local noneChecked = LFGListAdvancedFiltersActivitiesNoneChecked(enabled);

			local function AddGroup(groups)
				for _, activityId in ipairs(groups) do
					local name = C_LFGList.GetActivityGroupInfo(activityId);
					if name then
						if noneChecked then
							table.insert(enabled.activities, activityId);
							activitySet[activityId] = true;
						end

						rootDescription:CreateCheckbox(name, IsGroupSelected, SetGroupSelected, activityId);
					end
				end
			end

			local seasonGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));
			AddGroup(seasonGroups);

			rootDescription:CreateSpacer();

			local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE));
			AddGroup(expansionGroups);
		end

		rootDescription:CreateSpacer();
		rootDescription:CreateTitle(LFG_LIST_MINIMUM_RATING);

		local levelRangeFrame = rootDescription:CreateTemplate("LevelRangeFrameTemplate");
		levelRangeFrame:AddInitializer(function(frame, elementDescription, menu)
			frame:Reset();
			frame:SetWidth(38);
			frame.MaxLevel:Hide();
			frame.MinLevel.Dash:Hide();

			local enabled = C_LFGList.GetAdvancedFilter();
			local minLevel = enabled.minimumRating;
			if minLevel > 0 then
				frame:SetMinLevel(minLevel);
			end

			frame:SetLevelRangeChangedCallback(function(minLevel, maxLevel)
				enabled.minimumRating = minLevel;
				C_LFGList.SaveAdvancedFilter(enabled); 
				LFGListFrame.SearchPanel.ScrollBox:ForEachFrame(LFGListSearchEntry_Update);

				dropdown:ValidateResetState();
			end);
		end);

		rootDescription:CreateSpacer();
		rootDescription:CreateTitle(LFG_LIST_DIFFICULTY);

		local noneChecked = LFGListAdvancedFiltersDifficultyNoneChecked(enabled);
		AddEntry(PLAYER_DIFFICULTY1, "difficultyNormal", noneChecked);
		AddEntry(PLAYER_DIFFICULTY2, "difficultyHeroic", noneChecked);
		AddEntry(PLAYER_DIFFICULTY6, "difficultyMythic", noneChecked);
		AddEntry(PLAYER_DIFFICULTY_MYTHIC_PLUS, "difficultyMythicPlus", noneChecked);
	end

	if LFGListCanChangeLanguages() then
		rootDescription:CreateSpacer();
		local languages = rootDescription:CreateButton(LANGUAGES_LABEL);
		LFGListSearchPanel_SetupLanguageFilter(dropdown, languages);
	end
end

function LFGListSearchPanel_SetupLanguageFilter(dropdown, rootDescription)
	local enabled = C_LFGList.GetLanguageSearchFilter();
	local defaults = C_LFGList.GetDefaultLanguageSearchFilter();

	local function IsSelected(lang)
		return enabled[lang] or defaults[lang];
	end

	local function SetSelected(lang)
		enabled[lang] = not IsSelected(lang);
		C_LFGList.SaveLanguageSearchFilter(enabled);
	end

	for i, lang in ipairs(C_LFGList.GetAvailableLanguageSearchFilter()) do
		local text = _G["LFG_LIST_LANGUAGE_"..string.upper(lang)];
		local checkbox = rootDescription:CreateCheckbox(text, IsSelected, SetSelected, lang);

		if defaults[lang] then
			checkbox:SetEnabled(false);
		end
	end
end

function LFGListSearchPanel_OnShow(self)
	LFGListSearchPanel_UpdateResultList(self);

	if ( LFGListCanChangeLanguages() or IsPlayerAtEffectiveMaxLevel() ) then
		self.SearchBox:SetWidth(228);
		self.FilterButton:Show();
	else
		self.SearchBox:SetWidth(319);
		self.FilterButton:Hide();
	end

	self.FilterButton:SetIsDefaultCallback(function()
		if LFGListFrame.CategorySelection.selectedCategory ~= GROUP_FINDER_CATEGORY_ID_DUNGEONS then
			-- Filter reset doesn't apply to this category, return true
			-- as if the current filter is the default filter.
			return true;
		end

		local enabled = C_LFGList.GetAdvancedFilter();
		return LFGListAdvancedFiltersIsDefault(enabled);
	end);

	self.FilterButton:SetDefaultCallback(function()
		local enabled = C_LFGList.GetAdvancedFilter();
		enabled.needsTank = false;
		enabled.needsHealer = false;
		enabled.needsDamage = false;
		enabled.needsMyClass = false;
		enabled.hasTank = false;
		enabled.hasHealer = false;
		enabled.minimumRating = 0;
		enabled.activities = {};
		LFGListAdvancedFiltersCheckAllDifficulties(enabled);
		LFGListAdvancedFiltersCheckAllDungeons(enabled);
		C_LFGList.SaveAdvancedFilter(enabled); 
		LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel);
	end);

	self.FilterButton:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_LFG_FRAME_SEARCH_FILTER");

		if LFGListFrame.CategorySelection.selectedCategory == GROUP_FINDER_CATEGORY_ID_DUNGEONS then
			LFGListSearchPanel_SetupAdvancedFilter(dropdown, rootDescription);
		else
			LFGListSearchPanel_SetupLanguageFilter(dropdown, rootDescription);
		end
	end);
end

function LFGListSearchPanel_Clear(self)
	C_LFGList.ClearSearchResults();
	C_LFGList.ClearSearchTextFields();
	self.selectedResult = nil;
	LFGListSearchPanel_UpdateResultList(self);
end

function LFGListSearchPanel_EvaluateTutorial(self, mouseOverButton)
	local helpTipInfo = {
		text = CROSS_FACTION_GROUP_FINDER_HELPTIP,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_CROSS_FACTION_GROUP_FINDER,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		offsetX = 10,
		checkCVars = true,
	};
	HelpTip:Show(self, helpTipInfo, mouseOverButton);
end

function LFGListSearchPanel_SetCategory(self, categoryID, filters, preferredFilters)
	self.categoryID = categoryID;
	self.filters = filters;
	self.preferredFilters = preferredFilters or 0;

	local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID);
	self.SearchBox.Instructions:SetText(categoryInfo.searchPromptOverride or FILTER);
	local name = LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, filters, false);
	self.CategoryName:SetText(name);
end

function LFGListSearchPanel_DoSearch(self)
	local searchText = self.SearchBox:GetText();
	local languages = C_LFGList.GetLanguageSearchFilter();
	local advancedFilters = C_LFGList.GetAdvancedFilter();
	if LFGListFrame.CategorySelection.selectedCategory ~= GROUP_FINDER_CATEGORY_ID_DUNGEONS then
		advancedFilters = nil;
	end
	 
	local filters = ResolveCategoryFilters(self.categoryID, self.filters);
	C_LFGList.Search(self.categoryID, filters, self.preferredFilters, languages, nil, advancedFilters);
	self.searching = true;
	self.searchFailed = false;
	self.selectedResult = nil;
	LFGListSearchPanel_UpdateResultList(self);

	-- If auto-create is desired, then the caller needs to set up that data after the search begins.
	-- There's an issue with using OnTextChanged to handle this due to how OnShow processes the update.
	if self.previousSearchText ~= searchText then
		LFGListEntryCreation_ClearAutoCreateMode(self:GetParent().EntryCreation);
	end

	self.previousSearchText = searchText;
end

function LFGListSearchPanel_CreateGroupInstead(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local panel = LFGListFrame.SearchPanel;
	LFGListEntryCreation_Show(panel:GetParent().EntryCreation, panel.preferredFilters, panel.categoryID, panel.filters);
end

function LFGListSearchPanel_UpdateResultList(self)
	self.totalResults, self.results = C_LFGList.GetFilteredSearchResults();
	self.applications = C_LFGList.GetApplications();
	LFGListUtil_SortSearchResults(self);
	LFGListSearchPanel_UpdateResults(self);
end

function LFGListSearchPanel_ValidateSelected(self)
	if ( self.selectedResult and not LFGListSearchPanelUtil_CanSelectResult(self.selectedResult)) then
		self.selectedResult = nil;
	end
end

function LFGListSearchPanelUtil_CanSelectResult(resultID)
	local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(resultID);
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);

	if LFGListFrame.declines and LFGListFrame.declines[searchResultInfo.partyGUID] then
		appStatus = LFGListFrame.declines[searchResultInfo.partyGUID];
	end

	if ( appStatus ~= "none" or pendingStatus or searchResultInfo.isDelisted ) then
		return false;
	end

	return true;
end

function LFGListSearchPanel_InitButton(button, elementData)
	button.resultID = elementData.resultID;
	LFGListSearchEntry_Update(button);
end

function LFGListSearchPanel_UpdateResults(self)
	--If we have an application selected, deselect it.
	LFGListSearchPanel_ValidateSelected(self);

	if ( self.searching ) then
		self.SearchingSpinner:Show();
		self.ScrollBox.NoResultsFound:Hide();
		self.ScrollBox.StartGroupButton:Hide();
		self.ScrollBox:RemoveDataProvider();
	else
		self.SearchingSpinner:Hide();

		local dataProvider = CreateDataProvider();
		local results = self.results;
		for index = 1, #results do
			dataProvider:Insert({resultID=results[index]});
		end

		local apps = self.applications;
		local resultSet = tInvert(self.results);
		for i, app in ipairs(apps) do
			if not resultSet[app]  then
				dataProvider:Insert({resultID=app});
			end
		end

		if(self.totalResults == 0) then
			self.ScrollBox.NoResultsFound:Show();
			self.ScrollBox.StartGroupButton:SetShown(not self.searchFailed);
			self.ScrollBox.StartGroupButton:ClearAllPoints();
			self.ScrollBox.StartGroupButton:SetPoint("BOTTOM", self.ScrollBox.NoResultsFound, "BOTTOM", 0, - 27);
			self.ScrollBox.NoResultsFound:SetText(self.searchFailed and LFG_LIST_SEARCH_FAILED or LFG_LIST_NO_RESULTS_FOUND);
		else
			self.ScrollBox.NoResultsFound:Hide();
			self.ScrollBox.StartGroupButton:SetShown(false);

			if(self.shouldAlwaysShowCreateGroupButton) then
				dataProvider:Insert({startGroup=true});
			end
		end

		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

		--Reanchor the errors to not overlap applications
		if not self.ScrollBox:HasScrollableExtent() then
			local extent = self.ScrollBox:GetExtent();
			self.ScrollBox.NoResultsFound:SetPoint("TOP", self.ScrollBox, "TOP", 0, -extent - 27);
		end
	end
	LFGListSearchPanel_UpdateButtonStatus(self);
end

function LFGListSearchPanel_SelectResult(self, resultID)
	self.selectedResult = resultID;
	LFGListSearchPanel_UpdateResults(self);
end

function LFGListSearchPanel_UpdateButtonStatus(self)
	--Update the SignUpButton
	local resultID = self.selectedResult;
	local numApplications, numActiveApplications = C_LFGList.GetNumApplications();
	local messageApply = LFGListUtil_GetActiveQueueMessage(true);
	local availTank, availHealer, availDPS = C_LFGList.GetAvailableRoles();
	if ( messageApply ) then
		self.SignUpButton:Disable();
		self.SignUpButton.tooltip = messageApply;
	elseif ( not LFGListUtil_IsAppEmpowered() ) then
		self.SignUpButton:Disable();
		self.SignUpButton.tooltip = LFG_LIST_APP_UNEMPOWERED;
	elseif ( IsInGroup(LE_PARTY_CATEGORY_HOME) and C_LFGList.IsCurrentlyApplying() ) then
		self.SignUpButton:Disable();
		self.SignUpButton.tooltip = LFG_LIST_APP_CURRENTLY_APPLYING;
	elseif ( numActiveApplications >= MAX_LFG_LIST_APPLICATIONS ) then
		self.SignUpButton:Disable();
		self.SignUpButton.tooltip = string.format(LFG_LIST_HIT_MAX_APPLICATIONS, MAX_LFG_LIST_APPLICATIONS);
	elseif ( GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > MAX_PARTY_MEMBERS + 1 ) then
		self.SignUpButton:Disable();
		self.SignUpButton.tooltip = LFG_LIST_MAX_MEMBERS;
	elseif ( not (availTank or availHealer or availDPS) ) then
		self.SignUpButton:Disable();
		self.SignUpButton.tooltip = LFG_LIST_MUST_CHOOSE_SPEC;
	elseif ( GroupHasOfflineMember(LE_PARTY_CATEGORY_HOME) ) then
		self.SignUpButton:Disable();
		self.SignUpButton.tooltip = LFG_LIST_OFFLINE_MEMBER;
	elseif ( resultID ) then
		self.SignUpButton:Enable();
		self.SignUpButton.tooltip = nil;
	else
		self.SignUpButton:Disable();
		self.SignUpButton.tooltip = LFG_LIST_SELECT_A_SEARCH_RESULT;
	end

	local isPartyLeader = UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME);
	local canBrowseWhileQueued = C_LFGList.HasActiveEntryInfo() and isPartyLeader;
	--Update the StartGroupButton
	if ( IsInGroup(LE_PARTY_CATEGORY_HOME) and not isPartyLeader ) then
		self.ScrollBox.StartGroupButton:Disable();
		self.ScrollBox.StartGroupButton.tooltip = LFG_LIST_NOT_LEADER;
	else
		local messageStart = LFGListUtil_GetActiveQueueMessage(false);
		local startError, errorText = GetStartGroupRestriction();
		if ( messageStart ) then
			self.ScrollBox.StartGroupButton:Disable();
			self.ScrollBox.StartGroupButton.tooltip = messageStart;
		elseif ( startError ~= nil ) then
			self.ScrollBox.StartGroupButton:Disable();
			self.ScrollBox.StartGroupButton.tooltip = errorText;
		elseif (canBrowseWhileQueued) then
			self.ScrollBox.StartGroupButton:Disable();
			self.ScrollBox.StartGroupButton.tooltip = CANNOT_DO_THIS_WHILE_LFGLIST_LISTED;
		else
			self.ScrollBox.StartGroupButton:Enable();
			self.ScrollBox.StartGroupButton.tooltip = nil;
		end
	end

	self.BackButton:SetShown(not canBrowseWhileQueued);
	self.BackToGroupButton:SetShown(canBrowseWhileQueued)
end

function LFGListSearchPanel_SignUp(self)
	LFGListApplicationDialog_Show(LFGListApplicationDialog, self.selectedResult);
end

function LFGListSearchPanelSearchBox_OnEnterPressed(self)
	local parent = self:GetParent();
	if ( parent.AutoCompleteFrame:IsShown() and parent.AutoCompleteFrame.selected ) then
		C_LFGList.SetSearchToActivity(parent.AutoCompleteFrame.selected);
	end

	LFGListSearchPanel_DoSearch(self:GetParent());
	self:ClearFocus();
end

function LFGListSearchPanelSearchBox_OnTabPressed(self)
	if ( IsShiftKeyDown() ) then
		LFGListSearchPanel_AutoCompleteAdvance(self:GetParent(), -1);
	else
		LFGListSearchPanel_AutoCompleteAdvance(self:GetParent(), 1);
	end
end

function LFGListSearchPanelSearchBox_OnArrowPressed(self, key)
	if ( key == "UP" ) then
		LFGListSearchPanel_AutoCompleteAdvance(self:GetParent(), -1);
	elseif ( key == "DOWN" ) then
		LFGListSearchPanel_AutoCompleteAdvance(self:GetParent(), 1);
	end
end

function LFGListSearchPanelSearchBox_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	LFGListSearchPanel_UpdateAutoComplete(self:GetParent());
end

function LFGListSearchPanelSearchBox_OnEditFocusGained(self)
	LFGListSearchPanel_UpdateAutoComplete(self:GetParent());
	SearchBoxTemplate_OnEditFocusGained(self);

	local dungeonScore = C_ChallengeMode.GetOverallDungeonScore();
	if dungeonScore >= 100 then
		local helpTipInfo = {
			text = KEY_RANGE_GROUP_FINDER_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_KEY_RANGE_GROUP_FINDER,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			offsetX = 10,
			checkCVars = true,
		};
		HelpTip:Show(self, helpTipInfo, mouseOverButton);
	end
end

function LFGListSearchPanelSearchBox_OnEditFocusLost(self)
	LFGListSearchPanel_UpdateAutoComplete(self:GetParent());
	SearchBoxTemplate_OnEditFocusLost(self);
end

function LFGListSearchAutoCompleteButton_OnClick(self)
	local panel = self:GetParent():GetParent();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	C_LFGList.SetSearchToActivity(self.activityID);
	LFGListSearchPanel_DoSearch(panel);
	panel.SearchBox:ClearFocus();
end

function LFGListSearchPanel_AutoCompleteAdvance(self, offset)
	local selected = self.AutoCompleteFrame.selected;

	--Find the index of the current selection and how many results we have displayed
	local idx = nil;
	local numDisplayed = 0;
	for i=1, #self.AutoCompleteFrame.Results do
		local btn = self.AutoCompleteFrame.Results[i];
		if ( btn:IsShown() and btn.activityID ) then
			numDisplayed = i;
			if ( btn.activityID == selected ) then
				idx = i;
			end
		else
			break;
		end
	end

	local newIndex = nil;
	if ( not idx ) then
		--We had nothing selected, advance from the front or back
		if ( offset > 0 ) then
			newIndex = offset;
		else
			newIndex = numDisplayed + 1 + offset;
		end
	else
		--Advance from our old location
		newIndex = ((idx - 1 + offset + numDisplayed) % numDisplayed) + 1;
	end

	self.AutoCompleteFrame.selected = self.AutoCompleteFrame.Results[newIndex].activityID;
	LFGListSearchPanel_UpdateAutoComplete(self);
end

function LFGListSearchPanel_UpdateAutoComplete(self)
	local text = self.SearchBox:GetText();
	if ( text == "" or not self.SearchBox:HasFocus() ) then
		self.AutoCompleteFrame:Hide();
		self.AutoCompleteFrame.selected = nil;
		return;
	end

	--Choose the autocomplete results
	local filters = ResolveCategoryFilters(self.categoryID, self.filters);
	local matchingActivities = C_LFGList.GetAvailableActivities(self.categoryID, nil, filters, text);
	LFGListUtil_SortActivitiesByRelevancy(matchingActivities);

	local numResults = math.min(#matchingActivities, MAX_LFG_LIST_SEARCH_AUTOCOMPLETE_ENTRIES);

	if ( numResults == 0 ) then
		self.AutoCompleteFrame:Hide();
		self.AutoCompleteFrame.selected = nil;
		return;
	end

	--Update the buttons
	local foundSelected = false;
	for i=1, numResults do
		local id = matchingActivities[i];

		local button = self.AutoCompleteFrame.Results[i];
		if ( not button ) then
			button = CreateFrame("BUTTON", nil, self.AutoCompleteFrame, "LFGListSearchAutoCompleteButtonTemplate");
			button:SetPoint("TOPLEFT", self.AutoCompleteFrame.Results[i-1], "BOTTOMLEFT", 0, 0);
			button:SetPoint("TOPRIGHT", self.AutoCompleteFrame.Results[i-1], "BOTTOMRIGHT", 0, 0);
			self.AutoCompleteFrame.Results[i] = button;
		end

		if ( i == numResults and numResults < #matchingActivities ) then
			--This is just a "x more" button
			button:SetFormattedText(LFG_LIST_AND_MORE, #matchingActivities - numResults + 1);
			button:Disable();
			button.Selected:Hide();
			button.activityID = nil;
		else
			--This is an actual activity
			button:SetText( (C_LFGList.GetActivityFullName(id)) );
			button:Enable();
			button.activityID = id;

			if ( id == self.AutoCompleteFrame.selected ) then
				button.Selected:Show();
				foundSelected = true;
			else
				button.Selected:Hide();
			end
		end
		button:Show();
	end

	if ( not foundSelected ) then
		self.selected = nil;
	end

	--Hide unused buttons
	for i=numResults + 1, #self.AutoCompleteFrame.Results do
		self.AutoCompleteFrame.Results[i]:Hide();
	end

	--Update the frames height and show it
	self.AutoCompleteFrame:SetHeight(numResults * self.AutoCompleteFrame.Results[1]:GetHeight() + 8);
	self.AutoCompleteFrame:Show();
end

function LFGListSearchEntry_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

local function EntryStillSatisfiesFilters(enabled, displayData, searchResultInfo)
	local _, classFilename = UnitClass("player");
	local infoTable = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID);

	if enabled.needsTank and displayData["TANK"] ~= 0 then
		return false;
	elseif enabled.needsHealer and displayData["HEALER"] ~= 0 then
		return false;
	elseif enabled.needsDamage and displayData["DAMAGER"] >= 3 then
		return false;
	elseif enabled.needsMyClass and displayData[classFilename] > 0 then
		return false;
	elseif enabled.hasTank and displayData["TANK"] == 0 then
		return false;
	elseif enabled.hasHealer and displayData["HEALER"] == 0 then
		return false;
	elseif enabled.minimumRating > (searchResultInfo.leaderOverallDungeonScore or 0) then
		return false;
	elseif #enabled.activities > 0 then
		local foundActivity = false;
		for _, activityID in ipairs(enabled.activities) do
			if activityID == infoTable.groupFinderActivityGroupID then
				foundActivity = true;
				break;
			end
		end
		if not foundActivity then
			return false;
		end
	end
	if not LFGListAdvancedFiltersDifficultyNoneChecked(enabled) then
		if (infoTable.isNormalActivity and not enabled.difficultyNormal)
			or (infoTable.isHeroicActivity and not enabled.difficultyHeroic) 
			or (infoTable.isMythicActivity and not enabled.difficultyMythic)
			or (infoTable.isMythicPlusActivity and not enabled.difficultyMythicPlus) then
			return false;
		end
	end

	return true;
end

function LFGListSearchEntry_Update(self)
	local resultID = self.resultID;

	if not resultID or not C_LFGList.HasSearchResultInfo(resultID) then
		return;
	end

	local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(resultID);
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	local isDeclined = IsDeclined(appStatus);
	if LFGListFrame.declines then
		if not isDeclined and LFGListFrame.declines[searchResultInfo.partyGUID] then
			isDeclined = true;
			appStatus = LFGListFrame.declines[searchResultInfo.partyGUID];
		end
	end
	local isApplication = (appStatus ~= "none" or pendingStatus);
	local isAppFinished = LFGListUtil_IsStatusInactive(appStatus) or LFGListUtil_IsStatusInactive(pendingStatus);

	--Update visibility based on whether we're an application or not
	self.isApplication = isApplication;
	self.ResultBG:SetShown(not isApplication or isAppFinished);
	self.DataDisplay:SetShown(not isApplication);
	self.CancelButton:SetShown(isApplication and pendingStatus ~= "applied");
	self.CancelButton:SetEnabled(LFGListUtil_IsAppEmpowered());
	self.CancelButton.Icon:SetDesaturated(not LFGListUtil_IsAppEmpowered());
	self.CancelButton.tooltip = (not LFGListUtil_IsAppEmpowered()) and LFG_LIST_APP_UNEMPOWERED;
	self.Spinner:SetShown(pendingStatus == "applied");
	
	if ( pendingStatus == "applied" and C_LFGList.GetRoleCheckInfo() ) then
		self.PendingLabel:SetText(LFG_LIST_ROLE_CHECK);
		self.PendingLabel:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		self.PendingLabel:Show();
		self.ExpirationTime:Hide();
		self.CancelButton:Hide();
	elseif ( pendingStatus == "cancelled" or appStatus == "cancelled" or appStatus == "failed" ) then
		self.PendingLabel:SetText(LFG_LIST_APP_CANCELLED);
		self.PendingLabel:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		self.PendingLabel:Show();
		self.ExpirationTime:Hide();
		self.CancelButton:Hide();
	elseif ( isDeclined ) then
		self.PendingLabel:SetText((appStatus == "declined_full") and LFG_LIST_APP_FULL or LFG_LIST_APP_DECLINED);
		self.PendingLabel:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		self.PendingLabel:Show();
		self.ExpirationTime:Hide();
		self.CancelButton:Hide();
	elseif ( appStatus == "timedout" ) then
		self.PendingLabel:SetText(LFG_LIST_APP_TIMED_OUT);
		self.PendingLabel:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		self.PendingLabel:Show();
		self.ExpirationTime:Hide();
		self.CancelButton:Hide();
	elseif ( appStatus == "invited" ) then
		self.PendingLabel:SetText(LFG_LIST_APP_INVITED);
		self.PendingLabel:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
		self.PendingLabel:Show();
		self.ExpirationTime:Hide();
		self.CancelButton:Hide();
	elseif ( appStatus == "inviteaccepted" ) then
		self.PendingLabel:SetText(LFG_LIST_APP_INVITE_ACCEPTED);
		self.PendingLabel:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
		self.PendingLabel:Show();
		self.ExpirationTime:Hide();
		self.CancelButton:Hide();
	elseif ( appStatus == "invitedeclined" ) then
		self.PendingLabel:SetText(LFG_LIST_APP_INVITE_DECLINED);
		self.PendingLabel:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		self.PendingLabel:Show();
		self.ExpirationTime:Hide();
		self.CancelButton:Hide();
	elseif ( isApplication and pendingStatus ~= "applied" ) then
		self.PendingLabel:SetText(LFG_LIST_PENDING);
		self.PendingLabel:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
		self.PendingLabel:Show();
		self.ExpirationTime:Show();
		self.CancelButton:Show();
	else
		self.PendingLabel:Hide();
		self.ExpirationTime:Hide();
		self.CancelButton:Hide();
	end

	--Center justify if we're on more than one line
	if ( self.PendingLabel:GetHeight() > 15 ) then
		self.PendingLabel:SetJustifyH("CENTER");
	else
		self.PendingLabel:SetJustifyH("RIGHT");
	end

	--Change the anchor of the label depending on whether we have the expiration time
	if ( self.ExpirationTime:IsShown() ) then
		self.PendingLabel:SetPoint("RIGHT", self.ExpirationTime, "LEFT", -3, 0);
	else
		self.PendingLabel:SetPoint("RIGHT", self.ExpirationTime, "RIGHT", -3, 0);
	end

	self.expiration = GetTime() + appDuration;

	local panel = self:GetParent():GetParent():GetParent();

	local activityName = C_LFGList.GetActivityFullName(searchResultInfo.activityID, nil, searchResultInfo.isWarMode);

	local enabled = C_LFGList.GetAdvancedFilter();
	local displayData = C_LFGList.GetSearchResultMemberCounts(resultID);

	self.isNowFilteredOut = LFGListFrame.CategorySelection.selectedCategory == GROUP_FINDER_CATEGORY_ID_DUNGEONS and not EntryStillSatisfiesFilters(enabled, displayData, searchResultInfo);
	self.isApplication = isApplication and not isAppFinished;
	self.isSelected = panel.selectedResult == resultID and not isApplication and not searchResultInfo.isDelisted;

	self.BackgroundTexture:Show();
	if self.isNowFilteredOut then
		self.BackgroundTexture:SetAtlas("groupfinder-highlightbar-red");
	elseif self.isApplication then
		self.BackgroundTexture:SetAtlas("groupfinder-highlightbar-green");
	elseif self.isSelected then
		self.BackgroundTexture:SetAtlas("groupfinder-highlightbar-yellow");
	else
		self.BackgroundTexture:Hide();
	end

	self.resultID = resultID;
	local nameColor = NORMAL_FONT_COLOR;
	local activityColor = GRAY_FONT_COLOR;
	if isDeclined then
		nameColor = RED_FONT_COLOR;
		activityColor = LFG_LIST_DELISTED_FONT_COLOR;
	elseif ( searchResultInfo.isDelisted or isAppFinished ) then
		nameColor = LFG_LIST_DELISTED_FONT_COLOR;
		activityColor = LFG_LIST_DELISTED_FONT_COLOR;
	elseif ( searchResultInfo.numBNetFriends > 0 or searchResultInfo.numCharFriends > 0 or searchResultInfo.numGuildMates > 0 ) then
		nameColor = BATTLENET_FONT_COLOR;
	end
	self.Name:SetWidth(0);
	self.Name:SetText(searchResultInfo.name);
	self.Name:SetTextColor(nameColor.r, nameColor.g, nameColor.b);
	self.ActivityName:SetText(activityName);
	self.ActivityName:SetTextColor(activityColor.r, activityColor.g, activityColor.b);
	self.VoiceChat:SetShown(searchResultInfo.voiceChat ~= "");
	self.VoiceChat.tooltip = searchResultInfo.voiceChat;

	local showClassesByRole = LFGListFrame.CategorySelection.selectedCategory == GROUP_FINDER_CATEGORY_ID_DUNGEONS
	LFGListGroupDataDisplay_Update(self.DataDisplay, searchResultInfo.activityID, displayData, searchResultInfo.isDelisted, showClassesByRole);

	local nameWidth = isApplication and 165 or 176;
	if ( searchResultInfo.voiceChat ~= "" ) then
		nameWidth = nameWidth - 22;
	end
	if ( self.Name:GetWidth() > nameWidth ) then
		self.Name:SetWidth(nameWidth);
	end
	self.ActivityName:SetWidth(176);

	local mouseFoci = GetMouseFoci();
	for _, mouseFocus in ipairs(mouseFoci) do 
		if ( mouseFocus == self ) then
			LFGListSearchEntry_OnEnter(self);
			break
		end
		if ( mouseFocus == self.VoiceChat ) then
			mouseFocus:GetScript("OnEnter")(mouseFocus);
			break;
		end
	end

	if ( isApplication ) then
		self:SetScript("OnUpdate", LFGListSearchEntry_UpdateExpiration);
		LFGListSearchEntry_UpdateExpiration(self);
	else
		self:SetScript("OnUpdate", nil);
	end
end

function LFGListSearchEntry_UpdateExpiration(self)
	local duration = 0;
	local now = GetTime();
	if ( self.expiration and self.expiration > now ) then
		duration = self.expiration - now;
	end

	local minutes = math.floor(duration / 60);
	local seconds = duration % 60;
	self.ExpirationTime:SetFormattedText("%d:%.2d", minutes, seconds);
end

function LFGListSearchEntry_CreateContextMenu(self)
	local panel = LFGListFrame.SearchPanel;
	MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
		rootDescription:SetTag("MENU_LFG_FRAME_SEARCH_ENTRY");

		local searchResultInfo = C_LFGList.GetSearchResultInfo(self.resultID);
		local _, appStatus = C_LFGList.GetApplicationInfo(self.resultID);
		rootDescription:CreateTitle(searchResultInfo.name);

		local whisperButton = rootDescription:CreateButton(WHISPER_LEADER, function()
			ChatFrame_SendTell(searchResultInfo.leaderName);
		end);

		if not searchResultInfo.leaderName then
			whisperButton:SetEnabled(false);

			local applied = (appStatus == "applied" or appStatus == "invited");
			if not applied then
				whisperButton:SetTooltip(function(tooltip, description)
					GameTooltip_SetTitle(tooltip, WHISPER);
					GameTooltip_AddNormalLine(tooltip, LFG_LIST_MUST_SIGN_UP_TO_WHISPER);
				end);
			end
		end

		rootDescription:CreateButton(LFG_LIST_REPORT_GROUP_FOR, function()
			LFGList_ReportListing(self.resultID, searchResultInfo.leaderName);
			LFGListSearchPanel_UpdateResultList(panel);
		end);

		rootDescription:CreateButton(REPORT_GROUP_FINDER_ADVERTISEMENT, function()
			LFGList_ReportAdvertisement(self.resultID, searchResultInfo.leaderName);
			LFGListSearchPanel_UpdateResultList(panel);
		end);
	end);
end

function LFGListSearchEntry_OnClick(self, button)
	local panel = LFGListFrame.SearchPanel;
	if ( button == "RightButton" ) then
		LFGListSearchEntry_CreateContextMenu(self);
	elseif ( panel.selectedResult ~= self.resultID and LFGListSearchPanelUtil_CanSelectResult(self.resultID) ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		LFGListSearchPanel_SelectResult(panel, self.resultID);
	end
end

function LFGListSearchEntry_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 25, 0);
	local resultID = self.resultID;
	LFGListUtil_SetSearchEntryTooltip(GameTooltip, resultID);

	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	if(searchResultInfo.crossFactionListing) then
		LFGListSearchPanel_EvaluateTutorial(LFGListFrame.SearchPanel, self);
	end

	if self.isNowFilteredOut or self.isApplication or not self.isSelected then
		self.Highlight:Show();
	end
end

function LFGListSearchEntry_OnLeave(self)
	GameTooltip_Hide();

	self.Highlight:Hide();
end

function LFGListSearchEntryUtil_GetFriendList(resultID)
	local list = "";
	local bNetFriends, charFriends, guildMates = C_LFGList.GetSearchResultFriends(resultID);
	local displayedFirst = false;

	--BNet friends
	for i=1, #bNetFriends do
		if ( displayedFirst ) then
			list = list..PLAYER_LIST_DELIMITER;
		else
			displayedFirst = true;
		end
		list = list..FRIENDS_BNET_NAME_COLOR_CODE..bNetFriends[i]..FONT_COLOR_CODE_CLOSE;
	end

	--Character friends
	for i=1, #charFriends do
		if ( displayedFirst ) then
			list = list..PLAYER_LIST_DELIMITER;
		else
			displayedFirst = true;
		end
		list = list..FRIENDS_WOW_NAME_COLOR_CODE..charFriends[i]..FONT_COLOR_CODE_CLOSE;
	end

	--Guild mates
	for i=1, #guildMates do
		if ( displayedFirst ) then
			list = list..PLAYER_LIST_DELIMITER;
		else
			displayedFirst = true;
		end
		list = list..RGBTableToColorCode(ChatTypeInfo.GUILD)..guildMates[i]..FONT_COLOR_CODE_CLOSE;
	end
	return list;
end

-------------------------------------------------------
----------Application dialog functions
-------------------------------------------------------
function LFGListApplicationDialog_OnLoad(self)
	self:RegisterEvent("LFG_ROLE_UPDATE");
	self.Description.EditBox:SetScript("OnEnterPressed", nop);
	self.hideOnEscape = true;
end

function LFGListApplicationDialog_OnEvent(self, event)
	if ( event == "LFG_ROLE_UPDATE" ) then
		LFGListApplicationDialog_UpdateRoles(self);
	end
end

function LFGListApplicationDialog_Show(self, resultID)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	if ( searchResultInfo.activityID ~= self.activityID ) then
		C_LFGList.ClearApplicationTextFields();
	end

	self.resultID = resultID;
	self.activityID = searchResultInfo.activityID;
	LFGListApplicationDialog_UpdateRoles(self);
	StaticPopupSpecial_Show(self);
end

function LFGListApplicationDialog_UpdateRoles(self)
	local availTank, availHealer, availDPS = C_LFGList.GetAvailableRoles();

	local avail1, avail2, avail3;
	if ( availTank ) then
		avail1 = self.TankButton;
	end
	if ( availHealer ) then
		if ( avail1 ) then
			avail2 = self.HealerButton;
		else
			avail1 = self.HealerButton;
		end
	end
	if ( availDPS ) then
		if ( avail2 ) then
			avail3 = self.DamagerButton;
		elseif ( avail1 ) then
			avail2 = self.DamagerButton;
		else
			avail1 = self.DamagerButton;
		end
	end

	self.TankButton:SetShown(availTank);
	self.HealerButton:SetShown(availHealer);
	self.DamagerButton:SetShown(availDPS);

	if ( avail3 ) then
		avail1:ClearAllPoints();
		avail1:SetPoint("TOPRIGHT", self, "TOP", -53, -35);
		avail2:ClearAllPoints();
		avail2:SetPoint("TOP", self, "TOP", 0, -35);
		avail3:ClearAllPoints();
		avail3:SetPoint("TOPLEFT", self, "TOP", 53, -35);
	elseif ( avail2 ) then
		avail1:ClearAllPoints();
		avail1:SetPoint("TOPRIGHT", self, "TOP", -5, -35);
		avail2:ClearAllPoints();
		avail2:SetPoint("TOPLEFT", self, "TOP", 5, -35);
	elseif ( avail1 ) then
		avail1:ClearAllPoints();
		avail1:SetPoint("TOP", self, "TOP", 0, -35);
	end

	local _, tank, healer, dps = GetLFGRoles();
	self.TankButton.CheckButton:SetChecked(tank);
	self.HealerButton.CheckButton:SetChecked(healer);
	self.DamagerButton.CheckButton:SetChecked(dps);

	LFGListApplicationDialog_UpdateValidState(self);
end

function LFGListApplicationDialog_UpdateValidState(self)
	if (	( self.TankButton:IsShown() and self.TankButton.CheckButton:GetChecked())
		or	( self.HealerButton:IsShown() and self.HealerButton.CheckButton:GetChecked())
		or	( self.DamagerButton:IsShown() and self.DamagerButton.CheckButton:GetChecked()) ) then
		self.SignUpButton:Enable();
		self.SignUpButton.errorText = nil;
	else
		self.SignUpButton:Disable();
		self.SignUpButton.errorText = LFG_LIST_MUST_SELECT_ROLE;
	end
end

function LFGListApplicationDialogSignUpButton_OnClick(button)
	local dialog = button:GetParent();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	C_LFGList.ApplyToGroup(dialog.resultID, dialog.TankButton:IsShown() and dialog.TankButton.CheckButton:GetChecked(), dialog.HealerButton:IsShown() and dialog.HealerButton.CheckButton:GetChecked(), dialog.DamagerButton:IsShown() and dialog.DamagerButton.CheckButton:GetChecked());
	StaticPopupSpecial_Hide(dialog);
end

function LFGListRoleButtonCheckButton_OnClick(self)
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end

	local dialog = self:GetParent():GetParent();
	local leader, tank, healer, dps = GetLFGRoles();
	SetLFGRoles(leader, dialog.TankButton.CheckButton:GetChecked(), dialog.HealerButton.CheckButton:GetChecked(), dialog.DamagerButton.CheckButton:GetChecked());
end

-------------------------------------------------------
----------Invite dialog functions
-------------------------------------------------------
function LFGListInviteDialog_OnLoad(self)
	self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");
	self:RegisterEvent("LFG_LIST_JOINED_GROUP");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("UNIT_CONNECTION");
end

function LFGListInviteDialog_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" ) then
		LFGListInviteDialog_CheckPending(self);
	elseif ( event == "LFG_LIST_SEARCH_RESULT_UPDATED" ) then
		local id = ...;
		local _, status, pendingStatus = C_LFGList.GetApplicationInfo(id);

		local empowered = LFGListUtil_IsAppEmpowered();
		if ( self.resultID == id and not self.informational and (status ~= "invited" or not empowered) ) then
			--Check if we need to hide the panel
			StaticPopupSpecial_Hide(self);
			LFGListInviteDialog_CheckPending(self);
		elseif ( status == "invited" and not pendingStatus ) then
			--Check if we need to show this result
			LFGListInviteDialog_CheckPending(self);
		end
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		--Check if we need to hide the current panel
		if ( not LFGListUtil_IsAppEmpowered() and self:IsShown() and not self.informational ) then
			StaticPopupSpecial_Hide(self);
		end

		--Check if we need to show any panels
		LFGListInviteDialog_CheckPending(self);
	elseif ( event == "LFG_LIST_JOINED_GROUP" ) then
		if ( not LFGListUtil_IsAppEmpowered() ) then
			--Show the informational dialog, regardless of whether we already had something up
			local id, kstringGroupName = ...;
			StaticPopupSpecial_Hide(self);
			LFGListInviteDialog_Show(self, id, kstringGroupName);
		end
	elseif ( event == "UNIT_CONNECTION" ) then
		LFGListInviteDialog_UpdateOfflineNotice(self);
	end
end

function LFGListInviteDialog_CheckPending(self)
	--If we're already showing one, don't replace it
	if ( self:IsShown() ) then
		return;
	end

	--If we're not empowered to make changes to applications, don't pop up anything.
	if ( not LFGListUtil_IsAppEmpowered() ) then
		return;
	end

	local apps = C_LFGList.GetApplications();
	for i=1, #apps do
		local id, status, pendingStatus = C_LFGList.GetApplicationInfo(apps[i]);
		if ( status == "invited" and not pendingStatus ) then
			LFGListInviteDialog_Show(self, apps[i]);
			return;
		end
	end
end

function LFGListInviteDialog_Show(self, resultID, kstringGroupName)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	local activityName = C_LFGList.GetActivityFullName(searchResultInfo.activityID, nil, searchResultInfo.isWarMode);
	local _, status, _, _, role = C_LFGList.GetApplicationInfo(resultID);

	local informational = (status ~= "invited");
	assert(not informational or status == "inviteaccepted");

	self.resultID = resultID;
	self.GroupName:SetText(kstringGroupName or searchResultInfo.name);
	self.ActivityName:SetText(activityName);
	self.Role:SetText(_G[role]);
	local showDisabled = false;
	self.RoleIcon:SetAtlas(GetIconForRole(role, showDisabled), TextureKitConstants.IgnoreAtlasSize);
	self.Label:SetText(informational and LFG_LIST_JOINED_GROUP_NOTICE or LFG_LIST_INVITED_TO_GROUP);

	self.informational = informational;
	self.AcceptButton:SetShown(not informational);
	self.DeclineButton:SetShown(not informational);
	self.AcknowledgeButton:SetShown(informational);

	if ( not informational and GroupHasOfflineMember(LE_PARTY_CATEGORY_HOME) ) then
		self:SetHeight(250);
		self.OfflineNotice:Show();
		LFGListInviteDialog_UpdateOfflineNotice(self);
	else
		self:SetHeight(210);
		self.OfflineNotice:Hide();
	end

	StaticPopupSpecial_Show(self);

	PlaySound(SOUNDKIT.READY_CHECK);
	FlashClientIcon();
end

function LFGListInviteDialog_UpdateOfflineNotice(self)
	if ( GroupHasOfflineMember(LE_PARTY_CATEGORY_HOME) ) then
		self.OfflineNotice:SetText(LFG_LIST_OFFLINE_MEMBER_NOTICE);
		self.OfflineNotice:SetFontObject(GameFontRed);
	else
		self.OfflineNotice:SetText(LFG_LIST_OFFLINE_MEMBER_NOTICE_GONE);
		self.OfflineNotice:SetFontObject(GameFontGreen);
	end
end

function LFGListInviteDialog_Accept(self)
	C_LFGList.AcceptInvite(self.resultID);
	StaticPopupSpecial_Hide(self);
	LFGListInviteDialog_CheckPending(self);
end

function LFGListInviteDialog_Decline(self)
	C_LFGList.DeclineInvite(self.resultID);
	StaticPopupSpecial_Hide(self);
	LFGListInviteDialog_CheckPending(self);
end

function LFGListInviteDialog_Acknowledge(self)
	StaticPopupSpecial_Hide(self);
	LFGListInviteDialog_CheckPending(self);
end

-------------------------------------------------------
----------Group Data Display functions
-------------------------------------------------------
function LFGListGroupDataDisplay_Update(self, activityID, displayData, disabled, showClassesByRole)
	local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
	if(not activityInfo) then
		return;
	end
	if ( activityInfo.displayType == Enum.LFGListDisplayType.RoleCount ) then
		self.RoleCount:Show();
		self.Enumerate:Hide();
		self.PlayerCount:Hide();
		LFGListGroupDataDisplayRoleCount_Update(self.RoleCount, displayData, disabled);
	elseif ( activityInfo.displayType == Enum.LFGListDisplayType.RoleEnumerate ) then
		self.RoleCount:Hide();
		self.Enumerate:Show();
		self.PlayerCount:Hide();
		LFGListGroupDataDisplayEnumerate_Update(self.Enumerate, activityInfo.maxNumPlayers, displayData, disabled, LFG_LIST_GROUP_DATA_ROLE_ORDER, showClassesByRole);
	elseif ( activityInfo.displayType == Enum.LFGListDisplayType.ClassEnumerate ) then
		self.RoleCount:Hide();
		self.Enumerate:Show();
		self.PlayerCount:Hide();
		LFGListGroupDataDisplayEnumerate_Update(self.Enumerate, activityInfo.maxNumPlayers, displayData, disabled, LFG_LIST_GROUP_DATA_CLASS_ORDER, showClassesByRole);
	elseif ( activityInfo.displayType == Enum.LFGListDisplayType.PlayerCount ) then
		self.RoleCount:Hide();
		self.Enumerate:Hide();
		self.PlayerCount:Show();
		LFGListGroupDataDisplayPlayerCount_Update(self.PlayerCount, displayData, disabled);
	elseif ( activityInfo.displayType == Enum.LFGListDisplayType.HideAll ) then
		self.RoleCount:Hide();
		self.Enumerate:Hide();
		self.PlayerCount:Hide();
	else
		GMError("Unknown display type");
		self.RoleCount:Hide();
		self.Enumerate:Hide();
		self.PlayerCount:Hide();
	end
end

function LFGListGroupDataDisplayRoleCount_Update(self, displayData, disabled)
	self.TankCount:SetText(displayData.TANK);
	self.HealerCount:SetText(displayData.HEALER);
	self.DamagerCount:SetText(displayData.DAMAGER);

	--Update for the disabled state
	local r = disabled and LFG_LIST_DELISTED_FONT_COLOR.r or HIGHLIGHT_FONT_COLOR.r;
	local g = disabled and LFG_LIST_DELISTED_FONT_COLOR.g or HIGHLIGHT_FONT_COLOR.g;
	local b = disabled and LFG_LIST_DELISTED_FONT_COLOR.b or HIGHLIGHT_FONT_COLOR.b;
	self.TankCount:SetTextColor(r, g, b);
	self.HealerCount:SetTextColor(r, g, b);
	self.DamagerCount:SetTextColor(r, g, b);
	self.TankIcon:SetDesaturated(disabled);
	self.HealerIcon:SetDesaturated(disabled);
	self.DamagerIcon:SetDesaturated(disabled);
	self.TankIcon:SetAlpha(disabled and 0.5 or 0.70);
	self.HealerIcon:SetAlpha(disabled and 0.5 or 0.70);
	self.DamagerIcon:SetAlpha(disabled and 0.5 or 0.70);
end

function LFGListGroupDataDisplayEnumerate_Update(self, numPlayers, displayData, disabled, iconOrder, showClassesByRole)

	--Show/hide the required icons
	for i=1, #self.Icons do
		local icon = self.Icons[i];
		if ( i > numPlayers ) then
			icon:Hide();
		else
			icon:Show();
			for _, texture in ipairs(icon.Textures) do
				texture:SetDesaturated(disabled);
				texture:SetAlpha(disabled and 0.5 or 1.0);
			end
		end
	end

	--Note that icons are numbered from right to left
	local iconIndex = numPlayers;
	for i=1, #iconOrder do
		local role = iconOrder[i];
		if not showClassesByRole then
			for j=1, displayData[iconOrder[i]] do
				local icon = self.Icons[iconIndex];
				icon.RoleIconWithBackground:SetAtlas(LFG_LIST_GROUP_DATA_ATLASES[role], false);
				icon.RoleIcon:Hide();
				icon.ClassCircle:Hide();

				iconIndex = iconIndex - 1;
				if ( iconIndex < 1 ) then
					return;
				end
			end
		else
			local classesByRole = displayData.classesByRole[role];
			for class, num in pairs(classesByRole) do
				for k=1, num do
					local icon = self.Icons[iconIndex];
					icon.RoleIconWithBackground:Hide();
					icon.RoleIcon:Show();
					icon.RoleIcon:SetAtlas(LFG_LIST_GROUP_DATA_ATLASES_BORDERLESS[role], false);
					icon.ClassCircle:Show();
					icon.ClassCircle:SetAtlas("groupfinder-icon-class-color-"..class, false);
					
					iconIndex = iconIndex - 1;
					if ( iconIndex < 1 ) then
						return;
					end
				end
			end
		end
	end

	for i=1, iconIndex do
		local icon = self.Icons[i];
		icon:Show();
		icon.RoleIconWithBackground:Show();
		icon.RoleIconWithBackground:SetAtlas("groupfinder-icon-emptyslot", false);
		icon.ClassCircle:Hide();
		icon.RoleIcon:Hide();
	end
end

function LFGListGroupDataDisplayPlayerCount_Update(self, displayData, disabled)
	local numPlayers = displayData.TANK + displayData.HEALER + displayData.DAMAGER + displayData.NOROLE;

	local color = disabled and LFG_LIST_DELISTED_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
	self.Count:SetText(numPlayers);
	self.Count:SetTextColor(color.r, color.g, color.b);
	self.Icon:SetDesaturated(disabled);
	self.Icon:SetAlpha(disabled and 0.5 or 1);
end

-------------------------------------------------------
----------Requirement functions
-------------------------------------------------------
function LFGListRequirement_Validate(self, text)
	if ( self.validateFunc ) then
		self.warningText = self:validateFunc(text);
		self.WarningFrame:SetShown(self.warningText);
		self.CheckButton:SetShown(not self.warningText);
	end
	LFGListEntryCreation_UpdateValidState(self:GetParent());
end

-------------------------------------------------------
----------Utility functions
-------------------------------------------------------
function LFGListUtil_AugmentWithBest(filters, categoryID, groupID, activityID)
	local myNumMembers = math.max(GetNumGroupMembers(LE_PARTY_CATEGORY_HOME), 1);
	local myItemLevel = GetAverageItemLevel();
	if ( not activityID ) then
		--Find the best activity by iLevel and recommended flag
		local activities = C_LFGList.GetAvailableActivities(categoryID, groupID, filters);
		local bestItemLevel, bestRecommended, bestCurrentArea, bestMinLevel, bestMaxPlayers;
		for i=1, #activities do
			local activityInfo = C_LFGList.GetActivityInfoTable(activities[i]);
			local iLevel = activityInfo and activityInfo.ilvlSuggestion or 0;
			local isRecommended = bit.band(filters, Enum.LFGListFilter.Recommended) ~= 0;
			local currentArea = C_LFGList.GetActivityInfoExpensive(activities[i]);

			local usedItemLevel = myItemLevel;
			local isBetter = false;
			if ( not activityID ) then
				isBetter = true;
			elseif ( currentArea ~= bestCurrentArea ) then
				isBetter = currentArea;
			elseif ( bestRecommended ~= isRecommended ) then
				isBetter = isRecommended;
			elseif ( bestMinLevel ~= activityInfo.minLevel ) then
				isBetter = activityInfo.minLevel > bestMinLevel;
			elseif ( iLevel ~= bestItemLevel ) then
				isBetter = (iLevel > bestItemLevel and iLevel <= usedItemLevel) or
							(iLevel <= usedItemLevel and bestItemLevel > usedItemLevel) or
							(iLevel < bestItemLevel and iLevel > usedItemLevel);
			elseif ( (myNumMembers < activityInfo.maxNumPlayers) ~= (myNumMembers < bestMaxPlayers) ) then
				isBetter = myNumMembers < activityInfo.maxNumPlayers;
			end

			if ( isBetter ) then
				activityID = activities[i];
				bestItemLevel = iLevel;
				bestRecommended = isRecommended;
				bestCurrentArea = currentArea;
				bestMinLevel = activityInfo.minLevel;
				bestMaxPlayers = activityInfo.maxNumPlayers;
			end
		end
	end

	assert(activityID);

	--Update the categoryID and groupID with what we get from the activity
	local currentActivityInfo = C_LFGList.GetActivityInfoTable(activityID);
	if(not currentActivityInfo) then
		return;
	end

	--Update the filters if needed
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(currentActivityInfo.categoryID);

	-- This function may need to return the recommended or not-recommended state to determine the
	-- difficulties options. After a difficulty is selected, a 'nil' filter is passed to
	-- LFGListEntryCreation_Select, requiring us to fetch the filter from the activity info.
	-- If separateRecommended is not set, then this state is meaningless and we just return 0.
	local recFilter = 0;
	if ( categoryInfo and categoryInfo.separateRecommended ) then
		recFilter = bit.band(filters, bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.NotRecommended));

		if recFilter == 0 then
			recFilter = currentActivityInfo.filters;
		end
	end

	return recFilter, currentActivityInfo.categoryID, currentActivityInfo.groupFinderActivityGroupID, activityID;
end

function LFGListUtil_ValidateLevelReq(self, text)
	local myItemLevel = GetAverageItemLevel();
	if ( text ~= "" and tonumber(text) > myItemLevel) then
		return LFG_LIST_ILVL_ABOVE_YOURS;
	end
end

function LFGListUtil_ValidatePvPLevelReq(self, text)
	local _, _, avgItemLevelPvP = GetAverageItemLevel();
	if ( text ~= "" and tonumber(text) > avgItemLevelPvP) then
		return LFG_LIST_PVP_ILVL_ABOVE_YOURS;
	end
end

function LFGListUtil_ValidatePvpRatingReq(self, text)
	local selectedActivity = self:GetParent().selectedActivity;
	if(text ~= "" and selectedActivity and not C_LFGList.ValidateRequiredPvpRatingForActivity(selectedActivity, tonumber(text))) then
		return LFG_LIST_PVP_RATING_ABOVE_YOURS;
	end
end

function LFGListUtil_ValidateMythicPlusRatingReq(self, text)
	if(text ~= "" and not C_LFGList.ValidateRequiredDungeonScore(tonumber(text))) then
		return LFG_LIST_DUNGEON_SCORE_ABOVE_YOURS;
	end
end

function LFGListUtil_ValidateHonorLevelReq(self, text)
	local myHonorLevel = UnitHonorLevel("player");
	if (text ~= "" and tonumber(text) > myHonorLevel) then
		return LFG_LIST_HONOR_LEVEL_ABOVE_YOURS;
	end
end

-- TODO: Fix for Level Squish
function LFGListUtil_GetCurrentExpansion()
	if PVEFrame:TimerunningEnabled() then
		return LE_EXPANSION_MISTS_OF_PANDARIA;
	else
		return GetExpansionForLevel(UnitLevel("player")) or LE_EXPANSION_LEVEL_CURRENT;
	end
end

function LFGListUtil_GetDecoratedCategoryName(categoryName, filter, useColors)
	if ( filter == 0 ) then
		return categoryName;
	end

	local colorStart = "";
	local colorEnd = "";
	if ( useColors ) then
		colorStart = "|cffffffff";
		colorEnd = "|r";
	end

	local extraName = "";
	if ( filter == Enum.LFGListFilter.NotRecommended ) then
		extraName = LFG_LIST_LEGACY;
	elseif ( filter == Enum.LFGListFilter.Recommended ) then
		local exp = LFGListUtil_GetCurrentExpansion();
		extraName = _G["EXPANSION_NAME"..exp];
	end

	if(extraName ~= "") then
		return string.format(LFG_LIST_CATEGORY_FORMAT, categoryName, colorStart, extraName, colorEnd);
	else
		return categoryName;
	end
end

local roleRemainingKeyLookup = {
	[Enum.LFGRole.Tank] = "TANK_REMAINING",
	[Enum.LFGRole.Healer] = "HEALER_REMAINING",
	[Enum.LFGRole.Damage] = "DAMAGER_REMAINING",
};

local function HasRemainingSlotsForLocalPlayerRole(lfgSearchResultID)
	local roles = C_LFGList.GetSearchResultMemberCounts(lfgSearchResultID);
	if roles then
		local playerRole = GetSpecializationRoleEnum(GetSpecialization());
		if playerRole then
			local remainingRoleKey = roleRemainingKeyLookup[playerRole];
			if remainingRoleKey then
				return (roles[remainingRoleKey] or 0) > 0;
			end
		end
	end

	return false;
end

function LFGListUtil_SortSearchResultsCB(searchResultID1, searchResultID2)
	local searchResultInfo1 = C_LFGList.GetSearchResultInfo(searchResultID1);
	local searchResultInfo2 = C_LFGList.GetSearchResultInfo(searchResultID2);

	local hasRemainingRole1 = HasRemainingSlotsForLocalPlayerRole(searchResultID1);
	local hasRemainingRole2 = HasRemainingSlotsForLocalPlayerRole(searchResultID2);

	local _, appStatus1 = C_LFGList.GetApplicationInfo(searchResultID1);
	local _, appStatus2 = C_LFGList.GetApplicationInfo(searchResultID2);

	local isDeclined1 = IsDeclined(appStatus1);
	local isDeclined2 = IsDeclined(appStatus2);

	--sort declined to the bottom
	if LFGListFrame.declines then
		isDeclined1 = isDeclined1 or not not LFGListFrame.declines[searchResultInfo1.partyGUID];
		isDeclined2 = isDeclined2 or not not LFGListFrame.declines[searchResultInfo2.partyGUID];
	end

	if isDeclined1 ~= isDeclined2 then
		return isDeclined2;
	end

	-- Groups with your current role available are preferred
	if (hasRemainingRole1 ~= hasRemainingRole2) then
		return hasRemainingRole1;
	end

	--If one has more friends, do that one first
	if ( searchResultInfo1.numBNetFriends ~= searchResultInfo2.numBNetFriends ) then
		return searchResultInfo1.numBNetFriends > searchResultInfo2.numBNetFriends;
	end

	if ( searchResultInfo1.numCharFriends ~= searchResultInfo2.numCharFriends ) then
		return searchResultInfo1.numCharFriends > searchResultInfo2.numCharFriends;
	end

	if ( searchResultInfo1.numGuildMates ~= searchResultInfo2.numGuildMates ) then
		return searchResultInfo1.numGuildMates > searchResultInfo2.numGuildMates;
	end

	if ( searchResultInfo1.isWarMode ~= searchResultInfo2.isWarMode ) then
		return searchResultInfo1.isWarMode == C_PvP.IsWarModeDesired();
	end

	--If we aren't sorting by anything else, just go by ID
	return searchResultID1 < searchResultID2;
end

function LFGListUtil_SortSearchResults(self)
	table.sort(self.results, LFGListUtil_SortSearchResultsCB);
end

function LFGListUtil_SortApplicantsCB(applicantID1, applicantID2)
	local applicantInfo1 = C_LFGList.GetApplicantInfo(applicantID1);
	local applicantInfo2 = C_LFGList.GetApplicantInfo(applicantID2);

	--New items go to the bottom
	if ( applicantInfo1.isNew ~= applicantInfo2.isNew ) then
		return applicantInfo2.isNew;
	end

	return applicantInfo1.displayOrderID < applicantInfo2.displayOrderID;
end

function LFGListUtil_SortApplicants(applicants)
	table.sort(applicants, LFGListUtil_SortApplicantsCB);
end

function LFGListUtil_IsAppEmpowered()
	return not IsInGroup(LE_PARTY_CATEGORY_HOME) or UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME);
end

function LFGListUtil_IsEntryEmpowered()
	return UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) or UnitIsGroupAssistant("player", LE_PARTY_CATEGORY_HOME);
end

function LFGListUtil_CanSearchForGroup()
	local hasActiveEntry = C_LFGList.HasActiveEntryInfo();
	local canSearch = not hasActiveEntry or (LFGListUtil_IsAppEmpowered() or LFGListUtil_IsEntryEmpowered());
	return canSearch;
end

function LFGListUtil_CanListGroup()
	return LFGListUtil_IsAppEmpowered();
end

function LFGListUtil_AppendStatistic(label, value, title, lastTitle)
	if ( title ~= lastTitle ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(title, 1, 1, 1);
	end

	GameTooltip:AddLine(string.format(label, value));
end

function LFGList_ReportListing(searchResultID, leaderName)
	local reportInfo = ReportInfo:CreateReportInfoFromType(Enum.ReportType.GroupFinderPosting);
	reportInfo:SetGroupFinderSearchResultID(searchResultID);
	ReportFrame:InitiateReport(reportInfo, leaderName);
end

function LFGList_ReportAdvertisement(searchResultID, leaderName)
	local reportInfo = ReportInfo:CreateReportInfoFromType(Enum.ReportType.GroupFinderPosting);
	reportInfo:SetGroupFinderSearchResultID(searchResultID);
	ReportFrame:SetMinorCategoryFlag(Enum.ReportMinorCategory.Advertisement, true);
	ReportFrame:SetMajorType(Enum.ReportMajorCategory.InappropriateCommunication);
	local sendReportWithoutDialog = true;
	ReportFrame:InitiateReport(reportInfo, leaderName, nil, nil, sendReportWithoutDialog);
end

function LFGList_ReportApplicant(applicantID, applicantName)
	local reportInfo = ReportInfo:CreateReportInfoFromType(Enum.ReportType.GroupFinderApplicant);
	reportInfo:SetGroupFinderApplicantID(applicantID);
	ReportFrame:InitiateReport(reportInfo, applicantName);
end

function LFGListUtil_OpenBestWindow(toggle)
	local func = toggle and PVEFrame_ToggleFrame or PVEFrame_ShowFrame;
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	if ( activeEntryInfo ) then
		--Open to the window of our active activity
		local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID);
		if ( activityInfo and bit.band(activityInfo.filters, Enum.LFGListFilter.PvE) ~= 0 ) then
			func("GroupFinderFrame", "LFGListPVEStub");
		else
			func("PVPUIFrame", "LFGListPVPStub");
		end
	else
		--Open to the last window we had open
		if ( bit.band(LFGListFrame.baseFilters, Enum.LFGListFilter.PvE) ~= 0 ) then
			func("GroupFinderFrame", "LFGListPVEStub");
		else
			func("PVPUIFrame", "LFGListPVPStub");
		end
	end
end

function LFGListUtil_SortActivitiesByRelevancyCB(activityID1, activityID2)
	local activityInfo1 = C_LFGList.GetActivityInfoTable(activityID1);
	local activityInfo2 = C_LFGList.GetActivityInfoTable(activityID2);

	if(not activityInfo1 or not activityInfo2) then
		return false;
	end

	if ( activityInfo1.minLevel ~= activityInfo2.minLevel ) then
		return activityInfo1.minLevel > activityInfo2.minLevel;
	elseif ( activityInfo1.ilvlSuggestion ~= activityInfo2.ilvlSuggestion ) then
		local myILevel = GetAverageItemLevel();

		if ((activityInfo1.minLevel <= myILevel) ~= (activityInfo2.minLevel <= myILevel) ) then
			--If one is below our item level and the other above, choose the one we meet
			return activityInfo1.minLevel < myILevel;
		else
			--If both are above or both are below, choose the one closest to our iLevel
			return math.abs(activityInfo1.ilvlSuggestion - myILevel) < math.abs(activityInfo2.ilvlSuggestion - myILevel);
		end
	else
		return strcmputf8i(activityInfo1.fullName, activityInfo2.ilvlSuggestion) < 0;
	end
end

function LFGListUtil_SortActivitiesByRelevancy(activities)
	table.sort(activities, LFGListUtil_SortActivitiesByRelevancyCB);
end

LFG_LIST_ACTIVE_QUEUE_MESSAGE_EVENTS = {
	"LFG_LIST_ACTIVE_ENTRY_UPDATE",
	"LFG_LIST_SEARCH_RESULT_UPDATED",
	"UPDATE_BATTLEFIELD_STATUS",
	"LFG_UPDATE",
	"LFG_ROLE_CHECK_UPDATE",
	"LFG_PROPOSAL_UPDATE",
	"LFG_PROPOSAL_FAILED",
	"LFG_PROPOSAL_SUCCEEDED",
	"LFG_PROPOSAL_SHOW",
	"LFG_QUEUE_STATUS_UPDATE",
};

function LFGListUtil_GetActiveQueueMessage(isApplication)
	--Check for applications if we're trying to list
	if ( not isApplication and select(2,C_LFGList.GetNumApplications()) > 0 ) then
		return CANNOT_DO_THIS_WITH_LFGLIST_APP;
	end

	--Check for listings if we have an application
	if ( isApplication and C_LFGList.HasActiveEntryInfo() ) then
		return CANNOT_DO_THIS_WHILE_LFGLIST_LISTED;
	end

	--Check all LFG categories
	for category=1, NUM_LE_LFG_CATEGORYS do
		local mode = GetLFGMode(category);
		if ( mode ) then
			if ( mode == "lfgparty" ) then
				return CANNOT_DO_THIS_IN_LFG_PARTY;
			elseif ( mode == "rolecheck" or (mode and not isApplication) ) then
				return CANNOT_DO_THIS_IN_PVE_QUEUE;
			end
		end
	end

	--Check PvP role check
	local inProgress, _, _, _, _, isBattleground = GetLFGRoleUpdate();
	if ( inProgress ) then
		return isBattleground and CANNOT_DO_THIS_WHILE_PVP_QUEUING or CANNOT_DO_THIS_WHILE_PVE_QUEUING;
	end

	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch, suspend, _, _, _, _, _, _, isSoloQueue = GetBattlefieldStatus(i);
		if ( status and status ~= "none" ) then
			if not isSoloQueue or status == "active" then
				return CANNOT_DO_THIS_IN_BATTLEGROUND;
			end
		end
	end
end

local LFG_LIST_INACTIVE_STATUSES = {
	cancelled = true,
	failed = true,
	declined = true,
	timedout = true,
	invitedeclined = true,
}

function LFGListUtil_IsStatusInactive(status)
	return LFG_LIST_INACTIVE_STATUSES[status];
end

function LFGListUtil_SetAutoAccept(autoAccept)
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	if activeEntryInfo then
		C_LFGList.CopyActiveEntryInfoToCreationFields();
		C_LFGList.UpdateListing(activeEntryInfo.activityID, activeEntryInfo.requiredItemLevel, activeEntryInfo.requiredHonorLevel, autoAccept, activeEntryInfo.privateGroup, activeEntryInfo.questID);
	end
end

LFG_LIST_UTIL_SUPPRESS_AUTO_ACCEPT_LINE = 1;
LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE = 2;

function LFGListUtil_SetSearchEntryTooltip(tooltip, resultID, autoAcceptOption)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID, nil, searchResultInfo.isWarMode);
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID);
	local allowsCrossFaction = (categoryInfo and categoryInfo.allowCrossFaction) and (activityInfo and activityInfo.allowCrossFaction);

	local memberCounts = C_LFGList.GetSearchResultMemberCounts(resultID);
	tooltip:SetText(searchResultInfo.name, 1, 1, 1, true);
	tooltip:AddLine(activityInfo.fullName);

	if (searchResultInfo.playstyle and searchResultInfo.playstyle > 0) then
		local playstyleString = C_LFGList.GetPlaystyleString(searchResultInfo.playstyle, activityInfo);
		if(not searchResultInfo.crossFactionListing and allowsCrossFaction) then
			GameTooltip_AddColoredLine(tooltip, GROUP_FINDER_CROSS_FACTION_LISTING_WITH_PLAYSTLE:format(playstyleString,  FACTION_STRINGS[searchResultInfo.leaderFactionGroup]), GREEN_FONT_COLOR);
		else
			GameTooltip_AddColoredLine(tooltip, playstyleString, GREEN_FONT_COLOR);
		end
	elseif(not searchResultInfo.crossFactionListing and allowsCrossFaction) then
		GameTooltip_AddColoredLine(tooltip, GROUP_FINDER_CROSS_FACTION_LISTING_WITHOUT_PLAYSTLE:format(FACTION_STRINGS[searchResultInfo.leaderFactionGroup]), GREEN_FONT_COLOR);
	end
	if ( searchResultInfo.comment and searchResultInfo.comment == "" and searchResultInfo.questID ) then
		searchResultInfo.comment = LFGListUtil_GetQuestDescription(searchResultInfo.questID);
	end
	if ( searchResultInfo.comment ~= "" ) then
		tooltip:AddLine(string.format(LFG_LIST_COMMENT_FORMAT, searchResultInfo.comment), LFG_LIST_COMMENT_FONT_COLOR.r, LFG_LIST_COMMENT_FONT_COLOR.g, LFG_LIST_COMMENT_FONT_COLOR.b, true);
	end
	tooltip:AddLine(" ");
	if ( searchResultInfo.requiredDungeonScore and searchResultInfo.requiredDungeonScore > 0 ) then
		tooltip:AddLine(GROUP_FINDER_MYTHIC_RATING_REQ_TOOLTIP:format(searchResultInfo.requiredDungeonScore));
	end
	if ( searchResultInfo.requiredPvpRating and searchResultInfo.requiredPvpRating > 0 ) then
		tooltip:AddLine(GROUP_FINDER_PVP_RATING_REQ_TOOLTIP:format(searchResultInfo.requiredPvpRating));
	end
	if ( searchResultInfo.requiredItemLevel > 0 ) then
		if(activityInfo.isPvpActivity) then
			tooltip:AddLine(LFG_LIST_TOOLTIP_ILVL_PVP:format(searchResultInfo.requiredItemLevel));
		else
			tooltip:AddLine(LFG_LIST_TOOLTIP_ILVL:format(searchResultInfo.requiredItemLevel));
		end
	end
	if ( activityInfo.useHonorLevel and searchResultInfo.requiredHonorLevel > 0 ) then
		tooltip:AddLine(LFG_LIST_TOOLTIP_HONOR_LEVEL:format(searchResultInfo.requiredHonorLevel));
	end
	if ( searchResultInfo.voiceChat ~= "" ) then
		tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_VOICE_CHAT, searchResultInfo.voiceChat), nil, nil, nil, true);
	end
	if ( searchResultInfo.requiredItemLevel > 0 
		or (activityInfo.useHonorLevel and searchResultInfo.requiredHonorLevel > 0) 
		or searchResultInfo.voiceChat ~= ""
		or (searchResultInfo.requiredDungeonScore and searchResultInfo.requiredDungeonScore > 0) 
		or (searchResultInfo.requiredPvpRating and searchResultInfo.requiredPvpRating > 0) )
	then
		tooltip:AddLine(" ");
	end

	if ( searchResultInfo.leaderName ) then
		local leaderNameString = "";
		local factionString = searchResultInfo.leaderFactionGroup and FACTION_STRINGS[searchResultInfo.leaderFactionGroup];
		if(factionString and (UnitFactionGroup("player") ~= PLAYER_FACTION_GROUP[searchResultInfo.leaderFactionGroup])) then
			leaderNameString = LFG_LIST_TOOLTIP_LEADER_FACTION:format(searchResultInfo.leaderName, factionString);
		else
			leaderNameString = searchResultInfo.leaderName;
		end

		local leaderDungeonScoreInfo = searchResultInfo.leaderDungeonScoreInfo;

		local function WrapSpecificScoreColor(text, score)
			return (C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR):WrapTextInColorCode(text);
		end

		local overallColor = C_ChallengeMode.GetDungeonScoreRarityColor(searchResultInfo.leaderOverallDungeonScore or 0) or HIGHLIGHT_FONT_COLOR;

		if activityInfo.isMythicPlusActivity and searchResultInfo.leaderOverallDungeonScore then
			tooltip:AddDoubleLine(leaderNameString, overallColor:WrapTextInColorCode(searchResultInfo.leaderOverallDungeonScore))
			tooltip:AddDoubleLine(LFG_LIST_BEST_FOR_DUNGEON, MakeRunLevelWithIncrement(leaderDungeonScoreInfo).." "..WrapSpecificScoreColor(leaderDungeonScoreInfo.mapName, leaderDungeonScoreInfo.bestRunLevel));
			if searchResultInfo.leaderBestDungeonScoreInfo then
				tooltip:AddDoubleLine(LFG_LIST_BEST_RUN, MakeRunLevelWithIncrement(searchResultInfo.leaderBestDungeonScoreInfo).." "..WrapSpecificScoreColor(searchResultInfo.leaderBestDungeonScoreInfo.mapName, searchResultInfo.leaderBestDungeonScoreInfo.bestRunLevel));
			end
		else
			tooltip:AddLine(leaderNameString);
		end
	end

	if( activityInfo.isRatedPvpActivity and searchResultInfo.leaderPvpRatingInfo) then
		GameTooltip_AddNormalLine(tooltip, PVP_RATING_GROUP_FINDER:format(searchResultInfo.leaderPvpRatingInfo.activityName, searchResultInfo.leaderPvpRatingInfo.rating, PVPUtil.GetTierName(searchResultInfo.leaderPvpRatingInfo.tier)));
	end

	if ( searchResultInfo.leaderName or searchResultInfo.age > 0 ) then
		tooltip:AddLine(" ");
	end

	local memberInfoList = {};

	--enumerates both class and role
	if ( activityInfo.displayType == Enum.LFGListDisplayType.ClassEnumerate or activityInfo.displayType == Enum.LFGListDisplayType.RoleEnumerate ) then
		for i=1, searchResultInfo.numMembers do
			local role, class, classLocalized, specLocalized, isLeader = C_LFGList.GetSearchResultMemberInfo(resultID, i);

			if role then
				table.insert(memberInfoList, {role = role, class =  class, classLocalized = classLocalized, specLocalized = specLocalized, isLeader = isLeader});
			end
		end
	end

	-- If member info has been filled out for each member then display them individually. Otherwise just display member counts.
	if #memberInfoList == searchResultInfo.numMembers then
		local leaderIcon = CreateAtlasMarkup("groupfinder-icon-leader", 14, 9, 0, 0);
		tooltip:AddLine(MEMBERS_COLON);
		for i=1, searchResultInfo.numMembers do
			local memberInfo = memberInfoList[i];
			local classColor = RAID_CLASS_COLORS[memberInfo.class] or NORMAL_FONT_COLOR;
			local roleIcon = CreateAtlasMarkup(LFG_LIST_GROUP_DATA_ATLASES_BORDERLESS[memberInfo.role], 13, 13, 0, 0);
			local leaderString = memberInfo.isLeader and " "..leaderIcon or "";
			tooltip:AddLine(roleIcon.." "..string.format(LFG_LIST_TOOLTIP_CLASS_ROLE, memberInfo.classLocalized, memberInfo.specLocalized)..leaderString, classColor.r, classColor.g, classColor.b);
		end
	else
		tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_MEMBERS, searchResultInfo.numMembers, memberCounts.TANK, memberCounts.HEALER, memberCounts.DAMAGER));
	end

	if ( searchResultInfo.numBNetFriends + searchResultInfo.numCharFriends + searchResultInfo.numGuildMates > 0 ) then
		tooltip:AddLine(" ");
		tooltip:AddLine(LFG_LIST_TOOLTIP_FRIENDS_IN_GROUP);
		tooltip:AddLine(LFGListSearchEntryUtil_GetFriendList(resultID), 1, 1, 1, true);
	end

	local completedEncounters = C_LFGList.GetSearchResultEncounterInfo(resultID);
	if ( completedEncounters and #completedEncounters > 0 ) then
		tooltip:AddLine(" ");
		tooltip:AddLine(LFG_LIST_BOSSES_DEFEATED);
		for i=1, #completedEncounters do
			tooltip:AddLine(completedEncounters[i], RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		end
	end

	autoAcceptOption = autoAcceptOption or LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE;

	if autoAcceptOption == LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE and searchResultInfo.autoAccept then
		tooltip:AddLine(" ");
		tooltip:AddLine(LFG_LIST_TOOLTIP_AUTO_ACCEPT, LIGHTBLUE_FONT_COLOR:GetRGB());
	end

	if ( searchResultInfo.isDelisted ) then
		tooltip:AddLine(" ");
		tooltip:AddLine(LFG_LIST_ENTRY_DELISTED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	end

	tooltip:Show();
end

function LFGListUtil_GetQuestCategoryData(questID)
	-- Do not allow searches if the quest name cannot be looked up.
	local questName = QuestUtils_GetQuestName(questID);

	if not questName then
		return;
	end

	local activityID = C_LFGList.GetActivityIDForQuestID(questID);
	if activityID then
		local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
		if(not activityInfo) then
			return;
		end
		local filters = activityInfo.filters;
		-- NOTE: There's an issue where filters will actually contain ALL of the filters for the given activity.
		-- This portion of the UI only cares about the filters for specific categories that get updated when the category buttons are added,
		-- and furthermore only cares about them when we're separating a single category into recommended and non-recommended.
		-- The baseFilters on the frame contain the rest of the required filters.
		-- To solve this so that category selection can be properly driven from the API, only use the filters that would be present on the button.
		-- Otherwise the selection will not work, and it won't be possible to create a group automatically.
		local categoryInfo = C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID);
		if categoryInfo.separateRecommended then
			if bit.bor(filters, Enum.LFGListFilter.Recommended) then
				filters = Enum.LFGListFilter.Recommended;
			elseif bit.bor(filters, Enum.LFGListFilter.NotRecommended) then
				filters = Enum.LFGListFilter.NotRecommended;
			else
				filters = 0;
			end
		else
			filters = 0;
		end

		return activityID, activityInfo.categoryID, filters, questName;
	end
end

function LFGListUtil_FindQuestGroup(questID, isFromGreenEyeButton)
	if C_LFGList.HasActiveEntryInfo() then
		if LFGListUtil_CanListGroup() then
			StaticPopup_Show("PREMADE_GROUP_SEARCH_DELIST_WARNING", nil, nil, questID);
		else
			LFGListUtil_OpenBestWindow();
		end
	else
		LFGListFrame_BeginFindQuestGroup(LFGListFrame, questID, isFromGreenEyeButton);
	end
end

function LFGListUtil_FindScenarioGroup(scenarioID, shouldShowCreateGroupButton)
	if C_LFGList.HasActiveEntryInfo() then
		if LFGListUtil_CanListGroup() then
			StaticPopup_Show("PREMADE_SCENARIO_GROUP_SEARCH_DELIST_WARNING", nil, nil, scenarioID);
		else
			LFGListUtil_OpenBestWindow();
		end
	else
		LFGListFrame_BeginFindScenarioGroup(LFGListFrame, scenarioID, shouldShowCreateGroupButton);
	end
end

function LFGListUtil_GetQuestDescription(questID)
	local descriptionFormat = AUTO_GROUP_CREATION_NORMAL_QUEST;
	if ( QuestUtils_IsQuestWorldQuest(questID) ) then
		descriptionFormat = AUTO_GROUP_CREATION_WORLD_QUEST;
	end

	return descriptionFormat:format(QuestUtils_GetQuestName(questID));
end



-------------------------------------------------------
----------Edit Box functions
-------------------------------------------------------


function LFGListEditBox_AddToTabCategory(self, tabCategory)
	self.tabCategory = tabCategory;
	local cat = LFG_LIST_EDIT_BOX_TAB_CATEGORIES[tabCategory];
	if ( not cat ) then
		cat = {};
		LFG_LIST_EDIT_BOX_TAB_CATEGORIES[tabCategory] = cat;
	end
	self.tabCategoryIndex = #cat+1;
	cat[self.tabCategoryIndex] = self;
end

function LFGListEditBox_OnTabPressed(self)
	if ( self.tabCategory ) then
		local offset = IsShiftKeyDown() and -1 or 1;
		local cat = LFG_LIST_EDIT_BOX_TAB_CATEGORIES[self.tabCategory];
		if ( cat ) then
			--It's times like this when I wish Lua was 0-based...
			cat[((self.tabCategoryIndex - 1 + offset + #cat) % #cat) + 1]:SetFocus();
		end
	end
end

LFGAuthenticatorMessagingMixin = {}
function LFGAuthenticatorMessagingMixin:DisplayTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, LFG_AUTHENTICATOR_BUTTON_TOOLTIP);
	GameTooltip:Show();
end

function LFGAuthenticatorMessagingMixin:DisplayStaticPopup()
	StaticPopup_Show("GROUP_FINDER_AUTHENTICATOR_POPUP");
end

LFGEditBoxMixin = CreateFromMixins(LFGAuthenticatorMessagingMixin);
function LFGEditBoxMixin:AddToTabCategory(tabCategory, editBox)
	local addToTab = editBox or self;
	LFGListEditBox_AddToTabCategory(addToTab, tabCategory);
end

function LFGEditBoxMixin:OnLoad()
	if ( self.tabCategory ) then
		self:AddToTabCategory(self.tabCategory);
	end
end

function LFGEditBoxMixin:GetSelectedActivityID()
	return self:GetParent().selectedActivity or self:GetParent():GetParent().selectedActivity;
end

function LFGEditBoxMixin:OnShow()
	local isAccountSecured = C_LFGList.IsPlayerAuthenticatedForLFG(self:GetSelectedActivityID());
	if(self:GetParent().numeric or isAccountSecured) then
		self:SetEnabled(true);
		self.LockButton:Hide();
	else
		self:SetEnabled(false);
		self.LockButton:SetShown(not self:GetParent().hideLockButton);
	end
	self.editBoxEnabled = self:IsEnabled();
end

function LFGEditBoxMixin:OnEnter()
	if(not C_LFGList.IsPlayerAuthenticatedForLFG(self:GetSelectedActivityID()) and not self.editBoxEnabled) then
		self:DisplayTooltip();
	end
end

function LFGEditBoxMixin:OnMouseDown(button)

	if(not C_LFGList.IsPlayerAuthenticatedForLFG(self:GetSelectedActivityID()) and not self.editBoxEnabled) then
		self:DisplayStaticPopup();
	end
end

function LFGEditBoxMixin:OnTabPressed()
	LFGListEditBox_OnTabPressed(self);
end

LFGListLockButtonMixin = CreateFromMixins(LFGAuthenticatorMessagingMixin);

function LFGListLockButtonMixin:OnClick()
	self:DisplayStaticPopup();
end

function LFGListLockButtonMixin:OnEnter()
	self:DisplayTooltip();
end

LFGListCreationNameMixin = CreateFromMixins(LFGEditBoxMixin);

function LFGListCreationNameMixin:OnShow()
	LFGEditBoxMixin.OnShow(self);
	
	local isAccountSecured = C_LFGList.IsPlayerAuthenticatedForLFG(self:GetParent().selectedActivity);
	if not isAccountSecured then
		self:SetSecurityDisablePaste();
	end
end

LFGListCreationDescriptionMixin = CreateFromMixins(LFGEditBoxMixin);

function LFGListCreationDescriptionMixin:OnLoad()
	StoreSecureReference("LFGListCreationDescription", self.EditBox);
	self.EditBox:SetSecurityDisableSetText();
	self:AddToTabCategory("ENTRY_CREATION", self.EditBox);
	self.EditBox:SetScript("OnTabPressed", LFGListEditBox_OnTabPressed);
	self.EditBox:EnableMouse(false);
	InputScrollFrame_OnLoad(self);
end

function LFGListCreationDescriptionMixin:OnShow()
	local isAccountSecured = C_LFGList.IsPlayerAuthenticatedForLFG(self:GetParent().selectedActivity);

	if not isAccountSecured then
		self.EditBox:SetSecurityDisablePaste();
	end

	self.EditBox.Instructions:SetText(isAccountSecured and DESCRIPTION_OF_YOUR_GROUP or LFG_AUTHENTICATOR_DESCRIPTION_BOX);
	self.EditBox:SetEnabled(isAccountSecured);
	self.LockButton:SetShown(not isAccountSecured);
	self.editBoxEnabled = isAccountSecured;
end

LFGListCreateGroupDisabledStateButtonMixin = CreateFromMixins(LFGAuthenticatorMessagingMixin);

function LFGListCreateGroupDisabledStateButtonMixin:OnClick()
	if(not C_LFGList.IsPlayerAuthenticatedForLFG(self:GetParent().selectedActivity)) then
		self:DisplayStaticPopup();
	end
end

function LFGListCreateGroupDisabledStateButtonMixin:OnEnter()
	local parentErrorText = self:GetParent().errorText;
	if(parentErrorText) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddNormalLine(GameTooltip, parentErrorText);
		GameTooltip:Show();
	end
end

LFGListSearchBackToGroupButtonMixin = { };

function LFGListSearchBackToGroupButtonMixin:OnClick()
	local frame = self:GetParent():GetParent();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	LFGListFrame_SetActivePanel(frame, frame.ApplicationViewer);
end

LFGListSearchBackButtonMixin = { };

function LFGListSearchBackButtonMixin:OnClick()
	local frame = self:GetParent():GetParent();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	LFGListFrame_SetActivePanel(frame, frame.CategorySelection);
	self:GetParent().shouldAlwaysShowCreateGroupButton = false;
end
