-------------------------------------------------------
----------Constants
-------------------------------------------------------
MAX_LFG_LIST_APPLICATIONS = 5;
MAX_LFG_LIST_SEARCH_AUTOCOMPLETE_ENTRIES = 6;
MAX_LFG_LIST_GROUP_DROPDOWN_ENTRIES = 17;
LFG_LIST_DELISTED_FONT_COLOR = {r=0.3, g=0.3, b=0.3};
LFG_LIST_COMMENT_FONT_COLOR = {r=0.6, g=0.6, b=0.6};

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
}

LFG_LIST_GROUP_DATA_ATLASES = {
	--Roles
	TANK = "groupfinder-icon-role-large-tank",
	HEALER = "groupfinder-icon-role-large-heal",
	DAMAGER = "groupfinder-icon-role-large-dps",
};

--Fill out classes
for i=1, #CLASS_SORT_ORDER do
	LFG_LIST_GROUP_DATA_ATLASES[CLASS_SORT_ORDER[i]] = "groupfinder-icon-class-"..string.lower(CLASS_SORT_ORDER[i]);
end

LFG_LIST_GROUP_DATA_ROLE_ORDER = { "TANK", "HEALER", "DAMAGER" };
LFG_LIST_GROUP_DATA_CLASS_ORDER = CLASS_SORT_ORDER;

StaticPopupDialogs["LFG_LIST_INVITING_CONVERT_TO_RAID"] = {
	text = LFG_LIST_CONVERT_TO_RAID_WARNING,
	button1 = INVITE,
	button2 = CANCEL,
	OnAccept = function(self, applicantID) ConvertToRaid(); C_LFGList.InviteApplicant(applicantID) end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

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
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("UNIT_CONNECTION");
	for i=1, #LFG_LIST_ACTIVE_QUEUE_MESSAGE_EVENTS do
		self:RegisterEvent(LFG_LIST_ACTIVE_QUEUE_MESSAGE_EVENTS[i]);
	end
	LFGListFrame_SetBaseFilters(self, LE_LFG_LIST_FILTER_PVE);
	LFGListFrame_SetActivePanel(self, self.NothingAvailable);

	self.EventsInBackground = {
		LFG_LIST_SEARCH_FAILED = { self.SearchPanel };
	};
end

function LFGListFrame_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_AVAILABILITY_UPDATE" or event == "TRIAL_STATUS_UPDATE") then
		LFGListFrame_FixPanelValid(self);
	elseif ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		local createdNew = ...;
		LFGListFrame_FixPanelValid(self);	--If our current panel isn't valid, change it.

		if ( C_LFGList.GetActiveEntryInfo() ) then
			self.EntryCreation.WorkingCover:Hide();
		else
			LFGListFrame_CheckPendingQuestIDSearch(self);
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
			local autoAccept = select(9, C_LFGList.GetActiveEntryInfo());
			local numPings = nil;
			if ( not isLeader ) then
				numPings = 6;
			end
			--Non-leaders don't get another ping until they open the panel or we reset the count to 0
			if ( isLeader or not self.stopAssistPings ) then
				if ( autoAccept ) then
					--Check if we would be auto-inviting more people if we were in a raid
					if ( not IsInRaid(LE_PARTY_CATEGORY_HOME) and
					GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) + C_LFGList.GetNumInvitedApplicantMembers() + C_LFGList.GetNumPendingApplicantMembers() > (MAX_PARTY_MEMBERS+1) ) then
						if ( self.displayedAutoAcceptConvert ) then
							QueueStatusMinimapButton_SetGlowLock(QueueStatusMinimapButton, "lfglist-applicant", true, numPings);
							self.stopAssistPings = true;
						else
							self.displayedAutoAcceptConvert = true;
							StaticPopup_Show("LFG_LIST_AUTO_ACCEPT_CONVERT_TO_RAID");
						end
					end
				elseif ( not self:IsVisible() ) then
					QueueStatusMinimapButton_SetGlowLock(QueueStatusMinimapButton, "lfglist-applicant", true, numPings);
					self.stopAssistPings = true;
				end
			end
		end
	elseif ( event == "LFG_LIST_APPLICANT_UPDATED" ) then
		local numApps, numActiveApps = C_LFGList.GetNumApplicants();
		if ( numActiveApps == 0 ) then
			QueueStatusMinimapButton_SetGlowLock(QueueStatusMinimapButton, "lfglist-applicant", false);
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
		local id, newStatus, oldStatus = ...;
		if ( newStatus == "declined" ) then
			local info = ChatTypeInfo["SYSTEM"];
			local id, activity, name = C_LFGList.GetSearchResultInfo(id);
			DEFAULT_CHAT_FRAME:AddMessage(string.format(LFG_LIST_APP_DECLINED_MESSAGE, name), info.r, info.g, info.b);
		elseif ( newStatus == "declined_full" ) then
			local info = ChatTypeInfo["SYSTEM"];
			local id, activity, name = C_LFGList.GetSearchResultInfo(id);
			DEFAULT_CHAT_FRAME:AddMessage(string.format(LFG_LIST_APP_DECLINED_FULL_MESSAGE, name), info.r, info.g, info.b);
		elseif ( newStatus == "declined_delisted" ) then
			local info = ChatTypeInfo["SYSTEM"];
			local id, activity, name = C_LFGList.GetSearchResultInfo(id);
			DEFAULT_CHAT_FRAME:AddMessage(string.format(LFG_LIST_APP_DECLINED_DELISTED_MESSAGE, name), info.r, info.g, info.b);
		elseif ( newStatus == "timedout" ) then
			local info = ChatTypeInfo["SYSTEM"];
			local id, activity, name = C_LFGList.GetSearchResultInfo(id);
			DEFAULT_CHAT_FRAME:AddMessage(string.format(LFG_LIST_APP_TIMED_OUT_MESSAGE, name), info.r, info.g, info.b);
		end
	elseif ( event == "VARIABLES_LOADED" or event == "ADDON_LOADED" ) then
		if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_LFG_LIST) and UnitLevel("player") >= 90 ) then
			PremadeGroupsPvETutorialAlert:Show();
			if ( PremadeGroupsPvPTutorialAlert ) then
				PremadeGroupsPvPTutorialAlert:Show();
			end
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		if ( not IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
			self.displayedAutoAcceptConvert = false;
		end
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
	QueueStatusMinimapButton_SetGlowLock(QueueStatusMinimapButton, "lfglist-applicant", false);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function LFGListFrame_OnHide(self)
	LFGListFrame_SetPendingQuestIDSearch(self, nil);
	LFGListEntryCreation_ClearAutoCreateMode(self.EntryCreation);
end

function LFGListFrame_SetActivePanel(self, panel)
	if ( self.activePanel ) then
		self.activePanel:Hide();
	end
	self.activePanel = panel;
	self.activePanel:Show();
end

function LFGListFrame_IsPanelValid(self, panel)
	local listed = C_LFGList.GetActiveEntryInfo();

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
	local listed = C_LFGList.GetActiveEntryInfo();

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
	if questID and not C_LFGList.GetActiveEntryInfo() then
		LFGListFrame_SetPendingQuestIDSearch(self, nil);
		
		if issecure() then
			LFGListFrame_BeginFindQuestGroup(self, questID);
		else
			StaticPopup_Show("PREMADE_GROUP_INSECURE_SEARCH", QuestUtils_GetQuestName(questID), nil, questID);
		end
	end
end

function LFGListFrame_GetPendingQuestIDSearch(self)
	return self.pendingQuestIDSearch;
end

function LFGListFrame_SetPendingQuestIDSearch(self, questID)
	self.pendingQuestIDSearch = questID;
end

function LFGListFrame_BeginFindQuestGroup(self, questID)
	local activityID, categoryID, filters, questName = LFGListUtil_GetQuestCategoryData(questID);

	if not activityID then
		return;
	end

	if C_LFGList.GetActiveEntryInfo() then
		if LFGListUtil_CanListGroup() then
			C_LFGList.RemoveListing();
			LFGListFrame_SetPendingQuestIDSearch(self, questID);
		end
		return;
	end

	PVEFrame_ShowFrame("GroupFinderFrame", LFGListPVEStub);

	local panel = self.CategorySelection;
	LFGListCategorySelection_SelectCategory(panel, categoryID, filters);
	LFGListCategorySelection_StartFindGroup(panel, questName);
	LFGListEntryCreation_SetAutoCreateMode(panel:GetParent().EntryCreation, "quest", activityID, questID);
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
		local name, separateRecommended = C_LFGList.GetCategoryInfo(categoryID);

		if ( separateRecommended ) then
			nextBtn, isSelected = LFGListCategorySelection_AddButton(self, nextBtn, categoryID, LE_LFG_LIST_FILTER_RECOMMENDED);
			hasSelected = hasSelected or isSelected;
			nextBtn, isSelected = LFGListCategorySelection_AddButton(self, nextBtn, categoryID, LE_LFG_LIST_FILTER_NOT_RECOMMENDED);
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

	local name, separateRecommended = C_LFGList.GetCategoryInfo(categoryID);

	local button = self.CategoryButtons[btnIndex];
	if ( not button ) then
		self.CategoryButtons[btnIndex] = CreateFrame("BUTTON", nil, self, "LFGListCategoryTemplate");
		self.CategoryButtons[btnIndex]:SetPoint("TOP", self.CategoryButtons[btnIndex - 1], "BOTTOM", 0, -3);
		button = self.CategoryButtons[btnIndex];
	end

	button:SetText(LFGListUtil_GetDecoratedCategoryName(name, filters, true));
	button.categoryID = categoryID;
	button.filters = filters;

	local atlasName = nil;
	if ( bit.band(allFilters, LE_LFG_LIST_FILTER_RECOMMENDED) ~= 0 ) then
		atlasName = "groupfinder-button-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "raids").."-"..LFG_LIST_PER_EXPANSION_TEXTURES[LFGListUtil_GetCurrentExpansion()];
	elseif ( bit.band(allFilters, LE_LFG_LIST_FILTER_NOT_RECOMMENDED) ~= 0 ) then
		atlasName = "groupfinder-button-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "raids").."-"..LFG_LIST_PER_EXPANSION_TEXTURES[math.max(0,LFGListUtil_GetCurrentExpansion() - 1)];
	else
		atlasName = "groupfinder-button-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "questing");
	end

	local suffix = "";
	if ( bit.band(allFilters, LE_LFG_LIST_FILTER_PVE) ~= 0 ) then
		suffix = "-pve";
	elseif ( bit.band(allFilters, LE_LFG_LIST_FILTER_PVP) ~= 0 ) then
		suffix = "-pvp";
	end

	--Try with the suffix and then without it
	if ( not button.Icon:SetAtlas(atlasName..suffix) ) then
		button.Icon:SetAtlas(atlasName);
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

function LFGListCategorySelection_StartFindGroup(self, searchText)
	local baseFilters = self:GetParent().baseFilters;

	local searchPanel = self:GetParent().SearchPanel;
	LFGListSearchPanel_Clear(searchPanel);
	searchPanel.SearchBox:SetText(searchText or "");
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
	LFGListUtil_SetUpDropDown(self, self.CategoryDropDown, LFGListEntryCreation_PopulateCategories, LFGListEntryCreation_OnCategorySelected);
	LFGListUtil_SetUpDropDown(self, self.GroupDropDown, LFGListEntryCreation_PopulateGroups, LFGListEntryCreation_OnGroupSelected);
	LFGListUtil_SetUpDropDown(self, self.ActivityDropDown, LFGListEntryCreation_PopulateActivities, LFGListEntryCreation_OnActivitySelected);
	LFGListEntryCreation_SetBaseFilters(self, 0);
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
end

function LFGListEntryCreation_Show(self, baseFilters, selectedCategory, selectedFilters)
	--If this was what the player selected last time, just leave it filled out with the same info.
	--Also don't save it for categories that try to set it to the current area.
	local _, _, _, preferCurrentArea = C_LFGList.GetCategoryInfo(selectedCategory);
	local keepOldData = not preferCurrentArea and self.selectedCategory == selectedCategory and baseFilters == self.baseFilters and self.selectedFilters == selectedFilters;
	LFGListEntryCreation_SetBaseFilters(self, baseFilters);
	if ( not keepOldData ) then
		LFGListEntryCreation_Clear(self);
		LFGListEntryCreation_Select(self, selectedFilters, selectedCategory);
	end
	LFGListEntryCreation_SetEditMode(self, false);

	LFGListEntryCreation_UpdateValidState(self);

	LFGListFrame_SetActivePanel(self:GetParent(), self);
	self.Name:SetFocus();

	LFGListEntryCreation_CheckAutoCreate(self);
end

function LFGListEntryCreation_Clear(self)
	--Clear selections
	self.selectedCategory = nil;
	self.selectedGroup = nil;
	self.selectedActivity = nil;
	self.selectedFilters = nil;

	--Reset widgets
	C_LFGList.ClearCreationTextFields();
	self.ItemLevel.CheckButton:SetChecked(false);
	self.ItemLevel.EditBox:SetText("");
	self.HonorLevel.CheckButton:SetChecked(false);
	self.HonorLevel.EditBox:SetText("");
	self.VoiceChat.CheckButton:SetChecked(false);
	--self.VoiceChat.EditBox:SetText(""); --Cleared in ClearCreationTextFields
	self.PrivateGroup.CheckButton:SetChecked(false);

	self.ActivityFinder:Hide();
end

function LFGListEntryCreation_ClearFocus(self)
	self.Name:ClearFocus();
	self.ItemLevel.EditBox:ClearFocus();
	self.HonorLevel.EditBox:ClearFocus();
	self.VoiceChat.EditBox:ClearFocus();
	self.Description.EditBox:ClearFocus();
end

--This function accepts any or all of categoryID, groupId, and activityID
function LFGListEntryCreation_Select(self, filters, categoryID, groupID, activityID)
	filters, categoryID, groupID, activityID = LFGListUtil_AugmentWithBest(bit.bor(self.baseFilters,filters or 0), categoryID, groupID, activityID);
	self.selectedCategory = categoryID;
	self.selectedGroup = groupID;
	self.selectedActivity = activityID;
	self.selectedFilters = filters;

	--Update the category dropdown
	local categoryName, _, autoChoose = C_LFGList.GetCategoryInfo(categoryID);
	UIDropDownMenu_SetText(self.CategoryDropDown, LFGListUtil_GetDecoratedCategoryName(categoryName, filters, false));

	--Update the activity dropdown
	local _, shortName, _, _, iLevel, _, _, _, _, _, useHonorLevel = C_LFGList.GetActivityInfo(activityID);
	UIDropDownMenu_SetText(self.ActivityDropDown, shortName);

	--Update the group dropdown. If the group dropdown is showing an activity, hide the activity dropdown
	local groupName = C_LFGList.GetActivityGroupInfo(groupID);
	UIDropDownMenu_SetText(self.GroupDropDown, groupName or shortName);
	self.ActivityDropDown:SetShown(groupName and not autoChoose);
	self.GroupDropDown:SetShown(not autoChoose);

	--Update the recommended item level box
	if ( iLevel ~= 0 ) then
		self.ItemLevel.EditBox.Instructions:SetFormattedText(LFG_LIST_RECOMMENDED_ILVL, iLevel);
	else
		self.ItemLevel.EditBox.Instructions:SetText(LFG_LIST_ITEM_LEVEL_INSTR_SHORT);
	end

	if ( useHonorLevel ) then
		self.HonorLevel:Show();
		self.VoiceChat:SetPoint("TOPLEFT", self.HonorLevel, "BOTTOMLEFT", 0, -3);
	else
		self.HonorLevel:Hide();
		self.VoiceChat:SetPoint("TOPLEFT", self.ItemLevel, "BOTTOMLEFT", 0, -3);
	end

	LFGListRequirement_Validate(self.ItemLevel, self.ItemLevel.EditBox:GetText());
	if ( useHonorLevel ) then
		LFGListRequirement_Validate(self.HonorLevel, self.HonorLevel.EditBox:GetText());
	end
	LFGListEntryCreation_UpdateValidState(self);
end

function LFGListEntryCreation_PopulateCategories(self, dropDown, info)
	local categories = C_LFGList.GetAvailableCategories(self.baseFilters);
	for i=1, #categories do
		local categoryID = categories[i];
		local name, separateRecommended = C_LFGList.GetCategoryInfo(categoryID);
		if ( separateRecommended ) then
			LFGListEntryCreation_AddCategoryEntry(self, info, categoryID, name, LE_LFG_LIST_FILTER_RECOMMENDED);
			LFGListEntryCreation_AddCategoryEntry(self, info, categoryID, name, LE_LFG_LIST_FILTER_NOT_RECOMMENDED);
		else
			LFGListEntryCreation_AddCategoryEntry(self, info, categoryID, name, 0);
		end
	end
end

function LFGListEntryCreation_AddCategoryEntry(self, info, categoryID, name, filters)
	if ( filters ~= 0 and #C_LFGList.GetAvailableActivities(categoryID, nil, filters) == 0 ) then
		return;
	end

	info.text = LFGListUtil_GetDecoratedCategoryName(name, filters, false);
	info.value = categoryID;
	info.arg1 = filters;
	info.checked = (self.selectedCategory == categoryID and self.selectedFilters == filters);
	info.isRadio = true;
	UIDropDownMenu_AddButton(info);
end

function LFGListEntryCreation_OnCategorySelected(self, categoryID, filters)
	LFGListEntryCreation_Select(self, filters, categoryID, nil, nil);
end

function LFGListEntryCreation_PopulateGroups(self, dropDown, info)
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
			local filters = bit.bor(self.selectedFilters, self.baseFilters, LE_LFG_LIST_FILTER_RECOMMENDED);
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
	local activityOrder = activities[1] and select(10, C_LFGList.GetActivityInfo(activities[1]));

	local groupIndex, activityIndex = 1, 1;

	--Start merging
	for i=1, MAX_LFG_LIST_GROUP_DROPDOWN_ENTRIES do
		if ( not groupOrder and not activityOrder ) then
			break;
		end

		if ( activityOrder and (not groupOrder or activityOrder < groupOrder) ) then
			local activityID = activities[activityIndex];
			local name = select(ACTIVITY_RETURN_VALUES.shortName, C_LFGList.GetActivityInfo(activityID));

			info.text = name;
			info.value = activityID;
			info.arg1 = "activity";
			info.checked = (self.selectedActivity == activityID);
			info.isRadio = true;
			UIDropDownMenu_AddButton(info);

			activityIndex = activityIndex + 1;
			activityOrder = activities[activityIndex] and select(10, C_LFGList.GetActivityInfo(activities[activityIndex]));
		else
			local groupID = groups[groupIndex];
			local name = C_LFGList.GetActivityGroupInfo(groupID);

			info.text = name;
			info.value = groupID;
			info.arg1 = "group";
			info.checked = (self.selectedGroup == groupID);
			info.isRadio = true;
			UIDropDownMenu_AddButton(info);

			groupIndex = groupIndex + 1;
			groupOrder = groups[groupIndex] and select(2, C_LFGList.GetActivityGroupInfo(groups[groupIndex]));
		end
	end

	if ( #activities + #groups > MAX_LFG_LIST_GROUP_DROPDOWN_ENTRIES ) then
		useMore = true;
	end

	if ( useMore ) then
		info.text = LFG_LIST_MORE;
		info.value = nil;
		info.arg1 = "more";
		info.notCheckable = true;
		info.checked = false;
		info.isRadio = false;
		UIDropDownMenu_AddButton(info);
	end
end

function LFGListEntryCreation_OnGroupSelected(self, id, buttonType)
	if ( buttonType == "activity" ) then
		LFGListEntryCreation_Select(self, nil, nil, nil, id);
	elseif ( buttonType == "group" ) then
		LFGListEntryCreation_Select(self, self.selectedFilters, self.selectedCategory, id, nil);
	elseif ( buttonType == "more" ) then
		LFGListEntryCreationActivityFinder_Show(self.ActivityFinder, self.selectedCategory, nil, bit.bor(self.baseFilters, self.selectedFilters));
	end
end

function LFGListEntryCreation_PopulateActivities(self, dropDown, info)
	local useMore = self.selectedFilters == 0;

	local filters = bit.bor(self.baseFilters, self.selectedFilters);

	--Start out displaying everything
	local activities = C_LFGList.GetAvailableActivities(self.selectedCategory, self.selectedGroup, filters);

	--If we're displaying more than 5, see if we can just display recommended
	if ( useMore ) then
		if ( #activities > 5 ) then
			filters = bit.bor(filters, LE_LFG_LIST_FILTER_RECOMMENDED);
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

	for i=1, #activities do
		local activityID = activities[i];
		local shortName = select(ACTIVITY_RETURN_VALUES.shortName, C_LFGList.GetActivityInfo(activityID));

		info.text = shortName;
		info.value = activityID;
		info.arg1 = "activity";
		info.checked = (self.selectedActivity == activityID);
		info.isRadio = true;
		UIDropDownMenu_AddButton(info);
	end

	if ( useMore ) then
		info.text = LFG_LIST_MORE;
		info.value = nil;
		info.arg1 = "more";
		info.notCheckable = true;
		info.checked = false;
		info.isRadio = false;
		UIDropDownMenu_AddButton(info);
	end
end

function LFGListEntryCreation_OnActivitySelected(self, activityID, buttonType)
	if ( buttonType == "activity" ) then
		LFGListEntryCreation_Select(self, nil, nil, nil, activityID);
	elseif ( buttonType == "more" ) then
		LFGListEntryCreationActivityFinder_Show(self.ActivityFinder, self.selectedCategory, self.selectedGroup, bit.bor(self.baseFilters, self.selectedFilters));
	end
end

function LFGListEntryCreation_GetSanitizedName(self)
	return string.match(self.Name:GetText(), "^%s*(.-)%s*$");
end

function LFGListEntryCreation_ListGroupInternal(self, activityID, itemLevel, honorLevel, autoAccept, privateGroup, questID)
	if ( LFGListEntryCreation_IsEditMode(self) ) then
		local _;
		autoAccept, _, questID = select(9, C_LFGList.GetActiveEntryInfo());
		C_LFGList.UpdateListing(activityID, itemLevel, honorLevel, autoAccept, privateGroup, questID);
		LFGListFrame_SetActivePanel(self:GetParent(), self:GetParent().ApplicationViewer);
	else
		if(C_LFGList.CreateListing(activityID, itemLevel, honorLevel, autoAccept, privateGroup, questID)) then
			self.WorkingCover:Show();
			LFGListEntryCreation_ClearFocus(self);
		end
	end
end

function LFGListEntryCreation_ListGroup(self)
	local itemLevel = tonumber(self.ItemLevel.EditBox:GetText()) or 0;
	local honorLevel = tonumber(self.HonorLevel.EditBox:GetText()) or 0;
	local autoAccept = false;
	local privateGroup = self.PrivateGroup.CheckButton:GetChecked();

	LFGListEntryCreation_ListGroupInternal(self, self.selectedActivity, itemLevel, honorLevel, autoAccept, privateGroup);
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
	local honorLevel = 0;
	local autoAccept = true;
	local privateGroup = false;

	return activityID, itemLevel, honorLevel, autoAccept, privateGroup, questID;
end

function LFGListEntryCreation_GetAutoCreateData(self)
	if self.autoCreateActivityType == "quest" then
		return LFGListEntryCreation_GetAutoCreateDataQuest(self);
	end
end

function LFGListEntryCreation_CheckAutoCreate(self)
	if LFGListEntryCreation_IsAutoCreateMode(self) then
		C_LFGList.ClearCreationTextFields();
		LFGListEntryCreation_ListGroupInternal(self, LFGListEntryCreation_GetAutoCreateData(self));
		LFGListEntryCreation_ClearAutoCreateMode(self);
	end
end

function LFGListEntryCreation_UpdateValidState(self)
	local errorText;
	local maxPlayers, _, _, useHonorLevel = select(ACTIVITY_RETURN_VALUES.maxPlayers, C_LFGList.GetActivityInfo(self.selectedActivity));
	if ( maxPlayers > 0 and GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) >= maxPlayers ) then
		errorText = string.format(LFG_LIST_TOO_MANY_FOR_ACTIVITY, maxPlayers);
	elseif ( LFGListEntryCreation_GetSanitizedName(self) == "" ) then
		errorText = LFG_LIST_MUST_HAVE_NAME;
	elseif ( self.ItemLevel.warningText ) then
		errorText = self.ItemLevel.warningText;
	elseif ( useHonorLevel and self.HonorLevel.warningText ) then
		errorText = self.HonorLevel.warningText;
	else
		errorText = LFGListUtil_GetActiveQueueMessage(false);
	end

	self.ListGroupButton:SetEnabled(not errorText);
	self.ListGroupButton.errorText = errorText;
end


function LFGListEntryCreation_SetBaseFilters(self, baseFilters)
	self.baseFilters = baseFilters;
end

function LFGListEntryCreation_SetEditMode(self, editMode)
	self.editMode = editMode;
	if ( editMode ) then
		local active, activityID, ilvl, honorLevel, name, comment, voiceChat, duration, autoAccept, privateGroup, questID = C_LFGList.GetActiveEntryInfo();
		assert(active);

		--Update the dropdowns
		LFGListEntryCreation_Select(self, nil, nil, nil, activityID);
		UIDropDownMenu_DisableDropDown(self.CategoryDropDown);
		UIDropDownMenu_DisableDropDown(self.GroupDropDown);
		UIDropDownMenu_DisableDropDown(self.ActivityDropDown);

		--Update edit boxes
		C_LFGList.CopyActiveEntryInfoToCreationFields();
		self.Name:SetEnabled(questID == nil);
		if ( questID ) then
			self.Description.EditBox.Instructions:SetText(LFGListUtil_GetQuestDescription(questID));
		else
			self.Description.EditBox.Instructions:SetText(DESCRIPTION_OF_YOUR_GROUP);
		end
		self.ItemLevel.EditBox:SetText(ilvl ~= 0 and ilvl or "");
		self.HonorLevel.EditBox:SetText(honorLevel ~= 0 and honorLevel or "")
		self.PrivateGroup.CheckButton:SetChecked(privateGroup);

		self.ListGroupButton:SetText(DONE_EDITING);
	else
		UIDropDownMenu_EnableDropDown(self.CategoryDropDown);
		UIDropDownMenu_EnableDropDown(self.GroupDropDown);
		UIDropDownMenu_EnableDropDown(self.ActivityDropDown);
		self.ListGroupButton:SetText(LIST_GROUP);
		self.Name:Enable();
		self.Description.EditBox.Instructions:SetText(DESCRIPTION_OF_YOUR_GROUP);
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
	self.Dialog.ScrollFrame.update = function() LFGListEntryCreationActivityFinder_Update(self); end;
	self.Dialog.ScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.Dialog.ScrollFrame, "LFGListEntryCreationActivityListTemplate");

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
	self.matchingActivities = C_LFGList.GetAvailableActivities(self.categoryID, self.groupID, self.filters, self.Dialog.EntryBox:GetText());
	LFGListUtil_SortActivitiesByRelevancy(self.matchingActivities);
	if ( not self.selectedActivity or not tContains(self.matchingActivities, self.selectedActivity) ) then
		self.selectedActivity = self.matchingActivities[1];
	end
	LFGListEntryCreationActivityFinder_Update(self);
end

function LFGListEntryCreationActivityFinder_Update(self)
	local actitivities = self.matchingActivities;

	local offset = HybridScrollFrame_GetOffset(self.Dialog.ScrollFrame);

	for i=1, #self.Dialog.ScrollFrame.buttons do
		local button = self.Dialog.ScrollFrame.buttons[i];
		local idx = i + offset;
		local id = actitivities[idx];
		if ( id ) then
			button:SetText( (C_LFGList.GetActivityInfo(id)) );
			button.activityID = id;
			button.Selected:SetShown(self.selectedActivity == id);
			if ( self.selectedActivity == id ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
			button:Show();
		else
			button:Hide();
		end
	end
	HybridScrollFrame_Update(self.Dialog.ScrollFrame, self.Dialog.ScrollFrame.buttons[1]:GetHeight() * #actitivities, self.Dialog.ScrollFrame:GetHeight());
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
	self.selectedActivity = activityID;
	LFGListEntryCreationActivityFinder_Update(self);
end

-------------------------------------------------------
----------Application Viewing
-------------------------------------------------------
function LFGListApplicationViewer_OnLoad(self)
	self.ScrollFrame.update = function() LFGListApplicationViewer_UpdateResults(self); end;
	self.ScrollFrame.dynamic = function(offset) return LFGListApplicationViewer_GetScrollOffset(self, offset) end
	self.ScrollFrame.scrollBar.doNotHide = true;
	self.NameColumnHeader:Disable();
	self.RoleColumnHeader:Disable();
	self.ItemLevelColumnHeader:Disable();
	HybridScrollFrame_CreateButtons(self.ScrollFrame, "LFGListApplicantTemplate");
end

function LFGListApplicationViewer_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		LFGListApplicationViewer_UpdateInfo(self);
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		LFGListApplicationViewer_UpdateAvailability(self);
		LFGListApplicationViewer_UpdateInfo(self);
	elseif ( event == "LFG_LIST_APPLICANT_LIST_UPDATED" ) then
		LFGListApplicationViewer_UpdateResultList(self);
		LFGListApplicationViewer_UpdateResults(self);
	elseif ( event == "LFG_LIST_APPLICANT_UPDATED" ) then
		--If we can't make changes, we just remove people immediately
		local id = ...;
		if ( not LFGListUtil_IsEntryEmpowered() ) then
			C_LFGList.RemoveApplicant(id);
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
	local active, activityID = C_LFGList.GetActiveEntryInfo();
	if ( not active ) then
		return;
	end

	local data = GetGroupMemberCounts();
	data.DAMAGER = data.DAMAGER + data.NOROLE; --People without a role count as damage
	data.NOROLE = 0;
	LFGListGroupDataDisplay_Update(self.DataDisplay, activityID, data);
end

function LFGListApplicationViewer_UpdateInfo(self)
	local active, activityID, ilvl, honorLevel, name, comment, voiceChat, duration, autoAccept, privateGroup, questID = C_LFGList.GetActiveEntryInfo();
	local fullName, shortName, categoryID, groupID, iLevel, filters, minLevel, maxPlayers, displayType = C_LFGList.GetActivityInfo(activityID);
	local _, separateRecommended = C_LFGList.GetCategoryInfo(categoryID);
	assert(active);
	self.EntryName:SetWidth(0);
	self.EntryName:SetText(name);
	self.DescriptionFrame.activityName = C_LFGList.GetActivityInfo(activityID);
	if ( comment == "" and questID ) then
		comment = LFGListUtil_GetQuestDescription(questID);
	end
	self.DescriptionFrame.comment = comment;
	if ( comment == "" ) then
		self.DescriptionFrame.Text:SetText(self.DescriptionFrame.activityName);
	else
		self.DescriptionFrame.Text:SetFormattedText("%s |cff888888- %s|r", self.DescriptionFrame.activityName, self.DescriptionFrame.comment);
	end

	local hasRestrictions = false;
	if ( ilvl == 0 ) then
		self.ItemLevel:SetText("");
	else
		self.ItemLevel:SetFormattedText(LFG_LIST_ITEM_LEVEL_CURRENT, ilvl);
	end

	if ( privateGroup ) then
		self.PrivateGroup:SetText(LFG_LIST_PRIVATE);
		self.ItemLevel:ClearAllPoints();
		self.ItemLevel:SetPoint("LEFT", self.PrivateGroup, "RIGHT", 3, 0);
	else
		self.PrivateGroup:SetText("");
		self.ItemLevel:ClearAllPoints();
		self.ItemLevel:SetPoint("TOPLEFT", self.InfoBackground, "TOPLEFT", 12, -52);
	end

	if ( voiceChat == "" ) then
		self.VoiceChatFrame.tooltip = nil;
		self.VoiceChatFrame:Hide();
	else
		self.VoiceChatFrame.tooltip = voiceChat;
		self.VoiceChatFrame:Show();
	end

	if ( self.EntryName:GetWidth() > 290 ) then
		self.EntryName:SetWidth(290);
	end

	--Set the background
	local atlasName = nil;
	if ( separateRecommended and bit.band(filters, LE_LFG_LIST_FILTER_RECOMMENDED) ~= 0 ) then
		atlasName = "groupfinder-background-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "raids").."-"..LFG_LIST_PER_EXPANSION_TEXTURES[LFGListUtil_GetCurrentExpansion()];
	elseif ( separateRecommended and bit.band(filters, LE_LFG_LIST_FILTER_NOT_RECOMMENDED) ~= 0 ) then
		atlasName = "groupfinder-background-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "raids").."-"..LFG_LIST_PER_EXPANSION_TEXTURES[math.max(0,LFGListUtil_GetCurrentExpansion() - 1)];
	else
		atlasName = "groupfinder-background-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "questing");
	end

	local suffix = "";
	if ( bit.band(filters, LE_LFG_LIST_FILTER_PVE) ~= 0 ) then
		suffix = "-pve";
	elseif ( bit.band(filters, LE_LFG_LIST_FILTER_PVP) ~= 0 ) then
		suffix = "-pvp";
	end

	--Try with the suffix and then without it
	if ( not self.InfoBackground:SetAtlas(atlasName..suffix) ) then
		self.InfoBackground:SetAtlas(atlasName);
	end

	--Update the AutoAccept button
	self.AutoAcceptButton:SetChecked(autoAccept);
	if ( UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
		self.AutoAcceptButton:Show();
		self.AutoAcceptButton:Enable();
		self.AutoAcceptButton.Label:SetFontObject(GameFontHighlightSmall);
	elseif ( UnitIsGroupAssistant("player", LE_PARTY_CATEGORY_HOME) ) then
		self.AutoAcceptButton:Show();
		self.AutoAcceptButton:Disable();
		self.AutoAcceptButton.Label:SetFontObject(GameFontDisableSmall);
	else
		self.AutoAcceptButton:SetShown(autoAccept);
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
	self.ScrollFrame.NoApplicants:SetShown(empowered and (not self.applicants or #self.applicants == 0));
end

function LFGListApplicationViewer_UpdateResultList(self)
	self.applicants = C_LFGList.GetApplicants();

	--Filter applicants. Don't worry about order.
	LFGListUtil_FilterApplicants(self.applicants);

	--Sort applicants
	LFGListUtil_SortApplicants(self.applicants);

	--Cache off the group sizes for the scroll frame and the total height
	local totalHeight = 0;
	self.applicantSizes = {};
	for i=1, #self.applicants do
		local _, _, _, numMembers = C_LFGList.GetApplicantInfo(self.applicants[i]);
		self.applicantSizes[i] = numMembers;
		totalHeight = totalHeight + LFGListApplicationViewerUtil_GetButtonHeight(numMembers);
	end
	self.totalApplicantHeight = totalHeight;

	LFGListApplicationViewer_UpdateAvailability(self);
end

function LFGListApplicationViewer_UpdateInviteState(self)
	local active, activityID, ilvl, honorLevel, name, comment, voiceChat = C_LFGList.GetActiveEntryInfo();
	if ( not active ) then
		return;
	end

	local numAllowed = select(ACTIVITY_RETURN_VALUES.maxPlayers, C_LFGList.GetActivityInfo(activityID));
	if ( numAllowed == 0 ) then
		numAllowed = MAX_RAID_MEMBERS;
	end

	local currentCount = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
	local numInvited = C_LFGList.GetNumInvitedApplicantMembers();

	local buttons = self.ScrollFrame.buttons;
	for i=1, #buttons do
		local button = buttons[i];
		if ( button.applicantID ) then
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
		end
	end
end

function LFGListApplicationViewer_UpdateResults(self)
	local offset = HybridScrollFrame_GetOffset(self.ScrollFrame);
	local buttons = self.ScrollFrame.buttons;

	--If the mouse is over something in this frame, update it
	local mouseover = GetMouseFocus();
	local mouseoverParent = mouseover and mouseover:GetParent();
	local parentParent = mouseoverParent and mouseoverParent:GetParent();
	if ( mouseoverParent == self.ScrollFrame or parentParent == self.ScrollFrame ) then
		--Just hide the tooltip. We should show it again inside the update function.
		GameTooltip:Hide();
	end

	for i=1, #buttons do
		local button = buttons[i];
		local idx = i + offset;
		local id = self.applicants[idx];

		if ( id ) then
			button.applicantID = id;
			LFGListApplicationViewer_UpdateApplicant(button, id);
			button.Background:SetAlpha(idx % 2 == 0 and 0.1 or 0.05);
			button:Show();
		else
			button.applicantID = nil;
			button:Hide();
		end
	end
	HybridScrollFrame_Update(self.ScrollFrame, self.totalApplicantHeight, self.ScrollFrame:GetHeight());
	LFGListApplicationViewer_UpdateInviteState(self);
end

function LFGListApplicationViewer_UpdateApplicant(button, id)
	local id, status, pendingStatus, numMembers, isNew = C_LFGList.GetApplicantInfo(id);
	button:SetHeight(LFGListApplicationViewerUtil_GetButtonHeight(numMembers));

	--Update individual members
	for i=1, numMembers do
		local member = button.Members[i];
		if ( not member ) then
			member = CreateFrame("BUTTON", nil, button, "LFGListApplicantMemberTemplate");
			member:SetPoint("TOPLEFT", button.Members[i-1], "BOTTOMLEFT", 0, 0);
			button.Members[i] = member;
		end
		LFGListApplicationViewer_UpdateApplicantMember(member, id, i, status, pendingStatus);
		member:Show();
	end

	--Hide extra member buttons
	for i=numMembers+1, #button.Members do
		button.Members[i]:Hide();
	end

	--Update the Invite and Decline buttons based on group size
	if ( numMembers > 1 ) then
		button.DeclineButton:SetHeight(36);
		button.InviteButton:SetHeight(36);
		button.InviteButton:SetFormattedText(LFG_LIST_INVITE_GROUP, numMembers);
	else
		button.DeclineButton:SetHeight(22);
		button.InviteButton:SetHeight(22);
		button.InviteButton:SetText(INVITE);
	end

	if ( pendingStatus or status == "applied" ) then
		button.Status:Hide();
	elseif ( status == "invited" ) then
		button.Status:Show();
		button.Status:SetText(LFG_LIST_APP_INVITED);
		button.Status:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
	elseif ( status == "failed" or status == "cancelled" ) then
		button.Status:Show();
		button.Status:SetText(LFG_LIST_APP_CANCELLED);
		button.Status:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	elseif ( status == "declined" or status == "declined_full" or status == "declined_delisted" ) then
		button.Status:Show();
		button.Status:SetText(LFG_LIST_APP_DECLINED);
		button.Status:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	elseif ( status == "timedout" ) then
		button.Status:Show();
		button.Status:SetText(LFG_LIST_APP_TIMED_OUT);
		button.Status:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	elseif ( status == "inviteaccepted" ) then
		button.Status:Show();
		button.Status:SetText(LFG_LIST_APP_INVITE_ACCEPTED);
		button.Status:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
	elseif ( status == "invitedeclined" ) then
		button.Status:Show();
		button.Status:SetText(LFG_LIST_APP_INVITE_DECLINED);
		button.Status:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end

	button.numMembers = numMembers;
	button.InviteButton:SetShown(not pendingStatus and status == "applied" and LFGListUtil_IsEntryEmpowered());
	button.DeclineButton:SetShown(not pendingStatus and status ~= "invited" and LFGListUtil_IsEntryEmpowered());
	button.DeclineButton.isAck = (status ~= "applied" and status ~= "invited");
	button.Spinner:SetShown(pendingStatus);
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
	local grayedOut = not pendingStatus and (status == "failed" or status == "cancelled" or status == "declined" or status == "declined_full" or status == "declined_delisted" or status == "invitedeclined" or status == "timedout");
	local noTouchy = (status == "invited" or status == "inviteaccepted" or status == "invitedeclined");

	local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damage, assignedRole, relationship = C_LFGList.GetApplicantMemberInfo(appID, memberIdx);

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

	member.ItemLevel:SetShown(not grayedOut);
	member.ItemLevel:SetText(math.floor(itemLevel));

	local mouseFocus = GetMouseFocus();
	if ( mouseFocus == member ) then
		LFGListApplicantMember_OnEnter(member);
	elseif ( mouseFocus == member.FriendIcon ) then
		member.FriendIcon:GetScript("OnEnter")(member.FriendIcon);
	end
end

function LFGListApplicationViewer_GetScrollOffset(self, offset)
	local acum = 0;
	for i=1, #self.applicantSizes do
		local height = LFGListApplicationViewerUtil_GetButtonHeight(self.applicantSizes[i]);
		acum = acum + height;
		if ( acum > offset ) then
			return i - 1, height + offset - acum;
		end
	end

	--We're scrolled completely off the bottom
	return #self.applicantSizes, 0;
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

--Applicant members
function LFGListApplicantMember_OnEnter(self)
	local applicantID = self:GetParent().applicantID;
	local memberIdx = self.memberIdx;

	local active, activityID = C_LFGList.GetActiveEntryInfo();
	if ( not active ) then
		return;
	end


	local useHonorLevel = select(11, C_LFGList.GetActivityInfo(activityID));
	local id, status, pendingStatus, numMembers, isNew, comment = C_LFGList.GetApplicantInfo(applicantID);
	local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damage, assignedRole  = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx);

	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 105, 0);
	if ( name ) then
		local classTextColor = RAID_CLASS_COLORS[class];
		GameTooltip:SetText(name, classTextColor.r, classTextColor.g, classTextColor.b);
		GameTooltip:AddLine(string.format(UNIT_TYPE_LEVEL_TEMPLATE, level, localizedClass), 1, 1, 1);
	else
		GameTooltip:SetText(" ");	--Just make it empty until we get the name update
	end
	GameTooltip:AddLine(string.format(LFG_LIST_ITEM_LEVEL_CURRENT, itemLevel), 1, 1, 1);
	if ( useHonorLevel ) then
		GameTooltip:AddLine(string.format(LFG_LIST_HONOR_LEVEL_CURRENT_PVP, honorLevel), 1, 1, 1);
	end
	if ( comment and comment ~= "" ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(string.format(LFG_LIST_COMMENT_FORMAT, comment), LFG_LIST_COMMENT_FONT_COLOR.r, LFG_LIST_COMMENT_FONT_COLOR.g, LFG_LIST_COMMENT_FONT_COLOR.b, true);
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
	self.SearchBox.Instructions:SetText(FILTER);
	self.ScrollFrame.update = function() LFGListSearchPanel_UpdateResults(self); end;
	self.ScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.ScrollFrame, "LFGListSearchEntryTemplate");
	self.SearchBox.clearButton:SetScript("OnClick", function(btn)
		SearchBoxTemplateClearButton_OnClick(btn);
		LFGListSearchPanel_DoSearch(self);
	end);
end

function LFGListSearchPanel_OnEvent(self, event, ...)
	--Note: events are dispatched from the base frame. Add RegisterEvent there.
	if ( event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" ) then
		StaticPopupSpecial_Hide(LFGListApplicationDialog);
		if ( self.searching ) then
			-- got new list from server, everything we were filtering out should be gone
			self.filteredIDs = nil;
		end
		self.searching = false;
		self.searchFailed = false;
		LFGListSearchPanel_UpdateResultList(self);
		LFGListSearchPanel_UpdateResults(self);
	elseif ( event == "LFG_LIST_SEARCH_FAILED" ) then
		self.searching = false;
		self.searchFailed = true;
		LFGListSearchPanel_UpdateResultList(self);
		LFGListSearchPanel_UpdateResults(self);
	elseif ( event == "LFG_LIST_SEARCH_RESULT_UPDATED" ) then
		local id = ...;
		if ( self.selectedResult == id ) then
			LFGListSearchPanel_ValidateSelected(self);
			if ( self.selectedResult ~= id ) then
				LFGListSearchPanel_UpdateResults(self);
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
	end

	if ( tContains(LFG_LIST_ACTIVE_QUEUE_MESSAGE_EVENTS, event) ) then
		LFGListSearchPanel_UpdateButtonStatus(self);
	end
end

function LFGListSearchPanel_AddFilteredID(self, id)
	if ( not self.filteredIDs ) then
		self.filteredIDs = { };
	end
	tinsert(self.filteredIDs, id);
end

function LFGListSearchPanel_OnShow(self)
	LFGListSearchPanel_UpdateResultList(self);
	LFGListSearchPanel_UpdateResults(self);
	--LFGListSearchPanel_UpdateButtonStatus(self); --Called by UpdateResults

	local availableLanguages = C_LFGList.GetAvailableLanguageSearchFilter();
	local defaultLanguages = C_LFGList.GetDefaultLanguageSearchFilter();

	local canChangeLanguages = false;
	for i=1, #availableLanguages do
		if ( not defaultLanguages[availableLanguages[i]] ) then
			canChangeLanguages = true;
			break;
		end
	end

	if ( canChangeLanguages ) then
		self.SearchBox:SetWidth(228);
		self.FilterButton:Show();
	else
		self.SearchBox:SetWidth(319);
		self.FilterButton:Hide();
	end
end

function LFGListSearchPanel_Clear(self)
	C_LFGList.ClearSearchResults();
	self.SearchBox:SetText("");
	self.selectedResult = nil;
	LFGListSearchPanel_UpdateResultList(self);
	LFGListSearchPanel_UpdateResults(self);
end

function LFGListSearchPanel_SetCategory(self, categoryID, filters, preferredFilters)
	self.categoryID = categoryID;
	self.filters = filters;
	self.preferredFilters = preferredFilters;

	local name = LFGListUtil_GetDecoratedCategoryName(C_LFGList.GetCategoryInfo(categoryID), filters, false);
	self.CategoryName:SetText(name);
end

local function Higher(value)
	return value + 1;
end

local function Lower(value)
	return value - 1;
end

local function GetTermsTable(term)
	local termsTable = { term };
	local higherTerm = term:gsub("(%d+)", Higher);
	if higherTerm ~= term then
		table.insert(termsTable, higherTerm);
		table.insert(termsTable, (term:gsub("(%d+)", Lower)));
	end
	return { matches = termsTable };
end

function LFGListSearchPanel_ParseSearchTerms(searchText)
	local termSet = {};
	
	for term in searchText:gmatch("%S+") do
		termSet[term] = true;
	end
	
	local separatedTerms = {};
	for term in pairs(termSet) do
		table.insert(separatedTerms, GetTermsTable(term));
	end
	
	return separatedTerms;
end

function LFGListSearchPanel_DoSearch(self)
	local searchText = self.SearchBox:GetText();
	local languages = C_LFGList.GetLanguageSearchFilter();
	C_LFGList.Search(self.categoryID, LFGListSearchPanel_ParseSearchTerms(searchText), self.filters, self.preferredFilters, languages);
	self.searching = true;
	self.searchFailed = false;
	self.selectedResult = nil;
	LFGListSearchPanel_UpdateResultList(self);
	LFGListSearchPanel_UpdateResults(self);

	-- If auto-create is desired, then the caller needs to set up that data after the search begins.
	-- There's an issue with using OnTextChanged to handle this due to how OnShow processes the update.
	if self.previousSearchText ~= searchText then
		LFGListEntryCreation_ClearAutoCreateMode(self:GetParent().EntryCreation);
	end

	self.previousSearchText = searchText;
end

function LFGListSearchPanel_CreateGroupInstead(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local panel = self:GetParent():GetParent();
	LFGListEntryCreation_Show(panel:GetParent().EntryCreation, panel.preferredFilters, panel.categoryID, panel.filters);
end

function LFGListSearchPanel_UpdateResultList(self)
	self.totalResults, self.results = C_LFGList.GetSearchResults();
	self.applications = C_LFGList.GetApplications();
	if ( self.filteredIDs ) then
		LFGListUtil_FilterSearchResults(self.results, self.filteredIDs);
	end
	LFGListUtil_SortSearchResults(self.results);
end

function LFGListSearchPanel_ValidateSelected(self)
	if ( self.selectedResult and not LFGListSearchPanelUtil_CanSelectResult(self.selectedResult)) then
		self.selectedResult = nil;
	end
end

function LFGListSearchPanelUtil_CanSelectResult(resultID)
	local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(resultID);
	local id, activityID, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted = C_LFGList.GetSearchResultInfo(resultID);
	if ( appStatus ~= "none" or pendingStatus or isDelisted ) then
		return false;
	end
	return true;
end

function LFGListSearchPanel_UpdateResults(self)
	local offset = HybridScrollFrame_GetOffset(self.ScrollFrame);
	local buttons = self.ScrollFrame.buttons;

	--If we have an application selected, deselect it.
	LFGListSearchPanel_ValidateSelected(self);

	if ( self.searching ) then
		self.SearchingSpinner:Show();
		self.ScrollFrame.NoResultsFound:Hide();
		self.ScrollFrame.StartGroupButton:Hide();
		for i=1, #buttons do
			buttons[i]:Hide();
		end
	else
		self.SearchingSpinner:Hide();
		local results = self.results;
		local apps = self.applications;

		for i=1, #buttons do
			local button = buttons[i];
			local idx = i + offset;
			local result = (idx <= #apps) and apps[idx] or results[idx - #apps];

			if ( result ) then
				button.resultID = result;
				LFGListSearchEntry_Update(button);
				button:Show();
			else
				button.resultID = nil;
				button:Hide();
			end
		end

		local totalHeight = buttons[1]:GetHeight() * (#results + #apps);

		--Reanchor the errors to not overlap applications
		if ( totalHeight < self.ScrollFrame:GetHeight() ) then
			self.ScrollFrame.NoResultsFound:SetPoint("TOP", self.ScrollFrame, "TOP", 0, -totalHeight - 27);
		end
		self.ScrollFrame.NoResultsFound:SetShown(self.totalResults == 0);
		self.ScrollFrame.StartGroupButton:SetShown(self.totalResults == 0 and not self.searchFailed);
		self.ScrollFrame.NoResultsFound:SetText(self.searchFailed and LFG_LIST_SEARCH_FAILED or LFG_LIST_NO_RESULTS_FOUND);

		HybridScrollFrame_Update(self.ScrollFrame, totalHeight, self.ScrollFrame:GetHeight());
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

	--Update the StartGroupButton
	if ( IsInGroup(LE_PARTY_CATEGORY_HOME) and not UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
		self.ScrollFrame.StartGroupButton:Disable();
		self.ScrollFrame.StartGroupButton.tooltip = LFG_LIST_NOT_LEADER;
	else
		local messageStart = LFGListUtil_GetActiveQueueMessage(false);
		if ( messageStart ) then
			self.ScrollFrame.StartGroupButton:Disable();
			self.ScrollFrame.StartGroupButton.tooltip = messageStart;
		else
			self.ScrollFrame.StartGroupButton:Enable();
			self.ScrollFrame.StartGroupButton.tooltip = nil;
		end
	end
end

function LFGListSearchPanel_SignUp(self)
	LFGListApplicationDialog_Show(LFGListApplicationDialog, self.selectedResult);
end

function LFGListSearchPanelSearchBox_OnEnterPressed(self)
	local parent = self:GetParent();
	if ( parent.AutoCompleteFrame:IsShown() and parent.AutoCompleteFrame.selected ) then
		self:SetText( (C_LFGList.GetActivityInfo(parent.AutoCompleteFrame.selected)) );
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

function LFGListSearchAutoCompleteButton_OnClick(self)
	local panel = self:GetParent():GetParent();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	panel.SearchBox:SetText( (C_LFGList.GetActivityInfo(self.activityID)) );
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
	local matchingActivities = C_LFGList.GetAvailableActivities(self.categoryID, nil, self.filters, text);
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
			button:SetText( (C_LFGList.GetActivityInfo(id)) );
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
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");
	self:RegisterEvent("LFG_ROLE_CHECK_UPDATE");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function LFGListSearchEntry_Update(self)
	local resultID = self.resultID;
	local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(resultID);
	local isApplication = (appStatus ~= "none" or pendingStatus);
	local isAppFinished = LFGListUtil_IsStatusInactive(appStatus) or LFGListUtil_IsStatusInactive(pendingStatus);

	--Update visibility based on whether we're an application or not
	self.isApplication = isApplication;
	self.ApplicationBG:SetShown(isApplication and not isAppFinished);
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
	elseif ( appStatus == "declined" or appStatus == "declined_full" or appStatus == "declined_delisted" ) then
		self.PendingLabel:SetText(LFG_LIST_APP_DECLINED);
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

	local id, activityID, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted = C_LFGList.GetSearchResultInfo(resultID);
	local activityName = C_LFGList.GetActivityInfo(activityID);

	self.resultID = resultID;
	self.Selected:SetShown(panel.selectedResult == resultID and not isApplication and not isDelisted);
	self.Highlight:SetShown(panel.selectedResult ~= resultID and not isApplication and not isDelisted);
	local nameColor = NORMAL_FONT_COLOR;
	local activityColor = GRAY_FONT_COLOR;
	if ( isDelisted or isAppFinished ) then
		nameColor = LFG_LIST_DELISTED_FONT_COLOR;
		activityColor = LFG_LIST_DELISTED_FONT_COLOR;
	elseif ( numBNetFriends > 0 or numCharFriends > 0 or numGuildMates > 0 ) then
		nameColor = BATTLENET_FONT_COLOR;
	end
	self.Name:SetWidth(0);
	self.Name:SetText(name);
	self.Name:SetTextColor(nameColor.r, nameColor.g, nameColor.b);
	self.ActivityName:SetText(activityName);
	self.ActivityName:SetTextColor(activityColor.r, activityColor.g, activityColor.b);
	self.VoiceChat:SetShown(voiceChat ~= "");
	self.VoiceChat.tooltip = voiceChat;

	local displayData = C_LFGList.GetSearchResultMemberCounts(resultID);
	LFGListGroupDataDisplay_Update(self.DataDisplay, activityID, displayData, isDelisted);

	local nameWidth = isApplication and 165 or 176;
	if ( voiceChat ~= "" ) then
		nameWidth = nameWidth - 22;
	end
	if ( self.Name:GetWidth() > nameWidth ) then
		self.Name:SetWidth(nameWidth);
	end
	self.ActivityName:SetWidth(nameWidth);

	local mouseFocus = GetMouseFocus();
	if ( mouseFocus == self ) then
		LFGListSearchEntry_OnEnter(self);
	end
	if ( mouseFocus == self.VoiceChat ) then
		mouseFocus:GetScript("OnEnter")(mouseFocus);
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

function LFGListSearchEntry_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_SEARCH_RESULT_UPDATED" ) then
		local id = ...;
		if ( id == self.resultID ) then
			LFGListSearchEntry_Update(self);
		end
	elseif ( event == "LFG_ROLE_CHECK_UPDATE" ) then
		if ( self.resultID ) then
			LFGListSearchEntry_Update(self);
		end
	end
end

function LFGListSearchEntry_OnClick(self, button)
	local scrollFrame = self:GetParent():GetParent();
	if ( button == "RightButton" ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		EasyMenu(LFGListUtil_GetSearchEntryMenu(self.resultID), LFGListFrameDropDown, self, 290, -2, "MENU");
	elseif ( scrollFrame:GetParent().selectedResult ~= self.resultID and LFGListSearchPanelUtil_CanSelectResult(self.resultID) ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		LFGListSearchPanel_SelectResult(scrollFrame:GetParent(), self.resultID);
	end
end

function LFGListSearchEntry_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 25, 0);
	local resultID = self.resultID;
	LFGListUtil_SetSearchEntryTooltip(GameTooltip, resultID);
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
	local _, activityID = C_LFGList.GetSearchResultInfo(resultID);
	if ( activityID ~= self.activityID ) then
		C_LFGList.ClearApplicationTextFields();
	end

	self.resultID = resultID;
	self.activityID = activityID;
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
			local id = ...;
			StaticPopupSpecial_Hide(self);
			LFGListInviteDialog_Show(self, id);
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

function LFGListInviteDialog_Show(self, resultID)
	local id, activityID, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted = C_LFGList.GetSearchResultInfo(resultID);
	local activityName = C_LFGList.GetActivityInfo(activityID);
	local _, status, _, _, role = C_LFGList.GetApplicationInfo(resultID);

	local informational = (status ~= "invited");
	assert(not informational or status == "inviteaccepted");

	self.resultID = resultID;
	self.GroupName:SetText(name);
	self.ActivityName:SetText(activityName);
	self.Role:SetText(_G[role]);
	self.RoleIcon:SetTexCoord(GetTexCoordsForRole(role));
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
function LFGListGroupDataDisplay_Update(self, activityID, displayData, disabled)
	local fullName, shortName, categoryID, groupID, iLevel, filters, minLevel, maxPlayers, displayType = C_LFGList.GetActivityInfo(activityID);
	if ( displayType == LE_LFG_LIST_DISPLAY_TYPE_ROLE_COUNT ) then
		self.RoleCount:Show();
		self.Enumerate:Hide();
		self.PlayerCount:Hide();
		LFGListGroupDataDisplayRoleCount_Update(self.RoleCount, displayData, disabled);
	elseif ( displayType == LE_LFG_LIST_DISPLAY_TYPE_ROLE_ENUMERATE ) then
		self.RoleCount:Hide();
		self.Enumerate:Show();
		self.PlayerCount:Hide();
		LFGListGroupDataDisplayEnumerate_Update(self.Enumerate, maxPlayers, displayData, disabled, LFG_LIST_GROUP_DATA_ROLE_ORDER);
	elseif ( displayType == LE_LFG_LIST_DISPLAY_TYPE_CLASS_ENUMERATE ) then
		self.RoleCount:Hide();
		self.Enumerate:Show();
		self.PlayerCount:Hide();
		LFGListGroupDataDisplayEnumerate_Update(self.Enumerate, maxPlayers, displayData, disabled, LFG_LIST_GROUP_DATA_CLASS_ORDER);
	elseif ( displayType == LE_LFG_LIST_DISPLAY_TYPE_PLAYER_COUNT ) then
		self.RoleCount:Hide();
		self.Enumerate:Hide();
		self.PlayerCount:Show();
		LFGListGroupDataDisplayPlayerCount_Update(self.PlayerCount, displayData, disabled);
	elseif ( displayType == LE_LFG_LIST_DISPLAY_TYPE_HIDE_ALL ) then
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

function LFGListGroupDataDisplayEnumerate_Update(self, numPlayers, displayData, disabled, iconOrder)
	--Show/hide the required icons
	for i=1, #self.Icons do
		if ( i > numPlayers ) then
			self.Icons[i]:Hide();
		else
			self.Icons[i]:Show();
			self.Icons[i]:SetDesaturated(disabled);
			self.Icons[i]:SetAlpha(disabled and 0.5 or 1.0);
		end
	end

	--Note that icons are numbered from right to left
	local iconIndex = numPlayers;
	for i=1, #iconOrder do
		for j=1, displayData[iconOrder[i]] do
			self.Icons[iconIndex]:SetAtlas(LFG_LIST_GROUP_DATA_ATLASES[iconOrder[i]], false);
			iconIndex = iconIndex - 1;
			if ( iconIndex < 1 ) then
				return;
			end
		end
	end

	for i=1, iconIndex do
		self.Icons[i]:SetAtlas("groupfinder-icon-emptyslot", false);
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
			local fullName, shortName, categoryID, groupID, iLevel, filters, minLevel, maxPlayers, displayType, orderIndex, useHonorLevel = C_LFGList.GetActivityInfo(activities[i]);
			local isRecommended = bit.band(filters, LE_LFG_LIST_FILTER_RECOMMENDED) ~= 0;
			local currentArea = C_LFGList.GetActivityInfoExpensive(activities[i]);

			local usedItemLevel = myItemLevel;
			local isBetter = false;
			if ( not activityID ) then
				isBetter = true;
			elseif ( currentArea ~= bestCurrentArea ) then
				isBetter = currentArea;
			elseif ( bestRecommended ~= isRecommended ) then
				isBetter = isRecommended;
			elseif ( bestMinLevel ~= minLevel ) then
				isBetter = minLevel > bestMinLevel;
			elseif ( iLevel ~= bestItemLevel ) then
				isBetter = (iLevel > bestItemLevel and iLevel <= usedItemLevel) or
							(iLevel <= usedItemLevel and bestItemLevel > usedItemLevel) or
							(iLevel < bestItemLevel and iLevel > usedItemLevel);
			elseif ( (myNumMembers < maxPlayers) ~= (myNumMembers < bestMaxPlayers) ) then
				isBetter = myNumMembers < maxPlayers;
			end

			if ( isBetter ) then
				activityID = activities[i];
				bestItemLevel = iLevel;
				bestRecommended = isRecommended;
				bestCurrentArea = currentArea;
				bestMinLevel = minLevel;
				bestMaxPlayers = maxPlayers;
			end
		end
	end

	assert(activityID);

	--Update the categoryID and groupID with what we get from the activity
	local _;
	categoryID, groupID, _, filters = select(ACTIVITY_RETURN_VALUES.categoryID, C_LFGList.GetActivityInfo(activityID));

	--Update the filters if needed
	local _, separateRecommended = C_LFGList.GetCategoryInfo(categoryID);
	if ( separateRecommended ) then
		if ( bit.band(filters, LE_LFG_LIST_FILTER_RECOMMENDED) == 0 ) then
			filters = LE_LFG_LIST_FILTER_NOT_RECOMMENDED;
		else
			filters = LE_LFG_LIST_FILTER_RECOMMENDED;
		end
	else
		filters = 0;
	end

	return filters, categoryID, groupID, activityID;
end

function LFGListUtil_SetUpDropDown(context, dropdown, populateFunc, onClickFunc)
	local onClick = function(self, ...)
		onClickFunc(context, self.value, ...);
	end
	local initialize = function(self)
		local info = UIDropDownMenu_CreateInfo();
		info.func = onClick;
		populateFunc(context, dropdown, info);
	end
	dropdown:SetScript("OnShow", function(self)
		UIDropDownMenu_SetWidth(self, dropdown:GetWidth() - 50);
		UIDropDownMenu_Initialize(self, initialize);
	end);
	UIDropDownMenu_JustifyText(dropdown, "LEFT");
	UIDropDownMenu_SetAnchor(dropdown, -20, 7, "TOPRIGHT", dropdown, "BOTTOMRIGHT");
end

function LFGListUtil_ValidateLevelReq(self, text)
	local myItemLevel = GetAverageItemLevel();
	if ( text ~= "" and tonumber(text) > myItemLevel) then
		return LFG_LIST_ILVL_ABOVE_YOURS;
	end
end

function LFGListUtil_ValidateHonorLevelReq(self, text)
	local myHonorLevel = UnitHonorLevel("player");
	if (text ~= "" and tonumber(text) > myHonorLevel) then
		return LFG_LIST_HONOR_LEVEL_ABOVE_YOURS;
	end
end

function LFGListUtil_GetCurrentExpansion()
	for i=0, #MAX_PLAYER_LEVEL_TABLE do
		if ( UnitLevel("player") <= MAX_PLAYER_LEVEL_TABLE[i] ) then
			return i;
		end
	end

	--We're higher than the highest level. Weird.
	return #MAX_PLAYER_LEVEL_TABLE;
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
	if ( filter == LE_LFG_LIST_FILTER_NOT_RECOMMENDED ) then
		extraName = LFG_LIST_LEGACY;
	elseif ( filter == LE_LFG_LIST_FILTER_RECOMMENDED ) then
		local exp = LFGListUtil_GetCurrentExpansion();
		extraName = _G["EXPANSION_NAME"..exp];
	end

	return string.format(LFG_LIST_CATEGORY_FORMAT, categoryName, colorStart, extraName, colorEnd);
end

local roleRemainingKeyLookup = {
	["TANK"] = "TANK_REMAINING",
	["HEALER"] = "HEALER_REMAINING",
	["DAMAGER"] = "DAMAGER_REMAINING",
};

local function HasRemainingSlotsForLocalPlayerRole(lfgSearchResultID)
	local roles = C_LFGList.GetSearchResultMemberCounts(lfgSearchResultID);
	local playerRole = GetSpecializationRole(GetSpecialization());
	return roles[roleRemainingKeyLookup[playerRole]] > 0;
end

function LFGListUtil_SortSearchResultsCB(id1, id2)
	local id1, activityID1, name1, comment1, voiceChat1, iLvl1, honorLevel1, age1, numBNetFriends1, numCharFriends1, numGuildMates1, isDelisted1 = C_LFGList.GetSearchResultInfo(id1);
	local id2, activityID2, name2, comment2, voiceChat2, iLvl2, honorLevel2, age2, numBNetFriends2, numCharFriends2, numGuildMates2, isDelisted2 = C_LFGList.GetSearchResultInfo(id2);

	local hasRemainingRole1 = HasRemainingSlotsForLocalPlayerRole(id1);
	local hasRemainingRole2 = HasRemainingSlotsForLocalPlayerRole(id2);

	-- Groups with your current role available are preferred
	if (hasRemainingRole1 ~= hasRemainingRole2) then
		return hasRemainingRole1;
	end

	--If one has more friends, do that one first
	if ( numBNetFriends1 ~= numBNetFriends2 ) then
		return numBNetFriends1 > numBNetFriends2;
	end

	if ( numCharFriends1 ~= numCharFriends2 ) then
		return numCharFriends1 > numCharFriends2;
	end

	if ( numGuildMates1 ~= numGuildMates2 ) then
		return numGuildMates1 > numGuildMates2;
	end

	--If we aren't sorting by anything else, just go by ID
	return id1 < id2;
end

function LFGListUtil_SortSearchResults(results)
	table.sort(results, LFGListUtil_SortSearchResultsCB);
end

function LFGListUtil_FilterSearchResults(results, filteredIDs)
	for i, id in ipairs(filteredIDs) do
		for j = #results, 1, -1 do
			if ( results[i] == id ) then
				tremove(results, j);
				break;
			end
		end
	end
end

function LFGListUtil_FilterApplicants(applicants)
	--[[for i=#applicants, 1, -1 do
		local id, status, pendingStatus, numMembers, isNew = C_LFGList.GetApplicantInfo(applicants[i]);
		if ( status ~= "applied" and status ~= "invited" ) then
			--Remove this applicant. Don't worry about order.
			applicants[i] = applicants[#applicants];
			applicants[#applicants] = nil;
		end
	end--]]
end

function LFGListUtil_SortApplicantsCB(id1, id2)
	local _, _, _, _, isNew1, _, orderID1 = C_LFGList.GetApplicantInfo(id1);
	local _, _, _, _, isNew2, _, orderID2 = C_LFGList.GetApplicantInfo(id2);

	--New items go to the bottom
	if ( isNew1 ~= isNew2 ) then
		return isNew2;
	end

	return orderID1 < orderID2;
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
	local hasActiveEntry = C_LFGList.GetActiveEntryInfo();
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

local LFG_LIST_SEARCH_ENTRY_MENU = {
	{
		text = nil,	--Group name goes here
		isTitle = true,
		notCheckable = true,
	},
	{
		text = WHISPER_LEADER,
		func = function(_, name) ChatFrame_SendTell(name); end,
		notCheckable = true,
		arg1 = nil, --Leader name goes here
		disabled = nil, --Disabled if we don't have a leader name yet or you haven't applied
		tooltipWhileDisabled = 1,
		tooltipOnButton = 1,
		tooltipTitle = nil, --The title to display on mouseover
		tooltipText = nil, --The text to display on mouseover
	},
	{
		text = LFG_LIST_REPORT_GROUP_FOR,
		hasArrow = true,
		notCheckable = true,
		menuList = {
			{
				text = LFG_LIST_SPAM,
				func = function(_, id)
					CloseDropDownMenus();
					C_LFGList.ReportSearchResult(id, "lfglistspam");
					local panel = LFGListFrame.SearchPanel;
					LFGListSearchPanel_AddFilteredID(panel, id);
					LFGListSearchPanel_UpdateResultList(panel);
					LFGListSearchPanel_UpdateResults(panel);
				end,
				arg1 = nil, --Search result ID goes here
				notCheckable = true,
			},
			{
				text = LFG_LIST_BAD_NAME,
				func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistname"); end,
				arg1 = nil, --Search result ID goes here
				notCheckable = true,
			},
			{
				text = LFG_LIST_BAD_DESCRIPTION,
				func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistcomment"); end,
				arg1 = nil, --Search reuslt ID goes here
				notCheckable = true,
				disabled = nil,	--Disabled if the description is just an empty string
			},
			{
				text = LFG_LIST_BAD_LEADER_NAME,
				func = function(_, id) C_LFGList.ReportSearchResult(id, "badplayername"); end,
				arg1 = nil, --Search reuslt ID goes here
				notCheckable = true,
				disabled = nil,	--Disabled if we don't have a name for the leader
			},
		},
	},
	{
		text = CANCEL,
		notCheckable = true,
	},
};

function LFGListUtil_GetSearchEntryMenu(resultID)
	local id, activityID, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted, leaderName = C_LFGList.GetSearchResultInfo(resultID);
	local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(resultID);
	LFG_LIST_SEARCH_ENTRY_MENU[1].text = name;
	LFG_LIST_SEARCH_ENTRY_MENU[2].arg1 = leaderName;
	local applied = (appStatus == "applied" or appStatus == "invited");
	LFG_LIST_SEARCH_ENTRY_MENU[2].disabled = not leaderName;
	LFG_LIST_SEARCH_ENTRY_MENU[2].tooltipTitle = (not applied) and WHISPER
	LFG_LIST_SEARCH_ENTRY_MENU[2].tooltipText = (not applied) and LFG_LIST_MUST_SIGN_UP_TO_WHISPER;
	LFG_LIST_SEARCH_ENTRY_MENU[3].menuList[1].arg1 = resultID;
	LFG_LIST_SEARCH_ENTRY_MENU[3].menuList[2].arg1 = resultID;
	LFG_LIST_SEARCH_ENTRY_MENU[3].menuList[3].arg1 = resultID;
	LFG_LIST_SEARCH_ENTRY_MENU[3].menuList[3].disabled = (comment == "");
	LFG_LIST_SEARCH_ENTRY_MENU[3].menuList[4].arg1 = resultID;
	LFG_LIST_SEARCH_ENTRY_MENU[3].menuList[4].disabled = not leaderName;
	return LFG_LIST_SEARCH_ENTRY_MENU;
end

local LFG_LIST_APPLICANT_MEMBER_MENU = {
	{
		text = nil,	--Player name goes here
		isTitle = true,
		notCheckable = true,
	},
	{
		text = WHISPER,
		func = function(_, name) ChatFrame_SendTell(name); end,
		notCheckable = true,
		arg1 = nil, --Player name goes here
		disabled = nil, --Disabled if we don't have a name yet
	},
	{
		text = LFG_LIST_REPORT_FOR,
		hasArrow = true,
		notCheckable = true,
		menuList = {
			{
				text = LFG_LIST_BAD_PLAYER_NAME,
				notCheckable = true,
				func = function(_, id, memberIdx) C_LFGList.ReportApplicant(id, "badplayername", memberIdx); end,
				arg1 = nil, --Applicant ID goes here
				arg2 = nil, --Applicant Member index goes here
			},
			{
				text = LFG_LIST_BAD_DESCRIPTION,
				notCheckable = true,
				func = function(_, id) C_LFGList.ReportApplicant(id, "lfglistappcomment"); end,
				arg1 = nil, --Applicant ID goes here
			},
		},
	},
	{
		text = IGNORE_PLAYER,
		notCheckable = true,
		func = function(_, name, applicantID) AddIgnore(name); C_LFGList.DeclineApplicant(applicantID); end,
		arg1 = nil, --Player name goes here
		arg2 = nil, --Applicant ID goes here
		disabled = nil, --Disabled if we don't have a name yet
	},
	{
		text = CANCEL,
		notCheckable = true,
	},
};

function LFGListUtil_GetApplicantMemberMenu(applicantID, memberIdx)
	local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damage, assignedRole = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx);
	local id, status, pendingStatus, numMembers, isNew, comment = C_LFGList.GetApplicantInfo(applicantID);
	LFG_LIST_APPLICANT_MEMBER_MENU[1].text = name or " ";
	LFG_LIST_APPLICANT_MEMBER_MENU[2].arg1 = name;
	LFG_LIST_APPLICANT_MEMBER_MENU[2].disabled = not name or (status ~= "applied" and status ~= "invited");
	LFG_LIST_APPLICANT_MEMBER_MENU[3].menuList[1].arg1 = applicantID;
	LFG_LIST_APPLICANT_MEMBER_MENU[3].menuList[1].arg2 = memberIdx;
	LFG_LIST_APPLICANT_MEMBER_MENU[3].menuList[2].arg1 = applicantID;
	LFG_LIST_APPLICANT_MEMBER_MENU[3].menuList[2].disabled = (comment == "");
	LFG_LIST_APPLICANT_MEMBER_MENU[4].arg1 = name;
	LFG_LIST_APPLICANT_MEMBER_MENU[4].arg2 = applicantID;
	LFG_LIST_APPLICANT_MEMBER_MENU[4].disabled = not name;
	return LFG_LIST_APPLICANT_MEMBER_MENU;
end

function LFGListUtil_InitializeLangaugeFilter(dropdown)
	local info = UIDropDownMenu_CreateInfo();
	local languages = C_LFGList.GetAvailableLanguageSearchFilter();
	local enabled = C_LFGList.GetLanguageSearchFilter();
	local defaults = C_LFGList.GetDefaultLanguageSearchFilter();
	local entry = UIDropDownMenu_CreateInfo();
	for i=1, #languages do
		local lang = languages[i];
		entry.text = _G["LFG_LIST_LANGUAGE_"..string.upper(lang)];
		entry.checked = enabled[lang] or defaults[lang];
		entry.disabled = defaults[lang];
		entry.isNotRadio = true;
		entry.keepShownOnClick = true;
		entry.func = function(self,_,_,checked) enabled[lang] = checked; C_LFGList.SaveLanguageSearchFilter(enabled); end
		UIDropDownMenu_AddButton(entry);
	end
end

function LFGListUtil_OpenBestWindow(toggle)
	local func = toggle and PVEFrame_ToggleFrame or PVEFrame_ShowFrame;
	local active, activityID, ilvl, honorLevel, name, comment, voiceChat = C_LFGList.GetActiveEntryInfo();
	if ( active ) then
		--Open to the window of our active activity
		local fullName, shortName, categoryID, groupID, iLevel, filters = C_LFGList.GetActivityInfo(activityID);

		if ( bit.band(filters, LE_LFG_LIST_FILTER_PVE) ~= 0 ) then
			func("GroupFinderFrame", "LFGListPVEStub");
		else
			func("PVPUIFrame", "LFGListPVPStub");
		end
	else
		--Open to the last window we had open
		if ( bit.band(LFGListFrame.baseFilters, LE_LFG_LIST_FILTER_PVE) ~= 0 ) then
			func("GroupFinderFrame", "LFGListPVEStub");
		else
			func("PVPUIFrame", "LFGListPVPStub");
		end
	end
end

function LFGListUtil_SortActivitiesByRelevancyCB(id1, id2)
	local fullName1, _, _, _, iLevel1, _, minLevel1 = C_LFGList.GetActivityInfo(id1);
	local fullName2, _, _, _, iLevel2, _, minLevel2 = C_LFGList.GetActivityInfo(id2);

	if ( minLevel1 ~= minLevel2 ) then
		return minLevel1 > minLevel2;
	elseif ( iLevel1 ~= iLevel2 ) then
		local myILevel = GetAverageItemLevel();

		if ((iLevel1 <= myILevel) ~= (iLevel2 <= myILevel) ) then
			--If one is below our item level and the other above, choose the one we meet
			return iLevel1 < myILevel;
		else
			--If both are above or both are below, choose the one closest to our iLevel
			return math.abs(iLevel1 - myILevel) < math.abs(iLevel2 - myILevel);
		end
	else
		return strcmputf8i(fullName1, fullName2) < 0;
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
	if ( isApplication and C_LFGList.GetActiveEntryInfo() ) then
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
		local status, mapName, teamSize, registeredMatch, suspend = GetBattlefieldStatus(i);
		if ( status and status ~= "none" ) then
			return CANNOT_DO_THIS_IN_BATTLEGROUND;
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
	local active, activityID, iLevel, honorLevel, name, comment, voiceChat, expiration, oldAutoAccept, privateGroup, questID = C_LFGList.GetActiveEntryInfo();
	if active then
		C_LFGList.CopyActiveEntryInfoToCreationFields();
		C_LFGList.UpdateListing(activityID, iLevel, honorLevel, autoAccept, privateGroup, questID);
	end
end

LFG_LIST_UTIL_SUPPRESS_AUTO_ACCEPT_LINE = 1;
LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE = 2;

function LFGListUtil_SetSearchEntryTooltip(tooltip, resultID, autoAcceptOption)
	local id, activityID, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted, leaderName, numMembers, isAutoAccept, questID = C_LFGList.GetSearchResultInfo(resultID);
	local activityName, shortName, categoryID, groupID, minItemLevel, filters, minLevel, maxPlayers, displayType, _, useHonorLevel = C_LFGList.GetActivityInfo(activityID);
	local memberCounts = C_LFGList.GetSearchResultMemberCounts(resultID);
	tooltip:SetText(name, 1, 1, 1, true);
	tooltip:AddLine(activityName);
	if ( comment and comment == "" and questID ) then
		comment = LFGListUtil_GetQuestDescription(questID);
	end
	if ( comment ~= "" ) then
		tooltip:AddLine(string.format(LFG_LIST_COMMENT_FORMAT, comment), LFG_LIST_COMMENT_FONT_COLOR.r, LFG_LIST_COMMENT_FONT_COLOR.g, LFG_LIST_COMMENT_FONT_COLOR.b, true);
	end
	tooltip:AddLine(" ");
	if ( iLvl > 0 ) then
		tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_ILVL, iLvl));
	end
	if ( useHonorLevel and honorLevel > 0 ) then
		tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_HONOR_LEVEL, honorLevel));
	end
	if ( voiceChat ~= "" ) then
		tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_VOICE_CHAT, voiceChat), nil, nil, nil, true);
	end
	if ( iLvl > 0 or (useHonorLevel and honorLevel > 0) or voiceChat ~= "" ) then
		tooltip:AddLine(" ");
	end

	if ( leaderName ) then
		tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_LEADER, leaderName));
	end
	if ( age > 0 ) then
		tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_AGE, SecondsToTime(age, false, false, 1, false)));
	end

	if ( leaderName or age > 0 ) then
		tooltip:AddLine(" ");
	end

	if ( displayType == LE_LFG_LIST_DISPLAY_TYPE_CLASS_ENUMERATE ) then
		tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_MEMBERS_SIMPLE, numMembers));
		for i=1, numMembers do
			local role, class, classLocalized = C_LFGList.GetSearchResultMemberInfo(resultID, i);
			local classColor = RAID_CLASS_COLORS[class] or NORMAL_FONT_COLOR;
			tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_CLASS_ROLE, classLocalized, _G[role]), classColor.r, classColor.g, classColor.b);
		end
	else
		tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_MEMBERS, numMembers, memberCounts.TANK, memberCounts.HEALER, memberCounts.DAMAGER));
	end

	if ( numBNetFriends + numCharFriends + numGuildMates > 0 ) then
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

	if autoAcceptOption == LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE and isAutoAccept then
		tooltip:AddLine(" ");
		tooltip:AddLine(LFG_LIST_TOOLTIP_AUTO_ACCEPT, LIGHTBLUE_FONT_COLOR:GetRGB());
	end

	if ( isDelisted ) then
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
		local fullName, shortName, categoryID, groupID, iLevel, filters, minLevel, maxPlayers, displayType = C_LFGList.GetActivityInfo(activityID);

		-- NOTE: There's an issue where filters will actually contain ALL of the filters for the given activity.
		-- This portion of the UI only cares about the filters for specific categories that get updated when the category buttons are added,
		-- and furthermore only cares about them when we're separating a single category into recommended and non-recommended.
		-- The baseFilters on the frame contain the rest of the required filters.
		-- To solve this so that category selection can be properly driven from the API, only use the filters that would be present on the button.
		-- Otherwise the selection will not work, and it won't be possible to create a group automatically.
		local _, separateRecommended = C_LFGList.GetCategoryInfo(categoryID);
		if separateRecommended then
			if bit.bor(filters, LE_LFG_LIST_FILTER_RECOMMENDED) then
				filters = LE_LFG_LIST_FILTER_RECOMMENDED;
			elseif bit.bor(filters, LE_LFG_LIST_FILTER_NOT_RECOMMENDED) then
				filters = LE_LFG_LIST_FILTER_NOT_RECOMMENDED;
			else
				filters = 0;
			end
		else
			filters = 0;
		end

		return activityID, categoryID, filters, questName;
	end
end

function LFGListUtil_FindQuestGroup(questID)
	if C_LFGList.GetActiveEntryInfo() then
		if LFGListUtil_CanListGroup() then
			StaticPopup_Show("PREMADE_GROUP_SEARCH_DELIST_WARNING", nil, nil, questID);
		else
			LFGListUtil_OpenBestWindow();
		end
	else
		LFGListFrame_BeginFindQuestGroup(LFGListFrame, questID);
	end
end

function LFGListUtil_GetQuestDescription(questID)
	local descriptionFormat = AUTO_GROUP_CREATION_NORMAL_QUEST;
	if ( QuestUtils_IsQuestWorldQuest(questID) ) then
		descriptionFormat = AUTO_GROUP_CREATION_WORLD_QUEST;
	end

	return descriptionFormat:format(QuestUtils_GetQuestName(questID));
end
