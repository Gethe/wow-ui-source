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
	self:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE");
	LFGListFrame_SetActivePanel(self, self.NothingAvailable);
end

function LFGListFrame_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_AVAILABILITY_UPDATE" ) then
		if ( #C_LFGList.GetAvailableCategories() == 0 ) then
			LFGListFrame_SetActivePanel(self, self.NothingAvailable);
		elseif ( self.activePanel == self.NothingAvailable ) then
			LFGListFrame_SetActivePanel(self, self.CategorySelection);
		end
	end
	
	--Dispatch the event to our currently active panel
	local onEvent = self.activePanel and self.activePanel:GetScript("OnEvent");
	if ( onEvent ) then
		onEvent(self.activePanel, event, ...);
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

function LFGListCategorySelection_UpdateCategoryButtons(self)
	local categories = C_LFGList.GetAvailableCategories();

	--Update category buttons
	for i=1, #categories do
		local button = self.CategoryButtons[i];
		if ( not button ) then
			self.CategoryButtons[i] = CreateFrame("BUTTON", nil, self, "LFGListCategoryTemplate");
			self.CategoryButtons[i]:SetPoint("TOP", self.CategoryButtons[i - 1], "BOTTOM", 0, -5);
			button = self.CategoryButtons[i];
		end

		local categoryID = categories[i];
		local name = C_LFGList.GetCategoryInfo(categoryID);
		button:SetText(name);
		button.categoryID = categoryID;
		if ( self.selectedCategory == categoryID ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
	end

	--Hide any extra buttons
	for i=#categories + 1, #self.CategoryButtons do
		self.CategoryButtons[i]:Hide();
	end
end

function LFGListCategorySelection_SelectCategory(self, categoryID)
	self.selectedCategory = categoryID;
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
	LFGListEntryCreation_Select(entryCreation, panel.selectedCategory);
	LFGListFrame_SetActivePanel(panel:GetParent(), entryCreation);
end

--The individual category buttons
function LFGListCategorySelectionButton_OnClick(self)
	local panel = self:GetParent();
	LFGListCategorySelection_SelectCategory(panel, self.categoryID);
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

	--Reset widgets
	self.Name:SetText("");
	self.ItemLevel.CheckButton:SetChecked(false);
	self.ItemLevel.EditBox:SetText("");
	self.VoiceChat.CheckButton:SetChecked(false);
	self.VoiceChat.EditBox:SetText("");
	self.Description.EditBox:SetText("");
end

--This function accepts any or all of categoryID, groupId, and activityID
function LFGListEntryCreation_Select(self, categoryID, groupID, activityID)
	categoryID, groupID, activityID = LFGListUtil_AugmentWithBest(categoryID, groupID, activityID);
	self.selectedCategory = categoryID;
	self.selectedGroup = groupID;
	self.selectedActivity = activityID;

	--Update the category dropdown
	local categoryName = C_LFGList.GetCategoryInfo(categoryID);
	UIDropDownMenu_SetText(self.CategoryDropDown, categoryName);

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
		local name = C_LFGList.GetCategoryInfo(categoryID);

		info.text = name;
		info.value = categoryID;
		info.checked = (self.selectedCategory == categoryID);
		info.isRadio = true;
		UIDropDownMenu_AddButton(info);
	end
end

function LFGListEntryCreation_OnCategorySelected(self, categoryID)
	LFGListEntryCreation_Select(self, categoryID, nil, nil);
end

function LFGListEntryCreation_PopulateGroups(self, dropDown, info)
	if ( not self.selectedCategory ) then
		--We don't have a category, so we can't fill out groups.
		return;
	end

	local groups = C_LFGList.GetAvailableActivityGroups(self.selectedCategory);
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
	local activities = C_LFGList.GetAvailableActivities(self.selectedCategory, 0);
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
		LFGListEntryCreation_Select(self, nil, nil, id);
	else
		LFGListEntryCreation_Select(self, self.selectedCategory, id, nil);
	end
end

function LFGListEntryCreation_PopulateActivities(self, dropDown, info)
	local activities = C_LFGList.GetAvailableActivities(self.selectedCategory, self.selectedGroup);
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
	LFGListEntryCreation_Select(self, nil, nil, activityID);
end

function LFGListEntryCreationCancelButton_OnClick(self)
	local panel = self:GetParent();
	LFGListFrame_SetActivePanel(panel:GetParent(), panel:GetParent().CategorySelection);
end

-------------------------------------------------------
----------Utility functions
-------------------------------------------------------
function LFGListUtil_AugmentWithBest(categoryID, groupID, activityID)
	if ( not activityID ) then
		--Find the best activity by iLevel
		local activities = C_LFGList.GetAvailableActivities(categoryID, groupID);
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
	categoryID, groupID = select(ACTIVITY_RETURN_VALUES.categoryID, C_LFGList.GetActivityInfo(activityID));
	return categoryID, groupID, activityID;
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
