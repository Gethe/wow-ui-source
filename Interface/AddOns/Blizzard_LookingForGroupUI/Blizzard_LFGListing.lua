-------------------------------------------------------
----------Constants
-------------------------------------------------------
local LFGLISTING_CATEGORY_TEXTURES = {
	[2] = "ratedbgs", -- Dungeons
	--[117] = "dungeons", -- Heroic Dungeons
	[114] = "raids-wrath", -- Raids
	[116] = "questing", -- Quests & Zones
	[118] = "battlegrounds", -- PvP
	[120] = "custom-pve", -- Custom
};

local LFGLISTING_VIEWSTATE_CATEGORIES = 1;
local LFGLISTING_VIEWSTATE_ACTIVITIES = 2;
local LFGLISTING_VIEWSTATE_LOCKED = 3;

local LFGLISTING_BUTTONTYPE_ACTIVITYGROUP = 1;
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
	self:RegisterEvent("LFG_LIST_ROLE_UPDATE");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED");

	self.activities = {};
	self.categorySelection = nil;
	self.dirty = false;
	self.viewState = LFGLISTING_VIEWSTATE_ACTIVITIES;

	self:ClearUI();
	self:LoadSoloRolesOnStartup();
	self:UpdateFrameView();
end

function LFGListingMixin:OnEvent(event, ...)
	if ( event == "GROUP_LEFT" ) then
		local partyCategory, partyGUID = ...;
		if ( partyCategory == LE_PARTY_CATEGORY_HOME and not C_LFGList.HasActiveEntryInfo() ) then
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
			if ( createdNew or PENDING_LISTING_UPDATE ) then
				-- If this is either a brand new entry, or it was a manual update that we ourselves made, play a sound and swap to the browser.
				-- Notable case: if this is an update to an existing listing from our party leader, but we ourselves didn't do anything, don't deliver feedback.
				PlaySound(SOUNDKIT.PVP_ENTER_QUEUE);
				LFGParentFrame_SearchActiveEntry();
			end
		else
			if ( PENDING_LISTING_UPDATE ) then
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
	elseif ( event == "LFG_LIST_ROLE_UPDATE" ) then
		self:LoadSoloRoles();
	elseif ( event == "PLAYER_ROLES_ASSIGNED" ) then
		UIDropDownMenu_Initialize(self.GroupRoleButtons.RoleDropDown, LFGListingRoleDropDown_Initialize);
		LFGListingRoleIcon_UpdateRoleTexture(self.GroupRoleButtons.RoleIcon);
	end
end

function LFGListingMixin:OnShow()
	-- Baby hack... the selected tab texture doesn't blend well with the LFG texture, so move it down a hair when it's selected.
	LFGParentFrameTab1:SetPoint("BOTTOMLEFT", 16, 43);
	LFGParentFrameTab2:SetPoint("LEFT", LFGParentFrameTab1, "RIGHT", -14, 2);

	if (C_LFGList.HasActiveEntryInfo()) then
		self:LoadActiveEntry();
		self:LoadSoloRoles();
	else
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
	self:UpdateNewPlayerFriendlyButtonEnableState();
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
		self.NewPlayerFriendlyButton.CheckButton:SetChecked(activeEntryInfo.newPlayerFriendly);

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
	local newPlayerFriendlyEnabled = self.NewPlayerFriendlyButton.CheckButton:GetChecked();

	local saveSoloRoles = false;
	if (C_LFGList.HasActiveEntryInfo()) then
		if (hasSelectedActivity) then
			-- Update.
			PENDING_LISTING_UPDATE = true;
			C_LFGList.UpdateListing(selectedActivityIDs, newPlayerFriendlyEnabled);
			saveSoloRoles = true;
		else
			-- Delete.
			PENDING_LISTING_UPDATE = true;
			C_LFGList.RemoveListing();
		end
	else
		if (hasSelectedActivity) then
			-- Create.
			PENDING_LISTING_UPDATE = true;
			C_LFGList.CreateListing(selectedActivityIDs, newPlayerFriendlyEnabled);
			saveSoloRoles = true;
		end
	end

	if (saveSoloRoles) then
		self:SaveSoloRoles();
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

function LFGListingMixin:IsAnyActivityForActivityGroupSelected(activityGroupID)
	for activityID, selected in pairs(self.activities) do
		if (LFGUtil_GetActivityGroupForActivity(activityID) == activityGroupID) then
			if selected then
				return true;
			end
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

function LFGListingMixin:AreAllActivitiesForActivityGroupSelected(activityGroupID)
	for activityID, selected in pairs(self.activities) do
		if (LFGUtil_GetActivityGroupForActivity(activityID) == activityGroupID) then
			if not selected then
				return false;
			end
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

function LFGListingMixin:SetAllActivitiesForActivityGroup(activityGroupID, selected, userInput)
	for activityID, _ in pairs(self.activities) do
		if (LFGUtil_GetActivityGroupForActivity(activityID) == activityGroupID) then
			self:SetActivity(activityID, selected, false, userInput);
		end
	end
end

function LFGListingMixin:ToggleActivity(activityID, allowCreate, userInput)
	self:SetActivity(activityID, not self:IsActivitySelected(activityID), allowCreate, userInput);
end

-------------------------------------------------------
----------Button Control
-------------------------------------------------------
function LFGListingMixin:UpdatePostButtonEnableState()
	if (not LFGListingUtil_CanEditListing()) then
		if (C_LFGList.HasActiveEntryInfo()) then
			self.PostButton.errorText = LFG_LIST_ONLY_LEADER_UPDATE;
		else
			self.PostButton.errorText = LFG_LIST_ONLY_LEADER_CREATE;
		end
		self.PostButton:SetEnabled(false);
		return;
	end

	-- If our dirty flag is not set, disable the Post button.
	-- Alternatively, if we do not have an activeEntry, and also do not have any activities set, disable the Post button. (An initial listing needs at least one activity.)
	if (not self.dirty or (not C_LFGList.HasActiveEntryInfo() and not self:IsAnyActivitySelected())) then
		self.PostButton.errorText = nil;
		self.PostButton:SetEnabled(false);
		return;
	end

	if (not LFGListingActivityView_CanPostWithCurrentComment(self.ActivityView)) then
		self.PostButton.errorText = nil;
		self.PostButton:SetEnabled(false);
		return;
	end

	-- Check party size state.
	local hasSpaceForAtLeastOneActivity = false;
	local maxPlayerCountForActivities = 0;
	if (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
		local groupCount = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
		for activityID, selected in pairs(self.activities) do
			if (selected) then
				local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
				local maxPlayers = activityInfo.maxNumPlayers;
				if (maxPlayers > maxPlayerCountForActivities) then
					maxPlayerCountForActivities = maxPlayers;
				end
				if (maxPlayers == 0 or groupCount < maxPlayers) then
					hasSpaceForAtLeastOneActivity = true;
					break;
				end
			end
		end

		if (not hasSpaceForAtLeastOneActivity) then
			self.PostButton.errorText = string.format(LFG_LIST_TOO_MANY_FOR_ACTIVITY, maxPlayerCountForActivities);
			self.PostButton:SetEnabled(false);
			return;
		end
	end

	-- Success! Enable the button.
	self.PostButton.errorText = nil;
	self.PostButton:SetEnabled(true);
end

function LFGListingMixin:UpdateBackButtonEnableState()
	self.BackButton:SetEnabled(self.viewState == LFGLISTING_VIEWSTATE_ACTIVITIES);
end

function LFGListingMixin:UpdateNewPlayerFriendlyButtonEnableState()
	self.NewPlayerFriendlyButton.CheckButton:SetEnabled(LFGListingUtil_CanEditListing());
end

-------------------------------------------------------
----------Solo Role UI
-------------------------------------------------------
function LFGListingMixin:LoadSoloRolesOnStartup()
	local roles = C_LFGList.GetSavedRoles();
	self.SoloRoleButtons.Tank.CheckButton:SetChecked(roles.tank);
	self.SoloRoleButtons.Healer.CheckButton:SetChecked(roles.healer);
	self.SoloRoleButtons.DPS.CheckButton:SetChecked(roles.dps);

	self:SaveSoloRoles();
end

function LFGListingMixin:LoadSoloRoles()
	local roles = C_LFGList.GetRoles();
	self.SoloRoleButtons.Tank.CheckButton:SetChecked(roles.tank);
	self.SoloRoleButtons.Healer.CheckButton:SetChecked(roles.healer);
	self.SoloRoleButtons.DPS.CheckButton:SetChecked(roles.dps);
end

function LFGListingMixin:SaveSoloRoles()
	return C_LFGList.SetRoles({
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

	info.func = LFGListingRoleDropDownButton_OnClick;
	info.classicChecks = true;

	local buttons = {
		{ text = TANK, value = "TANK", },
		{ text = HEALER, value = "HEALER", },
		{ text = DAMAGER, value = "DAMAGER", },
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

function LFGListingRoleDropDownButton_OnClick(self)
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
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED");
	LFGListingRolePollButton_UpdateEnableState(self);
end

function LFGListingRolePollButton_OnEvent(self, event)
	if (event == "PARTY_LEADER_CHANGED") then
		LFGListingRolePollButton_UpdateEnableState(self);
	elseif (event == "PLAYER_ROLES_ASSIGNED") then
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
----------New Player Friendly Button
-------------------------------------------------------
function LFGListingNewPlayerFriendlyButtonCheckButton_OnShow(self)
	if (not C_LFGList.HasActiveEntryInfo()) then
		self:SetChecked(GetCVarBool("lfgNewPlayerFriendly"));
	end
end

function LFGListingNewPlayerFriendlyButtonCheckButton_OnClick(self, button)
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		SetCVar("lfgNewPlayerFriendly", "1");
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		SetCVar("lfgNewPlayerFriendly", "0");
	end
	LFGListingFrame:SetDirty(true);
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
		self.CategoryButtons[btnIndex]:SetPoint("TOP", self.CategoryButtons[btnIndex - 1], "BOTTOM", 0, -8);
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
	self.commentRequired = false;

	local view = CreateScrollBoxListTreeListView(0);

	view:SetElementFactory(function(factory, node)
		local elementData = node:GetData();

		if (elementData.buttonType == LFGLISTING_BUTTONTYPE_ACTIVITYGROUP) then
			local frame = factory("Frame", "LFGListingActivityRowTemplate");

			frame.CheckButton:SetScript("OnClick", function(button, buttonName, down)
				local node = button:GetParent():GetElementData();
				local parentFrame = view:FindFrame(node);
				local parentData = node:GetData();
				local activityGroupID = parentData.activityGroupID;
				local allSelected = LFGListingFrame:IsAnyActivityForActivityGroupSelected(activityGroupID);
				LFGListingFrame:SetAllActivitiesForActivityGroup(activityGroupID, not allSelected, true);

				LFGListingActivityView_InitActivityGroupButton(parentFrame, parentData, node:IsCollapsed());
				for index, child in ipairs(node.nodes) do
					local childFrame = view:FindFrame(child);
					if (childFrame) then
						LFGListingActivityView_InitActivityButton(childFrame, child:GetData());
					end
				end
			end)

			frame.ExpandOrCollapseButton:SetScript("OnClick", function(button, buttonName, down)
				local node = button:GetParent():GetElementData();
				node:ToggleCollapsed(true);
				LFGListingActivityView_InitActivityGroupButton(view:FindFrame(node), node:GetData(), node:IsCollapsed());
			end)

			LFGListingActivityView_InitActivityGroupButton(frame, elementData, node:IsCollapsed());

		elseif (elementData.buttonType == LFGLISTING_BUTTONTYPE_ACTIVITY) then
			local frame = factory("Frame", "LFGListingActivityRowTemplate");

			frame.CheckButton:SetScript("OnClick", function(button, buttonName, down)
				local node = button:GetParent():GetElementData();
				local activityID = node:GetData().activityID;
				LFGListingFrame:ToggleActivity(activityID, false, true);

				if (node.parent) then
					local parentFrame = view:FindFrame(node.parent);
					if (parentFrame) then
						LFGListingActivityView_InitActivityGroupButton(parentFrame, node.parent:GetData(), node.parent:IsCollapsed());
					end
				end
			end)

			LFGListingActivityView_InitActivityButton(frame, elementData);
		end
	end);

	view:SetPadding(4,4,4,4,0);
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
	local isAccountSecured = C_LFGList.IsPlayerAuthenticatedForLFG(categoryID);
	self.Comment.EditBox:ClearFocus();
	if (autoChooseActivity) then
		-- For auto-choose activity categories, we're going to check everything, so only show the comment.
		self.BarLeft:Hide();
		self.BarMiddle:Hide();
		self.BarRight:Hide();
		self.ScrollBox:Hide();
		self.commentRequired = true;
		self.Comment:ClearAllPoints();
		self.Comment:SetPoint("CENTER", 0, 20);
		self.Comment:SetHeight(110);
		self.Comment.EditBox.Instructions:SetText(isAccountSecured and DESCRIPTION_OF_YOUR_GROUP_MANDATORY or LFG_AUTHENTICATOR_DESCRIPTION_BOX);
		self.Comment.EditBox:SetEnabled(isAccountSecured);
		if (IN_SET_CATEGORY_SELECTION) then -- If this is being invoked because the user is choosing a category, auto-select the comment box.
			self.Comment.EditBox:SetFocus();
		end
	else
		self.BarLeft:Show();
		self.BarMiddle:Show();
		self.BarRight:Show();
		self.ScrollBox:Show();
		self.commentRequired = false;
		self.Comment:ClearAllPoints();
		self.Comment:SetPoint("BOTTOM", 0, 19);
		self.Comment:SetHeight(47);
		self.Comment.EditBox.Instructions:SetText(isAccountSecured and DESCRIPTION_OF_YOUR_GROUP or LFG_AUTHENTICATOR_DESCRIPTION_BOX);
		self.Comment.EditBox:SetEnabled(isAccountSecured);
	end

	LFGListingActivityView_UpdateActivities(self, categoryID);
end

function LFGListingActivityView_UpdateActivities(self, categoryID)
	local function ActivitySortComparator(lhsNode, rhsNode)
		local lhs = lhsNode:GetData();
		local rhs = rhsNode:GetData();

		if (lhs.orderIndex ~= rhs.orderIndex) then
			return lhs.orderIndex > rhs.orderIndex;
		elseif (lhs.maxLevel ~= rhs.maxLevel) then
			if (lhs.maxLevel == 0 or rhs.maxLevel == 0) then
				return lhs.maxLevel == 0;
			end
			return lhs.maxLevel > rhs.maxLevel;
		elseif (lhs.minLevel ~= rhs.minLevel) then
			return lhs.minLevel > rhs.minLevel;
		else
			return strcmputf8i(lhs.name, rhs.name) < 0;
		end
	end
	local function ActivityGroupSortComparator(lhsNode, rhsNode)
		local lhs = lhsNode:GetData();
		local rhs = rhsNode:GetData();

		if (lhs.buttonType ~= rhs.buttonType) then return lhs.buttonType > rhs.buttonType; -- If we have any free-floating activities, put them above any activity groups.
		elseif (lhs.orderIndex ~= rhs.orderIndex) then return lhs.orderIndex < rhs.orderIndex;
		elseif (lhs.buttonType == LFGLISTING_BUTTONTYPE_ACTIVITY) then return ActivitySortComparator(lhsNode, rhsNode);
		else return strcmputf8i(lhs.name, rhs.name) < 0;
		end
	end

	local dataProvider = CreateLinearizedTreeListDataProvider();

	-- Handle any activities without a group first.
	do
		local activities = C_LFGList.GetAvailableActivities(categoryID, 0);

		for _, activityID in ipairs(activities) do
			local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
			local name = activityInfo.shortName ~= "" and activityInfo.shortName or activityInfo.fullName;
			local maxLevel = activityInfo.maxLevel ~= 0 and activityInfo.maxLevel or activityInfo.maxLevelSuggestion;
			dataProvider:Insert({
				buttonType = LFGLISTING_BUTTONTYPE_ACTIVITY,
				activityID = activityID,
				name = name,
				minLevel = activityInfo.minLevel,
				maxLevel = maxLevel,
				orderIndex = activityInfo.orderIndex,
			});
		end
	end

	local playerLevel = UnitLevel("player");
	-- Now loop over groups and handle each of them.
	local activityGroups = C_LFGList.GetAvailableActivityGroups(categoryID);
	for _, activityGroupID in ipairs(activityGroups) do
		local activities = C_LFGList.GetAvailableActivities(categoryID, activityGroupID);
		if (#activities > 0) then
			local name, orderIndex = C_LFGList.GetActivityGroupInfo(activityGroupID);
			local groupTree = dataProvider:Insert({
				buttonType = LFGLISTING_BUTTONTYPE_ACTIVITYGROUP,
				activityGroupID = activityGroupID,
				name = name,
				orderIndex = orderIndex,
			});

			local hasSuggestedActivity = false;
			for _, activityID in ipairs(activities) do
				local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
				local name = activityInfo.shortName ~= "" and activityInfo.shortName or activityInfo.fullName;
				local maxLevel = activityInfo.maxLevel ~= 0 and activityInfo.maxLevel or activityInfo.maxLevelSuggestion;
				 
				groupTree:Insert({
					buttonType = LFGLISTING_BUTTONTYPE_ACTIVITY,
					activityID = activityID,
					name = name,
					minLevel = activityInfo.minLevel,
					maxLevel = maxLevel,
					orderIndex = activityInfo.orderIndex
				});

				if (playerLevel and not hasSuggestedActivity) then
					hasSuggestedActivity = activityInfo.maxLevelSuggestion >= playerLevel;
				end
			end
			if (playerLevel and not hasSuggestedActivity) then
				groupTree:SetCollapsed(true);
			end
			groupTree:SetSortComparator(ActivitySortComparator);
		end
	end

	dataProvider:SetSortComparator(ActivityGroupSortComparator);

	self.ScrollBox:SetDataProvider(dataProvider);
end

function LFGListingActivityView_InitActivityGroupButton(button, elementData, isCollapsed)
	-- Controls
	button.ExpandOrCollapseButton:Show();
	if (isCollapsed) then
		button.ExpandOrCollapseButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
	else
		button.ExpandOrCollapseButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
	end

	local allActivitiesSelected = LFGListingFrame:AreAllActivitiesForActivityGroupSelected(elementData.activityGroupID);
	local anyActivitySelected = LFGListingFrame:IsAnyActivityForActivityGroupSelected(elementData.activityGroupID);
	if (allActivitiesSelected) then
		button.CheckButton:SetChecked(true);
		button.CheckButton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
		button.CheckButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
	elseif (anyActivitySelected) then
		button.CheckButton:SetChecked(true);
		button.CheckButton:SetCheckedTexture("Interface\\Buttons\\UI-MultiCheck-Up");
		button.CheckButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-MultiCheck-Disabled");
	else
		button.CheckButton:SetChecked(false);
		button.CheckButton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
		button.CheckButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
	end

	-- Name
	button.NameButton.Name:SetWidth(0);
	button.NameButton.Name:SetText(elementData.name);
	button.NameButton.Name:SetFontObject(LFGActivityHeader);
	button.NameButton:SetWidth(button.NameButton.Name:GetWidth());

	-- Level
	button.Level:Hide();
end

function LFGListingActivityView_InitActivityButton(button, elementData)
	-- Controls
	button.ExpandOrCollapseButton:Hide();

	button.CheckButton:SetChecked(LFGListingFrame:IsActivitySelected(elementData.activityID));
	button.CheckButton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
	button.CheckButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");

	-- Name
	button.NameButton.Name:SetWidth(0);
	button.NameButton.Name:SetText(elementData.name);
	if (elementData.maxLevel ~= 0 and elementData.maxLevel < UnitLevel("player")) then
		button.NameButton.Name:SetFontObject(LFGActivityEntryTrivial);
		button.Level:SetFontObject(LFGActivityEntryTrivial);
	else
		button.NameButton.Name:SetFontObject(LFGActivityEntry);
		button.Level:SetFontObject(LFGActivityEntry);
	end
	button.NameButton:SetWidth(button.NameButton.Name:GetWidth());

	-- Level
	button.Level:Show();
	if ( elementData.minLevel == elementData.maxLevel or elementData.maxLevel == 0 ) then
		if (elementData.minLevel == 0) then
			button.Level:SetText("");
		else
			button.Level:SetText(format(LFD_LEVEL_FORMAT_SINGLE, elementData.minLevel));
		end
	else
		button.Level:SetText(format(LFD_LEVEL_FORMAT_RANGE, elementData.minLevel, elementData.maxLevel));
	end
end

function LFGListingActivityView_CanPostWithCurrentComment(self)
	if (self.commentRequired) then
		local commentText = LFGListingComment_GetComment(self.Comment);
		return commentText and commentText ~= "";
	end

	return true;
end

-------------------------------------------------------
----------Comment
-------------------------------------------------------
function LFGListingComment_OnTextChanged(self, userInput)
	if (userInput) then
		LFGListingFrame:SetDirty(true);
	end
end

function LFGListingComment_OnMouseDown(self, button)
	if (not self.EditBox:IsEnabled() and not C_LFGList.IsPlayerAuthenticatedForLFG(LFGListingFrame:GetCategorySelection())) then
		StaticPopup_Show("GROUP_FINDER_AUTHENTICATOR_POPUP");
	end
end

function LFGListingComment_GetComment(self)
	return self.EditBox:GetText();
end

-------------------------------------------------------
----------Locked View
-------------------------------------------------------
function LFGListingLockedView_OnLoad(self)
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self.framePool = CreateFramePool("Button", self, "LFGListingLockedViewActivityTemplate")
	self.maxActivityLines = 13; -- Max number of activity lines to show.
	LFGListingLockedView_RefreshContent(self);
end

function LFGListingLockedView_OnEvent(self, event)
	if (event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then
		LFGListingLockedView_RefreshContent(self);
	end
end

function LFGListingLockedView_RefreshContent(self)
	self.framePool:ReleaseAll();

	if (not C_LFGList.HasActiveEntryInfo()) then
		self.ErrorText:SetText(LFG_LIST_ONLY_LEADER_CREATE);
		self.ActivityText:Hide();
	else
		self.ErrorText:SetText(LFG_LIST_ONLY_LEADER_UPDATE);
		self.ActivityText:Show();

		local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
		local organizedActivities = LFGUtil_OrganizeActivitiesByActivityGroup(activeEntryInfo.activityIDs);
		local activityGroupIDs = GetKeysArray(organizedActivities);
		LFGUtil_SortActivityGroupIDs(activityGroupIDs);
		local numVerboseLines = 0; -- Predicted number of lines if we use verbose mode...
		for _, activityGroupID in ipairs(activityGroupIDs) do
			if (activityGroupID ~= 0) then
				numVerboseLines = numVerboseLines + 1;
			end
			numVerboseLines = numVerboseLines + #organizedActivities[activityGroupID];
		end
		local verboseMode = numVerboseLines <= self.maxActivityLines;

		local lastFrame = nil;
		for _, activityGroupID in ipairs(activityGroupIDs) do
			local activityIDs = organizedActivities[activityGroupID];
			if (activityGroupID == 0) then -- Free-floating activities (no group)
				for _, activityID in ipairs(activityIDs) do
					local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
					local frame = LFGListingLockedView_SafeAcquireFrame(self);
					if (not frame) then
						return;
					end

					LFGListingLockedView_SetLineContent(self, frame, activityInfo.fullName, nil);

					if (lastFrame) then
						frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -2);
					else
						frame:SetPoint("TOPLEFT", self.ActivityText, "BOTTOMLEFT", 12, -6)
					end
					lastFrame = frame;
				end
			else -- Grouped activities
				if (verboseMode) then
					do
						local activityGroupName = C_LFGList.GetActivityGroupInfo(activityGroupID);
						local frame = LFGListingLockedView_SafeAcquireFrame(self);
						if (not frame) then
							return;
						end

						local lineText = activityGroupName.." "..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("("..string.format(LFGBROWSE_ACTIVITY_COUNT, #activityIDs)..")");
						LFGListingLockedView_SetLineContent(self, frame, lineText, nil);

						if (lastFrame) then
							frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -2);
						else
							frame:SetPoint("TOPLEFT", self.ActivityText, "BOTTOMLEFT", 12, -6)
						end
						lastFrame = frame;
					end
					for _, activityID in ipairs(activityIDs) do
						local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
						local frame = LFGListingLockedView_SafeAcquireFrame(self);
						if (not frame) then
							return;
						end

						local lineText = string.format(LFG_LIST_INDENT, activityInfo.fullName);
						LFGListingLockedView_SetLineContent(self, frame, lineText, nil);

						if (lastFrame) then
							frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -2);
						else
							frame:SetPoint("TOPLEFT", self.ActivityText, "BOTTOMLEFT", 12, -6)
						end
						lastFrame = frame;
					end
				else
					local activityGroupName = C_LFGList.GetActivityGroupInfo(activityGroupID);
					local frame = LFGListingLockedView_SafeAcquireFrame(self);
					if (not frame) then
						return;
					end

					local lineText = activityGroupName.." "..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("("..string.format(LFGBROWSE_ACTIVITY_COUNT, #activityIDs)..")");
					local tooltip = activityGroupName;
					for _, activityID in ipairs(activityIDs) do
						local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
						tooltip = tooltip.."\n"..string.format(LFG_LIST_INDENT, activityInfo.fullName);
					end
					LFGListingLockedView_SetLineContent(self, frame, lineText, tooltip);

					if (lastFrame) then
						frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -2);
					else
						frame:SetPoint("TOPLEFT", self.ActivityText, "BOTTOMLEFT", 12, -6)
					end
					lastFrame = frame;
				end
			end
		end
	end
end

function LFGListingLockedView_SafeAcquireFrame(self)
	if (self.framePool:GetNumActive() >= self.maxActivityLines) then
		return nil;
	else
		return self.framePool:Acquire();
	end
end

function LFGListingLockedView_SetLineContent(self, frame, text, tooltip)
	frame.Text:SetSize(0, 0);
	frame.Text:SetText(text);
	frame.tooltip = tooltip;
	frame:SetSize(frame.Text:GetWidth(), frame.Text:GetHeight());
	frame:Show();
end

-------------------------------------------------------
----------Util
-------------------------------------------------------
function LFGListingUtil_CanEditListing()
	return not IsInGroup(LE_PARTY_CATEGORY_HOME) or UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME);
end
