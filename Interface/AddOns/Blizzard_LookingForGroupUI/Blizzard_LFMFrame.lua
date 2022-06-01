local LFMS_TO_DISPLAY = 16;

-------------------------------------------------------
----------LFMFrameMixin
-------------------------------------------------------
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
	LFGParentFrameBackground:SetPoint("TOPLEFT", -2, 0);
	self:RefreshDropdowns();
	self:RefreshResults();
	LFGParentFrameTitle:SetText(LFM_TITLE);

	-- Baby hack... the selected tab texture doesn't blend well with the LFG texture, so move it down a hair when it's selected.
	LFGParentFrameTab1:SetPoint("BOTTOMLEFT", 16, 45);
	LFGParentFrameTab2:SetPoint("LEFT", LFGParentFrameTab1, "RIGHT", -14, -2);
end

function LFMFrameMixin:RefreshResults(singleRefreshID)
	local numResults, resultIDs = C_LFGList.GetFilteredSearchResults();
	self.numResultsLoaded = numResults;
	local scrollOffset = FauxScrollFrame_GetOffset(LFMListScrollFrame);
	local showScrollBar = false;
	if ( numResults > LFMS_TO_DISPLAY ) then
		showScrollBar = true;
	end

	for i=1, LFMS_TO_DISPLAY, 1 do
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

function LFMFrameMixin:SearchActiveEntry()
	-- Note: Players can queue for activities in multiple categories, but the LFM UI only supports showing one category at a time.
	-- Thus, we'll use the first category we find and only search for activities in that first category.

	if (not self.TypeDropDown or not self.ActivityDropDown) then
		return;
	end

	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	local firstTypeID = 0;
	if (activeEntryInfo) then
		LFMFrameActivityDropDown_ValueReset(self.ActivityDropDown);
		for i=1, #activeEntryInfo.activityIDs do
			local activityID = activeEntryInfo.activityIDs[i];
			if (activityID ~= 0) then
				local _, _, typeID = C_LFGList.GetActivityInfo(activityID);
				if (firstTypeID == 0) then
					firstTypeID = typeID;
					UIDropDownMenu_Initialize(self.TypeDropDown, LFMFrameTypeDropDown_Initialize);
					UIDropDownMenu_SetSelectedValue(self.TypeDropDown, typeID);
				end
				if (typeID == firstTypeID) then
					LFMFrameActivityDropDown_ValueSetSelected(self.ActivityDropDown, activityID, true)
				end
			end
		end
	end

	SendLFMQuery();
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
	for i=1, LFMS_TO_DISPLAY, 1 do
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
	FauxScrollFrame_Update(LFMListScrollFrame, self.numResultsLoaded, LFMS_TO_DISPLAY, 16);
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

-- ////////////////////////////////////////////////// Type Dropdown \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
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
	LFMFrameActivityDropDown_ValueReset(self.owner.activityDropdown);
	UIDropDownMenu_ClearAll(self.owner.activityDropdown);
	UIDropDownMenu_Initialize(self.owner.activityDropdown, LFMFrameActivityDropDown_Initialize);
end
-- ////////////////////////////////////////////////// Type Dropdown \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-- ////////////////////////////////////////////////// Activity Dropdown \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function LFMFrameActivityDropDown_Initialize(self)
	local selectedType = 0;
	if (self.typeDropdown) then
		selectedType = UIDropDownMenu_GetSelectedValue(self.typeDropdown) or 0;
	end

	if ( selectedType > 0 ) then
		UIDropDownMenu_EnableDropDown(self);
		local activities = C_LFGList.GetAvailableActivities(selectedType);

		if (#activities > 0) then
			local metaButtonInfo = UIDropDownMenu_CreateInfo();
			metaButtonInfo.keepShownOnClick = true;
			metaButtonInfo.notCheckable = true;
			metaButtonInfo.leftPadding = 5;

			-- Check All button
			metaButtonInfo.text = CHECK_ALL;
			metaButtonInfo.func = function()
				LFMFrameActivityDropDown_ValueAll(self);
				UIDropDownMenu_Refresh(self, true);
				LFMFrameActivityDropDown_UpdateHeaderText(self);
				SendLFMQuery();
			end;
			UIDropDownMenu_AddButton(metaButtonInfo);

			-- Uncheck All button
			metaButtonInfo.text = UNCHECK_ALL;
			metaButtonInfo.func = function()
				LFMFrameActivityDropDown_ValueReset(self);
				UIDropDownMenu_Refresh(self, true);
				LFMFrameActivityDropDown_UpdateHeaderText(self);
				SendLFMQuery();
			end;
			UIDropDownMenu_AddButton(metaButtonInfo);
		end

		-- Individual Activity Buttons
		local buttonInfo = UIDropDownMenu_CreateInfo();
		buttonInfo.func = LFMActivityButton_OnClick;
		buttonInfo.owner = self;
		buttonInfo.keepShownOnClick = true;
		buttonInfo.classicChecks = true;

		for i=1, #activities do
			local name = C_LFGList.GetActivityInfo(activities[i]);

			buttonInfo.text = name;
			buttonInfo.value = activities[i];
			buttonInfo.checked = function(self)
				return LFMFrameActivityDropDown_ValueIsSelected(LFMFrameActivityDropDown, self.value);
			end;
			UIDropDownMenu_AddButton(buttonInfo);
		end
	else
		LFMFrameActivityDropDown_ValueReset(self);
		UIDropDownMenu_DisableDropDown(self);
		UIDropDownMenu_ClearAll(self);
	end

	LFMFrameActivityDropDown_UpdateHeaderText(self);
end

function LFMFrameActivityDropDown_ValueAll(self)
	local selectedType = 0;
	if (self.typeDropdown) then
		selectedType = UIDropDownMenu_GetSelectedValue(self.typeDropdown) or 0;
	end

	if ( selectedType > 0 ) then
		local activities = C_LFGList.GetAvailableActivities(selectedType);
		for i=1, #activities do
			LFMFrameActivityDropDown_ValueSetSelected(self, activities[i], true);
		end
	end
end

function LFMFrameActivityDropDown_ValueReset(self)
	wipe(self.selectedValues);
end

function LFMFrameActivityDropDown_ValueIsSelected(self, value)
	return tContains(self.selectedValues, value);
end

function LFMFrameActivityDropDown_ValueSetSelected(self, value, selected)
	if (selected) then
		if (not tContains(self.selectedValues, value)) then
			tinsert(self.selectedValues, value);
		end
	else
		tDeleteItem(self.selectedValues, value);
	end
	LFMFrameActivityDropDown_UpdateHeaderText(self);
end

function LFMFrameActivityDropDown_ValueToggleSelected(self, value)
	LFMFrameActivityDropDown_ValueSetSelected(self, value, not LFMFrameActivityDropDown_ValueIsSelected(self, value));
end

function LFMFrameActivityDropDown_UpdateHeaderText(self)
	if #self.selectedValues == 1 then
		local name = C_LFGList.GetActivityInfo(self.selectedValues[1]);
		UIDropDownMenu_SetText(self, name);
	else
		UIDropDownMenu_SetText(self, string.format(LFM_ACTIVITY_HEADER, #self.selectedValues));
	end
end

function LFMActivityButton_OnClick(self)
	LFMFrameActivityDropDown_ValueToggleSelected(self.owner, self.value);
	SendLFMQuery();
end
-- ////////////////////////////////////////////////// Activity Dropdown \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-- Refresh Button and Search
function LFMFrameSearchButton_OnClick(self, button)
	SendLFMQuery();
end

function SendLFMQuery()
	local categoryID = UIDropDownMenu_GetSelectedValue(LFMFrameTypeDropDown) or 0;
	local activityIDs = LFMFrameActivityDropDown.selectedValues;
	if (categoryID > 0) then
		C_LFGList.Search(categoryID, activityIDs);
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

-- QoL hackery: since the LFG Frame has a lot of wide dropdowns, we'll make the dropdowns behave like buttons.
function LFMDropDown_OnEnter(self)
	self.Button:LockHighlight();
end

function LFMDropDown_OnLeave(self)
	self.Button:UnlockHighlight();
end

function LFMDropDown_OnClick(self)
	ToggleDropDownMenu(nil, nil, self);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end