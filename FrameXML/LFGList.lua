ACTIVITY_RETURN_VALUES = {
	fullName = 1,
	shortName = 2,
	categoryID = 3,
	groupID = 4,
	itemLevel = 5,
};

-------------------------------------------------------
----------Base Frame
-------------------------------------------------------
function LFGListFrame_OnLoad(self)
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE");
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterEvent("LFG_LIST_ENTRY_CREATION_FAILED");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED");
	self:RegisterEvent("LFG_LIST_SEARCH_FAILED");
	LFGListFrame_SetActivePanel(self, self.NothingAvailable);

	self.EventsInBackground = {
		LFG_LIST_SEARCH_FAILED = { self.SearchPanel };
	}
end

function LFGListFrame_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_AVAILABILITY_UPDATE" ) then
		LFGListFrame_FixPanelValid(self);
	elseif ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		LFGListFrame_FixPanelValid(self);	--If our current panel isn't valid, change it.
		if ( C_LFGList.GetActiveEntryInfo() ) then
			self.EntryCreation.WorkingCover:Hide();
		end
	elseif ( event == "LFG_LIST_ENTRY_CREATION_FAILED" ) then
		self.EntryCreation.WorkingCover:Hide();
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
	C_LFGList.RequestAvailableActivities();
	PlaySound("igCharacterInfoOpen");
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

	--DEBUG - Always let us open the search panel and category selection panel
	if ( panel == self.SearchPanel or panel == self.CategorySelection ) then
		return true;
	end
	--END DEBUG

	if ( listed and panel ~= self.ApplicationViewer and not (panel == self.EntryCreation and LFGListEntryCreation_IsEditMode(self.EntryCreation)) ) then
		return false;
	end

	if ( not listed and (panel == self.ApplicationViewer or
			(panel == self.EntryCreation and LFGListEntryCreation_IsEditMode(self.EntryCreation)) ) ) then
		return false;
	end

	if ( #C_LFGList.GetAvailableCategories() == 0 ) then
		if ( panel == self.CategorySelection ) then
			return false;
		end
	else
		if ( panel == self.NothingAvailable ) then
			return false;
		end
	end

	return true;
end

function LFGListFrame_GetBestPanel(self)
	local listed = C_LFGList.GetActiveEntryInfo();

	if ( listed ) then
		return self.ApplicationViewer;
	elseif ( #C_LFGList.GetAvailableCategories() == 0 ) then
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
end

function LFGListCategorySelection_OnShow(self)
	LFGListCategorySelection_UpdateCategoryButtons(self);
end

function LFGListCategorySelection_UpdateCategoryButtons(self)
	local categories = C_LFGList.GetAvailableCategories();

	local nextBtn = 1;
	--Update category buttons
	for i=1, #categories do
		local categoryID = categories[i];
		local name, separateRecommended = C_LFGList.GetCategoryInfo(categoryID);

		if ( separateRecommended ) then
			nextBtn = LFGListCategorySelection_AddButton(self, nextBtn, categoryID, LE_LFG_LIST_FILTER_RECOMMENDED);
			nextBtn = LFGListCategorySelection_AddButton(self, nextBtn, categoryID, LE_LFG_LIST_FILTER_NOT_RECOMMENDED);
		else
			nextBtn = LFGListCategorySelection_AddButton(self, nextBtn, categoryID, 0);
		end
	end

	--Hide any extra buttons
	for i=nextBtn, #self.CategoryButtons do
		self.CategoryButtons[i]:Hide();
	end
end

function LFGListCategorySelection_AddButton(self, btnIndex, categoryID, filters)
	--Check that we have activities with this filter
	if ( filters ~= 0 and #C_LFGList.GetAvailableActivities(categoryID, nil, filters) == 0) then
		return btnIndex;
	end

	local name, separateRecommended = C_LFGList.GetCategoryInfo(categoryID);

	local button = self.CategoryButtons[btnIndex];
	if ( not button ) then
		self.CategoryButtons[btnIndex] = CreateFrame("BUTTON", nil, self, "LFGListCategoryTemplate");
		self.CategoryButtons[btnIndex]:SetPoint("TOP", self.CategoryButtons[btnIndex - 1], "BOTTOM", 0, -5);
		button = self.CategoryButtons[btnIndex];
	end

	button:SetText(LFGListUtil_GetDecoratedCategoryName(name, filters, true));
	button.categoryID = categoryID;
	button.filters = filters;
	if ( self.selectedCategory == categoryID and self.selectedFilters == filters ) then
		button:LockHighlight();
	else
		button:UnlockHighlight();
	end

	return btnIndex + 1;
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
	if ( IsInGroup() and not UnitIsGroupLeader("player") ) then
		startEnabled = false;
		self.StartGroupButton.tooltip = LFG_LIST_NOT_LEADER;
	end

	self.FindGroupButton:SetEnabled(findEnabled);
	self.StartGroupButton:SetEnabled(startEnabled);
end

function LFGListCategorySelectionStartGroupButton_OnClick(self)
	local panel = self:GetParent();
	if ( not panel.selectedCategory ) then
		return;
	end

	local entryCreation = panel:GetParent().EntryCreation;
	LFGListEntryCreation_Clear(entryCreation);
	LFGListEntryCreation_SetEditMode(entryCreation, false);
	LFGListEntryCreation_Select(entryCreation, panel.selectedFilters, panel.selectedCategory);
	LFGListFrame_SetActivePanel(panel:GetParent(), entryCreation);
end

function LFGListCategorySelectionFindGroupButton_OnClick(self)
	local panel = self:GetParent();
	if ( not panel.selectedCategory ) then
		return;
	end

	local searchPanel = panel:GetParent().SearchPanel;
	LFGListSearchPanel_Clear(searchPanel);
	LFGListSearchPanel_SetCategory(searchPanel, panel.selectedCategory, panel.selectedFilters);
	LFGListSearchPanel_DoSearch(searchPanel);
	LFGListFrame_SetActivePanel(panel:GetParent(), searchPanel);
end

--The individual category buttons
function LFGListCategorySelectionButton_OnClick(self)
	local panel = self:GetParent();
	LFGListCategorySelection_SelectCategory(panel, self.categoryID, self.filters);
end

-------------------------------------------------------
----------List Entry Creation
-------------------------------------------------------
function LFGListEntryCreation_OnLoad(self)
	self.Name.Instructions:SetText(LFG_LIST_ENTER_NAME);
	LFGListUtil_SetUpDropDown(self, self.CategoryDropDown, LFGListEntryCreation_PopulateCategories, LFGListEntryCreation_OnCategorySelected);
	LFGListUtil_SetUpDropDown(self, self.GroupDropDown, LFGListEntryCreation_PopulateGroups, LFGListEntryCreation_OnGroupSelected);
	LFGListUtil_SetUpDropDown(self, self.ActivityDropDown, LFGListEntryCreation_PopulateActivities, LFGListEntryCreation_OnActivitySelected);
end

function LFGListEntryCreation_Clear(self)
	--Clear selections
	self.selectedCategory = nil;
	self.selectedGroup = nil;
	self.selectedActivity = nil;
	self.selectedFilters = nil;

	--Reset widgets
	self.Name:SetText("");
	self.ItemLevel.CheckButton:SetChecked(false);
	self.ItemLevel.EditBox:SetText("");
	self.VoiceChat.CheckButton:SetChecked(false);
	self.VoiceChat.EditBox:SetText("");
	self.Description.EditBox:SetText("");
end

--This function accepts any or all of categoryID, groupId, and activityID
function LFGListEntryCreation_Select(self, filters, categoryID, groupID, activityID)
	filters, categoryID, groupID, activityID = LFGListUtil_AugmentWithBest(filters, categoryID, groupID, activityID);
	self.selectedCategory = categoryID;
	self.selectedGroup = groupID;
	self.selectedActivity = activityID;
	self.selectedFilters = filters;

	--Update the category dropdown
	local categoryName = C_LFGList.GetCategoryInfo(categoryID);
	UIDropDownMenu_SetText(self.CategoryDropDown, LFGListUtil_GetDecoratedCategoryName(categoryName, filters, false));

	--Update the activity dropdown
	local shortName = select(ACTIVITY_RETURN_VALUES.shortName, C_LFGList.GetActivityInfo(activityID));
	UIDropDownMenu_SetText(self.ActivityDropDown, shortName);

	--Update the group dropdown. If the group dropdown is showing an activity, hide the activity dropdown
	local groupName = C_LFGList.GetActivityGroupInfo(groupID);
	UIDropDownMenu_SetText(self.GroupDropDown, groupName or shortName);
	self.ActivityDropDown:SetShown(groupName);
end

function LFGListEntryCreation_PopulateCategories(self, dropDown, info)
	local categories = C_LFGList.GetAvailableCategories();
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

	local groups = C_LFGList.GetAvailableActivityGroups(self.selectedCategory, self.selectedFilters);
	for i=1, #groups do
		local groupID = groups[i];
		local name = C_LFGList.GetActivityGroupInfo(groupID);

		info.text = name;
		info.value = groupID;
		info.arg1 = false;	--isActuallyActivity
		info.checked = (self.selectedGroup == groupID);
		info.isRadio = true;
		UIDropDownMenu_AddButton(info);
	end

	--We also have in this dropdown any activities that have no parents
	local activities = C_LFGList.GetAvailableActivities(self.selectedCategory, 0, self.selectedFilters);
	for i=1, #activities do
		local activityID = activities[i];
		local name = select(ACTIVITY_RETURN_VALUES.shortName, C_LFGList.GetActivityInfo(activityID));

		info.text = name;
		info.value = activityID;
		info.arg1 = true;	--isActuallyActivity
		info.checked = (self.selectedActivity == activityID);
		info.isRadio = true;
		UIDropDownMenu_AddButton(info);
	end
end

function LFGListEntryCreation_OnGroupSelected(self, id, isActuallyActivity)
	if ( isActuallyActivity ) then
		LFGListEntryCreation_Select(self, nil, nil, nil, id);
	else
		LFGListEntryCreation_Select(self, self.selectedFilters, self.selectedCategory, id, nil);
	end
end

function LFGListEntryCreation_PopulateActivities(self, dropDown, info)
	local activities = C_LFGList.GetAvailableActivities(self.selectedCategory, self.selectedGroup, self.selectedFilters);
	for i=1, #activities do
		local activityID = activities[i];
		local shortName = select(ACTIVITY_RETURN_VALUES.shortName, C_LFGList.GetActivityInfo(activityID));

		info.text = shortName;
		info.value = activityID;
		info.checked = (self.selectedActivity == activityID);
		info.isRadio = true;
		UIDropDownMenu_AddButton(info);
	end
end

function LFGListEntryCreation_OnActivitySelected(self, activityID)
	LFGListEntryCreation_Select(self, nil, nil, nil, activityID);
end

function LFGListEntryCreation_ListGroup(self)
	if ( LFGListEntryCreation_IsEditMode(self) ) then
		C_LFGList.UpdateListing(self.selectedActivity, self.Name:GetText(), tonumber(self.ItemLevel.EditBox:GetText()) or 0, self.VoiceChat.EditBox:GetText(), self.Description.EditBox:GetText());
		LFGListFrame_SetActivePanel(self:GetParent(), self:GetParent().ApplicationViewer);
	else
		C_LFGList.CreateListing(self.selectedActivity, self.Name:GetText(), tonumber(self.ItemLevel.EditBox:GetText()) or 0, self.VoiceChat.EditBox:GetText(), self.Description.EditBox:GetText());
		self.WorkingCover:Show();
	end
end

function LFGListEntryCreation_SetEditMode(self, editMode)
	self.editMode = editMode;
	if ( editMode ) then
		local active, activityID, ilvl, name, comment, voiceChat = C_LFGList.GetActiveEntryInfo();
		assert(active);

		--Update the dropdowns
		LFGListEntryCreation_Select(self, nil, nil, nil, activityID);
		UIDropDownMenu_DisableDropDown(self.CategoryDropDown);
		UIDropDownMenu_DisableDropDown(self.GroupDropDown);
		UIDropDownMenu_DisableDropDown(self.ActivityDropDown);

		--Update edit boxes
		self.Name:SetText(name);
		self.ItemLevel.EditBox:SetText(ilvl == 0 and "" or ilvl);
		self.VoiceChat.EditBox:SetText(voiceChat);
		self.Description.EditBox:SetText(comment);

		self.ListGroupButton:SetText(DONE_EDITING);
	else
		UIDropDownMenu_EnableDropDown(self.CategoryDropDown);
		UIDropDownMenu_EnableDropDown(self.GroupDropDown);
		UIDropDownMenu_EnableDropDown(self.ActivityDropDown);
		self.ListGroupButton:SetText(LIST_GROUP);
	end
end

function LFGListEntryCreation_IsEditMode(self)
	return self.editMode;
end

function LFGListEntryCreationCancelButton_OnClick(self)
	local panel = self:GetParent();
	if ( LFGListEntryCreation_IsEditMode(panel) ) then
		LFGListFrame_SetActivePanel(panel:GetParent(), panel:GetParent().ApplicationViewer);
	else
		LFGListFrame_SetActivePanel(panel:GetParent(), panel:GetParent().CategorySelection);
	end
end

function LFGListEntryCreationListGroupButton_OnClick(self)
	LFGListEntryCreation_ListGroup(self:GetParent());
end

-------------------------------------------------------
----------Application Viewing
-------------------------------------------------------
function LFGListApplicationViewer_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		LFGListApplicationViewer_UpdateInfo(self);
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		LFGListApplicationViewer_UpdateAvailability(self);
	end
end

function LFGListApplicationViewer_OnShow(self)
	LFGListApplicationViewer_UpdateInfo(self);
	LFGListApplicationViewer_UpdateAvailability(self);
end

function LFGListApplicationViewer_OnUpdate(self)
	if ( self.expiration ) then
		local duration = self.expiration - GetTime();
		self.Duration:SetText(SecondsToTime(duration, false, false, 1, false));
	else
		self.Duration:SetText("");
	end
end

function LFGListApplicationViewer_UpdateInfo(self)
	local active, activityID, ilvl, name, comment, voiceChat, duration = C_LFGList.GetActiveEntryInfo();
	assert(active);
	self.EntryName:SetText(name);
	self.ActivityName:SetText(select(ACTIVITY_RETURN_VALUES.fullName, C_LFGList.GetActivityInfo(activityID)));
	self.DescriptionFrame.Text:SetText(comment);

	local hasRestrictions = false;
	if ( ilvl == 0 ) then
		self.ItemLevel:SetText("");
		self.VoiceChatFrame:SetPoint("TOPLEFT", self.ItemLevel, "TOPRIGHT", 0, 0);
	else
		hasRestrictions = true;
		self.ItemLevel:SetFormattedText(LFG_LIST_ITEM_LEVEL_CURRENT, ilvl);
		self.VoiceChatFrame:SetPoint("TOPLEFT", self.ItemLevel, "TOPRIGHT", 20, 0);
	end

	if ( voiceChat == "" ) then
		self.VoiceChatFrame.tooltip = nil;
		self.VoiceChatFrame:Hide();
	else
		hasRestrictions = true;
		self.VoiceChatFrame.tooltip = voiceChat;
		self.VoiceChatFrame:Show();
	end

	if ( hasRestrictions ) then
		self.DescriptionFrame:SetHeight(14);
	else
		self.DescriptionFrame:SetHeight(28);
	end

	self.expiration = GetTime() + duration;
end

function LFGListApplicationViewer_UpdateAvailability(self)
	if ( UnitIsGroupLeader("player") ) then
		self.RemoveEntryButton:Show();
		self.EditButton:Show();
	else
		self.RemoveEntryButton:Hide();
		self.EditButton:Hide();
	end
end

function LFGListApplicationViewerEditButton_OnClick(self)
	local panel = self:GetParent();
	local entryCreation = panel:GetParent().EntryCreation;
	LFGListEntryCreation_SetEditMode(entryCreation, true);
	LFGListFrame_SetActivePanel(panel:GetParent(), entryCreation);
end

-------------------------------------------------------
----------Searching
-------------------------------------------------------
function LFGListSearchPanel_OnLoad(self)
	self.ScrollFrame.update = function() LFGListSearchPanel_UpdateResults(self); end;
	self.ScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.ScrollFrame, "LFGListSearchEntryTemplate");
end

function LFGListSearchPanel_OnEvent(self, event, ...)
	--Note: events are dispatched from the base frame. Add RegisterEvent there.
	if ( event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" ) then
		StaticPopupSpecial_Hide(LFGListApplicationDialog);
		self.searching = false;
		self.searchFailed = false;
		LFGListSearchPanel_UpdateResultList(self);
		LFGListSearchPanel_UpdateResults(self);
	elseif ( event == "LFG_LIST_SEARCH_FAILED" ) then
		self.searching = false;
		self.searchFailed = true;
		LFGListSearchPanel_UpdateResultList(self);
		LFGListSearchPanel_UpdateResults(self);
	end
end

function LFGListSearchPanel_OnShow(self)
	LFGListSearchPanel_UpdateResultList(self);
	LFGListSearchPanel_UpdateResults(self);
end

function LFGListSearchPanel_Clear(self)
	C_LFGList.ClearSearchResults();
	self.SearchBox:SetText("");
	self.selectedResult = nil;
	LFGListSearchPanel_UpdateResultList(self);
	LFGListSearchPanel_UpdateResults(self);
end

function LFGListSearchPanel_SetCategory(self, categoryID, filters)
	self.categoryID = categoryID;
	self.filters = filters;

	local name = LFGListUtil_GetDecoratedCategoryName(C_LFGList.GetCategoryInfo(categoryID), filters, false);
	self.CategoryName:SetText(name);
end

function LFGListSearchPanel_DoSearch(self)
	C_LFGList.Search(self.categoryID, self.SearchBox:GetText(), self.filters);
	self.searching = true;
	self.searchFailed = false;
	self.selectedResult = nil;
	LFGListSearchPanel_UpdateResultList(self);
	LFGListSearchPanel_UpdateResults(self);
end

function LFGListSearchPanel_UpdateResultList(self)
	self.totalResults, self.results = C_LFGList.GetSearchResults();
	self.applications = C_LFGList.GetApplications();
	LFGListUtil_SortSearchResults(self.results);
end

function LFGListSearchPanel_UpdateResults(self)
	local offset = HybridScrollFrame_GetOffset(self.ScrollFrame);
	local buttons = self.ScrollFrame.buttons;

	if ( self.searching ) then
		self.SearchingSpinner:Show();
		self.ScrollFrame.NoResultsFound:Hide();
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
			self.ScrollFrame.NoResultsFound:SetPoint("CENTER", self.ScrollFrame, "BOTTOM", 0, (self.ScrollFrame:GetHeight() - totalHeight)/2);
		end
		self.ScrollFrame.NoResultsFound:SetShown(#results == 0);
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
	local resultID = self.selectedResult;
	if ( resultID ) then
		self.SignUpButton:Enable();
	else
		self.SignUpButton:Disable();
	end
end

function LFGListSearchPanel_SignUp(self)
	LFGListApplicationDialog_Show(LFGListApplicationDialog, self.selectedResult);
end

function LFGListSearchEntry_OnLoad(self)
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");
end

function LFGListSearchEntry_Update(self)
	local resultID = self.resultID;
	local _, appStatus, appDuration = C_LFGList.GetApplicationInfo(resultID);
	local isApplication = (appStatus ~= "none");

	--Update visibility based on whether we're an application or not
	self.isApplication = isApplication;
	self.ApplicationBG:SetShown(isApplication);
	self.ResultBG:SetShown(not isApplication);
	self.TankCount:SetShown(not isApplication);
	self.HealerCount:SetShown(not isApplication);
	self.DamageCount:SetShown(not isApplication);
	self.CancelButton:SetShown(isApplication and appStatus ~= "applying");
	self.Spinner:SetShown(appStatus == "applying");

	if ( appStatus == "canceling" or appStatus == "failed" ) then
		self.PendingLabel:SetText(LFG_LIST_APP_CANCELLED);
		self.PendingLabel:Show();
		self.ExpirationTime:Hide();
	elseif ( isApplication and appStatus ~= "applying" ) then
		self.PendingLabel:SetText(LFG_LIST_PENDING);
		self.PendingLabel:Show();
		self.ExpirationTime:Show();
	else
		self.PendingLabel:Hide();
		self.ExpirationTime:Hide();
	end

	self.expiration = GetTime() + appDuration;

	local panel = self:GetParent():GetParent():GetParent();

	local id, activityID, name, comment, voiceChat, iLvl, age, numBNetFriends, numCharFriends, numGuildMates, numTanks, numHealers, numDPS = C_LFGList.GetSearchResultInfo(resultID);
	local activityName = C_LFGList.GetActivityInfo(activityID);

	self.resultID = resultID;
	self.Selected:SetShown(panel.selectedResult == resultID and not isApplication);
	self.Highlight:SetShown(panel.selectedResult ~= resultID and not isApplication);
	self.Name:SetText(name);
	self.ActivityName:SetText(activityName);
	self.TankCount:SetText(numTanks);
	self.HealerCount:SetText(numHealers);
	self.DamageCount:SetText(numDPS);
	self.VoiceChat:SetShown(voiceChat ~= "" and not isApplication);
	self.VoiceChat.tooltip = string.format(LFG_LIST_TOOLTIP_VOICE_CHAT, voiceChat);
	self.Friends:SetShown(numBNetFriends + numCharFriends + numGuildMates > 0 and not isApplication);

	local nameWidth = 185;
	if ( isApplication ) then
		nameWidth = 165;
	elseif ( numBNetFriends + numCharFriends + numGuildMates > 0 ) then
		nameWidth = 145;
	elseif ( voiceChat ~= "" ) then
		nameWidth = 165;
	end
	self.Name:SetWidth(nameWidth);
	self.ActivityName:SetWidth(nameWidth);

	local mouseFocus = GetMouseFocus();
	if ( mouseFocus == self ) then
		LFGListSearchEntry_OnEnter(self);
	end
	if ( mouseFocus == self.VoiceChat ) then
		mouseFocus:GetScript("OnEnter")(mouseFocus);
	end
	if ( mouseFocus == self.Friends ) then
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
	end
end

function LFGListSearchEntry_OnClick(self)
	local scrollFrame = self:GetParent():GetParent();
	LFGListSearchPanel_SelectResult(scrollFrame:GetParent(), self.resultID);
end

function LFGListSearchEntry_OnEnter(self)
	local resultID = self.resultID;
	local id, activityID, name, comment, voiceChat, iLvl, age, numBNetFriends, numCharFriends, numGuildMates, numTanks, numHealers, numDPS = C_LFGList.GetSearchResultInfo(resultID);
	local activityName = C_LFGList.GetActivityInfo(activityID);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(name, 1, 1, 1, true);
	GameTooltip:AddLine(activityName);
	if ( comment ~= "" ) then
		GameTooltip:AddLine(string.format(LFG_LIST_COMMENT_FORMAT, comment), GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
	end
	GameTooltip:AddLine(" ");
	if ( iLvl > 0 ) then
		GameTooltip:AddLine(string.format(LFG_LIST_TOOLTIP_ILVL, iLvl));
	end
	if ( voiceChat ~= "" ) then
		GameTooltip:AddLine(string.format(LFG_LIST_TOOLTIP_VOICE_CHAT, voiceChat), nil, nil, nil, true);
	end
	if ( iLvl > 0 or voiceChat ~= "" ) then
		GameTooltip:AddLine(" ");
	end

	if ( age > 0 ) then
		GameTooltip:AddLine(string.format(LFG_LIST_TOOLTIP_AGE, SecondsToTime(age, false, false, 1, false)));
	end
	GameTooltip:AddLine(string.format(LFG_LIST_TOOLTIP_MEMBERS, numTanks + numHealers + numDPS, numTanks, numHealers, numDPS));

	if ( numBNetFriends + numCharFriends + numGuildMates > 0 ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(LFG_LIST_TOOLTIP_FRIENDS_IN_GROUP);
		GameTooltip:AddLine(LFGListSearchEntryUtil_GetFriendList(resultID), 1, 1, 1, true);
	end
	GameTooltip:Show();
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
end

function LFGListApplicationDialog_OnEvent(self, event)
	if ( event == "LFG_ROLE_UPDATE" ) then
		LFGListApplicationDialog_UpdateRoles(self);
	end
end

function LFGListApplicationDialog_Show(self, resultID)
	self.resultID = resultID;
	self.Description.EditBox:SetText("");
	LFGListApplicationDialog_UpdateRoles(self);
	StaticPopupSpecial_Show(self);
end

function LFGListApplicationDialog_UpdateRoles(self)
	local availTank, availHealer, availDPS = C_LFGList.GetAvailableRoles();

	local avail1, avail2;
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
		if ( avail1 ) then
			avail2 = self.DamagerButton;
		else
			avail1 = self.DamagerButton;
		end
	end

	self.TankButton:SetShown(availTank);
	self.HealerButton:SetShown(availHealer);
	self.DamagerButton:SetShown(availDPS);

	if ( avail2 ) then
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
end

function LFGListRoleButtonCheckButton_OnClick(self)
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
	end

	local dialog = self:GetParent():GetParent();
	local leader, tank, healer, dps = GetLFGRoles();
	SetLFGRoles(leader, dialog.TankButton.CheckButton:GetChecked(), dialog.HealerButton.CheckButton:GetChecked(), dialog.DamagerButton.CheckButton:GetChecked());
end

-------------------------------------------------------
----------Utility functions
-------------------------------------------------------
function LFGListUtil_AugmentWithBest(filters, categoryID, groupID, activityID)
	if ( not activityID ) then
		--Find the best activity by iLevel
		local activities = C_LFGList.GetAvailableActivities(categoryID, groupID, filters);
		local bestItemLevel;
		for i=1, #activities do
			local iLevel = select(ACTIVITY_RETURN_VALUES.itemLevel, C_LFGList.GetActivityInfo(activities[i]));
			if ( not activityID or (iLevel > bestItemLevel and iLevel <= GetAverageItemLevel()) ) then
				activityID = activities[i];
				bestItemLevel = iLevel;
			end
		end

		--TODO: If the categoryID we're given has the flag set for using current area, use that instead
	end

	assert(activityID);

	--Update the categoryID and groupID with what we get from the activity
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

function LFGListUtil_ValidateLevelReq(text)
	if ( text ~= "" and tonumber(text) > GetAverageItemLevel() ) then
		return LFG_LIST_ILVL_ABOVE_YOURS
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
	if ( filter == LE_LFG_LIST_FILTER_NOT_RECOMMENDED ) then
		extraName = LFG_LIST_LEGACY;
	elseif ( filter == LE_LFG_LIST_FILTER_RECOMMENDED ) then
		for i=0, #MAX_PLAYER_LEVEL_TABLE do
			if ( UnitLevel("player") <= MAX_PLAYER_LEVEL_TABLE[i] ) then
				extraName = _G["EXPANSION_NAME"..i];
				break;
			end
		end
	end

	return string.format(LFG_LIST_CATEGORY_FORMAT, categoryName, colorStart, extraName, colorEnd);
end

function LFGListUtil_SortSearchResultsCB(id1, id2)
	local id1, activityID1, name1, comment1, voiceChat1, iLvl1, age1, numBNetFriends1, numCharFriends1, numGuildMates1, numTanks1, numHealers1, numDPS1 = C_LFGList.GetSearchResultInfo(id1);
	local id2, activityID2, name2, comment2, voiceChat2, iLvl2, age2, numBNetFriends2, numCharFriends2, numGuildMates2, numTanks2, numHealers2, numDPS2 = C_LFGList.GetSearchResultInfo(id2);

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
	return id1 > id2;
end

function LFGListUtil_SortSearchResults(results)
	table.sort(results, LFGListUtil_SortSearchResultsCB);
end
