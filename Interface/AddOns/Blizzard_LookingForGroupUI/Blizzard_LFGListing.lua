-------------------------------------------------------
----------Constants
-------------------------------------------------------
local LFGLISTING_CATEGORY_TEXTURES = {
	[2] = "ratedbgs", -- Dungeons
	[117] = "dungeons", -- Heroic Dungeons
	[114] = "raids-wrath", -- Raids
	[116] = "questing", -- Quests & Zones
	[118] = "battlegrounds", -- PvP
	[120] = "custom-pve", -- Custom
};

local LFGLISTING_VIEWSTATE_CATEGORIES = 1;
local LFGLISTING_VIEWSTATE_ACTIVITIES = 2;
local LFGLISTING_VIEWSTATE_LOCKED = 3;

local LFGLISTING_BUTTONTYPE_CHECKALL = 1;
local LFGLISTING_BUTTONTYPE_ACTIVITY = 2;

local IN_SET_CATEGORY_SELECTION = false; -- Baby hack. This bool will be true when we're in code triggered by LFGListingMixin:SetCategorySelection. Useful for downstream effects.
local PENDING_LISTING_UPDATE = false; -- Will be true after the player fires off an update to their listing from the UI. Used to determine what feedback we should give.

-------------------------------------------------------
----------LFGListingMixin
-------------------------------------------------------
LFGListingMixin = {};

function LFGListingMixin:OnLoad()
	self:RegisterEvent("GROUP_LEFT");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE");
	self:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS");
	self:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TIMEOUT");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED");

	self.activities = {};
	self.categorySelection = nil;
	self.dirty = false;
	self.viewState = LFGLISTING_VIEWSTATE_ACTIVITIES;

	self:ClearUI();
	self:LoadSoloRoles();
	self:UpdateFrameView();
end

function LFGListingMixin:OnEvent(event, ...)
	if ( event == "GROUP_LEFT" ) then
		local partyCategory, partyGUID = ...;
		if (partyCategory == LE_PARTY_CATEGORY_HOME and not C_LFGList.HasActiveEntryInfo()) then
			-- If we just left a party and we don't have an activeEntry, assume that
			-- any activeEntry information we have was inherited from the group and should probably be thrown out.
			self:ClearCategorySelection();
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LEADER_CHANGED" ) then
		self:UpdateFrameView();
	elseif ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		local createdNew = ...;
		self:LoadActiveEntry();
		if (C_LFGList.HasActiveEntryInfo()) then
			if (createdNew or PENDING_LISTING_UPDATE) then
				-- Play sound, only if the update was manual.
				PlaySound(SOUNDKIT.PVP_ENTER_QUEUE);
			end
			if ( createdNew ) then
				-- Search LFM based on the active entry.
				LFGParentFrame_SearchActiveEntry();
			end
		else
			if (PENDING_LISTING_UPDATE) then
				-- Play sound, only if the update was manual.
				PlaySound(SOUNDKIT.LFG_DENIED);
			end
			self:SetDirty(self:IsAnyActivitySelected());
		end
		PENDING_LISTING_UPDATE = false;
	elseif ( event == "LFG_LIST_AVAILABILITY_UPDATE" ) then
		-- If available activities change, attempt a "soft reset" back to category selection. Then reload the active entry, if there is one.
		self:ClearCategorySelection();
		self:LoadActiveEntry();
	elseif ( event == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS" ) then
		if ( UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
			StaticPopup_Show("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS");
		end
	elseif ( event == "LFG_LIST_ENTRY_EXPIRED_TIMEOUT" ) then
		if ( UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
			StaticPopup_Show("LFG_LIST_ENTRY_EXPIRED_TIMEOUT");
		end
	elseif ( event == "PLAYER_ROLES_ASSIGNED" ) then
		UIDropDownMenu_Initialize(self.GroupRoleButtons.RoleDropDown, LFGListingRoleDropDown_Initialize);
		LFGListingRoleIcon_UpdateRoleTexture(self.GroupRoleButtons.RoleIcon);
	end
end

function LFGListingMixin:OnShow()
	-- Baby hack... the selected tab texture doesn't blend well with the LFG texture, so move it down a hair when it's selected.
	LFGParentFrameTab1:SetPoint("BOTTOMLEFT", 16, 43);
	LFGParentFrameTab2:SetPoint("LEFT", LFGParentFrameTab1, "RIGHT", -14, 2);

	self:LoadActiveEntry();

	if (not C_LFGList.HasActiveEntryInfo()) then
		self:SetDirty(self:IsAnyActivitySelected());
	end
	self:UpdatePostButtonEnableState();
	self:UpdateBackButtonEnableState();

	UIDropDownMenu_Initialize(self.GroupRoleButtons.RoleDropDown, LFGListingRoleDropDown_Initialize);
	LFGListingRoleIcon_UpdateRoleTexture(self.GroupRoleButtons.RoleIcon);
end

function LFGListingMixin:UpdateFrameView()
	-- Content view.
	self.CategoryView:Hide();
	self.ActivityView:Hide();
	self.LockedView:Hide();
	if (not LFGListingUtil_CanEditListing()) then
		self.viewState = LFGLISTING_VIEWSTATE_LOCKED;
		self.LockedView:Show();
	elseif (not self.categorySelection) then
		self.viewState = LFGLISTING_VIEWSTATE_CATEGORIES;
		self.CategoryView:Show();
	else
		self.viewState = LFGLISTING_VIEWSTATE_ACTIVITIES;
		self.ActivityView:Show();
	end

	-- Role view.
	if (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
		self.SoloRoleButtons:Hide();
		self.GroupRoleButtons:Show();
	else
		self.SoloRoleButtons:Show();
		self.GroupRoleButtons:Hide();
	end

	-- Buttons.
	self:UpdatePostButtonEnableState();
	self:UpdateBackButtonEnableState();
end

function LFGListingMixin:ClearUI()
	self:ClearCategorySelection();
	C_LFGList.ClearCreationTextFields();
	self.ActivityView.Comment.EditBox:ClearFocus();
	self:SetDirty(false);
end

function LFGListingMixin:SetDirty(state)
	self.dirty = state;
	self:UpdatePostButtonEnableState();
end

-------------------------------------------------------
----------Active Entry
-------------------------------------------------------
function LFGListingMixin:LoadActiveEntry()
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();

	if (activeEntryInfo) then
		-- Set LFG settings
		local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityIDs[1]);
		self:SetCategorySelection(activityInfo.categoryID); -- This will call UpdateActivities.
		C_LFGList.CopyActiveEntryInfoToCreationFields();
		self:SetDirty(false);
	end
end

function LFGListingMixin:CreateOrUpdateListing()
	if (not self.dirty) then
		return;
	end

	local selectedActivityIDs = {};
	local hasSelectedActivity = false;
	local i = 1;
	for activityID, selected in pairs(self.activities) do
		if (selected) then
			hasSelectedActivity = true;
			selectedActivityIDs[i] = activityID;
			i = i+1;
		end
	end

	if (C_LFGList.HasActiveEntryInfo()) then
		if (hasSelectedActivity) then
			-- Update.
			PENDING_LISTING_UPDATE = true;
			C_LFGList.UpdateListing(selectedActivityIDs);
		else
			-- Delete.
			PENDING_LISTING_UPDATE = true;
			C_LFGList.RemoveListing();
		end
	else
		if (hasSelectedActivity) then
			-- Create.
			PENDING_LISTING_UPDATE = true;
			C_LFGList.CreateListing(selectedActivityIDs);
		end
	end
end

function LFGListingMixin:RemoveListing()
	PENDING_LISTING_UPDATE = true;
	C_LFGList.RemoveListing();
end

-------------------------------------------------------
----------Category Selection
-------------------------------------------------------
function LFGListingMixin:GetCategorySelection()
	return self.categorySelection;
end

function LFGListingMixin:SetCategorySelection(categoryID)
	IN_SET_CATEGORY_SELECTION = true;
	self.categorySelection = categoryID;
	self:UpdateActivities();
	self:UpdateFrameView();
	IN_SET_CATEGORY_SELECTION = false;
end

function LFGListingMixin:ClearCategorySelection()
	self.categorySelection = nil;
	self:UpdateActivities();
	self:UpdateFrameView();
end

-------------------------------------------------------
----------Activity Selection
-------------------------------------------------------
function LFGListingMixin:UpdateActivities()
	self:ClearActivities();
	if (self.categorySelection) then
		local _, _, autoChooseActivity = C_LFGList.GetCategoryInfo(self.categorySelection);
		local activities = C_LFGList.GetAvailableActivities(self.categorySelection);
		for i=1, #activities do
			self:SetActivity(activities[i], false, true); -- Initialize to false, then overwrite later.
		end

		if (C_LFGList.HasActiveEntryInfo()) then
			local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
			for i=1, #activeEntryInfo.activityIDs do
				self:SetActivity(activeEntryInfo.activityIDs[i], true);
			end
		elseif (autoChooseActivity) then
			self:SetAllActivities(true);
		end
	end
end

function LFGListingMixin:ClearActivities()
	self.activities = {};
end

function LFGListingMixin:IsActivitySelected(activityID)
	return self.activities[activityID];
end

function LFGListingMixin:IsAnyActivitySelected()
	for activityID, selected in pairs(self.activities) do
		if selected then
			return true;
		end
	end
	return false;
end

function LFGListingMixin:AreAllActivitiesSelected()
	for activityID, selected in pairs(self.activities) do
		if not selected then
			return false;
		end
	end
	return true;
end

function LFGListingMixin:SetActivity(activityID, selected, allowCreate, userInput)
	if (not allowCreate and self.activities[activityID] == nil) then
		return;
	end

	self.activities[activityID] = selected;
	if (userInput) then
		if (C_LFGList.HasActiveEntryInfo()) then
			self:SetDirty(true);
		else
			self:SetDirty(self:IsAnyActivitySelected());
		end
	end
end

function LFGListingMixin:SetAllActivities(selected, userInput)
	for activityID, _ in pairs(self.activities) do
		self:SetActivity(activityID, selected, false, userInput);
	end
end

function LFGListingMixin:ToggleActivity(activityID, allowCreate, userInput)
	self:SetActivity(activityID, not self:IsActivitySelected(activityID), allowCreate, userInput);
end

-------------------------------------------------------
----------Button Control
-------------------------------------------------------
function LFGListingMixin:UpdatePostButtonEnableState()
	-- Check dirty state.
	if (not self.dirty) then
		self.PostButton.errorText = nil;
		self.PostButton:SetEnabled(false);
		return;
	end

	-- Check party size state.
	if (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
		local groupCount = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
		for activityID, selected in pairs(self.activities) do
			if (selected) then
				local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
				local maxPlayers = activityInfo.maxNumPlayers;
				if (maxPlayers > 0 and groupCount >= maxPlayers) then
					self.PostButton.errorText = string.format(LFG_LIST_TOO_MANY_FOR_ACTIVITY, maxPlayers);
					self.PostButton:SetEnabled(false);
					return;
				end
			end
		end
	end

	self.PostButton.errorText = nil;
	self.PostButton:SetEnabled(true);
end

function LFGListingMixin:UpdateBackButtonEnableState()
	self.BackButton:SetEnabled(self.viewState == LFGLISTING_VIEWSTATE_ACTIVITIES);
end

-------------------------------------------------------
----------Solo Role UI
-------------------------------------------------------
function LFGListingMixin:LoadSoloRoles()
	local roles = C_LFGList.GetLFGRoles();
	self.SoloRoleButtons.Tank.CheckButton:SetChecked(roles.tank);
	self.SoloRoleButtons.Healer.CheckButton:SetChecked(roles.healer);
	self.SoloRoleButtons.DPS.CheckButton:SetChecked(roles.dps);
end

function LFGListingMixin:SetSoloRoles()
	C_LFGList.SetLFGRoles({
		tank   = self.SoloRoleButtons.Tank.CheckButton:GetChecked(),
		healer = self.SoloRoleButtons.Healer.CheckButton:GetChecked(),
		dps    = self.SoloRoleButtons.DPS.CheckButton:GetChecked(),
	});
end

-------------------------------------------------------
----------Group Role UI
-------------------------------------------------------
function LFGListingRoleDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	local currentRole = UnitGroupRolesAssigned("player");

	info.func = LFGListingRoleButton_OnClick;
	info.classicChecks = true;

	local buttons = {
		{ text = TANK, value = "TANK", },
		{ text = HEALER, value = "HEALER", },
		{ text = DAMAGER, value = "DAMAGER", },
		{ text = NO_ROLE, value = "NONE", },
	};

	for i, button in ipairs(buttons) do
		info.text = button.text;
		info.value = button.value;
		info.checked = currentRole == info.value;
		info.owner = self;
		UIDropDownMenu_AddButton(info);
		if (info.checked) then
			UIDropDownMenu_SetSelectedValue(self, info.value);
		end
	end
end

function LFGListingRoleButton_OnClick(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value);
	UnitSetRole("player", self.value);
end

function LFGListingRoleIcon_UpdateRoleTexture(self)
	local currentRole = UnitGroupRolesAssigned("player");
	if (currentRole == "NONE") then
		self:Hide();
	else
		self:Show();
		self:GetNormalTexture():SetTexCoord(GetTexCoordsForRole(currentRole));
		self.Background:SetTexCoord(GetBackgroundTexCoordsForRole(currentRole));
		self.roleID = currentRole;
	end
end

-------------------------------------------------------
----------Role Check Button
-------------------------------------------------------
function LFGListingRolePollButton_OnLoad(self)
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	LFGListingRolePollButton_UpdateEnableState(self);
end

function LFGListingRolePollButton_OnEvent(self, event)
	if (event == "PARTY_LEADER_CHANGED") then
		LFGListingRolePollButton_UpdateEnableState(self);
	end
end

function LFGListingRolePollButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	InitiateRolePoll();
end

function LFGListingRolePollButton_UpdateEnableState(self)
	if (IsInGroup() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))) then
		self:Enable();
	else
		self:Disable();
	end
end

-------------------------------------------------------
----------Post Button
-------------------------------------------------------
function LFGListingPostButton_OnLoad(self)
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	LFGListingPostButton_UpdateText(self);
end

function LFGListingPostButton_OnEvent(self, event)
	if ( event == "GROUP_ROSTER_UPDATE" or event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		LFGListingPostButton_UpdateText(self);
	end
end

function LFGListingPostButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	LFGListingFrame:CreateOrUpdateListing();
end

function LFGListingPostButton_UpdateText(self)
	if (C_LFGList.HasActiveEntryInfo()) then
		self:SetText(LFG_POST_GROUP_UPDATE);
	elseif (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
		self:SetText(LFG_POST_GROUP_PARTY);
	else
		self:SetText(LFG_POST_GROUP_SOLO);
	end
end

-------------------------------------------------------
----------Back Button
-------------------------------------------------------
function LFGListingBackButton_OnLoad(self)
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	LFGListingBackButton_UpdateText(self);
end

function LFGListingBackButton_OnEvent(self, event)
	if ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		LFGListingBackButton_UpdateText(self);
	end
end

function LFGListingBackButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if (C_LFGList.HasActiveEntryInfo()) then
		LFGListingFrame:RemoveListing();
	else
		LFGListingFrame:ClearUI();
	end
end

function LFGListingBackButton_UpdateText(self)
	if (C_LFGList.HasActiveEntryInfo()) then
		self:SetText(LFG_LIST_UNLIST);
	else
		self:SetText(BACK);
	end
end

-------------------------------------------------------
----------Category Selection
-------------------------------------------------------
function LFGListingCategorySelection_OnShow(self)
	LFGListingCategorySelection_UpdateCategoryButtons(self);
end

function LFGListingCategorySelection_UpdateCategoryButtons(self)
	local categories = C_LFGList.GetAvailableCategories();
	local nextBtn = 1;

	--Update category buttons
	for i=1, #categories do
		local categoryID = categories[i];
		local categoryInfo = C_LFGList.GetCategoryInfo(categoryID);

		nextBtn = LFGListingCategorySelection_AddButton(self, nextBtn, categoryID);
	end

	--Hide any extra buttons
	for i=nextBtn, #self.CategoryButtons do
		self.CategoryButtons[i]:Hide();
	end
end

function LFGListingCategorySelection_AddButton(self, btnIndex, categoryID)
	if ( #C_LFGList.GetAvailableActivities(categoryID, nil) == 0) then
		return btnIndex;
	end

	local categoryName = C_LFGList.GetCategoryInfo(categoryID);

	local button = self.CategoryButtons[btnIndex];
	if ( not button ) then
		self.CategoryButtons[btnIndex] = CreateFrame("BUTTON", nil, self, "LFGListingCategoryTemplate");
		self.CategoryButtons[btnIndex]:SetPoint("TOP", self.CategoryButtons[btnIndex - 1], "BOTTOM", 0, -4);
		button = self.CategoryButtons[btnIndex];
	end

	button:SetText(categoryName);
	button.categoryID = categoryID;

	local atlasName = "groupfinder-button-"..(LFGLISTING_CATEGORY_TEXTURES[categoryID] or "questing");
	button.Icon:SetAtlas(atlasName);

	button:Show();

	return btnIndex + 1;
end

function LFGListingCategorySelectionButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	LFGListingFrame:SetCategorySelection(self.categoryID);
end

-------------------------------------------------------
----------Activity Selection
-------------------------------------------------------
function LFGListingActivityView_OnLoad(self)
	local view = CreateScrollBoxListLinearView();

	view:SetElementFactory(function(factory, elementData)
		-- Check All button
		if (elementData.buttonType == LFGLISTING_BUTTONTYPE_CHECKALL) then

			local frame = factory("Frame", "LFGListingActivityCheckAllTemplate");

			frame.CheckButton:SetScript("OnClick", function(button, buttonName, down)
				LFGListingFrame:SetAllActivities(not LFGListingFrame:AreAllActivitiesSelected(), true);

				view:ForEachFrame(function(frame, elementData)
					if (elementData.buttonType == LFGLISTING_BUTTONTYPE_ACTIVITY) then
						LFGListingActivityView_InitActivityButton(frame, elementData);
					end
				end);
			end)

			LFGListingActivityView_InitCheckAllButton(frame, elementData);

		-- Individual Activity button
		elseif (elementData.buttonType == LFGLISTING_BUTTONTYPE_ACTIVITY) then
			local frame = factory("Frame", "LFGListingActivityTemplate");

			frame.CheckButton:SetScript("OnClick", function(button, buttonName, down)
				local activityID = button:GetParent():GetElementData().activityID;
				LFGListingFrame:ToggleActivity(activityID, false, true);

				local checkAllButton = view:FindFrameByPredicate(function(frame) return frame:GetElementData().buttonType == LFGLISTING_BUTTONTYPE_CHECKALL; end);
				if (checkAllButton) then
					LFGListingActivityView_InitCheckAllButton(checkAllButton, checkAllButton:GetElementData());
				end
			end)

			LFGListingActivityView_InitActivityButton(frame, elementData);
		end
	end);

	view:SetPadding(4,4,4,4,2);
	view:SetElementExtent(18);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", 0, 0),
		CreateAnchor("BOTTOMRIGHT", -28, 88);
	};
	local scrollBoxAnchorsWithoutBar = {
		scrollBoxAnchorsWithBar[1],
		CreateAnchor("BOTTOMRIGHT", 0, 88);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end

function LFGListingActivityView_OnShow(self)
	local categoryID = LFGListingFrame:GetCategorySelection();
	local _, _, autoChooseActivity = C_LFGList.GetCategoryInfo(categoryID);
	self.Comment.EditBox:ClearFocus();
	if (autoChooseActivity) then
		-- For auto-choose activity categories, we're going to check everything, so only show the comment.
		self.BarLeft:Hide();
		self.BarMiddle:Hide();
		self.BarRight:Hide();
		self.ScrollBox:Hide();
		self.Comment:ClearAllPoints();
		self.Comment:SetPoint("CENTER", 0, 20);
		self.Comment:SetHeight(110);
		self.Comment.EditBox.Instructions:SetText(DESCRIPTION_OF_YOUR_GROUP_MANDATORY);
		if (IN_SET_CATEGORY_SELECTION) then -- If this is being invoked because the user is choosing a category, auto-select the comment box.
			self.Comment.EditBox:SetFocus();
		end
	else
		self.BarLeft:Show();
		self.BarMiddle:Show();
		self.BarRight:Show();
		self.ScrollBox:Show();
		self.Comment:ClearAllPoints();
		self.Comment:SetPoint("BOTTOM", 0, 19);
		self.Comment:SetHeight(47);
		self.Comment.EditBox.Instructions:SetText(DESCRIPTION_OF_YOUR_GROUP);
	end

	LFGListingActivityView_UpdateActivities(self, categoryID);
end

function LFGListingActivityView_UpdateActivities(self, categoryID)
	local activities = C_LFGList.GetAvailableActivities(categoryID);
	local dataProvider = CreateDataProvider();

	dataProvider:Insert({buttonType = LFGLISTING_BUTTONTYPE_CHECKALL});

	for i=1, #activities do
		local activityInfo = C_LFGList.GetActivityInfoTable(activities[i]);
		local name = activityInfo.shortName ~= "" and activityInfo.shortName or activityInfo.fullName;

		dataProvider:Insert({buttonType = LFGLISTING_BUTTONTYPE_ACTIVITY, activityID = activities[i], name = name, minLevel = activityInfo.minLevel, maxLevel = activityInfo.maxLevel});
	end

	local function SortComparator(lhs, rhs)
		if (lhs.buttonType ~= rhs.buttonType) then return lhs.buttonType < rhs.buttonType;
		elseif (lhs.maxLevel ~= rhs.maxLevel) then return lhs.maxLevel > rhs.maxLevel;
		elseif (lhs.minLevel ~= rhs.minLevel) then return lhs.minLevel > rhs.minLevel;
		else return strcmputf8i(lhs.name, rhs.name) < 0;
		end
	end
	dataProvider:SetSortComparator(SortComparator);

	self.ScrollBox:SetDataProvider(dataProvider);
end

function LFGListingActivityView_InitCheckAllButton(button, elementData)
	button.CheckButton:SetChecked(LFGListingFrame:AreAllActivitiesSelected());
end

function LFGListingActivityView_InitActivityButton(button, elementData)
	button.Name:SetText(elementData.name);
	if ( elementData.minLevel == elementData.maxLevel ) then
		if (elementData.minLevel == 0) then
			button.Level:SetText("");
		else
			button.Level:SetText(format(LFD_LEVEL_FORMAT_SINGLE, elementData.minLevel));
		end
	else
		button.Level:SetText(format(LFD_LEVEL_FORMAT_RANGE, elementData.minLevel, elementData.maxLevel));
	end
	button.CheckButton:SetChecked(LFGListingFrame:IsActivitySelected(elementData.activityID));
end

-------------------------------------------------------
----------Comment
-------------------------------------------------------
function LFGListingComment_OnTextChanged(self, userInput)
	if (userInput and (C_LFGList.HasActiveEntryInfo() or LFGListingFrame:IsAnyActivitySelected())) then
		LFGListingFrame:SetDirty(true);
	end
end

-------------------------------------------------------
----------Locked View
-------------------------------------------------------
function LFGListingLockedView_OnLoad(self)
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self.fontStringPool = CreateFontStringPool(self, "ARTWORK", 0, "LFGListingActivityNameTemplate")
	self.maxActivityLines = 11; -- Max number of names to show. If we have more than this, we'll show n-1 and the last line will be the overflow line.
	LFGListingLockedView_RefreshContent(self);
end

function LFGListingLockedView_OnEvent(self, event)
	if (event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then
		LFGListingLockedView_RefreshContent(self);
	end
end

function LFGListingLockedView_RefreshContent(self)
	self.fontStringPool:ReleaseAll();

	if (not C_LFGList.HasActiveEntryInfo()) then
		self.ErrorText:SetText(LFG_LIST_ONLY_LEADER_CREATE);
		self.ErrorText:ClearAllPoints();
		self.ErrorText:SetPoint("CENTER", 0, 25);
		self.ActivityText:Hide();
	else
		self.ErrorText:SetText(LFG_LIST_ONLY_LEADER_UPDATE);
		self.ErrorText:ClearAllPoints();
		self.ErrorText:SetPoint("TOPLEFT", 16, -20);
		self.ActivityText:Show();

		local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
		LFGUtil_SortActivityIDs(activeEntryInfo.activityIDs);
		local numActivities = #activeEntryInfo.activityIDs;
		local needOverflowText = numActivities > self.maxActivityLines;
		local lastFontString = nil;

		for i = 1, math.min(self.maxActivityLines, numActivities) do
			local fontString = self.fontStringPool:Acquire();
			local verticalSpacing = -3;

			if (i == self.maxActivityLines and needOverflowText) then
				fontString:SetText(string.format(LFG_LIST_AND_MORE, numActivities - (self.maxActivityLines - 1)));
				verticalSpacing = -6;
			else
				local activityID = activeEntryInfo.activityIDs[i];
				local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
				fontString:SetText(activityInfo.shortName ~= "" and activityInfo.shortName or activityInfo.fullName);
			end

			fontString:Show();
			if (lastFontString) then
				fontString:SetPoint("TOPLEFT", lastFontString, "BOTTOMLEFT", 0, verticalSpacing);
			else
				fontString:SetPoint("TOPLEFT", self.ActivityText, "BOTTOMLEFT", 12, -6)
			end
			lastFontString = fontString;
		end
	end
end

-------------------------------------------------------
----------Util
-------------------------------------------------------
function LFGListingUtil_CanEditListing()
	return not IsInGroup(LE_PARTY_CATEGORY_HOME) or UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME);
end