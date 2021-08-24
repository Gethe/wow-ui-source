LFGS_TO_DISPLAY = 16;

----------------------------- LFG Parent Functions -----------------------------
LFGParentFrameMixin = {};

function LFGParentFrameMixin:OnLoad()
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	PanelTemplates_SetNumTabs(self, 2);
	LFGParentFrame.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
end

function LFGParentFrameMixin:OnEvent(event, ...)
	if (event == "PLAYER_LEVEL_UP") then
		C_LFGList.RequestAvailableActivities();
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if ( unit == "player" ) then
			SetPortraitTexture(LFGParentFrameIcon, unit);
		end
	end
end

function ToggleLFGParentFrame(tab)
	local hideLFGParent;
	if ( LFGParentFrame:IsShown() and tab == LFGParentFrame.selectedTab and LFGParentFrameTab1:IsShown() ) then
		hideLFGParent = 1;
	end
	if ( LFGParentFrame:IsShown() and not tab ) then
		hideLFGParent = 1;
	end

	if ( hideLFGParent ) then
		HideUIPanel(LFGParentFrame);
	else
		ShowUIPanel(LFGParentFrame);
		-- Decide which subframe to show
		local tabToShow = tab or LFGParentFrame.selectedTab;
		if (tabToShow == 2) then
			LFGParentFrameTab2_OnClick();
		else -- Default to tab 1.
			LFGParentFrameTab1_OnClick();
		end
	end
	UpdateMicroButtons();
end

function LFGParentFrameTab1_OnClick()
	PanelTemplates_SetTab(LFGParentFrame, 1);
	LFGFrame:Show();
	LFMFrame:Hide();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function LFGParentFrameTab2_OnClick()
	PanelTemplates_SetTab(LFGParentFrame, 2);
	LFGFrame:Hide();
	LFMFrame:Show();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

----------------------------- LFM Functions -----------------------------
LFMFrameMixin = {};

function LFMFrameMixin:OnLoad()
	-- Event for entire list
	self:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");

	self:ClearSelection();
	self.numResultsLoaded = 0;

	self.TypeDropDown.activityDropdown = self.ActivityDropDown;
	self.ActivityDropDown.typeDropdown = self.TypeDropDown;
	UIDropDownMenu_Initialize(self.TypeDropDown, LFMFrameTypeDropDown_Initialize);
	UIDropDownMenu_Initialize(self.ActivityDropDown, LFMFrameActivityDropDown_Initialize);
end

function LFMFrameMixin:OnEvent(event, ...)
	if ( event == "LFG_LIST_AVAILABILITY_UPDATE" ) then
		self:RefreshDropdowns();
	elseif ( event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" ) then
		self:RefreshResults();
	elseif ( event == "LFG_LIST_SEARCH_RESULT_UPDATED") then
		local resultID = ...;
		self:RefreshResults(resultID);
	end
end

function LFMFrameMixin:RefreshDropdowns()
	UIDropDownMenu_Initialize(self.TypeDropDown, LFMFrameTypeDropDown_Initialize);
	UIDropDownMenu_Initialize(self.ActivityDropDown, LFMFrameActivityDropDown_Initialize);
end

function LFMFrameMixin:OnShow()
	LFGParentFrameBackground:SetTexture("Interface\\LFGFrame\\LFMFrame");
	self:RefreshDropdowns();
	self:RefreshResults();
	LFGParentFrameTab1:Show();
	LFGParentFrameTab2:Show();
	LFGParentFrameTitle:SetText(LFM_TITLE);
end

function LFMFrameMixin:RefreshResults(singleRefreshID)
	local numResults, resultIDs = C_LFGList.GetFilteredSearchResults();
	self.numResultsLoaded = numResults;
	local scrollOffset = FauxScrollFrame_GetOffset(LFMListScrollFrame);
	local showScrollBar = false;
	if ( numResults > LFGS_TO_DISPLAY ) then
		showScrollBar = true;
	end

	for i=1, LFGS_TO_DISPLAY, 1 do
		local resultIndex = scrollOffset + i;
		local button = self.LFMFrameButton[i];
		
		if ( resultIndex <= numResults ) then
			local resultID = resultIDs[resultIndex];

			local doResultRefresh = true;
			if (singleRefreshID and singleRefreshID ~= resultID) then
				doResultRefresh = false;
			end

			if (doResultRefresh) then
				LFMButton_Reset(button);
				button.resultID = resultID;
				local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
				if ( searchResultInfo and searchResultInfo.numMembers > 0 and searchResultInfo.leaderName ) then
					-- Leader info.
					local name, classFileName, className, level, zone = C_LFGList.GetSearchResultLeaderInfo(resultID);
					local classTextColor = classFileName and RAID_CLASS_COLORS[classFileName] or NORMAL_FONT_COLOR;

					button.Name:SetText(searchResultInfo.leaderName);
					button.Level:SetText(level);
					button.Class:SetText(className);
					button.Zone:SetText(zone);
					
					button.isDelisted = searchResultInfo.isDelisted;
					if (button.isDelisted) then
						button.Name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
						button.Level:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
						button.Class:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
						button.Zone:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					else
						button.Name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
						button.Level:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
						button.Class:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
						button.Zone:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
					end

					-- Show the party leader icon if necessary
					local isGroup = searchResultInfo.numMembers > 1;
					if ( isGroup ) then
						button.PartyIcon:Show();
					else	
						button.PartyIcon:Hide();
					end

					-- Set info for the tooltip
					button.isLFM = isGroup;
					button.leaderName = LFM_NAME_TEMPLATE:format(name, level, className);
					button.activityIDs = searchResultInfo.activityIDs;
					button.comment = searchResultInfo.comment;
					button.partyMembers = searchResultInfo.numMembers;
				
					-- If need scrollbar resize columns
					if ( showScrollBar ) then
						button.Zone:SetWidth(102);
					else
						button.Zone:SetWidth(117);
					end

					button:Show();
				end
			end
		else
			LFMButton_Reset(button);
			button:Hide();
		end
	end

	-- Clear our selection unless it matches one of our buttons, and that button isn't delisted.
	local clearSelection = true;
	if (self.selectedLFM) then
		for i=1,#self.LFMFrameButton do
			local button = self.LFMFrameButton[i];
			if (button.resultID == self.selectedLFM) then
				if (not button.isDelisted) then
					clearSelection = false;
				end
				break;
			end
		end
	end
	if (clearSelection) then
		self:ClearSelection();
	end

	self:UpdateScrollBar();
end

function LFMFrameMixin:ClearSelection()
	self.selectedLFM = nil;
	self.selectedName = nil;
	self:UpdateSelection();
end

function LFMFrameMixin:SetSelection(selectedResultID)
	self.selectedLFM = selectedResultID;
	self:UpdateSelection();
end

function LFMFrameMixin:UpdateSelection()
	local selectionIsDelisted = false;
	for i=1, LFGS_TO_DISPLAY, 1 do
		-- Highlight the correct lfm
		local button = self.LFMFrameButton[i];
		if ( self.selectedLFM and self.selectedLFM == button.resultID ) then
			self.selectedName = button.Name:GetText();
			button:LockHighlight();
			selectionIsDelisted = button.isDelisted;
		else
			button:UnlockHighlight();
		end
	end

	-- Update send message and group invite buttons
	if ( self.selectedName and (self.selectedName ~= UnitName("player") and not selectionIsDelisted) ) then
		LFMFrameSendMessageButton:Enable();
		if ( CanGroupInvite() ) then
			LFMFrameGroupInviteButton:Enable();
		else
			LFMFrameGroupInviteButton:Disable();
		end
	else
		LFMFrameSendMessageButton:Disable();
		LFMFrameGroupInviteButton:Disable();
	end
end

function LFMFrameMixin:UpdateScrollBar()
	-- If need scrollbar resize columns
	if ( showScrollBar ) then
		WhoFrameColumn_SetWidth(LFMFrameColumnHeader2, 105);
	else
		WhoFrameColumn_SetWidth(LFMFrameColumnHeader2, 120);
	end

	-- ScrollFrame update
	FauxScrollFrame_Update(LFMListScrollFrame, self.numResultsLoaded, LFGS_TO_DISPLAY, 16);
end

function LFMButton_Reset(self)
	self.resultID = 0;
	self.isDelisted = false;
	self.isLFM = false;
	self.leaderName = "";
	self.activityIDs = {};
	self.comment = "";
	self.partyMembers = 0;
end

function LFMButton_OnClick(self, button)
	if (self.isDelisted) then
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if ( button == "LeftButton" ) then
		LFMFrame:SetSelection(self.resultID);
	elseif ( button == "RightButton" ) then
		EasyMenu(LFMFrame:GetSearchEntryMenu(self.resultID), LFMFrameEntryDropDown, "cursor", nil, nil, "MENU");
	end
end

function LFMButton_OnEnter(self)
	if (self.isDelisted) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 27, -37);
	if ( self.isLFM ) then
		GameTooltip_AddColoredLine(GameTooltip, LFM_TITLE, HIGHLIGHT_FONT_COLOR);
	else
		GameTooltip_AddColoredLine(GameTooltip, LFG_TITLE, HIGHLIGHT_FONT_COLOR);
	end
	
	GameTooltip_AddColoredLine(GameTooltip, self.leaderName, NORMAL_FONT_COLOR);
	local numPartyMembers = self.partyMembers;
	if ( numPartyMembers > 0 ) then
		if (self.isLFM) then
			GameTooltip:AddTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
		end
		-- Only show party members if there are 10 or less
		if ( numPartyMembers > 10 ) then
			GameTooltip:AddLine(format(LFM_NUM_RAID_MEMBER_TEMPLATE, numPartyMembers));
			-- Bogus texture to make the spacing correct
			GameTooltip:AddTexture("");
		else
			for i=1, numPartyMembers do
				local name, _, class, level, isLeader = C_LFGList.GetSearchResultMemberInfo(self.resultID, i);
				if ( name and not isLeader ) then -- Skip the leader since we added them above.
					GameTooltip_AddColoredLine(GameTooltip, format(LFM_NAME_TEMPLATE, name, level, class), NORMAL_FONT_COLOR);
					-- Bogus texture to make the spacing correct
					GameTooltip:AddTexture("");
				end
			end
		end
	end

	local activityString = "";
	for i=1, #self.activityIDs do
		local name = C_LFGList.GetActivityInfo(self.activityIDs[i]);
		if (name) then
			activityString = activityString .. "\n" .. name;
		end
	end
	GameTooltip_AddColoredLine(GameTooltip, activityString, HIGHLIGHT_FONT_COLOR);

	if ( self.comment and self.comment ~= "" ) then
		GameTooltip_AddColoredLine(GameTooltip, "\n"..self.comment, HIGHLIGHT_FONT_COLOR, 1);
	end

	GameTooltip:Show();
end

-- Type Dropdown stuff
function LFMFrameTypeDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	local categories = C_LFGList.GetAvailableCategories();
	if (#categories == 0) then
		-- None button
		info.text = LFG_TYPE_NONE;
		info.value = 0;
		info.func = LFMTypeButton_OnClick;
		info.owner = self;
		info.checked = UIDropDownMenu_GetSelectedValue(self) == info.value;
		info.classicChecks = true;
		UIDropDownMenu_AddButton(info);
	else
		local currentSelectedValue = UIDropDownMenu_GetSelectedValue(self) or 0;
		local defaultToFirstValue = currentSelectedValue <= 0;
		for i=1, #categories do
			local name = C_LFGList.GetCategoryInfo(categories[i]);

			info.text = name;
			info.value = categories[i];
			info.func = LFMTypeButton_OnClick;
			info.owner = self;
			info.checked = currentSelectedValue == info.value or (defaultToFirstValue and i == 1);
			info.classicChecks = true;
			UIDropDownMenu_AddButton(info);
			if (info.checked) then
				UIDropDownMenu_SetSelectedValue(self, info.value);
			end
		end
	end
end

function LFMTypeButton_OnClick(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value);
	UIDropDownMenu_ClearAll(self.owner.activityDropdown);
	UIDropDownMenu_Initialize(self.owner.activityDropdown, LFMFrameActivityDropDown_Initialize);
end

-- Entryname Dropdown stuff
function LFMFrameActivityDropDown_Initialize(self)
	local selectedType = 0;
	if (self.typeDropdown) then
		selectedType = UIDropDownMenu_GetSelectedValue(self.typeDropdown) or 0;
	end

	if ( selectedType > 0 ) then
		UIDropDownMenu_EnableDropDown(self);
		local currentSelectedValue = UIDropDownMenu_GetSelectedValue(self);
		local activities = C_LFGList.GetAvailableActivities(selectedType);
		for i=1, #activities do
			local name = C_LFGList.GetActivityInfo(activities[i]);

			info.text = name;
			info.value = activities[i];
			info.func = LFMActivityButton_OnClick;
			info.owner = self;
			info.checked = currentSelectedValue == info.value;
			info.classicChecks = true;
			UIDropDownMenu_AddButton(info);
		end
	else
		UIDropDownMenu_DisableDropDown(self);
		UIDropDownMenu_ClearAll(self);
	end
end

function LFMActivityButton_OnClick(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value);
	SendLFMQuery();
end

-- Refresh Button and Search
function LFMFrameSearchButton_OnClick(self, button)
	SendLFMQuery();
end

function SendLFMQuery()
	local categoryID = UIDropDownMenu_GetSelectedValue(LFMFrameTypeDropDown) or 0;
	local activityID = UIDropDownMenu_GetSelectedValue(LFMFrameActivityDropDown) or 0;
	if (categoryID > 0 and activityID > 0) then
		C_LFGList.Search(categoryID, activityID);
	end
end

local LFM_FRAME_SEARCH_ENTRY_MENU = {
	{
		text = nil,	--Leader name goes here
		isTitle = true,
		notCheckable = true,
	},
	{
		text = SEND_MESSAGE,
		func = function(_, name) ChatFrame_SendTell(name); end,
		notCheckable = true,
		arg1 = nil, --Leader name goes here
		disabled = nil, --Disabled if we don't have a leader name yet
		tooltipWhileDisabled = 1,
		tooltipOnButton = 1,
		tooltipTitle = nil, --The title to display on mouseover
		tooltipText = nil, --The text to display on mouseover
	},
	{
		text = GROUP_INVITE,
		func = function(_, name) InviteUnit(name); end,
		notCheckable = true,
		arg1 = nil, --Leader name goes here
		disabled = nil, --Disabled if we don't have a leader name yet
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
					LFMFrame:RefreshResults();
				end,
				arg1 = nil, --Search result ID goes here
				notCheckable = true,
			},
			{
				text = LFG_LIST_BAD_DESCRIPTION,
				func = function(_, id)
					C_LFGList.ReportSearchResult(id, "lfglistcomment");
					LFMFrame:RefreshResults();
				end,
				arg1 = nil, --Search reuslt ID goes here
				notCheckable = true,
				disabled = nil,	--Disabled if the description is just an empty string
			},
			{
				text = LFG_LIST_BAD_LEADER_NAME,
				func = function(_, id)
					C_LFGList.ReportSearchResult(id, "badplayername");
					LFMFrame:RefreshResults();
				end,
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

function LFMFrameMixin:GetSearchEntryMenu(resultID)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	LFM_FRAME_SEARCH_ENTRY_MENU[1].text = searchResultInfo.leaderName;
	LFM_FRAME_SEARCH_ENTRY_MENU[2].arg1 = searchResultInfo.leaderName;
	LFM_FRAME_SEARCH_ENTRY_MENU[2].disabled = not searchResultInfo.leaderName;
	LFM_FRAME_SEARCH_ENTRY_MENU[3].arg1 = searchResultInfo.leaderName;
	LFM_FRAME_SEARCH_ENTRY_MENU[3].disabled = not searchResultInfo.leaderName;
	LFM_FRAME_SEARCH_ENTRY_MENU[4].menuList[1].arg1 = resultID;
	LFM_FRAME_SEARCH_ENTRY_MENU[4].menuList[2].arg1 = resultID;
	LFM_FRAME_SEARCH_ENTRY_MENU[4].menuList[2].disabled = (searchResultInfo.comment == "");
	LFM_FRAME_SEARCH_ENTRY_MENU[4].menuList[3].arg1 = resultID;
	LFM_FRAME_SEARCH_ENTRY_MENU[4].menuList[3].disabled = not searchResultInfo.leaderName;
	return LFM_FRAME_SEARCH_ENTRY_MENU;
end

----------------------------- LFG Functions -----------------------------
LFGFrameMixin = {};

function LFGFrameMixin:OnLoad()
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE");
	self:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS");
	self:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TIMEOUT");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:SetDirty(false);
	self:DefaultDropDownSetup();
	self:PermissionUpdate();
end

function LFGFrameMixin:OnEvent(event, ...)
	if ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		local createdNew = ...;
		if ( createdNew ) then
			PlaySound(SOUNDKIT.PVP_ENTER_QUEUE);
		end
		self:LoadActiveEntry();
	elseif ( event == "LFG_LIST_AVAILABILITY_UPDATE" ) then
		self:DefaultDropDownSetup();
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LEADER_CHANGED" ) then
		self:PermissionUpdate();
		self:UpdatePostButtonState();
	elseif ( event == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS" ) then
		if ( UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
			StaticPopup_Show("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS");
		end
	elseif ( event == "LFG_LIST_ENTRY_EXPIRED_TIMEOUT" ) then
		if ( UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
			StaticPopup_Show("LFG_LIST_ENTRY_EXPIRED_TIMEOUT");
		end
	end
end

function LFGFrameMixin:OnShow()
	LFGParentFrameBackground:SetTexture("Interface\\LFGFrame\\LFGFrame");
	LFGParentFrameTab1:Show();
	LFGParentFrameTab2:Show();
	LFGParentFrameTitle:SetText(LFG_TITLE);
	self:LoadActiveEntry();
end

function LFGFrameMixin:CanEditListing()
	return not IsInGroup(LE_PARTY_CATEGORY_HOME) or UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME);
end

function LFGFrameMixin:PermissionUpdate()
	self.readOnly = not self:CanEditListing();

	if (self.readOnly) then
		for i=1, #self.TypeDropDown do
			LFGFrameTypeDropDown_UpdateDisableState(self.TypeDropDown[i]);
		end
		for i=1, #self.ActivityDropDown do
			LFGFrameActivityDropDown_UpdateDisableState(self.ActivityDropDown[i]);
		end
		self.Comment:Disable();
		self.Comment:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	else
		for i=1, #self.TypeDropDown do
			LFGFrameTypeDropDown_UpdateDisableState(self.TypeDropDown[i]);
		end
		for i=1, #self.ActivityDropDown do
			LFGFrameActivityDropDown_UpdateDisableState(self.ActivityDropDown[i]);
		end
		self.Comment:Enable();
		self.Comment:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
end

function LFGFrameMixin:SetDirty(state)
	self.dirty = state;
	self:UpdatePostButtonState();
end

function LFGFrameMixin:CheckActivitiesDirty()
	local activeActivityID1, activeActivityID2, activeActivityID3 = 0, 0, 0;

	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	if (activeEntryInfo) then
		activeActivityID1 = activeEntryInfo.activityIDs[1];
		activeActivityID2 = activeEntryInfo.activityIDs[2];
		activeActivityID3 = activeEntryInfo.activityIDs[3];
	end

	if (
		activeActivityID1 ~= (UIDropDownMenu_GetSelectedValue(_G["LFGFrameActivityDropDown1"]) or 0) or
		activeActivityID2 ~= (UIDropDownMenu_GetSelectedValue(_G["LFGFrameActivityDropDown2"]) or 0) or
		activeActivityID3 ~= (UIDropDownMenu_GetSelectedValue(_G["LFGFrameActivityDropDown3"]) or 0)
	) then
		self:SetDirty(true);
	end
end

function LFGFrameMixin:UpdatePostButtonState()
	-- Check dirty state.
	if (not self.dirty) then
		self.PostButton.errorText = nil;
		self.PostButton:SetEnabled(false);
		return;
	end

	-- Check party size state.
	if (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
		local groupCount = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
		for i=1, #self.ActivityDropDown do
			local activityID = UIDropDownMenu_GetSelectedValue(self.ActivityDropDown[i]) or 0;
			if (activityID ~= 0) then
				local maxPlayers = select(8, C_LFGList.GetActivityInfo(activityID));
				if (maxPlayers > 0 and groupCount >= maxPlayers) then
					self.PostButton.errorText = string.format(LFG_LIST_TOO_MANY_FOR_ACTIVITY, maxPlayers);
					self.PostButton:SetEnabled(false);
					return;
				end
			end
		end
	end

	-- If we passed our checks, enable the button.
	self.PostButton.errorText = nil;
	self.PostButton:SetEnabled(true);
end

function LFGFrameMixin:CreateOrUpdateListing()
	if (not self.dirty) then
		return;
	end

	local activityIDs = {};
	local hasNonZeroActivityID = false;
	for i=1, #self.ActivityDropDown do
		local activityID = UIDropDownMenu_GetSelectedValue(self.ActivityDropDown[i]) or 0;
		activityIDs[i] = activityID;
		if (activityID ~= 0) then
			hasNonZeroActivityID = true;
		end
	end

	local hasActiveEntry = C_LFGList.HasActiveEntryInfo();
	if (hasActiveEntry) then
		if (hasNonZeroActivityID) then
			-- Update.
			C_LFGList.UpdateListing(activityIDs);
		else
			-- Delete.
			C_LFGList.RemoveListing();
		end
	else
		if (hasNonZeroActivityID) then
			-- Create.
			C_LFGList.CreateListing(activityIDs);
		end
	end
end

function LFGFrameMixin:DefaultDropDownSetup()
	for i=1, #self.TypeDropDown do
		local typeDropDown = self.TypeDropDown[i];
		local activityDropDown = self.ActivityDropDown[i];
		typeDropDown.activityDropdown = activityDropDown;
		activityDropDown.typeDropdown = typeDropDown;

		UIDropDownMenu_ClearAll(typeDropDown);
		LFGFrameTypeDropDown_UpdateDisableState(typeDropDown);
		UIDropDownMenu_ClearAll(activityDropDown);
		LFGFrameActivityDropDown_UpdateDisableState(activityDropDown);
		self:UpdateActivityIcon(i);
	end
end

function LFGFrameMixin:LoadActiveEntry()
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();

	if (activeEntryInfo) then
		-- Set LFG settings
		for i=1, #activeEntryInfo.activityIDs do
			local typeDropDown = self.TypeDropDown[i];
			local activityDropDown = self.ActivityDropDown[i];
			local activityID = activeEntryInfo.activityIDs[i];

			if (activityID ~= 0) then
				local _, _, typeID = C_LFGList.GetActivityInfo(activityID);
				UIDropDownMenu_Initialize(typeDropDown, LFGFrameTypeDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(typeDropDown, typeID);

				UIDropDownMenu_Initialize(activityDropDown, LFGFrameActivityDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(activityDropDown, activityID);
			else
				UIDropDownMenu_ClearAll(typeDropDown);
				UIDropDownMenu_ClearAll(activityDropDown);
			end

			LFGFrameActivityDropDown_UpdateDisableState(activityDropDown);
			self:UpdateActivityIcon(i);
		end
		C_LFGList.CopyActiveEntryInfoToCreationFields();
		LFGEye:Show();
	else
		LFGFrame:ClearFields();
		C_LFGList.ClearCreationTextFields();
		LFGEye:Hide();
	end

	self:SetDirty(false);
end

function LFGFrameMixin:UpdateActivityIcon(i)
	local activityIcon = self.ActivityIcon[i];
	local categoryID = UIDropDownMenu_GetSelectedValue(self.TypeDropDown[i]);
	local activityID = UIDropDownMenu_GetSelectedValue(self.ActivityDropDown[i]);

	if (not activityID or activityID <= 0) then
		activityIcon:SetTexture("");
		return;
	end

	local activityFileDataID = activityID and select(14, C_LFGList.GetActivityInfo(activityID)) or nil;
	local categoryFileDataID = categoryID and select(5, C_LFGList.GetCategoryInfo(categoryID)) or nil;
	if (activityFileDataID and activityFileDataID > 0) then
		activityIcon:SetTexture(activityFileDataID);
	elseif (categoryFileDataID and categoryFileDataID > 0) then
		activityIcon:SetTexture(categoryFileDataID);
	else
		activityIcon:SetTexture("");
	end
end

function LFGFrameMixin:FindSlotWithActivity(desiredActivity)
	for i=1, #self.ActivityDropDown do
		local selectedActivity = UIDropDownMenu_GetSelectedValue(self.ActivityDropDown[i]) or 0;
		if (selectedActivity == desiredActivity) then
			return i;
		end
	end
	return 0;
end

function LFGFrameMixin:ClearFields()
	self:DefaultDropDownSetup();
	C_LFGList.ClearCreationTextFields();
	self.Comment:ClearFocus();
end

-- ////////////////////////////////////////////////// Type Dropdown \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function LFGFrameTypeDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();

	-- None button
	info.text = LFG_TYPE_NONE;
	info.value = 0;
	info.func = LFGTypeButton_OnClick;
	info.owner = self;
	info.checked = UIDropDownMenu_GetSelectedValue(self) == info.value;
	info.classicChecks = true;
	UIDropDownMenu_AddButton(info);

	local categories = C_LFGList.GetAvailableCategories();
	for i=1, #categories do
		local name = C_LFGList.GetCategoryInfo(categories[i]);

		info.text = name;
		info.value = categories[i];
		info.func = LFGTypeButton_OnClick;
		info.owner = self;
		info.checked = UIDropDownMenu_GetSelectedValue(self) == info.value;
		info.classicChecks = true;
		UIDropDownMenu_AddButton(info);
	end
end

function LFGFrameTypeDropDown_UpdateDisableState(self)
	if (LFGFrame.readOnly) then
		UIDropDownMenu_DisableDropDown(self);
	else
		UIDropDownMenu_EnableDropDown(self);
	end
end

function LFGTypeButton_OnClick(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value);
	UIDropDownMenu_ClearAll(self.owner.activityDropdown);
	UIDropDownMenu_Initialize(self.owner.activityDropdown, LFGFrameActivityDropDown_Initialize);
	LFGFrame:UpdateActivityIcon(self.owner:GetID());
	LFGFrame:CheckActivitiesDirty();
end
-- ////////////////////////////////////////////////// Type Dropdown \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-- ////////////////////////////////////////////////// Activity Dropdown \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function LFGFrameActivityDropDown_Initialize(self)
	local selectedType = 0;
	if (self.typeDropdown) then
		selectedType = UIDropDownMenu_GetSelectedValue(self.typeDropdown) or 0;
	end
	if ( selectedType > 0 ) then
		local activities = C_LFGList.GetAvailableActivities(selectedType);
		for i=1, #activities do
			-- Filter out activities that are already selected by a different dropdown.
			local activityAlreadySelected = false;
			local existingActivitySlot = LFGFrame:FindSlotWithActivity(activities[i]);
			if (existingActivitySlot > 0 and existingActivitySlot ~= self:GetID()) then
				activityAlreadySelected = true;
			end

			if (not activityAlreadySelected) then
				local name = C_LFGList.GetActivityInfo(activities[i]);

				info.text = name;
				info.value = activities[i];
				info.func = LFGActivityButton_OnClick;
				info.owner = self;
				info.checked = UIDropDownMenu_GetSelectedValue(self) == info.value;
				info.classicChecks = true;
				UIDropDownMenu_AddButton(info);
			end
		end
	else
		UIDropDownMenu_ClearAll(self);
	end

	LFGFrameActivityDropDown_UpdateDisableState(self);
end

function LFGFrameActivityDropDown_UpdateDisableState(self)
	local typeDropDownHasValue = self.typeDropdown and ((UIDropDownMenu_GetSelectedValue(self.typeDropdown) or 0) > 0);
	if (LFGFrame.readOnly or not typeDropDownHasValue) then
		UIDropDownMenu_DisableDropDown(self);
	else
		UIDropDownMenu_EnableDropDown(self);
	end
end

function LFGActivityButton_OnClick(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value);
	LFGFrame:UpdateActivityIcon(self.owner:GetID());
	LFGFrame:CheckActivitiesDirty();
end
-- ////////////////////////////////////////////////// Activity Dropdown \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

function LFGComment_OnTextChanged(self, userInput)
	if (userInput and C_LFGList.HasActiveEntryInfo()) then
		LFGFrame:SetDirty(true);
	end
end

function LFGFrameClearAllButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if (C_LFGList.HasActiveEntryInfo()) then
		C_LFGList.RemoveListing();
	else
		LFGFrame:ClearFields();
		LFGFrame:SetDirty(false);
	end
end

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

function LFGFramePostButton_UpdateText(self)
	if (C_LFGList.HasActiveEntryInfo()) then
		self:SetText(LFG_POST_GROUP_UPDATE);
	elseif (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
		self:SetText(LFG_POST_GROUP_PARTY);
	else
		self:SetText(LFG_POST_GROUP_SOLO);
	end
end

function LFGFramePostButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	LFGFrame:CreateOrUpdateListing();
end
