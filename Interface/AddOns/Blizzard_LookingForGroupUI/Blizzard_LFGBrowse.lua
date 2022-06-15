-------------------------------------------------------
----------Constants
-------------------------------------------------------
local LFGBROWSE_DELISTED_FONT_COLOR = {r=0.3, g=0.3, b=0.3};
local LFGBROWSE_GROUPDATA_ROLE_ORDER = { "TANK", "HEALER", "DAMAGER" };
local LFGBROWSE_GROUPDATA_CLASS_ORDER = CLASS_SORT_ORDER;
local LFGBROWSE_GROUPDATA_ATLASES = {
	--Roles
	TANK = "groupfinder-icon-role-large-tank",
	HEALER = "groupfinder-icon-role-large-heal",
	DAMAGER = "groupfinder-icon-role-large-dps",
};
--Fill out classes
for i=1, #CLASS_SORT_ORDER do
	LFGBROWSE_GROUPDATA_ATLASES[CLASS_SORT_ORDER[i]] = "groupfinder-icon-class-"..string.lower(CLASS_SORT_ORDER[i]);
end

-------------------------------------------------------
----------LFGBrowseMixin
-------------------------------------------------------
LFGBrowseMixin = {};

function LFGBrowseMixin:OnLoad()
	-- Event for entire list
	self:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE");
	self:RegisterEvent("LFG_LIST_SEARCH_FAILED");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");

	self.results = {};
	self.searchFailed = false;
	self.searching = false;
	self.totalResults = 0;

	UIDropDownMenu_Initialize(self.CategoryDropDown, LFGBrowseCategoryDropDown_Initialize);
	UIDropDownMenu_Initialize(self.ActivityDropDown, LFGBrowseActivityDropDown_Initialize);

	local view = CreateScrollBoxListLinearView();
	view:SetElementFactory(function(factory, elementData)
		local frame = factory("Button", "LFGBrowseSearchEntryTemplate");
		LFGBrowseSearchEntry_Init(frame, elementData);
	end);
	view:SetElementExtent(36);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", 22, -128),
		CreateAnchor("BOTTOMRIGHT", -66, 102);
	};
	local scrollBoxAnchorsWithoutBar = {
		scrollBoxAnchorsWithBar[1],
		CreateAnchor("BOTTOMRIGHT", -38, 102);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);

	local function OnSelectionChanged(o, elementData, selected)
		local frame = self.ScrollBox:FindFrame(elementData);
		if frame then
			LFGBrowseSearchEntry_SetSelection(frame, selected);
		end
		self:UpdateButtonState();
	end;

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox, SelectionBehaviorPolicy.Deselectable);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);

	self:UpdateButtonState();
	if (C_LFGList.HasActiveEntryInfo()) then
		LFGParentFrame_SearchActiveEntry();
	end
end

function LFGBrowseMixin:OnEvent(event, ...)
	if ( event == "LFG_LIST_AVAILABILITY_UPDATE" ) then
		self:RefreshDropDowns();
	elseif ( event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" ) then
		self.searching = false;
		self.searchFailed = false;
		self:UpdateResultList();
	elseif ( event == "LFG_LIST_SEARCH_FAILED" ) then
		self.searching = false;
		self.searchFailed = true;
		self:UpdateResultList();
	end
end

function LFGBrowseMixin:OnShow()
	self:RefreshDropDowns();
	self:UpdateResultList();

	-- Baby hack... the selected tab texture doesn't blend well with the LFG texture, so move it down a hair when it's selected.
	LFGParentFrameTab1:SetPoint("BOTTOMLEFT", 16, 45);
	LFGParentFrameTab2:SetPoint("LEFT", LFGParentFrameTab1, "RIGHT", -14, -2);
end

function LFGBrowseMixin:UpdateResultList()
	self.totalResults, self.results = C_LFGList.GetFilteredSearchResults();
	LFGBrowseUtil_SortSearchResults(self.results);
	self:UpdateResults();
end

function LFGBrowseMixin:UpdateResults()
	if ( self.searching ) then
		self.SearchingSpinner:Show();
		self.ScrollBox:ClearDataProvider();
	else
		self.SearchingSpinner:Hide();
		
		if(self.totalResults == 0 or self.searchFailed) then
			self.NoResultsFound:Show();
			self.NoResultsFound:SetText(self.searchFailed and LFG_LIST_SEARCH_FAILED or LFG_LIST_NO_RESULTS_FOUND);
		else
			self.NoResultsFound:Hide();
			
			local dataProvider = CreateDataProvider();
			local results = self.results;
			for index = 1, #results do
				dataProvider:Insert({resultID=results[index]});
			end

			self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
		end
	end
	self:UpdateButtonState();
end

function LFGBrowseMixin:SearchActiveEntry()
	if (not self.CategoryDropDown or not self.ActivityDropDown) then
		return;
	end

	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	local firstCategoryID = 0;
	if (activeEntryInfo) then
		LFGBrowseActivityDropDown_ValueReset(self.ActivityDropDown);
		for i=1, #activeEntryInfo.activityIDs do
			local activityID = activeEntryInfo.activityIDs[i];
			if (activityID ~= 0) then
				local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
				local categoryID = activityInfo.categoryID;
				if (firstCategoryID == 0) then
					firstCategoryID = categoryID;
					UIDropDownMenu_Initialize(self.CategoryDropDown, LFGBrowseCategoryDropDown_Initialize);
					UIDropDownMenu_SetSelectedValue(self.CategoryDropDown, categoryID);
				end
				if (categoryID == firstCategoryID) then
					LFGBrowseActivityDropDown_ValueSetSelected(self.ActivityDropDown, activityID, true)
				end
			end
		end
	end

	LFGBrowse_DoSearch();
end

function LFGBrowseMixin:RefreshDropDowns()
	UIDropDownMenu_Initialize(self.CategoryDropDown, LFGBrowseCategoryDropDown_Initialize);
	UIDropDownMenu_Initialize(self.ActivityDropDown, LFGBrowseActivityDropDown_Initialize);
end

function LFGBrowseMixin:UpdateButtonState()
	local selectedResultID = self.selectionBehavior:HasSelection() and LFGBrowseFrame.selectionBehavior:GetSelectedElementData()[1].resultID or nil;
	local inviteText, inviteFunc = LFGBrowseUtil_GetInviteActionForResult(selectedResultID)

	self.GroupInviteButton:SetText(inviteText);
	self.GroupInviteButton.inviteFunc = inviteFunc;

	if (self.selectionBehavior:HasSelection()) then
		self.SendMessageButton:Enable();
		self.GroupInviteButton:Enable();
	else
		self.SendMessageButton:Disable();
		self.GroupInviteButton:Disable();
	end

	if (self.searching) then
		self.RefreshButton:Disable();
	else
		self.RefreshButton:Enable();
	end
end

-------------------------------------------------------
----------Searching
-------------------------------------------------------
function LFGBrowseSearchButton_OnClick(self, button)
	LFGBrowse_DoSearch();
end

function LFGBrowse_DoSearch()
	if (not LFGBrowseFrame.searching) then
		local categoryID = UIDropDownMenu_GetSelectedValue(LFGBrowseFrame.CategoryDropDown) or 0;
		local activityIDs = LFGBrowseFrame.ActivityDropDown.selectedValues;
		if (categoryID > 0) then
			C_LFGList.Search(categoryID, activityIDs);
			LFGBrowseFrame.searching = true;
			LFGBrowseFrame.searchFailed = false;
			LFGBrowseFrame:UpdateResults();
		end
	end
end

-------------------------------------------------------
----------Search Entry
-------------------------------------------------------
function LFGBrowseSearchEntry_Init(self, elementData)
	self.resultID = elementData.resultID;
	self.isDelisted = false;
	LFGBrowseSearchEntry_Update(self);
end

function LFGBrowseSearchEntry_Update(self)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(self.resultID);
	local isSolo = searchResultInfo.numMembers == 1;
	if (isSolo) then
		self.PartyIcon:Hide();
		self.ClassIcon:Show();
		self.Level:Show();

		local classFile, _, _, level = select(2, C_LFGList.GetSearchResultMemberInfo(self.resultID, 1));
		if (classFile and level) then
			self.Level:SetText(LEVEL_ABBR .. " " ..level);
			self.ClassIcon:SetAtlas(LFGBROWSE_GROUPDATA_ATLASES[classFile], false);
		else
			self.Level:Hide();
			self.ClassIcon:Hide();
		end
	else
		self.PartyIcon:Show();
		self.ClassIcon:Hide();
		self.Level:Hide();
		self.ClassIcon:Hide();
	end

	local activityText = "";
	if (#searchResultInfo.activityIDs == 1) then
		local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1]);
		activityText = activityInfo.shortName ~= "" and activityInfo.shortName or activityInfo.fullName;
	else
		activityText = string.format(LFGBROWSE_ACTIVITY_COUNT, #searchResultInfo.activityIDs)
	end

	if (LFGBrowseFrame.selectionBehavior.IsElementDataSelected(self:GetElementData()) and searchResultInfo.isDelisted) then
		LFGBrowseFrame.selectionBehavior:ToggleSelect(self); -- Toggle off.
	else
		LFGBrowseSearchEntry_SetSelection(self, LFGBrowseFrame.selectionBehavior.IsElementDataSelected(self:GetElementData()));
	end

	local nameColor = NORMAL_FONT_COLOR;
	local levelColor = GRAY_FONT_COLOR;
	local activityColor = GRAY_FONT_COLOR;
	if ( searchResultInfo.isDelisted ) then
		self.isDelisted = true;
		nameColor = LFGBROWSE_DELISTED_FONT_COLOR;
		levelColor = LFGBROWSE_DELISTED_FONT_COLOR;
		activityColor = LFGBROWSE_DELISTED_FONT_COLOR;
	else
		self.isDelisted = false;
	end
	self.Name:SetWidth(0);
	self.Name:SetText(searchResultInfo.leaderName);
	self.Name:SetTextColor(nameColor.r, nameColor.g, nameColor.b);
	if ( self.Name:GetWidth() > 176 ) then
		self.Name:SetWidth(176);
	end
	self.Level:SetTextColor(levelColor.r, levelColor.g, levelColor.b);
	self.ActivityName:SetText(activityText);
	self.ActivityName:SetTextColor(activityColor.r, activityColor.g, activityColor.b);
	self.ActivityName:SetWidth(176);

	local displayData = C_LFGList.GetSearchResultMemberCounts(self.resultID);
	LFGBrowseGroupDataDisplay_Update(self.DataDisplay, searchResultInfo.activityIDs[1], displayData, searchResultInfo.isDelisted, isSolo, searchResultInfo.comment);

	local mouseFocus = GetMouseFocus();
	if ( mouseFocus == self ) then
		LFGBrowseSearchEntry_OnEnter(self);
	end
end

function LFGBrowseSearchEntry_OnLoad(self)
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function LFGBrowseSearchEntry_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_SEARCH_RESULT_UPDATED" ) then
		local id = ...;
		if ( id == self.resultID ) then
			LFGBrowseSearchEntry_Update(self);
		end
	end
end

function LFGBrowseSearchEntry_OnClick(self, button)
	if (self.isDelisted) then
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if ( button == "LeftButton" ) then
		LFGBrowseFrame.selectionBehavior:ToggleSelect(self);
	elseif ( button == "RightButton" ) then
		EasyMenu(LFGBrowseFrame:GetSearchEntryMenu(self.resultID), LFGBrowseFrame.SearchEntryDropDown, "cursor", nil, nil, "MENU");
	end
end

function LFGBrowseSearchEntry_OnEnter(self)
	LFGBrowseSearchEntryTooltip_UpdateAndShow(LFGBrowseSearchEntryTooltip, self.resultID)
	LFGBrowseSearchEntryTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 8, 38);

	if not self.Selected:IsShown() then
		self.Highlight:Show();
	end
end

function LFGBrowseSearchEntry_OnLeave(self)
	LFGBrowseSearchEntryTooltip:Hide();
	self.Highlight:Hide();
end

function LFGBrowseSearchEntry_SetSelection(self, selected)
	self.Selected:SetShown(selected);
	if (selected) then
		self.Highlight:Hide();
	elseif (MouseIsOver(self)) then
		self.Highlight:Show();
	end
end

-------------------------------------------------------
----------Search Entry Tooltip
-------------------------------------------------------
function LFGBrowseSearchEntryTooltip_Load(self)
	self.memberPool = CreateFramePool("FRAME", self, "LFGBrowseSearchEntryTooltipGroupMember");
	self.activityPool = CreateFontStringPool(self, "ARTWORK", 0, "LFGBrowseSearchEntryTooltipActivityNameTemplate")
end

function LFGBrowseSearchEntryTooltip_UpdateAndShow(self, resultID)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	local numMembers = searchResultInfo.numMembers;
	local memberCounts = C_LFGList.GetSearchResultMemberCounts(resultID);

	-- Delisted Alert
	if (searchResultInfo.isDelisted) then
		self.Delisted:Show();
		self.LeaderIcon:SetPoint("TOPLEFT", self.Delisted, "BOTTOMLEFT", 0, -8);
	else
		self.Delisted:Hide();
		self.LeaderIcon:SetPoint("TOPLEFT", 11, -10);
	end

	-- Leader
	local lastMemberFrame = self.Leader;
	local maxNameWidth = 0;
	if (numMembers > 1) then
		self.LeaderIcon:Show();
		self.Leader:SetPoint("TOPLEFT", self.LeaderIcon, "TOPRIGHT", 0, -2)
	else
		self.LeaderIcon:Hide();
		self.Leader:SetPoint("TOPLEFT", self.LeaderIcon, "TOPLEFT", 0, -2)
	end
	local name, classFileName, className, role, level, areaName = C_LFGList.GetSearchResultLeaderInfo(resultID);
	if (name) then
		local classColor = RAID_CLASS_COLORS[classFileName];
		self.Leader.Name:SetWidth(0); -- Reset the width so that we auto-expand to the text size correctly.
		self.Leader.Name:SetText(name);
		self.Leader.Name:SetTextColor(classColor.r, classColor.g, classColor.b)
		self.Leader.Level:SetText(LEVEL_ABBR .. " " .. level);
		self.Leader.Role:SetAtlas(LFGBROWSE_GROUPDATA_ATLASES[role], false);
		self.Leader:Show();

		maxNameWidth = math.max(maxNameWidth, self.Leader.Name:GetWidth());
	else
		self.Leader:Hide();
		self.LeaderIcon:Hide();
	end

	-- Members
	self.memberPool:ReleaseAll();
	if (numMembers <= 10) then
		for i=1, numMembers do
			local name, classFileName, className, role, level, isLeader = C_LFGList.GetSearchResultMemberInfo(resultID, i);
			if (name and not isLeader) then -- Leader handled above.
				local frame = self.memberPool:Acquire();
				local classColor = RAID_CLASS_COLORS[classFileName];
				frame.Name:SetWidth(0); -- Reset the width so that we auto-expand to the text size correctly.
				frame.Name:SetText(name);
				frame.Name:SetTextColor(classColor.r, classColor.g, classColor.b)
				frame.Level:SetText(LEVEL_ABBR .. " " .. level);
				frame.Role:SetAtlas(LFGBROWSE_GROUPDATA_ATLASES[role], false);

				frame:SetPoint("TOPLEFT", lastMemberFrame, "BOTTOMLEFT", 0, 0);
				lastMemberFrame = frame;
				frame:Show();

				maxNameWidth = math.max(maxNameWidth, frame.Name:GetWidth());
			end
		end
	end

	-- Standardize name width to whatever our max is.
	if (maxNameWidth > 0) then
		self.Leader.Name:SetWidth(maxNameWidth);
		for frame in self.memberPool:EnumerateActive() do
			frame.Name:SetWidth(maxNameWidth);
		end
	end

	-- Comment
	self.Comment:SetPoint("TOP", lastMemberFrame, "BOTTOM", 0, -8);
	if ( searchResultInfo.comment ~= "" ) then
		self.Comment:SetText(string.format(LFG_LIST_COMMENT_FORMAT, searchResultInfo.comment));
		self.Comment:Show();
		self.MemberCount:SetPoint("TOPLEFT", self.Comment, "BOTTOMLEFT", 0, -8);
	else
		self.Comment:Hide();
		self.MemberCount:SetPoint("TOPLEFT", self.Comment, "TOPLEFT", 0, 0);
	end

	-- Member Count
	self.MemberCount:SetText(string.format(LFG_LIST_TOOLTIP_MEMBERS, numMembers, memberCounts.TANK, memberCounts.HEALER, memberCounts.DAMAGER));

	-- Activities
	local lastActivityString = nil
	self.activityPool:ReleaseAll();
	LFGUtil_SortActivityIDs(searchResultInfo.activityIDs);
	for i=1, #searchResultInfo.activityIDs do
		local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[i]);
		if (activityInfo) then
			local fontString = self.activityPool:Acquire();
			fontString:SetText(activityInfo.shortName);

			if (lastActivityString) then
				fontString:SetPoint("TOPLEFT", lastActivityString, "BOTTOMLEFT", 0, 0);
			else
				fontString:SetPoint("TOPLEFT", self.MemberCount, "BOTTOMLEFT", 0, -8);
			end

			lastActivityString = fontString;
			fontString:Show();
		end
	end

	-- Show
	self:Show();

	-- Height calculation
	local contentHeight = 40;
	if ( self.Delisted:IsShown() ) then
		contentHeight = contentHeight + self.Delisted:GetHeight();
		contentHeight = contentHeight + 8;
	end
	contentHeight = contentHeight + self.Leader:GetHeight();
	for frame in self.memberPool:EnumerateActive() do
		contentHeight = contentHeight + frame:GetHeight();
	end
	if ( self.Comment:IsShown() ) then
		contentHeight = contentHeight + self.Comment:GetHeight();
		contentHeight = contentHeight + 8;
	end
	contentHeight = contentHeight + self.MemberCount:GetHeight();
	for fontString in self.activityPool:EnumerateActive() do
		contentHeight = contentHeight + fontString:GetHeight();
	end
	self:SetHeight(contentHeight);
end

-------------------------------------------------------
----------Group Data Display
-------------------------------------------------------
function LFGBrowseGroupDataDisplay_Update(self, activityID, displayData, disabled, isSolo, comment)
	local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
	if(not activityInfo) then 
		return;
	end

	self.Solo:Hide();
	self.RoleCount:Hide();
	self.Enumerate:Hide();
	self.PlayerCount:Hide();
	self.Comment:Hide();
	
	if ( activityInfo.displayType == Enum.LFGListDisplayType.Comment ) then
		self.Comment:Show();
		LFGBrowseGroupDataDisplayComment_Update(self.Comment, comment, disabled);
	elseif ( isSolo ) then
		self.Solo:Show();
		LFGBrowseGroupDataDisplaySolo_Update(self.Solo, displayData);
	elseif ( activityInfo.displayType == Enum.LFGListDisplayType.RoleCount ) then
		self.RoleCount:Show();
		LFGBrowseGroupDataDisplayRoleCount_Update(self.RoleCount, displayData, disabled);
	elseif ( activityInfo.displayType == Enum.LFGListDisplayType.RoleEnumerate ) then
		self.Enumerate:Show();
		LFGBrowseGroupDataDisplayEnumerate_Update(self.Enumerate, activityInfo.maxNumPlayers, displayData, disabled, LFGBROWSE_GROUPDATA_ROLE_ORDER);
	elseif ( activityInfo.displayType == Enum.LFGListDisplayType.ClassEnumerate ) then
		self.Enumerate:Show();
		LFGBrowseGroupDataDisplayEnumerate_Update(self.Enumerate, activityInfo.maxNumPlayers, displayData, disabled, LFGBROWSE_GROUPDATA_CLASS_ORDER);
	elseif ( activityInfo.displayType == Enum.LFGListDisplayType.PlayerCount ) then
		self.PlayerCount:Show();
		LFGBrowseGroupDataDisplayPlayerCount_Update(self.PlayerCount, displayData, disabled);
	elseif ( activityInfo.displayType == Enum.LFGListDisplayType.HideAll ) then
		-- Handled above!
	else
		GMError("Unknown display type");
	end
end

function LFGBrowseGroupDataDisplayComment_Update(self, text, disabled)
	self:SetText(text);
	if (disabled) then
		self:SetTextColor(LFGBROWSE_DELISTED_FONT_COLOR.r, LFGBROWSE_DELISTED_FONT_COLOR.g, LFGBROWSE_DELISTED_FONT_COLOR.b);
	else
		self:SetTextColor(LIGHTGRAY_FONT_COLOR.r, LIGHTGRAY_FONT_COLOR.g, LIGHTGRAY_FONT_COLOR.b);
	end
end

function LFGBrowseGroupDataDisplaySolo_Update(self, displayData)
	-- TODO: IMPLEMENT ONCE SOLO ROLES ARE IN
	self:Hide();
end

function LFGBrowseGroupDataDisplayRoleCount_Update(self, displayData, disabled)
	self.TankCount:SetText(displayData.TANK);
	self.HealerCount:SetText(displayData.HEALER);
	self.DamagerCount:SetText(displayData.DAMAGER);

	--Update for the disabled state
	local r = disabled and LFGBROWSE_DELISTED_FONT_COLOR.r or HIGHLIGHT_FONT_COLOR.r;
	local g = disabled and LFGBROWSE_DELISTED_FONT_COLOR.g or HIGHLIGHT_FONT_COLOR.g;
	local b = disabled and LFGBROWSE_DELISTED_FONT_COLOR.b or HIGHLIGHT_FONT_COLOR.b;
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

function LFGBrowseGroupDataDisplayEnumerate_Update(self, numPlayers, displayData, disabled, iconOrder)
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
			self.Icons[iconIndex]:SetAtlas(LFGBROWSE_GROUPDATA_ATLASES[iconOrder[i]], false);
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

function LFGBrowseGroupDataDisplayPlayerCount_Update(self, displayData, disabled)
	local numPlayers = displayData.TANK + displayData.HEALER + displayData.DAMAGER + displayData.NOROLE;

	local color = disabled and LFGBROWSE_DELISTED_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
	self.Count:SetText(numPlayers);
	self.Count:SetTextColor(color.r, color.g, color.b);
	self.Icon:SetDesaturated(disabled);
	self.Icon:SetAlpha(disabled and 0.5 or 1);
end

-------------------------------------------------------
----------Search Entry Menu
-------------------------------------------------------
local LFGBROWSE_SEARCH_ENTRY_MENU = {
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
		func = function(_, name, inviteFunc) inviteFunc(name); end,
		notCheckable = true,
		arg1 = nil, --Leader name goes here
		arg2 = InviteUnit, -- Invite action function goes here
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
					LFGBrowseFrame:RefreshResults();
				end,
				arg1 = nil, --Search result ID goes here
				notCheckable = true,
			},
			{
				text = LFG_LIST_BAD_DESCRIPTION,
				func = function(_, id)
					C_LFGList.ReportSearchResult(id, "lfglistcomment");
					LFGBrowseFrame:RefreshResults();
				end,
				arg1 = nil, --Search reuslt ID goes here
				notCheckable = true,
				disabled = nil,	--Disabled if the description is just an empty string
			},
			{
				text = LFG_LIST_BAD_LEADER_NAME,
				func = function(_, id)
					C_LFGList.ReportSearchResult(id, "badplayername");
					LFGBrowseFrame:RefreshResults();
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

function LFGBrowseMixin:GetSearchEntryMenu(resultID)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	LFGBROWSE_SEARCH_ENTRY_MENU[1].text = searchResultInfo.leaderName;

	LFGBROWSE_SEARCH_ENTRY_MENU[2].arg1 = searchResultInfo.leaderName;
	LFGBROWSE_SEARCH_ENTRY_MENU[2].disabled = not searchResultInfo.leaderName;

	LFGBROWSE_SEARCH_ENTRY_MENU[3].arg1 = searchResultInfo.leaderName;
	LFGBROWSE_SEARCH_ENTRY_MENU[3].disabled = not searchResultInfo.leaderName;
	local inviteText, inviteFunc = LFGBrowseUtil_GetInviteActionForResult(resultID);
	LFGBROWSE_SEARCH_ENTRY_MENU[3].text = inviteText;
	LFGBROWSE_SEARCH_ENTRY_MENU[3].arg2 = inviteFunc;

	LFGBROWSE_SEARCH_ENTRY_MENU[4].menuList[1].arg1 = resultID;
	LFGBROWSE_SEARCH_ENTRY_MENU[4].menuList[2].arg1 = resultID;
	LFGBROWSE_SEARCH_ENTRY_MENU[4].menuList[2].disabled = (searchResultInfo.comment == "");
	LFGBROWSE_SEARCH_ENTRY_MENU[4].menuList[3].arg1 = resultID;
	LFGBROWSE_SEARCH_ENTRY_MENU[4].menuList[3].disabled = not searchResultInfo.leaderName;
	return LFGBROWSE_SEARCH_ENTRY_MENU;
end

-------------------------------------------------------
----------Category DropDown
-------------------------------------------------------
function LFGBrowseCategoryDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	local categories = C_LFGList.GetAvailableCategories();
	if (#categories == 0) then
		-- None button
		info.text = LFG_TYPE_NONE;
		info.value = 0;
		info.func = LFGBrowseCategoryButton_OnClick;
		info.owner = self;
		info.checked = UIDropDownMenu_GetSelectedValue(self) == info.value;
		info.classicChecks = true;
		UIDropDownMenu_AddButton(info);
	else
		local currentSelectedValue = UIDropDownMenu_GetSelectedValue(self) or 0;
		local foundChecked = false;
		for i=1, #categories do
			local name = C_LFGList.GetCategoryInfo(categories[i]);

			info.text = name;
			info.value = categories[i];
			info.func = LFGBrowseCategoryButton_OnClick;
			info.owner = self;
			info.checked = currentSelectedValue == info.value;
			info.classicChecks = true;
			UIDropDownMenu_AddButton(info);
			if (info.checked) then
				UIDropDownMenu_SetSelectedValue(self, info.value);
				foundChecked = true;
			end
		end

		if (not foundChecked) then
			UIDropDownMenu_SetText(self, CATEGORY);
		end
	end
end

function LFGBrowseCategoryButton_OnClick(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value);
	LFGBrowseActivityDropDown_ValueReset(LFGBrowseFrame.ActivityDropDown);
	UIDropDownMenu_ClearAll(LFGBrowseFrame.ActivityDropDown);
	UIDropDownMenu_Initialize(LFGBrowseFrame.ActivityDropDown, LFGBrowseActivityDropDown_Initialize);
	LFGBrowseActivityDropDown_ValueAll(LFGBrowseFrame.ActivityDropDown);
	LFGBrowse_DoSearch();
end

-------------------------------------------------------
----------Activity DropDown
-------------------------------------------------------
function LFGBrowseActivityDropDown_Initialize(self)
	local selectedType = UIDropDownMenu_GetSelectedValue(LFGBrowseFrame.CategoryDropDown) or 0;

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
				LFGBrowseActivityDropDown_ValueAll(self);
				UIDropDownMenu_Refresh(self, true);
				LFGBrowseActivityDropDown_UpdateHeaderText(self);
				LFGBrowse_DoSearch();
			end;
			UIDropDownMenu_AddButton(metaButtonInfo);

			-- Uncheck All button
			metaButtonInfo.text = UNCHECK_ALL;
			metaButtonInfo.func = function()
				LFGBrowseActivityDropDown_ValueReset(self);
				UIDropDownMenu_Refresh(self, true);
				LFGBrowseActivityDropDown_UpdateHeaderText(self);
				LFGBrowse_DoSearch();
			end;
			UIDropDownMenu_AddButton(metaButtonInfo);
		end

		-- Individual Activity Buttons
		local buttonInfo = UIDropDownMenu_CreateInfo();
		buttonInfo.func = LFGBrowseActivityButton_OnClick;
		buttonInfo.owner = self;
		buttonInfo.keepShownOnClick = true;
		buttonInfo.classicChecks = true;

		for i=1, #activities do
			local activityInfo = C_LFGList.GetActivityInfoTable(activities[i]);

			buttonInfo.text = activityInfo.fullName;
			buttonInfo.value = activities[i];
			buttonInfo.checked = function(self)
				return LFGBrowseActivityDropDown_ValueIsSelected(LFGBrowseFrame.ActivityDropDown, self.value);
			end;
			UIDropDownMenu_AddButton(buttonInfo);
		end
	else
		LFGBrowseActivityDropDown_ValueReset(self);
		UIDropDownMenu_DisableDropDown(self);
		UIDropDownMenu_ClearAll(self);
	end

	LFGBrowseActivityDropDown_UpdateHeaderText(self);
end

function LFGBrowseActivityDropDown_ValueAll(self)
	local selectedType = UIDropDownMenu_GetSelectedValue(LFGBrowseFrame.CategoryDropDown) or 0;

	if ( selectedType > 0 ) then
		local activities = C_LFGList.GetAvailableActivities(selectedType);
		for i=1, #activities do
			LFGBrowseActivityDropDown_ValueSetSelected(self, activities[i], true);
		end
	end
end

function LFGBrowseActivityDropDown_ValueReset(self)
	wipe(self.selectedValues);
end

function LFGBrowseActivityDropDown_ValueIsSelected(self, value)
	return tContains(self.selectedValues, value);
end

function LFGBrowseActivityDropDown_ValueSetSelected(self, value, selected)
	if (selected) then
		if (not tContains(self.selectedValues, value)) then
			tinsert(self.selectedValues, value);
		end
	else
		tDeleteItem(self.selectedValues, value);
	end
	LFGBrowseActivityDropDown_UpdateHeaderText(self);
end

function LFGBrowseActivityDropDown_ValueToggleSelected(self, value)
	LFGBrowseActivityDropDown_ValueSetSelected(self, value, not LFGBrowseActivityDropDown_ValueIsSelected(self, value));
end

function LFGBrowseActivityDropDown_UpdateHeaderText(self)
	if #self.selectedValues == 1 then
		local activityInfo = C_LFGList.GetActivityInfoTable(self.selectedValues[1]);
		UIDropDownMenu_SetText(self, activityInfo.fullName);
	else
		UIDropDownMenu_SetText(self, string.format(LFGBROWSE_ACTIVITY_HEADER, #self.selectedValues));
	end
end

function LFGBrowseActivityButton_OnClick(self)
	LFGBrowseActivityDropDown_ValueToggleSelected(self.owner, self.value);
	LFGBrowse_DoSearch();
end

-------------------------------------------------------
----------Buttons
-------------------------------------------------------
function LFGBrowseGroupInviteButton_OnClick(self, button)
	local selectedElement = LFGBrowseFrame.selectionBehavior:GetSelectedElementData()[1];
	if (selectedElement) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(selectedElement.resultID);
		if (searchResultInfo) then
			self.inviteFunc(searchResultInfo.leaderName);
		end
	end
end

function LFGBrowseSendMessageButton_OnClick(self, button)
	local selectedElement = LFGBrowseFrame.selectionBehavior:GetSelectedElementData()[1];
	if (selectedElement) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(selectedElement.resultID);
		if (searchResultInfo) then
			ChatFrame_SendTell(searchResultInfo.leaderName);
		end
	end
end

-------------------------------------------------------
----------Util
-------------------------------------------------------
local roleRemainingKeyLookup = {
	["TANK"] = "TANK_REMAINING",
	["HEALER"] = "HEALER_REMAINING",
	["DAMAGER"] = "DAMAGER_REMAINING",
};

local function HasRemainingSlotsForLocalPlayerRole(lfgSearchResultID)
	local roles = C_LFGList.GetSearchResultMemberCounts(lfgSearchResultID);
	local playerRole = "DAMAGER"; -- TODO: IMPLEMENT ONCE SOLO ROLES ARE IN
	return roles[roleRemainingKeyLookup[playerRole]] > 0;
end

function LFGBrowseUtil_SortSearchResults(results)
	local function SortCB(searchResultID1, searchResultID2)
		local searchResultInfo1 = C_LFGList.GetSearchResultInfo(searchResultID1);
		local searchResultInfo2 = C_LFGList.GetSearchResultInfo(searchResultID2);

		local isSolo1 = searchResultInfo1.numMembers == 1;
		local isSolo2 = searchResultInfo2.numMembers == 1;
		if (isSolo1 ~= isSolo2) then
			if (IsInGroup()) then
				return isSolo1; -- When in a group, solo players go to the top.
			else
				return isSolo2 -- When solo, groups go to the top.
			end
		end

		if (isSolo1) then
			-- For solo players, numRoles > canTank > canHeal > canDPS > timeInQueue.
			-- TODO: IMPLEMENT ONCE SOLO ROLES ARE IN
		else
			-- For groups, hasSlotForOurRoles > groupSize > timeInQueue
			local hasSlotForRole1 = HasRemainingSlotsForLocalPlayerRole(searchResultID1);
			local hasSlotForRole2 = HasRemainingSlotsForLocalPlayerRole(searchResultID2);
			-- Groups with your current role available are preferred
			if (hasSlotForRole1 ~= hasSlotForRole2) then
				return hasRemainingRole1;
			end
		end

		--If we aren't sorting by anything else, just go by ID
		return searchResultID1 < searchResultID2;
	end

	table.sort(results, SortCB);
end

function LFGBrowseUtil_GetInviteActionForResult(resultID)
	local inviteText = GROUP_INVITE;
	local inviteFunc = InviteToGroup;
	if (IsInGroup()) then
		if (not (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))) then
			inviteText = SUGGEST_INVITE;
		end
	elseif (resultID) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
		if (searchResultInfo and searchResultInfo.numMembers > 1) then
			inviteText = JOIN_QUEUE;
			inviteFunc = RequestInviteFromUnit;
		end
	end

	return inviteText, inviteFunc;
end