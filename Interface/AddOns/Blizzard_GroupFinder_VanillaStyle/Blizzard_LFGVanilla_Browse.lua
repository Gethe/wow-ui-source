-------------------------------------------------------
----------Constants
-------------------------------------------------------
local LFGBROWSE_TOOLTIP_MIN_WIDTH = 200;
local LFGBROWSE_DELISTED_FONT_COLOR = {r=0.3, g=0.3, b=0.3};
local LFGBROWSE_ACTIVITY_NOMATCH_FONT_COLOR = GRAY_FONT_COLOR;
local LFGBROWSE_ACTIVITY_MATCH_FONT_COLOR = BRIGHTBLUE_FONT_COLOR;
local LFGBROWSE_SELF_FONT_COLOR = LIGHTGREEN_FONT_COLOR;
local LFGBROWSE_GROUPDATA_ROLE_ORDER = { "TANK", "HEALER", "DAMAGER" };
local LFGBROWSE_GROUPDATA_CLASS_ORDER = CLASS_SORT_ORDER;
local LFGBROWSE_GROUPDATA_ATLASES = {
	--Roles
	TANK = "groupfinder-icon-role-large-tank",
	HEALER = "groupfinder-icon-role-large-heal",
	DAMAGER = "groupfinder-icon-role-large-dps",
	-- Solo Roles
	SOLO_TANK = "groupfinder-icon-role-micro-tank",
	SOLO_HEALER = "groupfinder-icon-role-micro-heal",
	SOLO_DAMAGER = "groupfinder-icon-role-micro-dps",
};
--Fill out classes
for i=1, #CLASS_SORT_ORDER do
	LFGBROWSE_GROUPDATA_ATLASES[CLASS_SORT_ORDER[i]] = "groupfinder-icon-class-"..string.lower(CLASS_SORT_ORDER[i]);
end

local LFGBROWSE_DUNGEON_NUM_TANKS_EXPECTED = 1;
local LFGBROWSE_DUNGEON_NUM_HEALERS_EXPECTED = 1;
local LFGBROWSE_DUNGEON_NUM_DPS_EXPECTED = 3;

-- If a listing is queued for multiple activities with disparate displayTypes, pick the "best" one (i.e. most flexible/informative) based off this priority.
local LFGBROWSE_DISPLAYTYPE_PRIORITY = {
	[Enum.LFGListDisplayType.Comment] = 6, -- Highest priority.
	[Enum.LFGListDisplayType.RoleCount] = 5,
	[Enum.LFGListDisplayType.PlayerCount] = 4,
	[Enum.LFGListDisplayType.RoleEnumerate] = 3,
	[Enum.LFGListDisplayType.ClassEnumerate] = 2,
	[Enum.LFGListDisplayType.HideAll] = 1, -- Lowest priority.
};

-------------------------------------------------------
----------LFGBrowseMixin
-------------------------------------------------------
LFGBrowseMixin = {};

function LFGBrowseMixin:OnLoad()
	-- Event for entire list
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE");
	self:RegisterEvent("LFG_LIST_SEARCH_FAILED");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED");
	self:RegisterEvent("REPORT_PLAYER_RESULT");

	self.results = {};
	self.searchFailed = false;
	self.searching = false;
	self.totalResults = 0;

	local view = CreateScrollBoxListLinearView();
	view:SetElementFactory(function(factory, elementData)
		factory("LFGBrowseSearchEntryTemplate", function(frame, elementData)
			LFGBrowseSearchEntry_Init(frame, elementData);
		end);
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

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox, SelectionBehaviorFlags.Deselectable);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);

	self:UpdateButtonState();
	if (C_LFGList.HasActiveEntryInfo()) then
		LFGParentFrame_SearchActiveEntry();
	end
end

function LFGBrowseMixin:OnEvent(event, ...)
	if ( event == "CVAR_UPDATE" ) then
		local name = ...;
		if name == "disableSuggestedLevelActivityFilter" then
			self:ActivityFiltersChanged();
		end
	elseif ( event == "LFG_LIST_AVAILABILITY_UPDATE" ) then
		self:RefreshDropdowns();
	elseif ( event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" ) then
		self.searching = false;
		self.searchFailed = false;
		self:UpdateResultList();
	elseif ( event == "LFG_LIST_SEARCH_FAILED" ) then
		self.searching = false;
		self.searchFailed = true;
		self:UpdateResultList();
	elseif ( event == "REPORT_PLAYER_RESULT") then
		local success, reportType = ...;
		if (success and reportType == Enum.ReportType.GroupFinderPosting) then
			LFGBrowseFrame:UpdateResultList();
		end
	end
end

function LFGBrowseMixin:OnShow()
	self:RefreshDropdowns();
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
	self.selectionBehavior:ClearSelections();
	self.ScrollBox:RemoveDataProvider();

	if ( self.searching ) then
		self.SearchingSpinner:Show();
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
	if (not self.CategoryDropdown or not self.ActivityDropdown) then
		return;
	end

	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	local firstCategoryID = 0;
	if (activeEntryInfo) then
		self.ActivityDropdown:ValueReset();
		for i=1, #activeEntryInfo.activityIDs do
			local activityID = activeEntryInfo.activityIDs[i];
			if (activityID ~= 0) then
				local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
				local categoryID = activityInfo.categoryID;
				if (firstCategoryID == 0) then
					firstCategoryID = categoryID;
					self.CategoryDropdown:SetValue(categoryID);
				end
				if (categoryID == firstCategoryID) then
					self.ActivityDropdown:ValueSetSelected(activityID, true)
				end
			end
		end
	end

	LFGBrowse_DoSearch();
end

function LFGBrowseMixin:ValidateSelection()
	local selectedResultID = self.selectionBehavior:HasSelection() and LFGBrowseFrame.selectionBehavior:GetSelectedElementData()[1].resultID or nil;
	if (selectedResultID) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(selectedResultID);
		if (not searchResultInfo or searchResultInfo.isDelisted) then
			self.selectionBehavior:ClearSelections();
		end
	end
end

function LFGBrowseMixin:RefreshDropdowns()
	self.CategoryDropdown:SetupDropdown();
	self.ActivityDropdown:SetupDropdown();
end

function LFGBrowseMixin:ResetDropdowns()
	self.CategoryDropdown:Reset();
	self.ActivityDropdown:Reset();
end

function LFGBrowseMixin:UpdateButtonState()
	local selectedResultID = self.selectionBehavior:HasSelection() and LFGBrowseFrame.selectionBehavior:GetSelectedElementData()[1].resultID or nil;
	local inviteText, inviteFunc = LFGBrowseUtil_GetInviteActionForResult(selectedResultID)

	self.GroupInviteButton:SetText(inviteText);
	self.GroupInviteButton.inviteFunc = inviteFunc;

	self.SendMessageButton:SetEnabled(self.selectionBehavior:HasSelection());
	self.GroupInviteButton:SetEnabled(self.selectionBehavior:HasSelection() and self.GroupInviteButton.inviteFunc);

	self.RefreshButton:SetEnabled(not self.searching);
end

function LFGBrowseMixin:ActivityFiltersChanged()
	self:ResetDropdowns();
end

-------------------------------------------------------
----------Searching
-------------------------------------------------------
function LFGBrowseSearchButton_OnClick(self, button)
	LFGBrowse_DoSearch();
end

function LFGBrowse_DoSearch()
	if (not LFGBrowseFrame.searching) then
		local categoryID = LFGBrowseFrame.CategoryDropdown:GetValue();
		if (categoryID > 0) then
			local activityIDs = LFGBrowseFrame.ActivityDropdown.selectedValues;
			if (#activityIDs == 0) then -- If we have no activities selected in the filter, search for everything in this category.
				activityIDs = LFGUtil_GetFilteredActivities(categoryID);
			end

			local filter = 0;
			local preferredFilters = 0;
			local languageFilter = nil;
			local searchCrossFactionListings = false;
			local advancedFilter = nil;
			C_LFGList.Search(categoryID, filter, preferredFilters, languageFilter, searchCrossFactionListings, advancedFilter, activityIDs);

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
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	local isSolo = searchResultInfo.numMembers == 1;
	local soloRoles = nil;
	if (isSolo) then
		self.PartyIcon:Hide();
		self.ClassIcon:Show();
		self.Level:Show();

		local memberInfo = C_LFGList.GetSearchResultPlayerInfo(self.resultID, 1);
		if (memberInfo and memberInfo.classFilename and memberInfo.level) then
			self.Level:SetText(LEVEL_ABBR .. " " ..memberInfo.level);
			self.ClassIcon:SetAtlas(LFGBROWSE_GROUPDATA_ATLASES[memberInfo.classFilename], false);
		else
			self.Level:Hide();
			self.ClassIcon:Hide();
		end
		self.Name:SetPoint("TOPLEFT", self.PartyIcon, "TOPLEFT", 1, -2);
		self.NewPlayerFriendlyIcon:SetPoint("LEFT", self.ClassIcon, "RIGHT", 2, 0);

		if (memberInfo) then
			soloRoles = memberInfo.lfgRoles;
		end
	else
		self.PartyIcon:Show();
		self.Level:Hide();
		self.ClassIcon:Hide();
		self.Name:SetPoint("TOPLEFT", self.PartyIcon, "TOPRIGHT", 0, -2);
		self.NewPlayerFriendlyIcon:SetPoint("LEFT", self.Name, "RIGHT", 2, 0);
	end

	self.isDelisted = searchResultInfo.isDelisted;
	self.hasSelf = searchResultInfo.hasSelf;

	local matchingActivities = {};
	local hasMatchingActivity = false;
	if (activeEntryInfo) then
		for _, activityID in ipairs(activeEntryInfo.activityIDs) do
			if (tContains(searchResultInfo.activityIDs, activityID)) then
				hasMatchingActivity = true;
				tinsert(matchingActivities, activityID);
			end
		end
	end
	local activitiesToDisplay = hasMatchingActivity and matchingActivities or searchResultInfo.activityIDs;

	local activityText = "";
	if ( searchResultInfo.hasSelf ) then
		activityText = LFG_SELF_LISTING;
	elseif ( #activitiesToDisplay == 1 ) then
		local activityInfo = C_LFGList.GetActivityInfoTable(activitiesToDisplay[1]);
		activityText = LFGUtil_GetActivityInfoName(activityInfo);
	else
		local activityString = hasMatchingActivity and LFGBROWSE_ACTIVITY_MATCHING_COUNT or LFGBROWSE_ACTIVITY_COUNT;
		activityText = string.format(activityString, #activitiesToDisplay);
	end

	local matchesFilters = true;
	if( #LFGBrowseFrame.ActivityDropdown.selectedValues > 0) then
		matchesFilters = false;
		for i=1, #searchResultInfo.activityIDs do
			if (LFGBrowseFrame.ActivityDropdown:ValueIsSelected(searchResultInfo.activityIDs[i])) then
				matchesFilters = true;
				break;
			end
		end
	end

	local leaderInfo = C_LFGList.GetSearchResultLeaderInfo(self.resultID);
	local nameColor = NORMAL_FONT_COLOR;
	if (leaderInfo and leaderInfo.classFilename) then
		nameColor = RAID_CLASS_COLORS[leaderInfo.classFilename];
	end
	local levelColor = GRAY_FONT_COLOR;
	local activityColor = LFGBROWSE_ACTIVITY_NOMATCH_FONT_COLOR;
	if ( searchResultInfo.isDelisted or not matchesFilters) then
		nameColor = LFGBROWSE_DELISTED_FONT_COLOR;
		levelColor = LFGBROWSE_DELISTED_FONT_COLOR;
		activityColor = LFGBROWSE_DELISTED_FONT_COLOR;
	elseif ( searchResultInfo.hasSelf ) then
		activityColor = LFGBROWSE_SELF_FONT_COLOR;
	elseif ( hasMatchingActivity ) then
		activityColor = LFGBROWSE_ACTIVITY_MATCH_FONT_COLOR;
	end

	self.Name:SetWidth(0);
	self.Name:SetText(searchResultInfo.leaderName);
	self.Name:SetTextColor(nameColor.r, nameColor.g, nameColor.b);
	if ( self.Name:GetWidth() > 176 ) then
		self.Name:SetWidth(176);
	end
	self.Level:SetTextColor(levelColor.r, levelColor.g, levelColor.b);
	self.ClassIcon:SetDesaturated(searchResultInfo.isDelisted);
	self.ActivityName:SetText(activityText);
	self.ActivityName:SetTextColor(activityColor.r, activityColor.g, activityColor.b);

	if ( searchResultInfo.newPlayerFriendly ) then
		self.NewPlayerFriendlyIcon:Show();
	else
		self.NewPlayerFriendlyIcon:Hide();
	end
	self.NewPlayerFriendlyIcon:SetDesaturated(searchResultInfo.isDelisted);

	local displayData = C_LFGList.GetSearchResultMemberCounts(self.resultID);
	local displayType, maxNumPlayers = LFGBrowseUtil_GetBestDisplayTypeForActivityIDs(searchResultInfo.activityIDs);
	LFGBrowseGroupDataDisplay_Update(self.DataDisplay, displayType, maxNumPlayers, displayData, searchResultInfo.isDelisted, isSolo, soloRoles, searchResultInfo.comment);

	local mouseFoci = GetMouseFoci();
	for _, mouseFocus in ipairs(mouseFoci) do
		if ( mouseFocus == self ) then
			LFGBrowseSearchEntry_OnEnter(self);
			break;
		end
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
			LFGBrowseFrame:ValidateSelection();
			LFGBrowseSearchEntry_Update(self);
		end
	end
end

function LFGBrowseSearchEntry_OnClick(self, button)
	if (self.isDelisted or self.hasSelf) then
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if ( button == "LeftButton" ) then
		LFGBrowseFrame.selectionBehavior:ToggleSelect(self);
	elseif ( button == "RightButton" ) then
		LFGBrowseFrame:CreateSearchEntryMenu(self);
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
	self.completedEncounterPool = CreateFontStringPool(self, "ARTWORK", 0, "LFGBrowseSearchEntryTooltipCompletedEncounterTemplate")
end

function LFGBrowseSearchEntryTooltip_UpdateAndShow(self, resultID)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	local numMembers = searchResultInfo.numMembers;
	local isSolo = numMembers == 1;
	local memberCounts = C_LFGList.GetSearchResultMemberCounts(resultID);
	local maxContentWidth = 0; -- Tracking the width of any variable-width content, so we can resize the container to match.

	-- Delisted Alert
	if (searchResultInfo.isDelisted) then
		self.Delisted:Show();
	else
		self.Delisted:Hide();
	end

	-- New Player Friendly
	if (searchResultInfo.newPlayerFriendly and not self.Delisted:IsShown()) then
		self.NewPlayerFriendlyIcon:Show();
		self.NewPlayerFriendlyText:Show();
	else
		self.NewPlayerFriendlyIcon:Hide();
		self.NewPlayerFriendlyText:Hide();
	end

	-- Leader
	if (self.NewPlayerFriendlyIcon:IsShown()) then
		self.LeaderIcon:SetPoint("TOPLEFT", self.NewPlayerFriendlyIcon, "BOTTOMLEFT", 0, -5);
	elseif (self.Delisted:IsShown()) then
		self.LeaderIcon:SetPoint("TOPLEFT", self.Delisted, "BOTTOMLEFT", 0, -8);
	else
		self.LeaderIcon:SetPoint("TOPLEFT", 11, -10);
	end
	local lastMemberFrame = self.Leader;
	local maxNameWidth = 0;
	if (numMembers > 1) then
		self.LeaderIcon:Show();
		self.Leader:SetPoint("TOPLEFT", self.LeaderIcon, "TOPRIGHT", 0, -2)
	else
		self.LeaderIcon:Hide();
		self.Leader:SetPoint("TOPLEFT", self.LeaderIcon, "TOPLEFT", 0, -2)
	end
	do
		local leaderInfo = C_LFGList.GetSearchResultLeaderInfo(resultID);
		if (leaderInfo and leaderInfo.name) then
			local classColor = RAID_CLASS_COLORS[leaderInfo.classFilename];
			self.Leader.Name:SetWidth(0); -- Reset the width so that we auto-expand to the text size correctly.
			self.Leader.Name:SetText(leaderInfo.name);
			self.Leader.Name:SetTextColor(classColor.r, classColor.g, classColor.b)
			self.Leader.Level:SetText(LEVEL_ABBR .. " " .. leaderInfo.level);
			if (isSolo) then
				LFGBrowseUtil_MapRoleStatesToRoleIcons(self.Leader.Roles, leaderInfo.lfgRoles.tank, leaderInfo.lfgRoles.healer, leaderInfo.lfgRoles.dps, true);
			else
				-- If we're in a party, just show our party-level role.
				local role = leaderInfo.assignedRole;
				LFGBrowseUtil_MapRoleStatesToRoleIcons(self.Leader.Roles, role == "TANK", role == "HEALER", role == "DAMAGER", false);
			end
			self.Leader:Show();

			maxNameWidth = math.max(maxNameWidth, self.Leader.Name:GetWidth());
		else
			self.Leader:Hide();
			self.LeaderIcon:Hide();
		end
	end

	-- Members
	self.memberPool:ReleaseAll();
	if (numMembers <= 10) then
		for i=1, numMembers do
			local memberInfo = C_LFGList.GetSearchResultPlayerInfo(resultID, i);
			if (memberInfo and memberInfo.name and not memberInfo.isLeader) then -- Leader handled above.
				local frame = self.memberPool:Acquire();
				local classColor = RAID_CLASS_COLORS[memberInfo.classFilename];
				frame.Name:SetWidth(0); -- Reset the width so that we auto-expand to the text size correctly.
				frame.Name:SetText(memberInfo.name);
				frame.Name:SetTextColor(classColor.r, classColor.g, classColor.b)
				frame.Level:SetText(LEVEL_ABBR .. " " .. memberInfo.level);
				frame.Role:SetAtlas(LFGBROWSE_GROUPDATA_ATLASES[memberInfo.assignedRole], false);

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
	if (isSolo) then
		self.MemberCount:SetText(string.format(LFG_LIST_TOOLTIP_MEMBERS_SIMPLE, numMembers));
	elseif (memberCounts) then
		self.MemberCount:SetText(string.format(LFG_LIST_TOOLTIP_MEMBERS, numMembers, memberCounts.TANK, memberCounts.HEALER, memberCounts.DAMAGER));
	end

	-- Activities
	local lastActivityString = nil
	self.activityPool:ReleaseAll();
	local numActivities = #searchResultInfo.activityIDs;
	local numActivityGroups = 1; -- Used for height calculation; value updated later.
	local ACTIVITY_GROUP_SPACER_HEIGHT = 6;
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();

	if (numActivities > 0) then
		local organizedActivities = LFGUtil_OrganizeActivitiesByActivityGroup(searchResultInfo.activityIDs);
		local activityGroupIDs = GetKeysArray(organizedActivities);
		numActivityGroups = #activityGroupIDs;
		LFGUtil_SortActivityGroupIDs(activityGroupIDs);

		for i, activityGroupID in ipairs(activityGroupIDs) do
			local activityIDs = organizedActivities[activityGroupID];
			if (activityGroupID == 0) then -- Free-floating activities (no group)
				for _, activityID in ipairs(activityIDs) do
					local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
					local activityName = LFGUtil_GetActivityInfoName(activityInfo);
					if (activityInfo and activityName ~= "") then
						local fontString = self.activityPool:Acquire();
						fontString:SetWidth(0);
						fontString:SetText(activityName);

						if (activeEntryInfo and tContains(activeEntryInfo.activityIDs, activityID)) then
							fontString:SetTextColor(LFGBROWSE_ACTIVITY_MATCH_FONT_COLOR.r, LFGBROWSE_ACTIVITY_MATCH_FONT_COLOR.g, LFGBROWSE_ACTIVITY_MATCH_FONT_COLOR.b);
						else
							fontString:SetTextColor(LFGBROWSE_ACTIVITY_NOMATCH_FONT_COLOR.r, LFGBROWSE_ACTIVITY_NOMATCH_FONT_COLOR.g, LFGBROWSE_ACTIVITY_NOMATCH_FONT_COLOR.b);
						end

						fontString:Show();
						if (lastActivityString) then
							fontString:SetPoint("TOPLEFT", lastActivityString, "BOTTOMLEFT", 0, 0);
						else
							fontString:SetPoint("TOPLEFT", self.MemberCount, "BOTTOMLEFT", 0, -8);
						end
						maxContentWidth = math.max(maxContentWidth, fontString:GetWidth());
						fontString:SetPoint("RIGHT", self, "RIGHT", -11, 0);
						lastActivityString = fontString;
					end
				end
			else -- Grouped activities
				local activityGroupName = C_LFGList.GetActivityGroupInfo(activityGroupID);
				local groupFontString = self.activityPool:Acquire();
				groupFontString:SetWidth(0);
				groupFontString:SetText(activityGroupName);
				groupFontString:Show();
				if (lastActivityString) then
					if (i > 1) then
						-- If this is a group after the first, add a bit more space.
						groupFontString:SetPoint("TOPLEFT", lastActivityString, "BOTTOMLEFT", 0, -ACTIVITY_GROUP_SPACER_HEIGHT);
					else
						groupFontString:SetPoint("TOPLEFT", lastActivityString, "BOTTOMLEFT", 0, 0);
					end
				else
					groupFontString:SetPoint("TOPLEFT", self.MemberCount, "BOTTOMLEFT", 0, -8);
				end
				maxContentWidth = math.max(maxContentWidth, groupFontString:GetWidth());
				lastActivityString = groupFontString;
				local groupHasMatchingActivity = false;

				for _, activityID in ipairs(activityIDs) do
					local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
					local activityName = LFGUtil_GetActivityInfoName(activityInfo);
					if (activityInfo and activityName ~= "") then
						local fontString = self.activityPool:Acquire();
						fontString:SetWidth(0);
						fontString:SetText(string.format(LFG_LIST_INDENT, activityName));

						if (activeEntryInfo and tContains(activeEntryInfo.activityIDs, activityID)) then
							groupHasMatchingActivity = true;
							fontString:SetTextColor(LFGBROWSE_ACTIVITY_MATCH_FONT_COLOR.r, LFGBROWSE_ACTIVITY_MATCH_FONT_COLOR.g, LFGBROWSE_ACTIVITY_MATCH_FONT_COLOR.b);
						else
							fontString:SetTextColor(LFGBROWSE_ACTIVITY_NOMATCH_FONT_COLOR.r, LFGBROWSE_ACTIVITY_NOMATCH_FONT_COLOR.g, LFGBROWSE_ACTIVITY_NOMATCH_FONT_COLOR.b);
						end

						fontString:Show();
						if (lastActivityString) then
							fontString:SetPoint("TOPLEFT", lastActivityString, "BOTTOMLEFT", 0, 0);
						else
							fontString:SetPoint("TOPLEFT", self.MemberCount, "BOTTOMLEFT", 0, -8);
						end
						maxContentWidth = math.max(maxContentWidth, fontString:GetWidth());
						fontString:SetPoint("RIGHT", self, "RIGHT", -11, 0);
						lastActivityString = fontString;
					end
				end

				if (groupHasMatchingActivity) then
					groupFontString:SetTextColor(LFGBROWSE_ACTIVITY_MATCH_FONT_COLOR.r, LFGBROWSE_ACTIVITY_MATCH_FONT_COLOR.g, LFGBROWSE_ACTIVITY_MATCH_FONT_COLOR.b);
				else
					groupFontString:SetTextColor(LFGBROWSE_ACTIVITY_NOMATCH_FONT_COLOR.r, LFGBROWSE_ACTIVITY_NOMATCH_FONT_COLOR.g, LFGBROWSE_ACTIVITY_NOMATCH_FONT_COLOR.b);
				end
			end
		end
	end

	-- Completed Encounters
	local lastCompletedEncounterString = nil
	self.completedEncounterPool:ReleaseAll();

	self.CompletedEncounterHeader:Hide(); -- Hide by default; show below if conditions are appropriate.
	if (numActivities == 1 and lastActivityString) then
		local completedEncounters = C_LFGList.GetSearchResultEncounterInfo(resultID);
		if (completedEncounters and #completedEncounters > 0) then
			self.CompletedEncounterHeader:Show();
			self.CompletedEncounterHeader:SetPoint("TOPLEFT", lastActivityString, "BOTTOMLEFT", 0, -8);

			for i=1, #completedEncounters do
				local fontString = self.completedEncounterPool:Acquire();
				fontString:SetText(completedEncounters[i]);
				fontString:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				fontString:Show();

				if (lastCompletedEncounterString) then
					fontString:SetPoint("TOPLEFT", lastCompletedEncounterString, "BOTTOMLEFT", 0, 0);
				else
					fontString:SetPoint("TOPLEFT", self.CompletedEncounterHeader, "BOTTOMLEFT", 0, 0);
				end
				lastCompletedEncounterString = fontString;
			end
		end
	end

	-- Show
	self:Show();

	-- Set Width
	self:SetWidth(math.max(maxContentWidth+22, LFGBROWSE_TOOLTIP_MIN_WIDTH));
	-- Height calculation
	local contentHeight = 40;
	if ( self.Delisted:IsShown() ) then
		contentHeight = contentHeight + self.Delisted:GetHeight();
		contentHeight = contentHeight + 8;
	end
	if ( self.NewPlayerFriendlyText:IsShown() ) then
		contentHeight = contentHeight + self.NewPlayerFriendlyText:GetHeight();
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
	contentHeight = contentHeight + ACTIVITY_GROUP_SPACER_HEIGHT * (numActivityGroups - 1); -- Gaps between activity groups.
	if ( self.CompletedEncounterHeader:IsShown() ) then
		contentHeight = contentHeight + self.CompletedEncounterHeader:GetHeight();
		contentHeight = contentHeight + 8;
	end
	for fontString in self.completedEncounterPool:EnumerateActive() do
		contentHeight = contentHeight + fontString:GetHeight();
	end
	self:SetHeight(contentHeight);
end

-------------------------------------------------------
----------Group Data Display
-------------------------------------------------------
function LFGBrowseGroupDataDisplay_Update(self, displayType, maxNumPlayers, displayData, disabled, isSolo, soloRoles, comment)
	if(not displayType) then
		return;
	end

	self.Solo:Hide();
	self.RoleCount:Hide();
	self.Enumerate:Hide();
	self.PlayerCount:Hide();
	self.Comment:Hide();

	if ( displayType == Enum.LFGListDisplayType.Comment ) then
		self.Comment:Show();
		LFGBrowseGroupDataDisplayComment_Update(self.Comment, comment, disabled);
	elseif ( displayData ) then
		if ( isSolo ) then
			self.Solo:Show();
			LFGBrowseGroupDataDisplaySolo_Update(self.Solo, soloRoles, disabled);
		elseif ( displayType == Enum.LFGListDisplayType.RoleCount ) then
			self.RoleCount:Show();
			LFGBrowseGroupDataDisplayRoleCount_Update(self.RoleCount, displayData, disabled);
		elseif ( displayType == Enum.LFGListDisplayType.RoleEnumerate ) then
			self.Enumerate:Show();
			LFGBrowseGroupDataDisplayEnumerate_Update(self.Enumerate, maxNumPlayers, displayData, disabled, LFGBROWSE_GROUPDATA_ROLE_ORDER);
		elseif ( displayType == Enum.LFGListDisplayType.ClassEnumerate ) then
			self.Enumerate:Show();
			LFGBrowseGroupDataDisplayEnumerate_Update(self.Enumerate, maxNumPlayers, displayData, disabled, LFGBROWSE_GROUPDATA_CLASS_ORDER);
		elseif ( displayType == Enum.LFGListDisplayType.PlayerCount ) then
			self.PlayerCount:Show();
			LFGBrowseGroupDataDisplayPlayerCount_Update(self.PlayerCount, displayData, disabled);
		elseif ( displayType ~= Enum.LFGListDisplayType.HideAll ) then
			GMError("Unknown display type");
		end
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

function LFGBrowseGroupDataDisplaySolo_Update(self, soloRoles, disabled)
	if (disabled) then
		self.RolesText:SetTextColor(LFGBROWSE_DELISTED_FONT_COLOR.r, LFGBROWSE_DELISTED_FONT_COLOR.g, LFGBROWSE_DELISTED_FONT_COLOR.b);
	else
		self.RolesText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end

	if (soloRoles and (soloRoles.tank or soloRoles.healer or soloRoles.dps)) then
		-- If we have at least one role, show it!
		LFGBrowseUtil_MapRoleStatesToRoleIcons(self.Roles, soloRoles.tank, soloRoles.healer, soloRoles.dps, true, disabled);
		self:Show();
	else
		self:Hide();
	end
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
function LFGBrowseMixin:CreateSearchEntryMenu(searchEntry)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(searchEntry.resultID);
	if (searchResultInfo == nil) then
		return;
	end

	MenuUtil.CreateContextMenu(LFGBrowseFrame.SearchEntryDropDown, function(owner, rootDescription)
		-- Leader Name (Title)
		rootDescription:CreateTitle(searchResultInfo.leaderName);

		-- Send Message
		local sendMessageButton = rootDescription:CreateButton(SEND_MESSAGE, function()
			ChatFrameUtil.SendTell(searchResultInfo.leaderName);
		end);
		sendMessageButton:SetEnabled(searchResultInfo.leaderName ~= nil);

		-- Invite Function
		local inviteText, inviteFunc = LFGBrowseUtil_GetInviteActionForResult(searchEntry.resultID);
		local inviteButton = rootDescription:CreateButton(inviteText, inviteFunc);
		inviteButton:SetEnabled(inviteFunc ~= nil);

		-- Report Group
		local reportGroupButton = rootDescription:CreateButton(LFG_LIST_REPORT_GROUP_FOR, function()
			LFGBrowseUtil_ReportListing(searchEntry.resultID, searchResultInfo.leaderName);
		end);

		-- Report Group (Advertisement)
		local reportAdvertisementButton = rootDescription:CreateButton(REPORT_GROUP_FINDER_ADVERTISEMENT, function()
			LFGBrowseUtil_ReportAdvertisement(searchEntry.resultID, searchResultInfo.leaderName);
		end);

	end);
end

-------------------------------------------------------
----------LFGBrowseCategoryDropdownMixin
-------------------------------------------------------
LFGBrowseCategoryDropdownMixin = {};

function LFGBrowseCategoryDropdownMixin:OnLoad()
	self:SetWidth(118);
	self:SetDefaultText(CATEGORY);
	self:SetSelectionTranslator(function(selection)
		return selection.text;
	end);
	self:Reset();
end

function LFGBrowseCategoryDropdownMixin:SetupDropdown()
	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_LFG_BROWSE_CATEGORY");

		local function IsSelected(value)
			return self:GetValue() == value;
		end
		local function SetSelected(value)
			self:SetValue(value);
			LFGBrowseCategoryButton_OnClick();
		end

		local hasActiveEntry = C_LFGList.HasActiveEntryInfo();
		local categories = C_LFGList.GetAvailableCategories();

		if (#categories == 0 and not hasActiveEntry) then
			rootDescription:CreateRadio(LFG_TYPE_NONE);
		else
			if (hasActiveEntry) then
				rootDescription:CreateRadio(LFG_SELF_LISTING, function() return false; end, function() LFGBrowseFrame:SearchActiveEntry(); end);
			end

			for i=1, #categories do
				local activities = LFGUtil_GetFilteredActivities(categories[i]);
				if (#activities ~= 0) then
					local categoryInfo = C_LFGList.GetLfgCategoryInfo(categories[i]);
					rootDescription:CreateRadio(categoryInfo.name, IsSelected, SetSelected, categories[i]);
				end
			end
		end
	end);
end

function LFGBrowseCategoryDropdownMixin:GetValue()
	return self.selectedCategoryID;
end

function LFGBrowseCategoryDropdownMixin:SetValue(value)
	self.selectedCategoryID = value;
	self:SetupDropdown();
end

function LFGBrowseCategoryDropdownMixin:Reset()
	self:SetValue(0);
end

function LFGBrowseCategoryButton_OnClick()
	LFGBrowseFrame.ActivityDropdown:Reset();
	LFGBrowse_DoSearch();
end

-------------------------------------------------------
----------LFGBrowseActivityDropdownMixin
-------------------------------------------------------
LFGBrowseActivityDropdownMixin = {};

function LFGBrowseActivityDropdownMixin:OnLoad()
	self.selectedValues = {};
	self:SetWidth(167);
	self:SetDefaultText(LFGBROWSE_ACTIVITY_HEADER_DEFAULT);
	self:UpdateHeader();
	self:Reset();
end

function LFGBrowseActivityDropdownMixin:SetupDropdown()
	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_LFG_BROWSE_ACTIVITY");

		local function IsActivitySelected(value)
			return self:ValueIsSelected(value);
		end
		local function IsActivityGroupSelected(value)
			return self:IsAnyValueSelectedForActivityGroup(value);
		end
		local function SelectActivity(value)
			self:ValueToggleSelected(value);
		end
		local function SelectActivityGroup(value)
			self:SetAllValuesForActivityGroup(value, not self:IsAnyValueSelectedForActivityGroup(value));
			LFGBrowse_DoSearch();
		end

		local selectedType = LFGBrowseFrame.CategoryDropdown:GetValue();
		if ( selectedType > 0 ) then
			self:SetEnabled(true);

			local activities = LFGUtil_GetFilteredActivities(selectedType);

			if (#activities > 0) then
				local organizedActivities = LFGUtil_OrganizeActivitiesByActivityGroup(activities);
				local activityGroupIDs = GetKeysArray(organizedActivities);
				LFGUtil_SortActivityGroupIDs(activityGroupIDs);

				for _, activityGroupID in ipairs(activityGroupIDs) do
					local activityIDs = organizedActivities[activityGroupID];
					if (activityGroupID == 0) then
						-- Free-floating activities (no group)
						for _, activityID in pairs(activityIDs) do
							local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
							local activityText = LFGUtil_GetActivityInfoName(activityInfo);

							rootDescription:CreateCheckbox(activityText, IsActivitySelected, SelectActivity, activityID);
						end
					else
						-- Grouped activities.
						local activityGroupText = C_LFGList.GetActivityGroupInfo(activityGroupID);
						local activityGroupCheckbox = rootDescription:CreateCheckbox(activityGroupText, IsActivityGroupSelected, SelectActivityGroup, activityGroupID);

						-- Determine the menu formatting based on how many groups we have.
						local parentMenu = rootDescription; -- If we only have one activityGroup, do everything in one menu (rootDescription) with indents for the individual activities.
						local textIndent = LFG_LIST_INDENT;
						if (#activityGroupIDs > 1) then
							parentMenu = activityGroupCheckbox; -- If we have more than one activityGroup, then group the activities into sub-menus based on the groups.
							textIndent = "%s";
						end

						for _, activityID in pairs(activityIDs) do
							local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
							local activityText = string.format(textIndent, LFGUtil_GetActivityInfoName(activityInfo));

							parentMenu:CreateCheckbox(activityText, IsActivitySelected, SelectActivity, activityID);
						end
					end
				end
			end
		else
			-- If we have no category selected, disable this dropdown.
			self:SetEnabled(false);
			self:ValueReset();
		end
	end);
end

function LFGBrowseActivityDropdownMixin:Reset()
	self:ValueReset();
	self:SetupDropdown();
end

function LFGBrowseActivityDropdownMixin:SetAllValuesForActivityGroup(activityGroupID, selected)
	local selectedType = LFGBrowseFrame.CategoryDropdown:GetValue();

	if ( selectedType > 0 ) then
		local activities = LFGUtil_GetFilteredActivities(selectedType);
		for i=1, #activities do
			if (LFGUtil_GetActivityGroupForActivity(activities[i]) == activityGroupID) then
				self:ValueSetSelected(activities[i], selected);
			end
		end
	end
end

function LFGBrowseActivityDropdownMixin:IsAnyValueSelectedForActivityGroup(activityGroupID)
	local selectedType = LFGBrowseFrame.CategoryDropdown:GetValue();

	if ( selectedType > 0 ) then
		local activities = LFGUtil_GetFilteredActivities(selectedType);
		for i=1, #activities do
			if (LFGUtil_GetActivityGroupForActivity(activities[i]) == activityGroupID) then
				if (self:ValueIsSelected(activities[i])) then
					return true;
				end
			end
		end
	end

	return false;
end

function LFGBrowseActivityDropdownMixin:ValueReset()
	wipe(self.selectedValues);
	self:UpdateHeader();
end

function LFGBrowseActivityDropdownMixin:ValueIsSelected(value)
	return tContains(self.selectedValues, value);
end

function LFGBrowseActivityDropdownMixin:ValueSetSelected(value, selected)
	if (selected) then
		if (not tContains(self.selectedValues, value)) then
			tinsert(self.selectedValues, value);
		end
	else
		tDeleteItem(self.selectedValues, value);
	end
	self:UpdateHeader();
end

function LFGBrowseActivityDropdownMixin:ValueToggleSelected(value)
	self:ValueSetSelected(value, not self:ValueIsSelected(value));
end

function LFGBrowseActivityDropdownMixin:UpdateHeader()
	if #self.selectedValues == 0 then
		self:OverrideText(LFGBROWSE_ACTIVITY_HEADER_DEFAULT);
		self.ResetButton:Hide();
	elseif #self.selectedValues == 1 then
		local activityInfo = C_LFGList.GetActivityInfoTable(self.selectedValues[1]);
		self:OverrideText(LFGUtil_GetActivityInfoName(activityInfo));
		self.ResetButton:Show();
	else
		self:OverrideText(string.format(LFGBROWSE_ACTIVITY_HEADER, #self.selectedValues));
		self.ResetButton:Show();
	end
end

function LFGBrowseActivityDropDownResetButton_OnClick(self)
	self:GetParent():ValueReset();
	LFGBrowse_DoSearch();
end

-------------------------------------------------------
----------Options Button
-------------------------------------------------------
LFGBrowseOptionsButton = { };

function LFGBrowseOptionsButton:OnLoad()
	self:SetupOptionsMenu();
end

function LFGBrowseOptionsButton:SetupOptionsMenu()
	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_LFG_LISTING_SETTINGS");

		local function getIgnoreSelectedLevel()
			return GetCVarBool("disableSuggestedLevelActivityFilter");
		end;
		local function setIgnoreSelectedLevel()
			SetCVar("disableSuggestedLevelActivityFilter", not getIgnoreSelectedLevel());
		end;
		rootDescription:CreateCheckbox(LFG_LIST_IGNORE_SUGGESTED_LEVEL, getIgnoreSelectedLevel, setIgnoreSelectedLevel);
	end);
end

-------------------------------------------------------
----------Buttons
-------------------------------------------------------
function LFGBrowseGroupInviteButton_OnClick(self, button)
	self.inviteFunc();
end

function LFGBrowseSendMessageButton_OnClick(self, button)
	local selectedElement = LFGBrowseFrame.selectionBehavior:GetSelectedElementData()[1];
	if (selectedElement) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(selectedElement.resultID);
		if (searchResultInfo) then
			ChatFrameUtil.SendTell(searchResultInfo.leaderName);
		end
	end
end

-------------------------------------------------------
----------Util
-------------------------------------------------------
local function HasRemainingSlotsForLocalPlayerRole(lfgSearchResultID)
	local roles = C_LFGList.GetSearchResultMemberCounts(lfgSearchResultID);
	local playerRoles = C_LFGListRoles.GetRoles();
	local canTank = roles["TANK_REMAINING"] > 0 and playerRoles.tank;
	local canHeal = roles["HEALER_REMAINING"] > 0 and playerRoles.healer;
	local canDPS = roles["DAMAGER_REMAINING"] > 0 and playerRoles.dps;
	local hasSlotForRole = canTank or canHeal or canDPS;
	return hasSlotForRole, canTank, canHeal, canDPS;
end

function LFGBrowseUtil_SortSearchResults(results)
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	local activeEntryUseDungeonRoles = false;
	if (activeEntryInfo) then
		for _, activityID in ipairs(activeEntryInfo.activityIDs) do
			local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
			if (activityInfo and activityInfo.useDungeonRoleExpectations) then
				activeEntryUseDungeonRoles = true;
				break;
			end
		end
	end
	local groupMemberCounts = GetGroupMemberCounts();

	local function SortCB(searchResultID1, searchResultID2)
		local searchResultInfo1 = C_LFGList.GetSearchResultInfo(searchResultID1);
		local searchResultInfo2 = C_LFGList.GetSearchResultInfo(searchResultID2);

		local hasSelf1 = searchResultInfo1.hasSelf;
		local hasSelf2 = searchResultInfo2.hasSelf;
		if (hasSelf1 ~= hasSelf2) then
			return hasSelf1; -- Always put self at the top.
		end

		-- Prioritize results that have a match.
		if (activeEntryInfo) then
			local matchingActivity1 = false;
			local matchingActivity2 = false;
			for _, activityID in ipairs(activeEntryInfo.activityIDs) do
				if (not matchingActivity1 and tContains(searchResultInfo1.activityIDs, activityID)) then
					matchingActivity1 = true;
				end
				if (not matchingActivity2 and tContains(searchResultInfo2.activityIDs, activityID)) then
					matchingActivity2 = true;
				end
			end

			if (matchingActivity1 ~= matchingActivity2) then
				return matchingActivity1;
			end
		end

		local isSolo1 = searchResultInfo1.numMembers == 1;
		local isSolo2 = searchResultInfo2.numMembers == 1;
		if (isSolo1 ~= isSolo2) then
			if (IsInGroup()) then
				return isSolo1; -- When in a group, solo players go to the top.
			else
				return isSolo2; -- When solo, groups go to the top.
			end
		end

		if (isSolo1) then
			-- For solo players, canTank > canHeal > canDPS > timeInQueue.
			-- Role ordering will change based on party if we're listed for a dungeon.
			local roleOrderings = {"TANK", "HEALER", "DAMAGER"};
			if (activeEntryUseDungeonRoles and groupMemberCounts) then
				if (groupMemberCounts["TANK"] >= LFGBROWSE_DUNGEON_NUM_TANKS_EXPECTED) then
					tDeleteItem(roleOrderings, "TANK");
					tinsert(roleOrderings, "TANK");
				end
				if (groupMemberCounts["HEALER"] >= LFGBROWSE_DUNGEON_NUM_HEALERS_EXPECTED) then
					tDeleteItem(roleOrderings, "HEALER");
					tinsert(roleOrderings, "HEALER");
				end
				if (groupMemberCounts["DAMAGER"] >= LFGBROWSE_DUNGEON_NUM_DPS_EXPECTED) then
					tDeleteItem(roleOrderings, "DAMAGER");
					tinsert(roleOrderings, "DAMAGER");
				end
			end

			local roles1 = C_LFGList.GetSearchResultMemberCounts(searchResultID1);
			local roles2 = C_LFGList.GetSearchResultMemberCounts(searchResultID2);
			for _, desiredRole in ipairs(roleOrderings) do
				local canPerformRole1 = roles1["LEADER_ROLE_" .. desiredRole];
				local canPerformRole2 = roles2["LEADER_ROLE_" .. desiredRole];
				if (canPerformRole1 ~= canPerformRole2) then
					return canPerformRole1;
				end
				if (canPerformRole1) then
					-- If we found a role that both players can perform, then they're both equally desired as far as role diffentiation goes.
					break;
				end
			end
		else
			-- For groups, hasSlotForRole > groupSize > canTank > canHeal > timeInQueue.

			-- Groups with one of your current roles available are preferred.
			local hasSlotForRole1, canTank1, canHeal1, canDPS1 = HasRemainingSlotsForLocalPlayerRole(searchResultID1);
			local hasSlotForRole2, canTank2, canHeal2, canDPS2 = HasRemainingSlotsForLocalPlayerRole(searchResultID2);
			if (hasSlotForRole1 ~= hasSlotForRole2) then
				return hasSlotForRole1;
			end

			-- If both groups can accommodate one or more of our roles, prioritize the larger group.
			if (searchResultInfo1.numMembers ~= searchResultInfo2.numMembers) then
				return searchResultInfo1.numMembers > searchResultInfo2.numMembers;
			end

			-- If both groups are the same size... we'll start looking at the particular roles. Groups that need more in-demand roles should be higher.
			if (canTank1 ~= canTank2) then
				return canTank1;
			end
			if (canHeal1 ~= canHeal2) then
				return canHeal1;
			end
		end

		-- If we've gotten this far, prioritize the older one.
		if (searchResultInfo1.age ~= searchResultInfo2.age) then
			return searchResultInfo1.age > searchResultInfo2.age;
		end

		--If we aren't sorting by anything else, just go by ID
		return searchResultID1 < searchResultID2;
	end

	table.sort(results, SortCB);
end

function LFGBrowseUtil_GetInviteActionForResult(resultID)
	local inviteText = GROUP_INVITE;
	local inviteFunc = nil;
	if (resultID) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
		if (searchResultInfo) then
			local resultIsEligible = searchResultInfo.numMembers == 1;
			local playerCanInvite = not IsInGroup() or (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"));
			if (resultIsEligible and playerCanInvite) then
				inviteText = GROUP_INVITE;
				inviteFunc = function() InviteToGroup(searchResultInfo.leaderName); end;
			end
		end
	end

	return inviteText, inviteFunc;
end
function LFGBrowseUtil_MapRoleStatesToRoleIcons(iconArray, isTank, isHealer, isDPS, useSimple, useDisabled)
	-- For each role flag, put its icon in the first available button slot. Then hide the rest.
	-- iconArray must be an array of (at least) 3 Textures.
	local roleStates = { isTank, isHealer, isDPS };
	local roleButtonIndex = 1;
	for i, roleEnabled in ipairs(roleStates) do
		if (roleEnabled) then
			local atlasKey = LFGBROWSE_GROUPDATA_ROLE_ORDER[i];
			if (useSimple) then
				atlasKey = "SOLO_" .. atlasKey;
			end
			iconArray[roleButtonIndex]:SetAtlas(LFGBROWSE_GROUPDATA_ATLASES[atlasKey], false);
			iconArray[roleButtonIndex]:SetDesaturated(useDisabled);
			iconArray[roleButtonIndex]:Show();
			roleButtonIndex = roleButtonIndex+1;
		end
	end
	for j = roleButtonIndex,#iconArray do
		iconArray[j]:Hide();
	end
end

function LFGBrowseUtil_ReportListing(searchResultID, leaderName)
	local reportInfo = ReportInfo:CreateReportInfoFromType(Enum.ReportType.GroupFinderPosting);
	reportInfo:SetGroupFinderSearchResultID(searchResultID);
	ReportFrame:InitiateReport(reportInfo, leaderName);
end

function LFGBrowseUtil_ReportAdvertisement(searchResultID, leaderName)
	ReportFrame:Hide(); -- Since we're about to submit a brand new report, close any existing report frames.
	local reportInfo = ReportInfo:CreateReportInfoFromType(Enum.ReportType.GroupFinderPosting);
	reportInfo:SetGroupFinderSearchResultID(searchResultID);
	ReportFrame:SetMinorCategoryFlag(Enum.ReportMinorCategory.Advertisement, true);
	ReportFrame:SetMajorType(Enum.ReportMajorCategory.InappropriateCommunication);
	local sendReportWithoutDialog = true;
	ReportFrame:InitiateReport(reportInfo, leaderName, nil, nil, sendReportWithoutDialog);
end

function LFGBrowseUtil_GetBestDisplayTypeForActivityIDs(activityIDs)
	local bestDisplayType = nil;
	local bestDisplayTypePriority = 0;
	local maxNumPlayers = 0;

	for _, activityID in ipairs(activityIDs) do
		local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
		if (activityInfo) then
			local displayTypePriority = LFGBROWSE_DISPLAYTYPE_PRIORITY[activityInfo.displayType];
			if (displayTypePriority and displayTypePriority > bestDisplayTypePriority) then
				bestDisplayType = activityInfo.displayType;
				bestDisplayTypePriority = displayTypePriority;
			end
			if (activityInfo.maxNumPlayers > maxNumPlayers) then
				maxNumPlayers = activityInfo.maxNumPlayers;
			end
		end
	end


	return bestDisplayType, maxNumPlayers;
end
