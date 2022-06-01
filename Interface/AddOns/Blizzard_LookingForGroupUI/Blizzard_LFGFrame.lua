-------------------------------------------------------
----------Constants
-------------------------------------------------------

--Hard-coded values. Should probably make these part of the DB, but it gets a little more complicated with the per-expansion textures
local LFG_LIST_CATEGORY_TEXTURES = {
	[2] = "ratedbgs", -- Dungeons
	[117] = "dungeons", -- Heroic Dungeons
	[114] = "raids-wrath", -- Raids
	[116] = "questing", -- Quests & Zones
	[118] = "battlegrounds", -- PvP
	[120] = "custom-pve", -- Custom
};

local LFG_VIEWSTATE_CATEGORIES = 1;
local LFG_VIEWSTATE_ACTIVITIES = 2;
local LFG_VIEWSTATE_LOCKED = 3;

local LFG_BUTTON_TYPE_CHECKALL = 1;
local LFG_BUTTON_TYPE_ACTIVITY = 2;

local IN_SET_CATEGORY_SELECTION = false; -- Baby hack. This bool will be true when we're in code triggered by LFGFrameMixin:SetCategorySelection. Useful for downstream effects.
local PENDING_LISTING_UPDATE = false; -- Will be true after the player fires off an update to their listing from the UI. Used to determine what feedback we should give.

-------------------------------------------------------
----------LFGFrameMixin
-------------------------------------------------------
LFGFrameMixin = {};

function LFGFrameMixin:OnLoad()
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
	self.viewState = LFG_VIEWSTATE_ACTIVITIES;

	self:ClearUI();
	self:UpdateLFGFrameView();
end

function LFGFrameMixin:OnEvent(event, ...)
	if ( event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LEADER_CHANGED" ) then
		self:UpdateLFGFrameView();
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
				LFGParentFrame_LFMSearchActiveEntry();
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
		UIDropDownMenu_Initialize(self.GroupRoleButtons.RoleDropDown, LFGFrameRoleDropDown_Initialize);
		LFGRoleIcon_UpdateRoleTexture(self.GroupRoleButtons.RoleIcon);
	end
end

function LFGFrameMixin:OnShow()
	LFGParentFrameBackground:SetTexture("Interface\\LFGFrame\\UI-LFG-FRAME");
	LFGParentFrameBackground:SetPoint("TOPLEFT", 0, 0);
	LFGParentFrameTitle:SetText(LFG_TITLE);

	-- Baby hack... the selected tab texture doesn't blend well with the LFG texture, so move it down a hair when it's selected.
	LFGParentFrameTab1:SetPoint("BOTTOMLEFT", 16, 43);
	LFGParentFrameTab2:SetPoint("LEFT", LFGParentFrameTab1, "RIGHT", -14, 2);

	self:LoadActiveEntry();

	if (not C_LFGList.HasActiveEntryInfo()) then
		self:SetDirty(self:IsAnyActivitySelected());
	end
	self:UpdatePostButtonEnableState();
	self:UpdateBackButtonEnableState();

	UIDropDownMenu_Initialize(self.GroupRoleButtons.RoleDropDown, LFGFrameRoleDropDown_Initialize);
	LFGRoleIcon_UpdateRoleTexture(self.GroupRoleButtons.RoleIcon);
end

function LFGFrameMixin:UpdateLFGFrameView()
	-- Content view.
	self.CategoryView:Hide();
	self.ActivityView:Hide();
	self.LockedView:Hide();
	if (not self:CanEditListing()) then
		self.viewState = LFG_VIEWSTATE_LOCKED;
		self.LockedView:Show();
	elseif (not self.categorySelection) then
		self.viewState = LFG_VIEWSTATE_CATEGORIES;
		self.CategoryView:Show();
	else
		self.viewState = LFG_VIEWSTATE_ACTIVITIES;
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

function LFGFrameMixin:ClearUI()
	self:ClearCategorySelection();
	C_LFGList.ClearCreationTextFields();
	self.ActivityView.Comment.EditBox:ClearFocus();
	self:SetDirty(false);
end

function LFGFrameMixin:SetDirty(state)
	self.dirty = state;
	self:UpdatePostButtonEnableState();
end

-------------------------------------------------------
----------Active Entry
-------------------------------------------------------
function LFGFrameMixin:LoadActiveEntry()
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();

	if (activeEntryInfo) then
		-- Set LFG settings
		local _, _, categoryID = C_LFGList.GetActivityInfo(activeEntryInfo.activityIDs[1]);
		self:SetCategorySelection(categoryID); -- This will call UpdateActivities.
		C_LFGList.CopyActiveEntryInfoToCreationFields();
		self:SetDirty(false);
	end
end

function LFGFrameMixin:CanEditListing()
	return not IsInGroup(LE_PARTY_CATEGORY_HOME) or UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME);
end

function LFGFrameMixin:CreateOrUpdateListing()
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

function LFGFrameMixin:RemoveListing()
	PENDING_LISTING_UPDATE = true;
	C_LFGList.RemoveListing();
end

-------------------------------------------------------
----------Category Selection
-------------------------------------------------------
function LFGFrameMixin:GetCategorySelection()
	return self.categorySelection;
end

function LFGFrameMixin:SetCategorySelection(categoryID)
	IN_SET_CATEGORY_SELECTION = true;
	self.categorySelection = categoryID;
	self:UpdateActivities();
	self:UpdateLFGFrameView();
	IN_SET_CATEGORY_SELECTION = false;
end

function LFGFrameMixin:ClearCategorySelection()
	self.categorySelection = nil;
	self:UpdateActivities();
	self:UpdateLFGFrameView();
end

-------------------------------------------------------
----------Activity Selection
-------------------------------------------------------
function LFGFrameMixin:UpdateActivities()
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

function LFGFrameMixin:ClearActivities()
	self.activities = {};
end

function LFGFrameMixin:IsActivitySelected(activityID)
	return self.activities[activityID];
end

function LFGFrameMixin:IsAnyActivitySelected()
	for activityID, selected in pairs(self.activities) do
		if selected then
			return true;
		end
	end
	return false;
end

function LFGFrameMixin:AreAllActivitiesSelected()
	for activityID, selected in pairs(self.activities) do
		if not selected then
			return false;
		end
	end
	return true;
end

function LFGFrameMixin:SetActivity(activityID, selected, allowCreate, userInput)
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

function LFGFrameMixin:SetAllActivities(selected, userInput)
	for activityID, _ in pairs(self.activities) do
		self:SetActivity(activityID, selected, false, userInput);
	end
end

function LFGFrameMixin:ToggleActivity(activityID, allowCreate, userInput)
	self:SetActivity(activityID, not self:IsActivitySelected(activityID), allowCreate, userInput);
end

-------------------------------------------------------
----------Button Control
-------------------------------------------------------
function LFGFrameMixin:UpdatePostButtonEnableState()
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
				local maxPlayers = select(9, C_LFGList.GetActivityInfo(activityID));
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

function LFGFrameMixin:UpdateBackButtonEnableState()
	self.BackButton:SetEnabled(self.viewState == LFG_VIEWSTATE_ACTIVITIES);
end

-------------------------------------------------------
----------Role UI
-------------------------------------------------------
function LFGFrameRoleDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	local currentRole = UnitGroupRolesAssigned("player");

	info.func = LFGRoleButton_OnClick;
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

function LFGRoleButton_OnClick(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value);
	UnitSetRole("player", self.value);
end

function LFGRoleIcon_UpdateRoleTexture(self)
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
function LFGFrameRolePollButton_OnLoad(self)
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	LFGFrameRolePollButton_UpdateEnableState(self);
end

function LFGFrameRolePollButton_OnEvent(self, event)
	if (event == "PARTY_LEADER_CHANGED") then
		LFGFrameRolePollButton_UpdateEnableState(self);
	end
end

function LFGFrameRolePollButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	InitiateRolePoll();
end

function LFGFrameRolePollButton_UpdateEnableState(self)
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	if (IsInGroup() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))) then
		self:Enable();
	else
		self:Disable();
	end
end

-------------------------------------------------------
----------Post Button
-------------------------------------------------------
function LFGFramePostButton_OnLoad(self)
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	LFGFramePostButton_UpdateText(self);
end

function LFGFramePostButton_OnEvent(self, event)
	if ( event == "GROUP_ROSTER_UPDATE" or event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		LFGFramePostButton_UpdateText(self);
	end
end

function LFGFramePostButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	LFGFrame:CreateOrUpdateListing();
end

function LFGFramePostButton_UpdateText(self)
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
function LFGFrameBackButton_OnLoad(self)
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	LFGFrameBackButton_UpdateText(self);
end

function LFGFrameBackButton_OnEvent(self, event)
	if ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		LFGFrameBackButton_UpdateText(self);
	end
end

function LFGFrameBackButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if (C_LFGList.HasActiveEntryInfo()) then
		LFGFrame:RemoveListing();
	else
		LFGFrame:ClearUI();
	end
end

function LFGFrameBackButton_UpdateText(self)
	if (C_LFGList.HasActiveEntryInfo()) then
		self:SetText(LFG_LIST_UNLIST);
	else
		self:SetText(BACK);
	end
end

-------------------------------------------------------
----------Category Selection
-------------------------------------------------------
function LFGCategorySelection_OnShow(self)
	LFGCategorySelection_UpdateCategoryButtons(self);
end

function LFGCategorySelection_UpdateCategoryButtons(self)
	local categories = C_LFGList.GetAvailableCategories();
	local nextBtn = 1;

	--Update category buttons
	for i=1, #categories do
		local categoryID = categories[i];
		local categoryInfo = C_LFGList.GetCategoryInfo(categoryID);

		nextBtn = LFGCategorySelection_AddButton(self, nextBtn, categoryID);
	end

	--Hide any extra buttons
	for i=nextBtn, #self.CategoryButtons do
		self.CategoryButtons[i]:Hide();
	end
end

function LFGCategorySelection_AddButton(self, btnIndex, categoryID)
	if ( #C_LFGList.GetAvailableActivities(categoryID, nil) == 0) then
		return btnIndex;
	end

	local categoryName = C_LFGList.GetCategoryInfo(categoryID);

	local button = self.CategoryButtons[btnIndex];
	if ( not button ) then
		self.CategoryButtons[btnIndex] = CreateFrame("BUTTON", nil, self, "LFGCategoryTemplate");
		self.CategoryButtons[btnIndex]:SetPoint("TOP", self.CategoryButtons[btnIndex - 1], "BOTTOM", 0, -4);
		button = self.CategoryButtons[btnIndex];
	end

	button:SetText(categoryName);
	button.categoryID = categoryID;

	local atlasName = "groupfinder-button-"..(LFG_LIST_CATEGORY_TEXTURES[categoryID] or "questing");
	button.Icon:SetAtlas(atlasName);

	button:Show();

	return btnIndex + 1;
end

function LFGCategorySelectionButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	LFGFrame:SetCategorySelection(self.categoryID);
end

-------------------------------------------------------
----------Activity Selection
-------------------------------------------------------
function LFGActivityView_OnLoad(self)
	local view = CreateScrollBoxListLinearView();

	view:SetElementFactory(function(factory, elementData)
		-- Check All button
		if (elementData.buttonType == LFG_BUTTON_TYPE_CHECKALL) then

			local frame = factory("Frame", "LFGActivityCheckAllTemplate");

			frame.CheckButton:SetScript("OnClick", function(button, buttonName, down)
				LFGFrame:SetAllActivities(not LFGFrame:AreAllActivitiesSelected(), true);

				view:ForEachFrame(function(frame, elementData)
					if (elementData.buttonType == LFG_BUTTON_TYPE_ACTIVITY) then
						LFGActivityView_InitActivityButton(frame, elementData);
					end
				end);
			end)

			LFGActivityView_InitCheckAllButton(frame, elementData);

		-- Individual Activity button
		elseif (elementData.buttonType == LFG_BUTTON_TYPE_ACTIVITY) then
			local frame = factory("Frame", "LFGActivityTemplate");

			frame.CheckButton:SetScript("OnClick", function(button, buttonName, down)
				local activityID = button:GetParent():GetElementData().activityID;
				LFGFrame:ToggleActivity(activityID, false, true);

				local checkAllButton = view:FindFrameByPredicate(function(frame) return frame:GetElementData().buttonType == LFG_BUTTON_TYPE_CHECKALL; end);
				if (checkAllButton) then
					LFGActivityView_InitCheckAllButton(checkAllButton, checkAllButton:GetElementData());
				end
			end)

			LFGActivityView_InitActivityButton(frame, elementData);
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

function LFGActivityView_OnShow(self)
	local categoryID = LFGFrame:GetCategorySelection();
	local _, _, autoChooseActivity = C_LFGList.GetCategoryInfo(categoryID);
	self.Comment.EditBox:ClearFocus();
	if (autoChooseActivity) then
		self.BarLeft:Hide();
		self.BarMiddle:Hide();
		self.BarRight:Hide();
		self.ScrollBox:Hide();
		self.Comment:ClearAllPoints();
		self.Comment:SetPoint("CENTER", 0, 20);
		self.Comment:SetHeight(110);
		self.Comment.EditBox.Instructions:SetText(DESCRIPTION_OF_YOUR_GROUP_MANDATORY);
		if (IN_SET_CATEGORY_SELECTION) then
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

	LFGActivityView_UpdateActivities(self, categoryID);
end

function LFGActivityView_UpdateActivities(self, categoryID)
	local activities = C_LFGList.GetAvailableActivities(categoryID);
	local dataProvider = CreateDataProvider();

	dataProvider:Insert({buttonType = LFG_BUTTON_TYPE_CHECKALL});

	for i=1, #activities do
		local longName, shortName, _, _, _, _, minLevel, maxLevel = C_LFGList.GetActivityInfo(activities[i]);
		local name = shortName ~= "" and shortName or longName;

		dataProvider:Insert({buttonType = LFG_BUTTON_TYPE_ACTIVITY, activityID = activities[i], name = name, minLevel = minLevel, maxLevel = maxLevel});
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

function LFGActivityView_InitCheckAllButton(button, elementData)
	button.CheckButton:SetChecked(LFGFrame:AreAllActivitiesSelected());
end

function LFGActivityView_InitActivityButton(button, elementData)
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
	button.CheckButton:SetChecked(LFGFrame:IsActivitySelected(elementData.activityID));
end

-------------------------------------------------------
----------Comment
-------------------------------------------------------
function LFGComment_OnTextChanged(self, userInput)
	if (userInput and (C_LFGList.HasActiveEntryInfo() or LFGFrame:IsAnyActivitySelected())) then
		LFGFrame:SetDirty(true);
	end
end

-------------------------------------------------------
----------Locked View
-------------------------------------------------------
function LFGLockedView_OnLoad(self)
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self.fontStringPool = CreateFontStringPool(self, "ARTWORK", 0, "LFGActivityNameTemplate")
	self.maxActivityLines = 11; -- Max number of names to show. If we have more than this, we'll show n-1 and the last line will be the overflow line.
	LFGLockedView_RefreshContent(self);
end

function LFGLockedView_OnEvent(self, event)
	if (event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then
		LFGLockedView_RefreshContent(self);
	end
end

function LFGLockedView_RefreshContent(self)
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
		local needOverflowText = #activeEntryInfo.activityIDs > self.maxActivityLines;
		local lastFontString = nil;
		for i = 1, math.min(self.maxActivityLines, #activeEntryInfo.activityIDs) do
			local fontString = self.fontStringPool:Acquire();
			local verticalSpacing = -3;

			if (i == self.maxActivityLines and needOverflowText) then
				fontString:SetText(string.format(LFG_LIST_AND_MORE, #activeEntryInfo.activityIDs - (self.maxActivityLines - 1)));
				verticalSpacing = -6;
			else
				local activityID = activeEntryInfo.activityIDs[i];
				local longName, shortName = C_LFGList.GetActivityInfo(activityID);
				fontString:SetText(shortName ~= "" and shortName or longName);
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
